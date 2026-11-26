import '../../domain/domain.dart';

/// Módulos que tocan al usuario según sus tipos, combinando las rutas de
/// CLAUDE.md §10.4. Una persona puede tener varios tipos (un colaborador casi
/// siempre es también afiliado): las rutas se juntan en el orden de
/// [TipoUsuario] y sin repetir módulos.
class PlanCapacitacion {
  const PlanCapacitacion({required this.arranque, required this.refuerzo});

  factory PlanCapacitacion.para(Perfil perfil, {Tipologia? tipologiaAtacada}) {
    final tipos = perfil.tipos.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final arranque = <String>[];
    final refuerzo = <String>[];
    for (final tipo in tipos) {
      final ruta = Ruta.para(tipo);
      for (final m in ruta.arranque) {
        if (!arranque.contains(m)) arranque.add(m);
      }
      final ciclo = ruta.refuerzo(
        tipologiaAtacada: tipologiaAtacada,
        esCuidador: perfil.esCuidador,
      );
      for (final m in ciclo) {
        if (!refuerzo.contains(m)) refuerzo.add(m);
      }
    }
    // Los Centinelas tienen acceso a M14 (CLAUDE.md §7).
    if (perfil.esCentinela && !refuerzo.contains('M14')) refuerzo.add('M14');
    return PlanCapacitacion(arranque: arranque, refuerzo: refuerzo);
  }

  /// Módulos de arranque, en orden.
  final List<String> arranque;

  /// Módulos del ciclo de refuerzo.
  final List<String> refuerzo;
}
