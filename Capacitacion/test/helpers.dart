import 'dart:io';

import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/domain/domain.dart';

List<Actividad> catalogoReal() => parsearActividades(
  File('assets/data/actividades.json').readAsStringSync(),
);

Actividad actividad(
  String id, {
  String modulo = 'M1',
  Mecanica mecanica = Mecanica.a1,
  Tipologia? tipologia = Tipologia.t1,
  Set<TipoUsuario> tipos = const {},
  int duracion = 60,
  String? varianteEx2,
  ContenidoActividad contenido = const ContenidoPendiente(),
}) => Actividad(
  id: id,
  modulo: modulo,
  mecanica: mecanica,
  titulo: id,
  tipologia: tipologia,
  tipos: tipos,
  duracionSegundos: duracion,
  varianteEx2: varianteEx2,
  mensajeClave: 'clave $id',
  contenido: contenido,
);

TarjetaRealOEstafa tarjeta(String id, {required bool esEstafa}) =>
    TarjetaRealOEstafa(
      id: id,
      mensaje: const MensajeSimulado(remitente: 'a@b.c', asunto: 's', cuerpo: 'c'),
      esEstafa: esEstafa,
      explicacion: 'exp $id',
      indicios: esEstafa ? const [Indicio.i7] : const [],
    );

Actividad rondaA2(String id, List<TarjetaRealOEstafa> tarjetas) => actividad(
  id,
  mecanica: Mecanica.a2,
  contenido: ContenidoRealOEstafa(tarjetas: tarjetas),
);
