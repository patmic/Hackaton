import 'package:capacitacion/src/app.dart';
import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/data/nucleo_api.dart';
import 'package:capacitacion/src/data/observador_api.dart';
import 'package:capacitacion/src/data/progreso_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

/// De punta a punta: lo que la persona responde en una lección cambia su plan
/// y lo que el aula le recomienda.
void main() {
  late MemoriaAlmacenObservador almacen;

  Future<void> abrirApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    almacen = MemoriaAlmacenObservador(
      const DatosObservador(idSeudonimo: 'dispositivo0123456789abcdef'),
    );
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
          almacenObservadorProvider.overrideWithValue(almacen),
          observadorApiProvider.overrideWithValue(null),
        ],
        child: const CapacitacionApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sin prácticas, la tarjeta explica que el plan se arma solo', (
    tester,
  ) async {
    await abrirApp(tester);
    await mostrar(tester, find.byKey(const ValueKey('tarjeta-plan-personal')));
    expect(find.text('Lo que más te conviene practicar'), findsOneWidget);
    expect(find.textContaining('se ordenarán solas para ti'), findsOneWidget);
    // Sin servidor configurado no se ofrece compartir: todo queda aquí.
    expect(
      find.byKey(const ValueKey('interruptor-compartir-radar')),
      findsNothing,
    );
  });

  testWidgets(
    'fallar las estafas de una ronda cambia el plan y lo recomendado',
    (tester) async {
      final ronda = catalogoReal().firstWhere((a) => a.id == 'M1-A2-01');
      final tarjetas = EvaluadorRealOEstafa.tarjetasDe(ronda);
      final senales = {
        for (final t in tarjetas)
          if (t.esEstafa) ...t.indicios,
      };

      await abrirApp(tester);
      await tocar(tester, find.text('Catálogo').last);
      await tocar(tester, find.byKey(const ValueKey('actividad-M1-A2-01')));
      await tocar(tester, find.text('Practicar: ¿real o estafa?'));
      // Responde «Es real» a todo: se le pasan todas las estafas.
      for (var i = 0; i < tarjetas.length; i++) {
        await tocar(tester, find.text('Es real'));
        await tocar(
          tester,
          find.text(
            i == tarjetas.length - 1 ? 'Ver resultado' : 'Siguiente caso',
          ),
        );
      }

      // El observador guardó un juicio por tarjeta, en el dispositivo.
      expect(almacen.datos.observaciones, hasLength(tarjetas.length));
      expect(
        almacen.datos.observaciones.where((o) => o.acerto == false),
        hasLength(tarjetas.where((t) => t.esEstafa).length),
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tocar(tester, find.text('Para ti').last);

      await mostrar(
        tester,
        find.byKey(const ValueKey('tarjeta-plan-personal')),
      );
      expect(find.textContaining('Para practicar'), findsWidgets);
      expect(
        find.textContaining('En las actividades se te pasó'),
        findsWidgets,
      );
      // Las recomendaciones ahora explican que trabajan lo que le costó.
      final motivos = find.textContaining('Te conviene practicar: ');
      expect(motivos, findsWidgets);
      final texto = (motivos.evaluate().first.widget as Text).data!;
      expect(senales.any((i) => texto.contains(i.nombre)), isTrue);
    },
  );
}
