import 'package:capacitacion/src/presentation/rutas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

void main() {
  testWidgets('solo los enlaces de verificación abren una pantalla', (
    tester,
  ) async {
    expect(
      generarRuta(const RouteSettings(name: '/verificar/$hashValido')),
      isA<MaterialPageRoute<void>>(),
    );
    // Un código mal formado igual abre la pantalla, que muestra AMARILLO.
    expect(generarRuta(const RouteSettings(name: '/verificar/abc')), isNotNull);
    expect(generarRuta(const RouteSettings(name: '/verificar')), isNull);
    expect(generarRuta(const RouteSettings(name: '/')), isNull);
    expect(
      generarRuta(
        const RouteSettings(name: 'https://otro.ejemplo/verificar/$hashValido'),
      ),
      isNull,
    );
  });
}
