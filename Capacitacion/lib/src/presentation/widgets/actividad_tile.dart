import 'package:material_ui/material_ui.dart';

import '../../domain/domain.dart';
import '../screens/actividad_screen.dart';

String duracionLegible(int segundos) =>
    segundos < 60 ? '$segundos s' : '${(segundos / 60).ceil()} min';

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
    final detalle = [
      actividad.modulo,
      actividad.mecanica.nombre,
      duracionLegible(actividad.duracionSegundos),
    ].join(' · ');
    return Card(
      child: ListTile(
        key: ValueKey('actividad-${actividad.id}'),
        title: Text(actividad.titulo),
        subtitle: Text(motivo == null ? detalle : '$detalle\n$motivo'),
        isThreeLine: motivo != null,
        trailing: completada
            ? const Icon(Icons.check_circle, semanticLabel: 'Completada')
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ActividadScreen(actividadId: actividad.id),
          ),
        ),
      ),
    );
  }
}
