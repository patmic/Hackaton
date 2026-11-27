import 'dart:convert';
import 'dart:typed_data';

import 'package:aiess/features/correo/eml.dart';
import 'package:aiess/features/sello/sello.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _b(String s) =>
    Uint8List.fromList(utf8.encode(s.replaceAll('\n', '\r\n')));

void main() {
  test(
    'correo multipart: asunto codificado, texto, enlace real del HTML y adjunto',
    () {
      final asunto = base64.encode(
        utf8.encode('IESS: tu pensión será suspendida'),
      );
      final html = base64.encode(
        utf8.encode(
          '<p>Estimado afiliado,</p><p><a href="http://iess-pagos.net/login">www.iess.gob.ec</a></p>',
        ),
      );
      final c = leerEml(
        _b('''From: "IESS Notificaciones" <avisos@iess-pagos.net>
Subject: =?utf-8?B?$asunto?=
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="XYZ"

--XYZ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Actualice su clave hoy mismo, su pensi=C3=B3n ser=C3=A1 suspendida.
--XYZ
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: base64

$html
--XYZ
Content-Type: application/zip
Content-Disposition: attachment; filename="detalle.zip"

UEsDBA==
--XYZ--
'''),
      );
      expect(c.asunto, 'IESS: tu pensión será suspendida');
      expect(c.remitente, contains('avisos@iess-pagos.net'));
      expect(c.cuerpo, contains('su pensión será suspendida'));
      // El texto visible dice iess.gob.ec, pero el enlace real lleva a iess-pagos.net.
      expect(
        c.cuerpo,
        contains('www.iess.gob.ec [http://iess-pagos.net/login]'),
      );
      expect(c.cuerpo, contains('Adjuntos: detalle.zip'));
      expect(asuntoDelIess(c.asunto), isTrue);
    },
  );

  test('el enlace del sello en la imagen del correo se encuentra', () {
    final c = leerEml(
      _b('''From: comunicacion@iess.gob.ec
Subject: Boletin informativo
Content-Type: text/html; charset=utf-8

<a href="https://sella.ejemplo.ec/checkin/AbCdEfGh.0123456789abcdef"><img src="sello.png"></a>
<p>Hola</p>
'''),
    );
    expect(Sello.codigoEn(c.paraAnalizar), 'AbCdEfGh.0123456789abcdef');
  });
}
