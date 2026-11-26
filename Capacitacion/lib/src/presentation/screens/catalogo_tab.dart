import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/capsula_tile.dart';
import '../widgets/selector_rango.dart';
import '../widgets/vista_async.dart';

class CatalogoTab extends ConsumerWidget {
  const CatalogoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroProvider);
    final notifier = ref.read(filtroProvider.notifier);
    final capsulas = ref.watch(capsulasFiltradasProvider);
    final progreso = ref.watch(progresoProvider).value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Tipo de correo', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: filtro.tipologia == null,
              onSelected: (_) => notifier.tipologia(null),
            ),
            for (final t in Tipologia.values)
              ChoiceChip(
                label: Text('${t.codigo} · ${t.nombre}'),
                selected: filtro.tipologia == t,
                onSelected: (_) => notifier.tipologia(t),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Rango de edad', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SelectorRango(
          seleccionado: filtro.rango,
          onCambio: notifier.rango,
          etiquetaTodos: 'Todos',
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Solo pendientes'),
          value: filtro.soloPendientes,
          onChanged: notifier.soloPendientes,
        ),
        VistaAsync(
          valor: capsulas,
          datos: (lista) => lista.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay cápsulas con estos filtros.'),
                )
              : Column(
                  children: [
                    for (final c in lista)
                      CapsulaTile(
                        capsula: c,
                        completada: progreso?.estaCompletada(c.id) ?? false,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
