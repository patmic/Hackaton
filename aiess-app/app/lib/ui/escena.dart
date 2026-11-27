// Escena única de la app: foto del cóndor a sangre arriba y, abajo, un panel cuyo borde superior
// es una onda sinusoidal viva (se agita cuando el cóndor habla o te escucha). El color del panel es el mensaje.
import 'dart:ui' show FontVariation;
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../features/mascota/pantera.dart';
import '../features/voz/voz.dart';
import '../features/llm/cerebro.dart';
import 'texto_vivo.dart';

class Paleta {
  // Colores del IESS (sitio oficial): azul 004294, azul oscuro 183675, amarillo FCC602. Rojo/verde solo para el veredicto.
  static const petroleo = Color(0xFF004294);
  static const bermellon = Color(0xFFD6312B);
  static const hoja = Color(0xFF1E8E3E);
  static const ambar = Color(0xFFFCC602);
  static const tintaPetroleo = Color(0xFF183675);

  static Color panel(EstadoPantera e) => switch (e) {
        EstadoPantera.alerta => bermellon,
        EstadoPantera.seguro => hoja,
        _ => petroleo,
      };

  /// Color de la onda fina que flota sobre la foto.
  static Color linea(EstadoPantera e) => switch (e) {
        EstadoPantera.alerta => const Color(0xFFFFB4A9),
        EstadoPantera.seguro => const Color(0xFFB7F0CB),
        EstadoPantera.escuchando => const Color(0xFF9FE0FF),
        _ => ambar,
      };
}

class EscenaPantera extends StatelessWidget {
  const EscenaPantera({
    super.key,
    required this.estado,
    required this.titular,
    required this.boton,
    this.subtitulo = '',
    this.pasos = const [],
    this.progreso,
    this.izquierda,
    this.derecha,
    this.alTocarPantera,
    this.encima,
  });

  final EstadoPantera estado;
  final String titular, subtitulo;
  /// Pasos de carga que se van generando (vacío = mostrar el texto del cóndor).
  final List<String> pasos;
  final double? progreso;
  final Widget boton;
  final Widget? izquierda, derecha, encima;
  final VoidCallback? alTocarPantera;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final alto = mq.size.height;
    // Panel: 42 % de la pantalla, entre 320 y 400 dp. La foto ocupa el resto + lo que tapa la onda.
    final panel = (alto * 0.42).clamp(320.0, 400.0).clamp(0.0, alto * 0.55);
    const m = 24.0; // margen lateral único de toda la escena (rejilla de 8)
    return Scaffold(
      backgroundColor: Paleta.panel(estado),
      body: Stack(
        fit: StackFit.expand, // la escena ocupa toda la pantalla
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: alto - panel + 56,
            child: Pantera(estado: estado, forma: Forma.plena, alTocar: alTocarPantera),
          ),
          if (encima != null) Positioned(left: 0, right: 0, top: 0, height: alto - panel, child: encima!),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: panel + 32,
            child: PanelOla(
              color: Paleta.panel(estado),
              linea: Paleta.linea(estado),
              child: Padding(
                // 48 = espacio de la onda; abajo: zona segura de la barra de navegación + 24.
                padding: EdgeInsets.fromLTRB(m, 48, m, mq.padding.bottom + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      layoutBuilder: (actual, previos) => Stack(alignment: Alignment.topLeft, children: [...previos, if (actual != null) actual]),
                      transitionBuilder: (c, a) => FadeTransition(
                          opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, .12), end: Offset.zero).animate(a), child: c)),
                      child: Text(
                        titular,
                        key: ValueKey(titular),
                        maxLines: 2,
                        style: const TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], fontSize: 32, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.8, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        layoutBuilder: (actual, previos) => Stack(alignment: Alignment.topLeft, children: [...previos, if (actual != null) actual]),
                        child: pasos.isNotEmpty
                            ? Align(key: const ValueKey('pasos'), alignment: Alignment.topLeft, child: PasosCarga(pasos: pasos, progreso: progreso, color: Colors.white, acento: Paleta.ambar))
                            : SingleChildScrollView(
                                key: ValueKey(subtitulo),
                                child: subtitulo.isEmpty
                                    ? const SizedBox.shrink()
                                    : TextoVivo(subtitulo,
                                        estilo: TextStyle(fontSize: 18, height: 1.45, color: Colors.white.withValues(alpha: 0.95))),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    boton,
                  ],
                ),
              ),
            ),
          ),
          // Barra superior: debajo de la barra de estado, mismo margen lateral que el resto.
          Positioned(
            top: mq.padding.top + 8,
            left: m - 8,
            right: m - 8,
            child: Row(children: [
              if (izquierda != null) izquierda!,
              const Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: Cerebro.i.cargando,
                builder: (_, cargando, __) => AnimatedOpacity(
                  opacity: cargando ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2.2, color: Paleta.ambar)),
                      SizedBox(width: 8),
                      Text('Despertando…', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ]),
                  ),
                ),
              ),
              const Spacer(),
              if (derecha != null) derecha!,
            ]),
          ),
        ],
      ),
    );
  }
}

/// Retroalimentación al tocar: se hunde un poco y vibra suave. Usado por todos los botones.
class Presionable extends StatefulWidget {
  const Presionable({super.key, required this.child, required this.alPulsar, this.forma = const StadiumBorder()});
  final Widget child;
  final VoidCallback? alPulsar;
  final ShapeBorder forma;

  @override
  State<Presionable> createState() => _PresionableState();
}

