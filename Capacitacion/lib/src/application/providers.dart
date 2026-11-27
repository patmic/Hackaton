import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/actividad_repository.dart';
import '../data/adaptador_verificacion.dart';
import '../data/capacitacion_api.dart';
import '../data/nucleo_api.dart';
import '../data/observador_api.dart';
import '../data/progreso_repository.dart';
import '../data/tipologia_repository.dart';
import '../domain/domain.dart';
import 'logica/logica.dart';

// ---------- Dependencias (se sobrescriben en pruebas) ----------

final actividadRepositoryProvider = Provider<ActividadRepository>(
  (ref) => AssetActividadRepository(),
);

final progresoRepositoryProvider = Provider<ProgresoRepository>(
  (ref) => PreferenciasProgresoRepository(),
);

final tipologiaRepositoryProvider = Provider<TipologiaRepository>(
  (ref) => AssetTipologiaRepository(),
);

/// Tipologías y Sello IESS de `tipologias.json`.
final tipologiasProvider = FutureProvider<CatalogoTipologias>(
  (ref) => ref.watch(tipologiaRepositoryProvider).obtener(),
);

final motorRecomendacionProvider = Provider(
  (ref) => const MotorRecomendacion(),
);

final evaluadorRealOEstafaProvider = Provider(
  (ref) => const EvaluadorRealOEstafa(),
);

/// Núcleo simulado hasta que el Bloque 3 publique su API.
final nucleoApiProvider = Provider<NucleoApi>(
  (ref) => MockNucleoApi(latencia: const Duration(milliseconds: 300)),
);

/// Alertas activas del Observatorio. Si el Núcleo falla, la app sigue
/// funcionando sin alertas.
final alertasProvider = FutureProvider<List<AlertaObservatorio>>((ref) async {
  try {
    return await ref.watch(nucleoApiProvider).alertasActivas();
  } on Exception {
    return const [];
  }
});

/// Reloj de la app. Se sobrescribe en las pruebas.
final relojProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// API de Capacitación simulada hasta que el otro bloque publique la suya.
/// El mock elige el siguiente correo con lo que el observador aprendió de la
/// persona y le cuenta cada reacción, como haría el servidor.
final capacitacionApiProvider = Provider<CapacitacionApi>(
  (ref) => MockCapacitacionApi(
    reloj: ref.watch(relojProvider),
    mapaObservado: () => ref.read(planPersonalizadoProvider).value?.mapa,
    alReaccionar: (correo, resultado, momento) => unawaited(
      ref
          .read(observadorProvider.notifier)
          .observar(
            ObservacionConducta.simulacro(
              correo: correo,
              resultado: resultado,
              momento: momento,
            ),
          ),
    ),
  ),
);

// ---------- Sesión (GET /api/v1/me) ----------

class SesionController extends AsyncNotifier<SesionUsuario> {
  @override
  Future<SesionUsuario> build() => ref.watch(capacitacionApiProvider).me();

  /// Solo demo: simula el inicio de sesión con un usuario ficticio. Con la
  /// API real, la sesión viene del proveedor de identidad.
  Future<void> iniciarSesionDemo(SesionUsuario sesion) async {
    final api = ref.read(capacitacionApiProvider);
    if (api is MockCapacitacionApi) api.iniciarSesion(sesion);
    state = await AsyncValue.guard(api.me);
  }
}

final sesionProvider = AsyncNotifierProvider<SesionController, SesionUsuario>(
  SesionController.new,
);

// ---------- Perfil ----------

/// El tipo, el perfil de conducta y el rango vienen de la sesión. Si `/me`
/// falla, la app sigue como EX5 (sin cuenta).
class PerfilNotifier extends Notifier<Perfil> {
  @override
  Perfil build() {
    final sesion = ref.watch(sesionProvider).value ?? SesionUsuario.sinCuenta;
    return Perfil(
      tipos: sesion.tipos,
      perfilConducta: sesion.perfilConducta,
      rangoEtario: sesion.rangoEtario,
    );
  }

  void elegirRango(RangoEtario? rango) => state = state.conRango(rango);

  void marcarCuidador(bool valor) => state = state.copyWith(esCuidador: valor);
}

