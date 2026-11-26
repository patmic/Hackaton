import 'package:capacitacion/src/data/nucleo_api.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hashValido =
      '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4';
  const hashRevocado =
      '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b';

  final api = MockNucleoApi(reloj: () => DateTime.utc(2026, 11, 27));

  Future<ResultadoVerificacion> verificar({String? hash, String? remitente}) =>
      api.verificar(
        SolicitudVerificacion(
          canal: CanalVerificacion.app,
          hashRecibido: hash,
          remitenteReportado: remitente,
        ),
      );

  test('sello auténtico devuelve VERDE con metadatos sellados', () async {
    final r = await verificar(hash: hashValido.toUpperCase());
    expect(r.semaforo, Semaforo.verde);
    expect(
      r.metadatosOficiales?.emisorNombre,
      'Dirección de Prestaciones y Pensiones',
    );
    expect(r.metadatosOficiales?.tipologia, Tipologia.t2);
    expect(r.capsulaEducativa, contains('ESTAFA'));
  });

  test('dominio en Black List es ROJO aunque traiga un hash válido', () async {
    final r = await verificar(
      hash: hashValido,
      remitente: 'reembolsos@iess-tramites-ec.com',
    );
    expect(r.semaforo, Semaforo.rojo);
    expect(r.estado, 'PHISHING_CONFIRMADO');
    expect(r.tipologiaSuplantada, Tipologia.t2);
  });

  test('sello revocado es ROJO', () async {
    final r = await verificar(hash: hashRevocado);
    expect(r.semaforo, Semaforo.rojo);
    expect(r.estado, 'SELLO_REVOCADO');
  });

  test('sello vencido es AMARILLO', () async {
    final tarde = MockNucleoApi(reloj: () => DateTime.utc(2027, 2));
    final r = await tarde.verificar(
      const SolicitudVerificacion(
        canal: CanalVerificacion.app,
        hashRecibido: hashValido,
      ),
    );
    expect(r.semaforo, Semaforo.amarillo);
    expect(r.estado, 'SELLO_VENCIDO');
  });

  test('hash inexistente es ROJO y mal formado es AMARILLO', () async {
    expect((await verificar(hash: 'a' * 64)).estado, 'SELLO_INEXISTENTE');
    expect((await verificar(hash: 'abc')).estado, 'CODIGO_INVALIDO');
  });

  test('remitente oficial sin sello es AMARILLO', () async {
    final r = await verificar(remitente: 'notificaciones@iess.gob.ec');
    expect(r.semaforo, Semaforo.amarillo);
    expect(r.estado, 'SIN_SELLO');
  });

  test('extraerDominio', () {
    expect(MockNucleoApi.extraerDominio('A@Biess-EC.net '), 'biess-ec.net');
    expect(
      MockNucleoApi.extraerDominio('https://www.iess-agenda.com/x?y=1'),
      'iess-agenda.com',
    );
    expect(MockNucleoApi.extraerDominio('  '), isNull);
  });

  test('alertas de demostración', () async {
    final a = await api.alertasActivas();
    expect(a.single.tipologia, Tipologia.t2);
    expect(a.single.afectaA(RangoEtario.r65mas), isTrue);
    expect(a.single.afectaA(RangoEtario.r18a29), isFalse);
  });
}
