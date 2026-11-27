import '../domain/domain.dart';

/// Contrato con la «API de Capacitación» del diagrama (CLAUDE.md §12). La
/// construye otro bloque; aquí está el cliente y un mock.
abstract interface class CapacitacionApi {
  /// `GET /api/v1/me`: tipos, zona y perfil del usuario actual.
  Future<SesionUsuario> me();

  /// `POST /api/v1/eventos`: eventos sin identificador personal.
  Future<void> registrarEventos(List<EventoApp> eventos);

  /// `POST /api/v1/capacitacion/inscribir`: consentimiento, elección de la
  /// plantilla de nivel 2 y envío del primer correo de prueba. [correo] solo
  /// hace falta si el usuario no tiene cuenta (doble opt-in).
  Future<EstadoCapacitacion> inscribir({
    required Consentimiento consentimiento,
    String? correo,
  });

  /// [PROPUESTO] `GET /api/v1/capacitacion/estado`.
  Future<EstadoCapacitacion> estadoCapacitacion();

  /// [PROPUESTO] `POST /api/v1/capacitacion/pausar`.
  Future<EstadoCapacitacion> pausar();

  /// [PROPUESTO] `POST /api/v1/capacitacion/reanudar`.
  Future<EstadoCapacitacion> reanudar();

  /// [PROPUESTO] `POST /api/v1/capacitacion/salir`. Borra la inscripción.
  Future<EstadoCapacitacion> salir();
}

/// API de Capacitación simulada. Aplica las reglas de [Escalera] y
/// [LimitesEnvio] como lo haría el servidor, y expone acciones de demo para
/// simular lo que en producción pasa en el correo del usuario.
class MockCapacitacionApi implements CapacitacionApi {
  MockCapacitacionApi({
    this._sesion = SesionUsuario.sinCuenta,
    DateTime Function()? reloj,
    this.entorno = Entorno.demo,
    this.plantillas = plantillasPrueba,
  }) : _reloj = reloj ?? DateTime.now;

  final Entorno entorno;
  final List<PlantillaCorreoPrueba> plantillas;
  final DateTime Function() _reloj;

  SesionUsuario _sesion;
  EstadoCapacitacion _estado = const EstadoCapacitacion();
  Duration _desfase = Duration.zero;
  int _contador = 0;
  final Set<String> _enviadas = {};

  /// Eventos recibidos, para el panel de demo y las pruebas.
  final List<EventoApp> eventosRecibidos = [];

  DateTime get ahora => _reloj().add(_desfase);
  EstadoCapacitacion get estado => _estado;

  @override
  Future<SesionUsuario> me() async => _sesion;

  @override
  Future<void> registrarEventos(List<EventoApp> eventos) async =>
      eventosRecibidos.addAll(eventos);

  @override
  Future<EstadoCapacitacion> inscribir({
    required Consentimiento consentimiento,
    String? correo,
  }) async {
    if (_estado.inscrito) return _estado;
    if (!_sesion.tieneCorreo) {
      final texto = correo?.trim() ?? '';
      final arroba = texto.indexOf('@');
      if (arroba < 1 || arroba == texto.length - 1) {
        throw const FormatException('Escribe un correo válido.');
      }
      return _estado = const EstadoCapacitacion(
        fase: FaseCapacitacion.confirmandoCorreo,
      );
    }
    return _estado = _enviar(const EstadoCapacitacion());
  }

  @override
  Future<EstadoCapacitacion> estadoCapacitacion() async => _estado;

  @override
  Future<EstadoCapacitacion> pausar() async {
    if (!_estado.inscrito || _estado.pausada) return _estado;
    return _estado = _estado.copyWith(
      fase: FaseCapacitacion.pausada,
      faseAntesDePausa: () => _estado.fase,
    );
  }

  @override
  Future<EstadoCapacitacion> reanudar() async {
    if (!_estado.pausada) return _estado;
    return _estado = _estado.copyWith(
      fase: _estado.faseAntesDePausa ?? FaseCapacitacion.enCurso,
      faseAntesDePausa: () => null,
    );
  }

  @override
  Future<EstadoCapacitacion> salir() async {
    _enviadas.clear();
    return _estado = const EstadoCapacitacion();
  }

  // ---------- Solo demo ----------

