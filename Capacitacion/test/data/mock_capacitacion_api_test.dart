import 'package:capacitacion/src/data/capacitacion_api.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final afiliado = sesionesDemo.firstWhere(
    (s) => s.tipos.length == 1 && s.tipos.contains(TipoUsuario.ex1),
  );
  final consentimiento = Consentimiento(
    version: Consentimiento.versionActual,
    aceptadoEn: DateTime.utc(2026, 11, 26),
  );

  MockCapacitacionApi crear(SesionUsuario sesion) => MockCapacitacionApi(
    sesion: sesion,
    reloj: () => DateTime.utc(2026, 11, 26, 10),
  );

  test('con cuenta: inscribir envía el correo de nivel 2 del tipo', () async {
    final api = crear(afiliado);
    final e = await api.inscribir(consentimiento: consentimiento);
    expect(e.fase, FaseCapacitacion.esperandoReaccion);
    expect(e.correoActual?.plantilla.id, 'N2-EX1-reembolso');
    expect(e.correoActual?.nivel, NivelCorreo.medio);
    expect(
      e.correoActual?.venceEn,
      DateTime.utc(2026, 11, 26, 10, 10),
      reason: 'ventana de 10 minutos en la demo',
    );
  });

  test('sin cuenta: pide correo válido y confirma con doble opt-in', () async {
    final api = crear(SesionUsuario.sinCuenta);
    await expectLater(
      api.inscribir(consentimiento: consentimiento, correo: 'sin-arroba'),
      throwsFormatException,
    );
    final e = await api.inscribir(
      consentimiento: consentimiento,
      correo: 'persona@practica.ejemplo',
    );
    expect(e.fase, FaseCapacitacion.confirmandoCorreo);
    final confirmado = api.confirmarCorreo();
    expect(confirmado.fase, FaseCapacitacion.esperandoReaccion);
    expect(confirmado.correoActual?.plantilla.id, 'N2-EX5-certificado');
  });

  test('clic: nivel Básico, baja a nivel 1 y marca los indicios', () async {
    final api = crear(afiliado);
    await api.inscribir(consentimiento: consentimiento);
    final e = api.simularReaccion(ResultadoSimulacro.clic);
    expect(e.fase, FaseCapacitacion.enCurso);
    expect(e.nivelInicial, NivelCapacitacion.basico);
    expect(e.nivelCorreo, NivelCorreo.facil);
    expect(e.mapa.estadoDe(Indicio.i6), EstadoIndicio.debil);
    expect(e.ultimoDesenlace?.microcursos, isNotEmpty);
  });

  test('reportar después de un clic no cambia el nivel inicial', () async {
    final api = crear(afiliado);
    await api.inscribir(consentimiento: consentimiento);
    api.simularReaccion(ResultadoSimulacro.clic);
    final e = api.simularReaccion(ResultadoSimulacro.reporto);
    expect(e.nivelInicial, NivelCapacitacion.basico);
  });

  test('si vence la ventana, queda IGNORO: Intermedio', () async {
    final api = crear(afiliado);
    await api.inscribir(consentimiento: consentimiento);
    expect(
      api.pasarTiempo(const Duration(minutes: 5)).fase,
      FaseCapacitacion.esperandoReaccion,
    );
    final e = api.pasarTiempo(const Duration(minutes: 6));
    expect(e.correoActual?.resultado, ResultadoSimulacro.ignoro);
    expect(e.nivelInicial, NivelCapacitacion.intermedio);
  });

  test('límites: nunca dos en 48 h, uno por semana', () async {
    final api = crear(afiliado);
    await api.inscribir(consentimiento: consentimiento);
    api.simularReaccion(ResultadoSimulacro.reporto);
    expect(api.enviarSiguiente(), isFalse);
    api.pasarTiempo(const Duration(days: 3));
    expect(api.enviarSiguiente(), isFalse);
    api.pasarTiempo(const Duration(days: 4));
    expect(api.enviarSiguiente(), isTrue);
    final e = api.estado;
    expect(e.correoActual?.nivel, NivelCorreo.dificil);
    // El siguiente trae al menos un indicio que no domina.
    expect(
      e.correoActual!.plantilla.indicios.any(e.mapa.porPracticar.contains),
      isTrue,
    );
  });

  test('en pausa no se envía; al reanudar vuelve a su fase', () async {
    final api = crear(afiliado);
    await api.inscribir(consentimiento: consentimiento);
    api.simularReaccion(ResultadoSimulacro.ignoro);
    await api.pausar();
    api.pasarTiempo(const Duration(days: 8));
    expect(api.enviarSiguiente(), isFalse);
    final e = await api.reanudar();
    expect(e.fase, FaseCapacitacion.enCurso);
    expect(api.enviarSiguiente(), isTrue);
  });

  test('dos reportes seguidos en nivel 3: Centinela, uno al mes', () async {
    final api = crear(afiliado);
    await api.inscribir(consentimiento: consentimiento);
    api.simularReaccion(ResultadoSimulacro.reporto); // nivel 2 → 3
    for (var i = 0; i < 2; i++) {
      api.pasarTiempo(const Duration(days: 7));
      expect(api.enviarSiguiente(), isTrue);
      expect(api.estado.correoActual?.nivel, NivelCorreo.dificil);
      api.simularReaccion(ResultadoSimulacro.reporto);
    }
    expect(api.estado.esCentinela, isTrue);
    api.pasarTiempo(const Duration(days: 7));
    expect(api.enviarSiguiente(), isFalse);
  });

  test('salir borra la inscripción', () async {
    final api = crear(afiliado);
    await api.inscribir(consentimiento: consentimiento);
    final e = await api.salir();
    expect(e.inscrito, isFalse);
  });

  test('guarda los eventos recibidos', () async {
    final api = crear(afiliado);
    await api.registrarEventos([
      EventoApp.actividadIniciada(
        actividadId: 'M1-A1-01',
        modulo: 'M1',
        momento: DateTime.utc(2026),
      ),
    ]);
    expect(api.eventosRecibidos.single.tipo, TipoEvento.actividadIniciada);
  });
}
