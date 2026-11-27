// Consentimiento explícito antes de que la IA lea un correo.
// Sin un "Sí" de la persona, el texto no sale del celular (ni a las reglas en el servidor ni al modelo).
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../features/voz/voz.dart';
import '../features/llm/cerebro.dart';
import 'tema.dart';

String get textoConsentimiento => Cerebro.i.enEsteEquipo
    ? 'Para revisar este correo, la inteligencia artificial de AIESS va a leerlo AQUÍ, en tu equipo: '
          'el correo no sale de él. Al terminar, la conversación se borra.'
    : 'Para revisar este correo, la inteligencia artificial de AIESS va a leerlo en el servidor de AIESS. '
          'Antes quitamos tu nombre, cédula, teléfono y cuentas. Al terminar, la conversación se borra: '
          'no se guarda ni se usa para entrenar.';

/// Devuelve true solo si la persona toca «Sí, revisar con la IA».
Future<bool> pedirConsentimientoIA(
  BuildContext context, {
  bool firmaValida = false,
  String? motivo,
}) async {
  final intro =
      motivo ??
      (firmaValida
          ? 'La firma del IESS es válida. Si igual quieres que la IA revise el texto: '
          : '');
  Voz.i.decir(
    '$intro¿Me das permiso para que la inteligencia artificial lea este correo? '
    'Al terminar, la conversación se borra.',
  );
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (c) => AlertDialog(
      icon: const Icon(Icons.privacy_tip_rounded, size: 36, color: Tono.lima),
      title: Text(
        '¿Revisar con la IA?',
        style: Letra.lexend(24, peso: FontWeight.w700, color: Tono.tinta),
      ),
      content: Semantics(
        liveRegion: true,
        child: Text(
          intro + textoConsentimiento,
          style: Letra.lectura(18, color: Tono.tinta),
        ),
      ),
      actionsOverflowDirection: VerticalDirection.up,
      actionsOverflowButtonSpacing: 8,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('No, gracias'),
        ),
        FilledButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(c, true);
          },
          icon: const Icon(Icons.check_rounded),
          label: const Text('Sí, revisar con la IA'),
        ),
      ],
    ),
  );
  if (ok != true) Voz.i.callar();
  return ok == true;
}
