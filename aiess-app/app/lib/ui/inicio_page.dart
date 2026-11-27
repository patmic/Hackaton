import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

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
import 'reporte_simulado.dart';
import 'aiess_home_screen.dart';
import 'aula_virtual.dart';
import '../features/sello/sello.dart';
import '../features/observatorio/observatorio.dart';

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
  var _titular = 'Hola, soy Leo';
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
              ? 'Hola, soy Leo. Veo que copiaste un mensaje. Toca Pegar y revisar, y lo vemos juntos.'
              : 'Hola, soy Leo. Si te llegó un correo raro, cópialo y toca Pegar y revisar. También puedes tocar el micrófono y contarme.',
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
        if (mounted) setState(() => _titular = 'Hola, soy Leo');
        return true;
      }
      if (p['bateria'] == true &&
          p['autoinicio'] == true &&
          p['ahorroFabricante'] == false) {
        setState(() => _titular = 'Último ajuste');
        await Voz.i.decir(
          'Tu celular congela algunas apps para ahorrar batería. En la siguiente pantalla, toca AIESS y elige Sin restricciones.',
        );
        await plataforma.invokeMethod('abrirAhorroFabricante');
        if (mounted) setState(() => _titular = 'Hola, soy Leo');
        return true;
      }
      if (p['bateria'] == true && p['autoinicio'] == true) return false;
      if (p['bateria'] == true) {
        setState(() => _titular = 'Un ajuste más');
        await Voz.i.decir(
          'Para avisarte al instante, busca AIESS en la siguiente pantalla y activa el inicio automático.',
        );
        await plataforma.invokeMethod('abrirInicioAutomatico');
        if (mounted) setState(() => _titular = 'Hola, soy Leo');
        return true;
      }
      setState(() => _titular = 'Necesito un permiso');
      await Voz.i.decir(
        'Para avisarte de correos peligrosos aunque no tengas la app abierta, toca Permitir en el siguiente mensaje.',
      );
      await plataforma.invokeMethod('abrirAjustesBateria');
      if (mounted) setState(() => _titular = 'Hola, soy Leo');
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
    // Resultado del sello ('valido', 'falso', 'sin_sello', 'sin_verificar'): se combina con los indicios.
    String? estadoSello,
    String? mensajeSello,
    bool verificadorAjeno = false,
    // false = solo reglas locales + fuentes públicas (al instante, sin la IA); la IA va con su botón.
    bool usarModelo = true,
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
    if (pasosPrevios.isEmpty && usarModelo) {
      unawaited(Voz.i.decir('Dame un momento, lo reviso.'));
    }
    var adelantado = '';
    final vIA = await Analizador.analizar(
      e,
      usarModelo: usarModelo,
      // Los pasos se van agregando en vivo, cada uno con su animación.
      alAvanzar: (paso, progreso) {
        if (!mounted) return;
        setState(() {
          if (_pasos.isEmpty || _pasos.last != paso) _pasos = [..._pasos, paso];
          _progreso = progreso;
        });
      },
      // Reacción inmediata (reglas, en milisegundos) mientras el modelo piensa.
      alSospechar: () => Voz.i.decir('Mmm, aquí hay algo raro. Déjame confirmarlo.'),
      // El modelo ya escribió veredicto y voz: el robot habla sin esperar el resto.
      alAdelantar: (phishing, voz) {
        if (!mounted || estadoSello != null) return;
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
    final v = estadoSello == null
        ? vIA
        : aplicarSello(
            vIA,
            estado: estadoSello,
            mensaje: mensajeSello,
            verificadorAjeno: verificadorAjeno,
          );
    _ultimoAnalizado = '${e.texto.trim().hashCode}';
    if (!mounted) return;
    if (adelantado.isEmpty) HapticFeedback.heavyImpact();
    setState(() {
      _veredicto = v;
      _estado = v.phishing
          ? EstadoRobot.alerta
          : (v.sinConfirmar ? EstadoRobot.reposo : EstadoRobot.seguro);
      _titular = v.titular;
      _modo = _Modo.resultado;
      _pasos = [];
    });
    unawaited(Observatorio.registrar(v));
    if (v.voz != adelantado) await _decir(v.locucion);
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
    unawaited(Voz.i.decir('Voy a verificar el sello de ese correo con el IESS.'));
    final r = await Sello.porAsunto(asunto);
    if (!mounted) return;
    final v = Sello.veredictoPorAsunto(r, asunto);
    HapticFeedback.heavyImpact();
    setState(() {
      _entrada = Entrada(asunto, canal: 'aviso');
      _veredicto = v;
      _estado = v.phishing
          ? EstadoRobot.alerta
          : (v.sinConfirmar ? EstadoRobot.reposo : EstadoRobot.seguro);
      _titular = v.phishing
          ? '¡Es una estafa!'
          : (v.sinConfirmar ? 'Sin sello: cuidado' : 'Sellado por el IESS');
      _subtitulo = '';
      _modo = _Modo.resultado;
      _pasos = [];
    });
    unawaited(Observatorio.registrar(v));
    await _decir(v.locucion);
  }

  /// Primero la firma del IESS (sello SellaCorreo). Luego, al instante y SIN la IA, los indicios del catálogo
  /// con reglas locales y fuentes públicas (solo el dominio sale): Sí/No y cuántos. El sello va como aviso.
  /// La IA solo lee el correo si la persona toca «Revisar con la IA» en el resultado.
  Future<void> _revisarTexto(
    String t, {
    String canal = 'mensaje copiado',
    List<String> pasosPrevios = const [],
  }) async {
    var estado = 'sin_sello';
    String? mensaje;
    var ajeno = false;
    if (Sello.codigoEn(t) != null) {
      final r = await _verificarSello(t, pasosPrevios: pasosPrevios);
      if (r == null || !mounted) return;
      if (r.valido) return;
      estado = r.sinRespuesta ? 'sin_verificar' : 'falso';
      mensaje = r.sinRespuesta ? null : r.mensaje;
      ajeno = r.motivo == 'dominio_ajeno';
    }
    await _analizar(
      Entrada(t, canal: canal),
      pasosPrevios: pasosPrevios,
      estadoSello: estado,
      mensajeSello: mensaje,
      verificadorAjeno: ajeno,
      usarModelo: false,
    );
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
          'Para que la IA lo revise, abre el correo, copia todo el texto y vuelve a tocar Revisar con la IA.',
        );
        return;
      }
    }
    final previo = _veredicto;
    await _analizar(
      Entrada(t, canal: 'correo revisado con la IA'),
      estadoSello: previo?.selloEstado,
      verificadorAjeno: previo?.indicios.contains('I2') ?? false,
    );
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
    // Sello falso o sin conexión: el resultado lo arma el análisis por indicios (con el aviso del sello).
    if (!r.valido) return r;
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
            : 'No abras sus enlaces ni entregues datos. Si quieres, avisa al IESS.',
        fuente: 'sello',
        selloEstado: 'valido',
      );
      _estado = r.valido ? EstadoRobot.seguro : EstadoRobot.alerta;
      _titular = r.valido ? 'Firma válida' : 'Sello falso';
      _modo = _Modo.resultado;
      _pasos = [];
    });
    unawaited(Observatorio.registrar(_veredicto!));
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
          _titular = 'Hola, soy Leo';
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
    // Celular: una captura (OCR con ML Kit), un correo guardado (.eml) o un PDF.
    final r = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['eml', 'pdf', 'png', 'jpg', 'jpeg', 'webp'],
    );
    if (r.isEmpty) return;
    final f = r.single;
    if (f.name.toLowerCase().endsWith('.eml')) {
      final correo = leerEml(await f.readAsBytes());
      await _revisarTexto(correo.paraAnalizar, canal: 'correo .eml');
      return;
    }
    if (f.name.toLowerCase().endsWith('.pdf') && f.path != null) {
      await _leerPdf(f.path!);
      return;
    }
    final ruta = f.path;
    if (ruta != null) await _analizarImagen(ruta);
  }

  /// PDF en el celular: Android dibuja cada página como imagen (sin abrir enlaces ni ejecutar nada del PDF)
  /// y el OCR de ML Kit las lee en el equipo. Las imágenes temporales se borran al terminar.
  Future<void> _leerPdf(String ruta) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = EstadoRobot.analizando;
      _titular = 'Revisando…';
      _subtitulo = '';
      _pasos = ['Leyendo el PDF en tu celular'];
      _progreso = null;
    });
    unawaited(Voz.i.decir('Déjame leer el PDF.'));
    final partes = <String>[];
    try {
      final paginas = await const MethodChannel(
        'aiess/plataforma',
      ).invokeListMethod<String>('pdfAImagenes', {'ruta': ruta});
      for (final p in paginas ?? const <String>[]) {
        try {
          partes.add((await LectorImagen.leer(p)).paraAnalizar());
        } catch (_) {}
        try {
          await File(p).delete();
        } catch (_) {}
      }
    } catch (_) {}
    if (!mounted) return;
    final texto = partes.where((t) => t.isNotEmpty).join('\n\n');
    if (texto.trim().length < 8) {
      setState(() {
        _estado = EstadoRobot.reposo;
        _titular = 'Hola, soy Leo';
        _pasos = [];
      });
      await _decir('No pude leer el PDF. Prueba con una captura del correo.');
      return;
    }
    await _revisarTexto(
      texto,
      canal: 'PDF',
      pasosPrevios: ['Leyendo el PDF en tu celular'],
    );
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
        _titular = 'Hola, soy Leo';
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
        '$motivo Toma una captura del correo completo y vuelve a intentarlo.',
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
            _titular = 'Hola, soy Leo';
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
          _titular = 'Hola, soy Leo';
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
      _titular = 'Hola, soy Leo';
      _subtitulo = '';
      _modo = _Modo.hablar;
    });
    _revisarPortapapeles();
  }

  /// Reporte al IESS SIMULADO (reglas del reto): no abre el correo ni envía nada; arma el caso y lo guarda.
  Future<void> _reportar() async {
    final v = _veredicto;
    if (v == null) return;
    await mostrarReporteSimulado(context, v, _entrada?.texto ?? '');
  }

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
        'Primero copia el correo o el enlace que te preocupa. Luego toca Pegar y revisar.',
      );
      if (mounted && _modo != _Modo.resultado)
        setState(() => _titular = 'Hola, soy Leo');
      return;
    }
    // Misma regla determinista que en las imágenes; un enlace suelto sí se revisa.
    final motivo = motivoNoEsMensaje(t);
    final soloEnlace = urlRe.hasMatch(t) && t.length < 300;
    if (motivo != null && (motivo.contains('diagrama') || !soloEnlace)) {
      HapticFeedback.mediumImpact();
      setState(() => _titular = 'No es un correo');
      await _decir('$motivo Copia el texto del correo o el enlace que te preocupa.');
      if (mounted && _modo != _Modo.resultado)
        setState(() => _titular = 'Hola, soy Leo');
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
        ? (_veredicto!.phishing
              ? EstadoHoja.estafa
              : (_veredicto!.sinConfirmar
                    ? EstadoHoja.duda
                    : EstadoHoja.seguro))
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
      indicios: _modo == _Modo.resultado ? _veredicto!.indicios : const [],
      avisoSello: _modo == _Modo.resultado ? _veredicto!.avisoSello : null,
      queSalio: _modo == _Modo.resultado ? _veredicto!.queSalio : null,
      textoCorreo:
          _modo == _Modo.resultado &&
              _entrada != null &&
              _entrada!.canal != 'aviso' &&
              _entrada!.texto.length > 40
          ? _entrada!.texto
          : null,
      onAula: () => abrirAulaVirtual(context),
      onPracticar: _abrirPractica,
      resumen: _modo == _Modo.resultado ? _veredicto?.resumen : null,
    );
  }
}
