"""Seudonimización y tokens (LOPDP por diseño, CLAUDE.md regla 3).

- `id_seudonimo`: HMAC-SHA256 del correo con la clave del servidor. Nunca se
  guarda el correo, la cédula ni el nombre en claro en las métricas. Aun así, un
  dato seudonimizado sigue siendo dato personal.
- Token del simulacro: se envía en las URL y en la cabecera `X-Simulacro-Ref`;
  en la base de datos solo se guarda su SHA-256 (CLAUDE.md §11).
"""

from __future__ import annotations

import hashlib
import hmac
import secrets

from .config import config


def normalizar_correo(correo: str) -> str:
    return correo.strip().lower()


def id_seudonimo(correo: str) -> str:
    """HMAC-SHA256(correo) con la clave del servidor, en hex (64 chars)."""
    clave = config.secreto_seudonimo.encode("utf-8")
    mensaje = normalizar_correo(correo).encode("utf-8")
    return hmac.new(clave, mensaje, hashlib.sha256).hexdigest()


def nuevo_token() -> str:
    """Token opaco para la URL de la página de destino y la cabecera."""
    return secrets.token_urlsafe(24)


def hash_token(token: str) -> str:
    """SHA-256 del token; es lo único que se guarda en la BD."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()
