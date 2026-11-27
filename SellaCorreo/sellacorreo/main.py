"""SellaCorreo · sitio web anti-phishing (un solo servicio, puerto 8090).

Páginas:
  /login     inicio de sesión para usuarios del IESS (usuarios demo de .env)
  /genkey    (con sesión) elegir taxonomía y generar enlace dinámico + imagen de encabezado
  /checkin   (pública) clic en la imagen del correo -> «Correo válido» / «Correo inválido»

El enlace es /checkin/<token>.<h16>: token aleatorio + 16 primeros caracteres del hash
compuesto H = SHA-256(usuario | HMAC(emisor-destinatario) | ts_utc | tamaño | SHA-256(contenido)).
CheckIn compara la huella con H y verifica la firma Ed25519 del sello.
"""
from __future__ import annotations

import base64
import hashlib
import hmac
import html
import logging
import os
import re
import secrets
import threading
import time
import uuid
from collections import defaultdict, deque
from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import quote

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse, Response
from fastapi.staticfiles import StaticFiles

from autenticidad import canonical_content, composite_hash, recipient_hmac, seal_payload, sha256_hex
from autenticidad.banner import banner_png, invalid_png

from . import firma, store

class _SinHealth(logging.Filter):
    """Oculta del log de acceso las llamadas del healthcheck de Docker a /health."""

    def filter(self, record: logging.LogRecord) -> bool:
        args = record.args
        return not (isinstance(args, tuple) and len(args) >= 3 and str(args[2]).startswith("/health"))


logging.getLogger("uvicorn.access").addFilter(_SinHealth())

STATIC = Path(__file__).resolve().parent / "static"
LINK_RE = re.compile(r"^(?P<token>[A-Za-z0-9_-]{20,64})\.(?P<h16>[0-9a-f]{16})$")
EMAIL_RE = re.compile(r"^[^@\s<>\"',;]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$")
CODE_ALPHABET = "ABCDEFGHJKMNPQRSTVWXYZ23456789"
COOKIE = "sc_sesion"
E = html.escape


@asynccontextmanager
async def lifespan(_app):
    firma.key()
    store.init()
    yield


app = FastAPI(title="SellaCorreo", version="2.0.0", lifespan=lifespan,
              description="Sello anti-phishing para correos institucionales: GenKey y CheckIn.")
app.mount("/static", StaticFiles(directory=STATIC), name="static")


@app.middleware("http")
async def security_headers(request: Request, call_next):
    resp = await call_next(request)
    resp.headers["Content-Security-Policy"] = (
        "default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; "
        "frame-ancestors 'none'; form-action 'self'")
    resp.headers["X-Content-Type-Options"] = "nosniff"
    resp.headers["Referrer-Policy"] = "no-referrer"
    return resp


# ------------------------------------------------------------------ configuración
def public_base() -> str:
    return os.environ.get("SELLACORREO_PUBLIC_URL", "http://localhost:8090").rstrip("/")


def _secret(name: str) -> bytes:
    val = os.environ.get(name, "")
    if len(val) < 32:
        raise RuntimeError(f"{name} debe tener al menos 32 caracteres (defínalo en .env)")
    return val.encode()


# ------------------------------------------------------------------ límite por IP
class RateLimiter:
    def __init__(self, limit: int, window: float = 60.0) -> None:
        self.limit, self.window, self.hits, self.lock = limit, window, defaultdict(deque), threading.Lock()

    def allow(self, key: str) -> bool:
        now = time.monotonic()
        with self.lock:
            q = self.hits[key]
            while q and now - q[0] > self.window:
                q.popleft()
            if len(q) >= self.limit:
                return False
            q.append(now)
            return True


checkin_limiter = RateLimiter(int(os.environ.get("SELLACORREO_RATE_LIMIT_PER_MIN", "30")))
login_limiter = RateLimiter(int(os.environ.get("SELLACORREO_LOGIN_LIMIT_PER_MIN", "10")))


def ip_of(request: Request) -> str:
    return request.client.host if request.client else "?"


def ip_hash(request: Request) -> str:
    return hashlib.sha256(_secret("SELLACORREO_SESSION_KEY") + ip_of(request).encode()).hexdigest()[:16]


# ------------------------------------------------------------------ sesión y CSRF
def _b64(b: bytes) -> str:
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode()


def _unb64(s: str) -> bytes:
    return base64.urlsafe_b64decode(s + "=" * (-len(s) % 4))


def make_session(usuario: str) -> str:
    exp = int(time.time()) + int(os.environ.get("SELLACORREO_SESSION_TTL", "28800"))
    body = f"{usuario}|{exp}|{secrets.token_hex(8)}".encode()
    mac = hmac.new(_secret("SELLACORREO_SESSION_KEY"), body, hashlib.sha256).digest()
    return _b64(body) + "." + _b64(mac)


def current_user(request: Request) -> dict | None:
    raw = request.cookies.get(COOKIE, "")
    try:
        body_b64, mac_b64 = raw.split(".", 1)
        body = _unb64(body_b64)
        good = hmac.new(_secret("SELLACORREO_SESSION_KEY"), body, hashlib.sha256).digest()
        if not hmac.compare_digest(good, _unb64(mac_b64)):
            return None
        usuario, exp, _ = body.decode().split("|")
        if int(exp) < time.time():
            return None
    except (ValueError, UnicodeDecodeError):
        return None
    return store.get_user(usuario)


def csrf_token(request: Request) -> str:
    return hmac.new(_secret("SELLACORREO_SESSION_KEY"), b"csrf|" + request.cookies.get(COOKIE, "").encode(),
                    hashlib.sha256).hexdigest()[:32]


def csrf_ok(request: Request, token: str) -> bool:
    return hmac.compare_digest(csrf_token(request), token or "")


