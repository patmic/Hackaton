import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';

/// Simula el inicio de sesión con un usuario ficticio por tipo (guion de la
/// demo, CLAUDE.md §15). En producción el tipo viene del padrón o del
/// directorio, nunca de esta lista.
class SesionDemoScreen extends ConsumerWidget {
  const SesionDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actual = ref.watch(sesionProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Sesión de demostración')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Elige un usuario ficticio. Simula lo que devuelve el inicio de '
              'sesión (GET /api/v1/me): el tipo sale de una fuente oficial, '
              'no lo elige el usuario.',
            ),
          ),
          for (final s in sesionesDemo)
            ListTile(
              key: ValueKey('sesion-${_clave(s)}'),
              leading: Icon(
                identical(s, actual)
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(
                s.tieneCuenta ? s.nombreTipo : 'Sin cuenta (${s.nombreTipo})',
              ),
              subtitle: Text(_detalle(s)),
              onTap: () async {
                await ref.read(sesionProvider.notifier).iniciarSesionDemo(s);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  static String _clave(SesionUsuario s) {
    final tipos = s.tipos.toList()..sort((a, b) => a.index.compareTo(b.index));
    return tipos.map((t) => t.codigo).join('-');
  }

  static String _detalle(SesionUsuario s) => [
    s.tipos.map((t) => t.codigo).join(' + '),
    'Perfil: ${s.perfilConducta.etiquetaVisible}',
    if (s.rangoEtario != null) 'Rango: ${s.rangoEtario!.codigo}',
  ].join(' · ');
}
