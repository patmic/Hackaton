# AIESS · Documentación para el jurado

**Reto:** ¿Cómo ayudar a una persona sin conocimientos técnicos a reconocer un correo de phishing, entender qué
puede pasarle y saber qué hacer y dónde reportarlo?
**Quién lo usa:** afiliados, jubilados, pensionistas y colaboradores del IESS, sin perfil técnico.

AIESS es una app Flutter (Android y web) con un **robot guardián que habla**: el correo se carga, el robot dice
con voz y con subtítulos si es phishing (Sí o No y cuántos indicios), por qué, qué hacer y dónde reportarlo.

## Componentes obligatorios: dónde se cumplen

| Requisito | Cómo lo cumple AIESS | Dónde |
|---|---|---|
| **Carga del correo** (.eml, PDF o texto) | Texto pegado o dictado; **.eml** (MIME completo: base64, quoted-printable, multipart, HTML con enlaces reales y adjuntos); **PDF** (en la web con PDF.js/OCR; en el celular, Android dibuja cada página y ML Kit la lee) e **imagen/captura** (OCR). Todo se lee **en el equipo**. | `lib/features/correo/eml.dart`, `web/ocr_aiess.js`, `lib/features/ocr/` |
| **Veredicto claro** (Sí o No y cuántos indicios) | La tarjeta del resultado dice **«Phishing: SÍ · 3 indicios»** o **«Phishing: NO · 0 indicios»** (o «sello falso» / «firma válida del IESS»), con color, ícono y palabra. | `Veredicto.resumen` en `lib/features/analisis/motor.dart` |
| **Avatar que explica** (voz y subtítulos, lenguaje simple) | Robot guardián animado: habla con voz sintética del sistema (TTS) y el texto aparece en pantalla al ritmo de la voz; frases cortas, sin tecnicismos. Escucha por voz con subtítulos en vivo. | `lib/features/mascota/robot_guardia.dart`, `lib/features/voz/voz.dart`, `lib/ui/texto_vivo.dart` |
| **IA local** (el modelo corre en el equipo; el correo no sale) | **En la PC:** `servidor/iniciar_windows.bat` arranca el modelo y la web en `http://localhost:8090` (solo escucha en la propia PC). **En el celular:** el modelo corre dentro del celular (llama.cpp); sin el modelo, deciden las reglas locales. El servidor es opcional, viene apagado y el APK de la demo no trae su clave. Antes de leer el correo se pide permiso y se dice **dónde** corre la IA. | `servidor/iniciar_windows.bat`, `lib/features/llm/llm.dart`, `lib/ui/consentimiento.dart` |
| **Fuentes OSINT y CTI** (declaradas; solo dominio o URL) | 1) **Reglas locales** (dominios parecidos al IESS, acortadores, enlace que dice una cosa y lleva a otra, remitente gratuito, TLD de riesgo). 2) **RDAP** (rdap.org): edad del dominio; se envía **solo el dominio**. 3) **OpenPhish** (lista pública): se descarga y se compara **en el equipo**; no se envía nada. Declaradas en Ajustes y en la web. | `lib/features/osint/url_analyzer.dart`, `lib/features/osint/cti.dart` |
| **Documentación** | Este archivo, `ARQUITECTURA.md` y las guías de `servidor/`. | `docs/` |

## Rúbrica del jurado (100 pts): dónde se cumple

Orden de la demo, igual que la rúbrica: problema → funcionalidad → seguridad → innovación → viabilidad →
experiencia → evidencia.

