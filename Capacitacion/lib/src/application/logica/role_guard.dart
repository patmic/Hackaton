import '../../domain/domain.dart';

/// A dónde lleva la app a cada usuario (CLAUDE.md §14, `RoleGuard`).
enum Destino {
  /// Externos: bandeja, verificador y capacitación.
  appCiudadana,

  /// Internos en el celular: lo mismo, con sus módulos (M11…).
  appInstitucional,

  /// Internos con rol de emisor, analista o administrador en la web. La
  /// consola la construyen los Bloques 1 y 3.
  consolaWeb,
}

/// IN2 (emitir), IN3 (observatorio y revocación) e IN4 (roles).
bool tieneRolDeConsola(Perfil perfil) => perfil.tipos.any(
  const {TipoUsuario.in2, TipoUsuario.in3, TipoUsuario.in4}.contains,
);

Destino destinoInicial(Perfil perfil, {required bool esWeb}) {
  if (perfil.zona == Zona.externa) return Destino.appCiudadana;
  return esWeb && tieneRolDeConsola(perfil)
      ? Destino.consolaWeb
      : Destino.appInstitucional;
}
