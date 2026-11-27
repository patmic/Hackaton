// Aula virtual / microlecciones: abre el módulo de capacitación del equipo (carpeta Capacitacion/ del repo)
// dentro de AIESS, con su propio código, su lógica y sus pruebas. Usa el mismo tema que el resto de la app.
import 'package:capacitacion/src/presentation/screens/inicio_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'tema.dart';

Future<void> abrirAulaVirtual(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _AulaAdaptable()));

/// En pantallas anchas (web en computadora) el aula va en una columna centrada de lectura cómoda,
/// en vez de líneas de texto de 1.300 px que cuestan seguir.
class _AulaAdaptable extends StatelessWidget {
  const _AulaAdaptable();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => c.maxWidth < 900
            ? const InicioScreen()
            : ColoredBox(
                color: Tono.azulSuave,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 820),
                    decoration: const BoxDecoration(
                      boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 32, offset: Offset(0, 8))],
                    ),
                    child: const InicioScreen(),
                  ),
                ),
              ),
      );
}
