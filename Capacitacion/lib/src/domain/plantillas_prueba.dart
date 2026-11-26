import 'capacitacion.dart';
import 'indicio.dart';
import 'tipo_usuario.dart';

/// Plantillas simuladas de correos de prueba.
///
/// Las de nivel 2 son el «primer correo por tipo» de CLAUDE.md §11. Las de
/// nivel 1 y 3 son propuestas para la escalera. En producción las arma la API
/// de Capacitación a partir del dataset sintético. Todo es ficticio.
const List<PlantillaCorreoPrueba> plantillasPrueba = [
  // ---------- Nivel 2: primer correo por tipo (§11) ----------
  PlantillaCorreoPrueba(
    id: 'N2-EX1-reembolso',
    tipos: {TipoUsuario.ex1},
    nivel: NivelCorreo.medio,
    asunto: 'Tienes un reembolso pendiente de \$187,40, vence hoy',
    indicios: [Indicio.i6, Indicio.i1, Indicio.i7],
  ),
  PlantillaCorreoPrueba(
    id: 'N2-EX2-pension',
    tipos: {TipoUsuario.ex2},
    nivel: NivelCorreo.medio,
    asunto: 'Tu pensión será suspendida si no actualizas tus datos hoy',
    indicios: [Indicio.i8, Indicio.i1, Indicio.i9],
  ),
  PlantillaCorreoPrueba(
    id: 'N2-EX3-glosa',
    tipos: {TipoUsuario.ex3},
    nivel: NivelCorreo.medio,
    asunto:
        'Glosa por aportes impagos: evita la coactiva cancelando la tasa hoy',
    indicios: [Indicio.i8, Indicio.i10, Indicio.i7],
  ),
  PlantillaCorreoPrueba(
    id: 'N2-EX4-planillas',
    tipos: {TipoUsuario.ex4},
    nivel: NivelCorreo.medio,
    asunto: 'Liquidación de planillas retenida: revisa el detalle adjunto',
    indicios: [Indicio.i5, Indicio.i7, Indicio.i1],
  ),
  PlantillaCorreoPrueba(
    id: 'N2-EX5-certificado',
    tipos: {TipoUsuario.ex5},
    nivel: NivelCorreo.medio,
    asunto:
        'Tu certificado de afiliación está listo. Escanea el QR para '
        'descargarlo',
    indicios: [Indicio.i11, Indicio.i7, Indicio.i1],
  ),
  PlantillaCorreoPrueba(
    id: 'N2-IN-buzon',
    tipos: TipoUsuario.internos,
    nivel: NivelCorreo.medio,
    asunto: 'Tu buzón institucional está lleno. Valida tu usuario y contraseña',
    indicios: [Indicio.i3, Indicio.i1, Indicio.i2],
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
  ),
  PlantillaCorreoPrueba(
    id: 'N1-EX-premio',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.facil,
    asunto:
        'Ganaste un bono de \$500: envía tu cédula y paga \$5 de envío antes '
        'de las 18:00',
    indicios: [Indicio.i6, Indicio.i9, Indicio.i10, Indicio.i1, Indicio.i7],
  ),
  PlantillaCorreoPrueba(
    id: 'N1-IN-parche',
    tipos: TipoUsuario.internos,
    nivel: NivelCorreo.facil,
    asunto:
        'Soporte TI: tu cuenta se desactiva HOY. Instala el parche adjunto e '
        'ingresa tu clave',
    indicios: [Indicio.i1, Indicio.i8, Indicio.i5, Indicio.i3, Indicio.i7],
  ),

  // ---------- Nivel 3: 1 indicio, sutil [PROPUESTO] ----------
  PlantillaCorreoPrueba(
    id: 'N3-EX-enlace',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Actualizamos el formato de tus certificados',
    indicios: [Indicio.i4],
  ),
  PlantillaCorreoPrueba(
    id: 'N3-EX-remitente',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Recordatorio de tu cita de control',
    indicios: [Indicio.i7],
  ),
  PlantillaCorreoPrueba(
    id: 'N3-EX-adjunto',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Tu estado de cuenta de noviembre (adjunto)',
    indicios: [Indicio.i5],
  ),
  PlantillaCorreoPrueba(
    id: 'N3-EX-datos',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Completa tu fecha de nacimiento para mantener tu perfil al día',
    indicios: [Indicio.i9],
  ),
  PlantillaCorreoPrueba(
    id: 'N3-EX-pago',
    tipos: TipoUsuario.externos,
    nivel: NivelCorreo.dificil,
    asunto: 'Emisión de tu certificado: valor de \$2,50',
    indicios: [Indicio.i10],
  ),
  PlantillaCorreoPrueba(
    id: 'N3-IN-documento',
    tipos: TipoUsuario.internos,
    nivel: NivelCorreo.dificil,
    asunto: 'Nueva política de vacaciones: revisa el documento compartido',
    indicios: [Indicio.i2],
  ),
];
