// Web: sin OCR local (ML Kit es solo Android/iOS). Misma API que lector_imagen.dart.
class LecturaImagen {
  const LecturaImagen(this.texto);
  final String texto;
  bool get vacia => texto.trim().isEmpty;
  String paraAnalizar() => texto.trim();
}

class LectorImagen {
  static Future<LecturaImagen> leer(String ruta) async => const LecturaImagen('');
}
