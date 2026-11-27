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

/// Nombre de cada indicio (catálogo oficial del reto, sección 3).
const nombreIndicio = {
  'I1': 'Urgencia artificial',
  'I2': 'Enlace a dominio no oficial',
  'I3': 'Pide claves, códigos o tarjeta',
  'I4': 'Enlace acortado u oculto',
  'I5': 'Adjunto o instalación sospechosa',
  'I6': 'Premio, bono o reembolso inesperado',
  'I7': 'Remitente no oficial',
  'I8': 'Amenaza o pérdida de beneficio',
  'I9': 'Pide datos personales o documentos',
  'I10': 'Pide pago o transferencia',
  'I11': 'Código QR a un sitio no verificable',
};

/// «Qué te podría pasar si caes en el engaño», por indicio (lo dice el avatar).
const riesgoIndicio = {
  'I3':
      'podrían entrar a tu cuenta del IESS y quedarse con tu pensión o tus préstamos',
  'I9':
      'con tu cédula y tu foto podrían sacar préstamos o abrir cuentas a tu nombre',
  'I10': 'perderías ese dinero y es muy difícil recuperarlo',
  'I6': 'te pedirían un pago o tus datos para cobrar un premio que no existe',
  'I5':
      'el archivo podría meter un virus que espía tu celular o tu computadora',
  'I2': 'la página es una copia falsa que roba lo que escribas',
  'I4': 'el enlace te lleva a un sitio distinto del que crees',
  'I11': 'el código QR te lleva a una página falsa sin que lo notes',
  'I7': 'no te escribe el IESS, aunque lo parezca',
  'I8': 'te asustan para que actúes sin pensar',
  'I1': 'el apuro es para que no tengas tiempo de verificar',
};

/// Solo códigos del catálogo, sin repetir, en el orden en que el avatar los explica.
List<String> indiciosValidos(Iterable<String> lista) {
  final set = {for (final i in lista) i.trim().toUpperCase()};
  return [
    for (final k in motivoVoz.keys)
      if (set.contains(k)) k,
  ];
}

const _ordinales = [
  'Primero',
  'Segundo',
  'Tercero',
  'Cuarto',
  'Quinto',
  'Sexto',
  'Séptimo',
  'Octavo',
  'Noveno',
  'Décimo',
  'Undécimo',
];

/// Lo que el avatar dice ante un phishing (rúbrica del jurado): «Encontré N indicios» y explica CADA uno,
/// qué te podría pasar, el aviso de deepfake y (en [queHacerEstafa]) qué hacer y dónde reportar.
String guionEstafa(List<String> indicios) {
  final n = indicios.length;
  final b = StringBuffer(
    n == 0
        ? 'Cuidado, este mensaje no es confiable. '
        : 'Encontré $n ${n == 1 ? 'indicio' : 'indicios'} de estafa. ',
  );
  for (var i = 0; i < n; i++) {
    final k = indicios[i];
    b.write('${n == 1 ? '' : '${_ordinales[i]}: '}${motivoVoz[k]} ');
  }
  final riesgos = [
    for (final k in indicios) riesgoIndicio[k]!,
  ].take(2).toList();
  if (riesgos.isNotEmpty) {
    b.write('Si caes en el engaño, ${riesgos.join(', y además ')}. ');
  }
  b.write(
    'Y ojo con los deepfakes: con tus fotos o videos de redes sociales pueden crear un video falso tuyo, '
    'con tu cara y tu voz, para pedirles dinero a tus amigos y familiares. Si alguien te pide dinero por video, '
    'llámale tú a su número de siempre. ',
  );
  return b.toString().trim();
}

/// Qué hacer y dónde reportar al IESS (canales oficiales del catálogo, sección 4).
String queHacerEstafa() {
  final c = Canales.i.contacto;
  return 'No abras sus enlaces ni adjuntos y no respondas. Repórtalo al IESS a ${c['seguridad_informacion']}, '
      'en ${c['denuncias_web']} o por WhatsApp al ${c['whatsapp']}. Si ya diste tu clave, cámbiala en '
      '${c['aplicaciones']} o llama al ${c['atencion_telefono']}.';
}

class Veredicto {
  Veredicto({
    required this.phishing,
    required this.puntaje,
    required this.voz,
    required this.indicios,
    required this.explicacion,
    required this.queHacer,
    this.fuente = 'reglas',
    this.avisoSello,
    this.selloEstado,
    this.salio = const [],
  });
  final bool phishing;

