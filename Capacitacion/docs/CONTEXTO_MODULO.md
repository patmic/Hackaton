# Contexto para Claude Code · Módulo de Capacitaciones (Escudo Cognitivo IESS)

Este archivo es la guía de trabajo para Claude Code en VS Code. Léelo completo antes de hacer cambios.

---

## 1. Qué es el proyecto

Hackatón del IESS (Ecuador), reto **«Seguridad inteligente, cultura consciente»**. La solución se llama **Escudo Cognitivo IESS** y se apoya en tres pilares:

1. **Tipologías de correo oficial**
   - `T1` Informativo
   - `T2` Financiero / Previsional
   - `T3` Trámites / Clínico
2. **Sellado ligero con hash (HMAC-SHA256).** El correo legítimo lleva un código o QR que se verifica *dentro* del canal oficial. El Núcleo nunca recibe el cuerpo del correo.
3. **Observatorio de Seguridad Cognitiva.** Cada verificación o reporte alimenta métricas por tipología y rango de edad, para hipersegmentar la concientización.

Rangos de edad anonimizados: `18-29`, `30-49`, `50-64` y `65+`.

**Fuentes de contexto en el repo (en orden de prioridad):**
- `Capacitacion/CLAUDE.md`: contexto completo del producto (indicios I1-I11, tipos de usuario EX/IN, módulos M1-M14, mecánicas A1-A9, flujo «Quiero capacitarme», contratos). **Manda lo marcado [DECIDIDO].** Reemplaza a la carpeta `Clasificacion/`, que no existe en el repo.
- `diagramas/diagrama.drawio.xml`: arquitectura del equipo. Proxy SMTP con Hash 1 (identidad del remitente) y Hash 2 (contenido), botón «Verificar en App» que abre la app con el Hash 2 por App Link, `GET /verificar/{hash_2}`, IA de análisis y «API de Capacitación».
- `inteligencia_colectiva_flujos_t_cnicos_mvp_y_an_lisis_del_d_cimo_hombre.md`: documento técnico del MVP, contratos de API y los 6 fallos del Décimo Hombre.
- `obsidian/`: investigación. Las notas más útiles son `1-Investigacion/07 Evidencia cientifica.md` y `1-Investigacion/09 Criterios de diseno.md`.
- `recursos/Boilerplate/ThemeGreen/`: sistema de diseño que se usará en la etapa visual.

### Decisiones del 2026-11-26

| Tema | Decisión |
|---|---|
| Ubicación | Todo va en `Capacitacion/`. La app Flutter queda en la raíz de esa carpeta. |
| Verificación | La app consume `GET /verificar/{hash_2}` (el del diagrama) con un **adaptador** que lo traduce al semáforo del dominio. Si el Núcleo pasa a `POST /api/v1/verify`, solo cambia el adaptador. |
| API de Capacitación | Solo **cliente + mock** en Flutter. La API real la construye otro bloque. |
| IA de análisis | La hace **otro bloque**. La app solo muestra la explicación que devuelve el servidor. |
| Fuera de alcance | Consola interna web (emitir, observatorio, revocación, roles) y mecánicas A8/A9 para internos. |

### División del equipo

| Bloque | Módulo | Responsables |
|---|---|---|
| 1 | Emisión y sellado (hash/QR, `POST /api/v1/hashes/register`) | Patric / Dani |
| 2 | Recepción y verificación + **capacitación** (este módulo) | Isaac / Sergio |
| 3 | Núcleo central (White/Black List) y Observatorio | Luis / Jhair |

---

## 2. Instrucciones del usuario (obligatorias)

- Todo el trabajo va en la carpeta **`Capacitacion/`** en la raíz del repo `Hackaton`.
- **Primero la lógica en Flutter para móvil.** El diseño viene después, primero en móvil y luego en web.
- Los estilos salen del template **`recursos/Boilerplate/ThemeGreen`**.
- **Antes de implementar algo nuevo, presenta las fases planeadas** y espera confirmación.
- **Avisa cada commit** que hagas, con hash y mensaje.
- Escribe en español: código del dominio, textos, commits y documentación.
- Haz un commit por fase, con mensajes del tipo `feat(capacitacion): ...`, `test(capacitacion): ...` o `docs(capacitacion): ...`.

