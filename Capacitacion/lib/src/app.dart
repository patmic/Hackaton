import 'package:material_ui/material_ui.dart';

import 'presentation/screens/inicio_screen.dart';

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
      home: InicioScreen(),
    );
  }
}
