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
  Future<String?> escuchar() async {
    await callar();
    final ok = await _stt.initialize(onError: (_) => escuchando.value = false);
    if (!ok) return null;
    final locales = await _stt.locales();
    final ids = locales.map((l) => l.localeId).toList();
    _localeStt = [
      'es_EC',
      'es_US',
      'es_MX',
      'es_419',
      'es_ES',
    ].firstWhere(ids.contains, orElse: () => _localeStt);
    final c = Completer<String?>();
    escuchando.value = true;
    await _stt.listen(
      listenOptions: SpeechListenOptions(
        partialResults: false,
        localeId: _localeStt,
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
      ),
      onResult: (r) {
        if (r.finalResult && !c.isCompleted) c.complete(r.recognizedWords);
      },
    );
    _stt.statusListener = (s) {
      if ((s == 'done' || s == 'notListening') && !c.isCompleted) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!c.isCompleted) c.complete(null);
        });
      }
    };
    final r = await c.future;
    escuchando.value = false;
    return (r == null || r.trim().isEmpty) ? null : r;
  }
}
