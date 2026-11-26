import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/data/capacitacion_api.dart';
import 'package:capacitacion/src/data/progreso_repository.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// API que falla las primeras [fallos] veces que recibe eventos.
class _ApiIntermitente extends MockCapacitacionApi {
  _ApiIntermitente(this.fallos);

  int fallos;

  @override
  Future<void> registrarEventos(List<EventoApp> eventos) async {
    if (fallos > 0) {
      fallos--;
      throw Exception('sin red');
    }
    await super.registrarEventos(eventos);
  }
}

void main() {
  final momento = DateTime.utc(2026, 11, 26);

  Future<ProviderContainer> crear(MockCapacitacionApi api) async {
    final c = ProviderContainer(
      overrides: [
        capacitacionApiProvider.overrideWithValue(api),
        actividadRepositoryProvider.overrideWithValue(
          MemoriaActividadRepository(catalogoReal()),
        ),
        progresoRepositoryProvider.overrideWithValue(
          MemoriaProgresoRepository(),
        ),
        relojProvider.overrideWithValue(() => momento),
      ],
    );
    addTearDown(c.dispose);
    c.listen(perfilProvider, (anterior, siguiente) {});
    await c.read(sesionProvider.future);
    return c;
  }

  test('el perfil sale de la sesión (GET /api/v1/me)', () async {
    final c = await crear(MockCapacitacionApi());
    expect(c.read(perfilProvider).tipos, {TipoUsuario.ex5});

    final jubilado = sesionesDemo.firstWhere(
      (s) => s.tipos.contains(TipoUsuario.ex2),
    );
    await c.read(sesionProvider.notifier).iniciarSesionDemo(jubilado);
    final perfil = c.read(perfilProvider);
    expect(perfil.tipos, {TipoUsuario.ex2});
    expect(perfil.usaInterfazSimplificada, isTrue);
    expect(perfil.rangoEtario, RangoEtario.r65mas);
    expect(perfil.perfilConducta.etiquetaVisible, 'En aprendizaje');
  });

  test('los eventos llevan contexto anónimo y nunca datos personales', () async {
    final api = MockCapacitacionApi();
    final c = await crear(api);
    await c
        .read(registroEventosProvider)
        .registrar(
          EventoApp.decisionTomada(
            itemId: 't1',
            opcion: 'ESTAFA',
            esCorrecta: true,
            momento: momento,
          ),
        );
    final json = api.eventosRecibidos.single.toJson();
    expect(json['evento'], 'DECISION_TOMADA');
    expect(json['tipo_usuario'], ['EX5']);
    expect(json['canal'], 'APP');
    for (final prohibido in ['cedula', 'nombre', 'correo', 'id_seudonimo']) {
      expect(json.containsKey(prohibido), isFalse, reason: prohibido);
    }
  });

  test('si la API falla, el evento espera y sale con el siguiente', () async {
    final api = _ApiIntermitente(1);
    final c = await crear(api);
    final registro = c.read(registroEventosProvider);
    EventoApp evento(String id) => EventoApp.actividadIniciada(
      actividadId: id,
      modulo: 'M1',
      momento: momento,
    );

    await registro.registrar(evento('a'));
    expect(registro.pendientes, 1);
    expect(api.eventosRecibidos, isEmpty);

    await registro.registrar(evento('b'));
    expect(registro.pendientes, 0);
    expect(api.eventosRecibidos.map((e) => e.datos['actividad_id']), [
      'a',
      'b',
    ]);
  });

  test('una ronda A2 registra inicio, decisiones y cierre', () async {
    final api = MockCapacitacionApi();
    final c = await crear(api);
    final ronda = catalogoReal().firstWhere((a) => a.id == 'M1-A2-01');
    final provider = realOEstafaProvider(ronda);
    c.listen(provider, (anterior, siguiente) {});
    final controller = c.read(provider.notifier);
    for (final t in controller.tarjetas) {
      controller.responder(esEstafa: t.esEstafa);
      await controller.siguiente();
    }
    await Future<void>.delayed(Duration.zero);
    final tipos = api.eventosRecibidos.map((e) => e.tipo).toList();
    expect(tipos.first, TipoEvento.actividadIniciada);
    expect(
      tipos.where((t) => t == TipoEvento.decisionTomada),
      hasLength(controller.tarjetas.length),
    );
    expect(tipos.last, TipoEvento.actividadCompletada);
  });

  test('inscribir con un correo inválido devuelve el mensaje', () async {
    final c = await crear(MockCapacitacionApi());
    await c.read(capacitacionProvider.future);
    final error = await c
        .read(capacitacionProvider.notifier)
        .inscribir(correo: 'x');
    expect(error, 'Escribe un correo válido.');
    expect(c.read(capacitacionProvider).value?.inscrito, isFalse);
  });

  group('RoleGuard', () {
    test('externos van a la app; IN2-IN4 en la web, a la consola', () {
      const afiliado = Perfil(tipos: {TipoUsuario.ex1});
      const emisor = Perfil(tipos: {TipoUsuario.ex1, TipoUsuario.in2});
      const colaborador = Perfil(tipos: {TipoUsuario.in1});
      expect(destinoInicial(afiliado, esWeb: true), Destino.appCiudadana);
      expect(destinoInicial(emisor, esWeb: true), Destino.consolaWeb);
      expect(destinoInicial(emisor, esWeb: false), Destino.appInstitucional);
      expect(
        destinoInicial(colaborador, esWeb: true),
        Destino.appInstitucional,
      );
    });
  });
}
