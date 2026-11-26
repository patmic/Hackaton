/// Progreso local del usuario. No contiene datos personales.
class Progreso {
  const Progreso({
    this.completadas = const {},
    this.mejoresPuntajes = const {},
  });

  factory Progreso.fromJson(Map<String, dynamic> json) => Progreso(
    completadas: (json['completadas'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toSet(),
    mejoresPuntajes:
        (json['mejores_puntajes'] as Map<String, dynamic>? ?? const {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
  );

  /// Ids de actividades terminadas.
  final Set<String> completadas;

  /// Mejor puntaje (0.0 a 1.0) por id de actividad evaluada.
  final Map<String, double> mejoresPuntajes;

  bool estaCompletada(String actividadId) => completadas.contains(actividadId);

  Progreso marcarCompletada(String actividadId) => Progreso(
    completadas: {...completadas, actividadId},
    mejoresPuntajes: mejoresPuntajes,
  );

  Progreso registrarPuntaje(String actividadId, double puntaje) {
    final anterior = mejoresPuntajes[actividadId] ?? 0;
    return Progreso(
      completadas: {...completadas, actividadId},
      mejoresPuntajes: {
        ...mejoresPuntajes,
        actividadId: puntaje > anterior ? puntaje : anterior,
      },
    );
  }

  /// Porcentaje (0.0 a 1.0) de actividades completadas sobre un total.
  double avance(int totalActividades) =>
      totalActividades == 0 ? 0 : completadas.length / totalActividades;

  Map<String, dynamic> toJson() => {
    'completadas': completadas.toList()..sort(),
    'mejores_puntajes': mejoresPuntajes,
  };
}
