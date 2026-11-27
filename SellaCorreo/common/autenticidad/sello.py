"""Sello de cera verde «VALIDAR CORREO» (PNG) que se pega dentro del correo.

Réplica en Pillow del sello de referencia de /SellaLogo (SVG de 300x300): silueta ondulada de cera,
pozo interior, texto circular y escudo con las siglas. Además lleva **asteriscos**: uno por cada
opción de «Hash de seguridad» integrada en el enlace (se dibujan dentro del escudo).

Se importa aparte (requiere Pillow), igual que banner.py.
"""
from __future__ import annotations

import io
import math

from PIL import Image, ImageChops, ImageDraw, ImageFilter

from .banner import _font

SIZE = 480  # píxeles del PNG final (cuadrado)
SS = 3  # supersampling para bordes suaves
K = SIZE * SS / 300  # píxeles de trabajo por unidad del SVG de referencia
MAX_ASTERISCOS = 4

BODY = [(0.00, (220, 255, 138)), (0.28, (168, 255, 62)), (0.68, (118, 220, 22)), (0.92, (78, 158, 8)), (1.00, (53, 110, 4))]
WELL = [(0.00, (182, 255, 87)), (0.55, (133, 235, 31)), (1.00, (76, 156, 7))]
INK = (16, 38, 1)


def _u(v: float) -> float:
    return v * K


def _lut(stops):
    def canal(i):
        out = []
        for v in range(256):
            t = v / 255
            val = stops[-1][1][i]
            for (p0, c0), (p1, c1) in zip(stops, stops[1:]):
                if t <= p1:
                    f = 0 if p1 == p0 else max(0.0, (t - p0) / (p1 - p0))
                    val = c0[i] + (c1[i] - c0[i]) * f
                    break
            out.append(round(val))
        return out
    return [canal(0), canal(1), canal(2)]


def _radial(w: int, h: int, cx: float, cy: float, r: float, stops) -> Image.Image:
    """Degradado radial con varias paradas, centrado en (cx, cy) y con radio r."""
    g = Image.radial_gradient("L").resize((max(2, int(2 * r)), max(2, int(2 * r))))
    base = Image.new("L", (w, h), 255)
    base.paste(g, (int(cx - r), int(cy - r)))
    return Image.merge("RGB", [base.point(lut) for lut in _lut(stops)])


def _blob() -> list[tuple[float, float]]:
    """Silueta orgánica de cera prensada (misma fórmula que el SVG de referencia)."""
    pts = []
    for i in range(96):
        a = i / 96 * math.tau
        r = 128 + math.sin(a * 11) * 5.2 + math.cos(a * 7 + 0.9) * 4.4 + math.sin(a * 3 - 0.5) * 3.1
        pts.append((_u(150 + math.cos(a) * r), _u(150 + math.sin(a) * r)))
    return pts


def _bez(p0, p1, p2, p3, n: int = 24):
    out = []
    for i in range(1, n + 1):
        t = i / n
        mt = 1 - t
        out.append((mt ** 3 * p0[0] + 3 * mt * mt * t * p1[0] + 3 * mt * t * t * p2[0] + t ** 3 * p3[0],
                    mt ** 3 * p0[1] + 3 * mt * mt * t * p1[1] + 3 * mt * t * t * p2[1] + t ** 3 * p3[1]))
    return out


