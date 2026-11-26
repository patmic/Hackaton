import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('catálogo', () {
    final catalogo = catalogoReal();

    test('se parsea completo y con ids únicos', () {
      expect(catalogo, hasLength(7));
      expect(catalogo.map((c) => c.id).toSet(), hasLength(catalogo.length));
    });

    test('cubre las tres tipologías y todos los rangos', () {
      expect(
        catalogo.map((c) => c.tipologia).toSet(),
        Tipologia.values.toSet(),
      );
      expect(
        catalogo.expand((c) => c.rangos).toSet(),
        RangoEtario.values.toSet(),
      );
    });

    test('las cápsulas son breves y tienen rangos', () {
      for (final c in catalogo) {
        expect(c.duracionSegundos, lessThanOrEqualTo(180), reason: c.id);
        expect(c.rangos, isNotEmpty, reason: c.id);
        expect(c.mensajeClave, isNotEmpty, reason: c.id);
      }
    });

    test('las cápsulas QUIZ traen preguntas', () {
      for (final c in catalogo.where((c) => c.formato == FormatoCapsula.quiz)) {
        expect(c.tieneQuiz, isTrue, reason: c.id);
      }
    });
  });

  group('enums', () {
    test('códigos válidos', () {
      expect(Tipologia.desdeCodigo('t2'), Tipologia.t2);
      expect(RangoEtario.desdeCodigo('65+'), RangoEtario.r65mas);
      expect(Semaforo.desdeCodigo('rojo'), Semaforo.rojo);
    });

    test('códigos inválidos lanzan FormatException', () {
      expect(() => Tipologia.desdeCodigo('T9'), throwsFormatException);
      expect(() => RangoEtario.desdeCodigo('70'), throwsFormatException);
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
