import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/mensaje_card.dart';

/// Mecánica A2 «¿Real o estafa?».
class RealOEstafaScreen extends ConsumerWidget {
  const RealOEstafaScreen({super.key, required this.actividad});

  final Actividad actividad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = realOEstafaProvider(actividad);
    final estado = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final tarjetas = controller.tarjetas;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('¿Real o estafa?')),
      body: estado.terminado
          ? _Resultado(actividad: actividad, resultado: estado.resultado!)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Caso ${estado.indice + 1} de ${tarjetas.length}',
                  style: textos.labelLarge,
                ),
                const SizedBox(height: 8),
                MensajeCard(mensaje: tarjetas[estado.indice].mensaje),
                const SizedBox(height: 16),
                if (!estado.respondida)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              controller.responder(esEstafa: false),
                          child: const Text('Es real'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => controller.responder(esEstafa: true),
                          child: const Text('Es estafa'),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _RetroCard(retro: estado.retroActual!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.siguiente,
                    child: Text(
                      estado.indice + 1 < tarjetas.length
                          ? 'Siguiente caso'
                          : 'Ver resultado',
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _RetroCard extends StatelessWidget {
  const _RetroCard({required this.retro});

  final RetroTarjeta retro;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              retro.mensaje,
              key: const ValueKey('retro-mensaje'),
              style: textos.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(retro.explicacion),
            for (final i in retro.indicios) Text('• ${i.nombre}'),
          ],
        ),
      ),
    );
  }
}

class _Resultado extends ConsumerWidget {
  const _Resultado({required this.actividad, required this.resultado});

  final Actividad actividad;
  final ResultadoActividad resultado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    final evaluador = ref.read(evaluadorRealOEstafaProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${resultado.aciertos} de ${resultado.total} casos reconocidos',
          key: const ValueKey('quiz-resultado'),
          style: textos.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(evaluador.mensajeFinal(resultado)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(actividad.mensajeClave, style: textos.titleMedium),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: ref.read(realOEstafaProvider(actividad).notifier).reiniciar,
          child: const Text('Intentar de nuevo'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver a la actividad'),
        ),
      ],
    );
  }
}
