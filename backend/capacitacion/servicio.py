"""Capa de servicio: orquesta el flujo «Quiero capacitarme».

Reúne el generador de correo, la escalera, el almacén, el envío y el
observatorio. La usan tanto la API (`api.py`, `landing.py`) como el script de
demostración, para que la lógica viva en un solo lugar.
"""

from __future__ import annotations

import secrets
from datetime import datetime, timedelta, timezone

from . import escalera, observatorio
from .almacen import (
    CONFIRMANDO_CORREO,
    EN_CURSO,
    ESPERANDO_REACCION,
    NO_INSCRITO,
    PAUSADA,
    Inscripcion,
    Simulacion,
    almacen,
)
from .catalogo import TIPOS_VALIDOS
from .config import config
from .envio import enviar as enviar_correo_fisico
from .generador_correo import generar_correo, microcursos_de
from .plantillas import PLANTILLAS, PLANTILLAS_POR_ID, Plantilla
from .seudonimo import hash_token, id_seudonimo, nuevo_token

# --------------------------------------------------------------------------- #
# Reloj (permite «viajar en el tiempo» en la demo)
# --------------------------------------------------------------------------- #

_desfase = timedelta(0)


def ahora() -> datetime:
    return datetime.now(timezone.utc) + _desfase


def avanzar_reloj(delta: timedelta) -> None:
    global _desfase
    _desfase += delta


# --------------------------------------------------------------------------- #
# Selección de plantilla y de tipo a personalizar
# --------------------------------------------------------------------------- #


def _tipos_validos(tipos: list[str] | set[str]) -> set[str]:
    limpios = {t.strip().upper() for t in tipos if t and t.strip()}
    validos = {t for t in limpios if t in TIPOS_VALIDOS}
    return validos or {"EX5"}  # sin cuenta → ciudadano


def _tipo_para(plantilla: Plantilla, tipos: set[str]) -> str:
    inter = plantilla.tipos & tipos
    candidatos = inter or tipos
    # Orden canónico (EX1..IN4) para que sea determinista.
    return sorted(candidatos, key=TIPOS_VALIDOS.index)[0]


def elegir_primer_correo(tipos: set[str]) -> Plantilla | None:
    """La plantilla del «primer correo por tipo» (§11) más específica."""
    candidatos = [
        p for p in PLANTILLAS if p.es_primer_correo and (p.tipos & tipos)
    ]
    if not candidatos:
        return None
    # Prefiere la plantilla cuyo conjunto de tipos es más específico.
    candidatos.sort(key=lambda p: (len(p.tipos), p.id))
    return candidatos[0]


# --------------------------------------------------------------------------- #
# Envío de un correo de prueba
# --------------------------------------------------------------------------- #


def _nuevo_simulacro_id() -> str:
    return "sim-" + secrets.token_hex(6)


def _enviar(insc: Inscripcion, plantilla: Plantilla) -> dict:
    token = nuevo_token()
    tipo_usuario = _tipo_para(plantilla, insc.tipos)
    correo = generar_correo(
        plantilla, tipo_usuario=tipo_usuario, token=token, para=insc.correo
    )
    resumen_envio = enviar_correo_fisico(correo)

    enviado = ahora()
    vence = enviado + config.ventana_reaccion
    sim = Simulacion(
        simulacro_id=_nuevo_simulacro_id(),
        id_seudonimo=insc.id_seudonimo,
        tipo_usuario=tipo_usuario,
        nivel=plantilla.nivel,
        indicios=tuple(plantilla.indicios),
        plantilla_id=plantilla.id,
        token_hash=hash_token(token),
        enviado_en=enviado,
        vence_en=vence,
        asunto=correo.asunto,
        remitente_visible=correo.remitente_correo_visible,
    )
    almacen.guardar_simulacion(sim)

    insc.ultimo_envio = enviado
    insc.fase = ESPERANDO_REACCION
    insc.simulacro_actual = sim.simulacro_id
    insc.enviadas.add(plantilla.id)
    return {"simulacion": sim, "envio": resumen_envio, "token": token}


# --------------------------------------------------------------------------- #
# Casos de uso
# --------------------------------------------------------------------------- #


def inscribir(
    correo: str,
    tipos: list[str],
    consentimiento: dict,
    *,
    tiene_cuenta: bool = True,
    rango_etario: str = "desconocido",
    es_cuidador: bool = False,
) -> dict:
    """Paso 1-2 de §11: consentimiento, (doble opt-in) y primer correo."""
    id_s = id_seudonimo(correo)
    tipos_v = _tipos_validos(tipos)
    insc = almacen.obtener_o_crear_inscripcion(id_s, correo, tipos_v)
    insc.rango_etario = rango_etario
    insc.es_cuidador = es_cuidador

    if insc.inscrito:
        return estado(insc)

    insc.consentimiento = consentimiento
    insc.tipos = tipos_v

    if not tiene_cuenta:
        # Doble opt-in: esperar la confirmación del correo antes de enviar.
        insc.fase = CONFIRMANDO_CORREO
        return estado(insc)

    _enviar_primer_correo(insc)
    return estado(insc)


