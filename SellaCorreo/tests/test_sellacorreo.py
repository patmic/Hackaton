"""SellaCorreo · Login, GenKey y CheckIn (10 casos).

| #  | Caso | Esperado |
|----|------|----------|
| 01 | Login con usuario demo; clave mala; GenKey sin sesión | 303 a GenKey; 401; redirección a /login |
| 02 | Contraseñas solo como hash scrypt; sesión firmada y manipulación | sin clave en claro; cookie alterada = sin sesión |
| 03 | GenKey muestra taxonomías configurables | comunicacional, informativo, recordatorio + extras de .env |
| 04 | GenKey genera enlace dinámico, imagen y HTML | /checkin/<token>.<h16>, PNG, snippet con imagen enlazada |
| 05 | Hash compuesto y firma Ed25519 | H recalculable; firma válida con la clave pública |
| 06 | CheckIn de un enlace auténtico | «Correo válido» con asunto, taxonomía y emisor |
| 07 | CheckIn de enlaces alterados o inventados | «Correo inválido» en todos los casos |
| 08 | Confirmación de destinatario (imagen copiada) | válido para el destinatario; inválido para otro |
| 09 | CSRF, validaciones y límite por IP | 403 sin token; 422 taxonomía inválida; 429 al exceder |
| 10 | Log encadenado firmado y privacidad | cadena íntegra; alterarla se detecta; sin destinatario en claro |
"""
import re
import sqlite3

from fastapi.testclient import TestClient

from autenticidad import canonical_content, composite_hash, recipient_hmac, seal_payload, sha256_hex, verify_ed25519
from conftest import PASS, TEST_ENV, USER
from sellacorreo import main as m

BASE = "http://localhost:8090"


def _csrf(client, path="/genkey"):
    return re.search(r'name="csrf" value="([0-9a-f]+)"', client.get(path).text).group(1)


def _genkey(client, **kw):
    data = {"taxonomia": "comunicacional", "asunto": "Comunicado: nuevo horario de atención",
            "destinatario": "", **kw}
    data["csrf"] = kw.get("csrf", _csrf(client))
    return client.post("/genkey", data=data)


def _link(page_html):
    return re.search(r'id="enlace" readonly value="(http://localhost:8090/checkin/[^"]+)"', page_html).group(1)


def test_caso_01_login(anon):
    assert anon.get("/genkey", follow_redirects=False).headers["location"] == "/login"
    assert "Correo electrónico" in anon.get("/login").text
    mal = anon.post("/login", data={"usuario": USER, "clave": "otra"})
    assert mal.status_code == 401 and "incorrectos" in mal.text
    assert anon.post("/login", data={"usuario": "nadie", "clave": "x"}).status_code == 401
    ok = anon.post("/login", data={"usuario": USER.upper(), "clave": PASS}, follow_redirects=False)
    assert ok.status_code == 303 and "httponly" in ok.headers["set-cookie"].lower()
    assert "GenKey" in anon.get("/genkey").text


def test_caso_02_hash_de_claves_y_sesion_firmada(staff):
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    hashes = [r[0] for r in conn.execute("SELECT password_hash FROM usuarios")]
    conn.close()
    assert len(hashes) == 3 and all(h.startswith("scrypt$") for h in hashes)
    assert PASS not in "".join(hashes)
    cookie = staff.cookies.get("sc_sesion")
    falsa = TestClient(m.app, base_url=BASE)
    falsa.cookies.set("sc_sesion", cookie[:-3] + ("AAA" if not cookie.endswith("AAA") else "BBB"))
    assert falsa.get("/genkey", follow_redirects=False).headers["location"] == "/login"
    salir = staff.post("/logout", data={"csrf": _csrf(staff)}, follow_redirects=False)
    assert salir.headers["location"] == "/login"


def test_caso_03_taxonomias_configurables(staff):
    page = staff.get("/genkey").text
    for t in ["comunicacional", "informativo", "recordatorio", "campaña"]:
        assert f'value="{t}"' in page


