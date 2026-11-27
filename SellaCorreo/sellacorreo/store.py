"""Almacenamiento SQLite interno (volumen /data), usuarios y log encadenado."""
from __future__ import annotations

import hashlib
import hmac
import logging
import os
import secrets
import sqlite3
import uuid
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path

from autenticidad import GENESIS_HASH, entry_hash

from . import firma

log = logging.getLogger("sellacorreo")
SCHEMA = Path(__file__).resolve().parent / "schema.sql"
LOG_FIELDS = ["entry_id", "ts_utc", "usuario", "taxonomia", "token_hash", "h", "seal_sig"]
INSTITUCION = os.environ.get("SELLACORREO_INSTITUCION", "IESS · entorno de demostración")


def now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def sha(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


# ------------------------------------------------------------ contraseñas (scrypt, stdlib)
def hash_password(password: str) -> str:
    salt = secrets.token_bytes(16)
    dk = hashlib.scrypt(password.encode(), salt=salt, n=2**14, r=8, p=1)
    return f"scrypt$16384$8$1${salt.hex()}${dk.hex()}"


def check_password(password: str, stored: str) -> bool:
    try:
        _, n, r, p, salt, dk = stored.split("$")
        calc = hashlib.scrypt(password.encode(), salt=bytes.fromhex(salt), n=int(n), r=int(r), p=int(p))
        return hmac.compare_digest(calc.hex(), dk)
    except (ValueError, TypeError):
        return False


def _db_path() -> str:
    return os.environ.get("SELLACORREO_DB_PATH", "/data/sellacorreo.db")


@contextmanager
def connect():
    conn = sqlite3.connect(_db_path(), timeout=15, isolation_level=None)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()


def demo_mode() -> bool:
    return os.environ.get("SELLACORREO_DEMO", "false").lower() == "true"


def demo_password() -> str:
    return os.environ.get("SELLACORREO_DEMO_PASSWORD", "")


def _seed_users(conn) -> None:
    """Usuarios desde .env: SELLACORREO_USUARIO_N=usuario|Nombre|Unidad|correo|clave
    Si la clave va vacía se usa SELLACORREO_DEMO_PASSWORD (cuenta de demostración)."""
    found = False
    for key in sorted(k for k in os.environ if k.startswith("SELLACORREO_USUARIO_")):
        if not os.environ[key].strip():
            continue  # variable declarada en docker-compose pero sin valor en .env
        parts = os.environ[key].split("|")
        if len(parts) == 5 and not parts[4].strip() and demo_password():
            parts[4] = demo_password()
        if len(parts) != 5 or not all(p.strip() for p in parts):
            log.warning("%s mal formado: use usuario|Nombre|Unidad|correo|clave", key)
            continue
        usuario, nombre, unidad, emisor, clave = (p.strip() for p in parts)
        row = conn.execute("SELECT password_hash FROM usuarios WHERE usuario=?", (usuario,)).fetchone()
        pw = row["password_hash"] if row and check_password(clave, row["password_hash"]) else hash_password(clave)
        conn.execute(
            "INSERT INTO usuarios (usuario, nombre, unidad, emisor, password_hash) VALUES (?,?,?,?,?) "
            "ON CONFLICT(usuario) DO UPDATE SET nombre=excluded.nombre, unidad=excluded.unidad, "
            "emisor=excluded.emisor, password_hash=excluded.password_hash, activo=1",
            (usuario.lower(), nombre, unidad, emisor.lower(), pw))
        found = True
    if not found:
        log.warning("No hay usuarios SELLACORREO_USUARIO_* en .env: nadie podrá iniciar sesión")


def init() -> None:
    Path(_db_path()).parent.mkdir(parents=True, exist_ok=True)
    with connect() as conn:
        conn.executescript(SCHEMA.read_text(encoding="utf-8"))
        cols = {r[1] for r in conn.execute("PRAGMA table_info(sellos)")}
        for col, ddl in [("palabra_cifrada", "TEXT"), ("palabra_tag", "TEXT"), ("expira_utc", "TEXT"),
                         ("exige_destinatario", "INTEGER NOT NULL DEFAULT 0"), ("exige_emisor", "INTEGER NOT NULL DEFAULT 0"), ("emisor_hmac", "TEXT"), ("exige_asunto", "INTEGER NOT NULL DEFAULT 1"),
                         ("destinatario_cifrado", "TEXT")]:
            if col not in cols:  # migración de bases creadas con la versión anterior
                conn.execute(f"ALTER TABLE sellos ADD COLUMN {col} {ddl}")
        for item in os.environ.get("SELLACORREO_TAXONOMIAS", "").split(","):
            item = item.strip().lower()
            if item:
                conn.execute("INSERT OR IGNORE INTO taxonomias (codigo, nombre) VALUES (?,?)", (item, item.capitalize()))
        _seed_users(conn)


def authenticate(usuario: str, clave: str) -> dict | None:
    """Acepta el correo electrónico o el nombre de usuario."""
    ident = usuario.strip().lower()
    with connect() as conn:
        row = conn.execute("SELECT * FROM usuarios WHERE (emisor=? OR usuario=?) AND activo=1", (ident, ident)).fetchone()
    if row is None:
        check_password(clave, hash_password("x"))  # tiempo similar si el usuario no existe
        return None
    return dict(row) if check_password(clave, row["password_hash"]) else None


def demo_users() -> list[dict]:
    """Cuentas que usan la contraseña de demostración (para la tarjeta de acceso rápido)."""
    pw = demo_password()
    if not pw:
        return []
    with connect() as conn:
        rows = [dict(r) for r in conn.execute("SELECT usuario, nombre, unidad, emisor, password_hash FROM usuarios "
                                              "WHERE activo=1 ORDER BY usuario")]
    return [{k: r[k] for k in ("usuario", "nombre", "unidad", "emisor")} for r in rows
            if check_password(pw, r["password_hash"])]


def get_user(usuario: str) -> dict | None:
    with connect() as conn:
        row = conn.execute("SELECT * FROM usuarios WHERE usuario=? AND activo=1", (usuario,)).fetchone()
    return dict(row) if row else None


def taxonomias() -> list[dict]:
    with connect() as conn:
        return [dict(r) for r in conn.execute("SELECT codigo, nombre FROM taxonomias WHERE activa=1 ORDER BY rowid")]


def save_seal(seal: dict) -> None:
    with connect() as conn:
        conn.execute(f"INSERT INTO sellos ({','.join(seal)}) VALUES ({','.join('?' * len(seal))})", list(seal.values()))


def get_seal(token: str) -> dict | None:
    with connect() as conn:
        row = conn.execute("SELECT * FROM sellos WHERE token=?", (token,)).fetchone()
    return dict(row) if row else None


def seals_with_subject(limit: int = 2000) -> list[dict]:
    """Sellos recientes que llevan el asunto dentro del hash (para buscar por asunto)."""
    with connect() as conn:
        return [dict(r) for r in conn.execute(
            "SELECT token, h, asunto FROM sellos WHERE COALESCE(exige_asunto, 1)=1 "
            "ORDER BY ts_utc DESC, rowid DESC LIMIT ?", (limit,))]


def seals_of(usuario: str, limit: int = 10) -> list[dict]:
    with connect() as conn:
        return [dict(r) for r in conn.execute(
            "SELECT token, codigo, taxonomia, asunto, ts_utc, h FROM sellos WHERE usuario=? ORDER BY ts_utc DESC, rowid DESC LIMIT ?",
            (usuario, limit))]


def append_log(**entry) -> dict:
    fields = {"entry_id": str(uuid.uuid4()), "ts_utc": now_utc(), **entry}
    with connect() as conn:
        conn.execute("BEGIN IMMEDIATE")
        try:
            last = conn.execute("SELECT entry_hash FROM log ORDER BY seq DESC LIMIT 1").fetchone()
            prev = last["entry_hash"] if last else GENESIS_HASH
            eh = entry_hash(prev, {k: fields[k] for k in LOG_FIELDS})
            kid, sig = firma.sign(eh.encode("ascii"))
            cols = LOG_FIELDS + ["prev_hash", "entry_hash", "entry_kid", "entry_sig"]
            conn.execute(f"INSERT INTO log ({','.join(cols)}) VALUES ({','.join('?' * len(cols))})",
                         [fields[k] for k in LOG_FIELDS] + [prev, eh, kid, sig])
            conn.execute("COMMIT")
        except Exception:
            conn.execute("ROLLBACK")
            raise
    return {"entry_id": fields["entry_id"], "prev_hash": prev, "entry_hash": eh}


def verify_chain() -> dict:
    prev, total, errores = GENESIS_HASH, 0, []
    with connect() as conn:
        for row in conn.execute("SELECT * FROM log ORDER BY seq"):
            total += 1
            calc = entry_hash(prev, {k: row[k] for k in LOG_FIELDS})
            if row["prev_hash"] != prev or calc != row["entry_hash"]:
                errores.append({"entry_id": row["entry_id"], "error": "cadena_rota"})
            elif not firma.verify(row["entry_kid"], row["entry_hash"].encode("ascii"), row["entry_sig"]):
                errores.append({"entry_id": row["entry_id"], "error": "firma_invalida"})
            prev = row["entry_hash"]
    return {"entradas": total, "integra": not errores, "errores": errores}


def record_verification(estado: str, ip_hash: str) -> None:
    with connect() as conn:
        conn.execute("INSERT INTO verificaciones (ts_utc, estado, ip_hash) VALUES (?,?,?)", (now_utc(), estado, ip_hash))


def save_greeting(clave: str, palabra_cifrada: str) -> None:
    with connect() as conn:
        conn.execute("INSERT INTO saludos (clave, palabra_cifrada, ts_utc) VALUES (?,?,?) "
                     "ON CONFLICT(clave) DO UPDATE SET palabra_cifrada=excluded.palabra_cifrada, ts_utc=excluded.ts_utc",
                     (clave, palabra_cifrada, now_utc()))


def get_greeting(clave: str) -> str | None:
    with connect() as conn:
        row = conn.execute("SELECT palabra_cifrada FROM saludos WHERE clave=?", (clave,)).fetchone()
    return row[0] if row else None
