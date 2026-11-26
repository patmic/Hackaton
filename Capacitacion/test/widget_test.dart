import 'dart:io';

import 'package:capacitacion/src/app.dart';
import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/capsula_repository.dart';
import 'package:capacitacion/src/data/progreso_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la app arranca y muestra recomendaciones', (tester) async {
    final catalogo = parsearCatalogo(
      File('assets/data/capsulas.json').readAsStringSync(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          capsulaRepositoryProvider.overrideWithValue(
            MemoriaCapsulaRepository(catalogo),
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
