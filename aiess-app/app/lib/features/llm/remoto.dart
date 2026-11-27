// Cliente del servidor de IA de AIESS (llama-server con el modelo LFM2 entrenado), para Android y web.
// Usa /completion con el MISMO formato de prompt del entrenamiento y recibe la respuesta en streaming.
// Privacidad: el texto solo viaja para analizarse; el servidor no lo escribe en disco ni lo registra
// (llama-server sin --log-prompts-dir y con --no-slots) y la memoria temporal se reemplaza con la siguiente revisión.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServidorIA {
  ServidorIA._();
  static final i = ServidorIA._();

  /// Web publicada por el propio servidor: misma dirección. Android: se configura en Ajustes
  /// (por defecto 127.0.0.1:8080, que con `adb reverse` apunta a la PC conectada por USB).
  // Secretos inyectados al compilar (nunca en el repo):
  //   flutter build apk --dart-define-from-file=secretos.json
  static const _urlSecreta = String.fromEnvironment('AIESS_SERVIDOR');
  static const _claveSecreta = String.fromEnvironment('AIESS_CLAVE');

  static String get porDefecto =>
      _urlSecreta.isNotEmpty ? _urlSecreta : (kIsWeb ? Uri.base.origin : 'http://127.0.0.1:8080');

  String url = porDefecto;
  String clave = _claveSecreta;
  bool disponible = false;
  String modelo = '';

  bool get afinado => disponible && modelo.toLowerCase().contains('aiess');

  Future<void> cargarAjustes() async {
    final p = await SharedPreferences.getInstance();
    url = (p.getString('servidor_url') ?? '').trim().isEmpty ? porDefecto : p.getString('servidor_url')!.trim();
    final guardada = p.getString('servidor_clave') ?? '';
    clave = guardada.isEmpty ? _claveSecreta : guardada;
  }

  Future<void> guardar(String nuevaUrl, String nuevaClave) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('servidor_url', nuevaUrl.trim());
    await p.setString('servidor_clave', nuevaClave.trim());
    await cargarAjustes();
    await comprobar();
  }

  Map<String, String> get _cabeceras => {
        'Content-Type': 'application/json',
        if (clave.isNotEmpty) 'Authorization': 'Bearer $clave',
      };

  Uri _u(String ruta) => Uri.parse('${url.replaceAll(RegExp(r'/+$'), '')}$ruta');

  /// ¿Responde el servidor? (3 s máximo, para no trabar la app).
  Future<bool> comprobar() async {
    try {
      final r = await http.get(_u('/health'), headers: _cabeceras).timeout(const Duration(seconds: 3));
      disponible = r.statusCode == 200;
      if (disponible) {
        final m = await http.get(_u('/v1/models'), headers: _cabeceras).timeout(const Duration(seconds: 3));
        final datos = jsonDecode(m.body) as Map<String, dynamic>;
        final lista = (datos['data'] ?? datos['models'] ?? []) as List;
        modelo = lista.isEmpty ? '' : ((lista.first as Map)['id'] ?? (lista.first as Map)['model'] ?? '').toString();
      }
    } catch (_) {
      disponible = false;
    }
    return disponible;
  }

  /// Genera con streaming. [alToken] recibe cada trozo apenas llega (Android); en web llega todo junto.
  Future<String> completar(String prompt,
      {int maxTokens = 300, double temperatura = 0, List<String> stop = const [], void Function(String)? alToken}) async {
    final cuerpo = jsonEncode({
      'prompt': prompt,
      'n_predict': maxTokens,
      'temperature': temperatura,
      'cache_prompt': true, // reutiliza el prompt de sistema: cada análisis solo procesa el correo nuevo
      'stream': true,
      if (stop.isNotEmpty) 'stop': stop,
    });
    final cliente = http.Client();
    final salida = StringBuffer();
    try {
      final req = http.Request('POST', _u('/completion'))
        ..headers.addAll(_cabeceras)
        ..body = cuerpo;
      final resp = await cliente.send(req).timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) throw Exception('servidor ${resp.statusCode}');
      var pendiente = '';
      await for (final trozo in resp.stream.transform(utf8.decoder).timeout(const Duration(seconds: 60))) {
        pendiente += trozo;
        final lineas = pendiente.split('\n');
        pendiente = lineas.removeLast();
        for (final l in lineas) {
          if (!l.startsWith('data:')) continue;
          final dato = l.substring(5).trim();
          if (dato.isEmpty || dato == '[DONE]') continue;
          final j = jsonDecode(dato) as Map<String, dynamic>;
          final t = (j['content'] ?? '') as String;
          if (t.isNotEmpty) {
            salida.write(t);
            alToken?.call(t);
          }
        }
      }
      return salida.toString();
    } finally {
      cliente.close();
    }
  }
}
