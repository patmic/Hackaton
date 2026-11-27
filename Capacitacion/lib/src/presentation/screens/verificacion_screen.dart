import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/resultado_verificacion_view.dart';

/// Pantalla que abre el botón «Verificar en App» del correo (paso 6 del
/// diagrama). Verifica el código apenas se abre.
class VerificacionScreen extends ConsumerStatefulWidget {
  const VerificacionScreen({super.key, required this.codigo});

  /// Código tal como vino en el enlace. Se valida al verificar.
  final String codigo;

  @override
  ConsumerState<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends ConsumerState<VerificacionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(verificacionProvider.notifier)
          .verificar(codigo: widget.codigo, origen: OrigenCodigo.appLink),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(verificacionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación del correo')),
      body: estado.when(
        data: (e) => e == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Código recibido desde el botón «Verificar en App».',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  ResultadoVerificacionView(estado: e),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              err is FormatException ? err.message : 'No se pudo verificar.',
            ),
          ),
        ),
      ),
    );
  }
}
