// Motor de análisis: léxico de indicios, reglas de respaldo, prompt para LFM2 y lectura de su JSON.
// Espejo de ml/aiess_ml/{evidencia,prompts}.py.
import 'dart:convert';
import 'dart:math';

import '../../core/canales.dart';
import '../osint/url_analyzer.dart';

const nombreMascota = 'AIess';

final Map<String, RegExp> lexico = {
  'I1':
      r'\b(hoy mismo|de inmediato|inmediat[oa]mente|urgente|urgencia|ultimo aviso|ultima oportunidad|en las proximas \d+|dentro de (las )?(\d+|veinticuatro|cuarenta y ocho) (horas|minutos|dias)|\d+\s?(h|horas|minutos)\b|antes de (las|que)|plazo (maximo|de|limite)|vence (hoy|manana)|caduca|expira|lo antes posible|sin demora)',
  'I3':
      r'\b(contrasena|clave|usuario y|credencial\w*|codigo de (verificacion|seguridad|acceso)|codigo que (le|te)|\bpin\b|\botp\b|token|tarjeta|cvv|inicie sesion|iniciar sesion|ingrese su usuario)',
  'I5':
      r'(\.(zip|rar|exe|apk|html?|docm|xlsm|iso|js|scr|msi)\b|instal(e|ar|a) (la |nuestra |esta )?(aplicacion|app)|descargue (la )?(app|aplicacion)|habilite (el contenido|las macros)|macros)',
  'I6':
      r'\b(reembolso|bono|premio|ganad(or|ora)|sorteo|devolucion|beneficio (unico|especial|extraordinario)|derecho a (un|una|recibir)|acreditar\w*|usd\s?\d|\$\s?\d)',
  'I8':
      r'\b(suspend\w*|bloque\w*|multa|embargo|perdida|perdera|cancelacion|cancelad[oa]|desactiv\w*|sancion\w*|proceso (judicial|legal|coactivo)|citacion|demanda|accion legal|coactiva|expediente)',
  'I9':
      r'\b(cedula|fecha de nacimiento|selfie|fotografia de su|foto de su|documento de identidad|datos personales|direccion domiciliaria|estado civil)',
  'I10':
      r'\b(pago|pague|cancele|transfer\w*|deposit\w*|tasa|arancel|criptomoneda\w*|bitcoin|usdt|abono|comision)',
  'I11': r'(\bqr\b|escane\w*)',
}.map((k, v) => MapEntry(k, RegExp(v)));

/// Lo que el robot dice en voz alta por cada señal (orden = prioridad).
const motivoVoz = {
  'I3': 'Te pide tu clave o códigos, y eso nunca se comparte.',
  'I10': 'Te pide hacer un pago.',
  'I9': 'Te pide tus datos o tu cédula.',
  'I2': 'El enlace no lleva a una página oficial del IESS.',
  'I4': 'El enlace esconde a dónde te lleva.',
  'I5': 'Trae un archivo peligroso.',
  'I8': 'Te amenaza con quitarte un beneficio.',
  'I1': 'Te apura para que no pienses.',
  'I6': 'Te ofrece dinero que no pediste.',
  'I11': 'Te pide escanear un código QR desconocido.',
  'I7': 'Quien lo envía no es una dirección oficial.',
};

class Veredicto {
  Veredicto({
    required this.phishing,
    required this.puntaje,
    required this.voz,
    required this.indicios,
    required this.explicacion,
    required this.queHacer,
    this.fuente = 'reglas',
  });
  final bool phishing;
  final int puntaje;
  final String voz, explicacion, queHacer, fuente;
  final List<String> indicios;

  /// 2-3 palabras para la pantalla (poka-yoke: el detalle lo dice la voz).
  /// Veredicto claro (requisito del reto): Sí o No, y cuántos indicios.
  String get resumen {
    final n = indicios.length;
    final cuantos = '$n ${n == 1 ? 'indicio' : 'indicios'}';
    if (fuente == 'sello')
      return phishing
          ? 'Phishing: SÍ · sello falso${n > 0 ? ' · $cuantos' : ''}'
          : 'Phishing: NO · firma válida del IESS';
    if (fuente == 'sin_sello')
      return 'Phishing: SÍ · sin sello del IESS${n > 0 ? ' · $cuantos' : ''}';
    if (fuente == 'sin_verificar')
      return 'Phishing: SÍ · sello sin comprobar${n > 0 ? ' · $cuantos' : ''}';
    return phishing ? 'Phishing: SÍ · $cuantos' : 'Phishing: NO · $cuantos';
  }

