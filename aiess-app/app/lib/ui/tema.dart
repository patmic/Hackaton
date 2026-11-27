import 'dart:ui' show FontVariation;

import 'package:material_ui/material_ui.dart';

/// Tokens de **ThemeGreen** (recursos/Boilerplate/ThemeGreen/tokens/tokens.json del repo del equipo):
/// tema oscuro, acento verde lima, superficies tipo vidrio, botones en píldora.
/// Reglas del kit: fondo siempre oscuro; el lima solo para la acción principal y el estado activo.
/// Accesibilidad: no se usa `ink-faint` (#4a4f49) para texto (contraste 2.3:1); el texto secundario es `ink-dim`.
class Tono {
  // --- ThemeGreen
  static const fondo = Color(0xFF070807); // --bg
  static const fondo2 = Color(0xFF0B0D0A); // --bg-2
  static const superficie = Color(
    0xFF121411,
  ); // --surface-glass (rgba 255,.045) sobre --bg
  static const superficieAlta = Color(0xFF181B16); // vidrio con hover
  static const tinta = Color(0xFFF4F6F1); // --ink (18:1 sobre el fondo)
  static const tintaSuave = Color(0xFFDFE3DC); // --ink-soft
  static const gris = Color(
    0xFF8B918A,
  ); // --ink-dim (5.6:1 sobre la superficie, AA)
  static const linea = Color(0x1AFFFFFF); // --line
  static const borde = Color(0xFF5A6157); // borde de control (3:1, WCAG 1.4.11)
  static const lima = Color(0xFF9DFF32); // --lime (acento)
  static const limaSuave = Color(0xFF6FD21A); // --lime-soft
  static const sobreLima = Color(
    0xFF0C1206,
  ); // --on-lime (texto sobre el acento)
  static const azul2 = Color(0xFF4C8DFF); // --blue
  static const cielo = Color(0xFF8EC6EA); // --sky
  static const rojo = Color(0xFFFF4D6D); // --live (veredicto: estafa)
  static const rojoSuave = Color(0xFF2A1016);
  static const verde = Color(0xFF3DDC4A); // --accent-green (veredicto: seguro)
  static const verdeSuave = Color(0xFF0F2412);
  static const ambar = Color(0xFFFFB020); // --accent-amber

  // --- Nombres usados en las pantallas (apuntan a los tokens de ThemeGreen)
  static const azul = lima; // acción principal
  static const azulOscuro = fondo2;
  static const amarillo = lima;
  static const azulSuave = fondo2;
  static const pelaje = lima;
  static const niebla = fondo;
}

/// Tipografía de AIESS, legible para todas las edades:
/// - **Lexend** (títulos, botones, navegación): creada para leer con menos esfuerzo; se ve seria y moderna.
/// - **Atkinson Hyperlegible** (texto para leer): creada para baja visión; letras que no se confunden (I l 1, O 0).
/// (ThemeGreen usa Plus Jakarta Sans; su README permite cambiarla por fuentes locales.)
/// Texto de lectura ≥ 18 sp con interlineado 1.5; nada por debajo de 14 sp.
class Letra {
  static const titulos = 'Lexend';
  static const texto = 'Atkinson';

