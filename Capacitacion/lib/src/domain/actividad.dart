import 'contenido_actividad.dart';
import 'indicio.dart';
import 'json.dart';
import 'mecanica.dart';
import 'modulo.dart';
import 'perfil.dart';
import 'tipo_usuario.dart';
import 'tipologia.dart';

/// Actividad de capacitación con el formato JSON de CLAUDE.md §12. La app la
/// muestra con el componente de su [mecanica].
///
/// Además de los campos de §12 lleva `titulo` y `resumen` (para listarla) y
/// el contenido propio de la mecánica (ver [ContenidoActividad]).
class Actividad {
  const Actividad({
    required this.id,
    required this.modulo,
    required this.mecanica,
    required this.titulo,
    required this.duracionSegundos,
    required this.mensajeClave,
    required this.contenido,
    this.resumen = '',
    this.pasos4r = const [],
    this.tipos = const {},
    this.tipologia,
    this.indicios = const [],
    this.varianteEx2,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    final mecanica = Mecanica.desdeCodigo(json['mecanica'] as String);
    final tipologia = json['tipologia'] as String?;
    return Actividad(
      id: json['id'] as String,
      modulo: (json['modulo'] as String).trim().toUpperCase(),
      mecanica: mecanica,
      titulo: json['titulo'] as String,
      resumen: json['resumen'] as String? ?? '',
      pasos4r: listaDeTextos(json['paso_4r']).map(Paso4R.desdeCodigo).toList(),
      tipos: listaDeTextos(json['tipos']).map(TipoUsuario.desdeCodigo).toSet(),
      tipologia: tipologia == null ? null : Tipologia.desdeCodigo(tipologia),
      indicios: listaDeTextos(
        json['indicios'],
      ).map(Indicio.desdeCodigo).toList(),
      varianteEx2: json['variante_ex2'] as String?,
      duracionSegundos: json['duracion_seg'] as int,
      mensajeClave: json['mensaje_clave'] as String,
      contenido: ContenidoActividad.desdeJson(mecanica, json),
    );
  }

  /// Ej.: `M1-A1-01`.
  final String id;

  /// Código del módulo (M1…M14).
  final String modulo;
  final Mecanica mecanica;
  final String titulo;
  final String resumen;
  final List<Paso4R> pasos4r;

  /// Tipos a los que va dirigida. Vacío: todos los del módulo.
  final Set<TipoUsuario> tipos;

  /// Tipología que enseña a reconocer. Null si es general.
  final Tipologia? tipologia;
  final List<Indicio> indicios;

  /// Id de la versión en audio (A7) que ve un EX2 en lugar de esta.
  final String? varianteEx2;

  /// Entre 1 y 5 minutos: poco y seguido (CLAUDE.md §10.1).
  final int duracionSegundos;

  /// La regla única que el usuario debe recordar.
  final String mensajeClave;
  final ContenidoActividad contenido;

  Modulo get moduloInfo => Modulo.porCodigo(modulo);

  /// Si le corresponde al usuario por su tipo y perfil. Un EX2 ve la
  /// [varianteEx2] en lugar de esta actividad.
  bool elegiblePara(Perfil perfil) {
    if (perfil.usaInterfazSimplificada && varianteEx2 != null) return false;
    final m = moduloInfo;
    if (!m.dirigidoA(perfil.tipos, perfil.perfilConducta)) return false;
    return tipos.isEmpty ||
        tipos.any(perfil.tipos.contains) ||
        (m.incluyeCentinelas && perfil.esCentinela);
  }
}
