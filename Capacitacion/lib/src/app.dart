import 'package:material_ui/material_ui.dart';
import 'package:theme_light/theme_light.dart';

import 'presentation/rutas.dart';
import 'presentation/screens/inicio_screen.dart';

/// Raíz del módulo de capacitaciones del Escudo Cognitivo IESS.
///
/// Usa el tema compartido `themeLight()` (`recursos/Boilerplate/ThemeLight/flutter`).
class CapacitacionApp extends StatelessWidget {
  const CapacitacionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capacitación IESS',
      debugShowCheckedModeBanner: false,
      theme: themeLight(),
      home: const InicioScreen(),
      onGenerateRoute: generarRuta,
      onUnknownRoute: rutaDesconocida,
    );
  }
}