  /// Lo que salió del equipo durante la revisión (rúbrica: solo el dominio o la URL). Ej.: 'el dominio x a RDAP'.
  final List<String> salio;

  /// Frase fija para la pantalla: qué salió a internet y que el correo no salió.
  String get queSalio => salio.isEmpty
      ? 'Lo que salió del equipo: nada. Todo se revisó aquí y el correo no salió.'
      : 'Lo que salió del equipo: solo ${salio.join(' y ')}. El correo no salió.';
  final int puntaje;
  final String voz, explicacion, queHacer, fuente;
  final List<String> indicios;

  /// Aviso aparte sobre el sello del IESS (no cambia el Sí/No, que lo deciden los indicios del catálogo).
  final String? avisoSello;

  /// 'valido', 'falso', 'sin_sello' o 'sin_verificar' (null si no se miró el sello).
  final String? selloEstado;

  /// Lo que el avatar dice completo (voz + subtítulos): el veredicto, y en una estafa también qué hacer.
  String get locucion => [
    voz,
    if (phishing) queHacer,
    if (avisoSello != null) avisoSello!,
  ].join(' ');

  /// Sin indicios, pero tampoco con sello válido: no es estafa según el catálogo, pero no se confirma.
  bool get sinConfirmar =>
      !phishing && selloEstado != null && selloEstado != 'valido';

  Veredicto copiar({
    bool? phishing,
    int? puntaje,
    String? voz,
    List<String>? indicios,
    String? explicacion,
    String? queHacer,
    String? fuente,
    String? avisoSello,
    String? selloEstado,
    List<String>? salio,
  }) => Veredicto(
    phishing: phishing ?? this.phishing,
    puntaje: puntaje ?? this.puntaje,
    voz: voz ?? this.voz,
    indicios: indicios ?? this.indicios,
    explicacion: explicacion ?? this.explicacion,
    queHacer: queHacer ?? this.queHacer,
    fuente: fuente ?? this.fuente,
    avisoSello: avisoSello ?? this.avisoSello,
    selloEstado: selloEstado ?? this.selloEstado,
    salio: salio ?? this.salio,
  );

  /// 2-3 palabras para la pantalla (poka-yoke: el detalle lo dice la voz).
  /// Veredicto claro (requisito del reto): Sí o No, y cuántos indicios (los mismos de la lista).
  String get resumen {
    final n = indicios.length;
    final cuantos = '$n ${n == 1 ? 'indicio' : 'indicios'}';
    if (selloEstado == 'valido' && !phishing)
      return 'Phishing: NO · firma válida del IESS';
    if (selloEstado == 'falso') return 'Phishing: SÍ · sello falso · $cuantos';
    return phishing ? 'Phishing: SÍ · $cuantos' : 'Phishing: NO · $cuantos';
  }

  String get titular => phishing
      ? (puntaje >= 60 ? '¡Es una estafa!' : 'Mejor no confíes')
      : (sinConfirmar ? 'Sin sello: no confíes aún' : 'Es seguro');
}

/// Avisos del sello (SellaCorreo) que se muestran APARTE del veredicto.
const avisoSinSello =
    'Este correo no trae el sello del IESS. Si dice ser del IESS, no confíes hasta confirmarlo por un canal oficial.';
const avisoSinVerificar =
    'No pude comprobar el sello del IESS ahora (sin conexión). No confíes hasta poder comprobarlo.';

