"""SellaCorreo · sitio web anti-phishing (un solo servicio, puerto 8090).

Páginas:
  /login     inicio de sesión para usuarios del IESS (usuarios demo de .env)
  /genkey    (con sesión) elegir taxonomía y generar enlace dinámico + imagen de encabezado
  /checkin   (pública) clic en la imagen del correo -> pide el emisor; «Correo válido y seguro» / «Correo falso»

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
from functools import lru_cache
from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import quote

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse, Response
from fastapi.staticfiles import StaticFiles

from autenticidad import canonical_content, composite_hash, normalize_email, recipient_hmac, seal_payload, sha256_hex
from autenticidad.banner import invalid_png
from autenticidad.sello import wax_seal_png

from . import firma, observatorio, store

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
    observatorio.iniciar()
    if not getattr(_app.state, "observatorio_montado", False):
        obs_router = observatorio.router(
            puede_ver_panel=lambda request: current_user(request) is not None,
            permitir=lambda request: observatorio_limiter.allow(ip_hash(request)))
        if obs_router is not None:
            _app.include_router(obs_router, prefix="/api/v1/observatorio")
            _app.state.observatorio_montado = True
    yield


app = FastAPI(title="SellaCorreo", version="2.0.0", lifespan=lifespan,
              description="Sello anti-phishing para correos institucionales: GenKey y CheckIn.")
app.mount("/static", StaticFiles(directory=STATIC), name="static")


OBS_API = "/api/v1/observatorio/"
# Orígenes con permiso para llamar a la API desde el navegador (la app Flutter
# web). Vacío o sin definir: solo localhost. Una expresión vacía no se acepta,
# porque coincidiría con cualquier origen.
OBS_ORIGENES = re.compile(os.environ.get("SELLACORREO_OBSERVATORIO_ORIGENES", "").strip()
                          or r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$")


@app.middleware("http")
async def observatorio_cors(request: Request, call_next):
    """CORS solo para la API del Observatorio: la app Flutter web corre en otro
    origen. Sin cookies (allow-credentials no se envía), así que la sesión del
    personal nunca viaja en estas llamadas."""
    origen = request.headers.get("origin", "")
    aplica = request.url.path.startswith(OBS_API) and OBS_ORIGENES.match(origen)
    if aplica and request.method == "OPTIONS":
        resp = Response(status_code=204)
    else:
        resp = await call_next(request)
    if aplica:
        resp.headers["Access-Control-Allow-Origin"] = origen
        resp.headers["Access-Control-Allow-Methods"] = "GET, POST, DELETE, OPTIONS"
        resp.headers["Access-Control-Allow-Headers"] = "Content-Type"
        resp.headers["Vary"] = "Origin"
    return resp


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
observatorio_limiter = RateLimiter(int(os.environ.get("SELLACORREO_OBSERVATORIO_LIMIT_PER_MIN", "120")))


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
    """Sin encabezado en ninguna página: Inicio, Sello, Validador e Ingresar/Salir van siempre en el pie."""
    if user:
        sesion = (f'<form method="post" action="/logout" class="sc-logout"><input type="hidden" name="csrf" '
                  f'value="{csrf_token(request)}"><button class="tl-btn tl-btn--ghost tl-btn--sm" type="submit">Salir</button></form>')
    else:
        sesion = '<a href="/login">Ingresar</a>'
    def foot(href, label, key):
        cur = ' aria-current="page"' if key == active else ""
        return f'<a href="{href}"{cur}>{label}</a>'
    links = (f'<nav class="sc-foot-links" aria-label="Secciones">' + foot("/", "Inicio", "inicio")
             + foot("/genkey", "Sello", "genkey") + foot("/checkin", "Validador", "checkin")
             + foot("/observatorio", "Observatorio", "observatorio")
             + foot("/reportar-incidente", "Reportar Incidente", "incidente") + sesion + "</nav>")
    head = ""
    return HTMLResponse(status_code=status, content=f"""<!doctype html><html lang="es"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>{E(title)} · SellaCorreo</title>
