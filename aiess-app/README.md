# AIESS

AIESS reúne la aplicación móvil y la interfaz web de escritorio, con el mismo flujo de revisión, aprendizaje y práctica.

## Interfaces

- `app/`: aplicación Flutter para Android y Web. En pantallas anchas usa `lib/ui/web_escritorio.dart`; en móvil y web angosta usa la interfaz adaptable de `lib/ui/inicio_page.dart`.
- `../Capacitacion/`: módulo Flutter de capacitación integrado en AIESS y reutilizable por separado. Ambos usan los tokens y componentes de `../recursos/Boilerplate/ThemeLight/flutter`.
- `../SellaCorreo/`: herramienta web institucional. Su hoja de tokens se basa en `../recursos/Boilerplate/ThemeLight`.

## Ejecutar Flutter

Desde `app/`:

```powershell
flutter pub get
flutter run -d chrome
flutter run -d android
```

## Modelo y servidor

- `ml/`: generación del conjunto de entrenamiento y evaluación local.
- `servidor/`: API de análisis remoto y despliegue.
- `docs/ARQUITECTURA.md`: componentes y flujo de datos.
