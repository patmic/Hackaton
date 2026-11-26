import 'package:capacitacion/src/app.dart';
import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/actividad_repository.dart';
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
          actividadRepositoryProvider.overrideWithValue(
            MemoriaActividadRepository(catalogoReal()),
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

  Future<void> tocar(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('la alerta T2 para 65+ aparece solo al elegir ese rango', (
    tester,
  ) async {
    await abrirApp(tester);
    await tocar(tester, find.widgetWithText(ChoiceChip, '18-29'));
    expect(find.textContaining('Alerta activa'), findsNothing);

    await tocar(tester, find.widgetWithText(ChoiceChip, '65+'));
    expect(find.byKey(const ValueKey('actividad-M1-A1-01')), findsOneWidget);
    expect(find.textContaining('Alerta activa'), findsWidgets);
  });

  testWidgets('una ronda de ¿real o estafa? guarda el progreso', (
    tester,
  ) async {
    final ronda = catalogoReal().firstWhere((a) => a.id == 'M1-A2-01');
    final tarjetas = EvaluadorRealOEstafa.tarjetasDe(ronda);
    final estafas = tarjetas.where((t) => t.esEstafa).length;

    await abrirApp(tester);
    await tocar(tester, find.text('Catálogo').last);
    await tocar(tester, find.byKey(const ValueKey('actividad-M1-A2-01')));
    await tocar(tester, find.text('Practicar: ¿real o estafa?'));

    // Responde «Es estafa» a todo: acierta las estafas y en los correos
    // reales recibe el mensaje de prudencia, nunca un reproche.
    for (var i = 0; i < tarjetas.length; i++) {
      expect(find.text('Caso ${i + 1} de ${tarjetas.length}'), findsOneWidget);
      await tocar(tester, find.text('Es estafa'));
      expect(
        find.text(
          tarjetas[i].esEstafa
              ? '¡Bien! Detectaste la estafa.'
              : 'Era legítimo, pero dudar está bien: verificar siempre es '
                    'mejor que arriesgarse.',
        ),
        findsOneWidget,
      );
      final esUltima = i == tarjetas.length - 1;
      await tocar(
        tester,
        find.text(esUltima ? 'Ver resultado' : 'Siguiente caso'),
      );
    }

    expect(
      find.text('$estafas de ${tarjetas.length} casos reconocidos'),
      findsOneWidget,
    );
    final guardado = await progreso.cargar();
    expect(guardado.mejoresPuntajes['M1-A2-01'], estafas / tarjetas.length);
    expect(guardado.estaCompletada('M1-A2-01'), isTrue);
  });

  testWidgets('verificar un remitente de la Black List', (tester) async {
    await abrirApp(tester);
    await tocar(tester, find.text('Verificar').last);

    await tester.enterText(
      find.byKey(const ValueKey('campo-remitente')),
      'reembolsos@iess-tramites-ec.com',
    );
    await tocar(tester, find.byKey(const ValueKey('boton-verificar')));

    expect(find.text('ROJO · Es una estafa'), findsOneWidget);
    expect(find.textContaining('en qué rango de edad'), findsOneWidget);
    expect(find.text('Aprende a reconocerlo'), findsOneWidget);
  });

  testWidgets('verificar sin datos muestra un aviso', (tester) async {
    await abrirApp(tester);
    await tocar(tester, find.text('Verificar').last);
    await tocar(tester, find.byKey(const ValueKey('boton-verificar')));
    expect(find.text('Ingresa el código o el remitente.'), findsOneWidget);
  });
}
