"""Regla 4 · Canonicalización.

Contenido canónico = "Subject: <asunto>\n\n<cuerpo>" con:
  * Unicode NFC
  * saltos de línea LF (CRLF y CR se convierten en LF)
  * sin espacios ni tabulaciones al final de cada línea
  * sin líneas vacías al final
Se excluyen todos los encabezados de transporte (Received, Return-Path, DKIM,
Message-ID, Date, To, X-Autenticidad, ...) porque solo se toma el asunto, y se
excluye el bloque visible de verificación (entre BLOCK_BEGIN y BLOCK_END).
Del mensaje MIME solo cuenta la parte text/plain; la parte HTML es una
representación del mismo texto más el QR.
"""
from __future__ import annotations

import re
import unicodedata
from email import policy
from email.parser import BytesParser

BLOCK_BEGIN = "-----INICIO BLOQUE DE VERIFICACION-----"
BLOCK_END = "-----FIN BLOQUE DE VERIFICACION-----"

_BLOCK_RE = re.compile(
    re.escape(BLOCK_BEGIN) + r".*?" + re.escape(BLOCK_END), re.DOTALL
)


def normalize_email(addr: str) -> str:
    return unicodedata.normalize("NFC", addr).strip().lower()


def _normalize_text(text: str) -> str:
    text = unicodedata.normalize("NFC", text)
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    lines = [ln.rstrip(" \t") for ln in text.split("\n")]
    while lines and lines[-1] == "":
        lines.pop()
    return "\n".join(lines)


def strip_verification_block(body: str) -> str:
    return _BLOCK_RE.sub("", body.replace("\r\n", "\n").replace("\r", "\n"))


def canonical_content(subject: str, body: str) -> bytes:
    subject = _normalize_text(subject).replace("\n", " ")
    body = _normalize_text(strip_verification_block(body))
    return f"Subject: {subject}\n\n{body}".encode("utf-8")


def _text_part(msg) -> str:
    if msg.is_multipart():
        part = msg.get_body(preferencelist=("plain",))
        if part is None:
            return ""
        return part.get_content()
    if msg.get_content_type() == "text/plain":
        return msg.get_content()
    return ""


def canonical_from_raw(raw: bytes | str) -> tuple[bytes, dict]:
    """Devuelve (contenido_canónico, encabezados_relevantes) de un .eml."""
    if isinstance(raw, str):
        raw = raw.encode("utf-8")
    msg = BytesParser(policy=policy.default).parsebytes(raw)
    subject = str(msg.get("Subject", "") or "")
    body = _text_part(msg)
    headers = {
        "x-autenticidad": str(msg.get("X-Autenticidad", "") or ""),
        "from": str(msg.get("From", "") or ""),
        "to": str(msg.get("To", "") or ""),
    }
    return canonical_content(subject, body), headers
