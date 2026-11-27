"""Fase 2.3 - Dataset de instrucciones (SFT) para LFM2: análisis + conversación del robot.

Uso:  python -I ml/scripts/03_construir_sft.py
Salida: ml/data/sft/{train,val,test}.jsonl  formato TRL "prompt-completion" conversacional:
  {"prompt":[{role:system},{role:user}], "completion":[{role:assistant}], "tarea": ..., "id": ...}

Variantes por correo (solo en train se aumentan):
  correo        -> correo completo + enlaces reales + adjuntos + [OSINT]
  notificacion  -> lo que ve el NotificationListener: asunto + ~160 caracteres, sin hrefs (flujo tipo Truecaller)
  sms           -> condensado corto con el enlace en el texto
  url           -> solo el enlace pegado por el usuario
"""
from __future__ import annotations

import collections
import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from aiess_ml import config  # noqa: E402
from aiess_ml.datos import URL_RE, Correo, cargar_correos, oraciones  # noqa: E402
from aiess_ml.evidencia import LEXICO, evidencias  # noqa: E402
from aiess_ml.datos import plegar  # noqa: E402
from aiess_ml.osint_rules import analizar_mensaje, resumen_osint  # noqa: E402
from aiess_ml.persona import ejemplos_chat  # noqa: E402
from aiess_ml.prompts import SYSTEM_PROMPT, objetivo_analisis, prompt_analisis  # noqa: E402

TEXTUALES = {"I1", "I3", "I5", "I6", "I8", "I9", "I10", "I11"}


def red_simulada(osint: dict, phishing: bool, rng: random.Random) -> list[str] | None:
    """En el celular la app puede anadir verificaciones de red reales. Aqui se simulan en ~35% de
    ejemplos (con ruido: muchos sitios de phishing tienen SSL valido) para que el modelo aprenda a
    usarlas sin depender de ellas. El 65% restante dice 'no realizada' (modo sin conexion)."""
    if not osint["urls"] or rng.random() > 0.35:
        return None
    u = osint["urls"][0]
    if u["confiable"]:
        return [f"Red: {u['host']} con certificado SSL válido; dominio registrado hace más de 5 años; sin redirecciones"]
    if not phishing:
        return [f"Red: {u['host']} con certificado SSL válido; sin redirecciones"]
    ssl = rng.choice(["certificado SSL válido (gratuito)", "certificado SSL válido (gratuito)", "sin certificado SSL",
                      "certificado no coincide con el dominio"])
    edad = rng.choice([f"dominio registrado hace {rng.randint(1, 45)} días", "edad del dominio desconocida"])
    red = rng.choice(["sin redirecciones", f"redirige {rng.randint(1, 3)} veces a otro dominio"])
    return [f"Red: {u['host']} con {ssl}; {edad}; {red}"]


def ejemplo(id_: str, tarea: str, user: str, assistant: str) -> dict:
    return {"id": id_, "tarea": tarea,
            "prompt": [{"role": "system", "content": SYSTEM_PROMPT}, {"role": "user", "content": user}],
            "completion": [{"role": "assistant", "content": assistant}]}


def indicios_en(texto: str, base: list[str], osint: dict) -> list[str]:
    """Indicios que siguen siendo observables tras recortar el mensaje."""
    pf = plegar(texto)
    vis = {k for k in base if k in TEXTUALES and LEXICO[k].search(pf)}
    return sorted(vis | (set(osint["indicios"]) & {"I2", "I4"}), key=lambda k: int(k[1:]))


def variante_correo(c: Correo, rng) -> dict:
    osint = analizar_mensaje(c.cuerpo, c.urls)
    user = prompt_analisis(c.cuerpo, asunto=c.asunto, canal="correo", hrefs=c.urls, adjuntos=c.adjuntos,
                           adjuntos_bytes=c.adjuntos_bytes, osint=resumen_osint(osint, red_simulada(osint, c.phishing, rng)))
    inds = [k for k in c.activos if k != "I7"]
    return ejemplo(c.id, "analisis_correo", user, objetivo_analisis(c.cuerpo, inds, c.phishing, osint, c.adjuntos, rng))


