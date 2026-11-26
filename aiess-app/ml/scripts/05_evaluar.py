"""Fase 2.5 - Evaluacion sobre ml/data/sft/test.jsonl.

  python -I ml/scripts/05_evaluar.py --backend reglas                       # baseline OSINT+lexico (sin GPU)
  python ml/scripts/05_evaluar.py --backend hf   --modelo ml/outputs/lfm2-1.2b-lora/merged
  python ml/scripts/05_evaluar.py --backend gguf --modelo ml/outputs/gguf/aiess-lfm2-1.2b-Q4_K_M.gguf

Evaluar el GGUF cuantizado es obligatorio: es el archivo que corre en el celular.
Salida: ml/reports/eval_<backend>.json
"""
from __future__ import annotations

import argparse
import collections
import json
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from aiess_ml import config  # noqa: E402
from aiess_ml.datos import plegar  # noqa: E402
from aiess_ml.evidencia import LEXICO  # noqa: E402
from aiess_ml.prompts import parsear_salida  # noqa: E402


def generador_reglas():
    """Baseline determinista = capa rapida de la app (corre en cada notificacion en milisegundos)."""
    fuertes = ("I3", "I5", "I9", "I10", "I11")

    def gen(mensajes):
        user = mensajes[-1]["content"]
        cuerpo = user.split("<<<", 1)[-1].split(">>>", 1)[0]
        osint = user.split("[OSINT]", 1)[-1]
        inds = {k for k in fuertes if LEXICO[k].search(plegar(cuerpo))}
        if "riesgo alto" in osint or "riesgo medio" in osint or "enlace real lleva" in osint:
            inds.add("I2")
        phish = bool(inds)
        return json.dumps({"veredicto": "PHISHING" if phish else "SEGURO", "indicios": sorted(inds)})
    return gen


def generador_hf(ruta: str, max_new: int):
    import torch
    from transformers import AutoModelForCausalLM, AutoTokenizer
    tok = AutoTokenizer.from_pretrained(ruta)
    model = AutoModelForCausalLM.from_pretrained(ruta, dtype="auto", device_map="auto").eval()

    def gen(mensajes):
        ids = tok.apply_chat_template(mensajes, add_generation_prompt=True, return_tensors="pt").to(model.device)
        with torch.no_grad():
            out = model.generate(ids, max_new_tokens=max_new, do_sample=False, repetition_penalty=1.05)
        return tok.decode(out[0, ids.shape[1]:], skip_special_tokens=True)
    return gen


def generador_gguf(ruta: str, max_new: int):
    from llama_cpp import Llama
    llm = Llama(model_path=ruta, n_ctx=2048, n_threads=4, verbose=False)  # 4 hilos ~ celular de gama media

    def gen(mensajes):
        r = llm.create_chat_completion(messages=mensajes, max_tokens=max_new, temperature=0.0, repeat_penalty=1.05)
        return r["choices"][0]["message"]["content"]
    return gen


def prf(tp, fp, fn):
    p = tp / max(1, tp + fp); r = tp / max(1, tp + fn)
    return {"precision": round(p, 3), "recall": round(r, 3), "f1": round(2 * p * r / max(1e-9, p + r), 3)}


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("--backend", choices=["reglas", "hf", "gguf"], required=True)
    ap.add_argument("--modelo", default="")
    ap.add_argument("--max-new", type=int, default=420)
    ap.add_argument("--limite", type=int, default=0)
    args = ap.parse_args()

    gen = {"reglas": generador_reglas, "hf": lambda: generador_hf(args.modelo, args.max_new),
           "gguf": lambda: generador_gguf(args.modelo, args.max_new)}[args.backend]()
    ejemplos = [json.loads(l) for l in open(config.DATA_DIR / "sft" / "test.jsonl", encoding="utf-8")]
    ejemplos = [e for e in ejemplos if e["tarea"].startswith("analisis")][: args.limite or None]

    por_tarea = collections.defaultdict(lambda: {"n": 0, "ok": 0, "tp": 0, "fp": 0, "fn": 0, "tn": 0})
    ind = {"tp": 0, "fp": 0, "fn": 0}
    invalidos, tiempos, errores = 0, [], []
    for i, e in enumerate(ejemplos):
        t0 = time.perf_counter()
        crudo = gen(e["prompt"])
        tiempos.append(time.perf_counter() - t0)
        real = json.loads(e["completion"][0]["content"])
        pred = parsear_salida(crudo)
        if pred is None:
            invalidos += 1
            pred = {"veredicto": "SEGURO", "indicios": []}   # peor caso: se cuenta como fallo
        s = por_tarea[e["tarea"]]
        s["n"] += 1
        yp, yr = pred["veredicto"] == "PHISHING", real["veredicto"] == "PHISHING"
        s["ok"] += yp == yr
        s["tp"] += yp and yr; s["fp"] += yp and not yr; s["fn"] += yr and not yp; s["tn"] += not yp and not yr
        if yp != yr and len(errores) < 15:
            errores.append({"id": e["id"], "real": real["veredicto"], "pred": pred["veredicto"], "salida": crudo[:300]})
        ip, ir = set(pred.get("indicios") or []), set(real["indicios"])
        ind["tp"] += len(ip & ir); ind["fp"] += len(ip - ir); ind["fn"] += len(ir - ip)
        if (i + 1) % 20 == 0:
            print(f"{i + 1}/{len(ejemplos)}")

    tot = {k: sum(s[k] for s in por_tarea.values()) for k in ("n", "ok", "tp", "fp", "fn", "tn")}
    rep = {"backend": args.backend, "modelo": args.modelo, "n": tot["n"],
           "exactitud": round(tot["ok"] / max(1, tot["n"]), 3), "phishing": prf(tot["tp"], tot["fp"], tot["fn"]),
           "falsos_negativos": tot["fn"], "falsos_positivos": tot["fp"],
           "indicios_micro": prf(ind["tp"], ind["fp"], ind["fn"]),
           "json_invalidos": invalidos, "latencia_media_s": round(sum(tiempos) / max(1, len(tiempos)), 3),
           "por_tarea": {t: {"n": s["n"], "exactitud": round(s["ok"] / s["n"], 3), **prf(s["tp"], s["fp"], s["fn"])}
                         for t, s in por_tarea.items()},
           "errores_muestra": errores}
    config.REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    (config.REPORTS_DIR / f"eval_{args.backend}.json").write_text(json.dumps(rep, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({k: v for k, v in rep.items() if k != "errores_muestra"}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
