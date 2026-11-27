"""SellaCorreo · Login, GenKey y CheckIn (10 casos).

| #  | Caso | Esperado |
|----|------|----------|
| 01 | Login con usuario demo; clave mala; GenKey sin sesión | 303 a GenKey; 401; redirección a /login |
| 02 | Contraseñas solo como hash scrypt; sesión firmada y manipulación | sin clave en claro; cookie alterada = sin sesión |
| 03 | GenKey muestra taxonomías configurables | comunicacional, informativo, recordatorio + extras de .env |
| 04 | GenKey genera enlace dinámico, imagen y HTML | /checkin/<token>.<h16>, PNG, snippet con imagen enlazada |
| 05 | Hash compuesto y firma Ed25519 | H recalculable; firma válida con la clave pública |
| 06 | CheckIn de un enlace auténtico | resultado directo «Correo válido y seguro» con asunto, taxonomía y emisor (verificado con el hash) |
| 07 | CheckIn de enlaces alterados o inventados | «Correo falso» en todos los casos |
| 08 | Sello anterior (sin emisor en el hash) | «Correo falso» con aviso de sello anterior |
| 09 | CSRF, validaciones y límite por IP | 403 sin token; 422 taxonomía inválida; 429 al exceder |
| 10 | Log encadenado firmado y privacidad | cadena íntegra; alterarla se detecta; sin destinatario en claro |
"""
import itertools
import re
import sqlite3

import pytest

from fastapi.testclient import TestClient

from autenticidad import canonical_content, composite_hash, recipient_hmac, seal_payload, sha256_hex, verify_ed25519
from conftest import PASS, TEST_ENV, USER
from sellacorreo import main as m

BASE = "http://localhost:8090"


def _csrf(client, path="/genkey"):
    return re.search(r'name="csrf" value="([0-9a-f]+)"', client.get(path).text).group(1)


def _genkey(client, **kw):
    data = {"taxonomia": "comunicacional", "asunto": "Comunicado: nuevo horario de atención",
            "destinatario": "", "pol_asunto": "1", **kw}
    data["csrf"] = kw.get("csrf", _csrf(client))
    return client.post("/genkey", data=data)


EMISOR = "comunicacion@demo.institucion.test"  # buzón del usuario de prueba


def _verificar(client, path):
    """CheckIn: el clic en la imagen. El emisor se verifica solo con el hash; no se pregunta nada."""
    return client.get(path)


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
    asunto = "Recordatorio de cita médica"
    link = _link(_genkey(staff, taxonomia="recordatorio", asunto=asunto).text)
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    conn.row_factory = sqlite3.Row
    s = dict(conn.execute("SELECT * FROM sellos WHERE token=?", (token,)).fetchone())
    conn.close()
    fp = m.sender_hmac(EMISOR)
    assert s["emisor_hmac"] == fp and len(fp) == 64  # huella HMAC del emisor, dentro del contenido sellado
    content = canonical_content(asunto, f"politicas: caduca=-; palabra=-; destinatario=opcional; emisor={fp}")
    rh = recipient_hmac(TEST_ENV["SELLACORREO_HMAC_KEY"].encode(), EMISOR, "*")  # sin destinatario: marcador fijo
    assert s["recipient_hmac"] is None
    assert s["h"] == composite_hash(USER, rh, s["ts_utc"], len(content), sha256_hex(content))
    assert link.endswith("." + s["h"][:16])
    pub = anon.get("/.well-known/sellacorreo-key").json()
    assert pub["kid"] == s["kid"]
    payload = seal_payload(s["h"], s["message_id"], s["ts_utc"], "recordatorio", s["kid"])
    assert verify_ed25519(pub["public_key"], payload, s["sig"])
    assert not verify_ed25519(pub["public_key"], seal_payload(s["h"], s["message_id"], s["ts_utc"], "informativo", s["kid"]), s["sig"])


