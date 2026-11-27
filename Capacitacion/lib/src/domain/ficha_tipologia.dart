import 'indicio.dart';
import 'json.dart';
import 'tipologia.dart';

/// Ficha de una tipología de correo oficial, tal como la define
/// `tipologias-correo/tipologias.json`.
///
/// Capacitación usa `nunca_trae` y `capsula` como contenido (README de
/// tipologías, sección 4): un correo que dice ser de una tipología y trae algo
/// de su lista `nunca_trae` es phishing aunque traiga un sello válido.
class FichaTipologia {
  const FichaTipologia({
    required this.tipologia,
    required this.proposito,
    required this.capsula,
    this.publico = const [],
    this.ejemploAsunto = '',
    this.siempreTrae = const [],
    this.nuncaTrae = const [],
    this.dominiosEnlacePermitidos = const [],
    this.adjuntosPermitidos = const [],
    this.suplantacionFrecuente = const [],
  });

  factory FichaTipologia.fromJson(Map<String, dynamic> json) => FichaTipologia(
    tipologia: Tipologia.desdeCodigo(json['id'] as String),
    proposito: json['proposito'] as String,
    capsula: json['capsula'] as String,
    publico: listaDeTextos(json['publico']),
    ejemploAsunto: json['ejemplo_asunto'] as String? ?? '',
    siempreTrae: listaDeTextos(json['siempre_trae']),
    nuncaTrae: listaDeTextos(json['nunca_trae']),
    dominiosEnlacePermitidos: listaDeTextos(json['dominios_enlace_permitidos']),
    adjuntosPermitidos: listaDeTextos(json['adjuntos_permitidos']),
    suplantacionFrecuente: listaDeTextos(json['suplantacion_frecuente'])
        .map(Indicio.desdeCodigo)
        .toList(),
  );

  final Tipologia tipologia;
  final String proposito;

  /// Regla de una línea para el momento enseñable.
  final String capsula;

  /// `afiliados`, `pensionistas`, `empleadores`, `colaboradores`.
  final List<String> publico;
  final String ejemploAsunto;
  final List<String> siempreTrae;
  final List<String> nuncaTrae;
  final List<String> dominiosEnlacePermitidos;

  /// Extensiones permitidas (por ejemplo `pdf`). Vacío: ningún adjunto.
  final List<String> adjuntosPermitidos;

  /// Indicios con los que más se suplanta esta tipología, en orden.
  final List<Indicio> suplantacionFrecuente;

  bool permiteAdjunto(String extension) =>
      adjuntosPermitidos.contains(extension.trim().toLowerCase());
}

/// Las tipologías y el Sello IESS de `tipologias.json`.
class CatalogoTipologias {
  const CatalogoTipologias({
    required this.version,
    required this.fichas,
    this.reglaGeneral = '',
    this.remitenteOficial = '@iess.gob.ec',
    this.descripcionExternos = '',
    this.formatoCodigoSello = 'IESS-XXXX-XXXX',
    this.textoFijoSello = '',
    this.reglaCoherencia = '',
  });

  factory CatalogoTipologias.fromJson(Map<String, dynamic> json) {
    final sello = json['sello'] as Map<String, dynamic>? ?? const {};
    final enCorreo = sello['en_el_correo'] as Map<String, dynamic>? ?? const {};
    final codigo =
        enCorreo['codigo_verificacion'] as Map<String, dynamic>? ?? const {};
    final externos = json['externos'] as Map<String, dynamic>? ?? const {};
    return CatalogoTipologias(
      version: json['version'] as String,
      reglaGeneral: json['regla_general'] as String? ?? '',
      remitenteOficial: json['remitente_oficial'] as String? ?? '@iess.gob.ec',
      fichas: {
        for (final f in listaDeMapas(
          json['tipologias'],
        ).map(FichaTipologia.fromJson))
          f.tipologia: f,
      },
      descripcionExternos: externos['descripcion'] as String? ?? '',
      formatoCodigoSello: codigo['formato'] as String? ?? 'IESS-XXXX-XXXX',
      textoFijoSello: enCorreo['texto_fijo'] as String? ?? '',
      reglaCoherencia: sello['regla_coherencia'] as String? ?? '',
    );
  }

  final String version;
  final Map<Tipologia, FichaTipologia> fichas;
  final String reglaGeneral;
  final String remitenteOficial;

  /// Correos legítimos ajenos al IESS (grupo `EXT`).
  final String descripcionExternos;
  final String formatoCodigoSello;

  /// «Abra usted mismo la app IESS para verificar este correo…».
  final String textoFijoSello;

  /// Un sello verificado no basta si el correo contradice su tipología.
  final String reglaCoherencia;

  FichaTipologia? ficha(Tipologia tipologia) => fichas[tipologia];

  /// Cápsula de la tipología, o una regla general si no hay ficha.
  String capsulaDe(Tipologia? tipologia) =>
      (tipologia == null ? null : fichas[tipologia]?.capsula) ??
      'El IESS nunca le pide claves, pagos ni datos por correo.';
}
