import 'dart:typed_data';

/// En Android/iOS los archivos se leen con [LectorImagen] (ML Kit) desde su ruta.
class LectorDocumento {
  static bool get disponible => false;
  static Future<String> leer(Uint8List bytes, String nombre) async => '';
}
