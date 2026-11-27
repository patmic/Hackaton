import 'dart:math' as math;

import '../../domain/domain.dart';

/// El observador en el dispositivo: aprende de las prácticas de la persona
/// y arma su plan cuando el Radar Phishing (el observador del servidor) no
/// está configurado, no responde o la persona no quiere compartir.
///
/// Es el mismo modelo de `Analisis-de-comportamiento/observador/modelo.py`,
/// para que el mapa de indicios coincida en la app y en el servidor (una
/// prueba lo compara con `contrato/plan.ejemplo.json`):
///
/// - Cada juicio deja evidencia de acierto o de fallo sobre los indicios del
///   correo o del ítem. Reportar un correo difícil pesa más que uno fácil;
///   caer en uno fácil pesa más que en uno difícil. Practicar en la app pesa
///   la mitad que la conducta real.
/// - La evidencia pierde la mitad de su peso cada 60 días (olvido).
/// - Dominio = media de una Beta(0,5 + aciertos, 0,5 + fallos).
///
/// La prioridad es la de `plan.py` sin lo aprendido de la población:
/// `riesgo × relevancia + exploración + repaso`. Lo que ya le engañó tiene
/// relevancia máxima; lo demás, según cuánto aparece en las lecciones de su
/// ruta.
class ObservadorLocal {
  const ObservadorLocal();

  static const vidaMediaDias = 60.0;
  static const pesoAcierto = {1: 0.6, 2: 1.0, 3: 1.4};
  static const pesoFallo = {1: 1.4, 2: 1.0, 3: 0.6};
  static const factorImplicito = 0.5;
  static const pesoActividad = 0.5;
  static const evidenciaMinima = 0.25;
  static const umbralDominado = 0.6;
  static const bonoExploracion = 0.1;
  static const bonoRepaso = 0.1;
  static const maxFalencias = 3;

  static double factorOlvido(DateTime momento, DateTime ahora) {
    final dias = math.max(0, ahora.difference(momento).inMilliseconds) / 864e5;
    return math.pow(0.5, dias / vidaMediaDias).toDouble();
  }

  /// Evidencia (ya con olvido) por indicio.
  Map<Indicio, EvidenciaIndicio> evidencia(
    List<ObservacionConducta> observaciones,
    DateTime ahora,
  ) {
    final ev = {for (final i in Indicio.values) i: EvidenciaIndicio()};
    for (final o in observaciones) {
      final f = factorOlvido(o.momento, ahora);
      for (final (indicio, acierto, fallo) in _aportes(o)) {
        ev[indicio]!.sumar(acierto * f, fallo * f, o.momento);
      }
    }
    return ev;
  }

  /// Estado visible de cada indicio: sale solo de las acciones de la persona.
  Map<Indicio, EstadoIndicio> estados(
    List<ObservacionConducta> observaciones,
    DateTime ahora,
  ) => {
    for (final e in evidencia(observaciones, ahora).entries)
      e.key: e.value.estado,
  };

