/// Tipologías de correo oficial del IESS.
///
/// Fuente: `tipologias-correo/tipologias.json` (v1.0, 2026-11-26), que
/// reemplaza a las tres tipologías del documento MVP: T3 y T4 se separaron
/// (los turnos médicos tienen reglas propias) y se agregaron T5 y T6. El
/// contenido completo de cada una (qué trae, qué nunca trae, cápsula) está en
/// [FichaTipologia].
///
/// Los correos legítimos que no son del IESS (SRI, Microsoft, Zoom) forman el
/// grupo `EXT` del JSON: no llevan Sello IESS y no son una tipología.
enum Tipologia {
  t1(
    codigo: 'T1',
    nombre: 'Informativo y eventos',
    descripcion:
        'Avisos generales: boletines, horarios, mantenimientos, charlas y '
        'encuestas. Nunca pide datos, claves ni pagos.',
  ),
  t2(
    codigo: 'T2',
    nombre: 'Financiero y previsional',
    descripcion:
        'Aportes, planillas, pensiones, prestaciones y devoluciones ya '
        'procesadas. Es la tipología con más riesgo de suplantación.',
  ),
  t3(
    codigo: 'T3',
    nombre: 'Trámites y certificados',
    descripcion: 'Avance o cierre de solicitudes que la persona inició.',
  ),
  t4(
    codigo: 'T4',
    nombre: 'Salud: turnos y citas',
    descripcion: 'Confirmar, recordar o reprogramar citas médicas.',
  ),
  t5(
    codigo: 'T5',
    nombre: 'Seguridad de cuenta',
    descripcion:
        'Confirmar cambios que la persona hizo y enviar alertas preventivas.',
  ),
  t6(
    codigo: 'T6',
    nombre: 'Interno para colaboradores',
    descripcion: 'Reuniones, memorandos, circulares e informes entre áreas.',
  );

  const Tipologia({
    required this.codigo,
    required this.nombre,
    required this.descripcion,
  });

  final String codigo;
  final String nombre;
  final String descripcion;

  /// Solo los colaboradores reciben correos T6.
  bool get esInterna => this == t6;

  static Tipologia desdeCodigo(String codigo) =>
      tryDesdeCodigo(codigo) ??
      (throw FormatException('Tipología desconocida: $codigo'));

  /// Igual que [desdeCodigo], pero devuelve null si el código no existe
  /// (por ejemplo `EXT`). Se usa con datos del servidor.
  static Tipologia? tryDesdeCodigo(String codigo) {
    final c = codigo.trim().toUpperCase();
    for (final t in values) {
      if (t.codigo == c) return t;
    }
    return null;
  }
}