def test_caso_06_checkin_valido(staff, anon):
    link = _link(_genkey(staff, taxonomia="informativo", asunto="Boletín informativo de diciembre").text)
    r = anon.get(link.replace(BASE, ""))  # sin pastilla de destinatario: resultado directo, sin preguntas
    assert r.status_code == 200 and "Correo válido y seguro" in r.text and 'data-resultado="valido"' in r.text
    assert "Falta un paso" not in r.text and 'name="emisor"' not in r.text
    assert "Boletín informativo de diciembre" in r.text and "Dirección de Comunicación" in r.text
    assert "informativo" in r.text
    # también pegando el enlace en la página CheckIn
    assert "Correo válido y seguro" in anon.get("/checkin", params={"enlace": link}).text


def test_caso_07_checkin_invalido(staff, anon):
    link = _link(_genkey(staff).text).replace(BASE, "")
    token, h16 = link.rsplit("/", 1)[1].split(".")
    otro_h = ("0" if h16[0] != "0" else "1") + h16[1:]
    otro_t = token[:-1] + ("A" if token[-1] != "A" else "B")
    for malo in [f"/checkin/{token}.{otro_h}", f"/checkin/{otro_t}.{h16}",
                 "/checkin/AAAAAAAAAAAAAAAAAAAAAAAA.0123456789abcdef", "/checkin/cualquier-cosa"]:
        r = anon.get(malo)
        assert "Correo falso" in r.text and 'data-resultado="invalido"' in r.text, malo
        assert "Correo válido" not in r.text and "Falta un paso" not in r.text, malo


def test_caso_08_sello_anterior(staff, anon):
    link = _link(_genkey(staff).text).replace(BASE, "")
    assert "Correo válido y seguro" in anon.get(link).text
    # sello sin emisor en el hash (anterior a esta verificación): nunca es válido
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    conn.execute("UPDATE sellos SET emisor_hmac=NULL WHERE token=?", (token,))
    conn.commit(); conn.close()
    viejo = anon.get(link).text
    assert "Correo falso" in viejo and "anterior" in viejo and "Correo válido" not in viejo


def test_caso_09_csrf_validaciones_y_limite(staff, anon):
    assert _genkey(staff, csrf="0" * 32).status_code == 403
    assert _genkey(staff, taxonomia="spam").status_code == 422
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
    _genkey(staff)
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
    assert 'sc-map__legend--strong">Hash de seguridad' in html and "Correo del emisor" in html and 'sc-map__legend--strong">Taxonomía del correo' in html
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
    for name in ("pol_palabra", "pol_caducidad", "pol_asunto", "palabra", "caducidad"):
        assert f'name="{name}"' in html
    assert 'id="sc-map"' in html and 'id="sc-progress"' in html


def test_palabra_segura_visible_solo_si_es_valido(staff, anon):
    link = _link(_genkey(staff, pol_palabra="1", palabra="girasol-azul").text)
    path = link.replace(BASE, "")
    ok = _verificar(anon, path)
    assert "Correo válido y seguro" in ok.text and "data-palabra-segura" in ok.text and "girasol-azul" in ok.text
    token, h16 = link.rsplit("/", 1)[1].split(".")
    bad = anon.get(f"/checkin/{token}.{'0' * 16}")
    assert "Correo falso" in bad.text and "girasol-azul" not in bad.text and "data-palabra-segura" not in bad.text
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
    r = _verificar(anon, link.replace(BASE, ""))
    assert "Correo falso" in r.text and "faro-rojo" not in r.text


def test_palabra_segura_requiere_longitud(staff):
    r = _genkey(staff, pol_palabra="1", palabra="ab")
    assert r.status_code == 422 and "palabra segura" in r.text


def test_caducidad(staff, anon):
    link = _link(_genkey(staff, pol_caducidad="1", caducidad="7", pol_palabra="1", palabra="luna-llena").text)
    path = link.replace(BASE, "")
    assert "Válido hasta" in _verificar(anon, path).text
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    conn.execute("UPDATE sellos SET expira_utc='2000-01-01T00:00:00Z' WHERE token=?", (token,))
    conn.commit(); conn.close()
    r = _verificar(anon, path)  # mover la fecha cambia el hash: también se detecta
    assert "Correo falso" in r.text and "luna-llena" not in r.text


