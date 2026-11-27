/// Progreso local del usuario. No contiene datos personales.
class Progreso {
  const Progreso({
    this.completadas = const {},
    this.mejoresPuntajes = const {},
    this.insignias = const {},
  });

  factory Progreso.fromJson(Map<String, dynamic> json) => Progreso(
    completadas: (json['completadas'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toSet(),
    mejoresPuntajes:
        (json['mejores_puntajes'] as Map<String, dynamic>? ?? const {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
    insignias: (json['insignias'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toSet(),
  );

  /// Ids de actividades terminadas.
  final Set<String> completadas;

  /// Mejor puntaje (0.0 a 1.0) por id de actividad evaluada.
  final Map<String, double> mejoresPuntajes;

  /// Ids de las insignias ganadas. Se guardan para no perderlas si la
  /// persona sale de la capacitación o cambia de ruta.
  final Set<String> insignias;

  bool estaCompletada(String actividadId) => completadas.contains(actividadId);

  Progreso marcarCompletada(String actividadId) => Progreso(
    completadas: {...completadas, actividadId},
    mejoresPuntajes: mejoresPuntajes,
    insignias: insignias,
  );

  Progreso registrarPuntaje(String actividadId, double puntaje) {
    final anterior = mejoresPuntajes[actividadId] ?? 0;
    return Progreso(
      completadas: {...completadas, actividadId},
      mejoresPuntajes: {
        ...mejoresPuntajes,
        actividadId: puntaje > anterior ? puntaje : anterior,
      },
      insignias: insignias,
    );
  }

  Progreso otorgarInsignias(Iterable<String> ids) => Progreso(
    completadas: completadas,
    mejoresPuntajes: mejoresPuntajes,
    insignias: {...insignias, ...ids},
  );

  /// Porcentaje (0.0 a 1.0) de actividades completadas sobre un total.
  double avance(int totalActividades) =>
      totalActividades == 0 ? 0 : completadas.length / totalActividades;

  Map<String, dynamic> toJson() => {
    'completadas': completadas.toList()..sort(),
    'mejores_puntajes': mejoresPuntajes,
    'insignias': insignias.toList()..sort(),
  };
}
