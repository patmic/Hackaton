import '../../domain/domain.dart';

/// Evalúa las respuestas del ejercicio "¿Real o estafa?".
///
/// Los mensajes son formativos: ninguno culpa al usuario. Confundir un
/// correo real con una estafa se trata como prudencia, no como error grave.
class EvaluadorQuiz {
  const EvaluadorQuiz();

  Retroalimentacion evaluar(
    PreguntaQuiz pregunta, {
    required bool respondioEstafa,
  }) {
    final acerto = respondioEstafa == pregunta.esEstafa;
    return Retroalimentacion(
      preguntaId: pregunta.id,
      acerto: acerto,
      respondioEstafa: respondioEstafa,
      mensaje: _mensaje(acerto: acerto, eraEstafa: pregunta.esEstafa),
      explicacion: pregunta.explicacion,
      senalesClave: pregunta.senalesClave,
    );
  }

  /// [respuestas]: id de pregunta → el usuario respondió "estafa".
  /// Las preguntas sin respuesta no se cuentan.
  ResultadoQuiz evaluarCapsula(Capsula capsula, Map<String, bool> respuestas) =>
      ResultadoQuiz(
        capsulaId: capsula.id,
        retroalimentaciones: [
          for (final p in capsula.preguntas)
            if (respuestas.containsKey(p.id))
              evaluar(p, respondioEstafa: respuestas[p.id]!),
        ],
      );

  static String _mensaje({required bool acerto, required bool eraEstafa}) {
    if (acerto && eraEstafa) return '¡Bien! Detectaste la estafa.';
    if (acerto) return 'Correcto: este correo es legítimo.';
    if (eraEstafa) {
      return 'Esta vez se coló una estafa. Fíjate en estas señales para la próxima.';
    }
    return 'Era legítimo, pero dudar está bien: verificar siempre es mejor que arriesgarse.';
  }

  /// Mensaje de cierre según el puntaje.
  String mensajeFinal(ResultadoQuiz resultado) {
    if (resultado.total == 0) return 'Sin respuestas todavía.';
    if (resultado.aciertos == resultado.total) {
      return 'Reconociste todos los casos. Comparte lo que aprendiste con tu familia.';
    }
    if (resultado.estafasNoDetectadas > 0) {
      return 'Repasa las señales: ante la duda, verifica en la app antes de hacer clic.';
    }
    return 'Vas bien. Recuerda: si dudas, verifica en la app oficial.';
  }
}
