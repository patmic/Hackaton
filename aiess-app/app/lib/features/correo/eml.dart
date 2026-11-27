// Lectura de un correo guardado (.eml, formato MIME de Gmail, Outlook, Thunderbird…), EN EL EQUIPO.
// Devuelve remitente, asunto y texto; en los correos HTML conserva los enlaces como «texto [enlace]»
// para que el análisis vea a dónde llevan de verdad (y encuentre el enlace del sello del IESS).
import 'dart:convert';
import 'dart:typed_data';

class CorreoEml {
  const CorreoEml({
    required this.remitente,
    required this.asunto,
    required this.cuerpo,
  });
  final String remitente, asunto, cuerpo;

  /// Texto completo para el análisis.
  String get paraAnalizar =>
      'De: $remitente\nAsunto: $asunto\n\n$cuerpo'.trim();
}

CorreoEml leerEml(Uint8List bytes) {
  final crudo = latin1
      .decode(bytes, allowInvalid: true)
      .replaceAll('\r\n', '\n');
  final (cab, cuerpo) = _partir(crudo);
  final remitente = _decodificarCabecera(cab['from'] ?? '');
  final asunto = _decodificarCabecera(cab['subject'] ?? '');
  return CorreoEml(
    remitente: remitente,
    asunto: asunto,
    cuerpo: _texto(cab, cuerpo).trim(),
  );
}

/// Separa cabeceras (desplegando líneas continuadas) y cuerpo.
(Map<String, String>, String) _partir(String s) {
  final i = s.indexOf('\n\n');
  final cabeceras = i < 0 ? s : s.substring(0, i);
  final cuerpo = i < 0 ? '' : s.substring(i + 2);
  final m = <String, String>{};
  String? ultima;
  for (final l in cabeceras.split('\n')) {
    if ((l.startsWith(' ') || l.startsWith('\t')) && ultima != null) {
      m[ultima] = '${m[ultima]} ${l.trim()}';
    } else {
      final p = l.indexOf(':');
      if (p > 0) {
        ultima = l.substring(0, p).trim().toLowerCase();
        m[ultima] = l.substring(p + 1).trim();
      }
    }
  }
  return (m, cuerpo);
}

String? _param(String cabecera, String nombre) => RegExp(
  '$nombre\\s*=\\s*"?([^";]+)"?',
  caseSensitive: false,
).firstMatch(cabecera)?.group(1);

/// Texto de la parte (o de la mejor parte de un multipart: texto plano primero, si no HTML).
String _texto(Map<String, String> cab, String cuerpo) {
  final tipo = (cab['content-type'] ?? 'text/plain').toLowerCase();
  if (tipo.startsWith('multipart/')) {
    final limite = _param(cab['content-type']!, 'boundary');
    if (limite == null) return cuerpo;
    final partes = cuerpo
        .split('--$limite')
        .where((p) => p.trim().isNotEmpty && !p.trim().startsWith('--'))
        .map((p) => _partir(p.replaceFirst(RegExp(r'^\n'), '')))
        .toList();
    final plano = partes.where(
      (p) => (p.$1['content-type'] ?? 'text/plain').toLowerCase().startsWith(
        'text/plain',
      ),
    );
    final html = partes.where(
      (p) => (p.$1['content-type'] ?? '').toLowerCase().startsWith('text/html'),
    );
    final anidadas = partes.where(
      (p) =>
          (p.$1['content-type'] ?? '').toLowerCase().startsWith('multipart/'),
    );
    final textos = <String>[
      for (final p in anidadas) _texto(p.$1, p.$2),
      if (plano.isNotEmpty) _texto(plano.first.$1, plano.first.$2),
      // Del HTML se toman los enlaces aunque haya texto plano (ahí suelen ir las trampas y el sello).
      if (html.isNotEmpty) _texto(html.first.$1, html.first.$2),
    ].where((t) => t.trim().isNotEmpty).toList();
    final adjuntos = [
      for (final p in partes)
        if ((p.$1['content-disposition'] ?? '').toLowerCase().contains(
          'attachment',
        ))
          _decodificarCabecera(
            _param(p.$1['content-disposition']!, 'filename') ?? 'adjunto',
          ),
    ];
    return [
      ...textos.toSet(),
      if (adjuntos.isNotEmpty) 'Adjuntos: ${adjuntos.join(', ')}',
    ].join('\n\n');
  }
  final bytes = _decodificarTransferencia(
    cuerpo,
    cab['content-transfer-encoding'] ?? '',
  );
  final texto = _decodificarCharset(bytes, _param(tipo, 'charset') ?? 'utf-8');
  return tipo.startsWith('text/html') ? _htmlATexto(texto) : texto;
}

