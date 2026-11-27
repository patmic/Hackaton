// Verificación del sello SellaCorreo (firma Ed25519 del IESS) y filtro de privacidad por asunto.
//
// Flujo: el IESS firma el correo en SellaCorreo (GenKey) y le pone una imagen con el enlace
// https://<servidor-sello>/checkin/<token>.<huella>. El robot toma ese enlace y lo verifica contra el
// servidor OFICIAL de SellaCorreo (AIESS_SELLO), nunca contra el dominio que trae el enlace: si un estafador
// pone un enlace a su propio "verificador", se marca como falso.
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/canales.dart' show plegar;

class ResultadoSello {
  const ResultadoSello({
    required this.valido,
    required this.motivo,
    required this.mensaje,
    this.datos = const {},
  });
  final bool valido;

  /// 'valido', 'hash_distinto', 'no_registrado', 'firma_invalida', 'caducado', 'dominio_ajeno', 'sin_conexion'…
  final String motivo;
  final String mensaje;
  final Map<String, dynamic> datos;

  /// No se pudo comprobar (sin internet): no es lo mismo que "falso".
  bool get sinRespuesta => motivo == 'sin_conexion' || motivo == 'limite';
}

class Sello {
  /// Servidor oficial de SellaCorreo (secreto de compilación, igual que AIESS_SERVIDOR).
  static const servidor = String.fromEnvironment('AIESS_SELLO');

  static final _enlace = RegExp(
    r'(?:(https?://[^\s/]+))?/checkin/([A-Za-z0-9_-]+\.[0-9a-f]{16})',
  );

  /// ¿El texto trae el enlace de un sello? Devuelve «token.huella» o null.
  static String? codigoEn(String texto) => _enlace.firstMatch(texto)?.group(2);

  static Future<ResultadoSello> verificar(
    String texto, {
    http.Client? cliente,
    String? servidorOficial,
  }) async {
    final servidor = servidorOficial ?? Sello.servidor;
    final m = _enlace.firstMatch(texto);
    if (m == null) {
      return const ResultadoSello(
        valido: false,
        motivo: 'sin_sello',
        mensaje: 'Este correo no trae el sello del IESS.',
      );
    }
    final oficial = Uri.tryParse(servidor);
    final origen = m.group(1);
    if (origen != null &&
        oficial != null &&
        Uri.parse(origen).host != oficial.host) {
      return ResultadoSello(
        valido: false,
        motivo: 'dominio_ajeno',
        mensaje:
            'El sello apunta a ${Uri.parse(origen).host}, que no es el verificador oficial del IESS. '
            'Es una imitación: no abras sus enlaces ni entregues datos.',
      );
    }
    if (servidor.isEmpty) {
      return const ResultadoSello(
        valido: false,
        motivo: 'sin_conexion',
        mensaje: 'Falta configurar el verificador de sellos.',
      );
    }
    try {
      final c = cliente ?? http.Client();
      final r = await c
          .get(Uri.parse('$servidor/api/v1/verificar/${m.group(2)}'))
          .timeout(const Duration(seconds: 8));
      final d = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      return ResultadoSello(
        valido: d['valido'] == true,
        motivo: '${d['motivo'] ?? 'desconocido'}',
        mensaje: '${d['mensaje'] ?? ''}',
        datos: d,
      );
    } catch (_) {
      return const ResultadoSello(
        valido: false,
        motivo: 'sin_conexion',
        mensaje:
            'No pude comprobar el sello ahora (sin conexión). Mientras tanto, no abras sus enlaces.',
      );
    }
  }
}

/// Privacidad: el guardián solo mira el ASUNTO de los correos y solo se activa si habla del IESS.
/// (Misma regla que PreFiltro.asuntoDelIess en Android.)
final _asuntoIess = RegExp(
  r'\b(iess|i\.e\.s\.s|biess|seguro social|seguridad social|afiliad\w*|afiliacion\w*|instituto ecuatoriano|jubilad\w*|jubilacion\w*|pension\w*|'
  r'montepio|cesantia\w*|fondos? de reserva|aportes?|planillas?|prestamos? (quirografario|hipotecario)\w*|'
  r'decimo (tercero|cuarto)|turno medico|cita medica)\b',
);

bool asuntoDelIess(String asunto) => _asuntoIess.hasMatch(plegar(asunto));

/// Marca con la que el aviso abre la app en modo "verificar sello" (solo lleva el asunto).
const marcaAvisoIess = 'AIESS_AVISO_IESS:';
