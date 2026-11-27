// Cerebro local: LFM2 (GGUF) ejecutado por llama.cpp vía el canal nativo "aiess/llm".
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analisis/motor.dart';
import 'remoto.dart';

class ModeloDescargable {
  const ModeloDescargable(this.nombre, this.archivo, this.url, this.mb);
  final String nombre, archivo, url;
  final int mb;
}

const modelosBase = [
  ModeloDescargable('Ligero (celulares básicos)', 'LFM2-350M-Q4_K_M.gguf',
      'https://huggingface.co/LiquidAI/LFM2-350M-GGUF/resolve/main/LFM2-350M-Q4_K_M.gguf', 229),
  ModeloDescargable('Completo (más inteligente)', 'LFM2-1.2B-Q4_K_M.gguf',
      'https://huggingface.co/LiquidAI/LFM2-1.2B-GGUF/resolve/main/LFM2-1.2B-Q4_K_M.gguf', 731),
];

class Cerebro {
  Cerebro._();
  static final i = Cerebro._();
  static const _m = MethodChannel('aiess/llm');
  static const _tokens = EventChannel('aiess/llm/tokens');

  String? ruta;
  /// Listo = hay servidor de IA disponible (modo principal) o un modelo local cargado (respaldo).
  bool get listo => ServidorIA.i.disponible || ruta != null;
  /// true mientras el modelo se carga en memoria (la UI muestra "Despertando al robot…").
  final cargando = ValueNotifier(false);

  /// Solo el modelo afinado con el dataset del IESS (archivo "aiess-*.gguf") decide veredictos.
  /// Un LFM2 base se usa para conversar; el veredicto lo dan las reglas OSINT.
  bool get afinado => ServidorIA.i.afinado || (ruta != null && ruta!.split(Platform.pathSeparator).last.toLowerCase().startsWith('aiess'));

  Future<Directory> _dir() async {
    final d = Directory('${(await getApplicationSupportDirectory()).path}/modelos');
    return d.create(recursive: true);
  }

  /// Modelos en la carpeta privada y en Android/data/ec.aiess.aiess/files/modelos (ahí se copian por USB).
  /// El modelo entrenado para el IESS (aiess-*.gguf) va primero.
  Future<List<File>> disponibles() async {
    final carpetas = <Directory>[await _dir()];
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) carpetas.add(await Directory('${ext.path}/modelos').create(recursive: true));
    } catch (_) {}
    final lista = <File>[
      for (final d in carpetas) ..._ggufEn(d),
    ];
    lista.sort((a, b) => (b.path.split('/').last.startsWith('aiess') ? 1 : 0) - (a.path.split('/').last.startsWith('aiess') ? 1 : 0));
    return lista;
  }

  List<File> _ggufEn(Directory d) {
    try {
      return d.listSync().whereType<File>().where((f) => f.path.endsWith('.gguf') && f.lengthSync() > 1000000).toList();
    } catch (_) {
      return const []; // sin permiso o carpeta inexistente: se ignora
    }
  }

  /// Carga el último modelo usado (o el primero disponible). No falla si no hay ninguno.
  Future<bool> iniciar() async {
    // Modo principal: IA en el servidor de AIESS (el celular no carga el modelo de 730 MB).
    await ServidorIA.i.cargarAjustes();
    cargando.value = true;
    final remoto = await ServidorIA.i.comprobar();
    cargando.value = false;
    if (remoto) return true;
    final prefs = await SharedPreferences.getInstance();
    final lista = await disponibles();
    if (lista.isEmpty) return false;
    final guardado = prefs.getString('modelo');
    final aiess = lista.where((f) => f.path.split('/').last.startsWith('aiess'));
    final elegido = aiess.isNotEmpty ? aiess.first : lista.firstWhere((f) => f.path == guardado, orElse: () => lista.first);
    return cargar(elegido.path);
  }

  Future<bool> cargar(String path) async {
    cargando.value = true;
    try {
      final ok = await _m.invokeMethod<bool>('cargar', {'ruta': path, 'nCtx': 2048}) ?? false;
      if (ok) {
        ruta = path;
        (await SharedPreferences.getInstance()).setString('modelo', path);
        await _calentar();
      }
      return ok;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    } finally {
      cargando.value = false;
    }
  }

  Future<String> generar(String prompt,
      {String prefijo = '', int maxTokens = 400, double temperatura = 0.0, List<String> stop = const [], void Function(String)? alToken}) async {
    if (ServidorIA.i.disponible) {
      try {
        return await ServidorIA.i.completar(prompt, maxTokens: maxTokens, temperatura: temperatura, stop: stop, alToken: alToken);
      } catch (_) {
        ServidorIA.i.disponible = false; // sin conexión: sigue con el modelo local si existe, o con las reglas
        if (ruta == null) return '';
      }
    }
    StreamSubscription? sub;
    if (alToken != null) sub = _tokens.receiveBroadcastStream().listen((t) => alToken(t as String));
    try {
      return await _m.invokeMethod<String>('generar', {'prompt': prompt, 'prefijo': prefijo, 'maxTokens': maxTokens, 'temperatura': temperatura}) ?? '';
    } finally {
      await sub?.cancel();
    }
  }

  /// Procesa el prompt de sistema una vez para dejarlo en caché: el primer análisis ya sale rápido.
  Future<void> _calentar() async {
    final pre = prefijoLfm2(systemPrompt());
    await generar(formatoLfm2(systemPrompt(), [('user', 'hola')]), prefijo: pre, maxTokens: 1);
  }

  Future<void> detener() => _m.invokeMethod('detener');

  /// Descarga con progreso (0..1). El archivo queda en el almacenamiento privado de la app.
  Stream<double> descargar(ModeloDescargable m) async* {
    final destino = File('${(await _dir()).path}/${m.archivo}');
    final tmp = File('${destino.path}.parcial');
    final resp = await http.Client().send(http.Request('GET', Uri.parse(m.url)));
    if (resp.statusCode != 200) throw HttpException('No se pudo descargar (${resp.statusCode})');
    final total = resp.contentLength ?? m.mb * 1000000;
    var recibido = 0;
    final out = tmp.openWrite();
    await for (final chunk in resp.stream) {
      out.add(chunk);
      recibido += chunk.length;
      yield recibido / total;
    }
    await out.close();
    await tmp.rename(destino.path);
    await cargar(destino.path);
    yield 1;
  }

  Future<bool> importar(String origen) async {
    final nombre = origen.split(RegExp(r'[\\/]')).last;
    final destino = File('${(await _dir()).path}/$nombre');
    await File(origen).copy(destino.path);
    return cargar(destino.path);
  }
}
