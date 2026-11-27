"""Observatorio en SellaCorreo: dial, panel, API del observador y CORS.

| #  | Caso | Esperado |
|----|------|----------|
| 11 | El dial de inicio tiene la tarjeta Observatorio abajo (en lugar de «Anti-phishing») | enlace /observatorio |
| 12 | /observatorio sin sesión | redirección al login, que vuelve al Observatorio |
| 13 | Panel con sesión | agregados con k = 10, aviso de datos sintéticos, sin identificadores |
| 14 | API: registrar, plan, siguiente, borrar | 201, plan con falencias, plantilla elegida, borrado |
| 15 | API: observación inválida o lote mixto | 422 y no se guarda nada |
| 16 | /resumen solo con sesión; CORS solo para la API y solo desde localhost | 401 / 200; cabeceras correctas |
"""
import re

from conftest import PASS, USER
from sellacorreo import observatorio

PERSONA = "app-demo-00000000000001"
SIM = {"id_seudonimo": PERSONA, "tipo": "SIMULACRO", "momento": "2026-11-26T10:00:00Z", "tipos": ["EX2"],
       "rango_etario": "65+", "plantilla_id": "N2-EX2-pension", "nivel": 2, "tipologia": "T2",
       "indicios": ["I8", "I1", "I9"], "indicios_implicitos": ["I7", "I2"], "resultado": "CLIC",
       "segundos_hasta_reaccion": 95}


def test_11_dial_con_observatorio(anon):
    html = anon.get("/").text
    assert 'data-home-card="observatorio"' in html and 'href="/observatorio"' in html
    assert "Anti-phishing" not in html
    assert "/static/img/observatorio.svg" in html
    assert anon.get("/static/img/observatorio.svg").status_code == 200


def test_12_sin_sesion_lleva_al_login_y_vuelve(anon):
    r = anon.get("/observatorio", follow_redirects=False)
    assert r.status_code == 303 and r.headers["location"] == "/login?siguiente=/observatorio"
    form = anon.get("/login?siguiente=/observatorio").text
    assert 'name="siguiente" value="/observatorio"' in form
    r = anon.post("/login", data={"usuario": USER, "clave": PASS, "siguiente": "/observatorio"},
                  follow_redirects=False)
    assert r.headers["location"] == "/observatorio"
    # Nunca a un destino fuera de la lista
    r = anon.post("/login", data={"usuario": USER, "clave": PASS, "siguiente": "https://otro.sitio"},
                  follow_redirects=False)
    assert r.headers["location"] == "/genkey"


def test_13_panel_con_agregados_y_aviso_sintetico(staff):
    html = staff.get("/observatorio").text
    assert "Observatorio" in html and "Indicios que más engañan" in html
    assert "personas sintéticas de demostración" in html
    assert "Lo que aprendió de cada segmento" in html
    assert "sint-" not in html  # ningún identificador de persona en el panel
    assert "style=" not in html  # la CSP no permite estilos en línea


def test_14_api_registrar_plan_siguiente_y_borrar(anon, staff):
    r = anon.post("/api/v1/observatorio/observaciones", json={"observaciones": [SIM]})
    assert r.status_code == 201 and r.json() == {"registradas": 1}
    plan = anon.get(f"/api/v1/observatorio/personas/{PERSONA}/plan").json()
    assert plan["falencias"][0]["indicio"] in {"I8", "I1", "I9"}
    assert plan["siguiente_correo"]["nivel"] == 1
    sig = anon.post(f"/api/v1/observatorio/personas/{PERSONA}/siguiente",
                    json={"ya_enviadas": ["N2-EX2-pension"]}).json()
    assert sig["plantilla_id"] and sig["plantilla_id"] != "N2-EX2-pension"
    # El panel muestra el plan solo si se escribe el código
    html = staff.get(f"/observatorio?persona={PERSONA}").text
    assert "Lo que más le conviene practicar" in html
    assert anon.delete(f"/api/v1/observatorio/personas/{PERSONA}").json() == {"borradas": 1}
    assert "No hay observaciones con ese código" in staff.get(f"/observatorio?persona={PERSONA}").text


def test_14b_plan_sin_historial_arranca_por_su_segmento(anon):
    plan = anon.get("/api/v1/observatorio/personas/persona-nueva-000000001/plan?tipos=EX2&rango=65+").json()
    assert plan["tipos"] == ["EX2"] and len(plan["falencias"]) == 3


def test_15_observacion_invalida_no_guarda_nada(anon):
    antes = observatorio.observador().almacen.contar()["observaciones"]
    r = anon.post("/api/v1/observatorio/observaciones", json=[SIM, {**SIM, "indicios": ["I99"]}])
    assert r.status_code == 422 and "indicios" in r.json()["error"]
    r = anon.post("/api/v1/observatorio/observaciones", json={**SIM, "id_seudonimo": "ana@correo.ec"})
    assert r.status_code == 422
    # Desde la red nadie puede marcar datos como sintéticos
    anon.post("/api/v1/observatorio/observaciones", json={**SIM, "id_seudonimo": "otra-persona-0000001",
                                                          "origen": "sintetico"})
    obs = observatorio.observador().almacen.de_persona("otra-persona-0000001")
    assert obs and obs[0].origen == "real"
    assert observatorio.observador().almacen.contar()["observaciones"] == antes + 1


def test_16_resumen_con_sesion_y_cors(anon, staff):
    assert anon.get("/api/v1/observatorio/resumen").status_code == 401
    res = staff.get("/api/v1/observatorio/resumen").json()
    assert res["k_anonimato"] == 10 and res["personas_sinteticas"] == 200
    assert all(s["personas"] >= 10 for s in res["segmentos"])
    # Preflight desde la app Flutter web en localhost
    r = anon.options("/api/v1/observatorio/observaciones",
                     headers={"Origin": "http://localhost:5173", "Access-Control-Request-Method": "POST"})
    assert r.status_code == 204 and r.headers["access-control-allow-origin"] == "http://localhost:5173"
    assert "access-control-allow-credentials" not in r.headers
    # Otro origen, o fuera de la API del Observatorio: sin CORS
    r = anon.get(f"/api/v1/observatorio/personas/{PERSONA}/plan", headers={"Origin": "https://malo.example"})
    assert "access-control-allow-origin" not in r.headers
    r = anon.get("/health", headers={"Origin": "http://localhost:5173"})
    assert "access-control-allow-origin" not in r.headers


def test_16b_quitar_sinteticos_pide_csrf(staff):
    r = staff.post("/observatorio/borrar-sinteticos", data={"csrf": "x"}, follow_redirects=False)
    assert r.status_code == 403
    assert observatorio.observador().almacen.contar()["sinteticas"] > 0
    csrf = re.search(r'name="csrf" value="([0-9a-f]+)"', staff.get("/observatorio").text).group(1)
    r = staff.post("/observatorio/borrar-sinteticos", data={"csrf": csrf}, follow_redirects=False)
    assert r.status_code == 303
    assert observatorio.observador().almacen.contar()["sinteticas"] == 0
    # Se vuelve a sembrar para no afectar a otras pruebas
    observatorio.iniciar()
