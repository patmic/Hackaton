import 'indicio.dart';

/// Resultado de terminar una actividad, sea cual sea su mecánica.
class ResultadoActividad {
  const ResultadoActividad({
    required this.actividadId,
    required this.aciertos,
    required this.total,
    this.estafasNoDetectadas = 0,
  });

  final String actividadId;
  final int aciertos;
  final int total;

  /// Estafas que el usuario creyó reales: el error más peligroso.
  final int estafasNoDetectadas;

  /// 0.0 a 1.0.
  double get puntaje => total == 0 ? 0 : aciertos / total;
}

/// Retroalimentación de una tarjeta de «¿Real o estafa?» (A2).
///
/// El tono es formativo, nunca punitivo: el castigo reduce el reporte
/// (ver obsidian, 07 Evidencia científica).
class RetroTarjeta {
  const RetroTarjeta({
    required this.tarjetaId,
    required this.acerto,
    required this.respondioEstafa,
    required this.mensaje,
    required this.explicacion,
    this.indicios = const [],
  });

  final String tarjetaId;
  final bool acerto;
  final bool respondioEstafa;
  final String mensaje;
  final String explicacion;
  final List<Indicio> indicios;
}
