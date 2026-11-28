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

  test(
    'Outlook (Vínculos seguros) y Gmail envuelven el enlace del sello: se recupera',
    () {
      const outlook =
          'Estimado afiliado: ver sello https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fsella.ejemplo.ec'
          '%2Fcheckin%2FmJgSxhVLg8t0ZtpOGrVdPrUy.ee183dcd83d7d994&data=05%7C02%7C&sdata=abc&reserved=0';
      expect(
        Sello.codigoEn(outlook),
        'mJgSxhVLg8t0ZtpOGrVdPrUy.ee183dcd83d7d994',
      );
      expect(
        desenvolverEnlaces(outlook),
        contains('https://sella.ejemplo.ec/checkin/'),
      );
      const gmail =
          'https://www.google.com/url?q=https://sella.ejemplo.ec/checkin/mJgSxhVLg8t0ZtpOGrVdPrUy.ee183dcd83d7d994&sa=D';
      expect(
        Sello.codigoEn(gmail),
        'mJgSxhVLg8t0ZtpOGrVdPrUy.ee183dcd83d7d994',
      );
    },
  );

  test(
    'aviso de Outlook: «Asunto • inicio del correo» → se usa solo el asunto',
    () {
      expect(
        Sello.variantesAsunto(
          'IESS: Su cita médica fue confirmada (caso 3) • Estimado afiliado: Su cita médica en el Hospital',
        ),
        contains('IESS: Su cita médica fue confirmada (caso 3)'),
      );
    },
  );
}