  String get titular => phishing
      ? (puntaje >= 60 ? '¡Es una estafa!' : 'Mejor no confíes')
      : 'Es seguro';
}

/// Regla del sello (SellaCorreo): todo correo sin un sello válido se DESCARTA de inmediato como estafa,
/// sin leerlo con la IA. [motivo] = 'sin_sello' (no trae sello), 'sello' (el sello no valida) o
/// 'sin_verificar' (no se pudo consultar a SellaCorreo).
/// Si después la persona acepta que la IA lo revise, [ia] agrega sus señales, pero el veredicto sigue siendo
/// SÍ: sin un sello válido el correo no es confiable aunque el texto parezca normal.
Veredicto descartarPorSello({
  required String motivo,
  String? mensajeSello,
  Veredicto? ia,
}) {
  final base = motivo == 'sello'
      ? (mensajeSello ??
            'El sello de este correo no es válido: alguien lo copió o lo alteró.')
      : motivo == 'sin_verificar'
      ? 'No pude comprobar el sello del IESS (sin conexión). Por seguridad, trátalo como estafa hasta poder comprobarlo.'
      : 'Este correo no trae el sello del IESS, así que no es confiable. Los correos verdaderos del IESS siempre lo llevan.';
  final extra = ia == null
      ? ''
      : (ia.phishing
            ? ' Además, ${ia.voz}'
            : ' El texto no tiene otras señales claras, pero sin un sello válido no es confiable.');
  return Veredicto(
    phishing: true,
    puntaje: ia == null ? 80 : (ia.puntaje > 80 ? ia.puntaje : 80),
    voz: '$base$extra',
    indicios: ia?.indicios ?? const [],
    explicacion: '$base$extra',
    queHacer:
        'No abras sus enlaces, no descargues adjuntos y no respondas. Si quieres, avisa al IESS.',
    fuente: motivo,
  );
}

/// Entrada normalizada desde portapapeles, voz, compartir o notificación.
class Entrada {
  Entrada(
    this.texto, {
    this.canal = 'mensaje copiado',
    this.asunto = '',
    this.remitente,
  });
  final String texto, canal, asunto;
  final String? remitente;
}

/// Regla determinista: ¿el texto (p. ej. leído de una imagen) es un correo o mensaje real?
/// 1) Si tiene 3+ términos técnicos (API, SMTP, hash, servidor…) es un documento o diagrama, no un mensaje.
/// 2) Exige ESTRUCTURA de mensaje: encabezados de correo, o remitente + saludo, o saludo + despedida/enlace,
///    o un SMS/chat corto con enlace. Palabras sueltas como "correo" o "IESS" ya no bastan.
bool pareceCorreoOMensaje(String texto) => motivoNoEsMensaje(texto) == null;

/// null si parece un mensaje; si no, una frase corta que explica por qué (para decirla en voz alta).
String? motivoNoEsMensaje(String texto) {
  final t = plegar(texto);
  final letras = RegExp(r'[a-z]').allMatches(t).length;
  if (letras < 25) return 'No encontré texto suficiente en la imagen.';

  final tecnico = RegExp(
    r'\b(api|smtp|proxy|hash|json|http|endpoint|fastapi|sqlite|postgresql|postgres|servidor|base de datos|logs?|whitelist|topologia|firma digital|auditoria|interceptor|get /|post /|diagrama|flujo|arquitectura|backend|frontend|deploy)\b',
  );
  final nTecnico = tecnico.allMatches(t).map((m) => m.group(0)).toSet().length;
  if (nTecnico >= 3)
    return 'Esto parece un documento o diagrama técnico, no un correo ni un mensaje.';

  final encabezados = RegExp(
    r'\b(de|para|asunto|cc|enviado|fecha|responder a)\s*:',
  ).allMatches(t).length;
  final remitente = RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+').hasMatch(t);
  final saludo =
      RegExp(
        r'(^|\n)\s*(estimad[oa]s?|senor(a|es)?|hola|buen(os|as) (dias|tardes|noches)|querid[oa])\b',
      ).hasMatch(t) ||
      RegExp(
        r'\b(estimad[oa] (afiliad[oa]|jubilad[oa]|cliente|usuario|senor))',
      ).hasMatch(t);
  final despedida = RegExp(
    r'\b(atentamente|saludos( cordiales)?|cordialmente|gracias|que tenga)\b',
  ).hasMatch(t);
  final enlace = urlRe.hasMatch(texto);
  final corto = texto.trim().length <= 400;
  final remitenteSms = RegExp(
    r'^\s*[a-z]{2,15}\s*:',
  ).hasMatch(t); // "IESS: su pension..."

  final esMensaje =
      encabezados >= 2 ||
      (remitente && (saludo || encabezados >= 1)) ||
      (saludo && (despedida || enlace)) ||
      (corto && enlace && (remitenteSms || saludo)) ||
      (corto && remitenteSms && RegExp(r'\b(su|tu|usted)\b').hasMatch(t));
  return esMensaje ? null : 'Esa imagen no parece un correo ni un mensaje.';
}

