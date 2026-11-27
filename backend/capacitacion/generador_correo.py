"""Generador de correos de phishing **simulado** (el corazón del bloque).

A partir de una `Plantilla` (tipo, nivel, tipología e indicios), construye un
correo MIME convincente y adaptado al tipo de usuario, que *realiza* exactamente
los indicios de la plantilla. El contenido es ficticio.

Garantías de seguridad (reglas 4 y 5 de CLAUDE.md), aplicadas aquí:
- El enlace del botón SIEMPRE apunta a la página de destino de la plataforma
  (`/p/{token}`), que no tiene formulario. El texto del enlace puede *mostrar* un
  dominio sospechoso (indicios I2/I4), pero el destino real es la página neutra.
- El remitente visible nunca es `@iess.gob.ec`. Sin I7 usa el dominio de práctica;
  con I7 usa un dominio «parecido» que es la lección a aprender.
- El QR codifica solo la URL de la página de destino; el adjunto de I5 es un
  marcador inofensivo con la extensión sospechosa, nunca un ejecutable real.
- Cada correo lleva cabeceras `X-Simulacro-Ref` y `X-Entrenamiento-IESS` y una
  cabecera `List-Unsubscribe` hacia `/salir/{token}`.
"""

from __future__ import annotations

import random
import struct
import zlib
from dataclasses import dataclass, field
from email.mime.application import MIMEApplication
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import formatdate, make_msgid
from html import escape

from . import fragmentos as fr
from .catalogo import MICROCURSO_POR_INDICIO, NOMBRE_TIPO
from .config import config
from .plantillas import Plantilla

# Si llega un tipo desconocido, el correo se dirige de forma genérica.
_PERSONA_FALLBACK = {"saludo": "Estimado usuario", "quien": "usuario"}


@dataclass
class Adjunto:
    filename: str
    maintype: str
    subtype: str
    datos: bytes
    cid: str | None = None  # Content-ID (sin < >), para imágenes embebidas.


@dataclass
class _Lienzo:
    """Estado mutable mientras se arma el correo."""

    tipo_usuario: str
    tipologia: str
    saludo: str
    remitente_nombre: str
    remitente_correo_visible: str
    area_firma: str
    asunto: str
    parrafos: list[str] = field(default_factory=list)
    reply_to: str | None = None
    enlace_mostrado: str | None = None  # texto del enlace (I2/I4); None = botón
    boton_label: str = "Continuar"
    adjuntos: list[Adjunto] = field(default_factory=list)


@dataclass
class CorreoGenerado:
    plantilla_id: str
    tipo_usuario: str
    tipologia: str
    indicios: tuple[str, ...]
    token: str
    asunto: str
    remitente_nombre: str
    remitente_correo_visible: str
    remitente_correo_envio: str
    reply_to: str | None
    para: str
    cuerpo_texto: str
    cuerpo_html: str
    adjuntos: list[Adjunto]
    cabeceras: dict[str, str]

    # -- Construcción MIME -------------------------------------------------- #

    def construir_mime(self, *, usar_remitente_envio: bool = False) -> MIMEMultipart:
        """Arma el mensaje MIME completo.

        `usar_remitente_envio=True` pone como `From` el buzón del dominio de
        práctica (necesario para enviar por SMTP/Resend con SPF/DKIM válidos) y
        deja el dominio «parecido» solo como nombre visible. En modo consola se
        usa `False` para reproducir el correo tal como lo vería la persona.
        """
        qr = [a for a in self.adjuntos if a.cid]
        normales = [a for a in self.adjuntos if not a.cid]

        texto = MIMEText(self.cuerpo_texto, "plain", "utf-8")
        html = MIMEText(self.cuerpo_html, "html", "utf-8")
        alternativa = MIMEMultipart("alternative")
        alternativa.attach(texto)
        alternativa.attach(html)

        if qr:
            relacionado = MIMEMultipart("related")
            relacionado.attach(alternativa)
            for a in qr:
                img = MIMEImage(a.datos, _subtype=a.subtype)
                img.add_header("Content-ID", f"<{a.cid}>")
                img.add_header(
                    "Content-Disposition", "inline", filename=a.filename
                )
                relacionado.attach(img)
            cuerpo = relacionado
        else:
            cuerpo = alternativa

        if normales:
            raiz: MIMEMultipart = MIMEMultipart("mixed")
            raiz.attach(cuerpo)
            for a in normales:
                parte = MIMEApplication(
                    a.datos, _subtype=a.subtype, name=a.filename
                )
                parte.add_header(
                    "Content-Disposition", "attachment", filename=a.filename
                )
                raiz.attach(parte)
        else:
            raiz = cuerpo  # type: ignore[assignment]

        if usar_remitente_envio:
            from_header = f"{self.remitente_nombre} <{self.remitente_correo_envio}>"
        else:
            from_header = (
                f"{self.remitente_nombre} <{self.remitente_correo_visible}>"
            )

        raiz["From"] = from_header
        raiz["To"] = self.para
        raiz["Subject"] = self.asunto
        raiz["Date"] = formatdate(localtime=True)
        raiz["Message-ID"] = make_msgid(domain=config.dominio_practica)
        if self.reply_to:
            raiz["Reply-To"] = self.reply_to
        for clave, valor in self.cabeceras.items():
            raiz[clave] = valor
        return raiz

    def como_eml(self, *, usar_remitente_envio: bool = False) -> str:
        return self.construir_mime(usar_remitente_envio=usar_remitente_envio).as_string()


