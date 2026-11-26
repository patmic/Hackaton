import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../widgets/actividad_tile.dart';
import '../widgets/selector_rango.dart';
import '../widgets/vista_async.dart';

class ParaTiTab extends ConsumerWidget {
  const ParaTiTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilProvider);
    final recomendaciones = ref.watch(recomendacionesProvider);
    final progreso = ref.watch(progresoProvider).value;
    final textos = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Para avisarte de las estafas que circulan, '
          '¿en qué rango de edad estás? (opcional)',
          style: textos.titleMedium,
        ),
        const SizedBox(height: 8),
        SelectorRango(
          seleccionado: perfil.rangoEtario,
          onCambio: ref.read(perfilProvider.notifier).elegirRango,
        ),
        const SizedBox(height: 24),
        Text('Recomendadas', style: textos.titleLarge),
        const SizedBox(height: 8),
        VistaAsync(
          valor: recomendaciones,
          datos: (lista) => lista.isEmpty
              ? const Text('Ya hiciste todas las actividades de tu ruta.')
              : Column(
                  children: [
                    for (final r in lista)
                      ActividadTile(
                        actividad: r.actividad,
                        completada:
                            progreso?.estaCompletada(r.actividad.id) ?? false,
                        motivo: r.motivos.isEmpty ? null : r.motivos.first,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
