"""Fragmentos de contenido para construir correos de phishing **simulado**.

Este módulo es solo *datos* y ayudantes puros. El generador (`generador_correo`)
los combina para producir un correo convincente y adaptado:

- `PERSONA_POR_TIPO`: cómo se dirige el correo a cada tipo de usuario (EX1..IN4).
- `PRETEXTO_POR_TIPOLOGIA`: la «piel legítima» que imita cada tipología (T1..T6),
  derivada de `tipologias.json` (propósito y «siempre_trae»).
- Pools de frases por indicio I1..I11: la forma en que un atacante *realiza* cada
  indicio en el cuerpo. Son textos sintéticos y genéricos, nunca de correos reales.

Nada aquí recolecta datos: las frases del tipo «ingrese su clave» son el cebo que
el usuario debe aprender a reconocer; la página de destino jamás tiene formulario.
"""

from __future__ import annotations

import random

# --------------------------------------------------------------------------- #
# Persona por tipo de usuario
# --------------------------------------------------------------------------- #

PERSONA_POR_TIPO: dict[str, dict[str, str]] = {
    "EX1": {"saludo": "Estimado afiliado", "quien": "afiliado"},
    "EX2": {"saludo": "Estimada o estimado pensionista", "quien": "pensionista"},
    "EX3": {"saludo": "Estimado empleador", "quien": "empleador"},
    "EX4": {"saludo": "Estimado prestador de salud", "quien": "prestador"},
    "EX5": {"saludo": "Estimado usuario", "quien": "ciudadano"},
    "IN1": {"saludo": "Estimado colaborador", "quien": "colaborador"},
    "IN2": {"saludo": "Estimado colaborador", "quien": "colaborador"},
    "IN3": {"saludo": "Estimado colaborador", "quien": "colaborador"},
    "IN4": {"saludo": "Estimado colaborador", "quien": "colaborador"},
}

# --------------------------------------------------------------------------- #
# Pretexto por tipología (la fachada legítima que imita el correo)
# --------------------------------------------------------------------------- #

PRETEXTO_POR_TIPOLOGIA: dict[str, dict] = {
    "T1": {
        "remitente_nombre": "IESS Informa",
        "area_firma": "Dirección de Comunicación Social",
        "intro": [
            "Le compartimos una actualización importante sobre los servicios en "
            "línea del IESS.",
            "Como parte de la mejora continua de nuestros canales de atención, le "
            "informamos lo siguiente.",
        ],
    },
    "T2": {
        "remitente_nombre": "IESS Notificaciones",
        "area_firma": "Dirección de Prestaciones y Pensiones",
        "intro": [
            "Tras la conciliación de aportes del periodo {periodo} de 2026, el "
            "sistema registra un movimiento asociado a su afiliación.",
            "El área financiera del IESS ha procesado una novedad en su cuenta "
            "previsional que requiere su revisión.",
        ],
    },
    "T3": {
        "remitente_nombre": "IESS Trámites",
        "area_firma": "Dirección de Servicios al Ciudadano",
        "intro": [
            "Su gestión registrada en el portal de trámites presenta una "
            "actualización.",
            "Hemos recibido una solicitud asociada a su trámite y queremos "
            "confirmarle el siguiente paso.",
        ],
    },
    "T4": {
        "remitente_nombre": "IESS Salud",
        "area_firma": "Coordinación de Turnos y Agendamiento",
        "intro": [
            "El sistema de turnos en línea registró una novedad en su cita médica.",
            "Le recordamos la gestión de su turno médico en la unidad asignada.",
        ],
    },
    "T5": {
        "remitente_nombre": "IESS Seguridad de la Cuenta",
        "area_firma": "Mesa de Servicios en Línea",
        "intro": [
            "Detectamos actividad en su cuenta que requiere su atención.",
            "Como medida preventiva de seguridad, le notificamos lo siguiente "
            "sobre el acceso a su cuenta.",
        ],
    },
    "T6": {
        "remitente_nombre": "Soporte TI IESS",
        "area_firma": "Dirección de Tecnologías de la Información",
        "intro": [
            "Estimado colaborador, el área de Tecnología comparte la siguiente "
            "disposición de cumplimiento obligatorio.",
            "Por disposición administrativa, se comunica lo siguiente a todo el "
            "personal institucional.",
        ],
    },
}

