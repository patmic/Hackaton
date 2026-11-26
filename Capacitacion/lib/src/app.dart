import 'package:material_ui/material_ui.dart';

/// Raíz del módulo de capacitaciones del Escudo Cognitivo IESS.
///
/// El tema visual (ThemeGreen) se aplica en la fase de diseño.
class CapacitacionApp extends StatelessWidget {
  const CapacitacionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Capacitación IESS',
      debugShowCheckedModeBanner: false,
      home: _InicioPlaceholder(),
    );
  }
}

class _InicioPlaceholder extends StatelessWidget {
  const _InicioPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Módulo de capacitaciones')),
    );
  }
}
