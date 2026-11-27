"""Punto de entrada de la API de Capacitación (FastAPI).

Arranque:
    uvicorn backend.capacitacion.main:app --reload --port 8080

En el diagrama de arquitectura es el nodo «API de Capacitación» de la Zona
Externa, que la App Oficial consume y que alimenta al Observatorio (Bloque 3).
"""

from __future__ import annotations

import logging
import threading
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import __version__, api, landing, servicio
from .catalogo import cargar_catalogo
from .config import config

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("capacitacion")


def _iniciar_scheduler() -> tuple[threading.Event, threading.Thread | None]:
    detener = threading.Event()
    intervalo = config.procesar_vencidas_seg
    if intervalo <= 0:
        return detener, None

    def _ciclo() -> None:
        while not detener.wait(intervalo):
            try:
                vencidas = servicio.procesar_vencidas()
                if vencidas:
                    log.info("Scheduler: %d simulaciones vencidas marcadas IGNORO.", len(vencidas))
            except Exception:  # fail-open: nunca matar el hilo
                log.exception("Error procesando simulaciones vencidas.")

    hilo = threading.Thread(target=_ciclo, name="capacitacion-vencidas", daemon=True)
    hilo.start()
    return detener, hilo


@asynccontextmanager
async def lifespan(_app: FastAPI):
    for aviso in config.validar():
        log.warning("Aviso de configuración: %s", aviso)
    cat = cargar_catalogo()
    log.info(
        "Catálogo de tipologías v%s cargado (%d tipologías). Entorno=%s, "
        "envío=%s, dominio_práctica=%s, nucleo_url=%s",
        cat.version,
        len(cat.tipologias),
        config.entorno,
        config.envio_modo,
        config.dominio_practica,
        config.nucleo_url or "desconectado",
    )
    detener, _ = _iniciar_scheduler()
    try:
        yield
    finally:
        detener.set()


app = FastAPI(
    title="API de Capacitación · Escudo Cognitivo IESS",
    version=__version__,
    lifespan=lifespan,
    description=(
        "Flujo «Quiero capacitarme»: genera y envía correos de phishing "
        "SIMULADO (ficticios) adaptados por tipo de usuario y tipología, aplica "
        "la escalera y los límites, y alimenta el Observatorio. Ninguna página "
        "de destino tiene formularios y ningún correo sale de iess.gob.ec."
    ),
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=list(config.cors_origenes) or ["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api.router)
app.include_router(landing.router)


@app.get("/")
def raiz() -> dict:
    return {
        "servicio": "API de Capacitación IESS",
        "version": __version__,
        "entorno": config.entorno,
        "envio_modo": config.envio_modo,
        "ventana_reaccion_min": int(config.ventana_reaccion.total_seconds() // 60),
        "endpoints": [
            "GET  /api/v1/me",
            "POST /api/v1/eventos",
            "POST /api/v1/capacitacion/inscribir",
            "GET  /api/v1/capacitacion/estado",
            "GET  /api/v1/capacitacion/plan",
            "POST /api/v1/capacitacion/confirmar",
            "POST /api/v1/capacitacion/pausar",
            "POST /api/v1/capacitacion/reanudar",
            "POST /api/v1/capacitacion/salir",
            "POST /api/v1/capacitacion/siguiente",
            "POST /api/v1/reportes/entrante",
            "GET  /api/v1/observatorio/metrics",
            "GET  /p/{token}",
            "POST /p/{token}/clic",
            "GET  /salir/{token}",
        ],
    }


@app.get("/salud")
def salud() -> dict:
    return {"ok": True}
