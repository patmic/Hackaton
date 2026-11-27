import 'package:aiess/features/analisis/motor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lee la respuesta del servidor cortada antes de que_hacer', () {
    const cortada =
        '{"veredicto": "PHISHING", "riesgo": "alto", "puntaje": 82, "voz": "Alto ahí, esto tiene señales de engaño.", '
        '"indicios": ["I2", "I8"], "explicacion": "El enlace lleva a iess-pagos.example"';
    final v = leerSalidaModelo(cortada);
    expect(v, isNotNull);
    expect(v!.phishing, isTrue);
    expect(v.indicios, ['I2', 'I8']);
  });
  test('lee la respuesta completa', () {
    final v = leerSalidaModelo(
      '{"veredicto": "SEGURO", "riesgo": "bajo", "puntaje": 3, "voz": "Todo bien.", "indicios": [], "explicacion": "x", "que_hacer": "y"}',
    );
    expect(v!.phishing, isFalse);
  });
  test('texto sin JSON no se acepta', () {
    expect(leerSalidaModelo('hola'), isNull);
  });
}
