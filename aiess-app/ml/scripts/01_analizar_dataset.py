"""Fase 2.1 - Inspeccion, limpieza y extraccion de patrones del CSV.

Uso:  python -I ml/scripts/01_analizar_dataset.py [--csv RUTA]
Salida: ml/reports/patrones.json, ml/reports/patrones.md, ml/data/split.json
Solo libreria estandar (corre en cualquier Python >= 3.10).
"""
from __future__ import annotations

import argparse
import collections
import itertools
import json
import math
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from aiess_ml import config  # noqa: E402
from aiess_ml.datos import cargar_correos, plegar, split_estratificado  # noqa: E402
from aiess_ml.evidencia import LEXICO  # noqa: E402
from aiess_ml.osint_rules import analizar_mensaje, analizar_url, partir_url  # noqa: E402

STOP = set("""a al algo ante con contra de del desde donde e el en entre era es esta este esto ha hay la las le les lo los
mas me mi muy no nos o os para pero por que se sea ser si sin sobre su sus te tu un una uno y ya usted ustedes
su sus sido fue son esta estas estos han he hemos le les lo su nuestro nuestra favor estimado estimada""".split())


def tokens(texto: str) -> list[str]:
    t = re.sub(r"https?://\S+|www\.\S+|[\w.+-]+@[\w.-]+", " ", plegar(texto))
    return [w for w in re.findall(r"[a-zñ]{3,}", t)]


def ngramas_doc(texto: str, n_max: int = 3) -> set[str]:
    toks = tokens(texto)
    res = set()
    for n in range(1, n_max + 1):
        for i in range(len(toks) - n + 1):
            g = toks[i:i + n]
            if g[0] in STOP or g[-1] in STOP:
                continue
            res.add(" ".join(g))
    return res


