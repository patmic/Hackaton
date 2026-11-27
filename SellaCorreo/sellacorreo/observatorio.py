"""Observatorio de comportamiento dentro de SellaCorreo.

Usa el paquete `observador` de `Analisis-de-comportamiento/` (en Docker se copia
con el contexto de compilación `observador`, ver docker-compose.yml). Si el
paquete no está, SellaCorreo sigue funcionando igual y el Observatorio se muestra
como no disponible (fail-open, como el resto del sellado).

Las observaciones se guardan en el mismo SQLite de SellaCorreo, en tablas
`obs_*`. En modo demo se siembra una población sintética marcada como tal.
"""
from __future__ import annotations

import html
import logging
import os
from datetime import datetime, timezone

from . import store

log = logging.getLogger("sellacorreo.observatorio")
E = html.escape

try:  # el paquete vive fuera de SellaCorreo
    from observador import Almacen, ObservacionInvalida, Observador
    from observador.api import crear_router
    from observador import sintetico

    DISPONIBLE = True
except ImportError:  # pragma: no cover - depende del despliegue
    DISPONIBLE = False

_observador: "Observador | None" = None


def demo_activo() -> bool:
    valor = os.environ.get("SELLACORREO_OBSERVATORIO_DEMO")
    return store.demo_mode() if valor is None else valor.lower() == "true"


def iniciar() -> None:
    """Crea el observador sobre la base de SellaCorreo y, en demo, siembra la
    población sintética si todavía no está."""
    global _observador
    if not DISPONIBLE:
        log.warning("Paquete observador no disponible: el Observatorio queda desactivado.")
        return
    try:
        _observador = Observador(Almacen(store._db_path()))
        if demo_activo() and _observador.almacen.contar()["sinteticas"] == 0:
            personas = int(os.environ.get("SELLACORREO_OBSERVATORIO_PERSONAS", "400"))
            obs = sintetico.generar(_observador.catalogo, personas=personas)
            _observador.almacen.registrar(obs)
            log.info("Observatorio: %s observaciones sintéticas de %s personas.", len(obs), personas)
    except Exception:  # fail-open: nunca impedir que arranque el sello
        log.exception("No se pudo iniciar el Observatorio.")
        _observador = None


def observador():
    return _observador


def router(puede_ver_panel, permitir):
    if _observador is None:
        return None
    return crear_router(_observador, puede_ver_panel=puede_ver_panel, permitir=permitir)


# ------------------------------------------------------------------ presentación
def _pct(x) -> str:
    return "—" if x is None else f"{round(x * 100)} %"


def _num(x, dec: int = 2) -> str:
    return "—" if x is None else f"{x:.{dec}f}".replace(".", ",")


def _barra(valor: float | None, clase: str = "") -> str:
    """Barra en SVG: la CSP de SellaCorreo no permite estilos en línea."""
    ancho = 0 if valor is None else max(0.0, min(1.0, valor)) * 100
    return (f'<svg class="sc-obs-bar {clase}" viewBox="0 0 100 8" preserveAspectRatio="none" aria-hidden="true">'
            f'<rect class="sc-obs-bar__track" width="100" height="8" rx="4"/>'
            f'<rect class="sc-obs-bar__fill" width="{ancho:.1f}" height="8" rx="4"/></svg>')


def _barras(filas, etiqueta, valor, clase="") -> str:
    if not filas:
        return '<p class="tl-hint">Sin grupos de 10 personas o más todavía.</p>'
    items = "".join(f'<li><span>{E(etiqueta(f))}</span>{_barra(valor(f), clase)}'
                    f'<span class="tl-bars__val">{_pct(valor(f))}</span></li>' for f in filas)
    return f'<ul class="tl-bars sc-obs-bars">{items}</ul>'


def _kpi(titulo, valor, ayuda) -> str:
    return (f'<div class="tl-card tl-stat"><div class="tl-stat__label">{E(titulo)}</div>'
            f'<div class="tl-stat__value">{E(valor)}</div><div class="tl-hint">{E(ayuda)}</div></div>')


def _segmentos(segmentos) -> str:
    if not segmentos:
        return '<p class="tl-hint">Ningún segmento llega todavía a 10 personas.</p>'
    filas = []
    for s in segmentos:
        chips = "".join(f'<span class="tl-badge tl-badge--outline">{E(f["codigo"])} · {_pct(f["tasa_engano"])}</span>'
                        for f in s["indicios"][:3])
        filas.append(f'<tr><td><strong>{E(s["nombre"])}</strong></td><td>{s["personas"]}</td>'
                     f'<td>{"—" if s["irs"] is None else s["irs"]}</td><td class="sc-obs-chips">{chips}</td>'
                     f'<td>{E(s["recomendacion"])}</td></tr>')
    return ('<div class="sc-obs-scroll"><table class="sc-table sc-obs-table"><tr><th>Segmento</th><th>Personas</th>'
            '<th>IRS</th><th>Indicios que más engañan</th><th>Acción sugerida</th></tr>' + "".join(filas)
            + "</table></div>")


