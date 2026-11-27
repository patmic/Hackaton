import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Microcurso por indicio (§11)', () {
    test('todos los indicios tienen microcurso', () {
      for (final i in Indicio.values) {
        expect(() => Microcurso.paraIndicio(i), returnsNormally);
      }
    });

    test('tabla de CLAUDE.md', () {
      expect(Microcurso.paraIndicio(Indicio.i1), Microcurso.prisaEsLaTrampa);
      expect(Microcurso.paraIndicio(Indicio.i2), Microcurso.canalesOficiales);
      expect(Microcurso.paraIndicio(Indicio.i7), Microcurso.canalesOficiales);
      expect(Microcurso.paraIndicio(Indicio.i3), Microcurso.nuncaTuClave);
      expect(Microcurso.paraIndicio(Indicio.i9), Microcurso.nuncaTuClave);
      expect(Microcurso.paraIndicio(Indicio.i4), Microcurso.aDondeLleva);
      expect(Microcurso.paraIndicio(Indicio.i6), Microcurso.nadieRegala);
      expect(Microcurso.paraIndicio(Indicio.i10), Microcurso.nadieRegala);
      expect(Microcurso.paraIndicio(Indicio.i11), Microcurso.paginaDelQr);
    });

    test('I8 va a M7 para EX2 y a M4 para los demás', () {
      final m = Microcurso.paraIndicio(Indicio.i8);
      expect(m.moduloPara({TipoUsuario.ex2}), 'M7');
      expect(m.moduloPara({TipoUsuario.ex1}), 'M4');
    });

    test('I5 va a M11 para internos y a M8 o M9 para externos', () {
      final m = Microcurso.paraIndicio(Indicio.i5);
      expect(m.moduloPara({TipoUsuario.in1, TipoUsuario.ex1}), 'M11');
      expect(m.moduloPara({TipoUsuario.ex3}), 'M8');
      expect(m.moduloPara({TipoUsuario.ex4}), 'M9');
    });
  });

  group('Rutas por tipo (§10.4)', () {
    test('arranque de cada tipo', () {
      expect(Ruta.para(TipoUsuario.ex1).arranque, ['M1', 'M2', 'M3']);
      expect(Ruta.para(TipoUsuario.ex2).arranque, ['M1', 'M7']);
      expect(Ruta.para(TipoUsuario.ex3).arranque, ['M1', 'M2', 'M8']);
      expect(Ruta.para(TipoUsuario.ex4).arranque, ['M1', 'M2', 'M9']);
      expect(Ruta.para(TipoUsuario.ex5).arranque, ['M1']);
      expect(Ruta.para(TipoUsuario.in1).arranque, ['M1', 'M3', 'M11']);
      expect(Ruta.para(TipoUsuario.in2).arranque, ['M11', 'M12']);
      expect(Ruta.para(TipoUsuario.in4).ritmo, Ritmo.semestral);
    });

    test('los módulos de las rutas existen', () {
      for (final t in TipoUsuario.values) {
        final ruta = Ruta.para(t);
        final refuerzo = ruta.refuerzo(esCuidador: true);
        for (final m in [...ruta.arranque, ...refuerzo]) {
          expect(() => Modulo.porCodigo(m), returnsNormally, reason: t.codigo);
        }
      }
    });

    test('EX1 refuerza según el ataque activo', () {
      final ruta = Ruta.para(TipoUsuario.ex1);
      expect(ruta.refuerzo(tipologiaAtacada: Tipologia.t2), ['M4']);
      expect(ruta.refuerzo(tipologiaAtacada: Tipologia.t3), ['M5']);
      expect(ruta.refuerzo(tipologiaAtacada: Tipologia.t1), ['M6']);
      expect(ruta.refuerzo(), ['M4', 'M5', 'M6']);
    });

    test('EX2 suma M4 si hay campaña T2', () {
      final ruta = Ruta.para(TipoUsuario.ex2);
      expect(ruta.refuerzo(), ['M7']);
      expect(ruta.refuerzo(tipologiaAtacada: Tipologia.t2), ['M7', 'M4']);
    });

    test('EX5 recibe M10 solo si verifica por otra persona', () {
      final ruta = Ruta.para(TipoUsuario.ex5);
      expect(ruta.refuerzo(), isEmpty);
      expect(ruta.refuerzo(esCuidador: true), ['M10']);
    });
  });

  group('PlanCapacitacion', () {
    test('junta las rutas de varios tipos sin repetir', () {
      final plan = PlanCapacitacion.para(
        const Perfil(tipos: {TipoUsuario.in1, TipoUsuario.ex1}),
      );
      expect(plan.arranque, ['M1', 'M2', 'M3', 'M11']);
      expect(plan.refuerzo, ['M4', 'M5', 'M6', 'M11']);
    });

    test('un Centinela tiene acceso a M14', () {
      final plan = PlanCapacitacion.para(
        const Perfil(
          tipos: {TipoUsuario.ex1},
          perfilConducta: PerfilConducta.centinela,
        ),
        tipologiaAtacada: Tipologia.t3,
      );
      expect(plan.refuerzo, ['M5', 'M14']);
    });
  });
}
