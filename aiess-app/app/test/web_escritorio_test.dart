// Web de escritorio: tamaños reales de pantalla × zoom del navegador (letra 1x, 1.5x, 2x).
// Falla si algo se desborda, si un control no tiene nombre o si el texto no tiene contraste.
import 'package:aiess/ui/aula_virtual.dart';
import 'package:aiess/ui/tema.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aiess/ui/web_escritorio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _web(Size tam, double letra) => ProviderScope(
  overrides: overridesAula,
  child: MaterialApp(
    theme: temaAIess(),
    home: MediaQuery(
      data: MediaQueryData(
        size: tam,
        textScaler: TextScaler.linear(letra),
        disableAnimations: true,
      ),
      child: const WebEscritorio(),
    ),
  ),
);

void main() {
  for (final tam in const [
    Size(1024, 700),
    Size(1366, 768),
    Size(1920, 1080),
  ]) {
    for (final letra in [1.0, 1.5, 2.0]) {
      // Con zoom alto en pantallas angostas la web pasa a una columna (se prueba en accesibilidad_test).
      if (tam.width / letra < 860) continue;
      testWidgets(
        'web sin desbordes: ${tam.width.toInt()}x${tam.height.toInt()}, zoom ${letra}x',
        (t) async {
          t.view.physicalSize = tam;
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
          await t.pumpWidget(_web(tam, letra));
          await t.pump(const Duration(milliseconds: 500));
          final e = t.takeException();
          expect(e, isNull, reason: '$e');
        },
      );
    }
  }

  testWidgets('web: con zoom alto en pantalla angosta pasa a una columna', (
    t,
  ) async {
    late bool dos;
    await t.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Builder(
          builder: (c) {
            dos = WebEscritorio.cabe(c, 1366);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(dos, isFalse);
  });

  testWidgets('web: controles con nombre, de buen tamaño y con contraste', (
    t,
  ) async {
    t.view.physicalSize = const Size(1366, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final s = t.ensureSemantics();
    await t.pumpWidget(_web(const Size(1366, 768), 1));
    await t.pump(const Duration(milliseconds: 300));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(t, meetsGuideline(androidTapTargetGuideline));
    await expectLater(t, meetsGuideline(textContrastGuideline));
    s.dispose();
  });

  testWidgets('web: tutorial para copiar un correo y globo de deepfakes', (
    t,
  ) async {
    t.view.physicalSize = const Size(1366, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_web(const Size(1366, 768), 1));
    await t.pump(const Duration(milliseconds: 300));

    // El tutorial empieza plegado y se abre con su botón.
    expect(find.text('Cómo copiar un correo'), findsNothing);
    await t.tap(find.byKey(const ValueKey('boton-tutorial-copiar')));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Cómo copiar un correo'), findsOneWidget);
    expect(find.textContaining('Ctrl + V'), findsOneWidget);

    // El globo invita; al tocarlo muestra la lección «¿Qué es un deepfake?» (M15).
    expect(find.textContaining('qué es un deepfake'), findsOneWidget);
    // El globo sale del robot: se ve sin desplazar el panel izquierdo.
    final globo = find.byKey(const ValueKey('globo-deepfake'));
    expect(t.getRect(globo).bottom, lessThan(768));
    await t.tap(globo);
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('¿Qué es un deepfake?'), findsOneWidget);
    expect(find.textContaining('Hacer la lección'), findsOneWidget);
    await t.ensureVisible(find.text('Otra sugerencia'));
    await t.tap(find.text('Otra sugerencia'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('La voz clonada de tu familiar'), findsOneWidget);
  });

  testWidgets('web: el campo recibe el foco al abrir y Ctrl+Enter revisa', (
    t,
  ) async {
    t.view.physicalSize = const Size(1366, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_web(const Size(1366, 768), 1));
    await t.pump(const Duration(milliseconds: 300));
    final campo = t.widget<EditableText>(find.byType(EditableText));
    expect(
      campo.focusNode.hasFocus,
      isTrue,
      reason: 'el cursor debe empezar en el campo del correo',
    );
    // Texto demasiado corto: Ctrl+Enter debe dar el aviso de que falta pegar el correo.
    await t.enterText(find.byType(TextField), 'hola');
    await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await t.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Pega primero'), findsOneWidget);
  });
}
