/// Rangos de edad anonimizados (buckets). Nunca se guarda la edad exacta
/// ni la cédula (mitigación del Fallo 3, LOPDP).
enum RangoEtario {
  r18a29('18-29'),
  r30a49('30-49'),
  r50a64('50-64'),
  r65mas('65+');

  const RangoEtario(this.codigo);

  final String codigo;

  /// Adultos mayores: se priorizan formatos de audio y textos cortos.
  bool get esAdultoMayor => this == RangoEtario.r65mas;

  static RangoEtario desdeCodigo(String codigo) => values.firstWhere(
    (r) => r.codigo == codigo,
    orElse: () => throw FormatException('Rango etario desconocido: $codigo'),
  );
}
