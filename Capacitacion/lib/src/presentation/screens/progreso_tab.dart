import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../widgets/vista_async.dart';

class ProgresoTab extends ConsumerWidget {
  const ProgresoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actividades = ref.watch(actividadesDelPerfilProvider);
    final progreso = ref.watch(progresoProvider);

    return VistaAsync(
      valor: actividades,
      datos: (lista) => VistaAsync(
        valor: progreso,
        datos: (p) {
          final hechas = lista.where((a) => p.estaCompletada(a.id)).length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '$hechas de ${lista.length} actividades hechas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: lista.isEmpty ? 0 : hechas / lista.length,
              ),
              const SizedBox(height: 24),
              for (final a in lista)
                ListTile(
                  leading: Icon(
                    p.estaCompletada(a.id)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(a.titulo),
                  subtitle: p.mejoresPuntajes[a.id] == null
                      ? Text(a.moduloInfo.nombre)
                      : Text(
                          '${a.moduloInfo.nombre} · Mejor resultado: '
                          '${(p.mejoresPuntajes[a.id]! * 100).round()} %',
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}
