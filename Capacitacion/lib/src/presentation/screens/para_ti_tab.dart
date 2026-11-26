import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../widgets/capsula_tile.dart';
import '../widgets/selector_rango.dart';
import '../widgets/vista_async.dart';

class ParaTiTab extends ConsumerWidget {
  const ParaTiTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilProvider);
    final recomendaciones = ref.watch(recomendacionesProvider);
    final progreso = ref.watch(progresoProvider).value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Para ayudarte mejor, ¿en qué rango de edad estás?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SelectorRango(
          seleccionado: perfil.rangoEtario,
          onCambio: ref.read(perfilProvider.notifier).elegirRango,
        ),
        const SizedBox(height: 24),
        Text('Recomendadas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        VistaAsync(
          valor: recomendaciones,
          datos: (lista) => lista.isEmpty
              ? const Text('Ya viste todas las cápsulas para tu perfil.')
              : Column(
                  children: [
                    for (final r in lista)
                      CapsulaTile(
                        capsula: r.capsula,
                        completada:
                            progreso?.estaCompletada(r.capsula.id) ?? false,
                        motivo: r.motivos.isEmpty ? null : r.motivos.first,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
