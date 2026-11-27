"""Clave Ed25519 propia: se genera en el primer arranque y queda en el volumen."""
from __future__ import annotations

import hashlib
import os
import threading
from pathlib import Path

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from autenticidad import b64u_encode, verify_ed25519

_lock = threading.Lock()
_state: dict = {}


def _path() -> Path:
    return Path(os.environ.get("SELLACORREO_KEY_PATH", "/data/ed25519.pem"))


def key():
    with _lock:
        path = _path()
        if _state.get("path") == str(path):
            return _state["key"], _state["kid"], _state["pub"]
        if path.exists():
            k = serialization.load_pem_private_key(path.read_bytes(), password=None)
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            k = Ed25519PrivateKey.generate()
            fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            with os.fdopen(fd, "wb") as f:
                f.write(k.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8,
                                        serialization.NoEncryption()))
        raw = k.public_key().public_bytes(serialization.Encoding.Raw, serialization.PublicFormat.Raw)
        kid = "ed25519-" + hashlib.sha256(raw).hexdigest()[:16]
        _state.update(path=str(path), key=k, kid=kid, pub=b64u_encode(raw))
        return k, kid, _state["pub"]


def sign(data: bytes) -> tuple[str, str]:
    k, kid, _ = key()
    return kid, b64u_encode(k.sign(data))


def verify(kid: str, data: bytes, sig: str) -> bool:
    _, my_kid, pub = key()
    return kid == my_kid and verify_ed25519(pub, data, sig)


def public() -> dict:
    _, kid, pub = key()
    return {"kid": kid, "alg": "Ed25519", "public_key": pub}
