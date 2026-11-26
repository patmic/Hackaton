/// Código de verificación que el Proxy SMTP inyecta en el correo (Hash 2 del
/// diagrama: hash del contenido completo). Son 64 caracteres hexadecimales.
abstract final class CodigoVerificacion {
  static final _formato = RegExp(r'^[0-9a-f]{64}$');
  static final _espacios = RegExp(r'\s');

  /// Quita espacios y pasa a minúsculas. Devuelve null si no tiene el
  /// formato de un código del IESS.
  static String? normalizar(String? texto) {
    if (texto == null) return null;
    final limpio = texto.replaceAll(_espacios, '').toLowerCase();
    return _formato.hasMatch(limpio) ? limpio : null;
  }
}

/// Enlace con el que el botón «Verificar en App» del correo abre la app
/// con el Hash 2 (paso 6 del diagrama).
///
/// Mitigación del Fallo 1: la app solo acepta su propio dominio verificado
/// (Android App Links con `autoVerify`, iOS Universal Links). Cualquier otro
/// enlace se rechaza, y la verificación ocurre siempre dentro de la app,
/// nunca en una página web.
abstract final class EnlaceVerificacion {
  /// [PROPUESTO] Dominio oficial para los App Links. El IESS debe publicar
  /// `/.well-known/assetlinks.json` y `apple-app-site-association` en él.
  static const hostOficial = 'app.iess.gob.ec';

  /// Esquema propio solo para desarrollo: otra app instalada podría
  /// registrar el mismo esquema, así que no sirve en producción.
  static const esquemaDesarrollo = 'iessverifica';

  static const segmento = 'verificar';

  /// Si [enlace] es un enlace de verificación aceptado: la ruta que entrega
  /// Flutter (`/verificar/<codigo>`), el App Link oficial o el esquema de
  /// desarrollo. No valida el código: ver [codigoDesde].
  static bool esEnlaceDeVerificacion(String? enlace) =>
      _segmentos(enlace) != null;

  /// El código tal como viene en el enlace, sin validar. Null si [enlace] no
  /// es un enlace de verificación aceptado.
  static String? codigoDesde(String? enlace) => _segmentos(enlace)?[1];

  /// El Hash 2 normalizado. Null si el enlace no se acepta o si el código no
  /// tiene el formato correcto.
  static String? hashDesde(String? enlace) =>
      CodigoVerificacion.normalizar(codigoDesde(enlace));

  /// Ruta interna de la app para un código.
  static String ruta(String codigo) => '/$segmento/$codigo';

  /// App Link oficial que el Proxy SMTP pone en el botón del correo.
  static Uri enlaceOficial(String codigo) =>
      Uri(scheme: 'https', host: hostOficial, path: ruta(codigo));

  static List<String>? _segmentos(String? enlace) {
    if (enlace == null) return null;
    final uri = Uri.tryParse(enlace.trim());
    if (uri == null) return null;

    final List<String> partes;
    if (!uri.hasScheme && uri.host.isEmpty) {
      partes = uri.pathSegments;
    } else if (uri.scheme == 'https' && uri.host == hostOficial) {
      partes = uri.pathSegments;
    } else if (uri.scheme == esquemaDesarrollo) {
      // iessverifica://verificar/<codigo>: «verificar» queda como host.
      partes = [uri.host, ...uri.pathSegments];
    } else {
      return null;
    }

    final segmentos = partes.where((s) => s.isNotEmpty).toList();
    if (segmentos.length != 2 || segmentos.first != segmento) return null;
    return segmentos;
  }
}