  PlanPersonalizado plan({
    required String idSeudonimo,
    required List<ObservacionConducta> observaciones,
    required DateTime ahora,
    required Set<TipoUsuario> tipos,
    List<Actividad> actividades = const [],
  }) {
    final ev = evidencia(observaciones, ahora);
    final exposicion = _exposicion(actividades);
    final conteos = _conteos(observaciones);

    final priorizados = <(double, Indicio)>[];
    for (final i in Indicio.values) {
      final e = ev[i]!;
      // Lo que ya le engañó es relevante para la persona, se use mucho o
      // poco en sus lecciones: su propia evidencia manda.
      final relevancia = e.fallo > 0 ? 1.0 : 0.5 + 0.5 * (exposicion[i] ?? 0);
      var p = (1 - e.dominio) * relevancia;
      if (e.estado == EstadoIndicio.sinProbar) p += bonoExploracion;
      if (e.repasar(ahora)) p += bonoRepaso;
      priorizados.add((p, i));
    }
    priorizados.sort((a, b) {
      final c = b.$1.compareTo(a.$1);
      return c != 0 ? c : a.$2.index.compareTo(b.$2.index);
    });

    final falencias = <FalenciaPlan>[];
    for (final (prioridad, i) in priorizados) {
      final e = ev[i]!;
      final repasar = e.repasar(ahora);
      if (e.estado == EstadoIndicio.dominado && !repasar) continue;
      final c = conteos[i]!;
      falencias.add(
        FalenciaPlan(
          indicio: i,
          estado: e.estado,
          prioridad: prioridad,
          modulo: Microcurso.paraIndicio(i).moduloPara(tipos),
          motivos: [
            if (c.clics > 0)
              'Hiciste clic ${c.clics == 1 ? 'una vez' : '${c.clics} veces'} '
                  'en correos de práctica que lo tenían.',
            if (c.erroresPractica > 0)
              'En las actividades se te pasó en algún caso.',
            if (repasar)
              'Lo dominabas, pero hace más de dos meses que no lo practicas.',
            if (e.estado == EstadoIndicio.sinProbar)
              'Todavía no lo hemos practicado contigo.',
          ],
        ),
      );
      if (falencias.length == maxFalencias) break;
    }

    final n = observaciones.length;
    final juicios = observaciones.where(_esJuicio).toList();
    final aciertos = juicios.where(_juicioCorrecto).length;
    final foco = _foco(observaciones, ahora);
    final confianza = n < 3
        ? 'BAJA'
        : n < 10
        ? 'MEDIA'
        : 'ALTA';
    return PlanPersonalizado(
      idSeudonimo: idSeudonimo,
      origen: OrigenPlan.dispositivo,
      falencias: falencias,
      mapa: MapaIndicios({for (final e in ev.entries) e.key: e.value.estado}),
      foco: foco,
      focoMotivo: foco == null
          ? null
          : 'Es la que más te ha costado reconocer cuando la imitan.',
      confianza: confianza,
      nota: confianza == 'BAJA'
          ? 'Con pocas prácticas todavía, el plan empieza por las señales de '
                'tus lecciones.'
          : 'El plan se basa en $n prácticas tuyas.',
      mensaje: falencias.isEmpty
          ? '¡Vas muy bien! Reconoces todas las señales que hemos practicado. '
                'Seguiremos con casos más sutiles.'
          : 'Esto es lo que más te conviene practicar ahora. Equivocarse en '
                'una práctica es parte de aprender: no tiene consecuencias.',
      observaciones: n,
      precision: juicios.isEmpty ? null : aciertos / juicios.length,
    );
  }

  // ------------------------------------------------------------ detalle

  static Iterable<(Indicio, double, double)> _aportes(
    ObservacionConducta o,
  ) sync* {
    if (o.tipo == TipoObservacion.simulacro &&
        (o.resultado == ResultadoSimulacro.reporto ||
            o.resultado == ResultadoSimulacro.clic)) {
      final nivel = o.nivel ?? 2;
      final reporto = o.resultado == ResultadoSimulacro.reporto;
      final peso = (reporto ? pesoAcierto : pesoFallo)[nivel] ?? 1.0;
      for (final i in o.indicios) {
        yield reporto ? (i, peso, 0.0) : (i, 0.0, peso);
      }
      final implicito = peso * factorImplicito;
      for (final i in o.indiciosImplicitos) {
        yield reporto ? (i, implicito, 0.0) : (i, 0.0, implicito);
      }
    } else if (o.tipo == TipoObservacion.decision && o.esEstafa == true) {
      for (final i in o.indicios) {
        yield o.acerto == true
            ? (i, pesoActividad, 0.0)
            : (i, 0.0, pesoActividad);
      }
    }
    // IGNORO no dice si vio los indicios (no se miden aperturas, §11); un
    // correo legítimo no trae indicios; verificar es un hábito, no dominio.
  }

  static bool _esJuicio(ObservacionConducta o) =>
      o.tipo == TipoObservacion.decision ||
      (o.tipo == TipoObservacion.simulacro &&
          (o.resultado == ResultadoSimulacro.reporto ||
              o.resultado == ResultadoSimulacro.clic));

  static bool _juicioCorrecto(ObservacionConducta o) =>
      o.tipo == TipoObservacion.decision
      ? o.acerto == true
      : o.resultado == ResultadoSimulacro.reporto;

