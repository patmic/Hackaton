import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/capsula_tile.dart';
import '../widgets/selector_rango.dart';

/// Verificación de un correo dentro de la app oficial (nunca desde la
/// página que abre un QR: mitigación del Fallo 1).
class VerificarTab extends ConsumerStatefulWidget {
  const VerificarTab({super.key});

  @override
  ConsumerState<VerificarTab> createState() => _VerificarTabState();
}

class _VerificarTabState extends ConsumerState<VerificarTab> {
  final _codigo = TextEditingController();
  final _remitente = TextEditingController();
  Tipologia? _tipologia;

  @override
  void dispose() {
    _codigo.dispose();
    _remitente.dispose();
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
          'Pega el código de verificación del correo o el remitente.',
          style: textos.titleMedium,
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
        TextField(
          key: const ValueKey('campo-remitente'),
          controller: _remitente,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Remitente (ej. pagos@dominio.com)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Text('¿De qué trata el correo?', style: textos.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
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
                      remitente: _remitente.text,
                      tipologiaPercibida: _tipologia,
                    ),
          child: const Text('Verificar'),
        ),
        const SizedBox(height: 16),
        estado.when(
          data: (e) => e == null ? const SizedBox.shrink() : _Resultado(e),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text(
            err is FormatException ? err.message : 'No se pudo verificar: $err',
          ),
        ),
      ],
    );
  }
}

class _Resultado extends ConsumerWidget {
  const _Resultado(this.estado);

  final VerificacionEstado estado;

  static String _fecha(DateTime f) {
    final l = f.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(l.day)}/${dos(l.month)}/${l.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = estado.resultado;
    final m = r.metadatosOficiales;
    final textos = Theme.of(context).textTheme;
    final perfil = ref.watch(perfilProvider);
    final titulo = switch (r.semaforo) {
      Semaforo.verde => 'Sello auténtico',
      Semaforo.amarillo => 'Precaución',
      Semaforo.rojo => 'Es una estafa',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${r.semaforo.codigo} · $titulo',
                  key: const ValueKey('semaforo'),
                  style: textos.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(r.motivo),
                if (m != null) ...[
                  const SizedBox(height: 12),
                  Text('Emitido por: ${m.emisorNombre}'),
                  Text('Tipo: ${m.tipologia.nombre} (${m.tipologia.codigo})'),
                  Text('Asunto oficial: «${m.asuntoResumen}»'),
                  Text('Fecha: ${_fecha(m.fecha)}'),
                ],
                if (r.capsulaEducativa != null) ...[
                  const SizedBox(height: 12),
                  Text(r.capsulaEducativa!, style: textos.titleSmall),
                ],
              ],
            ),
          ),
        ),
        if (perfil.esAnonimo) ...[
          const SizedBox(height: 16),
          const Text(
            'Para ayudarnos a proteger a más personas como tú, '
            '¿en qué rango de edad estás? (opcional)',
          ),
          const SizedBox(height: 8),
          SelectorRango(
            seleccionado: perfil.rangoEtario,
            onCambio: ref.read(perfilProvider.notifier).elegirRango,
            permitirTodos: false,
          ),
        ],
        if (estado.capsula != null) ...[
          const SizedBox(height: 16),
          Text('Aprende a reconocerlo', style: textos.titleMedium),
          CapsulaTile(capsula: estado.capsula!),
        ],
      ],
    );
  }
}
