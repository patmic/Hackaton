import 'dart:convert';

import 'package:aiess/features/sello/sello.dart';
import 'package:aiess/ui/tema.dart';
import 'package:aiess/ui/web_escritorio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

const _codigo = 'AbCdEfGhIjKlMnOp_q-1.0123456789abcdef';

void main() {
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
      expect(pedido, startsWith('$oficial/api/v1/asunto?asunto='));
      final v = Sello.veredictoPorAsunto(r);
      expect(v.phishing, isFalse);
      expect(v.resumen, 'Phishing: NO · firma válida del IESS');
      expect(v.voz, contains('selló'));
    });
    test('asunto sin sello: estafa al instante', () async {
      final c = MockClient(
        (_) async => http.Response(
          jsonEncode({'sellado': false, 'motivo': 'sin_sello', 'mensaje': '-'}),
          200,
        ),
      );
      final v = Sello.veredictoPorAsunto(
        await Sello.porAsunto('IESS: pensión suspendida', cliente: c, servidorOficial: oficial),
      );
      expect(v.phishing, isTrue);
      expect(v.resumen, 'Phishing: SÍ · sin sello del IESS');
    });
    test('sin conexión: no se confía (sello sin comprobar)', () async {
      final c = MockClient((_) async => throw Exception('sin red'));
      final v = Sello.veredictoPorAsunto(
        await Sello.porAsunto('IESS: aviso', cliente: c, servidorOficial: oficial),
      );
      expect(v.phishing, isTrue);
      expect(v.resumen, 'Phishing: SÍ · sello sin comprobar');
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

  testWidgets('web: sin sello es estafa al instante; sin un «Sí», la IA no lee el correo', (t) async {
    t.view.physicalSize = const Size(1366, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: temaAIess(),
        home: const MediaQuery(
          data: MediaQueryData(size: Size(1366, 768), disableAnimations: true),
          child: WebEscritorio(),
        ),
      ),
    );
    await t.pump(const Duration(milliseconds: 300));
    await t.enterText(
      find.byType(TextField),
      'Estimado afiliado: su pensión será suspendida HOY. Actualice su clave en http://iess-pagos.net/login',
    );
    await t.tap(find.text('Revisar con AIess'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('¿Revisar con la IA?'), findsOneWidget);
    await t.tap(find.text('No, gracias'));
    await t.pump(const Duration(milliseconds: 300));
    // Regla del sello: sin sello válido se descarta de inmediato, aunque la IA no lo haya leído.
    expect(find.textContaining('sin sello del IESS'), findsOneWidget);
    expect(find.textContaining('indicio'), findsNothing);
  });
}