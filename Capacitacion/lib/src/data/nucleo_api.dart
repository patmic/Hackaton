import '../domain/domain.dart';

/// Contrato con el Núcleo Central (Bloque 3).
///
/// - `POST /api/v1/verify` → [verificar]
/// - alertas de hipersegmentación del Observatorio → [alertasActivas]
abstract interface class NucleoApi {
  Future<ResultadoVerificacion> verificar(SolicitudVerificacion solicitud);
  Future<List<AlertaObservatorio>> alertasActivas();
}

/// Registro de la White List simulada.
class RegistroSello {
  const RegistroSello({
    required this.emisorNombre,
    required this.tipologia,
    required this.asuntoResumen,
    required this.timestamp,
    this.ttlDias = 30,
    this.revocado = false,
  });

  final String emisorNombre;
  final Tipologia tipologia;
  final String asuntoResumen;
  final DateTime timestamp;
  final int ttlDias;
  final bool revocado;

  bool vencido(DateTime ahora) =>
      ahora.isAfter(timestamp.add(Duration(days: ttlDias)));
}

/// Núcleo simulado para el MVP. Responde con el mismo JSON que definió el
/// documento técnico, para que cambiarlo por el real no toque la lógica.
class MockNucleoApi implements NucleoApi {
  MockNucleoApi({
    Map<String, RegistroSello>? whitelist,
    Map<String, Tipologia>? blacklistDominios,
    List<AlertaObservatorio>? alertas,
    DateTime Function()? reloj,
    this.latencia = Duration.zero,
  }) : whitelist = whitelist ?? _whitelistDemo,
       blacklistDominios = blacklistDominios ?? _blacklistDemo,
       alertas = alertas ?? _alertasDemo,
       _reloj = reloj ?? DateTime.now;

  static const dominioOficial = 'iess.gob.ec';
  static final _formatoHash = RegExp(r'^[0-9a-f]{64}$');

  final Map<String, RegistroSello> whitelist;

  /// Dominio → tipología que suplanta.
  final Map<String, Tipologia> blacklistDominios;
  final List<AlertaObservatorio> alertas;
  final Duration latencia;
  final DateTime Function() _reloj;

  @override
  Future<List<AlertaObservatorio>> alertasActivas() async {
    await Future<void>.delayed(latencia);
    return alertas;
  }

  @override
  Future<ResultadoVerificacion> verificar(
    SolicitudVerificacion solicitud,
  ) async {
    await Future<void>.delayed(latencia);
    return ResultadoVerificacion.fromJson(_responder(solicitud));
  }

  Map<String, dynamic> _responder(SolicitudVerificacion s) {
    final hash = s.hashRecibido?.trim().toLowerCase();
    final dominio = extraerDominio(s.remitenteReportado);
    final suplantada = dominio == null ? null : blacklistDominios[dominio];

    if (suplantada != null) {
      return _rojo(
        'PHISHING_CONFIRMADO',
        hash == null || hash.isEmpty
            ? 'El dominio del remitente está en la Black List.'
            : 'Hash inexistente en White List y dominio presente en Black List.',
        suplantada,
      );
    }

    if (hash != null && hash.isNotEmpty) {
      if (!_formatoHash.hasMatch(hash)) {
        return _amarillo(
          'CODIGO_INVALIDO',
          'El código no tiene el formato de un sello del IESS.',
          s.tipologiaPercibida,
        );
      }
      final registro = whitelist[hash];
      if (registro == null) {
        return _rojo(
          'SELLO_INEXISTENTE',
          'El código no fue emitido por el IESS.',
          s.tipologiaPercibida,
        );
      }
      if (registro.revocado) {
        return _rojo(
          'SELLO_REVOCADO',
          'Este sello fue revocado por Seguridad del IESS.',
          registro.tipologia,
        );
      }
      if (registro.vencido(_reloj())) {
        return _amarillo(
          'SELLO_VENCIDO',
          'El sello es auténtico pero ya venció. No actúes por este correo.',
          registro.tipologia,
        );
      }
      return {
        'estado': 'LEGITIMO',
        'semaforo': 'VERDE',
        'motivo': 'Sello auténtico en la White List.',
        'metadatos_oficiales': {
          'emisor_nombre': registro.emisorNombre,
          'tipologia': registro.tipologia.codigo,
          'asunto_resumen': registro.asuntoResumen,
          'timestamp': registro.timestamp.toUtc().toIso8601String(),
        },
        'capsula_educativa':
            'Compara: si el correo que lees te pide dinero, claves o trata '
            'de otro tema, es una ESTAFA aunque el sello sea real.',
      };
    }

    if (dominio == dominioOficial) {
      return _amarillo(
        'SIN_SELLO',
        'El remitente parece oficial pero el correo no trae sello. '
            'Un remitente se puede falsificar.',
        s.tipologiaPercibida,
      );
    }
    return _amarillo(
      'NO_VERIFICABLE',
      'No encontramos este remitente. Trátalo con precaución y repórtalo.',
      s.tipologiaPercibida,
    );
  }