<link rel="icon" href="/static/marca.svg" type="image/svg+xml">
<link rel="stylesheet" href="/static/tokens.css"><link rel="stylesheet" href="/static/components.css">
<link rel="stylesheet" href="/static/sella.css"></head><body class="tl-body">
{head}
<main class="tl-main sc-main">{body}</main>
<footer class="sc-footer"><div class="sc-footer__inner sc-footer__inner--fila">
<div class="sc-footer__brand"><img class="sc-footer__logo" src="/static/img/iess-logo.png" alt="Instituto Ecuatoriano de Seguridad Social" width="163" height="70">
<span class="sc-footer__sep" aria-hidden="true"></span>
<div class="sc-footer__name"><strong>AI-IESS · SellaCorreo</strong><span>Sello anti-phishing para correo institucional</span>
<p class="sc-footer__copy">© Instituto Ecuatoriano de Seguridad Social - Todos los derechos reservados.</p></div></div>
<div class="sc-footer__nav">{links}<div class="sc-tricolor" aria-hidden="true"><i></i><i></i><i></i></div></div>
</div></footer>
<script src="/static/app.js"></script></body></html>""")


def verdict(ok: bool, text: str, title: str | None = None) -> str:
    cls, icon, default = ("ok", "✓", "Correo válido y seguro") if ok else ("bad", "✕", "Correo falso")
    title = title or default
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


# Posible phishing: todo resultado que no sea válido; los estados «pendiente_*» (de versiones anteriores) no cuentan.
SOSPECHOSO = "estado NOT LIKE 'valido%' AND estado NOT LIKE 'pendiente%'"


def home_stats() -> dict:
    with store.connect() as conn:
        sellos = conn.execute("SELECT COUNT(*) FROM sellos").fetchone()[0]
        checks = conn.execute("SELECT COUNT(*) FROM verificaciones").fetchone()[0]
        bloqueados = conn.execute(f"SELECT COUNT(*) FROM verificaciones WHERE {SOSPECHOSO}").fetchone()[0]
    return {"sellos": sellos, "checks": checks, "bloqueados": bloqueados}


ICON_SHIELD = ('<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l7 3v6c0 4.5-3 7.8-7 9-4-1.2-7-4.5-7-9V6z"/></svg>')
ICON_DOC = ('<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="3" width="14" height="18" rx="2"/>'
            '<path d="M9 8h6M9 12h6M9 16h3"/></svg>')
ICON_RADAR = ('<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/>'
              '<path d="M12 12l6-6"/><circle cx="12" cy="12" r="1" fill="currentColor"/></svg>')
ICON_ARROW = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h13M13 6l6 6-6 6"/></svg>'
ICON_CHART = ('<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>'
              '<path d="M4 8l6-4 6 7 5-4"/></svg>')


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
  <p class="sc-home__sub">ANTI-PHISHING</p>
  <div class="sc-home__stage" id="sc-home-stage">
    <div class="sc-dial">{dial_svg()}
      <img class="sc-dial__img sc-dial__img--base sc-dial__img--escudo" src="/static/img/escudo-correo.png" alt="Escudo azul con un sobre de correo" width="410" height="410">
      <img class="sc-dial__img sc-dial__img--sello" src="/static/img/sello.jpg" alt="Sobre digital protegido por un escudo" width="410" height="410" aria-hidden="true">
      <img class="sc-dial__img sc-dial__img--escudo sc-dial__img--observatorio" src="/static/img/observatorio.svg" alt="" width="410" height="410" aria-hidden="true">
    </div>
    {home_card("sello", "/genkey", "Sellar Correo", "Crea tu sello de seguridad y evita el phishing", ICON_DOC)}
    {home_card("validador", "/checkin", "Validador", "Valida el hash y evita la suplantación de identidad", ICON_SHIELD,
                "Haga clic en el encabezado de su correo o pegue su enlace en este Validador.")}
    {home_card("observatorio", "/observatorio", "Observatorio", "Aprende del comportamiento y personaliza la capacitación", ICON_CHART,
                "Qué indicios engañan a cada grupo y qué debe practicar cada persona.")}
    {home_card("radar", "/radar", "Radar Phishing", "Monitorea en vivo los intentos de phishing detectados", ICON_RADAR)}
  </div>
</section>
<section class="tl-grid-stats sc-home__stats" aria-label="Resumen">
  <div class="tl-card tl-stat"><div class="tl-stat__label">Sellos emitidos</div><div class="tl-stat__value">{st["sellos"]}</div><div class="tl-hint">Firmados con Ed25519</div></div>
  <div class="tl-card tl-stat"><div class="tl-stat__label">Verificaciones</div><div class="tl-stat__value">{st["checks"]}</div><div class="tl-hint">Consultas en el Validador</div></div>
  <div class="tl-card tl-stat"><div class="tl-stat__label">Posibles phishing detectados</div><div class="tl-stat__value">{st["bloqueados"]}</div><div class="tl-hint">Enlaces inválidos, alterados o caducados</div></div>
</section>
"""
    return page("Inicio", body, user, request, active="inicio", chrome="home")


