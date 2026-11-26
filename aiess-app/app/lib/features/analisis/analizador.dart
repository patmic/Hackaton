// Orquestador: OSINT offline -> (red opcional) -> LFM2 local -> fusión.

import 'package:shared_preferences/shared_preferences.dart';

import '../llm/cerebro.dart';
import '../osint/url_analyzer.dart';
import 'motor.dart';
import 'red.dart';

class Analizador {
  /// [alAvanzar]: paso actual y progreso 0..1 (null = indeterminado) para la animación de carga.
  /// [alSospechar]: se llama al instante si las reglas ya ven señales.
  /// [alAdelantar]: veredicto y voz apenas el modelo los escribe, sin esperar el JSON completo.
  static Future<Veredicto> analizar(Entrada e,
      {void Function(String paso, double? progreso)? alAvanzar,
      void Function()? alSospechar,
      void Function(bool phishing, String voz)? alAdelantar,
      bool usarModelo = true}) async {
    alAvanzar?.call('Mirando el enlace', null);
    final osint = analizarMensaje(e.texto, remitente: e.remitente);
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('red') ?? false) {
      alAvanzar?.call('Revisando el sitio en internet', null);
      await revisarRed(osint);
    }
    if (usarModelo) await Future.delayed(const Duration(milliseconds: 350)); // que el paso alcance a verse
    alAvanzar?.call('Buscando señales de engaño', null);
    final reglas = analizarConReglas(e, osint);
    if (usarModelo) await Future.delayed(const Duration(milliseconds: 350));

    final cerebro = Cerebro.i;
    if (!usarModelo || !cerebro.afinado) return reglas;
    if (reglas.phishing) alSospechar?.call();
    alAvanzar?.call('Pensándolo con mi cerebro', 0);
    final system = systemPrompt();
    final prompt = formatoLfm2(system, [('user', promptAnalisis(e, osint))]);
    final fuerte = osint.puntaje >= 60 || reglas.puntaje >= 80;
    final buffer = StringBuffer();
    var n = 0;
    var adelantado = false;
    final salida = await cerebro.generar(prompt, prefijo: prefijoLfm2(system), maxTokens: 420, alToken: (t) {
      buffer.write(t);
      n++;
      if (n % 4 == 0) alAvanzar?.call('Pensándolo con mi cerebro', (n / 220).clamp(0.0, 0.97));
      if (adelantado || alAdelantar == null) return;
      // En cuanto el modelo termina de escribir "veredicto" y "voz", el cóndor ya puede hablar.
      final txt = buffer.toString();
      final v = RegExp(r'"veredicto"\s*:\s*"(PHISHING|SEGURO)"').firstMatch(txt);
      final voz = RegExp(r'"voz"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(txt);
      if (v != null && voz != null) {
        final phishing = v.group(1) == 'PHISHING';
        if (!phishing && fuerte) return; // la fusión lo corregirá: no adelantar un "seguro" dudoso
        adelantado = true;
        alAdelantar(phishing, voz.group(1)!.replaceAll(r'\"', '"'));
      }
    });
    alAvanzar?.call('Pensándolo con mi cerebro', 1);
    return fusionar(reglas, leerSalidaModelo(salida), osint);
  }

}
