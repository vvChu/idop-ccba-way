"""Unit tests for Microsoft Graph API App-Only Certificate Authentication."""

from __future__ import annotations

import datetime
from pathlib import Path
from unittest.mock import MagicMock

import pytest
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import pkcs12

from tools.auth.graph_auth import (
    DEFAULT_CLIENT_ID,
    DEFAULT_TENANT_ID,
    acquire_graph_token,
    get_graph_client,
    load_pfx_credentials,
)


def _generate_test_pfx(
    tmp_path: Path,
    filename: str = "test.pfx",
    password: str | None = None,
    expired: bool = False,
) -> Path:
    """Helper generating an in-memory PKCS#12 file for testing."""
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    subject = issuer = x509.Name([
        x509.NameAttribute(x509.NameOID.COMMON_NAME, "IDOP-Test-Cert"),
    ])
    now = datetime.datetime.now(datetime.timezone.utc)
    if expired:
        not_before = now - datetime.timedelta(days=30)
        not_after = now - datetime.timedelta(days=1)
    else:
        not_before = now - datetime.timedelta(days=1)
        not_after = now + datetime.timedelta(days=365)

    cert = (
        x509.CertificateBuilder()
        .subject_name(subject)
        .issuer_name(issuer)
        .public_key(private_key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(not_before)
        .not_valid_after(not_after)
        .sign(private_key, hashes.SHA256())
    )

    if password:
        enc = serialization.BestAvailableEncryption(password.encode("utf-8"))
    else:
        enc = serialization.NoEncryption()

    pfx_data = pkcs12.serialize_key_and_certificates(
        name=b"idop_test",
        key=private_key,
        cert=cert,
        cas=None,
        encryption_algorithm=enc,
    )

    pfx_file = tmp_path / filename
    pfx_file.write_bytes(pfx_data)
    return pfx_file


def test_load_valid_pfx_credentials(tmp_path: Path) -> None:
    """Verifies loading a valid unencrypted PFX file extracts proper credentials."""
    pfx_path = _generate_test_pfx(tmp_path, "valid.pfx")
    creds = load_pfx_credentials(pfx_path, None)

    assert len(creds["thumbprint"]) == 40
    assert creds["thumbprint"].isalnum()
    assert "BEGIN PRIVATE KEY" in creds["private_key"]
    assert "BEGIN CERTIFICATE" in creds["public_certificate"]
    assert "IDOP-Test-Cert" in creds["subject"]


def test_load_pfx_with_password(tmp_path: Path) -> None:
    """Verifies password-protected PFX decryption and failure on wrong password."""
    pfx_path = _generate_test_pfx(tmp_path, "secret.pfx", password="correct_password_123")

    # Correct password succeeds
    creds = load_pfx_credentials(pfx_path, "correct_password_123")
    assert len(creds["thumbprint"]) == 40

    # Wrong password raises ValueError
    with pytest.raises(ValueError, match="Failed to decrypt/load PKCS#12"):
        load_pfx_credentials(pfx_path, "wrong_password")


def test_load_pfx_file_not_found() -> None:
    """Verifies missing file raises FileNotFoundError."""
    with pytest.raises(FileNotFoundError, match="Certificate file not found"):
        load_pfx_credentials(Path("/nonexistent/path/ghost.pfx"))


def test_load_expired_pfx_fails(tmp_path: Path) -> None:
    """Verifies expired certificate is rejected with explicit expiration error."""
    pfx_path = _generate_test_pfx(tmp_path, "expired.pfx", expired=True)
    with pytest.raises(ValueError, match="expired on"):
        load_pfx_credentials(pfx_path)


def test_get_graph_client_caching(tmp_path: Path) -> None:
    """Verifies get_graph_client reuses the cached client instance."""
    pfx_path = _generate_test_pfx(tmp_path, "cache.pfx")

    client1 = get_graph_client(cert_path=pfx_path, force_refresh=True)
    client2 = get_graph_client(cert_path=pfx_path, force_refresh=False)
    assert client1 is client2

    # Force refresh creates new instance
    client3 = get_graph_client(cert_path=pfx_path, force_refresh=True)
    assert client3 is not client1


def test_acquire_graph_token_success() -> None:
    """Verifies acquire_graph_token extracts token string from successful result."""
    mock_client = MagicMock()
    mock_client.acquire_token_for_client.return_value = {
        "access_token": "mock_valid_bearer_token_xyz"
    }

    token = acquire_graph_token(mock_client)
    assert token == "mock_valid_bearer_token_xyz"
    mock_client.acquire_token_for_client.assert_called_once_with(
        scopes=["https://graph.microsoft.com/.default"]
    )


def test_acquire_graph_token_error_handling() -> None:
    """Verifies acquire_graph_token raises RuntimeError when MSAL returns an error dict."""
    mock_client = MagicMock()
    mock_client.acquire_token_for_client.return_value = {
        "error": "invalid_client",
        "error_description": "AADSTS700027: Client assertion signature is invalid.",
    }

    with pytest.raises(RuntimeError, match="AADSTS700027"):
        acquire_graph_token(mock_client)
