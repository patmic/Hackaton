"""Rutas JSON de la API de Capacitación (contratos de CLAUDE.md §12).

La identidad del usuario en la demo llega por cabeceras:
  X-Usuario-Correo: <correo>
  X-Usuario-Tipos:  EX1,IN1   (lista separada por comas)
En producción esto lo resuelve el login/`RoleGuard` del Bloque 2.
"""

from __future__ import annotations

import re
from datetime import timedelta

from fastapi import APIRouter, Header, HTTPException

from . import escalera, observatorio, servicio
from .schemas import (
    EstadoOut,
    EventosIn,
    EventosOut,
    InscribirIn,
    MeOut,
    ReaccionOut,
    ReporteEntranteIn,
)

router = APIRouter()


def _tipos(cabecera: str | None) -> list[str]:
    if not cabecera:
        return []
    return [t.strip() for t in cabecera.split(",") if t.strip()]


# --------------------------------------------------------------------------- #
# /me y /eventos
# --------------------------------------------------------------------------- #


@router.get("/api/v1/me", response_model=MeOut)
def me(
    x_usuario_correo: str | None = Header(default=None),
    x_usuario_tipos: str | None = Header(default=None),
):
    return servicio.me(x_usuario_correo, _tipos(x_usuario_tipos))


@router.post("/api/v1/eventos", response_model=EventosOut)
def eventos(cuerpo: EventosIn):
    n = observatorio.registrar_eventos(cuerpo.eventos)
    return EventosOut(registrados=n)


# --------------------------------------------------------------------------- #
# Flujo «Quiero capacitarme»
# --------------------------------------------------------------------------- #


@router.post("/api/v1/capacitacion/inscribir", response_model=EstadoOut)
def inscribir(cuerpo: InscribirIn):
    if not cuerpo.consentimiento.aceptado:
        raise HTTPException(400, "Se requiere aceptar el consentimiento.")
    return servicio.inscribir(
        correo=str(cuerpo.correo),
        tipos=cuerpo.tipos,
        consentimiento=cuerpo.consentimiento.model_dump(),
        tiene_cuenta=cuerpo.tiene_cuenta,
        rango_etario=cuerpo.rango_etario,
        es_cuidador=cuerpo.es_cuidador,
    )


@router.post("/api/v1/capacitacion/confirmar", response_model=EstadoOut)
def confirmar(x_usuario_correo: str | None = Header(default=None)):
    _requiere_correo(x_usuario_correo)
    return servicio.confirmar_correo(x_usuario_correo)


@router.get("/api/v1/capacitacion/estado", response_model=EstadoOut)
def estado(x_usuario_correo: str | None = Header(default=None)):
    _requiere_correo(x_usuario_correo)
    return servicio.estado_de_correo(x_usuario_correo)


@router.get("/api/v1/capacitacion/plan")
def plan(x_usuario_correo: str | None = Header(default=None)):
    """Devuelve el plan personalizado desde el observador (si está conectado) o
    un resumen local equivalente."""
    _requiere_correo(x_usuario_correo)
    return servicio.plan_de_correo(x_usuario_correo)


@router.post("/api/v1/capacitacion/pausar", response_model=EstadoOut)
def pausar(x_usuario_correo: str | None = Header(default=None)):
    _requiere_correo(x_usuario_correo)
    return servicio.pausar(x_usuario_correo)


@router.post("/api/v1/capacitacion/reanudar", response_model=EstadoOut)
def reanudar(x_usuario_correo: str | None = Header(default=None)):
    _requiere_correo(x_usuario_correo)
    return servicio.reanudar(x_usuario_correo)


@router.post("/api/v1/capacitacion/salir", response_model=EstadoOut)
def salir(x_usuario_correo: str | None = Header(default=None)):
    _requiere_correo(x_usuario_correo)
    return servicio.salir(x_usuario_correo)


@router.post("/api/v1/capacitacion/siguiente", response_model=EstadoOut)
def siguiente(x_usuario_correo: str | None = Header(default=None)):
    """Interno: aplica la escalera y envía el siguiente correo si procede."""
    _requiere_correo(x_usuario_correo)
    estado, _ = servicio.enviar_siguiente(x_usuario_correo)
    return estado


# --------------------------------------------------------------------------- #
# Reportes (webhook de recepción: reenviar el correo = reportar)
# --------------------------------------------------------------------------- #


@router.post("/api/v1/reportes/entrante", response_model=ReaccionOut)
def reporte_entrante(cuerpo: ReporteEntranteIn):
    token = _extraer_token(cuerpo)
    if not token:
        raise HTTPException(422, "No se encontró el token del simulacro.")
    des = servicio.procesar_reaccion_token(token, escalera.REPORTO)
    if des is None:
        return ReaccionOut(aceptado=False)
    return ReaccionOut(aceptado=True, resultado=escalera.REPORTO, desenlace=des)


def _extraer_token(cuerpo: ReporteEntranteIn) -> str | None:
    if cuerpo.token:
        return cuerpo.token.strip()
    for clave, valor in cuerpo.cabeceras.items():
        if clave.lower() == "x-simulacro-ref":
            return valor.strip()
    if cuerpo.cuerpo:
        m = re.search(r"X-Simulacro-Ref:\s*(\S+)", cuerpo.cuerpo)
        if m:
            return m.group(1)
        m = re.search(r"/p/([A-Za-z0-9_\-]+)", cuerpo.cuerpo)
        if m:
            return m.group(1)
    return None


# --------------------------------------------------------------------------- #
# Observatorio (lectura simple; la fuente es el Bloque 3)
# --------------------------------------------------------------------------- #


@router.get("/api/v1/observatorio/metrics")
def metrics(
    tipo: str | None = None,
    rango: str | None = None,
    tipologia: str | None = None,
):
    return {"celdas": observatorio.metricas(tipo, rango, tipologia)}


# --------------------------------------------------------------------------- #
# Ayudas de demostración (no son parte del contrato de producción)
# --------------------------------------------------------------------------- #


@router.post("/api/v1/demo/avanzar")
def demo_avanzar(minutos: int = 11):
    servicio.avanzar_reloj(timedelta(minutes=minutos))
    procesadas = servicio.procesar_vencidas()
    return {"avanzado_min": minutos, "vencidas_procesadas": procesadas}


@router.post("/api/v1/demo/reaccion")
def demo_reaccion(simulacro_id: str, resultado: str):
    resultado = resultado.strip().upper()
    if resultado not in {escalera.REPORTO, escalera.CLIC, escalera.IGNORO}:
        raise HTTPException(400, "resultado debe ser REPORTO, CLIC o IGNORO.")
    des = servicio.procesar_reaccion(simulacro_id, resultado)
    if des is None:
        raise HTTPException(404, "Simulacro no encontrado o ya resuelto.")
    return {"aceptado": True, "desenlace": des}


def _requiere_correo(correo: str | None) -> None:
    if not correo:
        raise HTTPException(401, "Falta la cabecera X-Usuario-Correo.")
