import 'indicio.dart';
import 'tipo_usuario.dart';

/// Microcurso que se ofrece cuando el usuario no vio un indicio
/// (CLAUDE.md §11, «Microcurso que se dispara por indicio»).
enum Microcurso {
  prisaEsLaTrampa('La prisa es la trampa'),
  canalesOficiales('Tus canales oficiales'),
  nuncaTuClave('El IESS nunca te pide tu clave'),
  aDondeLleva('Mira a dónde lleva de verdad un enlace'),
  adjuntosInesperados('Adjuntos que no esperabas'),
  nadieRegala('Nadie regala ni cobra por adelantado'),
  noBloqueaPorCorreo('El IESS no bloquea por correo'),
  paginaDelQr('No confíes en la página que abre un QR');

  const Microcurso(this.titulo);

  final String titulo;

  static Microcurso paraIndicio(Indicio indicio) => switch (indicio) {
    Indicio.i1 => Microcurso.prisaEsLaTrampa,
    Indicio.i2 || Indicio.i7 => Microcurso.canalesOficiales,
    Indicio.i3 || Indicio.i9 => Microcurso.nuncaTuClave,
    Indicio.i4 => Microcurso.aDondeLleva,
    Indicio.i5 => Microcurso.adjuntosInesperados,
    Indicio.i6 || Indicio.i10 => Microcurso.nadieRegala,
    Indicio.i8 => Microcurso.noBloqueaPorCorreo,
    Indicio.i11 => Microcurso.paginaDelQr,
  };

  /// Módulo donde vive el microcurso. Para I5 e I8 depende del tipo.
  String moduloPara(Set<TipoUsuario> tipos) => switch (this) {
    Microcurso.prisaEsLaTrampa || Microcurso.nuncaTuClave => 'M1',
    Microcurso.canalesOficiales => 'M2',
    Microcurso.aDondeLleva || Microcurso.paginaDelQr => 'M6',
    Microcurso.nadieRegala => 'M4',
    Microcurso.noBloqueaPorCorreo =>
      tipos.contains(TipoUsuario.ex2) ? 'M7' : 'M4',
    Microcurso.adjuntosInesperados => _moduloAdjuntos(tipos),
  };

  static String _moduloAdjuntos(Set<TipoUsuario> tipos) {
    if (tipos.any((t) => t.esInterno)) return 'M11';
    if (tipos.contains(TipoUsuario.ex4)) return 'M9';
    if (tipos.contains(TipoUsuario.ex3)) return 'M8';
    // [SUPUESTO] CLAUDE.md solo nombra M8 o M9 para externos. Para EX1, EX2
    // y EX5 se usa M1 (señales universales) hasta que el equipo lo defina.
    return 'M1';
  }
}
