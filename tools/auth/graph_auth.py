"""Microsoft Graph API App-Only Certificate Authentication Helper.

Provides headless, certificate-based authentication for IDOP services using
cryptography and MSAL Python.
"""

from __future__ import annotations

import datetime
import os
from pathlib import Path
from typing import Any

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.serialization import pkcs12
import msal

# IDOP Production Defaults (SSOT from environments.psd1 & PnPHelpers.psm1)
DEFAULT_CLIENT_ID = "c055c7a4-9150-4bd5-bf01-445c65467feb"
DEFAULT_TENANT_ID = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
GRAPH_DEFAULT_SCOPE = ["https://graph.microsoft.com/.default"]

_cached_client: msal.ConfidentialClientApplication | None = None


def load_pfx_credentials(
    pfx_path: Path | str, password: str | None = None
) -> dict[str, Any]:
    """Extracts SHA-1 thumbprint, PEM private key, and certificate from a PFX file.

    Args:
        pfx_path: Path to .pfx or .p12 certificate file (supports ~ expansion).
        password: Optional certificate password.

    Returns:
        Dict containing thumbprint, private_key, public_certificate,
        not_valid_after, and subject.

    Raises:
        FileNotFoundError: If pfx_path does not exist.
        ValueError: If file is not valid PKCS#12, password is incorrect,
            or certificate has expired.
    """
    path = Path(pfx_path).expanduser().resolve()
    if not path.is_file():
        raise FileNotFoundError(f"Certificate file not found: {path}")

    pfx_bytes = path.read_bytes()
    pwd_bytes = password.encode("utf-8") if password else None

    try:
        private_key, certificate, _ = pkcs12.load_key_and_certificates(
            pfx_bytes, pwd_bytes
        )
    except (ValueError, TypeError) as exc:
        raise ValueError(
            f"Failed to decrypt/load PKCS#12 certificate from {path}. "
            "Please verify the password and certificate format."
        ) from exc

    if private_key is None or certificate is None:
        raise ValueError(
            f"PFX file {path} does not contain both private key and certificate."
        )

    # Validate certificate validity period
    try:
        not_after = certificate.not_valid_after_utc
    except AttributeError:
        not_after = certificate.not_valid_after
        if not_after.tzinfo is None:
            not_after = not_after.replace(tzinfo=datetime.timezone.utc)
    now_utc = datetime.datetime.now(datetime.timezone.utc)
    if not_after < now_utc:
        raise ValueError(f"Certificate at {path} expired on {not_after}.")

    # 1. SHA-1 Thumbprint (40 hex uppercase chars matching Azure Portal)
    thumbprint = certificate.fingerprint(hashes.SHA1()).hex().upper()

    # 2. PEM-encoded private key (PKCS#8 unencrypted for MSAL)
    pem_key = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    ).decode("utf-8")

    # 3. PEM-encoded public certificate
    pem_cert = certificate.public_bytes(serialization.Encoding.PEM).decode("utf-8")

    return {
        "thumbprint": thumbprint,
        "private_key": pem_key,
        "public_certificate": pem_cert,
        "not_valid_after": not_after,
        "subject": certificate.subject.rfc4514_string(),
    }


def get_graph_client(
    client_id: str | None = None,
    tenant_id: str | None = None,
    cert_path: Path | str | None = None,
    cert_password: str | None = None,
    force_refresh: bool = False,
) -> msal.ConfidentialClientApplication:
    """Gets or initializes MSAL ConfidentialClientApplication with certificate credentials.

    Args:
        client_id: Azure AD Client/App ID. Defaults to env var or IDOP standard.
        tenant_id: Azure AD Tenant ID. Defaults to env var or IDOP standard.
        cert_path: Path to .pfx certificate. Defaults to IDOP_SP_CERT_PATH.
        cert_password: Password for cert. Defaults to IDOP_SP_CERT_PASSWORD.
        force_refresh: If True, re-creates the client instance.

    Returns:
        Configured MSAL ConfidentialClientApplication.
    """
    global _cached_client
    if _cached_client is not None and not force_refresh:
        return _cached_client

    resolved_client_id = (
        client_id or os.environ.get("IDOP_SP_CLIENT_ID") or DEFAULT_CLIENT_ID
    )
    resolved_tenant_id = (
        tenant_id
        or os.environ.get("IDOP_SP_TENANT_ID")
        or os.environ.get("IDOP_SP_TENANT")
        or DEFAULT_TENANT_ID
    )
    resolved_cert_path = cert_path or os.environ.get("IDOP_SP_CERT_PATH")
    resolved_password = (
        cert_password
        if cert_password is not None
        else os.environ.get("IDOP_SP_CERT_PASSWORD", "")
    )

    if not resolved_cert_path:
        raise ValueError(
            "Missing certificate path. Set IDOP_SP_CERT_PATH or pass cert_path explicitly."
        )

    creds = load_pfx_credentials(resolved_cert_path, resolved_password)

    client_credential = {
        "thumbprint": creds["thumbprint"],
        "private_key": creds["private_key"],
        "public_certificate": creds["public_certificate"],
    }

    authority = f"https://login.microsoftonline.com/{resolved_tenant_id}"
    client = msal.ConfidentialClientApplication(
        client_id=resolved_client_id,
        client_credential=client_credential,
        authority=authority,
    )
    _cached_client = client
    return client


def acquire_graph_token(
    client: msal.ConfidentialClientApplication | None = None,
    scopes: list[str] | None = None,
) -> str:
    """Acquires access token for Microsoft Graph (.default scope) leveraging internal MSAL cache.

    Args:
        client: Optional MSAL client instance. If None, uses get_graph_client().
        scopes: Scopes to request. Defaults to ['https://graph.microsoft.com/.default'].

    Returns:
        Bearer access token string.

    Raises:
        RuntimeError: If token acquisition fails.
    """
    active_client = client or get_graph_client()
    target_scopes = scopes or GRAPH_DEFAULT_SCOPE

    result = active_client.acquire_token_for_client(scopes=target_scopes)

    if "access_token" in result:
        return str(result["access_token"])

    error = result.get("error", "unknown_error")
    desc = result.get("error_description", "No description provided.")
    raise RuntimeError(f"Failed to acquire Microsoft Graph token: {error} - {desc}")
