import 'indicio.dart';
import 'microcurso.dart';
import 'tipo_usuario.dart';

/// Nivel inicial que deja el primer correo de prueba (CLAUDE.md §11).
enum NivelCapacitacion {
  basico('BASICO', 'Básico'),
  intermedio('INTERMEDIO', 'Intermedio'),
  avanzado('AVANZADO', 'Avanzado');

  const NivelCapacitacion(this.codigo, this.etiqueta);

  final String codigo;
  final String etiqueta;
}

/// Reacción al correo de prueba. En el MVP solo se miden dos señales: el clic
/// (el `POST` del botón «Continuar») y el reporte. No se miden aperturas.
enum ResultadoSimulacro {
  pendiente('PENDIENTE'),
  reporto('REPORTO'),
  clic('CLIC'),
  ignoro('IGNORO');

  const ResultadoSimulacro(this.codigo);

  final String codigo;
}

/// Dificultad del correo de prueba (escalera, CLAUDE.md §11).
enum NivelCorreo {
  facil(1, 'Fácil', '4 o más indicios, obvios'),
  medio(2, 'Medio', '2 o 3 indicios'),
  dificil(3, 'Difícil', '1 indicio, sutil');

  const NivelCorreo(this.numero, this.nombre, this.descripcion);

  final int numero;
  final String nombre;
  final String descripcion;

  NivelCorreo get subir => this == facil ? medio : dificil;
  NivelCorreo get bajar => this == dificil ? medio : facil;

  static NivelCorreo desdeNumero(int numero) => values.firstWhere(
    (n) => n.numero == numero,
    orElse: () => throw FormatException('Nivel de correo inválido: $numero'),
  );
}

/// Estado de un indicio en el mapa del usuario (CLAUDE.md §8.2, [DECIDIDO]).
enum EstadoIndicio {
  dominado('DOMINADO', 'Lo dominas'),

  /// Sin culpa: «débil» se muestra como «para practicar».
  debil('DEBIL', 'Para practicar'),
  sinProbar('SIN_PROBAR', 'Sin probar');

  const EstadoIndicio(this.codigo, this.etiquetaVisible);

  final String codigo;
  final String etiquetaVisible;

  static EstadoIndicio desdeCodigo(String codigo) => values.firstWhere(
    (e) => e.codigo == codigo.trim().toUpperCase(),
    orElse: () => throw FormatException('Estado de indicio inválido: $codigo'),
  );
}

/// Mapa de indicios del usuario. Lo que no aparece está SIN_PROBAR.
class MapaIndicios {
  const MapaIndicios([this.estados = const {}]);

  factory MapaIndicios.fromJson(Map<String, dynamic> json) => MapaIndicios({
    for (final e in json.entries)
      if (Indicio.tryDesdeCodigo(e.key) case final indicio?)
        indicio: EstadoIndicio.desdeCodigo(e.value as String),
  });

  final Map<Indicio, EstadoIndicio> estados;

  EstadoIndicio estadoDe(Indicio indicio) =>
      estados[indicio] ?? EstadoIndicio.sinProbar;

  MapaIndicios con(Iterable<Indicio> indicios, EstadoIndicio estado) =>
      MapaIndicios({
        ...estados,
        for (final i in indicios) i: estado,
      });

  /// Indicios que conviene incluir en el siguiente correo: DEBIL o
  /// SIN_PROBAR.
  Set<Indicio> get porPracticar => {
    for (final i in Indicio.values)
      if (estadoDe(i) != EstadoIndicio.dominado) i,
  };

  Set<Indicio> get debiles => {
    for (final i in Indicio.values)
      if (estadoDe(i) == EstadoIndicio.debil) i,
  };

  Map<String, String> toJson() => {
    for (final e in estados.entries) e.key.codigo: e.value.codigo,
  };
}

/// Plantilla de correo de prueba. El contenido es ficticio y se envía desde
/// el dominio de práctica, nunca desde iess.gob.ec (regla 5).
class PlantillaCorreoPrueba {
  const PlantillaCorreoPrueba({
    required this.id,
    required this.tipos,
    required this.nivel,
    required this.asunto,
    required this.indicios,
  });

  final String id;
  final Set<TipoUsuario> tipos;
  final NivelCorreo nivel;
  final String asunto;
  final List<Indicio> indicios;
}

/// Correo de prueba enviado.
class CorreoPrueba {
  const CorreoPrueba({
    required this.simulacroId,
    required this.plantilla,
    required this.nivel,
    required this.enviadoEn,
    required this.venceEn,
    this.resultado = ResultadoSimulacro.pendiente,
  });

  final String simulacroId;
  final PlantillaCorreoPrueba plantilla;
  final NivelCorreo nivel;
  final DateTime enviadoEn;

  /// Fin de la ventana de reacción.
  final DateTime venceEn;
  final ResultadoSimulacro resultado;

  bool get pendiente => resultado == ResultadoSimulacro.pendiente;

