// Verificación de enlaces en red (Android): HEAD sin seguir redirecciones ni enviar cookies.
import 'dart:io';

import '../osint/url_analyzer.dart';

/// Verificación en red (opcional, la activa el usuario): solo HEAD, sin seguir redirecciones ni enviar cookies.
Future<void> revisarRed(AnalisisOsint osint) async {
  for (final u in osint.urls.where((u) => !u.confiable).take(2)) {
    final cliente = HttpClient()
      ..connectionTimeout = const Duration(seconds: 4);
    var sslMalo = false;
    cliente.badCertificateCallback = (_, __, ___) {
      sslMalo = true;
      return false;
    };
    try {
      final (p, _) = partirUrl(u.url);
      final req = await cliente.headUrl(p!.replace(scheme: 'https'));
      req.followRedirects = false;
      final r = await req.close().timeout(const Duration(seconds: 5));
      final loc = r.headers.value(HttpHeaders.locationHeader);
      final destino = loc != null ? partirUrl(loc).$2 : '';
      osint.red.add(
        'Red: ${u.host} con certificado SSL válido; '
        '${destino.isNotEmpty && destino != u.host ? 'redirige a $destino' : 'sin redirecciones'}',
      );
    } catch (_) {
      osint.red.add(
        'Red: ${u.host} ${sslMalo ? 'con certificado no válido' : 'no responde o no tiene SSL'}',
      );
    } finally {
      cliente.close(force: true);
    }
  }
}
