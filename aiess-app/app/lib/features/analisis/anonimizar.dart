// Anonimización en el celular, ANTES de enviar el correo al servidor de IA (LOPDP: minimización).
// Se quitan los datos de la persona y se dejan las señales de estafa:
// - Se tapan: cédula, RUC, teléfonos, tarjetas, cuentas bancarias, la parte personal de los correos y
//   el nombre después del saludo ("Estimado Juan Pérez" -> "Estimado [NOMBRE]").
// - Se conservan: enlaces y dominios (iess-pagos.net delata la estafa), montos, plazos y el texto del engaño.
// Las reglas locales (OSINT) siguen viendo el texto completo: eso nunca sale del celular.

class TextoAnonimo {
  const TextoAnonimo(this.texto, this.cambios);
  final String texto;

  /// Cuántos datos personales se taparon (para avisarle a la persona).
  final int cambios;
}

final _url = RegExp(r'(?:https?://|www\.)\S+', caseSensitive: false);

/// Saludos seguidos de un nombre propio. No se tapan palabras genéricas ("Estimado afiliado").
final _saludo = RegExp(
  r'\b(Estimad[oa]s?|Querid[oa]s?|Señora?|Sr\.?|Sra\.?|Srta\.?|Hola|Don|Doña|Afiliad[oa]|Jubilad[oa])'
  r'(\s+)((?:[A-ZÁÉÍÓÚÑ][a-záéíóúñü]+)(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñü]+){0,3})',
);
const _genericos = {
  'afiliado',
  'afiliada',
  'afiliados',
  'usuario',
  'usuaria',
  'cliente',
  'jubilado',
  'jubilada',
  'pensionista',
  'ciudadano',
  'ciudadana',
  'beneficiario',
  'beneficiaria',
  'contribuyente',
  'empleador',
  'señor',
  'señora',
  'equipo',
  'iess',
  'biess',
  'colaborador',
  'colaboradora',
  'paciente',
};

final _reglas = <(RegExp, String)>[
  // Correo: se tapa la parte personal y se deja el dominio (la señal está en el dominio).
  (
    RegExp(r'\b[A-Za-z0-9._%+-]+@([A-Za-z0-9.-]+\.[A-Za-z]{2,})\b'),
    '[usuario]@\$1',
  ),
  // Tarjeta: 13 a 19 dígitos, con o sin espacios o guiones.
  (RegExp(r'\b(?:\d[ -]?){12,18}\d\b'), '[TARJETA]'),
  // Cuenta bancaria: "cuenta (de ahorros|corriente) (nro.) 2201234567".
  (
    RegExp(
      r'(cuenta(?:\s+de\s+ahorros|\s+corriente)?\s*(?:n[°ºo.]*|número)?\s*:?\s*)\d{6,}',
      caseSensitive: false,
    ),
    r'$1[CUENTA]',
  ),
  // Teléfonos de Ecuador: +593…, o un número que viene después de "llame", "celular", "WhatsApp"…
  (RegExp(r'\+?593[\s-]?\(?\d{1,2}\)?[\s-]?\d{3}[\s-]?\d{3,4}'), '[TELÉFONO]'),
  (
    RegExp(
      r'((?:llam\w*|tel[eé]fono|celular|cel\.|whats\w*|contacto|comun[ií]quese)(?:\s+(?:al|a|con|el|del))*\s*:?\s*)0\d[\s-]?\d{3}[\s-]?\d{3,4}\b',
      caseSensitive: false,
    ),
    r'$1[TELÉFONO]',
  ),
  // RUC (13 dígitos) y cédula (10 dígitos).
  (RegExp(r'\b\d{13}\b'), '[RUC]'),
  (RegExp(r'\b\d{9}-?\d\b'), '[CÉDULA]'),
  // Teléfonos con separadores (02-394-5666, 099 123 4567).
  (RegExp(r'\b0\d[\s-]\d{3}[\s-]?\d{3,4}\b'), '[TELÉFONO]'),
];

TextoAnonimo anonimizar(String texto) {
  var cambios = 0;
  final salida = StringBuffer();
  var desde = 0;
  // Se trabaja solo fuera de los enlaces: los enlaces se envían tal cual.
  for (final m in _url.allMatches(texto)) {
    salida.write(
      _limpiar(texto.substring(desde, m.start), (n) => cambios += n),
    );
    salida.write(m.group(0));
    desde = m.end;
  }
  salida.write(_limpiar(texto.substring(desde), (n) => cambios += n));
  return TextoAnonimo(salida.toString(), cambios);
}

String _limpiar(String t, void Function(int) contar) {
  for (final (re, cambio) in _reglas) {
    t = t.replaceAllMapped(re, (m) {
      contar(1);
      return cambio.replaceAllMapped(
        RegExp(r'\$(\d)'),
        (g) => m.group(int.parse(g.group(1)!)) ?? '',
      );
    });
  }
  return t.replaceAllMapped(_saludo, (m) {
    final nombre = m.group(3)!;
    final primera = nombre.split(RegExp(r'\s+')).first.toLowerCase();
    if (_genericos.contains(primera)) return m.group(0)!;
    contar(1);
    return '${m.group(1)}${m.group(2)}[NOMBRE]';
  });
}
