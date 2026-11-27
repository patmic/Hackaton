"""Lexico por indicio (sobre texto plegado) y extraccion de evidencia con offsets."""
from __future__ import annotations

import re

from .datos import oraciones, plegar

LEXICO: dict[str, re.Pattern] = {k: re.compile(v) for k, v in {
    "I1": r"\b(hoy mismo|de inmediato|inmediat[oa]mente|urgente|urgencia|ultimo aviso|ultima oportunidad|"
          r"en las proximas \d+|dentro de (las )?(\d+|veinticuatro|cuarenta y ocho) (horas|minutos|dias)|"
          r"\d+\s?(h|horas|minutos)\b|antes de (las|que)|plazo (maximo|de|limite)|vence (hoy|manana)|caduca|expira|"
          r"lo antes posible|sin demora)",
    "I3": r"\b(contrasena|clave|usuario y|credencial\w*|codigo de (verificacion|seguridad|acceso)|codigo que (le|te)|"
          r"\bpin\b|\botp\b|token|tarjeta|cvv|inicie sesion|iniciar sesion|ingrese su usuario)",
    "I5": r"(\.(zip|rar|exe|apk|html?|docm|xlsm|iso|js|scr|msi)\b|instal(e|ar|a) (la |nuestra |esta )?(aplicacion|app)|"
          r"descargue (la )?(app|aplicacion)|habilite (el contenido|las macros)|macros)",
    "I6": r"\b(reembolso|bono|premio|ganad(or|ora)|sorteo|devolucion|beneficio (unico|especial|extraordinario)|"
          r"derecho a (un|una|recibir)|acreditar\w*|usd\s?\d|\$\s?\d)",
    "I8": r"\b(suspend\w*|bloque\w*|multa|embargo|perdida|perdera|cancelacion|cancelad[oa]|desactiv\w*|sancion\w*|"
          r"proceso (judicial|legal|coactivo)|citacion|demanda|accion legal|coactiva|expediente)",
    "I9": r"\b(cedula|fecha de nacimiento|selfie|fotografia de su|foto de su|documento de identidad|datos personales|"
          r"direccion domiciliaria|estado civil)",
    "I10": r"\b(pago|pague|cancele|transfer\w*|deposit\w*|tasa|arancel|criptomoneda\w*|bitcoin|usdt|abono|comision)",
    "I11": r"(\bqr\b|escane\w*)",
}.items()}

# Lineas de pie de pagina que nunca son evidencia.
_BOILERPLATE = re.compile(r"(confidencial|no responda|mensaje generado|imagen:|privacidad|terminos|ayuda\]?$)")


def evidencias(texto: str, indicio: str, max_n: int = 2) -> list[dict]:
    pat = LEXICO.get(indicio)
    if not pat:
        return []
    res = []
    for ini, fin, frase in oraciones(texto):
        pf = plegar(frase)
        if _BOILERPLATE.search(pf):
            continue
        if pat.search(pf):
            res.append({"inicio": ini, "fin": fin, "texto": frase.strip()})
            if len(res) >= max_n:
                break
    return res


def primera_evidencia(texto: str, indicio: str, max_chars: int = 140) -> str | None:
    ev = evidencias(texto, indicio, 1)
    if not ev:
        return None
    t = ev[0]["texto"]
    return t if len(t) <= max_chars else t[: max_chars - 3].rsplit(" ", 1)[0] + "..."