final perfilProvider = NotifierProvider<PerfilNotifier, Perfil>(
  PerfilNotifier.new,
);

// ---------- Eventos (POST /api/v1/eventos) ----------

final registroEventosProvider = Provider<RegistroEventos>(
  (ref) => RegistroEventos(
    api: ref.watch(capacitacionApiProvider),
    contexto: () => ContextoEvento.desdePerfil(ref.read(perfilProvider)),
    reloj: ref.watch(relojProvider),
  ),
);

// ---------- «Quiero capacitarme» ----------

class CapacitacionController extends AsyncNotifier<EstadoCapacitacion> {
  @override
  Future<EstadoCapacitacion> build() {
    // Al cambiar de sesión se vuelve a cargar el estado.
    ref.watch(sesionProvider);
    return ref.watch(capacitacionApiProvider).estadoCapacitacion();
  }

  CapacitacionApi get _api => ref.read(capacitacionApiProvider);

  /// El mock, si la API es simulada. Habilita el panel de demostración.
  MockCapacitacionApi? get demo {
    final api = ref.read(capacitacionApiProvider);
    return api is MockCapacitacionApi ? api : null;
  }

  /// Acepta el consentimiento e inscribe. Devuelve un mensaje si el correo
  /// no es válido; en ese caso el estado no cambia.
  Future<String?> inscribir({String? correo}) async {
    final consentimiento = Consentimiento(
      version: Consentimiento.versionActual,
      aceptadoEn: ref.read(relojProvider)(),
    );
    try {
      final nuevo = await _api.inscribir(
        consentimiento: consentimiento,
        correo: correo,
      );
      state = AsyncData(nuevo);
      return null;
    } on FormatException catch (e) {
      return e.message;
    }
  }

  Future<void> pausar() async => state = await AsyncValue.guard(_api.pausar);

  Future<void> reanudar() async =>
      state = await AsyncValue.guard(_api.reanudar);

  Future<void> salir() async => state = await AsyncValue.guard(_api.salir);

  // ---------- Panel de demostración ----------

  void confirmarCorreoDemo() => _demo((d) => d.confirmarCorreo());

  void simularReaccionDemo(ResultadoSimulacro resultado) =>
      _demo((d) => d.simularReaccion(resultado));

  /// Deja vencer la ventana de reacción: el correo queda IGNORO.
  void dejarVencerDemo() =>
      _demo((d) => d.pasarTiempo(d.entorno.ventanaReaccion * 2));

  /// Simula que pasó una semana y pide el siguiente correo.
  void siguienteCorreoDemo() => _demo((d) {
    d.pasarTiempo(LimitesEnvio.unoPorSemana);
    d.enviarSiguiente();
    return d.estado;
  });

  void _demo(EstadoCapacitacion Function(MockCapacitacionApi) accion) {
    final d = demo;
    if (d == null) return;
    state = AsyncData(accion(d));
  }
}

final capacitacionProvider =
    AsyncNotifierProvider<CapacitacionController, EstadoCapacitacion>(
      CapacitacionController.new,
    );

// ---------- Catálogo ----------

final catalogoProvider = FutureProvider<List<Actividad>>(
  (ref) => ref.watch(actividadRepositoryProvider).obtenerTodas(),
);

final actividadPorIdProvider = FutureProvider.family<Actividad?, String>((
  ref,
  id,
) async {
  final catalogo = await ref.watch(catalogoProvider.future);
  for (final a in catalogo) {
    if (a.id == id) return a;
  }
  return null;
});

/// Actividades que le corresponden al usuario por su tipo y perfil.
final actividadesDelPerfilProvider = FutureProvider<List<Actividad>>((
  ref,
) async {
  final perfil = ref.watch(perfilProvider);
  final catalogo = await ref.watch(catalogoProvider.future);
  return catalogo.where((a) => a.elegiblePara(perfil)).toList();
});

class FiltroNotifier extends Notifier<FiltroActividades> {
  @override
  FiltroActividades build() => const FiltroActividades();

  void tipologia(Tipologia? valor) =>
      state = state.copyWith(tipologia: () => valor);

  void modulo(String? valor) => state = state.copyWith(modulo: () => valor);

  void mecanica(Mecanica? valor) =>
      state = state.copyWith(mecanica: () => valor);

