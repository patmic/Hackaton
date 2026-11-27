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
import '../features/llm/cerebro.dart';
import '../features/mascota/robot_guardia.dart';
import '../features/correo/eml.dart';
import '../features/ocr/documento.dart';
import '../features/ocr/ocr.dart';
import '../features/voz/voz.dart';
import 'ajustes_sheet.dart';
import 'practicar_page.dart';
import 'aiess_home_screen.dart';
import 'aula_virtual.dart';
import '../features/sello/sello.dart';

enum _Modo { copiado, hablar, resultado }

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> with WidgetsBindingObserver {
  static const _compartir = MethodChannel('aiess/compartir');

  var _estado = EstadoRobot.reposo;
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
              : 'Hola, soy AIess, tu robot guardián. Copia un correo sospechoso y toca Pegar y revisar, o tócame el micrófono y háblame.',
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
      _copiado =
          (t != null && t.length >= 8 && '${t.hashCode}' != _ultimoAnalizado)
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
    // Correo ya descartado por el sello: la IA solo agrega señales; el veredicto sigue siendo SÍ.
    String? motivoSello,
    String? mensajeSello,
    // La firma era válida: si la IA ve una estafa, es que cambiaron el texto del correo firmado.
    bool firmaValida = false,
  }) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = EstadoRobot.analizando;
      _titular = 'Revisando…';
      _subtitulo = '';
      _pasos = [...pasosPrevios];
      _progreso = null;
      _entrada = e;
    });
    if (pasosPrevios.isEmpty) unawaited(Voz.i.decir('Déjame revisarlo.'));
    var adelantado = '';
    final vIA = await Analizador.analizar(
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
      // El modelo ya escribió veredicto y voz: el robot habla sin esperar el resto.
      alAdelantar: (phishing, voz) {
        if (!mounted || motivoSello != null) return;
        adelantado = voz;
        HapticFeedback.heavyImpact();
        setState(() {
          _estado = phishing ? EstadoRobot.alerta : EstadoRobot.seguro;
          _titular = phishing ? '¡Es una estafa!' : 'Es seguro';
          _pasos = [];
          _subtitulo = voz;
        });
        Voz.i.decir(voz);
      },
    );
    final v = motivoSello == null
        ? (firmaValida ? conFirmaValida(vIA) : vIA)
        : descartarPorSello(
            motivo: motivoSello,
            mensajeSello: mensajeSello,
            ia: vIA,
          );
    _ultimoAnalizado = '${e.texto.trim().hashCode}';
    if (!mounted) return;
    if (adelantado.isEmpty) HapticFeedback.heavyImpact();
    setState(() {
      _veredicto = v;
      _estado = v.phishing ? EstadoRobot.alerta : EstadoRobot.seguro;
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
    } else if (txt != null && txt.startsWith(marcaAvisoIess)) {
      _guiarVerificacion(txt.substring(marcaAvisoIess.length).trim());
    } else if (txt != null && txt.trim().isNotEmpty) {
      _revisarTexto(txt, canal: 'mensaje compartido');
    }
  }

  /// Llegó un correo cuyo ASUNTO habla del IESS (el aviso no leyó nada más): el robot verifica el sello él solo
  /// con SellaCorreo (envía únicamente el asunto). Sellado = del IESS; sin sello = estafa.
  Future<void> _guiarVerificacion(String asunto) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = EstadoRobot.analizando;
      _titular = 'Revisando el sello…';
      _subtitulo = asunto.isEmpty ? '' : '«$asunto»';
      _pasos = ['Comprobando el sello con el IESS (solo el asunto)'];
      _progreso = null;
    });
    unawaited(Voz.i.decir('Verifico el sello de ese correo con el IESS.'));
    final r = await Sello.porAsunto(asunto);
    if (!mounted) return;
    final v = Sello.veredictoPorAsunto(r);
    HapticFeedback.heavyImpact();
    setState(() {
      _entrada = Entrada(asunto, canal: 'aviso');
      _veredicto = v;
      _estado = v.phishing ? EstadoRobot.alerta : EstadoRobot.seguro;
      _titular = v.phishing ? '¡Es una estafa!' : 'Sellado por el IESS';
      _subtitulo = '';
      _modo = _Modo.resultado;
      _pasos = [];
    });
    await _decir('${v.voz} ${v.queHacer}');
  }

  /// Primero la firma del IESS (sello SellaCorreo); el resultado sale al instante y NO se lee el correo.
  /// Sin sello válido (o sin poder comprobarlo) es estafa. La IA solo lee el correo si la persona toca
  /// «Revisar con la IA» en el resultado.
  Future<void> _revisarTexto(
    String t, {
    String canal = 'mensaje copiado',
    List<String> pasosPrevios = const [],
  }) async {
    if (Sello.codigoEn(t) != null) {
      final r = await _verificarSello(t, pasosPrevios: pasosPrevios);
      if (r == null || !mounted) return;
      if (r.sinRespuesta) _mostrarDescarte(t, 'sin_verificar');
      return;
    }
    _mostrarDescarte(t, 'sin_sello');
    await _decir('${_veredicto!.voz} ${_veredicto!.queHacer}');
  }

  /// Botón «Revisar con la IA» (tocarlo ES el permiso: el botón dice dónde corre y que todo se borra).
  /// Sirve también para el caso de una firma válida pegada a un texto cambiado.
  Future<void> _revisarConIA() async {
    var t = _entrada?.texto.trim() ?? '';
    // Desde el aviso o con solo el enlace del sello no tenemos el texto del correo: se toma lo copiado.
    final soloEnlace = Sello.codigoEn(t) != null && t.length < 160;
    if (_entrada?.canal == 'aviso' || soloEnlace || t.length < 40) {
      ClipboardData? d;
      try {
        d = await Clipboard.getData(Clipboard.kTextPlain);
      } catch (_) {}
      final copiado = d?.text?.trim() ?? '';
      if (copiado.length >= 40 && copiado != t) {
        t = copiado;
      } else {
        HapticFeedback.mediumImpact();
        await _decir(
          'Para que la IA lo revise, abre el correo, copia todo su texto y vuelve a tocar «Revisar con la IA».',
        );
        return;
      }
    }
    final previo = _veredicto;
    final firmaValida =
        previo != null && previo.fuente == 'sello' && !previo.phishing;
    final motivo =
        (previo != null &&
            previo.phishing &&
            const [
              'sin_sello',
              'sin_verificar',
              'sello',
            ].contains(previo.fuente))
        ? previo.fuente
        : null;
    await _analizar(
      Entrada(t, canal: 'correo revisado con la IA'),
      motivoSello: motivo,
      mensajeSello: motivo == 'sello' ? previo!.voz : null,
      firmaValida: firmaValida,
    );
  }

  /// Veredicto inmediato por falta de sello válido (no se lee el correo).
  void _mostrarDescarte(String t, String motivo) {
    final v = descartarPorSello(motivo: motivo);
    HapticFeedback.heavyImpact();
    setState(() {
      _entrada = Entrada(t, canal: 'sello');
      _veredicto = v;
      _estado = EstadoRobot.alerta;
      _titular = v.titular;
      _modo = _Modo.resultado;
      _pasos = [];
    });
    _ultimoAnalizado = '${t.trim().hashCode}';
  }

  /// Verifica el sello contra el servidor oficial de SellaCorreo (firma Ed25519, hash, emisor, caducidad).
  Future<ResultadoSello?> _verificarSello(
    String t, {
    List<String> pasosPrevios = const [],
  }) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = EstadoRobot.analizando;
      _titular = 'Revisando el sello…';
      _subtitulo = '';
      _pasos = [...pasosPrevios, 'Comprobando la firma del IESS'];
      _progreso = null;
    });
    unawaited(Voz.i.decir('Déjame comprobar la firma del IESS.'));
    final r = await Sello.verificar(t);
    _ultimoAnalizado = '${t.trim().hashCode}';
    if (!mounted) return null;
    if (r.sinRespuesta) {
      setState(() {
        _estado = EstadoRobot.reposo;
        _titular = 'No pude comprobarlo';
        _pasos = [];
      });
      await _decir(r.mensaje);
      return r;
    }
    final d = r.datos;
    final detalle = r.valido
        ? 'Firma válida del IESS. ${d['emisor'] ?? ''}${d['unidad'] != null ? ', ${d['unidad']}' : ''}'
              '${d['asunto'] != null ? '. Asunto: «${d['asunto']}»' : ''}. Revisa que el asunto coincida con el correo.'
        : r.mensaje;
    HapticFeedback.heavyImpact();
    setState(() {
      _entrada = Entrada(t, canal: 'sello');
      _veredicto = Veredicto(
        phishing: !r.valido,
        puntaje: r.valido ? 0 : 100,
        voz: detalle,
        indicios: const [],
        explicacion: detalle,
        queHacer: r.valido
            ? 'Puedes confiar en este correo. Igual, nunca entregues tu clave.'
            : 'No abras sus enlaces ni entregues datos. Puedes avisar al IESS.',
        fuente: 'sello',
      );
      _estado = r.valido ? EstadoRobot.seguro : EstadoRobot.alerta;
      _titular = r.valido ? 'Firma válida' : 'Sello falso';
      _modo = _Modo.resultado;
      _pasos = [];
    });
    await _decir(detalle);
    return r;
  }

  Future<void> _elegirCaptura() async {
    if (kIsWeb) {
      // Web: PDF o imagen, leídos con OCR en el propio navegador (el archivo no sale del equipo).
      final r = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['eml', 'pdf', 'png', 'jpg', 'jpeg', 'webp', 'bmp'],
      );
      if (r.isEmpty) return;
      final f = r.single;
      setState(() {
        _estado = EstadoRobot.analizando;
        _titular = 'Revisando…';
        _subtitulo = '';
        _pasos = ['Leyendo el archivo'];
        _progreso = null;
      });
      unawaited(Voz.i.decir('Déjame leer el archivo.'));
      var texto = '';
      try {
        final bytes = await f.readAsBytes();
        texto = f.name.toLowerCase().endsWith('.eml')
            ? leerEml(bytes).paraAnalizar
            : await LectorDocumento.leer(bytes, f.name);
      } catch (_) {}
      if (!mounted) return;
      if (texto.trim().length < 8) {
        setState(() {
          _estado = EstadoRobot.reposo;
          _titular = 'Hola, soy AIess';
          _pasos = [];
        });
        await _decir(
          'No pude leer texto en ese archivo. Prueba con una captura más clara.',
        );
        return;
      }
      await _revisarTexto(
        texto,
        canal: 'archivo subido',
        pasosPrevios: ['Leyendo el archivo'],
      );
      return;
    }
    // Celular: una captura (OCR con ML Kit) o un correo guardado (.eml).
    final r = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['eml', 'png', 'jpg', 'jpeg', 'webp'],
    );
    if (r.isEmpty) return;
    final f = r.single;
    if (f.name.toLowerCase().endsWith('.eml')) {
      final correo = leerEml(await f.readAsBytes());
      await _revisarTexto(correo.paraAnalizar, canal: 'correo .eml');
      return;
    }
    final ruta = f.path;
    if (ruta != null) await _analizarImagen(ruta);
  }

  /// OCR + QR en el celular y luego el análisis normal.
  Future<void> _analizarImagen(String ruta) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = EstadoRobot.analizando;
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
        _estado = EstadoRobot.reposo;
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
        _estado = EstadoRobot.reposo;
        _titular = 'No es un correo';
        _pasos = [];
      });
      await _decir(
        '$motivo Toma una captura del correo o mensaje completo y vuelve a intentarlo.',
      );
      return;
    }
    await _revisarTexto(
      lectura.paraAnalizar(),
      canal: 'captura de pantalla',
      pasosPrevios: ['Leyendo la imagen'],
    );
  }

  Future<void> _pulsar() async {
    switch (_modo) {
      case _Modo.copiado:
        await _revisarTexto(_copiado!);
      case _Modo.hablar:
        setState(() {
          _estado = EstadoRobot.escuchando;
          _titular = 'Te escucho…';
          _subtitulo = '';
        });
        // Subtítulos en vivo: lo que va entendiendo aparece mientras la persona habla.
        void verParcial() {
          if (mounted && Voz.i.parcial.value.isNotEmpty) {
            setState(() => _subtitulo = '«${Voz.i.parcial.value}»');
          }
        }

        Voz.i.parcial.addListener(verParcial);
        final dicho = await Voz.i.escuchar();
        Voz.i.parcial.removeListener(verParcial);
        if (!mounted) return;
        if (dicho == null) {
          setState(() {
            _estado = EstadoRobot.reposo;
            _titular = 'Hola, soy AIess';
          });
          await _decir(
            Voz.i.problemaEscucha ??
                'No te escuché bien. Toca el botón y vuelve a intentarlo.',
          );
          return;
        }
        final p = plegar(dicho);
        if (RegExp(r'(juguemos|jugar|practic|entrena)').hasMatch(p)) {
          setState(() => _estado = EstadoRobot.reposo);
          _abrirPractica();
          return;
        }
        if (urlRe.hasMatch(dicho) || dicho.length > 90) {
          await _revisarTexto(dicho, canal: 'mensaje dictado');
          return;
        }
        setState(() {
          _estado = EstadoRobot.analizando;
          _titular = 'Pensando…';
        });
        final r = await Persona.responder(dicho);
        if (!mounted) return;
        setState(() {
          _estado = EstadoRobot.reposo;
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
      _entrada = null; // la conversación se borra al terminar
      _estado = EstadoRobot.reposo;
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

  void _tocarRobot() {
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

  /// Pegar y revisar: lee el portapapeles en el momento (poka-yoke: si no hay nada, el robot explica qué hacer).
  Future<void> _pegarYRevisar() async {
    ClipboardData? d;
    try {
      d = await Clipboard.getData(Clipboard.kTextPlain);
    } catch (_) {}
    final t = d?.text?.trim() ?? '';
    // Un enlace de sello se verifica directo (no hace falta leer el correo).
    if (Sello.codigoEn(t) != null) {
      await _revisarTexto(t);
      return;
    }
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
    await _revisarTexto(t);
  }

  Future<void> _hablar() async {
    // Segundo toque mientras escucha = «Parar»: se usa lo que alcanzó a entender y se revisa.
    if (_estado == EstadoRobot.escuchando) {
      Voz.i.pararEscucha();
      return;
    }
    final previo = _modo;
    _modo = _Modo.hablar;
    await _pulsar();
    if (_modo == _Modo.hablar && previo != _Modo.resultado) _modo = previo;
  }

  @override
  Widget build(BuildContext context) {
    final escuchando = _estado == EstadoRobot.escuchando;
    final hoja = _modo == _Modo.resultado
        ? (_veredicto!.phishing ? EstadoHoja.estafa : EstadoHoja.seguro)
        : (_estado == EstadoRobot.analizando || escuchando
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
      onTapMascota: _tocarRobot,
      onReport: () async {
        await _reportar();
        _reiniciar();
      },
      onDone: _reiniciar,
      onReanalizar: _entrada == null ? null : () => _analizar(_entrada!),
      onRevisarIA: _modo == _Modo.resultado ? _revisarConIA : null,
      iaLocal: Cerebro.i.enEsteEquipo,
      onAula: () => abrirAulaVirtual(context),
      onPracticar: _abrirPractica,
      resumen: _modo == _Modo.resultado ? _veredicto?.resumen : null,
    );
  }
}
