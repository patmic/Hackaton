import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:theme_light/theme_light.dart';

import '../voz/voz.dart';

enum EstadoRobot { reposo, escuchando, analizando, seguro, alerta }

enum Forma { circulo, arco, plena }

/// Robot guardián animado: respira, parpadea, habla y muestra el estado del análisis.
class RobotGuardia extends StatefulWidget {
  const RobotGuardia({
    super.key,
    required this.estado,
    this.tam = 260,
    this.forma = Forma.circulo,
    this.alTocar,
  });

  final EstadoRobot estado;
  final double tam;
  final Forma forma;
  final VoidCallback? alTocar;

  @override
  State<RobotGuardia> createState() => _RobotGuardiaState();
}

class _RobotGuardiaState extends State<RobotGuardia>
    with TickerProviderStateMixin {
  late final _respira = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat(reverse: true);
  late final _gira = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();
  late final _parpado = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 130),
  );
  late final _rebote = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  Timer? _timer;
  final _rnd = Random();
  double _boca = 0;

  @override
  void initState() {
    super.initState();
    _programarParpadeo();
  }

  void _programarParpadeo() {
    _timer = Timer(Duration(milliseconds: 2200 + _rnd.nextInt(3800)), () async {
      if (!mounted) return;
      await _parpado.forward();
      await _parpado.reverse();
      if (_rnd.nextDouble() < 0.25) {
        await _parpado.forward();
        await _parpado.reverse();
      }
      _programarParpadeo();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _respira.dispose();
    _gira.dispose();
    _parpado.dispose();
    _rebote.dispose();
    super.dispose();
  }

  Color get _colorOjos => switch (widget.estado) {
    EstadoRobot.alerta => ThemeLightTokens.errorForeground,
    EstadoRobot.seguro => ThemeLightTokens.okForeground,
    EstadoRobot.analizando => Color.lerp(
      ThemeLightTokens.warnForeground,
      ThemeLightTokens.theme,
      sin(_gira.value * 2 * pi * 2) * 0.5 + 0.5,
    )!,
    EstadoRobot.escuchando => ThemeLightTokens.brand,
    EstadoRobot.reposo => ThemeLightTokens.theme,
  };

  Color get _colorAura => switch (widget.estado) {
    EstadoRobot.alerta => ThemeLightTokens.errorForeground,
    EstadoRobot.seguro => ThemeLightTokens.okForeground,
    EstadoRobot.escuchando => ThemeLightTokens.brand,
    EstadoRobot.analizando => ThemeLightTokens.warnForeground,
    EstadoRobot.reposo => ThemeLightTokens.theme,
  };

  double _calcularBoca(bool hablando, double silaba, bool reducido) {
    final objetivo = hablando && !reducido
        ? (0.25 + 0.75 * sin(_gira.value * 2 * pi * 3).abs()) *
              (0.55 + 0.45 * silaba)
        : 0.0;
    _boca += (objetivo - _boca) * 0.35;
    return _boca < 0.02 ? 0 : _boca;
  }

  @override
  Widget build(BuildContext context) {
    final reducido = MediaQuery.of(context).disableAnimations;
    return Semantics(
      label: 'AIess, robot guardián. Toca para escucharle',
      button: widget.alTocar != null,
      child: GestureDetector(
        onTap: () {
          _rebote.forward(from: 0);
          widget.alTocar?.call();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _respira,
            _gira,
            _parpado,
            _rebote,
            Voz.i.silaba,
            Voz.i.hablando,
          ]),
          builder: (context, _) {
            final hablando = Voz.i.hablando.value;
            final silaba = Voz.i.silaba.value;
            final boca = _calcularBoca(hablando, silaba, reducido);
            final respira = reducido
                ? 0.0
                : Curves.easeInOut.transform(_respira.value);
            final rebote = sin(_rebote.value * pi) * 0.035;
            final escala = 1 + respira * 0.012 + rebote;
            final robot = CustomPaint(
              painter: _RobotPintor(
                estado: widget.estado,
                ojos: _colorOjos,
                parpado: _parpado.value,
                boca: boca,
                escaner: widget.estado == EstadoRobot.analizando
                    ? _gira.value
                    : null,
              ),
            );

            if (widget.forma == Forma.plena) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final lado = min(
                    min(constraints.maxWidth * 0.8, constraints.maxHeight * 0.9),
                    460.0,
                  );
                  return DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ThemeLightTokens.background,
                          ThemeLightTokens.page,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: escala,
                        child: SizedBox.square(
                          dimension: lado,
                          child: robot,
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            final arco = widget.forma == Forma.arco;
            final alto = arco ? widget.tam * 1.22 : widget.tam;
            return SizedBox(
              width: widget.tam + 40,
              height: alto + 40,
              child: CustomPaint(
                painter: _AuraRobot(
                  color: _colorAura,
                  estado: widget.estado,
                  giro: _gira.value,
                  silaba: hablando ? max(silaba, 0.25) : 0,
                  respira: respira,
                  arco: arco,
                ),
                child: Center(
                  child: Transform.scale(
                    scale: escala,
                    child: SizedBox(
                      width: widget.tam,
                      height: alto,
                      child: robot,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RobotPintor extends CustomPainter {
  const _RobotPintor({
    required this.estado,
    required this.ojos,
    required this.parpado,
    required this.boca,
    required this.escaner,
  });

  final EstadoRobot estado;
  final Color ojos;
  final double parpado;
  final double boca;
  final double? escaner;

  @override
  void paint(Canvas canvas, Size size) {
    const ancho = 300.0;
    const alto = 340.0;
    final escala = min(size.width / ancho, size.height / alto);
    canvas.save();
    canvas.translate(
      (size.width - ancho * escala) / 2,
      (size.height - alto * escala) / 2,
    );
    canvas.scale(escala);

    final sombra = Paint()
      ..color = ThemeLightTokens.deep.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawOval(
      const Rect.fromLTWH(60, 307, 180, 20),
      sombra,
    );

    _dibujarAntena(canvas);
    _dibujarOrejas(canvas);
    _dibujarCuerpo(canvas);
    _dibujarCabeza(canvas);
    _dibujarVisor(canvas);
    _dibujarEmblema(canvas);
    canvas.restore();
  }

  void _dibujarAntena(Canvas canvas) {
    final linea = Paint()
      ..color = ThemeLightTokens.brand
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(150, 45), const Offset(150, 28), linea);
    canvas.drawCircle(
      const Offset(150, 22),
      12,
      Paint()..color = ThemeLightTokens.theme,
    );
    canvas.drawCircle(
      const Offset(150, 22),
      5,
      Paint()..color = ThemeLightTokens.background,
    );
  }

  void _dibujarOrejas(Canvas canvas) {
    final metal = Paint()..color = ThemeLightTokens.brand;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 91, 35, 56),
        const Radius.circular(13),
      ),
      metal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(233, 91, 35, 56),
        const Radius.circular(13),
      ),
      metal,
    );
    for (final x in [49.0, 251.0]) {
      canvas.drawCircle(
        Offset(x, 119),
        6,
        Paint()..color = ThemeLightTokens.primaryContainer,
      );
    }
  }

  void _dibujarCuerpo(Canvas canvas) {
    final cuerpo = RRect.fromRectAndRadius(
      const Rect.fromLTWH(68, 188, 164, 119),
      const Radius.circular(27),
    );
    canvas.drawRRect(
      cuerpo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ThemeLightTokens.background, ThemeLightTokens.primaryContainer],
        ).createShader(cuerpo.outerRect),
    );
    canvas.drawRRect(
      cuerpo,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = ThemeLightTokens.cardBorder,
    );

    final hombro = Paint()..color = ThemeLightTokens.brand;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(51, 202, 25, 63),
        const Radius.circular(12),
      ),
      hombro,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(224, 202, 25, 63),
        const Radius.circular(12),
      ),
      hombro,
    );

    final pecho = RRect.fromRectAndRadius(
      const Rect.fromLTWH(95, 205, 110, 77),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      pecho,
      Paint()..color = ThemeLightTokens.background,
    );
    canvas.drawRRect(
      pecho,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ThemeLightTokens.border,
    );

    final shield = Path()
      ..moveTo(150, 215)
      ..lineTo(174, 224)
      ..lineTo(171, 244)
      ..quadraticBezierTo(168, 258, 150, 269)
      ..quadraticBezierTo(132, 258, 129, 244)
      ..lineTo(126, 224)
      ..close();
    final colorEstado = switch (estado) {
      EstadoRobot.alerta => ThemeLightTokens.errorForeground,
      EstadoRobot.seguro => ThemeLightTokens.okForeground,
      _ => ThemeLightTokens.theme,
    };
    canvas.drawPath(shield, Paint()..color = colorEstado);
    canvas.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ThemeLightTokens.background,
    );
    _texto(canvas, 'A', const Offset(150, 236), 23, ThemeLightTokens.background);

    final luz = estado == EstadoRobot.alerta
        ? ThemeLightTokens.errorForeground
        : estado == EstadoRobot.seguro
        ? ThemeLightTokens.okForeground
        : ThemeLightTokens.theme;
    canvas.drawCircle(const Offset(84, 220), 5, Paint()..color = luz);
    canvas.drawCircle(const Offset(216, 220), 5, Paint()..color = luz);
    _texto(canvas, 'AIESS', const Offset(150, 293), 10, ThemeLightTokens.deep);
  }

  void _dibujarCabeza(Canvas canvas) {
    final cabeza = RRect.fromRectAndRadius(
      const Rect.fromLTWH(51, 48, 198, 140),
      const Radius.circular(34),
    );
    canvas.drawRRect(
      cabeza,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ThemeLightTokens.brand, ThemeLightTokens.deep],
        ).createShader(cabeza.outerRect),
    );
    canvas.drawRRect(
      cabeza,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = ThemeLightTokens.background,
    );
    final brillo = RRect.fromRectAndRadius(
      const Rect.fromLTWH(66, 60, 168, 9),
      const Radius.circular(5),
    );
    canvas.drawRRect(
      brillo,
      Paint()..color = ThemeLightTokens.background.withValues(alpha: 0.25),
    );
  }

  void _dibujarVisor(Canvas canvas) {
    final visor = RRect.fromRectAndRadius(
      const Rect.fromLTWH(71, 82, 158, 86),
      const Radius.circular(22),
    );
    canvas.drawRRect(
      visor,
      Paint()..color = ThemeLightTokens.nav,
    );
    canvas.drawRRect(
      visor,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ThemeLightTokens.background.withValues(alpha: 0.4),
    );

    canvas.save();
    canvas.clipRRect(visor);
    final altoOjo = max(4.0, 23 * (1 - parpado));
    for (final x in [113.0, 187.0]) {
      final ojo = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, 119), width: 24, height: altoOjo),
        Radius.circular(altoOjo / 2),
      );
      canvas.drawRRect(
        ojo,
        Paint()
          ..color = ojos.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawRRect(ojo, Paint()..color = ojos);
    }

    final altoBoca = 3 + boca * 13;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(150, 148),
          width: 31,
          height: altoBoca,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = ojos,
    );

    final avance = escaner;
    if (avance != null) {
      final y = 86 + Curves.easeInOut.transform(
        avance < 0.5 ? avance * 2 : 2 - avance * 2,
      ) * 78;
      final banda = Rect.fromLTWH(71, y - 8, 158, 16);
      canvas.drawRect(
        banda,
        Paint()..color = ThemeLightTokens.theme.withValues(alpha: 0.18),
      );
      canvas.drawLine(
        Offset(78, y),
        Offset(222, y),
        Paint()
          ..color = ThemeLightTokens.theme
          ..strokeWidth = 2,
      );
    }
    canvas.restore();
  }

  void _dibujarEmblema(Canvas canvas) {
    canvas.drawCircle(
      const Offset(222, 185),
      15,
      Paint()..color = ThemeLightTokens.background,
    );
    canvas.drawCircle(
      const Offset(222, 185),
      11,
      Paint()..color = ThemeLightTokens.theme,
    );
    canvas.drawCircle(
      const Offset(222, 185),
      4,
      Paint()..color = ThemeLightTokens.background,
    );
  }

  void _texto(Canvas canvas, String texto, Offset centro, double tam, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          color: color,
          fontSize: tam,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, centro - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(_RobotPintor oldDelegate) =>
      oldDelegate.estado != estado ||
      oldDelegate.ojos != ojos ||
      oldDelegate.parpado != parpado ||
      oldDelegate.boca != boca ||
      oldDelegate.escaner != escaner;
}

