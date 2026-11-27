import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/actividad_tile.dart';
import '../widgets/vista_async.dart';
import 'real_o_estafa_screen.dart';

class ActividadScreen extends ConsumerWidget {
  const ActividadScreen({super.key, required this.actividadId});

  final String actividadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actividad = ref.watch(actividadPorIdProvider(actividadId));
    return Scaffold(
      appBar: AppBar(title: const Text('Actividad')),
      body: VistaAsync(
        valor: actividad,
        datos: (a) => a == null
            ? const Center(child: Text('Actividad no encontrada.'))
            : _Contenido(actividad: a),
      ),
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.actividad});

  final Actividad actividad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    final modulo = actividad.moduloInfo;
    final completada =
        ref.watch(progresoProvider).value?.estaCompletada(actividad.id) ??
        false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(actividad.titulo, style: textos.headlineSmall),
          const SizedBox(height: 4),
          // Sin códigos internos (M1, A1): solo lo que la persona entiende.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.menu_book_rounded, size: 20),
                label: Text(modulo.nombre),
              ),
              Chip(
                avatar: const Icon(Icons.schedule_rounded, size: 20),
                label: Text(duracionLegible(actividad.duracionSegundos)),
              ),
            ],
          ),
          if (actividad.pasos4r.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Aprenderás a: ${actividad.pasos4r.map((p) => p.nombre.toLowerCase()).join(', ')}.',
              style: textos.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          if (actividad.resumen.isNotEmpty)
            Text(actividad.resumen, style: textos.bodyLarge),
          if (actividad.indicios.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Señales que vas a practicar', style: textos.titleMedium),
            for (final i in actividad.indicios)
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB3261E),
                  size: 28,
                ),
                title: Text(i.nombre),
                subtitle: Text(i.queSeRevisa),
              ),
          ],
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                actividad.mensajeClave,
                key: const ValueKey('mensaje-clave'),
                style: textos.titleMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (actividad.contenido is ContenidoRealOEstafa)
            SizedBox(
              height: 60,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => RealOEstafaScreen(actividad: actividad),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: const Text('Practicar: ¿real o estafa?'),
              ),
            ),
          // (La práctica interactiva de las demás mecánicas llega en la fase 4:
          // no se muestra un "disponible pronto" que deja a la persona sin salida.)
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: completada
                ? OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF17703A),
                    ),
                    label: const Text('Ya la hiciste · Volver'),
                  )
                : FilledButton.tonalIcon(
                    onPressed: () {
                      ref
                          .read(progresoProvider.notifier)
                          .marcarCompletada(actividad.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '¡Bien! Lección guardada en tu avance.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Ya la leí'),
                  ),
          ),
        ],
      ),
    );
  }
}