def test_caso_04_genkey_enlace_imagen_y_html(staff):
    r = _genkey(staff)
    assert r.status_code == 200 and "Sello generado" in r.text
    link = _link(r.text)
    assert re.fullmatch(r"http://localhost:8090/checkin/[A-Za-z0-9_-]{24}\.[0-9a-f]{16}", link)
    token = link.rsplit("/", 1)[1].split(".")[0]
    assert f'&lt;a href=&quot;{link}&quot;&gt;&lt;img src=&quot;http://localhost:8090/img/{token}.png' in r.text
    img = staff.get(f"/img/{token}.png")
    assert img.status_code == 200 and img.content[:4] == b"\x89PNG"
    assert staff.get("/img/AAAAAAAAAAAAAAAAAAAAAAAA.png").status_code == 404
    assert "Mis últimos sellos" in staff.get("/genkey").text


def test_caso_05_hash_compuesto_y_firma(staff, anon):
    asunto, dest = "Recordatorio de cita médica", "pedro@correo.test"
    link = _link(_genkey(staff, taxonomia="recordatorio", asunto=asunto, destinatario=dest).text)
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    conn.row_factory = sqlite3.Row
    s = dict(conn.execute("SELECT * FROM sellos WHERE token=?", (token,)).fetchone())
    conn.close()
    content = canonical_content(asunto, "politicas: caduca=-; palabra=-; destinatario=opcional")
    rh = recipient_hmac(TEST_ENV["SELLACORREO_HMAC_KEY"].encode(), "comunicacion@demo.institucion.test", dest)
    assert s["recipient_hmac"] == rh
    assert s["h"] == composite_hash(USER, rh, s["ts_utc"], len(content), sha256_hex(content))
    assert link.endswith("." + s["h"][:16])
    pub = anon.get("/.well-known/sellacorreo-key").json()
    assert pub["kid"] == s["kid"]
    payload = seal_payload(s["h"], s["message_id"], s["ts_utc"], "recordatorio", s["kid"])
    assert verify_ed25519(pub["public_key"], payload, s["sig"])
    assert not verify_ed25519(pub["public_key"], seal_payload(s["h"], s["message_id"], s["ts_utc"], "informativo", s["kid"]), s["sig"])


def test_caso_06_checkin_valido(staff, anon):
    link = _link(_genkey(staff, taxonomia="informativo", asunto="Boletín informativo de diciembre").text)
    r = anon.get(link.replace(BASE, ""))
    assert r.status_code == 200 and "Correo válido" in r.text and 'data-resultado="valido"' in r.text
    assert "Boletín informativo de diciembre" in r.text and "Dirección de Comunicación" in r.text
    assert "informativo" in r.text
    # también pegando el enlace en la página CheckIn
    assert "Correo válido" in anon.get("/checkin", params={"enlace": link}).text


def test_caso_07_checkin_invalido(staff, anon):
    link = _link(_genkey(staff).text).replace(BASE, "")
    token, h16 = link.rsplit("/", 1)[1].split(".")
    otro_h = ("0" if h16[0] != "0" else "1") + h16[1:]
    otro_t = token[:-1] + ("A" if token[-1] != "A" else "B")
    for malo in [f"/checkin/{token}.{otro_h}", f"/checkin/{otro_t}.{h16}",
                 "/checkin/AAAAAAAAAAAAAAAAAAAAAAAA.0123456789abcdef", "/checkin/cualquier-cosa"]:
        r = anon.get(malo)
        assert "Correo inválido" in r.text and 'data-resultado="invalido"' in r.text, malo