---

## 3. Recuperar el trabajo ya hecho (HECHO el 2026-11-26)

Los commits del bundle ya están en la rama local `capacitacion-flutter`, integrada con `main` (merge `6ce9a72`) y con `origin/main` (merge `631361a`). Esta sección queda como referencia por si otro integrante necesita repetirlo.

Hay 7 commits que se hicieron en una sesión en la nube y **no se pudieron subir a GitHub** (error 403 por permisos). Vienen en el archivo `capacitacion.bundle`, que acompaña a este documento.

Desde la raíz del repo local `Hackaton`:

```bash
git fetch origin
```

```bash
git bundle verify ruta/a/capacitacion.bundle
```

```bash
git fetch ruta/a/capacitacion.bundle claude/awesome-shannon-jy7nvv:capacitacion-flutter
```

```bash
git checkout capacitacion-flutter
```

El bundle parte del commit `9b1f986` («Add initial draft of the Escudo Cognitivo IESS document…»), así que ese commit tiene que existir en el repo local. Después se puede integrar a la rama de trabajo del equipo con `merge` o `rebase` y subir con `git push`.

**Commits incluidos:**

| Hash | Mensaje |
|---|---|
| `2c1cf96` | feat(capacitacion): proyecto Flutter base |
| `5c026fe` | feat(capacitacion): modelos de dominio |
| `68d427d` | feat(capacitacion): catálogo y repositorios |
| `04eef0b` | feat(capacitacion): lógica de recomendación y quiz |
| `ac7b2c9` | feat(capacitacion): estado y flujo navegable |
| `5c9ca43` | feat(capacitacion): integración simulada con núcleo |
| `89320eb` | test(capacitacion): pruebas de lógica y flujos |

---

## 4. Stack y comandos

- **Versiones:** Flutter **3.50.1** stable, Dart 3.14.0.
- **Plataformas:** Android, iOS y web. El identificador de la app es `ec.iess.capacitacion`.
- **Dependencias:** `flutter_riverpod` 3.5, `material_ui` 1.11 y `shared_preferences`.

Comandos, desde `Capacitacion/`:

