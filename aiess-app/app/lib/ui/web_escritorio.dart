// Versión web para computadora: dos columnas. Izquierda, el robot y cómo funciona; derecha, el espacio de
// trabajo para pegar el correo y ver el veredicto (escrito y hablado). La IA corre en el servidor de AIESS.
import 'dart:ui' show FontVariation;
import 'package:material_ui/material_ui.dart';
import 'package:theme_light/theme_light.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/canales.dart';
import '../features/analisis/analizador.dart';
import '../features/analisis/motor.dart';
import '../features/llm/remoto.dart';
import '../features/mascota/robot_guardia.dart';
import '../features/voz/voz.dart';
import 'aula_virtual.dart';
import 'consentimiento.dart';
import '../features/correo/eml.dart';
import '../features/ocr/documento.dart';
import 'package:file_picker/file_picker.dart';
import '../features/sello/sello.dart';
import 'practicar_page.dart';
import 'package:capacitacion/src/presentation/widgets/marca_iess.dart';
import 'tema.dart';
import 'texto_vivo.dart';

/// Colores de escritorio mapeados a los tokens compartidos de ThemeLight.
class _W {
  static const azul = ThemeLightTokens.theme;
  static const sobreAzul = ThemeLightTokens.background;
  static const panel = ThemeLightTokens.nav;
  static const azulOscuro = ThemeLightTokens.primaryContainer;
  static const amarillo = ThemeLightTokens.theme;
  static const papel = ThemeLightTokens.page;
  static const tinta = Tono.tinta;
  static const gris = Tono.gris;
  static const rojo = Tono.rojo;
  static const verde = Tono.verde;
}

class WebEscritorio extends StatefulWidget {
  const WebEscritorio({super.key});

  /// ¿Caben las dos columnas? Se mide el ancho EFECTIVO (ancho ÷ tamaño de letra):
  /// con zoom o letra grande en una pantalla angosta se pasa al diseño de una columna (reflujo, WCAG 1.4.10).
  static bool cabe(BuildContext context, double ancho) =>
      ancho / MediaQuery.textScalerOf(context).scale(1) >= 860;

  @override
  State<WebEscritorio> createState() => _WebEscritorioState();
}

class _WebEscritorioState extends State<WebEscritorio> {
  final _texto = TextEditingController();
  var _estado = EstadoRobot.reposo;
  Veredicto? _v;
  String? _aviso;
  List<String> _pasos = [];
  double? _progreso;
  bool _escuchando = false;

  bool get _ocupado => _estado == EstadoRobot.analizando || _escuchando;