# ------------------------------------------------------------------ plantillas
def page(title: str, body: str, user: dict | None = None, request: Request | None = None,
         status: int = 200, active: str = "", chrome: str = "") -> HTMLResponse:
    def link(href, label, key):
        cur = ' aria-current="page"' if key == active else ""
        return f'<a class="tl-nav__link"{cur} href="{href}">{label}</a>'
    nav = link("/", "Inicio", "inicio") + link("/genkey", "Sello", "genkey") + link("/checkin", "Validador", "checkin")
    if user:
        right = (f'<form method="post" action="/logout" class="sc-logout"><input type="hidden" name="csrf" '
                 f'value="{csrf_token(request)}">{"" if chrome == "genkey" else chr(60) + "span class=" + chr(34) + "sc-user" + chr(34) + ">" + E(user["nombre"]) + chr(60) + "/span>"}'
                 f'<button class="tl-btn tl-btn--ghost tl-btn--sm sc-logout__btn" type="submit">Salir</button></form>')
    else:
        right = '<a class="tl-btn tl-btn--secondary tl-btn--sm" href="/login">Ingresar</a>'
    if chrome in ("home", "genkey"):  # estas páginas no tienen encabezado: sus opciones van en el pie
        sesion = (f'<form method="post" action="/logout" class="sc-logout"><input type="hidden" name="csrf" '
                  f'value="{csrf_token(request)}"><button class="tl-btn tl-btn--ghost tl-btn--sm" type="submit">Salir</button></form>'
                  if user else '<a href="/login">Ingresar</a>')
        links = (f'<nav class="sc-foot-links" aria-label="Secciones"><a href="/">Inicio</a><a href="/genkey">Sello</a>'
                 f'<a href="/checkin">Validador</a>{sesion}</nav>')
        head = ""
    else:
        links = ""
        brand = ("" if chrome == "genkey" else
                 '<a class="tl-nav__brand sc-brand" href="/"><img src="/static/marca.svg" alt="" width="26" height="26">Sella<em>Correo</em></a>')
        head = (f'<nav class="tl-nav"><div class="tl-nav__inner">{brand}'
                f'<div class="tl-nav__links">{nav}</div><div class="sc-nav-right">{right}</div></div></nav>')
    return HTMLResponse(status_code=status, content=f"""<!doctype html><html lang="es"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>{E(title)} · SellaCorreo</title>
<link rel="icon" href="/static/marca.svg" type="image/svg+xml">
<link rel="stylesheet" href="/static/tokens.css"><link rel="stylesheet" href="/static/components.css">
<link rel="stylesheet" href="/static/sella.css"></head><body class="tl-body">
{head}
<main class="tl-main sc-main">{body}</main>
<footer class="tl-foot"><div class="tl-foot__inner"><span>SellaCorreo · sello anti-phishing para correo institucional</span>
<span class="tl-foot__small">La institución nunca pide contraseñas ni datos bancarios por correo.</span>{links}</div></footer>
<script src="/static/app.js"></script></body></html>""")


def verdict(ok: bool, text: str) -> str:
    cls, icon, title = ("ok", "✓", "Correo válido") if ok else ("bad", "✕", "Correo inválido")
    return (f'<section class="sc-verdict sc-verdict--{cls}" data-resultado="{"valido" if ok else "invalido"}">'
            f'<div class="sc-verdict__icon">{icon}</div><div><h1 class="sc-verdict__title">{title}</h1>'
            f'<p class="sc-verdict__text">{E(text)}</p></div></section>')


def fmt_code(c: str) -> str:
    return f"{c[:4]}-{c[4:8]}-{c[8:]}"


# ------------------------------------------------------------------ rutas generales
@app.get("/health")
def health():
    return {"status": "ok"}


def dial_svg() -> str:
    """Bisel tipo reloj: 60 marcas (12 mayores), puntos arriba/izquierda/derecha y un puntero naranja."""
    ticks = []
    for i in range(60):
        major = i % 5 == 0
        r1 = 214 if major else 222
        cls = "sc-dial__tick sc-dial__tick--major" if major else "sc-dial__tick"
        ticks.append(f'<line class="{cls}" x1="250" y1="{250 - r1}" x2="250" y2="20" transform="rotate({i * 6} 250 250)"/>')
    dots = "".join(f'<circle class="sc-dial__dot" cx="{x}" cy="{y}" r="5"/>' for x, y in [(250, 4), (4, 250), (496, 250), (250, 496)])
    return (f'<svg class="sc-dial__svg" viewBox="0 0 500 500" aria-hidden="true"><g class="sc-dial__ticks">{"".join(ticks)}</g>{dots}'
            f'<g class="sc-dial__pointer"><path d="M250 18 l-9 -16 h18 z"/></g></svg>')


def home_stats() -> dict:
    with store.connect() as conn:
        sellos = conn.execute("SELECT COUNT(*) FROM sellos").fetchone()[0]
        checks = conn.execute("SELECT COUNT(*) FROM verificaciones").fetchone()[0]
        bloqueados = conn.execute("SELECT COUNT(*) FROM verificaciones WHERE estado NOT LIKE 'valido%' "
                                  "AND estado <> 'pendiente_destinatario'").fetchone()[0]
    return {"sellos": sellos, "checks": checks, "bloqueados": bloqueados}


ICON_SHIELD = ('<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l7 3v6c0 4.5-3 7.8-7 9-4-1.2-7-4.5-7-9V6z"/></svg>')
ICON_DOC = ('<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="3" width="14" height="18" rx="2"/>'
            '<path d="M9 8h6M9 12h6M9 16h3"/></svg>')
ICON_ARROW = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h13M13 6l6 6-6 6"/></svg>'


