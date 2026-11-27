// Prueba de oro (plan, tarea 1.8): los 5 correos de práctica del reto (recursos-base/P01–P05.eml) deben dar
// el mismo veredicto y EXACTAMENTE los mismos indicios que la clave de respuestas. Sin red: sin CTI.
import 'dart:io';

import 'package:aiess/core/canales.dart';
import 'package:aiess/features/analisis/motor.dart';
import 'package:aiess/features/correo/eml.dart';
import 'package:aiess/features/osint/url_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

const esperado = {
  'P01': (true, {'I2', 'I3', 'I4', 'I6', 'I7', 'I10'}),
  'P02': (false, <String>{}),
  'P03': (true, {'I2'}),
  'P04': (false, <String>{}),
  'P05': (true, {'I7', 'I9', 'I11'}),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(Canales.cargar);

  for (final MapEntry(key: id, value: (phishing, indicios))
      in esperado.entries) {
    test('$id: phishing=$phishing, indicios=$indicios', () {
      final c = leerEml(File('test/fixtures/$id.eml').readAsBytesSync());
      final v = analizarConReglas(
        Entrada(c.paraAnalizar, asunto: c.asunto, remitente: c.remitente),
        analizarMensaje(c.paraAnalizar, remitente: c.remitente),
      );
      // ignore: avoid_print
      print('$id → ${v.resumen} ${v.indicios}');
      expect(v.phishing, phishing);
      expect(v.indicios.toSet(), indicios);
    });
  }
}
