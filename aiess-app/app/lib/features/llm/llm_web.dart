// Versión web del "cerebro": en el navegador no hay llama.cpp nativo, así que el veredicto lo dan
// las reglas OSINT (misma API que llm.dart para que el resto de la app no cambie).
import 'package:flutter/foundation.dart';

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
  bool get listo => false;
  bool get afinado => false;
  final cargando = ValueNotifier(false);

  Future<bool> iniciar() async => false;
  Future<bool> cargar(String path) async => false;
  Future<String> generar(String prompt,
          {String prefijo = '', int maxTokens = 400, double temperatura = 0.0, void Function(String)? alToken}) async =>
      '';
  Future<void> detener() async {}
  Stream<double> descargar(ModeloDescargable m) => const Stream.empty();
  Future<bool> importar(String origen) async => false;
}
