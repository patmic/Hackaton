"""Reglas 5, 6 y 7 · hash compuesto, sello Ed25519 y cadena del log."""
from __future__ import annotations

import base64
import hashlib
import hmac
import json
import re

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey

from .canon import normalize_email

GENESIS_HASH = "0" * 64


def b64u_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def b64u_decode(data: str) -> bytes:
    pad = "=" * (-len(data) % 4)
    return base64.urlsafe_b64decode(data + pad)


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def recipient_hmac(key: bytes, emisor: str, destinatario: str) -> str:
    """HMAC-SHA256(clave, emisor + "-" + destinatario). Nunca se guarda el destinatario."""
    msg = f"{normalize_email(emisor)}-{normalize_email(destinatario)}".encode("utf-8")
    return hmac.new(key, msg, hashlib.sha256).hexdigest()


def composite_hash(sid: str, rhmac: str, ts_utc: str, size: int, content_sha256: str) -> str:
    """H = SHA-256( sid | HMAC(emisor-destinatario) | ts_utc | tamaño_canónico | SHA-256(contenido) )."""
    material = "|".join([sid, rhmac, ts_utc, str(size), content_sha256])
    return sha256_hex(material.encode("utf-8"))


def seal_payload(h: str, msg_id: str, ts_utc: str, tipologia: str, kid: str) -> bytes:
    return "|".join([h, msg_id, ts_utc, tipologia, kid]).encode("utf-8")


def verify_ed25519(public_key_b64u: str, payload: bytes, sig_b64u: str) -> bool:
    try:
        key = Ed25519PublicKey.from_public_bytes(b64u_decode(public_key_b64u))
        key.verify(b64u_decode(sig_b64u), payload)
        return True
    except (InvalidSignature, ValueError, TypeError):
        return False


def entry_hash(prev_hash: str, fields: dict) -> str:
    canon = json.dumps(fields, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return sha256_hex(f"{prev_hash}|{canon}".encode("utf-8"))


_HDR_ORDER = ["v", "id", "ts", "tip", "kid", "h", "tok", "sig"]


def format_x_autenticidad(values: dict) -> str:
    return "; ".join(f"{k}={values[k]}" for k in _HDR_ORDER if k in values)


def parse_x_autenticidad(header: str) -> dict:
    header = re.sub(r"\s+", "", header or "")
    out = {}
    for part in header.split(";"):
        if "=" in part:
            k, v = part.split("=", 1)
            out[k.strip()] = v.strip()
    return out
