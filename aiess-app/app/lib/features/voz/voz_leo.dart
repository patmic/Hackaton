// Voz de Leo: audios pregrabados con ElevenLabs (assets/voz/*.mp3, índice en assets/voz/manifiesto.json).
// Nada sale del equipo: los audios van dentro de la app. Una frase se parte en trozos: cada trozo que coincide con
// el texto de un audio se reproduce con la voz de Leo; lo que no tiene audio (un dominio, un asunto, una respuesta
// libre de la IA) lo dice la voz del sistema.
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ParteVoz {
  const ParteVoz(this.texto, this.inicio, this.fin, [this.archivo]);

  /// Texto tal como está en la frase original (lo que se ve en los subtítulos).
  final String texto;

  /// Posición del trozo dentro de la frase completa (para el efecto karaoke).
  final int inicio, fin;

  /// Archivo dentro de assets/voz/ o null si se dice con la voz del sistema.
  final String? archivo;
}

class VozLeo {
  VozLeo._();
  static final i = VozLeo._();

  /// (texto en minúsculas, archivo), del más largo al más corto: así gana siempre la frase completa.
  List<(String, String)> _audios = const [];
  Future<void>? _carga;

  Future<void> cargar() => _carga ??= _leer();

  Future<void> _leer() async {
    try {
      final m = jsonDecode(await rootBundle.loadString('assets/voz/manifiesto.json')) as Map<String, dynamic>;
      _audios = [
        for (final a in (m['audios'] as List).cast<Map<String, dynamic>>())
          ((a['texto'] as String).trim().toLowerCase(), a['archivo'] as String),
      ]..sort((a, b) => b.$1.length.compareTo(a.$1.length));
    } catch (_) {
      _audios = const []; // sin manifiesto: todo con la voz del sistema
    }
  }

  /// ¿Algún audio empieza exactamente en la posición [i] de [bajo]? Devuelve (largo, archivo).
  (int, String)? _audioEn(String bajo, int i) {
    for (final (t, archivo) in _audios) {
      if (bajo.startsWith(t, i)) return (t.length, archivo);
    }
    return null;
  }

  /// Parte [texto] en trozos con audio de Leo y trozos para la voz del sistema.
  Future<List<ParteVoz>> partir(String texto) async {
    await cargar();
    final bajo = texto.toLowerCase();
    final partes = <ParteVoz>[];
    var i = 0;
    var libre = -1; // inicio del trozo sin audio en curso
    void cerrarLibre(int hasta) {
      if (libre >= 0 && texto.substring(libre, hasta).trim().isNotEmpty) {
        partes.add(ParteVoz(texto.substring(libre, hasta), libre, hasta));
      }
      libre = -1;
    }

    while (i < texto.length) {
      // Los audios solo pueden empezar al inicio o después de un espacio.
      final inicioPalabra = i == 0 || texto[i - 1].trim().isEmpty;
      final hallado = inicioPalabra && texto[i].trim().isNotEmpty ? _audioEn(bajo, i) : null;
      if (hallado != null) {
        cerrarLibre(i);
        final (largo, archivo) = hallado;
        partes.add(ParteVoz(texto.substring(i, i + largo), i, i + largo, archivo));
        i += largo;
      } else {
        if (libre < 0 && texto[i].trim().isNotEmpty) libre = i;
        i++;
      }
    }
    cerrarLibre(texto.length);
    return partes;
  }
}

/// Pronunciación para la voz del sistema (los audios de Leo ya la traen): AIESS = «Ay es», IESS = «I es».
String pronunciar(String t) => t
    .replaceAll(RegExp(r'\bAIESS\b|\bAIess\b', caseSensitive: false), 'Ay es')
    .replaceAll(RegExp(r'\biess\b', caseSensitive: false), 'I es');
