import '../../domain/domain.dart';

/// Microcurso que corresponde al primer indicio que explica el análisis del
/// servidor (CLAUDE.md §11). Null si el análisis no trae indicios.
Microcurso? microcursoParaVerificacion(ResultadoVerificacion resultado) {
  final indicios = resultado.analisis?.indicios ?? const <Indicio>[];
  return indicios.isEmpty ? null : Microcurso.paraIndicio(indicios.first);
}

/// Elige la actividad que se ofrece después de verificar un correo.
///
/// Prioridad:
/// 1. Si el análisis trae indicios: una actividad del módulo del microcurso
///    de ese indicio que lo trabaje; si no hay, cualquiera que lo trabaje.
/// 2. Si no: la de la tipología suplantada (o la de los metadatos en VERDE).
///
/// Siempre entre las que le corresponden al usuario y, si es posible,
/// pendiente y corta.
Actividad? actividadParaVerificacion({
  required ResultadoVerificacion resultado,
  required List<Actividad> actividades,
  required Perfil perfil,
  required Progreso progreso,
}) {
  final elegibles = actividades.where((a) => a.elegiblePara(perfil)).toList();

  final indicios = resultado.analisis?.indicios ?? const <Indicio>[];
  if (indicios.isNotEmpty) {
    final indicio = indicios.first;
    final modulo = Microcurso.paraIndicio(indicio).moduloPara(perfil.tipos);
    final trabajanIndicio = elegibles
        .where((a) => a.indicios.contains(indicio))
        .toList();
    final delModulo = trabajanIndicio.where((a) => a.modulo == modulo).toList();
    final elegida = _mejor(delModulo, progreso) ?? _mejor(trabajanIndicio, progreso);
    if (elegida != null) return elegida;
  }

  final tipologia =
      resultado.tipologiaSuplantada ??
      (resultado.semaforo == Semaforo.verde
          ? resultado.metadatosOficiales?.tipologia
          : null);
  return _mejor(
    elegibles
        .where((a) => tipologia == null || a.tipologia == tipologia)
        .toList(),
    progreso,
  );
}

/// Pendiente primero; entre iguales, la más corta.
Actividad? _mejor(List<Actividad> candidatas, Progreso progreso) {
  if (candidatas.isEmpty) return null;
  final ordenadas = [...candidatas]
    ..sort((a, b) {
      final pa = progreso.estaCompletada(a.id) ? 1 : 0;
      final pb = progreso.estaCompletada(b.id) ? 1 : 0;
      if (pa != pb) return pa.compareTo(pb);
      final porDuracion = a.duracionSegundos.compareTo(b.duracionSegundos);
      return porDuracion != 0 ? porDuracion : a.id.compareTo(b.id);
    });
  return ordenadas.first;
}
