import '../../domain/domain.dart';

/// Insignia de la gamificación del aula.
///
/// Se calcula con el progreso del dispositivo y el estado de «Quiero
/// capacitarme». No lleva datos personales ni compara a la persona con otras
/// (regla 3, LOPDP, y regla 7, sin culpa): cada quien ve solo las suyas.
class Insignia {
  const Insignia({
    required this.id,
    required this.nombre,
    required this.comoSeGana,
    required this.avance,
    required this.meta,
    required this.ganada,
    this.nueva = false,
    this.modulo,
  });

  final String id;
  final String nombre;

  /// Qué hay que hacer para ganarla, dicho en positivo.
  final String comoSeGana;

  /// Pasos hechos hacia la [meta] (para mostrar «2 de 4»).
  final int avance;
  final int meta;
  final bool ganada;

  /// Ganada recién y todavía sin guardar en el progreso: hay que celebrarla.
  final bool nueva;

  /// Código del módulo (M1…M15) si se gana al terminarlo; null si es un logro.
  final String? modulo;

  bool get esDeModulo => modulo != null;

  /// Avance de 0.0 a 1.0.
  double get fraccion =>
      ganada ? 1 : (meta == 0 ? 0 : (avance / meta).clamp(0.0, 1.0));
}

/// Todas las insignias que puede ganar el usuario con su ruta actual.
class ResumenInsignias {
  const ResumenInsignias(this.todas);

  /// Primero los logros y después los módulos, en el orden del catálogo.
  final List<Insignia> todas;

  List<Insignia> get ganadas => [
    for (final i in todas)
      if (i.ganada) i,
  ];

  /// Las que hay que celebrar y guardar.
  List<Insignia> get nuevas => [
    for (final i in todas)
      if (i.nueva) i,
  ];
}

/// Reglas de las insignias.
abstract final class Insignias {
  static const primerPaso = 'primer-paso';
  static const meCapacito = 'me-capacito';
  static const detective = 'detective';
  static const constancia = 'constancia';
  static const ojoDeLince = 'ojo-de-lince';
  static const centinela = 'centinela';
  static const rutaCompleta = 'ruta-completa';

  /// Lecciones para la insignia «Constancia». Solo se ofrece si la ruta
  /// tiene más, para que no repita a «Ruta completa».
  static const leccionesConstancia = 5;

  static String deModulo(String codigo) => 'modulo-$codigo';

  /// [actividades] son las de la ruta del usuario (las que le tocan por su
  /// tipo y perfil). Una insignia ya guardada en [progreso] sigue ganada
  /// aunque su regla deje de cumplirse.
  static ResumenInsignias calcular({
    required List<Actividad> actividades,
    required Progreso progreso,
    EstadoCapacitacion? capacitacion,
    Perfil? perfil,
  }) {
    final estado = capacitacion ?? const EstadoCapacitacion();
    final hechas = progreso.completadas.length;
    final hechasEnRuta = actividades
        .where((a) => progreso.estaCompletada(a.id))
        .length;
    final perfecta = progreso.mejoresPuntajes.values.any((p) => p >= 1);
    final reporto = estado.mapa.estados.values.contains(
      EstadoIndicio.dominado,
    );
    final esCentinela = estado.esCentinela || (perfil?.esCentinela ?? false);

    Insignia regla(
      String id,
      String nombre,
      String comoSeGana, {
      required int avance,
      required int meta,
      String? modulo,
    }) {
      final merecida = meta > 0 && avance >= meta;
      final guardada = progreso.insignias.contains(id);
      return Insignia(
        id: id,
        nombre: nombre,
        comoSeGana: comoSeGana,
        avance: avance.clamp(0, meta),
        meta: meta,
        ganada: merecida || guardada,
        nueva: merecida && !guardada,
        modulo: modulo,
      );
    }

    final logros = [
      regla(
        primerPaso,
        'Primer paso',
        'Termina tu primera lección.',
        avance: hechas,
        meta: 1,
      ),
      regla(
        meCapacito,
        'Me capacito',
        'Toca «Quiero capacitarme» y acepta practicar con correos de prueba.',
        avance: estado.inscrito ? 1 : 0,
        meta: 1,
      ),
      regla(
        detective,
        'Detective',
        'Reporta un correo de práctica sin abrir su enlace.',
        avance: reporto ? 1 : 0,
        meta: 1,
      ),
      if (actividades.length > leccionesConstancia)
        regla(
          constancia,
          'Constancia',
          'Termina $leccionesConstancia lecciones.',
          avance: hechas,
          meta: leccionesConstancia,
        ),
      regla(
        ojoDeLince,
        'Ojo de lince',
        'Acierta todos los casos de una práctica.',
        avance: perfecta ? 1 : 0,
        meta: 1,
      ),
      regla(
        centinela,
        'Centinela',
        'Reporta dos correos de práctica difíciles seguidos.',
        avance: esCentinela ? 2 : estado.reportesSeguidosNivel3,
        meta: 2,
      ),
      if (actividades.isNotEmpty)
        regla(
          rutaCompleta,
          'Ruta completa',
          'Termina todas las lecciones de tu ruta.',
          avance: hechasEnRuta,
          meta: actividades.length,
        ),
    ];

    // Una insignia por cada módulo de la ruta, en el orden del catálogo.
    final modulos = <Insignia>[];
    for (final m in catalogoModulos) {
      final delModulo = actividades.where((a) => a.modulo == m.codigo).toList();
      if (delModulo.isEmpty) continue;
      final total = delModulo.length;
      modulos.add(
        regla(
          deModulo(m.codigo),
          m.nombre,
          total == 1
              ? 'Termina la lección de este módulo.'
              : 'Termina las $total lecciones de este módulo.',
          avance: delModulo.where((a) => progreso.estaCompletada(a.id)).length,
          meta: total,
          modulo: m.codigo,
        ),
      );
    }

    return ResumenInsignias([...logros, ...modulos]);
  }
}
