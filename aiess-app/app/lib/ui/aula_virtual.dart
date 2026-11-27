// Aula virtual / microlecciones: abre el módulo de capacitación del equipo (carpeta Capacitacion/ del repo)
// dentro de AIESS, con su propio código, su lógica y sus pruebas. Usa el mismo tema que el resto de la app.
import 'package:capacitacion/src/presentation/screens/inicio_screen.dart';
import 'package:material_ui/material_ui.dart';

Future<void> abrirAulaVirtual(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const InicioScreen()));
