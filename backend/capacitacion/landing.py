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
  :root { color-scheme: light dark; }
  body { margin:0; font-family: Arial, Helvetica, sans-serif; background:#f3f4f6;
         color:#1f2937; }
  .caja { max-width:640px; margin:40px auto; background:#fff; border-radius:14px;
          overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,.12); }
  .cab { background:#1b7a3d; color:#fff; padding:18px 24px; font-size:18px;
         font-weight:700; }
  .cont { padding:24px; line-height:1.5; }
  .boton { display:inline-block; background:#1b7a3d; color:#fff; border:0;
           padding:12px 24px; border-radius:8px; font-size:15px; font-weight:700;
           cursor:pointer; text-decoration:none; }
  .alerta { background:#fff7ed; border:1px solid #fdba74; border-radius:10px;
            padding:16px; margin:16px 0; }
  .ok { background:#ecfdf5; border:1px solid #6ee7b7; }
  ul { padding-left:20px; }
  .pie { padding:14px 24px; background:#f9fafb; color:#6b7280; font-size:12px; }
  @media (prefers-color-scheme: dark) {
    body { background:#0b1220; color:#e5e7eb; }
    .caja { background:#111827; }
    .alerta { background:#1f2937; border-color:#92400e; }
    .ok { background:#064e3b; border-color:#065f46; }
    .pie { background:#0b1220; color:#9ca3af; }
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
