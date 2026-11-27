import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Muestra carga, error o datos de un AsyncValue.
class VistaAsync<T> extends StatelessWidget {
  const VistaAsync({super.key, required this.valor, required this.datos});

  final AsyncValue<T> valor;
  final Widget Function(T) datos;

  @override
  Widget build(BuildContext context) => valor.when(
    data: datos,
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('No se pudo cargar el contenido.\n$e'),
      ),
    ),
  );
}
