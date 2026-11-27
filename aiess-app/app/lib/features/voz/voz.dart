// Voz local: TTS del sistema para que el robot hable y reconocimiento de voz para escucharte.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Voz {
  Voz._();
  static final i = Voz._();

  final _tts = FlutterTts();
  final _stt = SpeechToText();
  final hablando = ValueNotifier(false);
  final escuchando = ValueNotifier(false);

  /// 0..1: "volumen" aproximado de la sílaba actual, para mover la cabeza del robot.
  final silaba = ValueNotifier(0.0);

  /// Hasta qué carácter del texto actual va hablando (para el efecto karaoke).
  final avance = ValueNotifier(0);
  String actual = '';
  bool _listo = false;
  String _localeStt = 'es_EC';

  Future<void> iniciar() async {
    if (_listo) return;
    _listo = true;
    final idiomas = List<String>.from(
      ((await _tts.getLanguages) as List?) ?? const [],
    );
    final pref = ['es-EC', 'es-US', 'es-MX', 'es-419', 'es-ES'];
    await _tts.setLanguage(
      pref.firstWhere(idiomas.contains, orElse: () => 'es-ES'),
    );
    await _tts.setSpeechRate(0.46); // pausado, pensado para personas mayores
    await _tts.setPitch(1.05);
    await _tts.awaitSpeakCompletion(true);
    _tts.setStartHandler(() => hablando.value = true);
    _tts.setCompletionHandler(_fin);
    _tts.setCancelHandler(_fin);
    _tts.setErrorHandler((_) => _fin());
    _tts.setProgressHandler((texto, ini, fin, palabra) {
      if (fin > avance.value) avance.value = fin;
      silaba.value = (palabra.length / 8).clamp(0.3, 1.0);
      Future.delayed(const Duration(milliseconds: 140), () => silaba.value = 0);
    });
  }

  void _fin() {
    hablando.value = false;
    silaba.value = 0;
    avance.value = actual.length;
  }

  Future<void> decir(String texto) async {
    await iniciar();
    await _tts.stop();
    actual = texto;
    avance.value = 0;
    if (texto.trim().isEmpty) return;
    hablando.value = true;
    // En pantalla se escribe AIess; en voz se pronuncia como una palabra.
    await _tts.speak(
      texto.replaceAll('AIess', 'Ayés').replaceAll('AIESS', 'Ayés'),
    );
  }

  Future<void> callar() async {
    await _tts.stop();
    _fin();
  }

  /// Escucha una frase y la devuelve (null si no se entendió o no hay permiso de micrófono).
  /// Por qué no se pudo escuchar la última vez (para decírselo a la persona). Null si funcionó.
  String? problemaEscucha;
  bool _sttListo = false;

  /// Cierra la escucha en curso (los avisos del micrófono se registran una sola vez y llaman aquí).
  void Function(String?) _terminarActual = (_) {};

  /// Lo último que se entendió. Muchos celulares nunca mandan el resultado "final":
  /// al terminar la escucha se usa esto en vez de perder lo que la persona dijo.
  String? _ultimoParcial;

  /// Lo que va entendiendo mientras la persona habla (subtítulos en vivo).
  final parcial = ValueNotifier('');

  /// Botón «Parar»: la persona terminó de hablar. Se usa lo que se alcanzó a entender.
  void pararEscucha() {
    if (!escuchando.value) return;
    _stt.stop();
    _terminarActual(_ultimoParcial);
  }

  /// Escucha una frase y la devuelve escrita. Nunca se queda colgada: termina con el resultado,
  /// con silencio, con un error del micrófono o a los 45 segundos.
  Future<String?> escuchar() async {
    await callar();
    problemaEscucha = null;
    _ultimoParcial = null;
    parcial.value = '';
    final c = Completer<String?>();
    void terminar(String? texto) {
      if (!c.isCompleted) c.complete(texto);
    }

    _terminarActual = terminar;

    try {
      if (!_sttListo) {
        _sttListo = await _stt.initialize(
          onError: (e) {
            problemaEscucha =
                e.errorMsg.contains('permission') ||
                    e.errorMsg.contains('not-allowed')
                ? 'No tengo permiso para usar el micrófono. Permítelo y vuelve a intentar.'
                : (e.errorMsg.contains('no-speech') ||
                      e.errorMsg.contains('no_match') ||
                      e.errorMsg.contains('speech_timeout'))
                ? 'No te escuché. Habla un poco más fuerte, cerca del micrófono.'
                : 'El micrófono tuvo un problema. Vuelve a intentarlo.';
            _terminarActual(_ultimoParcial);
          },
          onStatus: (s) {
            if (s == 'done' || s == 'notListening') {
              final cerrar = _terminarActual;
              Future.delayed(
                const Duration(milliseconds: 700),
                () => cerrar(_ultimoParcial),
              );
            }
          },
        );
      }
      if (!_sttListo) {
        problemaEscucha = kIsWeb
            ? 'Este navegador no permite dictar. Abre AIESS en Chrome o Edge, o escribe el correo.'
            : 'Este celular no tiene el dictado por voz activado. Puedes pegar el correo en su lugar.';
        return null;
      }
      final locales = await _stt.locales();
      final ids = locales.map((l) => l.localeId).toList();
      // Android usa "es_EC"; el navegador, "es-EC".
      final preferidos = kIsWeb
          ? ['es-EC', 'es-US', 'es-MX', 'es-419', 'es-ES']
          : ['es_EC', 'es_US', 'es_MX', 'es_419', 'es_ES'];
      _localeStt = preferidos.firstWhere(
        ids.contains,
        orElse: () => preferidos.first,
      );
      escuchando.value = true;
      await _stt.listen(
        // Dictado largo y con pausas generosas (las personas mayores hablan con calma).
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: true,
          localeId: _localeStt,
          listenFor: const Duration(seconds: 40),
          // Al quedarse callada 4 s se da por terminado y se revisa solo.
          pauseFor: const Duration(seconds: 4),
        ),
        onResult: (r) {
          if (r.recognizedWords.trim().isNotEmpty) {
            _ultimoParcial = r.recognizedWords;
            parcial.value = r.recognizedWords;
          }
          if (r.finalResult) terminar(r.recognizedWords);
        },
      );
      final r = await c.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          _stt.stop();
          return _ultimoParcial;
        },
      );
      // Si hubo un error pero alcanzó a entender algo, se usa eso.
      if (r != null && r.trim().isNotEmpty) problemaEscucha = null;
      if ((r == null || r.trim().isEmpty) && problemaEscucha == null) {
        problemaEscucha =
            'No te escuché bien. Toca el botón y vuelve a intentarlo.';
      }
      return (r == null || r.trim().isEmpty) ? null : r;
    } catch (_) {
      problemaEscucha ??=
          'El micrófono no está disponible ahora. Puedes pegar el correo en su lugar.';
      return null;
    } finally {
      escuchando.value = false;
    }
  }
}
