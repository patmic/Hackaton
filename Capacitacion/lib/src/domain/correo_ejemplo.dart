/// Correo de ejemplo usado en los ejercicios "¿Real o estafa?".
///
/// Es contenido ficticio de entrenamiento: no proviene de correos reales
/// de afiliados.
class CorreoEjemplo {
  const CorreoEjemplo({
    required this.remitente,
    required this.asunto,
    required this.cuerpo,
    this.tieneSello = false,
  });

  factory CorreoEjemplo.fromJson(Map<String, dynamic> json) => CorreoEjemplo(
    remitente: json['remitente'] as String,
    asunto: json['asunto'] as String,
    cuerpo: json['cuerpo'] as String,
    tieneSello: json['tiene_sello'] as bool? ?? false,
  );

  final String remitente;
  final String asunto;
  final String cuerpo;

  /// Si el correo trae un sello/código de verificación en el pie.
  final bool tieneSello;
}
