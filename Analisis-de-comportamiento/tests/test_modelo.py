"""Modelo de una persona: mapa de indicios, olvido, métricas y perfil (§7, §8)."""
from datetime import timedelta

import pytest

from conftest import AHORA, decision, simulacro, verificacion
from observador.modelo import (
    PESO_ACIERTO,
    VIDA_MEDIA_DIAS,
    estados_indicios,
    evidencia_por_indicio,
    metricas,
    perfil_conducta,
    retencion,
)


def estado(obs, indicio):
    return estados_indicios(obs, AHORA)[indicio].estado


# ---------------------------------------------------------------- reglas [DECIDIDO] del mapa (§8.2)
def test_reporto_deja_dominado_y_clic_deja_debil():
    assert estado([simulacro("REPORTO", ["I6", "I1"])], "I6") == "DOMINADO"
    assert estado([simulacro("CLIC", ["I6", "I1"])], "I6") == "DEBIL"


def test_ignoro_no_cambia_nada():
    assert estado([simulacro("IGNORO", ["I6"])], "I6") == "SIN_PROBAR"


def test_lo_no_visto_queda_sin_probar():
    assert estado([simulacro("REPORTO", ["I6"])], "I11") == "SIN_PROBAR"


def test_reportar_despues_de_un_clic_sigue_para_practicar():
    obs = [simulacro("CLIC", ["I8"], dias=2), simulacro("REPORTO", ["I8"], dias=1)]
    assert estado(obs, "I8") == "DEBIL"


def test_reporte_tardio_como_segunda_observacion():
    """La API de Capacitación manda el clic y, si después reenvía el correo,
    una segunda observación REPORTO con reporto_despues_de_clic."""
    from observador import Observacion

    clic = simulacro("CLIC", ["I8"], dias=1)
    tardio = Observacion.desde_json({**simulacro("REPORTO", ["I8"], dias=0.5).a_json(),
                                     "reporto_despues_de_clic": True})
    assert tardio.es_reporte_tardio and not tardio.es_juicio
    obs = [clic, tardio]
    assert estado(obs, "I8") == "DEBIL"  # no demuestra que reconoció el indicio
    m = metricas(obs, AHORA)
    assert (m.simulacros, m.clics, m.reportes, m.juicios) == (1, 1, 1, 1)


@pytest.mark.parametrize("nivel", [1, 2, 3])
def test_un_reporte_basta_para_dominar_en_cualquier_nivel(nivel):
    assert estado([simulacro("REPORTO", ["I4"], nivel=nivel)], "I4") == "DOMINADO"


def test_los_implicitos_cuentan_con_menos_peso_pero_en_la_misma_direccion():
    obs = [simulacro("REPORTO", ["I5"], nivel=1, implicitos=["I7", "I2"])]
    ev = evidencia_por_indicio(obs, AHORA)
    assert ev["I7"].acierto == pytest.approx(ev["I5"].acierto / 2, rel=1e-3)
    assert estado(obs, "I7") == "DOMINADO"
    obs = [simulacro("CLIC", ["I5"], nivel=1)]
    assert estado(obs, "I7") == "DEBIL"


# ---------------------------------------------------------------- dificultad
def test_reportar_un_correo_dificil_dice_mas_que_uno_facil():
    facil = evidencia_por_indicio([simulacro("REPORTO", ["I4"], nivel=1, dias=0)], AHORA)["I4"]
    dificil = evidencia_por_indicio([simulacro("REPORTO", ["I4"], nivel=3, dias=0)], AHORA)["I4"]
    assert dificil.acierto > facil.acierto
    assert dificil.acierto == pytest.approx(PESO_ACIERTO[3], rel=1e-3)


def test_caer_en_un_correo_obvio_dice_mas_que_caer_en_uno_sutil():
    facil = evidencia_por_indicio([simulacro("CLIC", ["I4"], nivel=1)], AHORA)["I4"]
    dificil = evidencia_por_indicio([simulacro("CLIC", ["I4"], nivel=3)], AHORA)["I4"]
    assert facil.fallo > dificil.fallo


def test_practicar_en_la_app_pesa_menos_que_la_conducta_real():
    app = evidencia_por_indicio([decision(False, ["I3"])], AHORA)["I3"]
    real = evidencia_por_indicio([simulacro("CLIC", ["I3"])], AHORA)["I3"]
    assert app.fallo < real.fallo


def test_un_correo_legitimo_bien_juzgado_no_deja_evidencia_de_indicios():
    ev = evidencia_por_indicio([decision(True, es_estafa=False)], AHORA)
    assert all(e.total == 0 for e in ev.values())


# ---------------------------------------------------------------- olvido
def test_la_evidencia_pierde_la_mitad_cada_vida_media():
    hoy = evidencia_por_indicio([simulacro("REPORTO", ["I1"], dias=0)], AHORA)["I1"].acierto
    vieja = evidencia_por_indicio([simulacro("REPORTO", ["I1"], dias=VIDA_MEDIA_DIAS)], AHORA)["I1"].acierto
    assert vieja == pytest.approx(hoy / 2, rel=1e-3)


