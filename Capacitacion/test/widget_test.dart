import 'package:capacitacion/src/app.dart';
import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/data/progreso_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('la app arranca y muestra recomendaciones', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          actividadRepositoryProvider.overrideWithValue(
            MemoriaActividadRepository(catalogoReal()),
          ),
          progresoRepositoryProvider.overrideWithValue(
            MemoriaProgresoRepository(),
          ),
        ],
        child: const CapacitacionApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Recomendadas'), findsOneWidget);
  });
}
