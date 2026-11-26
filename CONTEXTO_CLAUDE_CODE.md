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

**Fuentes de contexto en el repo:**
- `inteligencia_colectiva_flujos_t_cnicos_mvp_y_an_lisis_del_d_cimo_hombre.md`: documento técnico del MVP, contratos de API y los 6 fallos del Décimo Hombre.
- `obsidian/`: investigación. Las notas más útiles son `1-Investigacion/07 Evidencia cientifica.md` y `1-Investigacion/09 Criterios de diseno.md`.
- `Clasificacion/`: contexto principal del módulo. **Todavía no se ha revisado.**
- `recursos/Boilerplate/ThemeGreen/`: sistema de diseño que se usará en la etapa visual.

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

## 3. Recuperar el trabajo ya hecho (PRIMER PASO)

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

**Estado actual:** `flutter analyze` no reporta problemas y las **40 pruebas pasan**.

### Cosas a tener en cuenta

- En Flutter 3.50, `package:flutter/material.dart` está **obsoleto**. Se importa `package:material_ui/material_ui.dart`, que tiene la misma API. Si un integrante usa un Flutter anterior a 3.47, tiene que actualizar o revertir ese import.
- En web, sin `--no-web-resources-cdn`, la app descarga CanvasKit desde `gstatic.com` y en algunas redes no carga.
- Las reglas de lint son estrictas: `prefer_single_quotes`, `require_trailing_commas`, `strict-casts`, entre otras. Corre `dart format lib test` antes de cada commit.

---

## 5. Arquitectura

```
Capacitacion/
├── assets/data/capsulas.json          # catálogo (7 cápsulas)
├── lib/
│   ├── main.dart                      # ProviderScope + arranque
│   └── src/
│       ├── app.dart                   # MaterialApp (aquí irá el ThemeData de ThemeGreen)
│       ├── domain/                    # Dart puro, sin Flutter
│       │   ├── tipologia.dart         # enum T1/T2/T3
│       │   ├── rango_etario.dart      # enum 18-29…65+, esAdultoMayor
│       │   ├── formato_capsula.dart   # TEXTO / AUDIO / QUIZ
│       │   ├── capsula.dart           # micro-cápsula + fromJson
│       │   ├── correo_ejemplo.dart    # correo ficticio del quiz
│       │   ├── pregunta_quiz.dart
│       │   ├── resultado_quiz.dart    # Retroalimentacion, ResultadoQuiz
│       │   ├── progreso.dart          # completadas + mejores puntajes (JSON)
│       │   ├── perfil.dart            # rango opcional (anónimo)
│       │   ├── alerta_observatorio.dart
│       │   ├── verificacion.dart      # Semaforo, Solicitud/ResultadoVerificacion, MetadatosOficiales
│       │   └── domain.dart            # barrel
│       ├── data/
│       │   ├── capsula_repository.dart   # interfaz + Asset (JSON) + Memoria
│       │   ├── progreso_repository.dart  # interfaz + SharedPreferencesAsync + Memoria
│       │   └── nucleo_api.dart           # interfaz NucleoApi + MockNucleoApi
│       ├── application/
│       │   ├── logica/
│       │   │   ├── filtro_capsulas.dart
│       │   │   ├── motor_recomendacion.dart
│       │   │   ├── evaluador_quiz.dart
│       │   │   └── capsula_para_verificacion.dart
│       │   └── providers.dart         # todos los providers de Riverpod
│       └── presentation/
│           ├── screens/  inicio_screen (NavigationBar con 4 pestañas), para_ti_tab,
│           │             verificar_tab, catalogo_tab, progreso_tab, capsula_screen, quiz_screen
│           └── widgets/  capsula_tile, selector_rango, vista_async
└── test/  domain/, logica/, data/, presentation/flujos_test.dart, widget_test.dart, helpers.dart
```

### Providers principales (`application/providers.dart`)

- **Dependencias:** `capsulaRepositoryProvider`, `progresoRepositoryProvider` y `nucleoApiProvider`. Se sobrescriben en las pruebas.
- **Catálogo y filtros:** `catalogoProvider`, `capsulaPorIdProvider(id)`, `filtroProvider` y `capsulasFiltradasProvider`.
- **Usuario:** `perfilProvider` y `progresoProvider` (AsyncNotifier que persiste el progreso).
- **Recomendaciones:** `alertasProvider` (si el Núcleo falla, devuelve una lista vacía) y `recomendacionesProvider`.
- **Quiz y verificación:** `quizProvider(capsula)` (family autoDispose) y `verificacionProvider`.

---

## 6. Reglas de negocio implementadas

