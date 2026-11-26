import 'json.dart';
import 'perfil_conducta.dart';
import 'rango_etario.dart';
import 'tipo_usuario.dart';

/// Respuesta de `GET /api/v1/me` (CLAUDE.md §12): tipos, zona y perfil del
/// usuario actual. Decide qué ve la app.
///
/// Los tipos salen de una fuente oficial (padrón, directorio), nunca de lo que
/// declara el usuario. El correo llega enmascarado: la app no lo guarda.
class SesionUsuario {
  const SesionUsuario({
    required this.tipos,
    this.perfilConducta = PerfilConducta.sinPerfil,
    this.rangoEtario,
    this.correoEnmascarado,
  });

  factory SesionUsuario.fromJson(Map<String, dynamic> json) {
    final perfil = json['perfil_conducta'] as String?;
    final rango = json['rango_etario'] as String?;
    final tipos = listaDeTextos(
      json['tipos'],
    ).map(TipoUsuario.desdeCodigo).toSet();
    return SesionUsuario(
      tipos: tipos.isEmpty ? const {TipoUsuario.ex5} : tipos,
      perfilConducta: perfil == null
          ? PerfilConducta.sinPerfil
          : PerfilConducta.desdeCodigo(perfil),
      rangoEtario: rango == null ? null : RangoEtario.desdeCodigo(rango),
      correoEnmascarado: json['correo_enmascarado'] as String?,
    );
  }

  /// Sin sesión: EX5 (CLAUDE.md §7).
  static const sinCuenta = SesionUsuario(tipos: {TipoUsuario.ex5});

  final Set<TipoUsuario> tipos;
  final PerfilConducta perfilConducta;
  final RangoEtario? rangoEtario;

  /// Ej.: «a•••@practica.ejemplo». Null si no hay cuenta.
  final String? correoEnmascarado;

  bool get tieneCuenta => !tipos.contains(TipoUsuario.ex5);

  /// Con cuenta, el correo viene de la cuenta. Sin cuenta hay que pedirlo y
  /// confirmarlo (doble opt-in).
  bool get tieneCorreo => correoEnmascarado != null;

  Zona get zona =>
      tipos.any((t) => t.esInterno) ? Zona.interna : Zona.externa;

  /// Nombre para mostrar: el primer tipo, en el orden de [TipoUsuario].
  String get nombreTipo {
    final ordenados = tipos.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return ordenados.map((t) => t.nombre).join(' y ');
  }
}

/// Usuarios ficticios para la demo, uno por tipo (CLAUDE.md §15, fase 1).
/// Simulan lo que devolvería `GET /api/v1/me` tras iniciar sesión.
const List<SesionUsuario> sesionesDemo = [
  SesionUsuario.sinCuenta,
  SesionUsuario(
    tipos: {TipoUsuario.ex1},
    perfilConducta: PerfilConducta.prudente,
    rangoEtario: RangoEtario.r30a49,
    correoEnmascarado: 'a•••@practica.ejemplo',
  ),
  SesionUsuario(
    tipos: {TipoUsuario.ex2},
    perfilConducta: PerfilConducta.expuesto,
    rangoEtario: RangoEtario.r65mas,
    correoEnmascarado: 'j•••@practica.ejemplo',
  ),
  SesionUsuario(
    tipos: {TipoUsuario.ex3},
    rangoEtario: RangoEtario.r50a64,
    correoEnmascarado: 'e•••@practica.ejemplo',
  ),
  SesionUsuario(
    tipos: {TipoUsuario.ex4},
    perfilConducta: PerfilConducta.prudente,
    rangoEtario: RangoEtario.r30a49,
    correoEnmascarado: 'p•••@practica.ejemplo',
  ),
  SesionUsuario(
    tipos: {TipoUsuario.ex1, TipoUsuario.in1},
    perfilConducta: PerfilConducta.centinela,
    rangoEtario: RangoEtario.r30a49,
    correoEnmascarado: 'c•••@practica.ejemplo',
  ),
  SesionUsuario(
    tipos: {TipoUsuario.ex1, TipoUsuario.in2},
    perfilConducta: PerfilConducta.prudente,
    rangoEtario: RangoEtario.r50a64,
    correoEnmascarado: 'm•••@practica.ejemplo',
  ),
  SesionUsuario(
    tipos: {TipoUsuario.ex1, TipoUsuario.in3},
    perfilConducta: PerfilConducta.centinela,
    rangoEtario: RangoEtario.r30a49,
    correoEnmascarado: 's•••@practica.ejemplo',
  ),
  SesionUsuario(
    tipos: {TipoUsuario.ex1, TipoUsuario.in4},
    perfilConducta: PerfilConducta.prudente,
    rangoEtario: RangoEtario.r30a49,
    correoEnmascarado: 't•••@practica.ejemplo',
  ),
];