class _PresionableState extends State<Presionable> {
  bool _abajo = false;

  @override
  Widget build(BuildContext context) {
    final activo = widget.alPulsar != null;
    return GestureDetector(
      onTapDown: activo ? (_) => setState(() => _abajo = true) : null,
      onTapCancel: () => setState(() => _abajo = false),
      onTapUp: activo
          ? (_) {
              setState(() => _abajo = false);
              HapticFeedback.lightImpact();
              widget.alPulsar!();
            }
          : null,
      child: AnimatedScale(
        scale: _abajo ? 0.95 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedOpacity(opacity: activo ? 1 : 0.5, duration: const Duration(milliseconds: 200), child: widget.child),
      ),
    );
  }
}

/// Botón de ícono redondo de 48 dp sobre la foto (fondo translúcido para que se lea).
class BotonCirculo extends StatelessWidget {
  const BotonCirculo({super.key, required this.icono, required this.texto, required this.alPulsar});
  final IconData icono;
  final String texto;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: texto,
        child: Presionable(
          alPulsar: alPulsar,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.38), shape: BoxShape.circle),
            child: Icon(icono, color: Colors.white, size: 24),
          ),
        ),
      );
}

class PanelOla extends StatefulWidget {
  const PanelOla({super.key, required this.color, required this.linea, required this.child});
  final Color color, linea;
  final Widget child;

  @override
  State<PanelOla> createState() => _PanelOlaState();
}

class _PanelOlaState extends State<PanelOla> with SingleTickerProviderStateMixin {
  late final _t = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  double _energia = 0.15;

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducido = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: widget.color),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (_, color, child) => AnimatedBuilder(
        animation: Listenable.merge([_t, Voz.i.silaba, Voz.i.hablando, Voz.i.escuchando]),
        builder: (_, __) {
          final meta = Voz.i.hablando.value
              ? 0.55 + Voz.i.silaba.value * 0.45
              : Voz.i.escuchando.value
                  ? 0.6
                  : 0.15;
          _energia += (meta - _energia) * 0.1;
          final fase = reducido ? 0.0 : _t.value * 2 * pi * 8;
          return CustomPaint(
            painter: _LineasOla(fase, _energia, widget.linea),
            child: ClipPath(
              clipper: _BordeOla(fase, _energia),
              child: ColoredBox(color: color ?? widget.color, child: child),
            ),
          );
        },
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// y del borde en x (0..ancho). `capa` desplaza fase y amplitud para las líneas finas.
double _ola(double x, double ancho, double fase, double energia, [int capa = 0]) {
  final u = x / ancho;
  final amp = 4 + 22 * energia;
  return 32 -
      sin(u * 2 * pi * (1.15 + capa * 0.35) + fase * (1 + capa * 0.3) + capa) * amp * (1 - capa * 0.25) -
      sin(u * 2 * pi * 2.7 - fase * 0.7) * amp * 0.22;
}

class _BordeOla extends CustomClipper<Path> {
  _BordeOla(this.fase, this.energia);
  final double fase, energia;

  @override
  Path getClip(Size s) {
    final p = Path()..moveTo(0, _ola(0, s.width, fase, energia));
    for (var x = 4.0; x <= s.width; x += 4) {
      p.lineTo(x, _ola(x, s.width, fase, energia));
    }
    return p
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
  }

  @override
  bool shouldReclip(_BordeOla o) => true;
}

/// Dos ondas finas que flotan sobre la foto, encima del borde (efecto de audio en capas).
class _LineasOla extends CustomPainter {
  _LineasOla(this.fase, this.energia, this.color);
  final double fase, energia;
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    for (var capa = 1; capa <= 2; capa++) {
      final p = Path();
      for (var x = 0.0; x <= s.width; x += 4) {
        final y = _ola(x, s.width, fase, energia, capa) - 6.0 * capa;
        x == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
      }
      canvas.drawPath(
          p,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0 - capa * 0.6
            ..strokeCap = StrokeCap.round
            ..color = color.withValues(alpha: (0.25 + energia * 0.6) / capa));
    }
  }

  @override
  bool shouldRepaint(_LineasOla o) => true;
}

/// Botón principal: 64 dp, radio 20, ícono en disco. Se hunde y vibra al tocarlo.
class BotonUnico extends StatelessWidget {
  const BotonUnico({super.key, required this.texto, required this.icono, required this.alPulsar, this.fondo = Paleta.ambar, this.tinta = Paleta.tintaPetroleo});
  final String texto;
  final IconData icono;
  final VoidCallback? alPulsar;
  final Color fondo, tinta;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: texto,
      child: Presionable(
        alPulsar: alPulsar,
        child: Container(
          height: 64,
          decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: tinta, shape: BoxShape.circle),
                child: Icon(icono, color: fondo, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(texto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], color: tinta, fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón redondo de micrófono (Háblame), 64 dp; se ilumina mientras escucha.
class BotonMicrofono extends StatelessWidget {
  const BotonMicrofono({super.key, required this.escuchando, required this.alPulsar});
  final bool escuchando;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Háblame',
      child: Presionable(
        alPulsar: alPulsar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: escuchando ? Paleta.ambar : Paleta.tintaPetroleo,
            border: Border.all(color: Paleta.ambar, width: 3),
          ),
          child: Icon(Icons.mic_rounded, size: 30, color: escuchando ? Paleta.tintaPetroleo : Paleta.ambar),
        ),
      ),
    );
  }
}
