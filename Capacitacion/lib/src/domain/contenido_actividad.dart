import 'indicio.dart';
import 'json.dart';
import 'mecanica.dart';
import 'mensaje_simulado.dart';

/// Contenido propio de cada mecánica. La app elige el componente según el
/// tipo concreto.
///
/// Campos del JSON por mecánica (extensión del formato de CLAUDE.md §12):
/// - A1: `mensaje` y `senales`.
/// - A2: `tarjetas`.
/// - A3: `bandeja`.
/// - A6: `casos`.
/// - A7: `audio` y `opciones`.
/// - A4, A5, A8 y A9 todavía no tienen componente.
sealed class ContenidoActividad {
  const ContenidoActividad();

  factory ContenidoActividad.desdeJson(
    Mecanica mecanica,
    Map<String, dynamic> json,
  ) => switch (mecanica) {
    Mecanica.a1 => ContenidoCazaSenal.fromJson(json),
    Mecanica.a2 => ContenidoRealOEstafa.fromJson(json),
    Mecanica.a3 => ContenidoBandeja.fromJson(json),
    Mecanica.a6 => ContenidoVerifica.fromJson(json),
    Mecanica.a7 => ContenidoAudioReto.fromJson(json),
    Mecanica.a4 ||
    Mecanica.a5 ||
    Mecanica.a8 ||
    Mecanica.a9 => const ContenidoPendiente(),
  };

  /// Ítems que se evalúan para el puntaje.
  int get totalItems;

  /// Indicios que aparecen en el contenido.
  Set<Indicio> get indiciosUsados;
}

// ---------- A1 · Caza la señal ----------

/// Señal escondida en una zona del mensaje.
class SenalEscondida {
  const SenalEscondida({
    required this.indicio,
    required this.zona,
    required this.feedback,
  });

  factory SenalEscondida.fromJson(Map<String, dynamic> json) => SenalEscondida(
    indicio: Indicio.desdeCodigo(json['id'] as String),
    zona: ZonaMensaje.desdeCodigo(json['zona'] as String),
    feedback: json['feedback'] as String,
  );

  final Indicio indicio;
  final ZonaMensaje zona;

  /// Explicación que aparece al tocarla.
  final String feedback;
}

class ContenidoCazaSenal extends ContenidoActividad {
  const ContenidoCazaSenal({required this.mensaje, required this.senales});

  factory ContenidoCazaSenal.fromJson(Map<String, dynamic> json) =>
      ContenidoCazaSenal(
        mensaje: MensajeSimulado.fromJson(
          json['mensaje'] as Map<String, dynamic>,
        ),
        senales: listaDeMapas(
          json['senales'],
        ).map(SenalEscondida.fromJson).toList(),
      );

  final MensajeSimulado mensaje;
  final List<SenalEscondida> senales;

  @override
  int get totalItems => senales.length;

  @override
  Set<Indicio> get indiciosUsados => {for (final s in senales) s.indicio};
}

// ---------- A2 · ¿Real o estafa? ----------

class TarjetaRealOEstafa {
  const TarjetaRealOEstafa({
    required this.id,
    required this.mensaje,
    required this.esEstafa,
    required this.explicacion,
    this.indicios = const [],
  });

  factory TarjetaRealOEstafa.fromJson(Map<String, dynamic> json) =>
      TarjetaRealOEstafa(
        id: json['id'] as String,
        mensaje: MensajeSimulado.fromJson(
          json['mensaje'] as Map<String, dynamic>,
        ),
        esEstafa: json['es_estafa'] as bool,
        explicacion: json['explicacion'] as String,
        indicios: listaDeTextos(
          json['indicios'],
        ).map(Indicio.desdeCodigo).toList(),
      );

  final String id;
  final MensajeSimulado mensaje;
  final bool esEstafa;

  /// Por qué es real o estafa. Se muestra siempre, acierte o no.
  final String explicacion;

  /// Indicios presentes. Vacío en un correo legítimo.
  final List<Indicio> indicios;
}

class ContenidoRealOEstafa extends ContenidoActividad {
  const ContenidoRealOEstafa({required this.tarjetas});

  factory ContenidoRealOEstafa.fromJson(Map<String, dynamic> json) =>
      ContenidoRealOEstafa(
        tarjetas: listaDeMapas(
          json['tarjetas'],
        ).map(TarjetaRealOEstafa.fromJson).toList(),
      );

  /// Cinco por ronda (CLAUDE.md §10.3).
  final List<TarjetaRealOEstafa> tarjetas;

  @override
  int get totalItems => tarjetas.length;

  @override
  Set<Indicio> get indiciosUsados => {
    for (final t in tarjetas) ...t.indicios,
  };
}

// ---------- A3 · Bandeja simulada ----------

/// Lo que el usuario puede hacer con un mensaje de la bandeja.
enum AccionBandeja {
  confiar('CONFIAR', 'Confiar'),
  verificar('VERIFICAR', 'Verificar'),
  reportar('REPORTAR', 'Reportar');

  const AccionBandeja(this.codigo, this.etiqueta);

  final String codigo;
  final String etiqueta;

