import 'package:capacitacion/src/data/nucleo_api.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final api = MockNucleoApi(reloj: () => DateTime.utc(2026, 11, 27));

  Future<ResultadoVerificacion> verificar(String? hash) => api.verificar(
    SolicitudVerificacion(canal: CanalVerificacion.app, hashRecibido: hash),
  );

  test('código auténtico: VERDE con remitente, fecha y asunto sellados', () async {
    final r = await verificar(hashValido.toUpperCase());
    expect(r.semaforo, Semaforo.verde);
    final m = r.metadatosOficiales!;
    expect(m.remitente, 'notificaciones@iess.gob.ec');
    expect(m.emisorNombre, 'Dirección de Prestaciones y Pensiones');
    expect(m.tipologia, Tipologia.t2);
    expect(m.asuntoResumen, 'Notificación de rol de pensión mensual');
    expect(m.fecha, DateTime.utc(2026, 11, 26, 15, 30));
    expect(r.capsulaEducativa, contains('ESTAFA'));
    expect(r.analisis?.nivel, NivelRiesgo.bajo);
  });

  test('código inexistente: ROJO con análisis e indicios', () async {
    final r = await verificar('a' * 64);
    expect(r.semaforo, Semaforo.rojo);
    expect(r.estado, 'SELLO_INEXISTENTE');
    expect(r.analisis?.indicios, [Indicio.i7, Indicio.i2]);
  });

  test('sello revocado: ROJO con la tipología del registro', () async {
    final r = await verificar(hashRevocado);
    expect(r.semaforo, Semaforo.rojo);
    expect(r.estado, 'SELLO_REVOCADO');
    expect(r.tipologiaSuplantada, Tipologia.t1);
  });

  test('sello vencido: AMARILLO', () async {
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

  test('sin código o mal formado: AMARILLO', () async {
    expect((await verificar(null)).estado, 'SIN_SELLO');
    expect((await verificar('abc')).estado, 'CODIGO_INVALIDO');
  });

  test('sin conexión lanza NucleoNoDisponible', () async {
    final caido = MockNucleoApi(sinConexion: true);
    await expectLater(
      caido.verificar(
        const SolicitudVerificacion(
          canal: CanalVerificacion.app,
          hashRecibido: hashValido,
        ),
      ),
      throwsA(isA<NucleoNoDisponible>()),
    );
  });

  test('alertas de demostración', () async {
    final a = await api.alertasActivas();
    expect(a.single.tipologia, Tipologia.t2);
    expect(a.single.afectaA(RangoEtario.r65mas), isTrue);
    expect(a.single.afectaA(RangoEtario.r18a29), isFalse);
  });
}
