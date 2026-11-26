import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final catalogo = [
    actividad('t2-larga', tipologia: Tipologia.t2, duracion: 120),
    actividad('t2-corta', tipologia: Tipologia.t2, duracion: 60),
    actividad('t3-ex1', modulo: 'M5', tipologia: Tipologia.t3),
  ];

  ResultadoVerificacion rojo(Tipologia? t) => ResultadoVerificacion(
    estado: 'PHISHING_CONFIRMADO',
    semaforo: Semaforo.rojo,
    motivo: '',
    tipologiaSuplantada: t,
  );

  test('elige la tipología suplantada, pendiente y más corta', () {
    final a = actividadParaVerificacion(
      resultado: rojo(Tipologia.t2),
      actividades: catalogo,
      perfil: const Perfil(),
      progreso: const Progreso().marcarCompletada('t2-corta'),
    );
    expect(a?.id, 't2-larga');
  });

  test('solo ofrece lo que le corresponde al tipo', () {
    // M5 es para EX1, EX2 y EX4: un EX5 no lo ve.
    final a = actividadParaVerificacion(
      resultado: rojo(Tipologia.t3),
      actividades: catalogo,
      perfil: const Perfil(),
      progreso: const Progreso(),
    );
    expect(a, isNull);
  });

  test('en verde usa la tipología de los metadatos', () {
    final a = actividadParaVerificacion(
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
      actividades: catalogo,
      perfil: const Perfil(tipos: {TipoUsuario.ex1}),
      progreso: const Progreso(),
    );
    expect(a?.id, 't3-ex1');
  });
}
