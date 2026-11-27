"""Adaptador de envío de correo.

Modos (variable de entorno `ENVIO_MODO`):
- `consola` (por defecto): NO envía. Escribe cada correo como `.eml` en `salida/`
  y registra un resumen. Es el modo seguro para desarrollar y demostrar.
- `mailpit`: SMTP a Mailpit (localhost:1025), que atrapa el correo sin mandarlo.
- `resend` / `brevo`: envío real por API. Requiere clave y un dominio de práctica
  con SPF/DKIM. El `From` usa el buzón del dominio de práctica (no el «parecido»).

Barrera dura: nunca se envía con un dominio de práctica que termine en iess.gob.ec.
"""

from __future__ import annotations

import smtplib
from datetime import datetime
from pathlib import Path

from .config import config
from .generador_correo import CorreoGenerado


class EnvioError(RuntimeError):
    pass


def _verificar_dominio() -> None:
    if config.dominio_practica.endswith("iess.gob.ec"):
        raise EnvioError(
            "Negado: el dominio de práctica no puede ser iess.gob.ec (regla 5)."
        )


def enviar(correo: CorreoGenerado) -> dict:
    """Envía (o simula) el correo. Devuelve un resumen para registrar/depurar."""
    _verificar_dominio()
    modo = config.envio_modo
    if modo == "consola":
        return _modo_consola(correo)
    if modo == "mailpit":
        return _modo_smtp(correo, config.mailpit_host, config.mailpit_port)
    if modo == "resend":
        return _modo_resend(correo)
    if modo == "brevo":
        return _modo_brevo(correo)
    raise EnvioError(f"ENVIO_MODO desconocido: {modo}")


def _nombre_archivo(correo: CorreoGenerado) -> str:
    sello = datetime.now().strftime("%Y%m%d-%H%M%S")
    return f"{sello}_{correo.plantilla_id}_{correo.tipo_usuario}_{correo.token[:8]}.eml"


def _modo_consola(correo: CorreoGenerado) -> dict:
    carpeta: Path = config.salida_dir
    carpeta.mkdir(parents=True, exist_ok=True)
    ruta = carpeta / _nombre_archivo(correo)
    # Se guarda tal como lo vería la persona (remitente visible, incluido el
    # dominio «parecido» cuando hay I7).
    ruta.write_text(correo.como_eml(usar_remitente_envio=False), encoding="utf-8")
    return {
        "modo": "consola",
        "enviado": False,
        "archivo": str(ruta),
        "para": correo.para,
        "asunto": correo.asunto,
        "remitente_visible": correo.remitente_correo_visible,
        "tipologia": correo.tipologia,
        "indicios": list(correo.indicios),
    }


def _modo_smtp(correo: CorreoGenerado, host: str, puerto: int) -> dict:
    # En SMTP real el sobre usa el dominio de práctica verificado.
    mensaje = correo.construir_mime(usar_remitente_envio=True)
    try:
        with smtplib.SMTP(host, puerto, timeout=10) as smtp:
            smtp.send_message(
                mensaje,
                from_addr=correo.remitente_correo_envio,
                to_addrs=[correo.para],
            )
    except OSError as exc:  # Mailpit apagado, etc.
        raise EnvioError(f"No se pudo conectar a SMTP {host}:{puerto}: {exc}") from exc
    return {
        "modo": "mailpit",
        "enviado": True,
        "para": correo.para,
        "asunto": correo.asunto,
        "remitente_envio": correo.remitente_correo_envio,
    }


def _modo_resend(correo: CorreoGenerado) -> dict:
    if not config.resend_api_key:
        raise EnvioError("Falta RESEND_API_KEY.")
    try:
        import httpx  # import local: solo se necesita en este modo
    except ImportError as exc:  # pragma: no cover
        raise EnvioError("Instala httpx para el modo resend.") from exc

    carga = {
        "from": f"{correo.remitente_nombre} <{correo.remitente_correo_envio}>",
        "to": [correo.para],
        "subject": correo.asunto,
        "html": correo.cuerpo_html,
        "text": correo.cuerpo_texto,
        "headers": correo.cabeceras,
    }
    if correo.reply_to:
        carga["reply_to"] = correo.reply_to
    resp = httpx.post(
        "https://api.resend.com/emails",
        headers={"Authorization": f"Bearer {config.resend_api_key}"},
        json=carga,
        timeout=15,
    )
    if resp.status_code >= 300:
        raise EnvioError(f"Resend respondió {resp.status_code}: {resp.text}")
    return {"modo": "resend", "enviado": True, "respuesta": resp.json()}


def _modo_brevo(correo: CorreoGenerado) -> dict:
    if not config.brevo_api_key:
        raise EnvioError("Falta BREVO_API_KEY.")
    try:
        import httpx
    except ImportError as exc:  # pragma: no cover
        raise EnvioError("Instala httpx para el modo brevo.") from exc

    carga = {
        "sender": {
            "name": correo.remitente_nombre,
            "email": correo.remitente_correo_envio,
        },
        "to": [{"email": correo.para}],
        "subject": correo.asunto,
        "htmlContent": correo.cuerpo_html,
        "textContent": correo.cuerpo_texto,
        "headers": correo.cabeceras,
    }
    resp = httpx.post(
        "https://api.brevo.com/v3/smtp/email",
        headers={"api-key": config.brevo_api_key},
        json=carga,
        timeout=15,
    )
    if resp.status_code >= 300:
        raise EnvioError(f"Brevo respondió {resp.status_code}: {resp.text}")
    return {"modo": "brevo", "enviado": True, "respuesta": resp.json()}
