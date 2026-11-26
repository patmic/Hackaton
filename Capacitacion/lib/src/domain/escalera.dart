import 'capacitacion.dart';
import 'indicio.dart';
import 'microcurso.dart';
import 'tipo_usuario.dart';

/// Reglas del flujo «Quiero capacitarme» (CLAUDE.md §11).
///
/// Las aplica la API de Capacitación (otro bloque). Aquí están en Dart puro
/// para que el mock se comporte igual y como especificación ejecutable.
abstract final class Escalera {
  /// Diagnóstico por la reacción al primer correo. Si reportó después de
  /// hacer clic, cuenta el clic: el nivel es Básico.
  static NivelCapacitacion diagnostico(ResultadoSimulacro resultado) =>
      switch (resultado) {
        ResultadoSimulacro.reporto => NivelCapacitacion.avanzado,
        ResultadoSimulacro.ignoro => NivelCapacitacion.intermedio,
        ResultadoSimulacro.clic => NivelCapacitacion.basico,
        ResultadoSimulacro.pendiente => throw ArgumentError(
          'Sin reacción no hay diagnóstico.',
        ),
      };

  /// Reportó: sube un nivel. Ignoró: mismo nivel. Clic: baja un nivel.
  static NivelCorreo siguienteNivel(
    NivelCorreo actual,
    ResultadoSimulacro resultado,
  ) => switch (resultado) {
    ResultadoSimulacro.reporto => actual.subir,
    ResultadoSimulacro.clic => actual.bajar,
    ResultadoSimulacro.ignoro || ResultadoSimulacro.pendiente => actual,
  };

  /// Reportó: los indicios del correo quedan DOMINADO. Clic: DEBIL. Ignoró:
  /// sin cambios.
  static MapaIndicios actualizarMapa(
    MapaIndicios mapa,
    List<Indicio> indicios,
    ResultadoSimulacro resultado,
  ) => switch (resultado) {
    ResultadoSimulacro.reporto => mapa.con(indicios, EstadoIndicio.dominado),
    ResultadoSimulacro.clic => mapa.con(indicios, EstadoIndicio.debil),
    ResultadoSimulacro.ignoro || ResultadoSimulacro.pendiente => mapa,
  };

  /// Reportes seguidos en nivel 3. Cualquier otra reacción reinicia la
  /// cuenta.
  static int reportesSeguidosNivel3(
    int previos,
    NivelCorreo nivelDelCorreo,
    ResultadoSimulacro resultado,
  ) => resultado == ResultadoSimulacro.reporto &&
          nivelDelCorreo == NivelCorreo.dificil
      ? previos + 1
      : 0;

  /// Dos reportes seguidos en nivel 3: Centinela, con un correo al mes.
  static bool esCentinela(int reportesSeguidosNivel3) =>
      reportesSeguidosNivel3 >= 2;

  /// Elige la plantilla del siguiente correo: del tipo y nivel del usuario, y
  /// con al menos un indicio DEBIL o SIN_PROBAR. Prefiere las que tienen
  /// indicios DEBIL y las que todavía no se enviaron. Si ninguna cumple el
  /// nivel, prueba con cualquier nivel.
  static PlantillaCorreoPrueba? elegirPlantilla({
    required List<PlantillaCorreoPrueba> plantillas,
    required Set<TipoUsuario> tipos,
    required NivelCorreo nivel,
    required MapaIndicios mapa,
    Set<String> yaEnviadas = const {},
  }) {
    final porPracticar = mapa.porPracticar;
    final debiles = mapa.debiles;
    final delTipo = plantillas
        .where((p) => p.tipos.any(tipos.contains))
        .where((p) => p.indicios.any(porPracticar.contains))
        .toList();

    int puntaje(PlantillaCorreoPrueba p) =>
        (p.nivel == nivel ? 100 : 0) +
        (p.indicios.any(debiles.contains) ? 10 : 0) +
        (yaEnviadas.contains(p.id) ? 0 : 1);

    if (delTipo.isEmpty) return null;
    delTipo.sort((a, b) {
      final porPuntaje = puntaje(b).compareTo(puntaje(a));
      return porPuntaje != 0 ? porPuntaje : a.id.compareTo(b.id);
    });
    return delTipo.first;
  }

  /// Lo que se le muestra al usuario según su reacción.
  static DesenlaceSimulacro desenlace(
    CorreoPrueba correo,
    ResultadoSimulacro resultado,
    Set<TipoUsuario> tipos,
  ) {
    final indicios = correo.plantilla.indicios;
    return switch (resultado) {
      ResultadoSimulacro.reporto => DesenlaceSimulacro(
        resultado: resultado,
        titulo: '¡Lo detectaste!',
        mensaje:
            'Era un correo de práctica y lo reportaste sin hacer clic. Estas '
            'son las señales que tenía:',
        indicios: indicios,
      ),
      ResultadoSimulacro.clic => DesenlaceSimulacro(
        resultado: resultado,
        titulo: 'Era un correo de práctica',
        mensaje:
            'No pasó nada: era una práctica. Estas son las señales que tenía, '
            'para que la próxima vez las reconozcas:',
        indicios: indicios,
        microcursos: {for (final i in indicios) Microcurso.paraIndicio(i)}
            .toList(),
        modulosSugeridos: {
          for (final i in indicios) Microcurso.paraIndicio(i).moduloPara(tipos),
        }.toList(),
      ),
      ResultadoSimulacro.ignoro || ResultadoSimulacro.pendiente =>
        DesenlaceSimulacro(
          resultado: ResultadoSimulacro.ignoro,
          titulo: 'Te enviamos un correo de seguimiento',
          mensaje:
              'El correo de práctica tenía estas señales. Cuando veas algo '
              'así, repórtalo: empieza por «Reportar en un toque».',
          indicios: indicios,
          modulosSugeridos: const ['M3'],
        ),
    };
  }
}

/// Límites de envío (CLAUDE.md §11): como máximo un correo de prueba por
/// semana, nunca dos en 48 horas, y uno al mes para los Centinelas.
abstract final class LimitesEnvio {
  static const minimoEntreCorreos = Duration(hours: 48);
  static const unoPorSemana = Duration(days: 7);
  static const centinelaMensual = Duration(days: 30);

  /// Desde cuándo se puede enviar el siguiente correo. Null si es ahora.
  static DateTime? proximoEnvio({
    required DateTime ahora,
    DateTime? ultimoEnvio,
    bool esCentinela = false,
  }) {
    if (ultimoEnvio == null) return null;
    final espera = esCentinela ? centinelaMensual : unoPorSemana;
    final desde = ultimoEnvio.add(
      espera > minimoEntreCorreos ? espera : minimoEntreCorreos,
    );
    return ahora.isBefore(desde) ? desde : null;
  }
}

/// Ventana de reacción al correo de prueba.
enum Entorno {
  demo(Duration(minutes: 10)),
  produccion(Duration(hours: 48));

  const Entorno(this.ventanaReaccion);

  final Duration ventanaReaccion;
}