# ------------------------------------------------------------------ Radar Phishing
ECUADOR = timezone(timedelta(hours=-5))


def hora_ecuador(ts_utc: str) -> str:
    try:
        dt = datetime.strptime(ts_utc, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    except ValueError:
        return ts_utc
    return dt.astimezone(ECUADOR).strftime("%Y-%m-%d %H:%M")


def radar_data(dias: int = 14, limite: int = 20) -> dict:
    """Solo lo que ya guarda la tabla verificaciones (hora y estado); nunca correos ni IP."""
    desde = (datetime.now(timezone.utc) - timedelta(days=dias - 1)).strftime("%Y-%m-%dT00:00:00Z")
    with store.connect() as conn:
        total = conn.execute("SELECT COUNT(*) FROM verificaciones").fetchone()[0]
        validas = conn.execute("SELECT COUNT(*) FROM verificaciones WHERE estado LIKE 'valido%'").fetchone()[0]
        sospechosas = conn.execute(f"SELECT COUNT(*) FROM verificaciones WHERE {SOSPECHOSO}").fetchone()[0]
        motivos = conn.execute(f"SELECT estado, COUNT(*) n, MAX(ts_utc) ultimo FROM verificaciones WHERE {SOSPECHOSO} "
                               "GROUP BY estado ORDER BY n DESC").fetchall()
        ultimos = conn.execute(f"SELECT ts_utc, estado FROM verificaciones WHERE {SOSPECHOSO} "
                               "ORDER BY ts_utc DESC, vid DESC LIMIT ?", (limite,)).fetchall()
        filas = conn.execute(f"SELECT ts_utc, estado FROM verificaciones WHERE ts_utc >= ?", (desde,)).fetchall()
    hoy = datetime.now(ECUADOR).date()
    serie = {(hoy - timedelta(days=i)).isoformat(): [0, 0] for i in range(dias - 1, -1, -1)}
    for r in filas:
        dia = hora_ecuador(r["ts_utc"])[:10]
        if dia not in serie or r["estado"].startswith("pendiente"):
            continue
        serie[dia][0 if r["estado"].startswith("valido") else 1] += 1
    return {"total": total, "validas": validas, "sospechosas": sospechosas,
            "motivos": [dict(r) for r in motivos], "ultimos": [dict(r) for r in ultimos], "serie": serie}


@app.get("/radar", response_class=HTMLResponse)
def radar(request: Request):
    d = radar_data()
    tasa = f"{round(100 * d['sospechosas'] / d['total'])} %" if d["total"] else "—"
    tope = max([v[0] + v[1] for v in d["serie"].values()] + [1])
    barras = "".join(
        f'<div class="sc-radar__day" title="{dia}: {v[0]} válidas, {v[1]} sospechosas">'
        f'<svg class="sc-radar__bar" viewBox="0 0 10 100" preserveAspectRatio="none" aria-hidden="true">'
        f'<rect class="sc-radar__ok" x="0" y="{100 - 100 * v[0] / tope:.1f}" width="10" height="{100 * v[0] / tope:.1f}"/>'
        f'<rect class="sc-radar__mal" x="0" y="{100 - 100 * (v[0] + v[1]) / tope:.1f}" width="10" height="{100 * v[1] / tope:.1f}"/></svg>'
        f'<span class="sc-radar__lbl">{dia[8:10]}/{dia[5:7]}</span></div>' for dia, v in d["serie"].items())
    if d["motivos"]:
        mot = "".join(f'<tr><td>{E(MOTIVOS.get(r["estado"], r["estado"]))}</td><td class="sc-num">{r["n"]}</td>'
                      f'<td>{E(hora_ecuador(r["ultimo"]))}</td></tr>' for r in d["motivos"])
        mot = f'<table class="sc-table"><tr><th>Motivo</th><th class="sc-num">Intentos</th><th>Último (Ecuador)</th></tr>{mot}</table>'
    else:
        mot = '<p class="tl-hint">Aún no se han detectado intentos sospechosos.</p>'
    if d["ultimos"]:
        ult = "".join(f'<tr><td>{E(hora_ecuador(r["ts_utc"]))}</td><td><span class="sc-radar__tag">{E(r["estado"].replace("_", " "))}</span></td>'
                      f'<td>{E(MOTIVOS.get(r["estado"], r["estado"]))}</td></tr>' for r in d["ultimos"])
        ult = f'<table class="sc-table sc-radar__ult"><tr><th>Hora (Ecuador)</th><th>Estado</th><th>Motivo</th></tr>{ult}</table>'
    else:
        ult = '<p class="tl-hint">Sin intentos registrados.</p>'
    body = f"""<header class="tl-page-head"><h1 class="tl-h1">Radar Phishing</h1>
<p class="tl-page-desc">Monitoreo de las consultas al Validador: cuántos enlaces resultaron auténticos y cuántos fueron
inválidos, alterados o caducados. Solo se registran la hora y el resultado; nunca correos ni direcciones IP.</p></header>
<section class="sc-home__stats sc-radar__kpis" aria-label="Resumen del radar">
  <div class="tl-card tl-stat"><div class="tl-stat__label">Verificaciones</div><div class="tl-stat__value">{d["total"]}</div><div class="tl-hint">Consultas en el Validador</div></div>
  <div class="tl-card tl-stat"><div class="tl-stat__label">Correos auténticos</div><div class="tl-stat__value">{d["validas"]}</div><div class="tl-hint">Sello válido y seguro</div></div>
  <div class="tl-card tl-stat"><div class="tl-stat__label">Posibles phishing</div><div class="tl-stat__value">{d["sospechosas"]}</div><div class="tl-hint">{tasa} de las verificaciones</div></div>
</section>
<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Actividad de los últimos 14 días</h2>
<div class="sc-radar__legend"><span><i class="sc-radar__sw sc-radar__sw--ok"></i>Auténticos</span><span><i class="sc-radar__sw sc-radar__sw--mal"></i>Posibles phishing</span></div>
<div class="sc-radar__chart" role="img" aria-label="Verificaciones por día">{barras}</div></div></section>
<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Intentos por motivo</h2>{mot}</div></section>
<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Últimos intentos sospechosos</h2>{ult}</div></section>"""
    return page("Radar Phishing", body, current_user(request), request, active="radar")


@app.get("/reportar-incidente", response_class=HTMLResponse)
def report_incident(request: Request):
    return page("Reportar incidente", """<header class="tl-page-head"><h1 class="tl-h1">Reportar incidente</h1>
<p class="tl-page-desc">¿Recibió un correo que dice ser del IESS y le parece sospechoso?</p></header>
<section class="tl-card"><div class="tl-card__body"><ol class="sc-steps">
<li><strong>No haga clic</strong> en enlaces ni abra adjuntos, y no entregue contraseñas ni datos bancarios.</li>
<li><strong>Verifíquelo en el <a href="/checkin">Validador</a>:</strong> haga clic en la imagen del sello del encabezado o pegue su enlace.</li>
<li>Si el Validador muestra <strong>«Correo falso»</strong>, o el correo no trae el sello, repórtelo a la mesa de ayuda de su
institución y reenvíelo como adjunto.</li></ol></div></section>""", current_user(request), request, active="incidente")


@app.get("/.well-known/sellacorreo-key")
def public_key():
    return firma.public()


# ------------------------------------------------------------------ login
# Páginas a las que el login puede volver. Lista cerrada: nunca una URL arbitraria.
DESTINOS_LOGIN = {"/genkey", "/observatorio"}


def _destino(siguiente: str) -> str:
    return siguiente if siguiente in DESTINOS_LOGIN else "/genkey"


def _campo_siguiente(siguiente: str) -> str:
    return f'<input type="hidden" name="siguiente" value="{E(siguiente)}">' if siguiente in DESTINOS_LOGIN else ""


def demo_card(siguiente: str = "") -> str:
    if not store.demo_mode():
        return ""
    users = store.demo_users()
    if not users:
        return ""
    rows = "".join(f"""<form method="post" action="/login" class="sc-quick__form">{_campo_siguiente(siguiente)}
<input type="hidden" name="usuario" value="{E(u['emisor'])}"><input type="hidden" name="clave" value="{E(store.demo_password())}">
<button type="submit" class="sc-quick__row" data-demo="{E(u['usuario'])}"><span class="sc-quick__text">
<span class="sc-quick__title">{E(u['nombre'])}</span><span class="sc-quick__sub">{E(u['unidad'])} · {E(u['emisor'])}</span></span>
<span class="sc-quick__arrow" aria-hidden="true">→</span></button></form>""" for u in users)
    return f"""<section class="tl-card sc-quick" aria-labelledby="demo-title"><div class="tl-card__body">
<h2 class="sc-card-title" id="demo-title">Acceso rápido de demostración</h2>
<p class="tl-page-desc">Todas las cuentas de prueba usan la contraseña <code class="sc-pass">{E(store.demo_password())}</code>.</p>
<div class="sc-quick__list">{rows}</div></div></section>"""


def login_page(error: str = "", usuario: str = "", status: int = 200, siguiente: str = "") -> HTMLResponse:
    alert = f'<div class="tl-alert tl-alert--destructive" role="alert"><div class="tl-alert__body">{E(error)}</div></div>' if error else ""
    demo = demo_card(siguiente)
    return page("Ingresar", f"""<section class="sc-login{' sc-login--demo' if demo else ''}">
<section class="tl-card"><div class="tl-card__body">
<h1 class="sc-card-title sc-card-title--lg">Ingresar</h1>
<p class="tl-page-desc">Acceso para el personal del IESS que genera sellos. Los destinatarios verifican sin cuenta en <a href="/checkin">CheckIn</a>.</p>
{alert}
<form class="sc-form" method="post" action="/login" autocomplete="on">{_campo_siguiente(siguiente)}
<div class="tl-field"><label class="tl-field__label" for="usuario">Correo electrónico</label>
<input class="tl-input" id="usuario" name="usuario" required autocomplete="username" placeholder="usuario@demo.institucion.test" value="{E(usuario)}"></div>
<div class="tl-field"><label class="tl-field__label" for="clave">Contraseña</label>
<input class="tl-input" id="clave" name="clave" type="password" required autocomplete="current-password"></div>
<button class="tl-btn tl-btn--default sc-btn-block" type="submit">Ingresar</button>
</form></div></section>{demo}</section>""", status=status)


@app.get("/login", response_class=HTMLResponse)
def login_form(request: Request, siguiente: str = ""):
    if current_user(request):
        return RedirectResponse(_destino(siguiente), status_code=303)
    return login_page(siguiente=siguiente)


@app.post("/login")
def login(request: Request, usuario: str = Form(...), clave: str = Form(...), siguiente: str = Form("")):
    if not login_limiter.allow(ip_of(request)):
        return login_page("Demasiados intentos. Espere un minuto.", usuario, 429, siguiente)
    user = store.authenticate(usuario, clave)
    if user is None:
        return login_page("Usuario o contraseña incorrectos.", usuario, 401, siguiente)
    resp = RedirectResponse(_destino(siguiente), status_code=303)
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


def sender_hmac(emisor: str) -> str:
    """Huella del correo del emisor (HMAC con clave). El correo nunca se guarda en claro."""
    return hmac.new(_secret("SELLACORREO_HMAC_KEY"), b"emisor|" + normalize_email(emisor).encode("utf-8"),
                    hashlib.sha256).hexdigest()


def policy_line(expira: str | None, tag: str | None, exige: bool, emisor_fp: str, exige_asunto: bool = True) -> str:
    """Las políticas y la huella del emisor forman parte del contenido sellado: alterarlas cambia el hash H.
    «asunto=omitido» solo aparece cuando el asunto no se incluye en el hash."""
    base = (f"politicas: caduca={expira or '-'}; palabra={tag or '-'}; "
            f"destinatario={'obligatorio' if exige else 'opcional'}; emisor={emisor_fp}")
    return base if exige_asunto else base + "; asunto=omitido"


def seal_content(asunto: str, expira: str | None, tag: str | None, exige: bool, emisor_fp: str,
                 exige_asunto: bool = True) -> bytes:
    return canonical_content(asunto if exige_asunto else "", policy_line(expira, tag, exige, emisor_fp, exige_asunto))


def hash_options(seal: dict) -> list[str]:
    """Opciones de «Hash de seguridad» integradas en el enlace del sello: una por asterisco.
    «Correo del emisor» siempre va; las demás según lo guardado en el sello."""
    ops = ["Correo del emisor"]
    if seal.get("exige_asunto", 1):
        ops.append("Asunto del correo")
    if seal.get("palabra_tag"):
        ops.append("Palabra segura")
    if seal.get("expira_utc"):
        ops.append("Caducidad del enlace")
    return ops


@lru_cache(maxsize=256)
def _sello_png(codigo: str, taxonomia: str, asteriscos: int) -> bytes:
    return wax_seal_png(codigo, taxonomia, asteriscos)


# ------------------------------------------------------------------ GenKey
def initials(name: str) -> str:
    parts = [p for p in re.split(r"\s+", name) if p and p[0].isalpha() and p.lower() not in {"de", "del", "la", "y"}]
    return "".join(p[0].upper() for p in parts[:2]) or "SC"


def genkey_form(request: Request, user: dict, error: str = "", values: dict | None = None) -> str:
    v = {"taxonomia": "comunicacional", "asunto": "", "destinatario": "", "pol_palabra": "", "palabra": "",
         "pol_caducidad": "", "caducidad": "7", "pol_asunto": "1", **(values or {})}
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
             + pol("pol_asunto", "Asunto del correo", "Incluye el asunto en el hash; CheckIn lo muestra para que compare con el correo recibido")
             + ('<label class="sc-node sc-node--right sc-node--locked" data-node title="Siempre activa: el correo del emisor '
                'forma parte del hash y CheckIn lo pide antes de cualquier resultado"><input type="checkbox" checked disabled '
                'data-policy="pol_emisor"><span class="sc-node__dot sc-node__dot--pol"></span>Correo del emisor</label>'))
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
<div class="tl-field sc-policy" data-for="pol_asunto"><label class="tl-field__label" for="asunto">Asunto del correo</label>
<input class="tl-input" id="asunto" name="asunto" maxlength="300" value="{E(v['asunto'])}">
<span class="tl-hint">Forma parte del hash del sello y CheckIn lo muestra para que el destinatario compare.</span></div>
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
        f'<tr><td>{E(r["ts_utc"])}</td><td>{E(r["taxonomia"])}</td><td>{E(r["asunto"]) or "<em>sin asunto</em>"}</td>'
        f'<td><a href="/checkin/{E(r["token"])}.{E(r["h"][:16])}">{E(fmt_code(r["codigo"]))}</a></td></tr>' for r in rows)
    return (f'<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Mis últimos sellos</h2>'
            f'<table class="sc-table"><tr><th>Fecha (UTC)</th><th>Taxonomía</th><th>Asunto</th><th>Código</th></tr>{trs}</table>'
            f'</div></section>')


