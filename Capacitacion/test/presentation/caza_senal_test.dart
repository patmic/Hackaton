import 'package:capacitacion/src/app.dart';
import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/data/progreso_repository.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:capacitacion/src/presentation/screens/caza_senal_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

void main() {
  testWidgets('Caza la señal: se juega completa y queda guardada', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final progreso = MemoriaProgresoRepository();
    final act = catalogoReal().firstWhere((a) => a.id == 'M1-A1-01');
    final c = act.contenido as ContenidoCazaSenal;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          actividadRepositoryProvider.overrideWithValue(
            MemoriaActividadRepository(catalogoReal()),
          ),
          progresoRepositoryProvider.overrideWithValue(progreso),
        ],
        child: MaterialApp(home: CazaSenalScreen(actividad: act)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0 de ${c.senales.length}'), findsOneWidget);

    // Una pista ilumina una zona; después se tocan todas las partes con trampa.
    await tocar(tester, find.text('Dame una pista'));
    expect(find.text('Mira la parte que brilla.'), findsOneWidget);
    final m = c.mensaje;
    final textos = <String>[
      for (final s in c.senales)
        switch (s.zona.tipo) {
          TipoZona.remitente => m.remitente,
          TipoZona.asunto => m.asunto,
          TipoZona.cuerpo => m.parrafos[(s.zona.parrafo ?? 1) - 1],
          TipoZona.boton => m.boton!,
          TipoZona.adjunto => m.adjunto!,
          TipoZona.qr => 'Escanea este código',
        },
    ];
    for (final t in textos) {
      await tocar(tester, find.textContaining(t, findRichText: true).first);
    }
    expect(find.text('¡Las encontraste todas!'), findsOneWidget);
    expect(find.textContaining('1 pista'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // termina el confeti
    expect((await progreso.cargar()).estaCompletada('M1-A1-01'), isTrue);
  });

  testWidgets('aula en computadora: menú lateral en vez de barra inferior', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1;
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
        ],
        child: const CapacitacionApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
