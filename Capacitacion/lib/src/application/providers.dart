import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/capsula_repository.dart';
import '../data/nucleo_api.dart';
import '../data/progreso_repository.dart';
import '../domain/domain.dart';
import 'logica/logica.dart';

// ---------- Dependencias (se sobrescriben en pruebas) ----------

final capsulaRepositoryProvider = Provider<CapsulaRepository>(
  (ref) => AssetCapsulaRepository(),
);

final progresoRepositoryProvider = Provider<ProgresoRepository>(
  (ref) => PreferenciasProgresoRepository(),
);

final motorRecomendacionProvider = Provider(
  (ref) => const MotorRecomendacion(),
);

final evaluadorQuizProvider = Provider((ref) => const EvaluadorQuiz());

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

// ---------- Catálogo ----------

final catalogoProvider = FutureProvider<List<Capsula>>(
  (ref) => ref.watch(capsulaRepositoryProvider).obtenerTodas(),
);

final capsulaPorIdProvider = FutureProvider.family<Capsula?, String>((
  ref,
  id,
) async {
  final catalogo = await ref.watch(catalogoProvider.future);
  for (final c in catalogo) {
    if (c.id == id) return c;
  }
  return null;
});

class FiltroNotifier extends Notifier<FiltroCapsulas> {
  @override
  FiltroCapsulas build() => const FiltroCapsulas();

  void tipologia(Tipologia? valor) =>
      state = state.copyWith(tipologia: () => valor);

  void rango(RangoEtario? valor) => state = state.copyWith(rango: () => valor);

  void formato(FormatoCapsula? valor) =>
      state = state.copyWith(formato: () => valor);

  void soloPendientes(bool valor) =>
      state = state.copyWith(soloPendientes: valor);

  void limpiar() => state = const FiltroCapsulas();
}

final filtroProvider = NotifierProvider<FiltroNotifier, FiltroCapsulas>(
  FiltroNotifier.new,
);

final capsulasFiltradasProvider = FutureProvider<List<Capsula>>((ref) async {
  final catalogo = await ref.watch(catalogoProvider.future);
  final progreso = await ref.watch(progresoProvider.future);
  return ref.watch(filtroProvider).aplicar(catalogo, progreso);
});

// ---------- Perfil ----------

class PerfilNotifier extends Notifier<Perfil> {
  @override
  Perfil build() => const Perfil();

  void elegirRango(RangoEtario? rango) => state = state.conRango(rango);
}

final perfilProvider = NotifierProvider<PerfilNotifier, Perfil>(
  PerfilNotifier.new,
);

// ---------- Progreso ----------

class ProgresoNotifier extends AsyncNotifier<Progreso> {
  @override
  Future<Progreso> build() => ref.watch(progresoRepositoryProvider).cargar();

  Future<void> marcarCompletada(String capsulaId) =>
      _actualizar((p) => p.marcarCompletada(capsulaId));

  Future<void> registrarResultado(ResultadoQuiz resultado) => _actualizar(
    (p) => p.registrarPuntaje(resultado.capsulaId, resultado.puntaje),
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
  final catalogo = await ref.watch(catalogoProvider.future);
  final progreso = await ref.watch(progresoProvider.future);
  final alertas = await ref.watch(alertasProvider.future);
  return ref
      .watch(motorRecomendacionProvider)
      .recomendar(
        capsulas: catalogo,
        perfil: ref.watch(perfilProvider),
        progreso: progreso,
        alertas: alertas,
      );
});

// ---------- Quiz ----------

class QuizEstado {
  const QuizEstado({
    this.indice = 0,
    this.respuestas = const {},
    this.retroActual,
    this.resultado,
  });

  final int indice;
  final Map<String, bool> respuestas;

  /// Retroalimentación de la pregunta actual, ya respondida.
  final Retroalimentacion? retroActual;

  /// No null cuando el quiz terminó.
  final ResultadoQuiz? resultado;

  bool get terminado => resultado != null;
  bool get respondida => retroActual != null;
}

class QuizController extends Notifier<QuizEstado> {
  QuizController(this.capsula);

  final Capsula capsula;

  @override
  QuizEstado build() => const QuizEstado();

  PreguntaQuiz? get preguntaActual =>
      state.terminado || state.indice >= capsula.preguntas.length
      ? null
      : capsula.preguntas[state.indice];

  void responder({required bool esEstafa}) {
    final pregunta = preguntaActual;
    if (pregunta == null || state.respondida) return;
    state = QuizEstado(
      indice: state.indice,
      respuestas: {...state.respuestas, pregunta.id: esEstafa},
      retroActual: ref
          .read(evaluadorQuizProvider)
          .evaluar(pregunta, respondioEstafa: esEstafa),
    );
  }

  Future<void> siguiente() async {
    if (!state.respondida) return;
    final proximo = state.indice + 1;
    if (proximo < capsula.preguntas.length) {
      state = QuizEstado(indice: proximo, respuestas: state.respuestas);
      return;
    }
    final resultado = ref
        .read(evaluadorQuizProvider)
        .evaluarCapsula(capsula, state.respuestas);
    state = QuizEstado(
      indice: state.indice,
      respuestas: state.respuestas,
      resultado: resultado,
    );
    await ref.read(progresoProvider.notifier).registrarResultado(resultado);
  }

  void reiniciar() => state = const QuizEstado();
}

final quizProvider = NotifierProvider.autoDispose
    .family<QuizController, QuizEstado, Capsula>(QuizController.new);

// ---------- Verificación ----------

class VerificacionEstado {
  const VerificacionEstado({required this.resultado, this.capsula});

  final ResultadoVerificacion resultado;

  /// Cápsula sugerida tras verificar.
  final Capsula? capsula;
}

class VerificacionController extends AsyncNotifier<VerificacionEstado?> {
  @override
  Future<VerificacionEstado?> build() async => null;

  Future<void> verificar({
    String? codigo,
    String? remitente,
    Tipologia? tipologiaPercibida,
  }) async {
    final perfil = ref.read(perfilProvider);
    final solicitud = SolicitudVerificacion(
      hashRecibido: codigo,
      remitenteReportado: remitente,
      tipologiaPercibida: tipologiaPercibida,
      rangoEtario: perfil.rangoEtario,
      canal: CanalVerificacion.app,
    );
    if (solicitud.estaVacia) {
      state = AsyncError(
        const FormatException('Ingresa el código o el remitente.'),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final resultado = await ref.read(nucleoApiProvider).verificar(solicitud);
      final capsula = capsulaParaVerificacion(
        resultado: resultado,
        capsulas: await ref.read(catalogoProvider.future),
        perfil: perfil,
        progreso: await ref.read(progresoProvider.future),
      );
      return VerificacionEstado(resultado: resultado, capsula: capsula);
    });
  }

  void limpiar() => state = const AsyncData(null);
}

final verificacionProvider =
    AsyncNotifierProvider<VerificacionController, VerificacionEstado?>(
      VerificacionController.new,
    );
