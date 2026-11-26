import 'package:capacitacion/src/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la app arranca y muestra el inicio', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CapacitacionApp()));
    expect(find.text('Módulo de capacitaciones'), findsOneWidget);
  });
}
