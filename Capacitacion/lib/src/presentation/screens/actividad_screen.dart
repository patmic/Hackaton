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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(actividad.titulo, style: textos.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '${modulo.codigo} · ${modulo.nombre} · '
          '${duracionLegible(actividad.duracionSegundos)}',
        ),
        if (actividad.pasos4r.isNotEmpty)
          Text(actividad.pasos4r.map((p) => p.nombre).join(' → ')),
        const SizedBox(height: 16),
        if (actividad.resumen.isNotEmpty)
          Text(actividad.resumen, style: textos.bodyLarge),
        if (actividad.indicios.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Señales que vas a practicar', style: textos.titleMedium),
          for (final i in actividad.indicios)
            ListTile(
              dense: true,
              leading: const Icon(Icons.warning_amber),
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
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RealOEstafaScreen(actividad: actividad),
              ),
            ),
            child: const Text('Practicar: ¿real o estafa?'),
          )
        else
          // La práctica interactiva de cada mecánica llega en la fase 4.
          Text(
            'Práctica «${actividad.mecanica.nombre}»: disponible pronto.',
            style: textos.bodySmall,
          ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: completada
              ? null
              : () => ref
                    .read(progresoProvider.notifier)
                    .marcarCompletada(actividad.id),
          child: Text(completada ? 'Ya la hiciste' : 'Marcar como vista'),
        ),
      ],
    );
  }
}
