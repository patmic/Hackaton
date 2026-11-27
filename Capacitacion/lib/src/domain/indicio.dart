/// Catálogo oficial de indicios de phishing (CLAUDE.md §6, [DECIDIDO]).
/// Un correo es phishing si tiene al menos un indicio.
enum Indicio {
  i1(
    codigo: 'I1',
    nombre: 'Urgencia artificial',
    queSeRevisa: 'Plazos muy cortos, presión para actuar ya.',
  ),
  i2(
    codigo: 'I2',
    nombre: 'Enlace a dominio no oficial',
    queSeRevisa:
        'El enlace lleva a un sitio que no es del IESS ni de una entidad '
        'conocida.',
  ),
  i3(
    codigo: 'I3',
    nombre: 'Pide credenciales, claves, códigos o tarjeta',
    queSeRevisa:
        'Usuario, contraseña, clave, código de verificación o tarjeta.',
  ),
  i4(
    codigo: 'I4',
    nombre: 'Enlace acortado u oculto',
    queSeRevisa:
        'Acortadores, o un texto que muestra una dirección y lleva a otra.',
  ),
  i5(
    codigo: 'I5',
    nombre: 'Adjunto o instalación sospechosa',
    queSeRevisa: '.zip, .exe, .apk, .html, macros o «instale la aplicación».',
  ),
  i6(
    codigo: 'I6',
    nombre: 'Premio, bono o reembolso inesperado',
    queSeRevisa: 'Dinero o beneficios que no solicitaste.',
  ),
  i7(
    codigo: 'I7',
    nombre: 'Remitente no oficial',
    queSeRevisa:
        'Correo gratuito, dominio parecido o un «responder a» distinto.',
  ),
  i8(
    codigo: 'I8',
    nombre: 'Amenaza o pérdida de beneficio',
    queSeRevisa: 'Suspensión, bloqueo, multa, embargo o pérdida de la pensión.',
  ),
  i9(
    codigo: 'I9',
    nombre: 'Pide datos personales o documentos',
    queSeRevisa:
        'Cédula, fecha de nacimiento, foto del documento o una selfie.',
  ),
  i10(
    codigo: 'I10',
    nombre: 'Pide pago o transferencia',
    queSeRevisa: 'Depósito, tasa, multa o criptomonedas.',
  ),
  i11(
    codigo: 'I11',
    nombre: 'Código QR hacia sitio no verificable',
    queSeRevisa: 'Pide escanear un QR cuyo destino no se puede comprobar.',
  );

  const Indicio({
    required this.codigo,
    required this.nombre,
    required this.queSeRevisa,
  });

  final String codigo;
  final String nombre;
  final String queSeRevisa;

  static Indicio desdeCodigo(String codigo) =>
      tryDesdeCodigo(codigo) ??
      (throw FormatException('Indicio desconocido: $codigo'));

  /// Igual que [desdeCodigo], pero devuelve null si el código no existe.
  /// Se usa con datos del servidor, para que un código nuevo no rompa la app.
  static Indicio? tryDesdeCodigo(String codigo) {
    final c = codigo.trim().toUpperCase();
    for (final i in values) {
      if (i.codigo == c) return i;
    }
    return null;
  }
}