| Criterio | Cómo lo cumple AIESS | Dónde |
|---|---|---|
| **Problema (25)** · detecta los indicios y el avatar los explica, incluido el deepfake | Ante un phishing el robot dice, con voz y subtítulos: **«Encontré N indicios»** y explica **cada uno** (I1–I11 del catálogo), **qué te podría pasar** si caes, el aviso de **deepfake** («con tus fotos o videos de redes sociales pueden crear un video falso tuyo para pedirles dinero a tus amigos y familiares») y **qué hacer y dónde reportar** (seguridad.informacion@iess.gob.ec, denuncias.iess.gob.ec, app.iess.gob.ec, 593 2 3945666). | `guionEstafa`, `riesgoIndicio`, `queHacerEstafa` en `lib/features/analisis/motor.dart` |
| **Funcionalidad (20)** · completa el flujo; la cantidad coincide con la lista | Sí/No según el catálogo (Sí con al menos un indicio). El resumen («Phishing: SÍ · 3 indicios»), lo que dice el avatar y la **lista completa** de indicios en pantalla salen de la misma lista. Al instante con reglas locales; el botón «Revisar con la IA local» da la lista del modelo afinado con el dataset. | `Veredicto.resumen`, `indiciosValidos`; tarjetas en `lib/ui/web_escritorio.dart` y `lib/ui/aiess_home_screen.dart` |
| **Seguridad y datos (20)** · modelo local; solo dominio o URL sale; no abre enlaces ni adjuntos | Modelo LFM2 en la PC (`localhost`) o en el celular. A internet sale solo: el **dominio** (RDAP), la **huella SHA-256 del asunto** (consulta del sello, no el texto) y, al Observatorio, un **semáforo y códigos I1–I11** con un seudónimo al azar (se puede apagar). El panel **«Partes del correo»** muestra remitente, asunto, a dónde llevan de verdad los enlaces y los adjuntos **sin abrir nada**. | `lib/features/osint/cti.dart`, `Sello.huellaAsunto`, `lib/features/observatorio/observatorio.dart`, `lib/ui/partes_correo.dart` |
| **Innovación (15)** · IA y fuentes útiles | Modelo pequeño afinado con el dataset del reto, corriendo en el equipo; **sello SellaCorreo** (firma Ed25519) que el robot verifica solo desde el aviso del celular; OSINT/CTI con RDAP y OpenPhish; Observatorio de comportamiento. | `ml/`, `SellaCorreo/`, `Analisis-de-comportamiento/` |
| **Viabilidad (10)** · llega a un piloto | Funciona hoy en Android, web y PC; servidor en Docker detrás de Cloudflare (sin IP expuesta); el sello se integra al correo institucional sin cambiar el servidor de correo. | `servidor/LEEME_ORACLE.md`, `SellaCorreo/docker-compose.yml` |
| **Experiencia (5)** · fácil para no técnicos | Un botón grande, voz y subtítulos, letra grande y «Lectura fácil» (dislexia), lector de pantalla, navegación con Tab, dictado con «Parar», sin tecnicismos. | `lib/ui/lectura.dart`, `lib/ui/animaciones_web.dart` |
| **Evidencia (5)** · pruebas, fuentes y licencias | Prueba de oro con los 5 correos de práctica, 5 de 5 exactos (`test/correos_practica_test.dart`); pruebas de la rúbrica (`test/rubrica_test.dart`) y del sello; fuentes declaradas abajo; licencias en «IA declarada» y «Componentes». Métrica de las reglas frente al dataset en `ml/reports/eval_reglas.json`. | `test/`, `ml/reports/` |

**Sello y veredicto.** El sello no reemplaza a los indicios: con **sello válido** el correo es del IESS
(«Phishing: NO · firma válida»); con **sello falso** es phishing y se suma el indicio que corresponde (I2 o I4);
**sin sello**, el Sí/No lo deciden los indicios del catálogo y se muestra aparte el aviso «no trae el sello del IESS».
Si la firma es válida pero la IA ve señales de estafa, avisa que pudieron cambiar el texto de un correo firmado.

## IA declarada

| Pieza | Qué es | Origen |
|---|---|---|
| **LFM2-1.2B** (Liquid AI) | Modelo de lenguaje pequeño, cuantizado a GGUF Q4_K_M (~730 MB) para correr en CPU. Licencia *LFM Open License v1.0*. | Preexistente |
| **Ajuste fino AIESS** | LoRA/QLoRA sobre LFM2 con el dataset sintético del reto (1.000 correos, indicios I1–I11) y casos simulados; responde un JSON con veredicto, indicios, explicación y qué hacer. | **Adaptado** (`ml/`) |
| **llama.cpp** | Motor que ejecuta el GGUF en la PC (`llama-server`) y en Android (JNI). | Preexistente |
| **Reglas de indicios** | Léxico y análisis de enlaces/remitente que marcan I1–I11. Phishing con **al menos un indicio** (catálogo, sección 1). Deciden el veredicto y la lista; aciertan exacto los 5 correos de práctica P01–P05 (`test/correos_practica_test.dart`). | **Creado** |

