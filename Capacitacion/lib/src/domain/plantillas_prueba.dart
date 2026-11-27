import 'capacitacion.dart';
import 'indicio.dart';
import 'tipo_usuario.dart';
import 'tipologia.dart';

/// Plantillas simuladas de correos de prueba. Todo es ficticio.
///
/// - Las de nivel 2 marcadas con `esPrimerCorreo` son el «primer correo por
///   tipo» de CLAUDE.md §11 ([DECIDIDO]: ids, asuntos e indicios).
/// - Las demás son propuestas para la escalera [PROPUESTO].
/// - Cada una suplanta una tipología de `tipologias.json` usando sus
///   indicios de `suplantacion_frecuente` y rompiendo su `nunca_trae`.
/// - `backend/capacitacion/plantillas.py` (API de Capacitación) es un espejo
///   de esta lista: si cambias ids, niveles o indicios, avisa a ese bloque.
const List<PlantillaCorreoPrueba> plantillasPrueba = [
  // ---------- Nivel 2: primer correo por tipo (§11) ----------
  PlantillaCorreoPrueba(
    id: 'N2-EX1-reembolso',
    tipos: {TipoUsuario.ex1},
    nivel: NivelCorreo.medio,
    asunto: 'Tienes un reembolso pendiente de \$187,40, vence hoy',
    indicios: [Indicio.i6, Indicio.i1, Indicio.i7],
    tipologiaSuplantada: Tipologia.t2,
    nombreRemitente: 'IESS Devoluciones',
    usuarioRemitente: 'devoluciones',
    cuerpo:
        'Estimado afiliado:\n'
        'Tras revisar tus aportes, tienes un reembolso pendiente de '
        '\$187,40.\n'
        'El valor vence hoy a las 23:59. Si no lo solicitas, regresará al '
        'fondo común.',
    boton: 'Solicitar mi reembolso',
    esPrimerCorreo: true,
  ),
  PlantillaCorreoPrueba(
    id: 'N2-EX2-pension',
    tipos: {TipoUsuario.ex2},
    nivel: NivelCorreo.medio,
    asunto: 'Tu pensión será suspendida si no actualizas tus datos hoy',
    indicios: [Indicio.i8, Indicio.i1, Indicio.i9],
    tipologiaSuplantada: Tipologia.t2,
    nombreRemitente: 'IESS Pensiones',
    usuarioRemitente: 'pensiones',
    cuerpo:
        'Estimado jubilado:\n'
        'Sus datos no están actualizados en nuestro sistema.\n'
        'Si no los actualiza hoy, su pensión de diciembre quedará '
        'suspendida.\n'
        'Tenga a mano su cédula y su fecha de nacimiento.',
    boton: 'Actualizar mis datos',
    esPrimerCorreo: true,
  ),
  PlantillaCorreoPrueba(
    id: 'N2-EX3-glosa',
    tipos: {TipoUsuario.ex3},
    nivel: NivelCorreo.medio,
    asunto:
        'Glosa por aportes impagos: evita la coactiva cancelando la tasa hoy',
    indicios: [Indicio.i8, Indicio.i10, Indicio.i7],
    tipologiaSuplantada: Tipologia.t2,
    nombreRemitente: 'IESS Recaudación',
    usuarioRemitente: 'recaudacion',
    cuerpo:
        'Señor empleador:\n'
        'Su empresa registra una glosa por aportes impagos del período de '
        'octubre.\n'
        'Para evitar el inicio de la coactiva, cancele la tasa de '
        'regularización de \$48,00.',
    boton: 'Pagar la tasa',
    esPrimerCorreo: true,
  ),
  PlantillaCorreoPrueba(
    id: 'N2-EX4-planillas',
    tipos: {TipoUsuario.ex4},
    nivel: NivelCorreo.medio,
    asunto: 'Liquidación de planillas retenida: revisa el detalle adjunto',
    indicios: [Indicio.i5, Indicio.i7, Indicio.i1],
    tipologiaSuplantada: Tipologia.t2,
    nombreRemitente: 'IESS Prestadores',
    usuarioRemitente: 'prestadores',
    cuerpo:
        'Estimado prestador:\n'
        'La liquidación de sus planillas de noviembre quedó retenida por una '
        'observación.\n'
        'Revise el detalle adjunto y responda antes de las 18:00 de hoy.',
    boton: 'Descargar el detalle',
    adjunto: 'Detalle_liquidacion.zip',
    esPrimerCorreo: true,
  ),
  PlantillaCorreoPrueba(
    id: 'N2-EX5-certificado',
    tipos: {TipoUsuario.ex5},
    nivel: NivelCorreo.medio,
    asunto:
        'Tu certificado de afiliación está listo. Escanea el QR para '
        'descargarlo',
    indicios: [Indicio.i11, Indicio.i7, Indicio.i1],
    tipologiaSuplantada: Tipologia.t3,
    nombreRemitente: 'IESS Certificados',
    usuarioRemitente: 'certificados',
    cuerpo:
        'Hola:\n'
        'Tu certificado de afiliación ya está listo.\n'
        'Escanea el código QR con tu celular para descargarlo. El código '
        'vence hoy.',
    boton: 'Descargar certificado',
    tieneQr: true,
    esPrimerCorreo: true,
  ),
  PlantillaCorreoPrueba(
    id: 'N2-IN-buzon',
    tipos: TipoUsuario.internos,
    nivel: NivelCorreo.medio,
    asunto: 'Tu buzón institucional está lleno. Valida tu usuario y contraseña',
    indicios: [Indicio.i3, Indicio.i1, Indicio.i2],
    tipologiaSuplantada: Tipologia.t6,
    nombreRemitente: 'Soporte TI',
    usuarioRemitente: 'soporte.ti',
    cuerpo:
        'Estimado colaborador:\n'
        'Tu buzón institucional está al 99 % de su capacidad.\n'
        'Para no perder correos, valida tu usuario y contraseña en los '
        'próximos 60 minutos.',
    boton: 'Validar mi cuenta',
    esPrimerCorreo: true,
  ),

  // ---------- Nivel 2: más tipologías [PROPUESTO] ----------
  PlantillaCorreoPrueba(
    id: 'N2-EX-turno-qr',
    tipos: {TipoUsuario.ex1, TipoUsuario.ex2, TipoUsuario.ex4},
    nivel: NivelCorreo.medio,
    asunto: 'Tu turno médico fue reprogramado: confírmalo con el QR',
    indicios: [Indicio.i11, Indicio.i9, Indicio.i1],
    tipologiaSuplantada: Tipologia.t4,
    nombreRemitente: 'IESS Turnos',
    usuarioRemitente: 'turnos',
    cuerpo:
        'Hola:\n'
        'Tu turno médico fue reprogramado.\n'
        'Para confirmarlo, escanea el código QR y escribe tu número de '
        'cédula. Tienes plazo hasta hoy.',
    boton: 'Confirmar mi turno',
    tieneQr: true,
  ),
  PlantillaCorreoPrueba(
    id: 'N2-EX-clave',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.medio,
    asunto: 'Nuevo inicio de sesión en tu cuenta: confirma tu clave',
    indicios: [Indicio.i3, Indicio.i4, Indicio.i1],
    tipologiaSuplantada: Tipologia.t5,
    nombreRemitente: 'IESS Cuenta',
    usuarioRemitente: 'cuenta',
    cuerpo:
        'Hola:\n'
        'Registramos un inicio de sesión en tu cuenta desde un equipo nuevo.\n'
        'Si no fuiste tú, confirma tu clave en las próximas 24 horas: '
        'https://bit.ly/iess-acceso',
    boton: 'Confirmar mi clave',
  ),

  // ---------- Nivel 1: 4 o más indicios, obvios [PROPUESTO] ----------
  PlantillaCorreoPrueba(
    id: 'N1-EX-bloqueo',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.facil,
    asunto:
        '¡URGENTE! Tu cuenta será bloqueada hoy: confirma tu clave y tu '
        'tarjeta',
    indicios: [Indicio.i1, Indicio.i8, Indicio.i3, Indicio.i7, Indicio.i2],
    tipologiaSuplantada: Tipologia.t5,
    nombreRemitente: 'IESS Seguridad',
    usuarioRemitente: 'seguridad',
    cuerpo:
        '¡URGENTE!\n'
        'Tu cuenta será bloqueada HOY por actividad sospechosa.\n'
        'Para evitarlo, confirma tu clave y los datos de tu tarjeta en el '
        'portal de verificación.',
    boton: 'Confirmar ahora',
  ),
  PlantillaCorreoPrueba(
    id: 'N1-EX-premio',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.facil,
    asunto:
        'Ganaste un bono de \$500: envía tu cédula y paga \$5 de envío antes '
        'de las 18:00',
    indicios: [Indicio.i6, Indicio.i9, Indicio.i10, Indicio.i1, Indicio.i7],
    tipologiaSuplantada: Tipologia.t2,
    nombreRemitente: 'IESS Beneficios',
    usuarioRemitente: 'beneficios',
    cuerpo:
        '¡Felicidades!\n'
        'Ganaste un bono de \$500 por tu fidelidad como afiliado.\n'
        'Para recibirlo, envía una foto de tu cédula y paga \$5 de envío '
        'antes de las 18:00.',
    boton: 'Reclamar mi bono',
  ),
  PlantillaCorreoPrueba(
    id: 'N1-EX-cita-pago',
    tipos: {TipoUsuario.ex1, TipoUsuario.ex2, TipoUsuario.ex4},
    nivel: NivelCorreo.facil,
    asunto: '¡ÚLTIMO AVISO! Tu cita se cancela HOY si no pagas la confirmación',
    indicios: [Indicio.i1, Indicio.i8, Indicio.i10, Indicio.i7, Indicio.i2],
    tipologiaSuplantada: Tipologia.t4,
    nombreRemitente: 'IESS Agendamiento',
    usuarioRemitente: 'agendamiento',
    cuerpo:
        '¡ÚLTIMO AVISO!\n'
        'Tu cita médica de mañana se cancelará hoy si no la confirmas.\n'
        'Para confirmarla, paga \$5 desde el enlace. Sin el pago perderás tu '
        'turno.',
    boton: 'Pagar y confirmar',
  ),
  PlantillaCorreoPrueba(
    id: 'N1-IN-parche',
    tipos: TipoUsuario.internos,
    nivel: NivelCorreo.facil,
    asunto:
        'Soporte TI: tu cuenta se desactiva HOY. Instala el parche adjunto e '
        'ingresa tu clave',
    indicios: [Indicio.i1, Indicio.i8, Indicio.i5, Indicio.i3, Indicio.i7],
    tipologiaSuplantada: Tipologia.t6,
    nombreRemitente: 'Soporte TI',
    usuarioRemitente: 'mesa.ayuda',
    cuerpo:
        'Atención:\n'
        'Tu cuenta institucional se desactiva HOY por falta de '
        'actualización.\n'
        'Instala el parche adjunto e ingresa tu clave cuando te la pida.',
    boton: 'Descargar el parche',
    adjunto: 'Parche_cuenta.exe',
  ),

  // ---------- Nivel 3: 1 indicio, sutil [PROPUESTO] ----------
  // Además del indicio buscado siempre están I7 e I2 (ver
  // PlantillaCorreoPrueba.indiciosImplicitos).
  PlantillaCorreoPrueba(
    id: 'N3-EX-enlace',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Actualizamos el formato de tus certificados',
    indicios: [Indicio.i4],
    tipologiaSuplantada: Tipologia.t3,
    nombreRemitente: 'IESS Certificados',
    usuarioRemitente: 'certificados',
    cuerpo:
        'Hola:\n'
        'Actualizamos el formato de tus certificados de afiliación.\n'
        'Puedes ver el nuevo modelo en www.iess.gob.ec/certificados. No '
        'necesitas hacer ningún trámite.',
    boton: 'Ver el nuevo formato',
  ),
  PlantillaCorreoPrueba(
    id: 'N3-EX-remitente',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Recordatorio de tu cita de control',
    indicios: [Indicio.i7],
    tipologiaSuplantada: Tipologia.t4,
    nombreRemitente: 'IESS Turnos',
    usuarioRemitente: 'turnos',
    cuerpo:
        'Hola:\n'
        'Te recordamos tu cita de control de medicina general el martes 2 de '
        'diciembre a las 09:30, en el Hospital del Día.\n'
        'Si no puedes asistir, reprográmala con anticipación.',
    boton: 'Ver mi cita',
  ),
  PlantillaCorreoPrueba(
    id: 'N3-EX-adjunto',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Tu estado de cuenta de noviembre (adjunto)',
    indicios: [Indicio.i5],
    tipologiaSuplantada: Tipologia.t2,
    nombreRemitente: 'IESS Notificaciones',
    usuarioRemitente: 'notificaciones',
    cuerpo:
        'Estimado afiliado:\n'
        'Adjuntamos tu estado de cuenta de aportes de noviembre.\n'
        'Si el documento no se ve bien, habilita el contenido.',
    boton: 'Ver el adjunto',
    adjunto: 'Estado_cuenta_noviembre.docm',
  ),
  PlantillaCorreoPrueba(
    id: 'N3-EX-datos',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Completa tu fecha de nacimiento para mantener tu perfil al día',
    indicios: [Indicio.i9],
    tipologiaSuplantada: Tipologia.t1,
    nombreRemitente: 'IESS Informa',
    usuarioRemitente: 'informa',
    cuerpo:
        'IESS Informa:\n'
        'Estamos actualizando nuestra base de contactos.\n'
        'Completa tu fecha de nacimiento para mantener tu perfil al día.',
    boton: 'Completar mi perfil',
  ),
  PlantillaCorreoPrueba(
    id: 'N3-EX-pago',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Emisión de tu certificado: valor de \$2,50',
    indicios: [Indicio.i10],
    tipologiaSuplantada: Tipologia.t3,
    nombreRemitente: 'IESS Certificados',
    usuarioRemitente: 'certificados',
    cuerpo:
        'Hola:\n'
        'Tu certificado de historia laboral está listo.\n'
        'La emisión tiene un valor de \$2,50, que puedes pagar en línea.',
    boton: 'Pagar y descargar',
  ),
  PlantillaCorreoPrueba(
    id: 'N3-IN-documento',
    tipos: TipoUsuario.internos,
    nivel: NivelCorreo.dificil,
    asunto: 'Nueva política de vacaciones: revisa el documento compartido',
    indicios: [Indicio.i2],
    tipologiaSuplantada: Tipologia.t6,
    nombreRemitente: 'Talento Humano',
    usuarioRemitente: 'talento.humano',
    cuerpo:
        'Estimados compañeros:\n'
        'Compartimos la nueva política de vacaciones para el próximo año.\n'
        'Revisen el documento compartido antes de la reunión del viernes.',
    boton: 'Abrir el documento',
  ),
  PlantillaCorreoPrueba(
    id: 'N3-IN-reunion',
    tipos: TipoUsuario.internos,
    nivel: NivelCorreo.dificil,
    asunto: 'Agenda de la reunión de coordinación',
    indicios: [Indicio.i5],
    tipologiaSuplantada: Tipologia.t6,
    nombreRemitente: 'Coordinación Zonal',
    usuarioRemitente: 'coordinacion',
    cuerpo:
        'Buenos días:\n'
        'Adjunto la agenda de la reunión de coordinación del martes.\n'
        'Si el documento no se ve bien, habilita las macros.',
    boton: 'Ver el adjunto',
    adjunto: 'Agenda_coordinacion.docm',
  ),
  PlantillaCorreoPrueba(
    id: 'N3-IN-nomina',
    tipos: TipoUsuario.internos,
    nivel: NivelCorreo.dificil,
    asunto: 'Tu rol de pagos de noviembre ya está disponible',
    indicios: [Indicio.i4],
    tipologiaSuplantada: Tipologia.t6,
    nombreRemitente: 'Talento Humano',
    usuarioRemitente: 'nomina',
    cuerpo:
        'Estimados compañeros:\n'
        'El rol de pagos de noviembre ya está disponible.\n'
        'Consúltalo aquí: https://cutt.ly/rol-noviembre',
    boton: 'Ver mi rol',
  ),
];
