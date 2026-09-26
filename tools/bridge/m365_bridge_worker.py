#!/usr/bin/env python3
"""M365 Outbound Bridge Worker for SharePoint Lists (CDEDocuments & Opportunities).

Architecture:
- M365Config / BridgeConfig: Configuration loader from environment variables or .env.
- TokenBucketRateLimiter: Coroutine-safe rate limiter (5 req/s) with acquire() supporting backoff,
  parsing Retry-After header in both integer seconds and RFC 2822 HTTP-Date formats with UTC normalization.
- M365TokenManager: App-Only authentication integrated with tools.auth.graph_auth (PKCS#12 .pfx support),
  with proactive refresh (< 300s) and async lock to prevent thundering herd.
- LoopBreaker: 3-tier echo loop suppression (author app ID matching, in-memory LRU cache of
  recently updated (list, id, eTag) with 15-minute TTL, SHA-256 payload hash comparison).
- ResilientGraphClient: HTTP client wrapper (using httpx.AsyncClient) with full-jitter
  exponential backoff, rate limiting, and HTTP 429 / 5xx handling.
- DeadLetterQueue: DLQ isolation recording failed records to local SQLite table (sync_dlq)
  located at tools/output/state/m365_bridge.db.
- DeltaSyncEngine: Delta query implementation (GET .../items/delta?$expand=fields), tracking @odata.deltaLink,
  processing @removed deletions, and handling HTTP 410 Gone (delta token expired) by clearing
  state and resetting to full sync. Integrates Pydantic v2 validation guard with DLQ fallback.
- OutboundSyncEngine: Push updates to SharePoint Lists with Optimistic Concurrency Control (OCC).
- M365BridgeWorker: Coordinator with CLI interface supporting --dry-run, --once,
  --list CDEDocuments|Opportunities.
"""

from __future__ import annotations

import argparse
import asyncio
from datetime import datetime, timezone
import email.utils
import hashlib
import json
import logging
import os
from pathlib import Path
import random
import sqlite3
import sys
import time
from typing import Any, Dict, List, Optional, Tuple

from dotenv import load_dotenv
import httpx
import msal

# Project Root directory of IDOP-CCBA-WAY
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
load_dotenv(PROJECT_ROOT / ".env", override=False)

# Optional imports from repository modules
try:
    from tools.auth.graph_auth import get_graph_client
except ImportError:
    get_graph_client = None  # type: ignore[assignment]

try:
    from pydantic import ValidationError
    from tools.validator.models import CDEDocumentsItem, OpportunitiesItem
    HAS_MODELS = True
