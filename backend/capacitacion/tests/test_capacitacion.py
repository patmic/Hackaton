"""Pruebas de la API de Capacitación y su integración con el Observador."""
from __future__ import annotations

import os
import sys
from datetime import timedelta
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

RAIZ = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(RAIZ), str(RAIZ / "Analisis-de-comportamiento")]

os.environ.setdefault("PROCESAR_VENCIDAS_SEG", "0")
os.environ.setdefault("ENVIO_MODO", "consola")

from backend.capacitacion import escalera, observatorio, servicio  # noqa: E402
from backend.capacitacion.almacen import almacen  # noqa: E402
from backend.capacitacion.config import config  # noqa: E402
from backend.capacitacion.generador_correo import generar_correo  # noqa: E402
from backend.capacitacion.main import app  # noqa: E402
from backend.capacitacion.plantillas import PLANTILLAS  # noqa: E402
from backend.capacitacion.seudonimo import id_seudonimo  # noqa: E402


@pytest.fixture(autouse=True)
def _limpiar_estado(tmp_path):
    almacen._inscripciones.clear()
    almacen._simulaciones.clear()
    almacen._por_token_hash.clear()
    with observatorio._lock:
        observatorio._eventos.clear()
        observatorio._conteo.clear()
        observatorio._personas_por_celda.clear()
    salida_anterior = config.salida_dir
    nucleo_anterior = config.nucleo_url
    object.__setattr__(config, "salida_dir", tmp_path)
    servicio._desfase = timedelta(0)
    try:
        yield
    finally:
        object.__setattr__(config, "salida_dir", salida_anterior)
        object.__setattr__(config, "nucleo_url", nucleo_anterior)


def test_generador_cumple_garantias_de_seguridad():
    for p in PLANTILLAS:
        tipo = next(iter(p.tipos))
        correo = generar_correo(p, tipo_usuario=tipo, token=f"tok-{p.id}", para="prueba@ejemplo.test")
        assert not correo.remitente_correo_envio.endswith("iess.gob.ec")
        assert not correo.remitente_correo_visible.endswith("iess.gob.ec")
        assert f"/p/tok-{p.id}" in correo.cuerpo_html
        assert f"/salir/tok-{p.id}" in correo.cabeceras["List-Unsubscribe"]
        assert correo.cabeceras["X-Simulacro-Ref"] == f"tok-{p.id}"
        for adj in correo.adjuntos:
            if adj.cid is None:
                assert b"ARCHIVO DE PR" in adj.datos


def test_flujo_doble_opt_in_clic_y_momento_ensenanable():
    client = TestClient(app)
    correo = "sin-cuenta@practica.example.com"

    # Sin cuenta -> fase CONFIRMANDO_CORREO (no envía todavía)
    r = client.post(
        "/api/v1/capacitacion/inscribir",
        json={
            "consentimiento": {"version": "2026-11-v1", "aceptado": True},
            "correo": correo,
            "tipos": ["EX5"],
            "tiene_cuenta": False,
            "rango_etario": "30-49",
        },
    )
    assert r.status_code == 200
    assert r.json()["fase"] == "CONFIRMANDO_CORREO"

    # Confirmar envía el primer correo
    r = client.post("/api/v1/capacitacion/confirmar", headers={"X-Usuario-Correo": correo})
    assert r.status_code == 200
    est = r.json()
    assert est["fase"] == "ESPERANDO_REACCION"
    sim_id = est["correo_actual"]["simulacro_id"]

    # Extraer el token desde el archivo .eml generado
    eml = list(config.salida_dir.glob("*.eml"))[0].read_text(encoding="utf-8")
    token = [ln.split(": ", 1)[1].strip() for ln in eml.splitlines() if ln.startswith("X-Simulacro-Ref:")][0]

    # GET /p/{token} NO cuenta clic y no contiene formularios de captura de datos
    get_p = client.get(f"/p/{token}")
    assert get_p.status_code == 200
    assert 'type="password"' not in get_p.text and 'type="email"' not in get_p.text
    assert client.get("/api/v1/capacitacion/estado", headers={"X-Usuario-Correo": correo}).json()["fase"] == "ESPERANDO_REACCION"

    # POST /p/{token}/clic sí cuenta clic, baja nivel a 1 y marca indicios DEBIL
    post_clic = client.post(f"/p/{token}/clic")
    assert post_clic.status_code == 200
    assert "Era un correo de práctica" in post_clic.text
    est2 = client.get("/api/v1/capacitacion/estado", headers={"X-Usuario-Correo": correo}).json()
    assert est2["fase"] == "EN_CURSO"
    assert est2["nivel_inicial"] == "BASICO"
    assert est2["nivel_correo"] == 1
    assert est2["correo_actual"]["simulacro_id"] == sim_id
    assert any(v == "DEBIL" for v in est2["mapa_indicios"].values())


