"""
SPKI-pinned HTTPS client for pay.cfg-lab.computingforgeeks.com.

Validates the cert chain against the Private CA root AND checks the observed
SubjectPublicKeyInfo SHA-256 against an approved pin set. Supports primary +
backup pin for zero-downtime rotation.

Usage:
    ROOT_CA_PEM=./root-ca.pem python3 pinned_client.py
"""
import base64
import hashlib
import os
import socket
import ssl
import sys

from cryptography import x509
from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat

HOST = os.environ.get("PAY_HOST", "pay.cfg-lab.computingforgeeks.com")
PORT = int(os.environ.get("PAY_PORT", "443"))
ROOT_CA_PEM = os.environ.get("ROOT_CA_PEM", "./root-ca.pem")

# Primary pin (current key) + optional backup pin (next key pre-pinned before rotation)
PINS = {
    # Replace with your cert's SPKI SHA-256, base64-encoded:
    #   openssl x509 -in pay.pem -pubkey -noout \
    #     | openssl pkey -pubin -outform DER \
    #     | openssl dgst -sha256 -binary \
    #     | openssl enc -base64
    "T54tUdvkmrct4v2MpDvgR1wVgAuKOBaWkZQE/ydREaQ=",
    # "BACKUP_PIN_BASE64_HERE",  # next key, pre-pinned ahead of rotation
}


def spki_sha256_b64(cert_der: bytes) -> str:
    """Compute base64-encoded SHA-256 of the cert's SubjectPublicKeyInfo DER."""
    cert = x509.load_der_x509_certificate(cert_der)
    spki_der = cert.public_key().public_bytes(
        Encoding.DER, PublicFormat.SubjectPublicKeyInfo
    )
    return base64.b64encode(hashlib.sha256(spki_der).digest()).decode()


def connect_with_pin(host: str, port: int, pins: set) -> None:
    """Open a TLS connection and verify both chain validity and SPKI pin."""
    ctx = ssl.create_default_context(cafile=ROOT_CA_PEM)
    ctx.check_hostname = True
    ctx.verify_mode = ssl.CERT_REQUIRED

    with socket.create_connection((host, port), timeout=5) as raw:
        with ctx.wrap_socket(raw, server_hostname=host) as tls:
            peer_cert = tls.getpeercert(binary_form=True)
            observed_pin = spki_sha256_b64(peer_cert)
            if observed_pin not in pins:
                raise ssl.SSLError(
                    f"SPKI pin mismatch: observed {observed_pin!r} "
                    f"not in approved pin set"
                )
            print(f"OK: TLS handshake + pin verified ({observed_pin})")
            tls.send(b"GET / HTTP/1.1\r\nHost: " + host.encode() + b"\r\n\r\n")


if __name__ == "__main__":
    try:
        connect_with_pin(HOST, PORT, PINS)
    except (ssl.SSLError, OSError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
