import 'capacitacion.dart';
import 'indicio.dart';
import 'json.dart';
import 'microcurso.dart';
import 'rango_etario.dart';
import 'tipo_usuario.dart';
import 'tipologia.dart';
import 'verificacion.dart';

/// Lo que la persona hizo en una práctica, con el contrato del observador
/// (Radar Phishing · `Analisis-de-comportamiento/contrato/observacion_*.json`).
///
/// Solo lleva códigos (indicios, tipología, nivel, resultado). Nunca cédula,
/// nombre ni correo (regla 3). El `id_seudonimo` se añade al enviarla.
class ObservacionConducta {
  const ObservacionConducta._({
    required this.tipo,
    required this.momento,
    this.indicios = const [],
    this.indiciosImplicitos = const [],
    this.tipologia,
    this.actividadId,
    this.itemId,
    this.esEstafa,
    this.acerto,
    this.plantillaId,
    this.nivel,
    this.resultado,
    this.semaforo,
  });

  /// Un juicio dentro de una actividad: una tarjeta de «¿Real o estafa?» o
  /// una señal de «Caza la señal».
  factory ObservacionConducta.decision({
    required String actividadId,
    required String itemId,
    required bool esEstafa,
    required bool acerto,
    required List<Indicio> indicios,
    required DateTime momento,
    Tipologia? tipologia,
  }) => ObservacionConducta._(
    tipo: TipoObservacion.decision,
    momento: momento,
    actividadId: actividadId,
    itemId: itemId,
    esEstafa: esEstafa,
    acerto: acerto,
    indicios: indicios,
    tipologia: tipologia,
  );

  /// Reacción a un correo de prueba de «Quiero capacitarme».
  factory ObservacionConducta.simulacro({
    required CorreoPrueba correo,
    required ResultadoSimulacro resultado,
    required DateTime momento,
  }) => ObservacionConducta._(
    tipo: TipoObservacion.simulacro,
    momento: momento,
    plantillaId: correo.plantilla.id,
    nivel: correo.nivel.numero,
    resultado: resultado,
    indicios: correo.plantilla.indicios,
    indiciosImplicitos: [
      for (final i in Indicio.values)
        if (correo.plantilla.indiciosImplicitos.contains(i) &&
            !correo.plantilla.indicios.contains(i))
          i,
    ],
    tipologia: correo.plantilla.tipologiaSuplantada,
  );

  /// La persona verificó un correo antes de actuar.
  factory ObservacionConducta.verificacion({
    required Semaforo semaforo,
    required DateTime momento,
    Tipologia? tipologia,
  }) => ObservacionConducta._(
    tipo: TipoObservacion.verificacion,
    momento: momento,
    semaforo: semaforo,
    tipologia: tipologia,
  );

  factory ObservacionConducta.fromJson(Map<String, dynamic> json) {
    List<Indicio> indicios(String campo) => [
      for (final c in listaDeTextos(json[campo])) ?Indicio.tryDesdeCodigo(c),
    ];
    final tipologia = json['tipologia'] as String?;
    final resultado = json['resultado'] as String?;
    final semaforo = json['semaforo'] as String?;
    return ObservacionConducta._(
      tipo: TipoObservacion.desdeCodigo(json['tipo'] as String),
      momento: DateTime.parse(json['momento'] as String),
      indicios: indicios('indicios'),
      indiciosImplicitos: indicios('indicios_implicitos'),
      tipologia: tipologia == null ? null : Tipologia.tryDesdeCodigo(tipologia),
      actividadId: json['actividad_id'] as String?,
      itemId: json['item_id'] as String?,
      esEstafa: json['es_estafa'] as bool?,
      acerto: json['acerto'] as bool?,
      plantillaId: json['plantilla_id'] as String?,
      nivel: json['nivel'] as int?,
      resultado: resultado == null
          ? null
          : ResultadoSimulacro.values.firstWhere(
              (r) => r.codigo == resultado,
              orElse: () => ResultadoSimulacro.ignoro,
            ),
      semaforo: semaforo == null ? null : Semaforo.desdeCodigo(semaforo),
    );
  }

