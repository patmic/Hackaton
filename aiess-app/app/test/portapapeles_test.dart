// Al copiar o compartir un correo (Outlook, Gmail, Yahoo) el texto plano pierde el enlace de la imagen del sello;
// la versión HTML lo conserva. El bot debe recuperarlo y verificar el sello solo.
import 'package:aiess/features/sello/sello.dart';
import 'package:aiess/ui/inicio_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const texto = 'ANTI-PHISHING\nEstimado afiliado:\nSu cesantía fue aprobada.';
  const html =
      '<div><a href="https://sella.ejemplo.ec/checkin/mJgSxhVLg8t0ZtpOGrVdPrUy.ee183dcd83d7d994">'
      '<img src="https://sella.ejemplo.ec/img/x.png" alt="ANTI-PHISHING"></a></div>'
      '<p>Estimado afiliado:</p><p>Ver en <a href="http://iess-pagos.net/login">www.iess.gob.ec</a></p>';

  test(
    'recupera el enlace de la imagen del sello y el destino real de los botones',
    () {
      final t = conEnlacesDelHtml(texto, html);
      expect(Sello.codigoEn(t), 'mJgSxhVLg8t0ZtpOGrVdPrUy.ee183dcd83d7d994');
      expect(t, contains('www.iess.gob.ec [http://iess-pagos.net/login]'));
    },
  );

  test('sin HTML queda el texto tal cual; sin texto se arma desde el HTML', () {
    expect(conEnlacesDelHtml(texto, null), texto);
    expect(conEnlacesDelHtml('', html), contains('Estimado afiliado'));
  });
}