def test_caducado_de_verdad(staff, anon, monkeypatch):
    link = _link(_genkey(staff, pol_caducidad="1", caducidad="1").text)
    monkeypatch.setattr(m.store, "now_utc", lambda: "2999-01-01T00:00:00Z")
    r = anon.get(link.replace(BASE, ""))
    assert "Correo falso" in r.text and "caducó" in r.text


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
    assert "suplantación de identidad" in r.text and "/static/img/robot-aiess.svg" in r.text
    assert "Haga clic en el encabezado de su correo o pegue su enlace en este Validador." in r.text
    assert "/static/img/robot-aiess.svg" in r.text and anon.get("/static/img/robot-aiess.svg").status_code == 200
    assert "sc-dial__img--sello" in r.text and anon.get("/static/img/sello.jpg").status_code == 200
    for label in (">Inicio<", ">Sello<", ">Sellar Correo<", ">Validador<"):
        assert label in r.text
    assert "Sellos emitidos" in r.text and "Verificaciones" in r.text
    assert anon.get("/static/img/inicio-iess.jpg").headers["content-type"] == "image/jpeg"
    assert anon.get("/genkey", follow_redirects=False).headers["location"] == "/login"


def test_animacion_del_inicio(anon):
    html = anon.get("/").text
    assert 'class="sc-dial__pointer"' in html and 'id="sc-home-stage"' in html
    js = anon.get("/static/app.js").text
    assert "prefers-reduced-motion" in js and "sc-hcard--pill" in js and "HOLD" in js


def test_emisor_automatico_en_el_hash(staff, anon):
    link = _link(_genkey(staff, asunto="Aviso de emisor").text)
    path = link.replace(BASE, "")
    g = anon.get(path)
    assert "Correo válido y seguro" in g.text and "Falta un paso" not in g.text and 'name="emisor"' not in g.text
    # no hay forma de «declarar» un emisor: el emisor sale del hash, no de lo que escriba el visitante
    assert anon.post(path, data={"emisor": "suplantado@correo.test"}).status_code == 405
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    # alterar la huella del emisor guardada invalida el sello
    conn.execute("UPDATE sellos SET emisor_hmac=? WHERE token=?", ("0" * 64, token))
    conn.commit()
    assert "Correo falso" in anon.get(path).text
    # alterar el buzón del emisor (usado en el hash compuesto) también
    conn.execute("UPDATE sellos SET emisor_hmac=? WHERE token=?", (m.sender_hmac(EMISOR), token))
    conn.execute("UPDATE sellos SET emisor='otro@demo.institucion.test' WHERE token=?", (token,))
    conn.commit(); conn.close()
    assert "Correo falso" in anon.get(path).text


def test_emisor_siempre_fijo_en_genkey(staff, anon):
    """«Correo del emisor» es una pastilla fija: no se puede desmarcar y todo sello nuevo la lleva en el hash."""
    html = staff.get("/genkey").text
    assert 'data-policy="pol_emisor"' in html and "checked disabled" in html
    assert 'name="pol_emisor"' not in html
    link = _link(_genkey(staff, pol_emisor="").text)  # aunque el formulario no la envíe, el sello la lleva
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    assert conn.execute("SELECT emisor_hmac FROM sellos WHERE token=?", (token,)).fetchone()[0] == m.sender_hmac(EMISOR)
    conn.close()
    assert "Correo válido y seguro" in _verificar(anon, link.replace(BASE, "")).text




def test_sin_encabezado_y_navegacion_en_el_pie(staff, anon):
    """Ninguna página tiene cabecera oscura; Inicio, Sello, Validador y Ingresar/Salir van en el pie."""
    for pagina in ["/login", "/checkin", "/"]:
        html = anon.get(pagina).text
        assert 'class="tl-nav' not in html and "sc-nav-right" not in html, pagina
        assert 'class="sc-foot-links"' in html and ">Validador<" in html and ">Ingresar<" in html, pagina
    dentro = staff.get("/genkey").text
    assert 'class="tl-nav' not in dentro and ">Salir<" in dentro and "sc-user" not in dentro


