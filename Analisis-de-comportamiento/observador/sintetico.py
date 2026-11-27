"""Población sintética para la demo del Observatorio. Todo es inventado.

Cada persona ficticia tiene una «vulnerabilidad verdadera» por indicio que el
observador **no conoce**: depende de su segmento (por ejemplo, la amenaza sobre
la pensión, I8, engaña más a jubilados de 65+) y de un poco de azar. La
simulación le envía correos de prueba de `datos/plantillas.json`, eligiendo
cada siguiente correo con el propio plan del observador, y registra cómo
reacciona. Al final, el Observatorio debería «descubrir» esas
vulnerabilidades solo con lo observado: es la prueba de que aprende.

Las observaciones quedan con `origen = "sintetico"` y se pueden borrar.
"""
from __future__ import annotations

import hashlib
import json
import math
import random
from datetime import datetime, timedelta, timezone
from pathlib import Path

from .catalogo import CatalogoTipologias
from .observaciones import Observacion
from .plan import elegir_plantilla, generar_plan

RUTA_PLANTILLAS = Path(__file__).resolve().parents[1] / "datos" / "plantillas.json"

# Probabilidad base de hacer clic según el nivel del correo [SUPUESTO].
CLIC_BASE = {1: 0.03, 2: 0.08, 3: 0.15}
# En un correo obvio (nivel 1) las señales saltan a la vista: la vulnerabilidad
# de la persona pesa menos que en uno sutil.
PESO_VULNERABILIDAD = {1: 0.4, 2: 1.0, 3: 1.0}

# Vulnerabilidades por segmento: indicio -> probabilidad extra de caer [SUPUESTO,
# inspirado en el «ataque típico» de CLAUDE.md §7].
VULNERABILIDAD = {
    "EX1": {"I6": 0.24, "I10": 0.10, "I1": 0.06},
    "EX2": {"I8": 0.30, "I9": 0.14, "I1": 0.12},
    "EX3": {"I10": 0.24, "I8": 0.12},
    "EX4": {"I5": 0.26, "I1": 0.06},
    "EX5": {"I11": 0.26, "I9": 0.10},
    "IN1": {"I3": 0.30, "I5": 0.16, "I4": 0.12},
}
EXTRA_65 = {"I8": 0.08, "I11": 0.08, "I1": 0.04}

# Mezcla de la población ficticia: (tipos, rangos posibles, peso).
MEZCLA = [
    (("EX1",), ("18-29", "30-49", "50-64"), 38),
    (("EX2",), ("65+", "65+", "50-64"), 22),
    (("EX3",), ("30-49", "50-64"), 10),
    (("EX4",), ("30-49", "50-64"), 8),
    (("EX5",), ("18-29", "30-49", "65+"), 10),
    (("EX1", "IN1"), ("30-49", "50-64"), 12),
]


def cargar_plantillas(ruta: str | Path = RUTA_PLANTILLAS) -> list[dict]:
    return json.loads(Path(ruta).read_text(encoding="utf-8"))["plantillas"]


def _id(semilla: int, n: int) -> str:
    return "sint-" + hashlib.sha256(f"{semilla}:{n}".encode()).hexdigest()[:20]


def generar(catalogo: CatalogoTipologias, *, personas: int = 400, semilla: int = 2026,
            ahora: datetime | None = None, plantillas: list[dict] | None = None) -> list[Observacion]:
    rnd = random.Random(semilla)
    ahora = ahora or datetime.now(timezone.utc)
    plantillas = plantillas or cargar_plantillas()
    pesos = [m[2] for m in MEZCLA]
    resultado: list[Observacion] = []

    for n in range(personas):
        tipos, rangos, _ = rnd.choices(MEZCLA, weights=pesos)[0]
        rango = rnd.choice(rangos)
        ident = _id(semilla, n)
        vuln: dict[str, float] = {}
        for t in tipos:
            for i, v in VULNERABILIDAD.get(t, {}).items():
                vuln[i] = max(vuln.get(i, 0.0), v)
        if rango == "65+":
            for i, v in EXTRA_65.items():
                vuln[i] = vuln.get(i, 0.0) + v
        atencion = rnd.uniform(-0.03, 0.05)       # cuánto se distrae esta persona
        reporta = rnd.uniform(0.25, 0.75)         # hábito de reportar
        base = {"id_seudonimo": ident, "tipos": list(tipos), "rango_etario": rango, "origen": "sintetico"}

        historial: list[Observacion] = []
        momento = ahora - timedelta(days=rnd.uniform(70, 88))
        enviadas: list[str] = []
        for _ in range(rnd.randint(2, 5)):
            plan = generar_plan(ident, historial, momento, catalogo, tipos=tipos, rango_etario=rango)
            candidatas = [p for p in plantillas if set(p["tipos"]) & set(tipos)]
            pid = elegir_plantilla(plan, candidatas, enviadas)
            p = next(x for x in plantillas if x["id"] == pid)
            enviadas.append(pid)
            peor = max((vuln.get(i, 0.0) for i in p["indicios"]), default=0.0)
            p_clic = CLIC_BASE[p["nivel"]] + atencion + PESO_VULNERABILIDAD[p["nivel"]] * peor
            p_clic = min(0.9, max(0.02, p_clic))
            if rnd.random() < p_clic:
                resultado_sim, seg = "CLIC", rnd.lognormvariate(math.log(180), 0.8)
                # Tras el momento enseñable aprende: baja su vulnerabilidad a esos indicios.
                for i in p["indicios"]:
                    vuln[i] = vuln.get(i, 0.0) * 0.55
            elif rnd.random() < reporta + (0.15 if p["nivel"] == 1 else 0.0):
                resultado_sim, seg = "REPORTO", rnd.lognormvariate(math.log(1200), 0.9)
            else:
                resultado_sim, seg = "IGNORO", None
            obs = Observacion.desde_json({
                **base, "tipo": "SIMULACRO", "momento": momento.isoformat(), "plantilla_id": pid,
                "nivel": p["nivel"], "tipologia": p["tipologia"], "indicios": p["indicios"],
                "indicios_implicitos": p["indicios_implicitos"], "resultado": resultado_sim,
                "segundos_hasta_reaccion": seg,
                "reporto_despues_de_clic": resultado_sim == "CLIC" and rnd.random() < 0.2,
            })
            historial.append(obs)
            # Entre correo y correo, algo de práctica en la app.
            for _ in range(rnd.randint(0, 4)):
                momento_d = momento + timedelta(days=rnd.uniform(0.5, 6))
                indicios = rnd.sample(list(vuln) or ["I1", "I7"], k=min(2, len(vuln) or 2))
                es_estafa = rnd.random() < 0.75
                p_ok = 0.85 - (max(vuln.get(i, 0.0) for i in indicios) if es_estafa else 0.1)
                historial.append(Observacion.desde_json({
                    **base, "tipo": "DECISION", "momento": momento_d.isoformat(), "actividad_id": "M1-A2-01",
                    "item_id": f"tarjeta-{rnd.randint(1, 5)}", "es_estafa": es_estafa,
                    "indicios": indicios if es_estafa else [], "acerto": rnd.random() < p_ok,
                }))
            if rnd.random() < 0.4:
                historial.append(Observacion.desde_json({
                    **base, "tipo": "VERIFICACION", "semaforo": rnd.choice(["VERDE", "ROJO", "AMARILLO"]),
                    "momento": (momento + timedelta(days=rnd.uniform(1, 8))).isoformat(),
                }))
            momento += timedelta(days=rnd.uniform(9, 20))
            if momento >= ahora:
                break
        resultado.extend(o for o in historial if o.momento <= ahora)
    return resultado
