# AIESS: arquitectura (Fase 1)

Todo corre en el celular: modelo Liquid AI LFM2 cuantizado (GGUF) con llama.cpp, OSINT offline,
voz local y una pantera animada. Docker solo se usa para **construir** (entrenar el modelo y compilar la APK).

## 1. Flujo principal, estilo Truecaller

```
 Llega notificación (Gmail / Outlook / SMS / WhatsApp)
        │
        ▼
 [Android] NotificationListenerService (Kotlin, nativo)
        │  título + texto de la vista previa + app de origen
        ▼
 ┌──────────────── CAPA 1: TRIAJE RÁPIDO (<20 ms, siempre) ─────────────────┐
 │ OSINT offline (Dart): typosquatting, acortadores, marca suplantada,      │
 │ TLD riesgoso, subdominio engañoso, remitente no oficial                  │
 │ + léxico de indicios I1–I11                                              │
 └───────┬────────────────────────────────────────────────┬────────────────┘
         │ sin señales → no molestar                      │ con señales o mención del IESS
         ▼                                                ▼
     (silencio)               ┌── CAPA 2: OSINT DE RED (si hay internet y el usuario lo permite) ──┐
                              │ HEAD sin seguir enlaces: redirecciones, certificado SSL,          │
                              │ edad/registro del dominio (RDAP)                                  │
                              └───────────────────────────┬──────────────────────────────────────┘
                                                          ▼
                              ┌── CAPA 3: LFM2 LOCAL (llama.cpp, GGUF Q4_K_M) ──────────┐
                              │ prompt = mensaje + bloque [OSINT] → JSON:               │
                              │ veredicto, riesgo, puntaje, voz, indicios, explicación  │
                              └───────────────────────────┬────────────────────────────┘
                                                          ▼
                              FUSIÓN (Dart, determinista): puntaje final =
                              max(LLM, OSINT); si OSINT ≥ 60 siempre se marca ALERTA
                                                          ▼
                 Pop-up flotante (overlay) con la PANTERA ──► TTS lee el campo "voz"
                 [Es seguro] [Es estafa: reportar] [Ver detalle] ──► abre la app / chat
```

Por qué tres capas: cargar el modelo de 1,2B tarda 1–3 s y consume batería. El triaje filtra el 95 %
de las notificaciones (las legítimas sin señales) y el LLM solo se usa cuando aporta.

**iOS:** Apple no permite leer notificaciones de otras apps. En iOS el flujo es *Compartir con AIESS*
(Share Extension) y, para SMS, `ILMessageFilterExtension` (filtro de remitentes desconocidos).
El resto (modelo, OSINT, pantera y voz) es igual.

## 2. Componentes

| Capa | Tecnología | Nota |
|---|---|---|
| Modelo | LiquidAI **LFM2-1.2B** + LoRA, GGUF **Q4_K_M** (~0,7 GB) | Variante **LFM2-350M** (~0,25 GB) para gama baja o segundo plano |
| Inferencia | llama.cpp vía FFI (`llama_cpp_dart` / `fllama`) en un *isolate* | Contexto de 2048, 4 hilos, prompt de sistema en caché |
| OSINT | Dart puro, con las mismas reglas que `ml/aiess_ml/osint_rules.py` | Lista oficial en `shared/canales_oficiales.json` (un solo origen) |
| Voz salida | `flutter_tts` con voces locales del sistema (es-EC / es-US / es-MX) | El modelo genera el campo `voz`: frases cortas sin símbolos |
| Voz entrada | `speech_to_text` con reconocimiento en el dispositivo (Android 13+) y respaldo `sherpa_onnx` / Whisper tiny | Sin enviar audio a servidores |
| Pantera | **Rive** con una máquina de estados: `reposando`, `escuchando`, `analizando`, `hablando`, `seguro`, `alerta` + entrada `boca` para sincronizar labios | Lottie como alternativa |
| Estado | Riverpod 2 (`AsyncNotifier`) | Feature-first + Clean Architecture |
| Overlay | `flutter_overlay_window` (SYSTEM_ALERT_WINDOW) | Permiso explicado al usuario en el onboarding |
| Persistencia | Isar / Hive: historial local cifrado | Nada sale del teléfono |

Permisos y políticas (Google Play): el acceso a notificaciones y la superposición deben declararse con
una justificación (función principal: protección antifraude) y pedirse con una pantalla explicativa.

## 3. Estructura del repositorio

