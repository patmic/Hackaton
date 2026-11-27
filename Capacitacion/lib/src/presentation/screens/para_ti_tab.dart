import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/logica/logica.dart';
import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/actividad_tile.dart';
import '../widgets/selector_rango.dart';
import '../widgets/vista_async.dart';
import 'capacitacion_screen.dart';
import 'sesion_demo_screen.dart';

class ParaTiTab extends ConsumerWidget {
  const ParaTiTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionProvider).value ?? SesionUsuario.sinCuenta;
    final perfil = ref.watch(perfilProvider);
    final capacitacion = ref.watch(capacitacionProvider).value;
    final recomendaciones = ref.watch(recomendacionesProvider);
    final progreso = ref.watch(progresoProvider).value;
    final textos = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            key: const ValueKey('tarjeta-sesion'),
            leading: const Icon(Icons.person_outline),
            title: Text(sesion.tieneCuenta ? sesion.nombreTipo : 'Sin cuenta'),
            subtitle: Text('Perfil: ${perfil.perfilConducta.etiquetaVisible}'),
            trailing: TextButton(
              key: const ValueKey('boton-cambiar-sesion'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SesionDemoScreen(),
                ),
              ),
              child: const Text('Cambiar (demo)'),
            ),
          ),
        ),
        if (tieneRolDeConsola(perfil))
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Las herramientas de tu rol (emitir, observatorio, roles) están '
              'en la consola web, a cargo de los Bloques 1 y 3.',
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const ValueKey('boton-quiero-capacitarme'),
          icon: const Icon(Icons.school_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CapacitacionScreen()),
          ),
          label: Text(
            capacitacion?.inscrito ?? false
                ? 'Mi capacitación'
                : 'Quiero capacitarme',
          ),
        ),
        // Con cuenta, el rango viene del padrón. Sin cuenta se pregunta con
        // un clic y se puede no responder (Fallo 3).
        if (!sesion.tieneCuenta) ...[
          const SizedBox(height: 24),
          Text(
            'Para avisarte de las estafas que circulan, '
            '¿en qué rango de edad estás? (opcional)',
            style: textos.titleMedium,
          ),
          const SizedBox(height: 8),
          SelectorRango(
            seleccionado: perfil.rangoEtario,
            onCambio: ref.read(perfilProvider.notifier).elegirRango,
          ),
        ],
        const SizedBox(height: 24),
        Text('Recomendadas', style: textos.titleLarge),
        const SizedBox(height: 8),
        VistaAsync(
          valor: recomendaciones,
          datos: (lista) => lista.isEmpty
              ? const Text('Ya hiciste todas las actividades de tu ruta.')
              : Column(
                  children: [
                    for (final r in lista)
                      ActividadTile(
                        actividad: r.actividad,
                        completada:
                            progreso?.estaCompletada(r.actividad.id) ?? false,
                        motivo: r.motivos.isEmpty ? null : r.motivos.first,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
