import 'mecanica.dart';
import 'perfil_conducta.dart';
import 'tipo_usuario.dart';

/// Módulo de capacitación (CLAUDE.md §10.2).
class Modulo {
  const Modulo({
    required this.codigo,
    required this.nombre,
    required this.nivel,
    required this.tipos,
    required this.minutos,
    required this.objetivo,
    required this.mecanicas,
    this.incluyeCentinelas = false,
  });

  /// M1…M14.
  final String codigo;
  final String nombre;

  /// 1 (básico) a 4 (avanzado).
  final int nivel;
  final Set<TipoUsuario> tipos;

  /// Duración aproximada. En M7 es por pieza.
  final int minutos;
  final String objetivo;

  /// Mecánicas con las que se arman sus actividades.
  final List<Mecanica> mecanicas;

  /// M10 y M14 también se ofrecen a quien tiene perfil Centinela.
  final bool incluyeCentinelas;

  bool dirigidoA(Set<TipoUsuario> tiposUsuario, PerfilConducta perfil) =>
      tipos.any(tiposUsuario.contains) ||
      (incluyeCentinelas && perfil == PerfilConducta.centinela);

  static Modulo porCodigo(String codigo) => catalogoModulos.firstWhere(
    (m) => m.codigo == codigo.trim().toUpperCase(),
    orElse: () => throw FormatException('Módulo desconocido: $codigo'),
  );
}

/// Los 14 módulos de CLAUDE.md §10.2.
const List<Modulo> catalogoModulos = [
  Modulo(
    codigo: 'M1',
    nombre: 'Señales universales',
    nivel: 1,
    tipos: TipoUsuario.todos,
    minutos: 3,
    objetivo:
        'Nombrar urgencia, pedido de claves o dinero, remitente raro, '
        'enlace o QR externo.',
    mecanicas: [Mecanica.a1, Mecanica.a2],
  ),
  Modulo(
    codigo: 'M2',
    nombre: 'Tu canal oficial',
    nivel: 1,
    tipos: {
      TipoUsuario.ex1,
      TipoUsuario.ex2,
      TipoUsuario.ex3,
      TipoUsuario.ex4,
      TipoUsuario.in1,
    },
    minutos: 3,
    objetivo: 'Verificar en la bandeja espejo y con el sello.',
    mecanicas: [Mecanica.a6],
  ),
  Modulo(
    codigo: 'M3',
    nombre: 'Reportar en un toque',
    nivel: 1,
    tipos: TipoUsuario.todos,
    minutos: 2,
    objetivo: 'Reportar desde la app o reenviando el correo.',
    mecanicas: [Mecanica.a3],
  ),
  Modulo(
    codigo: 'M4',
    nombre: 'Estafas financieras (T2)',
    nivel: 2,
    tipos: {TipoUsuario.ex1, TipoUsuario.ex2},
    minutos: 4,
    objetivo: 'Reconocer reembolsos, bloqueos y créditos BIESS falsos.',
    mecanicas: [Mecanica.a4, Mecanica.a2],
  ),
  Modulo(
    codigo: 'M5',
    nombre: 'Trámites y salud (T3)',
    nivel: 2,
    tipos: {TipoUsuario.ex1, TipoUsuario.ex2, TipoUsuario.ex4},
    minutos: 3,
    objetivo: 'Distinguir citas y certificados reales.',
    mecanicas: [Mecanica.a1, Mecanica.a3],
  ),
  Modulo(
    codigo: 'M6',
    nombre: 'Comunicados falsos y QR (T1)',
    nivel: 2,
    tipos: TipoUsuario.externos,
    minutos: 3,
    objetivo: 'No abrir páginas desde un QR.',
    mecanicas: [Mecanica.a1, Mecanica.a6],
  ),
  Modulo(
    codigo: 'M7',
    nombre: 'Pensión segura',
    nivel: 3,
    tipos: {TipoUsuario.ex2},
    minutos: 1,
    objetivo: 'Ante urgencia sobre la pensión, parar y verificar.',
    mecanicas: [Mecanica.a7, Mecanica.a5],
  ),
  Modulo(
    codigo: 'M8',
    nombre: 'Obligaciones patronales seguras',
    nivel: 3,
    tipos: {TipoUsuario.ex3},
    minutos: 4,
    objetivo: 'Verificar glosas, multas y planillas.',
    mecanicas: [Mecanica.a3, Mecanica.a4],
  ),
  Modulo(
    codigo: 'M9',
    nombre: 'Pagos sin tramitadores',
    nivel: 3,
    tipos: {TipoUsuario.ex4},
    minutos: 4,
    objetivo: 'Rechazar comisiones por gestionar pagos.',
    mecanicas: [Mecanica.a4, Mecanica.a3],
  ),
  Modulo(
    codigo: 'M10',
    nombre: 'Cuida a los tuyos',
    nivel: 3,
    tipos: {TipoUsuario.ex5},
    minutos: 4,
    objetivo: 'Configurar el código antiphishing a un familiar.',
    mecanicas: [Mecanica.a5],
    incluyeCentinelas: true,
  ),
  Modulo(
    codigo: 'M11',
    nombre: 'Defiende tu cuenta institucional',
    nivel: 3,
    tipos: TipoUsuario.internos,
    minutos: 5,
    objetivo: 'Reportar simulacros y proteger credenciales.',
    mecanicas: [Mecanica.a8, Mecanica.a3],
  ),
  Modulo(
    codigo: 'M12',
    nombre: 'Emisión segura',
    nivel: 3,
    tipos: {TipoUsuario.in2},
    minutos: 5,
    objetivo: 'Emitir solo la tipología permitida.',
    mecanicas: [Mecanica.a3, Mecanica.a8],
  ),
  Modulo(
    codigo: 'M13',
    nombre: 'Respuesta a campañas',
    nivel: 3,
    tipos: {TipoUsuario.in3, TipoUsuario.in4},
    minutos: 30,
    objetivo: 'Detectar, segmentar y alertar (ejercicio de mesa).',
    mecanicas: [Mecanica.a9],
  ),
  Modulo(
    codigo: 'M14',
    nombre: 'Centinela: ataques avanzados',
    nivel: 4,
    tipos: {},
    minutos: 5,
    objetivo: 'Suplantación con IA y por WhatsApp.',
    mecanicas: [Mecanica.a4, Mecanica.a5],
    incluyeCentinelas: true,
  ),
];