def home_card(kind: str, href: str, title: str, text: str, icon: str, extra: str = "") -> str:
    more = f'<span class="sc-hcard__text sc-hcard__text--extra">{E(extra)}</span>' if extra else ""
    return (f'<a class="sc-hcard sc-hcard--{kind}" href="{href}" data-home-card="{kind}">'
            f'<span class="sc-hcard__icon">{icon}</span><span class="sc-hcard__body"><span class="sc-hcard__title">{E(title)}</span>'
            f'<span class="sc-hcard__text">{E(text)}</span>{more}</span><span class="sc-hcard__go">{ICON_ARROW}</span></a>')


@app.get("/", response_class=HTMLResponse)
def home(request: Request):
    user = current_user(request)
    st = home_stats()
    body = f"""<section class="sc-home" aria-labelledby="home-title">
  <h1 class="sc-home__title" id="home-title">AI-IESS</h1>
  <p class="sc-home__sub">SellaCorreo: sella los correos institucionales y permite que cualquiera compruebe si son auténticos.</p>
  <div class="sc-home__stage" id="sc-home-stage">
    <div class="sc-dial">{dial_svg()}
      <img class="sc-dial__img sc-dial__img--base sc-dial__img--escudo" src="/static/img/escudo-correo.png" alt="Escudo azul con un sobre de correo" width="410" height="410">
      <img class="sc-dial__img sc-dial__img--sello" src="/static/img/sello.jpg" alt="Sobre digital protegido por un escudo" width="410" height="410" aria-hidden="true">
      <span class="sc-dial__cap sc-dial__cap--bottom">Anti-phishing</span>
    </div>
    {home_card("sello", "/genkey", "Sello", "Crea tu sello de seguridad y evita el phishing", ICON_DOC)}
    {home_card("validador", "/checkin", "Validador", "Valida el hash y evita la suplantación de identidad", ICON_SHIELD,
                "Haga clic en el encabezado de su correo o pegue su enlace en este Validador.")}
  </div>
</section>
<section class="tl-grid-stats sc-home__stats" aria-label="Resumen">
  <div class="tl-card tl-stat"><div class="tl-stat__label">Sellos emitidos</div><div class="tl-stat__value">{st["sellos"]}</div><div class="tl-hint">Firmados con Ed25519</div></div>
  <div class="tl-card tl-stat"><div class="tl-stat__label">Verificaciones</div><div class="tl-stat__value">{st["checks"]}</div><div class="tl-hint">Consultas en el Validador</div></div>
  <div class="tl-card tl-stat"><div class="tl-stat__label">Posibles phishing detectados</div><div class="tl-stat__value">{st["bloqueados"]}</div><div class="tl-hint">Enlaces inválidos, alterados o caducados</div></div>
</section>
"""
    return page("Inicio", body, user, request, active="inicio", chrome="home")


@app.get("/.well-known/sellacorreo-key")
def public_key():
    return firma.public()


# ------------------------------------------------------------------ login
def demo_card() -> str:
    if not store.demo_mode():
        return ""
    users = store.demo_users()
    if not users:
        return ""
    rows = "".join(f"""<form method="post" action="/login" class="sc-quick__form">
<input type="hidden" name="usuario" value="{E(u['emisor'])}"><input type="hidden" name="clave" value="{E(store.demo_password())}">
<button type="submit" class="sc-quick__row" data-demo="{E(u['usuario'])}"><span class="sc-quick__text">
<span class="sc-quick__title">{E(u['nombre'])}</span><span class="sc-quick__sub">{E(u['unidad'])} · {E(u['emisor'])}</span></span>
<span class="sc-quick__arrow" aria-hidden="true">→</span></button></form>""" for u in users)
    return f"""<section class="tl-card sc-quick" aria-labelledby="demo-title"><div class="tl-card__body">
<h2 class="sc-card-title" id="demo-title">Acceso rápido de demostración</h2>
<p class="tl-page-desc">Todas las cuentas de prueba usan la contraseña <code class="sc-pass">{E(store.demo_password())}</code>.</p>
<div class="sc-quick__list">{rows}</div></div></section>"""


def login_page(error: str = "", usuario: str = "", status: int = 200) -> HTMLResponse:
    alert = f'<div class="tl-alert tl-alert--destructive" role="alert"><div class="tl-alert__body">{E(error)}</div></div>' if error else ""
    demo = demo_card()
    return page("Ingresar", f"""<section class="sc-login{' sc-login--demo' if demo else ''}">
<section class="tl-card"><div class="tl-card__body">
<h1 class="sc-card-title sc-card-title--lg">Ingresar</h1>
<p class="tl-page-desc">Acceso para el personal del IESS que genera sellos. Los destinatarios verifican sin cuenta en <a href="/checkin">CheckIn</a>.</p>
{alert}
<form class="sc-form" method="post" action="/login" autocomplete="on">
<div class="tl-field"><label class="tl-field__label" for="usuario">Correo electrónico</label>
<input class="tl-input" id="usuario" name="usuario" required autocomplete="username" placeholder="usuario@demo.institucion.test" value="{E(usuario)}"></div>
<div class="tl-field"><label class="tl-field__label" for="clave">Contraseña</label>
<input class="tl-input" id="clave" name="clave" type="password" required autocomplete="current-password"></div>
<button class="tl-btn tl-btn--default sc-btn-block" type="submit">Ingresar</button>
</form></div></section>{demo}</section>""", status=status)


@app.get("/login", response_class=HTMLResponse)
def login_form(request: Request):
    if current_user(request):
        return RedirectResponse("/genkey", status_code=303)
    return login_page()


