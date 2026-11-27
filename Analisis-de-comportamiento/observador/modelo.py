"""Modelo de una persona: qué indicios reconoce y cómo se comporta.

Cómo aprende (todo es explicable, sin cajas negras):

1. Cada observación deja **evidencia** sobre los indicios que tenía el correo o
   el ítem: evidencia de *acierto* (los reconoció) o de *fallo* (no los vio).
2. La evidencia **pesa según la dificultad** (idea de la NIST Phish Scale,
   `obsidian/1-Investigacion/07 Evidencia cientifica.md`): reportar un correo
   sutil (nivel 3) dice más que reportar uno obvio (nivel 1), y hacer clic en
   uno obvio dice más que hacer clic en uno sutil.
3. La evidencia **se olvida**: pierde la mitad de su peso cada
   `VIDA_MEDIA_DIAS`. Lo aprendido se olvida en 1 a 6 meses (CLAUDE.md §10.1),
   así que un indicio dominado hace tiempo vuelve a «por repasar».
4. Con esa evidencia se estima, para cada indicio, la probabilidad de que la
   persona lo reconozca: media de una distribución Beta.

Lo que ve la persona (DOMINADO / DEBIL / SIN_PROBAR, §8.2) sale **solo de sus
propias acciones**. El segmento al que pertenece se usa en `plan.py` para
decidir qué practicar primero, nunca para etiquetarla.
"""
from __future__ import annotations

import math
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from statistics import median

from .catalogo import INDICIOS, INTERNOS
from .observaciones import Observacion

VIDA_MEDIA_DIAS = 60.0
PESO_ACIERTO = {1: 0.6, 2: 1.0, 3: 1.4}   # reportar: más mérito cuanto más difícil
PESO_FALLO = {1: 1.4, 2: 1.0, 3: 0.6}     # clic: más diagnóstico cuanto más fácil
FACTOR_IMPLICITO = 0.5                     # I7 e I2 de todo correo de práctica
PESO_ACTIVIDAD = 0.5                       # practicar en la app pesa menos que la conducta real
PRIOR_PERSONAL = 0.5                       # Beta(0.5, 0.5) de Jeffreys: no presupone nada
EVIDENCIA_MINIMA = 0.25                    # por debajo, el indicio está SIN_PROBAR
UMBRAL_DOMINADO = 0.6
VENTANA_DIAS = 90                          # ventana del perfil de conducta (§7)
# [SUPUESTO] Tasa de clic esperada por nivel. Ho et al. (IEEE S&P 2025) midieron
# entre 1,8 % y 30,8 % según el señuelo; poblacion.py la recalibra con lo observado.
CLIC_ESPERADO = {1: 0.08, 2: 0.18, 3: 0.30}

ETIQUETAS_ESTADO = {"DOMINADO": "Lo dominas", "DEBIL": "Para practicar", "SIN_PROBAR": "Sin probar"}
ETIQUETAS_PERFIL = {
    "CENTINELA": "Centinela",
    "PRUDENTE": "Prudente",
    "EXPUESTO": "En aprendizaje",  # regla 7: «Expuesto» nunca se muestra
    "INACTIVO": "Inactivo",
    "SIN_PERFIL": "Sin perfil",
}


def factor_olvido(momento: datetime, ahora: datetime) -> float:
    dias = max(0.0, (ahora - momento).total_seconds() / 86400)
    return 0.5 ** (dias / VIDA_MEDIA_DIAS)


@dataclass
class Evidencia:
    """Evidencia acumulada (ya con olvido) sobre un indicio o una tipología."""

    acierto: float = 0.0
    fallo: float = 0.0
    ultima: datetime | None = None

    @property
    def total(self) -> float:
        return self.acierto + self.fallo

    def sumar(self, acierto: float, fallo: float, momento: datetime) -> None:
        self.acierto += acierto
        self.fallo += fallo
        if self.ultima is None or momento > self.ultima:
            self.ultima = momento

    def media(self, prior_media: float = 0.5, fuerza_prior: float = 2 * PRIOR_PERSONAL) -> float:
        a = fuerza_prior * prior_media + self.acierto
        b = fuerza_prior * (1 - prior_media) + self.fallo
        return a / (a + b)

    def desviacion(self, prior_media: float = 0.5, fuerza_prior: float = 2 * PRIOR_PERSONAL) -> float:
        a = fuerza_prior * prior_media + self.acierto
        b = fuerza_prior * (1 - prior_media) + self.fallo
        return math.sqrt(a * b / ((a + b) ** 2 * (a + b + 1)))


