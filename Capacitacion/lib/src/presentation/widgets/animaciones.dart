// Animaciones de las microlecciones: dan vida y retroalimentación, pero con calma para personas mayores.
// Reglas: cada animación tiene un significado (aparecer, acertar, fallar, avanzar), es finita (nunca en bucle),
// y si el celular pide "quitar animaciones" todo se muestra al instante.
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

bool sinMovimiento(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Entrada suave (sube y aparece). [orden] escalona varios elementos, uno tras otro.
class Aparecer extends StatefulWidget {
  const Aparecer({
    super.key,
    required this.child,
    this.orden = 0,
    this.desplazamiento = 24,
  });
  final Widget child;
  final int orden;
  final double desplazamiento;

  @override
  State<Aparecer> createState() => _AparecerState();
}

class _AparecerState extends State<Aparecer>
    with SingleTickerProviderStateMixin {
  static const _base = 420, _paso = 80;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _base + widget.orden.clamp(0, 10) * _paso),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (sinMovimiento(context)) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inicio =
        (widget.orden.clamp(0, 10) * _paso) /
        (_base + widget.orden.clamp(0, 10) * _paso);
    final a = CurvedAnimation(
      parent: _c,
      curve: Interval(inicio, 1, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (_, child) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * widget.desplazamiento),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Se hunde un poco al presionar (sin quitarle el toque al botón de adentro) y vibra suave.
class Rebote extends StatefulWidget {
  const Rebote({super.key, required this.child, this.escala = 0.95});
  final Widget child;
  final double escala;

  @override
  State<Rebote> createState() => _ReboteState();
}

class _ReboteState extends State<Rebote> {
  bool _abajo = false;

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) {
      HapticFeedback.selectionClick();
      setState(() => _abajo = true);
    },
    onPointerUp: (_) => setState(() => _abajo = false),
    onPointerCancel: (_) => setState(() => _abajo = false),
    child: AnimatedScale(
      scale: _abajo && !sinMovimiento(context) ? widget.escala : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}

/// Sacude el contenido como un "no" cada vez que cambia [disparo] (respuesta equivocada).
class Sacudir extends StatefulWidget {
  const Sacudir({super.key, required this.disparo, required this.child});
  final int disparo;
  final Widget child;

  @override
  State<Sacudir> createState() => _SacudirState();
}

class _SacudirState extends State<Sacudir> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(Sacudir old) {
    super.didUpdateWidget(old);
    if (old.disparo != widget.disparo && !sinMovimiento(context)) {
      HapticFeedback.mediumImpact();
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) => Transform.translate(
      offset: Offset(sin(_c.value * pi * 6) * 10 * (1 - _c.value), 0),
      child: child,
    ),
    child: widget.child,
  );
}

/// Aparece con un rebote elástico (para un logro o una señal encontrada).
class Saltar extends StatelessWidget {
  const Saltar({
    super.key,
    required this.child,
    this.duracion = const Duration(milliseconds: 650),
  });
  final Widget child;
  final Duration duracion;

  @override
  Widget build(BuildContext context) => sinMovimiento(context)
      ? child
      : TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: duracion,
          curve: Curves.elasticOut,
          builder: (_, v, c) => Transform.scale(scale: v, child: c),
          child: child,
        );
}

/// Número que sube contando (puntaje, lecciones hechas).
class ContadorAnimado extends StatelessWidget {
  const ContadorAnimado({
    super.key,
    required this.valor,
    this.estilo,
    this.sufijo = '',
  });
  final int valor;
  final TextStyle? estilo;
  final String sufijo;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: valor.toDouble()),
    duration: sinMovimiento(context)
        ? Duration.zero
        : const Duration(milliseconds: 900),
    curve: Curves.easeOutCubic,
    builder: (_, v, __) => Text('${v.round()}$sufijo', style: estilo),
  );
}

/// Barra de avance que se llena con suavidad.
class BarraAvance extends StatelessWidget {
  const BarraAvance({super.key, required this.valor, this.alto = 12});
  final double valor;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(alto),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: valor.clamp(0, 1)),
        duration: sinMovimiento(context)
            ? Duration.zero
            : const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => LinearProgressIndicator(
          value: v,
          minHeight: alto,
          backgroundColor: esquema.surfaceContainerHighest,
        ),
      ),
    );
  }
}

/// Lluvia de confeti de una sola vez (1,8 s) para celebrar. No intercepta toques.
class Confeti extends StatefulWidget {
  const Confeti({super.key, this.cantidad = 70});
  final int cantidad;

  @override
  State<Confeti> createState() => _ConfetiState();
}

class _ConfetiState extends State<Confeti> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final List<_Pieza> _piezas;

  @override
  void initState() {
    super.initState();
    final r = Random(7);
    _piezas = List.generate(
      widget.cantidad,
      (_) => _Pieza(
        x: r.nextDouble(),
        vx: (r.nextDouble() - 0.5) * 0.5,
        vy: 0.6 + r.nextDouble() * 0.9,
        giro: r.nextDouble() * 6,
        color: _colores[r.nextInt(_colores.length)],
        tam: 6 + r.nextDouble() * 7,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!sinMovimiento(context) && !_c.isAnimating && _c.value == 0) {
      HapticFeedback.heavyImpact();
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static const _colores = [
    Color(0xFF145962),
    Color(0xFF3DB28C),
    Color(0xFFF2B33D),
    Color(0xFFE85D75),
    Color(0xFF4C8DFF),
  ];

  @override
  Widget build(BuildContext context) {
    if (sinMovimiento(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => _c.isCompleted
            ? const SizedBox.shrink()
            : CustomPaint(
                size: Size.infinite,
                painter: _PintorConfeti(_piezas, _c.value),
              ),
      ),
    );
  }
}

class _Pieza {
  _Pieza({
    required this.x,
    required this.vx,
    required this.vy,
    required this.giro,
    required this.color,
    required this.tam,
  });
  final double x, vx, vy, giro, tam;
  final Color color;
}

class _PintorConfeti extends CustomPainter {
  _PintorConfeti(this.piezas, this.t);
  final List<_Pieza> piezas;
  final double t;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint();
    for (final q in piezas) {
      final y = -0.1 * s.height + (q.vy * t + 0.9 * t * t) * s.height;
      final x = (q.x + q.vx * t) * s.width;
      p.color = q.color.withValues(alpha: (1 - t).clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(q.giro + t * 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: q.tam,
            height: q.tam * 0.55,
          ),
          const Radius.circular(2),
        ),
        p,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PintorConfeti o) => o.t != t;
}
