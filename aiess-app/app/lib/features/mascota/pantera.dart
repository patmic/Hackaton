// La panterita: foto realista animada. Respira, parpadea, sus ojos cambian de color según el estado
// y MUEVE LA BOCA al hablar: la mandíbula de la foto se recorta y baja al ritmo de la voz,
// dejando ver el interior de la boca (el pelaje negro esconde la costura).
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../voz/voz.dart';

enum EstadoPantera { reposo, escuchando, analizando, seguro, alerta }

/// medallon: el círculo del emblema con su anillo dorado justo al borde.
enum Encuadre { completa, cara, medallon }

/// plena: la foto llena todo el espacio que le dé el padre (pantalla principal).
enum Forma { circulo, arco, plena }

/// Geometría del avatar del cóndor andino (assets/img/condor.png, 2048x2048 px, emblema circular).
class _Foto {
  static const asset = 'assets/img/condor.png';
  static const lado = 2048.0;
  static const fondo = Color(0xFF0A1B3A); // azul noche del emblema
  static const ojos = [Offset(1060, 405)]; // de perfil: un solo ojo visible
  static const radioOjo = 30.0;
  static const parpadoColor = Color(0xFF5A2232); // piel rojiza alrededor del ojo
  static const boca = Offset(1205, 558); // comisura del pico
  static const anchoBoca = 230.0;
  static const mandibula = Rect.fromLTRB(1075, 556, 1345, 625); // pico inferior
  static const completa = Rect.fromLTWH(0, 0, lado, lado);
  static const cara = Rect.fromLTWH(640, 130, 820, 820);
  static const medallon = Rect.fromLTWH(66, 66, 1916, 1916);
}

class Pantera extends StatefulWidget {
  const Pantera({super.key, required this.estado, this.tam = 260, this.encuadre = Encuadre.completa, this.forma = Forma.circulo, this.alTocar});
  final EstadoPantera estado;
  final double tam;
  final Encuadre encuadre;
  final Forma forma;
  final VoidCallback? alTocar;

  @override
  State<Pantera> createState() => _PanteraState();
}

class _PanteraState extends State<Pantera> with TickerProviderStateMixin {
  late final _respira = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
  late final _gira = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  late final _parpado = AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
  late final _rebote = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  Timer? _timer;
  final _rnd = Random();
  ui.Image? _img;
  ImageStream? _stream;
  late final _escucha = ImageStreamListener((info, _) {
    if (mounted) setState(() => _img = info.image);
  });
  double _boca = 0;

  @override
  void initState() {
    super.initState();
    _programarParpadeo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream?.removeListener(_escucha);
    _stream = const AssetImage(_Foto.asset).resolve(createLocalImageConfiguration(context))..addListener(_escucha);
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
    _stream?.removeListener(_escucha);
    _respira.dispose();
    _gira.dispose();
    _parpado.dispose();
    _rebote.dispose();
    super.dispose();
  }

  Color? get _colorOjos => switch (widget.estado) {
        EstadoPantera.alerta => const Color(0xFFFF3B2F),
        EstadoPantera.seguro => const Color(0xFF3DDC84),
        EstadoPantera.analizando => Color.lerp(const Color(0xFFF2B33D), const Color(0xFFFFE6A3), sin(_gira.value * 2 * pi * 2) * 0.5 + 0.5),
        _ => null,
      };

  Color get _colorAura => switch (widget.estado) {
        EstadoPantera.alerta => Colors.white,
        EstadoPantera.seguro => const Color(0xFFBFF2D7),
        EstadoPantera.escuchando => const Color(0xFF8FD3FF),
        _ => const Color(0xFFF2B33D),
      };

  /// Apertura de la boca 0..1: sílabas a ~4 por segundo, más abiertas en palabras largas, suavizado.
  double _calcularBoca(bool hablando, double silaba, bool reducido) {
    final meta = hablando && !reducido ? (0.25 + 0.75 * sin(_gira.value * 2 * pi * 3).abs()) * (0.55 + 0.45 * silaba) : 0.0;
    _boca += (meta - _boca) * 0.35;
    return _boca < 0.02 ? 0 : _boca;
  }

