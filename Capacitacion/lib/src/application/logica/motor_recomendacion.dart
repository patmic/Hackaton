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
/// (CLAUDE.md §10.4), las alertas activas del Observatorio y su progreso.
///
/// Orden de prioridad: alerta activa de la tipología > siguiente paso de la
/// ruta de arranque > ciclo de refuerzo > pendientes. Las completadas bajan,
/// salvo que convenga repasarlas.
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

  List<Recomendacion> recomendar({
    required List<Actividad> actividades,
    required Perfil perfil,
    required Progreso progreso,
    List<AlertaObservatorio> alertas = const [],
    int limite = 3,
  }) {
    final alertasDelUsuario =
        alertas.where((a) => a.afectaA(perfil.rangoEtario)).toList()..sort(
          (a, b) => b.incrementoPorcentaje.compareTo(a.incrementoPorcentaje),
        );
    final plan = PlanCapacitacion.para(
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

      final paso = plan.arranque.indexOf(a.modulo);
      if (paso >= 0) {
        final bono = pesoArranque - paso * pasoArranque;
        puntaje += bono < minimoArranque ? minimoArranque : bono;
        motivos.add('Paso ${paso + 1} de tu ruta de inicio');
      } else if (plan.refuerzo.contains(a.modulo)) {
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
}
