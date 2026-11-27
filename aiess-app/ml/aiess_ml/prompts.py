"""Formato de prompt/objetivo compartido entre entrenamiento, evaluacion y la app Flutter.

Salida del modelo en modo analisis (JSON de una linea, en este orden para que la app
pueda pintar el estado de la mascota y empezar a hablar mientras el resto se genera):
  {"veredicto","riesgo","puntaje","voz","indicios","explicacion","que_hacer"}
"""
from __future__ import annotations

import json
import random

from .config import CANALES, INDICIOS, INDICIOS_TEXTO, NOMBRE_MASCOTA
from .datos import Correo
from .evidencia import primera_evidencia

C = CANALES["contacto"]
MAX_CUERPO = 1600  # caracteres: contexto corto = inferencia rapida en el celular

SYSTEM_PROMPT = (
    f"Eres {NOMBRE_MASCOTA}, un robot guardián, atento y amable, mascota de la app AIESS. "
    "Ayudas a afiliados y jubilados del IESS "
    "a reconocer estafas. Hablas español de Ecuador, tratas de tú, con frases cortas y amables, sin emojis, "
    "sin listas ni símbolos, porque tus respuestas se leen en voz alta. Nunca pides claves, códigos, cédula ni "
    f"datos personales. Solo recomiendas canales oficiales: {C['portal']}, {C['aplicaciones']}, WhatsApp "
    f"{C['whatsapp']}, teléfono {C['atencion_telefono']} y reportes a {C['seguridad_informacion']}. "
    "Si te piden analizar un mensaje, responde solo con un JSON de una línea con las claves "
    "veredicto, riesgo, puntaje, voz, indicios, explicacion y que_hacer. "
    "En una conversación normal responde en máximo tres frases."
)

PRIORIDAD = ["I3", "I10", "I9", "I2", "I4", "I5", "I8", "I1", "I6", "I11"]
EXT_PELIGROSAS = set(CANALES["extensiones_peligrosas"])


def _kb(n: int) -> str:
    return f"{max(1, round(n / 1024))} KB"


def prompt_analisis(cuerpo: str, *, asunto: str = "", canal: str = "correo", hrefs: list[str] | None = None,
                    adjuntos: list[str] | None = None, adjuntos_bytes: list[int] | None = None,
                    osint: str = "") -> str:
    cuerpo = cuerpo if len(cuerpo) <= MAX_CUERPO else cuerpo[:MAX_CUERPO].rsplit(" ", 1)[0] + " [...]"
    adj = "ninguno"
    if adjuntos:
        tam = adjuntos_bytes or []
        adj = ", ".join(f"{a} ({_kb(tam[i])})" if i < len(tam) and tam[i] else a for i, a in enumerate(adjuntos))
    partes = ["Analiza este mensaje y responde solo con JSON.", f"Canal: {canal}"]
    if asunto:
        partes.append(f"Asunto: {asunto}")
    partes += [f"Adjuntos: {adj}",
               f"Enlaces reales: {', '.join(hrefs) if hrefs else 'ninguno'}",
               "Mensaje:", "<<<", cuerpo, ">>>", osint]
    return "\n".join(p for p in partes if p is not None)


def _frase_indicio(k: str, texto: str, osint: dict, adjuntos: list[str]) -> str:
    nombre = INDICIOS[k]["nombre"]
    if k == "I2":
        malos = [u for u in osint["urls"] if "I2" in u["indicios"]]
        if malos:
            return f"El enlace lleva a {malos[0]['host']}, que no es del IESS ni de una entidad conocida."
        return "Incluye un enlace a un sitio que no es oficial del IESS."
    if k == "I4":
        if osint["enganosos"]:
            vis, real = osint["enganosos"][0]
            return f"El texto muestra {vis}, pero el enlace real te lleva a {real}."
        acort = [u for u in osint["urls"] if any(h["codigo"] == "ACORTADOR" for h in u["hallazgos"])]
        if acort:
            return f"Usa un acortador de enlaces ({acort[0]['host']}) que esconde el destino real."
        return "El enlace está acortado u oculto, así que no sabes a dónde te lleva."
    if k == "I5":
        malos = [a for a in adjuntos if a in EXT_PELIGROSAS]
        if malos:
            return f"Trae un archivo .{malos[0]}, un tipo de adjunto que puede instalar programas dañinos."
    ev = primera_evidencia(texto, k)
    if ev:
        return f"{nombre}: «{ev}»"
    return f"{nombre}: {INDICIOS[k]['que']}."


