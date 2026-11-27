"""Fase 2.2 - Micro-simulaciones educativas (concientizacion defensiva) para el modo Entrenamiento.

Uso:  python -I ml/scripts/02_generar_simulaciones.py
Salida: ml/data/simulaciones.json  (se copia a app/assets/data/ en la Fase 3)

Garantias de seguridad de las plantillas generadas:
- Todos los enlaces usan TLD reservados (.example / .invalid / .test, RFC 2606): no resuelven.
- Los enlaces nunca son clicables en la app (campo "clicable": false).
- Cada simulacion lleva la marca "SIMULACIÓN EDUCATIVA AIESS".
"""
from __future__ import annotations

import collections
import json
import random
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from aiess_ml import config  # noqa: E402
from aiess_ml.datos import URL_RE, cargar_correos  # noqa: E402
from aiess_ml.evidencia import evidencias  # noqa: E402
from aiess_ml.osint_rules import analizar_mensaje, partir_url  # noqa: E402

MARCA = "SIMULACIÓN EDUCATIVA AIESS: este mensaje no es real."
EMAIL_RE = re.compile(r"[\w.+-]+@[\w-]+(?:\.[\w-]+)+")
RESERVADOS = tuple("." + t for t in config.CANALES["tlds_reservados"])

PISTA = {
    "I1": "Te mete prisa para que no pienses. El IESS no da plazos de horas por mensaje.",
    "I2": "Mira el dominio: no termina en iess.gob.ec.",
    "I3": "Pide tu clave o códigos. El IESS nunca los pide.",
    "I4": "El enlace está acortado o el texto muestra una dirección distinta a la real.",
    "I5": "Trae un archivo o pide instalar una app. No lo abras.",
    "I6": "Ofrece dinero que no pediste.",
    "I7": "El remitente no es una dirección oficial del IESS.",
    "I8": "Te amenaza con suspender o quitar un beneficio.",
    "I9": "Pide tu cédula, fecha de nacimiento o una selfie.",
    "I10": "Pide pagar una tasa o transferir dinero.",
    "I11": "Pide escanear un código QR desconocido.",
}


BILLETERA_RE = re.compile(r"\b(?:bc1|[13])[A-Za-z0-9]{25,60}\b|\b0x[a-fA-F0-9]{40}\b")


def sanear(texto: str, dominio: str) -> str:
    texto = URL_RE.sub(f"https://{dominio}/verificar", texto)
    texto = BILLETERA_RE.sub("[dirección de billetera]", texto)
    return EMAIL_RE.sub("usuario@correo.example", texto)


