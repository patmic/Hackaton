"""Línea de comandos del observador.

    python -m observador simular [--personas 400] [--semilla 2026]
        Genera la población sintética, la analiza y muestra lo que aprendió.
    python -m observador plan ARCHIVO.json
        Lee una lista de observaciones (JSON) y muestra el plan de la persona.
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone

from .catalogo import CatalogoTipologias
from .observaciones import Observacion
from .plan import generar_plan
from .poblacion import ModeloPoblacion
from .sintetico import EXTRA_65, MEZCLA, VULNERABILIDAD, generar


def _vulnerabilidad_oculta(segmento: str) -> list[str]:
    """Indicios que la simulación hace más engañosos en el segmento (lo que el
    observador no ve). Quien tiene varios tipos suma los de todos."""
    tipo, rango = segmento.split("|")
    total: dict[str, float] = {}
    for tipos, _, peso in MEZCLA:
        if tipo in tipos:
            combinada: dict[str, float] = {}
            for t in tipos:
                for i, v in VULNERABILIDAD.get(t, {}).items():
                    combinada[i] = max(combinada.get(i, 0.0), v)
            for i, v in combinada.items():
                total[i] = total.get(i, 0.0) + peso * v  # ponderado por lo común de cada mezcla
    if rango == "65+":
        for i, v in EXTRA_65.items():
            total[i] = total.get(i, 0.0) + v
    return sorted(total, key=lambda i: -total[i])


def _simular(args) -> int:
    catalogo = CatalogoTipologias.cargar()
    ahora = datetime.now(timezone.utc)
    obs = generar(catalogo, personas=args.personas, semilla=args.semilla, ahora=ahora)
    por_persona: dict[str, list[Observacion]] = {}
    for o in obs:
        por_persona.setdefault(o.id_seudonimo, []).append(o)
    res = ModeloPoblacion.construir(por_persona, ahora).resumen(catalogo)
    print(f"Población sintética: {len(por_persona)} personas, {len(obs)} observaciones, "
          f"{res['simulacros']} correos de prueba.")
    print(f"Tasa de clic {res['tasa_clic']:.0%} · reporte {res['tasa_reporte']:.0%} · "
          f"clic ajustado por dificultad {res['clic_ajustado']:.2f}\n")
    print("Lo que el observador descubrió por segmento (k ≥ 10):")
    for s in res["segmentos"]:
        top = ", ".join(f"{f['codigo']} {f['tasa_engano']:.0%}" for f in s["indicios"][:3])
        verdad = ", ".join(_vulnerabilidad_oculta(s["segmento"])[:3])
        print(f"  {s['nombre']:<24} IRS {s['irs']!s:>3} · más engañan: {top:<28} (vulnerabilidad oculta: {verdad})")
    desfases = [c for c in res["calibracion"] if c["desfase"]]
    if desfases:
        print("\nPlantillas cuya dificultad real no coincide con la nominal:")
        for c in desfases:
            print(f"  {c['plantilla_id']}: nivel {c['nivel_nominal']} → se comporta como {c['nivel_efectivo']} "
                  f"(clic {c['tasa_clic']:.0%})")
    return 0


def _plan(args) -> int:
    datos = json.loads(open(args.archivo, encoding="utf-8").read())
    obs = [Observacion.desde_json(d) for d in (datos if isinstance(datos, list) else datos["observaciones"])]
    if not obs:
        print("El archivo no tiene observaciones.", file=sys.stderr)
        return 1
    plan = generar_plan(obs[0].id_seudonimo, obs, datetime.now(timezone.utc), CatalogoTipologias.cargar())
    print(json.dumps(plan, ensure_ascii=False, indent=2))
    return 0


def main(argv=None) -> int:
    p = argparse.ArgumentParser(prog="python -m observador", description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("simular", help="población sintética y lo que aprende el observador")
    s.add_argument("--personas", type=int, default=400)
    s.add_argument("--semilla", type=int, default=2026)
    s.set_defaults(fn=_simular)
    pl = sub.add_parser("plan", help="plan de una persona a partir de un JSON de observaciones")
    pl.add_argument("archivo")
    pl.set_defaults(fn=_plan)
    args = p.parse_args(argv)
    return args.fn(args)


if __name__ == "__main__":
    raise SystemExit(main())