List<int> _decodificarTransferencia(String s, String cte) {
  switch (cte.trim().toLowerCase()) {
    case 'base64':
      try {
        return base64.decode(s.replaceAll(RegExp(r'\s'), ''));
      } catch (_) {
        return latin1.encode(s);
      }
    case 'quoted-printable':
      return _qp(s);
    default:
      return latin1.encode(s);
  }
}

List<int> _qp(String s) {
  final sin = s.replaceAll(RegExp(r'=\n'), '');
  final out = <int>[];
  for (var i = 0; i < sin.length; i++) {
    final c = sin[i];
    if (c == '=' && i + 2 < sin.length + 1 && i + 2 <= sin.length - 1 + 1) {
      final h = int.tryParse(
        sin.substring(i + 1, (i + 3).clamp(0, sin.length)),
        radix: 16,
      );
      if (h != null && i + 2 < sin.length) {
        out.add(h);
        i += 2;
        continue;
      }
    }
    out.add(sin.codeUnitAt(i) & 0xff);
  }
  return out;
}

String _decodificarCharset(List<int> b, String charset) {
  final cs = charset.toLowerCase();
  if (cs.contains('8859') || cs.contains('latin') || cs.contains('1252'))
    return latin1.decode(b, allowInvalid: true);
  return utf8.decode(b, allowMalformed: true);
}

/// Asuntos y remitentes codificados: =?utf-8?B?...?= o =?utf-8?Q?...?=
String _decodificarCabecera(String s) =>
    s.replaceAllMapped(RegExp(r'=\?([^?]+)\?([bBqQ])\?([^?]*)\?=\s*'), (m) {
      final bytes = m[2]!.toLowerCase() == 'b'
          ? _decodificarTransferencia(m[3]!, 'base64')
          : _qp(m[3]!.replaceAll('_', ' '));
      return _decodificarCharset(bytes, m[1]!);
    }).trim();

String _htmlATexto(String h) {
  var t = h
      .replaceAll(
        RegExp(
          r'<(script|style)[^>]*>.*?</\1>',
          caseSensitive: false,
          dotAll: true,
        ),
        ' ',
      )
      // Enlaces: «texto [destino real]» (así se ve si el texto dice una cosa y lleva a otra).
      .replaceAllMapped(
        RegExp(
          r'''<a\s[^>]*href\s*=\s*["']([^"']+)["'][^>]*>(.*?)</a>''',
          caseSensitive: false,
          dotAll: true,
        ),
        (m) =>
            ' ${m[2]!.replaceAll(RegExp(r'<[^>]+>'), ' ').trim()} [${m[1]}] ',
      )
      .replaceAll(
        RegExp(r'<br\s*/?>|</p>|</div>|</tr>|</li>', caseSensitive: false),
        '\n',
      )
      .replaceAll(RegExp(r'<[^>]+>'), ' ');
  const entidades = {
    '&nbsp;': ' ',
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&#39;': "'",
  };
  entidades.forEach((k, v) => t = t.replaceAll(k, v));
  return t
      .split('\n')
      .map((l) => l.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
      .where((l) => l.isNotEmpty)
      .join('\n');
}
