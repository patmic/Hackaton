import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/data/capacitacion_api.dart';
import 'package:capacitacion/src/data/observador_api.dart';
import 'package:capacitacion/src/data/progreso_repository.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Radar Phishing simulado: guarda lo que recibe y puede fallar.
class _RadarFalso implements ObservadorApi {
  final recibidas = <Map<String, dynamic>>[];
  final borradas = <String>[];
  ObservadorNoDisponible? falla;
  int planesPedidos = 0;

  @override
  Future<void> registrar(List<Map<String, dynamic>> observaciones) async {
    if (falla != null) throw falla!;
    recibidas.addAll(observaciones);
  }

  @override
  Future<PlanPersonalizado> plan(
    String idSeudonimo, {
    Set<TipoUsuario> tipos = const {},
    RangoEtario? rangoEtario,
  }) async {
    if (falla != null) throw falla!;
    planesPedidos++;
    return PlanPersonalizado(
      idSeudonimo: idSeudonimo,
      origen: OrigenPlan.servidor,
      observaciones: recibidas.length,
    );
  }

  @override
  Future<void> borrar(String idSeudonimo) async {
    if (falla != null) throw falla!;
    borradas.add(idSeudonimo);
  }
}

void main() {
  final ahora = DateTime.utc(2026, 11, 27, 12);
  const idInicial = 'dispositivo0123456789abcdef';

  late MemoriaAlmacenObservador almacen;
  late _RadarFalso radar;

  ProviderContainer crear({bool conServidor = true}) {
    almacen = MemoriaAlmacenObservador(
      const DatosObservador(idSeudonimo: idInicial),
    );
    radar = _RadarFalso();
    final c = ProviderContainer(
      overrides: [
        almacenObservadorProvider.overrideWithValue(almacen),
        observadorApiProvider.overrideWithValue(conServidor ? radar : null),
        actividadRepositoryProvider.overrideWithValue(
          MemoriaActividadRepository(catalogoReal()),
        ),
        progresoRepositoryProvider.overrideWithValue(
          MemoriaProgresoRepository(),
        ),
        relojProvider.overrideWithValue(() => ahora),
      ],
    );
    addTearDown(c.dispose);
    // Riverpod 3 pausa lo que nadie escucha: se escucha como en la app.
    c.listen(perfilProvider, (_, _) {});
    c.listen(planPersonalizadoProvider, (_, _) {});
    c.listen(recomendacionesProvider, (_, _) {});
    return c;
  }

  ObservacionConducta fallo(Indicio i) => ObservacionConducta.decision(
    actividadId: 'M1-A2-01',
    itemId: 'M1-A2-01-${i.codigo}',
    esEstafa: true,
    acerto: false,
    indicios: [i],
    momento: ahora,
  );

  test('aprende en el dispositivo y no envía nada sin permiso', () async {
    final c = crear();
    await c.read(observadorProvider.notifier).observar(fallo(Indicio.i3));
    await c.read(observadorProvider.notifier).observar(fallo(Indicio.i3));

    expect(almacen.datos.observaciones, hasLength(2));
    expect(radar.recibidas, isEmpty);
    final plan = await c.read(planPersonalizadoProvider.future);
    expect(plan.origen, OrigenPlan.dispositivo);
    expect(plan.debiles, {Indicio.i3});
  });

  test('al aceptar compartir envía todo con su código y su tipo', () async {
    final c = crear();
    final obs = c.read(observadorProvider.notifier);
    await obs.observar(fallo(Indicio.i3));
    await obs.compartir(true);
    await obs.observar(fallo(Indicio.i6));

    expect(radar.recibidas, hasLength(2));
    expect(radar.recibidas.first, containsPair('id_seudonimo', idInicial));
    expect(radar.recibidas.first, containsPair('tipos', ['EX5']));
    expect(radar.recibidas.first, containsPair('tipo', 'DECISION'));
    expect(almacen.datos.pendientes, isEmpty);
    // Con todo enviado, el plan viene del Radar Phishing.
    final plan = await c.read(planPersonalizadoProvider.future);
    expect(plan.origen, OrigenPlan.servidor);
    expect(radar.planesPedidos, greaterThan(0));
  });

  test('sin conexión guarda y reintenta; el plan se calcula aquí', () async {
    final c = crear();
    final obs = c.read(observadorProvider.notifier);
    await obs.compartir(true);
    radar.falla = const ObservadorNoDisponible('sin red');
    await obs.observar(fallo(Indicio.i3));
    expect(almacen.datos.pendientes, hasLength(1));
    expect(
      (await c.read(planPersonalizadoProvider.future)).origen,
      OrigenPlan.dispositivo,
    );

    radar.falla = null;
    await obs.observar(fallo(Indicio.i8));
    expect(radar.recibidas, hasLength(2));
    expect(almacen.datos.pendientes, isEmpty);
  });

  test('un lote rechazado (4xx) no frena a los siguientes', () async {
    final c = crear();
    final obs = c.read(observadorProvider.notifier);
    await obs.compartir(true);
    radar.falla = const ObservadorNoDisponible('HTTP 422', 422);
    await obs.observar(fallo(Indicio.i3));
    expect(almacen.datos.pendientes, isEmpty);

    radar.falla = const ObservadorNoDisponible('HTTP 429', 429);
    await obs.observar(fallo(Indicio.i3));
    expect(almacen.datos.pendientes, hasLength(1), reason: '429 se reintenta');
  });

  test('un ítem estafa sin indicios no se guarda', () async {
    final c = crear();
    await c
        .read(observadorProvider.notifier)
        .observar(
          ObservacionConducta.decision(
            actividadId: 'M1-A2-01',
            itemId: 'x',
            esEstafa: true,
            acerto: true,
            indicios: const [],
            momento: ahora,
          ),
        );
    expect(almacen.datos.observaciones, isEmpty);
  });

  test('borrar mis prácticas borra en el Radar y cambia el código', () async {
    final c = crear();
    final obs = c.read(observadorProvider.notifier);
    await obs.compartir(true);
    await obs.observar(fallo(Indicio.i3));
    await obs.borrarDatos();

    expect(radar.borradas, [idInicial]);
    expect(almacen.datos.observaciones, isEmpty);
    expect(almacen.datos.idSeudonimo, isNot(idInicial));
    expect(almacen.datos.idSeudonimo, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(almacen.datos.compartir, isTrue, reason: 'su elección se respeta');
  });

  test('sin servidor configurado todo funciona en el dispositivo', () async {
    final c = crear(conServidor: false);
    final obs = c.read(observadorProvider.notifier);
    await obs.compartir(true);
    await obs.observar(fallo(Indicio.i3));
    expect(
      (await c.read(planPersonalizadoProvider.future)).origen,
      OrigenPlan.dispositivo,
    );
    await obs.borrarDatos();
    expect(almacen.datos.observaciones, isEmpty);
  });

  test('las prácticas reordenan las recomendaciones', () async {
    final c = crear();
    final antes = await c.read(recomendacionesProvider.future);
    final obs = c.read(observadorProvider.notifier);
    // Se le pasa varias veces el QR que lleva a un sitio no verificable.
    for (var k = 0; k < 3; k++) {
      await obs.observar(fallo(Indicio.i11));
    }
    final despues = await c.read(recomendacionesProvider.future);
    bool trabajaI11(Recomendacion r) =>
        r.motivos.contains('Te conviene practicar: ${Indicio.i11.nombre}');
    expect(antes.where(trabajaI11), isEmpty);
    expect(despues.where(trabajaI11), isNotEmpty);
    expect(
      despues.map((r) => r.actividad.id),
      isNot(antes.map((r) => r.actividad.id)),
    );
  });

  group('«Quiero capacitarme» (mock)', () {
    final afiliado = sesionesDemo.firstWhere(
      (s) => s.tipos.length == 1 && s.tipos.contains(TipoUsuario.ex1),
    );
    final consentimiento = Consentimiento(
      version: Consentimiento.versionActual,
      aceptadoEn: ahora,
    );

    Future<String?> segundoCorreo(MapaIndicios? observado) async {
      final api = MockCapacitacionApi(
        sesion: afiliado,
        reloj: () => ahora,
        mapaObservado: () => observado,
      );
      await api.inscribir(consentimiento: consentimiento);
      api.simularReaccion(ResultadoSimulacro.ignoro);
      api.pasarTiempo(LimitesEnvio.unoPorSemana);
      api.enviarSiguiente();
      return api.estado.correoActual?.plantilla.id;
    }

    test(
      'el siguiente correo trabaja lo que le costó en las actividades',
      () async {
        expect(await segundoCorreo(null), 'N2-EX-clave');
        expect(
          await segundoCorreo(
            const MapaIndicios({Indicio.i9: EstadoIndicio.debil}),
          ),
          'N2-EX-turno-qr',
        );
      },
    );

    test('el primer correo sigue siendo el del tipo (§11)', () async {
      final api = MockCapacitacionApi(
        sesion: afiliado,
        reloj: () => ahora,
        mapaObservado: () => MapaIndicios({
          for (final i in Indicio.values) i: EstadoIndicio.dominado,
        }),
      );
      final e = await api.inscribir(consentimiento: consentimiento);
      expect(e.correoActual?.plantilla.id, 'N2-EX1-reembolso');
    });

    test('cada reacción llega al observador', () async {
      final c = crear();
      final api = c.read(capacitacionApiProvider) as MockCapacitacionApi;
      api.iniciarSesion(afiliado);
      await api.inscribir(consentimiento: consentimiento);
      api.simularReaccion(ResultadoSimulacro.clic);
      // La observación se guarda en segundo plano.
      for (var k = 0; k < 50 && almacen.datos.observaciones.isEmpty; k++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      final o = almacen.datos.observaciones.single;
      expect(o.tipo, TipoObservacion.simulacro);
      expect(o.resultado, ResultadoSimulacro.clic);
      expect(o.plantillaId, 'N2-EX1-reembolso');
      expect(o.indiciosImplicitos, [Indicio.i2]);
    });
  });
}
