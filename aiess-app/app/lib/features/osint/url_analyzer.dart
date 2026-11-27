// OSINT offline: reglas idénticas a ml/aiess_ml/osint_rules.py (el modelo se entrenó con este mismo texto).
import '../../core/canales.dart';

class Hallazgo {
  const Hallazgo(this.codigo, this.detalle, this.peso, [this.indicio]);
  final String codigo, detalle;
  final int peso;
  final String? indicio;
}

class AnalisisUrl {
  AnalisisUrl(
    this.url,
    this.host,
    this.hallazgos,
    this.oficial,
    this.confiable,
  );
  final String url, host;
  final List<Hallazgo> hallazgos;
  final bool oficial, confiable;
  int get puntaje => hallazgos.fold<int>(0, (a, h) => a + h.peso).clamp(0, 100);
  String get nivel => puntaje >= 60
      ? 'alto'
      : puntaje >= 30
      ? 'medio'
      : 'bajo';
  Set<String> get indicios => {
    for (final h in hallazgos)
      if (h.indicio != null) h.indicio!,
  };
}

class AnalisisOsint {
  AnalisisOsint(this.urls, this.enganosos, this.remitente);
  final List<AnalisisUrl> urls;
  final List<(String, String)> enganosos;
  final ({bool sospechoso, String detalle})? remitente;
  final List<String> red = [];

  int get puntaje => [
    ...urls.map((u) => u.puntaje),
    if (enganosos.isNotEmpty) 60,
    if (remitente?.sospechoso ?? false) 40,
    0,
  ].reduce((a, b) => a > b ? a : b);

  Set<String> get indicios => {
    for (final u in urls) ...u.indicios,
    if (enganosos.isNotEmpty) 'I4',
    if (remitente?.sospechoso ?? false) 'I7',
  };

  /// Bloque [OSINT] para el prompt del modelo (mismo formato que resumen_osint() en Python).
  String resumen() {
    final l = ['[OSINT]'];
    if (urls.isEmpty) l.add('- Enlaces: ninguno');
    for (final u in urls.take(4)) {
      if (u.confiable && u.hallazgos.isEmpty) {
        l.add('- ${u.host}: oficial o conocido, sin alertas');
      } else {
        final det = u.hallazgos.take(3).map((h) => h.detalle).join('; ');
        l.add(
          '- ${u.host.isEmpty ? u.url : u.host}: riesgo ${u.nivel} (${u.puntaje}): ${det.isEmpty ? 'sin alertas' : det}',
        );
      }
    }
    for (final (vis, real) in enganosos.take(2)) {
      l.add('- El texto muestra $vis pero el enlace real lleva a $real');
    }
    l.add(
      remitente != null
          ? '- Remitente: ${remitente!.detalle}'
          : '- Remitente: no disponible',
    );
    l.addAll(
      red.isEmpty
          ? ['- Verificacion en red: no realizada']
          : red.map((r) => '- $r'),
    );
    return l.join('\n');
  }
}

const _sufijos2 = {
  'gob.ec',
  'com.ec',
  'edu.ec',
  'org.ec',
  'net.ec',
  'fin.ec',
  'mil.ec',
  'co.uk',
  'com.co',
  'com.pe',
  'com.mx',
  'com.ar',
  'com.br',
  'co.jp',
};
const _homoglifos = [
  ('rn', 'm'),
  ('vv', 'w'),
  ('0', 'o'),
  ('1', 'i'),
  ('l', 'i'),
  ('|', 'i'),
  ('3', 'e'),
  ('5', 's'),
  ('4', 'a'),
  ('@', 'a'),
];
final _rutaSensible = RegExp(
  r'(login|signin|verific|actualiz|reembolso|desbloque|clave|password|premio|bono|pago|validar|confirmar|seguridad|cuenta)',
  caseSensitive: false,
);

bool _coincide(String host, String dom) =>
    host == dom || host.endsWith('.$dom');

(Uri?, String) partirUrl(String url) {
  var u = url.trim().replaceAll(
    RegExp(r'''^[.,;:!?»«"']+|[.,;:!?»«"']+$'''),
    '',
  );
  if (!RegExp(r'^[a-z][a-z0-9+.-]*://', caseSensitive: false).hasMatch(u))
    u = 'http://$u';
  final p = Uri.tryParse(u);
  if (p == null) return (null, '');
  var h = p.host.toLowerCase();
  if (h.endsWith('.')) h = h.substring(0, h.length - 1);
  return (p, h);
}