class _AuraRobot extends CustomPainter {
  const _AuraRobot({
    required this.color,
    required this.estado,
    required this.giro,
    required this.silaba,
    required this.respira,
    required this.arco,
  });

  final Color color;
  final EstadoRobot estado;
  final double giro;
  final double silaba;
  final double respira;
  final bool arco;

  Path _forma(Size size, double extra) {
    final rect = Rect.fromLTWH(
      14 - extra,
      14 - extra,
      size.width - 28 + 2 * extra,
      size.height - 28 + 2 * extra,
    );
    final arriba = Radius.circular(rect.width / 2);
    final abajo = Radius.circular(arco ? 44 + extra : rect.width / 2);
    return Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: arriba,
          topRight: arriba,
          bottomLeft: abajo,
          bottomRight: abajo,
        ),
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final borde = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + silaba * 4
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.8);
    final forma = _forma(size, respira * 2);
    switch (estado) {
      case EstadoRobot.analizando:
        canvas.drawPath(
          forma,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = color.withValues(alpha: 0.18),
        );
        final metric = forma.computeMetrics().first;
        final inicio = giro * metric.length;
        final fin = inicio + metric.length * 0.2;
        if (fin <= metric.length) {
          canvas.drawPath(metric.extractPath(inicio, fin), borde..strokeWidth = 5);
        } else {
          canvas.drawPath(
            metric.extractPath(inicio, metric.length),
            borde..strokeWidth = 5,
          );
          canvas.drawPath(
            metric.extractPath(0, fin - metric.length),
            borde..strokeWidth = 5,
          );
        }
      case EstadoRobot.escuchando:
        canvas.drawPath(forma, borde);
        for (var k = 0; k < 2; k++) {
          final fase = (giro + k * 0.5) % 1;
          canvas.drawPath(
            _forma(size, fase * 12),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = color.withValues(alpha: (1 - fase) * 0.45),
          );
        }
      default:
        canvas.drawPath(forma, borde);
        if (silaba > 0 && !arco) {
          for (var k = 0; k < 3; k++) {
            final fase = (giro * 1.5 + k / 3) % 1;
            canvas.drawPath(
              _forma(size, 6 + fase * 18),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = color.withValues(alpha: (1 - fase) * 0.35),
            );
          }
        }
    }
  }

  @override
  bool shouldRepaint(_AuraRobot oldDelegate) => true;
}
