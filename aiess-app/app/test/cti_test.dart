import 'dart:convert';

import 'package:aiess/core/canales.dart';
import 'package:aiess/features/osint/cti.dart';
import 'package:aiess/features/osint/url_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(Canales.cargar);
  tearDown(() => fijarListaOpenPhish(null));

  test(
    'RDAP: dominio recién creado suma riesgo; solo se envía el dominio',
    () async {
      final pedidos = <Uri>[];
      final hace3 = DateTime.now()
          .toUtc()
          .subtract(const Duration(days: 3))
          .toIso8601String();
      final cliente = MockClient((r) async {
        pedidos.add(r.url);
        if (r.url.host == 'rdap.org') {
          return http.Response(
            jsonEncode({
              'events': [
                {'eventAction': 'registration', 'eventDate': hace3},
              ],
            }),
            200,
          );
        }
        return http.Response('', 200); // lista OpenPhish vacía
      });
      final o = analizarMensaje(
        'Actualice su clave en http://iess-pagos.net/login?ced=1712345678',
      );
      await consultarCti(o, cliente: cliente);
      expect(o.cti.join(), contains('se creó hace'));
      expect(o.ctiPuntaje, greaterThanOrEqualTo(55));
      expect(o.indicios, contains('I2'));
      // A RDAP solo le llega el dominio (sin ruta, sin parámetros, sin la cédula).
      final rdap = pedidos.firstWhere((u) => u.host == 'rdap.org');
      expect(rdap.path, '/domain/iess-pagos.net');
      expect(rdap.query, isEmpty);
    },
  );

  test('OpenPhish: la lista se compara en el equipo', () async {
    fijarListaOpenPhish({'http://iess-pagos.net/login'});
    final cliente = MockClient(
      (r) async => http.Response('{}', 404),
    ); // RDAP sin datos
    final o = analizarMensaje('Ingrese en http://iess-pagos.net/login');
    await consultarCti(o, cliente: cliente);
    expect(o.cti.join(), contains('OpenPhish'));
    expect(o.ctiPuntaje, 95);
  });

  test('enlaces oficiales: no se consulta ninguna fuente', () async {
    var llamadas = 0;
    final cliente = MockClient((_) async {
      llamadas++;
      return http.Response('', 200);
    });
    final o = analizarMensaje('Revise su historial en https://www.iess.gob.ec');
    await consultarCti(o, cliente: cliente);
    expect(llamadas, 0);
    expect(o.cti, isEmpty);
  });
}
