import 'rango_etario.dart';
import 'tipologia.dart';

/// Semáforo que devuelve el Núcleo en `POST /api/v1/verify`.
enum Semaforo {
  verde('VERDE'),
  amarillo('AMARILLO'),
  rojo('ROJO');

  const Semaforo(this.codigo);

  final String codigo;

  static Semaforo desdeCodigo(String codigo) => values.firstWhere(
    (s) => s.codigo == codigo.toUpperCase(),
    orElse: () => throw FormatException('Semáforo desconocido: $codigo'),
  );
}

/// Canal desde el que se verifica.
enum CanalVerificacion {
  app('APP_MOVIL'),
  web('WEB_VERIFICADORA'),
  botWhatsapp('BOT_WHATSAPP');

  const CanalVerificacion(this.codigo);

  final String codigo;
}

/// Petición de verificación. Solo lleva el hash y metadatos no sensibles.
class SolicitudVerificacion {
  const SolicitudVerificacion({
    required this.canal,
    this.hashRecibido,
    this.remitenteReportado,
    this.tipologiaPercibida,
    this.rangoEtario,
  });

  final String? hashRecibido;
  final String? remitenteReportado;
  final Tipologia? tipologiaPercibida;
  final RangoEtario? rangoEtario;
  final CanalVerificacion canal;

  bool get estaVacia =>
      (hashRecibido == null || hashRecibido!.trim().isEmpty) &&
      (remitenteReportado == null || remitenteReportado!.trim().isEmpty);

  Map<String, dynamic> toJson() => {
    'hash_recibido': hashRecibido,
    'remitente_reportado': remitenteReportado,
    'tipologia_percibida': tipologiaPercibida?.codigo,
    'rango_etario_usuario': rangoEtario?.codigo,
    'canal': canal.codigo,
  };
}

/// Metadatos sellados que se muestran cuando el sello es auténtico
/// (mitigación del Fallo 2: nunca decir solo "es válido").
class MetadatosOficiales {
  const MetadatosOficiales({
    required this.emisorNombre,
    required this.tipologia,
    required this.asuntoResumen,
    required this.fecha,
  });

  factory MetadatosOficiales.fromJson(Map<String, dynamic> json) =>
      MetadatosOficiales(
        emisorNombre: json['emisor_nombre'] as String,
        tipologia: Tipologia.desdeCodigo(json['tipologia'] as String),
        asuntoResumen: json['asunto_resumen'] as String,
        fecha: DateTime.parse(json['timestamp'] as String),
      );

  final String emisorNombre;
  final Tipologia tipologia;
  final String asuntoResumen;
  final DateTime fecha;
}

/// Respuesta del Núcleo a una verificación.
class ResultadoVerificacion {
  const ResultadoVerificacion({
    required this.estado,
    required this.semaforo,
    required this.motivo,
    this.metadatosOficiales,
    this.capsulaEducativa,
    this.tipologiaSuplantada,
  });

  factory ResultadoVerificacion.fromJson(Map<String, dynamic> json) =>
      ResultadoVerificacion(
        estado: json['estado'] as String,
        semaforo: Semaforo.desdeCodigo(json['semaforo'] as String),
        motivo: json['motivo'] as String,
        metadatosOficiales: json['metadatos_oficiales'] == null
            ? null
            : MetadatosOficiales.fromJson(
                json['metadatos_oficiales'] as Map<String, dynamic>,
              ),
        capsulaEducativa: json['capsula_educativa'] as String?,
        tipologiaSuplantada: json['tipologia_suplantada'] == null
            ? null
            : Tipologia.desdeCodigo(json['tipologia_suplantada'] as String),
      );

  final String estado;
  final Semaforo semaforo;
  final String motivo;
  final MetadatosOficiales? metadatosOficiales;

  /// Texto corto que devuelve el Núcleo.
  final String? capsulaEducativa;

  /// Tipología que el atacante intenta suplantar, si se conoce.
  final Tipologia? tipologiaSuplantada;
}
