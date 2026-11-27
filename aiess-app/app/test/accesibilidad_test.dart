// Lista de verificación de accesibilidad de la pantalla principal:
// celular pequeño (320 dp), letra del sistema al 200 %, sin animaciones, en todos los estados.
// Falla si algo se desborda, si un botón mide menos de 48 dp o si un botón no tiene nombre.
import 'package:aiess/features/mascota/robot_guardia.dart';
import 'package:aiess/ui/aiess_home_screen.dart';
import 'package:aiess/ui/aula_virtual.dart';
import 'package:aiess/ui/tema.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// El globo de sugerencias lee las lecciones del aula: va dentro de un ProviderScope, como en main.dart.
Widget _app(EstadoHoja estado, {double letra = 1, bool escuchando = false}) =>
    ProviderScope(
      overrides: overridesAula,
      child: MaterialApp(
        theme: temaAIess(),
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(320, 640),
            textScaler: TextScaler.linear(letra),
            disableAnimations: true,
          ),
          child: AiessHomeScreen(
            estado: estado,
            estadoMascota: switch (estado) {
              EstadoHoja.estafa => EstadoRobot.alerta,
              EstadoHoja.seguro => EstadoRobot.seguro,
              EstadoHoja.analizando => EstadoRobot.analizando,
              EstadoHoja.listo => EstadoRobot.reposo,
            },
            titulo: estado == EstadoHoja.estafa
                ? '¡Es una estafa!'
                : 'Hola, soy AIess',
            pasos: estado == EstadoHoja.analizando
                ? const ['Mirando el enlace', 'Pensándolo con mi cerebro']
                : const [],
            escuchando: escuchando,
            onPasteAndCheck: () {},
            onVoiceInput: () {},
            onPickImage: () {},
            onOpenSettings: () {},
            onTapMascota: () {},
            onReport: () {},
            onDone: () {},
            onAula: () {},
            onPracticar: () {},
          ),
        ),
      ),
    );

void main() {
  for (final estado in EstadoHoja.values) {
    for (final letra in [1.0, 1.5, 2.0]) {
      testWidgets('sin desbordes: $estado, letra ${letra}x, 320 dp', (t) async {
        t.view.physicalSize = const Size(320, 640);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(_app(estado, letra: letra));
        await t.pump(const Duration(milliseconds: 500));
        final e = t.takeException();
        if (e is FlutterError) debugPrint(e.toStringDeep());
        expect(e, isNull);
      });
    }
  }

  testWidgets(
    'botones de al menos 48 dp y con nombre para el lector de pantalla',
    (t) async {
      t.view.physicalSize = const Size(360, 760);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final semantica = t.ensureSemantics();
      for (final estado in [EstadoHoja.listo, EstadoHoja.estafa]) {
        await t.pumpWidget(_app(estado));
        await t.pump(const Duration(milliseconds: 300));
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(t, meetsGuideline(textContrastGuideline));
      }
      semantica.dispose();
    },
  );

  testWidgets('celular: globo de deepfakes y tutorial para copiar un correo', (
    t,
  ) async {
    t.view.physicalSize = const Size(360, 760);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app(EstadoHoja.listo));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('globo-deepfake')), findsOneWidget);

    final tutorial = find.byKey(const ValueKey('boton-tutorial-copiar'));
    await t.ensureVisible(tutorial);
    await t.tap(tutorial);
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Cómo copiar un correo'), findsOneWidget);
    // En el celular empieza por los pasos del celular.
    expect(
      find.text('Vuelve a AIESS y toca «Pegar y revisar».'),
      findsOneWidget,
    );
  });

  testWidgets('el globo de deepfakes solo aparece antes de revisar', (t) async {
    t.view.physicalSize = const Size(360, 760);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app(EstadoHoja.estafa));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('globo-deepfake')), findsNothing);
  });
}
