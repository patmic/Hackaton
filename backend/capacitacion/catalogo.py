"""Catálogo de dominio: tipologías (desde tipologias.json), indicios, tipos de
usuario y canales oficiales.

La fuente de verdad de las tipologías es `tipologias-correo/tipologias.json`
(v1.0). Aquí se carga y se complementa con los indicios I1-I11 (CLAUDE.md §6) y
los tipos de usuario EX1-IN4 (CLAUDE.md §7), que viven en el código porque la app
Flutter ya los modela igual.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from functools import lru_cache

from .config import config

# --------------------------------------------------------------------------- #
# Indicios de phishing (CLAUDE.md §6 / recursos-base/Catalogo_Indicios...)
# --------------------------------------------------------------------------- #

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

# Microcurso que se dispara por indicio (CLAUDE.md §11).
MICROCURSO_POR_INDICIO: dict[str, str] = {
    "I1": "La prisa es la trampa",
    "I2": "Tus canales oficiales",
    "I3": "El IESS nunca te pide tu clave",
    "I4": "Mira a dónde lleva de verdad un enlace",
    "I5": "Adjuntos que no esperabas",
    "I6": "Nadie regala ni cobra por adelantado",
    "I7": "Tus canales oficiales",
    "I8": "El IESS no bloquea por correo",
    "I9": "El IESS nunca te pide tu clave",
    "I10": "Nadie regala ni cobra por adelantado",
    "I11": "No confíes en la página que abre un QR",
}

# --------------------------------------------------------------------------- #
# Tipos de usuario (CLAUDE.md §7)
# --------------------------------------------------------------------------- #

EXTERNOS = ("EX1", "EX2", "EX3", "EX4", "EX5")
INTERNOS = ("IN1", "IN2", "IN3", "IN4")
TIPOS_VALIDOS = EXTERNOS + INTERNOS

NOMBRE_TIPO: dict[str, str] = {
    "EX1": "Afiliado activo",
    "EX2": "Jubilado o pensionista",
    "EX3": "Empleador",
    "EX4": "Prestador externo de salud",
    "EX5": "Ciudadano sin cuenta o familiar",
    "IN1": "Colaborador general",
    "IN2": "Colaborador emisor",
    "IN3": "Analista de seguridad (CSI/OSI)",
    "IN4": "Administrador de plataforma",
}


def es_interno(tipo: str) -> bool:
    return tipo in INTERNOS


def zona_de(tipo: str) -> str:
    return "INTERNA" if es_interno(tipo) else "EXTERNA"


# Tipología que más se suplanta para cada tipo (CLAUDE.md §7 «ataque típico»).
# Es la «piel legítima» que imita el correo de práctica de ese tipo.
TIPOLOGIA_POR_TIPO: dict[str, str] = {
    "EX1": "T2",  # falsos reembolsos, créditos BIESS
    "EX2": "T2",  # bloqueo de pensión con urgencia
    "EX3": "T2",  # glosas, multas, planillas
    "EX4": "T2",  # falsos tramitadores de pagos (también T3)
    "EX5": "T3",  # certificados, trámites (también T4 salud)
    "IN1": "T6",  # robo de credenciales, falso soporte TI
    "IN2": "T6",
    "IN3": "T6",
    "IN4": "T6",
}

# Canales oficiales (CLAUDE.md §6). Se usan para fabricar dominios *parecidos*
# (el indicio I7/I2) y para los textos educativos.
REMITENTE_OFICIAL = "@iess.gob.ec"
PORTAL_OFICIAL = "www.iess.gob.ec"
APP_OFICIAL = "app.iess.gob.ec"
WHATSAPP_OFICIAL = "+593 9 62532338"
CORREO_SEGURIDAD = "seguridad.informacion@iess.gob.ec"


# --------------------------------------------------------------------------- #
# Tipologías (cargadas de tipologias.json)
# --------------------------------------------------------------------------- #


@dataclass(frozen=True)
class FichaTipologia:
    id: str
    nombre: str
    proposito: str
    publico: tuple[str, ...]
    ejemplo_asunto: str
    siempre_trae: tuple[str, ...]
    nunca_trae: tuple[str, ...]
    dominios_enlace_permitidos: tuple[str, ...]
    adjuntos_permitidos: tuple[str, ...]
    suplantacion_frecuente: tuple[str, ...]
    capsula: str


@dataclass(frozen=True)
class Catalogo:
    version: str
    remitente_oficial: str
    tipologias: dict[str, FichaTipologia]
    sello: dict
    externos: dict

    def ficha(self, tipologia: str) -> FichaTipologia:
        return self.tipologias[tipologia.strip().upper()]


@lru_cache(maxsize=1)
def cargar_catalogo() -> Catalogo:
    ruta = config.tipologias_json
    with ruta.open(encoding="utf-8") as fh:
        datos = json.load(fh)

    fichas: dict[str, FichaTipologia] = {}
    for t in datos["tipologias"]:
        fichas[t["id"]] = FichaTipologia(
            id=t["id"],
            nombre=t["nombre"],
            proposito=t["proposito"],
            publico=tuple(t.get("publico", [])),
            ejemplo_asunto=t.get("ejemplo_asunto", ""),
            siempre_trae=tuple(t.get("siempre_trae", [])),
            nunca_trae=tuple(t.get("nunca_trae", [])),
            dominios_enlace_permitidos=tuple(t.get("dominios_enlace_permitidos", [])),
            adjuntos_permitidos=tuple(t.get("adjuntos_permitidos", [])),
            suplantacion_frecuente=tuple(t.get("suplantacion_frecuente", [])),
            capsula=t.get("capsula", ""),
        )

    return Catalogo(
        version=datos.get("version", "?"),
        remitente_oficial=datos.get("remitente_oficial", REMITENTE_OFICIAL),
        tipologias=fichas,
        sello=datos.get("sello", {}),
        externos=datos.get("externos", {}),
    )
