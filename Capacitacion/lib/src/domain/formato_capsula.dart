/// Formato principal en que se entrega una cápsula.
enum FormatoCapsula {
  texto('TEXTO', 'Lectura breve'),
  audio('AUDIO', 'Audio'),
  quiz('QUIZ', '¿Real o estafa?');

  const FormatoCapsula(this.codigo, this.etiqueta);

  final String codigo;
  final String etiqueta;

  static FormatoCapsula desdeCodigo(String codigo) => values.firstWhere(
    (f) => f.codigo == codigo.toUpperCase(),
    orElse: () => throw FormatException('Formato desconocido: $codigo'),
  );
}
