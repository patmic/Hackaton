// Versión web del "cerebro": en el navegador no hay llama.cpp nativo, así que el veredicto lo dan
// las reglas OSINT (misma API que llm.dart para que el resto de la app no cambie).
import 'package:flutter/foundation.dart';

import 'remoto.dart';

class ModeloDescargable {
  const ModeloDescargable(this.nombre, this.archivo, this.url, this.mb);
  final String nombre, archivo, url;
  final int mb;
}

const modelosBase = <ModeloDescargable>[];

class Cerebro {
  Cerebro._();
  static final i = Cerebro._();

  String? ruta;
  bool get listo => ServidorIA.i.disponible;
  bool get afinado => ServidorIA.i.afinado;
  final cargando = ValueNotifier(false);

  /// En web la IA siempre es la del servidor (por defecto, el mismo que publica esta página).
  Future<bool> iniciar() async {
    await ServidorIA.i.cargarAjustes();
    cargando.value = true;
    final ok = await ServidorIA.i.comprobar();
    cargando.value = false;
    return ok;
  }
  Future<bool> cargar(String path) async => false;
  Future<String> generar(String prompt,
      {String prefijo = '', int maxTokens = 400, double temperatura = 0.0, List<String> stop = const [], void Function(String)? alToken}) async {
    if (!ServidorIA.i.disponible) return '';
    try {
      return await ServidorIA.i.completar(prompt, maxTokens: maxTokens, temperatura: temperatura, stop: stop, alToken: alToken);
    } catch (_) {
      ServidorIA.i.disponible = false;
      return '';
    }
  }
  Future<void> detener() async {}
  Stream<double> descargar(ModeloDescargable m) => const Stream.empty();
  Future<bool> importar(String origen) async => false;
}
