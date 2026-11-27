"""Página de destino del correo de prueba (`/p/{token}`).

Regla 4 de CLAUDE.md: **la página no tiene formularios**. Solo un botón
«Continuar» que hace un `POST`. El `GET` no cuenta como clic (los filtros de
Gmail/Outlook visitan los enlaces solos); solo el `POST /p/{token}/clic` cuenta.
Tras el clic se muestra de inmediato el *momento enseñable*.
"""

from __future__ import annotations

from html import escape

from fastapi import APIRouter
from fastapi.responses import HTMLResponse

from . import escalera, servicio
from .catalogo import INDICIOS

router = APIRouter()

_ESTILO = """
<style>
  :root {
    color-scheme: light dark;
    --theme-color: #145962;
    --theme-color-hover: #0e434b;
    --page-bg: #f8fafc;
    --card: #ffffff;
    --ink: #0f172a;
    --muted: #475569;
    --border: #cbd5e1;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 16px;
    font-family: "Google Sans", system-ui, "Segoe UI", Roboto, Arial, sans-serif;
    background: var(--page-bg);
    color: var(--ink);
    -webkit-font-smoothing: antialiased;
  }
  .caja {
    max-width: 640px;
    margin: 32px auto;
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 14px;
    overflow: hidden;
    box-shadow: 0 4px 16px rgba(15, 23, 42, .06);
  }
  .cab {
    background: #0a1a26;
    color: #ffffff;
    padding: 18px 24px;
    font-size: 17px;
    font-weight: 600;
    border-bottom: 3px solid var(--theme-color);
  }
  .cont { padding: 24px; line-height: 1.55; font-size: 15px; }
  .cont h2 { margin: 0 0 8px; font-size: 20px; line-height: 1.3; }
  .boton {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 40px;
    background: var(--theme-color);
    color: #ffffff;
    border: 0;
    padding: 10px 22px;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    transition: background-color .15s;
  }
  .boton:hover { background: var(--theme-color-hover); }
  .boton:focus-visible { outline: 2px solid var(--theme-color); outline-offset: 3px; }
  .alerta {
    background: #fffbeb;
    border: 1px solid #fde68a;
    color: #78350f;
    border-radius: 10px;
    padding: 16px 18px;
    margin: 16px 0;
  }
  .ok {
    background: #ecfdf5;
    border-color: #a7f3d0;
    color: #065f46;
  }
  ul { padding-left: 20px; margin: 10px 0; }
  li { margin-bottom: 6px; }
  .pie {
    padding: 14px 24px;
    background: #f1f5f9;
    border-top: 1px solid var(--border);
    color: var(--muted);
    font-size: 12px;
    line-height: 1.5;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --page-bg: #070807;
      --card: #121411;
      --ink: #f4f6f1;
      --muted: #8b918a;
      --border: rgba(255, 255, 255, .12);
    }
    .cab { background: #0b0d0a; border-bottom-color: #9dff32; }
    .boton { background: #9dff32; color: #0c1206; }
    .boton:hover { background: #84e61c; }
    .boton:focus-visible { outline-color: #9dff32; }
    .alerta { background: rgba(255, 176, 32, .10); border-color: rgba(255, 176, 32, .4); color: #fde68a; }
    .ok { background: rgba(61, 220, 74, .12); border-color: rgba(61, 220, 74, .4); color: #bbf7d0; }
    .pie { background: #0b0d0a; }
  }
</style>
"""


def _pagina(titulo: str, cuerpo: str) -> str:
    return (
        f"<!doctype html><html lang='es'><head><meta charset='utf-8'>"
        f"<meta name='viewport' content='width=device-width, initial-scale=1'>"
        f"<title>{escape(titulo)}</title>{_ESTILO}</head><body>"
        f"<div class='caja'><div class='cab'>IESS · Escuela Antiphishing</div>"
        f"<div class='cont'>{cuerpo}</div>"
        f"<div class='pie'>Ejercicio de concientización. Este sitio nunca te pide "
        f"claves, datos personales ni pagos.</div></div></body></html>"
    )


@router.get("/p/{token}", response_class=HTMLResponse)
def pagina_continuar(token: str):
    """Página neutra. NO cuenta clic. Solo ofrece el botón «Continuar»."""
    cuerpo = (
        "<p>Estás a punto de continuar con la acción del correo que recibiste.</p>"
        "<form method='post' action='clic'>"
        "<button class='boton' type='submit'>Continuar</button>"
        "</form>"
    )
    return HTMLResponse(_pagina("Continuar", cuerpo))


@router.post("/p/{token}/clic", response_class=HTMLResponse)
def registrar_clic(token: str):
    """Cuenta el CLIC y muestra el momento enseñable."""
    des = servicio.procesar_reaccion_token(token, escalera.CLIC)
    if des is None:
        # Token desconocido o simulacro ya resuelto: mensaje genérico, sin filtrar.
        cuerpo = (
            "<div class='alerta ok'><h2>Esto era una práctica de seguridad</h2>"
            "<p>No ocurrió nada. En un correo real, un enlace así podría llevarte "
            "a una página fraudulenta.</p></div>"
            "<p>Recuerda: el IESS nunca te pide claves, datos ni pagos por correo. "
            "Verifica siempre abriendo tú mismo la app oficial.</p>"
        )
        return HTMLResponse(_pagina("Práctica de seguridad", cuerpo))
    return HTMLResponse(_pagina("Práctica de seguridad", _momento_html(des)))


@router.get("/salir/{token}", response_class=HTMLResponse)
def salir(token: str):
    """List-Unsubscribe: da de baja al destinatario de las prácticas."""
    sim = servicio.almacen.simulacion_por_token(token)  # type: ignore[attr-defined]
    if sim is not None:
        insc = servicio.almacen.inscripcion(sim.id_seudonimo)  # type: ignore[attr-defined]
        if insc is not None:
            servicio.salir(insc.correo)
    cuerpo = (
        "<h2>Listo</h2><p>Dejaste de recibir correos de práctica. Puedes volver a "
        "activarlos cuando quieras desde la app, en «Quiero capacitarme».</p>"
    )
    return HTMLResponse(_pagina("Baja de prácticas", cuerpo))


def _momento_html(des: dict) -> str:
    titulo = escape(des.get("titulo", "Era un correo de práctica"))
    mensaje = escape(des.get("mensaje", ""))
    indicios_html = "".join(
        f"<li><b>{escape(cod)} · {escape(INDICIOS.get(cod, ''))}</b></li>"
        for cod in des.get("indicios", [])
    )
    micro = des.get("microcursos", [])
    micro_html = ""
    if micro:
        items = "".join(f"<li>{escape(m)}</li>" for m in micro)
        micro_html = (
            "<p>Te sugerimos estos microcursos de 1 minuto:</p>"
            f"<ul>{items}</ul>"
        )
    return (
        f"<div class='alerta'><h2>{titulo}</h2><p>{mensaje}</p>"
        f"<ul>{indicios_html}</ul></div>"
        f"{micro_html}"
        "<p>El IESS nunca te pide claves, datos personales ni pagos por correo. "
        "Verifica abriendo tú mismo la app oficial.</p>"
    )
