import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const motor = MotorRecomendacion();
  const alertaT2Mayores = AlertaObservatorio(
    id: 'a1',
    tipologia: Tipologia.t2,
    rangoEtario: RangoEtario.r65mas,
    incrementoPorcentaje: 40,
    mensaje: 'Aumento T2 en 65+',
  );

  final catalogo = [
    capsula('t1-general'),
    capsula(
      't2-mayores-audio',
      tipologia: Tipologia.t2,
      rangos: [RangoEtario.r65mas],
      formato: FormatoCapsula.audio,
    ),
    capsula(
      't2-jovenes',
      tipologia: Tipologia.t2,
      rangos: [RangoEtario.r18a29],
    ),
    capsula(
      't3-mayores',
      tipologia: Tipologia.t3,
      rangos: [RangoEtario.r65mas],
    ),
  ];

  List<String> ids(List<Recomendacion> r) =>
      r.map((e) => e.capsula.id).toList();

  test('la alerta del Observatorio pone primero su tipología', () {
    final r = motor.recomendar(
      capsulas: catalogo,
      perfil: const Perfil(rangoEtario: RangoEtario.r65mas),
      progreso: const Progreso(),
      alertas: [alertaT2Mayores],
    );
    expect(r.first.capsula.id, 't2-mayores-audio');
    expect(r.first.alerta, alertaT2Mayores);
    expect(r.first.motivos.first, contains('Alerta activa'));
  });

  test('con rango conocido no sugiere cápsulas de otros rangos', () {
    final r = motor.recomendar(
      capsulas: catalogo,
      perfil: const Perfil(rangoEtario: RangoEtario.r65mas),
      progreso: const Progreso(),
      limite: 10,
    );
    expect(ids(r), isNot(contains('t2-jovenes')));
  });

  test('la alerta de otro rango no aplica', () {
    final r = motor.recomendar(
      capsulas: catalogo,
      perfil: const Perfil(rangoEtario: RangoEtario.r18a29),
      progreso: const Progreso(),
      alertas: [alertaT2Mayores],
      limite: 10,
    );
    expect(r.every((e) => e.alerta == null), isTrue);
  });

  test('perfil anónimo recibe todas, prioriza alertas y generales', () {
    final r = motor.recomendar(
      capsulas: catalogo,
      perfil: const Perfil(),
      progreso: const Progreso(),
      alertas: [alertaT2Mayores],
      limite: 10,
    );
    expect(r, hasLength(4));
    expect(ids(r).take(2).toSet(), {'t2-mayores-audio', 't2-jovenes'});
    expect(ids(r)[2], 't1-general');
  });

  test(
    'las completadas bajan o desaparecen; las de bajo puntaje se repasan',
    () {
      final progreso = const Progreso()
          .marcarCompletada('t1-general')
          .registrarPuntaje('t3-mayores', .2);
      final r = motor.recomendar(
        capsulas: catalogo,
        perfil: const Perfil(rangoEtario: RangoEtario.r65mas),
        progreso: progreso,
        limite: 10,
      );
      expect(ids(r), isNot(contains('t1-general')));
      final repaso = r.firstWhere((e) => e.capsula.id == 't3-mayores');
      expect(repaso.motivos, contains('Te conviene repasarla'));
    },
  );

  test('respeta el límite', () {
    final r = motor.recomendar(
      capsulas: catalogoReal(),
      perfil: const Perfil(),
      progreso: const Progreso(),
      limite: 2,
    );
    expect(r, hasLength(2));
  });
}
