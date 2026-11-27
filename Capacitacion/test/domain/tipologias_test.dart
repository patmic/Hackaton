import 'dart:convert';
import 'dart:io';

import 'package:capacitacion/src/data/tipologia_repository.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const rutaAsset = 'assets/data/tipologias.json';
  const rutaOriginal = '../tipologias-correo/tipologias.json';

  final texto = File(rutaAsset).readAsStringSync();
  final json = jsonDecode(texto) as Map<String, dynamic>;
  final catalogo = parsearTipologias(texto);

  test('la copia del asset es igual a tipologias-correo/tipologias.json', () {
    final original = File(rutaOriginal);
    expect(
      original.existsSync(),
      isTrue,
      reason: 'Las pruebas se corren desde Capacitacion/',
    );
    expect(
      jsonDecode(original.readAsStringSync()),
      json,
      reason:
          'Si cambió el original, cópialo: '
          'cp ../tipologias-correo/tipologias.json assets/data/',
    );
  });

  test('el enum tiene las mismas tipologías y nombres que el JSON', () {
    final delJson = {
      for (final t in json['tipologias'] as List<dynamic>)
        (t as Map<String, dynamic>)['id'] as String: t['nombre'] as String,
    };
    expect({for (final t in Tipologia.values) t.codigo: t.nombre}, delJson);
  });

  test('cada tipología tiene ficha, cápsula e indicios válidos', () {
    expect(catalogo.version, '1.0');
    expect(catalogo.fichas.keys.toSet(), Tipologia.values.toSet());
    for (final f in catalogo.fichas.values) {
      expect(f.capsula, isNotEmpty, reason: f.tipologia.codigo);
      expect(f.nuncaTrae, isNotEmpty, reason: f.tipologia.codigo);
      expect(f.suplantacionFrecuente, isNotEmpty, reason: f.tipologia.codigo);
    }
    expect(catalogo.textoFijoSello, contains('nunca le pedirá claves'));
    expect(catalogo.formatoCodigoSello, 'IESS-XXXX-XXXX');
  });

  test('adjuntos permitidos y cápsula por defecto', () {
    expect(catalogo.ficha(Tipologia.t2)!.permiteAdjunto('PDF'), isTrue);
    expect(catalogo.ficha(Tipologia.t1)!.permiteAdjunto('pdf'), isFalse);
    expect(catalogo.ficha(Tipologia.t6)!.permiteAdjunto('zip'), isFalse);
    expect(catalogo.capsulaDe(Tipologia.t4), contains('código QR'));
    expect(catalogo.capsulaDe(null), contains('nunca le pide'));
  });

  test('códigos: EXT no es una tipología', () {
    expect(Tipologia.desdeCodigo('t6'), Tipologia.t6);
    expect(Tipologia.tryDesdeCodigo('EXT'), isNull);
    expect(() => Tipologia.desdeCodigo('EXT'), throwsFormatException);
    expect(Tipologia.t6.esInterna, isTrue);
  });

  test('cada tipología tiene un módulo que la trabaja', () {
    for (final t in Tipologia.values) {
      expect(
        () => Modulo.porCodigo(Ruta.moduloPorTipologia(t)),
        returnsNormally,
        reason: t.codigo,
      );
    }
    expect(Ruta.moduloPorTipologia(Tipologia.t4), 'M5');
    expect(Ruta.moduloPorTipologia(Tipologia.t6), 'M11');
  });

  test('el catálogo de actividades entrena cada tipología', () {
    final porTipologia = {
      for (final a in catalogoReal())
        if (a.tipologia != null) a.tipologia!,
    };
    expect(porTipologia, Tipologia.values.toSet());
  });
}
