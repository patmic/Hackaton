import '../domain/domain.dart';
import 'adaptador_verificacion.dart';

/// Contrato con el Núcleo Central (Bloque 3).
///
/// - `GET /verificar/{hash_2}` (diagrama) → [verificar]
/// - alertas de hipersegmentación del Observatorio → [alertasActivas]
///
/// Una implementación puede lanzar una excepción si el Núcleo no responde;
/// la app la trata como AMARILLO (nunca como VERDE).
abstract interface class NucleoApi {
  Future<ResultadoVerificacion> verificar(SolicitudVerificacion solicitud);
  Future<List<AlertaObservatorio>> alertasActivas();
}

/// El Núcleo no respondió.
class NucleoNoDisponible implements Exception {
  const NucleoNoDisponible([this.detalle = '']);

  final String detalle;

  @override
  String toString() => 'NucleoNoDisponible: $detalle';
}

/// Registro de la White List simulada (lo que el Proxy SMTP guarda en la BD
/// junto al Hash 2).
class RegistroSello {
  const RegistroSello({
    required this.remitente,
    required this.emisorNombre,
    required this.tipologia,
    required this.asuntoResumen,
    required this.timestamp,
    this.ttlDias = 30,
    this.revocado = false,
  });

  final String remitente;
  final String emisorNombre;
  final Tipologia tipologia;
  final String asuntoResumen;
  final DateTime timestamp;
  final int ttlDias;
  final bool revocado;

  bool vencido(DateTime ahora) =>
      ahora.isAfter(timestamp.add(Duration(days: ttlDias)));
}

/// Núcleo simulado para el MVP. Arma la misma respuesta JSON de
/// `GET /verificar/{hash_2}` que se propone al Bloque 3 y la pasa por el
/// [AdaptadorVerificacion], para que cambiarlo por el real no toque la
/// lógica.
class MockNucleoApi implements NucleoApi {
  MockNucleoApi({
    Map<String, RegistroSello>? whitelist,
    List<AlertaObservatorio>? alertas,
    DateTime Function()? reloj,
    this.latencia = Duration.zero,
    this.sinConexion = false,
    this.adaptador = const AdaptadorVerificacion(),
  }) : whitelist = whitelist ?? _whitelistDemo,
       alertas = alertas ?? _alertasDemo,
       _reloj = reloj ?? DateTime.now;

  final Map<String, RegistroSello> whitelist;
  final List<AlertaObservatorio> alertas;
  final Duration latencia;

  /// Simula que el Núcleo no responde.
  final bool sinConexion;
  final AdaptadorVerificacion adaptador;
  final DateTime Function() _reloj;

  /// Cuántas veces se consultó [verificar]. Sirve en las pruebas.
  int consultas = 0;

  @override
  Future<List<AlertaObservatorio>> alertasActivas() async {
    await Future<void>.delayed(latencia);
    if (sinConexion) throw const NucleoNoDisponible('alertas');
    return alertas;
  }

  @override
  Future<ResultadoVerificacion> verificar(
    SolicitudVerificacion solicitud,
  ) async {
    consultas++;
    await Future<void>.delayed(latencia);
    if (sinConexion) throw const NucleoNoDisponible('verificar');
    if (!solicitud.tieneHash) {
      return adaptador.sinCodigo(
        tipologiaPercibida: solicitud.tipologiaPercibida,
      );
    }
    final hash = CodigoVerificacion.normalizar(solicitud.hashRecibido);
    if (hash == null) {
      return adaptador.codigoInvalido(
        tipologiaPercibida: solicitud.tipologiaPercibida,
      );
    }
    return adaptador.desdeRespuesta(
      responderDiagrama(hash),
      tipologiaPercibida: solicitud.tipologiaPercibida,
    );
  }

  /// Respuesta simulada de `GET /verificar/{hash_2}`.
  Map<String, dynamic> responderDiagrama(String hash2) {
    final registro = whitelist[hash2];
    if (registro == null) {
      return {
        'valido': false,
        'motivo': 'HASH_INEXISTENTE',
        'analisis_ia': {
          'nivel_riesgo': 'ALTO',
          'explicacion':
              'El IESS no emitió este código, así que el correo no salió del '
              'IESS. El remitente y sus enlaces no son oficiales.',
          'indicios': ['I7', 'I2'],
        },
      };
    }
    final base = {
      'tipologia': registro.tipologia.codigo,
      'emisor_nombre': registro.emisorNombre,
      'asunto_resumen': registro.asuntoResumen,
    };
    if (registro.revocado) {
      return {
        ...base,
        'valido': false,
        'motivo': 'REVOCADO',
        'analisis_ia': {
          'nivel_riesgo': 'ALTO',
          'explicacion':
              'Seguridad del IESS revocó este sello, por ejemplo porque la '
              'cuenta que lo emitió fue comprometida. Aunque el remitente '
              'parezca oficial, no actúes.',
          'indicios': ['I2'],
        },
      };
    }
    if (registro.vencido(_reloj())) {
      return {...base, 'valido': false, 'motivo': 'VENCIDO'};
    }
    return {
      ...base,
      'valido': true,
      'remitente': registro.remitente,
      'fecha': registro.timestamp.toUtc().toIso8601String(),
      'analisis_ia': {
        'nivel_riesgo': 'BAJO',
        'explicacion':
            'El correo salió del IESS. Igual compara el asunto oficial con '
            'lo que lees.',
        'indicios': <String>[],
      },
    };
  }

  static final Map<String, RegistroSello> _whitelistDemo = {
    '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4':
        RegistroSello(
          remitente: 'notificaciones@iess.gob.ec',
          emisorNombre: 'Dirección de Prestaciones y Pensiones',
          tipologia: Tipologia.t2,
          asuntoResumen: 'Notificación de rol de pensión mensual',
          timestamp: DateTime.utc(2026, 11, 26, 15, 30),
        ),
    '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b':
        RegistroSello(
          remitente: 'afiliacion@iess.gob.ec',
          emisorNombre: 'Dirección de Afiliación',
          tipologia: Tipologia.t1,
          asuntoResumen: 'Recordatorio de actualización de datos',
          timestamp: DateTime.utc(2026, 11, 20, 9),
          revocado: true,
        ),
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