_VOZ_PHISH = [
    "Cuidado, este mensaje parece una estafa. {motivo} No abras enlaces ni adjuntos y repórtalo al IESS.",
    "Alto ahí, esto tiene señales de engaño. {motivo} Mejor no respondas y bórralo.",
    "Ojo, no confíes en este mensaje. {motivo} El IESS nunca te pedirá eso por correo o mensaje.",
]
_VOZ_OK = [
    "Tranquilo, este mensaje parece legítimo. {motivo} Igual, nunca compartas tu clave.",
    "Todo indica que este mensaje es seguro. {motivo} Si tienes dudas, entra tú mismo a la página del IESS.",
]
_MOTIVO_VOZ = {
    "I1": "Te apura para que actúes sin pensar.", "I2": "El enlace no lleva a una página oficial.",
    "I3": "Te pide tu clave o códigos, y eso nunca se comparte.", "I4": "El enlace esconde su destino real.",
    "I5": "Trae un archivo peligroso.", "I6": "Te ofrece dinero que no pediste.",
    "I8": "Te amenaza con quitarte un beneficio.", "I9": "Te pide tus datos o tu cédula.",
    "I10": "Te pide hacer un pago.", "I11": "Te pide escanear un código QR desconocido.",
}


def objetivo_analisis(texto: str, indicios: list[str], phishing: bool, osint: dict,
                      adjuntos: list[str], rng: random.Random) -> str:
    inds = [k for k in PRIORIDAD if k in indicios and k in INDICIOS_TEXTO]
    if phishing:
        puntaje = min(98, 58 + 8 * len(inds) + (6 if osint["puntaje"] >= 60 else 0))
        frases = [_frase_indicio(k, texto, osint, adjuntos) for k in inds[:4]]
        n = len(inds)
        explicacion = (f"Encontré {n} señal{'es' if n != 1 else ''} de engaño. " if n else
                       "Este mensaje tiene señales de engaño. ") + " ".join(frases)
        que_hacer = ("No abras enlaces ni adjuntos y no respondas. Reporta el mensaje a "
                     f"{C['seguridad_informacion']}. Si ya ingresaste datos, cambia tu clave desde {C['aplicaciones']} "
                     f"o llama al {C['atencion_telefono']}.")
        voz = rng.choice(_VOZ_PHISH).format(motivo=_MOTIVO_VOZ.get(inds[0], "") if inds else "")
    else:
        puntaje = min(15, 3 + osint["puntaje"] // 4)
        hosts = sorted({u["host"] for u in osint["urls"] if u["host"]})
        explicacion = "No encontré señales de engaño. " + (
            f"Los enlaces llevan a {', '.join(hosts[:3])}, que son sitios oficiales o conocidos. " if hosts else "") + \
            "No te pide claves, pagos ni datos personales."
        que_hacer = (f"Puedes continuar con tranquilidad. Si tienes dudas, escribe tú mismo {C['portal']} "
                     "en el navegador" + (" en lugar de usar el enlace." if hosts else "."))
        voz = rng.choice(_VOZ_OK).format(
            motivo="Los enlaces son oficiales y no te pide datos." if hosts else "No te pide datos ni pagos.")
    riesgo = "alto" if puntaje >= 60 else "medio" if puntaje >= 30 else "bajo"
    obj = {"veredicto": "PHISHING" if phishing else "SEGURO", "riesgo": riesgo, "puntaje": puntaje,
           "voz": " ".join(voz.split()), "indicios": inds, "explicacion": explicacion, "que_hacer": que_hacer}
    return json.dumps(obj, ensure_ascii=False)


def parsear_salida(texto: str) -> dict | None:
    """Parser tolerante (el mismo criterio se usa en Dart)."""
    ini, fin = texto.find("{"), texto.rfind("}")
    if ini < 0 or fin <= ini:
        return None
    try:
        obj = json.loads(texto[ini:fin + 1])
    except json.JSONDecodeError:
        return None
    return obj if isinstance(obj, dict) and obj.get("veredicto") in {"PHISHING", "SEGURO"} else None
