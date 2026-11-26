# Capacitación · Escudo Cognitivo IESS

Módulo de capacitaciones (Bloque 2: recepción y verificación) hecho en Flutter. Primero móvil (Android/iOS); la web viene después.

## Estructura

```
lib/
├── main.dart              # ProviderScope + arranque
└── src/
    ├── app.dart           # MaterialApp
    ├── domain/            # entidades y reglas (Dart puro)
    ├── data/              # JSON local, API simulada, repositorios
    ├── application/       # casos de uso y providers (Riverpod)
    └── presentation/      # pantallas y widgets
assets/data/               # catálogo de cápsulas
```

## Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Versión usada: Flutter 3.50.1 (stable), Dart 3.14.0. Estado: `flutter_riverpod`.
