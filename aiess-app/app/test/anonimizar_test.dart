import 'package:aiess/features/analisis/anonimizar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tapa los datos personales y deja las señales de estafa', () {
    final r = anonimizar('Estimado Juan Carlos Pérez, su cédula 1712345678 tiene un reembolso de \$187,40. '
        'Llame al 0991234567 o al +593 2 394 5666. Escriba a juan.perez@gmail.com. '
        'Deposite en la cuenta de ahorros 2201234567. Tarjeta 4111 1111 1111 1111. '
        'Ingrese en http://iess-pagos.net/reembolso?ced=1712345678 HOY.');
    expect(r.texto, contains('Estimado [NOMBRE]'));
    expect(r.texto, contains('[CÉDULA]'));
    expect(r.texto, contains('[TELÉFONO]'));
    expect(r.texto, contains('[usuario]@gmail.com'));
    expect(r.texto, contains('[CUENTA]'));
    expect(r.texto, contains('[TARJETA]'));
    // Lo que delata la estafa se conserva.
    expect(r.texto, contains('http://iess-pagos.net/reembolso?ced=1712345678'));
    expect(r.texto, contains('\$187,40'));
    expect(r.texto, contains('HOY'));
    for (final dato in ['Juan', 'Pérez', '0991234567', 'juan.perez', '2201234567', '4111']) {
      expect(r.texto.replaceAll('http://iess-pagos.net/reembolso?ced=1712345678', ''), isNot(contains(dato)), reason: dato);
    }
    expect(r.cambios, greaterThanOrEqualTo(7));
  });

  test('no toca los saludos genéricos ni un correo sin datos', () {
    final r = anonimizar('Estimado afiliado: su pensión será suspendida. Visite www.iess-actualiza.com');
    expect(r.texto, 'Estimado afiliado: su pensión será suspendida. Visite www.iess-actualiza.com');
    expect(r.cambios, 0);
  });
}
