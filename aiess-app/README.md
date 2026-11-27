# AIESS

AIESS reúne la aplicación móvil y la interfaz web de escritorio, con el mismo flujo de revisión, aprendizaje y práctica.

Robot guardián antiphishing del IESS: aviso tipo Truecaller cuando llega un correo, aula virtual
(`../Capacitacion`) y un modelo LFM2 entrenado que corre en un servidor. Estilo: ThemeLight.

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
