// Conversación del robot: con LFM2 si hay modelo; si no, respuestas guía (mismas que el dataset de persona).
import '../../core/canales.dart';
import '../analisis/motor.dart';
import '../llm/cerebro.dart';

class Persona {
  static final _historial = <(String, String)>[];

  static Future<String> responder(String pregunta) async {
    if (Cerebro.i.listo) {
      _historial.add(('user', pregunta));
      while (_historial.length > 6) {
        _historial.removeAt(0);
      }
      final r = (await Cerebro.i.generar(
        formatoLfm2(systemPrompt(), _historial),
        prefijo: prefijoLfm2(systemPrompt()),
        maxTokens: 160,
        temperatura: 0.3,
      )).trim();
      if (r.isNotEmpty && !r.startsWith('{')) {
        _historial.add(('assistant', r));
        return r;
      }
    }
    return guia(pregunta);
  }

  static String guia(String p) {
    final t = plegar(p);
    final c = Canales.i.contacto;
    bool tiene(String re) => RegExp(re).hasMatch(t);
    if (tiene(
      r'(hice clic|di mis datos|me estafaron|ingrese mi clave|ya pague)',
    )) {
      return 'Tranquilo, actuemos rápido. Cambia tu clave en ${c['aplicaciones']}, llama a tu banco si diste tu tarjeta '
          'y avisa al IESS a ${c['seguridad_informacion']}.';
    }
    if (tiene(r'(pagina|sitio|web|oficial|tramite)')) {
      return 'La página oficial es ${c['portal']}, y los trámites están en ${c['aplicaciones']}. Escríbela tú mismo en el navegador.';
    }
    if (tiene(r'(whatsapp|telefono|numero|llamar)')) {
      return 'El WhatsApp del IESS es ${c['whatsapp']}, y el teléfono es ${c['atencion_telefono']}.';
    }
    if (tiene(r'(denunci|report|avisar)')) {
      return 'Reenvía el mensaje a ${c['seguridad_informacion']} y no le respondas al estafador.';
    }
    if (tiene(r'(clave|contrasena)')) {
      return 'El IESS nunca te va a pedir tu clave por mensaje. Si alguien te la pide, es una estafa.';
    }
    if (tiene(r'(phishing|estafa|que es)')) {
      return 'Phishing es cuando alguien se hace pasar por el IESS para robarte tus claves o tu dinero. Cópiame el mensaje y lo reviso.';
    }
    if (tiene(r'(gracias|chao|adios)'))
      return 'Con gusto. Y recuerda: ante la duda, no hagas clic.';
    if (tiene(r'(hola|buenas|quien eres)')) {
      return 'Hola, soy $nombreMascota. Copia el mensaje que te preocupa y toca el botón. Yo lo reviso.';
    }
    return 'Puedo revisar mensajes por ti. Copia el mensaje o el enlace y toca el botón. Si quieres practicar, dime: juguemos.';
  }
}