  void soloPendientes(bool valor) =>
      state = state.copyWith(soloPendientes: valor);

  void limpiar() => state = const FiltroActividades();
}

final filtroProvider = NotifierProvider<FiltroNotifier, FiltroActividades>(
  FiltroNotifier.new,
);

final actividadesFiltradasProvider = FutureProvider<List<Actividad>>((
  ref,
) async {
  final perfil = ref.watch(perfilProvider);
  final filtro = ref.watch(filtroProvider);
  final catalogo = await ref.watch(catalogoProvider.future);
  final progreso = await ref.watch(progresoProvider.future);
  return filtro.aplicar(catalogo, perfil: perfil, progreso: progreso);
});

// ---------- Progreso ----------

class ProgresoNotifier extends AsyncNotifier<Progreso> {
  @override
  Future<Progreso> build() => ref.watch(progresoRepositoryProvider).cargar();

  Future<void> marcarCompletada(String actividadId) =>
      _actualizar((p) => p.marcarCompletada(actividadId));

  Future<void> registrarResultado(ResultadoActividad resultado) => _actualizar(
    (p) => p.registrarPuntaje(resultado.actividadId, resultado.puntaje),
  );

  /// Guarda insignias recién ganadas para no perderlas después.
  Future<void> otorgarInsignias(Set<String> ids) =>
      _actualizar((p) => p.otorgarInsignias(ids));

  Future<void> _actualizar(Progreso Function(Progreso) cambio) async {
    final actual = await future;
    final nuevo = cambio(actual);
    state = AsyncData(nuevo);
    await ref.read(progresoRepositoryProvider).guardar(nuevo);
  }
}

final progresoProvider = AsyncNotifierProvider<ProgresoNotifier, Progreso>(
  ProgresoNotifier.new,
);

// ---------- Insignias (gamificación) ----------

/// Insignias del usuario: logros y módulos terminados de su ruta. Si el
/// estado de «Quiero capacitarme» todavía no carga, se calculan sin él.
final insigniasProvider = FutureProvider<ResumenInsignias>((ref) async {
  final perfil = ref.watch(perfilProvider);
  final capacitacion = ref.watch(capacitacionProvider).value;
  final actividades = await ref.watch(actividadesDelPerfilProvider.future);
  final progreso = await ref.watch(progresoProvider.future);
  return Insignias.calcular(
    actividades: actividades,
    progreso: progreso,
    capacitacion: capacitacion,
    perfil: perfil,
  );
});

// ---------- Recomendaciones ----------

final recomendacionesProvider = FutureProvider<List<Recomendacion>>((
  ref,
) async {
  final perfil = ref.watch(perfilProvider);
  final motor = ref.watch(motorRecomendacionProvider);
  final catalogo = await ref.watch(catalogoProvider.future);
  final progreso = await ref.watch(progresoProvider.future);
  final alertas = await ref.watch(alertasProvider.future);
  PlanPersonalizado? plan;
  try {
    plan = await ref.watch(planPersonalizadoProvider.future);
  } on Object {
    plan = null; // sin plan, la ruta de su tipo sigue funcionando
  }
  return motor.recomendar(
    actividades: catalogo,
    perfil: perfil,
    progreso: progreso,
    alertas: alertas,
    plan: plan,
  );
});

// ---------- A2 · ¿Real o estafa? ----------

class RealOEstafaEstado {
  const RealOEstafaEstado({
    this.indice = 0,
    this.respuestas = const {},
    this.retroActual,
    this.resultado,
  });

  final int indice;
  final Map<String, bool> respuestas;

  /// Retroalimentación de la tarjeta actual, ya respondida.
  final RetroTarjeta? retroActual;

  /// No null cuando la ronda terminó.
  final ResultadoActividad? resultado;

  bool get terminado => resultado != null;
  bool get respondida => retroActual != null;
}

class RealOEstafaController extends Notifier<RealOEstafaEstado> {
  RealOEstafaController(this.actividad);

  final Actividad actividad;
  late DateTime _inicio;

  List<TarjetaRealOEstafa> get tarjetas =>
      EvaluadorRealOEstafa.tarjetasDe(actividad);

  RegistroEventos get _registro => ref.read(registroEventosProvider);

