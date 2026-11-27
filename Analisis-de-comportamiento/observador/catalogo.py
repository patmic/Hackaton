"""Vocabulario del dominio que usa el observador.

Los códigos salen de `Capacitacion/CLAUDE.md` (§6 indicios, §7 tipos de usuario,
§11 microcursos) y de `tipologias-correo/tipologias.json` (tipologías T1-T6).
El observador solo trabaja con códigos: no guarda nombres, cédulas ni correos.
"""
from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from pathlib import Path

# ------------------------------------------------------------------ indicios (§6)
INDICIOS: dict[str, str] = {
    "I1": "Urgencia artificial",
    "I2": "Enlace a dominio no oficial",
    "I3": "Pide credenciales, claves, códigos o tarjeta",
    "I4": "Enlace acortado u oculto",
    "I5": "Adjunto o instalación sospechosa",
    "I6": "Premio, bono o reembolso inesperado",
    "I7": "Remitente no oficial",
    "I8": "Amenaza o pérdida de beneficio",
    "I9": "Pide datos personales o documentos",
    "I10": "Pide pago o transferencia",
    "I11": "Código QR hacia sitio no verificable",
}
CODIGOS_INDICIO: tuple[str, ...] = tuple(INDICIOS)

# ------------------------------------------------------------------ tipos de usuario (§7)
TIPOS_USUARIO: tuple[str, ...] = ("EX1", "EX2", "EX3", "EX4", "EX5", "IN1", "IN2", "IN3", "IN4")
INTERNOS: frozenset[str] = frozenset({"IN1", "IN2", "IN3", "IN4"})
RANGOS_ETARIOS: tuple[str, ...] = ("18-29", "30-49", "50-64", "65+")
NIVELES: tuple[int, ...] = (1, 2, 3)
RESULTADOS: tuple[str, ...] = ("REPORTO", "CLIC", "IGNORO")
SEMAFOROS: tuple[str, ...] = ("VERDE", "AMARILLO", "ROJO")

# Público de tipologias.json al que pertenece cada tipo de usuario.
# [SUPUESTO] EX4 (prestador) y EX5 (sin cuenta) no aparecen en el JSON:
# EX4 recibe lo que reciben los afiliados y EX5 puede recibir cualquier
# correo externo.
PUBLICO_POR_TIPO: dict[str, frozenset[str]] = {
    "EX1": frozenset({"afiliados"}),
    "EX2": frozenset({"pensionistas"}),
    "EX3": frozenset({"empleadores"}),
    "EX4": frozenset({"afiliados"}),
    "EX5": frozenset({"afiliados", "pensionistas", "empleadores"}),
    **{t: frozenset({"colaboradores"}) for t in INTERNOS},
}

# Tipologías del «ataque típico» de cada tipo (CLAUDE.md §7). Pesan el doble.
ATAQUE_TIPICO: dict[str, frozenset[str]] = {
    "EX1": frozenset({"T2"}),
    "EX2": frozenset({"T2"}),
    "EX3": frozenset({"T2"}),
    "EX4": frozenset({"T2", "T3"}),
    "EX5": frozenset(),
    "IN1": frozenset({"T5", "T6"}),
    "IN2": frozenset({"T6"}),
    "IN3": frozenset({"T5", "T6"}),
    "IN4": frozenset({"T5", "T6"}),
}

# ------------------------------------------------------------------ microcursos (§11)
MICROCURSOS: dict[str, str] = {
    "I1": "La prisa es la trampa",
    "I2": "Tus canales oficiales",
    "I7": "Tus canales oficiales",
    "I3": "El IESS nunca te pide tu clave",
    "I9": "El IESS nunca te pide tu clave",
    "I4": "Mira a dónde lleva de verdad un enlace",
    "I5": "Adjuntos que no esperabas",
    "I6": "Nadie regala ni cobra por adelantado",
    "I10": "Nadie regala ni cobra por adelantado",
    "I8": "El IESS no bloquea por correo",
    "I11": "No confíes en la página que abre un QR",
}


