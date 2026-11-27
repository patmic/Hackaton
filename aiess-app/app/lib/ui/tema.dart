import 'package:material_ui/material_ui.dart';

/// Colores IESS compartidos por toda la app (mismo estilo que el aula virtual).
class Tono {
  static const azul = Color(0xFF004294); // azul IESS
  static const azulOscuro = Color(0xFF183675);
  static const amarillo = Color(0xFFFCC602); // amarillo IESS
  static const tinta = Color(0xFF14213D);
  static const gris = Color(0xFF5B6478);
  static const fondo = Color(0xFFF4F6FA);
  static const rojo = Color(0xFFC62828);
  static const rojoSuave = Color(0xFFFDECEA);
  static const verde = Color(0xFF1B7F3B);
  static const verdeSuave = Color(0xFFE6F4EA);
  static const azulSuave = Color(0xFFE3ECF8);
  // Nombres antiguos (ajustes).
  static const pelaje = azul;
  static const niebla = fondo;
}

/// Tema único de AIESS: Material 3 claro, AppBar azul IESS, tarjetas blancas y barra de navegación inferior,
/// igual que el aula virtual. Letra Atkinson (pensada para baja visión).
ThemeData temaAIess() {
  const fuente = 'Atkinson';
  final esquema = ColorScheme.fromSeed(seedColor: Tono.azul, brightness: Brightness.light).copyWith(
    primary: Tono.azul,
    onPrimary: Colors.white,
    secondary: Tono.amarillo,
    onSecondary: Tono.tinta,
    secondaryContainer: const Color(0xFFFFF1B8),
    onSecondaryContainer: Tono.tinta,
    surface: Colors.white,
    onSurface: Tono.tinta,
    error: Tono.rojo,
  );
  final base = ThemeData(useMaterial3: true, fontFamily: fuente, colorScheme: esquema);
  final redondo = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
  return base.copyWith(
    scaffoldBackgroundColor: Tono.fondo,
    textTheme: base.textTheme.apply(fontFamily: fuente, bodyColor: Tono.tinta, displayColor: Tono.tinta),
    appBarTheme: const AppBarTheme(
      backgroundColor: Tono.azul,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: fuente, fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    cardTheme: CardThemeData(color: Colors.white, elevation: 1, shadowColor: Colors.black26, margin: EdgeInsets.zero, shape: redondo),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFFFE27A),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontFamily: fuente, fontSize: 14, fontWeight: FontWeight.w600)),
      iconTheme: WidgetStateProperty.resolveWith((s) =>
          IconThemeData(color: s.contains(WidgetState.selected) ? Tono.tinta : Tono.gris, size: 26)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: redondo,
        textStyle: const TextStyle(fontFamily: fuente, fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: redondo,
        textStyle: const TextStyle(fontFamily: fuente, fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