# --------------------------------------------------------------------------- #
# Realizadores de indicios: cada uno muta el lienzo.
# --------------------------------------------------------------------------- #


def _ctx_valores(rnd: random.Random, plantilla: Plantilla) -> dict:
    c = dict(plantilla.contexto or {})
    c.setdefault("monto", fr.monto(rnd))
    c.setdefault("tasa", fr.tasa(rnd))
    c.setdefault("periodo", "octubre-diciembre")
    c.setdefault("referencia", fr.referencia_iess(rnd))
    c.setdefault("tramite", fr.numero_tramite(rnd))
    return c


def _realizar_i1(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    l.parrafos.append(rnd.choice(fr.FRASES_I1))
    sufijo = rnd.choice(fr.SUFIJO_ASUNTO_I1)
    if "hoy" not in l.asunto.lower() and sufijo not in l.asunto:
        l.asunto = f"{l.asunto} {sufijo}"


def _realizar_i2(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    l.enlace_mostrado = f"https://{fr.dominio_enlace_falso(rnd)}/acceso"


def _realizar_i3(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    l.parrafos.append(rnd.choice(fr.FRASES_I3))


def _realizar_i4(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    # El acortador tiene prioridad visual sobre el dominio parecido de I2.
    l.enlace_mostrado = fr.enlace_acortado(rnd)


def _realizar_i5(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    ext = (ctx.get("adjunto_ext") or "zip").lower()
    archivo = fr.nombre_adjunto(rnd, ext)
    plantilla_frase = fr.FRASES_I5.get(ext, fr.FRASES_I5["zip"])
    l.parrafos.append(plantilla_frase.format(archivo=archivo))
    # Carga inofensiva: solo un marcador de práctica, nunca un binario real.
    aviso = (
        "ARCHIVO DE PRÁCTICA - Simulación de concientización IESS. "
        "Este adjunto es inofensivo y no contiene software.\n"
        f"Simulaba un adjunto sospechoso del tipo .{ext} (indicio I5)."
    ).encode("utf-8")
    subtype = "pdf" if ext == "pdf" else "octet-stream"
    l.adjuntos.append(
        Adjunto(filename=archivo, maintype="application", subtype=subtype, datos=aviso)
    )


def _realizar_i6(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    l.parrafos.append(rnd.choice(fr.FRASES_I6).format(monto=ctx["monto"]))


def _realizar_i7(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    l.remitente_correo_visible = fr.correo_remitente_falso(rnd)
    # A veces el «responder a» difiere del remitente (otra pista de I7).
    if rnd.random() < 0.4:
        l.reply_to = f"respuestas@{fr.dominio_enlace_falso(rnd)}"


def _realizar_i8(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    l.parrafos.append(rnd.choice(fr.FRASES_I8))


def _realizar_i9(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    l.parrafos.append(rnd.choice(fr.FRASES_I9))


def _realizar_i10(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    l.parrafos.append(rnd.choice(fr.FRASES_I10).format(tasa=ctx["tasa"]))


def _realizar_i11(l: _Lienzo, rnd: random.Random, ctx: dict) -> None:
    l.parrafos.append(rnd.choice(fr.FRASES_I11))
    datos = _generar_qr_png(f"{config.base_url}/p/{l.boton_token}")  # type: ignore[attr-defined]
    l.adjuntos.append(
        Adjunto(
            filename=fr.nombre_qr(rnd),
            maintype="image",
            subtype="png",
            datos=datos,
            cid="qr",
        )
    )


# Orden canónico en que se añaden los párrafos para que el relato fluya.
_REALIZADORES = {
    "I7": _realizar_i7,
    "I6": _realizar_i6,
    "I8": _realizar_i8,
    "I3": _realizar_i3,
    "I9": _realizar_i9,
    "I10": _realizar_i10,
    "I5": _realizar_i5,
    "I11": _realizar_i11,
    "I2": _realizar_i2,
    "I4": _realizar_i4,
    "I1": _realizar_i1,
}
_ORDEN = ["I7", "I6", "I8", "I3", "I9", "I10", "I5", "I11", "I2", "I4", "I1"]


def _generar_qr_png(url: str) -> bytes:
    """QR real si está `qrcode`; si no, un PNG de respaldo válido."""
    try:
        import io

        import qrcode  # type: ignore

        img = qrcode.make(url)
        buf = io.BytesIO()
        img.save(buf, format="PNG")
        return buf.getvalue()
    except Exception:
        return _png_cuadricula()


def _png_cuadricula(lado: int = 132, bloque: int = 12) -> bytes:
    """PNG en escala de grises con patrón de ajedrez (apariencia de QR).

    Generado con la librería estándar, siempre válido. Sirve de respaldo cuando
    no está instalada la librería `qrcode`.
    """

    def _chunk(tipo: bytes, datos: bytes) -> bytes:
        c = tipo + datos
        return (
            struct.pack(">I", len(datos))
            + c
            + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)
        )

    firma = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", lado, lado, 8, 0, 0, 0, 0)  # 8-bit, gris
    filas = bytearray()
    for y in range(lado):
        filas.append(0)  # byte de filtro por fila
        for x in range(lado):
            oscuro = ((x // bloque) + (y // bloque)) % 2 == 0
            filas.append(0 if oscuro else 255)
    idat = zlib.compress(bytes(filas), 9)
    return (
        firma + _chunk(b"IHDR", ihdr) + _chunk(b"IDAT", idat) + _chunk(b"IEND", b"")
    )


# --------------------------------------------------------------------------- #
# Generación
# --------------------------------------------------------------------------- #


def generar_correo(
    plantilla: Plantilla,
    *,
    tipo_usuario: str,
    token: str,
    para: str = "destinatario@correo.test",
) -> CorreoGenerado:
    """Construye el correo de prueba para `tipo_usuario` a partir de `plantilla`."""
    # Semilla determinista: el mismo token produce siempre el mismo correo.
    rnd = random.Random(f"{token}:{plantilla.id}:{tipo_usuario}")

    tipologia = plantilla.tipologia
    pretexto = fr.PRETEXTO_POR_TIPOLOGIA[tipologia]
    persona = fr.PERSONA_POR_TIPO.get(tipo_usuario) or _PERSONA_FALLBACK
    ctx = _ctx_valores(rnd, plantilla)

    # Remitente por defecto: plausible pero desde el dominio de práctica (sin I7).
    local_area = pretexto["remitente_nombre"].split()[-1].lower()
    local_area = "".join(ch for ch in local_area if ch.isalnum()) or "notificaciones"
    remitente_visible = f"{local_area}@{config.dominio_practica}"

    lienzo = _Lienzo(
        tipo_usuario=tipo_usuario,
        tipologia=tipologia,
        saludo=persona["saludo"],
        remitente_nombre=pretexto["remitente_nombre"],
        remitente_correo_visible=remitente_visible,
        area_firma=pretexto["area_firma"],
        asunto=plantilla.asunto,
    )
    # Token accesible para el realizador de QR.
    lienzo.boton_token = token  # type: ignore[attr-defined]

    # Párrafo de apertura (piel legítima de la tipología).
    intro = rnd.choice(pretexto["intro"]).format(**ctx)
    lienzo.parrafos.append(intro)
    # Las tipologías financieras/trámites mencionan una referencia creíble.
    if tipologia in {"T2", "T3"}:
        etiqueta = "Referencia" if tipologia == "T2" else "N.° de trámite"
        valor = ctx["referencia"] if tipologia == "T2" else ctx["tramite"]
        lienzo.parrafos.append(f"{etiqueta}: {valor}.")

    # Realizar cada indicio en el orden canónico.
    for indicio in _ORDEN:
        if indicio in plantilla.indicios:
            _REALIZADORES[indicio](lienzo, rnd, ctx)

    cuerpo_texto, cuerpo_html = _render(lienzo, token)

    cabeceras = {
        "X-Simulacro-Ref": token,
        "X-Entrenamiento-IESS": "simulacro-consentido",
        "X-Tipologia-Simulada": tipologia,
        "List-Unsubscribe": f"<{config.base_url}/salir/{token}>",
        "Auto-Submitted": "auto-generated",
    }

    return CorreoGenerado(
        plantilla_id=plantilla.id,
        tipo_usuario=tipo_usuario,
        tipologia=tipologia,
        indicios=tuple(plantilla.indicios),
        token=token,
        asunto=lienzo.asunto,
        remitente_nombre=lienzo.remitente_nombre,
        remitente_correo_visible=lienzo.remitente_correo_visible,
        remitente_correo_envio=f"capacitacion@{config.dominio_practica}",
        reply_to=lienzo.reply_to,
        para=para,
        cuerpo_texto=cuerpo_texto,
        cuerpo_html=cuerpo_html,
        adjuntos=lienzo.adjuntos,
        cabeceras=cabeceras,
    )


# --------------------------------------------------------------------------- #
# Render de cuerpo (texto y HTML)
# --------------------------------------------------------------------------- #


def _render(l: _Lienzo, token: str) -> tuple[str, str]:
    destino = f"{config.base_url}/p/{token}"
    firma = [
        "Atentamente,",
        l.area_firma,
        "Instituto Ecuatoriano de Seguridad Social",
    ]

    # ---- Texto plano ----
    lineas = [f"{l.saludo}:", ""]
    for p in l.parrafos:
        lineas.append(p)
        lineas.append("")
    if l.enlace_mostrado:
        lineas.append(f"Para continuar ingrese aquí: {l.enlace_mostrado}")
    else:
        lineas.append(f"Para continuar: [{l.boton_label}] {destino}")
    lineas.append("")
    lineas.extend(firma)
    texto = "\n".join(lineas)

    # ---- HTML ----
    estilo_boton = (
        "display:inline-block;background:#1b7a3d;color:#ffffff;"
        "text-decoration:none;padding:12px 22px;border-radius:8px;"
        "font-weight:700;font-family:Arial,Helvetica,sans-serif;"
    )
    parrafos_html = "\n".join(f"<p>{escape(p)}</p>" for p in l.parrafos)
    if l.enlace_mostrado:
        enlace_html = (
            f'<p>Para continuar ingrese aquí: '
            f'<a href="{escape(destino)}">{escape(l.enlace_mostrado)}</a></p>'
        )
    else:
        enlace_html = (
            f'<p style="margin:22px 0;">'
            f'<a href="{escape(destino)}" style="{estilo_boton}">'
            f"{escape(l.boton_label)}</a></p>"
        )
    qr_html = (
        '<p><img src="cid:qr" alt="Código QR" width="150" height="150"></p>'
        if any(a.cid for a in l.adjuntos)
        else ""
    )
    firma_html = "<br>".join(escape(f) for f in firma)

    html = f"""<!doctype html>
<html lang="es"><body style="margin:0;background:#f3f4f6;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0"
       style="background:#f3f4f6;padding:24px 0;">
  <tr><td align="center">
    <table role="presentation" width="600" cellpadding="0" cellspacing="0"
           style="background:#ffffff;border-radius:12px;overflow:hidden;
                  font-family:Arial,Helvetica,sans-serif;font-size:14px;
                  color:#1f2937;max-width:600px;width:100%;">
      <tr><td style="background:#1b7a3d;padding:16px 24px;color:#ffffff;
                     font-size:18px;font-weight:700;">
        IESS · Seguridad Social
      </td></tr>
      <tr><td style="padding:24px;">
        <p>{escape(l.saludo)}:</p>
        {parrafos_html}
        {enlace_html}
        {qr_html}
        <p style="margin-top:24px;">{firma_html}</p>
      </td></tr>
      <tr><td style="padding:14px 24px;background:#f9fafb;color:#6b7280;
                     font-size:11px;">
        Instituto Ecuatoriano de Seguridad Social · {escape(config.base_url)}
      </td></tr>
    </table>
  </td></tr>
</table>
</body></html>"""
    return texto, html


def microcursos_de(indicios) -> list[str]:
    """Momento enseñable: microcursos de los indicios del correo (sin repetir)."""
    vistos: list[str] = []
    for i in indicios:
        titulo = MICROCURSO_POR_INDICIO.get(i)
        if titulo and titulo not in vistos:
            vistos.append(titulo)
    return vistos


def nombre_tipo(tipo: str) -> str:
    return NOMBRE_TIPO.get(tipo, tipo)