def _aportes(o: Observacion) -> list[tuple[str, float, float]]:
    """(indicio, acierto, fallo) que deja una observación, sin olvido."""
    if o.es_reporte_tardio:
        return []  # ya contó el clic de ese mismo correo
    if o.tipo == "SIMULACRO" and o.resultado in ("REPORTO", "CLIC"):
        nivel = o.nivel or 2
        if o.resultado == "REPORTO":
            peso = PESO_ACIERTO[nivel]
            return ([(i, peso, 0.0) for i in o.indicios]
                    + [(i, peso * FACTOR_IMPLICITO, 0.0) for i in o.indicios_implicitos])
        peso = PESO_FALLO[nivel]
        return ([(i, 0.0, peso) for i in o.indicios]
                + [(i, 0.0, peso * FACTOR_IMPLICITO) for i in o.indicios_implicitos])
    if o.tipo == "DECISION" and o.es_estafa:
        return [(i, PESO_ACTIVIDAD, 0.0) if o.acerto else (i, 0.0, PESO_ACTIVIDAD) for i in o.indicios]
    # IGNORO no dice si vio los indicios (no se miden aperturas, §11);
    # un correo legítimo bien juzgado no trae indicios; una verificación
    # muestra un hábito, no el dominio de un indicio.
    return []


def evidencia_por_indicio(observaciones: list[Observacion], ahora: datetime) -> dict[str, Evidencia]:
    ev = {i: Evidencia() for i in INDICIOS}
    for o in observaciones:
        f = factor_olvido(o.momento, ahora)
        for indicio, a, b in _aportes(o):
            ev[indicio].sumar(a * f, b * f, o.momento)
    return ev


def evidencia_por_tipologia(observaciones: list[Observacion], ahora: datetime) -> dict[str, Evidencia]:
    """Qué tan bien distingue los correos que suplantan cada tipología."""
    ev: dict[str, Evidencia] = {}
    for o in observaciones:
        if not o.tipologia or o.es_reporte_tardio:
            continue
        f = factor_olvido(o.momento, ahora)
        if o.tipo == "SIMULACRO" and o.resultado in ("REPORTO", "CLIC"):
            peso = (PESO_ACIERTO if o.resultado == "REPORTO" else PESO_FALLO)[o.nivel or 2]
            acierto = peso if o.resultado == "REPORTO" else 0.0
            ev.setdefault(o.tipologia, Evidencia()).sumar(acierto * f, (peso - acierto) * f, o.momento)
        elif o.tipo == "DECISION" and o.es_estafa:
            ok = PESO_ACTIVIDAD if o.acerto else 0.0
            ev.setdefault(o.tipologia, Evidencia()).sumar(ok * f, (PESO_ACTIVIDAD - ok) * f, o.momento)
    return ev


@dataclass(frozen=True)
class EstadoIndicio:
    indicio: str
    estado: str            # DOMINADO | DEBIL | SIN_PROBAR (compatible con el mapa de §8.2)
    dominio: float         # probabilidad estimada de reconocerlo, solo con sus acciones
    evidencia: float
    confianza: str         # BAJA | MEDIA | ALTA
    repasar: bool          # lo dominaba, pero la evidencia ya es vieja

    def a_json(self) -> dict:
        return {"indicio": self.indicio, "nombre": INDICIOS[self.indicio], "estado": self.estado,
                "etiqueta": ETIQUETAS_ESTADO[self.estado], "dominio": round(self.dominio, 3),
                "evidencia": round(self.evidencia, 3), "confianza": self.confianza, "repasar": self.repasar}


