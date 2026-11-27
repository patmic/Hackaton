import 'indicio.dart';
import 'json.dart';
import 'rango_etario.dart';
import 'tipologia.dart';

/// Resultado de una verificación, en tres colores.
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

/// Cómo llegó el código a la app. Es una métrica anónima del Observatorio:
/// cuántos verifican con el botón del correo y cuántos pegando el código.
enum OrigenCodigo {
  appLink('APP_LINK'),
  pegado('PEGADO');

  const OrigenCodigo(this.codigo);

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
    this.origen = OrigenCodigo.pegado,
  });

  final String? hashRecibido;

  /// Solo para el contrato alternativo `POST /api/v1/verify`.
  final String? remitenteReportado;
  final Tipologia? tipologiaPercibida;
  final RangoEtario? rangoEtario;
  final CanalVerificacion canal;
  final OrigenCodigo origen;

  bool get tieneHash => hashRecibido != null && hashRecibido!.trim().isNotEmpty;

  bool get estaVacia =>
      !tieneHash &&
      (remitenteReportado == null || remitenteReportado!.trim().isEmpty);

  /// Cuerpo de `POST /api/v1/verify` (contrato del documento técnico).
  Map<String, dynamic> toJson() => {
    'hash_recibido': hashRecibido,
    'remitente_reportado': remitenteReportado,
    'tipologia_percibida': tipologiaPercibida?.codigo,
    'rango_etario_usuario': rangoEtario?.codigo,
    'canal': canal.codigo,
  };

  /// URL de `GET /verificar/{hash_2}` (contrato del diagrama). Los datos
  /// anónimos para el Observatorio van como parámetros opcionales
  /// [PROPUESTO al Bloque 3].
  Uri uriDiagrama(Uri base) {
    final hash = hashRecibido;
    if (hash == null || hash.trim().isEmpty) {
      throw StateError('La solicitud no tiene hash.');
    }
    final prefijo = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(
      path: '$prefijo/verificar/${hash.trim()}',
      queryParameters: {
        'canal': canal.codigo,
        'origen': origen.codigo,
        if (rangoEtario != null) 'rango_etario': rangoEtario!.codigo,
        if (tipologiaPercibida != null)
          'tipologia_percibida': tipologiaPercibida!.codigo,
      },
    );
  }
}

/// Datos sellados que se muestran cuando el código es auténtico. Mitigación
/// del Fallo 2: nunca decir solo «es válido»; el usuario compara.
class MetadatosOficiales {
  const MetadatosOficiales({
    required this.emisorNombre,
    required this.fecha,
    this.remitente,
    this.tipologia,
    this.asuntoResumen,
  });

  factory MetadatosOficiales.fromJson(Map<String, dynamic> json) {
    final tipologia = json['tipologia'] as String?;
    return MetadatosOficiales(
      emisorNombre: json['emisor_nombre'] as String,
      remitente: json['remitente'] as String?,
      tipologia: tipologia == null ? null : Tipologia.desdeCodigo(tipologia),
      asuntoResumen: json['asunto_resumen'] as String?,
      fecha: DateTime.parse(json['timestamp'] as String),
    );
  }

  final String emisorNombre;

  /// Remitente verificado (diagrama, paso 8a).
  final String? remitente;
  final Tipologia? tipologia;
  final String? asuntoResumen;
  final DateTime fecha;
}

/// Nivel de riesgo que estima el análisis del servidor.
enum NivelRiesgo {
  bajo('BAJO', 'Bajo'),
  medio('MEDIO', 'Medio'),
  alto('ALTO', 'Alto');

  const NivelRiesgo(this.codigo, this.etiqueta);

  final String codigo;
  final String etiqueta;

  static NivelRiesgo? tryDesdeCodigo(String? codigo) {
    if (codigo == null) return null;
    final c = codigo.trim().toUpperCase();
    for (final n in values) {
      if (n.codigo == c) return n;
    }
    return null;
  }
}

/// Análisis de riesgo que devuelve el servidor. Lo produce la IA de otro
/// bloque; la app solo lo muestra y lo usa para sugerir un microcurso.
class AnalisisRiesgo {
  const AnalisisRiesgo({
    required this.explicacion,
    this.nivel,
    this.indicios = const [],
  });

  /// Los códigos de indicio que la app no conoce se ignoran.
  factory AnalisisRiesgo.fromJson(Map<String, dynamic> json) => AnalisisRiesgo(
    explicacion: json['explicacion'] as String? ?? '',
    nivel: NivelRiesgo.tryDesdeCodigo(json['nivel_riesgo'] as String?),
    indicios: listaDeTextos(
      json['indicios'],
    ).map(Indicio.tryDesdeCodigo).whereType<Indicio>().toList(),
  );

  final String explicacion;
  final NivelRiesgo? nivel;

  /// Señales de alerta que explica el análisis.
  final List<Indicio> indicios;
}

/// Resultado de una verificación.
class ResultadoVerificacion {
  const ResultadoVerificacion({
    required this.estado,
    required this.semaforo,
    required this.motivo,
    this.metadatosOficiales,
    this.capsulaEducativa,
    this.tipologiaSuplantada,
    this.analisis,
  });

  /// Respuesta de `POST /api/v1/verify` (contrato del documento técnico).
  factory ResultadoVerificacion.fromJson(Map<String, dynamic> json) {
    final metadatos = json['metadatos_oficiales'] as Map<String, dynamic>?;
    final suplantada = json['tipologia_suplantada'] as String?;
    final analisis = json['analisis_ia'] as Map<String, dynamic>?;
    return ResultadoVerificacion(
      estado: json['estado'] as String,
      semaforo: Semaforo.desdeCodigo(json['semaforo'] as String),
      motivo: json['motivo'] as String,
      metadatosOficiales: metadatos == null
          ? null
          : MetadatosOficiales.fromJson(metadatos),
      capsulaEducativa: json['capsula_educativa'] as String?,
      tipologiaSuplantada: suplantada == null
          ? null
          : Tipologia.desdeCodigo(suplantada),
      analisis: analisis == null ? null : AnalisisRiesgo.fromJson(analisis),
    );
  }

  /// Código del caso: LEGITIMO, SELLO_INEXISTENTE, SELLO_COPIADO…
  final String estado;
  final Semaforo semaforo;
  final String motivo;
  final MetadatosOficiales? metadatosOficiales;

  /// Texto corto que educa sobre el caso.
  final String? capsulaEducativa;

  /// Tipología que el atacante intenta suplantar, si se conoce.
  final Tipologia? tipologiaSuplantada;
  final AnalisisRiesgo? analisis;

  bool get esAutentico => semaforo == Semaforo.verde;

  /// El usuario dijo que lo que muestra la app no coincide con el correo que
  /// lee: el sello es real pero lo copiaron de otro correo (Fallo 2).
  ResultadoVerificacion marcarComoCopiado() => ResultadoVerificacion(
    estado: 'SELLO_COPIADO',
    semaforo: Semaforo.rojo,
    motivo:
        'El sello es real, pero no corresponde a este correo: lo copiaron '
        'de otro. Es una estafa.',
    metadatosOficiales: metadatosOficiales,
    capsulaEducativa:
        'Compara siempre lo que dice la app con lo que lees. Un sello '
        'auténtico pegado en otro correo no lo vuelve oficial.',
    tipologiaSuplantada: metadatosOficiales?.tipologia ?? tipologiaSuplantada,
    analisis: analisis,
  );
}
