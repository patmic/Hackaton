// Diseño adaptable del aula: en celular una columna; en computadora, tarjetas en rejilla y textos con
// ancho de lectura cómodo (no líneas de 1.800 px que cuestan seguir).
import 'package:material_ui/material_ui.dart';

/// Ancho a partir del cual se usa el diseño de computadora (menú lateral, rejilla).
const anchoEscritorio = 900.0;

/// Centra el contenido con un ancho máximo de lectura.
class AnchoLectura extends StatelessWidget {
  const AnchoLectura({super.key, required this.child, this.maximo = 780});
  final Widget child;
  final double maximo;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maximo),
      child: child,
    ),
  );
}

/// Rejilla de tarjetas que se adapta al ancho: 1, 2 o 3 columnas.
class RejillaAdaptable extends StatelessWidget {
  const RejillaAdaptable({
    super.key,
    required this.children,
    this.espacio = 12,
    this.minimoTarjeta = 340,
  });
  final List<Widget> children;
  final double espacio, minimoTarjeta;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final columnas = (c.maxWidth / minimoTarjeta).floor().clamp(1, 3);
      final ancho = (c.maxWidth - espacio * (columnas - 1)) / columnas;
      return Wrap(
        spacing: espacio,
        runSpacing: espacio,
        children: [for (final h in children) SizedBox(width: ancho, child: h)],
      );
    },
  );
}
