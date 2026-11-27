# ThemeLight para Flutter

Este paquete lleva a Flutter la paleta, tipografía, radios y estilos de controles del boilerplate ThemeLight. AIESS y Capacitación lo consumen como dependencia local para compartir tema en móvil y Web.

```yaml
dependencies:
  theme_light:
    path: ../recursos/Boilerplate/ThemeLight/flutter
```

Importa `package:theme_light/theme_light.dart`, asigna `themeLight()` a `MaterialApp.theme` y usa `ThemeLightTokens` para componentes que necesiten valores explícitos.

La tipografía conserva Lexend para títulos y Atkinson Hyperlegible para lectura. Los archivos de fuente se incluyen desde `assets/fonts/`.