  final TipoObservacion tipo;
  final DateTime momento;

  /// Indicios presentes en el correo o en el ítem. Vacío si era legítimo.
  final List<Indicio> indicios;

  /// Solo SIMULACRO: I7 e I2 de todo correo de práctica (pesan la mitad).
  final List<Indicio> indiciosImplicitos;
  final Tipologia? tipologia;

  // DECISION
  final String? actividadId;
  final String? itemId;
  final bool? esEstafa;
  final bool? acerto;

  // SIMULACRO
  final String? plantillaId;
  final int? nivel;
  final ResultadoSimulacro? resultado;

  // VERIFICACION
  final Semaforo? semaforo;

  /// JSON del contrato del observador. Sin [idSeudonimo] es el formato con
  /// el que se guarda en el dispositivo.
  Map<String, dynamic> toJson({
    String? idSeudonimo,
    Set<TipoUsuario> tipos = const {},
    RangoEtario? rangoEtario,
  }) => {
    'id_seudonimo': ?idSeudonimo,
    'tipo': tipo.codigo,
    'momento': momento.toUtc().toIso8601String(),
    if (tipos.isNotEmpty)
      'tipos': [
        for (final t in TipoUsuario.values)
          if (tipos.contains(t)) t.codigo,
      ],
    'rango_etario': ?rangoEtario?.codigo,
    if (indicios.isNotEmpty) 'indicios': [for (final i in indicios) i.codigo],
    if (indiciosImplicitos.isNotEmpty)
      'indicios_implicitos': [for (final i in indiciosImplicitos) i.codigo],
    'tipologia': ?tipologia?.codigo,
    'actividad_id': ?actividadId,
    'item_id': ?itemId,
    'es_estafa': ?esEstafa,
    'acerto': ?acerto,
    'plantilla_id': ?plantillaId,
    'nivel': ?nivel,
    'resultado': ?resultado?.codigo,
    'semaforo': ?semaforo?.codigo,
  };
}

enum TipoObservacion {
  simulacro('SIMULACRO'),
  decision('DECISION'),
  verificacion('VERIFICACION');

  const TipoObservacion(this.codigo);

  final String codigo;

  static TipoObservacion desdeCodigo(String codigo) => values.firstWhere(
    (t) => t.codigo == codigo.trim().toUpperCase(),
    orElse: () => throw FormatException('Tipo de observación: $codigo'),
  );
}

/// De dónde salió el plan.
enum OrigenPlan {
  /// Del observador del servidor (Radar Phishing): usa también lo que
  /// aprendió de personas con el mismo tipo de cuenta.
  servidor,

  /// Calculado en el dispositivo con las prácticas de la persona.
  dispositivo,
}

/// Un indicio que conviene practicar y por qué.
class FalenciaPlan {
  const FalenciaPlan({
    required this.indicio,
    required this.estado,
    required this.prioridad,
    this.motivos = const [],
    this.modulo,
  });

  factory FalenciaPlan.fromJson(Map<String, dynamic> json) {
    final micro = json['microcurso'] as Map<String, dynamic>?;
    return FalenciaPlan(
      indicio: Indicio.desdeCodigo(json['indicio'] as String),
      estado: EstadoIndicio.desdeCodigo(json['estado'] as String),
      prioridad: (json['prioridad'] as num?)?.toDouble() ?? 0,
      motivos: listaDeTextos(json['motivos']),
      modulo: micro?['modulo'] as String?,
    );
  }

  final Indicio indicio;
  final EstadoIndicio estado;
  final double prioridad;

  /// Por qué está en el plan, en lenguaje sin culpa (regla 7).
  final List<String> motivos;

  /// Módulo del microcurso del indicio (CLAUDE.md §11).
  final String? modulo;

