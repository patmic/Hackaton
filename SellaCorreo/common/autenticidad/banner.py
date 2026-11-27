"""Imagen de encabezado SellaCorreo (PNG) que se pega dentro del correo.

Se importa aparte (requiere Pillow) para que signer y db no dependan de ella.
"""
from __future__ import annotations

import io

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

FONTS = Path(__file__).resolve().parent / "fonts"  # DejaVu Sans (licencia libre, ver LICENSE-DejaVu.txt)

TEAL, DEEP, WHITE, MINT = (20, 89, 98), (10, 26, 38), (255, 255, 255), (94, 234, 212)


def _font(size: int, bold: bool = False):
    for name in (["DejaVuSans-Bold.ttf"] if bold else []) + ["DejaVuSans.ttf"]:
        try:
            return ImageFont.truetype(str(FONTS / name), size)
        except OSError:
            pass
    try:
        return ImageFont.load_default(size=size)
    except TypeError:  # Pillow < 10.1
        return ImageFont.load_default()


def banner_png(codigo: str, tipologia: str = "comunicacional", width: int = 640, height: int = 120) -> bytes:
    img = Image.new("RGB", (width, height), TEAL)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, width, 6], fill=DEEP)
    # Escudo con check
    cx, top = 58, 22
    d.polygon([(cx - 30, top), (cx + 30, top), (cx + 30, top + 40), (cx, top + 76), (cx - 30, top + 40)], fill=WHITE)
    d.line([(cx - 15, top + 36), (cx - 3, top + 50), (cx + 17, top + 24)], fill=TEAL, width=7)
    d.text((112, 20), "SellaCorreo", font=_font(30, bold=True), fill=WHITE)
    d.text((112, 58), f"Correo institucional sellado · {tipologia}", font=_font(16), fill=WHITE)
    d.text((112, 82), "Haga clic aquí para verificar que no es phishing", font=_font(16, bold=True), fill=MINT)
    code_font = _font(18, bold=True)
    tw = d.textlength(codigo, font=code_font)
    d.rounded_rectangle([width - tw - 40, 20, width - 16, 52], radius=8, outline=WHITE, width=2)
    d.text((width - tw - 28, 25), codigo, font=code_font, fill=WHITE)
    buf = io.BytesIO()
    img.save(buf, format="PNG", optimize=True)
    return buf.getvalue()


def invalid_png(width: int = 640, height: int = 120) -> bytes:
    img = Image.new("RGB", (width, height), (153, 27, 27))
    d = ImageDraw.Draw(img)
    d.text((32, 30), "SellaCorreo · sello no reconocido", font=_font(26, bold=True), fill=WHITE)
    d.text((32, 72), "Este correo podría ser phishing. No haga clic en sus enlaces.", font=_font(16), fill=WHITE)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()
