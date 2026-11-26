import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const evaluador = EvaluadorRealOEstafa();
  final estafa = tarjeta('e', esEstafa: true);
  final real = tarjeta('r', esEstafa: false);

  test('cuatro casos de respuesta con mensaje formativo', () {
    expect(evaluador.evaluar(estafa, respondioEstafa: true).acerto, isTrue);
    expect(evaluador.evaluar(real, respondioEstafa: false).acerto, isTrue);

    final colada = evaluador.evaluar(estafa, respondioEstafa: false);
    expect(colada.acerto, isFalse);
    expect(colada.mensaje, contains('señales'));
    expect(colada.indicios, [Indicio.i7]);

    final prudente = evaluador.evaluar(real, respondioEstafa: true);
    expect(prudente.acerto, isFalse);
    expect(prudente.mensaje, contains('dudar está bien'));
  });

  test('la explicación se muestra siempre', () {
    expect(
      evaluador.evaluar(estafa, respondioEstafa: true).explicacion,
      'exp e',
    );
    expect(
      evaluador.evaluar(estafa, respondioEstafa: false).explicacion,
      'exp e',
    );
  });

  test('resultado de una ronda', () {
    final ronda = rondaA2('c', [estafa, real]);
    final r = evaluador.evaluarRonda(ronda, {'e': false, 'r': false});
    expect(r.actividadId, 'c');
    expect(r.total, 2);
    expect(r.aciertos, 1);
    expect(r.puntaje, .5);
    expect(r.estafasNoDetectadas, 1);
    expect(evaluador.mensajeFinal(r), contains('Repasa'));
  });

  test('tarjetas sin responder no cuentan', () {
    final ronda = rondaA2('c', [estafa, real]);
    final r = evaluador.evaluarRonda(ronda, {'e': true});
    expect(r.total, 1);
    expect(r.puntaje, 1);
    expect(evaluador.mensajeFinal(r), contains('todos'));
  });

  test('una actividad que no es A2 no tiene tarjetas', () {
    expect(EvaluadorRealOEstafa.tarjetasDe(actividad('x')), isEmpty);
  });

  test('las rondas A2 del catálogo real se pueden evaluar completas', () {
    for (final a in catalogoReal().where((a) => a.mecanica == Mecanica.a2)) {
      final tarjetas = EvaluadorRealOEstafa.tarjetasDe(a);
      final r = evaluador.evaluarRonda(a, {
        for (final t in tarjetas) t.id: t.esEstafa,
      });
      expect(r.puntaje, 1, reason: a.id);
    }
  });
}
