"""Aprendizaje colectivo: k-anonimato, priors por segmento y calibración."""
from collections import defaultdict

import pytest

from conftest import AHORA, simulacro
from observador.modelo import CLIC_ESPERADO
from observador.poblacion import K_ANONIMATO, ModeloPoblacion, nivel_efectivo
from observador.sintetico import generar


def poblacion(personas: int, resultado_por_persona, indicios=("I8",), tipos=("EX2",), rango="65+",
              plantilla="N2-EX2-pension", nivel=2):
    por_persona = {}
    for n in range(personas):
        pid = f"persona-segmento-{n:04d}"
        por_persona[pid] = [simulacro(resultado_por_persona(n), indicios, persona=pid, tipos=tipos, rango=rango,
                                      plantilla=plantilla, nivel=nivel)]
    return ModeloPoblacion.construir(por_persona, AHORA)


def test_ninguna_celda_con_menos_de_k_personas_se_publica(catalogo):
    chica = poblacion(K_ANONIMATO - 1, lambda n: "CLIC").resumen(catalogo)
    assert chica["personas"] is None
    assert chica["indicios"] == [] and chica["segmentos"] == []
    assert all(c["tasa_clic"] is None for c in chica["calibracion"])
    grande = poblacion(K_ANONIMATO, lambda n: "CLIC").resumen(catalogo)
    assert grande["personas"] == K_ANONIMATO
    assert grande["segmentos"][0]["segmento"] == "EX2|65+"


def test_el_resumen_no_lleva_identificadores(catalogo):
    texto = str(poblacion(12, lambda n: "CLIC").resumen(catalogo))
    assert "persona-segmento" not in texto


def test_prior_del_segmento(catalogo):
    # 3 de cada 4 jubilados de 65+ cayeron con I8: reconocerlo vale 0,25.
    m = poblacion(20, lambda n: "CLIC" if n % 4 else "REPORTO")
    assert m.prior_deteccion("I8", ["EX2"], "65+") == pytest.approx(0.25)
    # Otro segmento sin datos usa el total.
    assert m.prior_deteccion("I8", ["EX1"], "18-29") == pytest.approx(0.25)
    # Un indicio sin exposiciones: sin prior.
    assert m.prior_deteccion("I11", ["EX2"], "65+") is None


def test_calibracion_detecta_una_plantilla_mas_dificil_que_su_nivel(catalogo):
    m = poblacion(40, lambda n: "CLIC" if n % 2 else "IGNORO", plantilla="N1-EX-premio", nivel=1)
    fila = next(c for c in m.calibracion() if c["plantilla_id"] == "N1-EX-premio")
    assert fila["tasa_clic"] == 0.5
    assert fila["nivel_efectivo"] == 3 and fila["desfase"] is True


def test_cortes_de_nivel_efectivo():
    assert nivel_efectivo(CLIC_ESPERADO[1]) == 1
    assert nivel_efectivo(CLIC_ESPERADO[2]) == 2
    assert nivel_efectivo(CLIC_ESPERADO[3]) == 3


def test_el_observador_descubre_las_vulnerabilidades_ocultas(catalogo):
    """La población sintética esconde qué indicio engaña más a cada segmento.
    El observador no lo sabe: debe encontrarlo solo con lo observado."""
    obs = generar(catalogo, personas=400, semilla=7, ahora=AHORA)
    por_persona = defaultdict(list)
    for o in obs:
        por_persona[o.id_seudonimo].append(o)
    res = ModeloPoblacion.construir(por_persona, AHORA).resumen(catalogo)
    top = {s["segmento"]: [f["codigo"] for f in s["indicios"][:3]] for s in res["segmentos"]}
    assert "I8" in top["EX2|65+"] or "I9" in top["EX2|65+"]
    assert top["EX4|50-64"][0] == "I5" or top["EX4|30-49"][0] == "I5"
    assert any(t[0] == "I6" for s, t in top.items() if s.startswith("EX1|"))
    assert 0.1 < res["tasa_clic"] < 0.35  # en el rango de Ho et al. (1,8 % a 30,8 %)
    assert res["personas_sinteticas"] == 400
