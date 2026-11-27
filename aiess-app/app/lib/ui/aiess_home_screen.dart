// Pantalla principal AIESS, pensada para personas mayores y con discapacidad.
// Heurísticas aplicadas:
// - Una sola acción principal por momento; lo demás aparece solo cuando hace falta (menos saturación).
// - Todo botón lleva ícono + TEXTO (nada de íconos sueltos que haya que adivinar).
// - Botones de 64–104 dp, separados ≥ 12 dp (temblor, poca precisión al tocar).
// - Texto ≥ 17 sp; respeta el tamaño de letra del sistema (la pantalla se desplaza si no cabe).
// - Estado visible: el robot, el color de la tarjeta y un texto dicen lo que pasa; lo que se dice también se escribe.
// - Lector de pantalla: cada cambio importante se anuncia (liveRegion) y cada botón tiene nombre.
// - Si el sistema pide "quitar animaciones", se quitan.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../features/mascota/robot_guardia.dart';
import 'package:capacitacion/src/presentation/widgets/marca_iess.dart';

import 'package:theme_light/theme_light.dart';
import 'globo_deepfake.dart';
import 'tema.dart';
import 'partes_correo.dart';
import '../features/analisis/motor.dart' show nombreIndicio;
import 'texto_vivo.dart';
import 'tutorial_copiar.dart';

/// Estado visual de la pantalla.
/// duda = sin indicios pero sin sello válido del IESS: no es estafa (catálogo), pero no se confirma.
enum EstadoHoja { listo, analizando, estafa, seguro, duda }

class AiessHomeScreen extends StatelessWidget {
  const AiessHomeScreen({
    super.key,
    required this.onPasteAndCheck,
    required this.onVoiceInput,
    required this.onPickImage,
    required this.onOpenSettings,
    this.hasClipboardContent = true,
    this.estado = EstadoHoja.listo,
    this.estadoMascota = EstadoRobot.reposo,
    this.titulo = 'Hola, soy Leo',
    this.texto,
    this.pasos = const [],
    this.progreso,
    this.escuchando = false,
    this.onTapMascota,
    this.onReport,
    this.onDone,
    this.onReanalizar,
    this.onRevisarIA,
    this.iaLocal = false,
    this.indicios = const [],
    this.avisoSello,
    this.textoCorreo,
    this.queSalio,
    this.onAula,
    this.onPracticar,
    this.resumen,
  });

  final VoidCallback onPasteAndCheck, onVoiceInput, onPickImage, onOpenSettings;
  final bool hasClipboardContent;
  final EstadoHoja estado;
  final EstadoRobot estadoMascota;
  final String titulo;

  /// Lo que dice el robot (se escribe en vivo). Null = indicación de inicio.
  final String? texto;
  final List<String> pasos;
  final double? progreso;
  final bool escuchando;

  /// ¿La IA corre en este equipo? (cambia el texto del botón «Revisar con la IA»).
  final bool iaLocal;

  /// Indicios del catálogo encontrados (se listan TODOS: la cantidad coincide con el resumen y el avatar).
  final List<String> indicios;

  /// Aviso aparte sobre el sello del IESS.
  final String? avisoSello;

  /// Texto del correo revisado (para mostrar sus partes sin abrir nada).
  final String? textoCorreo;

  /// «Lo que salió del equipo: …» (rúbrica: seguridad y datos).
  final String? queSalio;

  /// «Phishing: SÍ · 3 indicios» (veredicto claro).
  final String? resumen;
  final VoidCallback? onTapMascota,
      onReport,
      onDone,
      onReanalizar,
      onRevisarIA,
      onAula,
      onPracticar;

  String get _indicacion => escuchando
      ? 'Te escucho. Lee el correo en voz alta. Al terminar toca «Parar» o quédate callado y lo reviso.'
      : hasClipboardContent
      ? 'Ya copiaste algo. Toca el botón azul y te digo si es seguro.'
      : 'Copia el correo que te parezca raro y toca el botón azul.';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sinAnimar = mq.disableAnimations;
    final dur = sinAnimar ? Duration.zero : const Duration(milliseconds: 280);
    final medallon = (mq.size.width * 0.42).clamp(120.0, mq.size.height * 0.2);

