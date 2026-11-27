import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/logica/logica.dart';
import '../../application/providers.dart';
import '../widgets/actividad_tile.dart' show colorHecho;
import '../widgets/animaciones.dart';
import '../widgets/ilustracion_modulo.dart';
import '../widgets/vista_async.dart';

class ProgresoTab extends ConsumerWidget {
  const ProgresoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actividades = ref.watch(actividadesDelPerfilProvider);
    final progreso = ref.watch(progresoProvider);
    final insignias = ref.watch(insigniasProvider).value;

    return VistaAsync(
      valor: actividades,
      datos: (lista) => VistaAsync(
        valor: progreso,
        datos: (p) {
          final hechas = lista.where((a) => p.estaCompletada(a.id)).length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (insignias != null) ...[
                SeccionInsignias(resumen: insignias),
                const SizedBox(height: 28),
              ],
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

// ---------- Insignias (gamificación) ----------

/// Todas las insignias del usuario: las ganadas a color y las que faltan en
/// gris, con cuánto le falta. Cada quien ve solo las suyas: sin ranking ni
/// comparación con otras personas (sin culpa).
class SeccionInsignias extends StatelessWidget {
  const SeccionInsignias({super.key, required this.resumen});

  final ResumenInsignias resumen;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final ganadas = resumen.ganadas.length;
    final total = resumen.todas.length;
    return Column(
      key: const ValueKey('seccion-insignias'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Mis insignias', style: textos.titleLarge),
        const SizedBox(height: 4),
        Text(
          ganadas == 0
              ? 'Termina tu primera lección y gana tu primera insignia.'
              : 'Ganaste $ganadas de $total insignias',
          style: textos.bodyLarge?.copyWith(color: esquema.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        BarraAvance(valor: total == 0 ? 0 : ganadas / total),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            for (final i in resumen.todas) InsigniaTile(insignia: i),
          ],
        ),
      ],
    );
  }
}

/// Una insignia con su nombre y su estado. Al tocarla explica cómo se gana.
class InsigniaTile extends StatelessWidget {
  const InsigniaTile({super.key, required this.insignia});

  final Insignia insignia;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    // Con letra grande la tarjeta crece en vez de cortar el nombre.
    final ancho = MediaQuery.textScalerOf(
      context,
    ).scale(104).clamp(104.0, 200.0);
    final estado = insignia.ganada
        ? '¡Ganada!'
        : '${insignia.avance} de ${insignia.meta}';
    void abrir() => mostrarDetalleInsignia(context, insignia);

    return Semantics(
      button: true,
      label:
          'Insignia ${insignia.nombre}: '
          '${insignia.ganada ? 'ganada' : 'llevas $estado'}',
      onTap: abrir,
      excludeSemantics: true,
      child: SizedBox(
        width: ancho,
        child: Rebote(
          child: InkWell(
            key: ValueKey('insignia-${insignia.id}'),
            borderRadius: BorderRadius.circular(16),
            onTap: abrir,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                children: [
                  // La clave cambia al ganarla: la medalla entra con un salto.
                  InsigniaVista(
                    key: ValueKey('${insignia.id}-${insignia.ganada}'),
                    insignia: insignia,
                    animada: insignia.ganada,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insignia.nombre,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textos.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    estado,
                    style: textos.labelMedium?.copyWith(
                      color: insignia.ganada
                          ? colorHecho()
                          : esquema.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoja con la insignia en grande: su lema si ya se ganó, o qué falta.
Future<void> mostrarDetalleInsignia(BuildContext context, Insignia insignia) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final textos = Theme.of(context).textTheme;
        final esquema = Theme.of(context).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              key: ValueKey('detalle-insignia-${insignia.id}'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: InsigniaVista(
                    insignia: insignia,
                    tam: 112,
                    animada: insignia.ganada,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  insignia.nombre,
                  textAlign: TextAlign.center,
                  style: textos.headlineSmall,
                ),
                const SizedBox(height: 8),
                if (insignia.ganada) ...[
                  Text(
                    '¡Ganada!',
                    textAlign: TextAlign.center,
                    style: textos.titleMedium?.copyWith(color: colorHecho()),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    estiloInsignia(insignia).lema,
                    textAlign: TextAlign.center,
                    style: textos.bodyLarge,
                  ),
                ] else ...[
                  Text(
                    insignia.comoSeGana,
                    textAlign: TextAlign.center,
                    style: textos.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Llevas ${insignia.avance} de ${insignia.meta}',
                    textAlign: TextAlign.center,
                    style: textos.titleMedium?.copyWith(
                      color: esquema.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BarraAvance(valor: insignia.fraccion),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          ),
        );
      },
    );

/// Resumen corto para el inicio del aula: las insignias ganadas y un botón
/// para verlas todas en «Mi avance».
class TiraInsignias extends StatelessWidget {
  const TiraInsignias({super.key, required this.resumen, this.onVerTodas});

  final ResumenInsignias resumen;
  final VoidCallback? onVerTodas;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final ganadas = resumen.ganadas;
    return Card(
      key: const ValueKey('tira-insignias'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ganadas.isEmpty
                  ? 'Gana tu primera insignia'
                  : 'Tus insignias: ${ganadas.length} de '
                        '${resumen.todas.length}',
              style: textos.titleMedium,
            ),
            const SizedBox(height: 8),
            if (ganadas.isEmpty)
              Text(
                'Termina una lección para ganarla.',
                style: textos.bodyMedium?.copyWith(
                  color: esquema.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final i in ganadas.take(8))
                    InsigniaVista(insignia: i, tam: 40),
                ],
              ),
            if (onVerTodas != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  key: const ValueKey('boton-ver-insignias'),
                  onPressed: onVerTodas,
                  child: const Text('Ver mis insignias'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
