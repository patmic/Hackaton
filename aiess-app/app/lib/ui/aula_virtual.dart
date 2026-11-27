// Aula virtual / microlecciones: abre el módulo de capacitación del equipo (carpeta Capacitacion/ del repo)
// dentro de AIESS, con su propio código, su lógica y sus pruebas. Usa el mismo tema que el resto de la app.
// El aula se adapta sola: en computadora usa menú lateral, rejilla de lecciones y ancho de lectura.
import 'package:capacitacion/src/application/providers.dart' as cap;
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/presentation/screens/inicio_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Dentro de AIESS el catálogo del aula se lee desde los assets del paquete del módulo de capacitación.
/// Lo usan `main.dart` y las pruebas que montan pantallas con contenido del aula.
final overridesAula = [
  cap.actividadRepositoryProvider.overrideWithValue(
    AssetActividadRepository(
      ruta: 'packages/capacitacion/assets/data/actividades.json',
    ),
  ),
];

Future<void> abrirAulaVirtual(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => const InicioScreen()));
