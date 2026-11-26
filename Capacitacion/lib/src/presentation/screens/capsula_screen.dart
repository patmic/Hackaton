import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/capsula_tile.dart';
import '../widgets/vista_async.dart';
import 'quiz_screen.dart';

class CapsulaScreen extends ConsumerWidget {
  const CapsulaScreen({super.key, required this.capsulaId});

  final String capsulaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsula = ref.watch(capsulaPorIdProvider(capsulaId));
    return Scaffold(
      appBar: AppBar(title: const Text('Cápsula')),
      body: VistaAsync(
        valor: capsula,
        datos: (c) => c == null
            ? const Center(child: Text('Cápsula no encontrada.'))
            : _Contenido(capsula: c),
      ),
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.capsula});

  final Capsula capsula;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    final completada =
        ref.watch(progresoProvider).value?.estaCompletada(capsula.id) ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(capsula.titulo, style: textos.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '${capsula.tipologia.codigo} · ${capsula.tipologia.nombre} · '
          '${duracionLegible(capsula.duracionSegundos)}',
        ),
        const SizedBox(height: 16),
        for (final p in capsula.contenido)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(p, style: textos.bodyLarge),
          ),
        if (capsula.senales.isNotEmpty) ...[
          Text('Señales de alerta', style: textos.titleMedium),
          for (final s in capsula.senales)
            ListTile(
              dense: true,
              leading: const Icon(Icons.warning_amber),
              title: Text(s),
            ),
        ],
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              capsula.mensajeClave,
              key: const ValueKey('mensaje-clave'),
              style: textos.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (capsula.tieneQuiz)
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => QuizScreen(capsula: capsula),
              ),
            ),
            child: const Text('Practicar: ¿real o estafa?'),
          ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: completada
              ? null
              : () => ref
                    .read(progresoProvider.notifier)
                    .marcarCompletada(capsula.id),
          child: Text(completada ? 'Ya la viste' : 'Marcar como vista'),
        ),
      ],
    );
  }
}
