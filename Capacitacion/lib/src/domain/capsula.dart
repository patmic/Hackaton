import 'formato_capsula.dart';
import 'pregunta_quiz.dart';
import 'rango_etario.dart';
import 'tipologia.dart';

/// Micro-cápsula preventiva: contenido breve sobre un tipo de engaño,
/// dirigida a una tipología y a uno o más rangos de edad.
class Capsula {
  const Capsula({
    required this.id,
    required this.titulo,
    required this.resumen,
    required this.tipologia,
    required this.rangos,
    required this.formato,
    required this.duracionSegundos,
    required this.mensajeClave,
    this.contenido = const [],
    this.senales = const [],
    this.preguntas = const [],
  });

  factory Capsula.fromJson(Map<String, dynamic> json) => Capsula(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    resumen: json['resumen'] as String,
    tipologia: Tipologia.desdeCodigo(json['tipologia'] as String),
    rangos: (json['rangos'] as List<dynamic>)
        .cast<String>()
        .map(RangoEtario.desdeCodigo)
        .toList(),
    formato: FormatoCapsula.desdeCodigo(json['formato'] as String),
    duracionSegundos: json['duracion_segundos'] as int,
    mensajeClave: json['mensaje_clave'] as String,
    contenido: (json['contenido'] as List<dynamic>? ?? const []).cast<String>(),
    senales: (json['senales'] as List<dynamic>? ?? const []).cast<String>(),
    preguntas: (json['preguntas'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PreguntaQuiz.fromJson)
        .toList(),
  );

  final String id;
  final String titulo;
  final String resumen;
  final Tipologia tipologia;

  /// Rangos a los que va dirigida. Vacío no se permite: usar todos.
  final List<RangoEtario> rangos;
  final FormatoCapsula formato;

  /// Duración estimada. Las cápsulas deben ser cortas (menos de 3 min).
  final int duracionSegundos;

  /// La regla única que el usuario debe recordar.
  final String mensajeClave;

  /// Párrafos breves del contenido.
  final List<String> contenido;

  /// Señales de alerta que enseña a reconocer.
  final List<String> senales;
  final List<PreguntaQuiz> preguntas;

  bool get tieneQuiz => preguntas.isNotEmpty;

  bool dirigidaA(RangoEtario rango) => rangos.contains(rango);
}