@app.get("/observatorio", response_class=HTMLResponse)
def observatorio_get(request: Request, persona: str = ""):
    """Panel del Observatorio: agregados con k = 10 y el plan de una persona por
    su código. Es interno: pide sesión, como el Sello."""
    user = current_user(request)
    if not user:
        return RedirectResponse("/login?siguiente=/observatorio", status_code=303)
    return page("Observatorio", observatorio.panel(csrf_token(request), persona[:64]), user, request,
                active="observatorio", chrome="observatorio")


@app.post("/observatorio/borrar-sinteticos")
def observatorio_borrar_sinteticos(request: Request, csrf: str = Form("")):
    if not current_user(request):
        return RedirectResponse("/login?siguiente=/observatorio", status_code=303)
    if not csrf_ok(request, csrf):
        return JSONResponse({"error": "CSRF"}, status_code=403)
    observatorio.borrar_sinteticos()
    return RedirectResponse("/observatorio", status_code=303)


@app.get("/genkey", response_class=HTMLResponse)
def genkey_get(request: Request):
    user = current_user(request)
    if not user:
        return RedirectResponse("/login", status_code=303)
    return page("GenKey", genkey_form(request, user), user, request, active="genkey", chrome="genkey")


def create_seal(user: dict, taxonomia: str, asunto: str, destinatario: str, palabra: str | None = None,
                dias: int | None = None, exige_destinatario: bool = False, exige_asunto: bool = True) -> dict:
    asunto = asunto.strip()[:300] if exige_asunto else ""  # sin asunto, ni el texto ni el hash lo llevan
    now = datetime.now(timezone.utc).replace(microsecond=0)
    ts = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    expira = (now + timedelta(days=dias)).strftime("%Y-%m-%dT%H:%M:%SZ") if dias else None
    msg_id = str(uuid.uuid4())
    token = secrets.token_urlsafe(18)
    tag = word_tag(palabra) if palabra else None
    emisor_fp = sender_hmac(user["emisor"])
    content = seal_content(asunto, expira, tag, exige_destinatario, emisor_fp, exige_asunto)
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
        "exige_emisor": 1, "exige_asunto": 1 if exige_asunto else 0, "emisor_hmac": emisor_fp})
    store.append_log(usuario=user["usuario"], taxonomia=taxonomia, token_hash=store.sha(token), h=h, seal_sig=sig)
    base = public_base()
    opciones = hash_options({"exige_asunto": exige_asunto, "palabra_tag": tag, "expira_utc": expira})
    return {"token": token, "codigo": fmt_code(codigo), "h": h, "expira": expira, "opciones": opciones,
            "enlace": f"{base}/checkin/{token}.{h[:16]}", "imagen": f"{base}/img/{token}.png"}


