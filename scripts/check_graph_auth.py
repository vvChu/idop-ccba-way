"""Microsoft Graph API Authentication and Permission Consent Checker.

Validates App-Only Certificate setup, decodes JWT token roles, and confirms
connectivity to the IDOP SharePoint site on Microsoft Graph.
"""

from __future__ import annotations

import argparse
import datetime
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

# Ensure repository root is on sys.path for direct script execution
REPO_ROOT = Path(__file__).resolve().parents[1]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import pkcs12
import jwt

from tools.auth.graph_auth import (
    DEFAULT_CLIENT_ID,
    DEFAULT_TENANT_ID,
    acquire_graph_token,
    get_graph_client,
    load_pfx_credentials,
)

IDOP_SITE_GRAPH_URL = (
    "https://graph.microsoft.com/v1.0/sites/ibstbim.sharepoint.com:/sites/idop"
)
REQUIRED_SITE_ROLES = {"Sites.FullControl.All", "Sites.ReadWrite.All"}
REQUIRED_FILE_ROLES = {"Files.ReadWrite.All"}


def load_local_env_file() -> None:
    """Loads environment variables from .env file if present, without overriding existing env."""
    env_path = Path(".env").resolve()
    if not env_path.is_file():
        return

    for line in env_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        key = key.strip()
        val = val.strip().strip("'\"")
        if key and key not in os.environ:
            os.environ[key] = val