def log_odds(docs_a: list[set[str]], docs_b: list[set[str]], top: int = 25, min_df: int = 8):
    """Log-odds con prior de Dirichlet informativo (Monroe et al. 2008), por frecuencia de documento."""
    ca, cb = collections.Counter(), collections.Counter()
    for d in docs_a:
        ca.update(d)
    for d in docs_b:
        cb.update(d)
    na, nb = sum(ca.values()), sum(cb.values())
    total = ca + cb
    a0 = 0.01 * sum(total.values())
    res = []
    for w, tot in total.items():
        if tot < min_df:
            continue
        aw = 0.01 * tot
        ya, yb = ca[w], cb[w]
        la = math.log((ya + aw) / (na + a0 - ya - aw))
        lb = math.log((yb + aw) / (nb + a0 - yb - aw))
        z = (la - lb) / math.sqrt(1 / (ya + aw) + 1 / (yb + aw))
        res.append((w, round(z, 2), ya, yb))
    res.sort(key=lambda x: -x[1])
    # quita n-gramas contenidos en otros ya elegidos con score similar (redundancia)
    elegidos: list = []
    for r in res:
        if any(r[0] in e[0] or e[0] in r[0] for e in elegidos):
            continue
        elegidos.append(r)
        if len(elegidos) >= top:
            break
    return [{"ngrama": w, "z": z, "docs_clase": ya, "docs_contraste": yb} for w, z, ya, yb in elegidos]


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", type=Path, default=config.CSV_PATH)
    args = ap.parse_args()
    config.asegurar_directorios()

    correos, avisos = cargar_correos(args.csv)
    P = [c for c in correos if c.phishing]
    L = [c for c in correos if not c.phishing]
    texto = {c.id: f"{c.asunto}\n{c.cuerpo}" for c in correos}
    ng = {c.id: ngramas_doc(texto[c.id]) for c in correos}
    rep: dict = {"archivo": str(args.csv), "filas_validas": len(correos), "avisos_limpieza": avisos,
                 "balance": {"phishing": len(P), "legitimo": len(L)}}

    # Indicios: frecuencia y co-ocurrencia
    rep["indicios"] = {k: {"nombre": v["nombre"], "n": sum(c.indicios[k] for c in correos)}
                       for k, v in config.INDICIOS.items()}
    pares = collections.Counter()
    for c in P:
        pares.update(itertools.combinations(c.activos, 2))
    rep["coocurrencia_top"] = [{"par": f"{a}+{b}", "n": n} for (a, b), n in pares.most_common(12)]
    rep["n_indicios_por_phishing"] = dict(sorted(collections.Counter(len(c.activos) for c in P).items()))

    # Lenguaje: n-gramas distintivos
    rep["ngramas_phishing"] = log_odds([ng[c.id] for c in P], [ng[c.id] for c in L])
    rep["ngramas_legitimo"] = log_odds([ng[c.id] for c in L], [ng[c.id] for c in P])
    rep["ngramas_por_indicio"] = {
        k: log_odds([ng[c.id] for c in P if c.indicios[k]], [ng[c.id] for c in L], top=12, min_df=5)
        for k in config.INDICIOS}
    rep["asuntos_phishing"] = log_odds([ngramas_doc(c.asunto, 2) for c in P],
                                       [ngramas_doc(c.asunto, 2) for c in L], top=15, min_df=4)

    # Botones / CTA (aparecen entre corchetes)
    def ctas(cs):
        return collections.Counter(b.strip() for c in cs for b in re.findall(r"\[([^\]\n]{2,40})\]", c.cuerpo)
                                   if not b.lower().startswith(("http", "imagen")))
    rep["cta_phishing"] = ctas(P).most_common(20)
    rep["cta_legitimo"] = ctas(L).most_common(10)

    # URLs y dominios
    def hosts(cs):
        return collections.Counter(partir_url(u)[1] for c in cs for u in c.urls)
    hp, hl = hosts(P), hosts(L)
    rep["dominios_phishing"] = hp.most_common(40)
    rep["dominios_legitimo"] = hl.most_common(25)
    rep["tlds_phishing"] = collections.Counter(h.rsplit(".", 1)[-1] for h in hp.elements()).most_common(15)
    rep["acortadores_usados"] = sorted({h for h in hp if h in config.CANALES["acortadores"]})
    rep["dominios_en_ambas_clases"] = sorted(set(hp) & set(hl))
    no_cubiertos = sorted(h for h in hl if not analizar_url("https://" + h)["confiable"])
    rep["legitimos_fuera_de_lista_oficial"] = no_cubiertos
    rep["texto_visible_distinto_al_enlace"] = sum(1 for c in P if analizar_mensaje(c.cuerpo, c.urls)["enganosos"])

    # Adjuntos y saltos
    rep["adjuntos"] = {"phishing": collections.Counter(a for c in P for a in c.adjuntos).most_common(),
                       "legitimo": collections.Counter(a for c in L for a in c.adjuntos).most_common()}
    rep["hops_media"] = {"phishing": round(sum(c.hops for c in P) / len(P), 2),
                         "legitimo": round(sum(c.hops for c in L) / len(L), 2)}

    # Validacion del lexico de evidencia (recall en Ik=1, falsos positivos en legitimos)
    lex = {}
    for k, pat in LEXICO.items():
        pos = [c for c in P if c.indicios[k]]
        hit_pos = sum(1 for c in pos if pat.search(plegar(texto[c.id])))
        hit_leg = sum(1 for c in L if pat.search(plegar(texto[c.id])))
        lex[k] = {"recall": round(hit_pos / max(1, len(pos)), 3), "falsos_pos_legitimos": round(hit_leg / len(L), 3)}
    rep["lexico_evidencia"] = lex

    # Validacion de reglas OSINT contra etiquetas I2 / I4
    def matriz(k):
        tp = fp = fn = tn = 0
        for c in correos:
            pred = k in analizar_mensaje(c.cuerpo, c.urls)["indicios"]
            real = bool(c.indicios[k])
            tp += pred and real; fp += pred and not real; fn += real and not pred; tn += not pred and not real
        prec = tp / max(1, tp + fp); rec = tp / max(1, tp + fn)
        return {"tp": tp, "fp": fp, "fn": fn, "tn": tn, "precision": round(prec, 3), "recall": round(rec, 3)}
    rep["osint_vs_etiquetas"] = {"I2": matriz("I2"), "I4": matriz("I4")}
    rep["osint_url_phishing_detectadas"] = round(
        sum(1 for c in P for u in c.urls if analizar_url(u)["puntaje"] >= 30) / max(1, sum(len(c.urls) for c in P)), 3)
    rep["osint_url_legitimas_falsas_alarmas"] = round(
        sum(1 for c in L for u in c.urls if analizar_url(u)["puntaje"] >= 30) / max(1, sum(len(c.urls) for c in L)), 3)

    split = split_estratificado(correos)
    (config.DATA_DIR / "split.json").write_text(json.dumps(split, indent=1), encoding="utf-8")
    rep["split"] = {k: len(v) for k, v in split.items()}

    (config.REPORTS_DIR / "patrones.json").write_text(json.dumps(rep, ensure_ascii=False, indent=2), encoding="utf-8")
    (config.REPORTS_DIR / "patrones.md").write_text(a_markdown(rep), encoding="utf-8")
    print(a_markdown(rep)[:6000])
    print(f"\n-> {config.REPORTS_DIR / 'patrones.json'}\n-> {config.DATA_DIR / 'split.json'}")


