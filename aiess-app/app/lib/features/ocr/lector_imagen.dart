// Lectura de capturas de pantalla en el celular (Google ML Kit, sin internet): texto por OCR.
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LecturaImagen {
  const LecturaImagen(this.texto);
  final String texto;

  bool get vacia => texto.trim().isEmpty;

  String paraAnalizar() => texto.trim();
}

class LectorImagen {
  static Future<LecturaImagen> leer(String ruta) async {
    final ocr = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final r = await ocr.processImage(InputImage.fromFilePath(ruta));
      return LecturaImagen(r.text);
    } finally {
      await ocr.close();
    }
  }
}
