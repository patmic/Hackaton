/// Zona del usuario: externa (ciudadanía) o interna (colaboradores).
enum Zona {
  externa('EXTERNA'),
  interna('INTERNA');

  const Zona(this.codigo);

  final String codigo;
}

/// Tipo de usuario (CLAUDE.md §7, [DECIDIDO]).
///
/// Sale de una fuente oficial (padrón de afiliación o de pensiones,
/// directorio institucional), nunca de lo que el usuario declara. Una
/// persona puede tener varios tipos.
enum TipoUsuario {
  ex1('EX1', 'Afiliado activo', Zona.externa),
  ex2('EX2', 'Jubilado o pensionista', Zona.externa),
  ex3('EX3', 'Empleador', Zona.externa),
  ex4('EX4', 'Prestador externo de salud', Zona.externa),
  ex5('EX5', 'Ciudadano sin cuenta o familiar', Zona.externa),
  in1('IN1', 'Colaborador general', Zona.interna),
  in2('IN2', 'Colaborador emisor', Zona.interna),
  in3('IN3', 'Analista de seguridad (CSI/OSI)', Zona.interna),
  in4('IN4', 'Administrador de plataforma', Zona.interna);

  const TipoUsuario(this.codigo, this.nombre, this.zona);

  final String codigo;
  final String nombre;
  final Zona zona;

  static const Set<TipoUsuario> todos = {
    ex1,
    ex2,
    ex3,
    ex4,
    ex5,
    in1,
    in2,
    in3,
    in4,
  };
  static const Set<TipoUsuario> externos = {ex1, ex2, ex3, ex4, ex5};
  static const Set<TipoUsuario> internos = {in1, in2, in3, in4};

  bool get esInterno => zona == Zona.interna;

  /// Marca de riesgo «alto privilegio». Los directivos también la tienen,
  /// pero eso no es un tipo.
  bool get esAltoPrivilegio => this == in3 || this == in4;

  static TipoUsuario desdeCodigo(String codigo) => values.firstWhere(
    (t) => t.codigo == codigo.trim().toUpperCase(),
    orElse: () => throw FormatException('Tipo de usuario desconocido: $codigo'),
  );
}
