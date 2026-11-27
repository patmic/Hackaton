/// Tipologías oficiales de correo del IESS (sección 3 del documento MVP).
enum Tipologia {
  t1(
    codigo: 'T1',
    nombre: 'Informativo',
    descripcion:
        'Comunicados, campañas, recordatorios y boletines. Nunca pide '
        'contraseñas ni transferencias.',
  ),
  t2(
    codigo: 'T2',
    nombre: 'Financiero / Previsional',
    descripcion:
        'Aportes, pensiones, créditos BIESS, liquidaciones y pagos. Es la '
        'tipología con más riesgo de suplantación.',
  ),
  t3(
    codigo: 'T3',
    nombre: 'Trámites / Clínico',
    descripcion: 'Citas médicas, certificados y actualización de expedientes.',
  );

  const Tipologia({
    required this.codigo,
    required this.nombre,
    required this.descripcion,
  });

  final String codigo;
  final String nombre;
  final String descripcion;

  static Tipologia desdeCodigo(String codigo) => values.firstWhere(
    (t) => t.codigo == codigo.toUpperCase(),
    orElse: () => throw FormatException('Tipología desconocida: $codigo'),
  );
}
