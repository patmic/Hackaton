import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/actividad_tile.dart';
import '../widgets/animaciones.dart';
import '../widgets/ilustracion_modulo.dart';
import '../widgets/responsivo.dart';
import '../widgets/vista_async.dart';
import 'caza_senal_screen.dart';
import 'real_o_estafa_screen.dart';

class ActividadScreen extends ConsumerWidget {
  const ActividadScreen({super.key, required this.actividadId});

  final String actividadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actividad = ref.watch(actividadPorIdProvider(actividadId));
    return Scaffold(
      appBar: AppBar(title: const Text('Lección')),
      body: VistaAsync(
        valor: actividad,
        datos: (a) => a == null
            ? const Center(child: Text('Actividad no encontrada.'))
            : _Contenido(actividad: a),
      ),
    );
  }
}

class _Contenido extends ConsumerStatefulWidget {
  const _Contenido({required this.actividad});

  final Actividad actividad;

  @override
  ConsumerState<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends ConsumerState<_Contenido> {
  bool _celebrar = false;

  Actividad get actividad => widget.actividad;

  /// Botón grande del juego de esta lección (si la mecánica ya tiene componente).
  Widget? _juego(BuildContext context) {
    final (
      String? texto,
      IconData? icono,
      Widget? pantalla,
    ) = switch (actividad.contenido) {
      ContenidoCazaSenal() => (
        'Jugar: Caza la señal',
        Icons.search_rounded,
        CazaSenalScreen(actividad: actividad),
      ),
      ContenidoRealOEstafa() => (
        'Practicar: ¿real o estafa?',
        Icons.style_rounded,
        RealOEstafaScreen(actividad: actividad),
      ),
      _ => (null, null, null),
    };
    if (texto == null || pantalla == null) return null;
    return Rebote(
      child: SizedBox(
        height: 64,
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            PageRouteBuilder<void>(
              transitionDuration: sinMovimiento(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 380),
              pageBuilder: (_, _, _) => pantalla,
              transitionsBuilder: (_, a, _, hijo) => FadeTransition(
                opacity: a,
                child: ScaleTransition(
                  scale: Tween(begin: 0.94, end: 1.0).animate(
                    CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
                  ),
                  child: hijo,
                ),
              ),
            ),
          ),
          icon: Icon(icono, size: 28),
          label: Text(texto),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final modulo = actividad.moduloInfo;
    final completada =
        ref.watch(progresoProvider).value?.estaCompletada(actividad.id) ??
        false;
    final juego = _juego(context);
    var n = 0;

    return Stack(
      children: [
        // Lección corta: se construye completa (el lector de pantalla la recorre entera).
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: AnchoLectura(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Portada con la ilustración del módulo: se sabe de qué trata antes de leer.
                Aparecer(
                  orden: n++,
                  child: PortadaModulo(
                    codigo: actividad.modulo,
                    nombre: modulo.nombre,
                  ),
                ),
                const SizedBox(height: 16),
                Aparecer(
                  orden: n++,
                  child: Text(actividad.titulo, style: textos.headlineSmall),
                ),
                const SizedBox(height: 10),
                // Sin códigos internos: módulo y duración en pastillas.
                Aparecer(
                  orden: n++,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.menu_book_rounded, size: 20),
                        label: Text(modulo.nombre),
                      ),
                      Chip(
                        avatar: const Icon(Icons.schedule_rounded, size: 20),
                        label: Text(
                          duracionLegible(actividad.duracionSegundos),
                        ),
                      ),
                    ],
                  ),
                ),
                if (actividad.resumen.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Aparecer(
                    orden: n++,
                    child: Text(actividad.resumen, style: textos.bodyLarge),
                  ),
                ],
                if (juego != null) ...[
                  const SizedBox(height: 18),
                  Aparecer(orden: n++, child: juego),
                ],
                if (actividad.indicios.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Aparecer(
                    orden: n++,
                    child: Text(
                      'Señales que vas a practicar',
                      style: textos.titleMedium,
                    ),
                  ),
                  for (final i in actividad.indicios)
                    Aparecer(
                      orden: n++,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: esquema.error,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(i.nombre, style: textos.titleMedium),
                                  Text(i.queSeRevisa, style: textos.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 18),
                Aparecer(
                  orden: n++,
                  child: Card(
                    color: esquema.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_rounded,
                            color: esquema.primary,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              actividad.mensajeClave,
                              key: const ValueKey('mensaje-clave'),
                              style: textos.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Aparecer(
                  orden: n++,
                  child: Rebote(
                    child: SizedBox(
                      height: 56,
                      child: completada
                          ? OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: Icon(
                                Icons.check_circle_rounded,
                                color: colorHecho(),
                              ),
                              label: const Text('Ya la hiciste · Volver'),
                            )
                          : OutlinedButton.icon(
                              onPressed: () async {
                                setState(() => _celebrar = true);
                                await ref
                                    .read(progresoProvider.notifier)
                                    .marcarCompletada(actividad.id);
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Ya la leí'),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_celebrar) const Positioned.fill(child: Confeti()),
      ],
    );
  }
}