def test_reporte_entrante_sube_nivel_y_promueve_centinela():
    client = TestClient(app)
    correo = "afiliado-pro@practica.example.com"

    r = client.post(
        "/api/v1/capacitacion/inscribir",
        json={
            "consentimiento": {"version": "2026-11-v1", "aceptado": True},
            "correo": correo,
            "tipos": ["EX1"],
            "tiene_cuenta": True,
            "rango_etario": "30-49",
        },
    )
    assert r.status_code == 200 and r.json()["fase"] == "ESPERANDO_REACCION"
    eml = sorted(config.salida_dir.glob("*.eml"))[-1].read_text(encoding="utf-8")
    token = [ln.split(": ", 1)[1].strip() for ln in eml.splitlines() if ln.startswith("X-Simulacro-Ref:")][0]

    rep = client.post("/api/v1/reportes/entrante", json={"cabeceras": {"X-Simulacro-Ref": token}})
    assert rep.status_code == 200 and rep.json()["aceptado"] is True
    est = client.get("/api/v1/capacitacion/estado", headers={"X-Usuario-Correo": correo}).json()
    assert est["nivel_inicial"] == "AVANZADO"
    assert est["nivel_correo"] == 3


def test_vencimiento_genera_ignoro_y_correo_seguimiento():
    client = TestClient(app)
    correo = "olvidadizo@practica.example.com"
    client.post(
        "/api/v1/capacitacion/inscribir",
        json={
            "consentimiento": {"version": "2026-11-v1", "aceptado": True},
            "correo": correo,
            "tipos": ["EX2"],
            "tiene_cuenta": True,
            "rango_etario": "65+",
        },
    )
    antes = len(list(config.salida_dir.glob("*.eml")))
    r = client.post("/api/v1/demo/avanzar?minutos=11")
    assert r.status_code == 200 and len(r.json()["vencidas_procesadas"]) == 1
    despues = len(list(config.salida_dir.glob("*.eml")))
    assert despues == antes + 1  # se escribió el .eml de seguimiento
    est = client.get("/api/v1/capacitacion/estado", headers={"X-Usuario-Correo": correo}).json()
    assert est["nivel_inicial"] == "INTERMEDIO"
    assert est["ultimo_desenlace"]["resultado"] == escalera.IGNORO


def test_integracion_completa_con_observador(monkeypatch):
    from fastapi import FastAPI
    from observador import Almacen as ObsAlmacen, Observador
    from observador.api import crear_router

    obs = Observador(ObsAlmacen(":memory:"))
    obs_app = FastAPI()
    obs_app.include_router(
        crear_router(obs, puede_ver_panel=lambda _r: True),
        prefix="/api/v1/observatorio",
    )
    obs_client = TestClient(obs_app)

    class _HttpxBridge:
        @staticmethod
        def post(url, json=None, timeout=5):
            path = url.split("http://obs.test", 1)[1]
            return obs_client.post(path, json=json)

        @staticmethod
        def get(url, params=None, timeout=5):
            path = url.split("http://obs.test", 1)[1]
            return obs_client.get(path, params=params)

        @staticmethod
        def delete(url, timeout=5):
            path = url.split("http://obs.test", 1)[1]
            return obs_client.delete(path)

    object.__setattr__(config, "nucleo_url", "http://obs.test")
    monkeypatch.setattr(observatorio, "_httpx", lambda: _HttpxBridge)

    client = TestClient(app)
    correo = "integrado@practica.example.com"
    id_s = id_seudonimo(correo)

    client.post(
        "/api/v1/capacitacion/inscribir",
        json={
            "consentimiento": {"version": "2026-11-v1", "aceptado": True},
            "correo": correo,
            "tipos": ["EX1"],
            "tiene_cuenta": True,
            "rango_etario": "50-64",
        },
    )
    sim_id = client.get("/api/v1/capacitacion/estado", headers={"X-Usuario-Correo": correo}).json()["correo_actual"]["simulacro_id"]
    client.post(f"/api/v1/demo/reaccion?simulacro_id={sim_id}&resultado=CLIC")

    # El observador recibió la observación del simulacro
    assert len(obs.almacen.de_persona(id_s)) == 1

    # Enviar un evento DECISION_TOMADA con id_seudonimo también alimenta al observador
    ev_resp = client.post(
        "/api/v1/eventos",
        json={
            "eventos": [
                {
                    "evento": "DECISION_TOMADA",
                    "id_seudonimo": id_s,
                    "tipo_usuario": "EX1",
                    "rango_etario": "50-64",
                    "es_estafa": True,
                    "es_correcta": False,
                    "indicios": ["I4"],
                    "tipologia": "T3",
                }
            ]
        },
    )
    assert ev_resp.status_code == 200 and ev_resp.json()["registrados"] == 1
    assert len(obs.almacen.de_persona(id_s)) == 2

    # Plan desde el observador a través de la API de Capacitación
    plan_resp = client.get("/api/v1/capacitacion/plan", headers={"X-Usuario-Correo": correo})
    assert plan_resp.status_code == 200
    assert plan_resp.json()["id_seudonimo"] == id_s

    # Siguiente correo se elige consultando al observador
    client.post("/api/v1/demo/avanzar?minutos=10081")
    sig_resp = client.post("/api/v1/capacitacion/siguiente", headers={"X-Usuario-Correo": correo})
    assert sig_resp.status_code == 200
    assert sig_resp.json()["fase"] == "ESPERANDO_REACCION"

    # Derecho de eliminación (LOPDP): salir borra también en el observador
    client.post("/api/v1/capacitacion/salir", headers={"X-Usuario-Correo": correo})
    assert obs.almacen.de_persona(id_s) == []
