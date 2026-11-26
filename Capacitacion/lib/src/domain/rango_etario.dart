/// Rangos de edad anonimizados. Nunca se guarda la edad exacta ni la cédula
/// (mitigación del Fallo 3, LOPDP).
///
/// El rango alimenta al Observatorio y a las alertas por segmento. No decide
/// el formato de las actividades: eso lo hace el tipo de usuario (EX2 usa
/// audio, CLAUDE.md §14).
enum RangoEtario {
  r18a29('18-29'),
  r30a49('30-49'),
  r50a64('50-64'),
  r65mas('65+');

  const RangoEtario(this.codigo);

  final String codigo;

  static RangoEtario desdeCodigo(String codigo) => values.firstWhere(
    (r) => r.codigo == codigo,
    orElse: () => throw FormatException('Rango etario desconocido: $codigo'),
  );
}
