"""Unit tests for M365 Outbound Bridge Worker (CDEDocuments & Opportunities).

Verifies:
1. Rate limiter parsing Retry-After (integer seconds vs RFC 2822 HTTP-Date with UTC normalization) and throttling.
2. Loop breaker 3-tier suppression (matching app ID, eTag cache, SHA-256 payload hash).
3. Delta sync lifecycle (initial sync, nextLink pagination, deltaLink persistence, 410 Gone recovery, deletions).
4. DLQ isolation after retry exhaustion, validation error routing, and resolution lifecycle.
5. Token refresh lifecycle (proactive refresh < 300s, async lock thundering herd).
6. Resilient HTTP client (Retry-After backoff, HTTP 429/5xx retry, non-retryable status codes).
7. Outbound sync engine with Optimistic Concurrency Control (OCC).
8. Pydantic v2 typed models validation integration for CDEDocuments & Opportunities.
9. Worker coordinator & CLI dry-run execution.
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timedelta, timezone
import email.utils
from pathlib import Path
import time
from typing import Any, Dict
from unittest.mock import AsyncMock, MagicMock, patch

import httpx
import pytest

from tools.bridge.m365_bridge_worker import (
    DeadLetterQueue,
    DeltaSyncEngine,
    LoopBreaker,
    M365BridgeWorker,
    M365Config,
    M365TokenManager,
    OutboundSyncEngine,
    ResilientGraphClient,
    TokenBucketRateLimiter,
    main,
)
from tools.validator.models import CDEDocumentsItem, OpportunitiesItem


# ==============================================================================
# 1. CONFIGURATION TESTS
# ==============================================================================

def test_m365_config_defaults() -> None:
    """Verify default configuration values and single site architecture."""
    config = M365Config()
    assert config.tenant_id == "d7aa4978-363e-47aa-a77e-7da957b32bf3"
    assert config.client_id == "c055c7a4-9150-4bd5-bf01-445c65467feb"
    assert config.rate_limit_rps == 5.0
    assert config.rate_limit_burst == 10
    assert config.sync_interval_seconds == 60
    assert "sites/idop" in config.idop_site_url
    assert "sites/idop" in config.cde_site_url


def test_m365_config_custom_overrides() -> None:
    """Verify custom parameter overrides."""
    config = M365Config(
        tenant_id="custom-tenant",
        client_id="custom-client",
        client_secret="custom-secret",
        rate_limit_rps=10.0,
        rate_limit_burst=20,
        sync_interval_seconds=30,
    )
    assert config.tenant_id == "custom-tenant"
    assert config.client_id == "custom-client"
    assert config.client_secret == "custom-secret"
    assert config.rate_limit_rps == 10.0
    assert config.rate_limit_burst == 20
    assert config.sync_interval_seconds == 30
    assert config.has_credentials() is True


# ==============================================================================
# 2. RATE LIMITER & RETRY-AFTER TESTS
# ==============================================================================

def test_rate_limiter_retry_after_integer_seconds() -> None:
    """Verify parsing integer seconds in Retry-After header."""
    assert TokenBucketRateLimiter.parse_retry_after("15") == 15.0
    assert TokenBucketRateLimiter.parse_retry_after(" 0 ") == 0.0
    assert TokenBucketRateLimiter.parse_retry_after("120") == 120.0


def test_rate_limiter_retry_after_rfc2822_date() -> None:
    """Verify parsing RFC 2822 HTTP-Date format in Retry-After header with UTC normalization."""
    future_time = datetime.now(timezone.utc) + timedelta(seconds=25)
    header_val = email.utils.format_datetime(future_time)

    delay = TokenBucketRateLimiter.parse_retry_after(header_val)
    # Delay should be approximately 24-26 seconds
    assert 20.0 <= delay <= 26.0

    # Past date should return 0.0
    past_time = datetime.now(timezone.utc) - timedelta(seconds=10)
    past_header = email.utils.format_datetime(past_time)
    assert TokenBucketRateLimiter.parse_retry_after(past_header) == 0.0


def test_rate_limiter_retry_after_fallback_exponential() -> None:
    """Verify invalid or missing Retry-After header falls back to exponential backoff with jitter."""
    # None header
    delay1 = TokenBucketRateLimiter.parse_retry_after(None, attempt=1, base_backoff=2.0)
    assert 0.1 <= delay1 <= 4.0

    # Non-date invalid string
    delay2 = TokenBucketRateLimiter.parse_retry_after("invalid-format-string", attempt=2, base_backoff=2.0)
    assert 0.1 <= delay2 <= 8.0


def test_rate_limiter_throttling_acquisition() -> None:
    """Verify TokenBucketRateLimiter consumes tokens and throttles when depleted."""
    async def _test() -> None:
        limiter = TokenBucketRateLimiter(rate_per_second=10.0, capacity=2)

        # First 2 tokens should be immediately available
        w1 = await limiter.acquire(1.0)
        assert w1 == 0.0
        w2 = await limiter.acquire(1.0)
        assert w2 == 0.0

        # Third token needs wait time: 1 token / 10 rps = ~0.1s
        start = time.monotonic()
        w3 = await limiter.acquire(1.0)
        elapsed = time.monotonic() - start
        assert w3 > 0.08
        assert elapsed >= 0.08

    asyncio.run(_test())


# ==============================================================================
# 3. TOKEN MANAGER & MSAL LIFECYCLE TESTS
# ==============================================================================

def test_token_manager_proactive_refresh_cache_hit() -> None:
    """Verify TokenManager returns cached token directly when expiry > 300s."""
    async def _test() -> None:
        config = M365Config(client_secret="dummy_secret")
        mock_msal_app = MagicMock()
        manager = M365TokenManager(config=config, app=mock_msal_app)

        # Set token expiring in 1000 seconds (> 300s threshold)
        manager.set_cached_token("valid_token_123", expires_in=1000.0)

        token = await manager.get_token()
        assert token == "valid_token_123"
        # MSAL app should not be called at all
        mock_msal_app.acquire_token_for_client.assert_not_called()
        mock_msal_app.acquire_token_silent.assert_not_called()

    asyncio.run(_test())


def test_token_manager_proactive_refresh_near_expiry() -> None:
    """Verify TokenManager proactively triggers refresh when expiry < 300s."""
    async def _test() -> None:
        config = M365Config(client_secret="dummy_secret")
        mock_msal_app = MagicMock()
        mock_msal_app.acquire_token_silent.return_value = None
        mock_msal_app.acquire_token_for_client.return_value = {
            "access_token": "new_refreshed_token_456",
            "expires_in": 3600,
        }
        manager = M365TokenManager(config=config, app=mock_msal_app)

        # Set token expiring in 100 seconds (< 300s threshold)
        manager.set_cached_token("old_expiring_token", expires_in=100.0)

        token = await manager.get_token()
        assert token == "new_refreshed_token_456"
        mock_msal_app.acquire_token_for_client.assert_called_once_with(scopes=manager.scopes)

    asyncio.run(_test())


def test_token_manager_thundering_herd_lock() -> None:
    """Verify concurrent requests only trigger one token acquisition via async lock."""
    async def _test() -> None:
        config = M365Config(client_secret="dummy_secret")
        mock_msal_app = MagicMock()
        mock_msal_app.acquire_token_silent.return_value = None

        call_count = 0

        def _slow_acquire(scopes: Any) -> Dict[str, Any]:
            nonlocal call_count
            call_count += 1
            time.sleep(0.05)
            return {"access_token": "herd_token_789", "expires_in": 3600}

        mock_msal_app.acquire_token_for_client = _slow_acquire
        manager = M365TokenManager(config=config, app=mock_msal_app)

        # Launch 10 simultaneous coroutines requesting token
        tasks = [manager.get_token() for _ in range(10)]
        results = await asyncio.gather(*tasks)

        assert all(r == "herd_token_789" for r in results)
        assert call_count == 1, f"Expected 1 acquisition call, but got {call_count}"

    asyncio.run(_test())


# ==============================================================================
# 4. LOOP BREAKER 3-TIER SUPPRESSION TESTS
# ==============================================================================

def test_loop_breaker_tier1_author_application_id() -> None:
    """Verify Tier 1: Matching author Application ID suppresses echo."""
    async def _test() -> None:
        breaker = LoopBreaker()
        spark_client_id = "c055c7a4-9150-4bd5-bf01-445c65467feb"

        # 1. Matching author App ID -> Echo event
        is_echo = await breaker.is_echo_event(
            list_name="CDEDocuments",
            item_id="101",
            etag="etag_1",
            fields={"Title": "Doc1"},
            last_modified_app_id=spark_client_id,
            spark_client_id=spark_client_id,
        )
        assert is_echo is True

        # 2. Case-insensitive matching
        is_echo_upper = await breaker.is_echo_event(
            list_name="CDEDocuments",
            item_id="101",
            etag="etag_1",
            fields={"Title": "Doc1"},
            last_modified_app_id=spark_client_id.upper(),
            spark_client_id=spark_client_id,
        )
        assert is_echo_upper is True

        # 3. User update (app ID is None or different) -> Not echo
        is_echo_user = await breaker.is_echo_event(
            list_name="CDEDocuments",
            item_id="101",
            etag="etag_1",
            fields={"Title": "Doc1"},
            last_modified_app_id=None,
            spark_client_id=spark_client_id,
        )
        assert is_echo_user is False

    asyncio.run(_test())


def test_loop_breaker_tier2_etag_cache() -> None:
    """Verify Tier 2: In-memory LRU cache of recently updated (list, id, eTag) suppresses echo."""
    async def _test() -> None:
        breaker = LoopBreaker(ttl_seconds=10)
        spark_client_id = "spark_client_id_test"

        # Register outbound push update from Spark
        await breaker.register_outbound_update(
            list_name="Opportunities",
            item_id="202",
            etag="etag_abc_123",
            payload={"OpportunityName": "Project A", "Stage": "Proposal/HSDX"},
        )

        # Incoming delta query with same list, item_id, etag -> Suppressed!
        is_echo = await breaker.is_echo_event(
            list_name="Opportunities",
            item_id="202",
            etag="etag_abc_123",
            fields={"OpportunityName": "Project A", "Stage": "Proposal/HSDX"},
            last_modified_app_id="external_or_blank_id",
            spark_client_id=spark_client_id,
        )
        assert is_echo is True

        # Different etag with different payload -> Not echo
        is_echo_diff = await breaker.is_echo_event(
            list_name="Opportunities",
            item_id="202",
            etag="etag_new_999",
            fields={"OpportunityName": "Project A Modified", "Stage": "Closed - Won"},
            last_modified_app_id="external_id",
            spark_client_id=spark_client_id,
        )
        assert is_echo_diff is False

    asyncio.run(_test())


def test_loop_breaker_tier3_payload_hash() -> None:
    """Verify Tier 3: SHA-256 payload hash suppresses identical content changes."""
    async def _test() -> None:
        breaker = LoopBreaker()
        spark_client_id = "spark_client_id_test"

        payload = {"Title": "Drawing 01", "ApprovalStatus": "S2", "DocumentCode": "DOC-001"}

        # Register update
        await breaker.register_outbound_update(
            list_name="CDEDocuments",
            item_id="303",
            etag="etag_init",
            payload=payload,
        )

        # Delta query arrives with a new eTag but identical business content -> Suppressed!
        is_echo_same_content = await breaker.is_echo_event(
            list_name="CDEDocuments",
            item_id="303",
            etag="etag_different_generated_by_sharepoint",
            fields=payload,
            last_modified_app_id=None,
            spark_client_id=spark_client_id,
        )
        assert is_echo_same_content is True

        # Delta query with modified content -> NOT suppressed
        modified_payload = dict(payload)
        modified_payload["ApprovalStatus"] = "A1"
        is_echo_modified = await breaker.is_echo_event(
            list_name="CDEDocuments",
            item_id="303",
            etag="etag_different_generated_by_sharepoint_2",
            fields=modified_payload,
            last_modified_app_id=None,
            spark_client_id=spark_client_id,
        )
        assert is_echo_modified is False

    asyncio.run(_test())


# ==============================================================================
# 5. RESILIENT GRAPH CLIENT TESTS
# ==============================================================================

def test_resilient_graph_client_success() -> None:
    """Verify ResilientGraphClient injects headers and returns successful response."""
    async def _test() -> None:
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_bearer_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)

        mock_http = AsyncMock()
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = {"value": []}
        mock_http.request.return_value = mock_resp

        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)
        resp = await client.request("GET", "https://graph.microsoft.com/v1.0/sites")

        assert resp.status_code == 200
        mock_http.request.assert_called_once()
        call_headers = mock_http.request.call_args[1]["headers"]
        assert call_headers["Authorization"] == "Bearer test_bearer_token"
        assert call_headers["Accept"] == "application/json"

    asyncio.run(_test())


def test_resilient_graph_client_http_429_backoff() -> None:
    """Verify ResilientGraphClient handles HTTP 429 and retries."""
    async def _test() -> None:
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)

        mock_http = AsyncMock()

        resp_429 = MagicMock()
        resp_429.status_code = 429
        resp_429.headers = {"Retry-After": "0"}  # 0s for instant test execution

        resp_200 = MagicMock()
        resp_200.status_code = 200
        resp_200.json.return_value = {"status": "ok"}

        mock_http.request.side_effect = [resp_429, resp_200]

        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)
        resp = await client.request("GET", "https://graph.microsoft.com/v1.0/sites", max_retries=3)

        assert resp.status_code == 200
        assert mock_http.request.call_count == 2

    asyncio.run(_test())


def test_resilient_graph_client_non_retryable_codes() -> None:
    """Verify 400, 404, 410, 412 are returned immediately without retrying."""
    async def _test() -> None:
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)

        for code in (400, 404, 410, 412):
            mock_http = AsyncMock()
            mock_resp = MagicMock()
            mock_resp.status_code = code
            mock_http.request.return_value = mock_resp

            client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)
            resp = await client.request("GET", f"https://graph.microsoft.com/v1.0/test/{code}", max_retries=4)

            assert resp.status_code == code
            assert mock_http.request.call_count == 1

    asyncio.run(_test())


def test_resilient_graph_client_network_error_retry() -> None:
    """Verify ResilientGraphClient retries on network ConnectError."""
    async def _test() -> None:
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)

        mock_http = AsyncMock()
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = {"ok": True}

        # 1 network error, then success
        mock_http.request.side_effect = [
            httpx.ConnectError("Connection failed"),
            mock_resp,
        ]

        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)
        resp = await client.request("GET", "https://graph.microsoft.com/v1.0/test", max_retries=3, base_backoff=0.01)
        assert resp.status_code == 200
        assert mock_http.request.call_count == 2

    asyncio.run(_test())


def test_resilient_graph_client_timeout_exhaustion() -> None:
    """Verify ResilientGraphClient raises TimeoutError when retries are exhausted on 503."""
    async def _test() -> None:
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)

        mock_http = AsyncMock()
        resp_503 = MagicMock()
        resp_503.status_code = 503
        resp_503.headers = {"Retry-After": "0"}
        mock_http.request.return_value = resp_503

        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)
        # Attempt 2 retries, last attempt returns 503
        resp = await client.request("GET", "https://graph.microsoft.com/v1.0/test", max_retries=2, base_backoff=0.01)
        assert resp.status_code == 503
        assert mock_http.request.call_count == 2

    asyncio.run(_test())


# ==============================================================================
# 6. DELTA SYNC ENGINE TESTS
# ==============================================================================

def test_delta_sync_lifecycle_and_persistence(tmp_path: Path) -> None:
    """Verify DeltaSyncEngine handles initial sync, pagination, and deltaLink persistence."""
    async def _test() -> None:
        db_file = str(tmp_path / "test_delta.db")
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)
        breaker = LoopBreaker()

        mock_http = AsyncMock()

        # Page 1: 1 item + nextLink
        resp_p1 = MagicMock()
        resp_p1.status_code = 200
        resp_p1.json.return_value = {
            "value": [
                {
                    "id": "1",
                    "eTag": "etag_1",
                    "fields": {"Title": "Doc 1", "DocumentCode": "CDE-001"},
                }
            ],
            "@odata.nextLink": "https://graph.microsoft.com/v1.0/page2",
        }

        # Page 2: 1 item + deltaLink
        resp_p2 = MagicMock()
        resp_p2.status_code = 200
        resp_p2.json.return_value = {
            "value": [
                {
                    "id": "2",
                    "eTag": "etag_2",
                    "fields": {"Title": "Doc 2", "DocumentCode": "CDE-002"},
                }
            ],
            "@odata.deltaLink": "https://graph.microsoft.com/v1.0/delta_token_final",
        }

        mock_http.request.side_effect = [resp_p1, resp_p2]
        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)

        engine = DeltaSyncEngine(
            graph_client=client,
            loop_breaker=breaker,
            config=config,
            db_path=db_file,
        )

        changes = await engine.sync_list("site_id_1", "CDEDocuments")

        assert len(changes) == 2
        assert changes[0]["id"] == "1"
        assert changes[0]["action"] == "UPSERT"
        assert changes[1]["id"] == "2"
        assert changes[1]["action"] == "UPSERT"

        # Verify delta link persisted
        persisted = engine.get_checkpoint("site_id_1", "CDEDocuments")
        assert persisted == "https://graph.microsoft.com/v1.0/delta_token_final"

    asyncio.run(_test())


def test_delta_sync_deletion_tracking() -> None:
    """Verify DeltaSyncEngine recognizes @removed deletion events."""
    async def _test() -> None:
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)
        breaker = LoopBreaker()

        mock_http = AsyncMock()
        resp = MagicMock()
        resp.status_code = 200
        resp.json.return_value = {
            "value": [
                {
                    "id": "42",
                    "@removed": {"reason": "deleted"},
                }
            ],
            "@odata.deltaLink": "https://graph.microsoft.com/v1.0/delta_after_del",
        }
        mock_http.request.return_value = resp
        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)

        engine = DeltaSyncEngine(
            graph_client=client,
            loop_breaker=breaker,
            config=config,
            db_path=":memory:",
        )

        changes = await engine.sync_list("site_id_1", "Opportunities")
        assert len(changes) == 1
        assert changes[0]["id"] == "42"
        assert changes[0]["action"] == "DELETED"
        assert changes[0]["removed_reason"] == "deleted"

    asyncio.run(_test())


def test_delta_sync_410_gone_recovery(tmp_path: Path) -> None:
    """Verify DeltaSyncEngine clears checkpoint and resets to full sync on HTTP 410 Gone."""
    async def _test() -> None:
        db_file = str(tmp_path / "test_410.db")
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)
        breaker = LoopBreaker()

        mock_http = AsyncMock()

        # Step 1: Initial query with stale delta link returns 410 Gone
        resp_410 = MagicMock()
        resp_410.status_code = 410

        # Step 2: Fallback full sync query returns 200 with new delta link
        resp_full = MagicMock()
        resp_full.status_code = 200
        resp_full.json.return_value = {
            "value": [
                {
                    "id": "100",
                    "eTag": "etag_full",
                    "fields": {"Title": "Recovered Item"},
                }
            ],
            "@odata.deltaLink": "https://graph.microsoft.com/v1.0/brand_new_delta_link",
        }

        mock_http.request.side_effect = [resp_410, resp_full]
        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)

        engine = DeltaSyncEngine(
            graph_client=client,
            loop_breaker=breaker,
            config=config,
            db_path=db_file,
        )

        # Pre-seed stale checkpoint
        engine.save_checkpoint("site_1", "CDEDocuments", "https://graph.microsoft.com/v1.0/stale_delta")

        changes = await engine.sync_list("site_1", "CDEDocuments")

        assert len(changes) == 1
        assert changes[0]["id"] == "100"
        expected_link = "https://graph.microsoft.com/v1.0/brand_new_delta_link"
        assert engine.get_checkpoint("site_1", "CDEDocuments") == expected_link

    asyncio.run(_test())


# ==============================================================================
# 7. DEAD-LETTER QUEUE (DLQ) TESTS
# ==============================================================================

def test_dead_letter_queue_lifecycle(tmp_path: Path) -> None:
    """Verify DLQ record failure, query unresolved, and mark resolved lifecycle."""
    db_file = str(tmp_path / "dlq_test.db")
    dlq = DeadLetterQueue(db_path=db_file)

    # 1. Record 2 failures
    id1 = dlq.record_failure(
        sync_direction="PULL_DELTA",
        list_name="CDEDocuments",
        item_id="doc_999",
        payload={"raw": "corrupt"},
        error_code="LOOKUP_NOT_FOUND",
        error_message="Lookup project '9999' does not exist.",
        retry_count=3,
    )
    id2 = dlq.record_failure(
        sync_direction="PUSH_SHAREPOINT",
        list_name="Opportunities",
        item_id="opp_888",
        payload={"Value": "invalid_number"},
        error_code="SCHEMA_MISMATCH",
        error_message="Expected float for field 'Value'.",
        retry_count=3,
    )
    assert id1 > 0
    assert id2 > id1

    # 2. Query unresolved
    unresolved = dlq.get_unresolved()
    assert len(unresolved) == 2
    assert unresolved[0]["item_id"] == "doc_999"
    assert unresolved[1]["item_id"] == "opp_888"

    # Query filtered by list
    cde_unresolved = dlq.get_unresolved(list_name="CDEDocuments")
    assert len(cde_unresolved) == 1
    assert cde_unresolved[0]["list_name"] == "CDEDocuments"

    # 3. Mark first record resolved
    resolved = dlq.mark_resolved(id1, notes="Manually fixed lookup reference in project master.")
    assert resolved is True

    # 4. Check unresolved count decreased
    unresolved_after = dlq.get_unresolved()
    assert len(unresolved_after) == 1
    assert unresolved_after[0]["id"] == id2


def test_dead_letter_queue_chatops_alert() -> None:
    """Verify DLQ triggers ChatOps notification when configured."""
    dlq = DeadLetterQueue(
        db_path=":memory:",
        chatops_url="http://127.0.0.1:8095",
        chatops_secret="test_secret",
    )

    with patch("httpx.Client.post") as mock_post:
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_post.return_value = mock_resp

        dlq_id = dlq.record_failure(
            sync_direction="PULL_DELTA",
            list_name="CDEDocuments",
            item_id="item_alert",
            payload={"error": "test"},
            error_code="TEST_ERROR",
            error_message="Test alert message",
        )
        assert dlq_id > 0
        mock_post.assert_called_once()
        args, kwargs = mock_post.call_args
        assert "/api/v1/notify" in args[0]
        assert kwargs["headers"]["X-ChatOps-Secret"] == "test_secret"
        assert "CDEDocuments" in kwargs["json"]["title"]


# ==============================================================================
# 8. OUTBOUND SYNC ENGINE TESTS
# ==============================================================================

def test_outbound_sync_dlq_on_retry_exhaustion() -> None:
    """Verify OutboundSyncEngine writes to DLQ when retries are exhausted."""
    async def _test() -> None:
        dlq = DeadLetterQueue(db_path=":memory:")
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)
        breaker = LoopBreaker()

        mock_http = AsyncMock()
        resp_500 = MagicMock()
        resp_500.status_code = 500
        resp_500.raise_for_status.side_effect = httpx.HTTPStatusError(
            "Server Error", request=MagicMock(), response=resp_500
        )
        mock_http.request.return_value = resp_500

        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)
        engine = OutboundSyncEngine(
            graph_client=client,
            loop_breaker=breaker,
            config=config,
            dlq=dlq,
        )

        with pytest.raises(Exception):
            await engine.push_item_update(
                site_id="site_1",
                list_name="CDEDocuments",
                item_id="doc_fail",
                fields_to_update={"ApprovalStatus": "S2"},
                max_retries=2,
            )

        # Verify entry in DLQ
        unresolved = dlq.get_unresolved("CDEDocuments")
        assert len(unresolved) == 1
        assert unresolved[0]["item_id"] == "doc_fail"
        assert unresolved[0]["error_code"] == "RETRY_EXHAUSTED"

    asyncio.run(_test())


def test_outbound_sync_occ_precondition_failed() -> None:
    """Verify OutboundSyncEngine raises ValueError on HTTP 412 Concurrency Conflict."""
    async def _test() -> None:
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)
        breaker = LoopBreaker()

        mock_http = AsyncMock()
        resp_412 = MagicMock()
        resp_412.status_code = 412
        mock_http.request.return_value = resp_412

        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)
        engine = OutboundSyncEngine(
            graph_client=client,
            loop_breaker=breaker,
            config=config,
        )

        with pytest.raises(ValueError) as exc_info:
            await engine.push_item_update(
                site_id="site_1",
                list_name="Opportunities",
                item_id="opp_occ",
                fields_to_update={"Stage": "Closed - Won"},
                current_etag="etag_old",
            )
        assert "HTTP 412 Precondition Failed" in str(exc_info.value)

    asyncio.run(_test())


# ==============================================================================
# 9. PYDANTIC V2 TYPED MODEL VALIDATION TESTS (IDOP INTEGRATION)
# ==============================================================================

def test_pydantic_model_delta_payload_validation_success() -> None:
    """Verify DeltaSyncEngine properly validates delta payloads using CDEDocumentsItem and OpportunitiesItem."""
    async def _test() -> None:
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)
        breaker = LoopBreaker()

        mock_http = AsyncMock()
        resp = MagicMock()
        resp.status_code = 200
        resp.json.return_value = {
            "value": [
                {
                    "id": "101",
                    "eTag": "etag_cde_1",
                    "fields": {
                        "Title": "ISO Architecture Drawing",
                        "DocumentCode": "IBST-CDE-ARC-001",
                        "ApprovalStatus": "S1",
                    },
                }
            ],
            "@odata.deltaLink": "https://graph.microsoft.com/v1.0/delta_end",
        }
        mock_http.request.return_value = resp
        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)

        engine = DeltaSyncEngine(
            graph_client=client,
            loop_breaker=breaker,
            config=config,
            db_path=":memory:",
        )

        changes = await engine.sync_list("site_id_1", "CDEDocuments")
        assert len(changes) == 1
        record = changes[0]
        assert record["action"] == "UPSERT"
        assert record["id"] == "101"
        assert "model" in record
        assert isinstance(record["model"], CDEDocumentsItem)
        assert record["model"].id == 101
        assert record["model"].document_code == "IBST-CDE-ARC-001"
        assert record["model"].approval_status == "S1"

    asyncio.run(_test())


def test_pydantic_model_delta_payload_validation_failure_dlq_routing() -> None:
    """Verify DeltaSyncEngine routes invalid schema items to DLQ without crashing sync loop."""
    async def _test() -> None:
        dlq = DeadLetterQueue(db_path=":memory:")
        config = M365Config()
        token_mgr = M365TokenManager(config=config)
        token_mgr.set_cached_token("test_token")
        rate_limiter = TokenBucketRateLimiter(rate_per_second=100.0, capacity=10)
        breaker = LoopBreaker()

        mock_http = AsyncMock()
        resp = MagicMock()
        resp.status_code = 200
        resp.json.return_value = {
            "value": [
                {
                    "id": "202",
                    "eTag": "etag_opp_invalid",
                    "fields": {
                        "OpportunityName": "Bad Opportunity",
                        # Stage has invalid choice literal
                        "Stage": "NON_EXISTENT_STAGE_CHOICE",
                    },
                },
                {
                    "id": "203",
                    "eTag": "etag_opp_valid",
                    "fields": {
                        "OpportunityName": "Good Opportunity",
                        "Stage": "New",
                        "Value": 50000000.0,
                    },
                },
            ],
            "@odata.deltaLink": "https://graph.microsoft.com/v1.0/delta_end",
        }
        mock_http.request.return_value = resp
        client = ResilientGraphClient(token_mgr, rate_limiter, http_client=mock_http)

        engine = DeltaSyncEngine(
            graph_client=client,
            loop_breaker=breaker,
            config=config,
            dlq=dlq,
            db_path=":memory:",
        )

        changes = await engine.sync_list("site_id_1", "Opportunities")
        # Only the valid item should be yielded in changes
        assert len(changes) == 1
        assert changes[0]["id"] == "203"
        assert isinstance(changes[0]["model"], OpportunitiesItem)
        assert changes[0]["model"].opportunity_name == "Good Opportunity"

        # The invalid item should be safely isolated in the DLQ
        unresolved = dlq.get_unresolved("Opportunities")
        assert len(unresolved) == 1
        assert unresolved[0]["item_id"] == "202"
        assert unresolved[0]["error_code"] == "VALIDATION_ERROR"
        assert "Stage" in unresolved[0]["error_message"]

    asyncio.run(_test())


# ==============================================================================
# 10. WORKER COORDINATOR & CLI DRY RUN TESTS
# ==============================================================================

def test_bridge_worker_run_once_dry_run() -> None:
    """Verify M365BridgeWorker.run_once(dry_run=True) simulates correctly without mutation."""
    async def _test() -> None:
        worker = M365BridgeWorker(dlq_db_path=":memory:")
        stats = await worker.run_once(dry_run=True)
        assert stats["dry_run"] is True
        assert stats["errors"] == 0
        assert "CDEDocuments" in stats["lists_processed"]
        assert "Opportunities" in stats["lists_processed"]

        # Filtered by list
        stats_cde = await worker.run_once(target_list="CDEDocuments", dry_run=True)
        assert stats_cde["target_list"] == "CDEDocuments"
        assert stats_cde["lists_processed"] == ["CDEDocuments"]

    asyncio.run(_test())


def test_cli_main_dry_run_and_dlq_flags(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Verify CLI main entrypoint supports --dry-run, --dlq-list, and --dlq-resolve."""
    db_path = str(tmp_path / "cli_test.db")
    monkeypatch.setenv("M365_DLQ_DB_PATH", db_path)

    # 1. Test --dry-run --once
    monkeypatch.setattr("sys.argv", ["m365_bridge_worker.py", "--dry-run", "--once"])
    exit_code = main()
    assert exit_code == 0

    # 2. Pre-seed a DLQ record in the test database
    dlq = DeadLetterQueue(db_path=db_path)
    dlq_id = dlq.record_failure(
        sync_direction="PULL_DELTA",
        list_name="CDEDocuments",
        item_id="cli_item_1",
        payload={"field": "val"},
        error_code="CLI_TEST",
        error_message="Test message",
    )

    # 3. Test --dlq-list
    monkeypatch.setattr("sys.argv", ["m365_bridge_worker.py", "--dlq-list"])
    exit_code_list = main()
    assert exit_code_list == 0

    # 4. Test --dlq-resolve
    monkeypatch.setattr("sys.argv", ["m365_bridge_worker.py", "--dlq-resolve", str(dlq_id)])
    exit_code_resolve = main()
    assert exit_code_resolve == 0
    assert len(dlq.get_unresolved()) == 0
