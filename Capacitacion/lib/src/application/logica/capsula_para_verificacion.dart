import '../../domain/domain.dart';

/// Elige la cápsula que se ofrece después de verificar un correo:
/// la de la tipología suplantada, dirigida al rango del usuario y,
/// si es posible, pendiente.
Capsula? capsulaParaVerificacion({
  required ResultadoVerificacion resultado,
  required List<Capsula> capsulas,
  required Perfil perfil,
  required Progreso progreso,
}) {
  final tipologia =
      resultado.tipologiaSuplantada ??
      (resultado.semaforo == Semaforo.verde
          ? resultado.metadatosOficiales?.tipologia
          : null);

  final rango = perfil.rangoEtario;
  final candidatas = capsulas.where((c) {
    if (tipologia != null && c.tipologia != tipologia) return false;
    if (rango != null && !c.dirigidaA(rango)) return false;
    return true;
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