except ImportError:
    ValidationError = Exception  # type: ignore[assignment,misc]
    CDEDocumentsItem = None  # type: ignore[assignment]
    OpportunitiesItem = None  # type: ignore[assignment]
    HAS_MODELS = False

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [%(name)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("m365_bridge")


class M365Config:
    """Configuration loader for Microsoft 365 SharePoint Online integration.

    Loads credentials, site URLs, list definitions, and rate limiting parameters
    from environment variables or constructor arguments.
    """

    def __init__(
        self,
        tenant_id: Optional[str] = None,
        client_id: Optional[str] = None,
        client_secret: Optional[str] = None,
        cert_path: Optional[str] = None,
        cert_password: Optional[str] = None,
        idop_site_url: Optional[str] = None,
        cde_site_url: Optional[str] = None,
        idop_site_id: Optional[str] = None,
        cde_site_id: Optional[str] = None,
        rate_limit_rps: Optional[float] = None,
        rate_limit_burst: Optional[int] = None,
        sync_interval_seconds: Optional[int] = None,
        database_url: Optional[str] = None,
        dlq_db_path: Optional[str] = None,
        chatops_gateway_url: Optional[str] = None,
        chatops_internal_secret: Optional[str] = None,
    ) -> None:
        """Initialize M365Config with environment fallbacks."""
        self.tenant_id = (
            tenant_id
            or os.environ.get("IDOP_SP_TENANT")
            or os.environ.get("IDOP_SP_TENANT_ID")
            or os.environ.get("M365_TENANT_ID")
            or os.environ.get("TENANT_ID")
            or "d7aa4978-363e-47aa-a77e-7da957b32bf3"
        )
        self.client_id = (
            client_id
            or os.environ.get("IDOP_SP_CLIENT_ID")
            or os.environ.get("M365_CLIENT_ID")
            or os.environ.get("CLIENT_ID")
            or "c055c7a4-9150-4bd5-bf01-445c65467feb"
        )
        self.client_secret = (
            client_secret
            or os.environ.get("IDOP_SP_CLIENT_SECRET")
            or os.environ.get("M365_CLIENT_SECRET")
            or os.environ.get("CLIENT_SECRET")
            or ""
        )
        self.cert_path = (
            cert_path
            or os.environ.get("IDOP_SP_CERT_PATH")
            or os.environ.get("M365_CERTIFICATE_PATH")
            or ""
        )
        self.cert_password = (
            cert_password
            or os.environ.get("IDOP_SP_CERT_PASSWORD")
            or ""
        )

        # SharePoint Sites URLs (IDOP Non-Negotiable 3: Single Production Site)
        self.idop_site_url = (
            idop_site_url
            or os.environ.get("IDOP_SP_URL")
            or os.environ.get("M365_IDOP_SITE_URL")
            or "https://ibstbim.sharepoint.com/sites/idop"
        )
        self.cde_site_url = (
            cde_site_url
            or os.environ.get("IDOP_CDE_URL")
            or os.environ.get("M365_CDE_SITE_URL")
            or "https://ibstbim.sharepoint.com/sites/idop"
        )

        # Graph Site IDs ({hostname},{site-id},{web-id})
        self.idop_site_id = (
            idop_site_id
            or os.environ.get("IDOP_SITE_ID")
            or os.environ.get("M365_IDOP_SITE_ID")
            or "ibstbim.sharepoint.com,idop-site-collection-id,idop-web-id"
        )
        self.cde_site_id = (
            cde_site_id
            or os.environ.get("CDE_SITE_ID")
            or os.environ.get("M365_CDE_SITE_ID")
            or self.idop_site_id
        )

        # Rate Limiting & Polling
        self.rate_limit_rps = float(
            rate_limit_rps
            or os.environ.get("M365_RATE_LIMIT_RPS")
            or 5.0
        )
        self.rate_limit_burst = int(
            rate_limit_burst
            or os.environ.get("M365_RATE_LIMIT_BURST")
            or 10
        )
        self.sync_interval_seconds = int(
            sync_interval_seconds
            or os.environ.get("M365_SYNC_INTERVAL")
            or os.environ.get("POLL_INTERVAL")
            or 60
        )

        # Database & Storage (stored in tools/output/state/ under .gitignore)
        self.database_url = (
            database_url
            or os.environ.get("DATABASE_URL")
            or ""
        )
        default_dlq_path = str(PROJECT_ROOT / "tools" / "output" / "state" / "m365_bridge.db")
        self.dlq_db_path = (
            dlq_db_path
            or os.environ.get("M365_DLQ_DB_PATH")
            or default_dlq_path
        )

        # ChatOps Alerting
        self.chatops_gateway_url = (
            chatops_gateway_url
            or os.environ.get("CHATOPS_GATEWAY_URL")
            or "http://127.0.0.1:8095"
        )
        self.chatops_internal_secret = (
            chatops_internal_secret
            or os.environ.get("CHATOPS_INTERNAL_SECRET")
            or ""
        )

    def has_credentials(self) -> bool:
        """Check whether valid client credentials or certificates are configured."""
        return bool(self.client_secret or (self.cert_path and os.path.exists(self.cert_path)))


# Alias for backward/forward compatibility
BridgeConfig = M365Config


class TokenBucketRateLimiter:
    """Thread-safe and coroutine-safe Token Bucket Rate Limiter.

    Maintains a burst capacity and replenishes tokens at a sustained rate.
    Supports parsing Microsoft Graph Retry-After headers in both integer seconds
    and RFC 2822 HTTP-Date formats with timezone-aware UTC normalization.
    """

    def __init__(self, rate_per_second: float = 5.0, capacity: int = 10) -> None:
        """Initialize TokenBucketRateLimiter.

        Args:
            rate_per_second: Token generation rate per second (default: 5.0).
            capacity: Maximum burst capacity in tokens (default: 10).
        """
        self.rate = float(rate_per_second)
        self.capacity = float(capacity)
        self.tokens = float(capacity)
        self.last_update = time.monotonic()
        self._lock = asyncio.Lock()

    async def acquire(self, tokens: float = 1.0) -> float:
        """Acquire specified tokens, sleeping if required.

        Args:
            tokens: Number of tokens to consume (default: 1.0).

        Returns:
            Total wait time in seconds (0.0 if tokens were immediately available).
        """
        total_waited = 0.0
        async with self._lock:
            while True:
                now = time.monotonic()
                elapsed = now - self.last_update
                self.last_update = now
                self.tokens = min(self.capacity, self.tokens + elapsed * self.rate)

                if self.tokens >= tokens:
                    self.tokens -= tokens
                    return total_waited

                needed = tokens - self.tokens
                wait_time = needed / self.rate
                total_waited += wait_time
                await asyncio.sleep(wait_time)

    @staticmethod
    def parse_retry_after(
        retry_after_header: Optional[str],
        attempt: int = 1,
        base_backoff: float = 2.0,
    ) -> float:
        """Parse Retry-After header into delay seconds.

        Handles:
        1. Integer seconds (e.g. "12")
        2. RFC 2822 HTTP-Date (e.g. "Fri, 26 Sep 2026 09:30:00 GMT")
        3. Fallback: Full-jitter exponential backoff

        Args:
            retry_after_header: Raw HTTP header value or None.
            attempt: Current retry attempt count (1-indexed).
            base_backoff: Base backoff time in seconds.

        Returns:
            Calculated wait duration in seconds.
        """
        if retry_after_header:
            cleaned = retry_after_header.strip()
            # Format 1: Integer seconds
            if cleaned.isdigit():
                return max(0.0, float(cleaned))

            # Format 2: RFC 2822 HTTP-Date
            try:
                target_dt = email.utils.parsedate_to_datetime(cleaned)
                if target_dt.tzinfo is None:
                    target_dt = target_dt.replace(tzinfo=timezone.utc)
                now_dt = datetime.now(timezone.utc)
                diff = (target_dt - now_dt).total_seconds()
                return max(0.0, diff)
            except Exception:
                pass

        # Format 3: Fallback Exponential Backoff with Full Jitter
        max_backoff = min(60.0, base_backoff * (2 ** attempt))
        return random.uniform(0.1, max_backoff)

    async def wait_retry_after(
        self,
        retry_after_header: Optional[str],
        attempt: int = 1,
        base_backoff: float = 2.0,
    ) -> float:
        """Calculate wait time from Retry-After header and sleep.

        Args:
            retry_after_header: Raw Retry-After header.
            attempt: Current retry attempt.
            base_backoff: Base backoff multiplier.

        Returns:
            Seconds slept.
        """
        delay = self.parse_retry_after(retry_after_header, attempt=attempt, base_backoff=base_backoff)
        if delay > 0:
            await asyncio.sleep(delay)
        return delay


class M365TokenManager:
    """MSAL-based OAuth2 Client Credentials token manager.

    Features:
    - App-Only authentication (client_secret or PKCS#12 certificate via tools.auth.graph_auth).
    - Proactive refresh when remaining token lifetime is < 300 seconds.
    - Async lock to prevent thundering herd across concurrent requests.
    """

    def __init__(
        self,
        config: M365Config,
        app: Optional[Any] = None,
    ) -> None:
        """Initialize M365TokenManager.

        Args:
            config: M365Config instance.
            app: Optional pre-configured MSAL ConfidentialClientApplication (for testing/mocking).
        """
        self.config = config
        self.authority = f"https://login.microsoftonline.com/{config.tenant_id}"
        self.scopes = ["https://graph.microsoft.com/.default"]
        self._lock = asyncio.Lock()
        self._access_token: Optional[str] = None
        self._token_expires_at: float = 0.0

        if app is not None:
            self._app = app
        elif config.has_credentials():
            if config.cert_path and os.path.exists(config.cert_path):
                # Use tools.auth.graph_auth for PKCS#12 (.pfx) support
                try:
                    if get_graph_client is not None:
                        self._app = get_graph_client(
                            client_id=config.client_id,
                            tenant_id=config.tenant_id,
                            cert_path=config.cert_path,
                            cert_password=config.cert_password,
                        )
                    else:
                        raise ImportError("tools.auth.graph_auth.get_graph_client is not available")
                except Exception as exc:
                    logger.warning(f"Could not load certificate client: {exc}")
                    self._app = None
            elif config.client_secret:
                self._app = msal.ConfidentialClientApplication(
                    client_id=config.client_id,
                    authority=self.authority,
                    client_credential=config.client_secret,
                )
            else:
                self._app = None
        else:
            self._app = None

    def set_cached_token(self, access_token: str, expires_in: float = 3600.0) -> None:
        """Manually populate cached token (useful for tests and mocks)."""
        self._access_token = access_token
        self._token_expires_at = time.time() + float(expires_in)

    async def get_token(self) -> str:
        """Acquire a valid access token, performing proactive refresh if < 300s remaining.

        Returns:
            OAuth2 access token string.

        Raises:
            RuntimeError: If authentication fails.
            ValueError: If no credentials are configured.
        """
        async with self._lock:
            now = time.time()
            # Proactive refresh check: If cached token is valid for > 300s, return immediately
            if self._access_token and (self._token_expires_at - now) > 300.0:
                return self._access_token

            if self._app is not None:
                # 1. Attempt silent token acquisition from MSAL internal cache
                result = self._app.acquire_token_silent(self.scopes, account=None)
                if result and "access_token" in result:
                    expires_in = float(result.get("expires_in", 3600))
                    token_expiry = now + expires_in
                    if (token_expiry - now) > 300.0:
                        self._access_token = result["access_token"]
                        self._token_expires_at = token_expiry
                        return self._access_token

                # 2. Acquire token for client via Entra ID in executor thread
                loop = asyncio.get_running_loop()
                result = await loop.run_in_executor(
                    None, lambda: self._app.acquire_token_for_client(scopes=self.scopes)
                )

                if result and "access_token" in result:
                    self._access_token = result["access_token"]
                    expires_in = float(result.get("expires_in", 3600))
                    self._token_expires_at = now + expires_in
                    return self._access_token

                error_desc = result.get("error_description", result.get("error", "Unknown auth error"))
                raise RuntimeError(f"Microsoft Entra ID authentication failed: {error_desc}")

            # Fallback if cached token was manually set
            if self._access_token:
                return self._access_token

            raise ValueError("M365TokenManager: No client credentials or MSAL app configured.")


class LoopBreaker:
    """3-Tier Echo Loop Suppression for Bidirectional Synchronization.

    Prevents infinite feedback loops where Spark updates SharePoint,
    which triggers delta sync, which triggers another Spark update.

    Tiers:
    - Tier 1: Matching author Application ID (item.lastModifiedBy.application.id == spark_client_id).
    - Tier 2: In-memory LRU cache of recently updated (list, id, eTag) with 15-minute TTL.
    - Tier 3: SHA-256 payload hash comparison on core business fields.
    """

    def __init__(self, ttl_seconds: int = 900) -> None:
        """Initialize LoopBreaker.

        Args:
            ttl_seconds: Cache retention time in seconds (default: 900s / 15 minutes).
        """
        self.ttl = float(ttl_seconds)
        # (list_name, item_id, etag) -> monotonic_timestamp
        self._sent_etags: Dict[Tuple[str, str, str], float] = {}
        # (list_name, item_id) -> sha256_hash
        self._content_hashes: Dict[Tuple[str, str], str] = {}
        self._lock = asyncio.Lock()

    async def register_outbound_update(
        self,
        list_name: str,
        item_id: str,
        etag: str,
        payload: Dict[str, Any],
    ) -> None:
        """Register an outbound update pushed by Spark to SharePoint.

        Args:
            list_name: SharePoint list name.
            item_id: List item ID.
            etag: New eTag returned from SharePoint.
            payload: Field dictionary updated.
        """
        async with self._lock:
            now = time.monotonic()
            if etag:
                self._sent_etags[(list_name, str(item_id), etag)] = now
            self._content_hashes[(list_name, str(item_id))] = self.hash_payload(payload)
            self._cleanup(now)

    async def is_echo_event(
        self,
        list_name: str,
        item_id: str,
        etag: str,
        fields: Dict[str, Any],
        last_modified_app_id: Optional[str],
        spark_client_id: str,
    ) -> bool:
        """Check whether an incoming delta item is an echo of Spark's own changes.

        Args:
            list_name: Name of the SharePoint list.
            item_id: List item identifier.
            etag: Item eTag.
            fields: Item fields dictionary.
            last_modified_app_id: Application ID of the last modifying identity.
            spark_client_id: Spark application client ID.

        Returns:
            True if this is an echo event (must be suppressed), False otherwise.
        """
        # Tier 1: Matching author Application ID
        if last_modified_app_id and spark_client_id:
            if last_modified_app_id.strip().lower() == spark_client_id.strip().lower():
                return True

        async with self._lock:
            now = time.monotonic()
            self._cleanup(now)

            # Tier 2: In-memory LRU cache of recently updated (list, id, eTag)
            if etag and (list_name, str(item_id), etag) in self._sent_etags:
                return True

            # Tier 3: SHA-256 payload hash comparison
            current_hash = self.hash_payload(fields)
            last_hash = self._content_hashes.get((list_name, str(item_id)))
            if last_hash and last_hash == current_hash:
                return True

            # Record latest content hash
            self._content_hashes[(list_name, str(item_id))] = current_hash
            return False

    @staticmethod
    def hash_payload(payload: Dict[str, Any]) -> str:
        """Compute deterministic SHA-256 hash of a dictionary payload."""
        normalized = json.dumps(payload, sort_keys=True, default=str)
        return hashlib.sha256(normalized.encode("utf-8")).hexdigest()

    def _cleanup(self, now: float) -> None:
        """Evict expired eTag cache entries."""
        expired = [k for k, ts in self._sent_etags.items() if now - ts > self.ttl]
        for k in expired:
            del self._sent_etags[k]


class ResilientGraphClient:
    """HTTP client wrapper communicating with Microsoft Graph API.

    Features:
    - Built on top of httpx.AsyncClient.
    - Integrated with TokenBucketRateLimiter.
    - Automatic OAuth2 token injection.
    - Exponential backoff with full jitter on HTTP 429 and 5xx server errors.
    - Safe handling of 410 Gone and 412 Precondition Failed.
    """

    def __init__(
        self,
        token_manager: M365TokenManager,
        rate_limiter: TokenBucketRateLimiter,
        http_client: Optional[httpx.AsyncClient] = None,
        timeout: float = 30.0,
    ) -> None:
        """Initialize ResilientGraphClient.

        Args:
            token_manager: M365TokenManager instance.
            rate_limiter: TokenBucketRateLimiter instance.
            http_client: Optional httpx.AsyncClient instance.
            timeout: Request timeout in seconds.
        """
        self.token_manager = token_manager
        self.rate_limiter = rate_limiter
        self.client = http_client or httpx.AsyncClient(timeout=timeout)
        self._owned_client = http_client is None

    async def request(
        self,
        method: str,
        url: str,
        max_retries: int = 5,
        base_backoff: float = 2.0,
        **kwargs: Any,
    ) -> httpx.Response:
        """Execute HTTP request with rate limiting and retry backoff.

        Args:
            method: HTTP verb (GET, POST, PATCH, etc.).
            url: Target Microsoft Graph API endpoint.
            max_retries: Maximum retry attempts for transient errors.
            base_backoff: Base duration for backoff calculations.
            **kwargs: Extra parameters passed to httpx.request.

        Returns:
            httpx.Response object.

        Raises:
            TimeoutError: When retry limit is exceeded.
            httpx.RequestError: When network transport error persists.
        """
        for attempt in range(1, max_retries + 1):
            await self.rate_limiter.acquire()
            token = await self.token_manager.get_token()

            headers = dict(kwargs.get("headers") or {})
            headers.setdefault("Authorization", f"Bearer {token}")
            headers.setdefault("Accept", "application/json")
            kwargs["headers"] = headers

            try:
                response = await self.client.request(method, url, **kwargs)

                # Return on successful codes or business error codes that should NOT be retried
                # (e.g. 400 Bad Request, 404 Not Found, 410 Gone, 412 Precondition Failed)
                if response.status_code not in (429, 500, 502, 503, 504):
                    return response

                if attempt == max_retries:
                    return response

                # Rate limited (429) or transient server error (5xx)
                retry_header = response.headers.get("Retry-After")
                delay = await self.rate_limiter.wait_retry_after(
                    retry_header, attempt=attempt, base_backoff=base_backoff
                )
                logger.warning(
                    f"Graph API returned HTTP {response.status_code} on {url}. "
                    f"Retrying attempt {attempt}/{max_retries} after {delay:.2f}s..."
                )

            except (httpx.ConnectError, httpx.ReadTimeout, httpx.WriteTimeout, httpx.PoolTimeout) as exc:
                if attempt == max_retries:
                    raise
                delay = await self.rate_limiter.wait_retry_after(
                    None, attempt=attempt, base_backoff=base_backoff
                )
                logger.warning(
                    f"Network error on {url}: {exc}. "
                    f"Retrying attempt {attempt}/{max_retries} after {delay:.2f}s..."
                )

        raise TimeoutError(f"Exceeded max retries ({max_retries}) calling {url}")

    async def close(self) -> None:
        """Close the underlying HTTP client."""
        if self._owned_client:
            await self.client.aclose()

    async def __aenter__(self) -> "ResilientGraphClient":
        return self

    async def __aexit__(self, exc_type: Any, exc_val: Any, exc_tb: Any) -> None:
        await self.close()


class DeadLetterQueue:
    """Dead-Letter Queue (DLQ) for isolating failed sync records.

    Stores poison messages, schema validation errors, and unresolvable items
    into a local SQLite table (sync_dlq) after retry exhaustion, allowing inspection,
    remediation, and manual replay.
    """

    def __init__(
        self,
        db_path: str = ":memory:",
        chatops_url: Optional[str] = None,
        chatops_secret: Optional[str] = None,
    ) -> None:
        """Initialize DeadLetterQueue.

        Args:
            db_path: Path to SQLite database file or ':memory:'.
            chatops_url: Optional URL to ChatOps Gateway notify API.
            chatops_secret: Optional secret for ChatOps Gateway.
        """
        self.db_path = db_path
        self.chatops_url = chatops_url
        self.chatops_secret = chatops_secret
        self._shared_conn: Optional[sqlite3.Connection] = None
        if self.db_path == ":memory:":
            self._shared_conn = sqlite3.connect(":memory:")
            self._shared_conn.row_factory = sqlite3.Row
        self._ensure_tables()

    def _get_connection(self) -> sqlite3.Connection:
        """Get a database connection."""
        if self._shared_conn is not None:
            return self._shared_conn
        if self.db_path != ":memory:":
            os.makedirs(os.path.dirname(os.path.abspath(self.db_path)), exist_ok=True)
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _ensure_tables(self) -> None:
        """Create sync_dlq and system_checkpoints tables if not existing."""
        with self._get_connection() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS sync_dlq (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    sync_direction TEXT NOT NULL,
                    list_name TEXT NOT NULL,
                    item_id TEXT,
                    payload TEXT NOT NULL,
                    error_code TEXT,
                    error_message TEXT,
                    stack_trace TEXT,
                    retry_count INTEGER DEFAULT 0,
                    created_at TEXT NOT NULL,
                    resolved INTEGER DEFAULT 0,
                    resolved_at TEXT,
                    resolution_notes TEXT
                );
                """
            )
            conn.execute(
                """
                CREATE INDEX IF NOT EXISTS idx_sync_dlq_unresolved
                ON sync_dlq(resolved, list_name);
                """
            )
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS system_checkpoints (
                    checkpoint_key TEXT PRIMARY KEY,
                    delta_link TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                );
                """
            )
            conn.commit()

    def record_failure(
        self,
        sync_direction: str,
        list_name: str,
        item_id: Optional[str],
        payload: Any,
        error_code: str,
        error_message: str,
        stack_trace: str = "",
        retry_count: int = 0,
    ) -> int:
        """Record an unprocessable or exhausted record to DLQ.

        Args:
            sync_direction: 'PULL_DELTA' or 'PUSH_SHAREPOINT'.
            list_name: Target SharePoint list.
            item_id: Record identifier.
            payload: Data payload (dict, str, etc.).
            error_code: Error classification code.
            error_message: Detailed error message.
            stack_trace: Traceback string.
            retry_count: Number of retries attempted before isolation.

        Returns:
            Newly inserted DLQ record ID.
        """
        payload_str = json.dumps(payload, default=str) if not isinstance(payload, str) else payload
        now_iso = datetime.now(timezone.utc).isoformat()

        with self._get_connection() as conn:
            cursor = conn.execute(
                """
                INSERT INTO sync_dlq (
                    sync_direction, list_name, item_id, payload,
                    error_code, error_message, stack_trace, retry_count,
                    created_at, resolved
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0);
                """,
                (
                    sync_direction,
                    list_name,
                    str(item_id) if item_id is not None else None,
                    payload_str,
                    error_code,
                    error_message,
                    stack_trace,
                    retry_count,
                    now_iso,
                ),
            )
            conn.commit()
            dlq_id = int(cursor.lastrowid)

        logger.error(
            f"DLQ Isolated Record #{dlq_id} [{sync_direction} - {list_name} - Item {item_id}]: "
            f"Code {error_code}, Message: {error_message}"
        )
        self.notify_chatops(dlq_id, list_name, item_id, error_message)
        return dlq_id

    def notify_chatops(
        self,
        dlq_id: int,
        list_name: str,
        item_id: Optional[str],
        error_message: str,
    ) -> bool:
        """Send notification to ChatOps Gateway if configured.

        Args:
            dlq_id: ID of isolated record.
            list_name: Target list name.
            item_id: Optional item identifier.
            error_message: Error description.

        Returns:
            True if alert was dispatched successfully, False otherwise.
        """
        if not self.chatops_url or not self.chatops_secret:
            return False
        try:
            headers = {"X-ChatOps-Secret": self.chatops_secret, "Content-Type": "application/json"}
            payload = {
                "title": f"🚨 [M365 DLQ Alert] {list_name}",
                "body": f"Record ID #{dlq_id}\nItem: {item_id}\nError: {error_message}",
                "severity": "WARNING",
            }
            with httpx.Client(timeout=5.0) as client:
                res = client.post(f"{self.chatops_url.rstrip('/')}/api/v1/notify", headers=headers, json=payload)
                return res.status_code == 200
        except Exception as exc:
            logger.warning(f"Could not dispatch ChatOps notification for DLQ #{dlq_id}: {exc}")
            return False

    def get_unresolved(self, list_name: Optional[str] = None) -> List[Dict[str, Any]]:
        """Retrieve unresolved DLQ records.

        Args:
            list_name: Optional filter for specific list.

        Returns:
            List of dictionary records.
        """
        query = "SELECT * FROM sync_dlq WHERE resolved = 0"
        params: List[Any] = []
        if list_name:
            query += " AND list_name = ?"
            params.append(list_name)
        query += " ORDER BY id ASC;"

        with self._get_connection() as conn:
            cursor = conn.execute(query, params)
            rows = cursor.fetchall()
            return [dict(row) for row in rows]

    def mark_resolved(self, dlq_id: int, notes: str = "") -> bool:
        """Mark a DLQ record as resolved.

        Args:
            dlq_id: Target record ID.
            notes: Remediation notes.

        Returns:
            True if record was updated, False if not found.
        """
        now_iso = datetime.now(timezone.utc).isoformat()
        with self._get_connection() as conn:
            cursor = conn.execute(
                """
                UPDATE sync_dlq
                SET resolved = 1, resolved_at = ?, resolution_notes = ?
                WHERE id = ?;
                """,
                (now_iso, notes, dlq_id),
            )
            conn.commit()
            return cursor.rowcount > 0

    def get_all(self, limit: int = 100) -> List[Dict[str, Any]]:
        """Retrieve latest DLQ records up to limit."""
        with self._get_connection() as conn:
            cursor = conn.execute("SELECT * FROM sync_dlq ORDER BY id DESC LIMIT ?;", (limit,))
            return [dict(row) for row in cursor.fetchall()]


