"""Carga, validacion y limpieza del CSV del IESS (separador ';', UTF-8)."""
from __future__ import annotations

import csv
import random
import re
import unicodedata
from dataclasses import dataclass, field
from pathlib import Path

from .config import COLUMNAS_ESPERADAS, SEED

URL_RE = re.compile(r"(?:https?://|www\.)[^\s\[\]<>\"«»,;)]+", re.I)
_LISTA_RE = re.compile(r"\[([^\]]*)\]")


def plegar(s: str) -> str:
    """minusculas sin tildes: 'Contraseña' -> 'contrasena'."""
    s = unicodedata.normalize("NFD", s or "")
    return "".join(c for c in s if unicodedata.category(c) != "Mn").lower()


def parse_lista(s: str) -> list[str]:
    return [x.strip() for x in _LISTA_RE.findall(s or "") if x.strip()]


def _a_int(s: str, defecto: int = 0) -> int:
    try:
        return int(float((s or "").strip()))
    except ValueError:
        return defecto


def limpiar_texto(s: str) -> str:
    s = unicodedata.normalize("NFC", (s or "").replace("\r\n", "\n").replace("\r", "\n"))
    s = s.replace(" ", " ").replace("​", "")
    s = re.sub(r"[ \t]+\n", "\n", s)
    s = re.sub(r"\n{3,}", "\n\n", s)
    return s.strip()


@dataclass
class Correo:
    id: str
    asunto: str
    cuerpo: str
    fecha: str
    urls: list[str]
    adjuntos: list[str]
    adjuntos_bytes: list[int]
    hops: int
    phishing: bool
    indicios: dict[str, int] = field(default_factory=dict)

    @property
    def activos(self) -> list[str]:
        return [k for k, v in self.indicios.items() if v]

    def urls_visibles(self) -> list[str]:
        return URL_RE.findall(self.cuerpo)


def _a_bool_phishing(v: str) -> bool:
    v = plegar(v).strip()
    if v in {"si", "yes", "1", "true", "phishing"}:
        return True
    if v in {"no", "0", "false", "legitimo"}:
        return False
    raise ValueError(f"Valor de 'Phishing' desconocido: {v!r}")


def cargar_correos(path: Path) -> tuple[list[Correo], list[str]]:
    """Devuelve (correos, avisos). Lanza error si faltan columnas."""
    avisos: list[str] = []
    with open(path, encoding="utf-8-sig", newline="") as f:
        lector = csv.DictReader(f, delimiter=";")
        faltan = [c for c in COLUMNAS_ESPERADAS if c not in (lector.fieldnames or [])]
        if faltan:
            raise SystemExit(f"Faltan columnas en el CSV: {faltan}. Encontradas: {lector.fieldnames}")
        filas = list(lector)

    correos: list[Correo] = []
    vistos: set[tuple[str, str]] = set()
    for n, r in enumerate(filas, start=2):
        try:
            c = Correo(
                id=r["id"].strip(),
                asunto=limpiar_texto(r["subject"]),
                cuerpo=limpiar_texto(r["body"]),
                fecha=r["date"].strip(),
                urls=parse_lista(r["urls"]),
                adjuntos=[plegar(x).lstrip(".") for x in parse_lista(r["attachments_types"])],
                adjuntos_bytes=[_a_int(x) for x in parse_lista(r["attachments_sizes"])],
                hops=_a_int(r["hops_count"]),
                phishing=_a_bool_phishing(r["Phishing"]),
                indicios={f"I{i}": 1 if _a_int(r[f"I{i}"]) else 0 for i in range(1, 12)},
            )
        except (ValueError, KeyError) as e:
            avisos.append(f"fila {n}: descartada ({e})")
            continue
        if not c.cuerpo and not c.asunto:
            avisos.append(f"{c.id}: sin asunto ni cuerpo, descartado")
            continue
        clave = (c.asunto, c.cuerpo)
        if clave in vistos:
            avisos.append(f"{c.id}: duplicado exacto, descartado")
            continue
        vistos.add(clave)
        if _a_int(r["url_count"]) != len(c.urls):
            avisos.append(f"{c.id}: url_count={r['url_count']} pero hay {len(c.urls)} urls")
        if _a_int(r["attachments_count"]) != len(c.adjuntos):
            avisos.append(f"{c.id}: attachments_count no coincide con attachments_types")
        if c.phishing != any(c.indicios.values()):
            avisos.append(f"{c.id}: Phishing={c.phishing} inconsistente con indicios {c.activos}")
        correos.append(c)
    return correos, avisos


def split_estratificado(correos: list[Correo], val: float = 0.1, test: float = 0.1,
                        seed: int = SEED) -> dict[str, list[str]]:
    rng = random.Random(seed)
    out: dict[str, list[str]] = {"train": [], "val": [], "test": []}
    for etiqueta in (True, False):
        ids = sorted(c.id for c in correos if c.phishing == etiqueta)
        rng.shuffle(ids)
        n_val, n_test = round(len(ids) * val), round(len(ids) * test)
        out["test"] += ids[:n_test]
        out["val"] += ids[n_test:n_test + n_val]
        out["train"] += ids[n_test + n_val:]
    return out


def oraciones(texto: str) -> list[tuple[int, int, str]]:
    """Segmenta en oraciones/lineas conservando offsets (para resaltar en la app)."""
    res = []
    for m in re.finditer(r"[^\n.!?]+(?:[.!?]+|$)", texto, re.M):
        frag = m.group(0)
        ini = m.start() + (len(frag) - len(frag.lstrip()))
        fin = m.end() - (len(frag) - len(frag.rstrip()))
        if fin - ini >= 3:
            res.append((ini, fin, texto[ini:fin]))
    return res
