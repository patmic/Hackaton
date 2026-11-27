import 'capacitacion.dart';
import 'perfil.dart';
import 'perfil_conducta.dart';
import 'rango_etario.dart';
import 'tipo_usuario.dart';

/// Tipos de evento de `POST /api/v1/eventos` (CLAUDE.md §12).
enum TipoEvento {
  actividadIniciada('ACTIVIDAD_INICIADA'),
  senalEncontrada('SENAL_ENCONTRADA'),
  decisionTomada('DECISION_TOMADA'),
  actividadCompletada('ACTIVIDAD_COMPLETADA'),
  respuestaEvaluacion('RESPUESTA_EVALUACION'),
  simulacroResultado('SIMULACRO_RESULTADO');

  const TipoEvento(this.codigo);

  final String codigo;
}

/// Contexto anónimo que acompaña a cada evento: tipo, perfil y segmento.
/// Nunca lleva cédula, nombre, correo ni `id_seudonimo` (regla 3).
class ContextoEvento {
  const ContextoEvento({
    required this.tipos,
    required this.perfilConducta,
    this.rangoEtario,
    this.esCuidador = false,
  });

  factory ContextoEvento.desdePerfil(Perfil perfil) => ContextoEvento(
    tipos: perfil.tipos,
    perfilConducta: perfil.perfilConducta,
    rangoEtario: perfil.rangoEtario,
    esCuidador: perfil.esCuidador,
  );

  static const canal = 'APP';

  final Set<TipoUsuario> tipos;
  final PerfilConducta perfilConducta;
  final RangoEtario? rangoEtario;
  final bool esCuidador;

  Map<String, dynamic> toJson() => {
    'tipo_usuario': [
      for (final t in TipoUsuario.values)
        if (tipos.contains(t)) t.codigo,
    ],
    'perfil_conducta': perfilConducta.codigo,
    'rango_etario': rangoEtario?.codigo,
    'es_cuidador': esCuidador,
    'canal': canal,
  };
}

/// Evento de la app para el Observatorio.
class EventoApp {
  const EventoApp({
    required this.tipo,
    required this.datos,
    required this.momento,
    this.contexto,
  });

  factory EventoApp.actividadIniciada({
    required String actividadId,
    required String modulo,
    required DateTime momento,
  }) => EventoApp(
    tipo: TipoEvento.actividadIniciada,
    datos: {'actividad_id': actividadId, 'modulo': modulo},
    momento: momento,
  );

  factory EventoApp.senalEncontrada({
    required String senalId,
    required int segundosDesdeInicio,
    required DateTime momento,
  }) => EventoApp(
    tipo: TipoEvento.senalEncontrada,
    datos: {'senal_id': senalId, 'segundos_desde_inicio': segundosDesdeInicio},
    momento: momento,
  );

  factory EventoApp.decisionTomada({
    required String itemId,
    required String opcion,
    required bool esCorrecta,
    required DateTime momento,
  }) => EventoApp(
    tipo: TipoEvento.decisionTomada,
    datos: {'item_id': itemId, 'opcion': opcion, 'es_correcta': esCorrecta},
    momento: momento,
  );

  factory EventoApp.actividadCompletada({
    required String actividadId,
    required int aciertos,
    required int total,
    required int duracionSeg,
    required DateTime momento,
  }) => EventoApp(
    tipo: TipoEvento.actividadCompletada,
    datos: {
      'actividad_id': actividadId,
      'aciertos': aciertos,
      'total': total,
      'duracion_seg': duracionSeg,
    },
    momento: momento,
  );

  factory EventoApp.simulacroResultado({
    required String simulacroId,
    required ResultadoSimulacro resultado,
    required DateTime momento,
  }) => EventoApp(
    tipo: TipoEvento.simulacroResultado,
    datos: {'simulacro_id': simulacroId, 'resultado': resultado.codigo},
    momento: momento,
  );

  final TipoEvento tipo;
  final Map<String, Object> datos;
  final DateTime momento;
  final ContextoEvento? contexto;

  EventoApp conContexto(ContextoEvento nuevo) =>
      EventoApp(tipo: tipo, datos: datos, momento: momento, contexto: nuevo);

  Map<String, dynamic> toJson() => {
    'evento': tipo.codigo,
    'momento': momento.toUtc().toIso8601String(),
    ...?contexto?.toJson(),
    'datos': datos,
  };
}