/// Combina el resultado del sello con el análisis por indicios (catálogo: Sí si hay al menos un indicio).
/// - 'valido': la firma es del IESS (si además la IA ve una estafa, cambiaron el texto: [conFirmaValida]).
/// - 'falso': el sello existe pero no valida → estafa; suma el indicio que corresponde
///   (verificador ajeno = I2; enlace alterado = I4).
/// - 'sin_sello' / 'sin_verificar': el Sí/No lo deciden los indicios; el sello va como aviso aparte.
Veredicto aplicarSello(
  Veredicto v, {
  required String estado,
  String? mensaje,
  bool verificadorAjeno = false,
}) {
  switch (estado) {
    case 'valido':
      return conFirmaValida(v).copiar(selloEstado: 'valido');
    case 'falso':
      final ind = indiciosValidos([
        ...v.indicios,
        verificadorAjeno ? 'I2' : 'I4',
      ]);
      return v.copiar(
        phishing: true,
        puntaje: v.puntaje > 90 ? v.puntaje : 90,
        indicios: ind,
        voz:
            '${mensaje ?? 'El sello de este correo es falso: lo copiaron o lo alteraron.'} ${guionEstafa(ind)}',
        explicacion: [for (final k in ind) motivoVoz[k]!].join(' '),
        queHacer: queHacerEstafa(),
        fuente: 'sello',
        selloEstado: 'falso',
      );
    case 'sin_verificar':
      return v.copiar(
        avisoSello: avisoSinVerificar,
        selloEstado: 'sin_verificar',
      );
    default:
      return v.copiar(avisoSello: avisoSinSello, selloEstado: 'sin_sello');
  }
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

/// Remitente escrito en el texto («De: Nombre <correo>» o «From: …»), para revisar el indicio I7.
String? remitenteEn(String texto) {
  final l = RegExp(
    r'^\s*(?:de|from|remitente)\s*:\s*(.+)$',
    caseSensitive: false,
    multiLine: true,
  ).firstMatch(texto)?.group(1);
  return l == null
      ? null
      : RegExp(r'[\w.+-]+@[\w-]+(\.[\w-]+)+').firstMatch(l)?.group(0);
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
  final enlaceRiesgoso = osint.puntaje >= 30 || osint.enganosos.isNotEmpty;
  // Catálogo del reto (sección 1): un correo es phishing cuando presenta AL MENOS UN indicio.
  // Si un legítimo da falso positivo, se ajusta el léxico, no este umbral (plan 1.2).
  final phishing = enlaceRiesgoso || ind.isNotEmpty;
  final orden = motivoVoz.keys.where(ind.contains).toList();
  final c = Canales.i.contacto;
  if (phishing) {
    final puntaje = min(
      98,
      58 + 8 * orden.length + (osint.puntaje >= 60 ? 6 : 0),
    );
    return Veredicto(
      phishing: true,
      puntaje: puntaje,
      voz: guionEstafa(orden),
      indicios: orden,
      explicacion: [
        ...orden.map((k) => motivoVoz[k]!),
        ...osint.cti.where(
          (c) => c.startsWith('OpenPhish') || c.contains('se creó hace'),
        ),
      ].join(' '),
      queHacer: queHacerEstafa(),
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

/// Fusión determinista (plan 1.2): el veredicto y la LISTA de indicios salen siempre de las reglas, que
/// aciertan los correos de práctica (la IA no decide sola). Del modelo solo se toma su explicación, y solo si
/// habla de los mismos indicios; si propone otros, se ignoran.
Veredicto fusionar(Veredicto reglas, Veredicto? modelo, AnalisisOsint osint) {
  if (modelo == null) return reglas;
  final mismos = indiciosValidos(
    modelo.indicios,
  ).toSet().difference(reglas.indicios.toSet()).isEmpty;
  final extra = modelo.explicacion.trim();
  return reglas.copiar(
    explicacion:
        mismos && extra.isNotEmpty && reglas.phishing == modelo.phishing
        ? '${reglas.explicacion} $extra'.trim()
        : reglas.explicacion,
    fuente: 'modelo',
  );
}

/// La firma del IESS era válida, pero la IA ve señales de estafa en el TEXTO: alguien pudo pegar un sello
/// verdadero a un contenido cambiado. Se avisa así, con las señales que vio la IA.
Veredicto conFirmaValida(Veredicto ia) {
  if (!ia.phishing) {
    return Veredicto(
      phishing: false,
      puntaje: ia.puntaje,
      voz:
          'La firma es válida y el texto no tiene señales de estafa. ${ia.voz}',
      indicios: ia.indicios,
      explicacion: ia.explicacion,
      queHacer: ia.queHacer,
      fuente: ia.fuente,
    );
  }
  final aviso =
      'Ojo: la firma del IESS es válida, pero el texto tiene señales de estafa. Puede que hayan cambiado el '
      'contenido de un correo firmado.';
  return Veredicto(
    phishing: true,
    puntaje: ia.puntaje,
    voz: '$aviso ${ia.voz}',
    indicios: ia.indicios,
    explicacion: '$aviso ${ia.explicacion}',
    queHacer: ia.queHacer,
    fuente: ia.fuente,
  );
}
