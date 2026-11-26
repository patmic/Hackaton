import 'package:capacitacion/src/application/providers.dart';
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/data/nucleo_api.dart';
import 'package:capacitacion/src/data/progreso_repository.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late MockNucleoApi api;

  /// Espera a que termine el `build()` del controlador, para que no pise el
  /// estado que deja cada prueba.
  Future<ProviderContainer> crear({bool sinConexion = false}) async {
    api = MockNucleoApi(
      reloj: () => DateTime.utc(2026, 11, 27),
      sinConexion: sinConexion,
    );
    final container = ProviderContainer(
      overrides: [
        actividadRepositoryProvider.overrideWithValue(
          MemoriaActividadRepository(catalogoReal()),
        ),
        progresoRepositoryProvider.overrideWithValue(
          MemoriaProgresoRepository(),
        ),
        nucleoApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);
    container.listen(verificacionProvider, (anterior, siguiente) {});
    await container.read(verificacionProvider.future);
    return container;
  }

  VerificacionController controller(ProviderContainer c) =>
      c.read(verificacionProvider.notifier);

  VerificacionEstado? estado(ProviderContainer c) =>
      c.read(verificacionProvider).value;

  test('código auténtico: VERDE pendiente de comparar', () async {
    final c = await crear();
    await controller(c).verificar(
      codigo: hashValido,
      origen: OrigenCodigo.appLink,
    );
    final e = estado(c)!;
    expect(e.resultado.semaforo, Semaforo.verde);
    expect(e.faltaComparar, isTrue);
  });

  test('si no coincide, el sello fue copiado: ROJO con sugerencia T2', () async {
    final c = await crear();
    await controller(c).verificar(codigo: hashValido);
    await controller(c).confirmarCoincidencia(coincide: false);
    final e = estado(c)!;
    expect(e.resultado.estado, 'SELLO_COPIADO');
    expect(e.resultado.semaforo, Semaforo.rojo);
    expect(e.faltaComparar, isFalse);
    expect(e.actividad?.tipologia, Tipologia.t2);
  });

  test('si coincide, queda confirmado y sigue VERDE', () async {
    final c = await crear();
    await controller(c).verificar(codigo: hashValido);
    await controller(c).confirmarCoincidencia(coincide: true);
    final e = estado(c)!;
    expect(e.resultado.semaforo, Semaforo.verde);
    expect(e.coincidenciaConfirmada, isTrue);
    expect(e.faltaComparar, isFalse);
  });

  test('código inexistente: ROJO con microcurso del indicio', () async {
    final c = await crear();
    await controller(c).verificar(codigo: 'b' * 64);
    final e = estado(c)!;
    expect(e.resultado.semaforo, Semaforo.rojo);
    // El análisis simulado explica I7 → «Tus canales oficiales».
    expect(e.microcurso, Microcurso.canalesOficiales);
  });

  test('código mal formado: AMARILLO sin consultar al servidor', () async {
    final c = await crear();
    await controller(c).verificar(codigo: 'no-es-un-codigo');
    expect(estado(c)!.resultado.estado, 'CODIGO_INVALIDO');
    expect(api.consultas, 0);
  });

  test('sin conexión: AMARILLO, nunca VERDE', () async {
    final c = await crear(sinConexion: true);
    await controller(c).verificar(codigo: hashValido);
    final e = estado(c)!;
    expect(e.resultado.semaforo, Semaforo.amarillo);
    expect(e.resultado.estado, 'SIN_CONEXION');
  });

  test('sin código muestra un aviso', () async {
    final c = await crear();
    await controller(c).verificar(codigo: '   ');
    final valor = c.read(verificacionProvider);
    expect(valor.hasError, isTrue);
    expect(
      (valor.error! as FormatException).message,
      'Ingresa el código de verificación.',
    );
  });

  test('el rango del perfil viaja en la solicitud, sin datos personales', () {
    const s = SolicitudVerificacion(
      canal: CanalVerificacion.app,
      hashRecibido: hashValido,
      rangoEtario: RangoEtario.r30a49,
    );
    final campos = s.uriDiagrama(Uri.parse('https://n.ejemplo')).queryParameters;
    expect(campos.keys, isNot(contains('cedula')));
    expect(campos['rango_etario'], '30-49');
  });
}
