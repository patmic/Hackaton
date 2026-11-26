import '../domain/domain.dart';

/// Traduce la respuesta de `GET /verificar/{hash_2}` (diagrama del equipo)
/// al resultado del dominio. Si el Núcleo pasa a `POST /api/v1/verify`, se
/// usa [ResultadoVerificacion.fromJson] y la lógica no cambia.
///
/// Respuesta que la app espera [PROPUESTO al Bloque 3]:
///
/// ```json
/// {
///   "valido": true,
///   "remitente": "notificaciones@iess.gob.ec",
///   "emisor_nombre": "Dirección de Prestaciones y Pensiones",
///   "fecha": "2026-11-26T15:30:00Z",
///   "tipologia": "T2",
///   "asunto_resumen": "Notificación de rol de pensión mensual",
///   "motivo": null,
///   "analisis_ia": {
///     "nivel_riesgo": "BAJO",
///     "explicacion": "…",
///     "indicios": []
///   }
/// }
/// ```
///
/// Con `valido: false`, `motivo` es `HASH_INEXISTENTE`, `CONTENIDO_ALTERADO`,
/// `REVOCADO` o `VENCIDO`.
///
/// Regla de seguridad: nunca se devuelve VERDE sin remitente y fecha
/// (Fallo 2), ni cuando no hubo respuesta del servidor.
class AdaptadorVerificacion {
  const AdaptadorVerificacion();

  static const _educaRojo =
      'No hagas clic ni respondas. El IESS nunca te pedirá claves ni pagos '
      'por correo. Repórtalo.';
  static const _educaAmarillo =
      'Ante la duda, no hagas clic. Entra por tu cuenta al canal oficial.';
  static const _educaVerde =
      'Compara: si el correo que lees te pide dinero, claves o trata de '
      'otro tema, es una ESTAFA aunque el sello sea real.';

  ResultadoVerificacion desdeRespuesta(
    Map<String, dynamic> json, {
    Tipologia? tipologiaPercibida,
  }) {
    final analisisJson = json['analisis_ia'] as Map<String, dynamic>?;
    final analisis = analisisJson == null
        ? null
        : AnalisisRiesgo.fromJson(analisisJson);
    final codigoTipologia = json['tipologia'] as String?;
    final tipologia = codigoTipologia == null
        ? tipologiaPercibida
        : Tipologia.desdeCodigo(codigoTipologia);

    final valido = json['valido'];
    if (valido is! bool) {
      return _amarillo(
        'NO_VERIFICABLE',
        'La respuesta del servidor no se pudo interpretar. No actúes por '
            'este correo hasta verificarlo.',
        tipologia,
        analisis,
      );
    }

    if (valido) {
      final remitente = json['remitente'] as String?;
      final fecha = DateTime.tryParse(json['fecha'] as String? ?? '');
      if (remitente == null || remitente.trim().isEmpty || fecha == null) {
        return _amarillo(
          'RESPUESTA_INCOMPLETA',
          'El servidor reconoció el código, pero no envió el remitente ni la '
              'fecha. Sin esos datos no podemos asegurar que sea este correo.',
          tipologia,
          analisis,
        );
      }
      return ResultadoVerificacion(
        estado: 'LEGITIMO',
        semaforo: Semaforo.verde,
        motivo: 'El código coincide con el que registró el IESS.',
        metadatosOficiales: MetadatosOficiales(
          emisorNombre: json['emisor_nombre'] as String? ?? remitente,
          remitente: remitente,
          tipologia: tipologia,
          asuntoResumen: json['asunto_resumen'] as String?,
          fecha: fecha,
        ),
        capsulaEducativa: _educaVerde,
        analisis: analisis,
      );
    }

    return switch ((json['motivo'] as String? ?? '').toUpperCase()) {
      'VENCIDO' => _amarillo(
        'SELLO_VENCIDO',
        'El sello es auténtico pero ya venció. No actúes por este correo.',
        tipologia,
        analisis,
      ),
      'REVOCADO' => _rojo(
        'SELLO_REVOCADO',
        'Este sello fue revocado por Seguridad del IESS.',
        tipologia,
        analisis,
      ),
      'CONTENIDO_ALTERADO' => _rojo(
        'CORREO_ALTERADO',
        'El correo fue modificado después de salir del IESS.',
        tipologia,
        analisis,
      ),
      _ => _rojo(
        'SELLO_INEXISTENTE',
        'El código no fue emitido por el IESS.',
        tipologia,
        analisis,
      ),
    };
  }

  /// El texto no tiene el formato de un código del IESS. No se consulta al
  /// servidor.
  ResultadoVerificacion codigoInvalido({Tipologia? tipologiaPercibida}) =>
      _amarillo(
        'CODIGO_INVALIDO',
        'El código no tiene el formato de un código del IESS. Revisa que lo '
            'hayas copiado completo.',
        tipologiaPercibida,
        null,
      );

  /// No hubo respuesta del servidor. Nunca se asume que el correo es real.
  ResultadoVerificacion sinConexion({Tipologia? tipologiaPercibida}) =>
      _amarillo(
        'SIN_CONEXION',
        'No pudimos comprobar el código. No actúes por este correo hasta '
            'verificarlo.',
        tipologiaPercibida,
        null,
      );

  /// El correo no trae código. Todos los correos oficiales salen del Proxy
  /// SMTP con su código y el botón «Verificar en App».
  ResultadoVerificacion sinCodigo({Tipologia? tipologiaPercibida}) => _amarillo(
    'SIN_SELLO',
    'El correo no trae código de verificación. Los correos oficiales del '
        'IESS siempre lo traen: no actúes por él y repórtalo.',
    tipologiaPercibida,
    null,
  );

  static ResultadoVerificacion _rojo(
    String estado,
    String motivo,
    Tipologia? tipologia,
    AnalisisRiesgo? analisis,
  ) => ResultadoVerificacion(
    estado: estado,
    semaforo: Semaforo.rojo,
    motivo: motivo,
    tipologiaSuplantada: tipologia,
    capsulaEducativa: _educaRojo,
    analisis: analisis,
  );

  static ResultadoVerificacion _amarillo(
    String estado,
    String motivo,
    Tipologia? tipologia,
    AnalisisRiesgo? analisis,
  ) => ResultadoVerificacion(
    estado: estado,
    semaforo: Semaforo.amarillo,
    motivo: motivo,
    tipologiaSuplantada: tipologia,
    capsulaEducativa: _educaAmarillo,
    analisis: analisis,
  );
}
