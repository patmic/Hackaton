// Voz local: Leo habla con sus audios pregrabados (voz_leo.dart) y, para lo que no tiene audio, con el TTS del
// sistema. Reconocimiento de voz para escucharte.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'voz_leo.dart';

class Voz {
  Voz._();
  static final i = Voz._();

  final _tts = FlutterTts();
  final _audio = AudioPlayer();

  /// Cada frase nueva sube el turno: así una frase vieja deja de sonar si llega otra o se pide callar.
  int _turno = 0;

  /// Para el karaoke de la voz del sistema: dónde empieza y termina el trozo que está diciendo.
  int _ttsBase = 0, _ttsFin = 0;
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
    _tts.setProgressHandler((texto, ini, fin, palabra) {
      final a = (_ttsBase + fin).clamp(_ttsBase, _ttsFin);
      if (a > avance.value) avance.value = a;
      silaba.value = (palabra.length / 8).clamp(0.3, 1.0);
      Future.delayed(const Duration(milliseconds: 140), () => silaba.value = 0);
    });
    unawaited(VozLeo.i.cargar());
  }

  void _fin() {
    hablando.value = false;
    silaba.value = 0;
    avance.value = actual.length;
  }

  /// Dice [texto] con la voz de Leo: cada trozo que tiene audio pregrabado suena con ese audio; el resto, con la
  /// voz del sistema. Termina cuando acaba de hablar (o cuando otra frase o [callar] lo interrumpen).
  Future<void> decir(String texto) async {
    await iniciar();
    final turno = ++_turno;
    await _detener();
    actual = texto;
    avance.value = 0;
    if (texto.trim().isEmpty) {
      _fin();
      return;
    }
    hablando.value = true;
    final partes = await VozLeo.i.partir(texto);
    for (var k = 0; k < partes.length; k++) {
      if (turno != _turno) return;
      final p = partes[k];
      final sono = p.archivo != null && await _reproducir(p, turno);
      if (turno != _turno) return;
      if (!sono && p.archivo != null) {
        // Un audio de Leo no cargó o no sonó: TODO lo que falta lo dice la voz del sistema de una vez, para que
        // nunca se quede a medias (antes se quedaba callado después de «Encontré N indicios»).
        await _decirSistema(
          ParteVoz(texto.substring(p.inicio), p.inicio, texto.length),
        );
        break;
      }
      if (!sono) await _decirSistema(p);
      if (turno == _turno) avance.value = p.fin;
    }
    if (turno == _turno) _fin();
  }

  /// Un audio de Leo. false si no se pudo reproducir (entonces lo dice la voz del sistema).
  Future<bool> _reproducir(ParteVoz p, int turno) async {
    StreamSubscription<Duration>? sub;
    try {
      final dur = await _audio
          .setAsset('assets/voz/${p.archivo}')
          .timeout(const Duration(seconds: 4));
      final total = dur?.inMilliseconds ?? 0;
      if (total <= 0) return false;
      sub = _audio.positionStream.listen((pos) {
        if (turno != _turno) return;
        final ms = pos.inMilliseconds;
        if (total > 0) {
          avance.value =
              p.inicio +
              ((p.fin - p.inicio) * ms / total).round().clamp(
                0,
                p.fin - p.inicio,
              );
        }
        silaba.value = (ms ~/ 160).isEven
            ? 0.85
            : 0.35; // la cabeza de Leo se mueve mientras habla
      });
      unawaited(_audio.play());
      // Nunca se queda esperando: en el navegador el aviso de «terminó» a veces no llega. Se espera lo que dura
      // el audio (más un margen) y se sigue con el siguiente trozo.
      await Future.any([
        _audio.processingStateStream.firstWhere(
          (s) => s == ProcessingState.completed,
        ),
        Future.delayed(Duration(milliseconds: total + 700)),
      ]);
      await _audio.pause();
      return true;
    } catch (_) {
      return false;
    } finally {
      await sub?.cancel();
      silaba.value = 0;
    }
  }

  Future<void> _decirSistema(ParteVoz p) async {
    _ttsBase = p.inicio;
    _ttsFin = p.fin;
    // Límite por si la voz del sistema no avisa que terminó (pasa en algunos navegadores).
    await _tts
        .speak(pronunciar(p.texto))
        .timeout(
          Duration(milliseconds: 4000 + p.texto.length * 90),
          onTimeout: () => null,
        );
  }

  Future<void> _detener() async {
    try {
      await _tts.stop();
      await _audio.stop();
    } catch (_) {}
  }

  Future<void> callar() async {
    _turno++;
    await _detener();
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
                ? 'No tengo permiso para usar el micrófono. Actívalo y vuelve a intentarlo.'
                : (e.errorMsg.contains('no-speech') ||
                      e.errorMsg.contains('no_match') ||
                      e.errorMsg.contains('speech_timeout'))
                ? 'No te escuché. Habla un poco más fuerte y cerca del micrófono.'
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
            : 'Este celular no tiene activado el dictado por voz. Puedes pegar el correo en su lugar.';
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
