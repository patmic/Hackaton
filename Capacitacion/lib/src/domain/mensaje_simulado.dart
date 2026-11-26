/// Mensaje ficticio que se usa en las actividades. Nunca proviene de correos
/// reales de afiliados.
class MensajeSimulado {
  const MensajeSimulado({
    required this.remitente,
    required this.asunto,
    required this.cuerpo,
    this.etiqueta = 'SIMULACIÓN',
    this.boton,
    this.adjunto,
    this.tieneQr = false,
    this.codigoVerificacion,
  });

  factory MensajeSimulado.fromJson(Map<String, dynamic> json) =>
      MensajeSimulado(
        etiqueta: json['etiqueta'] as String? ?? 'SIMULACIÓN',
        remitente: json['remitente'] as String,
        asunto: json['asunto'] as String,
        cuerpo: json['cuerpo'] as String,
        boton: json['boton'] as String?,
        adjunto: json['adjunto'] as String?,
        tieneQr: json['qr'] as bool? ?? false,
        codigoVerificacion: json['codigo_verificacion'] as String?,
      );

  /// Siempre visible, para que nadie confunda la práctica con un correo real.
  final String etiqueta;
  final String remitente;
  final String asunto;

  /// Párrafos separados por saltos de línea.
  final String cuerpo;

  /// Texto del botón del correo, si tiene uno.
  final String? boton;

  /// Nombre del archivo adjunto, si tiene uno.
  final String? adjunto;

  /// Si el correo pide escanear un QR.
  final bool tieneQr;

  /// Sello o código de verificación impreso en el pie, si lo trae.
  final String? codigoVerificacion;

  List<String> get parrafos => cuerpo
      .split('\n')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
}

/// Parte del mensaje donde se esconde una señal (actividad A1).
enum TipoZona { remitente, asunto, cuerpo, boton, adjunto, qr }

/// Zona de una señal. En el JSON: `remitente`, `asunto`, `cuerpo:2`
/// (segundo párrafo, contando desde 1), `boton`, `adjunto` o `qr`.
class ZonaMensaje {
  const ZonaMensaje(this.tipo, {this.parrafo});

  factory ZonaMensaje.desdeCodigo(String codigo) {
    final partes = codigo.trim().toLowerCase().split(':');
    final tipo = TipoZona.values.firstWhere(
      (t) => t.name == partes.first,
      orElse: () => throw FormatException('Zona desconocida: $codigo'),
    );
    if (partes.length == 1) return ZonaMensaje(tipo);
    final numero = int.tryParse(partes[1]);
    if (tipo != TipoZona.cuerpo ||
        partes.length > 2 ||
        numero == null ||
        numero < 1) {
      throw FormatException('Zona desconocida: $codigo');
    }
    return ZonaMensaje(tipo, parrafo: numero);
  }

  final TipoZona tipo;

  /// Párrafo del cuerpo (desde 1). Null si señala todo el cuerpo.
  final int? parrafo;

  String get codigo => parrafo == null ? tipo.name : '${tipo.name}:$parrafo';

  bool existeEn(MensajeSimulado mensaje) => switch (tipo) {
    TipoZona.remitente || TipoZona.asunto => true,
    TipoZona.cuerpo => parrafo == null || parrafo! <= mensaje.parrafos.length,
    TipoZona.boton => mensaje.boton != null,
    TipoZona.adjunto => mensaje.adjunto != null,
    TipoZona.qr => mensaje.tieneQr,
  };
}
