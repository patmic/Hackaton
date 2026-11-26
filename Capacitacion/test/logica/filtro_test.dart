import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final lista = [
    actividad('a', tipologia: Tipologia.t1),
    actividad(
      'b',
      modulo: 'M4',
      mecanica: Mecanica.a2,
      tipologia: Tipologia.t2,
    ),
    actividad('c', modulo: 'M3', mecanica: Mecanica.a3, tipologia: null),
  ];

  List<String> ids(List<Actividad> l) => l.map((a) => a.id).toList();

  test('sin filtros devuelve todo', () {
    expect(const FiltroActividades().aplicar(lista), hasLength(3));
    expect(const FiltroActividades().estaVacio, isTrue);
  });

  test('combina tipología, módulo y mecánica', () {
    expect(
      ids(const FiltroActividades(tipologia: Tipologia.t2).aplicar(lista)),
      ['b'],
    );
    expect(ids(const FiltroActividades(modulo: 'M3').aplicar(lista)), ['c']);
    expect(
      ids(const FiltroActividades(mecanica: Mecanica.a1).aplicar(lista)),
      ['a'],
    );
  });

  test('con perfil deja solo lo que le corresponde', () {
    // M4 es para EX1 y EX2: un EX5 no lo ve.
    expect(ids(const FiltroActividades().aplicar(lista, perfil: const Perfil())), [
      'a',
      'c',
    ]);
  });

  test('solo pendientes excluye completadas', () {
    final p = const Progreso().marcarCompletada('a');
    expect(
      ids(const FiltroActividades(soloPendientes: true).aplicar(lista, progreso: p)),
      ['b', 'c'],
    );
  });

  test('copyWith permite volver a null', () {
    const f = FiltroActividades(tipologia: Tipologia.t1, modulo: 'M1');
    expect(f.copyWith(tipologia: () => null).tipologia, isNull);
    expect(f.copyWith(modulo: () => null).modulo, isNull);
    expect(f.copyWith(soloPendientes: true).tipologia, Tipologia.t1);
  });
}
