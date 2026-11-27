"""Puente con el Observatorio / observador (Bloque 3, en SellaCorreo).

- Guarda los eventos de la app (`POST /api/v1/eventos`) localmente.
- Por cada resultado de simulacro arma una «observación» con el formato del
  observador y la reenvía en lote a su endpoint si está configurado `NUCLEO_URL`.
- Reenvío *best-effort* y *fail-open* (§5.3): si el observador no responde, el
  flujo de capacitación continúa igual.

Contrato acordado con el observador (Analisis-de-comportamiento, en SellaCorreo):
  POST   {NUCLEO_URL}/api/v1/observatorio/observaciones   {"observaciones": [...]}
  DELETE {NUCLEO_URL}/api/v1/observatorio/personas/{id}    (derecho de eliminación)

El `id_seudonimo` (HMAC, nunca el correo) sí viaja aquí: el observador arma un
plan por persona, como `mapa_indicios` y `perfiles_conducta` de §13. Solo
`eventos_observatorio` es anónimo, y los agregados se publican con k ≥ 10.
"""

from __future__ import annotations

import logging
import os
import threading
from collections import defaultdict
from datetime import datetime, timezone

from .almacen import Simulacion
from .config import config

log = logging.getLogger("capacitacion.observatorio")

OBSERVATORIO_PATH = os.environ.get(
    "OBSERVATORIO_PATH", "/api/v1/observatorio/observaciones"
)
PERSONAS_PATH = os.environ.get("PERSONAS_PATH", "/api/v1/observatorio/personas")

# Máximo por lote y umbral k=10 (regla 6).
MAX_LOTE = 200
K_MINIMO = 10

_lock = threading.Lock()
_eventos: list[dict] = []
_conteo: dict[tuple[str, str, str], dict[str, int]] = defaultdict(
    lambda: defaultdict(int)
)
_personas_por_celda: dict[tuple[str, str, str], set[str]] = defaultdict(set)


def _ahora_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def registrar_eventos(eventos: list[dict]) -> int:
    """Guarda los eventos de la app (telemetría). No van al endpoint de
    observaciones, que solo acepta observaciones de simulacro."""
    with _lock:
        for ev in eventos:
            ev.setdefault("recibido_en", _ahora_iso())
            _eventos.append(ev)
    return len(eventos)


def observacion_de_simulacro(
    sim: Simulacion,
    *,
    tipos: list[str],
    indicios_implicitos: list[str],
    rango_etario: str = "desconocido",
    reporto_despues_de_clic: bool = False,
    segundos_hasta_reaccion: int | None = None,
    resultado: str | None = None,
) -> dict:
    """Arma la observación con el esquema del observador.

    `resultado` permite registrar un reporte posterior al clic (el reporte
    cuenta para el perfil aunque el nivel ya haya bajado, CLAUDE.md §11)."""
    obs: dict = {
        "id_seudonimo": sim.id_seudonimo,
        "tipo": "SIMULACRO",
        "momento": _ahora_iso(),
        "tipos": tipos or [sim.tipo_usuario],
        "plantilla_id": sim.plantilla_id,
        "nivel": sim.nivel,
        "tipologia": _tipologia_de(sim.plantilla_id),
        "indicios": list(sim.indicios),
        "indicios_implicitos": list(indicios_implicitos),
        "resultado": resultado or sim.resultado,
        "reporto_despues_de_clic": reporto_despues_de_clic,
    }
    # "desconocido" da 422 en el observador: se omite el campo.
    if rango_etario and rango_etario != "desconocido":
        obs["rango_etario"] = rango_etario
    if segundos_hasta_reaccion is not None:
        obs["segundos_hasta_reaccion"] = int(segundos_hasta_reaccion)
    return obs


def registrar_resultado_simulacro(
    sim: Simulacion,
    *,
    tipos: list[str],
    indicios_implicitos: list[str],
    rango_etario: str = "desconocido",
    reporto_despues_de_clic: bool = False,
    segundos_hasta_reaccion: int | None = None,
    resultado: str | None = None,
) -> dict:
    obs = observacion_de_simulacro(
        sim,
        tipos=tipos,
        indicios_implicitos=indicios_implicitos,
        rango_etario=rango_etario,
        reporto_despues_de_clic=reporto_despues_de_clic,
        segundos_hasta_reaccion=segundos_hasta_reaccion,
        resultado=resultado,
    )
    with _lock:
        _eventos.append({"tipo": "SIMULACRO_RESULTADO", **obs})
        celda = (sim.tipo_usuario, rango_etario, obs["tipologia"])
        _conteo[celda][obs["resultado"]] += 1
        _personas_por_celda[celda].add(sim.id_seudonimo)
    _reenviar_observaciones([obs])
    return obs


def eliminar_persona(id_seudonimo: str) -> None:
    """Derecho de eliminación: avisa al observador que borre el plan (best-effort)."""
    if not config.nucleo_url:
        return
    httpx = _httpx()
    if httpx is None:
        return
    url = f"{config.nucleo_url}{PERSONAS_PATH}/{id_seudonimo}"
    try:
        httpx.delete(url, timeout=5)
    except Exception as exc:  # fail-open
        log.warning("No se pudo eliminar la persona en el observador: %s", exc)


def metricas(
    tipo: str | None = None,
    rango: str | None = None,
    tipologia: str | None = None,
) -> list[dict]:
    """Métricas agregadas locales con supresión k=10 (regla 6)."""
    salida: list[dict] = []
    with _lock:
        for (t, r, tp), resultados in _conteo.items():
            if tipo and t != tipo:
                continue
            if rango and r != rango:
                continue
            if tipologia and tp != tipologia:
                continue
            n = len(_personas_por_celda[(t, r, tp)])
            if n < K_MINIMO:
                continue
            salida.append(
                {
                    "tipo_usuario": t,
                    "rango_etario": r,
                    "tipologia": tp,
                    "personas": n,
                    "resultados": dict(resultados),
                }
            )
    return salida


def _tipologia_de(plantilla_id: str) -> str:
    from .plantillas import PLANTILLAS_POR_ID

    p = PLANTILLAS_POR_ID.get(plantilla_id)
    return p.tipologia if p else "?"


def _httpx():
    try:
        import httpx

        return httpx
    except ImportError:
        log.warning("httpx no está instalado; no se contacta al observador.")
        return None


def _reenviar_observaciones(observaciones: list[dict]) -> None:
    if not config.nucleo_url or not observaciones:
        return
    httpx = _httpx()
    if httpx is None:
        return
    url = f"{config.nucleo_url}{OBSERVATORIO_PATH}"
    # Respeta el máximo de 200 por envío (todo-o-nada en el observador).
    for i in range(0, len(observaciones), MAX_LOTE):
        lote = observaciones[i : i + MAX_LOTE]
        try:
            resp = httpx.post(url, json={"observaciones": lote}, timeout=5)
            if resp.status_code >= 300:
                log.warning(
                    "El observador rechazó el lote (%s): %s",
                    resp.status_code,
                    resp.text[:300],
                )
        except Exception as exc:  # fail-open: no romper el flujo
            log.warning("No se pudo reenviar al observador (%s): %s", url, exc)
