import 'dart:convert';
import 'dart:io';

import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:capacitacion/src/domain/json.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// El observador del dispositivo usa el mismo modelo que el del servidor
/// (`Analisis-de-comportamiento/observador/modelo.py`).
void main() {
  const contrato = '../Analisis-de-comportamiento/contrato';
  const local = ObservadorLocal();
  final ahora = DateTime.utc(2026, 11, 27, 12);

  Map<String, dynamic> leer(String nombre) =>
      jsonDecode(File('$contrato/$nombre').readAsStringSync())
          as Map<String, dynamic>;

  ObservacionConducta decision(
    Indicio indicio, {
    required bool acerto,
    int dias = 0,
    Tipologia? tipologia,
  }) => ObservacionConducta.decision(
    actividadId: 'M1-A2-01',
    itemId: 'M1-A2-01-t${indicio.codigo}',
    esEstafa: true,
    acerto: acerto,
    indicios: [indicio],
    tipologia: tipologia,
    momento: ahora.subtract(Duration(days: dias)),
  );

  CorreoPrueba correo(String id) => CorreoPrueba(
    simulacroId: 'sim-1',
    plantilla: plantillasPrueba.firstWhere((p) => p.id == id),
    nivel: plantillasPrueba.firstWhere((p) => p.id == id).nivel,
    enviadoEn: ahora,
    venceEn: ahora.add(const Duration(minutes: 10)),
  );

  test('da el mismo mapa de indicios que el observador del servidor', () {
    final obs = [
      for (final n in ['simulacro', 'decision', 'verificacion'])
        ObservacionConducta.fromJson(leer('observacion_$n.json')),
    ];
    final plan = leer('plan.ejemplo.json');
    final momento = DateTime.parse(plan['generado_en'] as String);
    final ev = local.evidencia(obs, momento);
    for (final esperado in listaDeMapas(plan['indicios'])) {
      final i = Indicio.desdeCodigo(esperado['indicio'] as String);
      final e = ev[i]!;
      expect(e.estado.codigo, esperado['estado'], reason: i.codigo);
      expect(
        e.dominio,
        closeTo((esperado['dominio'] as num).toDouble(), 0.001),
        reason: i.codigo,
      );
      expect(
        e.total,
        closeTo((esperado['evidencia'] as num).toDouble(), 0.001),
        reason: i.codigo,
      );
    }
  });

  test('sin prácticas todo está sin probar y la confianza es baja', () {
    final plan = local.plan(
      idSeudonimo: 'id',
      observaciones: const [],
      ahora: ahora,
      tipos: {TipoUsuario.ex1},
      actividades: catalogoReal(),
    );
    expect(plan.sinDatos, isTrue);
    expect(plan.confianza, 'BAJA');
    expect(plan.falencias, hasLength(3));
    expect(
      plan.falencias.every((f) => f.estado == EstadoIndicio.sinProbar),
      isTrue,
    );
  });

  test('lo que se le pasa en las actividades sube primero en el plan', () {
    final plan = local.plan(
      idSeudonimo: 'id',
      observaciones: [
        decision(Indicio.i3, acerto: false),
        decision(Indicio.i3, acerto: false),
        decision(Indicio.i1, acerto: true),
        decision(Indicio.i1, acerto: true),
      ],
      ahora: ahora,
      tipos: {TipoUsuario.ex1},
    );
    final primera = plan.falencias.first;
    expect(primera.indicio, Indicio.i3);
    expect(primera.estado, EstadoIndicio.debil);
    expect(primera.modulo, 'M1');
    expect(primera.motivos, contains(startsWith('En las actividades')));
    expect(plan.mapa.estadoDe(Indicio.i1), EstadoIndicio.dominado);
    expect(plan.falencias.map((f) => f.indicio), isNot(contains(Indicio.i1)));
    expect(plan.precision, 0.5);
  });

  test(
    'lo que ya le engañó entra al plan aunque sus lecciones casi no lo traigan',
    () {
      // Una sin cuenta (EX5) cae tres veces con un QR: I11 aparece en pocas de
      // sus lecciones, pero ya le costó, así que va antes que lo no probado.
      final plan = local.plan(
        idSeudonimo: 'id',
        observaciones: [
          for (var k = 0; k < 3; k++) decision(Indicio.i11, acerto: false),
        ],
        ahora: ahora,
        tipos: {TipoUsuario.ex5},
        actividades: catalogoReal()
            .where((a) => a.elegiblePara(const Perfil()))
            .toList(),
      );
      expect(plan.falencias.first.indicio, Indicio.i11);
      expect(plan.falencias.first.estado, EstadoIndicio.debil);
    },
  );

  test('practicar bien lo saca del plan: aprende de cada respuesta', () {
    final fallos = [
      decision(Indicio.i3, acerto: false, dias: 2),
      decision(Indicio.i3, acerto: false, dias: 2),
    ];
    final antes = local.estados(fallos, ahora)[Indicio.i3];
    final despues = local.estados([
      ...fallos,
      for (var k = 0; k < 6; k++) decision(Indicio.i3, acerto: true),
    ], ahora)[Indicio.i3];
    expect(antes, EstadoIndicio.debil);
    expect(despues, EstadoIndicio.dominado);
  });

  test('el correo de prueba pesa más que la práctica y según su nivel', () {
    // Clic en el primer correo del afiliado (nivel 2: I6, I1, I7; I2 implícito).
    final clic = ObservacionConducta.simulacro(
      correo: correo('N2-EX1-reembolso'),
      resultado: ResultadoSimulacro.clic,
      momento: ahora,
    );
    final ev = local.evidencia([clic], ahora);
    expect(ev[Indicio.i6]!.fallo, closeTo(1.0, 1e-9));
    expect(ev[Indicio.i2]!.fallo, closeTo(0.5, 1e-9), reason: 'implícito');
    final plan = local.plan(
      idSeudonimo: 'id',
      observaciones: [clic],
      ahora: ahora,
      tipos: {TipoUsuario.ex1},
    );
    expect(
      plan.falencias.first.motivos,
      contains('Hiciste clic una vez en correos de práctica que lo tenían.'),
    );
    expect(plan.foco, Tipologia.t2, reason: 'el correo imitaba T2');
  });

  test('ignorar un correo no suma ni resta dominio', () {
    final ignoro = ObservacionConducta.simulacro(
      correo: correo('N2-EX1-reembolso'),
      resultado: ResultadoSimulacro.ignoro,
      momento: ahora,
    );
    expect(local.estados([ignoro], ahora).values.toSet(), {
      EstadoIndicio.sinProbar,
    });
  });

  test('lo dominado hace más de dos meses vuelve al plan para repasar', () {
    final observaciones = [
      for (var k = 0; k < 8; k++) decision(Indicio.i8, acerto: true, dias: 70),
      // Las demás señales, dominadas hace poco.
      for (final i in Indicio.values)
        if (i != Indicio.i8)
          for (var k = 0; k < 6; k++) decision(i, acerto: true, dias: 3),
    ];
    final plan = local.plan(
      idSeudonimo: 'id',
      observaciones: observaciones,
      ahora: ahora,
      tipos: {TipoUsuario.ex2},
    );
    expect(plan.falencias.map((f) => f.indicio), [Indicio.i8]);
    final i8 = plan.falencias.single;
    expect(i8.estado, EstadoIndicio.dominado);
    expect(i8.modulo, 'M7', reason: 'microcurso de I8 para EX2');
    expect(i8.motivos, contains(startsWith('Lo dominabas')));
  });

  test('el foco es la tipología que más le cuesta', () {
    final plan = local.plan(
      idSeudonimo: 'id',
      observaciones: [
        decision(Indicio.i8, acerto: false, tipologia: Tipologia.t5),
        decision(Indicio.i6, acerto: true, tipologia: Tipologia.t2),
      ],
      ahora: ahora,
      tipos: {TipoUsuario.ex1},
    );
    expect(plan.foco, Tipologia.t5);
  });
}
