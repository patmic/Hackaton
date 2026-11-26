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
  const ex1 = Perfil(tipos: {TipoUsuario.ex1});

  final catalogo = [
    actividad('m1', tipologia: Tipologia.t1),
    actividad('m2', modulo: 'M2', mecanica: Mecanica.a6, tipologia: null),
    actividad('m3', modulo: 'M3', mecanica: Mecanica.a3, tipologia: null),
    actividad(
      'm4-t2',
      modulo: 'M4',
      mecanica: Mecanica.a2,
      tipologia: Tipologia.t2,
    ),
    actividad('m5-t3', modulo: 'M5', tipologia: Tipologia.t3),
    actividad(
      'm7-ex2',
      modulo: 'M7',
      mecanica: Mecanica.a7,
      tipologia: Tipologia.t2,
    ),
  ];

  List<String> ids(List<Recomendacion> r) =>
      r.map((e) => e.actividad.id).toList();

  test('sigue la ruta de arranque del tipo en orden', () {
    final r = motor.recomendar(
      actividades: catalogo,
      perfil: ex1,
      progreso: const Progreso(),
    );
    expect(ids(r), ['m1', 'm2', 'm3']);
    expect(r.first.motivos.first, 'Paso 1 de tu ruta de inicio');
  });

  test('al completar un paso sube el siguiente', () {
    final r = motor.recomendar(
      actividades: catalogo,
      perfil: ex1,
      progreso: const Progreso().marcarCompletada('m1'),
    );
    expect(ids(r).first, 'm2');
    expect(ids(r), isNot(contains('m1')));
  });

  test('la alerta del Observatorio pone primero su tipología', () {
    final r = motor.recomendar(
      actividades: catalogo,
      perfil: ex1.conRango(RangoEtario.r65mas),
      progreso: const Progreso(),
      alertas: [alertaT2Mayores],
    );
    expect(r.first.actividad.id, 'm4-t2');
    expect(r.first.alerta, alertaT2Mayores);
    expect(r.first.motivos.first, contains('Alerta activa'));
  });

  test('la alerta de otro rango no aplica', () {
    final r = motor.recomendar(
      actividades: catalogo,
      perfil: ex1.conRango(RangoEtario.r18a29),
      progreso: const Progreso(),
      alertas: [alertaT2Mayores],
      limite: 10,
    );
    expect(r.every((e) => e.alerta == null), isTrue);
  });

  test('el ataque activo define el refuerzo de EX1', () {
    const alertaT3 = AlertaObservatorio(
      id: 'a2',
      tipologia: Tipologia.t3,
      mensaje: 'Campaña T3',
    );
    final r = motor.recomendar(
      actividades: catalogo,
      perfil: ex1,
      progreso: const Progreso(),
      alertas: [alertaT3],
      limite: 10,
    );
    final m5 = r.firstWhere((e) => e.actividad.id == 'm5-t3');
    expect(m5.alerta, alertaT3);
    expect(m5.motivos, contains('Refuerzo para tu perfil'));
    final m4 = r.firstWhere((e) => e.actividad.id == 'm4-t2');
    expect(m4.motivos, isNot(contains('Refuerzo para tu perfil')));
  });

  test('solo recomienda lo que le corresponde al tipo', () {
    final r = motor.recomendar(
      actividades: catalogo,
      perfil: ex1,
      progreso: const Progreso(),
      limite: 10,
    );
    expect(ids(r), isNot(contains('m7-ex2')));

    // Ruta de EX2: M1 → M7.
    final ex2 = motor.recomendar(
      actividades: catalogo,
      perfil: const Perfil(tipos: {TipoUsuario.ex2}),
      progreso: const Progreso(),
      limite: 10,
    );
    expect(ids(ex2).take(2).toList(), ['m1', 'm7-ex2']);

    // Sin sesión (EX5): M2, M4, M5 y M7 no son para su tipo.
    final ex5 = motor.recomendar(
      actividades: catalogo,
      perfil: const Perfil(),
      progreso: const Progreso(),
      limite: 10,
    );
    expect(ids(ex5), ['m1', 'm3']);
  });

  test('un EX2 recibe la variante en audio en lugar de la original', () {
    final conVariante = [
      actividad('m1-a1', tipologia: Tipologia.t2, varianteEx2: 'm1-a7'),
      actividad(
        'm1-a7',
        mecanica: Mecanica.a7,
        tipologia: Tipologia.t2,
        tipos: const {TipoUsuario.ex2},
      ),
    ];
    final r = motor.recomendar(
      actividades: conVariante,
      perfil: const Perfil(tipos: {TipoUsuario.ex2}),
      progreso: const Progreso(),
    );
    expect(ids(r), ['m1-a7']);
  });

  test('las completadas bajan; las de bajo puntaje se repasan', () {
    final progreso = const Progreso()
        .marcarCompletada('m2')
        .registrarPuntaje('m1', .2);
    final r = motor.recomendar(
      actividades: catalogo,
      perfil: ex1,
      progreso: progreso,
      limite: 10,
    );
    final repaso = r.firstWhere((e) => e.actividad.id == 'm1');
    expect(repaso.motivos, contains('Te conviene repasarla'));
    expect(ids(r).indexOf('m2'), greaterThan(ids(r).indexOf('m3')));
  });

  test('respeta el límite con el catálogo real', () {
    final r = motor.recomendar(
      actividades: catalogoReal(),
      perfil: const Perfil(),
      progreso: const Progreso(),
      limite: 2,
    );
    expect(r, hasLength(2));
  });
}