La IA no decide sola: el veredicto y la lista de indicios salen siempre de las reglas; del modelo solo se toma su explicación, y solo si habla de los mismos indicios (`fusionar`).

## Componentes (preexistentes, adaptados y creados)

| Componente | Tipo | Uso en AIESS |
|---|---|---|
| Flutter 3.50, Riverpod, material_ui | Preexistente | App Android y web |
| flutter_tts / speech_to_text | Preexistente | Voz del robot y dictado |
| Google ML Kit (Android) | Preexistente | OCR de capturas en el celular |
| Tesseract.js, PDF.js | Preexistente | OCR de imágenes y PDF en el navegador |
| Lexend, Atkinson Hyperlegible | Preexistente | Tipografía legible para personas mayores |
| ThemeLight | Adaptado (del equipo) | Tema visual compartido |
| SellaCorreo | Creado (equipo) + adaptado | Sello Ed25519 del IESS; AIESS lo verifica por `/api/v1/verificar` |
| Módulo Capacitación (aula virtual) | Creado (equipo) + adaptado | Microlecciones animadas, «Caza la señal», «¿Real o estafa?» |
| Robot guardián, aviso tipo Truecaller, anonimizador, lector .eml, CTI, flujo de firma y consentimiento | **Creado** | Núcleo de AIESS |

## Privacidad (por diseño)

- **Nunca se abre nada:** el bot solo LEE los enlaces (dominio, destino real, listas públicas); no visita el sitio
  ni abre adjuntos. Se quitó la opción que consultaba el sitio sospechoso.
- **Reporte al IESS simulado** (reglas del reto): «Avisar al IESS» arma el caso `AIESS-AAAAMMDD-XXXX` con los
  indicios, el dominio y el asunto sin datos personales; no envía nada. En el equipo queda solo hora, caso y la
  huella SHA-256 del correo.
- **Qué salió del equipo:** cada resultado lo dice («solo el dominio x a RDAP» o «nada»).
- **Solo HTTPS** en Android (`network_security_config.xml`); HTTP plano solo hacia el propio equipo.

- **El guardián del celular solo lee el ASUNTO** de los correos y solo avisa si habla del IESS; el resto se ignora sin registrar nada.
- **Primero el sello:** si el correo trae el sello SellaCorreo, se verifica la firma sin leer el correo. Desde el
  aviso del celular se consulta con la **huella SHA-256 del asunto**, nunca con su texto.
- **La IA solo lee el correo si la persona toca «Revisar con la IA local»**; el botón dice dónde corre y que
  nunca se guarda y la conversación se borra.
- **Observatorio:** solo semáforo y códigos I1–I11 con un seudónimo al azar; se apaga en Ajustes.
- **Anonimización** antes de cualquier envío (nombre, cédula, RUC, teléfono, tarjeta, cuenta, correo).
- **Fuentes externas:** solo el dominio (RDAP); OpenPhish se compara en el equipo.
- **Borrado:** al terminar, el texto se borra de la app y se reemplaza en la memoria del modelo.

## Cómo probarlo en una PC (IA local)

1. Copia a `servidor/`: `bin\` (llama.cpp para Windows), `modelos\aiess-lfm2-1.2b-Q4_K_M.gguf` y `web\`
   (`flutter build web --release --no-web-resources-cdn --dart-define-from-file=secretos.json --dart-define=AIESS_SERVIDOR=`).
2. Doble clic en `servidor\iniciar_windows.bat`: se abre `http://localhost:8090`.
3. Pega un correo, sube un `.eml`/PDF/imagen o dicta: el robot responde con voz y subtítulos.
