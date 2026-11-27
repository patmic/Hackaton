import 'dart:convert';
import 'dart:io';

import 'package:capacitacion/src/data/observador_api.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Cliente del Radar Phishing con el contrato de
/// `Analisis-de-comportamiento/observador/api.py`.
void main() {
  final plan = File('../Analisis-de-comportamiento/contrato/plan.ejemplo.json')
      .readAsStringSync();

  test('usa las rutas del observador bajo /api/v1/observatorio', () async {
    final pedidos = <http.Request>[];
    final api = HttpObservadorApi(
      Uri.parse('https://sello.ejemplo/base/'),
      cliente: MockClient((r) async {
        pedidos.add(r);
        return r.method == 'GET'
            ? http.Response.bytes(utf8.encode(plan), 200)
            : http.Response('{"registradas": 1}', 201);
      }),
    );
    await api.registrar([
      {'id_seudonimo': 'x', 'tipo': 'VERIFICACION'},
    ]);
    final p = await api.plan(
      'a3f9c2e17b4d48e0b6c1',
      tipos: {TipoUsuario.in1, TipoUsuario.ex1},
      rangoEtario: RangoEtario.r65mas,
    );
    await api.borrar('a3f9c2e17b4d48e0b6c1');

    expect(pedidos.map((r) => '${r.method} ${r.url.path}'), [
      'POST /base/api/v1/observatorio/observaciones',
      'GET /base/api/v1/observatorio/personas/a3f9c2e17b4d48e0b6c1/plan',
      'DELETE /base/api/v1/observatorio/personas/a3f9c2e17b4d48e0b6c1',
    ]);
    expect(jsonDecode(pedidos.first.body), {
      'observaciones': [
        {'id_seudonimo': 'x', 'tipo': 'VERIFICACION'},
      ],
    });
    expect(pedidos[1].url.queryParameters, {
      'tipos': 'EX1,IN1',
      'rango': '65+',
    });
    expect(p.idSeudonimo, 'a3f9c2e17b4d48e0b6c1');
    expect(p.falencias, isNotEmpty);
  });

  test('envía en lotes de 200 (el observador es todo o nada)', () async {
    final tamanos = <int>[];
    final api = HttpObservadorApi(
      Uri.parse('http://localhost:8090'),
      cliente: MockClient((r) async {
        tamanos.add(
          ((jsonDecode(r.body) as Map)['observaciones'] as List).length,
        );
        return http.Response('{}', 201);
      }),
    );
    await api.registrar([
      for (var i = 0; i < 450; i++) {'i': i},
    ]);
    expect(tamanos, [200, 200, 50]);
  });

  test('un error del servidor o de red se informa sin romper la app', () async {
    Future<ObservadorNoDisponible> falla(MockClientHandler h) async {
      final api = HttpObservadorApi(
        Uri.parse('http://localhost:8090'),
        cliente: MockClient(h),
      );
      try {
        await api.registrar([{}]);
      } on ObservadorNoDisponible catch (e) {
        return e;
      }
      fail('debía fallar');
    }

    expect(
      (await falla((_) async => http.Response('', 422))).rechazado,
      isTrue,
    );
    expect(
      (await falla((_) async => http.Response('', 429))).rechazado,
      isFalse,
    );
    expect(
      (await falla((_) async => http.Response('', 503))).rechazado,
      isFalse,
    );
    expect(
      (await falla((_) async => throw const SocketException('sin red')))
          .rechazado,
      isFalse,
    );
  });

  test(
    'sin URL de compilación no hay servidor: todo queda en el dispositivo',
    () {
      expect(HttpObservadorApi.urlEntorno, isEmpty);
      expect(HttpObservadorApi.desdeEntorno(), isNull);
    },
  );

  test('el código del dispositivo cumple el formato del observador', () {
    final id = DatosObservador.nuevo().idSeudonimo;
    expect(id, matches(RegExp(r'^[A-Za-z0-9_-]{16,64}$')));
    expect(DatosObservador.nuevo().idSeudonimo, isNot(id));
  });

  test('guarda como máximo 500 y no reenvía lo ya enviado', () {
    var d = const DatosObservador(idSeudonimo: 'x', enviadas: 0);
    final o = ObservacionConducta.verificacion(
      semaforo: Semaforo.verde,
      momento: DateTime.utc(2026, 11, 27),
    );
    for (var i = 0; i < 499; i++) {
      d = d.con(o);
    }
    d = d.copyWith(enviadas: 499);
    d = d.con(o).con(o).con(o);
    expect(d.observaciones, hasLength(DatosObservador.maximo));
    expect(d.pendientes, hasLength(3));
    final otra = DatosObservador.fromJson(
      jsonDecode(jsonEncode(d.toJson())) as Map<String, dynamic>,
    );
    expect(otra.pendientes, hasLength(3));
    expect(otra.idSeudonimo, 'x');
  });
}
