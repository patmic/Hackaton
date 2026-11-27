import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final ruta = [
    actividad('M1-a', modulo: 'M1'),
    actividad('M1-b', modulo: 'M1'),
    actividad('M3-a', modulo: 'M3'),
  ];

  ResumenInsignias calcular({
    Progreso progreso = const Progreso(),
    EstadoCapacitacion? capacitacion,
    Perfil? perfil,
    List<Actividad>? actividades,
  }) => Insignias.calcular(
    actividades: actividades ?? ruta,
    progreso: progreso,
    capacitacion: capacitacion,
    perfil: perfil,
  );

  Insignia buscar(ResumenInsignias r, String id) =>
      r.todas.firstWhere((i) => i.id == id);

  test('sin progreso no hay insignias ganadas, pero se ve cuánto falta', () {
    final r = calcular();
    expect(r.ganadas, isEmpty);
    expect(r.nuevas, isEmpty);

    final m1 = buscar(r, Insignias.deModulo('M1'));
    expect(m1.esDeModulo, isTrue);
    expect(m1.avance, 0);
    expect(m1.meta, 2);
    expect(m1.fraccion, 0);

    // Una insignia por módulo de la ruta, en el orden del catálogo, después
    // de los logros.
    expect(r.todas.where((i) => i.esDeModulo).map((i) => i.modulo), [
      'M1',
      'M3',
    ]);
    expect(r.todas.first.esDeModulo, isFalse);
    // Con 3 lecciones en la ruta, «Constancia» (5) repetiría «Ruta completa».
    expect(r.todas.map((i) => i.id), isNot(contains(Insignias.constancia)));
  });

  test('terminar lecciones da «Primer paso», el módulo y la ruta', () {
    final una = const Progreso().marcarCompletada('M1-a');
    var r = calcular(progreso: una);
    expect(r.nuevas.map((i) => i.id), [Insignias.primerPaso]);
    expect(buscar(r, Insignias.deModulo('M1')).avance, 1);
    expect(buscar(r, Insignias.deModulo('M1')).fraccion, .5);

    final todas = una.marcarCompletada('M1-b').marcarCompletada('M3-a');
    r = calcular(progreso: todas);
    expect(
      r.nuevas.map((i) => i.id),
      unorderedEquals([
        Insignias.primerPaso,
        Insignias.rutaCompleta,
        Insignias.deModulo('M1'),
        Insignias.deModulo('M3'),
      ]),
    );
  });

  test('«Constancia» se ofrece si la ruta tiene más de 5 lecciones', () {
    final larga = [for (var i = 0; i < 6; i++) actividad('M1-$i')];
    var p = const Progreso();
    for (var i = 0; i < 4; i++) {
      p = p.marcarCompletada('M1-$i');
    }
    var constancia = buscar(
      calcular(actividades: larga, progreso: p),
      Insignias.constancia,
    );
    expect(constancia.ganada, isFalse);
    expect(constancia.avance, 4);

    constancia = buscar(
      calcular(actividades: larga, progreso: p.marcarCompletada('M1-4')),
      Insignias.constancia,
    );
    expect(constancia.ganada, isTrue);
  });

  test('acertar todos los casos de una práctica da «Ojo de lince»', () {
    final casi = calcular(
      progreso: const Progreso().registrarPuntaje('M1-a', .8),
    );
    expect(buscar(casi, Insignias.ojoDeLince).ganada, isFalse);

    final todo = calcular(
      progreso: const Progreso().registrarPuntaje('M1-a', 1),
    );
    expect(buscar(todo, Insignias.ojoDeLince).ganada, isTrue);
  });

  test('«Quiero capacitarme»: inscribirse, reportar y llegar a Centinela', () {
    var r = calcular(
      capacitacion: const EstadoCapacitacion(
        fase: FaseCapacitacion.esperandoReaccion,
      ),
    );
    expect(buscar(r, Insignias.meCapacito).ganada, isTrue);
    expect(buscar(r, Insignias.detective).ganada, isFalse);

    // Reportó un correo de nivel 3: el indicio queda dominado.
    r = calcular(
      capacitacion: const EstadoCapacitacion(
        fase: FaseCapacitacion.enCurso,
        mapa: MapaIndicios({Indicio.i1: EstadoIndicio.dominado}),
        reportesSeguidosNivel3: 1,
      ),
    );
    expect(buscar(r, Insignias.detective).ganada, isTrue);
    final centinela = buscar(r, Insignias.centinela);
    expect(centinela.ganada, isFalse);
    expect(centinela.avance, 1);
    expect(centinela.meta, 2);

    r = calcular(
      capacitacion: const EstadoCapacitacion(
        fase: FaseCapacitacion.enCurso,
        esCentinela: true,
      ),
    );
    expect(buscar(r, Insignias.centinela).ganada, isTrue);
  });

  test('hacer clic en un correo de práctica no da «Detective»', () {
    final r = calcular(
      capacitacion: const EstadoCapacitacion(
        fase: FaseCapacitacion.enCurso,
        mapa: MapaIndicios({Indicio.i1: EstadoIndicio.debil}),
      ),
    );
    expect(buscar(r, Insignias.detective).ganada, isFalse);
  });

  test('el perfil Centinela de la sesión también da la insignia', () {
    final r = calcular(
      perfil: const Perfil(
        tipos: {TipoUsuario.ex1},
        perfilConducta: PerfilConducta.centinela,
      ),
    );
    expect(buscar(r, Insignias.centinela).ganada, isTrue);
  });

  test('una insignia guardada deja de ser nueva y no se pierde', () {
    // «Me capacito» se ganó antes y la persona salió de la capacitación.
    final p = const Progreso()
        .marcarCompletada('M1-a')
        .otorgarInsignias({Insignias.primerPaso, Insignias.meCapacito});
    final r = calcular(progreso: p);
    expect(buscar(r, Insignias.meCapacito).ganada, isTrue);
    expect(buscar(r, Insignias.meCapacito).fraccion, 1);
    expect(buscar(r, Insignias.primerPaso).nueva, isFalse);
    expect(r.nuevas, isEmpty);
  });

  test('el progreso guarda las insignias en JSON', () {
    final p = const Progreso()
        .marcarCompletada('x')
        .otorgarInsignias({Insignias.primerPaso})
        .registrarPuntaje('y', .5);
    final copia = Progreso.fromJson(p.toJson());
    expect(copia.insignias, {Insignias.primerPaso});
    expect(copia.completadas, {'x', 'y'});
    // Un progreso guardado antes de las insignias se sigue leyendo.
    expect(Progreso.fromJson(const {'completadas': ['x']}).insignias, isEmpty);
  });
}
