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

## Qué hace (lógica)

| Pieza | Archivo | Regla |
|---|---|---|
| Catálogo | `assets/data/capsulas.json` | 7 cápsulas breves (≤ 3 min) por tipología T1/T2/T3 y rango 18-29, 30-49, 50-64, 65+ |
| Filtro | `application/logica/filtro_capsulas.dart` | Tipología, rango, formato y solo pendientes |
| Recomendación | `application/logica/motor_recomendacion.dart` | Alerta del Observatorio > rango del usuario > pendientes; audio para 65+; repaso si el puntaje fue < 50 % |
| Quiz «¿Real o estafa?» | `application/logica/evaluador_quiz.dart` | Siempre explica; nunca castiga. Marcar un correo real como estafa se trata como prudencia |
| Verificación | `data/nucleo_api.dart` | Mock de `POST /api/v1/verify`: Black List → ROJO; sello válido → VERDE con metadatos sellados; revocado → ROJO; vencido, sin sello o desconocido → AMARILLO |
| Cápsula tras verificar | `application/logica/capsula_para_verificacion.dart` | Misma tipología suplantada, rango del usuario, pendiente y más corta |
| Progreso | `data/progreso_repository.dart` | Solo en el dispositivo (shared_preferences). No se envía al Núcleo |

Privacidad: el rango de edad es opcional y anonimizado; no se pide cédula ni nombre.

### Datos de prueba del mock

- Sello válido (T2, Prestaciones): `8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4`
- Sello revocado (T1, Afiliación): `1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b`
- Dominios en Black List: `iess-tramites-ec.com`, `biess-ec.net` (T2), `iess-gob-ec.info` (T1), `iess-agenda.com` (T3)
- Alerta activa: +40 % de phishing T2 en 65+

### Conectar con el Núcleo real (Bloque 3)

Implementar `NucleoApi` con HTTP y sobrescribir `nucleoApiProvider` en `lib/src/application/providers.dart`. El JSON esperado es el del documento técnico.

## Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build web --no-web-resources-cdn   # web sin depender del CDN de CanvasKit
```

Versión usada: Flutter 3.50.1 (stable), Dart 3.14.0. Estado: `flutter_riverpod`.
