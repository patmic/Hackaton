import 'correo_ejemplo.dart';

/// Ejercicio de inoculación: el usuario decide si el correo es real o estafa.
class PreguntaQuiz {
  const PreguntaQuiz({
    required this.id,
    required this.correo,
    required this.esEstafa,
    required this.explicacion,
    this.senalesClave = const [],
  });

  factory PreguntaQuiz.fromJson(Map<String, dynamic> json) => PreguntaQuiz(
    id: json['id'] as String,
    correo: CorreoEjemplo.fromJson(json['correo'] as Map<String, dynamic>),
    esEstafa: json['es_estafa'] as bool,
    explicacion: json['explicacion'] as String,
    senalesClave: (json['senales_clave'] as List<dynamic>? ?? const [])
        .cast<String>(),
  );

  final String id;
  final CorreoEjemplo correo;
  final bool esEstafa;

  /// Por qué es real o estafa. Se muestra siempre, acierte o no.
  final String explicacion;

  /// Señales concretas que el usuario debía notar.
  final List<String> senalesClave;
}