```bash
flutter pub get
```

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter run
```

```bash
flutter build web --no-web-resources-cdn
```

**Estado actual:** en la sesión en la nube, `flutter analyze` no reportó problemas y las **40 pruebas pasaron**. Desde el 2026-11-26 se trabaja en una máquina sin Flutter (la red no permitió descargar el SDK), así que los commits marcados **«sin verificar»** todavía no pasaron por `dart format`, `flutter analyze` ni `flutter test`. En cuanto haya Flutter, hay que correr los tres comandos y corregir en un commit aparte.

### Cosas a tener en cuenta

- En Flutter 3.50, `package:flutter/material.dart` está **obsoleto**. Se importa `package:material_ui/material_ui.dart`, que tiene la misma API. Si un integrante usa un Flutter anterior a 3.47, tiene que actualizar o revertir ese import.
- En web, sin `--no-web-resources-cdn`, la app descarga CanvasKit desde `gstatic.com` y en algunas redes no carga.
- Las reglas de lint son estrictas: `prefer_single_quotes`, `require_trailing_commas`, `strict-casts`, entre otras. Corre `dart format lib test` antes de cada commit.

---

## 5. Arquitectura (actualizada en la fase 1)

```
Capacitacion/
├── CLAUDE.md                          # contexto del producto (fuente principal)
├── docs/CONTEXTO_MODULO.md            # esta guía
├── assets/data/actividades.json       # catálogo: 9 actividades (M1-M7), JSON de CLAUDE.md §12
├── lib/
│   ├── main.dart                      # ProviderScope + arranque
│   └── src/
│       ├── app.dart                   # MaterialApp (aquí irá el ThemeData de ThemeGreen)
│       ├── domain/                    # Dart puro, sin Flutter
│       │   ├── indicio.dart           # I1-I11 (§6)
│       │   ├── microcurso.dart        # microcurso por indicio (§11)
│       │   ├── tipo_usuario.dart      # EX1-EX5, IN1-IN4 y Zona (§7)
│       │   ├── perfil_conducta.dart   # Centinela, Prudente, Expuesto («En aprendizaje»)…
│       │   ├── mecanica.dart          # A1-A9 y Paso4R
│       │   ├── modulo.dart            # M1-M14 (§10.2), catálogo constante
│       │   ├── ruta.dart              # rutas por tipo (§10.4)
│       │   ├── mensaje_simulado.dart  # mensaje ficticio y zonas de señal (A1)
│       │   ├── contenido_actividad.dart # contenido por mecánica (sealed)
│       │   ├── actividad.dart         # actividad + elegibilidad por tipo
│       │   ├── perfil.dart            # tipos, perfil de conducta, rango opcional, cuidador
│       │   ├── progreso.dart, resultado_actividad.dart, alerta_observatorio.dart
│       │   ├── verificacion.dart      # Semaforo, Solicitud/ResultadoVerificacion
│       │   ├── tipologia.dart, rango_etario.dart, json.dart
│       │   └── domain.dart            # barrel
│       ├── data/
│       │   ├── actividad_repository.dart # interfaz + Asset (JSON) + Memoria
│       │   ├── progreso_repository.dart  # interfaz + SharedPreferencesAsync + Memoria
│       │   └── nucleo_api.dart           # interfaz NucleoApi + MockNucleoApi
│       ├── application/
│       │   ├── logica/  plan_capacitacion, motor_recomendacion, filtro_actividades,
│       │   │            evaluador_real_o_estafa, actividad_para_verificacion
│       │   └── providers.dart         # todos los providers de Riverpod
│       └── presentation/
│           ├── screens/  inicio_screen (4 pestañas), para_ti_tab, verificar_tab,
│           │             catalogo_tab, progreso_tab, actividad_screen, real_o_estafa_screen
│           └── widgets/  actividad_tile, mensaje_card, selector_rango, vista_async
└── test/  domain/ (modelos, rutas), logica/, data/, presentation/flujos_test.dart, widget_test.dart
```

### Providers principales (`application/providers.dart`)

- **Dependencias:** `actividadRepositoryProvider`, `progresoRepositoryProvider` y `nucleoApiProvider`. Se sobrescriben en las pruebas.
- **Perfil:** `perfilProvider` (tipos, perfil de conducta, rango, cuidador). `asignarTipos` lo usará la sesión de la fase 3.
- **Catálogo:** `catalogoProvider`, `actividadPorIdProvider(id)`, `actividadesDelPerfilProvider`, `filtroProvider` y `actividadesFiltradasProvider`.
- **Progreso:** `progresoProvider` (AsyncNotifier que persiste en el dispositivo).
- **Recomendaciones:** `alertasProvider` (si el Núcleo falla, lista vacía) y `recomendacionesProvider`.
- **Mecánicas y verificación:** `realOEstafaProvider(actividad)` (family autoDispose) y `verificacionProvider`.

---

## 6. Reglas de negocio implementadas

| Regla | Dónde |
|---|---|
| Sin sesión el usuario es EX5; el tipo nunca se autodeclara | `perfil.dart` |
| Un EX2 usa la interfaz simplificada y ve la `variante_ex2` en audio; lo decide el tipo, no la edad (§14) | `perfil.dart`, `actividad.dart` |
| Una actividad le corresponde al usuario si su módulo y sus `tipos` lo incluyen; M10 y M14 también se abren a Centinelas | `actividad.dart`, `modulo.dart` |
| Rutas de arranque y refuerzo por tipo; con varios tipos se juntan sin repetir; Centinela suma M14 | `ruta.dart`, `plan_capacitacion.dart` |
| Recomendación: alerta del Observatorio (+100 + % de incremento) > paso de la ruta de inicio (80, 70, 60…, mínimo 50) > refuerzo (+40) > pendiente (+20); repaso si el puntaje es < 50 % (+25); completada (−50). Desempate por duración y luego por id | `motor_recomendacion.dart` |
| EX1 refuerza con M4, M5 o M6 según la tipología del ataque activo; EX2 suma M4 si la campaña es T2; EX5 recibe M10 si verifica por otra persona | `ruta.dart` |
| Microcurso por indicio (§11). I8: M7 para EX2, M4 los demás. I5: M11 internos, M9 EX4, M8 EX3; **[SUPUESTO]** M1 para EX1, EX2 y EX5 | `microcurso.dart` |
| «Expuesto» se muestra como «En aprendizaje» (regla 7) | `perfil_conducta.dart` |
| A2 **formativo, no punitivo**: siempre muestra la explicación; marcar un correo real como estafa se trata como prudencia | `evaluador_real_o_estafa.dart` |
| Verificación (`GET /verificar/{hash_2}`, adaptador en `adaptador_verificacion.dart`): `valido: true` con remitente y fecha → VERDE con los datos sellados; sin remitente o fecha → AMARILLO (Fallo 2); `HASH_INEXISTENTE`, `REVOCADO`, `CONTENIDO_ALTERADO` → ROJO; `VENCIDO`, respuesta ilegible, sin conexión o código mal formado → AMARILLO. Nunca VERDE sin respuesta del servidor | `adaptador_verificacion.dart`, `providers.dart` |
| Entrada por App Link: solo `https://app.iess.gob.ec/verificar/<código>`, la ruta `/verificar/<código>` y el esquema de desarrollo `iessverifica://`; cualquier otro enlace abre «Enlace no reconocido» (Fallo 1) | `enlace_verificacion.dart`, `rutas.dart`, `AndroidManifest.xml` |
| En VERDE el usuario compara remitente y asunto con el correo; si no coinciden, ROJO `SELLO_COPIADO` (Fallo 2) | `verificacion.dart`, `resultado_verificacion_view.dart` |
| El análisis de la IA llega del servidor; la app sugiere el microcurso de su primer indicio y una actividad que lo trabaje | `actividad_para_verificacion.dart` |
| Tras verificar: rango opcional y, para EX5, «¿verificas por otra persona?» (marca cuidador) | `resultado_verificacion_view.dart` |
| Pregunta opcional de rango de edad de 1 clic después de verificar; nunca se pide cédula ni nombre (Fallo 3, LOPDP) | `resultado_verificacion_view.dart` |
| El progreso se guarda solo en el dispositivo | `progreso_repository.dart` |
| El perfil (tipos, perfil de conducta, rango) sale de `GET /api/v1/me`; si falla, la app sigue como EX5 | `providers.dart` (`sesionProvider`, `perfilProvider`) |
| «Quiero capacitarme»: consentimiento (qué se mide, frecuencia, cómo salir); con cuenta usa el correo de la cuenta (enmascarado); sin cuenta pide correo y doble opt-in | `capacitacion_api.dart`, `capacitacion_screen.dart` |
| Diagnóstico por la primera reacción; si reporta después de un clic, el nivel sigue siendo Básico | `escalera.dart` |
| Escalera sobre el nivel real del correo enviado: reporta +1, ignora igual, clic −1; el siguiente correo trae al menos un indicio DEBIL o SIN_PROBAR y prefiere plantillas no enviadas | `escalera.dart`, `capacitacion_api.dart` |
| Límites: 1 por semana, nunca 2 en 48 h, 1 al mes para Centinela; en pausa no se envía | `escalera.dart` (`LimitesEnvio`) |
| Mapa de indicios: reporta → DOMINADO, clic → DEBIL (se muestra «Para practicar»), ignora → igual | `escalera.dart`, `capacitacion.dart` |
| Eventos de §12 con contexto anónimo; nunca cédula, nombre, correo ni `id_seudonimo`. A2 registra inicio, decisiones y cierre | `evento_app.dart`, `registro_eventos.dart`, `providers.dart` |

