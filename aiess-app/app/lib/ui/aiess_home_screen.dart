// Pantalla principal AIESS con el mismo estilo del aula virtual: AppBar azul IESS, fondo claro,
// tarjeta blanca y barra de navegación inferior (Revisar · Aula virtual · Practicar).
// El cóndor es un medallón cuyo anillo muestra el estado; la tarjeta se tiñe de rojo o verde con el veredicto.
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../features/mascota/pantera.dart';
import 'tema.dart';
import 'texto_vivo.dart';

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
    this.onAula,
    this.onPracticar,
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
  final VoidCallback? onTapMascota, onReport, onDone, onReanalizar, onAula, onPracticar;

  String get _indicacion => hasClipboardContent
      ? 'Tienes un texto copiado. Toca «Pegar y revisar» y te digo si es seguro.'
      : 'Copia el correo o enlace que te parezca raro y toca «Pegar y revisar». También puedes hablarme.';

  (Color, Color, IconData, String) get _tarjeta => switch (estado) {
        EstadoHoja.estafa => (Tono.rojoSuave, Tono.rojo, Icons.gpp_bad_rounded, 'Posible estafa'),
        EstadoHoja.seguro => (Tono.verdeSuave, Tono.verde, Icons.verified_user_rounded, 'Parece seguro'),
        EstadoHoja.analizando => (Colors.white, Tono.azul, Icons.manage_search_rounded, 'Revisando'),
        EstadoHoja.listo => (Colors.white, Colors.white, Icons.shield_rounded, 'Listo para revisar'),
      };

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final alto = mq.size.height;
    final medallon = (mq.size.width * 0.5).clamp(140.0, alto * 0.24);
    final (fondo, borde, icono, etiqueta) = _tarjeta;
    final colorEtiqueta = estado == EstadoHoja.listo ? Tono.azul : borde;

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.shield_rounded, color: Tono.amarillo),
          SizedBox(width: 8),
          Text('AIESS'),
        ]),
        actions: [
          IconButton(
            tooltip: 'Revisar una captura',
            icon: const Icon(Icons.add_photo_alternate_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              onPickImage();
            },
          ),
          IconButton(
            tooltip: 'Ajustes y ayuda',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              onOpenSettings();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          if (i == 1) onAula?.call();
          if (i == 2) onPracticar?.call();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield_rounded), label: 'Revisar'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Aula virtual'),
          NavigationDestination(icon: Icon(Icons.sports_esports_outlined), label: 'Practicar'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          children: [
            const Spacer(),
            Pantera(estado: estadoMascota, tam: medallon, encuadre: Encuadre.medallon, alTocar: onTapMascota),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borde, width: 1.5),
                boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(icono, color: colorEtiqueta, size: 22),
                  const SizedBox(width: 6),
                  Text(etiqueta, style: TextStyle(color: colorEtiqueta, fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  layoutBuilder: (a, p) => Stack(alignment: Alignment.topLeft, children: [...p, if (a != null) a]),
                  child: Text(titulo,
                      key: ValueKey(titulo),
                      maxLines: 2,
                      style: const TextStyle(color: Tono.tinta, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6, height: 1.15)),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: alto * 0.2),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    layoutBuilder: (a, p) => Stack(alignment: Alignment.topLeft, children: [...p, if (a != null) a]),
                    child: pasos.isNotEmpty
                        ? Align(key: const ValueKey('pasos'), alignment: Alignment.topLeft, child: PasosCarga(pasos: pasos, progreso: progreso))
                        : SingleChildScrollView(
                            key: ValueKey(texto ?? _indicacion),
                            child: texto == null
                                ? Text(_indicacion, style: const TextStyle(color: Tono.gris, fontSize: 17, height: 1.45))
                                : TextoVivo(texto!, estilo: const TextStyle(color: Tono.tinta, fontSize: 17, height: 1.45)),
                          ),
                  ),
                ),
              ]),
            ),
            const Spacer(),
            _acciones(),
            const SizedBox(height: 10),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.lock_outline_rounded, size: 16, color: Tono.gris),
              SizedBox(width: 6),
              Flexible(
                child: Text('Tu correo se analiza y se elimina. Nunca te pediremos claves.',
                    textAlign: TextAlign.center, style: TextStyle(color: Tono.gris, fontSize: 13)),
              ),
            ]),
          ],
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
            style: TextButton.styleFrom(foregroundColor: Tono.azul, minimumSize: const Size(0, 48)),
            icon: const Icon(Icons.refresh_rounded, size: 22),
            label: const Text('Analizar de nuevo', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
      ]);

  Widget _acciones() {
    final ocupado = estado == EstadoHoja.analizando;
    switch (estado) {
      case EstadoHoja.estafa:
        return _conReanalizar(
            _PrimaryActionButton(texto: 'Avisar al IESS', icono: Icons.campaign_rounded, onTap: onReport ?? () {}, fondo: Tono.rojo));
      case EstadoHoja.seguro:
        return _conReanalizar(_PrimaryActionButton(texto: 'Listo', icono: Icons.check_rounded, onTap: onDone ?? () {}, fondo: Tono.verde));
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

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.texto, required this.icono, required this.onTap, this.fondo = Tono.azul});
  final String texto;
  final IconData icono;
  final VoidCallback? onTap;
  final Color fondo;

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 64,
            decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icono, size: 28, color: Colors.white),
              const SizedBox(width: 10),
              Flexible(
                child: Text(texto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
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
              decoration: BoxDecoration(color: activo ? Tono.azul : Tono.amarillo, borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.mic_rounded, size: 30, color: activo ? Colors.white : Tono.tinta),
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