@app.post("/genkey", response_class=HTMLResponse)
def genkey_post(request: Request, csrf: str = Form(""), taxonomia: str = Form(...), asunto: str = Form(...),
                destinatario: str = Form(""), pol_palabra: str = Form(""), palabra: str = Form(""),
                pol_caducidad: str = Form(""), caducidad: str = Form(""), pol_asunto: str = Form("")):
    user = current_user(request)
    if not user:
        return RedirectResponse("/login", status_code=303)
    values = {"taxonomia": taxonomia, "asunto": asunto, "destinatario": destinatario, "pol_palabra": pol_palabra,
              "palabra": palabra, "pol_caducidad": pol_caducidad, "caducidad": caducidad, "pol_asunto": pol_asunto}
    if not csrf_ok(request, csrf):
        return page("GenKey", genkey_form(request, user, "La sesión del formulario expiró. Intente de nuevo.", values),
                    user, request, 403, "genkey", chrome="genkey")
    destinatario = destinatario.strip().lower()
    palabra = palabra.strip()
    err = ""
    if taxonomia not in {t["codigo"] for t in store.taxonomias()}:
        err = "Taxonomía no válida."
    elif pol_asunto and not asunto.strip():
        err = "Escriba el asunto o desmarque «Asunto del correo»."
    elif pol_palabra and not (3 <= len(palabra) <= 40):
        err = "La palabra segura debe tener entre 3 y 40 caracteres."
    elif pol_caducidad and caducidad not in CADUCIDADES:
        err = "Caducidad no válida."
    if err:
        return page("GenKey", genkey_form(request, user, err, values), user, request, 422, "genkey", chrome="genkey")
    s = create_seal(user, taxonomia, asunto, "", palabra if pol_palabra else None,
                    int(caducidad) if pol_caducidad else None, False, bool(pol_asunto))
    politicas = [p for p, on in [("correo del emisor (siempre, en el hash)", True), ("asunto en el hash", pol_asunto),
                                 ("palabra segura", pol_palabra),
                                 (f"caduca {s['expira']}" if s["expira"] else "", pol_caducidad)] if on and p]
    snippet = (f'<a href="{s["enlace"]}"><img src="{s["imagen"]}" width="240" height="240" '
               f'alt="ANTI-PHISHING" style="display:block;border:0"></a>')
    body = f"""<div class="tl-alert tl-alert--ok" role="status"><div class="tl-alert__title">Sello generado · código {E(s['codigo'])}</div>
<div class="tl-alert__body">Pegue la imagen al inicio del correo «{E(asunto)}» ({E(taxonomia)}).
Políticas: {E(", ".join(politicas) or "ninguna")}. El sello lleva {len(s["opciones"])} {"asterisco" if len(s["opciones"]) == 1 else "asteriscos"}.</div></div>
<section class="tl-card"><div class="tl-card__body sc-form">
<div class="tl-field"><span class="tl-field__label">1 · Imagen con enlace (cópiela y péguela en Outlook o Gmail)</span>
<div id="sello-preview" class="sc-preview"><a href="{E(s['enlace'])}"><img class="sc-banner sc-seal" src="{E(s['imagen'])}" width="240" height="240" alt="ANTI-PHISHING"></a></div>
<p class="sc-stars-legend" data-asteriscos="{len(s['opciones'])}"><span class="sc-stars" aria-hidden="true">{'*' * len(s['opciones'])}</span>
{len(s['opciones'])} {'asterisco' if len(s['opciones']) == 1 else 'asteriscos'}: uno por cada opción de «Hash de seguridad» integrada en el enlace ({E(", ".join(s['opciones']))}).</p>
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
    "sello_anterior": "Este sello es anterior a la verificación de emisor: no incluye el correo del emisor en su hash.",
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
    if not seal.get("emisor_hmac"):  # sello anterior a la verificación de emisor
        return False, "sello_anterior", seal
    # Recalcular H con los datos guardados (asunto + políticas + emisor): detecta registros manipulados
    content = seal_content(seal["asunto"], seal.get("expira_utc"), seal.get("palabra_tag"),
                           bool(seal.get("exige_destinatario")), seal["emisor_hmac"], bool(seal.get("exige_asunto", 1)))
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
    con_asunto = bool(seal.get("exige_asunto", 1))
    rows = ([("Asunto", seal["asunto"])] if con_asunto else []) + [
        ("Taxonomía", seal["taxonomia"]), ("Emisor", seal["nombre_emisor"]),
        ("Unidad", seal["unidad"]), ("Buzón", seal["emisor"]), ("Institución", seal["institucion"]),
        ("Fecha (UTC)", seal["ts_utc"]), ("Código", fmt_code(seal["codigo"]))]
    ops = hash_options(seal)
    rows.append(("Hash de seguridad", "*" * len(ops) + " · " + ", ".join(o.lower() for o in ops)))
    if seal.get("expira_utc"):
        rows.append(("Válido hasta (UTC)", seal["expira_utc"]))
    dl = "".join(f"<dt>{E(k)}</dt><dd>{E(v)}</dd>" for k, v in rows)
    intro = "el asunto y el remitente deben coincidir." if con_asunto else "el remitente debe coincidir."
    return (f'<section class="tl-card"><div class="tl-card__body"><p class="tl-text">Compare con el correo que recibió: '
            f'{intro}</p><dl class="sc-kv">{dl}</dl></div></section>')


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
<input class="tl-input sc-code" id="enlace" name="enlace" required placeholder=\"""" + html.escape(public_base()) + """/checkin/..."></div>
<div class="tl-row"><button class="tl-btn tl-btn--default" type="submit">Verificar</button></div></form>
<p class="tl-hint">Si el correo no trae imagen SellaCorreo, desconfíe: los correos institucionales sellados siempre la llevan.</p>
</div></section>""", current_user(request), request, active="checkin")


