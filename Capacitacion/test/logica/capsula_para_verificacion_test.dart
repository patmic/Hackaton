import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final catalogo = [
    capsula('t2-larga', tipologia: Tipologia.t2, duracion: 120),
    capsula('t2-corta', tipologia: Tipologia.t2, duracion: 60),
    capsula('t3', tipologia: Tipologia.t3, rangos: [RangoEtario.r65mas]),
  ];

  ResultadoVerificacion rojo(Tipologia? t) => ResultadoVerificacion(
    estado: 'PHISHING_CONFIRMADO',
    semaforo: Semaforo.rojo,
    motivo: '',
    tipologiaSuplantada: t,
  );

  test('elige la tipología suplantada, pendiente y más corta', () {
    final c = capsulaParaVerificacion(
      resultado: rojo(Tipologia.t2),
      capsulas: catalogo,
      perfil: const Perfil(),
      progreso: const Progreso().marcarCompletada('t2-corta'),
    );
    expect(c?.id, 't2-larga');
  });

  test('respeta el rango del usuario', () {
    final c = capsulaParaVerificacion(
      resultado: rojo(Tipologia.t3),
      capsulas: catalogo,
      perfil: const Perfil(rangoEtario: RangoEtario.r18a29),
      progreso: const Progreso(),
    );
    expect(c, isNull);
  });

  test('en verde usa la tipología de los metadatos', () {
    final c = capsulaParaVerificacion(
      resultado: ResultadoVerificacion(
        estado: 'LEGITIMO',
        semaforo: Semaforo.verde,
        motivo: '',
        metadatosOficiales: MetadatosOficiales(
          emisorNombre: 'x',
          tipologia: Tipologia.t3,
          asuntoResumen: 'y',
          fecha: DateTime.utc(2026),
        ),
      ),
      capsulas: catalogo,
      perfil: const Perfil(),
      progreso: const Progreso(),
    );
    expect(c?.id, 't3');
  });
}