@pytest.mark.parametrize("asunto_on,palabra_on,caducidad_on", list(itertools.product([False, True], repeat=3)))
def test_combinaciones_de_politicas(staff, anon, asunto_on, palabra_on, caducidad_on):
    """Las ocho combinaciones de Asunto / Palabra segura / Caducidad (Correo del emisor siempre activa)."""
    datos = {"taxonomia": "informativo", "asunto": "Aviso combinado", "palabra": "girasol-azul", "caducidad": "7",
             "csrf": _csrf(staff)}
    if asunto_on: datos["pol_asunto"] = "1"
    if palabra_on: datos["pol_palabra"] = "1"
    if caducidad_on: datos["pol_caducidad"] = "1"
    r = staff.post("/genkey", data=datos)
    assert r.status_code == 200 and "Sello generado" in r.text
    link = _link(r.text)
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    conn.row_factory = sqlite3.Row
    row = dict(conn.execute("SELECT * FROM sellos WHERE token=?", (token,)).fetchone())
    conn.close()
    assert bool(row["exige_asunto"]) == asunto_on
    assert (row["asunto"] == "Aviso combinado") == asunto_on
    assert (row["palabra_cifrada"] is not None) == palabra_on
    assert (row["expira_utc"] is not None) == caducidad_on
    n = 1 + asunto_on + palabra_on + caducidad_on  # asteriscos: una por opción de «Hash de seguridad» integrada
    assert f'data-asteriscos="{n}"' in r.text
    texto = _verificar(anon, link.replace(BASE, "")).text  # resultado directo, sin preguntas
    assert "Correo válido y seguro" in texto and "Falta un paso" not in texto
    assert f"Hash de seguridad</dt><dd>{'*' * n} ·" in texto
    assert ("Aviso combinado" in texto) == asunto_on
    assert ("girasol-azul" in texto) == palabra_on
    assert ("Válido hasta" in texto) == caducidad_on

def test_politica_seleccionada_sin_valor_se_rechaza(staff):
    assert _genkey(staff, pol_asunto="1", asunto="").status_code == 422
    assert _genkey(staff, pol_palabra="1", palabra="").status_code == 422
    assert _genkey(staff, pol_caducidad="1", caducidad="").status_code == 422
    assert _genkey(staff, pol_caducidad="1", caducidad="5").status_code == 422
    assert _genkey(staff, pol_palabra="1", palabra="ab").status_code == 422
    assert _genkey(staff, pol_asunto="", asunto="").status_code == 200  # sin asunto ni política: sello válido


def test_valor_sin_politica_se_ignora(staff, anon):
    r = _genkey(staff, pol_asunto="", asunto="Texto secreto", palabra="palabra-oculta", pol_caducidad="",
                caducidad="30")
    assert r.status_code == 200
    link = _link(r.text)
    token = link.rsplit("/", 1)[1].split(".")[0]
    conn = sqlite3.connect(TEST_ENV["SELLACORREO_DB_PATH"])
    row = conn.execute("SELECT asunto, palabra_cifrada, expira_utc FROM sellos WHERE token=?", (token,)).fetchone()
    conn.close()
    assert row == ("", None, None)
    texto = _verificar(anon, link.replace(BASE, "")).text
    assert "Correo válido y seguro" in texto and "Texto secreto" not in texto and "palabra-oculta" not in texto


def test_campos_ocultos_no_se_envian_en_el_formulario(staff):
    js = staff.get("/static/app.js").text
    assert "i.disabled = !on" in js and "dest-opt" not in js
    html = staff.get("/genkey").text
    for pill in ("pol_asunto", "pol_palabra", "pol_caducidad"):
        assert f'data-for="{pill}"' in html
    assert "pol_destinatario" not in html and 'name="destinatario"' not in html