Veredicto analizarConReglas(Entrada e, AnalisisOsint osint) {
  final t = plegar('${e.asunto} ${e.texto}');
  final ind = <String>{
    for (final MapEntry(key: k, value: re) in lexico.entries)
      if (re.hasMatch(t)) k,
    ...osint.indicios,
  };
  // Regla C (medida en el set de prueba: correos 95,5 % de exactitud, falsos positivos 23 -> 7 de 200):
  // estafa si hay un enlace riesgoso, o una señal fuerte acompañada de otra, o dos señales débiles.
  // Una sola palabra como "pago" o "cuenta" ya no basta (las usan facturas y bancos legítimos).
  const fuertes = {'I3', 'I5', 'I9', 'I11'};
  const debiles = {'I1', 'I6', 'I8', 'I10', 'I7'};
  final nF = ind.where(fuertes.contains).length;
  final nD = ind.where(debiles.contains).length;
  final enlaceRiesgoso = osint.puntaje >= 30 || osint.enganosos.isNotEmpty;
  final phishing = enlaceRiesgoso || (nF >= 1 && nF + nD >= 2) || nD >= 2;
  final orden = motivoVoz.keys.where(ind.contains).toList();
  final c = Canales.i.contacto;
  if (phishing) {
    final puntaje = min(
      98,
      58 + 8 * orden.length + (osint.puntaje >= 60 ? 6 : 0),
    );
    final motivos = orden.take(2).map((k) => motivoVoz[k]!).join(' ');
    return Veredicto(
      phishing: true,
      puntaje: puntaje,
      voz:
          'Cuidado, este mensaje parece una estafa. $motivos No abras el enlace ni respondas.',
      indicios: orden,
      explicacion: [
        ...orden.map((k) => motivoVoz[k]!),
        ...osint.cti.where(
          (c) => c.startsWith('OpenPhish') || c.contains('se creó hace'),
        ),
      ].join(' '),
      queHacer:
          'No abras enlaces ni adjuntos. Avísale al IESS a ${c['seguridad_informacion']}. '
          'Si ya diste tu clave, cámbiala en ${c['aplicaciones']} o llama al ${c['atencion_telefono']}.',
    );
  }
  final hosts = osint.urls
      .map((u) => u.host)
      .where((h) => h.isNotEmpty)
      .toSet();
  return Veredicto(
    phishing: false,
    puntaje: min(15, 3 + osint.puntaje ~/ 4),
    voz: hosts.isEmpty
        ? 'Tranquilo, no encontré señales de estafa. Igual, nunca compartas tu clave.'
        : 'Tranquilo, el enlace es oficial y no te pide datos. Igual, nunca compartas tu clave.',
    indicios: const [],
    explicacion: 'No encontré señales de engaño.',
    queHacer:
        'Si tienes dudas, escribe tú mismo ${c['portal']} en el navegador.',
  );
}

// ---------------------------------------------------------------- prompt LFM2

String systemPrompt() {
  final c = Canales.i.contacto;
  return 'Eres $nombreMascota, un robot guardián, valiente y cariñoso, mascota de la app AIESS. '
      'Ayudas a afiliados y jubilados del IESS a reconocer estafas. Hablas español de Ecuador, tratas de tú, '
      'con frases cortas y amables, sin emojis, sin listas ni símbolos, porque tus respuestas se leen en voz alta. '
      'Nunca pides claves, códigos, cédula ni datos personales. Solo recomiendas canales oficiales: '
      '${c['portal']}, ${c['aplicaciones']}, WhatsApp ${c['whatsapp']}, teléfono ${c['atencion_telefono']} '
      'y reportes a ${c['seguridad_informacion']}. Si te piden analizar un mensaje, responde solo con un JSON de una '
      'línea con las claves veredicto, riesgo, puntaje, voz, indicios, explicacion y que_hacer. '
      'En una conversación normal responde en máximo tres frases.';
}

