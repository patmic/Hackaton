import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/resultado_verificacion_view.dart';

/// Verificación de un correo dentro de la app oficial, nunca desde la página
/// que abre un QR o un enlace (mitigación del Fallo 1).
///
/// Lo normal es llegar con el botón «Verificar en App» del correo (ver
/// `VerificacionScreen`). Esta pestaña sirve para pegar el código a mano.
class VerificarTab extends ConsumerStatefulWidget {
  const VerificarTab({super.key});

  @override
  ConsumerState<VerificarTab> createState() => _VerificarTabState();
}

class _VerificarTabState extends ConsumerState<VerificarTab> {
  final _codigo = TextEditingController();
  Tipologia? _tipologia;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(verificacionProvider);
    final textos = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pega el código de verificación que trae el correo al final.',
          style: textos.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Si el correo tiene el botón «Verificar en App», tócalo: la app se '
          'abre y verifica sola.',
          style: textos.bodySmall,
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('campo-codigo'),
          controller: _codigo,
          decoration: const InputDecoration(
            labelText: 'Código de verificación',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Text('¿De qué trata el correo? (opcional)', style: textos.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in Tipologia.values)
              ChoiceChip(
                label: Text(t.nombre),
                selected: _tipologia == t,
                onSelected: (s) => setState(() => _tipologia = s ? t : null),
              ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('boton-verificar'),
          onPressed: estado.isLoading
              ? null
              : () => ref
                    .read(verificacionProvider.notifier)
                    .verificar(
                      codigo: _codigo.text,
                      tipologiaPercibida: _tipologia,
                    ),
          child: const Text('Verificar'),
        ),
        const SizedBox(height: 8),
        Text(
          '¿El correo no trae código ni botón? Los correos oficiales del IESS '
          'siempre lo traen: no actúes por él y repórtalo a '
          '${CanalesOficiales.correoReportes}.',
          style: textos.bodySmall,
        ),
        const SizedBox(height: 16),
        estado.when(
          data: (e) => e == null
              ? const SizedBox.shrink()
              : ResultadoVerificacionView(estado: e),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text(
            err is FormatException ? err.message : 'No se pudo verificar: $err',
          ),
        ),
      ],
    );
  }
}