  Microcurso get microcurso => Microcurso.paraIndicio(indicio);
}

/// Plan personalizado según las falencias de la persona:
/// `GET /api/v1/observatorio/personas/{id}/plan` o su cálculo en el
/// dispositivo ([OrigenPlan.dispositivo]).
class PlanPersonalizado {
  const PlanPersonalizado({
    required this.idSeudonimo,
    required this.origen,
    this.falencias = const [],
    this.mapa = const MapaIndicios(),
    this.foco,
    this.focoMotivo,
    this.perfilEtiqueta,
    this.perfilMotivo,
    this.ritmo,
    this.confianza = 'BAJA',
    this.nota = '',
    this.mensaje = '',
    this.observaciones = 0,
    this.precision,
  });

  /// Lee el plan del observador. Un indicio o una tipología que la app no
  /// conoce se ignora.
  factory PlanPersonalizado.fromJson(
    Map<String, dynamic> json, {
    OrigenPlan origen = OrigenPlan.servidor,
  }) {
    final foco = json['foco_tipologia'] as Map<String, dynamic>?;
    final perfil = json['perfil_conducta'] as Map<String, dynamic>?;
    final confianza = json['confianza'] as Map<String, dynamic>? ?? const {};
    final metricas = json['metricas'] as Map<String, dynamic>? ?? const {};
    final ritmo = json['ritmo'] as Map<String, dynamic>?;
    return PlanPersonalizado(
      idSeudonimo: json['id_seudonimo'] as String,
      origen: origen,
      falencias: [
        for (final f in listaDeMapas(json['falencias']))
          if (Indicio.tryDesdeCodigo(f['indicio'] as String? ?? '') != null)
            FalenciaPlan.fromJson(f),
      ],
      mapa: MapaIndicios({
        for (final i in listaDeMapas(json['indicios']))
          ?Indicio.tryDesdeCodigo(i['indicio'] as String? ?? ''):
              EstadoIndicio.desdeCodigo(i['estado'] as String),
      }),
      foco: foco == null
          ? null
          : Tipologia.tryDesdeCodigo(foco['tipologia'] as String? ?? ''),
      focoMotivo: foco?['motivo'] as String?,
      perfilEtiqueta: perfil?['etiqueta'] as String?,
      perfilMotivo: perfil?['motivo'] as String?,
      ritmo: ritmo?['descripcion'] as String?,
      confianza: confianza['nivel'] as String? ?? 'BAJA',
      nota: confianza['nota'] as String? ?? '',
      mensaje: json['mensaje'] as String? ?? '',
      observaciones: confianza['observaciones'] as int? ?? 0,
      precision: (metricas['precision'] as num?)?.toDouble(),
    );
  }

  /// Código de capacitación: aleatorio, no sale de datos personales. Con él,
  /// la propia persona puede ver su plan en el Radar Phishing.
  final String idSeudonimo;
  final OrigenPlan origen;

  /// Hasta 3 indicios, del más al menos conveniente de practicar.
  final List<FalenciaPlan> falencias;

  /// Estado de cada indicio, solo con las acciones de la persona.
  final MapaIndicios mapa;

  /// Tipología que más le ha costado reconocer cuando la imitan.
  final Tipologia? foco;
  final String? focoMotivo;

  /// Perfil de conducta visible («En aprendizaje», nunca «Expuesto»).
  final String? perfilEtiqueta;
  final String? perfilMotivo;
  final String? ritmo;

  /// BAJA, MEDIA o ALTA, según cuántas observaciones hay.
  final String confianza;
  final String nota;
  final String mensaje;
  final int observaciones;

  /// Aciertos ÷ juicios (null si aún no hay juicios).
  final double? precision;

  bool get sinDatos => observaciones == 0;

  /// Indicios que la persona ya probó y le costaron (no los SIN_PROBAR).
  Set<Indicio> get debiles => {
    for (final f in falencias)
      if (f.estado == EstadoIndicio.debil) f.indicio,
  };
}