def _calibracion(filas) -> str:
    visibles = [c for c in filas if c["tasa_clic"] is not None]
    if not visibles:
        return '<p class="tl-hint">Aún no hay plantillas enviadas a 10 personas o más.</p>'
    trs = []
    for c in sorted(visibles, key=lambda c: (not c["desfase"], c["plantilla_id"])):
        badge = ('<span class="tl-badge tl-badge--warning">Recalibrar</span>' if c["desfase"]
                 else '<span class="tl-badge tl-badge--success">Coincide</span>')
        trs.append(f'<tr><td><code>{E(c["plantilla_id"])}</code></td><td>{c["nivel_nominal"]} → {c["nivel_efectivo"]}</td>'
                   f'<td>{_pct(c["tasa_clic"])}</td><td>{_pct(c["tasa_reporte"])}</td><td>{badge}</td></tr>')
    return ('<div class="sc-obs-scroll"><table class="sc-table"><tr><th>Plantilla</th><th>Nivel nominal → real</th>'
            '<th>Clic</th><th>Reporte</th><th></th></tr>' + "".join(trs) + "</table></div>")


def _plan(plan: dict | None, consulta: str, error: str) -> str:
    form = (f'<form class="sc-obs-buscar" method="get" action="/observatorio#plan">'
            f'<label class="tl-field__label" for="persona">Código de capacitación (lo muestra la app en «Mi plan»)</label>'
            f'<div class="sc-obs-buscar__fila"><input class="tl-input" id="persona" name="persona" value="{E(consulta)}" '
            f'placeholder="por ejemplo a3f9c2e17b4d48e0b6c1" autocomplete="off">'
            f'<button class="tl-btn tl-btn--default" type="submit">Ver plan</button></div></form>')
    if error:
        return form + f'<div class="tl-alert tl-alert--destructive" role="alert"><div class="tl-alert__body">{E(error)}</div></div>'
    if plan is None:
        return form
    m = plan["metricas"]
    falencias = "".join(
        f'<li><strong>{E(f["indicio"])} · {E(f["nombre"])}</strong> <span class="tl-badge tl-badge--secondary">'
        f'{E(f["etiqueta"])}</span><br><span class="tl-hint">{E(" ".join(f["motivos"]))}</span><br>'
        f'<span class="sc-obs-micro">Microcurso «{E(f["microcurso"]["titulo"])}» ({E(f["microcurso"]["modulo"])})</span></li>'
        for f in plan["falencias"]) or "<li>Reconoce todas las señales practicadas.</li>"
    mapa = "".join(f'<span class="sc-obs-ind sc-obs-ind--{i["estado"].lower()}" title="{E(i["nombre"])}">'
                   f'{E(i["indicio"])}</span>' for i in plan["indicios"])
    sig = plan["siguiente_correo"]
    foco = plan["foco_tipologia"]
    return form + f"""<div class="sc-obs-plan">
<div><h3 class="tl-title">Lo que más le conviene practicar</h3><ol class="sc-obs-falencias">{falencias}</ol></div>
<div class="sc-obs-plan__lado">
<p><span class="tl-stat__label">Perfil</span><br><strong>{E(plan["perfil_conducta"]["etiqueta"])}</strong>
 <span class="tl-hint">· {E(plan["perfil_conducta"]["motivo"])}</span></p>
<p><span class="tl-stat__label">Mapa de indicios</span><br><span class="sc-obs-mapa">{mapa}</span></p>
<p><span class="tl-stat__label">Siguiente correo de práctica</span><br>Nivel {sig["nivel"]} ·
 indicios {E(", ".join(sig["indicios_objetivo"]))}{f' · imita {E(sig["tipologia"])}' if sig["tipologia"] else ""}<br>
 <span class="tl-hint">{E(sig["motivo"])}</span></p>
{f'<p><span class="tl-stat__label">Tipología foco</span><br>{E(foco["nombre"])}<br><span class="tl-hint">«{E(foco["capsula"])}»</span></p>' if foco else ""}
<p><span class="tl-stat__label">Ritmo</span><br>{E(plan["ritmo"]["descripcion"])}</p>
<p class="tl-hint">{m["simulacros"]} correos de práctica · {m["decisiones"]} decisiones · precisión {_pct(m["precision"])} ·
 confianza {E(plan["confianza"]["nivel"].lower())}</p>
</div></div>"""


