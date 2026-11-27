"""Rutas, constantes y catalogo de indicios (fuente: Catalogo_Indicios_y_Canales_Oficiales.pdf)."""
from __future__ import annotations

import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]          # D:\iesston
ML_DIR = ROOT / "ml"
DATA_DIR = ML_DIR / "data"
REPORTS_DIR = ML_DIR / "reports"
OUTPUTS_DIR = ML_DIR / "outputs"
SHARED_DIR = ROOT / "shared"

CSV_PATH = Path(os.environ.get(
    "AIESS_CSV", str(ROOT / "datos" / "dataset_entrenamiento_IESS_1000.csv")))

# Modelo base de Liquid AI. 1.2B = mejor calidad; 350M/700M para gama baja.
BASE_MODEL = os.environ.get("AIESS_BASE_MODEL", "LiquidAI/LFM2-1.2B")

SEED = 42
NOMBRE_MASCOTA = os.environ.get("AIESS_MASCOTA", "AIess")

CANALES: dict = json.loads((SHARED_DIR / "canales_oficiales.json").read_text(encoding="utf-8"))

COLUMNAS_ESPERADAS = [
    "id", "subject", "body", "date", "url_count", "urls", "attachments_count",
    "attachments_types", "attachments_total_size", "attachments_sizes", "hops_count",
    "Phishing", *[f"I{i}" for i in range(1, 12)],
]

INDICIOS: dict[str, dict[str, str]] = {
    "I1": {"nombre": "Urgencia artificial",
           "que": "plazos muy cortos o presión para actuar de inmediato"},
    "I2": {"nombre": "Enlace a dominio no oficial",
           "que": "el enlace lleva a un sitio que no es del IESS ni de una entidad pública o servicio conocido"},
    "I3": {"nombre": "Pide credenciales, claves, códigos o tarjeta",
           "que": "solicita usuario, contraseña, clave de afiliado, códigos de verificación o datos de tarjeta"},
    "I4": {"nombre": "Enlace acortado u oculto",
           "que": "usa un acortador o el texto muestra una dirección y el enlace lleva a otra"},
    "I5": {"nombre": "Adjunto o instalación sospechosa",
           "que": "archivo .zip, .exe, .apk, .html o con macros, o pide instalar una aplicación"},
    "I6": {"nombre": "Premio, bono o reembolso inesperado",
           "que": "ofrece dinero o beneficios que no solicitaste"},
    "I7": {"nombre": "Remitente no oficial",
           "que": "correo gratuito, dominio parecido al oficial o responder-a distinto"},
    "I8": {"nombre": "Amenaza o pérdida de beneficio",
           "que": "advierte de suspensión, bloqueo, multa, embargo o pérdida de pensión o afiliación"},
    "I9": {"nombre": "Pide datos personales o documentos",
           "que": "solicita cédula, fecha de nacimiento, foto del documento o selfie"},
    "I10": {"nombre": "Pide pago o transferencia",
            "que": "solicita depósito, tasa, multa, criptomonedas o transferencia"},
    "I11": {"nombre": "Código QR hacia sitio no verificable",
            "que": "pide escanear un QR cuyo destino no se puede comprobar"},
}

# I7 depende del remitente, que NO es columna del CSV: el modelo no puede verlo en el texto.
# Se excluye de la salida del LLM y lo decide el modulo OSINT cuando el usuario aporta el remitente.
INDICIOS_TEXTO = [k for k in INDICIOS if k != "I7"]


def asegurar_directorios() -> None:
    for d in (DATA_DIR, REPORTS_DIR, OUTPUTS_DIR, DATA_DIR / "sft"):
        d.mkdir(parents=True, exist_ok=True)
