import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final lista = [
    capsula('a', tipologia: Tipologia.t1),
    capsula('b', tipologia: Tipologia.t2, rangos: [RangoEtario.r65mas]),
    capsula('c', tipologia: Tipologia.t2, formato: FormatoCapsula.audio),
  ];

  test('sin filtros devuelve todo', () {
    expect(const FiltroCapsulas().aplicar(lista), hasLength(3));
    expect(const FiltroCapsulas().estaVacio, isTrue);
  });

  test('combina tipología, rango y formato', () {
    expect(
      const FiltroCapsulas(tipologia: Tipologia.t2)
          .aplicar(lista)
          .map((c) => c.id),
      ['b', 'c'],
    );
    expect(
      const FiltroCapsulas(rango: RangoEtario.r18a29)
          .aplicar(lista)
          .map((c) => c.id),
      ['a', 'c'],
    );
    expect(
      const FiltroCapsulas(
        tipologia: Tipologia.t2,
        formato: FormatoCapsula.audio,
      ).aplicar(lista).map((c) => c.id),
      ['c'],
    );
  });

  test('solo pendientes excluye completadas', () {
    final p = const Progreso().marcarCompletada('a');
    expect(
      const FiltroCapsulas(soloPendientes: true)
          .aplicar(lista, p)
          .map((c) => c.id),
      ['b', 'c'],
    );
  });

  test('copyWith permite volver a null', () {
    const f = FiltroCapsulas(tipologia: Tipologia.t1);
    expect(f.copyWith(tipologia: () => null).tipologia, isNull);
    expect(f.copyWith(soloPendientes: true).tipologia, Tipologia.t1);
  });
}
