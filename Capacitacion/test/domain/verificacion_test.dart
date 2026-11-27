import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('CodigoVerificacion', () {
    test('normaliza espacios y mayúsculas', () {
      final conEspacios =
          ' ${hashValido.substring(0, 32).toUpperCase()} '
          '${hashValido.substring(32)}\n';
      expect(CodigoVerificacion.normalizar(conEspacios), hashValido);
    });

    test('rechaza lo que no es un código del IESS', () {
      expect(CodigoVerificacion.normalizar(null), isNull);
      expect(CodigoVerificacion.normalizar('abc'), isNull);
      expect(CodigoVerificacion.normalizar('g' * 64), isNull);
      expect(CodigoVerificacion.normalizar('a' * 65), isNull);
    });
  });

  group('EnlaceVerificacion (App Link, Fallo 1)', () {
    test(
      'acepta la ruta de Flutter, el dominio oficial y el de desarrollo',
      () {
        expect(
          EnlaceVerificacion.hashDesde('/verificar/$hashValido'),
          hashValido,
        );
        expect(
          EnlaceVerificacion.hashDesde(
            'https://app.iess.gob.ec/verificar/$hashValido',
          ),
          hashValido,
        );
        expect(
          EnlaceVerificacion.hashDesde('iessverifica://verificar/$hashValido'),
          hashValido,
        );
        expect(
          EnlaceVerificacion.hashDesde('/verificar/$hashValido/'),
          hashValido,
        );
      },
    );

    test('rechaza otros dominios, http y rutas distintas', () {
      for (final enlace in [
        'https://app.iess.gob.ec.otro.com/verificar/$hashValido',
        'https://iess-verifica.com/verificar/$hashValido',
        'http://app.iess.gob.ec/verificar/$hashValido',
        '/verificar',
        '/',
        '/otra/$hashValido',
        '/verificar/$hashValido/extra',
        hashValido,
        null,
      ]) {
        expect(
          EnlaceVerificacion.esEnlaceDeVerificacion(enlace),
          isFalse,
          reason: '$enlace',
        );
      }
    });

    test('un enlace aceptado con código mal formado no da hash', () {
      expect(
        EnlaceVerificacion.esEnlaceDeVerificacion('/verificar/abc'),
        isTrue,
      );
      expect(EnlaceVerificacion.codigoDesde('/verificar/abc'), 'abc');
      expect(EnlaceVerificacion.hashDesde('/verificar/abc'), isNull);
    });

    test('arma el enlace oficial que va en el botón del correo', () {
      expect(
        EnlaceVerificacion.enlaceOficial(hashValido).toString(),
        'https://app.iess.gob.ec/verificar/$hashValido',
      );
      expect(
        EnlaceVerificacion.hashDesde(
          EnlaceVerificacion.enlaceOficial(hashValido).toString(),
        ),
        hashValido,
      );
    });
  });

  group('SolicitudVerificacion.uriDiagrama', () {
    test('arma GET /verificar/{hash_2} con datos anónimos', () {
      const s = SolicitudVerificacion(
        canal: CanalVerificacion.app,
        hashRecibido: hashValido,
        rangoEtario: RangoEtario.r65mas,
        origen: OrigenCodigo.appLink,
      );
      final uri = s.uriDiagrama(Uri.parse('https://nucleo.ejemplo/api/'));
      expect(uri.path, '/api/verificar/$hashValido');
      expect(uri.queryParameters, {
        'canal': 'APP_MOVIL',
        'origen': 'APP_LINK',
        'rango_etario': '65+',
      });
    });

    test('sin hash no se puede armar', () {
      const s = SolicitudVerificacion(canal: CanalVerificacion.app);
      expect(
        () => s.uriDiagrama(Uri.parse('https://nucleo.ejemplo')),
        throwsStateError,
      );
    });
  });

  test('marcarComoCopiado pasa a ROJO y conserva los datos sellados', () {
    final verde = ResultadoVerificacion(
      estado: 'LEGITIMO',
      semaforo: Semaforo.verde,
      motivo: '',
      metadatosOficiales: MetadatosOficiales(
        emisorNombre: 'Dirección de Prestaciones y Pensiones',
        tipologia: Tipologia.t2,
        fecha: DateTime.utc(2026, 11, 26),
      ),
    );
    expect(verde.esAutentico, isTrue);
    final copiado = verde.marcarComoCopiado();
    expect(copiado.semaforo, Semaforo.rojo);
    expect(copiado.estado, 'SELLO_COPIADO');
    expect(copiado.esAutentico, isFalse);
    expect(copiado.tipologiaSuplantada, Tipologia.t2);
    expect(copiado.metadatosOficiales, same(verde.metadatosOficiales));
  });

  test('POST /api/v1/verify sigue soportado por fromJson', () {
    final r = ResultadoVerificacion.fromJson({
      'estado': 'PHISHING_CONFIRMADO',
      'semaforo': 'ROJO',
      'motivo': 'x',
      'metadatos_oficiales': null,
      'tipologia_suplantada': 'T2',
      'capsula_educativa': 'y',
    });
    expect(r.semaforo, Semaforo.rojo);
    expect(r.tipologiaSuplantada, Tipologia.t2);
    expect(r.analisis, isNull);
  });
}
