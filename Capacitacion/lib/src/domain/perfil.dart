import 'rango_etario.dart';

/// Perfil mínimo del usuario. El rango es opcional: si consulta de forma
/// anónima se le pregunta con un clic y puede no responder.
class Perfil {
  const Perfil({this.rangoEtario});

  final RangoEtario? rangoEtario;

  bool get esAnonimo => rangoEtario == null;

  Perfil conRango(RangoEtario? rango) => Perfil(rangoEtario: rango);
}