    return Scaffold(
      appBar: AppBar(
        // Marca compartida: logo oficial del IESS + AIESS. La barra limita la letra a 1.3x para no partirse.
        title: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          // Si no cabe (pantalla angosta o letra grande), se achica en vez de cortarse.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LogoIess(alto: 26),
                Container(
                  width: 1.5,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.white54,
                ),
                const Text('AIESS'),
              ],
            ),
          ),
        ),
        actions: [
          // Ajustes con texto: los mayores no reconocen el engranaje solo.
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(48, 48),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onOpenSettings();
                },
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Ajustes'),
              ),
            ),
          ),
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
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'Revisar',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            label: 'Aprender',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            label: 'Practicar',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, caja) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: caja.maxHeight - 28),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Semantics(
                      button: true,
                      label: 'Leo. Toca para escucharlo otra vez',
                      excludeSemantics: true,
                      onTap: onTapMascota,
                      child: RobotGuardia(
                        estado: estadoMascota,
                        tam: medallon,
                        alTocar: onTapMascota,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Globo(
                    estado: estado,
                    titulo: titulo,
                    texto: texto,
                    indicacion: _indicacion,
                    pasos: pasos,
                    progreso: progreso,
                    dur: dur,
                    resumen: resumen,
                    indicios: indicios,
                    avisoSello: avisoSello,
                    textoCorreo: textoCorreo,
                    queSalio: queSalio,
                  ),
                  // Si quiere aprender más: sugerencias sobre deepfakes que dice el robot.
                  if (estado == EstadoHoja.listo) ...[
                    const SizedBox(height: 12),
                    const GloboDeepfake(),
                  ],
                  const Spacer(),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: dur,
                    child: KeyedSubtree(
                      key: ValueKey(estado),
                      child: _acciones(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _Privacidad(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _acciones(BuildContext context) {
    switch (estado) {
      case EstadoHoja.analizando:
        // Escuchando: un botón grande para PARAR (callarse 4 s también termina y revisa).
        if (escuchando) {
          return _BotonPrincipal(
            texto: 'Parar y revisar',
            icono: Icons.stop_circle_rounded,
            onTap: onVoiceInput,
          );
        }
        // Mientras revisa no hay nada más que tocar: un solo botón que explica qué pasa.
        return _BotonPrincipal(
          texto: 'Revisando…',
          icono: Icons.hourglass_top_rounded,
          onTap: null,
          cargando: true,
        );
      case EstadoHoja.estafa:
      case EstadoHoja.seguro:
      case EstadoHoja.duda:
        final estafa = estado == EstadoHoja.estafa;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BotonPrincipal(
              texto: estafa ? 'Avisar al IESS' : 'Listo, entendido',
              icono: estafa ? Icons.campaign_rounded : Icons.check_rounded,
              fondo: estafa ? Tono.rojo : Tono.verde,
              onTap: estafa ? (onReport ?? () {}) : (onDone ?? () {}),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _BotonTarjeta(
                      texto: 'Escuchar otra vez',
                      icono: Icons.volume_up_rounded,
                      onTap: onTapMascota,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Vuelve al inicio para revisar un correo NUEVO, sin cerrar la app (control y libertad).
                  Expanded(
                    child: _BotonTarjeta(
                      texto: 'Revisar otro correo',
                      icono: Icons.forward_to_inbox_rounded,
                      onTap: onDone,
                    ),
                  ),
                ],
              ),
            ),
            if (onRevisarIA != null) ...[
              const SizedBox(height: 12),
              // La IA solo lee el correo si la persona toca aquí (sirve para detectar un sello verdadero
              // pegado a un texto cambiado). El botón dice dónde corre y que todo se borra.
              BotonRevisarIA(local: iaLocal, onTap: onRevisarIA!),
            ],
          ],
        );
      case EstadoHoja.listo:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BotonPrincipal(
              texto: 'Pegar y revisar',
              icono: Icons.content_paste_search_rounded,
              onTap: onPasteAndCheck,
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En la web no hay lector de imágenes: no se muestra un botón que no funciona.
                  Expanded(
                    child: _BotonTarjeta(
                      // En la web se sube un PDF o una foto (OCR en el navegador).
                      texto: kIsWeb ? 'Subir correo' : 'Escanear o subir',
                      ayuda: kIsWeb ? '.eml, PDF o foto' : 'Foto, .eml o PDF',
                      icono: kIsWeb
                          ? Icons.upload_file_rounded
                          : Icons.document_scanner_rounded,
                      onTap: onPickImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BotonTarjeta(
                      // Mientras escucha, el mismo botón sirve para PARAR (si la persona se calla
                      // 4 segundos también termina solo y se revisa).
                      texto: escuchando ? 'Parar' : 'Hablar',
                      ayuda: escuchando
                          ? 'Toca al terminar'
                          : 'Dicta el correo',
                      icono: escuchando
                          ? Icons.stop_circle_rounded
                          : Icons.mic_rounded,
                      activo: escuchando,
                      onTap: onVoiceInput,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Tutorial corto: cómo copiar el contenido de un correo para pegarlo.
            TextButton.icon(
              key: const ValueKey('boton-tutorial-copiar'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => mostrarTutorialCopiar(context),
              icon: const Icon(Icons.help_outline_rounded),
              label: const Text('¿Cómo copio un correo?'),
            ),
          ],
        );
    }
  }
}

// ---------------------------------------------------------------- piezas

/// Lo que dice el robot: título + texto (o los pasos de carga). Se anuncia al lector de pantalla.
class _Globo extends StatelessWidget {
  const _Globo({
    required this.estado,
    required this.titulo,
    required this.texto,
    required this.indicacion,
    required this.pasos,
    required this.progreso,
    required this.dur,
    this.resumen,
    this.indicios = const [],
    this.avisoSello,
    this.textoCorreo,
    this.queSalio,
  });
  final String? resumen;
  final String? textoCorreo;
  final String? queSalio;
  final List<String> indicios;
  final String? avisoSello;
  final EstadoHoja estado;
  final String titulo, indicacion;
  final String? texto;
  final List<String> pasos;
  final double? progreso;
  final Duration dur;

  @override
  Widget build(BuildContext context) {
    // El color nunca va solo: siempre lo acompañan un ícono y una palabra.
    final (fondo, borde, icono, etiqueta) = switch (estado) {
      EstadoHoja.estafa => (
        Tono.rojoSuave,
        Tono.rojo,
        Icons.gpp_bad_rounded,
        resumen ?? 'Posible estafa',
      ),
      EstadoHoja.seguro => (
        Tono.verdeSuave,
        Tono.verde,
        Icons.verified_user_rounded,
        resumen ?? 'Parece seguro',
      ),
      EstadoHoja.duda => (
        ThemeLightTokens.warnBackground,
        ThemeLightTokens.warnForeground,
        Icons.gpp_maybe_rounded,
        resumen ?? 'Sin sello del IESS',
      ),
      _ => (Tono.superficie, Tono.linea, null, null),
    };
    final alto = MediaQuery.sizeOf(context).height;
    return Semantics(
      liveRegion: true,
      child: AnimatedContainer(
        duration: dur,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borde,
            width: estado == EstadoHoja.listo || estado == EstadoHoja.analizando
                ? 1
                : 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (etiqueta != null) ...[
              Row(
                children: [
                  Icon(icono, color: borde, size: 26),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      etiqueta,
                      style: Letra.lexend(
                        18,
                        peso: FontWeight.w700,
                        color: borde,
                        espacio: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            AnimatedSwitcher(
              duration: dur,
              layoutBuilder: (a, p) =>
                  Stack(alignment: Alignment.topLeft, children: [...p, ?a]),
              child: Text(
                titulo,
                key: ValueKey(titulo),
                style: Letra.lexend(
                  26,
                  peso: FontWeight.w700,
                  color: Tono.tinta,
                  alto: 1.15,
                  espacio: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: alto * 0.26),
              child: AnimatedSwitcher(
                duration: dur,
                layoutBuilder: (a, p) =>
                    Stack(alignment: Alignment.topLeft, children: [...p, ?a]),
                child: pasos.isNotEmpty
                    ? SingleChildScrollView(
                        key: const ValueKey('pasos'),
                        reverse:
                            true, // con letra grande se ve siempre el paso actual
                        child: PasosCarga(pasos: pasos, progreso: progreso),
                      )
                    : SingleChildScrollView(
                        key: ValueKey(texto ?? indicacion),
                        child: texto == null
                            ? Text(
                                indicacion,
                                style: Letra.lectura(19, color: Tono.gris),
                              )
                            : TextoVivo(
                                texto!,
                                estilo: Letra.lectura(19, color: Tono.tinta),
                              ),
                      ),
              ),
            ),
            if (indicios.isNotEmpty && pasos.isEmpty) ...[
              const SizedBox(height: 12),
              Semantics(
                header: true,
                child: Text(
                  'Indicios encontrados (${indicios.length})',
                  style: Letra.lexend(
                    16,
                    peso: FontWeight.w700,
                    color: borde,
                    espacio: 0,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              for (final k in indicios)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$k · ',
                          style: TextStyle(
                            color: borde,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: nombreIndicio[k] ?? k),
                      ],
                    ),
                    style: Letra.lectura(17, color: Tono.tinta),
                  ),
                ),
            ],
            if (textoCorreo != null && pasos.isEmpty)
              PanelPartesCorreo(texto: textoCorreo!),
            if (queSalio != null && pasos.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: Tono.gris,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        queSalio!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Tono.gris,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (avisoSello != null && pasos.isEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 22,
                    color: ThemeLightTokens.warnForeground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      avisoSello!,
                      style: Letra.lectura(
                        16,
                        color: ThemeLightTokens.warnForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Privacidad extends StatelessWidget {
  const _Privacidad();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.lock_outline_rounded, size: 18, color: Tono.gris),
      SizedBox(width: 6),
      Flexible(
        child: Text(
          'Quitamos tus datos personales y luego se borra todo. Nunca te pediremos claves.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Tono.gris, fontSize: 15, height: 1.35),
        ),
      ),
    ],
  );
}

/// Botón principal: ancho completo, mínimo 72 dp, ícono + texto. Vibra y se hunde al tocarlo.
class _BotonPrincipal extends StatelessWidget {
  const _BotonPrincipal({
    required this.texto,
    required this.icono,
    required this.onTap,
    this.fondo = Tono.lima,
    this.cargando = false,
  });
  final String texto;
  final IconData icono;
  final VoidCallback? onTap;
  final Color fondo;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final activo = onTap != null;
    return Semantics(
      button: true,
      enabled: activo,
      label: texto,
      excludeSemantics: true,
      child: _Presion(
        escala: 0.97,
        onTap: activo
            ? () {
                HapticFeedback.mediumImpact();
                onTap!();
              }
            : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: activo || cargando ? fondo : fondo.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Radios.pildora),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (cargando)
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Tono.sobreLima,
                  ),
                )
              else
                Icon(icono, size: 30, color: Tono.sobreLima),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  texto,
                  textAlign: TextAlign.center,
                  style: Letra.lexend(
                    21,
                    color: Tono.sobreLima,
                    alto: 1.15,
                    espacio: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón secundario tipo tarjeta: ícono grande arriba, nombre y una ayuda corta debajo.
/// Pensado para baja visión (ícono 36 + texto) y temblor (≥ 104 dp de alto).
class _BotonTarjeta extends StatelessWidget {
  const _BotonTarjeta({
    required this.texto,
    required this.icono,
    required this.onTap,
    this.ayuda,
    this.activo = false,
  });
  final String texto;
  final String? ayuda;
  final IconData icono;
  final VoidCallback? onTap;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final tinta = activo ? Tono.sobreLima : Tono.tinta;
    final colorIcono = activo ? Tono.sobreLima : Tono.lima;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: ayuda == null ? texto : '$texto. $ayuda',
      excludeSemantics: true,
      child: _Presion(
        escala: 0.95,
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: AnimatedContainer(
          duration: MediaQuery.of(context).disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 220),
          constraints: BoxConstraints(minHeight: ayuda == null ? 88 : 104),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: activo ? Tono.lima : Tono.superficie,
            borderRadius: BorderRadius.circular(Radios.xl),
            border: Border.all(
              color: activo ? Tono.lima : Tono.borde,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Pulso(
                activo: activo,
                child: Icon(icono, size: 36, color: colorIcono),
              ),
              const SizedBox(height: 6),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: Letra.lexend(19, color: tinta, alto: 1.15, espacio: 0),
              ),
              if (ayuda != null)
                Text(
                  ayuda!,
                  textAlign: TextAlign.center,
                  style: Letra.lectura(
                    15,
                    color: activo ? Tono.sobreLima : Tono.gris,
                    alto: 1.3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Late suave mientras el micrófono escucha (señal visible para quien no oye el aviso sonoro).
class _Pulso extends StatefulWidget {
  const _Pulso({required this.activo, required this.child});
  final bool activo;
  final Widget child;

  @override
  State<_Pulso> createState() => _PulsoState();
}

class _PulsoState extends State<_Pulso> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(_Pulso old) {
    super.didUpdateWidget(old);
    _sincronizar();
  }

  @override
  void initState() {
    super.initState();
    _sincronizar();
  }

  void _sincronizar() {
    if (widget.activo) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return ScaleTransition(
      scale: Tween(
        begin: 1.0,
        end: 1.18,
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// Escala al presionar (100 ms).
class _Presion extends StatefulWidget {
  const _Presion({
    required this.child,
    required this.onTap,
    required this.escala,
  });
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
    onTapDown: widget.onTap == null
        ? null
        : (_) => setState(() => _abajo = true),
    onTapCancel: () => setState(() => _abajo = false),
    onTapUp: widget.onTap == null
        ? null
        : (_) {
            setState(() => _abajo = false);
            widget.onTap!();
          },
    child: AnimatedScale(
      scale: _abajo && !MediaQuery.of(context).disableAnimations
          ? widget.escala
          : 1,
      duration: const Duration(milliseconds: 100),
      child: widget.child,
    ),
  );
}

/// «Revisar con la IA local» + «Nunca se guarda y la conversación se borra». Tocarlo es el permiso.
class BotonRevisarIA extends StatelessWidget {
  const BotonRevisarIA({super.key, required this.local, required this.onTap});
  final bool local;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titulo = local
        ? 'Revisar con la IA local'
        : 'Revisar con la IA de AIESS';
    const nota = 'Nunca se guarda y la conversación se borra.';
    return Semantics(
      button: true,
      label: '$titulo. $nota',
      excludeSemantics: true,
      child: Material(
        color: Tono.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Tono.borde, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology_rounded,
                    size: 30,
                    color: Tono.tinta,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Tono.tinta,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: Tono.gris,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                nota,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Tono.gris,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
