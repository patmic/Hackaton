// Pantalla principal AIESS: el cóndor como medallón oficial. Su anillo exterior ES el estado
// (amarillo listo, rojo estafa, verde seguro) y de él salen ondas cuando habla.
// Sin tarjetas: el texto va directo sobre el azul noche del emblema. Un botón principal + micrófono.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/mascota/pantera.dart';
import 'texto_vivo.dart';

class _C {
  static const nocheArriba = Color(0xFF0A1B3A); // mismo azul del fondo del emblema
  static const iessAbajo = Color(0xFF00337F); // baja hacia el azul IESS
  static const amarillo = Color(0xFFFCC602); // amarillo IESS
  static const tinta = Color(0xFF0A1B3A);
  static const voz = Color(0xFF0B3F8C);
  static const rojoArriba = Color(0xFF3A0B0E);
  static const rojoAbajo = Color(0xFF8E1B15);
  static const verdeArriba = Color(0xFF062B1A);
  static const verdeAbajo = Color(0xFF136B2C);
}

/// Estado visual de la pantalla.
enum EstadoHoja { listo, analizando, estafa, seguro }

class AiessHomeScreen extends StatelessWidget {
  const AiessHomeScreen({
    super.key,
    required this.onPasteAndCheck,
    required this.onVoiceInput,
    required this.onPickImage,
    required this.onOpenSettings,
    this.hasClipboardContent = true,
    this.estado = EstadoHoja.listo,
    this.estadoMascota = EstadoPantera.reposo,
    this.titulo = 'Hola, soy AIess',
    this.texto,
    this.pasos = const [],
    this.progreso,
    this.escuchando = false,
    this.onTapMascota,
    this.onReport,
    this.onDone,
    this.onReanalizar,
  });

  final VoidCallback onPasteAndCheck, onVoiceInput, onPickImage, onOpenSettings;
  final bool hasClipboardContent;
  final EstadoHoja estado;
  final EstadoPantera estadoMascota;
  final String titulo;
  /// Lo que dice el cóndor (se escribe en vivo). Null = indicación de inicio.
  final String? texto;
  final List<String> pasos;
  final double? progreso;
  final bool escuchando;
  final VoidCallback? onTapMascota, onReport, onDone, onReanalizar;

  (Color, Color) get _fondo => switch (estado) {
        EstadoHoja.estafa => (_C.rojoArriba, _C.rojoAbajo),
        EstadoHoja.seguro => (_C.verdeArriba, _C.verdeAbajo),
        _ => (_C.nocheArriba, _C.iessAbajo),
      };

  String get _indicacion => hasClipboardContent
      ? 'Tienes un texto copiado. Toca el botón amarillo y te digo si es seguro.'
      : 'Copia el correo o enlace que te parezca raro y toca el botón amarillo. También puedes hablarme.';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final ancho = mq.size.width;
    final alto = mq.size.height;
    // Medallón: ~64 % del ancho, sin pasar del 34 % del alto (pantallas bajas).
    final medallon = (ancho * 0.64).clamp(180.0, alto * 0.34);
    final (arriba, abajo) = _fondo;
    final listo = estado == EstadoHoja.listo;