@app.post("/login")
def login(request: Request, usuario: str = Form(...), clave: str = Form(...)):
    if not login_limiter.allow(ip_of(request)):
        return login_page("Demasiados intentos. Espere un minuto.", usuario, 429)
    user = store.authenticate(usuario, clave)
    if user is None:
        return login_page("Usuario o contraseña incorrectos.", usuario, 401)
    resp = RedirectResponse("/genkey", status_code=303)
    resp.set_cookie(COOKIE, make_session(user["usuario"]), httponly=True, samesite="lax",
                    secure=os.environ.get("SELLACORREO_COOKIE_SECURE", "false").lower() == "true",
                    max_age=int(os.environ.get("SELLACORREO_SESSION_TTL", "28800")))
    return resp


@app.post("/logout")
def logout(request: Request, csrf: str = Form("")):
    resp = RedirectResponse("/login", status_code=303)
    if csrf_ok(request, csrf):
        resp.delete_cookie(COOKIE)
    return resp


# ------------------------------------------------------------------ políticas de seguridad
CADUCIDADES = {"1": "24 horas", "7": "7 días", "30": "30 días", "90": "90 días"}


def _pw_key(token: str) -> bytes:
    return hmac.new(_secret("SELLACORREO_HMAC_KEY"), b"palabra-segura|" + token.encode(), hashlib.sha256).digest()


def encrypt_word(token: str, word: str) -> str:
    nonce = secrets.token_bytes(12)
    return _b64(nonce + AESGCM(_pw_key(token)).encrypt(nonce, word.encode(), token.encode()))


def decrypt_word(token: str, blob: str | None) -> str | None:
    if not blob:
        return None
    raw = _unb64(blob)
    return AESGCM(_pw_key(token)).decrypt(raw[:12], raw[12:], token.encode()).decode()


def word_tag(word: str) -> str:
    return hmac.new(_secret("SELLACORREO_HMAC_KEY"), b"tag|" + word.encode(), hashlib.sha256).hexdigest()[:16]


def policy_line(expira: str | None, tag: str | None, exige: bool, exige_emisor: bool = False) -> str:
    """Las políticas forman parte del contenido sellado: alterarlas cambia el hash H.
    «emisor» solo aparece cuando está activa, así los sellos anteriores siguen validando."""
    base = f"politicas: caduca={expira or '-'}; palabra={tag or '-'}; destinatario={'obligatorio' if exige else 'opcional'}"
    return base + ("; emisor=obligatorio" if exige_emisor else "")


def seal_content(asunto: str, expira: str | None, tag: str | None, exige: bool, exige_emisor: bool = False) -> bytes:
    return canonical_content(asunto, policy_line(expira, tag, exige, exige_emisor))


# ------------------------------------------------------------------ GenKey
def initials(name: str) -> str:
    parts = [p for p in re.split(r"\s+", name) if p and p[0].isalpha() and p.lower() not in {"de", "del", "la", "y"}]
    return "".join(p[0].upper() for p in parts[:2]) or "SC"


def genkey_form(request: Request, user: dict, error: str = "", values: dict | None = None) -> str:
    v = {"taxonomia": "comunicacional", "asunto": "", "destinatario": "", "pol_palabra": "", "palabra": "",
         "pol_caducidad": "", "caducidad": "7", "pol_destinatario": "", "pol_emisor": "", **(values or {})}
    taxs = store.taxonomias()
    left = "".join(
        f'<label class="sc-node sc-node--left" data-node><input type="radio" name="taxonomia" value="{E(t["codigo"])}"'
        f'{" checked" if t["codigo"] == v["taxonomia"] else ""} required>'
        f'<span class="sc-node__dot sc-node__dot--{i % 6}"></span>{E(t["nombre"])}</label>'
        for i, t in enumerate(taxs))
    def pol(name, label, hint):
        return (f'<label class="sc-node sc-node--right" data-node title="{E(hint)}"><input type="checkbox" name="{name}" value="1"'
                f'{" checked" if v[name] else ""} data-policy="{name}"><span class="sc-node__dot sc-node__dot--pol"></span>{E(label)}</label>')
    right = (pol("pol_palabra", "Palabra segura", "El destinatario verá esta palabra en CheckIn si el correo es auténtico")
             + pol("pol_caducidad", "Caducidad del enlace", "Después de la fecha, CheckIn lo marcará inválido")
             + pol("pol_destinatario", "Exigir destinatario", "CheckIn solo dirá «válido» si quien verifica es el destinatario")
             + pol("pol_emisor", "Exigir emisor", "CheckIn pedirá confirmar el correo de quien envió el mensaje"))
    cad = "".join(f'<option value="{k}"{" selected" if k == v["caducidad"] else ""}>{E(lbl)}</option>' for k, lbl in CADUCIDADES.items())
    alert = f'<div class="tl-alert tl-alert--destructive" role="alert"><div class="tl-alert__body">{E(error)}</div></div>' if error else ""
    return f"""<header class="tl-page-head sc-page-center"><h1 class="tl-h1">GenKey</h1></header>
{alert}
<form class="sc-form" method="post" action="/genkey" autocomplete="off" id="genkey-form">
<input type="hidden" name="csrf" value="{csrf_token(request)}">
<section class="tl-card sc-map-card"><div class="tl-card__body">
<div class="sc-map" id="sc-map">
  <svg class="sc-map__lines" id="sc-lines" aria-hidden="true"></svg>
  <fieldset class="sc-map__col sc-map__col--left"><legend class="sc-map__legend sc-map__legend--strong">Taxonomía del correo</legend>{left}</fieldset>
  <div class="sc-map__center">
    <div class="sc-hub" id="sc-hub">
      <svg class="sc-hub__ring" viewBox="0 0 120 120" aria-hidden="true">
        <circle cx="60" cy="60" r="54" class="sc-hub__track"/>
        <circle cx="60" cy="60" r="54" class="sc-hub__progress" id="sc-progress" pathLength="100"/>
      </svg>
      <div class="sc-hub__avatar"><img class="sc-hub__img" src="/static/img/genkey-logo.png" alt="" width="160" height="160"></div>
      <span class="sc-hub__knob" aria-hidden="true"></span>
    </div>
    <div class="sc-hub__name">Nivel de seguridad</div>
    <div class="sc-hub__meta">Generar, copia y pegale a tu correo</div>
  </div>
  <fieldset class="sc-map__col sc-map__col--right"><legend class="sc-map__legend sc-map__legend--strong">Hash de seguridad</legend>{right}</fieldset>
</div></div></section>

<section class="tl-card"><div class="tl-card__body sc-form">
<div class="tl-field"><label class="tl-field__label" for="asunto">Asunto del correo</label>
<input class="tl-input" id="asunto" name="asunto" required maxlength="300" value="{E(v['asunto'])}">
<span class="tl-hint">Forma parte del hash del sello y aparece en CheckIn para que el destinatario compare.</span></div>
<div class="tl-field"><label class="tl-field__label" for="destinatario">Correo del destinatario <span id="dest-opt">(opcional)</span></label>
<input class="tl-input" id="destinatario" name="destinatario" type="email" value="{E(v['destinatario'])}">
<span class="tl-hint">Se guarda solo como huella HMAC.</span></div>
<div class="tl-field sc-policy" data-for="pol_palabra"><label class="tl-field__label" for="palabra">Palabra segura</label>
<input class="tl-input" id="palabra" name="palabra" maxlength="40" value="{E(v['palabra'])}" placeholder="p. ej. girasol-azul">
<span class="tl-hint">Acuérdela antes con el destinatario. CheckIn la muestra solo si el correo es válido; se guarda cifrada.</span></div>
<div class="tl-field sc-policy" data-for="pol_caducidad"><label class="tl-field__label" for="caducidad">El enlace caduca en</label>
<select class="tl-select" id="caducidad" name="caducidad">{cad}</select></div>
<div class="tl-row"><button class="tl-btn tl-btn--default" type="submit">Generar enlace e imagen</button>
<span class="tl-hint">Emisor: {E(user['emisor'])}</span></div>
</div></section>
</form>{history(user)}"""


