import 'package:material_ui/material_ui.dart';

import '../../domain/domain.dart';
import '../screens/capsula_screen.dart';

String duracionLegible(int segundos) =>
    segundos < 60 ? '$segundos s' : '${(segundos / 60).ceil()} min';

class CapsulaTile extends StatelessWidget {
  const CapsulaTile({
    super.key,
    required this.capsula,
    this.completada = false,
    this.motivo,
  });

  final Capsula capsula;
  final bool completada;
  final String? motivo;

  @override
  Widget build(BuildContext context) {
    final detalle = [
      capsula.tipologia.codigo,
      capsula.formato.etiqueta,
      duracionLegible(capsula.duracionSegundos),
    ].join(' · ');
    return Card(
      child: ListTile(
        key: ValueKey('capsula-${capsula.id}'),
        title: Text(capsula.titulo),
        subtitle: Text(motivo == null ? detalle : '$detalle\n$motivo'),
        isThreeLine: motivo != null,
        trailing: completada
            ? const Icon(Icons.check_circle, semanticLabel: 'Completada')
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CapsulaScreen(capsulaId: capsula.id),
          ),
        ),
      ),
    );
  }
}
