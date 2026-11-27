-- SellaCorreo · esquema SQLite (se aplica al arrancar; idempotente)
-- Ningún destinatario se guarda en claro: solo HMAC(emisor-destinatario).

CREATE TABLE IF NOT EXISTS usuarios (
    usuario        TEXT PRIMARY KEY,
    nombre         TEXT NOT NULL,
    unidad         TEXT NOT NULL,
    emisor         TEXT NOT NULL,             -- buzón institucional desde el que envía
    password_hash  TEXT NOT NULL,             -- scrypt$n$r$p$sal$hash
    activo         INTEGER NOT NULL DEFAULT 1
);

-- Taxonomías (tipologías) de correo. Se amplían con SELLACORREO_TAXONOMIAS en .env.
CREATE TABLE IF NOT EXISTS taxonomias (
    codigo   TEXT PRIMARY KEY,
    nombre   TEXT NOT NULL,
    activa   INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS sellos (
    token          TEXT PRIMARY KEY,          -- aleatorio, va en el enlace
    codigo         TEXT NOT NULL UNIQUE,      -- código corto visible en la imagen
    message_id     TEXT NOT NULL UNIQUE,
    usuario        TEXT NOT NULL,
    nombre_emisor  TEXT NOT NULL,
    unidad         TEXT NOT NULL,
    emisor         TEXT NOT NULL,
    institucion    TEXT NOT NULL,
    taxonomia      TEXT NOT NULL,
    asunto         TEXT NOT NULL,             -- se muestra en CheckIn para comparar
    ts_utc         TEXT NOT NULL,
    recipient_hmac TEXT,                      -- NULL si no se indicó destinatario
    h              TEXT NOT NULL,             -- hash compuesto
    content_size   INTEGER NOT NULL,
    content_sha256 TEXT NOT NULL,
    kid            TEXT NOT NULL,
    sig            TEXT NOT NULL,             -- Ed25519 sobre H|id|ts_utc|taxonomía|kid
    palabra_cifrada TEXT,                     -- palabra segura cifrada (AES-GCM); solo se muestra en CheckIn válido
    palabra_tag    TEXT,                      -- HMAC corto de la palabra (va dentro del contenido sellado)
    expira_utc     TEXT,                      -- caducidad del enlace (NULL = no caduca)
    exige_destinatario INTEGER NOT NULL DEFAULT 0,
    exige_emisor   INTEGER NOT NULL DEFAULT 0
);

-- Log encadenado: una fila por sello generado, con prev_hash y firma.
CREATE TABLE IF NOT EXISTS log (
    seq            INTEGER PRIMARY KEY AUTOINCREMENT,
    entry_id       TEXT NOT NULL UNIQUE,
    ts_utc         TEXT NOT NULL,
    usuario        TEXT NOT NULL,
    taxonomia      TEXT NOT NULL,
    token_hash     TEXT NOT NULL,             -- SHA-256 del token (el token no se repite aquí)
    h              TEXT NOT NULL,
    seal_sig       TEXT NOT NULL,
    prev_hash      TEXT NOT NULL,
    entry_hash     TEXT NOT NULL UNIQUE,
    entry_kid      TEXT NOT NULL,
    entry_sig      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS verificaciones (
    vid      INTEGER PRIMARY KEY AUTOINCREMENT,
    ts_utc   TEXT NOT NULL,
    estado   TEXT NOT NULL,                   -- valido | no_registrado | hash_distinto | ...
    ip_hash  TEXT NOT NULL
);

INSERT OR IGNORE INTO taxonomias (codigo, nombre) VALUES
  ('comunicacional', 'Comunicacional'),
  ('informativo',    'Informativo'),
  ('recordatorio',   'Recordatorio');
