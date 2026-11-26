import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/actividad_repository.dart';
import '../data/adaptador_verificacion.dart';
import '../data/nucleo_api.dart';
import '../data/progreso_repository.dart';
import '../domain/domain.dart';
import 'logica/logica.dart';

// ---------- Dependencias (se sobrescriben en pruebas) ----------

final actividadRepositoryProvider = Provider<ActividadRepository>(
  (ref) => AssetActividadRepository(),
);

final progresoRepositoryProvider = Provider<ProgresoRepository>(
  (ref) => PreferenciasProgresoRepository(),
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

// ---------- Perfil ----------

class PerfilNotifier extends Notifier<Perfil> {
  @override
  Perfil build() => const Perfil();

  void elegirRango(RangoEtario? rango) => state = state.conRango(rango);

  void marcarCuidador(bool valor) =>
      state = state.copyWith(esCuidador: valor);

  /// Los tipos y el perfil de conducta vienen de una fuente oficial
  /// (`GET /api/v1/me`), nunca de lo que declara el usuario.
  void asignarTipos(
    Set<TipoUsuario> tipos, {
    PerfilConducta perfilConducta = PerfilConducta.sinPerfil,
  }) => state = state.copyWith(tipos: tipos, perfilConducta: perfilConducta);
}

final perfilProvider = NotifierProvider<PerfilNotifier, Perfil>(
  PerfilNotifier.new,
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

// ---------- Recomendaciones ----------

final recomendacionesProvider = FutureProvider<List<Recomendacion>>((
  ref,
) async {
  final perfil = ref.watch(perfilProvider);
  final motor = ref.watch(motorRecomendacionProvider);
  final catalogo = await ref.watch(catalogoProvider.future);
  final progreso = await ref.watch(progresoProvider.future);
  final alertas = await ref.watch(alertasProvider.future);
  return motor.recomendar(
    actividades: catalogo,
    perfil: perfil,
    progreso: progreso,
    alertas: alertas,
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

  List<TarjetaRealOEstafa> get tarjetas =>
      EvaluadorRealOEstafa.tarjetasDe(actividad);

  @override
  RealOEstafaEstado build() => const RealOEstafaEstado();

  TarjetaRealOEstafa? get tarjetaActual =>
      state.terminado || state.indice >= tarjetas.length
      ? null
      : tarjetas[state.indice];

  void responder({required bool esEstafa}) {
    final tarjeta = tarjetaActual;
    if (tarjeta == null || state.respondida) return;
    state = RealOEstafaEstado(
      indice: state.indice,
      respuestas: {...state.respuestas, tarjeta.id: esEstafa},
      retroActual: ref
          .read(evaluadorRealOEstafaProvider)
          .evaluar(tarjeta, respondioEstafa: esEstafa),
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