### Formato del catálogo (`assets/data/actividades.json`)

Cada actividad sigue el JSON de CLAUDE.md §12 (`id`, `modulo`, `mecanica`, `paso_4r`, `tipos`, `tipologia`, `indicios`, `variante_ex2`, `duracion_seg`, `mensaje_clave`) más dos campos para listarla (`titulo`, `resumen`) y el contenido de su mecánica:

| Mecánica | Campos |
|---|---|
| A1 Caza la señal | `mensaje` (`remitente`, `asunto`, `cuerpo` con párrafos separados por `
`, y opcionales `boton`, `adjunto`, `qr`, `codigo_verificacion`) y `senales` (`id` del indicio, `zona`: `remitente`, `asunto`, `cuerpo:N`, `boton`, `adjunto` o `qr`, y `feedback`) |
| A2 ¿Real o estafa? | `tarjetas`: 5, cada una con `mensaje`, `es_estafa`, `explicacion`, `indicios` |
| A3 Bandeja simulada | `bandeja`: 5, cada una con `mensaje`, `accion_correcta` (`CONFIAR`, `VERIFICAR`, `REPORTAR`), `explicacion`, `indicios` |
| A6 Verifica en 3 pasos | `casos`: cada uno con `mensaje` (con `codigo_verificacion`), `es_estafa`, `explicacion`, `indicios` |
| A7 Audio-reto | `audio` (`guion`, `url`) y `opciones`: 2, una correcta |

