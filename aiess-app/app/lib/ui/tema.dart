import 'dart:ui' show FontVariation;

import 'package:material_ui/material_ui.dart';
import 'package:theme_light/theme_light.dart';

/// Alias de uso interno para mantener las pantallas conectadas a los tokens
/// compartidos de ThemeLight.
class Tono {
  static const fondo = ThemeLightTokens.page;
  static const fondo2 = ThemeLightTokens.primaryContainer;
  static const superficie = ThemeLightTokens.background;
  static const superficieAlta = ThemeLightTokens.muted;
  static const tinta = ThemeLightTokens.foreground;
  static const tintaSuave = ThemeLightTokens.secondaryForeground;
  static const gris = ThemeLightTokens.mutedForeground;
  static const linea = ThemeLightTokens.border;
  static const borde = ThemeLightTokens.cardBorder;
  static const lima = ThemeLightTokens.theme;
  static const limaSuave = ThemeLightTokens.brand;
  static const sobreLima = ThemeLightTokens.background;
  static const azul2 = ThemeLightTokens.brand;
  static const cielo = ThemeLightTokens.brand;
  static const rojo = ThemeLightTokens.destructive;
  static const rojoSuave = ThemeLightTokens.errorBackground;
  static const verde = ThemeLightTokens.okForeground;
  static const verdeSuave = ThemeLightTokens.okBackground;
  static const ambar = ThemeLightTokens.warnForeground;

  static const azul = lima;
  static const azulOscuro = ThemeLightTokens.deep;
  static const amarillo = lima;
  static const azulSuave = ThemeLightTokens.primaryContainer;
  static const pelaje = lima;
  static const niebla = fondo;
}

/// Tipografía legible que se conserva también dentro del aula de capacitación.
class Letra {
  static const titulos = 'packages/theme_light/ThemeLightLexend';
  static const texto = 'packages/theme_light/ThemeLightAtkinson';

  static TextStyle lexend(
    double tam, {
    FontWeight peso = FontWeight.w600,
    Color? color,
    double alto = 1.2,
    double espacio = -0.2,
  }) => TextStyle(
    fontFamily: titulos,
    fontSize: tam,
    fontWeight: peso,
    fontVariations: [FontVariation('wght', peso.value.toDouble())],
    color: color,
    height: alto,
    letterSpacing: espacio,
  );

  static TextStyle lectura(
    double tam, {
    Color? color,
    FontWeight peso = FontWeight.w400,
    double alto = 1.5,
  }) => TextStyle(
    fontFamily: texto,
    fontSize: tam,
    fontWeight: peso,
    color: color,
    height: alto,
  );
}

/// Tema Flutter con la paleta, superficies y controles de ThemeLight.
ThemeData temaAIess() {
  final base = themeLight();
  final texto = TextTheme(
    displaySmall: Letra.lexend(34, peso: FontWeight.w700, alto: 1.1),
    headlineLarge: Letra.lexend(30, peso: FontWeight.w700, alto: 1.15),
    headlineMedium: Letra.lexend(26, peso: FontWeight.w700, alto: 1.2),
    headlineSmall: Letra.lexend(23, peso: FontWeight.w600, alto: 1.25),
    titleLarge: Letra.lexend(21, peso: FontWeight.w600, alto: 1.3),
    titleMedium: Letra.lexend(18, peso: FontWeight.w600, alto: 1.3, espacio: 0),
    titleSmall: Letra.lexend(16, peso: FontWeight.w600, alto: 1.3, espacio: 0),
    bodyLarge: Letra.lectura(19),
    bodyMedium: Letra.lectura(17),
    bodySmall: Letra.lectura(15, alto: 1.45),
    labelLarge: Letra.lexend(17, peso: FontWeight.w600, espacio: 0),
    labelMedium: Letra.lexend(15, peso: FontWeight.w500, espacio: 0),
    labelSmall: Letra.lexend(14, peso: FontWeight.w500, espacio: 0.2),
  ).apply(
    bodyColor: ThemeLightTokens.foreground,
    displayColor: ThemeLightTokens.foreground,
  );

  return base.copyWith(
    fontFamily: Letra.texto,
    textTheme: texto,
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: Letra.lexend(
        21,
        peso: FontWeight.w600,
        color: ThemeLightTokens.background,
        espacio: 0,
      ),
    ),
  );
}