def test_lineas_del_mapa_genkey(staff):
    """El mapa tiene el contenedor de líneas y el script las recalcula con las posiciones reales."""
    html = staff.get("/genkey").text
    assert 'id="sc-lines"' in html and 'class="sc-map__lines"' in html and 'id="sc-progress"' in html
    js = staff.get("/static/app.js").text
    assert "const draw = () =>" in js and "ResizeObserver" in js and 'addEventListener("load", draw)' in js
    assert "is-on" in js and "fonts.ready" in js


def test_sello_de_cera_con_asteriscos(staff, anon):
    """La imagen es el sello verde «VALIDAR CORREO» (sin cruz) y lleva un asterisco por opción de Hash de seguridad."""
    import io
    from PIL import Image, ImageChops
    from autenticidad.sello import wax_seal_png
    r = _genkey(staff, pol_palabra="1", palabra="girasol-azul", pol_caducidad="1", caducidad="7")
    assert 'data-asteriscos="4"' in r.text and "4 asteriscos" in r.text
    assert "Correo del emisor, Asunto del correo, Palabra segura, Caducidad del enlace" in r.text
    token = _link(r.text).rsplit("/", 1)[1].split(".")[0]
    img = staff.get(f"/img/{token}.png")
    im = Image.open(io.BytesIO(img.content))
    assert img.status_code == 200 and img.headers["content-type"] == "image/png" and im.size == (480, 480) and im.mode == "RGBA"
    assert im.getpixel((240, 20))[3] > 0 or im.getpixel((240, 40))[3] > 0  # cuerpo de cera, no un fondo vacío
    verde = im.getpixel((240, 120))
    assert verde[1] > verde[0] and verde[1] > verde[2]  # sello verde
    sobre_iess = im.getpixel((240, 187))  # donde antes iba la cruz «+»: ahora verde del escudo, no crema
    assert sobre_iess[0] < 180 and sobre_iess[1] > sobre_iess[0]
    # cada asterisco extra cambia solo la zona baja del escudo
    imgs = {n: Image.open(io.BytesIO(wax_seal_png("ABCD-EFGH-12", "informativo", n))).convert("RGBA") for n in (1, 2, 3, 4)}
    assert len({im2.tobytes() for im2 in imgs.values()}) == 4
    for n in (2, 3, 4):
        caja = ImageChops.difference(imgs[n - 1], imgs[n]).getbbox()
        assert caja and caja[1] > 260  # debajo del código, dentro del escudo
    assert wax_seal_png("X", "informativo", 0) != wax_seal_png("X", "informativo", 1)
    assert staff.get("/img/AAAAAAAAAAAAAAAAAAAAAAAA.png").status_code == 404
    # el HTML para pegar apunta a la imagen cuadrada
    assert 'width="240" height="240"' in r.text and "&lt;img src=&quot;http://localhost:8090/img/" in r.text


def test_asteriscos_segun_opciones(staff):
    assert m.hash_options({"exige_asunto": 0}) == ["Correo del emisor"]
    assert m.hash_options({"exige_asunto": 1, "palabra_tag": "x", "expira_utc": "2030-01-01T00:00:00Z"}) == [
        "Correo del emisor", "Asunto del correo", "Palabra segura", "Caducidad del enlace"]
    solo = _genkey(staff, pol_asunto="")
    assert 'data-asteriscos="1"' in solo.text and "1 asterisco:" in solo.text


def test_pie_institucional_en_todas_las_paginas(staff, anon):
    """Pie con logo IESS, enlaces (incl. Reportar Incidente), barra tricolor y derechos, en todas las páginas."""
    for pagina in ["/", "/login", "/checkin", "/reportar-incidente", "/checkin/cualquier-cosa"]:
        html = anon.get(pagina).text
        assert 'class="sc-footer"' in html, pagina
        assert 'src="/static/img/iess-logo.png"' in html and "AI-IESS · SellaCorreo" in html, pagina
        assert "Sello anti-phishing para correo institucional" in html, pagina
        assert 'class="sc-tricolor"' in html and html.count("<i></i>") == 3, pagina
        assert "© Instituto Ecuatoriano de Seguridad Social - Todos los derechos reservados." in html, pagina
        for enlace in ('href="/"', 'href="/genkey"', 'href="/checkin"', 'href="/reportar-incidente"'):
            assert enlace in html.split('class="sc-footer"')[1], (pagina, enlace)
        assert ">Reportar Incidente<" in html and ">Ingresar<" in html, pagina
    assert ">Salir<" in staff.get("/genkey").text.split('class="sc-footer"')[1]
    logo = anon.get("/static/img/iess-logo.png")
    assert logo.status_code == 200 and logo.headers["content-type"] == "image/png"
    assert "Reportar incidente" in anon.get("/reportar-incidente").text


