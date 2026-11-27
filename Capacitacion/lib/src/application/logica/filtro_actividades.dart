import '../../domain/domain.dart';

/// Criterios del catálogo. Un campo null significa «todos».
class FiltroActividades {
  const FiltroActividades({
    this.tipologia,
    this.modulo,
    this.mecanica,
    this.soloPendientes = false,
  });

  final Tipologia? tipologia;

  /// Código del módulo (M1…M14).
  final String? modulo;
  final Mecanica? mecanica;
  final bool soloPendientes;

  bool get estaVacio =>
      tipologia == null &&
      modulo == null &&
      mecanica == null &&
      !soloPendientes;

  /// Con [perfil] solo deja las actividades que le corresponden al usuario.
  List<Actividad> aplicar(
    List<Actividad> actividades, {
    Perfil? perfil,
    Progreso? progreso,
  }) => actividades.where((a) {
    if (perfil != null && !a.elegiblePara(perfil)) return false;
    if (tipologia != null && a.tipologia != tipologia) return false;
    if (modulo != null && a.modulo != modulo) return false;
    if (mecanica != null && a.mecanica != mecanica) return false;
    if (soloPendientes && (progreso?.estaCompletada(a.id) ?? false)) {
      return false;
    }
    return true;
  }).toList();

  FiltroActividades copyWith({
    Tipologia? Function()? tipologia,
    String? Function()? modulo,
    Mecanica? Function()? mecanica,
    bool? soloPendientes,
  }) => FiltroActividades(
    tipologia: tipologia != null ? tipologia() : this.tipologia,
    modulo: modulo != null ? modulo() : this.modulo,
    mecanica: mecanica != null ? mecanica() : this.mecanica,
    soloPendientes: soloPendientes ?? this.soloPendientes,
  );
}