  @override
  RealOEstafaEstado build() {
    _inicio = _registro.ahora();
    unawaited(
      _registro.registrar(
        EventoApp.actividadIniciada(
          actividadId: actividad.id,
          modulo: actividad.modulo,
          momento: _inicio,
        ),
      ),
    );
    return const RealOEstafaEstado();
  }

  TarjetaRealOEstafa? get tarjetaActual =>
      state.terminado || state.indice >= tarjetas.length
      ? null
      : tarjetas[state.indice];

  void responder({required bool esEstafa}) {
    final tarjeta = tarjetaActual;
    if (tarjeta == null || state.respondida) return;
    final retro = ref
        .read(evaluadorRealOEstafaProvider)
        .evaluar(tarjeta, respondioEstafa: esEstafa);
    state = RealOEstafaEstado(
      indice: state.indice,
      respuestas: {...state.respuestas, tarjeta.id: esEstafa},
      retroActual: retro,
    );
    unawaited(
      _registro.registrar(
        EventoApp.decisionTomada(
          itemId: tarjeta.id,
          opcion: esEstafa ? 'ESTAFA' : 'REAL',
          esCorrecta: retro.acerto,
          momento: _registro.ahora(),
        ),
      ),
    );
    unawaited(
      ref
          .read(observadorProvider.notifier)
          .observar(
            ObservacionConducta.decision(
              actividadId: actividad.id,
              itemId: tarjeta.id,
              esEstafa: tarjeta.esEstafa,
              acerto: retro.acerto,
              indicios: tarjeta.indicios,
              tipologia: actividad.tipologia,
              momento: _registro.ahora(),
            ),
          ),
    );
  }

  Future<void> siguiente() async {
    if (!state.respondida) return;
    final proximo = state.indice + 1;
    if (proximo < tarjetas.length) {
      state = RealOEstafaEstado(indice: proximo, respuestas: state.respuestas);
      return;
    }
    final resultado = ref
        .read(evaluadorRealOEstafaProvider)
        .evaluarRonda(actividad, state.respuestas);
    state = RealOEstafaEstado(
      indice: state.indice,
      respuestas: state.respuestas,
      resultado: resultado,
    );
    final fin = _registro.ahora();
    unawaited(
      _registro.registrar(
        EventoApp.actividadCompletada(
          actividadId: actividad.id,
          aciertos: resultado.aciertos,
          total: resultado.total,
          duracionSeg: fin.difference(_inicio).inSeconds,
          momento: fin,
        ),
      ),
    );
    await ref.read(progresoProvider.notifier).registrarResultado(resultado);
  }

  void reiniciar() => state = const RealOEstafaEstado();
}

final realOEstafaProvider = NotifierProvider.autoDispose
    .family<RealOEstafaController, RealOEstafaEstado, Actividad>(
      RealOEstafaController.new,
    );

// ---------- Verificación ----------

final adaptadorVerificacionProvider = Provider(
  (ref) => const AdaptadorVerificacion(),
);

class VerificacionEstado {
  const VerificacionEstado({
    required this.resultado,
    this.actividad,
    this.microcurso,
    this.coincidenciaConfirmada = false,
  });

  final ResultadoVerificacion resultado;

  /// Actividad sugerida tras verificar.
  final Actividad? actividad;

  /// Microcurso del primer indicio que explica el análisis.
  final Microcurso? microcurso;

  /// El usuario confirmó que lo que muestra la app coincide con el correo.
  final bool coincidenciaConfirmada;

  /// En VERDE, falta que el usuario compare los datos sellados con el
  /// correo que lee (Fallo 2).
  bool get faltaComparar => resultado.esAutentico && !coincidenciaConfirmada;
}

class VerificacionController extends AsyncNotifier<VerificacionEstado?> {
  @override
  Future<VerificacionEstado?> build() async => null;

