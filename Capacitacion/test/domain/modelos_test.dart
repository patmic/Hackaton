import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('catálogo de actividades', () {
    final catalogo = catalogoReal();
    final porId = {for (final a in catalogo) a.id: a};
    final variantes = {
      for (final a in catalogo)
        if (a.varianteEx2 != null) a.varianteEx2!,
    };

    test('se parsea completo y con ids únicos', () {
      expect(catalogo, hasLength(12));
      expect(porId, hasLength(catalogo.length));
    });

    test('cubre las seis tipologías', () {
      expect(
        catalogo.map((a) => a.tipologia).whereType<Tipologia>().toSet(),
        Tipologia.values.toSet(),
      );
    });

    test('cada actividad es breve y tiene paso 4R y mensaje clave', () {
      for (final a in catalogo) {
        expect(a.duracionSegundos, inInclusiveRange(30, 300), reason: a.id);
        expect(a.pasos4r, isNotEmpty, reason: a.id);
        expect(a.mensajeClave, isNotEmpty, reason: a.id);
      }
    });

    test('módulo, mecánica y tipos son coherentes con §10.2', () {
      for (final a in catalogo) {
        final m = a.moduloInfo;
        if (!variantes.contains(a.id)) {
          expect(m.mecanicas, contains(a.mecanica), reason: a.id);
        }
        if (m.tipos.isNotEmpty) {
          expect(m.tipos.containsAll(a.tipos), isTrue, reason: a.id);
        }
      }
    });

    test('los indicios del contenido están en la actividad', () {
      for (final a in catalogo) {
        expect(
          a.indicios.toSet().containsAll(a.contenido.indiciosUsados),
          isTrue,
          reason: a.id,
        );
      }
    });

    test('cada mecánica trae su contenido', () {
      for (final a in catalogo) {
        switch (a.contenido) {
          case final ContenidoCazaSenal c:
            expect(c.senales, isNotEmpty, reason: a.id);
            for (final s in c.senales) {
              expect(s.zona.existeEn(c.mensaje), isTrue, reason: a.id);
            }
          case final ContenidoRealOEstafa c:
            expect(c.tarjetas, hasLength(5), reason: a.id);
          case final ContenidoBandeja c:
            expect(c.mensajes, hasLength(5), reason: a.id);
          case final ContenidoVerifica c:
            expect(
              c.casos.every((k) => k.mensaje.codigoVerificacion != null),
              isTrue,
              reason: a.id,
            );
          case final ContenidoAudioReto c:
            expect(c.opciones, hasLength(2), reason: a.id);
            expect(c.opciones.where((o) => o.esCorrecta), hasLength(1));
          case ContenidoPendiente():
            fail('${a.id} usa una mecánica sin componente');
        }
      }
    });

    test('la variante EX2 existe, es audio-reto y es para EX2', () {
      for (final id in variantes) {
        final v = porId[id];
        expect(v, isNotNull, reason: id);
        expect(v!.mecanica, Mecanica.a7);
        expect(v.tipos, contains(TipoUsuario.ex2));
      }
    });
  });

  group('elegibilidad', () {
    final catalogo = catalogoReal();
    List<String> idsPara(Perfil p) => [
      for (final a in catalogo)
        if (a.elegiblePara(p)) a.id,
    ];

    test('un EX2 ve la versión en audio y no la original', () {
      final ids = idsPara(const Perfil(tipos: {TipoUsuario.ex2}));
      expect(ids, contains('M1-A7-01'));
      expect(ids, isNot(contains('M1-A1-01')));
      expect(ids, contains('M7-A7-01'));
    });

    test('un EX1 no ve las actividades exclusivas de EX2', () {
      final ids = idsPara(const Perfil(tipos: {TipoUsuario.ex1}));
      expect(ids, contains('M1-A1-01'));
      expect(ids, isNot(contains('M1-A7-01')));
      expect(ids, isNot(contains('M7-A7-01')));
    });

    test('sin sesión (EX5) solo ve lo de su módulo', () {
      final ids = idsPara(const Perfil());
      expect(ids, containsAll(['M1-A1-01', 'M3-A3-01', 'M6-A1-01']));
      expect(ids, isNot(contains('M2-A6-01')));
      expect(ids, isNot(contains('M4-A2-01')));
    });

    test('M14 se abre solo a Centinelas', () {
      final m14 = actividad('x', modulo: 'M14', mecanica: Mecanica.a4);
      expect(m14.elegiblePara(const Perfil(tipos: {TipoUsuario.ex1})), isFalse);
      expect(
        m14.elegiblePara(
          const Perfil(
            tipos: {TipoUsuario.ex1},
            perfilConducta: PerfilConducta.centinela,
          ),
        ),
        isTrue,
      );
    });
  });

  group('enums', () {
    test('códigos válidos', () {
      expect(Tipologia.desdeCodigo('t2'), Tipologia.t2);
      expect(RangoEtario.desdeCodigo('65+'), RangoEtario.r65mas);
      expect(Semaforo.desdeCodigo('rojo'), Semaforo.rojo);
      expect(Indicio.desdeCodigo('i11'), Indicio.i11);
      expect(TipoUsuario.desdeCodigo('ex2'), TipoUsuario.ex2);
      expect(Mecanica.desdeCodigo('A1'), Mecanica.a1);
      expect(Mecanica.desdeCodigo('a6_verifica_3_pasos'), Mecanica.a6);
      expect(Paso4R.desdeCodigo('replicar'), Paso4R.replicar);
      expect(Modulo.porCodigo('m13').minutos, 30);
    });

    test('códigos inválidos lanzan FormatException', () {
      expect(() => Tipologia.desdeCodigo('T9'), throwsFormatException);
      expect(() => RangoEtario.desdeCodigo('70'), throwsFormatException);
      expect(() => Indicio.desdeCodigo('I12'), throwsFormatException);
      expect(() => TipoUsuario.desdeCodigo('EX9'), throwsFormatException);
      expect(() => Mecanica.desdeCodigo('A10'), throwsFormatException);
      expect(() => Modulo.porCodigo('M15'), throwsFormatException);
    });

    test('hay 11 indicios, 9 tipos, 9 mecánicas y 14 módulos', () {
      expect(Indicio.values, hasLength(11));
      expect(TipoUsuario.values, hasLength(9));
      expect(Mecanica.values, hasLength(9));
      expect(catalogoModulos.map((m) => m.codigo).toSet(), hasLength(14));
    });

    test('«Expuesto» nunca se muestra al usuario (regla 7)', () {
      expect(PerfilConducta.expuesto.etiquetaVisible, 'En aprendizaje');
      for (final p in PerfilConducta.values) {
        expect(p.etiquetaVisible, isNot(contains('Expuesto')));
      }
    });
  });

  group('Perfil', () {
    test('sin sesión es EX5, externo y sin rango', () {
      const p = Perfil();
      expect(p.tipos, {TipoUsuario.ex5});
      expect(p.zona, Zona.externa);
      expect(p.sinRango, isTrue);
      expect(p.usaInterfazSimplificada, isFalse);
    });

    test('colaborador que también es afiliado está en la zona interna', () {
      const p = Perfil(tipos: {TipoUsuario.ex1, TipoUsuario.in1});
      expect(p.zona, Zona.interna);
    });

    test('la interfaz simplificada depende del tipo, no de la edad', () {
      expect(
        const Perfil(rangoEtario: RangoEtario.r65mas).usaInterfazSimplificada,
        isFalse,
      );
      expect(
        const Perfil(tipos: {TipoUsuario.ex2}).usaInterfazSimplificada,
        isTrue,
      );
    });

    test('copyWith permite borrar el rango', () {
      const p = Perfil(rangoEtario: RangoEtario.r30a49);
      expect(p.conRango(null).sinRango, isTrue);
      expect(p.copyWith(esCuidador: true).rangoEtario, RangoEtario.r30a49);
    });
  });

  group('ZonaMensaje', () {
    const m = MensajeSimulado(
      remitente: 'a@b.c',
      asunto: 's',
      cuerpo: 'uno\n\ndos',
      boton: 'Cobrar',
    );

    test('lee las zonas del JSON', () {
      expect(ZonaMensaje.desdeCodigo('cuerpo:2').parrafo, 2);
      expect(ZonaMensaje.desdeCodigo('BOTON').tipo, TipoZona.boton);
      expect(ZonaMensaje.desdeCodigo('cuerpo:2').codigo, 'cuerpo:2');
    });

    test('zonas inválidas lanzan FormatException', () {
      expect(() => ZonaMensaje.desdeCodigo('pie'), throwsFormatException);
      expect(() => ZonaMensaje.desdeCodigo('cuerpo:0'), throwsFormatException);
      expect(() => ZonaMensaje.desdeCodigo('asunto:1'), throwsFormatException);
    });

    test('comprueba si la zona existe en el mensaje', () {
      expect(m.parrafos, ['uno', 'dos']);
      expect(ZonaMensaje.desdeCodigo('cuerpo:2').existeEn(m), isTrue);
      expect(ZonaMensaje.desdeCodigo('cuerpo:3').existeEn(m), isFalse);
      expect(ZonaMensaje.desdeCodigo('boton').existeEn(m), isTrue);
      expect(ZonaMensaje.desdeCodigo('adjunto').existeEn(m), isFalse);
      expect(ZonaMensaje.desdeCodigo('qr').existeEn(m), isFalse);
    });
  });

  group('Progreso', () {
    test('guarda el mejor puntaje y marca completada', () {
      final p = const Progreso()
          .registrarPuntaje('a', 0.5)
          .registrarPuntaje('a', 0.25)
          .registrarPuntaje('a', 1);
      expect(p.mejoresPuntajes['a'], 1);
      expect(p.estaCompletada('a'), isTrue);
    });

    test('ida y vuelta a JSON', () {
      final p = const Progreso()
          .marcarCompletada('x')
          .registrarPuntaje('y', .5);
      final copia = Progreso.fromJson(p.toJson());
      expect(copia.completadas, {'x', 'y'});
      expect(copia.mejoresPuntajes, {'y': .5});
    });

    test('avance', () {
      expect(const Progreso().avance(0), 0);
      expect(const Progreso().marcarCompletada('a').avance(4), .25);
    });
  });

  test('ResultadoActividad calcula el puntaje', () {
    expect(
      const ResultadoActividad(actividadId: 'a', aciertos: 0, total: 0).puntaje,
      0,
    );
    expect(
      const ResultadoActividad(actividadId: 'a', aciertos: 3, total: 4).puntaje,
      .75,
    );
  });

  test('SolicitudVerificacion vacía y su JSON', () {
    const vacia = SolicitudVerificacion(
      canal: CanalVerificacion.app,
      hashRecibido: '  ',
    );
    expect(vacia.estaVacia, isTrue);
    const s = SolicitudVerificacion(
      canal: CanalVerificacion.botWhatsapp,
      remitenteReportado: 'x@y.com',
      rangoEtario: RangoEtario.r65mas,
      tipologiaPercibida: Tipologia.t2,
    );
    expect(s.toJson(), {
      'hash_recibido': null,
      'remitente_reportado': 'x@y.com',
      'tipologia_percibida': 'T2',
      'rango_etario_usuario': '65+',
      'canal': 'BOT_WHATSAPP',
    });
  });
}
