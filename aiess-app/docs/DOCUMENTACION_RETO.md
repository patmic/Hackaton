# AIESS · Documentación para el jurado

**Reto:** ¿Cómo ayudar a una persona sin conocimientos técnicos a reconocer un correo de phishing, entender qué
puede pasarle y saber qué hacer y dónde reportarlo?
**Quién lo usa:** afiliados, jubilados, pensionistas y colaboradores del IESS, sin perfil técnico.

AIESS es una app Flutter (Android y web) con un **robot guardián que habla**: el correo se carga, el robot dice
con voz y con subtítulos si es phishing (Sí o No y cuántos indicios), por qué, qué hacer y dónde reportarlo.

## Componentes obligatorios: dónde se cumplen

| Requisito | Cómo lo cumple AIESS | Dónde |
|---|---|---|
| **Carga del correo** (.eml, PDF o texto) | Texto pegado o dictado; **.eml** (MIME completo: base64, quoted-printable, multipart, HTML con enlaces reales y adjuntos); **PDF** (texto o escaneado con OCR) e **imagen/captura** (OCR). Todo se lee **en el equipo**. | `lib/features/correo/eml.dart`, `web/ocr_aiess.js`, `lib/features/ocr/` |
| **Veredicto claro** (Sí o No y cuántos indicios) | La tarjeta del resultado dice **«Phishing: SÍ · 3 indicios»** o **«Phishing: NO · 0 indicios»** (o «sello falso» / «firma válida del IESS»), con color, ícono y palabra. | `Veredicto.resumen` en `lib/features/analisis/motor.dart` |
| **Avatar que explica** (voz y subtítulos, lenguaje simple) | Robot guardián animado: habla con voz sintética del sistema (TTS) y el texto aparece en pantalla al ritmo de la voz; frases cortas, sin tecnicismos. Escucha por voz con subtítulos en vivo. | `lib/features/mascota/robot_guardia.dart`, `lib/features/voz/voz.dart`, `lib/ui/texto_vivo.dart` |
| **IA local** (el modelo corre en el equipo; el correo no sale) | **En la PC:** `servidor/iniciar_windows.bat` arranca el modelo y la web en `http://localhost:8090` (solo escucha en la propia PC). **En el celular:** el modelo corre dentro del celular (llama.cpp) y es la primera opción; el servidor es opcional y viene apagado. Antes de leer el correo se pide permiso y se dice **dónde** corre la IA. | `servidor/iniciar_windows.bat`, `lib/features/llm/llm.dart`, `lib/ui/consentimiento.dart` |
| **Fuentes OSINT y CTI** (declaradas; solo dominio o URL) | 1) **Reglas locales** (dominios parecidos al IESS, acortadores, enlace que dice una cosa y lleva a otra, remitente gratuito, TLD de riesgo). 2) **RDAP** (rdap.org): edad del dominio; se envía **solo el dominio**. 3) **OpenPhish** (lista pública): se descarga y se compara **en el equipo**; no se envía nada. Declaradas en Ajustes y en la web. | `lib/features/osint/url_analyzer.dart`, `lib/features/osint/cti.dart` |
| **Documentación** | Este archivo, `ARQUITECTURA.md` y las guías de `servidor/`. | `docs/` |

## IA declarada

| Pieza | Qué es | Origen |
|---|---|---|
| **LFM2-1.2B** (Liquid AI) | Modelo de lenguaje pequeño, cuantizado a GGUF Q4_K_M (~730 MB) para correr en CPU. Licencia *LFM Open License v1.0*. | Preexistente |
| **Ajuste fino AIESS** | LoRA/QLoRA sobre LFM2 con el dataset sintético del reto (1.000 correos, indicios I1–I11) y casos simulados; responde un JSON con veredicto, indicios, explicación y qué hacer. | **Adaptado** (`ml/`) |
| **llama.cpp** | Motor que ejecuta el GGUF en la PC (`llama-server`) y en Android (JNI). | Preexistente |
| **Reglas «C»** | Respaldo determinista sin IA: phishing si hay enlace riesgoso, o una señal fuerte más otra, o dos débiles (95,5 % en el set de prueba). | **Creado** |

La IA nunca decide sola: su respuesta se combina con las reglas y las fuentes OSINT/CTI (`fusionar`).

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

- **El guardián del celular solo lee el ASUNTO** de los correos y solo avisa si habla del IESS; el resto se ignora sin registrar nada.
- **Primero el sello:** si el correo trae el sello SellaCorreo, se verifica la firma sin leer el correo.
- **La IA solo lee con un «Sí» explícito**, y se le dice a la persona dónde corre.
- **Anonimización** antes de cualquier envío (nombre, cédula, RUC, teléfono, tarjeta, cuenta, correo).
- **Fuentes externas:** solo el dominio (RDAP); OpenPhish se compara en el equipo.
- **Borrado:** al terminar, el texto se borra de la app y se reemplaza en la memoria del modelo.

## Cómo probarlo en una PC (IA local)

1. Copia a `servidor/`: `bin\` (llama.cpp para Windows), `modelos\aiess-lfm2-1.2b-Q4_K_M.gguf` y `web\`
   (`flutter build web --release --no-web-resources-cdn --dart-define-from-file=secretos.json --dart-define=AIESS_SERVIDOR=`).
2. Doble clic en `servidor\iniciar_windows.bat`: se abre `http://localhost:8090`.
3. Pega un correo, sube un `.eml`/PDF/imagen o dicta: el robot responde con voz y subtítulos.