String dominioRegistrable(String host) {
  final p = host.split('.');
  if (p.length >= 3 && _sufijos2.contains(p.sublist(p.length - 2).join('.')))
    return p.sublist(p.length - 3).join('.');
  return p.length >= 2 ? p.sublist(p.length - 2).join('.') : host;
}

String esqueleto(String s) {
  var r = plegar(s);
  for (final (a, b) in _homoglifos) {
    r = r.replaceAll(a, b);
  }
  return r.replaceAll(RegExp(r'[^a-z0-9]'), '');
}

int distancia(String a, String b) {
  final d = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
  for (var i = 0; i <= a.length; i++) d[i][0] = i;
  for (var j = 0; j <= b.length; j++) d[0][j] = j;
  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final c = a[i - 1] == b[j - 1] ? 0 : 1;
      var v = [
        d[i - 1][j] + 1,
        d[i][j - 1] + 1,
        d[i - 1][j - 1] + c,
      ].reduce((x, y) => x < y ? x : y);
      if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1])
        v = v < d[i - 2][j - 2] + 1 ? v : d[i - 2][j - 2] + 1;
      d[i][j] = v;
    }
  }
  return d[a.length][b.length];
}

bool _esIp(String h) =>
    RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(h) || h.contains(':');

List<String> _tokensHost(String host) {
  final reg = dominioRegistrable(host);
  final sub = host != reg
      ? host
            .substring(0, host.length - reg.length)
            .replaceAll(RegExp(r'\.$'), '')
      : '';
  final etiquetas = [
    reg.split('.').first,
    ...sub.split('.').where((x) => x.isNotEmpty && x != 'www'),
  ];
  final toks = <String>[];
  for (final e in etiquetas) {
    toks.add(e);
    toks.addAll(e.split(RegExp(r'[-_]')).where((t) => t.isNotEmpty && t != e));
  }
  return toks;
}

AnalisisUrl analizarUrl(String url) {
  final c = Canales.i;
  final hs = <Hallazgo>[];
  final (p, host) = partirUrl(url);
  if (p == null || host.isEmpty) {
    hs.add(
      const Hallazgo(
        'URL_INVALIDA',
        'la direccion no tiene un formato valido',
        30,
        'I2',
      ),
    );
    return AnalisisUrl(url, host, hs, false, false);
  }
  final oficial = c.dominiosIess.any((d) => _coincide(host, d));
  final confiable = oficial || c.confiables.any((d) => _coincide(host, d));
  final reg = dominioRegistrable(host);
  final tld = host.split('.').last;
  final urlL = url.toLowerCase();

  if (p.scheme == 'http' && urlL.startsWith('http://'))
    hs.add(const Hallazgo('SIN_HTTPS', 'usa http sin cifrado', 15));
  if (p.userInfo.isNotEmpty)
    hs.add(
      const Hallazgo(
        'USUARIO_EN_URL',
        "la direccion esconde el destino real detras de un '@'",
        35,
        'I4',
      ),
    );
  if (_esIp(host))
    hs.add(
      const Hallazgo(
        'IP_DIRECTA',
        'apunta a una direccion IP en lugar de un dominio',
        35,
        'I2',
      ),
    );
  if (host.contains('xn--'))
    hs.add(
      const Hallazgo(
        'PUNYCODE',
        'usa caracteres especiales para imitar otro dominio',
        30,
        'I2',
      ),
    );
  if (c.acortadores.contains(host) || c.acortadores.contains(reg)) {
    hs.add(
      Hallazgo(
        'ACORTADOR',
        '$host es un acortador: oculta el destino real',
        35,
        'I4',
      ),
    );
  }
  if (c.alojamiento.any((d) {
    final partes = d.split('/');
    return _coincide(host, partes.first) &&
        (partes.length == 1 || urlL.contains(partes.sublist(1).join('/')));
  })) {
    hs.add(
      Hallazgo(
        'ALOJAMIENTO_GENERICO',
        '$host es un servicio de alojamiento gratuito que cualquiera puede usar',
        25,
        'I2',
      ),
    );
  }
  if (c.tldsRiesgosos.contains(tld))
    hs.add(
      Hallazgo(
        'TLD_RIESGOSO',
        'la terminacion .$tld es frecuente en sitios de estafa',
        20,
      ),
    );

  if (!confiable) {
    hs.add(
      Hallazgo(
        'DOMINIO_NO_OFICIAL',
        '$reg no es un dominio del IESS ni de una entidad conocida',
        30,
        'I2',
      ),
    );
    final esqs = {for (final t in _tokensHost(host)) t: esqueleto(t)};
    marcas:
    for (final marca in c.marcas) {
      final m = esqueleto(marca);
      for (final MapEntry(key: t, value: e) in esqs.entries) {
        if (m.length >= 3 && e == m) {
          hs.add(
            Hallazgo(
              'SUPLANTA_MARCA',
              "usa el nombre '$marca' pero no es el sitio oficial",
              25,
              'I2',
            ),
          );
          break marcas;
        }
        final lim = m.length <= 6 ? 1 : 2;
        if (m.length >= 4 && e.length >= 3) {
          final dd = distancia(e, m);
          if (dd > 0 && dd <= lim) {
            hs.add(
              Hallazgo(
                'TYPOSQUATTING',
                "'$t' imita a '$marca' con letras cambiadas",
                40,
                'I2',
              ),
            );
            break marcas;
          }
        }
      }
    }
    if (RegExp(r'(^|\.)(iess|gob|sri)\.(gob\.)?(ec)\.').hasMatch(host)) {
      hs.add(
        Hallazgo(
          'SUBDOMINIO_ENGANOSO',
          '$host pone un dominio oficial al inicio pero el sitio real es $reg',
          35,
          'I2',
        ),
      );
    }
    if (_rutaSensible.hasMatch(p.path))
      hs.add(
        const Hallazgo(
          'RUTA_SENSIBLE',
          'la ruta pide verificar, actualizar o ingresar datos',
          10,
        ),
      );
    if ('.'.allMatches(host).length >= 4)
      hs.add(
        const Hallazgo(
          'MUCHOS_SUBDOMINIOS',
          'tiene demasiados subdominios',
          10,
        ),
      );
  }
  return AnalisisUrl(url, host, hs, oficial, confiable);
}