  /// Qué tanto aparece cada indicio en las lecciones de su ruta (0 a 1).
  static Map<Indicio, double> _exposicion(List<Actividad> actividades) {
    final crudo = {for (final i in Indicio.values) i: 0.0};
    for (final a in actividades) {
      for (final i in {...a.indicios, ...a.contenido.indiciosUsados}) {
        crudo[i] = crudo[i]! + 1;
      }
    }
    final maximo = crudo.values.fold(0.0, math.max);
    return maximo == 0
        ? crudo
        : {for (final e in crudo.entries) e.key: e.value / maximo};
  }

  static Map<Indicio, ({int clics, int erroresPractica})> _conteos(
    List<ObservacionConducta> observaciones,
  ) {
    final clics = {for (final i in Indicio.values) i: 0};
    final errores = {for (final i in Indicio.values) i: 0};
    for (final o in observaciones) {
      if (o.tipo == TipoObservacion.simulacro &&
          o.resultado == ResultadoSimulacro.clic) {
        for (final i in o.indicios) {
          clics[i] = clics[i]! + 1;
        }
      } else if (o.tipo == TipoObservacion.decision &&
          o.esEstafa == true &&
          o.acerto == false) {
        for (final i in o.indicios) {
          errores[i] = errores[i]! + 1;
        }
      }
    }
    return {
      for (final i in Indicio.values)
        i: (clics: clics[i]!, erroresPractica: errores[i]!),
    };
  }

  /// La tipología con más riesgo entre las que ya le costaron alguna vez.
  static Tipologia? _foco(
    List<ObservacionConducta> observaciones,
    DateTime ahora,
  ) {
    final ev = <Tipologia, EvidenciaIndicio>{};
    for (final o in observaciones) {
      final t = o.tipologia;
      if (t == null) continue;
      final f = factorOlvido(o.momento, ahora);
      if (o.tipo == TipoObservacion.simulacro &&
          (o.resultado == ResultadoSimulacro.reporto ||
              o.resultado == ResultadoSimulacro.clic)) {
        final reporto = o.resultado == ResultadoSimulacro.reporto;
        final peso = (reporto ? pesoAcierto : pesoFallo)[o.nivel ?? 2] ?? 1.0;
        ev
            .putIfAbsent(t, EvidenciaIndicio.new)
            .sumar(reporto ? peso * f : 0, reporto ? 0 : peso * f, o.momento);
      } else if (o.tipo == TipoObservacion.decision && o.esEstafa == true) {
        final ok = o.acerto == true;
        ev
            .putIfAbsent(t, EvidenciaIndicio.new)
            .sumar(
              ok ? pesoActividad * f : 0,
              ok ? 0 : pesoActividad * f,
              o.momento,
            );
      }
    }
    Tipologia? mejor;
    var riesgo = -1.0;
    for (final e in ev.entries) {
      if (e.value.fallo <= 0 || e.value.total < evidenciaMinima) continue;
      final r = 1 - e.value.dominio;
      if (r > riesgo) {
        riesgo = r;
        mejor = e.key;
      }
    }
    return mejor;
  }
}

/// Evidencia acumulada sobre un indicio o una tipología.
class EvidenciaIndicio {
  double acierto = 0;
  double fallo = 0;
  DateTime? ultima;

  double get total => acierto + fallo;

  /// Probabilidad estimada de reconocerlo: Beta(0,5 + acierto, 0,5 + fallo).
  double get dominio => (0.5 + acierto) / (1 + acierto + fallo);

  EstadoIndicio get estado => total < ObservadorLocal.evidenciaMinima
      ? EstadoIndicio.sinProbar
      : dominio >= ObservadorLocal.umbralDominado
      ? EstadoIndicio.dominado
      : EstadoIndicio.debil;

  /// Lo dominaba, pero la evidencia ya tiene más de dos meses.
  bool repasar(DateTime ahora) =>
      ultima != null &&
      acierto > fallo &&
      ahora.difference(ultima!) > const Duration(days: 60); // = vidaMediaDias

  void sumar(double a, double f, DateTime momento) {
    acierto += a;
    fallo += f;
    if (ultima == null || momento.isAfter(ultima!)) ultima = momento;
  }
}