def test_caso_08_confirmacion_destinatario(staff, anon):
    link = _link(_genkey(staff, destinatario="ana@correo.test").text).replace(BASE, "")
    assert "¿Le llegó a usted?" in anon.get(link).text
    assert "enviado a usted" in anon.post(link, data={"correo": "ANA@correo.test"}).text
    otro = anon.post(link, data={"correo": "victima@correo.test"}).text
    assert "Correo inválido" in otro and "copió la imagen" in otro
    sin_dest = _link(_genkey(staff).text).replace(BASE, "")
    assert "¿Le llegó a usted?" not in anon.get(sin_dest).text


def test_caso_09_csrf_validaciones_y_limite(staff, anon):
    assert _genkey(staff, csrf="0" * 32).status_code == 403
    assert _genkey(staff, taxonomia="spam").status_code == 422
    assert _genkey(staff, destinatario="no-es-correo").status_code == 422
    link = _link(_genkey(staff).text).replace(BASE, "")
    original = m.checkin_limiter
    m.checkin_limiter = m.RateLimiter(3)
    try:
        codes = [anon.get(link).status_code for _ in range(5)]
    finally:
        m.checkin_limiter = original
    assert codes == [200, 200, 200, 429, 429]
    csp = anon.get("/checkin").headers["content-security-policy"]
    assert "default-src 'self'" in csp and "frame-ancestors 'none'" in csp


def test_caso_10_log_encadenado_y_privacidad(staff):
    _genkey(staff, destinatario="maria@correo.test")
    audit = staff.get("/api/v1/integridad").json()
    assert audit["integra"] and audit["entradas"] >= 5
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    dump = "\n".join(conn.iterdump()).lower()
    for addr in ["maria@correo.test", "ana@correo.test", "pedro@correo.test"]:
        assert addr not in dump
    seq = conn.execute("SELECT seq FROM log ORDER BY seq LIMIT 1 OFFSET 1").fetchone()[0]
    conn.execute("UPDATE log SET taxonomia='alterada' WHERE seq=?", (seq,))
    conn.commit()
    roto = staff.get("/api/v1/integridad").json()
    assert not roto["integra"] and roto["errores"][0]["error"] == "cadena_rota"
    conn.close()
    assert TestClient(m.app, base_url=BASE).get("/api/v1/integridad").status_code == 401


def test_acceso_rapido_demostracion(anon, monkeypatch):
    page = anon.get("/login").text
    assert "Acceso rápido de demostración" in page and "Demo2026" in page
    # solo aparecen las cuentas que usan la contraseña demo (no la de clave propia)
    assert 'data-demo="iess.admin"' in page and 'data-demo="iess.comunicacion"' not in page
    assert "Subdirección de Tecnología · admin@demo.institucion.test" in page
    # clic en la fila = envía su formulario
    form = re.search(r'<form method="post" action="/login" class="sc-quick__form">\s*'
                     r'<input type="hidden" name="usuario" value="([^"]+)"><input type="hidden" name="clave" value="([^"]+)">', page)
    r = anon.post("/login", data={"usuario": form.group(1), "clave": form.group(2)}, follow_redirects=False)
    assert r.status_code == 303 and r.headers["location"] == "/genkey"
    html = anon.get("/genkey").text
    assert "Taxonomía del correo" in html and "Nivel de seguridad" in html
    assert "Generar, copia y pegale a tu correo" in html and "Elija la taxonomía" not in html
    assert 'class="sc-brand"' not in html
    assert 'class="sc-hub__img" src="/static/img/genkey-logo.png"' in html
    assert 'sc-map__legend--strong">Hash de seguridad' in html and "Exigir emisor" in html and 'sc-map__legend--strong">Taxonomía del correo' in html
    # login normal con correo electrónico
    c = TestClient(m.app, base_url=BASE)
    ok = c.post("/login", data={"usuario": "comunicacion@demo.institucion.test", "clave": PASS}, follow_redirects=False)
    assert ok.status_code == 303
    # fuera de modo demo la tarjeta no se muestra
    monkeypatch.setenv("SELLACORREO_DEMO", "false")
    assert "Acceso rápido" not in TestClient(m.app, base_url=BASE).get("/login").text