def test_radar_phishing(staff, anon):
    """Inicio: tarjeta «Radar Phishing» en lugar del rótulo; /radar muestra solo hora y resultado de las verificaciones."""
    home = anon.get("/").text
    assert 'data-home-card="radar"' in home and 'href="/radar"' in home and ">Radar Phishing<" in home
    assert "sc-dial__cap--bottom" not in home
    antes = m.radar_data()
    token, h16 = _link(_genkey(staff).text).rsplit("/", 1)[1].split(".")
    anon.get(f"/checkin/{token}.{'0' * 16}")            # alterado
    anon.get("/checkin/cualquier-cosa")                  # malformado
    anon.get(f"/checkin/{token}.{h16}")                  # auténtico
    d = m.radar_data()
    assert d["total"] == antes["total"] + 3 and d["validas"] == antes["validas"] + 1
    assert d["sospechosas"] == antes["sospechosas"] + 2
    assert {"enlace_malformado", "hash_distinto"} <= {u["estado"] for u in d["ultimos"]}
    assert [u["ts_utc"] for u in d["ultimos"]] == sorted((u["ts_utc"] for u in d["ultimos"]), reverse=True)
    assert len(d["serie"]) == 14 and sum(v[0] + v[1] for v in d["serie"].values()) >= 3
    r = anon.get("/radar")
    assert r.status_code == 200 and "Radar Phishing" in r.text and 'class="sc-footer"' in r.text
    assert m.MOTIVOS["hash_distinto"] in r.text and m.MOTIVOS["enlace_malformado"] in r.text
    assert "sc-radar__chart" in r.text and "Hora (Ecuador)" in r.text
    assert "@" not in r.text.split("<main")[1].split("</main>")[0]   # ningún correo en la página


def test_api_verificar_para_el_robot(staff, anon):
    """El robot AIESS verifica la firma por API: mismo resultado que CheckIn, sin la palabra segura."""
    link = _link(_genkey(staff, taxonomia="informativo", asunto="Boletín informativo de diciembre").text)
    token_h = link.rsplit("/", 1)[1]
    for forma in (token_h, link):  # solo «token.huella» o el enlace completo
        r = anon.get(f"/api/v1/verificar/{forma}")
        d = r.json()
        assert r.status_code == 200 and d["valido"] is True and d["motivo"] == "valido"
        assert d["asunto"] == "Boletín informativo de diciembre" and d["taxonomia"] == "informativo"
        assert "palabra" not in str(d).lower()
        assert r.headers["access-control-allow-origin"] == "*"
    token, h16 = token_h.split(".")
    otro = ("0" if h16[0] != "0" else "1") + h16[1:]
    d = anon.get(f"/api/v1/verificar/{token}.{otro}").json()
    assert d["valido"] is False and d["motivo"] == "hash_distinto" and "asunto" not in d
    assert anon.get("/api/v1/verificar/inventado.0000000000000000").json()["motivo"] in ("no_registrado", "enlace_malformado")

    # Guardián del celular: solo conoce el ASUNTO de la notificación.
    d = anon.get("/api/v1/asunto", params={"asunto": "RE:  boletín INFORMATIVO de diciembre "}).json()
    assert d["sellado"] is True and d["buzon"] and "palabra" not in str(d).lower()
    assert d["enlace"].endswith(token_h)
    d = anon.get("/api/v1/asunto", params={"asunto": "IESS: su pensión será suspendida"}).json()
    assert d["sellado"] is False and d["motivo"] == "sin_sello"