({bool sospechoso, String detalle})? analizarRemitente(String? remitente) {
  if (remitente == null || remitente.trim().isEmpty) return null;
  final m = RegExp(r'[\w.+-]+@([\w-]+(?:\.[\w-]+)+)').firstMatch(remitente);
  if (m == null)
    return null; // en notificaciones el "remitente" suele ser un nombre, no un correo
  final dom = m.group(1)!.toLowerCase();
  final c = Canales.i;
  if (c.dominiosIess.any((d) => _coincide(dom, d)))
    return (sospechoso: false, detalle: 'dominio oficial del IESS');
  if (c.correoGratuito.contains(dom))
    return (sospechoso: true, detalle: 'usa un correo gratuito ($dom)');
  if (c.confiables.any((d) => _coincide(dom, d)))
    return (sospechoso: false, detalle: 'dominio de entidad conocida');
  final r = analizarUrl('http://$dom');
  final extra = r.hallazgos
      .where((h) => h.codigo == 'SUPLANTA_MARCA' || h.codigo == 'TYPOSQUATTING')
      .map((h) => h.detalle)
      .join('; ');
  return (
    sospechoso: true,
    detalle: 'dominio no oficial ($dom)${extra.isEmpty ? '' : '; $extra'}',
  );
}

AnalisisOsint analizarMensaje(
  String cuerpo, {
  List<String>? hrefs,
  String? remitente,
}) {
  final enlaces = (hrefs == null || hrefs.isEmpty)
      ? urlRe.allMatches(cuerpo).map((m) => m.group(0)!).toList()
      : hrefs;
  final unicos = {...enlaces}.toList();
  final urls = unicos.map(analizarUrl).toList();
  final enganosos = <(String, String)>[];
  if (hrefs != null && hrefs.isNotEmpty) {
    final reales = {for (final h in hrefs) partirUrl(h).$2};
    for (final v in urlRe.allMatches(cuerpo)) {
      final hv = partirUrl(v.group(0)!).$2;
      if (hv.isNotEmpty && !reales.contains(hv))
        enganosos.add((hv, (reales.toList()..sort()).first));
    }
  }
  return AnalisisOsint(urls, enganosos, analizarRemitente(remitente));
}