def test_base_de_datos_es_sqlite():
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    tablas = {r[0] for r in conn.execute("SELECT name FROM sqlite_master WHERE type='table'")}
    conn.close()
    assert {"usuarios", "taxonomias", "sellos", "log", "verificaciones"} <= tablas


# ------------------------------------------------------------ políticas de seguridad (GenKey v2)
def test_genkey_sin_cuerpo_y_con_politicas(staff):
    html = staff.get("/genkey").text
    assert 'name="cuerpo"' not in html
    for name in ("pol_palabra", "pol_caducidad", "pol_destinatario", "palabra", "caducidad"):
        assert f'name="{name}"' in html
    assert 'id="sc-map"' in html and 'id="sc-progress"' in html


def test_palabra_segura_visible_solo_si_es_valido(staff, anon):
    link = _link(_genkey(staff, pol_palabra="1", palabra="girasol-azul").text)
    ok = anon.get(link.replace(BASE, ""))
    assert "Correo válido" in ok.text and "data-palabra-segura" in ok.text and "girasol-azul" in ok.text
    token, h16 = link.rsplit("/", 1)[1].split(".")
    bad = anon.get(f"/checkin/{token}.{'0' * 16}")
    assert "Correo inválido" in bad.text and "girasol-azul" not in bad.text and "data-palabra-segura" not in bad.text
    # en la base solo queda cifrada
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    row = conn.execute("SELECT palabra_cifrada, palabra_tag FROM sellos WHERE token=?", (token,)).fetchone()
    dump = "\n".join(conn.iterdump())
    conn.close()
    assert row[0] and row[1] and "girasol-azul" not in dump


def test_palabra_segura_oculta_si_se_altera_el_registro(staff, anon):
    link = _link(_genkey(staff, pol_palabra="1", palabra="faro-rojo").text)
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    conn.execute("UPDATE sellos SET asunto='Actualice su clave aquí' WHERE token=?", (token,))
    conn.commit(); conn.close()
    r = anon.get(link.replace(BASE, ""))
    assert "Correo inválido" in r.text and "faro-rojo" not in r.text


def test_palabra_segura_requiere_longitud(staff):
    r = _genkey(staff, pol_palabra="1", palabra="ab")
    assert r.status_code == 422 and "palabra segura" in r.text


def test_caducidad(staff, anon):
    link = _link(_genkey(staff, pol_caducidad="1", caducidad="7", pol_palabra="1", palabra="luna-llena").text)
    assert "Válido hasta" in anon.get(link.replace(BASE, "")).text
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    conn.execute("UPDATE sellos SET expira_utc='2000-01-01T00:00:00Z' WHERE token=?", (token,))
    conn.commit(); conn.close()
    r = anon.get(link.replace(BASE, ""))  # mover la fecha cambia el hash: también se detecta
    assert "Correo inválido" in r.text and "luna-llena" not in r.text


def test_caducado_de_verdad(staff, anon, monkeypatch):
    link = _link(_genkey(staff, pol_caducidad="1", caducidad="1").text)
    monkeypatch.setattr(m.store, "now_utc", lambda: "2999-01-01T00:00:00Z")
    r = anon.get(link.replace(BASE, ""))
    assert "Correo inválido" in r.text and "caducó" in r.text


def test_exigir_destinatario(staff, anon):
    assert _genkey(staff, pol_destinatario="1").status_code == 422
    link = _link(_genkey(staff, pol_destinatario="1", destinatario="ana@correo.test",
                         pol_palabra="1", palabra="trigo-verde").text)
    path = link.replace(BASE, "")
    g = anon.get(path)
    assert "Falta un paso" in g.text and "Correo válido" not in g.text and "trigo-verde" not in g.text
    otro = anon.post(path, data={"correo": "pirata@correo.test"})
    assert "Correo inválido" in otro.text and "trigo-verde" not in otro.text
    ok = anon.post(path, data={"correo": "ana@correo.test"})
    assert "Correo válido" in ok.text and "trigo-verde" in ok.text


