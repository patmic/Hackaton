import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import 'actividad_tile.dart';
import 'selector_rango.dart';

/// Resultado de una verificación (pasos 8a y 8b del diagrama), con lo que
/// sigue: comparar, entender el análisis, reportar y aprender.
class ResultadoVerificacionView extends ConsumerWidget {
  const ResultadoVerificacionView({super.key, required this.estado});

  final VerificacionEstado estado;

  static String titulo(Semaforo semaforo) => switch (semaforo) {
    Semaforo.verde => 'Correo auténtico',
    Semaforo.amarillo => 'Precaución',
    Semaforo.rojo => 'Alerta de phishing',
  };

  static String fecha(DateTime f) {
    final l = f.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(l.day)}/${dos(l.month)}/${l.year} ${dos(l.hour)}:${dos(l.minute)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = estado.resultado;
    final m = r.metadatosOficiales;
    final textos = Theme.of(context).textTheme;
    final perfil = ref.watch(perfilProvider);
    final controller = ref.read(verificacionProvider.notifier);
    final perfilNotifier = ref.read(perfilProvider.notifier);

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
                  '${r.semaforo.codigo} · ${titulo(r.semaforo)}',
                  key: const ValueKey('semaforo'),
                  style: textos.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(r.motivo),
                if (m != null) ...[
                  const SizedBox(height: 12),
                  if (m.remitente != null)
                    Text('Remitente verificado: ${m.remitente}'),
                  Text('Emitido por: ${m.emisorNombre}'),
                  if (m.tipologia != null)
                    Text(
                      'Tipo: ${m.tipologia!.nombre} (${m.tipologia!.codigo})',
                    ),
                  if (m.asuntoResumen != null)
                    Text('Asunto oficial: «${m.asuntoResumen}»'),
                  Text('Fecha: ${fecha(m.fecha)}'),
                ],
                if (r.capsulaEducativa != null) ...[
                  const SizedBox(height: 12),
                  Text(r.capsulaEducativa!, style: textos.titleSmall),
                ],
              ],
            ),
          ),
        ),
        if (estado.faltaComparar) ...[
          const SizedBox(height: 16),
          Text(
            '¿El correo que lees viene de este remitente y trata de esto?',
            style: textos.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('boton-no-coincide'),
                  onPressed: () =>
                      controller.confirmarCoincidencia(coincide: false),
                  child: const Text('No coincide'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const ValueKey('boton-coincide'),
                  onPressed: () =>
                      controller.confirmarCoincidencia(coincide: true),
                  child: const Text('Sí, coincide'),
                ),
              ),
            ],
          ),
        ],
        if (estado.coincidenciaConfirmada) ...[
          const SizedBox(height: 16),
          const Text(
            'Bien. Aun así, si el correo te pide claves o pagos, no lo hagas: '
            'el IESS nunca los pide por correo.',
          ),
        ],
        if (r.analisis != null) ...[
          const SizedBox(height: 16),
          _Analisis(analisis: r.analisis!),
        ],
        if (!r.esAutentico) ...[
          const SizedBox(height: 16),
          const _ComoReportar(),
        ],
        if (perfil.sinRango) ...[
          const SizedBox(height: 16),
          const Text(
            'Para ayudarnos a proteger a más personas como tú, '
            '¿en qué rango de edad estás? (opcional)',
          ),
          const SizedBox(height: 8),
          SelectorRango(
            seleccionado: perfil.rangoEtario,
            onCambio: perfilNotifier.elegirRango,
            permitirTodos: false,
          ),
        ],
        // CLAUDE.md §14: a quien verifica sin cuenta (EX5) se le pregunta si
        // lo hace por otra persona (marca de riesgo «cuidador»).
        if (perfil.tipos.contains(TipoUsuario.ex5))
          SwitchListTile(
            key: const ValueKey('switch-cuidador'),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Verifico este correo por otra persona (opcional)',
            ),
            value: perfil.esCuidador,
            onChanged: perfilNotifier.marcarCuidador,
          ),
        if (estado.actividad != null || estado.microcurso != null) ...[
          const SizedBox(height: 16),
          Text('Aprende a reconocerlo', style: textos.titleMedium),
          if (estado.microcurso != null)
            Text('Microcurso: «${estado.microcurso!.titulo}»'),
          if (estado.actividad != null)
            ActividadTile(actividad: estado.actividad!),
        ],
      ],
    );
  }
}

class _Analisis extends StatelessWidget {
  const _Analisis({required this.analisis});

  final AnalisisRiesgo analisis;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              analisis.nivel == null
                  ? 'Análisis de riesgo'
                  : 'Análisis de riesgo: ${analisis.nivel!.etiqueta}',
              key: const ValueKey('analisis-titulo'),
              style: textos.titleMedium,
            ),
            if (analisis.explicacion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(analisis.explicacion),
            ],
            for (final i in analisis.indicios)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.warning_amber),
                title: Text(i.nombre),
                subtitle: Text(i.queSeRevisa),
              ),
          ],
        ),
      ),
    );
  }
}

class _ComoReportar extends StatelessWidget {
  const _ComoReportar();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Repórtalo', style: textos.titleMedium),
        const SizedBox(height: 4),
        const Text('Reenvía el correo a:'),
        const SelectableText(
          CanalesOficiales.correoReportes,
          key: ValueKey('correo-reportes'),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tu reporte ayuda a alertar a otras personas. Equivocarte no tiene '
          'consecuencias.',
        ),
      ],
    );
  }
}
