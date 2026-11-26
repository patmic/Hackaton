import '../../domain/domain.dart';

/// Cápsula sugerida y por qué.
class Recomendacion {
  const Recomendacion({
    required this.capsula,
    required this.puntaje,
    required this.motivos,
    this.alerta,
  });

  final Capsula capsula;
  final int puntaje;
  final List<String> motivos;

  /// Alerta del Observatorio que la originó, si existe.
  final AlertaObservatorio? alerta;
}

/// Ordena las cápsulas según el perfil, el progreso y las alertas activas
/// del Observatorio (motor de hipersegmentación del lado del usuario).
class MotorRecomendacion {
  const MotorRecomendacion();

  static const pesoAlerta = 100;
  static const pesoRango = 30;
  static const pesoGeneral = 10;
  static const pesoPendiente = 20;
  static const penalizacionCompletada = 50;
  static const pesoAudioAdultoMayor = 15;
  static const pesoRepaso = 25;
  static const umbralRepaso = 0.5;

  List<Recomendacion> recomendar({
    required List<Capsula> capsulas,
    required Perfil perfil,
    required Progreso progreso,
    List<AlertaObservatorio> alertas = const [],
    int limite = 3,
  }) {
    final rango = perfil.rangoEtario;
    final resultado = <Recomendacion>[];

    for (final c in capsulas) {
      // Si conocemos el rango, no sugerimos cápsulas dirigidas a otros.
      if (rango != null && !c.dirigidaA(rango)) continue;

      var puntaje = 0;
      final motivos = <String>[];
      AlertaObservatorio? alertaAplicada;

      for (final a in alertas) {
        if (a.tipologia == c.tipologia && a.afectaA(rango)) {
          final bono =
              pesoAlerta + a.incrementoPorcentaje.clamp(0, 100).round();
          if (alertaAplicada == null ||
              a.incrementoPorcentaje > alertaAplicada.incrementoPorcentaje) {
            alertaAplicada = a;
          }
          puntaje += bono;
        }
      }
      if (alertaAplicada != null) {
        motivos.add('Alerta activa: ${alertaAplicada.mensaje}');
      }

      if (rango != null) {
        puntaje += pesoRango;
        motivos.add('Pensada para tu rango de edad (${rango.codigo})');
      } else if (c.rangos.length == RangoEtario.values.length) {
        puntaje += pesoGeneral;
      }

      final mejor = progreso.mejoresPuntajes[c.id];
      if (!progreso.estaCompletada(c.id)) {
        puntaje += pesoPendiente;
        motivos.add('Aún no la has visto');
      } else if (mejor != null && mejor < umbralRepaso) {
        puntaje += pesoRepaso;
        motivos.add('Te conviene repasarla');
      } else {
        puntaje -= penalizacionCompletada;
      }

      if ((rango?.esAdultoMayor ?? false) &&
          c.formato == FormatoCapsula.audio) {
        puntaje += pesoAudioAdultoMayor;
        motivos.add('Formato de audio, fácil de escuchar');
      }

      resultado.add(
        Recomendacion(
          capsula: c,
          puntaje: puntaje,
          motivos: motivos,
          alerta: alertaAplicada,
        ),
      );
    }

    resultado.sort((a, b) {
      final cmp = b.puntaje.compareTo(a.puntaje);
      return cmp != 0
          ? cmp
          : a.capsula.duracionSegundos.compareTo(b.capsula.duracionSegundos);
    });
    return resultado.where((r) => r.puntaje > 0).take(limite).toList();
  }
}