def test_migracion_base_anterior(tmp_path, monkeypatch):
    db = tmp_path / "vieja.db"
    conn = sqlite3.connect(db)
    conn.execute("CREATE TABLE sellos (token TEXT PRIMARY KEY, codigo TEXT, message_id TEXT, usuario TEXT, nombre_emisor TEXT,"
                 " unidad TEXT, emisor TEXT, institucion TEXT, taxonomia TEXT, asunto TEXT, ts_utc TEXT, recipient_hmac TEXT,"
                 " h TEXT, content_size INTEGER, content_sha256 TEXT, kid TEXT, sig TEXT)")
    conn.commit(); conn.close()
    monkeypatch.setenv("SELLACORREO_DB_PATH", str(db))
    m.store.init()
    cols = {r[1] for r in sqlite3.connect(db).execute("PRAGMA table_info(sellos)")}
    assert {"palabra_cifrada", "palabra_tag", "expira_utc", "exige_destinatario"} <= cols


def test_pagina_de_inicio(anon):
    r = anon.get("/")
    assert r.status_code == 200 and "AI-IESS" in r.text
    assert 'data-home-card="validador"' in r.text and 'href="/checkin"' in r.text
    assert 'data-home-card="sello"' in r.text and 'href="/genkey"' in r.text
    assert "suplantación de identidad" in r.text and "/static/img/escudo-correo.png" in r.text
    assert "Haga clic en el encabezado de su correo o pegue su enlace en este Validador." in r.text
    assert "/static/img/escudo-correo.png" in r.text and anon.get("/static/img/escudo-correo.png").status_code == 200
    assert "sc-dial__img--sello" in r.text and anon.get("/static/img/sello.jpg").status_code == 200
    for label in (">Inicio<", ">Sello<", ">Validador<"):
        assert label in r.text
    assert "Sellos emitidos" in r.text and "Verificaciones" in r.text
    assert anon.get("/static/img/inicio-iess.jpg").headers["content-type"] == "image/jpeg"
    assert anon.get("/genkey", follow_redirects=False).headers["location"] == "/login"


def test_animacion_del_inicio(anon):
    html = anon.get("/").text
    assert 'class="sc-dial__pointer"' in html and 'id="sc-home-stage"' in html
    js = anon.get("/static/app.js").text
    assert "prefers-reduced-motion" in js and "sc-hcard--pill" in js and "HOLD" in js


def test_exigir_emisor(staff, anon):
    emisor = "comunicacion@demo.institucion.test"  # buzón del usuario de prueba
    link = _link(_genkey(staff, pol_emisor="1", asunto="Aviso de emisor").text)
    path = link.replace(BASE, "")
    g = anon.get(path)
    assert "Falta un paso" in g.text and 'name="emisor"' in g.text
    assert "Correo válido" not in g.text and emisor not in g.text.split("Falta un paso")[0]
    otro = anon.post(path, data={"emisor": "suplantado@correo.test"})
    assert "Correo inválido" in otro.text and "phishing" in otro.text
    ok = anon.post(path, data={"emisor": emisor.upper()})
    assert "Correo válido" in ok.text and "el emisor" in ok.text
    # la política forma parte del hash: quitarla de la base invalida el sello
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    conn.execute("UPDATE sellos SET exige_emisor=0 WHERE token=?", (token,))
    conn.commit(); conn.close()
    assert "Correo inválido" in anon.get(path).text


def test_sellos_sin_exigir_emisor_no_cambian(staff, anon):
    """Un sello sin la política sigue validando (el contenido no incluye «emisor»)."""
    link = _link(_genkey(staff).text)
    assert "Correo válido" in anon.get(link.replace(BASE, "")).text
