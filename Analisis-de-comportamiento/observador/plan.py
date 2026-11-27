"""Plan de capacitación personalizado a partir de las falencias de la persona.

La prioridad de cada indicio combina tres cosas, y el plan dice siempre por qué:

    prioridad = riesgo × relevancia + exploración + repaso

- **riesgo**: 1 − probabilidad de reconocerlo. Usa la evidencia de la persona;
  si tiene poca, se apoya en lo que el observador aprendió de su segmento
  (`poblacion.py`) y, sin eso, en un punto neutro.
- **relevancia**: qué tanto se usa ese indicio para suplantar las tipologías que
  la persona recibe (`suplantacion_frecuente` de `tipologias.json`).
- **exploración**: un indicio sin probar suma un poco, para medirlo pronto (la
  escalera exige al menos un indicio DEBIL o SIN_PROBAR en cada correo, §11).
- **repaso**: un indicio que dominaba hace más de dos meses vuelve al plan.

Los textos son formativos (regla 7, «sin culpa»): describen qué practicar, nunca
juzgan a la persona.
"""
from __future__ import annotations

from datetime import datetime

from .catalogo import INDICIOS, MICROCURSOS, CatalogoTipologias, modulo_del_microcurso, ordenar_tipos
from .modelo import (
    ETIQUETAS_ESTADO,
    PRIOR_PERSONAL,
    estados_indicios,
    evidencia_por_indicio,
    evidencia_por_tipologia,
    metricas,
    perfil_conducta,
    retencion,
)
from .observaciones import Observacion
from .poblacion import ModeloPoblacion

VERSION_MODELO = "1.0"
FUERZA_PRIOR_SEGMENTO = 2.0
BONO_EXPLORACION = 0.10
BONO_REPASO = 0.10
MAX_FALENCIAS = 3


def _siguiente_nivel(observaciones: list[Observacion]) -> tuple[int, str]:
    """Escalera de §11 sobre el último correo de prueba."""
    sims = sorted((o for o in observaciones if o.tipo == "SIMULACRO" and not o.es_reporte_tardio),
                  key=lambda o: o.momento)
    if not sims:
        return 2, "Primer correo de práctica: nivel medio."
    u = sims[-1]
    if u.resultado == "REPORTO":
        return min(3, u.nivel + 1), "Reportaste el último correo de práctica: el siguiente es un poco más difícil."
    if u.resultado == "CLIC":
        return max(1, u.nivel - 1), "El siguiente correo será más fácil de reconocer, para practicar con calma."
    return u.nivel, "El siguiente correo tendrá la misma dificultad."


def _conteos(observaciones: list[Observacion]) -> dict[str, dict[str, int]]:
    c = {i: {"clics": 0, "reportes": 0, "errores_practica": 0} for i in INDICIOS}
    for o in observaciones:
        if o.tipo == "SIMULACRO" and not o.es_reporte_tardio:
            for i in o.indicios:
                if o.resultado == "CLIC":
                    c[i]["clics"] += 1
                elif o.resultado == "REPORTO":
                    c[i]["reportes"] += 1
        elif o.tipo == "DECISION" and o.es_estafa and not o.acerto:
            for i in o.indicios:
                c[i]["errores_practica"] += 1
    return c


