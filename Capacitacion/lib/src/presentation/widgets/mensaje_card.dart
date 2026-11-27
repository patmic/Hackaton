import 'package:material_ui/material_ui.dart';

import '../../domain/domain.dart';

/// Muestra un mensaje simulado. La etiqueta «SIMULACIÓN» va siempre visible.
class MensajeCard extends StatelessWidget {
  const MensajeCard({super.key, required this.mensaje});

  final MensajeSimulado mensaje;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mensaje.etiqueta, style: textos.labelSmall),
            const SizedBox(height: 8),
            Text('De: ${mensaje.remitente}', style: textos.bodySmall),
            const SizedBox(height: 4),
            Text(mensaje.asunto, style: textos.titleMedium),
            const SizedBox(height: 8),
            for (final p in mensaje.parrafos)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(p, style: textos.bodyLarge),
              ),
            if (mensaje.boton != null)
              Text('[${mensaje.boton}]', style: textos.labelLarge),
            if (mensaje.adjunto != null)
              Text('Adjunto: ${mensaje.adjunto}', style: textos.bodySmall),
            if (mensaje.tieneQr) Text('[Código QR]', style: textos.bodySmall),
            if (mensaje.codigoVerificacion != null) ...[
              const SizedBox(height: 8),
              Text('[Incluye código de verificación]', style: textos.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
