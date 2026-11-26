import 'dart:math';

import 'package:flutter/material.dart';

/// Paleta "pantera de la selva".
class Tono {
  static const pelaje = Color(0xFF1C1B33);
  static const hojaNoche = Color(0xFF26254A);
  static const iris = Color(0xFFF2B33D);
  static const alerta = Color(0xFF9E1F18);
  static const alertaHoja = Color(0xFFB8322A);
  static const selva = Color(0xFF145C3D);
  static const selvaHoja = Color(0xFF1B7550);
  static const niebla = Color(0xFFECEFF5);
}

ThemeData temaAIess() {
  const fuente = 'Atkinson';
  final base = ThemeData(useMaterial3: true, fontFamily: fuente, colorSchemeSeed: Tono.pelaje, brightness: Brightness.dark);
  return base.copyWith(
    scaffoldBackgroundColor: Tono.pelaje,
    textTheme: base.textTheme.apply(fontFamily: fuente, bodyColor: Colors.white, displayColor: Colors.white),
  );
}

/// Botón único, grande (76 dp), en forma de píldora.
class BotonGrande extends StatelessWidget {
  const BotonGrande({super.key, required this.texto, required this.icono, required this.alPulsar,
      this.fondo = Tono.iris, this.tinta = Tono.pelaje});
  final String texto;
  final IconData icono;
  final VoidCallback? alPulsar;
  final Color fondo, tinta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 76,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: fondo,
          foregroundColor: tinta,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontFamily: 'Atkinson', fontSize: 23, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
        onPressed: alPulsar,
        icon: Icon(icono, size: 30),
        label: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

/// Fondo de selva nocturna: hojas de monstera dibujadas, color según el estado.
class FondoSelva extends StatelessWidget {
  const FondoSelva({super.key, required this.color, required this.hoja, required this.child});
  final Color color, hoja;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, c, __) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: hoja),
        duration: const Duration(milliseconds: 600),
        builder: (_, h, __) => CustomPaint(painter: _Hojas(c ?? color, h ?? hoja), child: child),
      ),
    );
  }
}

class _Hojas extends CustomPainter {
  _Hojas(this.fondo, this.hoja);
  final Color fondo, hoja;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = fondo);
    final p = Paint()..color = hoja;
    _monstera(canvas, Offset(-s.width * 0.08, s.height * 0.10), s.width * 0.55, 0.5, p);
    _monstera(canvas, Offset(s.width * 1.06, s.height * 0.02), s.width * 0.48, 2.5, p);
    _monstera(canvas, Offset(s.width * 1.02, s.height * 0.70), s.width * 0.40, 3.6, p);
    _monstera(canvas, Offset(-s.width * 0.05, s.height * 0.86), s.width * 0.34, -0.6, p);
  }

  void _monstera(Canvas canvas, Offset c, double r, double ang, Paint p) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(ang);
    final hojaPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(r * 0.55, -r * 0.55, r * 1.05, -r * 0.25, r, r * 0.12)
      ..cubicTo(r * 0.95, r * 0.55, r * 0.45, r * 0.62, 0, 0);
    // Cortes característicos de la monstera.
    final cortes = Path();
    for (var k = 0; k < 4; k++) {
      final t = 0.32 + k * 0.17;
      final a = -0.2 + k * 0.05;
      final base = Offset(r * t, r * 0.04 * k);
      cortes.addPath(
          Path()
            ..moveTo(base.dx, base.dy)
            ..lineTo(base.dx + r * 0.5 * cos(a - 0.9), base.dy + r * 0.5 * sin(a - 0.9))
            ..lineTo(base.dx + r * 0.5 * cos(a - 0.75), base.dy + r * 0.5 * sin(a - 0.75))
            ..close(),
          Offset.zero);
      cortes.addPath(
          Path()
            ..moveTo(base.dx, base.dy)
            ..lineTo(base.dx + r * 0.45 * cos(a + 0.95), base.dy + r * 0.45 * sin(a + 0.95))
            ..lineTo(base.dx + r * 0.45 * cos(a + 0.8), base.dy + r * 0.45 * sin(a + 0.8))
            ..close(),
          Offset.zero);
    }
    canvas.drawPath(Path.combine(PathOperation.difference, hojaPath, cortes), p);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Hojas o) => o.fondo != fondo || o.hoja != hoja;
}