  /// Simula el inicio de sesión con otro usuario ficticio.
  void iniciarSesion(SesionUsuario sesion) {
    _sesion = sesion;
    _estado = const EstadoCapacitacion();
    _enviadas.clear();
  }

  /// Simula que el usuario sin cuenta confirmó su correo (doble opt-in).
  EstadoCapacitacion confirmarCorreo() {
    if (_estado.fase != FaseCapacitacion.confirmandoCorreo) return _estado;
    return _estado = _enviar(_estado);
  }

  /// Simula la reacción al correo de prueba: el webhook de reporte o el
  /// `POST /p/{token}/clic`.
  EstadoCapacitacion simularReaccion(ResultadoSimulacro resultado) {
    final correo = _estado.correoActual;
    if (_estado.fase != FaseCapacitacion.esperandoReaccion ||
        correo == null ||
        !correo.pendiente ||
        resultado == ResultadoSimulacro.pendiente) {
      return _estado;
    }
    final reportes = Escalera.reportesSeguidosNivel3(
      _estado.reportesSeguidosNivel3,
      correo.nivel,
      resultado,
    );
    return _estado = _estado.copyWith(
      fase: FaseCapacitacion.enCurso,
      nivelInicial: _estado.nivelInicial ?? Escalera.diagnostico(resultado),
      nivelCorreo: Escalera.siguienteNivel(correo.nivel, resultado),
      correoActual: () => correo.conResultado(resultado),
      ultimoDesenlace: () =>
          Escalera.desenlace(correo, resultado, _sesion.tipos),
      mapa: Escalera.actualizarMapa(
        _estado.mapa,
        correo.plantilla.indicios,
        resultado,
      ),
      reportesSeguidosNivel3: reportes,
      esCentinela: _estado.esCentinela || Escalera.esCentinela(reportes),
    );
  }

  /// Simula que pasó el tiempo. Si vence la ventana sin reacción, el proceso
  /// programado marca IGNORO y envía el seguimiento.
  EstadoCapacitacion pasarTiempo(Duration duracion) {
    _desfase += duracion;
    final correo = _estado.correoActual;
    if (_estado.fase == FaseCapacitacion.esperandoReaccion &&
        correo != null &&
        correo.pendiente &&
        ahora.isAfter(correo.venceEn)) {
      return simularReaccion(ResultadoSimulacro.ignoro);
    }
    return _estado;
  }

  /// Desde cuándo se puede enviar el siguiente correo. Null si es ahora.
  DateTime? get proximoEnvio => LimitesEnvio.proximoEnvio(
    ahora: ahora,
    ultimoEnvio: _estado.ultimoEnvio,
    esCentinela: _estado.esCentinela,
  );

  /// `POST /api/v1/capacitacion/siguiente` (interno): envía el siguiente
  /// correo si la capacitación está en curso (no en pausa) y se respetan los
  /// límites. Devuelve si lo envió.
  bool enviarSiguiente() {
    if (_estado.fase != FaseCapacitacion.enCurso || proximoEnvio != null) {
      return false;
    }
    _estado = _enviar(_estado);
    return _estado.fase == FaseCapacitacion.esperandoReaccion;
  }

  EstadoCapacitacion _enviar(EstadoCapacitacion base) {
    final plantilla = Escalera.elegirPlantilla(
      plantillas: plantillas,
      tipos: _sesion.tipos,
      nivel: base.nivelCorreo,
      mapa: base.mapa,
      yaEnviadas: _enviadas,
      primerEnvio: _enviadas.isEmpty,
    );
    if (plantilla == null) {
      return base.copyWith(fase: FaseCapacitacion.enCurso);
    }
    _enviadas.add(plantilla.id);
    final enviado = ahora;
    return base.copyWith(
      fase: FaseCapacitacion.esperandoReaccion,
      // El nivel es el de la plantilla enviada: si no hubo una del nivel
      // pedido, la escalera se aplica sobre la dificultad real del correo.
      correoActual: () => CorreoPrueba(
        simulacroId: 'sim-${++_contador}',
        plantilla: plantilla,
        nivel: plantilla.nivel,
        enviadoEn: enviado,
        venceEn: enviado.add(entorno.ventanaReaccion),
      ),
      ultimoEnvio: enviado,
    );
  }
}