def confianza_de(evidencia: float) -> str:
    return "BAJA" if evidencia < 1.0 else "MEDIA" if evidencia < 3.0 else "ALTA"


def estados_indicios(observaciones: list[Observacion], ahora: datetime) -> dict[str, EstadoIndicio]:
    resultado = {}
    for indicio, ev in evidencia_por_indicio(observaciones, ahora).items():
        dominio = ev.media()
        if ev.total < EVIDENCIA_MINIMA:
            estado = "SIN_PROBAR"
        elif dominio >= UMBRAL_DOMINADO:
            estado = "DOMINADO"
        else:
            estado = "DEBIL"
        repasar = (ev.ultima is not None and ev.acierto > ev.fallo
                   and (ahora - ev.ultima) > timedelta(days=VIDA_MEDIA_DIAS))
        resultado[indicio] = EstadoIndicio(indicio, estado, dominio, ev.total, confianza_de(ev.total), repasar)
    return resultado


# ------------------------------------------------------------------ conducta
@dataclass(frozen=True)
class Metricas:
    """Métricas de la persona en la ventana de 90 días (CLAUDE.md §8)."""

    acciones: int = 0
    juicios: int = 0
    aciertos: int = 0
    simulacros: int = 0
    reportes: int = 0
    clics: int = 0
    ignorados: int = 0
    decisiones: int = 0
    verificaciones: int = 0
    falsos_positivos: int = 0
    items_legitimos: int = 0
    mediana_segundos_reporte: float | None = None
    clics_esperados: float = 0.0
    ultima_accion: datetime | None = None
    otras: dict = field(default_factory=dict)

    @property
    def precision(self) -> float | None:
        return self.aciertos / self.juicios if self.juicios else None

    @property
    def tasa_reporte(self) -> float | None:
        return self.reportes / self.simulacros if self.simulacros else None

    @property
    def clic_ajustado(self) -> float | None:
        """Clics observados ÷ clics esperados por la dificultad de los correos.
        Menos de 1: cae menos de lo esperado. Es la forma honesta de comparar
        tasas de clic (NIST Phish Scale)."""
        return self.clics / self.clics_esperados if self.clics_esperados else None

    def a_json(self) -> dict:
        def r(x):
            return None if x is None else round(x, 3)
        return {"acciones": self.acciones, "juicios": self.juicios, "precision": r(self.precision),
                "simulacros": self.simulacros, "reportes": self.reportes, "clics": self.clics,
                "ignorados": self.ignorados, "tasa_reporte": r(self.tasa_reporte),
                "clic_ajustado": r(self.clic_ajustado), "decisiones": self.decisiones,
                "verificaciones": self.verificaciones, "falsos_positivos": self.falsos_positivos,
                "mediana_segundos_reporte": r(self.mediana_segundos_reporte)}


def metricas(observaciones: list[Observacion], ahora: datetime, ventana_dias: int = VENTANA_DIAS,
             clic_esperado: dict | None = None) -> Metricas:
    """`clic_esperado`: tasa de clic esperada por plantilla (calibrada por
    `poblacion.py`); si falta, se usa la del nivel."""
    desde = ahora - timedelta(days=ventana_dias)
    obs = [o for o in observaciones if o.momento >= desde]
    c = dict(acciones=len(obs), juicios=0, aciertos=0, simulacros=0, reportes=0, clics=0, ignorados=0,
             decisiones=0, verificaciones=0, falsos_positivos=0, items_legitimos=0, clics_esperados=0.0)
    seg_reporte = []
    for o in obs:
        if o.es_juicio:
            c["juicios"] += 1
            c["aciertos"] += int(o.juicio_correcto)
        if o.es_reporte_tardio:
            # Segunda observación del mismo correo: suma el reporte (§11), no otro simulacro.
            c["reportes"] += 1
        elif o.tipo == "SIMULACRO":
            c["simulacros"] += 1
            esperado = (clic_esperado or {}).get(o.plantilla_id or "", CLIC_ESPERADO[o.nivel or 2])
            c["clics_esperados"] += esperado
            if o.resultado == "CLIC":
                c["clics"] += 1
            # Un CLIC con reporto_despues_de_clic (si llega en una sola observación)
            # también suma el reporte para el perfil (§11).
            if o.resultado == "REPORTO" or o.reporto_despues_de_clic:
                c["reportes"] += 1
                if o.resultado == "REPORTO" and o.segundos_hasta_reaccion is not None:
                    seg_reporte.append(o.segundos_hasta_reaccion)
            if o.resultado == "IGNORO":
                c["ignorados"] += 1
        elif o.tipo == "DECISION":
            c["decisiones"] += 1
            if o.es_estafa is False and o.acerto is False:
                # Marcó como estafa un correo real: prudencia, pero es un falso positivo.
                c["falsos_positivos"] += 1
            if o.es_estafa is False:
                c["items_legitimos"] += 1
        elif o.tipo == "VERIFICACION":
            c["verificaciones"] += 1
    ultima = max((o.momento for o in observaciones), default=None)
    return Metricas(**c, mediana_segundos_reporte=median(seg_reporte) if seg_reporte else None,
                    ultima_accion=ultima)


