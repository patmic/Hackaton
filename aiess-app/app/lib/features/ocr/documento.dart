// Lectura de documentos subidos (PDF o imagen). En la web el OCR corre en el navegador (ocr_aiess.js);
// en el celular se usa el lector de imágenes con ML Kit (lector_imagen.dart).
export 'documento_io.dart' if (dart.library.js_interop) 'documento_web.dart';