def ejercicios_del_dataset(correos, ids: set[str], n: int, rng: random.Random) -> list[dict]:
    pool = [c for c in correos if c.id in ids]
    elegidos = rng.sample([c for c in pool if c.phishing], n // 2) + rng.sample([c for c in pool if not c.phishing], n // 2)
    rng.shuffle(elegidos)
    out = []
    for c in elegidos:
        osint = analizar_mensaje(c.cuerpo, c.urls)
        marcas = []
        for k in c.activos:
            for ev in evidencias(c.cuerpo, k, 2):
                marcas.append({"indicio": k, **ev})
        out.append({
            "id": f"ej_{c.id}", "tipo": "correo", "origen": "dataset", "simulacion": True, "marca": MARCA,
            "asunto": c.asunto, "cuerpo": c.cuerpo, "adjuntos": c.adjuntos,
            "enlaces": [{"url": u["url"], "host": u["host"], "clicable": False,
                         "alertas": [h["detalle"] for h in u["hallazgos"]]} for u in osint["urls"]],
            "respuesta": "PHISHING" if c.phishing else "SEGURO",
            "indicios": c.activos, "resaltados": marcas,
            "pistas": [PISTA[k] for k in c.activos] or ["Enlaces oficiales y sin pedidos de datos, claves ni pagos."],
            "dificultad": dificultad(len(c.activos)) if c.phishing else "media",
        })
    return out


def dificultad(n: int) -> str:
    return "facil" if n >= 4 else "media" if n == 3 else "dificil"


def minar_banco(correos) -> dict:
    P = [c for c in correos if c.phishing]
    frases: dict[str, collections.Counter] = {k: collections.Counter() for k in config.INDICIOS}
    for c in P:
        for k in c.activos:
            for ev in evidencias(c.cuerpo, k, 1):
                if 25 <= len(ev["texto"]) <= 180 and not URL_RE.search(ev["texto"]):
                    frases[k][ev["texto"]] += 1
    dominios = sorted({h for c in P for u in c.urls for h in [partir_url(u)[1]] if h.endswith(RESERVADOS)})
    ctas = collections.Counter(b for c in P for b in re.findall(r"\[([^\]\n]{4,30})\]", c.cuerpo)
                               if not b.lower().startswith(("http", "imagen", "privacidad", "términos", "ayuda")))
    asuntos = collections.Counter(c.asunto for c in P)
    return {"frases": {k: [f for f, _ in v.most_common(25)] for k, v in frases.items()},
            "dominios": dominios, "ctas": [b for b, _ in ctas.most_common(12)],
            "asuntos": [a for a, _ in asuntos.most_common(40)]}


def plantillas(correos, ids_train: set[str], banco: dict, n: int, rng: random.Random) -> list[dict]:
    """Micro-simulacion = condensado coherente de UN correo de phishing de train:
    se conservan 1-3 frases-indicio, se reemplaza el enlace por un dominio reservado
    y se recalculan los indicios sobre el texto final."""
    textuales = ("I1", "I3", "I5", "I6", "I8", "I9", "I10", "I11")
    candidatos = [c for c in correos if c.phishing and c.id in ids_train and any(k in textuales for k in c.activos)]
    rng.shuffle(candidatos)
    out = []
    for i, c in enumerate(candidatos[:n]):
        sms = i % 3 == 2
        propios = [k for k in c.activos if k in textuales]
        k_texto = rng.sample(propios, min(len(propios), rng.choice([1, 2] if sms else [2, 3])))
        hosts = [partir_url(u)[1] for u in c.urls]
        reservados = [h for h in hosts if h.endswith(RESERVADOS)]
        dominio = reservados[0] if reservados else rng.choice(banco["dominios"])
        acortado = "I4" in c.activos and not reservados
        url = (f"https://acortador.example/{rng.randrange(36**5):05x}" if acortado
               else f"https://{dominio}/{rng.choice(['verificar', 'actualizar', 'reembolso', 'acceso'])}")
        lineas = list(dict.fromkeys(sanear(ev["texto"], dominio) for k in k_texto for ev in evidencias(c.cuerpo, k, 1)))
        if not lineas:
            continue
        cta = next((b for b in re.findall(r"\[([^\]\n]{4,30})\]", c.cuerpo)
                    if not b.lower().startswith(("http", "imagen", "privacidad", "términos", "ayuda"))), "Continuar")
        if sms:
            cuerpo = f"IESS: {' '.join(lineas)} Ingresa: {url}"
            asunto = ""
        else:
            cuerpo = "Estimado afiliado:\n\n" + "\n\n".join(lineas) + f"\n\n[{cta}]\n\nAtentamente,\nDepartamento de Afiliación"
            asunto = c.asunto
        inds = {k for k in c.activos if k in textuales and evidencias(cuerpo, k, 1)} | {"I2"}
        if acortado:
            inds.add("I4")
        inds_ord = sorted(inds, key=lambda k: int(k[1:]))
        out.append({
            "id": f"sim_{i:03d}", "tipo": "sms" if sms else "correo", "origen": "plantilla", "simulacion": True,
            "marca": MARCA, "asunto": asunto, "cuerpo": cuerpo, "adjuntos": [],
            "enlaces": [{"url": url, "host": partir_url(url)[1], "clicable": False, "alertas": []}],
            "respuesta": "PHISHING", "indicios": inds_ord,
            "resaltados": [{"indicio": k, **ev} for k in inds_ord for ev in evidencias(cuerpo, k, 1)],
            "basado_en": c.id,
            "pistas": [PISTA[k] for k in inds_ord], "dificultad": dificultad(len(inds_ord)),
        })
    return out


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    rng = random.Random(config.SEED)
    correos, _ = cargar_correos(config.CSV_PATH)
    split = json.loads((config.DATA_DIR / "split.json").read_text(encoding="utf-8"))
    banco = minar_banco(correos)
    # Ejercicios del split de prueba: el usuario practica con correos que el modelo no vio.
    ej = ejercicios_del_dataset(correos, set(split["test"]), 40, rng)
    sims = plantillas(correos, set(split["train"]), banco, 45, rng)
    salida = {"version": 1, "marca": MARCA, "pistas": PISTA,
              "indicios": {k: v["nombre"] for k, v in config.INDICIOS.items()},
              "contacto": config.CANALES["contacto"], "ejercicios": ej + sims}
    destino = config.DATA_DIR / "simulaciones.json"
    destino.write_text(json.dumps(salida, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{len(ej)} ejercicios del dataset + {len(sims)} plantillas -> {destino}")
    for s in sims[:3]:
        print("\n---", s["tipo"], s["indicios"], s["dificultad"], "\n", s["asunto"], "\n", s["cuerpo"])


if __name__ == "__main__":
    main()
