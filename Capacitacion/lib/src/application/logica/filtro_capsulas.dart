import '../../domain/domain.dart';

/// Criterios del catálogo. Un campo null significa "todos".
class FiltroCapsulas {
  const FiltroCapsulas({
    this.tipologia,
    this.rango,
    this.formato,
    this.soloPendientes = false,
  });

  final Tipologia? tipologia;
  final RangoEtario? rango;
  final FormatoCapsula? formato;
  final bool soloPendientes;

  bool get estaVacio =>
      tipologia == null && rango == null && formato == null && !soloPendientes;

  List<Capsula> aplicar(List<Capsula> capsulas, [Progreso? progreso]) =>
      capsulas.where((c) {
        if (tipologia != null && c.tipologia != tipologia) return false;
        if (rango != null && !c.dirigidaA(rango!)) return false;
        if (formato != null && c.formato != formato) return false;
        if (soloPendientes && (progreso?.estaCompletada(c.id) ?? false)) {
          return false;
        }
        return true;
      }).toList();

  FiltroCapsulas copyWith({
    Tipologia? Function()? tipologia,
    RangoEtario? Function()? rango,
    FormatoCapsula? Function()? formato,
    bool? soloPendientes,
  }) => FiltroCapsulas(
    tipologia: tipologia != null ? tipologia() : this.tipologia,
    rango: rango != null ? rango() : this.rango,
    formato: formato != null ? formato() : this.formato,
    soloPendientes: soloPendientes ?? this.soloPendientes,
  );
}