def variante_notificacion(c: Correo, rng) -> dict | None:
    frases = [t for _, _, t in oraciones(c.cuerpo) if not t.lower().startswith(("estimad", "hola", "[imagen"))]
    snippet = " ".join(frases)[:160].rsplit(" ", 1)[0]
    if len(snippet) < 30:
        return None
    osint = analizar_mensaje(snippet, URL_RE.findall(snippet))
    inds = indicios_en(f"{c.asunto} {snippet}", c.activos, osint)
    phishing = c.phishing and bool(inds)
    if c.phishing and not phishing:
        return None  # el recorte no deja evidencia: no se ensena a adivinar
    app = rng.choice(["Gmail", "Outlook", "Correo"])
    user = prompt_analisis(snippet, asunto=c.asunto, canal=f"notificación de {app} (vista previa)",
                           osint=resumen_osint(osint))
    return ejemplo(c.id + "_notif", "analisis_notificacion", user,
                   objetivo_analisis(f"{c.asunto}. {snippet}", inds, phishing, osint, [], rng))


def variante_sms(c: Correo, rng) -> dict | None:
    if not c.urls:
        return None
    evs = [ev["texto"] for k in c.activos if k in TEXTUALES for ev in evidencias(c.cuerpo, k, 1)]
    if c.phishing and not evs:
        return None
    if not c.phishing:
        evs = [t for _, _, t in oraciones(c.cuerpo)][1:3]
    texto = " ".join(dict.fromkeys(evs))[:220] + f" {c.urls[0]}"
    osint = analizar_mensaje(texto, [c.urls[0]])
    inds = indicios_en(texto, c.activos, osint)
    phishing = c.phishing and bool(inds)
    if c.phishing and not phishing:
        return None
    canal = rng.choice(["SMS", "WhatsApp"])
    user = prompt_analisis(texto, canal=canal, hrefs=[c.urls[0]],
                           osint=resumen_osint(osint, red_simulada(osint, phishing, rng)))
    return ejemplo(c.id + "_sms", "analisis_sms", user, objetivo_analisis(texto, inds, phishing, osint, [], rng))


def variantes_url(correos: list[Correo], rng) -> list[dict]:
    clase = collections.defaultdict(set)
    for c in correos:
        for u in c.urls:
            clase[u].add(c.phishing)
    out = []
    for u, etiquetas in sorted(clase.items()):
        if len(etiquetas) != 1:
            continue
        phishing = etiquetas.pop()
        osint = analizar_mensaje(u, [u])
        inds = sorted(set(osint["indicios"]) & {"I2", "I4"}, key=lambda k: int(k[1:]))
        if phishing and not inds:
            continue
        user = prompt_analisis(u, canal="enlace pegado", hrefs=[u],
                               osint=resumen_osint(osint, red_simulada(osint, phishing, rng)))
        out.append(ejemplo("url_" + str(len(out)), "analisis_url", user, objetivo_analisis(u, inds, phishing, osint, [], rng)))
    return out


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    rng = random.Random(config.SEED)
    correos, _ = cargar_correos(config.CSV_PATH)
    split = json.loads((config.DATA_DIR / "split.json").read_text(encoding="utf-8"))
    por_id = {c.id: c for c in correos}
    salida: dict[str, list[dict]] = {}
    for nombre, ids in split.items():
        cs = [por_id[i] for i in ids if i in por_id]
        ej = [variante_correo(c, rng) for c in cs]
        ej += [e for c in cs if (e := variante_notificacion(c, rng))]       # tambien en val/test: es el flujo principal
        if nombre == "train":
            ej += [e for c in cs if rng.random() < 0.5 and (e := variante_sms(c, rng))]
            ej += variantes_url(cs, rng)
        salida[nombre] = ej
    chat = ejemplos_chat(SYSTEM_PROMPT, seed=config.SEED)
    rng.shuffle(chat)
    n_val = max(8, len(chat) // 10)
    salida["val"] += chat[:n_val]
    salida["train"] += chat[n_val:]

    destino = config.DATA_DIR / "sft"
    destino.mkdir(parents=True, exist_ok=True)
    for nombre, ej in salida.items():
        rng.shuffle(ej)
        with open(destino / f"{nombre}.jsonl", "w", encoding="utf-8") as f:
            for e in ej:
                f.write(json.dumps(e, ensure_ascii=False) + "\n")
        print(f"{nombre}: {len(ej)} ejemplos {dict(collections.Counter(e['tarea'] for e in ej))}")
    muestra = next(e for e in salida["train"] if e["tarea"] == "analisis_correo")
    print("\n=== USER ===\n" + muestra["prompt"][1]["content"] + "\n=== ASSISTANT ===\n" + muestra["completion"][0]["content"])
    largo = max(len(e["prompt"][0]["content"]) + len(e["prompt"][1]["content"]) + len(e["completion"][0]["content"])
                for v in salida.values() for e in v)
    print(f"\nEjemplo mas largo: {largo} caracteres (~{largo // 3} tokens)")


if __name__ == "__main__":
    main()