def _falso(motivo: str, user, request):
    return page("Correo falso", verdict(False, MOTIVOS[motivo] + " Podría ser phishing: no haga clic en sus enlaces "
                                        "ni entregue datos."), user, request, active="checkin")


def _limitado(user, request):
    return page("CheckIn", verdict(False, "Demasiadas consultas. Intente en un minuto.", "Demasiadas consultas"),
                user, request, 429, "checkin")


def _valido(seal: dict, user, request):
    store.record_verification("valido", ip_hash(request))
    texto = (f"Emitido por {seal['nombre_emisor']} ({seal['institucion']}). El hash, la firma digital y el correo "
             "del emisor, sellado dentro del hash, coinciden.")
    return page("Correo válido y seguro", verdict(True, texto) + safe_word_box(seal) + seal_details(seal),
                user, request, active="checkin")


@app.get("/checkin/{link}", response_class=HTMLResponse)
def checkin(link: str, request: Request):
    """El emisor se verifica solo (huella dentro del hash y firma): resultado directo, sin preguntas."""
    user = current_user(request)
    if not checkin_limiter.allow(ip_of(request)):
        return _limitado(user, request)
    ok, motivo, seal = check_link(link)
    if not ok:
        store.record_verification(motivo, ip_hash(request))
        return _falso(motivo, user, request)
    return _valido(seal, user, request)