class DeltaSyncEngine:
    """Delta Query Synchronization Engine for SharePoint Lists.

    Features:
    - Tracks changes via GET .../items/delta?$expand=fields.
    - Persists @odata.deltaLink tokens per (site_id, list_name) to local SQLite storage.
    - Detects item deletions via @removed flags.
    - Recovers from HTTP 410 Gone (expired delta token) by clearing token
      and performing full sync.
    - Integrates with LoopBreaker to filter echo updates.
    - Validates payload against Pydantic models (tools.validator.models) with DLQ fallback.
    """

    def __init__(
        self,
        graph_client: ResilientGraphClient,
        loop_breaker: LoopBreaker,
        config: M365Config,
        dlq: Optional[DeadLetterQueue] = None,
        db_path: Optional[str] = None,
    ) -> None:
        """Initialize DeltaSyncEngine.

        Args:
            graph_client: ResilientGraphClient instance.
            loop_breaker: LoopBreaker instance.
            config: M365Config instance.
            dlq: Optional DeadLetterQueue instance.
            db_path: Optional SQLite database path for checkpoint persistence.
        """
        self.graph = graph_client
        self.loop_breaker = loop_breaker
        self.config = config
        self.dlq = dlq
        self.db_path = db_path or config.dlq_db_path
        self._memory_checkpoints: Dict[str, str] = {}
        self._ensure_storage()

    def _ensure_storage(self) -> None:
        """Ensure system_checkpoints table exists."""
        if self.db_path and self.db_path != ":memory:":
            os.makedirs(os.path.dirname(os.path.abspath(self.db_path)), exist_ok=True)
            try:
                with sqlite3.connect(self.db_path) as conn:
                    conn.execute(
                        """
                        CREATE TABLE IF NOT EXISTS system_checkpoints (
                            checkpoint_key TEXT PRIMARY KEY,
                            delta_link TEXT NOT NULL,
                            updated_at TEXT NOT NULL
                        );
                        """
                    )
                    conn.commit()
            except Exception as e:
                logger.warning(f"Could not initialize system_checkpoints in {self.db_path}: {e}")

    def get_checkpoint(self, site_id: str, list_name: str) -> Optional[str]:
        """Get stored delta link for a site and list."""
        key = f"delta:{site_id}:{list_name}"
        if self.db_path and self.db_path != ":memory:":
            try:
                with sqlite3.connect(self.db_path) as conn:
                    cursor = conn.execute(
                        "SELECT delta_link FROM system_checkpoints WHERE checkpoint_key = ?;",
                        (key,),
                    )
                    row = cursor.fetchone()
                    if row:
                        return str(row[0])
            except Exception:
                pass
        return self._memory_checkpoints.get(key)

    def save_checkpoint(self, site_id: str, list_name: str, delta_link: str) -> None:
        """Persist delta link for a site and list."""
        key = f"delta:{site_id}:{list_name}"
        now_iso = datetime.now(timezone.utc).isoformat()
        self._memory_checkpoints[key] = delta_link

        if self.db_path and self.db_path != ":memory:":
            try:
                with sqlite3.connect(self.db_path) as conn:
                    conn.execute(
                        """
                        INSERT INTO system_checkpoints (checkpoint_key, delta_link, updated_at)
                        VALUES (?, ?, ?)
                        ON CONFLICT(checkpoint_key) DO UPDATE SET
                            delta_link = excluded.delta_link,
                            updated_at = excluded.updated_at;
                        """,
                        (key, delta_link, now_iso),
                    )
                    conn.commit()
            except Exception as e:
                logger.warning(f"Could not persist checkpoint {key}: {e}")

    def clear_checkpoint(self, site_id: str, list_name: str) -> None:
        """Clear stored checkpoint to force a full re-sync."""
        key = f"delta:{site_id}:{list_name}"
        self._memory_checkpoints.pop(key, None)

        if self.db_path and self.db_path != ":memory:":
            try:
                with sqlite3.connect(self.db_path) as conn:
                    conn.execute(
                        "DELETE FROM system_checkpoints WHERE checkpoint_key = ?;",
                        (key,),
                    )
                    conn.commit()
            except Exception:
                pass

    async def sync_list(self, site_id: str, list_name: str) -> List[Dict[str, Any]]:
        """Perform delta query sync on a SharePoint list.

        Args:
            site_id: Graph site identifier.
            list_name: SharePoint list name (e.g. CDEDocuments).

        Returns:
            List of changed items with action 'UPSERT' or 'DELETED'.
        """
        stored_link = self.get_checkpoint(site_id, list_name)
        initial_url = (
            stored_link
            or f"https://graph.microsoft.com/v1.0/sites/{site_id}/lists/{list_name}/items/delta?$expand=fields"
        )
        url: Optional[str] = initial_url
        changes: List[Dict[str, Any]] = []

        while url:
            resp = await self.graph.request("GET", url)

            # Handle HTTP 410 Gone (Delta Token Expired)
            if resp.status_code == 410:
                logger.warning(
                    f"Delta token for list '{list_name}' has expired (HTTP 410 Gone). "
                    "Resetting checkpoint and restarting full sync..."
                )
                self.clear_checkpoint(site_id, list_name)
                url = f"https://graph.microsoft.com/v1.0/sites/{site_id}/lists/{list_name}/items/delta?$expand=fields"
                resp = await self.graph.request("GET", url)

            resp.raise_for_status()
            data = resp.json()

            for item in data.get("value", []):
                item_id = str(item.get("id", ""))
                etag = item.get("eTag", "")

                # 1. Check for deletion flag (@removed)
                if "@removed" in item:
                    logger.info(f"Detected DELETED item {item_id} in {list_name}")
                    changes.append({
                        "id": item_id,
                        "action": "DELETED",
                        "removed_reason": item.get("@removed", {}).get("reason", "deleted"),
                        "list_name": list_name,
                    })
                    continue

                fields = item.get("fields", {})
                last_modified_app = (
                    item.get("lastModifiedBy", {})
                    .get("application", {})
                    .get("id")
                )

                # 2. Check LoopBreaker for echo suppression
                is_echo = await self.loop_breaker.is_echo_event(
                    list_name=list_name,
                    item_id=item_id,
                    etag=etag,
                    fields=fields,
                    last_modified_app_id=last_modified_app,
                    spark_client_id=self.config.client_id,
                )

                if is_echo:
                    logger.debug(f"Suppressed echo event for {list_name} item {item_id}")
                    continue

                # 3. Pydantic Model Validation Guard
                validated_model = None
                if HAS_MODELS:
                    payload_to_validate = dict(fields)
                    # Merge top-level id into payload for Pydantic model compatibility
                    if "ID" not in payload_to_validate and "id" not in payload_to_validate and item_id:
                        payload_to_validate["ID"] = item_id

                    try:
                        if list_name == "CDEDocuments" and CDEDocumentsItem is not None:
                            validated_model = CDEDocumentsItem.model_validate(payload_to_validate)
                        elif list_name == "Opportunities" and OpportunitiesItem is not None:
                            validated_model = OpportunitiesItem.model_validate(payload_to_validate)
                    except ValidationError as val_err:
                        logger.warning(
                            f"Validation failed for {list_name} item {item_id}: {val_err}. Routing to DLQ."
                        )
                        if self.dlq is not None:
                            self.dlq.record_failure(
                                sync_direction="PULL_DELTA",
                                list_name=list_name,
                                item_id=item_id,
                                payload=payload_to_validate,
                                error_code="VALIDATION_ERROR",
                                error_message=str(val_err),
                                retry_count=0,
                            )
                        continue

                record: Dict[str, Any] = {
                    "id": item_id,
                    "action": "UPSERT",
                    "fields": fields,
                    "eTag": etag,
                    "list_name": list_name,
                }
                if validated_model is not None:
                    record["model"] = validated_model

                changes.append(record)

            # Check for next page or delta completion
            if "@odata.nextLink" in data:
                url = data["@odata.nextLink"]
            elif "@odata.deltaLink" in data:
                new_delta_link = data["@odata.deltaLink"]
                self.save_checkpoint(site_id, list_name, new_delta_link)
                logger.info(f"Updated delta link checkpoint for {list_name}")
                break
            else:
                break

        return changes


