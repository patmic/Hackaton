"""Plan personalizado: falencias, foco, siguiente correo y ritmo."""
import re

from conftest import AHORA, PERSONA, decision, simulacro
from observador.plan import elegir_plantilla, generar_plan
from observador.poblacion import ModeloPoblacion
from observador.sintetico import cargar_plantillas

PALABRAS_CON_CULPA = re.compile(r"fallaste|culpa|error grave|mal hecho|negligen|expuesto", re.I)


def plan(obs, catalogo, **kw):
    return generar_plan(PERSONA, obs, AHORA, catalogo, **kw)


def test_las_falencias_salen_de_lo_que_no_vio(catalogo):
    p = plan([simulacro("CLIC", ["I6", "I1", "I7"])], catalogo)
    codigos = [f["indicio"] for f in p["falencias"]]
    assert set(codigos) <= {"I6", "I1", "I7", "I2"} | set()  # lo visto en el correo va primero
    assert codigos[0] in {"I6", "I1", "I7"}
    primera = p["falencias"][0]
    assert any("clic" in m for m in primera["motivos"])
    assert primera["microcurso"]["titulo"]


def test_lo_dominado_no_es_falencia(catalogo):
    p = plan([simulacro("REPORTO", ["I6", "I1"], nivel=3, dias=d) for d in (1, 2, 3)], catalogo)
    assert not {"I6", "I1"} & {f["indicio"] for f in p["falencias"]}


def test_sin_historial_explora_lo_que_mas_se_usa_contra_su_tipo(catalogo):
    p = plan([], catalogo, tipos=["EX2"])
    assert len(p["falencias"]) == 3
    assert all(f["estado"] == "SIN_PROBAR" for f in p["falencias"])
    # A los jubilados se les suplanta sobre todo T2 y T4: I2, I7, I1 están en esas listas.
    assert {f["indicio"] for f in p["falencias"]} <= {"I2", "I7", "I1", "I6", "I8", "I11"}
    assert p["confianza"]["nivel"] == "BAJA"
    assert p["siguiente_correo"]["nivel"] == 2


def test_arranque_en_frio_con_lo_aprendido_del_segmento(catalogo):
    # En su segmento, I9 engaña a casi todos: aunque la persona no tenga
    # historial, el plan empieza por ahí y lo dice.
    por_persona = {
        f"persona-segmento-{n:04d}": [simulacro("CLIC", ["I9"], persona=f"persona-segmento-{n:04d}",
                                                tipos=("EX2",), rango="65+")] for n in range(15)
    }
    pob = ModeloPoblacion.construir(por_persona, AHORA)
    p = plan([], catalogo, poblacion=pob, tipos=["EX2"], rango_etario="65+")
    assert p["falencias"][0]["indicio"] == "I9"
    assert any("mismo tipo de cuenta" in m for m in p["falencias"][0]["motivos"])
    assert "personas con tu mismo tipo de cuenta" in p["confianza"]["nota"]
    # Lo que ve la persona sigue saliendo solo de sus acciones.
    assert p["indicios"][8]["estado"] == "SIN_PROBAR"


def test_escalera_del_siguiente_correo(catalogo):
    assert plan([simulacro("REPORTO", ["I6"], nivel=2)], catalogo)["siguiente_correo"]["nivel"] == 3
    assert plan([simulacro("CLIC", ["I6"], nivel=2)], catalogo)["siguiente_correo"]["nivel"] == 1
    assert plan([simulacro("IGNORO", ["I6"], nivel=2)], catalogo)["siguiente_correo"]["nivel"] == 2
    p = plan([simulacro("REPORTO", ["I6"], nivel=3)], catalogo)["siguiente_correo"]
    assert p["nivel"] == 3 and len(p["indicios_objetivo"]) == 1


def test_el_reporte_tardio_no_sube_el_nivel(catalogo):
    from observador import Observacion

    tardio = Observacion.desde_json({**simulacro("REPORTO", ["I6"], dias=0.5).a_json(),
                                     "reporto_despues_de_clic": True})
    p = plan([simulacro("CLIC", ["I6"], nivel=2, dias=1), tardio], catalogo)
    assert p["siguiente_correo"]["nivel"] == 1


def test_foco_en_la_tipologia_que_mas_le_cuesta(catalogo):
    obs = [simulacro("CLIC", ["I11", "I9"], tipologia="T4", dias=3), simulacro("REPORTO", ["I6"], tipologia="T2")]
    foco = plan(obs, catalogo)["foco_tipologia"]
    assert foco["tipologia"] == "T4"
    assert "QR" in foco["capsula"]


def test_ritmo_segun_el_perfil(catalogo):
    expuesto = [decision(False, ["I3"])] * 4 + [decision(True)] * 2
    assert plan(expuesto, catalogo)["ritmo"]["codigo"] == "INTENSIVO"
    centinela = [simulacro("REPORTO", ["I1"], dias=d) for d in (1, 2)] + [decision(True)] * 4
    assert plan(centinela, catalogo)["ritmo"]["codigo"] == "MENSUAL"


def test_los_textos_son_sin_culpa_y_sin_datos_personales(catalogo):
    obs = [simulacro("CLIC", ["I6", "I1"]), decision(False, ["I3"])] + [decision(False)] * 4
    p = plan(obs, catalogo)
    visibles = [p["mensaje"], p["perfil_conducta"]["etiqueta"]] + [m for f in p["falencias"] for m in f["motivos"]]
    assert not any(PALABRAS_CON_CULPA.search(t) for t in visibles)
    assert p["perfil_conducta"]["etiqueta"] == "En aprendizaje"

    def claves(x):
        if isinstance(x, dict):
            for k, v in x.items():
                yield k
                yield from claves(v)
        elif isinstance(x, list):
            for v in x:
                yield from claves(v)

    # «nombre» sí aparece, pero es el nombre del indicio o de la tipología.
    personales = {"cedula", "nombres", "apellidos", "correo", "email", "telefono", "ip", "direccion"}
    assert not personales & set(claves(p))


def test_elegir_plantilla_trabaja_el_plan(catalogo):
    plantillas = cargar_plantillas()
    # Cayó con el QR de un turno: el siguiente es nivel 1 y debe volver a trabajar I11.
    p = plan([simulacro("CLIC", ["I11", "I9", "I1"], tipologia="T4", plantilla="N2-EX-turno-qr")], catalogo)
    elegida = elegir_plantilla(p, plantillas, ya_enviadas=["N2-EX-turno-qr"])
    detalle = next(x for x in plantillas if x["id"] == elegida)
    assert detalle["nivel"] == 1
    assert set(detalle["indicios"]) & {"I11", "I9", "I1"}
    assert "EX1" in detalle["tipos"]


def test_elegir_plantilla_respeta_el_tipo(catalogo):
    plantillas = cargar_plantillas()
    p = plan([], catalogo, tipos=["IN1"])
    elegida = elegir_plantilla(p, plantillas)
    assert "IN1" in next(x for x in plantillas if x["id"] == elegida)["tipos"]
