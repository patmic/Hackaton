import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../widgets/vista_async.dart';

class ProgresoTab extends ConsumerWidget {
  const ProgresoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogo = ref.watch(catalogoProvider);
    final progreso = ref.watch(progresoProvider);

    return VistaAsync(
      valor: catalogo,
      datos: (capsulas) => VistaAsync(
        valor: progreso,
        datos: (p) {
          final avance = p.avance(capsulas.length);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${p.completadas.length} de ${capsulas.length} cápsulas vistas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: avance),
              const SizedBox(height: 24),
              for (final c in capsulas)
                ListTile(
                  leading: Icon(
                    p.estaCompletada(c.id)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(c.titulo),
                  subtitle: p.mejoresPuntajes[c.id] == null
                      ? null
                      : Text(
                          'Mejor resultado: '
                          '${(p.mejoresPuntajes[c.id]! * 100).round()} %',
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}