class OutboundSyncEngine:
    """Outbound Synchronization Engine for pushing changes to SharePoint Lists.

    Supports Optimistic Concurrency Control (OCC) using the If-Match header
    and registers successful updates with LoopBreaker to avoid echo loops.
    """

    def __init__(
        self,
        graph_client: ResilientGraphClient,
        loop_breaker: LoopBreaker,
        config: M365Config,
        dlq: Optional[DeadLetterQueue] = None,
    ) -> None:
        """Initialize OutboundSyncEngine."""
        self.graph = graph_client
        self.loop_breaker = loop_breaker
        self.config = config
        self.dlq = dlq

    async def push_item_update(
        self,
        site_id: str,
        list_name: str,
        item_id: str,
        fields_to_update: Dict[str, Any],
        current_etag: Optional[str] = None,
        max_retries: int = 3,
    ) -> Dict[str, Any]:
        """Push updated fields to SharePoint List Item.

        Args:
            site_id: Graph site identifier.
            list_name: Target list name.
            item_id: Item identifier.
            fields_to_update: Dictionary of fields to update.
            current_etag: Optional eTag for Optimistic Concurrency Control.
            max_retries: Retries before sending to DLQ.

        Returns:
            Dictionary response from SharePoint.

        Raises:
            ValueError: On concurrency conflict (HTTP 412).
            Exception: On persistent failure after DLQ isolation.
        """
        url = f"https://graph.microsoft.com/v1.0/sites/{site_id}/lists/{list_name}/items/{item_id}/fields"
        headers = {"Content-Type": "application/json"}
        if current_etag:
            headers["If-Match"] = current_etag

        last_exc: Optional[Exception] = None
        for attempt in range(1, max_retries + 1):
            try:
                resp = await self.graph.request("PATCH", url, headers=headers, json=fields_to_update, max_retries=1)

                if resp.status_code == 412:
                    msg = (
                        f"Concurrency Conflict (HTTP 412 Precondition Failed) on {list_name} item {item_id}. "
                        "Item was modified concurrently."
                    )
                    logger.warning(msg)
                    raise ValueError(msg)

                resp.raise_for_status()
                updated_data = resp.json()
                new_etag = updated_data.get("eTag", "")

                # Register in LoopBreaker to suppress echo in subsequent delta queries
                await self.loop_breaker.register_outbound_update(
                    list_name=list_name,
                    item_id=str(item_id),
                    etag=new_etag,
                    payload=fields_to_update,
                )
                logger.info(f"Successfully pushed updates for {list_name} item {item_id}")
                return updated_data

            except ValueError:
                raise
            except Exception as exc:
                last_exc = exc
                logger.warning(f"Push update attempt {attempt}/{max_retries} failed for item {item_id}: {exc}")
                if attempt < max_retries:
                    await asyncio.sleep(1.0 * attempt)

        # Retry exhausted: Isolate to DLQ
        if self.dlq is not None and last_exc is not None:
            self.dlq.record_failure(
                sync_direction="PUSH_SHAREPOINT",
                list_name=list_name,
                item_id=str(item_id),
                payload=fields_to_update,
                error_code="RETRY_EXHAUSTED",
                error_message=str(last_exc),
                retry_count=max_retries,
            )

        if last_exc:
            raise last_exc
        raise RuntimeError("Push update failed without exception.")