  /// Verifica un código pegado o recibido por App Link. Un código con mal
  /// formato no se envía al servidor; si el servidor no responde, el
  /// resultado es AMARILLO.
  Future<void> verificar({
    String? codigo,
    Tipologia? tipologiaPercibida,
    OrigenCodigo origen = OrigenCodigo.pegado,
  }) async {
    final texto = codigo?.trim() ?? '';
    if (texto.isEmpty) {
      state = AsyncError(
        const FormatException('Ingresa el código de verificación.'),
        StackTrace.current,
      );
      return;
    }
    final perfil = ref.read(perfilProvider);
    final adaptador = ref.read(adaptadorVerificacionProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final hash = CodigoVerificacion.normalizar(texto);
      final resultado = hash == null
          ? adaptador.codigoInvalido(tipologiaPercibida: tipologiaPercibida)
          : await _consultar(
              SolicitudVerificacion(
                canal: CanalVerificacion.app,
                hashRecibido: hash,
                tipologiaPercibida: tipologiaPercibida,
                rangoEtario: perfil.rangoEtario,
                origen: origen,
              ),
              adaptador,
            );
      // Verificar antes de actuar es un hábito que el observador cuenta
      // para el perfil (Prudente), no para el dominio de un indicio.
      unawaited(
        ref
            .read(observadorProvider.notifier)
            .observar(
              ObservacionConducta.verificacion(
                semaforo: resultado.semaforo,
                tipologia: tipologiaPercibida,
                momento: ref.read(relojProvider)(),
              ),
            ),
      );
      return _conSugerencia(resultado);
    });
  }

  /// Respuesta del usuario tras comparar los datos sellados con el correo.
  /// Si no coinciden, el sello fue copiado de otro correo: pasa a ROJO.
  Future<void> confirmarCoincidencia({required bool coincide}) async {
    final actual = state.value;
    if (actual == null || !actual.faltaComparar) return;
    if (coincide) {
      state = AsyncData(
        VerificacionEstado(
          resultado: actual.resultado,
          actividad: actual.actividad,
          microcurso: actual.microcurso,
          coincidenciaConfirmada: true,
        ),
      );
      return;
    }
    state = await AsyncValue.guard(
      () => _conSugerencia(actual.resultado.marcarComoCopiado()),
    );
  }

  void limpiar() => state = const AsyncData(null);

  Future<ResultadoVerificacion> _consultar(
    SolicitudVerificacion solicitud,
    AdaptadorVerificacion adaptador,
  ) async {
    try {
      return await ref.read(nucleoApiProvider).verificar(solicitud);
    } on Exception {
      return adaptador.sinConexion(
        tipologiaPercibida: solicitud.tipologiaPercibida,
      );
    }
  }

  Future<VerificacionEstado> _conSugerencia(
    ResultadoVerificacion resultado,
  ) async {
    final actividad = actividadParaVerificacion(
      resultado: resultado,
      actividades: await ref.read(catalogoProvider.future),
      perfil: ref.read(perfilProvider),
      progreso: await ref.read(progresoProvider.future),
    );
    return VerificacionEstado(
      resultado: resultado,
      actividad: actividad,
      microcurso: microcursoParaVerificacion(resultado),
    );
  }
}

final verificacionProvider =
    AsyncNotifierProvider<VerificacionController, VerificacionEstado?>(
      VerificacionController.new,
    );

// ---------- Observador (Radar Phishing) ----------

/// Prácticas guardadas en el dispositivo. Se sobrescribe en pruebas.
final almacenObservadorProvider = Provider<AlmacenObservador>(
  (ref) => PreferenciasAlmacenObservador(),
);

/// Cliente del Radar Phishing (observador en SellaCorreo). Null si la app se
/// compiló sin `OBSERVADOR_URL` ni `AIESS_SELLO`: todo se calcula aquí.
final observadorApiProvider = Provider<ObservadorApi?>(
  (ref) => HttpObservadorApi.desdeEntorno(),
);

final observadorLocalProvider = Provider((ref) => const ObservadorLocal());

/// Aprende de lo que la persona hace: cada tarjeta de «¿Real o estafa?»,
/// cada señal de «Caza la señal», cada reacción a un correo de prueba y cada
/// verificación. Todo se guarda en el dispositivo; si la persona acepta
/// compartir, también se envía al Radar Phishing con su código aleatorio
/// (nunca nombre, cédula ni correo).
class ObservadorController extends AsyncNotifier<DatosObservador> {
  /// Las escrituras van en fila para no perder ninguna.
  Future<void> _fila = Future.value();

  AlmacenObservador get _almacen => ref.read(almacenObservadorProvider);

