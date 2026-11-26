/// Canales oficiales del IESS (CLAUDE.md §6).
///
/// Son los únicos datos reales de la app. Hay que verificar su vigencia
/// antes de publicar (regla 2 de CLAUDE.md).
abstract final class CanalesOficiales {
  static const dominioCorreo = 'iess.gob.ec';
  static const portal = 'www.iess.gob.ec';
  static const appAfiliado = 'app.iess.gob.ec';

  /// A donde se reenvía un correo sospechoso (CLAUDE.md §11, reglas de
  /// medición). En la demo se usa la dirección del dominio de práctica.
  static const correoReportes = 'seguridad.informacion@iess.gob.ec';
}
