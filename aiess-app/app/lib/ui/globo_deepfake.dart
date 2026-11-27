// Globo de texto del robot con sugerencias para aprender sobre deepfakes.
// Las sugerencias son las lecciones del módulo M15 del aula (Capacitacion/assets/data/actividades.json) que le
// corresponden a la persona según su tipo. Al tocar el globo el robot dice de qué se trata cada una y ofrece
// hacer la lección (de 1 a 3 minutos) o empezar la capacitación personalizada («Quiero capacitarme»).
import 'package:capacitacion/src/application/providers.dart' as cap;
import 'package:capacitacion/src/domain/domain.dart';
import 'package:capacitacion/src/presentation/screens/actividad_screen.dart';
import 'package:capacitacion/src/presentation/screens/capacitacion_screen.dart';
import 'package:capacitacion/src/presentation/widgets/actividad_tile.dart'
    show duracionLegible;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/voz/voz.dart';
import 'tema.dart';

/// Módulo del aula con las lecciones de deepfakes.
const moduloDeepfakes = 'M15';

const _invitacion =
    '¿Sabes qué es un deepfake y cómo te puede afectar? Toca aquí y te cuento.';

class GloboDeepfake extends ConsumerStatefulWidget {
  const GloboDeepfake({super.key});

  @override
  ConsumerState<GloboDeepfake> createState() => _GloboDeepfakeState();
}

class _GloboDeepfakeState extends ConsumerState<GloboDeepfake> {
  /// Sugerencia que se muestra. Null: todavía la invitación.
  int? _actual;

  void _decir(Actividad a) =>
      Voz.i.decir('${a.resumen} Recuerda: ${a.mensajeClave}');

  void _mostrar(List<Actividad> sugerencias, int i) {
    setState(() => _actual = i);
    _decir(sugerencias[i]);
  }

  void _abrir(Widget pantalla) {
    Voz.i.callar();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    final sugerencias = [
      for (final a
          in ref.watch(cap.actividadesDelPerfilProvider).value ??
              const <Actividad>[])
        if (a.modulo == moduloDeepfakes) a,
    ];
    // Sin lecciones (cargando o sin catálogo) no se muestra un globo vacío.
    if (sugerencias.isEmpty) return const SizedBox.shrink();
    final i = _actual == null ? null : _actual! % sugerencias.length;
    final a = i == null ? null : sugerencias[i];
    final textos = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // La cola del globo apunta al robot, que está centrado encima.
        const Center(
          child: CustomPaint(size: Size(22, 12), painter: _Cola()),
        ),
        Material(
          color: Tono.superficie,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radios.lg),
            side: const BorderSide(color: Tono.borde),
          ),
          clipBehavior: Clip.antiAlias,
          child: Semantics(
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  key: const ValueKey('globo-deepfake'),
                  // Tocar el globo: la primera vez empieza; después, el robot lo repite.
                  onTap: a == null
                      ? () => _mostrar(sugerencias, 0)
                      : () => _decir(a),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.record_voice_over_rounded,
                              color: Tono.lima,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                a == null ? _invitacion : a.titulo,
                                style: textos.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        if (a != null) ...[
                          const SizedBox(height: 8),
                          Text(a.resumen, style: textos.bodyLarge),
                          const SizedBox(height: 8),
                          Text(
                            'Recuerda: ${a.mensajeClave}',
                            style: textos.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sugerencia ${i! + 1} de ${sugerencias.length} · '
                            'toca el globo para escucharla otra vez',
                            style: textos.bodySmall?.copyWith(color: Tono.gris),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (a != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                          onPressed: () =>
                              _abrir(ActividadScreen(actividadId: a.id)),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            'Hacer la lección · '
                            '${duracionLegible(a.duracionSegundos)}',
                          ),
                        ),
                        if (sugerencias.length > 1)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            onPressed: () => _mostrar(sugerencias, i! + 1),
                            icon: const Icon(Icons.lightbulb_outline_rounded),
                            label: const Text('Otra sugerencia'),
                          ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                          onPressed: () => _abrir(const CapacitacionScreen()),
                          icon: const Icon(Icons.school_rounded),
                          label: const Text('Quiero capacitarme'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Triángulo de la cola del globo, con el mismo fondo y borde.
class _Cola extends CustomPainter {
  const _Cola();

  @override
  void paint(Canvas canvas, Size size) {
    final punta = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height);
    canvas.drawPath(punta, Paint()..color = Tono.superficie);
    canvas.drawPath(
      punta,
      Paint()
        ..color = Tono.borde
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_Cola oldDelegate) => false;
}