  static AccionBandeja desdeCodigo(String codigo) => values.firstWhere(
    (a) => a.codigo == codigo.trim().toUpperCase(),
    orElse: () => throw FormatException('Acción desconocida: $codigo'),
  );
}

class ItemBandeja {
  const ItemBandeja({
    required this.id,
    required this.mensaje,
    required this.accionCorrecta,
    required this.explicacion,
    this.indicios = const [],
  });

  factory ItemBandeja.fromJson(Map<String, dynamic> json) => ItemBandeja(
    id: json['id'] as String,
    mensaje: MensajeSimulado.fromJson(json['mensaje'] as Map<String, dynamic>),
    accionCorrecta: AccionBandeja.desdeCodigo(
      json['accion_correcta'] as String,
    ),
    explicacion: json['explicacion'] as String,
    indicios: listaDeTextos(
      json['indicios'],
    ).map(Indicio.desdeCodigo).toList(),
  );

  final String id;
  final MensajeSimulado mensaje;
  final AccionBandeja accionCorrecta;
  final String explicacion;
  final List<Indicio> indicios;
}

class ContenidoBandeja extends ContenidoActividad {
  const ContenidoBandeja({required this.mensajes});

  factory ContenidoBandeja.fromJson(Map<String, dynamic> json) =>
      ContenidoBandeja(
        mensajes: listaDeMapas(
          json['bandeja'],
        ).map(ItemBandeja.fromJson).toList(),
      );

  /// Cinco mensajes (CLAUDE.md §10.3).
  final List<ItemBandeja> mensajes;

  @override
  int get totalItems => mensajes.length;

  @override
  Set<Indicio> get indiciosUsados => {
    for (final m in mensajes) ...m.indicios,
  };
}

// ---------- A6 · Verifica en 3 pasos ----------

/// Correo con un sello de prueba que el usuario verifica con el verificador
/// real. Uno de los casos trae un sello copiado de otro correo.
class CasoVerificacion {
  const CasoVerificacion({
    required this.id,
    required this.mensaje,
    required this.esEstafa,
    required this.explicacion,
    this.indicios = const [],
  });

  factory CasoVerificacion.fromJson(Map<String, dynamic> json) =>
      CasoVerificacion(
        id: json['id'] as String,
        mensaje: MensajeSimulado.fromJson(
          json['mensaje'] as Map<String, dynamic>,
        ),
        esEstafa: json['es_estafa'] as bool,
        explicacion: json['explicacion'] as String,
        indicios: listaDeTextos(
          json['indicios'],
        ).map(Indicio.desdeCodigo).toList(),
      );

  final String id;

  /// Trae siempre `codigo_verificacion`.
  final MensajeSimulado mensaje;
  final bool esEstafa;
  final String explicacion;
  final List<Indicio> indicios;
}

class ContenidoVerifica extends ContenidoActividad {
  const ContenidoVerifica({required this.casos});

  factory ContenidoVerifica.fromJson(Map<String, dynamic> json) =>
      ContenidoVerifica(
        casos: listaDeMapas(
          json['casos'],
        ).map(CasoVerificacion.fromJson).toList(),
      );

  final List<CasoVerificacion> casos;

  @override
  int get totalItems => casos.length;

  @override
  Set<Indicio> get indiciosUsados => {for (final c in casos) ...c.indicios};
}

// ---------- A7 · Audio-reto ----------

/// Uno de los dos botones grandes del audio-reto.
class OpcionAudio {
  const OpcionAudio({
    required this.id,
    required this.texto,
    required this.esCorrecta,
    required this.feedback,
  });

  factory OpcionAudio.fromJson(Map<String, dynamic> json) => OpcionAudio(
    id: json['id'] as String,
    texto: json['texto'] as String,
    esCorrecta: json['es_correcta'] as bool,
    feedback: json['feedback'] as String,
  );

  final String id;
  final String texto;
  final bool esCorrecta;
  final String feedback;
}

class ContenidoAudioReto extends ContenidoActividad {
  const ContenidoAudioReto({
    required this.guion,
    required this.opciones,
    this.audioUrl,
  });

  factory ContenidoAudioReto.fromJson(Map<String, dynamic> json) {
    final audio = json['audio'] as Map<String, dynamic>;
    return ContenidoAudioReto(
      guion: audio['guion'] as String,
      audioUrl: audio['url'] as String?,
      opciones: listaDeMapas(
        json['opciones'],
      ).map(OpcionAudio.fromJson).toList(),
    );
  }

  /// Texto del audio. Mientras no haya reproductor se muestra como texto.
  final String guion;

  /// Archivo de audio. Null hasta que se graben los audios.
  final String? audioUrl;
  final List<OpcionAudio> opciones;

  @override
  int get totalItems => 1;

  @override
  Set<Indicio> get indiciosUsados => const {};
}

// ---------- Mecánicas sin componente todavía ----------

class ContenidoPendiente extends ContenidoActividad {
  const ContenidoPendiente();

  @override
  int get totalItems => 0;

  @override
  Set<Indicio> get indiciosUsados => const {};
}
