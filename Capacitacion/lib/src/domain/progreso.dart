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

  /// Ids de cápsulas vistas hasta el final.
  final Set<String> completadas;

  /// Mejor puntaje (0.0 a 1.0) por id de cápsula con quiz.
  final Map<String, double> mejoresPuntajes;

  bool estaCompletada(String capsulaId) => completadas.contains(capsulaId);

  Progreso marcarCompletada(String capsulaId) => Progreso(
    completadas: {...completadas, capsulaId},
    mejoresPuntajes: mejoresPuntajes,
  );

  Progreso registrarPuntaje(String capsulaId, double puntaje) {
    final anterior = mejoresPuntajes[capsulaId] ?? 0;
    return Progreso(
      completadas: {...completadas, capsulaId},
      mejoresPuntajes: {
        ...mejoresPuntajes,
        capsulaId: puntaje > anterior ? puntaje : anterior,
      },
    );
  }

  /// Porcentaje (0.0 a 1.0) de cápsulas completadas sobre un total.
  double avance(int totalCapsulas) =>
      totalCapsulas == 0 ? 0 : completadas.length / totalCapsulas;

  Map<String, dynamic> toJson() => {
    'completadas': completadas.toList()..sort(),
    'mejores_puntajes': mejoresPuntajes,
  };
}
