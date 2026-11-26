import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const evaluador = EvaluadorQuiz();
  final estafa = pregunta('e', esEstafa: true);
  final real = pregunta('r', esEstafa: false);

  test('cuatro casos de respuesta con mensaje formativo', () {
    expect(evaluador.evaluar(estafa, respondioEstafa: true).acerto, isTrue);
    expect(evaluador.evaluar(real, respondioEstafa: false).acerto, isTrue);

    final coladaRetro = evaluador.evaluar(estafa, respondioEstafa: false);
    expect(coladaRetro.acerto, isFalse);
    expect(coladaRetro.mensaje, contains('señales'));

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

  test('resultado de una cápsula', () {
    final c = capsula('c', preguntas: [estafa, real]);
    final r = evaluador.evaluarCapsula(c, {'e': false, 'r': false});
    expect(r.total, 2);
    expect(r.aciertos, 1);
    expect(r.puntaje, .5);
    expect(r.estafasNoDetectadas, 1);
    expect(evaluador.mensajeFinal(r), contains('Repasa'));
  });

  test('preguntas sin responder no cuentan', () {
    final c = capsula('c', preguntas: [estafa, real]);
    final r = evaluador.evaluarCapsula(c, {'e': true});
    expect(r.total, 1);
    expect(r.puntaje, 1);
    expect(evaluador.mensajeFinal(r), contains('todos'));
  });
}
