import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

import pytest

RAIZ = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RAIZ))

from observador import CatalogoTipologias, Observacion  # noqa: E402

AHORA = datetime(2026, 11, 26, 12, 0, tzinfo=timezone.utc)
PERSONA = "persona-prueba-0001"


@pytest.fixture(scope="session")
def catalogo() -> CatalogoTipologias:
    return CatalogoTipologias.cargar()


def simulacro(resultado: str, indicios, *, nivel: int = 2, dias: float = 1, persona: str = PERSONA,
              tipologia: str = "T2", implicitos=("I7", "I2"), tipos=("EX1",), rango="30-49",
              plantilla: str = "N2-EX1-reembolso", segundos: float | None = 300, origen=None) -> Observacion:
    return Observacion.desde_json({
        "id_seudonimo": persona, "tipo": "SIMULACRO", "momento": (AHORA - timedelta(days=dias)).isoformat(),
        "plantilla_id": plantilla, "nivel": nivel, "tipologia": tipologia, "indicios": list(indicios),
        "indicios_implicitos": list(implicitos), "resultado": resultado, "segundos_hasta_reaccion": segundos,
        "tipos": list(tipos), "rango_etario": rango,
    }, origen=origen)


def decision(acerto: bool, indicios=("I1",), *, es_estafa: bool = True, dias: float = 1,
             persona: str = PERSONA, tipos=("EX1",)) -> Observacion:
    return Observacion.desde_json({
        "id_seudonimo": persona, "tipo": "DECISION", "momento": (AHORA - timedelta(days=dias)).isoformat(),
        "actividad_id": "M1-A2-01", "item_id": "t1", "es_estafa": es_estafa,
        "indicios": list(indicios) if es_estafa else [], "acerto": acerto, "tipos": list(tipos),
    })


def verificacion(dias: float = 1, persona: str = PERSONA, semaforo: str = "ROJO") -> Observacion:
    return Observacion.desde_json({
        "id_seudonimo": persona, "tipo": "VERIFICACION", "semaforo": semaforo,
        "momento": (AHORA - timedelta(days=dias)).isoformat(), "tipos": ["EX1"],
    })