def _arc_text(layer: Image.Image, text: str, r: float, top: bool, font, fill, tracking: float) -> None:
    """Texto sobre un arco: arriba lee de izquierda a derecha por fuera; abajo también de izquierda a derecha."""
    cx = cy = _u(150)
    r = _u(r)
    adv = [font.getlength(c) + _u(tracking) for c in text]
    total = sum(adv) / r
    centro = -math.pi / 2 if top else math.pi / 2
    cum = 0.0
    g = int(font.size * 2.2)
    for ch, a in zip(text, adv):
        mid = (cum + a / 2) / r
        th = centro - total / 2 + mid if top else centro + total / 2 - mid
        cum += a
        if ch == " ":
            continue
        glyph = Image.new("RGBA", (g, g), (0, 0, 0, 0))
        ImageDraw.Draw(glyph).text((g / 2, g / 2), ch, font=font, fill=fill, anchor="mm")
        giro = -(math.degrees(th) + 90) if top else (90 - math.degrees(th))
        glyph = glyph.rotate(giro, resample=Image.BICUBIC)
        x, y = cx + r * math.cos(th), cy + r * math.sin(th)
        layer.alpha_composite(glyph, (int(x - g / 2), int(y - g / 2)))


def _asterisco(draw: ImageDraw.ImageDraw, cx: float, cy: float, r: float, color) -> None:
    """Asterisco de seis brazos (tres líneas que se cruzan)."""
    ancho = max(2, int(_u(1.7)))
    for grados in (90, 30, 150):
        a = math.radians(grados)
        dx, dy = math.cos(a) * _u(r), math.sin(a) * _u(r)
        draw.line([(cx - dx, cy - dy), (cx + dx, cy + dy)], fill=color, width=ancho)
        for sx, sy in ((cx - dx, cy - dy), (cx + dx, cy + dy)):  # puntas redondeadas
            draw.ellipse([sx - ancho / 2, sy - ancho / 2, sx + ancho / 2, sy + ancho / 2], fill=color)