def test_lo_dominado_hace_mucho_vuelve_a_repaso():
    e = estados_indicios([simulacro("REPORTO", ["I6"], dias=75)], AHORA)["I6"]
    assert e.repasar is True
    e = estados_indicios([simulacro("REPORTO", ["I6"], dias=5)], AHORA)["I6"]
    assert e.repasar is False


def test_lo_reciente_pesa_mas_que_lo_viejo():
    # Cayó hace 4 meses, pero reportó la semana pasada: hoy lo reconoce.
    obs = [simulacro("CLIC", ["I8"], dias=120), simulacro("REPORTO", ["I8"], dias=7)]
    assert estado(obs, "I8") == "DOMINADO"


# ---------------------------------------------------------------- métricas
def test_metricas_basicas_y_clic_ajustado():
    obs = [simulacro("CLIC", ["I1"], nivel=1, dias=10), simulacro("REPORTO", ["I1"], nivel=2, dias=5, segundos=600),
           simulacro("IGNORO", ["I1"], nivel=3, dias=3), decision(True), verificacion()]
    m = metricas(obs, AHORA)
    assert (m.simulacros, m.clics, m.reportes, m.ignorados) == (3, 1, 1, 1)
    assert m.juicios == 3 and m.precision == pytest.approx(2 / 3)
    assert m.verificaciones == 1
    assert m.mediana_segundos_reporte == 600
    # Esperados con la dificultad nominal: 0.08 + 0.18 + 0.30
    assert m.clic_ajustado == pytest.approx(1 / 0.56, rel=1e-3)


def test_la_ventana_es_de_90_dias():
    m = metricas([simulacro("CLIC", ["I1"], dias=120), decision(True)], AHORA)
    assert m.simulacros == 0 and m.acciones == 1


def test_marcar_como_estafa_un_correo_real_es_falso_positivo():
    m = metricas([decision(False, es_estafa=False)], AHORA)
    assert m.falsos_positivos == 1


# ---------------------------------------------------------------- perfil de conducta (§7)
def test_menos_de_cinco_acciones_sin_perfil():
    m = metricas([decision(True)] * 4, AHORA)
    assert perfil_conducta(m, ["EX1"], AHORA).codigo == "SIN_PERFIL"


def test_centinela_prudente_y_en_aprendizaje():
    centinela = [simulacro("REPORTO", ["I1"], dias=d) for d in (1, 2)] + [decision(True)] * 4
    assert perfil_conducta(metricas(centinela, AHORA), ["EX1"], AHORA).codigo == "CENTINELA"
    prudente = [verificacion()] + [decision(True)] * 3 + [decision(False)] + [decision(True)]
    assert perfil_conducta(metricas(prudente, AHORA), ["EX1"], AHORA).codigo == "PRUDENTE"
    expuesto = [decision(False)] * 4 + [decision(True)] * 2
    perfil = perfil_conducta(metricas(expuesto, AHORA), ["EX1"], AHORA)
    assert perfil.codigo == "EXPUESTO"
    assert perfil.a_json()["etiqueta"] == "En aprendizaje"  # regla 7


def test_un_colaborador_que_cae_en_un_simulacro_queda_en_aprendizaje():
    obs = [simulacro("CLIC", ["I3"], tipos=("EX1", "IN1"))] + [decision(True)] * 6
    assert perfil_conducta(metricas(obs, AHORA), ["EX1", "IN1"], AHORA).codigo == "EXPUESTO"
    assert perfil_conducta(metricas(obs, AHORA), ["EX1"], AHORA).codigo != "EXPUESTO"


def test_inactivo_sin_acciones_en_90_dias():
    m = metricas([decision(True, dias=100)], AHORA)
    assert perfil_conducta(m, ["EX1"], AHORA).codigo == "INACTIVO"


# ---------------------------------------------------------------- retención (R4)
def test_r4_adelanta_el_refuerzo_si_la_precision_cae():
    inicio = [decision(True, dias=d) for d in (80, 79, 78, 77)]
    reciente = [decision(False, dias=d) for d in (10, 8, 6)] + [decision(True, dias=4)]
    r = retencion(inicio + reciente, AHORA)
    assert r.precision_inicial == 1.0 and r.precision_reciente == 0.25
    assert r.adelantar_refuerzo is True


def test_r4_no_dispara_antes_de_60_dias():
    obs = [decision(True, dias=d) for d in (20, 19, 18)] + [decision(False, dias=d) for d in (3, 2, 1)]
    assert retencion(obs, AHORA).adelantar_refuerzo is False


def test_r4_sin_juicios():
    assert retencion([], AHORA - timedelta(days=1)).adelantar_refuerzo is False
