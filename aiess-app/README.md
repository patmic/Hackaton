# AIESS: cóndor guardián antiphishing del IESS

App Flutter (Android y web) con un cóndor que habla, aviso tipo Truecaller cuando llega un correo,
aula virtual (módulo `../Capacitacion`) y un modelo LFM2 entrenado que corre en un servidor.

- Arquitectura: [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md)
- Datos y modelo: `ml/` · App: `app/` · Servidor (Docker + Caddy): `servidor/` ([guía](servidor/LEEME_ORACLE.md))
- Estilo: ThemeGreen (`../recursos/Boilerplate/ThemeGreen`), tokens en `app/lib/ui/tema.dart`.

## Para empezar a trabajar en la app

**Requisitos:** Flutter **3.50.1** (stable), Android Studio con SDK, **NDK** y **CMake** (llama.cpp se compila
para el modelo local de respaldo), un celular Android 8+ de 64 bits o el emulador.

```powershell
git clone --recurse-submodules -b flutter https://github.com/patmic/Hackaton.git
cd Hackaton/aiess-app/app
copy secretos.ejemplo.json secretos.json   # pide la dirección y la clave del servidor al equipo (no se suben)
flutter pub get
flutter test
```

Correr y compilar (siempre con los secretos):

```powershell
flutter run --dart-define-from-file=secretos.json
flutter build apk --release --target-platform android-arm64 --dart-define-from-file=secretos.json
flutter build web --release --no-web-resources-cdn --dart-define-from-file=secretos.json --dart-define=AIESS_SERVIDOR=
```

- `secretos.json` y `servidor/.env` están en `.gitignore`: **nunca** los subas (el repo es público).
- Si clonaste sin `--recurse-submodules`: `git submodule update --init aiess-app/third_party/llama.cpp`.
- El modelo `.gguf` (730 MB) no está en el repo: está en el servidor; para probar en tu PC pídelo al equipo
  y sigue `servidor/LEEME_ORACLE.md` (o `servir_web_local.py`).
- Antes de subir cambios: `flutter analyze` y `flutter test` (incluyen pruebas de accesibilidad: letra grande,
  botones de 48 dp y contraste).

## Fase 2: cómo correrla

Pasos 01–03 y la evaluación por reglas: solo usan la librería estándar de Python (corren en este PC).

```powershell
python -I ml/scripts/01_analizar_dataset.py
python -I ml/scripts/02_generar_simulaciones.py
python -I ml/scripts/03_construir_sft.py
python -I ml/scripts/05_evaluar.py --backend reglas
```

Pasos 04–06 (fine-tuning y GGUF): necesitan una GPU NVIDIA. Hay dos opciones:

1. **Google Colab** (T4 gratis o L4): subir la carpeta `iesston/`, luego
   `pip install -r ml/requirements-train.txt` y correr:
   ```
   python ml/scripts/04_finetune_lora.py --qlora          # en T4
   python ml/scripts/06_exportar_gguf.py --corrida ml/outputs/lfm2-1.2b-qlora
   python ml/scripts/05_evaluar.py --backend gguf --modelo ml/outputs/gguf/aiess-lfm2-1.2b-Q4_K_M.gguf
   ```
2. **Docker con GPU**: ver el encabezado de `ml/Dockerfile`.

Para gama baja o el análisis en segundo plano: `--modelo LiquidAI/LFM2-350M`.

Licencia: los pesos de LFM2 usan la *LFM Open License v1.0*. Revisar sus condiciones de uso comercial antes de publicar.
