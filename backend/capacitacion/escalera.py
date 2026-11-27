"""Escalera de dificultad y límites de envío (CLAUDE.md §11).

Espeja `Capacitacion/lib/src/domain/escalera.dart`. Las reglas:
- Reportó → sube un nivel y los indicios quedan DOMINADO.
- Ignoró → mismo nivel.
- Hizo clic → baja un nivel y los indicios quedan DEBIL.
- Dos reportes seguidos en nivel 3 → Centinela (un correo al mes).
- El siguiente correo incluye al menos un indicio DEBIL o SIN_PROBAR.
- Límites: máximo un correo por semana, nunca dos en 48 h.
"""

from __future__ import annotations

from datetime import datetime, timedelta

from .plantillas import Plantilla

# --- Estados del mapa de indicios ---
DOMINADO = "DOMINADO"
DEBIL = "DEBIL"
SIN_PROBAR = "SIN_PROBAR"

# --- Resultados del simulacro ---
REPORTO = "REPORTO"
CLIC = "CLIC"
IGNORO = "IGNORO"
PENDIENTE = "PENDIENTE"

# --- Niveles iniciales de capacitación ---
AVANZADO = "AVANZADO"
INTERMEDIO = "INTERMEDIO"
BASICO = "BASICO"

TODOS_INDICIOS = tuple(f"I{n}" for n in range(1, 12))


def diagnostico(resultado: str) -> str:
    return {
        REPORTO: AVANZADO,
        IGNORO: INTERMEDIO,
        CLIC: BASICO,
    }[resultado]


def siguiente_nivel(actual: int, resultado: str) -> int:
    if resultado == REPORTO:
        return min(3, actual + 1)
    if resultado == CLIC:
        return max(1, actual - 1)
    return actual  # IGNORO / PENDIENTE


def actualizar_mapa(
    mapa: dict[str, str], indicios, resultado: str
) -> dict[str, str]:
    nuevo = dict(mapa)
    if resultado == REPORTO:
        for i in indicios:
            nuevo[i] = DOMINADO
    elif resultado == CLIC:
        for i in indicios:
            # No degradar un indicio ya dominado por un clic posterior.
            if nuevo.get(i) != DOMINADO:
                nuevo[i] = DEBIL
    return nuevo


def reportes_seguidos_nivel3(previos: int, nivel_del_correo: int, resultado: str) -> int:
    if resultado == REPORTO and nivel_del_correo == 3:
        return previos + 1
    return 0


def es_centinela(reportes_seguidos: int) -> bool:
    return reportes_seguidos >= 2


def estado_de(mapa: dict[str, str], indicio: str) -> str:
    return mapa.get(indicio, SIN_PROBAR)


def por_practicar(mapa: dict[str, str]) -> set[str]:
    return {i for i in TODOS_INDICIOS if estado_de(mapa, i) != DOMINADO}


def debiles(mapa: dict[str, str]) -> set[str]:
    return {i for i in TODOS_INDICIOS if estado_de(mapa, i) == DEBIL}


def elegir_plantilla(
    plantillas: list[Plantilla],
    tipos: set[str],
    nivel: int,
    mapa: dict[str, str],
    ya_enviadas: set[str] | None = None,
) -> Plantilla | None:
    """Elige la plantilla del siguiente correo: del tipo y nivel del usuario, con
    al menos un indicio DEBIL o SIN_PROBAR; prefiere las de indicios DEBIL y las
    que todavía no se enviaron. Si ninguna cumple el nivel, usa cualquier nivel."""
    ya_enviadas = ya_enviadas or set()
    practicar = por_practicar(mapa)
    debs = debiles(mapa)

    del_tipo = [
        p
        for p in plantillas
        if (p.tipos & tipos) and (practicar & set(p.indicios))
    ]
    if not del_tipo:
        return None

    def puntaje(p: Plantilla) -> int:
        return (
            (100 if p.nivel == nivel else 0)
            + (10 if debs & set(p.indicios) else 0)
            + (0 if p.id in ya_enviadas else 1)
        )

    del_tipo.sort(key=lambda p: (-puntaje(p), p.id))
    return del_tipo[0]


# --------------------------------------------------------------------------- #
# Límites de envío
# --------------------------------------------------------------------------- #

MINIMO_ENTRE_CORREOS = timedelta(hours=48)
UNO_POR_SEMANA = timedelta(days=7)
CENTINELA_MENSUAL = timedelta(days=30)


def proximo_envio(
    ahora: datetime,
    ultimo_envio: datetime | None,
    es_centinela_usuario: bool = False,
) -> datetime | None:
    """Desde cuándo se puede enviar el siguiente correo. None si es ahora."""
    if ultimo_envio is None:
        return None
    espera = CENTINELA_MENSUAL if es_centinela_usuario else UNO_POR_SEMANA
    desde = ultimo_envio + max(espera, MINIMO_ENTRE_CORREOS)
    return desde if ahora < desde else None
