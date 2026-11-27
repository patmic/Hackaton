import 'package:material_ui/material_ui.dart';
import 'package:theme_light/theme_light.dart';

import '../../domain/domain.dart';
import '../screens/actividad_screen.dart';
import 'animaciones.dart';
import 'ilustracion_modulo.dart';

/// Color de estado completado del tema compartido.
Color colorHecho() => ThemeLightTokens.okForeground;

String duracionLegible(int segundos) =>
    segundos < 60 ? '$segundos s' : '${(segundos / 60).ceil()} min';

/// Tarjeta de lección: la ilustración del módulo dice de qué trata; el estado va con ícono y palabra
/// (no solo color); toda la tarjeta se toca (área grande) y se hunde al presionarla.
class ActividadTile extends StatelessWidget {
  const ActividadTile({
    super.key,
    required this.actividad,
    this.completada = false,
    this.motivo,
  });

  final Actividad actividad;
  final bool completada;
  final String? motivo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final verde = colorHecho();
    final modulo = estiloModulo(actividad.modulo);
    return Rebote(
      escala: 0.97,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('actividad-${actividad.id}'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ActividadScreen(actividadId: actividad.id),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Franja del color del módulo: se reconoce de lejos.
                Container(width: 6, color: modulo.color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                    child: Row(
                      children: [
                        IlustracionModulo(codigo: actividad.modulo, tam: 56),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(actividad.titulo, style: textos.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                '${actividad.mecanica.nombre} · ${duracionLegible(actividad.duracionSegundos)}',
                                style: textos.bodyMedium?.copyWith(
                                  color: esquema.onSurfaceVariant,
                                ),
                              ),
                              if (motivo != null) ...[
                                const SizedBox(height: 4),
                                Text(motivo!, style: textos.bodySmall),
                              ],
                              if (completada) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: verde,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Hecha',
                                      style: textos.labelMedium?.copyWith(
                                        color: verde,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          completada
                              ? Icons.check_circle
                              : Icons.chevron_right_rounded,
                          color: completada ? verde : esquema.onSurfaceVariant,
                          semanticLabel: completada ? 'Completada' : null,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
