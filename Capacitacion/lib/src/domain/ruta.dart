import 'tipo_usuario.dart';
import 'tipologia.dart';

/// Ritmo base de refuerzo (CLAUDE.md §10.4).
enum Ritmo {
  semanal('Semanal'),
  cadaDosSemanas('Cada 2 semanas'),
  mensual('Mensual'),
  porCampania('Por campaña'),
  trimestral('Trimestral'),
  semestral('Semestral'),
  opcional('Opcional');

  const Ritmo(this.etiqueta);

  final String etiqueta;
}

/// Ruta de capacitación de un tipo de usuario (CLAUDE.md §10.4).
class Ruta {
  const Ruta._(this.tipo, this.arranque, this.ritmo);

  final TipoUsuario tipo;

  /// Módulos de arranque, en orden.
  final List<String> arranque;
  final Ritmo ritmo;

  static Ruta para(TipoUsuario tipo) => switch (tipo) {
    TipoUsuario.ex1 => const Ruta._(TipoUsuario.ex1, [
      'M1',
      'M2',
      'M3',
    ], Ritmo.cadaDosSemanas),
    TipoUsuario.ex2 => const Ruta._(TipoUsuario.ex2, [
      'M1',
      'M7',
    ], Ritmo.semanal),
    TipoUsuario.ex3 => const Ruta._(TipoUsuario.ex3, [
      'M1',
      'M2',
      'M8',
    ], Ritmo.mensual),
    TipoUsuario.ex4 => const Ruta._(TipoUsuario.ex4, [
      'M1',
      'M2',
      'M9',
    ], Ritmo.porCampania),
    // M1 exprés tras su primera verificación.
    TipoUsuario.ex5 => const Ruta._(TipoUsuario.ex5, ['M1'], Ritmo.opcional),
    TipoUsuario.in1 => const Ruta._(TipoUsuario.in1, [
      'M1',
      'M3',
      'M11',
    ], Ritmo.mensual),
    // M12 es obligatorio antes de asumir el rol de emisor.
    TipoUsuario.in2 => const Ruta._(TipoUsuario.in2, [
      'M11',
      'M12',
    ], Ritmo.trimestral),
    TipoUsuario.in3 => const Ruta._(TipoUsuario.in3, [
      'M11',
      'M13',
    ], Ritmo.trimestral),
    TipoUsuario.in4 => const Ruta._(TipoUsuario.in4, [
      'M11',
      'M13',
    ], Ritmo.semestral),
  };

  /// Módulos del ciclo de refuerzo.
  ///
  /// [tipologiaAtacada] es la tipología del ataque activo (alerta del
  /// Observatorio). [esCuidador] marca a quien verifica por otra persona.
  List<String> refuerzo({
    Tipologia? tipologiaAtacada,
    bool esCuidador = false,
  }) => switch (tipo) {
    TipoUsuario.ex1 =>
      tipologiaAtacada == null
          ? const ['M4', 'M5', 'M6']
          : [moduloPorTipologia(tipologiaAtacada)],
    TipoUsuario.ex2 =>
      tipologiaAtacada == Tipologia.t2 ? const ['M7', 'M4'] : const ['M7'],
    TipoUsuario.ex3 => const ['M8'],
    TipoUsuario.ex4 => const ['M9', 'M5'],
    TipoUsuario.ex5 => esCuidador ? const ['M10'] : const [],
    TipoUsuario.in1 => const ['M11'],
    TipoUsuario.in2 => const ['M12'],
    TipoUsuario.in3 || TipoUsuario.in4 => const ['M13'],
  };

  /// Módulo de nivel 2 que trabaja cada tipología.
  static String moduloPorTipologia(Tipologia tipologia) => switch (tipologia) {
    Tipologia.t1 => 'M6',
    Tipologia.t2 => 'M4',
    Tipologia.t3 => 'M5',
  };
}
