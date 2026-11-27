import 'perfil_conducta.dart';
import 'rango_etario.dart';
import 'tipo_usuario.dart';

/// Perfil del usuario dentro de la app. No guarda datos personales: solo el
/// tipo (de fuente oficial), el perfil de conducta (lo calcula el Núcleo), el
/// rango de edad opcional y si verifica por otra persona.
class Perfil {
  const Perfil({
    this.tipos = const {TipoUsuario.ex5},
    this.perfilConducta = PerfilConducta.sinPerfil,
    this.rangoEtario,
    this.esCuidador = false,
  });

  /// Sin sesión el usuario es EX5 (CLAUDE.md §7).
  final Set<TipoUsuario> tipos;
  final PerfilConducta perfilConducta;

  /// Opcional: se pregunta con un clic y se puede no responder (Fallo 3).
  final RangoEtario? rangoEtario;

  /// Marca de riesgo «cuidador»: verifica por otra persona.
  final bool esCuidador;

  Zona get zona =>
      tipos.any((t) => t.esInterno) ? Zona.interna : Zona.externa;

  /// EX2: letra grande, menos pasos y audio. Se activa por tipo, no por la
  /// edad declarada (CLAUDE.md §14).
  bool get usaInterfazSimplificada => tipos.contains(TipoUsuario.ex2);

  bool get esCentinela => perfilConducta == PerfilConducta.centinela;

  bool get sinRango => rangoEtario == null;

  Perfil copyWith({
    Set<TipoUsuario>? tipos,
    PerfilConducta? perfilConducta,
    RangoEtario? Function()? rangoEtario,
    bool? esCuidador,
  }) => Perfil(
    tipos: tipos ?? this.tipos,
    perfilConducta: perfilConducta ?? this.perfilConducta,
    rangoEtario: rangoEtario != null ? rangoEtario() : this.rangoEtario,
    esCuidador: esCuidador ?? this.esCuidador,
  );

  Perfil conRango(RangoEtario? rango) => copyWith(rangoEtario: () => rango);
}