def history(user: dict) -> str:
    rows = store.seals_of(user["usuario"])
    if not rows:
        return ""
    trs = "".join(
        f'<tr><td>{E(r["ts_utc"])}</td><td>{E(r["taxonomia"])}</td><td>{E(r["asunto"])}</td>'
        f'<td><a href="/checkin/{E(r["token"])}.{E(r["h"][:16])}">{E(fmt_code(r["codigo"]))}</a></td></tr>' for r in rows)
    return (f'<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Mis últimos sellos</h2>'
            f'<table class="sc-table"><tr><th>Fecha (UTC)</th><th>Taxonomía</th><th>Asunto</th><th>Código</th></tr>{trs}</table>'
            f'</div></section>')


@app.get("/genkey", response_class=HTMLResponse)
def genkey_get(request: Request):
    user = current_user(request)
    if not user:
        return RedirectResponse("/login", status_code=303)
    return page("GenKey", genkey_form(request, user), user, request, active="genkey", chrome="genkey")


def create_seal(user: dict, taxonomia: str, asunto: str, destinatario: str, palabra: str | None = None,
                dias: int | None = None, exige_destinatario: bool = False, exige_emisor: bool = False) -> dict:
    asunto = asunto.strip()[:300]
    now = datetime.now(timezone.utc).replace(microsecond=0)
    ts = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    expira = (now + timedelta(days=dias)).strftime("%Y-%m-%dT%H:%M:%SZ") if dias else None
    msg_id = str(uuid.uuid4())
    token = secrets.token_urlsafe(18)
    tag = word_tag(palabra) if palabra else None
    content = seal_content(asunto.strip(), expira, tag, exige_destinatario, exige_emisor)
    size, csha = len(content), sha256_hex(content)
    rh = recipient_hmac(_secret("SELLACORREO_HMAC_KEY"), user["emisor"], destinatario or "*")
    h = composite_hash(user["usuario"], rh, ts, size, csha)
    kid = firma.public()["kid"]
    _, sig = firma.sign(seal_payload(h, msg_id, ts, taxonomia, kid))
    codigo = "".join(secrets.choice(CODE_ALPHABET) for _ in range(10))
    store.save_seal({
        "token": token, "codigo": codigo, "message_id": msg_id, "usuario": user["usuario"],
        "nombre_emisor": user["nombre"], "unidad": user["unidad"], "emisor": user["emisor"],
        "institucion": store.INSTITUCION, "taxonomia": taxonomia, "asunto": asunto.strip()[:300], "ts_utc": ts,
        "recipient_hmac": rh if destinatario else None, "h": h, "content_size": size, "content_sha256": csha,
        "kid": kid, "sig": sig, "palabra_cifrada": encrypt_word(token, palabra) if palabra else None,
        "palabra_tag": tag, "expira_utc": expira, "exige_destinatario": 1 if exige_destinatario else 0,
        "exige_emisor": 1 if exige_emisor else 0})
    store.append_log(usuario=user["usuario"], taxonomia=taxonomia, token_hash=store.sha(token), h=h, seal_sig=sig)
    base = public_base()
    return {"token": token, "codigo": fmt_code(codigo), "h": h, "expira": expira,
            "enlace": f"{base}/checkin/{token}.{h[:16]}", "imagen": f"{base}/img/{token}.png"}


