import 'rango_etario.dart';
import 'tipologia.dart';

/// Alerta de hipersegmentación emitida por el Observatorio (Bloque 3).
/// Ej.: aumento del 40 % de phishing T2 dirigido a 65+.
class AlertaObservatorio {
  const AlertaObservatorio({
    required this.id,
    required this.tipologia,
    required this.mensaje,
    this.rangoEtario,
    this.incrementoPorcentaje = 0,
  });

  factory AlertaObservatorio.fromJson(Map<String, dynamic> json) =>
      AlertaObservatorio(
        id: json['id'] as String,
        tipologia: Tipologia.desdeCodigo(json['tipologia'] as String),
        rangoEtario: json['rango_etario'] == null
            ? null
            : RangoEtario.desdeCodigo(json['rango_etario'] as String),
        incrementoPorcentaje: (json['incremento_pct'] as num? ?? 0).toDouble(),
        mensaje: json['mensaje'] as String,
      );

  final String id;
  final Tipologia tipologia;

  /// Null si la alerta afecta a todos los rangos.
  final RangoEtario? rangoEtario;
  final double incrementoPorcentaje;
  final String mensaje;

  bool afectaA(RangoEtario? rango) =>
      rangoEtario == null || rango == null || rangoEtario == rango;
}