  CorreoPrueba conResultado(ResultadoSimulacro nuevo) => CorreoPrueba(
    simulacroId: simulacroId,
    plantilla: plantilla,
    nivel: nivel,
    enviadoEn: enviadoEn,
    venceEn: venceEn,
    resultado: nuevo,
  );
}

/// Lo que ve el usuario después de reaccionar a un correo de prueba.
class DesenlaceSimulacro {
  const DesenlaceSimulacro({
    required this.resultado,
    required this.titulo,
    required this.mensaje,
    required this.indicios,
    this.microcursos = const [],
    this.modulosSugeridos = const [],
  });

  final ResultadoSimulacro resultado;
  final String titulo;
  final String mensaje;

  /// Indicios que tenía el correo.
  final List<Indicio> indicios;

  /// Momento enseñable: microcursos de los indicios que no vio.
  final List<Microcurso> microcursos;
  final List<String> modulosSugeridos;
}

enum FaseCapacitacion {
  noInscrito,

  /// Doble opt-in: falta confirmar el correo (usuario sin cuenta).
  confirmandoCorreo,

  /// Hay un correo de prueba dentro de su ventana de reacción.
  esperandoReaccion,

  /// Entre un correo y el siguiente.
  enCurso,
  pausada,
}

/// Estado de la capacitación del usuario en el flujo «Quiero capacitarme».
class EstadoCapacitacion {
  const EstadoCapacitacion({
    this.fase = FaseCapacitacion.noInscrito,
    this.faseAntesDePausa,
    this.nivelInicial,
    this.nivelCorreo = NivelCorreo.medio,
    this.correoActual,
    this.ultimoDesenlace,
    this.mapa = const MapaIndicios(),
    this.reportesSeguidosNivel3 = 0,
    this.esCentinela = false,
    this.ultimoEnvio,
  });

  final FaseCapacitacion fase;

  /// Fase a la que se vuelve al reanudar.
  final FaseCapacitacion? faseAntesDePausa;

  /// Se fija con la reacción al primer correo.
  final NivelCapacitacion? nivelInicial;

  /// Nivel del próximo correo.
  final NivelCorreo nivelCorreo;
  final CorreoPrueba? correoActual;
  final DesenlaceSimulacro? ultimoDesenlace;
  final MapaIndicios mapa;
  final int reportesSeguidosNivel3;
  final bool esCentinela;
  final DateTime? ultimoEnvio;

  bool get inscrito => fase != FaseCapacitacion.noInscrito;
  bool get pausada => fase == FaseCapacitacion.pausada;

  EstadoCapacitacion copyWith({
    FaseCapacitacion? fase,
    FaseCapacitacion? Function()? faseAntesDePausa,
    NivelCapacitacion? nivelInicial,
    NivelCorreo? nivelCorreo,
    CorreoPrueba? Function()? correoActual,
    DesenlaceSimulacro? Function()? ultimoDesenlace,
    MapaIndicios? mapa,
    int? reportesSeguidosNivel3,
    bool? esCentinela,
    DateTime? ultimoEnvio,
  }) => EstadoCapacitacion(
    fase: fase ?? this.fase,
    faseAntesDePausa: faseAntesDePausa != null
        ? faseAntesDePausa()
        : this.faseAntesDePausa,
    nivelInicial: nivelInicial ?? this.nivelInicial,
    nivelCorreo: nivelCorreo ?? this.nivelCorreo,
    correoActual: correoActual != null ? correoActual() : this.correoActual,
    ultimoDesenlace: ultimoDesenlace != null
        ? ultimoDesenlace()
        : this.ultimoDesenlace,
    mapa: mapa ?? this.mapa,
    reportesSeguidosNivel3:
        reportesSeguidosNivel3 ?? this.reportesSeguidosNivel3,
    esCentinela: esCentinela ?? this.esCentinela,
    ultimoEnvio: ultimoEnvio ?? this.ultimoEnvio,
  );
}

/// Consentimiento del flujo «Quiero capacitarme» (CLAUDE.md §11, paso 1).
class Consentimiento {
  const Consentimiento({required this.version, required this.aceptadoEn});

  static const versionActual = '2026-11-v1';

  /// Qué se mide, con qué frecuencia y cómo salir.
  static const puntos = [
    'Qué medimos: solo si tocas «Continuar» en un correo de práctica o si lo '
        'reportas. No medimos si lo abres.',
    'Con qué frecuencia: como máximo un correo de práctica por semana, y '
        'nunca dos en 48 horas.',
    'Cómo salir: puedes pausar o salir cuando quieras desde la app.',
    'Tus datos: no guardamos tu cédula ni tu nombre en las métricas.',
    'Los correos de práctica nunca llegan desde iess.gob.ec y nunca te piden '
        'claves, datos personales ni pagos reales.',
  ];

  final String version;
  final DateTime aceptadoEn;

  Map<String, dynamic> toJson() => {
    'version': version,
    'aceptado_en': aceptadoEn.toUtc().toIso8601String(),
  };
}
