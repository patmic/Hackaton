import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/actividad_tile.dart';
import '../widgets/animaciones.dart';
import '../widgets/responsivo.dart';
import '../widgets/vista_async.dart';

/// Actividades que le corresponden al usuario, con filtros.
class CatalogoTab extends ConsumerWidget {
  const CatalogoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroProvider);
    final notifier = ref.read(filtroProvider.notifier);
    final actividades = ref.watch(actividadesFiltradasProvider);
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
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Solo pendientes'),
          value: filtro.soloPendientes,
          onChanged: notifier.soloPendientes,
        ),
        VistaAsync(
          valor: actividades,
          datos: (lista) => lista.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay actividades con estos filtros.'),
                )
              : RejillaAdaptable(
                  children: [
                    for (final (i, a) in lista.indexed)
                      Aparecer(
                        orden: i,
                        child: ActividadTile(
                          actividad: a,
                          completada: progreso?.estaCompletada(a.id) ?? false,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