  Future<void> _revisar() async {
    final t = _texto.text.trim();
    // 1) Si trae el sello del IESS, se verifica la firma sin leer el correo.
    if (Sello.codigoEn(t) != null) {
      setState(() {
        _estado = EstadoRobot.analizando;
        _aviso = null;
        _v = null;
        _pasos = ['Comprobando la firma del IESS'];
        _progreso = null;
      });
      final r = await Sello.verificar(t);
      if (!mounted) return;
      if (r.sinRespuesta) {
        setState(() {
          _estado = EstadoRobot.reposo;
          _pasos = [];
          _aviso = r.mensaje;
        });
        Voz.i.decir(r.mensaje);
        return;
      }
      final d = r.datos;
      final texto = r.valido
          ? 'Firma válida del IESS. ${d['emisor'] ?? ''}${d['asunto'] != null ? '. Asunto: «${d['asunto']}»' : ''}. '
                'Revisa que el asunto coincida con el correo.'
          : r.mensaje;
      setState(() {
        _v = Veredicto(
          phishing: !r.valido,
          puntaje: r.valido ? 0 : 100,
          voz: texto,
          indicios: const [],
          explicacion: texto,
          queHacer: r.valido
              ? 'Puedes confiar en este correo. Si igual quieres, pega su texto y la IA lo revisa (con tu permiso).'
              : 'No abras sus enlaces ni entregues datos. Puedes avisar al IESS.',
          fuente: 'sello',
        );
        _estado = r.valido ? EstadoRobot.seguro : EstadoRobot.alerta;
        _pasos = [];
      });
      Voz.i.decir(texto);
      return;
    }
    if (t.length < 8) {
      setState(
        () => _aviso =
            'Pega primero el texto del correo o el enlace que te parezca raro.',
      );
      Voz.i.decir(_aviso!);
      return;
    }
    final motivo = motivoNoEsMensaje(t);
    if (motivo != null && !(urlRe.hasMatch(t) && t.length < 300)) {
      setState(() {
        _aviso = '$motivo Pega el texto del correo o el enlace sospechoso.';
        _v = null;
      });
      Voz.i.decir(_aviso!);
      return;
    }
    // 2) Sin sello: la IA solo lee el correo si la persona lo acepta.
    if (!await pedirConsentimientoIA(context)) {
      setState(
        () => _aviso =
            'No lo leí. Si el correo trae la imagen del sello del IESS, pega su enlace y verifico la firma sin leer el correo.',
      );
      return;
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = EstadoRobot.analizando;
      _aviso = null;
      _v = null;
      _pasos = [];
      _progreso = null;
    });
    final v = await Analizador.analizar(
      Entrada(t, canal: 'correo pegado en la web'),
      alAvanzar: (paso, p) {
        if (!mounted) return;
        setState(() {
          if (_pasos.isEmpty || _pasos.last != paso) _pasos = [..._pasos, paso];
          _progreso = p;
        });
      },
    );
    if (!mounted) return;
    setState(() {
      _v = v;
      _estado = v.phishing ? EstadoRobot.alerta : EstadoRobot.seguro;
      _pasos = [];
    });
    Voz.i.decir(v.voz);
  }

  void _hablarRobot() => _v == null
      ? Voz.i.decir('Pega un correo y te digo si es una estafa.')
      : Voz.i.decir('${_v!.explicacion} ${_v!.queHacer}');

  Future<void> _hablar() async {
    setState(() => _escuchando = true);
    // Lo dictado se va escribiendo en el campo mientras la persona habla.
    void verParcial() {
      if (mounted && Voz.i.parcial.value.isNotEmpty)
        _texto.text = Voz.i.parcial.value;
    }

    Voz.i.parcial.addListener(verParcial);
    final dicho = await Voz.i.escuchar();
    Voz.i.parcial.removeListener(verParcial);
    if (!mounted) return;
    setState(() => _escuchando = false);
    if (dicho != null) {
      // Lo dictado queda escrito en el campo para que la persona lo vea; luego se revisa (con su permiso).
      _texto.text = dicho;
      await _revisar();
    } else {
      final motivo =
          Voz.i.problemaEscucha ?? 'No te escuché bien. Vuelve a intentarlo.';
      setState(() => _aviso = motivo);
      Voz.i.decir(motivo);
    }
  }

  /// PDF o imagen: el OCR corre en el navegador (el archivo no sale del equipo). El texto leído queda
  /// en el campo para que la persona lo vea, y sigue el flujo normal (sello primero, IA con permiso).
  Future<void> _subir() async {
    final r = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['eml', 'pdf', 'png', 'jpg', 'jpeg', 'webp', 'bmp'],
    );
    if (r.isEmpty) return;
    final f = r.single;
    setState(() {
      _estado = EstadoRobot.analizando;
      _aviso = null;
      _v = null;
      _pasos = ['Leyendo «${f.name}» en tu navegador'];
      _progreso = null;
    });
    Voz.i.decir('Déjame leer el archivo.');
    var texto = '';
    try {
      final bytes = await f.readAsBytes();
      texto = f.name.toLowerCase().endsWith('.eml')
          ? leerEml(bytes).paraAnalizar
          : await LectorDocumento.leer(bytes, f.name);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _estado = EstadoRobot.reposo;
      _pasos = [];
    });
    if (texto.trim().length < 8) {
      const m =
          'No pude leer texto en ese archivo. Prueba con una captura más clara o copia el texto del correo.';
      setState(() => _aviso = m);
      Voz.i.decir(m);
      return;
    }
    _texto.text = texto;
    await _revisar();
  }

  Future<void> _reportar() async {
    final c = Canales.i.contacto;
    await launchUrl(
      Uri.parse(
        'mailto:${c['seguridad_informacion']}?subject=${Uri.encodeComponent('Reporte de posible phishing (AIESS)')}'
        '&body=${Uri.encodeComponent('Recibí este mensaje sospechoso:\n\n${_texto.text}\n\nSeñales: ${_v?.explicacion ?? ''}')}',
      ),
    );
  }

  void _limpiar() {
    Voz.i.callar();
    setState(() {
      _texto.clear();
      _v = null;
      _aviso = null;
      _estado = EstadoRobot.reposo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _W.papel,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------------- Izquierda: el robot y cómo funciona
          Expanded(
            flex: 5,
            child: ColoredBox(
              color: _W.panel,
              child: LayoutBuilder(
                builder: (context, caja) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(48, 36, 48, 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: caja.maxHeight - 68),
                    // Tres bloques repartidos: marca arriba, robot y mensaje al centro, privacidad abajo.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Marca: logo oficial del IESS + AIESS, y el estado del servidor.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const LogoIess(alto: 30),
                                Container(
                                  width: 1.5,
                                  height: 26,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  color: Colors.white54,
                                ),
                                Text(
                                  'AIESS',
                                  style: Letra.lexend(
                                    20,
                                    peso: FontWeight.w700,
                                    color: Colors.white,
                                    espacio: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _EstadoServidor(),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Semantics(
                                  button: true,
                                  label:
                                      'AIess, el robot. Toca para escucharlo',
                                  excludeSemantics: true,
                                  onTap: _hablarRobot,
                                  child: RobotGuardia(
                                    estado: _estado,
                                    tam: (caja.maxHeight * 0.3).clamp(
                                      140.0,
                                      260.0,
                                    ),
                                    alTocar: _hablarRobot,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text(
                                'Tu robot guardián contra estafas',
                                style: Letra.lexend(
                                  40,
                                  peso: FontWeight.w700,
                                  color: Colors.white,
                                  alto: 1.1,
                                  espacio: -0.8,
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Medida de lectura cómoda (~60 caracteres por línea).
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 560,
                                ),
                                child: Text(
                                  'Pega un correo raro y te digo, con voz y por escrito, si es una estafa.',
                                  style: Letra.lectura(
                                    20,
                                    color: Colors.white.withValues(alpha: 0.92),
                                    alto: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.white.withValues(alpha: 0.85),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Antes de revisarlo quitamos tu nombre, cédula, teléfono y cuentas. Luego se borra todo. Nunca te pediremos claves. '
                                  'Fuentes OSINT y CTI: reglas locales, RDAP (edad del dominio) y OpenPhish; solo se consulta el dominio o el enlace.',
                                  style: Letra.lectura(
                                    16,
                                    color: Colors.white.withValues(alpha: 0.88),
                                    alto: 1.45,
                                  ),
                                ),
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
          ),
          // ---------------- Derecha: espacio de trabajo
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(64, 56, 64, 48),
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Pega aquí el correo sospechoso',
                        style: TextStyle(
                          fontFamily: 'packages/theme_light/ThemeLightLexend',
                          fontVariations: const [FontVariation('wght', 700)],
                          color: _W.tinta,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Si trae la imagen del sello del IESS, pega su enlace: verifico la firma sin leer el correo.',
                        style: TextStyle(
                          color: _W.gris,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CallbackShortcuts(
                        bindings: {
                          const SingleActivator(
                            LogicalKeyboardKey.enter,
                            control: true,
                          ): () {
                            if (!_ocupado) _revisar();
                          },
                          const SingleActivator(
                            LogicalKeyboardKey.enter,
                            meta: true,
                          ): () {
                            if (!_ocupado) _revisar();
                          },
                        },
                        child: TextField(
                          autofocus: true,
                          controller: _texto,
                          minLines: 8,
                          maxLines: 14,
                          style: const TextStyle(
                            color: _W.tinta,
                            fontSize: 18,
                            height: 1.45,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Texto del correo',
                            alignLabelWithHint: true,
                            labelStyle: const TextStyle(fontSize: 18),
                            hintText:
                                'Ejemplo: "IESS: su afiliación será suspendida hoy. Actualice su clave en https://…"',
                            hintStyle: const TextStyle(color: _W.gris),
                            filled: true,
                            contentPadding: const EdgeInsets.all(20),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Tono.borde,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: _W.azul,
                                width: 3,
                              ),
                            ),
                            helperText:
                                'Atajo de teclado: Ctrl + Enter para revisar.',
                            helperStyle: const TextStyle(
                              color: _W.gris,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 280),
                            child: SizedBox(
                              height: 60,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _W.azul,
                                  foregroundColor: _W.sobreAzul,
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                    fontFamily:
                                        'packages/theme_light/ThemeLightLexend',
                                    fontVariations: [
                                      FontVariation('wght', 600),
                                    ],
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: _ocupado ? null : _revisar,
                                icon: _estado == EstadoRobot.analizando
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: _W.sobreAzul,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.manage_search_rounded,
                                        size: 26,
                                      ),
                                label: Text(
                                  _estado == EstadoRobot.analizando
                                      ? 'Revisando…'
                                      : 'Revisar con AIess',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _BotonTexto(
                            icono: _escuchando
                                ? Icons.graphic_eq_rounded
                                : Icons.mic_rounded,
                            texto: _escuchando ? 'Te escucho…' : 'Dictar',
                            activo: _escuchando,
                            onTap: _ocupado ? null : _hablar,
                          ),
                          const SizedBox(width: 12),
                          _BotonTexto(
                            icono: Icons.backspace_outlined,
                            texto: 'Borrar',
                            onTap: _limpiar,
                          ),
                          _BotonTexto(
                            icono: Icons.upload_file_rounded,
                            texto: 'Subir correo (.eml, PDF o imagen)',
                            onTap: _ocupado ? null : _subir,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _resultado(),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => abrirAulaVirtual(context),
                            icon: const Icon(Icons.school_rounded),
                            label: const Text('Aprender con microlecciones'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PracticarPage(),
                              ),
                            ),
                            icon: const Icon(Icons.sports_esports_rounded),
                            label: const Text('Practicar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultado() {
    if (_pasos.isNotEmpty) {
      return Container(
        key: const ValueKey('pasos'),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _W.azulOscuro,
          borderRadius: BorderRadius.circular(20),
        ),
        child: PasosCarga(
          pasos: _pasos,
          progreso: _progreso,
          color: Tono.tinta,
          acento: _W.amarillo,
        ),
      );
    }
    if (_aviso != null) {
      return Container(
        key: ValueKey(_aviso),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeLightTokens.warnBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: ThemeLightTokens.warnForeground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _aviso!,
                style: const TextStyle(
                  color: ThemeLightTokens.warnForeground,
                  fontSize: 17,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final v = _v;
    if (v == null) return const SizedBox(key: ValueKey('vacio'));
    final color = v.phishing ? _W.rojo : _W.verde;
    return Semantics(
      key: ValueKey(v),
      liveRegion: true,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Tono.superficie,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: color,
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
              child: Row(
                children: [
                  Icon(
                    v.phishing
                        ? Icons.gpp_bad_rounded
                        : Icons.verified_user_rounded,
                    color: _W.sobreAzul,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Text(
                      v.resumen,
                      style: const TextStyle(
                        fontFamily: 'packages/theme_light/ThemeLightLexend',
                        fontVariations: const [FontVariation('wght', 700)],
                        color: _W.sobreAzul,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextoVivo(
                    v.voz,
                    estilo: const TextStyle(
                      fontFamily: 'packages/theme_light/ThemeLightLexend',
                      fontVariations: const [FontVariation('wght', 600)],
                      color: _W.tinta,
                      fontSize: 20,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (v.phishing && v.indicios.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Señales que encontré',
                      style: TextStyle(
                        fontFamily: 'packages/theme_light/ThemeLightLexend',
                        fontVariations: const [FontVariation('wght', 700)],
                        color: _W.gris,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final k in v.indicios.take(3))
                      if (motivoVoz[k] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  motivoVoz[k]!,
                                  style: const TextStyle(
                                    color: _W.tinta,
                                    fontSize: 17,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    v.queHacer,
                    style: const TextStyle(
                      color: _W.gris,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (v.phishing)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: color,
                            minimumSize: const Size(0, 52),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _reportar,
                          icon: const Icon(Icons.campaign_rounded),
                          label: const Text(
                            'Avisar al IESS',
                            style: TextStyle(
                              fontFamily:
                                  'packages/theme_light/ThemeLightLexend',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _W.tinta,
                          minimumSize: const Size(0, 52),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => Voz.i.decir('${v.voz} ${v.queHacer}'),
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text(
                          'Escuchar de nuevo',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _limpiar,
                        icon: const Icon(Icons.forward_to_inbox_rounded),
                        label: const Text(
                          'Revisar otro correo',
                          style: TextStyle(fontSize: 17),
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
    );
  }
}

/// Botón secundario con ícono + texto (60 dp de alto).
class _BotonTexto extends StatelessWidget {
  const _BotonTexto({
    required this.icono,
    required this.texto,
    required this.onTap,
    this.activo = false,
  });
  final IconData icono;
  final String texto;
  final VoidCallback? onTap;
  final bool activo;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 60,
    child: OutlinedButton.icon(
      style:
          OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            backgroundColor: activo ? _W.azul : Tono.superficie,
            foregroundColor: activo ? _W.sobreAzul : _W.tinta,
            shape: const StadiumBorder(),
          ).copyWith(
            side: WidgetStateProperty.resolveWith(
              (e) => e.contains(WidgetState.focused)
                  ? const BorderSide(color: _W.azul, width: 3)
                  : const BorderSide(color: Tono.borde, width: 1.5),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontFamily: 'packages/theme_light/ThemeLightLexend',
                fontVariations: [FontVariation('wght', 600)],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      onPressed: onTap,
      icon: Icon(icono, size: 26),
      label: Text(texto),
    ),
  );
}

/// Indicador del servidor de IA (verde: modelo entrenado conectado).
class _EstadoServidor extends StatefulWidget {
  @override
  State<_EstadoServidor> createState() => _EstadoServidorState();
}

class _EstadoServidorState extends State<_EstadoServidor> {
  @override
  void initState() {
    super.initState();
    ServidorIA.i.comprobar().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ok = ServidorIA.i.afinado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok ? Tono.lima : Tono.ambar,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ok ? 'IA conectada' : 'Revisión por reglas',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
