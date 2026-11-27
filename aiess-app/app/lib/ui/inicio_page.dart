import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/canales.dart';
import '../features/analisis/analizador.dart';
import '../features/analisis/motor.dart';
import '../features/chat/persona.dart';
import '../features/mascota/pantera.dart';
import '../features/ocr/ocr.dart';
import '../features/voz/voz.dart';
import 'ajustes_sheet.dart';
import 'practicar_page.dart';
import 'aiess_home_screen.dart';
import 'aula_virtual.dart';

enum _Modo { copiado, hablar, resultado }

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> with WidgetsBindingObserver {
  static const _compartir = MethodChannel('aiess/compartir');

  var _estado = EstadoPantera.reposo;
  var _modo = _Modo.hablar;
  var _titular = 'Hola, soy AIess';
  var _subtitulo = '';
  var _pasos = <String>[];
  double? _progreso;
  String? _copiado;
  String? _ultimoAnalizado;
  Veredicto? _veredicto;
  Entrada? _entrada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _compartir.setMethodCallHandler((c) async {
      if (c.method == 'compartido')
        _recibir(Map<String, dynamic>.from(c.arguments as Map));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map? inicial;
      if (!kIsWeb) {
        try {
          inicial = await _compartir.invokeMethod<Map>('inicial');
        } catch (_) {}
      }
      if (inicial != null &&
          (inicial['texto'] != null || inicial['imagen'] != null)) {
        _recibir(Map<String, dynamic>.from(inicial));
      } else {
        if (await _faltaSegundoPlano()) return;
        await _revisarPortapapeles();
        Voz.i.decir(
          _copiado != null
              ? 'Hola, soy AIess. Veo que copiaste un mensaje. Toca Pegar y revisar.'
              : 'Hola, soy AIess, tu cóndor guardián. Copia un correo sospechoso y toca Pegar y revisar, o tócame el micrófono y háblame.',
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed && _modo != _Modo.resultado)
      _revisarPortapapeles();
  }

  /// Sin permiso de segundo plano, Android duerme al guardián y no salen los pop-ups de correo.
  Future<bool> _faltaSegundoPlano() async {
    if (kIsWeb) return false;
    const plataforma = MethodChannel('aiess/plataforma');
    try {
      final p = Map<String, dynamic>.from(
        await plataforma.invokeMethod('permisos'),
      );
      if (p['pantallaCompleta'] == false) {
        setState(() => _titular = 'Un permiso más');
        await Voz.i.decir(
          'Para avisarte aunque tu celular esté bloqueado, activa el permiso de pantalla completa para AIESS.',
        );
        await plataforma.invokeMethod('abrirAjustesPantallaCompleta');
        if (mounted) setState(() => _titular = 'Hola, soy AIess');
        return true;
      }
      if (p['bateria'] == true &&
          p['autoinicio'] == true &&
          p['ahorroFabricante'] == false) {
        setState(() => _titular = 'Último ajuste');
        await Voz.i.decir(
          'Tu celular congela las apps para ahorrar batería. En la siguiente pantalla toca AIESS y elige Sin restricciones.',
        );
        await plataforma.invokeMethod('abrirAhorroFabricante');
        if (mounted) setState(() => _titular = 'Hola, soy AIess');
        return true;
      }
      if (p['bateria'] == true && p['autoinicio'] == true) return false;
      if (p['bateria'] == true) {
        setState(() => _titular = 'Un ajuste más');
        await Voz.i.decir(
          'Para avisarte al instante, busca AIESS en la siguiente pantalla y activa el inicio automático.',
        );
        await plataforma.invokeMethod('abrirInicioAutomatico');
        if (mounted) setState(() => _titular = 'Hola, soy AIess');
        return true;
      }
      setState(() => _titular = 'Necesito un permiso');
      await Voz.i.decir(
        'Para avisarte de correos peligrosos aunque no tengas la app abierta, toca Permitir en el siguiente mensaje.',
      );
      await plataforma.invokeMethod('abrirAjustesBateria');
      if (mounted) setState(() => _titular = 'Hola, soy AIess');
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<void> _revisarPortapapeles() async {
    ClipboardData? d;
    try {
      d = await Clipboard.getData(
        Clipboard.kTextPlain,
      ); // en web puede pedir permiso o fallar
    } catch (_) {}
    final t = d?.text?.trim();
    setState(() {
      _copiado = (t != null && t.length >= 8 && t != _ultimoAnalizado)
          ? t
          : null;
      if (_modo != _Modo.resultado)
        _modo = _copiado != null ? _Modo.copiado : _Modo.hablar;
    });
  }

  Future<void> _decir(String texto) async {
    setState(() => _subtitulo = texto);
    // Escrito y hablado: el texto queda en pantalla hasta la siguiente acción.
    await Voz.i.decir(texto);
  }

  Future<void> _analizar(
    Entrada e, {
    List<String> pasosPrevios = const [],
  }) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = EstadoPantera.analizando;
      _titular = 'Revisando…';
      _subtitulo = '';
      _pasos = [...pasosPrevios];
      _progreso = null;
      _entrada = e;
    });
    if (pasosPrevios.isEmpty) unawaited(Voz.i.decir('Déjame revisarlo.'));
    var adelantado = '';
    final v = await Analizador.analizar(
      e,
      // Los pasos se van agregando en vivo, cada uno con su animación.
      alAvanzar: (paso, progreso) {
        if (!mounted) return;
        setState(() {
          if (_pasos.isEmpty || _pasos.last != paso) _pasos = [..._pasos, paso];
          _progreso = progreso;
        });
      },
      // Reacción inmediata (reglas, en milisegundos) mientras el modelo piensa.
      alSospechar: () => Voz.i.decir('Mmm, veo algo raro. Déjame confirmarlo.'),
      // El modelo ya escribió veredicto y voz: el cóndor habla sin esperar el resto.
      alAdelantar: (phishing, voz) {
        if (!mounted) return;
        adelantado = voz;
        HapticFeedback.heavyImpact();
        setState(() {
          _estado = phishing ? EstadoPantera.alerta : EstadoPantera.seguro;
          _titular = phishing ? '¡Es una estafa!' : 'Es seguro';
          _pasos = [];
          _subtitulo = voz;
        });
        Voz.i.decir(voz);
      },
    );
    _ultimoAnalizado = e.texto.trim();
    if (!mounted) return;
    if (adelantado.isEmpty) HapticFeedback.heavyImpact();
    setState(() {
      _veredicto = v;
      _estado = v.phishing ? EstadoPantera.alerta : EstadoPantera.seguro;
      _titular = v.titular;
      _modo = _Modo.resultado;
      _pasos = [];
    });
    if (v.voz != adelantado) await _decir(v.voz);
  }

  /// Algo compartido con AIESS desde otra app: texto o una captura de pantalla.
  void _recibir(Map<String, dynamic> m) {
    final img = m['imagen'] as String?;
    final txt = m['texto'] as String?;
    if (img != null) {
      _analizarImagen(img);
    } else if (txt != null && txt.trim().isNotEmpty) {
      _analizar(Entrada(txt, canal: 'mensaje compartido'));
    }
  }

  Future<void> _elegirCaptura() async {
    if (kIsWeb) {
      await _decir(
        'En la versión web no puedo leer imágenes. Copia el texto del correo y toca Pegar y revisar.',
      );
      return;
    }
    final r = await FilePicker.pickFiles(type: FileType.image);
    final ruta = r.isEmpty ? null : r.single.path;
    if (ruta != null) await _analizarImagen(ruta);
  }

  /// OCR + QR en el celular y luego el análisis normal.
  Future<void> _analizarImagen(String ruta) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = EstadoPantera.analizando;
      _titular = 'Revisando…';
      _subtitulo = '';
      _pasos = ['Leyendo la imagen'];
      _progreso = null;
    });
    unawaited(Voz.i.decir('Déjame leer la imagen.'));
    LecturaImagen lectura;
    try {
      lectura = await LectorImagen.leer(ruta);
    } catch (_) {
      lectura = const LecturaImagen('');
    }
    if (!mounted) return;
    if (lectura.vacia) {
      setState(() {
        _estado = EstadoPantera.reposo;
        _titular = 'Hola, soy AIess';
        _pasos = [];
      });
      await _decir(
        'No pude leer texto en esa imagen. Prueba con una captura más clara.',
      );
      return;
    }
    // Regla determinista: si la imagen no es un correo o mensaje, no se inventa un veredicto.
    final motivo = motivoNoEsMensaje(lectura.paraAnalizar());
    if (motivo != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _estado = EstadoPantera.reposo;
        _titular = 'No es un correo';
        _pasos = [];
      });
      await _decir(
        '$motivo Toma una captura del correo o mensaje completo y vuelve a intentarlo.',
      );
      return;
    }
    await _analizar(
      Entrada(lectura.paraAnalizar(), canal: 'captura de pantalla'),
      pasosPrevios: ['Leyendo la imagen'],
    );
  }

  Future<void> _pulsar() async {
    switch (_modo) {
      case _Modo.copiado:
        await _analizar(Entrada(_copiado!));
      case _Modo.hablar:
        setState(() {
          _estado = EstadoPantera.escuchando;
          _titular = 'Te escucho…';
        });
        final dicho = await Voz.i.escuchar();
        if (!mounted) return;
        if (dicho == null) {
          setState(() {
            _estado = EstadoPantera.reposo;
            _titular = 'Hola, soy AIess';
          });
          await _decir(
            'No te escuché bien. Toca el botón y vuelve a intentarlo.',
          );
          return;
        }
        final p = plegar(dicho);
        if (RegExp(r'(juguemos|jugar|practic|entrena)').hasMatch(p)) {
          setState(() => _estado = EstadoPantera.reposo);
          _abrirPractica();
          return;
        }
        if (urlRe.hasMatch(dicho) || dicho.length > 90) {
          await _analizar(Entrada(dicho, canal: 'mensaje dictado'));
          return;
        }
        setState(() {
          _estado = EstadoPantera.analizando;
          _titular = 'Pensando…';
        });
        final r = await Persona.responder(dicho);
        if (!mounted) return;
        setState(() {
          _estado = EstadoPantera.reposo;
          _titular = 'Hola, soy AIess';
        });
        await _decir(r);
      case _Modo.resultado:
        if (_veredicto!.phishing) {
          await _reportar();
        }
        _reiniciar();
    }
  }

  void _reiniciar() {
    Voz.i.callar();
    setState(() {
      _veredicto = null;
      _estado = EstadoPantera.reposo;
      _titular = 'Hola, soy AIess';
      _subtitulo = '';
      _modo = _Modo.hablar;
    });
    _revisarPortapapeles();
  }

  Future<void> _reportar() async {
    final c = Canales.i.contacto;
    final uri = Uri(
      scheme: 'mailto',
      path: c['seguridad_informacion'],
      query: _query({
        'subject': 'Reporte de posible phishing (AIESS)',
        'body':
            'Recibí este mensaje sospechoso:\n\n${_entrada?.texto ?? ''}\n\nSeñales detectadas: ${_veredicto?.explicacion ?? ''}',
      }),
    );
    await launchUrl(uri);
  }

  String _query(Map<String, String> m) => m.entries
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');

  void _tocarPantera() {
    final v = _veredicto;
    if (v != null) {
      _decir('${v.explicacion} ${v.queHacer}');
    } else {
      _decir(Persona.guia('hola'));
    }
  }

  void _abrirPractica() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const PracticarPage()));

  /// Pegar y revisar: lee el portapapeles en el momento (poka-yoke: si no hay nada, el cóndor explica qué hacer).
  Future<void> _pegarYRevisar() async {
    ClipboardData? d;
    try {
      d = await Clipboard.getData(Clipboard.kTextPlain);
    } catch (_) {}
    final t = d?.text?.trim() ?? '';
    if (t.length < 8) {
      HapticFeedback.mediumImpact();
      setState(() => _titular = 'No hay nada copiado');
      await _decir(
        'Primero copia el correo o el enlace sospechoso. Luego toca Pegar y revisar.',
      );
      if (mounted && _modo != _Modo.resultado)
        setState(() => _titular = 'Hola, soy AIess');
      return;
    }
    // Misma regla determinista que en las imágenes; un enlace suelto sí se revisa.
    final motivo = motivoNoEsMensaje(t);
    final soloEnlace = urlRe.hasMatch(t) && t.length < 300;
    if (motivo != null && (motivo.contains('diagrama') || !soloEnlace)) {
      HapticFeedback.mediumImpact();
      setState(() => _titular = 'No es un correo');
      await _decir('$motivo Copia el texto del correo o el enlace sospechoso.');
      if (mounted && _modo != _Modo.resultado)
        setState(() => _titular = 'Hola, soy AIess');
      return;
    }
    await _analizar(Entrada(t));
  }

  Future<void> _hablar() async {
    final previo = _modo;
    _modo = _Modo.hablar;
    await _pulsar();
    if (_modo == _Modo.hablar && previo != _Modo.resultado) _modo = previo;
  }

  @override
  Widget build(BuildContext context) {
    final escuchando = _estado == EstadoPantera.escuchando;
    final hoja = _modo == _Modo.resultado
        ? (_veredicto!.phishing ? EstadoHoja.estafa : EstadoHoja.seguro)
        : (_estado == EstadoPantera.analizando || escuchando
              ? EstadoHoja.analizando
              : EstadoHoja.listo);
    return AiessHomeScreen(
      estado: hoja,
      estadoMascota: _estado,
      titulo: _titular,
      texto: _subtitulo.isEmpty ? null : _subtitulo,
      pasos: _pasos,
      progreso: _progreso,
      escuchando: escuchando,
      hasClipboardContent: _copiado != null,
      onPasteAndCheck: _pegarYRevisar,
      onVoiceInput: _hablar,
      onPickImage: _elegirCaptura,
      onOpenSettings: () =>
          mostrarAjustes(context, alPracticar: _abrirPractica),
      onTapMascota: _tocarPantera,
      onReport: () async {
        await _reportar();
        _reiniciar();
      },
      onDone: _reiniciar,
      onReanalizar: _entrada == null ? null : () => _analizar(_entrada!),
      onAula: () => abrirAulaVirtual(context),
      onPracticar: _abrirPractica,
    );
  }
}
