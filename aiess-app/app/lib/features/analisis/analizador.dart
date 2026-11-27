import 'dart:async';

// Orquestador: OSINT offline -> (red opcional) -> LFM2 local -> fusión.

import '../llm/cerebro.dart';
import '../llm/remoto.dart';
import '../osint/cti.dart';
import '../osint/url_analyzer.dart';
import 'anonimizar.dart';
import 'motor.dart';

class Analizador {
  /// [alAvanzar]: paso actual y progreso 0..1 (null = indeterminado) para la animación de carga.
  /// [alSospechar]: se llama al instante si las reglas ya ven señales.
  /// [alAdelantar]: veredicto y voz apenas el modelo los escribe, sin esperar el JSON completo.
  static Future<Veredicto> analizar(
    Entrada e, {
    void Function(String paso, double? progreso)? alAvanzar,
    void Function()? alSospechar,
    void Function(bool phishing, String voz)? alAdelantar,
    bool usarModelo = true,
  }) async {
    alAvanzar?.call('Mirando el enlace', null);
    // Si el texto trae «De: …» (pegado, .eml, PDF o captura), el remitente también se revisa (indicio I7).
    final osint = analizarMensaje(
      e.texto,
      remitente: e.remitente ?? remitenteEn(e.texto),
    );
    // Fuentes OSINT/CTI externas: solo el dominio o la URL (nunca el texto del correo).
    if (osint.urls.any((u) => !u.confiable)) {
      alAvanzar?.call(
        'Consultando fuentes de amenazas (solo el dominio)',
        null,
      );
      await consultarCti(osint);
    }
    // Nunca se visita el sitio sospechoso (ni siquiera una consulta HEAD): el bot solo LEE los enlaces.
    if (usarModelo)
      await Future.delayed(
        const Duration(milliseconds: 350),
      ); // que el paso alcance a verse
    alAvanzar?.call('Buscando señales de engaño', null);
    final reglas = analizarConReglas(e, osint);
    if (usarModelo) await Future.delayed(const Duration(milliseconds: 350));

    final cerebro = Cerebro.i;
    if (!usarModelo || !cerebro.afinado) {
      return reglas.copiar(salio: [...osint.consultados]);
    }
    if (reglas.phishing) alSospechar?.call();
    // Antes de que el texto salga del celular se tapan los datos personales (cédula, teléfono, nombre…).
    final anonimo = anonimizar(promptAnalisis(e, osint));
    if (anonimo.cambios > 0) {
      alAvanzar?.call('Quitando tus datos personales', null);
      if (usarModelo) await Future.delayed(const Duration(milliseconds: 350));
    }
    alAvanzar?.call('Pensándolo con mi cerebro', 0);
    final system = systemPrompt();
    final prompt = formatoLfm2(system, [('user', anonimo.texto)]);
    final fuerte = osint.puntaje >= 60 || reglas.puntaje >= 80;
    final buffer = StringBuffer();
    var n = 0;
    var adelantado = false;
    final salida = await cerebro.generar(
      prompt,
      prefijo: prefijoLfm2(system),
      maxTokens: 260,
      stop: const [', "que_hacer"'],
      alToken: (t) {
        buffer.write(t);
        n++;
        if (n % 4 == 0)
          alAvanzar?.call(
            'Pensándolo con mi cerebro',
            (n / 220).clamp(0.0, 0.97),
          );
        if (adelantado || alAdelantar == null) return;
        // En cuanto el modelo termina de escribir "veredicto" y "voz", el robot ya puede hablar.
        final txt = buffer.toString();
        final v = RegExp(
          r'"veredicto"\s*:\s*"(PHISHING|SEGURO)"',
        ).firstMatch(txt);
        final voz = RegExp(r'"voz"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(txt);
        if (v != null && voz != null) {
          final phishing = v.group(1) == 'PHISHING';
          if (!phishing && fuerte)
            return; // la fusión lo corregirá: no adelantar un "seguro" dudoso
          adelantado = true;
          alAdelantar(phishing, voz.group(1)!.replaceAll(r'\"', '"'));
        }
      },
    );
    alAvanzar?.call('Pensándolo con mi cerebro', 1);
    // La conversación se borra al terminar: el servidor reemplaza el correo por el prompt de sistema solo.
    unawaited(ServidorIA.i.olvidar(prefijoLfm2(system)));
    return fusionar(reglas, leerSalidaModelo(salida), osint).copiar(
      salio: [
        ...osint.consultados,
        // Solo si la persona activó el servidor en Ajustes: va el texto SIN datos personales.
        if (!cerebro.enEsteEquipo)
          'el texto sin tus datos al servidor de AIESS',
      ],
    );
  }
}
