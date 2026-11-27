import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';

/// «Lo que más te conviene practicar»: el plan que el observador armó con
/// las prácticas de la persona. Explica por qué se recomiendan esas
/// lecciones y deja decidir si se comparte con el Radar Phishing.
class PlanPersonalCard extends ConsumerWidget {
  const PlanPersonalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planPersonalizadoProvider).value;
    final datos = ref.watch(observadorProvider).value;
    final hayServidor = ref.watch(observadorApiProvider) != null;
    if (plan == null || datos == null) return const SizedBox.shrink();
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final suave = textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant);

    return Card(
      key: const ValueKey('tarjeta-plan-personal'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.radar_rounded, size: 28, color: esquema.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lo que más te conviene practicar',
                    style: textos.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (plan.sinDatos)
              Text(
                'Cuando hagas tus primeras lecciones, aquí verás qué señales te '
                'cuestan más, y las lecciones se ordenarán solas para ti.',
                style: textos.bodyLarge,
              )
            else ...[
              Text(plan.mensaje, style: textos.bodyLarge),
              const SizedBox(height: 12),
              // Primero lo que ya le costó; después lo nuevo por probar.
              for (final f in [
                ...plan.falencias.where(
                  (f) => f.estado != EstadoIndicio.sinProbar,
                ),
                ...plan.falencias.where(
                  (f) => f.estado == EstadoIndicio.sinProbar,
                ),
              ])
                _Falencia(falencia: f),
              if (plan.foco != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Los correos que más te cuestan: los que imitan '
                    '«${plan.foco!.nombre}».',
                    style: textos.bodyMedium,
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Text(
              plan.origen == OrigenPlan.servidor
                  ? 'Plan del Radar Phishing. ${plan.nota}'
                  : 'Se calcula en tu dispositivo con tus prácticas. ${plan.nota}',
              style: suave,
            ),
            const Divider(height: 24),
            if (hayServidor) ...[
              SwitchListTile(
                key: const ValueKey('interruptor-compartir-radar'),
                contentPadding: EdgeInsets.zero,
                value: datos.compartir,
                onChanged: (v) =>
                    ref.read(observadorProvider.notifier).compartir(v),
                title: const Text(
                  'Compartir mis prácticas con el Radar Phishing',
                ),
                subtitle: const Text(
                  'Ayuda a saber qué estafas engañan más a personas como tú. '
                  'Van con un código al azar, sin tu nombre, cédula ni correo.',
                ),
              ),
              if (datos.compartir)
                _Codigo(codigo: datos.idSeudonimo, estilo: suave),
            ],
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const ValueKey('boton-borrar-practicas'),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Borrar mis prácticas'),
                onPressed: () => _confirmarBorrado(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarBorrado(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Borrar tus prácticas?'),
        content: const Text(
          'Se borra lo que aprendimos de tus respuestas, aquí y en el Radar '
          'Phishing, y empiezas con un código nuevo. Tus lecciones hechas y '
          'tus insignias no se borran.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Sí, borrar'),
          ),
        ],
      ),
    );
    if (ok ?? false) await ref.read(observadorProvider.notifier).borrarDatos();
  }
}

class _Falencia extends StatelessWidget {
  const _Falencia({required this.falencia});

  final FalenciaPlan falencia;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final etiqueta = falencia.estado == EstadoIndicio.dominado
        ? 'Para repasar'
        : falencia.estado.etiquetaVisible;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            falencia.estado == EstadoIndicio.sinProbar
                ? Icons.explore_outlined
                : Icons.flag_outlined,
            color: esquema.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(falencia.indicio.nombre, style: textos.titleSmall),
                Text(
                  [
                    etiqueta,
                    if (falencia.motivos.isNotEmpty) falencia.motivos.first,
                  ].join(' · '),
                  style: textos.bodyMedium?.copyWith(
                    color: esquema.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Codigo extends StatelessWidget {
  const _Codigo({required this.codigo, this.estilo});

  final String codigo;
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Expanded(
          child: SelectableText(
            'Tu código de capacitación: $codigo. Con él ves tu plan en el '
            'Radar Phishing.',
            style: estilo,
          ),
        ),
        IconButton(
          tooltip: 'Copiar código',
          icon: const Icon(Icons.copy_rounded),
          onPressed: () => Clipboard.setData(ClipboardData(text: codigo)),
        ),
      ],
    ),
  );
}
