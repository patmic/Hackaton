// Usa material_ui (la librería Material de Flutter 3.50), la misma que AIESS y Capacitación:
// si se mezclara con package:flutter/material.dart, los temas no serían compatibles.
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Colores de `ThemeLight/tokens/tokens.json`, convertidos a colores Flutter.
abstract final class ThemeLightTokens {
  static const theme = Color(0xFF145962);
  static const brand = Color(0xFF355872);
  static const deep = Color(0xFF0E434B);
  static const nav = Color(0xFF0A1A26);

  static const page = Color(0xFFF8FAFC);
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF262626);
  static const muted = Color(0xFFF5F5F5);
  static const mutedForeground = Color(0xFF737373);
  static const border = Color(0xFFE5E5E5);
  static const cardBorder = Color(0xFFCBD5E1);

  static const primaryContainer = Color(0xFFE7F0F1);
  static const secondary = Color(0xFFF4F4F5);
  static const secondaryForeground = Color(0xFF303036);
  static const destructive = Color(0xFFC24132);

  static const okBackground = Color(0xFFECFDF5);
  static const okForeground = Color(0xFF065F46);
  static const warnBackground = Color(0xFFFFFBEB);
  static const warnForeground = Color(0xFF92400E);
  static const errorBackground = Color(0xFFFEF2F2);
  static const errorForeground = Color(0xFF991B1B);

  static const radius = 10.0;
  static const smallRadius = 6.0;
  static const mediumRadius = 8.0;
  static const largeRadius = 14.0;
}

/// Tema Material compartido por la aplicación AIESS y el módulo Capacitación.
ThemeData themeLight() {
  const fuenteTexto = 'packages/theme_light/ThemeLightAtkinson';
  const fuenteTitulos = 'packages/theme_light/ThemeLightLexend';
  const outline = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(ThemeLightTokens.mediumRadius),
    ),
    borderSide: BorderSide(color: ThemeLightTokens.border),
  );

  final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fuenteTexto,
    // Lectura en Atkinson Hyperlegible; títulos y etiquetas en Lexend.
    textTheme: _textos(fuenteTexto, fuenteTitulos),
    scaffoldBackgroundColor: ThemeLightTokens.page,
    colorScheme: const ColorScheme.light(
      primary: ThemeLightTokens.theme,
      onPrimary: ThemeLightTokens.background,
      primaryContainer: ThemeLightTokens.primaryContainer,
      onPrimaryContainer: ThemeLightTokens.deep,
      secondary: ThemeLightTokens.brand,
      onSecondary: ThemeLightTokens.background,
      secondaryContainer: ThemeLightTokens.secondary,
      onSecondaryContainer: ThemeLightTokens.secondaryForeground,
      surface: ThemeLightTokens.background,
      onSurface: ThemeLightTokens.foreground,
      surfaceContainerHighest: ThemeLightTokens.muted,
      onSurfaceVariant: ThemeLightTokens.mutedForeground,
      outline: ThemeLightTokens.border,
      outlineVariant: ThemeLightTokens.cardBorder,
      error: ThemeLightTokens.destructive,
      onError: ThemeLightTokens.background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeLightTokens.nav,
      foregroundColor: ThemeLightTokens.background,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: ThemeLightTokens.background,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeLightTokens.largeRadius),
        side: const BorderSide(color: ThemeLightTokens.cardBorder),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ThemeLightTokens.background,
      surfaceTintColor: Colors.transparent,
      indicatorColor: ThemeLightTokens.primaryContainer,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? ThemeLightTokens.deep
              : ThemeLightTokens.mutedForeground,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? ThemeLightTokens.theme
              : ThemeLightTokens.mutedForeground,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        backgroundColor: ThemeLightTokens.theme,
        foregroundColor: ThemeLightTokens.background,
        disabledBackgroundColor: ThemeLightTokens.muted,
        disabledForegroundColor: ThemeLightTokens.mutedForeground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeLightTokens.mediumRadius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        foregroundColor: ThemeLightTokens.deep,
        side: const BorderSide(color: ThemeLightTokens.cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeLightTokens.mediumRadius),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: ThemeLightTokens.background,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: outline,
      enabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(ThemeLightTokens.mediumRadius),
        ),
        borderSide: BorderSide(color: ThemeLightTokens.theme, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(ThemeLightTokens.mediumRadius),
        ),
        borderSide: BorderSide(color: ThemeLightTokens.destructive),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(ThemeLightTokens.mediumRadius),
        ),
        borderSide: BorderSide(color: ThemeLightTokens.destructive, width: 2),
      ),
    ),
    dividerColor: ThemeLightTokens.border,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ThemeLightTokens.nav,
      contentTextStyle: TextStyle(color: ThemeLightTokens.background),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ThemeLightTokens.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeLightTokens.largeRadius),
      ),
    ),
  );
  return theme;
}

TextTheme _textos(String texto, String titulos) {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light).textTheme.apply(fontFamily: texto);
  TextStyle? t(TextStyle? e) => e?.copyWith(fontFamily: titulos);
  return base.copyWith(
    displayLarge: t(base.displayLarge),
    displayMedium: t(base.displayMedium),
    displaySmall: t(base.displaySmall),
    headlineLarge: t(base.headlineLarge),
    headlineMedium: t(base.headlineMedium),
    headlineSmall: t(base.headlineSmall),
    titleLarge: t(base.titleLarge),
    titleMedium: t(base.titleMedium),
    titleSmall: t(base.titleSmall),
    labelLarge: t(base.labelLarge),
    labelMedium: t(base.labelMedium),
    labelSmall: t(base.labelSmall),
  );
}