  @override
  Widget build(BuildContext context) {
    final reducido = MediaQuery.of(context).disableAnimations;
    final src = switch (widget.encuadre) { Encuadre.cara => _Foto.cara, Encuadre.medallon => _Foto.medallon, _ => _Foto.completa };

    return Semantics(
      label: 'AIess, el cóndor andino guardián',
      button: widget.alTocar != null,
      child: GestureDetector(
        onTap: () {
          _rebote.forward(from: 0);
          widget.alTocar?.call();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_respira, _gira, _parpado, _rebote, Voz.i.silaba, Voz.i.hablando]),
          builder: (context, _) {
            final hablando = Voz.i.hablando.value;
            final silaba = Voz.i.silaba.value;
            final boca = _calcularBoca(hablando, silaba, reducido);
            final resp = reducido ? 0.0 : Curves.easeInOut.transform(_respira.value);
            final rebote = sin(_rebote.value * pi) * 0.05;
            final escala = 1 + resp * 0.012 + rebote;
            final foto = CustomPaint(
              painter: _FotoHablante(
                img: _img,
                src: src,
                alin: widget.forma == Forma.plena ? const Alignment(0, -0.25) : Alignment.center,
                contener: widget.forma == Forma.plena,
                boca: boca,
                tinte: _colorOjos,
                parpado: _parpado.value,
                escaner: widget.estado == EstadoPantera.analizando && widget.forma == Forma.plena ? _gira.value : null,
              ),
            );

            if (widget.forma == Forma.plena) {
              return ClipRect(
                child: Transform.scale(scale: 1.03 + (escala - 1), alignment: const Alignment(0, 0.3), child: SizedBox.expand(child: foto)),
              );
            }
            final t = widget.tam;
            final arco = widget.forma == Forma.arco;
            final alto = arco ? t * 1.22 : t;
            final recorte = arco
                ? BorderRadius.vertical(top: Radius.circular(t / 2), bottom: const Radius.circular(40))
                : BorderRadius.circular(t / 2);
            return SizedBox(
              width: t + 40,
              height: alto + 40,
              child: CustomPaint(
                painter: _Aura(_colorAura, widget.estado, _gira.value, hablando ? max(silaba, 0.25) : 0, resp, arco),
                child: Center(
                  child: Transform.scale(
                    scale: escala,
                    child: ClipRRect(borderRadius: recorte, child: SizedBox(width: t, height: alto, child: foto)),
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

/// Dibuja la foto (BoxFit.cover con alineación), la boca animada, los ojos y el escáner.
class _FotoHablante extends CustomPainter {
  _FotoHablante({required this.img, required this.src, required this.alin, required this.boca, required this.tinte, required this.parpado, this.escaner, this.contener = false});
  final bool contener;
  final ui.Image? img;
  final Rect src;
  final Alignment alin;
  final double boca, parpado;
  final Color? tinte;
  final double? escaner;

  @override
  void paint(Canvas canvas, Size s) {
    final im = img;
    canvas.drawRect(Offset.zero & s, Paint()..color = _Foto.fondo);
    if (im == null) return;
    // contener: el emblema entero (un poco ampliado); cover: recorte que llena el espacio.
    final lado = contener ? min(s.width, s.height) * 1.08 : max(s.width, s.height);
    final esc = lado / src.width;
    final ox = (s.width - lado) * (alin.x + 1) / 2, oy = (s.height - lado) * (alin.y + 1) / 2;
    final k = im.width / _Foto.lado; // por si el archivo no mide exactamente 1080
    Rect enImagen(Rect r) => Rect.fromLTRB(r.left * k, r.top * k, r.right * k, r.bottom * k);
    Offset aPantalla(Offset p) => Offset(ox + (p.dx - src.left) * esc, oy + (p.dy - src.top) * esc);
    Rect rectPantalla(Rect r) => Rect.fromPoints(aPantalla(r.topLeft), aPantalla(r.bottomRight));
    final pintura = Paint()..filterQuality = FilterQuality.medium;

    canvas.drawImageRect(im, enImagen(src), Rect.fromLTWH(ox, oy, lado, lado), pintura);

    // ---- Boca: interior oscuro + mandíbula desplazada hacia abajo.
    if (boca > 0) {
      final abre = boca * 24; // px del avatar original
      final c = aPantalla(_Foto.boca);
      final ancho = _Foto.anchoBoca * esc;
      final alto = (abre * 1.25 + 3) * esc;
      final hueco = Rect.fromCenter(center: c.translate(0, alto / 2 - 2 * esc), width: ancho, height: alto);
      canvas.drawOval(hueco, Paint()..color = const Color(0xFF2A0B12));
      canvas.drawOval(
          Rect.fromCenter(center: hueco.center.translate(0, hueco.height * 0.22), width: ancho * 0.55, height: hueco.height * 0.55),
          Paint()..color = const Color(0xFF9A4656).withValues(alpha: 0.85)); // lengua
      final m = rectPantalla(_Foto.mandibula);
      final destino = m.shift(Offset(0, abre * esc));
      canvas.save();
      canvas.clipRRect(RRect.fromRectAndCorners(destino,
          topLeft: Radius.circular(m.width * 0.35),
          topRight: Radius.circular(m.width * 0.35),
          bottomLeft: Radius.circular(m.width * 0.5),
          bottomRight: Radius.circular(m.width * 0.5)));
      canvas.drawImageRect(im, enImagen(_Foto.mandibula), destino, pintura);
      canvas.restore();
    }

    // ---- Ojos: tinte de estado y párpados.
    final r = _Foto.radioOjo * esc;
    for (final o in _Foto.ojos) {
      final c = aPantalla(o);
      if (tinte != null) {
        canvas.drawCircle(c, r * 1.05, Paint()..color = tinte!.withValues(alpha: 0.55)..blendMode = BlendMode.color);
        canvas.drawCircle(
            c,
            r * 1.7,
            Paint()
              ..shader = RadialGradient(colors: [tinte!.withValues(alpha: 0.35), tinte!.withValues(alpha: 0)])
                  .createShader(Rect.fromCircle(center: c, radius: r * 1.7)));
      }
      if (parpado > 0) {
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCenter(center: c, width: r * 2.7, height: r * 2.3)));
        canvas.drawRect(Rect.fromLTWH(c.dx - r * 1.4, c.dy - r * 1.2, r * 2.8, r * 2.4 * parpado), Paint()..color = _Foto.parpadoColor);
        canvas.restore();
      }
    }

    // ---- Escáner mientras analiza.
    final t = escaner;
    if (t != null) {
      final y = Curves.easeInOut.transform(t < 0.5 ? t * 2 : 2 - t * 2) * s.height;
      final banda = Rect.fromLTWH(0, y - 90, s.width, 90);
      canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF0D3B78).withValues(alpha: 0.18));
      canvas.drawRect(
          banda,
          Paint()
            ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00F2B33D), Color(0x55F2B33D)])
                .createShader(banda));
      canvas.drawLine(Offset(0, y), Offset(s.width, y), Paint()..color = const Color(0xFFF2B33D)..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(_FotoHablante o) => true;
}

class _Aura extends CustomPainter {
  _Aura(this.color, this.estado, this.giro, this.silaba, this.resp, this.arco);
  final Color color;
  final EstadoPantera estado;
  final double giro, silaba, resp;
  final bool arco;

  Path _forma(Size s, double extra) {
    final rect = Rect.fromLTWH(14 - extra, 14 - extra, s.width - 28 + 2 * extra, s.height - 28 + 2 * extra);
    final top = Radius.circular(rect.width / 2);
    final abajo = Radius.circular(arco ? 44 + extra : rect.width / 2);
    return Path()..addRRect(RRect.fromRectAndCorners(rect, topLeft: top, topRight: top, bottomLeft: abajo, bottomRight: abajo));
  }

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 + silaba * 6
      ..strokeCap = StrokeCap.round
      ..color = color;
    switch (estado) {
      case EstadoPantera.analizando:
        canvas.drawPath(_forma(s, 0), Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = color.withValues(alpha: 0.2));
        final m = _forma(s, 0).computeMetrics().first;
        final ini = giro * m.length;
        canvas.drawPath(m.extractPath(ini, ini + m.length * 0.22), p..strokeWidth = 6);
        if (ini + m.length * 0.22 > m.length) canvas.drawPath(m.extractPath(0, ini + m.length * 0.22 - m.length), p);
      case EstadoPantera.escuchando:
        canvas.drawPath(_forma(s, 0), p);
        for (var k = 0; k < 2; k++) {
          final f = (giro + k * 0.5) % 1;
          canvas.drawPath(_forma(s, f * 12), Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = color.withValues(alpha: (1 - f) * 0.6));
        }
      default:
        canvas.drawPath(_forma(s, resp * 2), p);
        if (silaba > 0 && !arco) {
          for (var k = 0; k < 3; k++) {
            final f = (giro * 1.5 + k / 3) % 1;
            canvas.drawPath(_forma(s, 6 + f * 18),
                Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..color = color.withValues(alpha: (1 - f) * 0.55));
          }
        }
    }
  }

  @override
  bool shouldRepaint(_Aura o) => true;
}