def panel(csrf: str, consulta: str = "") -> str:
    """Cuerpo HTML de /observatorio."""
    if _observador is None:
        return ('<section class="tl-card"><div class="tl-card__body"><h1 class="tl-h1">Observatorio</h1>'
                '<p class="tl-page-desc">El observador de comportamiento no está disponible en este despliegue. '
                'El sello y el Validador funcionan con normalidad.</p></div></section>')
    r = _observador.resumen()
    plan, error = None, ""
    consulta = consulta.strip()
    if consulta:
        try:
            if not _observador.almacen.de_persona(consulta):
                error = "No hay observaciones con ese código."
            else:
                plan = _observador.plan(consulta)
        except ObservacionInvalida:
            error = "El código no tiene el formato esperado."
    sint = r["almacen"]["sinteticas"]
    aviso = ""
    if sint:
        aviso = (f'<div class="tl-alert tl-alert--theme sc-obs-aviso" role="status"><div class="tl-alert__body">'
                 f'<strong>Incluye {r["personas_sinteticas"]} personas sintéticas de demostración.</strong> '
                 f'Sus datos son inventados y sirven para mostrar cómo aprende el observador.</div>'
                 f'<form method="post" action="/observatorio/borrar-sinteticos"><input type="hidden" name="csrf" '
                 f'value="{E(csrf)}"><button class="tl-btn tl-btn--ghost tl-btn--sm" type="submit">Quitar datos '
                 f'sintéticos</button></form></div>')
    minutos = r["mediana_minutos_reporte"]
    kpis = "".join([
        _kpi("Personas observadas", str(r["personas"] or "Menos de 10"), f"Últimos {r['ventana_dias']} días"),
        _kpi("Correos de práctica", str(r["simulacros"]), f"Clic {_pct(r['tasa_clic'])}"),
        _kpi("Tasa de reporte", _pct(r["tasa_reporte"]), "La conducta con mejor evidencia"),
        _kpi("Clic ajustado", _num(r["clic_ajustado"]), "1 = lo esperado por la dificultad; menos es mejor"),
        _kpi("Mediana hasta reportar", "—" if minutos is None else f"{_num(minutos, 0)} min", "Desde que llega el correo"),
    ])
    ahora = datetime.now(timezone.utc).strftime("%d/%m/%Y %H:%M UTC")
    return f"""<section class="sc-obs" aria-labelledby="obs-title">
<header class="sc-obs__head"><h1 class="tl-h1" id="obs-title">Observatorio</h1>
<p class="tl-page-desc">Aprende de cómo reaccionan las personas a los correos de práctica y a la capacitación, y
personaliza lo que cada una practica. Solo se muestran grupos de {r["k_anonimato"]} personas o más; ningún dato
identifica a nadie. Actualizado {E(ahora)}.</p></header>
{aviso}
<section class="tl-grid-stats sc-obs__kpis" aria-label="Resumen">{kpis}</section>
<div class="sc-obs__grid">
<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Indicios que más engañan</h2>
<p class="tl-hint">Porcentaje de correos de práctica con ese indicio en los que hubo clic.</p>
{_barras(r["indicios"][:8], lambda f: f"{f['codigo']} · {f['nombre']}", lambda f: f["tasa_engano"], "sc-obs-bar--alerta")}</div></section>
<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Tipologías que más se suplantan con éxito</h2>
<p class="tl-hint">Según tipologias-correo: el correo de práctica imitaba esa tipología.</p>
{_barras(r["tipologias"], lambda f: f"{f['codigo']} · {f['nombre']}", lambda f: f["tasa_engano"], "sc-obs-bar--alerta")}</div></section>
</div>
<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Lo que aprendió de cada segmento</h2>
<p class="tl-hint">Tipo de usuario × rango de edad. IRS: índice de resiliencia del segmento (0 a 100). Las acciones
masivas las aprueba un analista de seguridad (IN3).</p>{_segmentos(r["segmentos"])}</div></section>
<div class="sc-obs__grid">
<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Perfiles de conducta</h2>
<p class="tl-hint">«En aprendizaje» es el nombre visible de «Expuesto»: nadie ve una etiqueta que culpe.</p>
{_barras([p for p in r["perfiles"] if p["personas"]], lambda p: p["etiqueta"],
         lambda p: p["personas"] / max(1, r["personas"] or 1))}</div></section>
<section class="tl-card"><div class="tl-card__body"><h2 class="tl-title">Dificultad real de los correos de práctica</h2>
<p class="tl-hint">Si una plantilla engaña como si fuera de otro nivel, conviene recalibrarla.</p>
{_calibracion(r["calibracion"])}</div></section>
</div>
<section class="tl-card" id="plan"><div class="tl-card__body"><h2 class="tl-title">Plan personalizado de una persona</h2>
<p class="tl-hint">Solo quien tiene el código (la propia persona) puede compartirlo. No hay lista de personas.</p>
{_plan(plan, consulta, error)}</div></section>
</section>"""


def borrar_sinteticos() -> int:
    return _observador.almacen.borrar_sinteticos() if _observador else 0
