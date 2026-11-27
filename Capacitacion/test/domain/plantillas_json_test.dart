import 'dart:convert';
import 'dart:io';

import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// `plantillasPrueba` (Dart) es la fuente de verdad de los correos de prueba.
/// El observador (`Analisis-de-comportamiento`) y la API de Capacitación
/// (`backend/capacitacion`) leen la misma lista desde
/// `Analisis-de-comportamiento/datos/plantillas.json`.
///
/// Para regenerar el JSON después de cambiar las plantillas:
/// `flutter test test/domain/plantillas_json_test.dart --dart-define=ACTUALIZAR_PLANTILLAS=true`
void main() {
  const ruta = '../Analisis-de-comportamiento/datos/plantillas.json';
  const actualizar = bool.fromEnvironment('ACTUALIZAR_PLANTILLAS');

  Map<String, Object?> aJson(PlantillaCorreoPrueba p) => {
    'id': p.id,
    'nivel': p.nivel.numero,
    'tipologia': p.tipologiaSuplantada.codigo,
    'indicios': [for (final i in p.indicios) i.codigo],
    'indicios_implicitos': [
      for (final i in Indicio.values)
        if (p.indiciosImplicitos.contains(i)) i.codigo,
    ],
    'tipos': [
      for (final t in TipoUsuario.values)
        if (p.tipos.contains(t)) t.codigo,
    ],
    'es_primer_correo': p.esPrimerCorreo,
    'asunto': p.asunto,
    'nombre_remitente': p.nombreRemitente,
    'remitente': p.remitente,
    'cuerpo': p.cuerpo,
    'boton': p.boton,
    'adjunto': p.adjunto,
    'qr': p.tieneQr,
  };

  final esperado = {
    'fuente': 'Capacitacion/lib/src/domain/plantillas_prueba.dart',
    'dominio_practica': DominioPractica.dominio,
    'plantillas': [for (final p in plantillasPrueba) aJson(p)],
  };

  test('datos/plantillas.json está al día con plantillasPrueba', () {
    final archivo = File(ruta);
    final texto = '${const JsonEncoder.withIndent('  ').convert(esperado)}\n';
    if (actualizar) {
      archivo.writeAsStringSync(texto);
    }
    expect(archivo.existsSync(), isTrue, reason: 'Falta $ruta');
    expect(
      jsonDecode(archivo.readAsStringSync()),
      jsonDecode(texto),
      reason:
          'Cambiaste plantillas_prueba.dart: regenera el JSON con '
          '--dart-define=ACTUALIZAR_PLANTILLAS=true y avisa a backend/capacitacion.',
    );
  });
}
