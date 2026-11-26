import 'package:material_ui/material_ui.dart';

import '../../domain/domain.dart';

/// Pregunta opcional de un clic por el rango de edad (Fallo 3).
class SelectorRango extends StatelessWidget {
  const SelectorRango({
    super.key,
    required this.seleccionado,
    required this.onCambio,
    this.permitirTodos = true,
    this.etiquetaTodos = 'Prefiero no decir',
  });

  final RangoEtario? seleccionado;
  final ValueChanged<RangoEtario?> onCambio;
  final bool permitirTodos;
  final String etiquetaTodos;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (permitirTodos)
          ChoiceChip(
            label: Text(etiquetaTodos),
            selected: seleccionado == null,
            onSelected: (_) => onCambio(null),
          ),
        for (final r in RangoEtario.values)
          ChoiceChip(
            label: Text(r.codigo),
            selected: seleccionado == r,
            onSelected: (_) => onCambio(r),
          ),
      ],
    );
  }
}
