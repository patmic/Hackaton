// Ondas sinusoidales que "respiran" con la voz del robot (o la tuya mientras escucha).
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'voz.dart';

class OndasVoz extends StatefulWidget {
  const OndasVoz({super.key, required this.color, this.alto = 64});
  final Color color;
  final double alto;

  @override
  State<OndasVoz> createState() => _OndasVozState();
}

class _OndasVozState extends State<OndasVoz> with SingleTickerProviderStateMixin {
  late final _t = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  double _energia = 0.08;

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: Listenable.merge([_t, Voz.i.silaba, Voz.i.hablando, Voz.i.escuchando]),
        builder: (_, __) {
          final activo = Voz.i.hablando.value || Voz.i.escuchando.value;
          final meta = Voz.i.hablando.value ? 0.45 + Voz.i.silaba.value * 0.55 : (Voz.i.escuchando.value ? 0.55 : 0.08);
          _energia += (meta - _energia) * 0.12; // suavizado
          return SizedBox(
            height: widget.alto,
            width: double.infinity,
            child: CustomPaint(painter: _Ondas(_t.value * 2 * pi * 6, _energia, widget.color, activo)),
          );
        },
      ),
    );
  }
}

class _Ondas extends CustomPainter {
  _Ondas(this.fase, this.energia, this.color, this.activo);
  final double fase, energia;
  final Color color;
  final bool activo;

  @override
  void paint(Canvas canvas, Size s) {
    final capas = [
      (frec: 1.6, vel: 1.0, amp: 1.0, alfa: 0.95, grosor: 3.2),
      (frec: 2.3, vel: -1.3, amp: 0.7, alfa: 0.55, grosor: 2.4),
      (frec: 3.1, vel: 0.8, amp: 0.45, alfa: 0.35, grosor: 2.0),
    ];
    final mitad = s.height / 2;
    for (final c in capas) {
      final path = Path();
      for (var x = 0.0; x <= s.width; x += 3) {
        final u = x / s.width;
        final envolvente = sin(pi * u); // se apaga en los bordes
        final y = mitad +
            sin(u * 2 * pi * c.frec + fase * c.vel) * mitad * 0.85 * energia * c.amp * envolvente +
            sin(u * 2 * pi * c.frec * 2.1 - fase * 0.6) * mitad * 0.12 * energia * envolvente;
        x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = c.grosor
            ..strokeCap = StrokeCap.round
            ..color = color.withValues(alpha: c.alfa * (activo ? 1 : 0.6)));
    }
  }

  @override
  bool shouldRepaint(_Ondas o) => true;
}
