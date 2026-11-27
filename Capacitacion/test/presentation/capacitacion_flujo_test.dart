import 'package:capacitacion/src/app.dart';
import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/data/capacitacion_api.dart';
import 'package:capacitacion/src/data/nucleo_api.dart';
import 'package:capacitacion/src/data/progreso_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

void main() {
  Future<void> abrirApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          actividadRepositoryProvider.overrideWithValue(
            MemoriaActividadRepository(catalogoReal()),
          ),
          progresoRepositoryProvider.overrideWithValue(
            MemoriaProgresoRepository(),
          ),
          nucleoApiProvider.overrideWithValue(
            MockNucleoApi(reloj: () => DateTime.utc(2026, 11, 27)),
          ),
          capacitacionApiProvider.overrideWithValue(
            MockCapacitacionApi(reloj: () => DateTime.utc(2026, 11, 27, 9)),
          ),
        ],
        child: const CapacitacionApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder clave(String valor) => find.byKey(ValueKey(valor));

  testWidgets('«Quiero capacitarme» sin cuenta: consentimiento, doble opt-in, '
      'clic y momento enseñable', (tester) async {
    await abrirApp(tester);
    await tocar(tester, clave('boton-quiero-capacitarme'));
    expect(find.textContaining('No medimos si lo abres'), findsOneWidget);

    // Sin cuenta hay que dar un correo válido.
    await tocar(tester, clave('boton-acepto'));
    expect(clave('error-correo'), findsOneWidget);
    await tester.enterText(clave('campo-correo'), 'persona@practica.ejemplo');
    await tocar(tester, clave('boton-acepto'));
    expect(
      find.text('Confirma tu correo con el enlace que te enviamos.'),
      findsOneWidget,
    );

    await tocar(tester, clave('demo-confirmar'));
    expect(
      find.text('Revisa tu correo como lo harías cualquier día.'),
      findsOneWidget,
    );

    await tocar(tester, clave('demo-clic'));
    expect(find.text('Era un correo de práctica'), findsOneWidget);
    expect(
      find.text('«No confíes en la página que abre un QR»'),
      findsOneWidget,
    );
    expect(find.text('Tu nivel inicial: Básico'), findsOneWidget);
    await mostrar(tester, clave('demo-siguiente'));
    expect(clave('demo-siguiente'), findsOneWidget);
  });

  testWidgets('la sesión de demo cambia el tipo y la ruta', (tester) async {
    await abrirApp(tester);
    expect(find.text('Sin cuenta'), findsOneWidget);

    await tocar(tester, clave('boton-cambiar-sesion'));
    await tocar(tester, clave('sesion-EX2'));

    expect(find.text('Jubilado o pensionista'), findsOneWidget);
    expect(find.text('Perfil: En aprendizaje'), findsOneWidget);
    // Un EX2 ve la versión en audio.
    expect(clave('actividad-M1-A7-01'), findsOneWidget);
    expect(clave('actividad-M1-A1-01'), findsNothing);
  });
}
