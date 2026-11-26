import 'dart:io';

import 'package:capacitacion/src/data/capsula_repository.dart';
import 'package:capacitacion/src/domain/domain.dart';

List<Capsula> catalogoReal() =>
    parsearCatalogo(File('assets/data/capsulas.json').readAsStringSync());

Capsula capsula(
  String id, {
  Tipologia tipologia = Tipologia.t1,
  List<RangoEtario> rangos = RangoEtario.values,
  FormatoCapsula formato = FormatoCapsula.texto,
  int duracion = 60,
  List<PreguntaQuiz> preguntas = const [],
}) => Capsula(
  id: id,
  titulo: id,
  resumen: '',
  tipologia: tipologia,
  rangos: rangos,
  formato: formato,
  duracionSegundos: duracion,
  mensajeClave: 'clave $id',
  preguntas: preguntas,
);

PreguntaQuiz pregunta(String id, {required bool esEstafa}) => PreguntaQuiz(
  id: id,
  correo: const CorreoEjemplo(remitente: 'a@b.c', asunto: 's', cuerpo: 'c'),
  esEstafa: esEstafa,
  explicacion: 'exp $id',
);
