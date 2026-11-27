"""El ejemplo de plan del contrato se genera con el modelo real.

La app Flutter lo lee en sus pruebas (`PlanPersonalizado.fromJson`), así que un
cambio de forma en el plan rompe primero aquí. Para regenerarlo:
`ACTUALIZAR_CONTRATO=1 python -m pytest tests/test_contrato.py`.
"""
import json
import os
from pathlib import Path

from conftest import AHORA
from observador import Observacion
from observador.plan import generar_plan

CONTRATO = Path(__file__).resolve().parents[1] / "contrato"


def test_plan_ejemplo_al_dia(catalogo):
    obs = [Observacion.desde_json(json.loads((CONTRATO / f"observacion_{n}.json").read_text(encoding="utf-8")))
           for n in ("simulacro", "decision", "verificacion")]
    plan = generar_plan(obs[0].id_seudonimo, obs, AHORA.replace(hour=18), catalogo)
    texto = json.dumps(plan, ensure_ascii=False, indent=2) + "\n"
    archivo = CONTRATO / "plan.ejemplo.json"
    if os.environ.get("ACTUALIZAR_CONTRATO"):
        archivo.write_text(texto, encoding="utf-8")
    assert json.loads(archivo.read_text(encoding="utf-8")) == json.loads(texto), (
        "El plan cambió de forma: regenere contrato/plan.ejemplo.json y revise el cliente de la app.")
