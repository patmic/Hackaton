"""Genera correos de prueba de ejemplo y los escribe como `.eml`, sin enviar nada.

Sirve para ver la salida del generador sin levantar el servidor ni instalar
FastAPI. Solo usa la librería estándar (y `qrcode` si está, opcional).

Uso:
    python -m backend.capacitacion.ejemplos.generar_demo
    # o
    python backend/capacitacion/ejemplos/generar_demo.py

Los `.eml` quedan en backend/capacitacion/ejemplos/salida_demo/.
"""

from __future__ import annotations

import sys
from pathlib import Path

# Permite ejecutarlo como script suelto (añade la raíz del repo al path).
if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parents[3]))

from backend.capacitacion.generador_correo import generar_correo  # noqa: E402
from backend.capacitacion.plantillas import PLANTILLAS  # noqa: E402
from backend.capacitacion.servicio import _tipo_para  # noqa: E402

SALIDA = Path(__file__).resolve().parent / "salida_demo"


def main() -> None:
    SALIDA.mkdir(parents=True, exist_ok=True)
    # Token fijo → salida reproducible.
    token_base = "DEMO-TOKEN-0001"

    print(f"Generando {len(PLANTILLAS)} correos de prueba en {SALIDA}\n")
    print(f"{'plantilla':22} {'tipo':5} {'tipol':5} {'niv':3} indicios")
    print("-" * 70)

    for p in PLANTILLAS:
        tipo = _tipo_para(p, set(p.tipos))
        correo = generar_correo(
            p,
            tipo_usuario=tipo,
            token=f"{token_base}-{p.id}",
            para="afiliado@correo.test",
        )
        archivo = SALIDA / f"{p.id}.eml"
        archivo.write_text(correo.como_eml(), encoding="utf-8")
        adj = ",".join(a.filename for a in correo.adjuntos) or "-"
        print(
            f"{p.id:22} {tipo:5} {p.tipologia:5} {p.nivel:<3} "
            f"{' '.join(p.indicios)}"
        )
        print(f"    asunto: {correo.asunto}")
        print(f"    de:     {correo.remitente_nombre} <{correo.remitente_correo_visible}>")
        print(f"    adj:    {adj}")

    print(f"\nListo. Abre los .eml en Gmail/Outlook/Thunderbird para verlos.")


if __name__ == "__main__":
    main()