String promptAnalisis(Entrada e, AnalisisOsint osint) {
  var cuerpo = e.texto.trim();
  if (cuerpo.length > 1600) cuerpo = '${cuerpo.substring(0, 1600)} [...]';
  final hrefs = osint.urls.map((u) => u.url).toList();
  return [
    'Analiza este mensaje y responde solo con JSON.',
    'Canal: ${e.canal}',
    if (e.asunto.isNotEmpty) 'Asunto: ${e.asunto}',
    'Adjuntos: ninguno',
    'Enlaces reales: ${hrefs.isEmpty ? 'ninguno' : hrefs.join(', ')}',
    'Mensaje:',
    '<<<',
    cuerpo,
    '>>>',
    osint.resumen(),
  ].join('\n');
}

/// Plantilla de chat de LFM2 (ChatML con <|startoftext|>).
/// Parte fija del prompt (se guarda en la caché de llama.cpp y no se recalcula).
String prefijoLfm2(String system) =>
    '<|startoftext|><|im_start|>system\n$system<|im_end|>\n';

String formatoLfm2(String system, List<(String rol, String texto)> turnos) {
  final b = StringBuffer(prefijoLfm2(system));
  for (final (rol, texto) in turnos) {
    b.write('<|im_start|>$rol\n$texto<|im_end|>\n');
  }
  b.write('<|im_start|>assistant\n');
  return b.toString();
}

Veredicto? leerSalidaModelo(String s) {
  // Respuesta completa: JSON normal. Respuesta cortada antes de "que_hacer" (para ir más rápido): se cierra el JSON.
  final i = s.indexOf('{');
  if (i < 0) return null;
  var cuerpo = s.substring(i).trim();
  Map<String, dynamic>? j;
  for (final intento in [
    cuerpo,
    '${cuerpo.replaceAll(RegExp(r'[,\s]+$'), '')}}',
  ]) {
    try {
      final f = intento.lastIndexOf('}');
      j = jsonDecode(intento.substring(0, f + 1)) as Map<String, dynamic>;
      break;
    } catch (_) {}
  }
  if (j == null) return null;
  final v = j['veredicto'];
  if (v != 'PHISHING' && v != 'SEGURO') return null;
  return Veredicto(
    phishing: v == 'PHISHING',
    puntaje: (j['puntaje'] as num?)?.toInt() ?? (v == 'PHISHING' ? 80 : 5),
    voz: (j['voz'] ?? '') as String,
    indicios: List<String>.from((j['indicios'] ?? const []) as List),
    explicacion: (j['explicacion'] ?? '') as String,
    queHacer: (j['que_hacer'] ?? '') as String,
    fuente: 'modelo',
  );
}

/// Fusión determinista: el modelo explica, pero nunca rebaja una alerta fuerte del OSINT.
Veredicto fusionar(Veredicto reglas, Veredicto? modelo, AnalisisOsint osint) {
  if (modelo == null) return reglas;
  if (!modelo.phishing && (osint.puntaje >= 60 || reglas.puntaje >= 80))
    return reglas;
  if (modelo.voz.trim().isEmpty) return reglas;
  if (modelo.queHacer.trim().isEmpty || modelo.explicacion.trim().isEmpty) {
    // El servidor corta antes de "que_hacer": se completa con el consejo fijo de las reglas.
    return Veredicto(
      phishing: modelo.phishing,
      puntaje: modelo.puntaje,
      voz: modelo.voz,
      indicios: modelo.indicios,
      explicacion: modelo.explicacion.trim().isEmpty
          ? reglas.explicacion
          : modelo.explicacion,
      queHacer: modelo.phishing
          ? analizarConReglas(
              Entrada('clave pago', canal: ''),
              AnalisisOsint([], [], null),
            ).queHacer
          : reglas.queHacer,
      fuente: 'modelo',
    );
  }
  return modelo;
}

/// Lo que se dice antes de pedir permiso para que la IA revise un correo ya descartado por el sello.
String introPorSello(String motivo) =>
    '${motivo == 'sin_sello'
        ? 'Este correo no trae el sello del IESS: es una estafa.'
        : motivo == 'sello'
        ? 'El sello no es válido: es una estafa.'
        : 'No pude comprobar el sello: trátalo como estafa.'} '
    'Si quieres, la IA revisa qué otras señales tiene. ';