```
iesston/
├── shared/
│   └── canales_oficiales.json        # dominios oficiales, acortadores y contactos (Python + Flutter)
├── docs/ARQUITECTURA.md
├── ml/                               # FASE 2: datos + fine-tuning
│   ├── Dockerfile                    # entorno GPU para entrenar y exportar
│   ├── requirements-train.txt
│   ├── aiess_ml/
│   │   ├── config.py                 # rutas, catálogo I1–I11, modelo base
│   │   ├── datos.py                  # carga, validación, limpieza y split estratificado
│   │   ├── osint_rules.py            # reglas OSINT offline (espejo del módulo Dart)
│   │   ├── evidencia.py              # léxico por indicio y evidencia con offsets
│   │   ├── prompts.py                # prompt del sistema, formato de entrada y JSON de salida
│   │   └── persona.py                # diálogos de la pantera
│   ├── scripts/
│   │   ├── 01_analizar_dataset.py    # patrones → reports/patrones.{json,md}
│   │   ├── 02_generar_simulaciones.py# micro-simulaciones → data/simulaciones.json
│   │   ├── 03_construir_sft.py       # data/sft/{train,val,test}.jsonl
│   │   ├── 04_finetune_lora.py       # LoRA / QLoRA con TRL
│   │   ├── 05_evaluar.py             # reglas | hf | gguf
│   │   └── 06_exportar_gguf.py       # merge → GGUF → Q4_K_M / Q8_0 + manifest
│   ├── data/  reports/  outputs/
└── app/                              # FASE 3: Flutter
    ├── Dockerfile                    # compila la APK (Flutter SDK + Android SDK + NDK)
    ├── pubspec.yaml
    ├── android/app/src/main/kotlin/.../AiessNotificationListener.kt
    ├── assets/
    │   ├── rive/pantera.riv
    │   ├── data/simulaciones.json  canales_oficiales.json
    │   └── models/                  # GGUF (o descarga verificada con sha256 en el primer uso)
    └── lib/
        ├── main.dart
        ├── core/        (di, theme, router, errors, platform_channels)
        ├── features/
        │   ├── guardian/            # notificaciones → triaje → overlay
        │   │   ├── data/ (notification_channel.dart)
        │   │   ├── domain/ (analizar_notificacion.dart)
        │   │   └── presentation/ (overlay_alerta.dart)
        │   ├── analisis/            # orquestador: OSINT + LLM + fusión
        │   │   ├── data/ (llm_local_datasource.dart, prompt_builder.dart, salida_parser.dart)
        │   │   ├── domain/ (veredicto.dart, analizar_mensaje_usecase.dart)
        │   │   └── presentation/
        │   ├── osint/               # url_analyzer.dart, typosquatting.dart, red_checker.dart
        │   ├── mascota/             # pantera_widget.dart, pantera_controller.dart (estados Rive)
        │   ├── voz/                 # tts_service.dart, stt_service.dart
        │   ├── chat/                # chat con la pantera
        │   └── entrenamiento/       # micro-simulaciones y puntaje
        └── shared/widgets/
```

## 4. Contrato del modelo (idéntico en Python y Dart)

Entrada (mensaje del usuario):
```
Analiza este mensaje y responde solo con JSON.
Canal: notificación de Gmail (vista previa) | correo | SMS | WhatsApp | enlace pegado
Asunto: …
Adjuntos: zip (137 KB) | ninguno
Enlaces reales: https://… | ninguno
Mensaje:
<<<
…
>>>
[OSINT]
- host: riesgo alto (75): …
- El texto muestra X pero el enlace real lleva a Y
- Remitente: no disponible
- Verificacion en red: no realizada
```
Salida, una línea JSON. El orden importa: la app colorea a la pantera con `veredicto` y empieza a hablar con `voz`
mientras se genera el resto:
`{"veredicto":"PHISHING","riesgo":"alto","puntaje":90,"voz":"…","indicios":["I2","I8"],"explicacion":"…","que_hacer":"…"}`

## 5. Decisiones sobre los datos

- **I7 (remitente)** no se puede ver en el CSV: no hay columna de remitente. Se excluye de la salida del LLM y lo
  decide el OSINT cuando la notificación trae el remitente. No cambia la etiqueta: ningún correo tiene solo I7.
- **hops_count** no existe en una notificación ni en un SMS: se usa solo en el análisis, no como entrada del modelo.
- **`urls`** contiene los href reales, distintos del texto visible. Con eso se aprende I4 (63 casos).
- Los dominios `.example/.test/.invalid` del dataset no generan alerta por sí solos, para que el modelo no aprenda un atajo que
  no existe en la vida real.
