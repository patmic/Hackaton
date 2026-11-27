// Verificación del sello SellaCorreo (firma Ed25519 del IESS) y filtro de privacidad por asunto.
//
// Flujo: el IESS firma el correo en SellaCorreo (GenKey) y le pone una imagen con el enlace
// https://<servidor-sello>/checkin/<token>.<huella>. El robot toma ese enlace y lo verifica contra el
// servidor OFICIAL de SellaCorreo (AIESS_SELLO), nunca contra el dominio que trae el enlace: si un estafador
// pone un enlace a su propio "verificador", se marca como falso.
import 'dart:convert';

import '../analisis/motor.dart';
import '../osint/url_analyzer.dart';
import 'package:crypto/crypto.dart';
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

/// Motivos de SellaCorreo dichos por Leo (guion de Leo, audios E10–E17 en assets/voz).
const _cierreSello = 'Podría ser una estafa: no hagas clic en sus enlaces ni entregues tus datos.';
const _motivoLeo = {
  'enlace_malformado': 'Ese enlace no tiene el formato del sello del IESS. $_cierreSello',
  'no_registrado': 'El IESS no tiene registrado ningún correo con este sello. $_cierreSello',
  'hash_distinto': 'El enlace del sello fue alterado: no coincide con el registro del IESS. $_cierreSello',
  'contenido_alterado': 'Los datos de este sello fueron alterados. $_cierreSello',
  'firma_invalida': 'La firma digital de este sello no es válida. $_cierreSello',
  'caducado': 'El sello de este correo ya caducó. $_cierreSello',
  'sello_anterior': 'Este sello es de una versión anterior y ya no se puede verificar. $_cierreSello',
};

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
        // El servidor responde en «usted»; Leo lo dice con su propia frase (y su audio) según el motivo.
        mensaje: _motivoLeo[d['motivo']] ?? '${d['mensaje'] ?? ''}',
        datos: d,
      );
    } catch (_) {
      return const ResultadoSello(
        valido: false,
        motivo: 'sin_conexion',
        mensaje:
            'No pude comprobar el sello ahora porque no hay conexión. Mientras tanto, no abras sus enlaces.',
      );
    }
  }

  /// El guardián del celular solo ve el ASUNTO de la notificación (no el correo ni sus enlaces). Le pregunta a
  /// SellaCorreo si el IESS selló un correo con ese asunto; el servidor busca ese sello y verifica su firma.
  /// Se envía SOLO la huella del asunto. `valido` = hay un sello válido.
  static Future<ResultadoSello> porAsunto(
    String asunto, {
    http.Client? cliente,
    String? servidorOficial,
  }) async {
    final servidor = servidorOficial ?? Sello.servidor;
    if (servidor.isEmpty || asunto.trim().isEmpty) {
      return const ResultadoSello(
        valido: false,
        motivo: 'sin_conexion',
        mensaje: 'No pude comprobar el sello.',
      );
    }
    try {
      final c = cliente ?? http.Client();
      // Privacidad: se envía la HUELLA (SHA-256) del asunto, no su texto. El servidor la compara con la
      // huella de los asuntos que el IESS selló.
      final uri = Uri.parse(
        '$servidor/api/v1/asunto',
      ).replace(queryParameters: {'huella': huellaAsunto(asunto)});
      final r = await c.get(uri).timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) throw Exception('http ${r.statusCode}');
      final d = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      return ResultadoSello(
        valido: d['sellado'] == true,
        motivo: '${d['motivo'] ?? 'desconocido'}',
        // El servidor responde en «usted»; Leo lo dice con su propia frase (y su audio) según el motivo.
        mensaje: _motivoLeo[d['motivo']] ?? '${d['mensaje'] ?? ''}',
        datos: d,
      );
    } catch (_) {
      return const ResultadoSello(
        valido: false,
        motivo: 'sin_conexion',
        mensaje:
            'No pude comprobar el sello ahora porque no hay conexión. Mientras tanto, no abras sus enlaces.',
      );
    }
  }

  /// Asunto normalizado: sin «RE:», «RV:», «Fwd:», espacios de más ni mayúsculas (igual que el servidor).
  static String normalizarAsunto(String asunto) => asunto
      .replaceFirst(
        RegExp(
          r'^\s*((re|rv|fw|fwd|reenviado|respuesta)\s*:\s*)+',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();

  /// SHA-256 del asunto normalizado: lo único que sale del equipo en la consulta por asunto.
  static String huellaAsunto(String asunto) =>
      sha256.convert(utf8.encode(normalizarAsunto(asunto))).toString();

  /// Veredicto a partir de la consulta por asunto (mismo formato en el aviso y en la app).
  /// Sellado: es del IESS. Sin sello: el Sí/No lo deciden los indicios que se ven en el ASUNTO (catálogo),
  /// y el sello va como aviso aparte; para contar todos los indicios hay que revisar el correo completo.
  static Veredicto veredictoPorAsunto(ResultadoSello r, String asunto) {
    if (r.valido) {
      return Veredicto(
        phishing: false,
        puntaje: 0,
        voz: r.mensaje,
        indicios: const [],
        explicacion: r.mensaje,
        queHacer: 'Igual, nunca entregues tu clave.',
        fuente: 'sello',
        selloEstado: 'valido',
      );
    }
    final reglas = analizarConReglas(
      Entrada(asunto, canal: 'asunto del aviso'),
      analizarMensaje(asunto),
    );
    final v = aplicarSello(
      reglas,
      estado: r.sinRespuesta ? 'sin_verificar' : 'sin_sello',
    );
    // Solo se vio el asunto: sin indicios no se dice «tranquilo», se pide revisar el correo completo.
    return v.phishing
        ? v
        : v.copiar(
            voz:
                'En el asunto no veo señales de estafa, pero no pude confirmar que sea del IESS. '
                'Copia el correo y lo reviso completo.',
          );
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