def generar_plan(id_seudonimo: str, observaciones: list[Observacion], ahora: datetime,
                 catalogo: CatalogoTipologias, poblacion: ModeloPoblacion | None = None,
                 tipos=None, rango_etario: str | None = None) -> dict:
    obs = sorted(observaciones, key=lambda o: o.momento)
    if obs:
        tipos = obs[-1].tipos or tipos
        rango_etario = obs[-1].rango_etario or rango_etario
    tipos = ordenar_tipos(tipos or ("EX5",))

    estados = estados_indicios(obs, ahora)
    evidencia = evidencia_por_indicio(obs, ahora)
    exposicion = catalogo.exposicion_por_indicio(tipos)
    conteos = _conteos(obs)
    pesos_tipologia = catalogo.pesos_para(tipos)
    clic_esperado = poblacion.clic_esperado_por_plantilla() if poblacion else None
    met = metricas(obs, ahora, clic_esperado=clic_esperado)
    perfil = perfil_conducta(met, tipos, ahora)
    usa_segmento = False

    priorizados = []
    for i in INDICIOS:
        e, ev = estados[i], evidencia[i]
        prior = poblacion.prior_deteccion(i, tipos, rango_etario) if poblacion else None
        if prior is not None:
            dominio = ev.media(prior, FUERZA_PRIOR_SEGMENTO)
            usa_segmento = usa_segmento or ev.total < 1.0
        else:
            dominio = ev.media(0.5, 2 * PRIOR_PERSONAL)
        relevancia = 0.5 + 0.5 * exposicion[i]
        prioridad = (1 - dominio) * relevancia
        prioridad += BONO_EXPLORACION if e.estado == "SIN_PROBAR" else 0.0
        prioridad += BONO_REPASO if e.repasar else 0.0

        motivos = []
        c = conteos[i]
        if c["clics"]:
            veces = "una vez" if c["clics"] == 1 else f"{c['clics']} veces"
            motivos.append(f"Hiciste clic {veces} en correos de práctica que lo tenían.")
        if c["errores_practica"]:
            motivos.append("En las actividades se te pasó en algún caso.")
        if e.repasar:
            motivos.append("Lo dominabas, pero hace más de dos meses que no lo practicas.")
        if e.estado == "SIN_PROBAR":
            motivos.append("Todavía no lo hemos practicado contigo.")
        if exposicion[i] >= 0.7:
            suplantadas = [catalogo.nombre(t) for t in pesos_tipologia
                           if i in catalogo.tipologias[t].suplantacion_frecuente]
            if suplantadas:
                motivos.append("Es de los que más se usan para imitar correos que recibes: "
                               + ", ".join(suplantadas[:2]) + ".")
        if prior is not None and prior < 0.6 and ev.total < 1.0:
            motivos.append("Es de los que más engañan a personas con tu mismo tipo de cuenta.")
        priorizados.append((prioridad, i, e, dominio, motivos))

    priorizados.sort(key=lambda x: (-x[0], list(INDICIOS).index(x[1])))
    falencias = []
    for prioridad, i, e, dominio, motivos in priorizados:
        if e.estado == "DOMINADO" and not e.repasar:
            continue
        falencias.append({
            "indicio": i, "nombre": INDICIOS[i], "estado": e.estado, "etiqueta": ETIQUETAS_ESTADO[e.estado],
            "prioridad": round(prioridad, 3), "riesgo": round(1 - dominio, 3), "motivos": motivos,
            "microcurso": {"titulo": MICROCURSOS[i], "modulo": modulo_del_microcurso(i, set(tipos))},
        })
        if len(falencias) == MAX_FALENCIAS:
            break

    # ---------------------------------------------- tipología foco
    ev_tip = evidencia_por_tipologia(obs, ahora)
    candidatas = []
    for t in set(pesos_tipologia) | set(ev_tip):
        ev = ev_tip.get(t)
        riesgo = 1 - ev.media() if ev and ev.total >= 0.25 else None
        peso = pesos_tipologia.get(t, 0.5)
        if riesgo is not None and ev.fallo > 0:
            candidatas.append((riesgo * (0.5 + peso / 4), t, "Es la que más te ha costado reconocer cuando la imitan."))
        elif falencias and falencias[0]["indicio"] in catalogo.tipologias[t].suplantacion_frecuente and peso > 0:
            candidatas.append((0.3 * peso / 2, t, "La imitan con el indicio que más te conviene practicar."))
    foco = None
    if candidatas:
        _, t, motivo = max(candidatas, key=lambda x: (x[0], -int(x[1][1:])))
        foco = {"tipologia": t, "nombre": catalogo.nombre(t), "motivo": motivo, "capsula": catalogo.capsula(t)}

    # ---------------------------------------------- siguiente correo de prueba
    nivel, motivo_nivel = _siguiente_nivel(obs)
    cuantos = {1: 3, 2: 2, 3: 1}[nivel]
    objetivo = [f["indicio"] for f in falencias[:cuantos]] or [priorizados[0][1]]
    tipologia_objetivo = foco["tipologia"] if foco else None
    if tipologia_objetivo is None:
        relevantes = [t for t in pesos_tipologia if objetivo[0] in catalogo.tipologias[t].suplantacion_frecuente]
        tipologia_objetivo = max(relevantes, key=lambda t: pesos_tipologia[t], default=None)

    # ---------------------------------------------- ritmo
    ret = retencion(obs, ahora)
    if perfil.codigo == "EXPUESTO":
        ritmo = {"codigo": "INTENSIVO", "descripcion": "Doble frecuencia por 4 semanas, con retroalimentación inmediata."}
    elif perfil.codigo == "CENTINELA":
        ritmo = {"codigo": "MENSUAL", "descripcion": "Un correo de práctica al mes: tus reportes ya alertan a otros."}
    else:
        ritmo = {"codigo": "BASE", "descripcion": "El ritmo de la ruta de tu tipo de usuario."}
    ritmo["adelantar_refuerzo"] = ret.adelantar_refuerzo
    if ret.adelantar_refuerzo:
        ritmo["motivo"] = "Tu precisión bajó frente a tus primeras semanas: adelantamos el siguiente refuerzo (R4)."

    # ---------------------------------------------- confianza y mensaje
    n = len(obs)
    confianza = "BAJA" if n < 3 else "MEDIA" if n < 10 else "ALTA"
    if confianza == "BAJA":
        nota = ("Con pocas observaciones, el plan se apoya en lo que el observador aprendió de personas "
                "con tu mismo tipo de cuenta." if usa_segmento else
                "Con pocas observaciones, el plan se apoya en las señales que más se usan contra tu tipo de cuenta.")
    else:
        nota = f"El plan se basa en {n} observaciones tuyas de los últimos meses."
    if not falencias:
        mensaje = "¡Vas muy bien! Reconoces todas las señales que hemos practicado. Seguiremos con correos más sutiles."
    else:
        mensaje = ("Esto es lo que más te conviene practicar ahora. Equivocarse en una práctica es parte de "
                   "aprender: no tiene consecuencias.")

    return {
        "id_seudonimo": id_seudonimo,
        "generado_en": ahora.isoformat().replace("+00:00", "Z"),
        "version_modelo": VERSION_MODELO,
        "tipos": list(tipos),
        "perfil_conducta": perfil.a_json(),
        "metricas": met.a_json(),
        "indicios": [estados[i].a_json() for i in INDICIOS],
        "falencias": falencias,
        "foco_tipologia": foco,
        "siguiente_correo": {"nivel": nivel, "indicios_objetivo": objetivo, "tipologia": tipologia_objetivo,
                             "motivo": motivo_nivel},
        "ritmo": ritmo,
        "retencion": ret.a_json(),
        "confianza": {"nivel": confianza, "observaciones": n, "nota": nota},
        "mensaje": mensaje,
    }


