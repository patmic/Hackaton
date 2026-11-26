import '../../domain/domain.dart';

/// Elige la actividad que se ofrece después de verificar un correo: la de la
/// tipología suplantada, que le corresponda al usuario y, si es posible,
/// pendiente y corta.
Actividad? actividadParaVerificacion({
  required ResultadoVerificacion resultado,
  required List<Actividad> actividades,
  required Perfil perfil,
  required Progreso progreso,
}) {
  final tipologia =
      resultado.tipologiaSuplantada ??
      (resultado.semaforo == Semaforo.verde
          ? resultado.metadatosOficiales?.tipologia
          : null);

  final candidatas = actividades.where((a) {
    if (!a.elegiblePara(perfil)) return false;
    return tipologia == null || a.tipologia == tipologia;
  }).toList();
  if (candidatas.isEmpty) return null;

  candidatas.sort((a, b) {
    final pa = progreso.estaCompletada(a.id) ? 1 : 0;
    final pb = progreso.estaCompletada(b.id) ? 1 : 0;
    if (pa != pb) return pa.compareTo(pb);
    return a.duracionSegundos.compareTo(b.duracionSegundos);
  });
  return candidatas.first;
}