  /// Estilo Lexend con el peso aplicado también al eje variable de la fuente.
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

/// Radios de ThemeGreen.
class Radios {
  static const pildora = 999.0; // --r-pill
  static const xl = 26.0;
  static const lg = 18.0;
  static const md = 16.0;
  static const sm = 12.0;
}

/// Tema único de AIESS con ThemeGreen: oscuro, acento lima, vidrio y píldoras.
ThemeData temaAIess() {
  final esquema = const ColorScheme.dark(
    primary: Tono.lima,
    onPrimary: Tono.sobreLima,
    primaryContainer: Color(0xFF1C2A10),
    onPrimaryContainer: Tono.lima,
    secondary: Tono.cielo,
    onSecondary: Tono.sobreLima,
    secondaryContainer: Color(0xFF1A2530),
    onSecondaryContainer: Tono.tinta,
    surface: Tono.superficie,
    onSurface: Tono.tinta,
    onSurfaceVariant: Tono.gris,
    surfaceContainerHighest: Color(0xFF22261F),
    surfaceContainerHigh: Tono.superficieAlta,
    surfaceContainer: Tono.superficie,
    surfaceContainerLow: Tono.fondo2,
    outline: Tono.borde,
    outlineVariant: Color(0xFF2A2E27),
    error: Tono.rojo,
    onError: Tono.sobreLima,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: Letra.texto,
    colorScheme: esquema,
  );
  final pildora = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radios.pildora),
  );
  final textos = TextTheme(
    displaySmall: Letra.lexend(
      34,
      peso: FontWeight.w700,
      alto: 1.1,
      espacio: -0.8,
    ),
    headlineLarge: Letra.lexend(
      30,
      peso: FontWeight.w700,
      alto: 1.15,
      espacio: -0.6,
    ),
    headlineMedium: Letra.lexend(
      26,
      peso: FontWeight.w700,
      alto: 1.2,
      espacio: -0.5,
    ),
    headlineSmall: Letra.lexend(
      23,
      peso: FontWeight.w600,
      alto: 1.25,
      espacio: -0.3,
    ),
    titleLarge: Letra.lexend(21, peso: FontWeight.w600, alto: 1.3),
    titleMedium: Letra.lexend(18, peso: FontWeight.w600, alto: 1.3, espacio: 0),
    titleSmall: Letra.lexend(16, peso: FontWeight.w600, alto: 1.3, espacio: 0),
    bodyLarge: Letra.lectura(19),
    bodyMedium: Letra.lectura(17),
    bodySmall: Letra.lectura(15, alto: 1.45),
    labelLarge: Letra.lexend(17, peso: FontWeight.w600, espacio: 0),
    labelMedium: Letra.lexend(15, peso: FontWeight.w500, espacio: 0),
    labelSmall: Letra.lexend(14, peso: FontWeight.w500, espacio: 0.2),
  ).apply(bodyColor: Tono.tinta, displayColor: Tono.tinta);

  return base.copyWith(
    scaffoldBackgroundColor: Tono.fondo,
    textTheme: textos,
    appBarTheme: AppBarTheme(
      backgroundColor: Tono.fondo,
      foregroundColor: Tono.tinta,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      shape: const Border(bottom: BorderSide(color: Tono.linea)),
      titleTextStyle: Letra.lexend(
        21,
        peso: FontWeight.w600,
        color: Tono.tinta,
        espacio: 0,
      ),
    ),
    // .tg-card: vidrio con borde --line y radio xl.
    cardTheme: CardThemeData(
      color: Tono.superficie,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radios.lg),
        side: const BorderSide(color: Tono.linea),
      ),
    ),
    // .tg-pillnav: el activo va en lima con texto oscuro.
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Tono.fondo2,
      surfaceTintColor: Colors.transparent,
      height: 76,
      indicatorColor: Tono.lima,
      indicatorShape: pildora,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => Letra.lexend(
          15,
          peso: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? Tono.tinta : Tono.gris,
          espacio: 0,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? Tono.sobreLima : Tono.gris,
          size: 28,
        ),
      ),
    ),
    // .tg-btn--solid: píldora lima, texto oscuro. Anillo de foco visible para quien usa el teclado.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: pildora,
        backgroundColor: Tono.lima,
        foregroundColor: Tono.sobreLima,
        disabledBackgroundColor: const Color(0xFF2A2E27),
        disabledForegroundColor: Tono.gris,
        textStyle: Letra.lexend(18, espacio: 0),
      ).copyWith(side: _anillo(Tono.tinta, null)),
    ),
    // .tg-btn--outline
    outlinedButtonTheme: OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
            minimumSize: const Size(0, 56),
            shape: pildora,
            foregroundColor: Tono.tinta,
            backgroundColor: Tono.superficie,
            textStyle: Letra.lexend(17, espacio: 0),
          ).copyWith(
            side: _anillo(
              Tono.lima,
              const BorderSide(color: Tono.borde, width: 1.5),
            ),
          ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: Tono.lima,
        shape: pildora,
        textStyle: Letra.lexend(17, espacio: 0),
      ).copyWith(side: _anillo(Tono.lima, null)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Tono.superficie,
      selectedColor: Tono.lima,
      side: const BorderSide(color: Tono.borde),
      shape: pildora,
      labelStyle: Letra.lexend(
        15,
        peso: FontWeight.w500,
        espacio: 0,
        color: Tono.tinta,
      ),
      secondaryLabelStyle: Letra.lexend(
        15,
        peso: FontWeight.w600,
        espacio: 0,
        color: Tono.sobreLima,
      ),
      checkmarkColor: Tono.sobreLima,
    ),
    // .tg-search: campo oscuro; el foco se marca en lima.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0D100C),
      labelStyle: Letra.lexend(
        17,
        peso: FontWeight.w500,
        color: Tono.gris,
        espacio: 0,
      ),
      floatingLabelStyle: Letra.lexend(
        17,
        peso: FontWeight.w600,
        color: Tono.lima,
        espacio: 0,
      ),
      hintStyle: Letra.lectura(17, color: Tono.gris),
      helperStyle: Letra.lectura(15, color: Tono.gris),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radios.lg),
        borderSide: const BorderSide(color: Tono.borde, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radios.lg),
        borderSide: const BorderSide(color: Tono.lima, width: 2.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radios.lg),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Tono.lima,
      linearTrackColor: Color(0xFF22261F),
    ),
    dividerTheme: const DividerThemeData(color: Tono.linea),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Tono.superficieAlta,
      contentTextStyle: Letra.lectura(17, color: Tono.tinta),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radios.md),
        side: const BorderSide(color: Tono.linea),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Tono.fondo2,
      surfaceTintColor: Colors.transparent,
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: Letra.lexend(18, espacio: 0, color: Tono.tinta),
      subtitleTextStyle: Letra.lectura(16, color: Tono.gris),
      iconColor: Tono.gris,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Tono.sobreLima : Tono.gris,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? Tono.lima
            : const Color(0xFF22261F),
      ),
    ),
  );
}

/// Borde de 3 dp cuando el control tiene el foco del teclado; si no, [normal].
WidgetStateProperty<BorderSide?> _anillo(Color color, BorderSide? normal) =>
    WidgetStateProperty.resolveWith(
      (e) => e.contains(WidgetState.focused)
          ? BorderSide(
              color: color,
              width: 3,
              strokeAlign: BorderSide.strokeAlignOutside,
            )
          : normal,
    );