@dataclass(frozen=True)
class PerfilConducta:
    codigo: str
    motivo: str

    def a_json(self) -> dict:
        return {"codigo": self.codigo, "etiqueta": ETIQUETAS_PERFIL[self.codigo], "motivo": self.motivo}


def perfil_conducta(m: Metricas, tipos, ahora: datetime) -> PerfilConducta:
    """Reglas de CLAUDE.md §7 (umbrales de partida, se recalibran en el piloto)."""
    if m.acciones == 0 and m.ultima_accion is not None:
        return PerfilConducta("INACTIVO", "Sin acciones en los últimos 90 días.")
    if m.acciones < 5 or m.precision is None:
        return PerfilConducta("SIN_PERFIL", "Menos de 5 acciones en la ventana de 90 días.")
    p = m.precision
    if set(tipos) & INTERNOS and m.clics > 0:
        return PerfilConducta("EXPUESTO", "Hizo clic en un simulacro (colaborador).")
    if p < 0.6:
        return PerfilConducta("EXPUESTO", f"Precisión de {p:.0%}, por debajo del 60 %.")
    if m.reportes >= 1 and p >= 0.8:
        return PerfilConducta("CENTINELA", f"Reportó y su precisión es de {p:.0%}.")
    if m.verificaciones > 0 or m.reportes > 0:
        return PerfilConducta("PRUDENTE", f"Verifica o reporta y su precisión es de {p:.0%}.")
    # [SUPUESTO] §7 no define qué pasa con quien acierta pero nunca verifica ni reporta.
    return PerfilConducta("SIN_PERFIL", "Acierta, pero todavía no verifica ni reporta.")


@dataclass(frozen=True)
class Retencion:
    """Regla R4 (CLAUDE.md §9): la precisión a 60 días cae más de 15 puntos
    frente al día 0 → adelantar el siguiente refuerzo."""

    precision_inicial: float | None
    precision_reciente: float | None
    adelantar_refuerzo: bool

    def a_json(self) -> dict:
        def r(x):
            return None if x is None else round(x, 3)
        return {"precision_inicial": r(self.precision_inicial), "precision_reciente": r(self.precision_reciente),
                "adelantar_refuerzo": self.adelantar_refuerzo}


def retencion(observaciones: list[Observacion], ahora: datetime) -> Retencion:
    juicios = sorted((o for o in observaciones if o.es_juicio), key=lambda o: o.momento)
    if not juicios:
        return Retencion(None, None, False)
    inicio = juicios[0].momento
    base = [o for o in juicios if o.momento <= inicio + timedelta(days=14)]
    recientes = [o for o in juicios if o.momento >= ahora - timedelta(days=30)]

    def prec(lista):
        return sum(o.juicio_correcto for o in lista) / len(lista) if len(lista) >= 3 else None

    pi, pr = prec(base), prec(recientes)
    caida = (pi is not None and pr is not None and (ahora - inicio) >= timedelta(days=60) and pi - pr > 0.15)
    return Retencion(pi, pr, caida)
