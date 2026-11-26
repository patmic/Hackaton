import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.capsula});

  final Capsula capsula;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = quizProvider(capsula);
    final estado = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('¿Real o estafa?')),
      body: estado.terminado
          ? _Resultado(capsula: capsula, resultado: estado.resultado!)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Caso ${estado.indice + 1} de ${capsula.preguntas.length}',
                  style: textos.labelLarge,
                ),
                const SizedBox(height: 8),
                _CorreoCard(correo: capsula.preguntas[estado.indice].correo),
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
                      estado.indice + 1 < capsula.preguntas.length
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

class _CorreoCard extends StatelessWidget {
  const _CorreoCard({required this.correo});

  final CorreoEjemplo correo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('De: ${correo.remitente}', style: textos.bodySmall),
            const SizedBox(height: 4),
            Text(correo.asunto, style: textos.titleMedium),
            const SizedBox(height: 8),
            Text(correo.cuerpo, style: textos.bodyLarge),
            if (correo.tieneSello) ...[
              const SizedBox(height: 8),
              Text('[Incluye código de verificación]', style: textos.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _RetroCard extends StatelessWidget {
  const _RetroCard({required this.retro});

  final Retroalimentacion retro;

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
            for (final s in retro.senalesClave) Text('• $s'),
          ],
        ),
      ),
    );
  }
}

class _Resultado extends ConsumerWidget {
  const _Resultado({required this.capsula, required this.resultado});

  final Capsula capsula;
  final ResultadoQuiz resultado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    final evaluador = ref.read(evaluadorQuizProvider);
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
            child: Text(capsula.mensajeClave, style: textos.titleMedium),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: ref.read(quizProvider(capsula).notifier).reiniciar,
          child: const Text('Intentar de nuevo'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver a la cápsula'),
        ),
      ],
    );
  }
}
