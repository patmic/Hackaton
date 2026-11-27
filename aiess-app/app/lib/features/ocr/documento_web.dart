import 'dart:js_interop';
import 'dart:typed_data';

@JS('aiessLeerImagen')
external JSPromise<JSString> _leerImagen(JSUint8Array bytes);

@JS('aiessLeerPdf')
external JSPromise<JSString> _leerPdf(JSUint8Array bytes);

/// OCR en el navegador: el PDF o la imagen nunca se envían a un servidor.
class LectorDocumento {
  static bool get disponible => true;

  static Future<String> leer(Uint8List bytes, String nombre) async {
    final js = bytes.toJS;
    final esPdf = nombre.toLowerCase().endsWith('.pdf');
    final r = await (esPdf ? _leerPdf(js) : _leerImagen(js)).toDart;
    return r.toDart.trim();
  }
}
