/// Mecánicas interactivas (CLAUDE.md §10.3): nueve componentes reutilizables
/// que interpretan el JSON de una actividad.
enum Mecanica {
  a1('A1', 'A1_CAZA_SENAL', 'Caza la señal'),
  a2('A2', 'A2_REAL_O_ESTAFA', '¿Real o estafa?'),
  a3('A3', 'A3_BANDEJA_SIMULADA', 'Bandeja simulada'),
  a4('A4', 'A4_CHAT_ESTAFADOR', 'Chat con el estafador'),
  a5('A5', 'A5_AYUDA_VECINO', 'Ayuda a tu vecino'),
  a6('A6', 'A6_VERIFICA_3_PASOS', 'Verifica en 3 pasos'),
  a7('A7', 'A7_AUDIO_RETO', 'Audio-reto'),
  a8('A8', 'A8_SIMULACRO', 'Simulacro con momento enseñable'),
  a9('A9', 'A9_EJERCICIO_MESA', 'Ejercicio de mesa');

  const Mecanica(this.clave, this.codigo, this.nombre);

  /// Código corto (A1…A9).
  final String clave;

  /// Código del JSON de actividad (A1_CAZA_SENAL…).
  final String codigo;
  final String nombre;

  /// Acepta el código corto («A1») o el largo («A1_CAZA_SENAL»).
  static Mecanica desdeCodigo(String codigo) {
    final c = codigo.trim().toUpperCase();
    return values.firstWhere(
      (m) => m.codigo == c || m.clave == c,
      orElse: () => throw FormatException('Mecánica desconocida: $codigo'),
    );
  }
}

/// Modelo 4R (CLAUDE.md §10.1): cada módulo recorre los cuatro pasos.
enum Paso4R {
  reconocer('RECONOCER', 'Reconocer'),
  reaccionar('REACCIONAR', 'Reaccionar'),
  reportar('REPORTAR', 'Reportar'),
  replicar('REPLICAR', 'Replicar');

  const Paso4R(this.codigo, this.nombre);

  final String codigo;
  final String nombre;

  static Paso4R desdeCodigo(String codigo) => values.firstWhere(
    (p) => p.codigo == codigo.trim().toUpperCase(),
    orElse: () => throw FormatException('Paso 4R desconocido: $codigo'),
  );
}
