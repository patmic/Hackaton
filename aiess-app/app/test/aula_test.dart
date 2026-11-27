import 'package:capacitacion/src/application/providers.dart' as cap;
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/presentation/screens/inicio_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aiess/ui/tema.dart';

void main() {
  testWidgets('el aula virtual abre con el tema de AIESS', (t) async {
    await t.pumpWidget(ProviderScope(
      overrides: [
        cap.actividadRepositoryProvider
            .overrideWithValue(AssetActividadRepository(ruta: 'packages/capacitacion/assets/data/actividades.json')),
      ],
      child: MaterialApp(theme: temaAIess(), home: const InicioScreen()),
    ));
    await t.pump(const Duration(seconds: 1));
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('el aula no se desborda en 320 dp con letra al 200 %', (t) async {
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(ProviderScope(
      overrides: [
        cap.actividadRepositoryProvider
            .overrideWithValue(AssetActividadRepository(ruta: 'packages/capacitacion/assets/data/actividades.json')),
      ],
      child: MaterialApp(
        theme: temaAIess(),
        home: const MediaQuery(
          data: MediaQueryData(size: Size(320, 640), textScaler: TextScaler.linear(2)),
          child: InicioScreen(),
        ),
      ),
    ));
    await t.pump(const Duration(seconds: 1));
    final e = t.takeException();
    expect(e, isNull, reason: '$e');
  });
}
