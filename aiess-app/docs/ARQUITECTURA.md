# AIESS: interfaces y arquitectura

AIESS reúne sus pantallas móvil y web en una sola aplicación Flutter. Ambas usan el paquete compartido `recursos/Boilerplate/ThemeLight/flutter`; el diseño cambia de disposición según el ancho de pantalla, pero mantiene colores, tipografía, componentes y estados comunes. La mascota visual es un robot guardián dibujado en Flutter.

## Interfaces

| Superficie | Implementación | Entrada |
|---|---|---|
| Móvil | Flutter con navegación compacta y funciones nativas Android | `aiess-app/app/lib/ui/inicio_page.dart` |
| Web y escritorio | La misma aplicación Flutter; panel de escritorio adaptable | `aiess-app/app/lib/ui/web_escritorio.dart` |
| Capacitación | Módulo Flutter integrado y publicable por separado | `Capacitacion/` |
| SellaCorreo | Interfaz web propia con los tokens y componentes CSS ThemeLight | `SellaLogo/` y `SellaCorreo/` |

`aiess-app/app/lib/main.dart` selecciona la experiencia de escritorio o móvil según la plataforma y el tamaño disponible. La lógica de análisis y sus servicios se comparten entre las dos experiencias Flutter.

## Tema y mascota

- Los tokens, fuentes y el tema Material residen en `recursos/Boilerplate/ThemeLight/flutter/`.
- AIESS y Capacitación declaran ese paquete mediante dependencia local de Flutter.
- Los estilos específicos de cada pantalla usan los mismos tokens del paquete para superficies, texto, bordes y estados de seguridad.
- `aiess-app/app/lib/features/mascota/robot_guardia.dart` dibuja el robot con `CustomPainter` y expone estados comunes: reposo, escucha, análisis, seguro y alerta.
- Los nombres, mensajes y recursos visuales de AIESS deben referirse al robot guardián.

## Análisis de mensajes

En Android, `NotificationListenerService` entrega la vista previa de notificaciones autorizadas. La aplicación combina el triaje local y las señales OSINT con el análisis del modelo cuando corresponde. Las pantallas móvil y web muestran el mismo resultado y sus estados de seguridad; las capacidades que dependen de Android se limitan a esa plataforma.

El módulo `aiess-app/ml/` contiene preparación de datos, prompts y entrenamiento. La persona del modelo se define en `aiess-app/ml/aiess_ml/persona.py` y las instrucciones de análisis en `aiess-app/ml/aiess_ml/prompts.py`.

## Ubicaciones principales

```text
recursos/Boilerplate/ThemeLight/flutter/  Tema Material, tokens y fuentes compartidas
aiess-app/app/lib/main.dart             Entrada y selección de interfaz adaptable
aiess-app/app/lib/ui/                   Pantallas móvil, escritorio y estilos de AIESS
aiess-app/app/lib/features/mascota/     Robot guardián animado
aiess-app/app/android/                  Integración nativa Android
aiess-app/ml/                           Datos, prompts y herramientas del modelo
Capacitacion/                           Módulo Flutter de aprendizaje
SellaLogo/                              Sitio de simulación con estilo ThemeLight
```