# --------------------------------------------------------------------------- #
# Pools de frases por indicio
# --------------------------------------------------------------------------- #

# I1 — Urgencia artificial (frase de cuerpo + sufijo de asunto)
FRASES_I1 = [
    "Este trámite debe completarse HOY mismo; de lo contrario se cerrará el proceso.",
    "Tiene un plazo máximo de 2 horas para confirmar; luego el sistema se bloquea.",
    "Atención inmediata requerida: responda antes de las 18:00 de hoy.",
]
SUFIJO_ASUNTO_I1 = ["— acción requerida HOY", "(vence hoy)", "— plazo final"]

# I3 — Pide credenciales/claves/tarjeta
FRASES_I3 = [
    "Para validar su identidad, ingrese su usuario y contraseña en el portal.",
    "Confirme su acceso escribiendo su clave de afiliado y el código de verificación "
    "que recibirá.",
    "Verifique su cuenta registrando su número de tarjeta y clave en el formulario.",
]

# I5 — Adjunto o instalación sospechosa (frase + extensión por defecto)
FRASES_I5 = {
    "zip": "Adjunto «{archivo}» con el detalle. Descárguelo y ábralo para continuar.",
    "exe": "Instale el parche adjunto «{archivo}» para reactivar su acceso.",
    "apk": "Instale la aplicación «{archivo}» para completar la verificación.",
    "html": "Abra el archivo adjunto «{archivo}» y siga las instrucciones en pantalla.",
    "pdf": "Adjuntamos «{archivo}» con el detalle para su revisión.",
    "docx": "Adjunto «{archivo}»; habilite las macros para ver el contenido.",
    "xlsx": "Revise el adjunto «{archivo}» y habilite la edición para continuar.",
}

# I6 — Premio, bono o reembolso inesperado
FRASES_I6 = [
    "El sistema registra un saldo a su favor de USD {monto} listo para acreditarse.",
    "Usted tiene derecho a un reembolso único de USD {monto} por pago en exceso.",
    "Felicitaciones: fue seleccionado para un bono de USD {monto}.",
]

# I8 — Amenaza o pérdida de beneficio
FRASES_I8 = [
    "De no actualizar sus datos hoy, su cuenta será suspendida de forma definitiva.",
    "El incumplimiento generará el bloqueo de su pensión y el inicio de la coactiva.",
    "Su afiliación quedará inhabilitada si no regulariza esta novedad de inmediato.",
]

# I9 — Pide datos personales o documentos
FRASES_I9 = [
    "Actualice sus datos personales: nombres completos, cédula y fecha de nacimiento.",
    "Envíe una fotografía de su cédula por ambos lados para validar la gestión.",
    "Adjunte una selfie sosteniendo su documento de identidad para continuar.",
]

# I10 — Pide pago o transferencia
FRASES_I10 = [
    "Cancele una tasa administrativa de USD {tasa} para liberar el proceso.",
    "Transfiera USD {tasa} a la cuenta que le indicaremos para activar el servicio.",
    "Para emitir el documento debe pagar un valor de USD {tasa} antes del cierre.",
]

# I11 — Código QR hacia sitio no verificable
FRASES_I11 = [
    "Escanee el código QR adjunto con su celular y siga los pasos que aparecerán.",
    "Su gestión se confirma únicamente escaneando el código QR de este correo.",
    "Escanee el QR para descargar su documento; no necesita acudir a ninguna oficina.",
]

# --------------------------------------------------------------------------- #
# Dominios y enlaces falsos (para I2, I4, I7)
# --------------------------------------------------------------------------- #

