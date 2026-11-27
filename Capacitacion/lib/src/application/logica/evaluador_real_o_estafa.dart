import '../../domain/domain.dart';

/// Evalúa la mecánica A2 «¿Real o estafa?».
///
/// Los mensajes son formativos: ninguno culpa al usuario. Confundir un correo
/// real con una estafa se trata como prudencia, no como error grave.
class EvaluadorRealOEstafa {
  const EvaluadorRealOEstafa();

  RetroTarjeta evaluar(
    TarjetaRealOEstafa tarjeta, {
    required bool respondioEstafa,
  }) {
    final acerto = respondioEstafa == tarjeta.esEstafa;
    return RetroTarjeta(
      tarjetaId: tarjeta.id,
      acerto: acerto,
      respondioEstafa: respondioEstafa,
      mensaje: _mensaje(acerto: acerto, eraEstafa: tarjeta.esEstafa),
      explicacion: tarjeta.explicacion,
      indicios: tarjeta.indicios,
    );
  }

  /// [respuestas]: id de tarjeta → el usuario respondió «estafa». Las
  /// tarjetas sin respuesta no se cuentan.
  ResultadoActividad evaluarRonda(
    Actividad actividad,
    Map<String, bool> respuestas,
  ) {
    final retros = [
      for (final t in tarjetasDe(actividad))
        if (respuestas.containsKey(t.id))
          evaluar(t, respondioEstafa: respuestas[t.id]!),
    ];
    return ResultadoActividad(
      actividadId: actividad.id,
      aciertos: retros.where((r) => r.acerto).length,
      total: retros.length,
      estafasNoDetectadas: retros
          .where((r) => !r.acerto && !r.respondioEstafa)
          .length,
    );
  }

  /// Tarjetas de la actividad. Vacío si no es de la mecánica A2.
  static List<TarjetaRealOEstafa> tarjetasDe(Actividad actividad) {
    final contenido = actividad.contenido;
    return contenido is ContenidoRealOEstafa ? contenido.tarjetas : const [];
  }

  static String _mensaje({required bool acerto, required bool eraEstafa}) {
    if (acerto && eraEstafa) return '¡Bien! Detectaste la estafa.';
    if (acerto) return 'Correcto: este correo es legítimo.';
    if (eraEstafa) {
      return 'Esta vez se coló una estafa. Fíjate en estas señales para la próxima.';
    }
    return 'Era legítimo, pero dudar está bien: verificar siempre es mejor que arriesgarse.';
  }

  /// Mensaje de cierre según el resultado.
  String mensajeFinal(ResultadoActividad resultado) {
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