class M365BridgeWorker:
    """Coordinator and Daemon for M365 SharePoint Lists Outbound & Inbound Bridge.

    Manages synchronization lifecycle, delta polling, echo suppression,
    error isolation via DLQ, and CLI interface.
    """

    def __init__(
        self,
        config: Optional[M365Config] = None,
        dlq_db_path: Optional[str] = None,
    ) -> None:
        """Initialize M365BridgeWorker."""
        self.config = config or M365Config()
        db_path = dlq_db_path or self.config.dlq_db_path

        self.rate_limiter = TokenBucketRateLimiter(
            rate_per_second=self.config.rate_limit_rps,
            capacity=self.config.rate_limit_burst,
        )
        self.token_manager = M365TokenManager(config=self.config)
        self.graph_client = ResilientGraphClient(
            token_manager=self.token_manager,
            rate_limiter=self.rate_limiter,
        )
        self.loop_breaker = LoopBreaker(ttl_seconds=900)
        self.dlq = DeadLetterQueue(
            db_path=db_path,
            chatops_url=self.config.chatops_gateway_url,
            chatops_secret=self.config.chatops_internal_secret,
        )
        self.delta_engine = DeltaSyncEngine(
            graph_client=self.graph_client,
            loop_breaker=self.loop_breaker,
            config=self.config,
            dlq=self.dlq,
            db_path=db_path,
        )
        self.outbound_engine = OutboundSyncEngine(
            graph_client=self.graph_client,
            loop_breaker=self.loop_breaker,
            config=self.config,
            dlq=self.dlq,
        )
        self.running = False

    async def run_once(
        self,
        target_list: Optional[str] = None,
        dry_run: bool = False,
    ) -> Dict[str, Any]:
        """Execute one complete synchronization cycle across configured lists.

        Args:
            target_list: Optional specific list ('CDEDocuments' or 'Opportunities').
            dry_run: When True, simulates queries without external mutations.

        Returns:
            Dictionary with cycle statistics.
        """
        stats: Dict[str, Any] = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "dry_run": dry_run,
            "target_list": target_list or "ALL",
            "lists_processed": [],
            "total_upserts": 0,
            "total_deletions": 0,
            "errors": 0,
        }

        lists_to_check: List[Tuple[str, str]] = []
        if not target_list or target_list.lower() == "cdedocuments":
            lists_to_check.append(("CDEDocuments", self.config.cde_site_id))
        if not target_list or target_list.lower() == "opportunities":
            lists_to_check.append(("Opportunities", self.config.idop_site_id))

        if dry_run:
            logger.info("[DRY-RUN] Simulating M365 Bridge Worker synchronization cycle...")
            for l_name, s_id in lists_to_check:
                logger.info(
                    f"[DRY-RUN] Validating configuration for list '{l_name}': "
                    f"Site ID: {s_id}, RPS: {self.config.rate_limit_rps}"
                )
                stats["lists_processed"].append(l_name)

            stats["unresolved_dlq_count"] = len(self.dlq.get_unresolved())
            logger.info(f"[DRY-RUN] Cycle completed successfully. DLQ items: {stats['unresolved_dlq_count']}")
            return stats

        # Real Execution
        for l_name, s_id in lists_to_check:
            try:
                logger.info(f"Syncing list '{l_name}' from site {s_id}...")
                changes = await self.delta_engine.sync_list(s_id, l_name)
                stats["lists_processed"].append(l_name)

                for item in changes:
                    action = item.get("action")
                    if action == "UPSERT":
                        stats["total_upserts"] += 1
                        await self._process_business_logic(l_name, item)
                    elif action == "DELETED":
                        stats["total_deletions"] += 1
                        logger.info(f"Processed deletion for {l_name} item {item.get('id')}")

            except Exception as e:
                stats["errors"] += 1
                logger.error(f"Error syncing {l_name}: {e}", exc_info=True)
                self.dlq.record_failure(
                    sync_direction="PULL_DELTA",
                    list_name=l_name,
                    item_id=None,
                    payload={"site_id": s_id},
                    error_code="SYNC_CYCLE_ERROR",
                    error_message=str(e),
                )

        return stats

    async def _process_business_logic(self, list_name: str, item: Dict[str, Any]) -> None:
        """Process business logic for synchronized items."""
        item_id = item.get("id")
        fields = item.get("fields", {})

        if list_name == "CDEDocuments":
            title = fields.get("Title", "Untitled")
            doc_code = fields.get("DocumentCode", "N/A")
            approval = fields.get("ApprovalStatus", "S0")
            logger.info(
                f"[CDEDocuments] Received Document: '{title}', Code: {doc_code}, Status: {approval} (ID: {item_id})"
            )
        elif list_name == "Opportunities":
            opp_name = fields.get("OpportunityName", "Untitled")
            stage = fields.get("Stage", "New")
            val = fields.get("Value", 0)
            logger.info(
                f"[Opportunities] Received Opportunity: '{opp_name}', Stage: {stage}, Value: {val} (ID: {item_id})"
            )

    async def start(
        self,
        target_list: Optional[str] = None,
        dry_run: bool = False,
    ) -> None:
        """Start daemon loop running periodically."""
        self.running = True
        logger.info(
            f"M365BridgeWorker daemon started. Interval: {self.config.sync_interval_seconds}s, "
            f"Dry Run: {dry_run}, List: {target_list or 'ALL'}"
        )

        while self.running:
            try:
                await self.run_once(target_list=target_list, dry_run=dry_run)
            except Exception as e:
                logger.error(f"Error in M365BridgeWorker main loop: {e}", exc_info=True)

            if not self.running:
                break
            await asyncio.sleep(self.config.sync_interval_seconds)

    async def stop(self) -> None:
        """Stop worker daemon."""
        self.running = False
        await self.graph_client.close()
        logger.info("M365BridgeWorker stopped safely.")