| Regla | Dónde |
|---|---|
| Filtro por tipología, rango, formato y solo pendientes | `filtro_capsulas.dart` |
| Recomendación por puntaje: alerta del Observatorio (+100 + % de incremento) > rango del usuario (+30) > pendiente (+20); audio para 65+ (+15); repaso si el puntaje es < 50 % (+25); completada (−50). Con rango conocido se excluyen las cápsulas de otros rangos | `motor_recomendacion.dart` |
| Quiz **formativo, no punitivo**: siempre muestra la explicación; marcar un correo real como estafa se trata como prudencia. El castigo reduce el reporte (ver evidencia en Obsidian) | `evaluador_quiz.dart` |
| Verificación simulada (`POST /api/v1/verify`): dominio en Black List → ROJO (aunque traiga un hash válido); hash válido → VERDE **con metadatos sellados** (Fallo 2: nunca decir solo «es válido»); revocado → ROJO; vencido, sin sello, desconocido o mal formado → AMARILLO | `nucleo_api.dart` |
| Tras verificar se sugiere la cápsula de la tipología suplantada, del rango del usuario, pendiente y más corta | `capsula_para_verificacion.dart` |
| Pregunta opcional de rango de edad de 1 clic después de verificar; nunca se pide cédula ni nombre (Fallo 3, LOPDP) | `verificar_tab.dart` |
| La verificación ocurre dentro de la app, nunca en la página que abre un QR (Fallo 1) | `verificar_tab.dart`, cápsula `t1-qr-falso` |
| El progreso se guarda solo en el dispositivo y no se envía al Núcleo | `progreso_repository.dart` |

### Datos de prueba del Núcleo simulado

- Sello válido (T2, Dirección de Prestaciones y Pensiones): `8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4`
- Sello revocado (T1, Dirección de Afiliación): `1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b`
- Dominios en Black List: `iess-tramites-ec.com` y `biess-ec.net` (T2), `iess-gob-ec.info` (T1), `iess-agenda.com` (T3)
- Alerta activa: +40 % de phishing T2 dirigido a 65+

---

## 7. Supuestos que hay que revisar

La carpeta `Clasificacion/` **no estaba disponible** cuando se escribió el código. Todo lo siguiente es propuesta y se debe validar contra ella:

- Las 7 cápsulas de `assets/data/capsulas.json`: títulos, textos, señales y casos del quiz.
- Los pesos del motor de recomendación.
- Los formatos (TEXTO / AUDIO / QUIZ). El audio todavía no reproduce nada: solo es una etiqueta.
- Si «clasificación» se refiere a otra cosa, como clasificar correos o usuarios, hay que replantear el dominio.

---

## 8. Próximas fases (proponer al usuario antes de implementar)

**Fase A. Revisar `Clasificacion/`**
- Leer toda la carpeta y compararla con las secciones 6 y 7.
- Presentar al usuario la lista de diferencias y los cambios propuestos.
- Ajustar el dominio, el catálogo y las pruebas.

**Fase B. Diseño móvil con ThemeGreen**
- Traducir `recursos/Boilerplate/ThemeGreen/tokens/tokens.json` a un `ThemeData` oscuro, por ejemplo en `lib/src/presentation/theme/theme_green.dart`:
  - **Colores:** fondo `--bg #070807`; texto `--ink #f4f6f1`, `--ink-dim #8b918a` y `--ink-faint #4a4f49`.
  - **Acento:** lima `#9dff32`, con texto encima `--on-lime #0c1206`. Se usa **solo para la acción principal y el estado activo**.
  - **Colores secundarios:** blue `#4c8dff`, sky `#8ec6ea`, cyan `#4fd3e6`, live `#ff4d6d` y warn `#ff8b6b`.
  - **Tipografía:** Plus Jakarta Sans y, para códigos y hashes, IBM Plex Mono. Usar el paquete `google_fonts` o incluir las fuentes como assets.
  - **Radios y formas:** pill 999, xl 26, lg 18, md 16, sm 12. Los botones van en forma de píldora (`tg-btn`). Las tarjetas son de vidrio con gradiente azul y verde (`tg-card`, `tg-linkcard`).
- Mapear tipologías a colores, en una propuesta coherente con ThemeGreen.
- Para el semáforo: VERDE = lima, AMARILLO = warn, ROJO = live.
- Accesibilidad para 65+: texto grande, buen contraste, objetivos táctiles de al menos 48 px y respeto de las animaciones reducidas.
- Revisar el README de ThemeGreen, que tiene las reglas de uso, y el `home/index.html` de referencia.

**Fase C. Diseño web**
- Versión web adaptable (puntos de corte de 760 y 820 px, como ThemeGreen). Puede ser la misma app Flutter web o una página HTML con `tokens.css` y `components.css` de ThemeGreen. Hay que preguntar al usuario qué prefiere.

**Fase D. Integración real**
- Implementar `HttpNucleoApi` contra la API del Bloque 3 y sobrescribir `nucleoApiProvider`.
- Si el Núcleo expone un endpoint de alertas, consumirlo desde `alertasProvider`.
- Opcional: escáner de QR dentro de la app (el payload es texto, nunca una URL).

**Fase E. Contenido**
- Reproductor real para cápsulas de audio.
- Más cápsulas y más casos de quiz.
- Revisión de textos con el equipo de Comunicación.

---

## 9. Cómo trabajar

1. Recupera los commits del bundle (sección 3) y comprueba que `flutter analyze` y `flutter test` pasan.
2. Revisa `Clasificacion/` (Fase A) y **presenta las fases** al usuario antes de tocar código.
3. Por cada fase: implementa, ejecuta `dart format`, `flutter analyze` y `flutter test`, haz el commit y **comunica el hash y el mensaje**.
4. Mantén separadas la lógica (`domain`, `application`) y la presentación. El diseño no debe cambiar las reglas de negocio.
5. No guardes datos personales. El rango de edad es opcional y anonimizado.