    return Scaffold(
      body: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: arriba),
        duration: const Duration(milliseconds: 500),
        builder: (_, cA, __) => TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: abajo),
          duration: const Duration(milliseconds: 500),
          builder: (_, cB, child) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [cA ?? arriba, cB ?? abajo]),
            ),
            child: child,
          ),
          child: Padding(
            // Zonas seguras: barra de estado (+16) y barra de navegación (+20).
            padding: EdgeInsets.fromLTRB(24, mq.padding.top + 16, 24, mq.padding.bottom + 20),
            child: Column(
              children: [
                Row(children: [
                  _TopGlassButton(icon: Icons.add_photo_alternate_rounded, tooltip: 'Revisar una captura', onTap: onPickImage),
                  const Spacer(),
                  _TopGlassButton(icon: Icons.tune_rounded, tooltip: 'Ajustes y ayuda', onTap: onOpenSettings),
                ]),
                const Spacer(flex: 2),
                // Medallón con su aura de estado (+40 de margen para las ondas).
                Pantera(estado: estadoMascota, tam: medallon, encuadre: Encuadre.medallon, alTocar: onTapMascota),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: Text(
                    titulo,
                    key: ValueKey(titulo),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  // El texto va pegado al título; si es largo, se desplaza dentro de este alto.
                  constraints: BoxConstraints(maxHeight: alto * 0.2),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    layoutBuilder: (a, p) => Stack(alignment: Alignment.topCenter, children: [...p, if (a != null) a]),
                    child: pasos.isNotEmpty
                        ? Align(key: const ValueKey('pasos'), alignment: Alignment.topCenter, child: PasosCarga(pasos: pasos, progreso: progreso))
                        : SingleChildScrollView(
                            key: ValueKey(texto ?? _indicacion),
                            child: texto == null
                                ? Text(_indicacion,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.86), fontSize: 17, height: 1.45))
                                : TextoVivo(texto!,
                                    alineacion: TextAlign.center,
                                    estilo: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontSize: 17, height: 1.45)),
                          ),
                  ),
                ),
                const Spacer(flex: 3),
                _acciones(),
                const SizedBox(height: 12),
                AnimatedOpacity(
                  opacity: listo ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Text('Gratis y privado. Nunca te pediremos claves.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Botón principal + "Analizar de nuevo" (repite el análisis del mismo correo).
  Widget _conReanalizar(Widget principal) => Column(mainAxisSize: MainAxisSize.min, children: [
        principal,
        if (onReanalizar != null)
          TextButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              onReanalizar!();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white, minimumSize: const Size(0, 48)),
            icon: const Icon(Icons.refresh_rounded, size: 22),
            label: const Text('Analizar de nuevo', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
      ]);

  Widget _acciones() {
    final ocupado = estado == EstadoHoja.analizando;
    switch (estado) {
      case EstadoHoja.estafa:
        return _conReanalizar(_PrimaryActionButton(
            texto: 'Avisar al IESS', icono: Icons.campaign_rounded, onTap: onReport ?? () {}, claro: true, tinta: _C.rojoAbajo));
      case EstadoHoja.seguro:
        return _conReanalizar(
            _PrimaryActionButton(texto: 'Listo', icono: Icons.check_rounded, onTap: onDone ?? () {}, claro: true, tinta: _C.verdeAbajo));
      default:
        return Row(children: [
          Expanded(
            child: _PrimaryActionButton(
              texto: 'Pegar y revisar',
              icono: Icons.content_paste_search_rounded,
              onTap: ocupado ? null : onPasteAndCheck,
            ),
          ),
          const SizedBox(width: 12),
          _VoiceActionButton(onTap: ocupado ? null : onVoiceInput, activo: escuchando),
        ]);
    }
  }
}

// ---------------------------------------------------------------- piezas

class _TopGlassButton extends StatelessWidget {
  const _TopGlassButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Semantics(
          button: true,
          label: tooltip,
          child: _Presion(
            escala: 0.92,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
      );
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.texto, required this.icono, required this.onTap, this.claro = false, this.tinta = _C.tinta});
  final String texto;
  final IconData icono;
  final VoidCallback? onTap;
  final bool claro;
  final Color tinta;

  @override
  Widget build(BuildContext context) {
    final activo = onTap != null;
    return Semantics(
      button: true,
      label: texto,
      child: _Presion(
        escala: 0.97,
        onTap: activo
            ? () {
                HapticFeedback.mediumImpact();
                onTap!();
              }
            : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: activo ? 1 : 0.5,
          child: Container(
            height: 64,
            decoration: BoxDecoration(color: claro ? Colors.white : _C.amarillo, borderRadius: BorderRadius.circular(18)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icono, size: 28, color: tinta),
              const SizedBox(width: 10),
              Flexible(
                child: Text(texto,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: tinta, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _VoiceActionButton extends StatelessWidget {
  const _VoiceActionButton({required this.onTap, required this.activo});
  final VoidCallback? onTap;
  final bool activo;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Hablar con AIess',
        child: Semantics(
          button: true,
          label: 'Hablar con AIess',
          child: _Presion(
            escala: 0.94,
            onTap: onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: activo ? _C.amarillo : _C.voz,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _C.amarillo.withValues(alpha: 0.8), width: 2),
              ),
              child: Icon(Icons.mic_rounded, size: 30, color: activo ? _C.tinta : _C.amarillo),
            ),
          ),
        ),
      );
}

/// Escala al presionar (100 ms).
class _Presion extends StatefulWidget {
  const _Presion({required this.child, required this.onTap, required this.escala});
  final Widget child;
  final VoidCallback? onTap;
  final double escala;

  @override
  State<_Presion> createState() => _PresionState();
}

class _PresionState extends State<_Presion> {
  bool _abajo = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _abajo = true),
        onTapCancel: () => setState(() => _abajo = false),
        onTapUp: widget.onTap == null
            ? null
            : (_) {
                setState(() => _abajo = false);
                widget.onTap!();
              },
        child: AnimatedScale(scale: _abajo ? widget.escala : 1, duration: const Duration(milliseconds: 100), child: widget.child),
      );
}
