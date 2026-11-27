import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/actividad_tile.dart';
import '../widgets/vista_async.dart';

/// Flujo «Quiero capacitarme» (CLAUDE.md §11, [DECIDIDO]).
class CapacitacionScreen extends ConsumerWidget {
  const CapacitacionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(capacitacionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Quiero capacitarme')),
      body: VistaAsync(
        valor: estado,
        datos: (e) =>
            e.inscrito ? _EstadoView(estado: e) : const _ConsentimientoView(),
      ),
    );
  }
}

// ---------- Paso 1: consentimiento ----------

class _ConsentimientoView extends ConsumerStatefulWidget {
  const _ConsentimientoView();

  @override
  ConsumerState<_ConsentimientoView> createState() =>
      _ConsentimientoViewState();
}

class _ConsentimientoViewState extends ConsumerState<_ConsentimientoView> {
  final _correo = TextEditingController();
  String? _error;
  bool _enviando = false;

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  Future<void> _aceptar(bool pideCorreo) async {
    setState(() {
      _enviando = true;
      _error = null;
    });
    final error = await ref
        .read(capacitacionProvider.notifier)
        .inscribir(correo: pideCorreo ? _correo.text : null);
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final sesion = ref.watch(sesionProvider).value ?? SesionUsuario.sinCuenta;
    final pideCorreo = !sesion.tieneCorreo;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Te enviaremos correos de práctica, parecidos a una estafa, para '
          'que aprendas a reconocerlas.',
          style: textos.titleMedium,
        ),
        const SizedBox(height: 16),
        for (final punto in Consentimiento.puntos)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check),
                const SizedBox(width: 8),
                Expanded(child: Text(punto)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        if (pideCorreo) ...[
          TextField(
            key: const ValueKey('campo-correo'),
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Tu correo',
              helperText: 'Te enviaremos un enlace para confirmarlo.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
        ] else
          Text('Usaremos el correo de tu cuenta: ${sesion.correoEnmascarado}'),
        if (_error != null)
          Text(
            _error!,
            key: const ValueKey('error-correo'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('boton-acepto'),
          onPressed: _enviando ? null : () => _aceptar(pideCorreo),
          child: const Text('Acepto y quiero capacitarme'),
        ),
      ],
    );
  }
}

// ---------- Pasos 2 a 4: correo de práctica, reacción y escalera ----------

class _EstadoView extends ConsumerWidget {
  const _EstadoView({required this.estado});

  final EstadoCapacitacion estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    final controller = ref.read(capacitacionProvider.notifier);
    final desenlace = estado.ultimoDesenlace;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _mensajeFase(estado),
          key: const ValueKey('mensaje-fase'),
          style: textos.titleLarge,
        ),
        if (estado.fase == FaseCapacitacion.esperandoReaccion)
          const Text(
            'No te diremos cuál es el correo de práctica. Trátalo como '
            'cualquier otro: si algo te parece raro, repórtalo.',
          ),
        if (estado.nivelInicial != null) ...[
          const SizedBox(height: 8),
          Text('Tu nivel inicial: ${estado.nivelInicial!.etiqueta}'),
        ],
        if (estado.esCentinela)
          const Text('Eres Centinela: tus reportes alertan a otras personas.'),
        if (desenlace != null) ...[
          const SizedBox(height: 16),
          _DesenlaceCard(desenlace: desenlace),
        ],
        const SizedBox(height: 16),
        _MapaView(mapa: estado.mapa),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            if (estado.pausada)
              OutlinedButton(
                key: const ValueKey('boton-reanudar'),
                onPressed: controller.reanudar,
                child: const Text('Reanudar'),
              )
            else
              OutlinedButton(
                key: const ValueKey('boton-pausar'),
                onPressed: controller.pausar,
                child: const Text('Pausar'),
              ),
            TextButton(
              key: const ValueKey('boton-salir'),
              onPressed: controller.salir,
              child: const Text('Salir de la capacitación'),
            ),
          ],
        ),
        if (controller.demo != null) ...[
          const SizedBox(height: 24),
          _PanelDemo(estado: estado),
        ],
      ],
    );
  }

  static String _mensajeFase(EstadoCapacitacion e) => switch (e.fase) {
    FaseCapacitacion.noInscrito => 'No estás inscrito.',
    FaseCapacitacion.confirmandoCorreo =>
      'Confirma tu correo con el enlace que te enviamos.',
    FaseCapacitacion.esperandoReaccion =>
      'Revisa tu correo como lo harías cualquier día.',
    FaseCapacitacion.enCurso =>
      'Tu próximo correo de práctica llegará más adelante.',
    FaseCapacitacion.pausada => 'Tu capacitación está en pausa.',
  };
}

class _DesenlaceCard extends ConsumerWidget {
  const _DesenlaceCard({required this.desenlace});

  final DesenlaceSimulacro desenlace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    final actividades = ref.watch(actividadesDelPerfilProvider).value ?? [];
    final sugeridas = actividades
        .where((a) => desenlace.modulosSugeridos.contains(a.modulo))
        .take(3)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              desenlace.titulo,
              key: const ValueKey('desenlace-titulo'),
              style: textos.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(desenlace.mensaje),
            for (final i in desenlace.indicios) Text('• ${i.nombre}'),
            if (desenlace.microcursos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Microcursos para ti', style: textos.titleSmall),
              for (final m in desenlace.microcursos) Text('«${m.titulo}»'),
            ],
            for (final a in sugeridas) ActividadTile(actividad: a),
          ],
        ),
      ),
    );
  }
}

class _MapaView extends StatelessWidget {
  const _MapaView({required this.mapa});

  final MapaIndicios mapa;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('Tus señales'),
      children: [
        for (final i in Indicio.values)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(i.nombre),
            trailing: Text(mapa.estadoDe(i).etiquetaVisible),
          ),
      ],
    );
  }
}

/// Simula lo que en producción pasa en el correo del usuario.
class _PanelDemo extends ConsumerWidget {
  const _PanelDemo({required this.estado});

  final EstadoCapacitacion estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    final controller = ref.read(capacitacionProvider.notifier);
    final correo = estado.correoActual;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Panel de demostración', style: textos.titleMedium),
            const Text('Simula lo que pasaría en tu correo.'),
            if (correo != null)
              Text(
                'Último correo: «${correo.plantilla.asunto}» '
                '(nivel ${correo.nivel.numero})',
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (estado.fase == FaseCapacitacion.confirmandoCorreo)
                  OutlinedButton(
                    key: const ValueKey('demo-confirmar'),
                    onPressed: controller.confirmarCorreoDemo,
                    child: const Text('Confirmar correo'),
                  ),
                if (estado.fase == FaseCapacitacion.esperandoReaccion) ...[
                  OutlinedButton(
                    key: const ValueKey('demo-reporto'),
                    onPressed: () => controller.simularReaccionDemo(
                      ResultadoSimulacro.reporto,
                    ),
                    child: const Text('Lo reportó'),
                  ),
                  OutlinedButton(
                    key: const ValueKey('demo-clic'),
                    onPressed: () =>
                        controller.simularReaccionDemo(ResultadoSimulacro.clic),
                    child: const Text('Hizo clic'),
                  ),
                  OutlinedButton(
                    key: const ValueKey('demo-ignoro'),
                    onPressed: controller.dejarVencerDemo,
                    child: const Text('No hizo nada'),
                  ),
                ],
                if (estado.fase == FaseCapacitacion.enCurso)
                  OutlinedButton(
                    key: const ValueKey('demo-siguiente'),
                    onPressed: controller.siguienteCorreoDemo,
                    child: const Text('Pasa una semana: siguiente correo'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
