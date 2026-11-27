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
    """Guarda los eventos de la app (telemetría) y reenvía al observador los
    que traigan `id_seudonimo` y correspondan a DECISION/VERIFICACION."""
    observaciones_obs: list[dict] = []
    with _lock:
        for ev in eventos:
            ev.setdefault("recibido_en", _ahora_iso())
            _eventos.append(ev)
            obs = _observacion_de_evento(ev)
            if obs is not None:
                observaciones_obs.append(obs)
    if observaciones_obs:
        _reenviar_observaciones(observaciones_obs)
    return len(eventos)


def _observacion_de_evento(ev: dict) -> dict | None:
    """Convierte un evento de la app al esquema del observador si trae
    `id_seudonimo` y suficientes datos de juicio/verificación."""
    id_s = ev.get("id_seudonimo")
    if not id_s:
        return None
    tipo_ev = str(ev.get("tipo") or ev.get("evento") or "").upper()
    datos = ev.get("datos") if isinstance(ev.get("datos"), dict) else {}
    momento = ev.get("momento") or _ahora_iso()

    base: dict = {"id_seudonimo": id_s, "momento": momento}
    tipos = ev.get("tipos") or ([ev["tipo_usuario"]] if ev.get("tipo_usuario") else None)
    if tipos:
        base["tipos"] = tipos
    rango = ev.get("rango_etario")
    if rango and rango != "desconocido":
        base["rango_etario"] = rango

    if tipo_ev in {"DECISION", "DECISION_TOMADA"}:
        es_estafa = ev.get("es_estafa", datos.get("es_estafa"))
        acerto = ev.get("acerto", ev.get("es_correcta", datos.get("es_correcta")))
        indicios = ev.get("indicios", datos.get("indicios", []))
        if not isinstance(es_estafa, bool) or not isinstance(acerto, bool):
            return None
        if es_estafa and not indicios:
            return None
        obs = {**base, "tipo": "DECISION", "es_estafa": es_estafa, "acerto": acerto, "indicios": indicios}
        for k in ("actividad_id", "item_id", "tipologia"):
            val = ev.get(k, datos.get(k))
            if val is not None:
                obs[k] = val
        return obs

    if tipo_ev == "VERIFICACION":
        semaforo = ev.get("semaforo", datos.get("semaforo"))
        if not semaforo:
            return None
        obs = {**base, "tipo": "VERIFICACION", "semaforo": semaforo}
        if ev.get("tipologia") or datos.get("tipologia"):
            obs["tipologia"] = ev.get("tipologia") or datos.get("tipologia")
        return obs

    return None


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


def siguiente_plantilla(
    id_seudonimo: str,
    *,
    candidatas: list[dict],
    ya_enviadas: set[str] | list[str] = (),
    tipos: set[str] | list[str] = (),
    rango_etario: str = "desconocido",
) -> str | None:
    """Consulta al observador qué plantilla conviene enviar a continuación.

    Devuelve el `plantilla_id` recomendado o `None` si no hay `NUCLEO_URL` o si
    falla (fail-open hacia la escalera local).
    """
    if not config.nucleo_url or not candidatas:
        return None
    httpx = _httpx()
    if httpx is None:
        return None
    url = f"{config.nucleo_url}{PERSONAS_PATH}/{id_seudonimo}/siguiente"
    cuerpo: dict = {
        "ya_enviadas": sorted(ya_enviadas),
        "candidatas": candidatas,
        "tipos": sorted(tipos),
    }
    if rango_etario and rango_etario != "desconocido":
        cuerpo["rango_etario"] = rango_etario
    try:
        resp = httpx.post(url, json=cuerpo, timeout=5)
        if resp.status_code < 300:
            pid = resp.json().get("plantilla_id")
            return str(pid) if pid else None
        log.warning(
            "El observador devolvió %s al pedir siguiente plantilla: %s",
            resp.status_code,
            resp.text[:300],
        )
    except Exception as exc:  # fail-open
        log.warning("No se pudo consultar siguiente plantilla al observador: %s", exc)
    return None


def obtener_plan(
    id_seudonimo: str,
    *,
    tipos: set[str] | list[str] = (),
    rango_etario: str = "desconocido",
) -> dict | None:
    """Obtiene el plan personalizado del observador (best-effort / fail-open)."""
    if not config.nucleo_url:
        return None
    httpx = _httpx()
    if httpx is None:
        return None
    url = f"{config.nucleo_url}{PERSONAS_PATH}/{id_seudonimo}/plan"
    params: dict[str, str] = {}
    if tipos:
        params["tipos"] = ",".join(sorted(tipos))
    if rango_etario and rango_etario != "desconocido":
        params["rango"] = rango_etario
    try:
        resp = httpx.get(url, params=params, timeout=5)
        if resp.status_code < 300:
            return resp.json()
        log.warning("El observador devolvió %s al pedir plan: %s", resp.status_code, resp.text[:300])
    except Exception as exc:  # fail-open
        log.warning("No se pudo consultar el plan al observador: %s", exc)
    return None


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
