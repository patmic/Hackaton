/// Perfil de conducta (CLAUDE.md §7).
///
/// Lo calcula el Núcleo (Bloque 3) con una ventana de 90 días. La app solo
/// lo recibe y lo muestra con [etiquetaVisible].
enum PerfilConducta {
  centinela('CENTINELA', 'Centinela'),
  prudente('PRUDENTE', 'Prudente'),

  /// Regla 7 (sin culpa): «Expuesto» nunca se muestra al usuario.
  expuesto('EXPUESTO', 'En aprendizaje'),
  inactivo('INACTIVO', 'Inactivo'),
  sinPerfil('SIN_PERFIL', 'Sin perfil');

  const PerfilConducta(this.codigo, this.etiquetaVisible);

  final String codigo;

  /// Texto que ve el usuario.
  final String etiquetaVisible;

  static PerfilConducta desdeCodigo(String codigo) => values.firstWhere(
    (p) => p.codigo == codigo.trim().toUpperCase(),
    orElse: () =>
        throw FormatException('Perfil de conducta desconocido: $codigo'),
  );
}