def elegir_plantilla(plan: dict, candidatas: list[dict], ya_enviadas=()) -> str | None:
    """Elige el correo de prueba que mejor trabaja el plan.

    `candidatas`: `[{id, nivel, tipologia, indicios, tipos?}]` (por ejemplo,
    `datos/plantillas.json`). Prefiere: el nivel pedido, los indicios objetivo
    (y luego cualquier falencia), la tipología foco y lo que no se envió."""
    obj = plan["siguiente_correo"]
    prioridad = {f["indicio"]: f["prioridad"] for f in plan.get("falencias", [])}
    tipos = set(plan.get("tipos", []))
    enviadas = set(ya_enviadas)
    mejor, mejor_puntaje = None, None
    for c in candidatas:
        if c.get("tipos") and tipos and not tipos & set(c["tipos"]):
            continue
        indicios = set(c.get("indicios", []))
        p = 100 if c.get("nivel") == obj["nivel"] else 40 if abs((c.get("nivel") or 2) - obj["nivel"]) == 1 else 0
        p += sum(40 / (1 + k) for k, i in enumerate(obj["indicios_objetivo"]) if i in indicios)
        p += 10 * sum(prioridad.get(i, 0) for i in indicios)
        p += 15 if obj.get("tipologia") and c.get("tipologia") == obj["tipologia"] else 0
        p -= 60 if c.get("id") in enviadas else 0
        if mejor_puntaje is None or p > mejor_puntaje or (p == mejor_puntaje and c["id"] < mejor):
            mejor, mejor_puntaje = c["id"], p
    return mejor