Las pruebas de `test/domain/modelos_test.dart` validan que el catálogo cumpla estas reglas.

### Datos de prueba del Núcleo simulado

- Código válido (T2, Dirección de Prestaciones y Pensiones, `notificaciones@iess.gob.ec`): `8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4`
- Código revocado (T1, Dirección de Afiliación): `1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b`
- Cualquier otro código de 64 caracteres hexadecimales: inexistente (ROJO).
- `MockNucleoApi(sinConexion: true)` simula que el Núcleo no responde.
- Sesiones de demo (`domain/sesion.dart`): sin cuenta (EX5), EX1, EX2, EX3, EX4 y cuatro colaboradores (IN1-IN4, también afiliados). Correos enmascarados en `practica.ejemplo` (ficticio).
- Panel de demostración en «Mi capacitación»: confirmar correo, «Lo reportó», «Hizo clic», «No hizo nada» y «Pasa una semana: siguiente correo».
- Alerta activa: +40 % de phishing T2 dirigido a 65+.
- Para probar el App Link en Android: `adb shell am start -a android.intent.action.VIEW -d "https://app.iess.gob.ec/verificar/<código>"` (sin `assetlinks.json` el sistema pregunta con qué app abrirlo).

### Contratos propuestos a los otros bloques (regla 9)

| Endpoint | Estado | Qué espera la app |
|---|---|---|
| `GET /verificar/{hash_2}` | Del diagrama | `valido`, `remitente`, `fecha`, `emisor_nombre`, `tipologia`, `asunto_resumen`, `motivo` y `analisis_ia` (`nivel_riesgo`, `explicacion`, `indicios`). Parámetros anónimos: `canal`, `origen`, `rango_etario`, `tipologia_percibida` |
| `GET /api/v1/me` | §12 | `tipos`, `perfil_conducta`, `rango_etario`, `correo_enmascarado` |
| `POST /api/v1/eventos` | §12 | Lista de eventos `{evento, momento, tipo_usuario, perfil_conducta, rango_etario, es_cuidador, canal, datos}` |
| `POST /api/v1/capacitacion/inscribir` | §12 | `consentimiento` (`version`, `aceptado_en`) y `correo` solo sin cuenta |
| `GET /api/v1/capacitacion/estado`, `POST …/pausar`, `…/reanudar`, `…/salir` | **Nuevos [PROPUESTO]** | Estado: fase, nivel inicial, nivel del próximo correo, último desenlace, mapa de indicios |

### Pendiente para la fase 7 (App Links en producción)

- El IESS publica `https://app.iess.gob.ec/.well-known/assetlinks.json` con la huella SHA-256 del certificado de la app (`ec.iess.capacitacion`).
- iOS: capacidad *Associated Domains* (`applinks:app.iess.gob.ec`) en Xcode y `apple-app-site-association` en el dominio. No se tocó el proyecto de Xcode sin poder compilarlo.
- Web: la ruta `/#/verificar/<código>` ya funciona con la estrategia de URL por defecto.

---

## 7. Diferencias encontradas al revisar contra `Capacitacion/CLAUDE.md` y el diagrama

