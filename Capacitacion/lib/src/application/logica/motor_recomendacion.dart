import '../../domain/domain.dart';
import 'plan_capacitacion.dart';

/// Actividad sugerida y por qué.
class Recomendacion {
  const Recomendacion({
    required this.actividad,
    required this.puntaje,
    required this.motivos,
    this.alerta,
  });

  final Actividad actividad;
  final int puntaje;
  final List<String> motivos;

  /// Alerta del Observatorio que la originó, si existe.
  final AlertaObservatorio? alerta;
}

/// Ordena las actividades que le corresponden al usuario según su ruta
/// (CLAUDE.md §10.4), las alertas activas del Observatorio, lo que el
/// observador aprendió de la persona ([PlanPersonalizado]) y su progreso.
///
/// Orden de prioridad: alerta activa de la tipología > señal que ya le costó
/// (falencia DEBIL) > siguiente paso de la ruta de arranque > ciclo de
/// refuerzo > pendientes. Las completadas bajan, salvo que convenga
/// repasarlas. Una señal sin probar suma poco: el plan solo manda cuando hay
/// evidencia de la propia persona.
class MotorRecomendacion {
  const MotorRecomendacion();

  static const pesoAlerta = 100;

  /// Primer módulo de la ruta de arranque. Cada paso siguiente vale
  /// [pasoArranque] menos, pero nunca menos que [minimoArranque]: un paso
  /// de arranque siempre pesa más que el refuerzo.
  static const pesoArranque = 80;
  static const pasoArranque = 10;
  static const minimoArranque = pesoRefuerzo + pasoArranque;
  static const pesoRefuerzo = 40;
  static const pesoPendiente = 20;
  static const pesoRepaso = 25;
  static const penalizacionCompletada = 50;
  static const umbralRepaso = 0.5;

  /// La falencia más importante del plan; cada una de las siguientes vale
  /// [pasoFalencia] menos. Incluso la tercera llega al primer paso de
  /// arranque con una señal sin probar: lo que ya le costó gana a la ruta
  /// genérica. No pasa de [pesoAlerta]: una campaña activa va primero.
  static const pesoFalencia = pesoAlerta;
  static const pasoFalencia = 5;

  /// Señal que todavía no se practicó: un empujón para medirla pronto.
  static const pesoSinProbar = 10;

  /// Lección que imita la tipología que más le cuesta.
  static const pesoFoco = 20;

  List<Recomendacion> recomendar({
    required List<Actividad> actividades,
    required Perfil perfil,
    required Progreso progreso,
    List<AlertaObservatorio> alertas = const [],
    PlanPersonalizado? plan,
    int limite = 3,
  }) {
    final alertasDelUsuario =
        alertas.where((a) => a.afectaA(perfil.rangoEtario)).toList()..sort(
          (a, b) => b.incrementoPorcentaje.compareTo(a.incrementoPorcentaje),
        );
    final ruta = PlanCapacitacion.para(
      perfil,
      tipologiaAtacada: alertasDelUsuario.isEmpty
          ? null
          : alertasDelUsuario.first.tipologia,
    );

    final resultado = <Recomendacion>[];
    for (final a in actividades) {
      if (!a.elegiblePara(perfil)) continue;

      var puntaje = 0;
      final motivos = <String>[];

      AlertaObservatorio? alerta;
      for (final candidata in alertasDelUsuario) {
        if (candidata.tipologia == a.tipologia) {
          alerta = candidata;
          break;
        }
      }
      if (alerta != null) {
        puntaje +=
            pesoAlerta + alerta.incrementoPorcentaje.clamp(0, 100).round();
        motivos.add('Alerta activa: ${alerta.mensaje}');
      }

      if (plan != null) {
        puntaje += _aportePlan(a, plan, motivos);
      }

      final paso = ruta.arranque.indexOf(a.modulo);
      if (paso >= 0) {
        final bono = pesoArranque - paso * pasoArranque;
        puntaje += bono < minimoArranque ? minimoArranque : bono;
        motivos.add('Paso ${paso + 1} de tu ruta de inicio');
      } else if (ruta.refuerzo.contains(a.modulo)) {
        puntaje += pesoRefuerzo;
        motivos.add('Refuerzo para tu perfil');
      }

      final mejor = progreso.mejoresPuntajes[a.id];
      if (!progreso.estaCompletada(a.id)) {
        puntaje += pesoPendiente;
        motivos.add('Aún no la has hecho');
      } else if (mejor != null && mejor < umbralRepaso) {
        puntaje += pesoRepaso;
        motivos.add('Te conviene repasarla');
      } else {
        puntaje -= penalizacionCompletada;
      }

      resultado.add(
        Recomendacion(
          actividad: a,
          puntaje: puntaje,
          motivos: motivos,
          alerta: alerta,
        ),
      );
    }

    // Mayor puntaje primero; a igual puntaje, la más corta; al final el id,
    // para que el orden no dependa del algoritmo de ordenamiento.
    resultado.sort((a, b) {
      final porPuntaje = b.puntaje.compareTo(a.puntaje);
      if (porPuntaje != 0) return porPuntaje;
      final porDuracion = a.actividad.duracionSegundos.compareTo(
        b.actividad.duracionSegundos,
      );
      if (porDuracion != 0) return porDuracion;
      return a.actividad.id.compareTo(b.actividad.id);
    });
    return resultado.where((r) => r.puntaje > 0).take(limite).toList();
  }

  /// Cuánto suma la actividad por trabajar lo que el plan dice que conviene
  /// practicar. Cuenta la falencia más importante que trabaja (no todas, para
  /// no premiar a la que solo junta muchas señales).
  static int _aportePlan(
    Actividad a,
    PlanPersonalizado plan,
    List<String> motivos,
  ) {
    final senales = {...a.indicios, ...a.contenido.indiciosUsados};
    var puntaje = 0;
    String? motivo;
    for (final (orden, f) in plan.falencias.indexed) {
      if (!senales.contains(f.indicio)) continue;
      // DEBIL, o DOMINADO que toca repasar, pesan según su orden en el plan.
      final valor = f.estado == EstadoIndicio.sinProbar
          ? pesoSinProbar
          : pesoFalencia - orden * pasoFalencia;
      if (valor <= puntaje) continue;
      puntaje = valor;
      motivo = switch (f.estado) {
        EstadoIndicio.sinProbar =>
          'Practica una señal nueva para ti: ${f.indicio.nombre}',
        EstadoIndicio.debil => 'Te conviene practicar: ${f.indicio.nombre}',
        EstadoIndicio.dominado => 'Repasa: ${f.indicio.nombre}',
      };
    }
    if (motivo != null) motivos.add(motivo);
    if (plan.foco != null && a.tipologia == plan.foco) {
      puntaje += pesoFoco;
      motivos.add('Imita los correos que más te cuestan: ${plan.foco!.nombre}');
    }
    return puntaje;
  }
}
