import 'dart:ui' show FontVariation;

import 'package:material_ui/material_ui.dart';

/// Colores IESS compartidos por toda la app (mismo estilo que el aula virtual).
class Tono {
  static const azul = Color(0xFF004294); // azul IESS
  static const azulOscuro = Color(0xFF183675);
  static const amarillo = Color(0xFFFCC602); // amarillo IESS
  static const tinta = Color(0xFF14213D); // texto principal (contraste 15:1 sobre blanco)
  static const gris = Color(0xFF4A5468); // texto secundario (contraste 7.9:1, AAA)
  static const fondo = Color(0xFFF4F6FA);
  static const rojo = Color(0xFFB3261E); // 6.5:1 con blanco
  static const rojoSuave = Color(0xFFFDECEA);
  static const verde = Color(0xFF17703A); // 6.2:1 con blanco
  static const verdeSuave = Color(0xFFE6F4EA);
  static const azulSuave = Color(0xFFE3ECF8);
  static const borde = Color(0xFFD5DCE8);
  // Nombres antiguos (ajustes).
  static const pelaje = azul;
  static const niebla = fondo;
}

/// Tipografía de AIESS, legible para todas las edades:
/// - **Lexend** (títulos, botones, navegación): creada para leer con menos esfuerzo; se ve seria y moderna.
/// - **Atkinson Hyperlegible** (texto para leer): creada para baja visión; letras que no se confunden (I l 1, O 0).
/// Texto de lectura ≥ 18 sp con interlineado 1.5; nada por debajo de 14 sp.
class Letra {
  static const titulos = 'Lexend';
  static const texto = 'Atkinson';

  /// Estilo Lexend con el peso aplicado también al eje variable de la fuente.
  static TextStyle lexend(double tam, {FontWeight peso = FontWeight.w600, Color? color, double alto = 1.2, double espacio = -0.2}) =>
      TextStyle(
        fontFamily: titulos,
        fontSize: tam,
        fontWeight: peso,
        fontVariations: [FontVariation('wght', peso.value.toDouble())],
        color: color,
        height: alto,
        letterSpacing: espacio,
      );

  static TextStyle lectura(double tam, {Color? color, FontWeight peso = FontWeight.w400, double alto = 1.5}) =>
      TextStyle(fontFamily: texto, fontSize: tam, fontWeight: peso, color: color, height: alto);
}

/// Tema único de AIESS: Material 3 claro, AppBar azul IESS, tarjetas blancas y barra de navegación inferior,
/// igual que el aula virtual.
ThemeData temaAIess() {
  final esquema = ColorScheme.fromSeed(seedColor: Tono.azul, brightness: Brightness.light).copyWith(
    primary: Tono.azul,
    onPrimary: Colors.white,
    secondary: Tono.amarillo,
    onSecondary: Tono.tinta,
    secondaryContainer: const Color(0xFFFFF1B8),
    onSecondaryContainer: Tono.tinta,
    surface: Colors.white,
    onSurface: Tono.tinta,
    onSurfaceVariant: Tono.gris,
    outline: Tono.borde,
    error: Tono.rojo,
  );
  final base = ThemeData(useMaterial3: true, fontFamily: Letra.texto, colorScheme: esquema);
  final redondo = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
  // Escala tipográfica: títulos en Lexend, lectura en Atkinson (tamaños pensados para personas mayores).
  final textos = TextTheme(
    displaySmall: Letra.lexend(34, peso: FontWeight.w700, alto: 1.15, espacio: -0.6),
    headlineLarge: Letra.lexend(30, peso: FontWeight.w700, alto: 1.15, espacio: -0.5),
    headlineMedium: Letra.lexend(26, peso: FontWeight.w700, alto: 1.2, espacio: -0.4),
    headlineSmall: Letra.lexend(23, peso: FontWeight.w600, alto: 1.25),
    titleLarge: Letra.lexend(21, peso: FontWeight.w600, alto: 1.3),
    titleMedium: Letra.lexend(18, peso: FontWeight.w600, alto: 1.3, espacio: 0),
    titleSmall: Letra.lexend(16, peso: FontWeight.w600, alto: 1.3, espacio: 0),
    bodyLarge: Letra.lectura(19),
    bodyMedium: Letra.lectura(17),
    bodySmall: Letra.lectura(15, alto: 1.45),
    labelLarge: Letra.lexend(17, peso: FontWeight.w600, espacio: 0),
    labelMedium: Letra.lexend(15, peso: FontWeight.w500, espacio: 0),
    labelSmall: Letra.lexend(14, peso: FontWeight.w500, espacio: 0.1),
  ).apply(bodyColor: Tono.tinta, displayColor: Tono.tinta);

  return base.copyWith(
    scaffoldBackgroundColor: Tono.fondo,
    textTheme: textos,
    appBarTheme: AppBarTheme(
      backgroundColor: Tono.azul,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: Letra.lexend(21, peso: FontWeight.w600, color: Colors.white, espacio: 0),
    ),
    cardTheme: CardThemeData(color: Colors.white, elevation: 1, shadowColor: Colors.black26, margin: EdgeInsets.zero, shape: redondo),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      height: 76,
      indicatorColor: const Color(0xFFFFE27A),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => Letra.lexend(15,
          peso: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500, color: Tono.tinta, espacio: 0)),
      iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? Tono.tinta : Tono.gris, size: 28)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(0, 56), shape: redondo, textStyle: Letra.lexend(18, espacio: 0)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: redondo,
        side: const BorderSide(color: Tono.azul, width: 1.5),
        foregroundColor: Tono.azul,
        textStyle: Letra.lexend(17, espacio: 0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48), textStyle: Letra.lexend(17, espacio: 0)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: Letra.lexend(17, peso: FontWeight.w500, color: Tono.gris, espacio: 0),
      hintStyle: Letra.lectura(17, color: const Color(0xFF7A8396)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, contentTextStyle: Letra.lectura(17, color: Colors.white)),
    listTileTheme: ListTileThemeData(titleTextStyle: Letra.lexend(18, espacio: 0, color: Tono.tinta), subtitleTextStyle: Letra.lectura(16, color: Tono.gris)),
  );
}