@app.post("/genkey", response_class=HTMLResponse)
def genkey_post(request: Request, csrf: str = Form(""), taxonomia: str = Form(...), asunto: str = Form(...),
                destinatario: str = Form(""), pol_palabra: str = Form(""), palabra: str = Form(""),
                pol_caducidad: str = Form(""), caducidad: str = Form("7"), pol_destinatario: str = Form(""),
                pol_emisor: str = Form("")):
    user = current_user(request)
    if not user:
        return RedirectResponse("/login", status_code=303)
    values = {"taxonomia": taxonomia, "asunto": asunto, "destinatario": destinatario, "pol_palabra": pol_palabra,
              "palabra": palabra, "pol_caducidad": pol_caducidad, "caducidad": caducidad, "pol_destinatario": pol_destinatario,
              "pol_emisor": pol_emisor}
    if not csrf_ok(request, csrf):
        return page("GenKey", genkey_form(request, user, "La sesión del formulario expiró. Intente de nuevo.", values),
                    user, request, 403, "genkey", chrome="genkey")
    destinatario = destinatario.strip().lower()
    palabra = palabra.strip()
    err = ""
    if taxonomia not in {t["codigo"] for t in store.taxonomias()}:
        err = "Taxonomía no válida."
    elif not asunto.strip():
        err = "Escriba el asunto."
    elif destinatario and not EMAIL_RE.match(destinatario):
        err = "El correo del destinatario no es válido."
    elif pol_palabra and not (3 <= len(palabra) <= 40):
        err = "La palabra segura debe tener entre 3 y 40 caracteres."
    elif pol_caducidad and caducidad not in CADUCIDADES:
        err = "Caducidad no válida."
    elif pol_destinatario and not destinatario:
        err = "La política «Exigir destinatario» necesita el correo del destinatario."
    if err:
        return page("GenKey", genkey_form(request, user, err, values), user, request, 422, "genkey", chrome="genkey")
    s = create_seal(user, taxonomia, asunto, destinatario, palabra if pol_palabra else None,
                    int(caducidad) if pol_caducidad else None, bool(pol_destinatario), bool(pol_emisor))
    politicas = [p for p, on in [("palabra segura", pol_palabra), (f"caduca {s['expira']}" if s["expira"] else "", pol_caducidad),
                                 ("exige destinatario", pol_destinatario), ("exige emisor", pol_emisor)] if on and p]
    snippet = (f'<a href="{s["enlace"]}"><img src="{s["imagen"]}" width="640" height="120" '
               f'alt="SellaCorreo: haga clic para verificar este correo" style="display:block;border:0"></a>')
    body = f"""<div class="tl-alert tl-alert--ok" role="status"><div class="tl-alert__title">Sello generado · código {E(s['codigo'])}</div>
<div class="tl-alert__body">Pegue la imagen al inicio del correo «{E(asunto)}» ({E(taxonomia)}).
Políticas: {E(", ".join(politicas) or "ninguna")}.</div></div>
<section class="tl-card"><div class="tl-card__body sc-form">
<div class="tl-field"><span class="tl-field__label">1 · Imagen con enlace (cópiela y péguela en Outlook o Gmail)</span>
<div id="sello-preview" class="sc-preview"><a href="{E(s['enlace'])}"><img class="sc-banner" src="{E(s['imagen'])}" width="640" height="120" alt="SellaCorreo: haga clic para verificar este correo"></a></div>
<div class="tl-row"><button class="tl-btn tl-btn--default" type="button" data-copy-html="sello-preview">Copiar imagen con enlace</button>
<a class="tl-btn tl-btn--secondary" href="{E(s['enlace'])}" target="_blank" rel="noopener">Probar en CheckIn</a></div></div>
<div class="tl-field"><label class="tl-field__label" for="enlace">2 · Enlace dinámico</label>
<input class="tl-input sc-code" id="enlace" readonly value="{E(s['enlace'])}">
<div class="tl-row"><button class="tl-btn tl-btn--ghost tl-btn--sm" type="button" data-copy="enlace">Copiar enlace</button></div></div>
<div class="tl-field"><label class="tl-field__label" for="html">3 · HTML para pegar (si su editor admite HTML)</label>
<textarea class="tl-textarea sc-code" id="html" rows="4" readonly>{E(snippet)}</textarea>
<div class="tl-row"><button class="tl-btn tl-btn--ghost tl-btn--sm" type="button" data-copy="html">Copiar HTML</button>
<a class="tl-btn tl-btn--ghost tl-btn--sm" href="{E(s['imagen'])}" download="sellacorreo-{E(s['codigo'])}.png">Descargar imagen</a></div></div>
<dl class="sc-kv"><dt>Hash H</dt><dd>{E(s['h'])}</dd><dt>Firma</dt><dd>Ed25519 · {E(firma.public()['kid'])}</dd></dl>
</div></section>
<p><a class="tl-btn tl-btn--secondary" href="/genkey">Generar otro sello</a></p>"""
    return page("Sello generado", body, user, request, active="genkey")


@app.get("/api/v1/integridad")
def integrity(request: Request):
    if not current_user(request):
        return JSONResponse(status_code=401, content={"error": "inicie sesión"})
    return store.verify_chain()


# ------------------------------------------------------------------ CheckIn
MOTIVOS = {
    "enlace_malformado": "El enlace no tiene el formato de SellaCorreo.",
    "no_registrado": "No existe ningún correo institucional con este sello.",
    "hash_distinto": "La huella del enlace no coincide con el hash registrado: el enlace fue alterado.",
    "contenido_alterado": "Los datos del sello no coinciden con su hash: el registro fue alterado.",
    "firma_invalida": "La firma digital del sello no es válida.",
    "caducado": "El sello de este correo ya caducó.",
}


