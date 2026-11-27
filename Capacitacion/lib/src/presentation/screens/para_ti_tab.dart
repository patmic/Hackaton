import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/logica/logica.dart';
import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/actividad_tile.dart';
import '../widgets/animaciones.dart';
import '../widgets/plan_personal_card.dart';
import '../widgets/responsivo.dart';
import '../widgets/selector_rango.dart';
import '../widgets/vista_async.dart';
import 'capacitacion_screen.dart';
import 'progreso_tab.dart' show TiraInsignias;
import 'sesion_demo_screen.dart';

/// Inicio del aula. Orden por importancia (una cosa a la vez):
/// 1. Qué es esto y cuánto llevo  2. La acción principal  3. Qué hacer ahora  4. Ajustes opcionales.
class ParaTiTab extends ConsumerWidget {
  const ParaTiTab({super.key, this.onVerInsignias});

  /// Lleva a «Mi avance», donde están todas las insignias.
  final VoidCallback? onVerInsignias;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionProvider).value ?? SesionUsuario.sinCuenta;
    final perfil = ref.watch(perfilProvider);
    final capacitacion = ref.watch(capacitacionProvider).value;
    final recomendaciones = ref.watch(recomendacionesProvider);
    final progreso = ref.watch(progresoProvider).value;
    final insignias = ref.watch(insigniasProvider).value;
    final total = ref.watch(actividadesDelPerfilProvider).value?.length ?? 0;
    final hechas = progreso?.completadas.length ?? 0;
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;

    // Lista corta: se construye completa (no perezosa) para que el lector de pantalla la recorra entera.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Bienvenida + avance (visibilidad del estado del sistema).
          Text('Aprende a no caer en estafas', style: textos.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Lecciones cortas, de 1 a 3 minutos. Puedes parar cuando quieras.',
            style: textos.bodyLarge?.copyWith(color: esquema.onSurfaceVariant),
          ),
          if (total > 0) ...[
            const SizedBox(height: 16),
            Semantics(
              label: 'Llevas $hechas de $total lecciones',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hechas == 0
                        ? 'Aún no empiezas: tienes $total lecciones'
                        : 'Llevas $hechas de $total lecciones',
                    style: textos.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : (hechas / total).clamp(0, 1),
                      minHeight: 10,
                      backgroundColor: esquema.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Insignias ganadas: se ve lo logrado y dan ganas de seguir.
          if (insignias != null) ...[
            const SizedBox(height: 16),
            TiraInsignias(resumen: insignias, onVerTodas: onVerInsignias),
          ],
          const SizedBox(height: 20),

          // 2. Acción principal, grande y con texto claro.
          SizedBox(
            height: 64,
            child: FilledButton.icon(
              key: const ValueKey('boton-quiero-capacitarme'),
              icon: const Icon(Icons.play_arrow_rounded, size: 30),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CapacitacionScreen(),
                ),
              ),
              label: Text(
                capacitacion?.inscrito ?? false
                    ? 'Seguir mi capacitación'
                    : 'Quiero capacitarme',
              ),
            ),
          ),
          if (tieneRolDeConsola(perfil))
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Las herramientas de tu rol (emitir, observatorio, roles) están '
                'en la consola web, a cargo de los Bloques 1 y 3.',
              ),
            ),

          // 3. Qué hacer ahora.
          const SizedBox(height: 28),
          Text('Recomendadas', style: textos.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Toca una lección para empezar.',
            style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          VistaAsync(
            valor: recomendaciones,
            datos: (lista) => lista.isEmpty
                ? const Text('Ya hiciste todas las actividades de tu ruta.')
                : RejillaAdaptable(
                    children: [
                      for (final (i, r) in lista.indexed)
                        Aparecer(
                          orden: i,
                          child: ActividadTile(
                            actividad: r.actividad,
                            completada:
                                progreso?.estaCompletada(r.actividad.id) ??
                                false,
                            motivo: r.motivos.isEmpty ? null : r.motivos.first,
                          ),
                        ),
                    ],
                  ),
          ),
          // Por qué esas lecciones: lo que el observador aprendió de ti.
          const SizedBox(height: 16),
          const PlanPersonalCard(),

          // 4. Opcional: edad (sin cuenta) y perfil, al final para no distraer.
          if (!sesion.tieneCuenta) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Para avisarte de las estafas que circulan, '
                      '¿en qué rango de edad estás? (opcional)',
                      style: textos.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SelectorRango(
                      seleccionado: perfil.rangoEtario,
                      onCambio: ref.read(perfilProvider.notifier).elegirRango,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            // Sin ListTile: con letra grande el botón baja a otra línea en vez de romper la tarjeta.
            child: Padding(
              key: const ValueKey('tarjeta-sesion'),
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.person_outline, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 4,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sesion.tieneCuenta
                                  ? sesion.nombreTipo
                                  : 'Sin cuenta',
                              style: textos.titleMedium,
                            ),
                            Text(
                              'Perfil: ${perfil.perfilConducta.etiquetaVisible}',
                              style: textos.bodyMedium?.copyWith(
                                color: esquema.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          key: const ValueKey('boton-cambiar-sesion'),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SesionDemoScreen(),
                            ),
                          ),
                          child: const Text('Cambiar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
