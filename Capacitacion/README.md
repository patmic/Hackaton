# Capacitación · Escudo Cognitivo IESS

Módulo de capacitaciones (Bloque 2: recepción y verificación) hecho en Flutter. Primero móvil (Android/iOS); la web viene después.

> Estado: los commits marcados «sin verificar» no pasaron todavía por `flutter analyze` ni `flutter test` (ver `docs/CONTEXTO_MODULO.md`).

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
assets/data/actividades.json   # catálogo de actividades (formato JSON de CLAUDE.md §12)
docs/CONTEXTO_MODULO.md        # guía de trabajo del módulo
```

## Qué hace (lógica)

Fuente de las reglas: `CLAUDE.md` de esta carpeta (lo marcado [DECIDIDO] manda) y `diagramas/diagrama.drawio.xml`.

| Pieza | Archivo | Regla |
|---|---|---|
| Indicios I1-I11 | `domain/indicio.dart` | Catálogo oficial (§6). Un correo es phishing si tiene al menos uno |
| Microcurso por indicio | `domain/microcurso.dart` | Tabla de §11. I5 e I8 cambian de módulo según el tipo |
| Tipos de usuario | `domain/tipo_usuario.dart` | EX1-EX5 e IN1-IN4 (§7), de fuente oficial. Sin sesión: EX5 |
| Perfil de conducta | `domain/perfil_conducta.dart` | Lo calcula el Núcleo. «Expuesto» se muestra como «En aprendizaje» (regla 7) |
| Módulos y mecánicas | `domain/modulo.dart`, `domain/mecanica.dart` | M1-M14 (§10.2), A1-A9 (§10.3) y modelo 4R |
| Rutas | `domain/ruta.dart`, `application/logica/plan_capacitacion.dart` | Arranque y refuerzo por tipo (§10.4); varios tipos se combinan sin repetir |
| Actividades | `domain/actividad.dart`, `domain/contenido_actividad.dart` | JSON de §12 + contenido por mecánica. Un EX2 ve la `variante_ex2` en audio |
| Recomendación | `application/logica/motor_recomendacion.dart` | Alerta activa > paso de la ruta de arranque > refuerzo según el ataque activo > pendientes; repaso si el puntaje fue < 50 % |
| ¿Real o estafa? (A2) | `application/logica/evaluador_real_o_estafa.dart` | Siempre explica; nunca castiga. Marcar un correo real como estafa es prudencia |
| Verificación | `data/nucleo_api.dart` | Mock de `POST /api/v1/verify` (la fase 2 lo cambia por `GET /verificar/{hash_2}` del diagrama) |
| Actividad tras verificar | `application/logica/actividad_para_verificacion.dart` | Misma tipología suplantada, que le corresponda al tipo, pendiente y más corta |
| Progreso | `data/progreso_repository.dart` | Solo en el dispositivo (shared_preferences) |

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
