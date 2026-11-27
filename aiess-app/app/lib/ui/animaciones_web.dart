// Animaciones propias de la web de escritorio (con mouse). Igual que en el aula: cada una tiene un
// significado, es finita y si el sistema pide «reducir movimiento» todo queda quieto.
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:capacitacion/src/presentation/widgets/animaciones.dart';

export 'package:capacitacion/src/presentation/widgets/animaciones.dart'
    show Aparecer, Saltar, sinMovimiento;

/// Al pasar el mouse el elemento se eleva un poco; al presionarlo se hunde. Dice «esto se puede tocar».
class Flotar extends StatefulWidget {
  const Flotar({
    super.key,
    required this.child,
    this.activo = true,
    this.foco = true,
  });
  final Widget child;
  final bool activo;

  /// Dibuja también el anillo de foco al llegar con Tab.
  final bool foco;

  @override
  State<Flotar> createState() => _FlotarState();
}

class _FlotarState extends State<Flotar> {
  bool _encima = false, _abajo = false;

  @override
  Widget build(BuildContext context) {
    final quieto = sinMovimiento(context) || !widget.activo;
    final escala = quieto ? 1.0 : (_abajo ? 0.96 : (_encima ? 1.03 : 1.0));
    final subir = quieto || _abajo || !_encima ? 0.0 : -0.06;
    return MouseRegion(
      onEnter: (_) => setState(() => _encima = true),
      onExit: (_) => setState(() => _encima = _abajo = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _abajo = true),
        onPointerUp: (_) => setState(() => _abajo = false),
        onPointerCancel: (_) => setState(() => _abajo = false),
        child: AnimatedSlide(
          offset: Offset(0, subir),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: escala,
            duration: Duration(milliseconds: _abajo ? 90 : 180),
            curve: Curves.easeOutCubic,
            child: widget.foco ? AnilloFoco(child: widget.child) : widget.child,
          ),
        ),
      ),
    );
  }
}

/// Se sacude una vez al aparecer (alerta: «¡ojo con esto!»).
class SacudirAlEntrar extends StatefulWidget {
  const SacudirAlEntrar({super.key, required this.child, this.retraso = 250});
  final Widget child;
  final int retraso;

  @override
  State<SacudirAlEntrar> createState() => _SacudirAlEntrarState();
}

class _SacudirAlEntrarState extends State<SacudirAlEntrar>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    if (sinMovimiento(context)) return;
    Future.delayed(Duration(milliseconds: widget.retraso), () {
      if (mounted) _c.forward();
    });
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
      offset: Offset(sin(_c.value * pi * 6) * 9 * (1 - _c.value), 0),
      child: child,
    ),
    child: widget.child,
  );
}

/// Un anillo que se expande y se desvanece UNA vez detrás del ícono del veredicto.
class Onda extends StatefulWidget {
  const Onda({super.key, required this.child, required this.color});
  final Widget child;
  final Color color;

  @override
  State<Onda> createState() => _OndaState();
}

class _OndaState extends State<Onda> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    if (!sinMovimiento(context)) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) {
      final t = Curves.easeOutCubic.transform(_c.value);
      return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (_c.isAnimating)
            for (final d in [0.0, 0.25])
              Opacity(
                opacity: (1 - ((t - d) / (1 - d)).clamp(0.0, 1.0)) * 0.7,
                child: Transform.scale(
                  scale: 1 + ((t - d) / (1 - d)).clamp(0.0, 1.0) * 1.4,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.color, width: 3),
                    ),
                  ),
                ),
              ),
          child!,
        ],
      );
    },
    child: widget.child,
  );
}

/// Transición entre los estados del panel de resultado: se funde, sube un poco y crece.
Widget transicionResultado(Widget child, Animation<double> a) {
  final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
  return FadeTransition(
    opacity: c,
    alwaysIncludeSemantics: true,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(c),
      child: ScaleTransition(
        scale: Tween(begin: 0.97, end: 1.0).animate(c),
        alignment: Alignment.topCenter,
        child: child,
      ),
    ),
  );
}

/// Anillo de foco bien visible (3 px, alto contraste) alrededor de un botón cuando se llega con Tab.
/// Así quien navega con teclado siempre sabe dónde está (WCAG 2.4.7).
class AnilloFoco extends StatefulWidget {
  const AnilloFoco({
    super.key,
    required this.child,
    this.radio = 40,
    this.color = const Color(0xFFE8A317),
  });
  final Widget child;
  final double radio;
  final Color color;

  @override
  State<AnilloFoco> createState() => _AnilloFocoState();
}

class _AnilloFocoState extends State<AnilloFoco> {
  bool _foco = false;

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onFocusChange: (f) => setState(() => _foco = f),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radio),
        border: Border.all(
          color: _foco ? widget.color : Colors.transparent,
          width: 3,
        ),
      ),
      child: widget.child,
    ),
  );
}

/// Hace que algo que solo se tocaba (el robot) también se use con teclado: Tab llega, Enter o
/// Espacio lo activan, y se ve el anillo de foco.
class Enfocable extends StatelessWidget {
  const Enfocable({
    super.key,
    required this.child,
    required this.alActivar,
    required this.etiqueta,
  });
  final Widget child;
  final VoidCallback alActivar;
  final String etiqueta;

  @override
  Widget build(BuildContext context) => AnilloFoco(
    radio: 999,
    child: FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            alActivar();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        label: etiqueta,
        excludeSemantics: true,
        onTap: alActivar,
        child: child,
      ),
    ),
  );
}
