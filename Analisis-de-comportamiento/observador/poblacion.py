"""Lo que el observador aprende de **todas** las personas (inteligencia colectiva).

1. **Por segmento** (tipo de usuario × rango de edad): qué indicios y qué
   tipologías engañan más. Sirve de punto de partida para una persona nueva de
   ese segmento (arranque en frío) y alimenta el Observatorio (§8, §9).
2. **Por plantilla**: la tasa de clic real de cada correo de prueba. Si una
   plantilla «de nivel 2» engaña como una de nivel 3, se recalibra su
   dificultad (idea de la NIST Phish Scale). Así la escalera y el clic ajustado
   comparan con la dificultad real y no con la nominal.

Privacidad (CLAUDE.md, reglas 3 y 6): aquí solo hay conteos. Ninguna celda con
menos de `K_ANONIMATO` personas distintas sale del módulo ni se usa como prior.
"""
from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timedelta

from .catalogo import INDICIOS, RANGOS_ETARIOS, TIPOS_USUARIO, CatalogoTipologias
from .modelo import CLIC_ESPERADO, ETIQUETAS_PERFIL, VENTANA_DIAS, metricas, perfil_conducta
from .observaciones import Observacion

K_ANONIMATO = 10
EXPOSICIONES_MINIMAS = 5     # para usar una tasa como prior
FUERZA_PRIOR_PLANTILLA = 10  # pseudo-envíos del prior por nivel


@dataclass
class Celda:
    """Conteos de un grupo. `personas` se usa solo para el umbral k y se
    descarta al publicar."""

    personas: set = field(default_factory=set)
    exposiciones: int = 0
    clics: int = 0
    reportes: int = 0

    def sumar(self, persona: str, resultado: str) -> None:
        self.personas.add(persona)
        self.exposiciones += 1
        self.clics += resultado == "CLIC"
        self.reportes += resultado == "REPORTO"

    @property
    def publicable(self) -> bool:
        return len(self.personas) >= K_ANONIMATO

    @property
    def tasa_engano(self) -> float | None:
        return self.clics / self.exposiciones if self.exposiciones else None

    @property
    def tasa_reporte(self) -> float | None:
        return self.reportes / self.exposiciones if self.exposiciones else None


def nivel_efectivo(tasa_clic: float) -> int:
    """Nivel al que se parece una tasa de clic: el corte entre dos niveles es
    el punto medio de sus tasas esperadas (`CLIC_ESPERADO`)."""
    corte_12 = (CLIC_ESPERADO[1] + CLIC_ESPERADO[2]) / 2
    corte_23 = (CLIC_ESPERADO[2] + CLIC_ESPERADO[3]) / 2
    return 1 if tasa_clic < corte_12 else 2 if tasa_clic < corte_23 else 3


def segmentos_de(tipos, rango) -> list[str]:
    """Una persona con varios tipos (un colaborador suele ser también
    afiliado) aporta a cada segmento de sus tipos."""
    r = rango or "sin-rango"
    return [f"{t}|{r}" for t in tipos] or [f"EX5|{r}"]


def nombre_segmento(clave: str) -> str:
    tipo, rango = clave.split("|")
    return f"{tipo} · {rango if rango != 'sin-rango' else 'rango no informado'}"


