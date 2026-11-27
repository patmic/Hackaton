// Observatorio de SellaCorreo: cada revisión deja una observación ANÓNIMA para que el IESS vea qué indicios
// aparecen en los correos que reciben sus afiliados (y arme campañas de capacitación).
//
// Qué se envía (contrato «VERIFICACION» de Analisis-de-comportamiento/contrato/):
//   - id_seudonimo: un código al azar de este equipo (no es la cédula, el nombre ni el correo),
//   - semáforo: ROJO (phishing), VERDE (firma válida del IESS o sin indicios) o AMARILLO (sin sello),
//   - indicios: solo los códigos I1–I11.
// Nunca se envía el texto del correo, el asunto, el remitente ni los enlaces. Se puede apagar en Ajustes.
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../analisis/motor.dart';
import '../sello/sello.dart';

class Observatorio {
  static const _clave = 'observatorio';

  static Future<bool> activo() async =>
      (await SharedPreferences.getInstance()).getBool(_clave) ?? true;

  static Future<void> activar(bool si) async =>
      (await SharedPreferences.getInstance()).setBool(_clave, si);

  static Future<String> _seudonimo() async {
    final p = await SharedPreferences.getInstance();
    var id = p.getString('observatorio_id');
    if (id == null) {
      const letras =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      final r = Random.secure();
      id = String.fromCharCodes(
        List.generate(24, (_) => letras.codeUnitAt(r.nextInt(letras.length))),
      );
      await p.setString('observatorio_id', id);
    }
    return id;
  }

  /// Semáforo de la observación.
  static String semaforo(Veredicto v) =>
      v.phishing ? 'ROJO' : (v.sinConfirmar ? 'AMARILLO' : 'VERDE');

  /// Cuerpo exacto que se envía (para pruebas y para mostrarlo a quien lo pida).
  static Map<String, dynamic> observacion(Veredicto v, String id) => {
    'id_seudonimo': id,
    'tipo': 'VERIFICACION',
    'semaforo': semaforo(v),
    'indicios': indiciosValidos(v.indicios),
  };

  /// Registra la revisión. Nunca falla ni demora la app: si no hay red, se pierde esa observación.
  static Future<void> registrar(Veredicto v, {http.Client? cliente}) async {
    try {
      if (Sello.servidor.isEmpty || !await activo()) return;
      final c = cliente ?? http.Client();
      await c
          .post(
            Uri.parse('${Sello.servidor}/api/v1/observatorio/observaciones'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'observaciones': [observacion(v, await _seudonimo())],
            }),
          )
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
  }
}