def check_link(link: str) -> tuple[bool, str, dict | None]:
    m = LINK_RE.match(link)
    if not m:
        return False, "enlace_malformado", None
    seal = store.get_seal(m["token"])
    if seal is None:
        return False, "no_registrado", None
    if not hmac.compare_digest(seal["h"][:16], m["h16"]):
        return False, "hash_distinto", seal
    # Recalcular H con los datos guardados (asunto + políticas): detecta registros manipulados
    content = seal_content(seal["asunto"], seal.get("expira_utc"), seal.get("palabra_tag"),
                           bool(seal.get("exige_destinatario")), bool(seal.get("exige_emisor")))
    rh = seal["recipient_hmac"] or recipient_hmac(_secret("SELLACORREO_HMAC_KEY"), seal["emisor"], "*")
    if composite_hash(seal["usuario"], rh, seal["ts_utc"], len(content), sha256_hex(content)) != seal["h"]:
        return False, "contenido_alterado", seal
    payload = seal_payload(seal["h"], seal["message_id"], seal["ts_utc"], seal["taxonomia"], seal["kid"])
    if not firma.verify(seal["kid"], payload, seal["sig"]):
        return False, "firma_invalida", seal
    if seal.get("expira_utc") and seal["expira_utc"] < store.now_utc():
        return False, "caducado", seal
    return True, "valido", seal


def safe_word_box(seal: dict) -> str:
    word = decrypt_word(seal["token"], seal.get("palabra_cifrada"))
    if not word:
        return ""
    return (f'<section class="sc-safeword" data-palabra-segura><span class="sc-safeword__label">Palabra segura</span>'
            f'<span class="sc-safeword__word">{E(word)}</span><span class="sc-safeword__hint">Debe coincidir con la que '
            f'acordó con la institución. Si no la reconoce, no confíe en el correo.</span></section>')


def seal_details(seal: dict) -> str:
    rows = [("Asunto", seal["asunto"]), ("Taxonomía", seal["taxonomia"]), ("Emisor", seal["nombre_emisor"]),
            ("Unidad", seal["unidad"]), ("Buzón", seal["emisor"]), ("Institución", seal["institucion"]),
            ("Fecha (UTC)", seal["ts_utc"]), ("Código", fmt_code(seal["codigo"]))]
    if seal.get("expira_utc"):
        rows.append(("Válido hasta (UTC)", seal["expira_utc"]))
    dl = "".join(f"<dt>{E(k)}</dt><dd>{E(v)}</dd>" for k, v in rows)
    return (f'<section class="tl-card"><div class="tl-card__body"><p class="tl-text">Compare con el correo que recibió: '
            f'el asunto y el remitente deben coincidir.</p><dl class="sc-kv">{dl}</dl></div></section>')


def recipient_form(link: str, required: bool = False) -> str:
    label = ("Este correo exige confirmar el destinatario: escriba el correo en el que lo recibió" if required
             else "¿Le llegó a usted? Confírmelo con su correo")
    return f"""<section class="tl-card"><div class="tl-card__body">
<form class="sc-form" method="post" action="/checkin/{E(link)}">
<div class="tl-field"><label class="tl-field__label" for="correo">{label}</label>
<input class="tl-input" id="correo" name="correo" type="email" required placeholder="usted@ejemplo.com">
<span class="tl-hint">Detecta si alguien copió esta imagen en un correo falso. Su correo no se guarda.</span></div>
<div class="tl-row"><button class="tl-btn tl-btn--default" type="submit">Confirmar destinatario</button></div>
</form></div></section>"""


def confirm_form(link: str, need_emisor: bool, need_destinatario: bool) -> str:
    """Formulario que pide solo lo que exigen las políticas activas del sello."""
    campos = ""
    if need_emisor:
        campos += ('<div class="tl-field"><label class="tl-field__label" for="emisor">Correo institucional de quien le envió este mensaje</label>'
                   '<input class="tl-input" id="emisor" name="emisor" type="email" required placeholder="remitente@institucion.gob">'
                   '<span class="tl-hint">Use el remitente que aparece en el correo que recibió. Debe coincidir con el emisor del sello.</span></div>')
    if need_destinatario:
        campos += ('<div class="tl-field"><label class="tl-field__label" for="correo">Correo en el que recibió este mensaje</label>'
                   '<input class="tl-input" id="correo" name="correo" type="email" required placeholder="usted@ejemplo.com">'
                   '<span class="tl-hint">Detecta si alguien copió esta imagen en un correo falso. Su correo no se guarda.</span></div>')
    return (f'<section class="tl-card"><div class="tl-card__body"><form class="sc-form" method="post" action="/checkin/{E(link)}">'
            f'{campos}<div class="tl-row"><button class="tl-btn tl-btn--default" type="submit">Confirmar</button></div>'
            f'</form></div></section>')


def pending(text: str) -> str:
    return (f'<section class="sc-verdict sc-verdict--pending" data-resultado="pendiente"><div class="sc-verdict__icon">?</div>'
            f'<div><h1 class="sc-verdict__title">Falta un paso</h1><p class="sc-verdict__text">{E(text)}</p></div></section>')


def _extract_link(value: str) -> str:
    value = value.strip()
    m = re.search(r"/checkin/([A-Za-z0-9_.-]+)", value)
    return m.group(1) if m else value