def wax_seal_png(codigo: str, tipologia: str = "comunicacional", asteriscos: int = 1, size: int = SIZE,
                 saludo: str | None = None) -> bytes:
    """PNG cuadrado (transparente) del sello. `asteriscos` = opciones de «Hash de seguridad» integradas.
    `saludo` = palabra saludo del emisor: si se da, es lo único que va en el arco inferior."""
    n = max(0, min(int(asteriscos), MAX_ASTERISCOS))
    W = int(_u(300))
    canvas = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    blob = _blob()

    # sombra exterior
    sombra = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    ImageDraw.Draw(sombra).polygon([(x, y + _u(7)) for x, y in blob], fill=(10, 22, 2, 107))
    canvas.alpha_composite(sombra.filter(ImageFilter.GaussianBlur(_u(6))))

    # cuerpo de cera
    mask = Image.new("L", (W, W), 0)
    ImageDraw.Draw(mask).polygon(blob, fill=255)
    canvas.paste(_radial(W, W, 0.34 * W, 0.28 * W, 0.72 * W, BODY), (0, 0), mask)
    ImageDraw.Draw(canvas).line(blob + [blob[0]], fill=(62, 130, 5, 255), width=int(_u(2.5)), joint="curve")

    # brillo y sombreado de la cera (recortados a la silueta)
    brillo = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    bd = ImageDraw.Draw(brillo)
    bd.ellipse([_u(40), _u(30), _u(200), _u(170)], fill=(255, 255, 255, 40))
    bd.ellipse([_u(110), _u(150), _u(300), _u(310)], fill=(23, 51, 2, 55))
    brillo = brillo.filter(ImageFilter.GaussianBlur(_u(18)))
    brillo.putalpha(ImageChops.multiply(brillo.getchannel("A"), mask))
    canvas.alpha_composite(brillo)

    d = ImageDraw.Draw(canvas)
    c = _u(150)

    def circ(r, **kw):
        d.ellipse([c - _u(r), c - _u(r), c + _u(r), c + _u(r)], **kw)

    # borde elevado y pozo interior prensado
    circ(109, outline=(216, 255, 130, 166), width=int(_u(5)))
    circ(106, outline=(49, 102, 3, 140), width=int(_u(3)))
    pozo = Image.new("L", (W, W), 0)
    ImageDraw.Draw(pozo).ellipse([c - _u(103), c - _u(103), c + _u(103), c + _u(103)], fill=255)
    box, lado = c - _u(103), _u(206)
    canvas.paste(_radial(W, W, box + 0.62 * lado, box + 0.66 * lado, 0.68 * lado, WELL), (0, 0), pozo)
    circ(103, outline=(58, 120, 4, 255), width=int(_u(2)))
    circ(75, outline=(217, 255, 134, 115), width=int(_u(1.2)))
    trazos = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    td = ImageDraw.Draw(trazos)
    paso = 7.0 / 80  # 3.5 de trazo y 3.5 de hueco sobre r=80
    for i in range(int(math.tau / paso)):
        a0 = math.degrees(i * paso)
        td.arc([c - _u(80), c - _u(80), c + _u(80), c + _u(80)], a0, a0 + math.degrees(paso / 2),
               fill=(40, 84, 2, 107), width=int(_u(1.4)))
    canvas.alpha_composite(trazos)

    # texto circular
    texto = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    _arc_text(texto, "★ VALIDAR CORREO ★", 93, True, _font(int(_u(11.5)), True), (24, 56, 2, 255), 2.4)
    tip = (tipologia or "").upper()[:14]
    abajo = f"SHA-256 · {tip}"
    if saludo and saludo.strip():
        abajo = " ".join(saludo.split()).upper()[:24]  # solo la palabra saludo, sin la taxonomía
    _arc_text(texto, abajo, 93, False, _font(int(_u(10)), True), (29, 66, 3, 255), 1.6)
    canvas.alpha_composite(texto)

    # escudo central
    borde = ([(150, 93), (188, 106), (188, 142)] + _bez((188, 142), (188, 168), (171, 186), (150, 197))
             + _bez((150, 197), (129, 186), (112, 168), (112, 142)) + [(112, 106)])
    interior = ([(150, 99), (182, 110), (182, 141)] + _bez((182, 141), (182, 163), (168, 179), (150, 189))
                + _bez((150, 189), (132, 179), (118, 163), (118, 141)) + [(118, 110)])
    px = lambda pts: [(_u(x), _u(y)) for x, y in pts]  # noqa: E731
    d.polygon(px(borde), fill=(98, 191, 15, 255))
    d.line(px(borde + [borde[0]]), fill=(27, 61, 2, 255), width=int(_u(2.4)), joint="curve")
    d.line(px(interior + [interior[0]]), fill=(215, 255, 130, 166), width=int(_u(1.4)), joint="curve")
    sigla = _font(int(_u(27)), True)
    d.text((c, _u(151.2)), "IESS", font=sigla, fill=(229, 255, 170, 255), anchor="ms")
    d.text((c, _u(150)), "IESS", font=sigla, fill=INK + (255,), anchor="ms")
    d.line([(_u(127), _u(156.5)), (_u(173), _u(156.5))], fill=(27, 61, 2, 128), width=int(_u(1.4)))
    d.text((c, _u(166)), (codigo or "SELLACORREO")[:14], font=_font(int(_u(7.4)), True), fill=INK + (255,), anchor="mm")

    # asteriscos: uno por cada opción de «Hash de seguridad» integrada
    sep = 9.8
    for i in range(n):
        _asterisco(d, c + _u((i - (n - 1) / 2) * sep), _u(181.5), 3.8, INK + (255,))

    # destello de cera pulida
    flash = Image.new("RGBA", (int(_u(70)), int(_u(46))), (0, 0, 0, 0))
    ImageDraw.Draw(flash).ellipse([_u(7), _u(10), _u(63), _u(34)], fill=(255, 255, 255, 66))
    flash = flash.rotate(32, resample=Image.BICUBIC)
    canvas.alpha_composite(flash, (int(_u(102 - 35)), int(_u(84 - 23))))

    out = canvas.resize((size, size), Image.LANCZOS)
    buf = io.BytesIO()
    out.save(buf, "PNG", optimize=True)
    return buf.getvalue()