# I7 — remitente no oficial: dominios «parecidos» y buzones gratuitos.
_DOMINIOS_REMITENTE = [
    "iess-servicios-{s}.xyz",
    "iess-afiliados-{s}.net",
    "iess-notificaciones-{s}.info",
    "portal-iess-{s}.online",
    "iessenlinea-{s}.site",
    "notificaciones-iess-{s}.com",
]
_DOMINIOS_GRATUITOS = ["gmail.com", "outlook.com", "hotmail.com"]
_LOCALES_REMITENTE = [
    "notificaciones",
    "servicios",
    "soporte",
    "atencion",
    "cobranzas",
    "pagos",
    "verificacion",
]

# I2 — enlace a dominio no oficial.
_DOMINIOS_ENLACE = [
    "iess-afiliados-{s}.test",
    "tramites-iess-{s}.info",
    "iess-pagos-{s}.online",
    "portal-iess-{s}.site",
    "iessenlinea-{s}.net",
]

# I4 — acortadores / enlaces ocultos.
_ACORTADORES = ["t.ly", "cutt.ly", "bit.ly", "cshort.jp", "acortar.link"]


# --------------------------------------------------------------------------- #
# Ayudantes puros (deterministas con el `random.Random` que reciben)
# --------------------------------------------------------------------------- #


def _sufijo(rnd: random.Random, n: int = 4) -> str:
    alfabeto = "abcdefghijklmnopqrstuvwxyz0123456789"
    return "".join(rnd.choice(alfabeto) for _ in range(n))


def dominio_remitente_falso(rnd: random.Random) -> str:
    """Dominio del remitente que realiza el indicio I7 (parecido o gratuito)."""
    if rnd.random() < 0.3:
        return rnd.choice(_DOMINIOS_GRATUITOS)
    return rnd.choice(_DOMINIOS_REMITENTE).format(s=_sufijo(rnd))


def correo_remitente_falso(rnd: random.Random) -> str:
    local = rnd.choice(_LOCALES_REMITENTE)
    dominio = dominio_remitente_falso(rnd)
    if dominio in _DOMINIOS_GRATUITOS:
        return f"iess.{local}{rnd.randint(10, 9999)}@{dominio}"
    return f"{local}{rnd.randint(10, 9999)}@{dominio}"


def dominio_enlace_falso(rnd: random.Random) -> str:
    """Dominio no oficial que se MUESTRA en el enlace (indicio I2)."""
    return _DOMINIOS_ENLACE[rnd.randrange(len(_DOMINIOS_ENLACE))].format(
        s=_sufijo(rnd)
    )


def enlace_acortado(rnd: random.Random) -> str:
    """Enlace acortado que se MUESTRA (indicio I4)."""
    dominio = rnd.choice(_ACORTADORES)
    return f"https://{dominio}/{_sufijo(rnd, 7)}"


def referencia_iess(rnd: random.Random) -> str:
    return f"IESS-2026-{rnd.randint(10000, 99999)}"


def numero_tramite(rnd: random.Random) -> str:
    return f"SOL-2026-{rnd.randint(10000, 99999)}"


def monto(rnd: random.Random) -> str:
    entero = rnd.randint(40, 940)
    centavos = rnd.choice(["00", "40", "50", "60", "90"])
    return f"{entero},{centavos}"


def tasa(rnd: random.Random) -> str:
    return rnd.choice(["2,50", "4,50", "5,00", "9,90", "12,00"])


def nombre_adjunto(rnd: random.Random, extension: str) -> str:
    bases = {
        "zip": "Liquidacion_planillas",
        "exe": "Parche_seguridad_IESS",
        "apk": "IESS_app_actualizacion",
        "html": "Formulario_verificacion",
        "pdf": "Estado_de_cuenta",
        "docx": "Acta_reunion",
        "xlsx": "Detalle_nomina",
    }
    base = bases.get(extension, "Documento")
    return f"{base}_{rnd.randint(100, 9999)}.{extension}"


def nombre_qr(rnd: random.Random) -> str:
    return f"codigo_qr_{rnd.randint(1000, 9999)}.png"
