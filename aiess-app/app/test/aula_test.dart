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
}
