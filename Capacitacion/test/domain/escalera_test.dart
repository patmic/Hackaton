import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('diagnóstico inicial (§11)', () {
    test('reportó sin clic: Avanzado; ignoró: Intermedio; clic: Básico', () {
      expect(
        Escalera.diagnostico(ResultadoSimulacro.reporto),
        NivelCapacitacion.avanzado,
      );
      expect(
        Escalera.diagnostico(ResultadoSimulacro.ignoro),
        NivelCapacitacion.intermedio,
      );
      expect(
        Escalera.diagnostico(ResultadoSimulacro.clic),
        NivelCapacitacion.basico,
      );
      expect(
        () => Escalera.diagnostico(ResultadoSimulacro.pendiente),
        throwsArgumentError,
      );
    });
  });

  group('escalera', () {
    test('reportó sube, ignoró se queda, clic baja, sin salirse de 1-3', () {
      expect(
        Escalera.siguienteNivel(NivelCorreo.medio, ResultadoSimulacro.reporto),
        NivelCorreo.dificil,
      );
      expect(
        Escalera.siguienteNivel(NivelCorreo.dificil, ResultadoSimulacro.reporto),
        NivelCorreo.dificil,
      );
      expect(
        Escalera.siguienteNivel(NivelCorreo.medio, ResultadoSimulacro.ignoro),
        NivelCorreo.medio,
      );
      expect(
        Escalera.siguienteNivel(NivelCorreo.medio, ResultadoSimulacro.clic),
        NivelCorreo.facil,
      );
      expect(
        Escalera.siguienteNivel(NivelCorreo.facil, ResultadoSimulacro.clic),
        NivelCorreo.facil,
      );
    });

    test('mapa de indicios: reporte → dominado, clic → para practicar', () {
      const indicios = [Indicio.i1, Indicio.i7];
      final tras = Escalera.actualizarMapa(
        const MapaIndicios(),
        indicios,
        ResultadoSimulacro.clic,
      );
      expect(tras.estadoDe(Indicio.i1), EstadoIndicio.debil);
      expect(tras.estadoDe(Indicio.i3), EstadoIndicio.sinProbar);
      final luego = Escalera.actualizarMapa(tras, [
        Indicio.i1,
      ], ResultadoSimulacro.reporto);
      expect(luego.estadoDe(Indicio.i1), EstadoIndicio.dominado);
      expect(luego.debiles, {Indicio.i7});
      expect(
        Escalera.actualizarMapa(tras, indicios, ResultadoSimulacro.ignoro),
        same(tras),
      );
    });

    test('dos reportes seguidos en nivel 3: Centinela', () {
      var seguidos = Escalera.reportesSeguidosNivel3(
        0,
        NivelCorreo.dificil,
        ResultadoSimulacro.reporto,
      );
      expect(Escalera.esCentinela(seguidos), isFalse);
      seguidos = Escalera.reportesSeguidosNivel3(
        seguidos,
        NivelCorreo.dificil,
        ResultadoSimulacro.reporto,
      );
      expect(Escalera.esCentinela(seguidos), isTrue);
      expect(
        Escalera.reportesSeguidosNivel3(
          1,
          NivelCorreo.medio,
          ResultadoSimulacro.reporto,
        ),
        0,
      );
    });
  });

  group('plantillas', () {
    test('hay un primer correo de nivel 2 para cada tipo (§11)', () {
      for (final t in TipoUsuario.values) {
        final p = Escalera.elegirPlantilla(
          plantillas: plantillasPrueba,
          tipos: {t},
          nivel: NivelCorreo.medio,
          mapa: const MapaIndicios(),
        );
        expect(p?.nivel, NivelCorreo.medio, reason: t.codigo);
      }
    });

    test('la cantidad de indicios respeta el nivel', () {
      for (final p in plantillasPrueba) {
        final n = p.indicios.length;
        switch (p.nivel) {
          case NivelCorreo.facil:
            expect(n, greaterThanOrEqualTo(4), reason: p.id);
          case NivelCorreo.medio:
            expect(n, inInclusiveRange(2, 3), reason: p.id);
          case NivelCorreo.dificil:
            expect(n, 1, reason: p.id);
        }
      }
    });

    test('el siguiente correo incluye un indicio débil o sin probar', () {
      // EX1 domina todo menos I4 (sin probar) e I7 (débil).
      var mapa = const MapaIndicios().con(
        Indicio.values,
        EstadoIndicio.dominado,
      );
      mapa = mapa.con([Indicio.i7], EstadoIndicio.debil);
      final estados = Map.of(mapa.estados)..remove(Indicio.i4);
      mapa = MapaIndicios(estados);

      final p = Escalera.elegirPlantilla(
        plantillas: plantillasPrueba,
        tipos: {TipoUsuario.ex1},
        nivel: NivelCorreo.dificil,
        mapa: mapa,
      )!;
      expect(p.indicios.any(mapa.porPracticar.contains), isTrue);
      // Entre N3-EX-enlace (I4, sin probar) y N3-EX-remitente (I7, débil),
      // prefiere el débil.
      expect(p.id, 'N3-EX-remitente');
    });

    test('prefiere las que no se enviaron', () {
      final p = Escalera.elegirPlantilla(
        plantillas: plantillasPrueba,
        tipos: {TipoUsuario.ex1},
        nivel: NivelCorreo.facil,
        mapa: const MapaIndicios(),
        yaEnviadas: {'N1-EX-bloqueo'},
      );
      expect(p?.id, 'N1-EX-premio');
    });
  });

  group('desenlace', () {
    final correo = CorreoPrueba(
      simulacroId: 's1',
      plantilla: plantillasPrueba.firstWhere((p) => p.id == 'N2-EX1-reembolso'),
      nivel: NivelCorreo.medio,
      enviadoEn: DateTime.utc(2026, 11, 26),
      venceEn: DateTime.utc(2026, 11, 26, 0, 10),
    );

    test('clic: momento enseñable con un microcurso por indicio', () {
      final d = Escalera.desenlace(correo, ResultadoSimulacro.clic, {
        TipoUsuario.ex1,
      });
      expect(d.titulo, 'Era un correo de práctica');
      // I6 → «Nadie regala…», I1 → «La prisa…», I7 → «Tus canales…».
      expect(d.microcursos, [
        Microcurso.nadieRegala,
        Microcurso.prisaEsLaTrampa,
        Microcurso.canalesOficiales,
      ]);
      expect(d.modulosSugeridos, ['M4', 'M1', 'M2']);
    });

    test('reporte: «¡Lo detectaste!»; ignorado: seguimiento con M3', () {
      expect(
        Escalera.desenlace(correo, ResultadoSimulacro.reporto, {
          TipoUsuario.ex1,
        }).titulo,
        '¡Lo detectaste!',
      );
      expect(
        Escalera.desenlace(correo, ResultadoSimulacro.ignoro, {
          TipoUsuario.ex1,
        }).modulosSugeridos,
        ['M3'],
      );
    });
  });

  group('límites de envío', () {
    final ultimo = DateTime.utc(2026, 11, 1);

    test('el primero sale ya; después, uno por semana', () {
      expect(LimitesEnvio.proximoEnvio(ahora: ultimo), isNull);
      expect(
        LimitesEnvio.proximoEnvio(
          ahora: ultimo.add(const Duration(days: 1)),
          ultimoEnvio: ultimo,
        ),
        ultimo.add(const Duration(days: 7)),
      );
      expect(
        LimitesEnvio.proximoEnvio(
          ahora: ultimo.add(const Duration(days: 7)),
          ultimoEnvio: ultimo,
        ),
        isNull,
      );
    });

    test('un Centinela recibe uno al mes', () {
      expect(
        LimitesEnvio.proximoEnvio(
          ahora: ultimo.add(const Duration(days: 8)),
          ultimoEnvio: ultimo,
          esCentinela: true,
        ),
        ultimo.add(const Duration(days: 30)),
      );
    });
  });

  test('MapaIndicios ida y vuelta a JSON, ignorando códigos desconocidos', () {
    final mapa = const MapaIndicios().con([Indicio.i2], EstadoIndicio.debil);
    final json = {...mapa.toJson(), 'I99': 'DOMINADO'};
    expect(MapaIndicios.fromJson(json).estados, {Indicio.i2: EstadoIndicio.debil});
  });

  test('los textos visibles no culpan (regla 7)', () {
    expect(EstadoIndicio.debil.etiquetaVisible, 'Para practicar');
  });
}
