import 'package:material_ui/material_ui.dart';

import '../../domain/domain.dart';
import '../screens/actividad_screen.dart';

/// Verde de "hecho" con buen contraste en tema claro u oscuro.
Color colorHecho(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF3DDC4A)
    : const Color(0xFF17703A);

String duracionLegible(int segundos) =>
    segundos < 60 ? '$segundos s' : '${(segundos / 60).ceil()} min';

/// Lección en la lista: estado con ícono + palabra (no solo color), sin códigos internos,
/// toda la tarjeta se puede tocar (área grande).
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
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final detalle =
        '${actividad.mecanica.nombre} · ${duracionLegible(actividad.duracionSegundos)}';
    final verde = colorHecho(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('actividad-${actividad.id}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ActividadScreen(actividadId: actividad.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: completada
                    ? verde.withValues(alpha: 0.16)
                    : esquema.primaryContainer,
                child: Icon(
                  completada ? Icons.check_rounded : Icons.play_arrow_rounded,
                  color: completada ? verde : esquema.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(actividad.titulo, style: textos.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      completada ? '$detalle · Hecha' : detalle,
                      style: textos.bodyMedium?.copyWith(
                        color: completada ? verde : esquema.onSurfaceVariant,
                      ),
                    ),
                    if (motivo != null) ...[
                      const SizedBox(height: 6),
                      Text(motivo!, style: textos.bodySmall),
                    ],
                  ],
                ),
              ),
              Icon(
                completada ? Icons.check_circle : Icons.chevron_right,
                semanticLabel: completada ? 'Completada' : null,
                color: completada ? verde : esquema.onSurfaceVariant,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