  static Map<String, dynamic> _rojo(
    String estado,
    String motivo,
    Tipologia? tipologia,
  ) => {
    'estado': estado,
    'semaforo': 'ROJO',
    'motivo': motivo,
    'metadatos_oficiales': null,
    'tipologia_suplantada': tipologia?.codigo,
    'capsula_educativa':
        'No hagas clic ni respondas. El IESS nunca te pedirá claves ni '
        'pagos por correo. Bloquea este remitente.',
  };

  static Map<String, dynamic> _amarillo(
    String estado,
    String motivo,
    Tipologia? tipologia,
  ) => {
    'estado': estado,
    'semaforo': 'AMARILLO',
    'motivo': motivo,
    'metadatos_oficiales': null,
    'tipologia_suplantada': tipologia?.codigo,
    'capsula_educativa':
        'Ante la duda, no hagas clic. Entra por tu cuenta al canal oficial.',
  };

  /// Toma el dominio de un correo o URL. Devuelve null si no hay.
  static String? extraerDominio(String? texto) {
    if (texto == null) return null;
    var t = texto.trim().toLowerCase();
    if (t.isEmpty) return null;
    final arroba = t.lastIndexOf('@');
    if (arroba >= 0) t = t.substring(arroba + 1);
    t = t.replaceFirst(RegExp(r'^[a-z]+://'), '');
    t = t.split(RegExp(r'[/?#:]')).first;
    if (t.startsWith('www.')) t = t.substring(4);
    return t.isEmpty ? null : t;
  }

  static final Map<String, RegistroSello> _whitelistDemo = {
    '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4':
        RegistroSello(
          emisorNombre: 'Dirección de Prestaciones y Pensiones',
          tipologia: Tipologia.t2,
          asuntoResumen: 'Notificación de rol de pensión mensual',
          timestamp: DateTime.utc(2026, 11, 26, 15, 30),
        ),
    '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b':
        RegistroSello(
          emisorNombre: 'Dirección de Afiliación',
          tipologia: Tipologia.t1,
          asuntoResumen: 'Recordatorio de actualización de datos',
          timestamp: DateTime.utc(2026, 11, 20, 9),
          revocado: true,
        ),
  };

  static const Map<String, Tipologia> _blacklistDemo = {
    'iess-tramites-ec.com': Tipologia.t2,
    'biess-ec.net': Tipologia.t2,
    'iess-gob-ec.info': Tipologia.t1,
    'iess-agenda.com': Tipologia.t3,
  };

  static const List<AlertaObservatorio> _alertasDemo = [
    AlertaObservatorio(
      id: 'alerta-t2-65',
      tipologia: Tipologia.t2,
      rangoEtario: RangoEtario.r65mas,
      incrementoPorcentaje: 40,
      mensaje: 'Aumento del 40 % de phishing financiero dirigido a 65+.',
    ),
  ];
}
