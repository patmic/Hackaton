import 'package:capacitacion/src/app.dart';
import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/capsula_repository.dart';
import 'package:capacitacion/src/data/nucleo_api.dart';
import 'package:capacitacion/src/data/progreso_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

void main() {
  late MemoriaProgresoRepository progreso;

  Future<void> abrirApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    progreso = MemoriaProgresoRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          capsulaRepositoryProvider.overrideWithValue(
            MemoriaCapsulaRepository(catalogoReal()),
          ),
          progresoRepositoryProvider.overrideWithValue(progreso),
          nucleoApiProvider.overrideWithValue(
            MockNucleoApi(reloj: () => DateTime.utc(2026, 11, 27)),
          ),
        ],
        child: const CapacitacionApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('al elegir 65+ la alerta T2 sube la cápsula de reembolso', (
    tester,
  ) async {
    await abrirApp(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, '65+'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('capsula-t2-reembolso-24h')),
      findsOneWidget,
    );
    expect(find.textContaining('Alerta activa'), findsOneWidget);
  });

  testWidgets('quiz completo guarda el progreso', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Catálogo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('capsula-t2-reembolso-24h')));
    await tester.pumpAndSettle();

    final practicar = find.text('Practicar: ¿real o estafa?');
    await tester.ensureVisible(practicar);
    await tester.pumpAndSettle();
    await tester.tap(practicar);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Es estafa'));
    await tester.pumpAndSettle();
    expect(find.text('¡Bien! Detectaste la estafa.'), findsOneWidget);
    await tester.tap(find.text('Siguiente caso'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Es estafa'));
    await tester.pumpAndSettle();
    expect(find.textContaining('dudar está bien'), findsOneWidget);
    await tester.tap(find.text('Ver resultado'));
    await tester.pumpAndSettle();

    expect(find.text('1 de 2 casos reconocidos'), findsOneWidget);
    final guardado = await progreso.cargar();
    expect(guardado.mejoresPuntajes['t2-reembolso-24h'], .5);
    expect(guardado.estaCompletada('t2-reembolso-24h'), isTrue);
  });

  testWidgets('verificar un remitente de la Black List', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Verificar').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('campo-remitente')),
      'reembolsos@iess-tramites-ec.com',
    );
    await tester.tap(find.byKey(const ValueKey('boton-verificar')));
    await tester.pumpAndSettle();

    expect(find.text('ROJO · Es una estafa'), findsOneWidget);
    expect(find.textContaining('en qué rango de edad'), findsOneWidget);
    expect(find.text('Aprende a reconocerlo'), findsOneWidget);
  });

  testWidgets('verificar sin datos muestra un aviso', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Verificar').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('boton-verificar')));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa el código o el remitente.'), findsOneWidget);
  });
}