def run_mock_verification() -> int:
    """Executes offline verification using an in-memory self-signed certificate."""
    print("================================================================================")
    print("🧪 Running Mock App-Only Certificate & Graph Auth Verification (Offline Mode)")
    print("================================================================================")

    # 1. Generate in-memory self-signed certificate
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    subject = issuer = x509.Name([
        x509.NameAttribute(x509.NameOID.COMMON_NAME, "IDOP-Mock-Deploy"),
    ])
    now = datetime.datetime.now(datetime.timezone.utc)
    cert = (
        x509.CertificateBuilder()
        .subject_name(subject)
        .issuer_name(issuer)
        .public_key(private_key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(now - datetime.timedelta(days=1))
        .not_valid_after(now + datetime.timedelta(days=365))
        .sign(private_key, hashes.SHA256())
    )

    pfx_data = pkcs12.serialize_key_and_certificates(
        name=b"idop_mock",
        key=private_key,
        cert=cert,
        cas=None,
        encryption_algorithm=serialization.NoEncryption(),
    )

    tmp_pfx = Path("/tmp/idop_mock_test.pfx")
    tmp_pfx.write_bytes(pfx_data)

    try:
        creds = load_pfx_credentials(tmp_pfx, None)
        print(f"✅ In-memory PKCS#12 loaded successfully.")
        print(f"   Thumbprint (SHA-1): {creds['thumbprint']}")
        print(f"   Subject:           {creds['subject']}")
        print(f"   Expires:           {creds['not_valid_after']}")

        # 2. Mock JWT roles check
        mock_payload: dict[str, Any] = {
            "aud": "https://graph.microsoft.com",
            "iss": f"https://sts.windows.net/{DEFAULT_TENANT_ID}/",
            "appid": DEFAULT_CLIENT_ID,
            "roles": ["Sites.FullControl.All", "Files.ReadWrite.All"],
        }
        mock_secret = "mock_secret_key_32_bytes_long_123"
        mock_token = jwt.encode(mock_payload, mock_secret, algorithm="HS256")
        decoded = jwt.decode(mock_token, options={"verify_signature": False})
        roles = set(decoded.get("roles", []))

        print(f"\n✅ Simulated Token Decoded:")
        print(f"   App ID: {decoded.get('appid')}")
        print(f"   Roles:  {list(roles)}")

        has_site_perm = bool(roles & REQUIRED_SITE_ROLES)
        has_file_perm = bool(roles & REQUIRED_FILE_ROLES)

        print(f"\n📋 Permission Evaluation:")
        print(f"   [{'PASS' if has_site_perm else 'FAIL'}] SharePoint List Access (Sites.FullControl.All or Sites.ReadWrite.All)")
        print(f"   [{'PASS' if has_file_perm else 'FAIL'}] Master OneDrive 5TB Access (Files.ReadWrite.All)")

        print("\n✅ Mock verification completed with zero errors.")
        return 0
    finally:
        if tmp_pfx.exists():
            tmp_pfx.unlink()


def run_live_verification(
    client_id: str | None,
    tenant_id: str | None,
    cert_path: str | None,
    cert_password: str | None,
) -> int:
    """Executes live verification against Microsoft Graph API."""
    load_local_env_file()

    resolved_cert = cert_path or os.environ.get("IDOP_SP_CERT_PATH")
    if not resolved_cert:
        print("❌ Error: IDOP_SP_CERT_PATH not configured.")
        print("   Please create a .env file from .env.example or provide --cert-path.")
        print("   To run offline test, use: python scripts/check_graph_auth.py --mock")
        return 1

    print("================================================================================")
    print("🔐 Checking App-Only Certificate & Microsoft Graph API Permissions (Live Mode)")
    print("================================================================================")

    try:
        client = get_graph_client(
            client_id=client_id,
            tenant_id=tenant_id,
            cert_path=resolved_cert,
            cert_password=cert_password,
            force_refresh=True,
        )
        print(f"✅ Certificate loaded from: {resolved_cert}")

        token = acquire_graph_token(client)
        print("✅ Successfully acquired Microsoft Graph access token.")

        # Decode token without verification to inspect claims
        decoded = jwt.decode(token, options={"verify_signature": False})
        roles = set(decoded.get("roles", []))

        print(f"\n🔑 Token Claims:")
        print(f"   App ID (Client): {decoded.get('appid')}")
        print(f"   Tenant ID:       {decoded.get('tid')}")
        print(f"   Granted Roles:   {sorted(roles)}")

        has_site_perm = bool(roles & REQUIRED_SITE_ROLES)
        has_file_perm = bool(roles & REQUIRED_FILE_ROLES)

        print(f"\n📋 Permission Evaluation:")
        if has_site_perm:
            print("   ✅ [PASS] SharePoint List Access (Sites.FullControl.All / Sites.ReadWrite.All)")
        else:
            print("   ⚠️  [MISSING] SharePoint List Access: Neither Sites.FullControl.All nor Sites.ReadWrite.All granted.")
            print("       -> Go to Azure Portal > Entra ID > App Registrations > API Permissions > Add Sites.FullControl.All (Application) and Grant Admin Consent.")

        if has_file_perm:
            print("   ✅ [PASS] 5TB Master OneDrive Access (Files.ReadWrite.All)")
        else:
            print("   ⚠️  [MISSING] Master OneDrive Access: Files.ReadWrite.All not granted.")
            print("       -> Go to Azure Portal > Entra ID > App Registrations > API Permissions > Add Files.ReadWrite.All (Application) and Grant Admin Consent.")

        # Test Graph API Site Call
        print(f"\n🌐 Testing Site Connectivity: {IDOP_SITE_GRAPH_URL} ...")
        req = urllib.request.Request(
            IDOP_SITE_GRAPH_URL,
            headers={"Authorization": f"Bearer {token}", "Accept": "application/json"},
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            print(f"   Site ID:      {data.get('id')}")
            print(f"   DisplayName:  {data.get('displayName')}")
            print(f"   WebUrl:       {data.get('webUrl')}")
            print("\n🎉 Connection to IDOP SharePoint Site verified successfully!")

        return 0 if (has_site_perm and has_file_perm) else 2

    except urllib.error.HTTPError as exc:
        print(f"❌ Graph API HTTP Error {exc.code}: {exc.reason}")
        try:
            err_body = json.loads(exc.read().decode("utf-8"))
            print(f"   Details: {err_body.get('error', {}).get('message')}")
        except Exception:
            pass
        return 1
    except Exception as exc:
        print(f"❌ Verification Failed: {exc}")
        return 1


def main() -> int:
    """CLI entrypoint."""
    parser = argparse.ArgumentParser(
        description="Verify Microsoft Graph App-Only Certificate authentication and permissions."
    )
    parser.add_argument(
        "--mock",
        action="store_true",
        help="Run offline mock simulation using in-memory self-signed certificate.",
    )
    parser.add_argument(
        "--cert-path",
        type=str,
        default=None,
        help="Path to .pfx certificate file.",
    )
    parser.add_argument(
        "--cert-password",
        type=str,
        default=None,
        help="Certificate password.",
    )
    parser.add_argument(
        "--client-id",
        type=str,
        default=None,
        help="App Client ID.",
    )
    parser.add_argument(
        "--tenant-id",
        type=str,
        default=None,
        help="Entra ID Tenant ID.",
    )

    args = parser.parse_args()

    if args.mock:
        return run_mock_verification()

    return run_live_verification(
        client_id=args.client_id,
        tenant_id=args.tenant_id,
        cert_path=args.cert_path,
        cert_password=args.cert_password,
    )


if __name__ == "__main__":
    sys.exit(main())