def modulo_del_microcurso(indicio: str, tipos: set[str] | frozenset[str]) -> str:
    """Módulo donde vive el microcurso del indicio (§11). Igual que
    `Microcurso.moduloPara` de la app Flutter."""
    if indicio in ("I1", "I3", "I9"):
        return "M1"
    if indicio in ("I2", "I7"):
        return "M2"
    if indicio in ("I4", "I11"):
        return "M6"
    if indicio in ("I6", "I10"):
        return "M4"
    if indicio == "I8":
        return "M7" if "EX2" in tipos else "M4"
    # I5: M11 internos, M9 EX4, M8 EX3; [SUPUESTO] M1 para el resto.
    if tipos & INTERNOS:
        return "M11"
    if "EX4" in tipos:
        return "M9"
    if "EX3" in tipos:
        return "M8"
    return "M1"


def ordenar_tipos(tipos) -> tuple[str, ...]:
    return tuple(t for t in TIPOS_USUARIO if t in set(tipos))


# ------------------------------------------------------------------ tipologías (tipologias.json)
@dataclass(frozen=True)
class Tipologia:
    codigo: str
    nombre: str
    capsula: str
    publico: frozenset[str] = frozenset()
    suplantacion_frecuente: tuple[str, ...] = ()


@dataclass(frozen=True)
class CatalogoTipologias:
    version: str
    tipologias: dict[str, Tipologia] = field(default_factory=dict)

    @classmethod
    def desde_json(cls, datos: dict) -> "CatalogoTipologias":
        tipologias = {}
        for t in datos["tipologias"]:
            tipologias[t["id"]] = Tipologia(
                codigo=t["id"],
                nombre=t["nombre"],
                capsula=t.get("capsula", ""),
                publico=frozenset(t.get("publico", [])),
                suplantacion_frecuente=tuple(i for i in t.get("suplantacion_frecuente", []) if i in INDICIOS),
            )
        return cls(version=str(datos.get("version", "")), tipologias=tipologias)

    @classmethod
    def cargar(cls, ruta: str | Path | None = None) -> "CatalogoTipologias":
        """Lee `tipologias.json`. Busca, en orden: el argumento, la variable
        `OBSERVADOR_TIPOLOGIAS` y `tipologias-correo/tipologias.json` en la
        raíz del repositorio."""
        candidatas = [ruta, os.environ.get("OBSERVADOR_TIPOLOGIAS"),
                      Path(__file__).resolve().parents[2] / "tipologias-correo" / "tipologias.json"]
        for c in candidatas:
            if c and Path(c).is_file():
                return cls.desde_json(json.loads(Path(c).read_text(encoding="utf-8")))
        raise FileNotFoundError("No se encontró tipologias.json (defina OBSERVADOR_TIPOLOGIAS)")

    def nombre(self, codigo: str | None) -> str:
        t = self.tipologias.get(codigo or "")
        return t.nombre if t else (codigo or "")

    def capsula(self, codigo: str | None) -> str:
        t = self.tipologias.get(codigo or "")
        return t.capsula if t else "El IESS nunca le pide claves, pagos ni datos por correo."

    def pesos_para(self, tipos) -> dict[str, float]:
        """Qué tan expuesta está una persona a cada tipología, por sus tipos.

        1 si la tipología se dirige a su público, 2 si además es el ataque
        típico de su tipo (§7), 0 si no la recibe."""
        tipos = set(tipos)
        publico = set().union(*(PUBLICO_POR_TIPO.get(t, frozenset()) for t in tipos)) if tipos else set()
        tipicas = set().union(*(ATAQUE_TIPICO.get(t, frozenset()) for t in tipos)) if tipos else set()
        pesos = {}
        for codigo, t in self.tipologias.items():
            if t.publico & publico:
                pesos[codigo] = 2.0 if codigo in tipicas else 1.0
        return pesos

    def exposicion_por_indicio(self, tipos) -> dict[str, float]:
        """Exposición relativa (0 a 1) a cada indicio: los indicios con los que
        se suplantan las tipologías que la persona recibe. Los primeros de
        `suplantacion_frecuente` pesan más."""
        crudo = {i: 0.0 for i in INDICIOS}
        for codigo, peso in self.pesos_para(tipos).items():
            for orden, indicio in enumerate(self.tipologias[codigo].suplantacion_frecuente):
                crudo[indicio] += peso * max(0.4, 1.0 - 0.15 * orden)
        maximo = max(crudo.values()) or 1.0
        return {i: v / maximo for i, v in crudo.items()}
