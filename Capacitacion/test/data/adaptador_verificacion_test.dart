import 'package:capacitacion/src/data/adaptador_verificacion.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const adaptador = AdaptadorVerificacion();

  Map<String, dynamic> valida({String? remitente, String? fecha}) => {
    'valido': true,
    'remitente': remitente,
    'emisor_nombre': 'Dirección de Afiliación',
    'fecha': fecha,
    'tipologia': 'T1',
    'asunto_resumen': 'Boletín de noviembre',
  };

  group('GET /verificar/{hash_2} → semáforo', () {
    test('válido y completo: VERDE con los datos sellados', () {
      final r = adaptador.desdeRespuesta(
        valida(
          remitente: 'comunicacion@iess.gob.ec',
          fecha: '2026-11-20T10:00:00Z',
        ),
      );
      expect(r.semaforo, Semaforo.verde);
      expect(r.estado, 'LEGITIMO');
      expect(r.metadatosOficiales?.remitente, 'comunicacion@iess.gob.ec');
      expect(r.metadatosOficiales?.tipologia, Tipologia.t1);
      expect(r.metadatosOficiales?.fecha, DateTime.utc(2026, 11, 20, 10));
    });

    test('válido sin remitente o sin fecha nunca es VERDE (Fallo 2)', () {
      final sinRemitente = adaptador.desdeRespuesta(
        valida(fecha: '2026-11-20T10:00:00Z'),
      );
      final sinFecha = adaptador.desdeRespuesta(
        valida(remitente: 'comunicacion@iess.gob.ec'),
      );
      for (final r in [sinRemitente, sinFecha]) {
        expect(r.semaforo, Semaforo.amarillo);
        expect(r.estado, 'RESPUESTA_INCOMPLETA');
      }
    });

    test('sin emisor usa el remitente como emisor', () {
      final r = adaptador.desdeRespuesta({
        'valido': true,
        'remitente': 'notificaciones@iess.gob.ec',
        'fecha': '2026-11-20T10:00:00Z',
      });
      expect(r.metadatosOficiales?.emisorNombre, 'notificaciones@iess.gob.ec');
      expect(r.metadatosOficiales?.tipologia, isNull);
    });

    test('motivos de rechazo', () {
      ResultadoVerificacion conMotivo(String? motivo) =>
          adaptador.desdeRespuesta({'valido': false, 'motivo': motivo});

      expect(conMotivo('HASH_INEXISTENTE').estado, 'SELLO_INEXISTENTE');
      expect(conMotivo('HASH_INEXISTENTE').semaforo, Semaforo.rojo);
      expect(conMotivo('CONTENIDO_ALTERADO').estado, 'CORREO_ALTERADO');
      expect(conMotivo('revocado').estado, 'SELLO_REVOCADO');
      expect(conMotivo('VENCIDO').semaforo, Semaforo.amarillo);
      expect(conMotivo(null).semaforo, Semaforo.rojo);
    });

    test('respuesta sin «valido» es AMARILLO', () {
      final r = adaptador.desdeRespuesta({'motivo': 'x'});
      expect(r.semaforo, Semaforo.amarillo);
      expect(r.estado, 'NO_VERIFICABLE');
    });

    test('usa la tipología percibida si el servidor no la envía', () {
      final r = adaptador.desdeRespuesta({
        'valido': false,
      }, tipologiaPercibida: Tipologia.t3);
      expect(r.tipologiaSuplantada, Tipologia.t3);
    });

    test('lee el análisis de la IA e ignora indicios desconocidos', () {
      final r = adaptador.desdeRespuesta({
        'valido': false,
        'analisis_ia': {
          'nivel_riesgo': 'alto',
          'explicacion': 'Pide la clave con urgencia.',
          'indicios': ['I3', 'I99', 'I1'],
        },
      });
      expect(r.analisis?.nivel, NivelRiesgo.alto);
      expect(r.analisis?.explicacion, 'Pide la clave con urgencia.');
      expect(r.analisis?.indicios, [Indicio.i3, Indicio.i1]);
    });
  });

  test('casos locales nunca son VERDE', () {
    expect(adaptador.codigoInvalido().semaforo, Semaforo.amarillo);
    expect(adaptador.sinConexion().estado, 'SIN_CONEXION');
    expect(adaptador.sinCodigo().estado, 'SIN_SELLO');
  });
}