  @override
  Future<DatosObservador> build() =>
      ref.watch(almacenObservadorProvider).cargar();

  Future<void> observar(ObservacionConducta observacion) =>
      observarVarias([observacion]);

  Future<void> observarVarias(List<ObservacionConducta> observaciones) =>
      _enFila((d) async {
        var nuevo = d;
        for (final o in observaciones) {
          // Un ítem estafa sin indicios no enseña nada y el observador lo
          // rechazaría (y con él todo el lote).
          if (o.esEstafa == true && o.indicios.isEmpty) continue;
          nuevo = nuevo.con(o);
        }
        return nuevo;
      });

  /// La persona decide si comparte sus prácticas con el Radar Phishing.
  Future<void> compartir(bool valor) =>
      _enFila((d) async => d.copyWith(compartir: valor));

  /// Borra todo lo aprendido, aquí y en el Radar Phishing (LOPDP), y crea
  /// un código nuevo.
  Future<void> borrarDatos() => _enFila((d) async {
    final api = ref.read(observadorApiProvider);
    if (api != null && (d.compartir || d.enviadas > 0)) {
      try {
        await api.borrar(d.idSeudonimo);
      } on ObservadorNoDisponible {
        // Sin conexión igual se borra aquí y se cambia el código: lo que
        // quedó en el servidor ya no se puede ligar a este dispositivo.
      }
    }
    return DatosObservador.nuevo().copyWith(compartir: d.compartir);
  });

  Future<void> _enFila(
    Future<DatosObservador> Function(DatosObservador) cambio,
  ) {
    final paso = _fila.then((_) async {
      try {
        final nuevo = await _enviarPendientes(await cambio(await future));
        await _almacen.guardar(nuevo);
        state = AsyncData(nuevo);
      } on Exception {
        // Fail-open: si no se pudo guardar, la lección sigue igual.
      }
    });
    _fila = paso;
    return paso;
  }

  /// Envía lo que el Radar Phishing aún no tiene. Si no responde, se
  /// reintenta con la siguiente práctica (fail-open).
  Future<DatosObservador> _enviarPendientes(DatosObservador d) async {
    final api = ref.read(observadorApiProvider);
    if (api == null || !d.compartir || d.pendientes.isEmpty) return d;
    final perfil = ref.read(perfilProvider);
    try {
      await api.registrar([
        for (final o in d.pendientes)
          o.toJson(
            idSeudonimo: d.idSeudonimo,
            tipos: perfil.tipos,
            rangoEtario: perfil.rangoEtario,
          ),
      ]);
    } on ObservadorNoDisponible catch (e) {
      // Un lote rechazado (4xx) nunca se aceptará: no debe frenar a los
      // siguientes. Sin conexión o con límite (429) se reintenta.
      if (!e.rechazado) return d;
    }
    return d.copyWith(enviadas: d.observaciones.length);
  }
}

final observadorProvider =
    AsyncNotifierProvider<ObservadorController, DatosObservador>(
      ObservadorController.new,
    );

/// Plan personalizado según sus falencias. Viene del Radar Phishing si la
/// persona comparte y el servidor ya tiene todas sus prácticas (así también
/// usa lo aprendido de personas con su mismo tipo de cuenta); si no, se
/// calcula en el dispositivo con el mismo modelo.
final planPersonalizadoProvider = FutureProvider<PlanPersonalizado>((
  ref,
) async {
  final datos = await ref.watch(observadorProvider.future);
  final perfil = ref.watch(perfilProvider);
  final actividades = await ref.watch(actividadesDelPerfilProvider.future);
  final local = ref
      .watch(observadorLocalProvider)
      .plan(
        idSeudonimo: datos.idSeudonimo,
        observaciones: datos.observaciones,
        ahora: ref.read(relojProvider)(),
        tipos: perfil.tipos,
        actividades: actividades,
      );
  final api = ref.watch(observadorApiProvider);
  if (api == null || !datos.compartir || datos.pendientes.isNotEmpty) {
    return local;
  }
  try {
    return await api.plan(
      datos.idSeudonimo,
      tipos: perfil.tipos,
      rangoEtario: perfil.rangoEtario,
    );
  } on ObservadorNoDisponible {
    return local;
  }
});
