/// Retroalimentación de una respuesta. El tono es formativo, nunca punitivo:
/// el castigo reduce el reporte (ver 07 Evidencia científica).
class Retroalimentacion {
  const Retroalimentacion({
    required this.preguntaId,
    required this.acerto,
    required this.respondioEstafa,
    required this.mensaje,
    required this.explicacion,
    this.senalesClave = const [],
  });

  final String preguntaId;
  final bool acerto;
  final bool respondioEstafa;
  final String mensaje;
  final String explicacion;
  final List<String> senalesClave;
}

/// Resultado de completar el quiz de una cápsula.
class ResultadoQuiz {
  const ResultadoQuiz({
    required this.capsulaId,
    required this.retroalimentaciones,
  });

  final String capsulaId;
  final List<Retroalimentacion> retroalimentaciones;

  int get total => retroalimentaciones.length;
  int get aciertos => retroalimentaciones.where((r) => r.acerto).length;

  /// 0.0 a 1.0.
  double get puntaje => total == 0 ? 0 : aciertos / total;

  /// Estafas que el usuario creyó reales: el error más peligroso.
  int get estafasNoDetectadas =>
      retroalimentaciones.where((r) => !r.acerto && !r.respondioEstafa).length;
}