def a_markdown(r: dict) -> str:
    L = [f"# Patrones del dataset IESS\n", f"Filas válidas: {r['filas_validas']} | balance: {r['balance']} | "
         f"avisos de limpieza: {len(r['avisos_limpieza'])} | split: {r['split']}\n", "## Indicios"]
    L += [f"- {k} {v['nombre']}: {v['n']}" for k, v in r["indicios"].items()]
    L += ["\n## Co-ocurrencias más frecuentes", ", ".join(f"{x['par']} ({x['n']})" for x in r["coocurrencia_top"])]
    L += ["\n## N-gramas distintivos de phishing (z log-odds)"]
    L += [f"- {x['ngrama']} (z={x['z']}, {x['docs_clase']}/{x['docs_contraste']})" for x in r["ngramas_phishing"][:20]]
    L += ["\n## N-gramas por indicio"]
    L += [f"- {k}: " + "; ".join(x["ngrama"] for x in v[:8]) for k, v in r["ngramas_por_indicio"].items()]
    L += ["\n## Asuntos típicos de phishing", "; ".join(x["ngrama"] for x in r["asuntos_phishing"])]
    L += ["\n## Botones (CTA) en phishing", ", ".join(f"{b} ({n})" for b, n in r["cta_phishing"])]
    L += ["\n## Dominios de phishing", ", ".join(f"{h} ({n})" for h, n in r["dominios_phishing"][:25])]
    L += [f"\nTLDs: {r['tlds_phishing']}", f"Acortadores: {r['acortadores_usados']}",
          f"Dominios en ambas clases: {r['dominios_en_ambas_clases']}",
          f"Legítimos fuera de la lista oficial: {r['legitimos_fuera_de_lista_oficial']}",
          f"Texto visible ≠ enlace real (phishing): {r['texto_visible_distinto_al_enlace']}"]
    L += [f"\n## Adjuntos\n{r['adjuntos']}", f"\nSaltos (hops) medios: {r['hops_media']}"]
    L += ["\n## Léxico de evidencia (recall en Ik=1 / FP en legítimos)"]
    L += [f"- {k}: recall {v['recall']}, FP {v['falsos_pos_legitimos']}" for k, v in r["lexico_evidencia"].items()]
    L += ["\n## Reglas OSINT vs etiquetas", json.dumps(r["osint_vs_etiquetas"]),
          f"URLs de phishing marcadas (>=30): {r['osint_url_phishing_detectadas']} | "
          f"falsas alarmas en URLs legítimas: {r['osint_url_legitimas_falsas_alarmas']}"]
    return "\n".join(L) + "\n"


if __name__ == "__main__":
    main()