def confirmar_correo(correo: str) -> dict:
    """Doble opt-in: la persona confirmó su correo; se envía el primero."""
    id_s = id_seudonimo(correo)
    insc = almacen.inscripcion(id_s)
    if insc is None or insc.fase != CONFIRMANDO_CORREO:
        return estado(insc) if insc else _estado_vacio()
    _enviar_primer_correo(insc)
    return estado(insc)


def _enviar_primer_correo(insc: Inscripcion) -> None:
    plantilla = elegir_primer_correo(insc.tipos) or escalera.elegir_plantilla(
        PLANTILLAS, insc.tipos, nivel=2, mapa=insc.mapa, ya_enviadas=insc.enviadas
    )
    if plantilla is None:
        insc.fase = EN_CURSO
        return
    _enviar(insc, plantilla)


def enviar_siguiente(correo: str) -> tuple[dict, bool]:
    """`POST /api/v1/capacitacion/siguiente` (interno): aplica la escalera."""
    id_s = id_seudonimo(correo)
    insc = almacen.inscripcion(id_s)
    if insc is None or insc.fase != EN_CURSO:
        return (estado(insc) if insc else _estado_vacio()), False
    if escalera.proximo_envio(ahora(), insc.ultimo_envio, insc.es_centinela):
        return estado(insc), False
    plantilla = escalera.elegir_plantilla(
        PLANTILLAS, insc.tipos, insc.nivel_correo, insc.mapa, insc.enviadas
    )
    if plantilla is None:
        return estado(insc), False
    _enviar(insc, plantilla)
    return estado(insc), True


def pausar(correo: str) -> dict:
    insc = almacen.inscripcion(id_seudonimo(correo))
    if insc is None or not insc.inscrito or insc.pausada:
        return estado(insc) if insc else _estado_vacio()
    insc.fase_antes_de_pausa = insc.fase
    insc.fase = PAUSADA
    return estado(insc)


def reanudar(correo: str) -> dict:
    insc = almacen.inscripcion(id_seudonimo(correo))
    if insc is None or not insc.pausada:
        return estado(insc) if insc else _estado_vacio()
    insc.fase = insc.fase_antes_de_pausa or EN_CURSO
    insc.fase_antes_de_pausa = None
    return estado(insc)


def salir(correo: str) -> dict:
    id_s = id_seudonimo(correo)
    almacen.eliminar_inscripcion(id_s)
    # Derecho de eliminación: avisa al observador que borre el plan de la persona.
    observatorio.eliminar_persona(id_s)
    return _estado_vacio()


# --------------------------------------------------------------------------- #
# Reacción al correo de prueba (clic / reporte / vencimiento)
# --------------------------------------------------------------------------- #


def procesar_reaccion_token(token: str, resultado: str) -> dict | None:
    sim = almacen.simulacion_por_token(token)
    if sim is None:
        return None
    return _procesar_reaccion(sim, resultado)


def procesar_reaccion(simulacro_id: str, resultado: str) -> dict | None:
    sim = almacen.simulacion(simulacro_id)
    if sim is None:
        return None
    return _procesar_reaccion(sim, resultado)


def _procesar_reaccion(sim: Simulacion, resultado: str) -> dict | None:
    if resultado == "PENDIENTE":
        return None
    insc = almacen.inscripcion(sim.id_seudonimo)

    # Reporte posterior al clic (§11): no cambia el nivel (sigue Básico), pero
    # el reporte cuenta para el perfil y se observa una sola vez.
    if not sim.pendiente:
        if (
            sim.resultado == escalera.CLIC
            and resultado == escalera.REPORTO
            and not sim.reporto_despues_de_clic
        ):
            sim.reporto_despues_de_clic = True
            _observar(sim, insc, resultado=escalera.REPORTO)
            des = desenlace(sim, escalera.REPORTO)
            if insc is not None:
                insc.ultimo_desenlace = des
            return des
        return None

    # Primera reacción.
    sim.resultado = resultado
    sim.resultado_en = ahora()
    sim.microcurso_enviado = resultado == escalera.CLIC
    if resultado == escalera.CLIC:
        sim.hubo_clic = True

    if insc is not None:
        insc.nivel_inicial = insc.nivel_inicial or escalera.diagnostico(resultado)
        insc.nivel_correo = escalera.siguiente_nivel(sim.nivel, resultado)
        insc.mapa = escalera.actualizar_mapa(insc.mapa, sim.indicios, resultado)
        insc.reportes_seguidos_nivel3 = escalera.reportes_seguidos_nivel3(
            insc.reportes_seguidos_nivel3, sim.nivel, resultado
        )
        if escalera.es_centinela(insc.reportes_seguidos_nivel3):
            insc.es_centinela = True
        insc.fase = EN_CURSO
        des = desenlace(sim, resultado)
        insc.ultimo_desenlace = des
    else:
        des = desenlace(sim, resultado)

    _observar(sim, insc)
    return des


