import 'dart:convert';

import 'package:aiess/core/canales.dart';
import 'package:aiess/features/sello/sello.dart';
import 'package:aiess/ui/aula_virtual.dart';
import 'package:aiess/ui/tema.dart';
import 'package:aiess/ui/web_escritorio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

const _codigo = 'AbCdEfGhIjKlMnOp_q-1.0123456789abcdef';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(Canales.cargar);
  group('Aviso: el robot verifica el sello solo con el asunto', () {
    const oficial = 'https://sella.ejemplo.ec';
    test('asunto sellado: del IESS, con el buzón para comparar', () async {
      String? pedido;
      final c = MockClient((r) async {
        pedido = r.url.toString();
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'sellado': true,
              'motivo': 'valido',
              'mensaje': 'El IESS selló un correo con este asunto.',
              'buzon': 'comunicacion@iess.gob.ec',
            }),
          ),
          200,
        );
      });
      final r = await Sello.porAsunto(
        'IESS: Actualización de datos',
        cliente: c,
        servidorOficial: oficial,
      );
      // Privacidad: sale solo la huella del asunto, nunca su texto.
      expect(
        pedido,
        '$oficial/api/v1/asunto?huella=${Sello.huellaAsunto('IESS: Actualización de datos')}',
      );
      expect(pedido, isNot(contains('Actualizaci')));
      final v = Sello.veredictoPorAsunto(r, 'IESS: Actualización de datos');
      expect(v.phishing, isFalse);
      expect(v.resumen, 'Phishing: NO · firma válida del IESS');
      expect(v.voz, contains('selló'));
    });
    test(
      'asunto sin sello: lo deciden los indicios del asunto, y avisa del sello',
      () async {
        final c = MockClient(
          (_) async => http.Response(
            jsonEncode({
              'sellado': false,
              'motivo': 'sin_sello',
              'mensaje': '-',
            }),
            200,
          ),
        );
        const asunto =
            'IESS: actualice su clave hoy o su pensión será suspendida';
        final v = Sello.veredictoPorAsunto(
          await Sello.porAsunto(asunto, cliente: c, servidorOficial: oficial),
          asunto,
        );
        expect(v.phishing, isTrue);
        expect(v.resumen, 'Phishing: SÍ · ${v.indicios.length} indicios');
        expect(v.indicios, containsAll(['I3', 'I8']));
        expect(v.avisoSello, contains('no trae el sello'));
        // Asunto sin señales: no se dice «seguro», se pide revisar el correo completo.
        final neutro = Sello.veredictoPorAsunto(
          await Sello.porAsunto(
            'IESS: Boletín de diciembre',
            cliente: c,
            servidorOficial: oficial,
          ),
          'IESS: Boletín de diciembre',
        );
        expect(neutro.phishing, isFalse);
        expect(neutro.sinConfirmar, isTrue);
        expect(neutro.voz, isNot(contains('Tranquilo')));
      },
    );
    test('sin conexión: no se confía (sello sin comprobar)', () async {
      final c = MockClient((_) async => throw Exception('sin red'));
      final v = Sello.veredictoPorAsunto(
        await Sello.porAsunto(
          'IESS: aviso',
          cliente: c,
          servidorOficial: oficial,
        ),
        'IESS: aviso',
      );
      expect(v.selloEstado, 'sin_verificar');
      expect(v.avisoSello, contains('pude comprobar'));
    });
  });

  group('Sello del IESS', () {
    test('encuentra el enlace del sello en el texto del correo', () {
      expect(
        Sello.codigoEn(
          'Verifique: https://sella.ejemplo.ec/checkin/$_codigo gracias',
        ),
        _codigo,
      );
      expect(Sello.codigoEn('/checkin/$_codigo'), _codigo);
      expect(
        Sello.codigoEn('IESS: actualice su clave en http://iess-pagos.net'),
        isNull,
      );
    });

    test('firma válida: la respuesta del verificador oficial', () async {
      final cliente = MockClient((r) async {
        expect(r.url.path, '/api/v1/verificar/$_codigo');
        return http.Response(
          jsonEncode({
            'valido': true,
            'motivo': 'valido',
            'mensaje': 'ok',
            'emisor': 'Dirección',
            'asunto': 'Boletín',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final r = await Sello.verificar(
        '/checkin/$_codigo',
        cliente: cliente,
        servidorOficial: 'https://sella.ejemplo.ec',
      );
      expect(r.valido, isTrue);
      expect(r.datos['asunto'], 'Boletín');
    });

    test('huella alterada: falso', () async {
      final cliente = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'valido': false,
            'motivo': 'hash_distinto',
            'mensaje': 'alterado',
          }),
          200,
        ),
      );
      final r = await Sello.verificar(
        '/checkin/$_codigo',
        cliente: cliente,
        servidorOficial: 'https://sella.ejemplo.ec',
      );
      expect(r.valido, isFalse);
      expect(r.sinRespuesta, isFalse);
    });

    test('enlace a un verificador ajeno: falso sin preguntarle', () async {
      var llamado = false;
      final cliente = MockClient((_) async {
        llamado = true;
        return http.Response(jsonEncode({'valido': true}), 200);
      });
      final r = await Sello.verificar(
        'https://iess-verifica.xyz/checkin/$_codigo',
        cliente: cliente,
        servidorOficial: 'https://sella.ejemplo.ec',
      );
      expect(r.valido, isFalse);
      expect(r.motivo, 'dominio_ajeno');
      expect(llamado, isFalse);
    });

    test(
      'sin internet: "no pude comprobarlo", no se marca como falso',
      () async {
        final cliente = MockClient((_) async => throw Exception('sin red'));
        final r = await Sello.verificar(
          '/checkin/$_codigo',
          cliente: cliente,
          servidorOficial: 'https://sella.ejemplo.ec',
        );
        expect(r.valido, isFalse);
        expect(r.sinRespuesta, isTrue);
      },
    );
  });

  group('Privacidad: solo asuntos del IESS activan el aviso', () {
    test('asuntos del IESS', () {
      for (final a in [
        'IESS: su aporte de noviembre',
        'Notificación del Instituto Ecuatoriano de Seguridad Social',
        'Pensión jubilar de diciembre',
        'Préstamo quirografario BIESS aprobado',
        'Turno médico confirmado',
        'Su afiliación fue actualizada',
      ]) {
        expect(asuntoDelIess(a), isTrue, reason: a);
      }
    });
    test('el resto de correos se ignora', () {
      for (final a in [
        'Tu pedido de Amazon',
        'Reunión del lunes',
        'Factura de luz',
        'Oferta de vuelos',
        'Hola!',
      ]) {
        expect(asuntoDelIess(a), isFalse, reason: a);
      }
    });
  });

  testWidgets('web: sin sello es estafa al instante; la IA solo con su botón', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues({'observatorio': false});
    // Sin plugins de voz en la prueba: el robot «habla» en silencio.
    for (final canal in [
      'flutter_tts',
      'plugin.csdcorp.com/speech_to_text',
      'com.ryanheise.just_audio.methods',
    ]) {
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        MethodChannel(canal),
        (_) async => null,
      );
    }
    t.view.physicalSize = const Size(1366, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: overridesAula,
        child: MaterialApp(
          theme: temaAIess(),
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(1366, 768),
              disableAnimations: true,
            ),
            child: WebEscritorio(),
          ),
        ),
      ),
    );
    await t.pump(const Duration(milliseconds: 300));
    await t.enterText(
      find.byType(TextField),
      'Estimado afiliado: su pensión será suspendida HOY. Actualice su clave en http://iess-pagos.net/login',
    );
    await t.tap(find.text('Revisar con Leo'));
    // El análisis por indicios consulta fuentes públicas (en la prueba no hay red): se espera a que termine.
    await t.runAsync(() => Future.delayed(const Duration(milliseconds: 800)));
    for (var i = 0; i < 10; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    // Sin diálogos: el veredicto sale al instante y la IA queda en un botón que la persona decide tocar.
    expect(find.text('¿Revisar con la IA?'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp('Revisar con la IA.*se borra')),
      findsOneWidget,
    );
    // Regla del sello: sin sello válido se descarta de inmediato, aunque la IA no lo haya leído.
    // Sin sello: Sí/No y cantidad por los indicios del catálogo (al instante, sin la IA) + aviso del sello.
    expect(find.textContaining('Phishing: SÍ ·'), findsOneWidget);
    expect(find.textContaining('no trae el sello del IESS'), findsWidgets);
  });
}