| # | Código recuperado | Lo que piden CLAUDE.md o el diagrama |
|---|---|---|
| 1 | 7 «cápsulas» con señales en texto libre | Módulos M1-M14, actividades en el JSON de la §12, indicios I1-I11 y mecánicas A1-A9 |
| 2 | Segmenta solo por rango de edad | Tipo de usuario EX1-EX5 / IN1-IN4 (desde `GET /api/v1/me`, nunca autodeclarado) y perfil de conducta |
| 3 | Audio para 65+ | Audio para **EX2** por tipo, no por edad declarada (§14) |
| 4 | Pesos de recomendación por rango | Rutas por tipo (§10.4) y refuerzo según el ataque activo |
| 5 | `POST /api/v1/verify` y Black List por remitente | `GET /verificar/{hash_2}`, con entrada por App Link desde el botón del correo |
| 6 | Sin flujo de capacitación | Flujo «Quiero capacitarme», consentimiento, eventos, mapa de indicios, «Expuesto» mostrado como «en aprendizaje», pregunta de cuidador |

### Avisos del Décimo Hombre

- **El botón «Verificar en App» es un enlace dentro del correo.** Un atacante puede copiarlo y apuntarlo a su sitio. Se acepta solo como **App Link verificado** (Android `autoVerify`, iOS Universal Links) sobre un dominio oficial, y la app siempre muestra remitente, fecha y asunto sellados para comparar (Fallo 2). Un esquema propio (`iess://`) lo puede capturar otra app: solo para desarrollo. Hay que validarlo con el equipo, porque la §5.2 de CLAUDE.md dice «nunca deep links».
- **Cambios de contrato que hay que avisar a los Bloques 1 y 3 (regla 9):** que `GET /verificar/{hash_2}` responda con remitente, fecha, tipología, asunto y el análisis de la IA, y endpoints para consultar el estado de la capacitación, pausarla y salir (no están en la §12).

---

## 8. Fases (confirmadas el 2026-11-26)

Cada fase termina con `dart format`, `flutter analyze`, `flutter test` y un commit cuyo hash se comunica.

| Fase | Contenido |
|---|---|
| 0 · Base | Mover esta guía a `Capacitacion/docs/` y anotar las decisiones. |
| 1 · Dominio | Indicios I1-I11 con su microcurso, tipos EX/IN y zona, perfil de conducta, módulos M1-M14, mecánicas A1-A9, modelo 4R. `Actividad` (JSON §12) reemplaza a `Capsula`. Recomendación por la ruta del tipo (§10.4), audio para EX2. |
| 2 · Verificación | Adaptador `GET /verificar/{hash_2}` → semáforo. Entrada por App Link (`go_router`) y por código pegado. Explicación de la IA del servidor y microcurso del indicio. Rango opcional y «¿verificas por otra persona?». |
| 3 · API de Capacitación | Cliente + mock de `/me`, `/eventos` y `/capacitacion/inscribir`. Sesión simulada por tipo. Flujo «Quiero capacitarme» con consentimiento, pausa y salida. El mock aplica diagnóstico, escalera y límites, con un panel de demo. |
| 4 · Mecánicas | Componentes A1, A2, A3, A6 y A7 que leen el JSON de actividad y emiten eventos. |
| 5 · Diseño móvil | ThemeGreen como `ThemeData` oscuro, fuentes como assets, semáforo lima/warn/live, tipologías T1 blue, T2 violet, T3 cyan, modo EX2 accesible. |
| 6 · Diseño web | Cortes 760 y 820 px. Preguntar al usuario: Flutter web o HTML con `tokens.css`. |
| 7 · Integración y contenido | Clientes HTTP reales (`--dart-define`), archivos de App Links documentados, audio real, A4, A5, más actividades. |

---

## 9. Cómo trabajar

1. Comprueba que `flutter analyze` y `flutter test` pasan (los commits «sin verificar» pueden necesitar correcciones).
2. Sigue las fases de la sección 8 y **presenta al usuario** cualquier fase nueva antes de tocar código.
3. Por cada fase: implementa, ejecuta `dart format`, `flutter analyze` y `flutter test`, haz el commit y **comunica el hash y el mensaje**.
4. Mantén separadas la lógica (`domain`, `application`) y la presentación. El diseño no debe cambiar las reglas de negocio.
5. No guardes datos personales. El rango de edad es opcional y anonimizado.
