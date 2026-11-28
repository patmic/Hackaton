// Rúbrica del jurado (Hackatón Código Confianza IESS 2026):
// - Problema: detecta los indicios y el avatar los explica (incluido el deepfake), qué te puede pasar y dónde reportar.
// - Funcionalidad: la cantidad de indicios coincide con la lista; Sí si hay al menos uno (catálogo, sección 1).
// - Seguridad: solo sale el dominio o una huella; al Observatorio, solo códigos anónimos.
import 'dart:convert';

import 'package:aiess/core/canales.dart';
import 'package:aiess/features/analisis/motor.dart';
import 'package:aiess/features/observatorio/observatorio.dart';
import 'package:aiess/features/osint/url_analyzer.dart';
import 'package:aiess/features/sello/sello.dart';
import 'package:aiess/ui/partes_correo.dart';
import 'package:aiess/ui/reporte_simulado.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(Canales.cargar);

  Veredicto reglas(String t) =>
      analizarConReglas(Entrada(t), analizarMensaje(t));

  test(
    'el avatar dice «Encontré N indicios», explica cada uno, el riesgo, el deepfake y dónde reportar',
    () {
      final v = reglas(
        'Estimado afiliado: su pensión será suspendida HOY. Ingrese su usuario y contraseña en '
        'http://iess-pagos.net/login y cancele una tasa de \$4,50.',
      );
      expect(v.phishing, isTrue);
      final n = v.indicios.length;
      expect(n, greaterThanOrEqualTo(3));
      expect(v.voz, startsWith('Encontré ${cantidadIndicios(n)}'));
      for (final k in v.indicios) {
        expect(v.voz, contains(motivoVoz[k]!), reason: 'explica $k');
      }
      expect(v.voz, contains('Si caes en el engaño'));
      expect(v.voz.toLowerCase(), contains('deepfake'));
      expect(v.locucion, contains('seguridad.informacion@iess.gob.ec'));
      expect(v.locucion, contains('denuncias.iess.gob.ec'));
      // La cantidad del resumen es la misma de la lista.
      expect(v.resumen, 'Phishing: SÍ · $n indicios');
    },
  );

  test(
    'correo legítimo sin sello: NO y 0 indicios (como el dataset); el sello va como aviso',
    () {
      final v = aplicarSello(
        reglas(
          'Estimado afiliado: le recordamos que puede revisar su historial de aportes en www.iess.gob.ec. '
          'Atentamente, IESS',
        ),
        estado: 'sin_sello',
      );
      expect(v.phishing, isFalse);
      expect(v.resumen, 'Phishing: NO · 0 indicios');
      expect(v.avisoSello, isNotNull);
      expect(v.sinConfirmar, isTrue);
    },
  );

  test('sello falso: SÍ, y suma el indicio del verificador ajeno', () {
    final v = aplicarSello(
      reglas('Estimado afiliado, revise su comunicado.'),
      estado: 'falso',
      verificadorAjeno: true,
    );
    expect(v.phishing, isTrue);
    expect(v.indicios, contains('I2'));
    final n = v.indicios.length;
    expect(
      v.resumen,
      'Phishing: SÍ · sello falso · $n ${n == 1 ? 'indicio' : 'indicios'}',
    );
  });

  test('firma válida con texto cambiado: la IA lo descubre', () {
    final ia = reglas('Actualice su clave hoy en http://iess-pagos.net');
    final v = aplicarSello(ia, estado: 'valido');
    expect(v.phishing, isTrue);
    expect(v.voz, contains('la firma del IESS es verdadera'));
  });

  test('solo indicios del catálogo, sin repetir', () {
    expect(
      indiciosValidos(['i3', 'I3', 'X9', 'I1']),
      ['I1', 'I3']..sort(
        (a, b) => motivoVoz.keys
            .toList()
            .indexOf(a)
            .compareTo(motivoVoz.keys.toList().indexOf(b)),
      ),
    );
  });

  test(
    'consulta por asunto: sale solo la huella SHA-256 del asunto normalizado',
    () {
      expect(
        Sello.huellaAsunto('RE:  Fwd: IESS:   Hola  Mundo '),
        sha256.convert(utf8.encode('iess: hola mundo')).toString(),
      );
    },
  );

  test('Observatorio: solo seudónimo, semáforo y códigos de indicios', () {
    final v = reglas(
      'Ingrese su contraseña hoy en http://iess-pagos.net/login',
    );
    final o = Observatorio.observacion(v, 'abcdefghijklmnop1234');
    expect(
      o.keys,
      unorderedEquals(['id_seudonimo', 'tipo', 'semaforo', 'indicios']),
    );
    expect(o['tipo'], 'VERIFICACION');
    expect(o['semaforo'], v.phishing ? 'ROJO' : 'VERDE');
    expect(
      (o['indicios'] as List).every((i) => RegExp(r'^I\d+$').hasMatch(i)),
      isTrue,
    );
    expect(jsonEncode(o), isNot(contains('iess-pagos')));
  });

  test(
    'partes del correo sin abrir nada: remitente, asunto, destino real de enlaces y adjuntos',
    () {
      final p = PartesCorreo.de(
        'De: avisos@iess-pagos.net\nAsunto: Su pensión\n\n'
        'Ingrese en www.iess.gob.ec [http://iess-pagos.net/login]\nAdjuntos: detalle.zip',
      );
      expect(p.remitente, 'avisos@iess-pagos.net');
      expect(p.asunto, 'Su pensión');
      final falso = p.enlaces.firstWhere((e) => e.$2.contains('iess-pagos'));
      expect(falso.$1, 'Ingrese en www.iess.gob.ec');
      expect(falso.$3, isFalse);
      expect(p.adjuntos, contains('detalle.zip'));
    },
  );

  test(
    'reporte SIMULADO: caso, indicios y dominio; nunca el texto ni datos personales (2.6)',
    () async {
      SharedPreferences.setMockInitialValues({});
      const correo =
          'De: avisos@iess-pagos.net\nAsunto: Hola Juan Pérez, cédula 1712345678\n\n'
          'Ingrese su contraseña en http://iess-pagos.net/login';
      final v = reglas(correo);
      final r = ReporteSimulado.preparar(
        v,
        correo,
        ahora: DateTime(2026, 11, 27),
      );
      expect(r.caso, matches(RegExp(r'^AIESS-20261127-[A-Z0-9]{4}$')));
      expect(r.destinatario, 'seguridad.informacion@iess.gob.ec');
      expect(r.dominios, contains('iess-pagos.net'));
      expect(r.asunto, isNot(contains('1712345678')));
      await r.guardar();
      final guardado = (await SharedPreferences.getInstance())
          .getStringList('reportes_simulados')!
          .join();
      expect(guardado, contains(r.caso));
      expect(guardado, isNot(contains('contraseña')));
      expect(guardado, isNot(contains('iess-pagos')));
    },
  );

  test(
    'un consejo de seguridad no es un indicio, pero una estafa con consejo sí se detecta',
    () {
      final legitimo = reglas(
        'Estimado afiliado: su afiliación quedó registrada. El IESS nunca le pedirá su clave por correo. '
        'Atentamente, IESS',
      );
      expect(legitimo.resumen, 'Phishing: NO · 0 indicios');
      expect(
        reglas(
          'No comparta su contraseña con nadie. Atentamente, IESS',
        ).phishing,
        isFalse,
      );
      expect(
        reglas(
          'De no hacerlo, su cuenta será suspendida. Ingrese su clave aquí.',
        ).indicios,
        contains('I3'),
      );
      expect(
        reglas(
          'El IESS nunca le pedirá su clave, por eso ingrese su clave aquí: http://iess-pagos.net',
        ).indicios,
        contains('I3'),
      );
    },
  );
}