@app.get("/api/v1/verificar/{link:path}")
def api_verificar(link: str, request: Request):
    """Verificación para apps (robot AIESS): la MISMA comprobación que CheckIn (hash, firma Ed25519, emisor,
    caducidad), en JSON. Acepta el enlace completo o solo «token.huella». Nunca devuelve la palabra segura
    (esa solo se muestra en la página de CheckIn, a la persona)."""
    cors = {"Access-Control-Allow-Origin": "*", "Cache-Control": "no-store"}
    if not checkin_limiter.allow(ip_of(request)):
        return JSONResponse({"valido": False, "motivo": "limite", "mensaje": "Demasiadas consultas. Intente en un minuto."},
                            status_code=429, headers=cors)
    ok, motivo, seal = check_link(_extract_link(link))
    store.record_verification(motivo, ip_hash(request))
    if not ok:
        return JSONResponse({"valido": False, "motivo": motivo,
                             "mensaje": MOTIVOS[motivo] + " Podría ser phishing: no haga clic en sus enlaces ni entregue datos."},
                            headers=cors)
    datos = {"valido": True, "motivo": "valido",
             "mensaje": f"Emitido por {seal['nombre_emisor']} ({seal['institucion']}). El hash, la firma digital "
                        "y el correo del emisor coinciden.",
             "emisor": seal["nombre_emisor"], "unidad": seal["unidad"], "buzon": seal["emisor"],
             "institucion": seal["institucion"], "taxonomia": seal["taxonomia"], "fecha_utc": seal["ts_utc"],
             "codigo": fmt_code(seal["codigo"]), "expira_utc": seal.get("expira_utc")}
    if seal.get("exige_asunto", 1):
        datos["asunto"] = seal["asunto"]
    return JSONResponse(datos, headers=cors)


@app.get("/img/{token}.png")
def image(token: str):
    seal = store.get_seal(token) if re.fullmatch(r"[A-Za-z0-9_-]{20,64}", token) else None
    if seal is None:
        return Response(invalid_png(), media_type="image/png", status_code=404)
    return Response(_sello_png(fmt_code(seal["codigo"]), seal["taxonomia"], len(hash_options(seal))), media_type="image/png",
                    headers={"Cache-Control": "public, max-age=86400"})