@dataclass
class ModeloPoblacion:
    ahora: datetime
    personas: int = 0
    por_indicio: dict = field(default_factory=lambda: defaultdict(Celda))          # (segmento|*, indicio)
    por_tipologia: dict = field(default_factory=lambda: defaultdict(Celda))        # (segmento|*, tipologia)
    por_plantilla: dict = field(default_factory=lambda: defaultdict(Celda))        # plantilla_id
    por_segmento: dict = field(default_factory=lambda: defaultdict(Celda))         # segmento (1 por simulacro)
    nivel_plantilla: dict = field(default_factory=dict)
    perfiles: dict = field(default_factory=lambda: defaultdict(set))               # perfil -> personas
    precisiones: dict = field(default_factory=lambda: defaultdict(list))           # segmento -> [precisión]
    reporte_seg: list = field(default_factory=list)
    falsos_positivos: int = 0
    decisiones_legitimas: int = 0
    sinteticas: int = 0

    # -------------------------------------------------------------- construcción
    @classmethod
    def construir(cls, por_persona: dict[str, list[Observacion]], ahora: datetime) -> "ModeloPoblacion":
        m = cls(ahora=ahora)
        desde = ahora - timedelta(days=VENTANA_DIAS)
        for persona, obs in por_persona.items():
            if not obs:
                continue
            m.personas += 1
            ultima = max(obs, key=lambda o: o.momento)
            m.sinteticas += ultima.origen == "sintetico"
            segs = segmentos_de(ultima.tipos, ultima.rango_etario)
            met = metricas(obs, ahora)
            m.perfiles[perfil_conducta(met, ultima.tipos, ahora).codigo].add(persona)
            if met.precision is not None:
                for s in segs:
                    m.precisiones[s].append(met.precision)
            m.falsos_positivos += met.falsos_positivos
            m.decisiones_legitimas += met.items_legitimos
            for o in obs:
                if o.momento < desde or o.tipo != "SIMULACRO" or o.es_reporte_tardio:
                    continue
                if o.resultado == "REPORTO" and o.segundos_hasta_reaccion is not None:
                    m.reporte_seg.append(o.segundos_hasta_reaccion)
                if o.plantilla_id:
                    m.por_plantilla[o.plantilla_id].sumar(persona, o.resultado)
                    m.nivel_plantilla[o.plantilla_id] = o.nivel
                for s in segs:
                    m.por_segmento[s].sumar(persona, o.resultado)
                for s in [*segs, "*"]:
                    for i in o.indicios:
                        m.por_indicio[(s, i)].sumar(persona, o.resultado)
                    if o.tipologia:
                        m.por_tipologia[(s, o.tipologia)].sumar(persona, o.resultado)
        return m

    # -------------------------------------------------------------- priors (arranque en frío)
    def prior_deteccion(self, indicio: str, tipos, rango) -> float | None:
        """Probabilidad de reconocer el indicio en el segmento de la persona:
        1 − tasa de engaño. Solo con celdas publicables; si no, el total; si
        tampoco, None (la persona arranca neutral)."""
        tasas = []
        for s in segmentos_de(tipos, rango):
            c = self.por_indicio.get((s, indicio))
            if c and c.publicable and c.exposiciones >= EXPOSICIONES_MINIMAS:
                tasas.append(1 - c.tasa_engano)
        if tasas:
            return sum(tasas) / len(tasas)
        c = self.por_indicio.get(("*", indicio))
        if c and c.publicable and c.exposiciones >= EXPOSICIONES_MINIMAS:
            return 1 - c.tasa_engano
        return None

    # -------------------------------------------------------------- calibración de plantillas
    def clic_esperado_por_plantilla(self) -> dict[str, float]:
        """Tasa de clic esperada de cada plantilla: el prior de su nivel
        corregido con lo observado (Beta con `FUERZA_PRIOR_PLANTILLA`)."""
        res = {}
        for pid, c in self.por_plantilla.items():
            prior = CLIC_ESPERADO.get(self.nivel_plantilla.get(pid, 2), 0.25)
            res[pid] = (prior * FUERZA_PRIOR_PLANTILLA + c.clics) / (FUERZA_PRIOR_PLANTILLA + c.exposiciones)
        return res

    def calibracion(self) -> list[dict]:
        esperado = self.clic_esperado_por_plantilla()
        filas = []
        for pid, c in sorted(self.por_plantilla.items()):
            nominal = self.nivel_plantilla.get(pid, 2)
            tasa = esperado[pid]
            efectivo = nivel_efectivo(tasa)
            filas.append({
                "plantilla_id": pid, "nivel_nominal": nominal,
                "envios": c.exposiciones if c.publicable else None,
                "tasa_clic": round(c.tasa_engano, 3) if c.publicable else None,
                "tasa_reporte": round(c.tasa_reporte, 3) if c.publicable else None,
                "clic_esperado_calibrado": round(tasa, 3),
                "nivel_efectivo": efectivo if c.publicable else None,
                "desfase": c.publicable and efectivo != nominal,
            })
        return filas

    # -------------------------------------------------------------- resumen para el Observatorio
    def _tabla(self, celdas: dict, segmento: str, claves, nombres) -> list[dict]:
        filas = []
        for k in claves:
            c = celdas.get((segmento, k))
            if not c or not c.publicable:
                continue
            filas.append({"codigo": k, "nombre": nombres(k), "personas": len(c.personas),
                          "exposiciones": c.exposiciones, "tasa_engano": round(c.tasa_engano, 3),
                          "tasa_reporte": round(c.tasa_reporte, 3)})
        return sorted(filas, key=lambda f: (-f["tasa_engano"], f["codigo"]))

    def resumen(self, catalogo: CatalogoTipologias) -> dict:
        global_i = self.por_indicio
        sims = sum(c.exposiciones for c in self.por_plantilla.values())
        clics = sum(c.clics for c in self.por_plantilla.values())
        reportes = sum(c.reportes for c in self.por_plantilla.values())
        # Contra la dificultad nominal: con la calibrada el total daría 1 por construcción.
        clics_esp = sum(CLIC_ESPERADO.get(self.nivel_plantilla.get(p, 2), 0.25) * c.exposiciones
                        for p, c in self.por_plantilla.items())
        reporte_seg = sorted(self.reporte_seg)
        mediana = reporte_seg[len(reporte_seg) // 2] if reporte_seg else None

        segmentos = []
        claves_seg = sorted({s for (s, _) in global_i if s != "*"},
                            key=lambda s: (TIPOS_USUARIO.index(s.split("|")[0]),
                                           (RANGOS_ETARIOS + ("sin-rango",)).index(s.split("|")[1])))
        for s in claves_seg:
            indicios = self._tabla(global_i, s, INDICIOS, INDICIOS.get)
            if not indicios:
                continue  # segmento con menos de k personas: no se muestra
            tipologias = self._tabla(self.por_tipologia, s, catalogo.tipologias, catalogo.nombre)
            precs = self.precisiones.get(s, [])
            prec = sum(precs) / len(precs) if len(precs) >= K_ANONIMATO else None
            celda = self.por_segmento[s]
            rep = celda.tasa_reporte
            fp = self.falsos_positivos / self.decisiones_legitimas if self.decisiones_legitimas else 0.0
            # [SUPUESTO] IRS (§8.2) con los componentes disponibles: precisión,
            # reporte y 1 − falsos positivos (la tasa de verificación necesita
            # saber cuántos correos oficiales recibió cada persona).
            componentes = [x for x in (prec, rep, 1 - fp) if x is not None]
            irs = round(100 * sum(componentes) / len(componentes)) if componentes else None
            segmentos.append({
                "segmento": s, "nombre": nombre_segmento(s),
                "personas": len(celda.personas),
                "irs": irs, "indicios": indicios[:5], "tipologias": tipologias[:3],
                "recomendacion": self._recomendacion(s, indicios, tipologias, catalogo),
            })

        perfiles = []
        for codigo, personas in self.perfiles.items():
            n = len(personas)
            perfiles.append({"codigo": codigo, "etiqueta": ETIQUETAS_PERFIL[codigo],
                             "personas": n if n >= K_ANONIMATO else None})
        orden = list(ETIQUETAS_PERFIL)
        perfiles.sort(key=lambda p: orden.index(p["codigo"]))

        def r(x):
            return None if x is None else round(x, 3)
        return {
            "generado_en": self.ahora.isoformat().replace("+00:00", "Z"),
            "k_anonimato": K_ANONIMATO,
            "ventana_dias": VENTANA_DIAS,
            "personas": self.personas if self.personas >= K_ANONIMATO else None,
            "personas_sinteticas": self.sinteticas,
            "simulacros": sims,
            "tasa_clic": r(clics / sims) if sims else None,
            "tasa_reporte": r(reportes / sims) if sims else None,
            "clic_ajustado": r(clics / clics_esp) if clics_esp else None,
            "mediana_minutos_reporte": r(mediana / 60) if mediana is not None else None,
            "indicios": self._tabla(global_i, "*", INDICIOS, INDICIOS.get),
            "tipologias": self._tabla(self.por_tipologia, "*", catalogo.tipologias, catalogo.nombre),
            "segmentos": segmentos,
            "perfiles": perfiles,
            "calibracion": self.calibracion(),
        }

    @staticmethod
    def _recomendacion(segmento: str, indicios: list[dict], tipologias: list[dict],
                       catalogo: CatalogoTipologias) -> str:
        """Acción para el segmento (reglas R1 y R2 de §9, sin disparo masivo:
        un IN3 aprueba cualquier campaña)."""
        top = indicios[0]
        texto = (f"«{top['nombre']}» engaña al {top['tasa_engano']:.0%} de este segmento: "
                 f"priorizar su microcurso")
        if tipologias:
            texto += f" y correos de práctica que suplanten «{catalogo.nombre(tipologias[0]['codigo'])}»"
        return texto + "."
