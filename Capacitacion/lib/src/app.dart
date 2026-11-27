import 'package:material_ui/material_ui.dart';

import 'presentation/rutas.dart';
import 'presentation/screens/inicio_screen.dart';

/// Raíz del módulo de capacitaciones del Escudo Cognitivo IESS.
///
/// Tema visual: ThemeGreen (recursos/Boilerplate/ThemeGreen). Dentro de AIESS se usa el tema completo de la app.
class CapacitacionApp extends StatelessWidget {
  const CapacitacionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capacitación IESS',
      debugShowCheckedModeBanner: false,
      theme: temaThemeGreen(),
      home: InicioScreen(),
      onGenerateRoute: generarRuta,
      onUnknownRoute: rutaDesconocida,
    );
  }
}

/// Tokens básicos de ThemeGreen (fondo --bg, acento --lime, texto --ink / --ink-dim).
ThemeData temaThemeGreen() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF070807),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF9DFF32),
    onPrimary: Color(0xFF0C1206),
    primaryContainer: Color(0xFF1C2A10),
    surface: Color(0xFF121411),
    onSurface: Color(0xFFF4F6F1),
    onSurfaceVariant: Color(0xFF8B918A),
    outline: Color(0xFF5A6157),
    error: Color(0xFFFF4D6D),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF070807),
    foregroundColor: Color(0xFFF4F6F1),
  ),
);
