"""Contrato de entrada, almacén SQLite y fachada."""
import json
from pathlib import Path

import pytest

from conftest import AHORA, PERSONA, decision, simulacro
from observador import Almacen, Observacion, ObservacionInvalida, Observador

CONTRATO = Path(__file__).resolve().parents[1] / "contrato"
BASE = {"id_seudonimo": PERSONA, "tipo": "SIMULACRO", "momento": "2026-11-26T10:00:00Z", "nivel": 2,
        "indicios": ["I6"], "resultado": "CLIC"}


@pytest.mark.parametrize("cambio, mensaje", [
    ({"id_seudonimo": "corto"}, "id_seudonimo"),
    ({"id_seudonimo": "ana.perez@correo.ec"}, "id_seudonimo"),  # nunca un correo
    ({"tipo": "OTRO"}, "tipo"),
    ({"indicios": ["I99"]}, "indicios"),
    ({"indicios": []}, "al menos un indicio"),
    ({"resultado": "ABRIO"}, "resultado"),  # no se miden aperturas
    ({"nivel": 4}, "nivel"),
    ({"tipologia": "EXT"}, "tipologia"),
    ({"tipos": ["EX9"]}, "tipos"),
    ({"rango_etario": "70"}, "rango_etario"),
    ({"segundos_hasta_reaccion": -1}, "negativo"),
    ({"momento": "ayer"}, "momento"),
])
def test_observaciones_invalidas(cambio, mensaje):
    with pytest.raises(ObservacionInvalida, match=mensaje):
        Observacion.desde_json({**BASE, **cambio})


def test_decision_y_verificacion_validan_sus_campos():
    with pytest.raises(ObservacionInvalida):
        Observacion.desde_json({"id_seudonimo": PERSONA, "tipo": "DECISION", "es_estafa": True, "indicios": []})
    with pytest.raises(ObservacionInvalida):
        Observacion.desde_json({"id_seudonimo": PERSONA, "tipo": "VERIFICACION", "semaforo": "AZUL"})


def test_ida_y_vuelta_json():
    o = simulacro("REPORTO", ["I6", "I1"], segundos=0)
    copia = Observacion.desde_json(json.loads(json.dumps(o.a_json())))
    assert copia == o
    assert copia.a_json()["segundos_hasta_reaccion"] == 0  # el 0 no se pierde
    assert "acerto" not in o.a_json()


def test_los_implicitos_no_repiten_los_declarados():
    o = Observacion.desde_json({**BASE, "indicios": ["I7", "I6"], "indicios_implicitos": ["I7", "I2"]})
    assert o.indicios_implicitos == ("I2",)


def test_ejemplos_del_contrato_son_validos():
    for archivo in sorted(CONTRATO.glob("observacion_*.json")):
        Observacion.desde_json(json.loads(archivo.read_text(encoding="utf-8")))


def test_almacen_en_archivo_y_derecho_de_eliminacion(tmp_path):
    alm = Almacen(tmp_path / "obs.db")
    otra = "persona-prueba-0002"
    alm.registrar([simulacro("CLIC", ["I6"]), decision(True), simulacro("CLIC", ["I1"], persona=otra)])
    assert len(alm.de_persona(PERSONA)) == 2
    assert set(alm.por_persona()) == {PERSONA, otra}
    assert alm.borrar_persona(PERSONA) == 2
    assert alm.de_persona(PERSONA) == []
    assert alm.contar() == {"observaciones": 1, "personas": 1, "sinteticas": 0}


def test_borrar_solo_lo_sintetico(catalogo):
    alm = Almacen()
    alm.registrar([simulacro("CLIC", ["I6"]), simulacro("CLIC", ["I6"], persona="sint-000000000000000a",
                                                         origen="sintetico")])
    assert alm.borrar_sinteticos() == 1
    assert alm.contar()["personas"] == 1


def test_un_lote_con_una_observacion_mala_no_guarda_nada(catalogo):
    obs = Observador(catalogo=catalogo, reloj=lambda: AHORA)
    with pytest.raises(ObservacionInvalida):
        obs.registrar([simulacro("CLIC", ["I6"]).a_json(), {**BASE, "indicios": ["I99"]}])
    assert obs.almacen.contar()["observaciones"] == 0


def test_fachada_plan_y_resumen(catalogo):
    obs = Observador(catalogo=catalogo, reloj=lambda: AHORA)
    assert obs.registrar([simulacro("CLIC", ["I8"]).a_json()]) == 1
    p = obs.plan(PERSONA)
    assert p["falencias"][0]["indicio"] in {"I8", "I7", "I2"}
    res = obs.resumen()
    assert res["almacen"]["observaciones"] == 1
    assert res["personas"] is None  # una sola persona: menos de k
    with pytest.raises(ObservacionInvalida):
        obs.plan("x")
