import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/actividad_tile.dart' show colorHecho;
import '../widgets/animaciones.dart';
import '../widgets/responsivo.dart';
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
      body: AnchoLectura(
        child: estado.terminado
            ? _Resultado(actividad: actividad, resultado: estado.resultado!)
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Caso ${estado.indice + 1} de ${tarjetas.length}',
                          style: textos.labelLarge,
                        ),
                        const SizedBox(height: 6),
                        BarraAvance(
                          valor:
                              (estado.indice + (estado.respondida ? 1 : 0)) /
                              tarjetas.length,
                          alto: 10,
                        ),
                        const SizedBox(height: 12),
                        // Cada caso entra deslizándose; si la respuesta fue equivocada, la tarjeta hace "no".
                        Sacudir(
                          disparo:
                              estado.respondida && !estado.retroActual!.acerto
                              ? estado.indice + 1
                              : 0,
                          child: AnimatedSwitcher(
                            duration: sinMovimiento(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 420),
                            transitionBuilder: (c, a) => FadeTransition(
                              opacity: a,
                              child: SlideTransition(
                                position:
                                    Tween(
                                      begin: const Offset(0.25, 0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: a,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: c,
                              ),
                            ),
                            child: KeyedSubtree(
                              key: ValueKey(estado.indice),
                              child: MensajeCard(
                                mensaje: tarjetas[estado.indice].mensaje,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!estado.respondida)
                          Row(
                            children: [
                              Expanded(
                                child: Rebote(
                                  child: SizedBox(
                                    height: 64,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          controller.responder(esEstafa: false),
                                      icon: const Icon(
                                        Icons.verified_user_rounded,
                                      ),
                                      label: const Text('Es real'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Rebote(
                                  child: SizedBox(
                                    height: 64,
                                    child: FilledButton.icon(
                                      onPressed: () =>
                                          controller.responder(esEstafa: true),
                                      icon: const Icon(Icons.gpp_bad_rounded),
                                      label: const Text('Es estafa'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else ...[
                          Aparecer(
                            key: ValueKey('r${estado.indice}'),
                            child: _RetroCard(retro: estado.retroActual!),
                          ),
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
                  ),
                  if (estado.respondida && estado.retroActual!.acerto)
                    Positioned.fill(
                      child: Confeti(
                        key: ValueKey('c${estado.indice}'),
                        cantidad: 40,
                      ),
                    ),
                ],
              ),
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
    final esquema = Theme.of(context).colorScheme;
    final color = retro.acerto ? colorHecho() : esquema.error;
    return Card(
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Saltar(
              child: Icon(
                retro.acerto ? Icons.celebration_rounded : Icons.info_rounded,
                color: color,
                size: 36,
              ),
            ),
            const SizedBox(height: 6),
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
    final bien = resultado.aciertos * 2 >= resultado.total;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Saltar(
                child: Icon(
                  bien ? Icons.emoji_events_rounded : Icons.school_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              BarraAvance(
                valor: resultado.total == 0
                    ? 0
                    : resultado.aciertos / resultado.total,
              ),
              const SizedBox(height: 12),
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
                  child: Text(
                    actividad.mensajeClave,
                    style: textos.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: ref
                    .read(realOEstafaProvider(actividad).notifier)
                    .reiniciar,
                child: const Text('Intentar de nuevo'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver a la actividad'),
              ),
            ],
          ),
        ),
        if (bien) const Positioned.fill(child: Confeti()),
      ],
    );
  }
}