def _observar(
    sim: Simulacion,
    insc: Inscripcion | None,
    *,
    resultado: str | None = None,
) -> None:
    """Envía la observación al Observatorio con el esquema acordado."""
    plantilla = PLANTILLAS_POR_ID.get(sim.plantilla_id)
    implicitos = list(plantilla.indicios_implicitos) if plantilla else []
    if insc is not None:
        tipos = sorted(insc.tipos, key=TIPOS_VALIDOS.index)
        rango = insc.rango_etario
    else:
        tipos = [sim.tipo_usuario]
        rango = "desconocido"

    momento = ahora() if resultado else sim.resultado_en
    segundos = (
        int((momento - sim.enviado_en).total_seconds()) if momento else None
    )
    observatorio.registrar_resultado_simulacro(
        sim,
        tipos=tipos,
        indicios_implicitos=implicitos,
        rango_etario=rango,
        reporto_despues_de_clic=sim.reporto_despues_de_clic,
        segundos_hasta_reaccion=segundos,
        resultado=resultado,
    )


def procesar_vencidas() -> list[dict]:
    """El proceso programado marca IGNORO las simulaciones vencidas (§12)."""
    resultados = []
    for sim in almacen.vencidas(ahora()):
        des = _procesar_reaccion(sim, escalera.IGNORO)
        if des:
            resultados.append({"simulacro_id": sim.simulacro_id, "desenlace": des})
    return resultados


# --------------------------------------------------------------------------- #
# Desenlace (momento enseñable) y estado
# --------------------------------------------------------------------------- #


def desenlace(sim: Simulacion, resultado: str) -> dict:
    indicios = list(sim.indicios)
    if resultado == escalera.REPORTO:
        return {
            "resultado": resultado,
            "titulo": "¡Lo detectaste!",
            "mensaje": (
                "Era un correo de práctica y lo reportaste sin hacer clic. "
                "Estas son las señales que tenía:"
            ),
            "indicios": indicios,
            "microcursos": [],
        }
    if resultado == escalera.CLIC:
        return {
            "resultado": resultado,
            "titulo": "Era un correo de práctica",
            "mensaje": (
                "No pasó nada: era una práctica. Estas son las señales que "
                "tenía, para que la próxima vez las reconozcas:"
            ),
            "indicios": indicios,
            "microcursos": microcursos_de(indicios),
        }
    return {
        "resultado": escalera.IGNORO,
        "titulo": "Te enviamos un correo de seguimiento",
        "mensaje": (
            "El correo de práctica tenía estas señales. Cuando veas algo así, "
            "repórtalo: empieza por «Reportar en un toque»."
        ),
        "indicios": indicios,
        "microcursos": [],
    }


def _resumen_correo(insc: Inscripcion) -> dict | None:
    if not insc.simulacro_actual:
        return None
    sim = almacen.simulacion(insc.simulacro_actual)
    if sim is None:
        return None
    return {
        "simulacro_id": sim.simulacro_id,
        "plantilla_id": sim.plantilla_id,
        "tipo_usuario": sim.tipo_usuario,
        "tipologia": PLANTILLAS_POR_ID[sim.plantilla_id].tipologia,
        "nivel": sim.nivel,
        "indicios": list(sim.indicios),
        "asunto": sim.asunto,
        "remitente_visible": sim.remitente_visible,
        "enviado_en": sim.enviado_en.isoformat(),
        "vence_en": sim.vence_en.isoformat(),
        "resultado": sim.resultado,
    }


def estado(insc: Inscripcion) -> dict:
    prox = escalera.proximo_envio(ahora(), insc.ultimo_envio, insc.es_centinela)
    return {
        "fase": insc.fase,
        "inscrito": insc.inscrito,
        "pausada": insc.pausada,
        "nivel_inicial": insc.nivel_inicial,
        "nivel_correo": insc.nivel_correo,
        "es_centinela": insc.es_centinela,
        "mapa_indicios": dict(insc.mapa),
        "correo_actual": _resumen_correo(insc),
        "ultimo_desenlace": insc.ultimo_desenlace,
        "proximo_envio": prox.isoformat() if prox else None,
    }


def _estado_vacio() -> dict:
    return {
        "fase": NO_INSCRITO,
        "inscrito": False,
        "pausada": False,
        "nivel_inicial": None,
        "nivel_correo": 2,
        "es_centinela": False,
        "mapa_indicios": {},
        "correo_actual": None,
        "ultimo_desenlace": None,
        "proximo_envio": None,
    }


def estado_de_correo(correo: str) -> dict:
    insc = almacen.inscripcion(id_seudonimo(correo))
    return estado(insc) if insc else _estado_vacio()


def me(correo: str | None, tipos: list[str]) -> dict:
    tipos_v = sorted(_tipos_validos(tipos), key=TIPOS_VALIDOS.index)
    zona = "INTERNA" if any(t.startswith("IN") for t in tipos_v) else "EXTERNA"
    insc = almacen.inscripcion(id_seudonimo(correo)) if correo else None
    return {
        "tipos": tipos_v,
        "zona": zona,
        "rango_etario": insc.rango_etario if insc else "desconocido",
        "perfil_conducta": "CENTINELA"
        if (insc and insc.es_centinela)
        else "SIN_PERFIL",
        "es_alto_privilegio": any(t in {"IN3", "IN4"} for t in tipos_v),
    }