@app.get("/checkin", response_class=HTMLResponse)
def checkin_home(request: Request, enlace: str = ""):
    if enlace:
        return RedirectResponse(f"/checkin/{quote(_extract_link(enlace), safe='')}", status_code=303)
    return page("CheckIn", """<header class="tl-page-head"><h1 class="tl-h1">CheckIn</h1>
<p class="tl-page-desc">¿Recibió un correo que dice ser del IESS? Haga clic en la imagen SellaCorreo del encabezado,
o pegue aquí el enlace de esa imagen.</p></header>
<section class="tl-card"><div class="tl-card__body"><form class="sc-form" method="get" action="/checkin">
<div class="tl-field"><label class="tl-field__label" for="enlace">Enlace de la imagen SellaCorreo</label>
<input class="tl-input sc-code" id="enlace" name="enlace" required placeholder="http://localhost:8090/checkin/..."></div>
<div class="tl-row"><button class="tl-btn tl-btn--default" type="submit">Verificar</button></div></form>
<p class="tl-hint">Si el correo no trae imagen SellaCorreo, desconfíe: los correos institucionales sellados siempre la llevan.</p>
</div></section>""", current_user(request), request, active="checkin")


def _invalid(motivo: str, user, request):
    return page("Correo inválido", verdict(False, MOTIVOS[motivo] + " Podría ser phishing: no haga clic en sus "
                                           "enlaces ni entregue datos."), user, request, active="checkin")


@app.get("/checkin/{link}", response_class=HTMLResponse)
def checkin(link: str, request: Request):
    user = current_user(request)
    if not checkin_limiter.allow(ip_of(request)):
        return page("CheckIn", verdict(False, "Demasiadas consultas. Intente en un minuto."), user, request, 429, "checkin")
    ok, motivo, seal = check_link(link)
    if not ok:
        store.record_verification(motivo, ip_hash(request))
        return _invalid(motivo, user, request)
    need_em, need_de = bool(seal.get("exige_emisor")), bool(seal.get("exige_destinatario"))
    if need_em or need_de:
        store.record_verification("pendiente_confirmacion", ip_hash(request))
        return page("CheckIn", pending("El sello existe, pero este correo exige confirmar " +
                                       ("el emisor" if need_em else "") + (" y " if need_em and need_de else "") +
                                       ("el destinatario" if need_de else "") + " antes de mostrar el resultado.")
                    + confirm_form(link, need_em, need_de), user, request, active="checkin")
    store.record_verification("valido", ip_hash(request))
    texto = f"Emitido por {seal['nombre_emisor']} ({seal['institucion']}). El hash y la firma digital coinciden."
    extra = recipient_form(link) if seal["recipient_hmac"] else ""
    return page("Correo válido", verdict(True, texto) + safe_word_box(seal) + seal_details(seal) + extra,
                user, request, active="checkin")


@app.post("/checkin/{link}", response_class=HTMLResponse)
def checkin_recipient(link: str, request: Request, correo: str = Form(""), emisor: str = Form("")):
    user = current_user(request)
    if not checkin_limiter.allow(ip_of(request)):
        return page("CheckIn", verdict(False, "Demasiadas consultas. Intente en un minuto."), user, request, 429, "checkin")
    ok, motivo, seal = check_link(link)
    if not ok:
        store.record_verification(motivo, ip_hash(request))
        return _invalid(motivo, user, request)
    need_em, need_de = bool(seal.get("exige_emisor")), bool(seal.get("exige_destinatario"))
    if need_em or need_de:
        if (need_em and not emisor.strip()) or (need_de and not correo.strip()):
            store.record_verification("pendiente_confirmacion", ip_hash(request))
            return page("CheckIn", pending("Complete los datos que exige este sello.")
                        + confirm_form(link, need_em, need_de), user, request, active="checkin")
        if need_em and emisor.strip().lower() != seal["emisor"].lower():
            store.record_verification("emisor_distinto", ip_hash(request))
            return page("Correo inválido", verdict(False, "El correo que indicó no es el del emisor de este sello. "
                                                   "Trátelo como phishing."), user, request, active="checkin")
        if need_de and not (seal["recipient_hmac"] and hmac.compare_digest(
                recipient_hmac(_secret("SELLACORREO_HMAC_KEY"), seal["emisor"], correo.strip().lower()), seal["recipient_hmac"])):
            store.record_verification("destinatario_distinto", ip_hash(request))
            return page("Correo inválido", verdict(False, "El sello existe, pero no fue emitido para la dirección que ingresó. "
                                                   "Si usted lo recibió, alguien copió la imagen: trátelo como phishing."),
                        user, request, active="checkin")
        store.record_verification("valido_confirmado", ip_hash(request))
        confirmado = []
        if need_em: confirmado.append("el emisor")
        if need_de: confirmado.append("el destinatario")
        return page("Correo válido", verdict(True, "Confirmado: " + " y ".join(confirmado) + ". El sello coincide.")
                    + safe_word_box(seal) + seal_details(seal), user, request, active="checkin")
    if seal["recipient_hmac"] and hmac.compare_digest(
            recipient_hmac(_secret("SELLACORREO_HMAC_KEY"), seal["emisor"], correo), seal["recipient_hmac"]):
        store.record_verification("valido_destinatario", ip_hash(request))
        return page("Correo válido", verdict(True, "El sello coincide y el correo fue enviado a usted.")
                    + safe_word_box(seal) + seal_details(seal), user, request, active="checkin")
    store.record_verification("destinatario_distinto", ip_hash(request))
    return page("Correo inválido", verdict(False, "El sello existe, pero no fue emitido para la dirección que ingresó. "
                                           "Si usted lo recibió, alguien copió la imagen: trátelo como phishing."),
                user, request, active="checkin")


@app.get("/img/{token}.png")
def image(token: str):
    seal = store.get_seal(token) if re.fullmatch(r"[A-Za-z0-9_-]{20,64}", token) else None
    if seal is None:
        return Response(invalid_png(), media_type="image/png", status_code=404)
    return Response(banner_png(fmt_code(seal["codigo"]), seal["taxonomia"]), media_type="image/png",
                    headers={"Cache-Control": "public, max-age=86400"})
