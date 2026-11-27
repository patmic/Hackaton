// Texto que "se va generando": karaoke sincronizado con la voz y pasos de carga que se arman en vivo.
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../features/voz/voz.dart';

/// Revela el texto a medida que el cóndor lo dice. Si el motor de voz no informa el avance,
/// usa una máquina de escribir (~16 caracteres por segundo). Lo ya dicho va en blanco; lo que falta, tenue.
class TextoVivo extends StatefulWidget {
  const TextoVivo(
    this.texto, {
    super.key,
    this.estilo,
    this.alineacion = TextAlign.left,
  });
  final TextAlign alineacion;
  final String texto;
  final TextStyle? estilo;

  @override
  State<TextoVivo> createState() => _TextoVivoState();
}

class _TextoVivoState extends State<TextoVivo> {
  Timer? _maquina;
  int _escrito = 0;

  @override
  void initState() {
    super.initState();
    _arrancar();
  }

  @override
  void didUpdateWidget(TextoVivo old) {
    super.didUpdateWidget(old);
    if (old.texto != widget.texto) _arrancar();
  }

  void _arrancar() {
    _maquina?.cancel();
    _escrito = 0;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _escrito = widget.texto.length;
      return;
    }
    _maquina = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) return;
      setState(() => _escrito = (_escrito + 1).clamp(0, widget.texto.length));
      if (_escrito >= widget.texto.length) t.cancel();
    });
  }

  @override
  void dispose() {
    _maquina?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base =
        widget.estilo ??
        DefaultTextStyle.of(context).style.copyWith(fontSize: 19, height: 1.4);
    return ValueListenableBuilder<int>(
      valueListenable: Voz.i.avance,
      builder: (_, dicho, __) {
        final t = widget.texto;
        final mismoTexto = Voz.i.actual == t;
        final visible =
            (mismoTexto ? (dicho > _escrito ? dicho : _escrito) : _escrito)
                .clamp(0, t.length);
        final hablado = mismoTexto ? dicho.clamp(0, visible) : visible;
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: t.substring(0, hablado), style: base),
              TextSpan(
                text: t.substring(hablado, visible),
                style: base.copyWith(
                  color: base.color?.withValues(alpha: 0.55),
                ),
              ),
              if (visible < t.length)
                TextSpan(
                  text: ' ▍',
                  style: base.copyWith(
                    color: base.color?.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          textAlign: widget.alineacion,
        );
      },
    );
  }
}

/// Lista de pasos que se arma en vivo: los terminados con ✓, el actual con puntos animados y barra si hay progreso.
class PasosCarga extends StatelessWidget {
  const PasosCarga({
    super.key,
    required this.pasos,
    this.progreso,
    this.color,
    this.acento,
  });
  final List<String> pasos;
  final double? progreso;

  /// Color del texto y del acento (✓, puntos, barra). Por defecto, los del tema claro.
  final Color? color, acento;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final tinta = color ?? esquema.onSurface;
    final marca = acento ?? esquema.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < pasos.length; i++)
          TweenAnimationBuilder<double>(
            key: ValueKey(pasos[i]),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (_, a, child) => Opacity(
              opacity: a,
              child: Transform.translate(
                offset: Offset(0, (1 - a) * 14),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 28,
                    child: i < pasos.length - 1
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: marca,
                            size: 24,
                          )
                        : _Puntos(color: marca),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      pasos[i],
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: i == pasos.length - 1
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: tinta.withValues(
                          alpha: i == pasos.length - 1 ? 1 : 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (progreso != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progreso),
                duration: const Duration(milliseconds: 300),
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  color: marca,
                  backgroundColor: tinta.withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Puntos extends StatefulWidget {
  const _Puntos({required this.color});
  final Color color;

  @override
  State<_Puntos> createState() => _PuntosState();
}

class _PuntosState extends State<_Puntos> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var k = 0; k < 3; k++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(
                alpha: ((_c.value * 3 - k) % 3) < 1 ? 1 : 0.3,
              ),
            ),
          ),
      ],
    ),
  );
}