def build_cli() -> argparse.ArgumentParser:
    """Build CLI parser for M365 Bridge Worker."""
    parser = argparse.ArgumentParser(
        description="Outbound Bridge Worker for Microsoft 365 SharePoint Lists (CDEDocuments & Opportunities)."
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulate execution without modifying external APIs or state.",
    )
    parser.add_argument(
        "--once",
        action="store_true",
        help="Execute a single synchronization cycle and exit.",
    )
    parser.add_argument(
        "--list",
        dest="target_list",
        choices=["CDEDocuments", "Opportunities"],
        help="Filter sync to a specific SharePoint list.",
    )
    parser.add_argument(
        "--interval",
        type=int,
        help="Custom polling interval in seconds.",
    )
    parser.add_argument(
        "--dlq-list",
        action="store_true",
        help="Display all unresolved items currently in Dead-Letter Queue.",
    )
    parser.add_argument(
        "--dlq-resolve",
        type=int,
        metavar="ID",
        help="Mark a specific Dead-Letter Queue item as resolved.",
    )
    return parser


def main() -> int:
    """Main CLI entrypoint."""
    parser = build_cli()
    args = parser.parse_args()

    config = M365Config()
    if args.interval:
        config.sync_interval_seconds = args.interval

    worker = M365BridgeWorker(config=config)

    # Handle DLQ commands
    if args.dlq_list:
        unresolved = worker.dlq.get_unresolved()
        print(f"\n=== Dead-Letter Queue: {len(unresolved)} Unresolved Records ===")
        for rec in unresolved:
            print(
                f"[ID {rec['id']}] {rec['created_at']} | Direction: {rec['sync_direction']} | "
                f"List: {rec['list_name']} | Item: {rec['item_id']} | Code: {rec['error_code']}\n"
                f"  Message: {rec['error_message']}\n"
            )
        return 0

    if args.dlq_resolve:
        success = worker.dlq.mark_resolved(args.dlq_resolve, notes="Resolved via CLI tool.")
        if success:
            print(f"DLQ Record #{args.dlq_resolve} marked as resolved.")
            return 0
        print(f"Error: DLQ Record #{args.dlq_resolve} not found.", file=sys.stderr)
        return 1

    async def _async_main() -> int:
        if args.once:
            res = await worker.run_once(target_list=args.target_list, dry_run=args.dry_run)
            print(json.dumps(res, indent=2))
            return 0
        try:
            await worker.start(target_list=args.target_list, dry_run=args.dry_run)
            return 0
        except KeyboardInterrupt:
            await worker.stop()
            return 0

    return asyncio.run(_async_main())


if __name__ == "__main__":
    sys.exit(main())
