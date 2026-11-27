import 'dart:io';

import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Desplaza la lista visible hasta que [finder] exista y quede en pantalla.
///
/// Las listas de Flutter construyen sus hijos a medida que aparecen: un
/// botón al final de una pantalla larga todavía no existe hasta que se llega
/// a él, así que `ensureVisible` solo no basta.
Future<void> mostrar(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    final listaVisible = find
        .byWidgetPredicate(
          (w) =>
              w is Scrollable &&
              axisDirectionToAxis(w.axisDirection) == Axis.vertical,
        )
        .hitTestable();
    await tester.scrollUntilVisible(
      finder,
      150,
      scrollable: listaVisible.first,
      maxScrolls: 100,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

/// Lleva [finder] a la pantalla y lo toca.
Future<void> tocar(WidgetTester tester, Finder finder) async {
  await mostrar(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Sello válido del Núcleo simulado (T2, Dirección de Prestaciones y
/// Pensiones).
const hashValido =
    '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4';

/// Sello revocado del Núcleo simulado (T1, Dirección de Afiliación).
const hashRevocado =
    '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b';

List<Actividad> catalogoReal() =>
    parsearActividades(File('assets/data/actividades.json').readAsStringSync());

Actividad actividad(
  String id, {
  String modulo = 'M1',
  Mecanica mecanica = Mecanica.a1,
  Tipologia? tipologia = Tipologia.t1,
  Set<TipoUsuario> tipos = const {},
  int duracion = 60,
  String? varianteEx2,
  List<Indicio> indicios = const [],
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
  indicios: indicios,
  mensajeClave: 'clave $id',
  contenido: contenido,
);

TarjetaRealOEstafa tarjeta(String id, {required bool esEstafa}) =>
    TarjetaRealOEstafa(
      id: id,
      mensaje: const MensajeSimulado(
        remitente: 'a@b.c',
        asunto: 's',
        cuerpo: 'c',
      ),
      esEstafa: esEstafa,
      explicacion: 'exp $id',
      indicios: esEstafa ? const [Indicio.i7] : const [],
    );

Actividad rondaA2(String id, List<TarjetaRealOEstafa> tarjetas) => actividad(
  id,
  mecanica: Mecanica.a2,
  contenido: ContenidoRealOEstafa(tarjetas: tarjetas),
);
