import 'dart:convert';
import 'dart:io';

import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contrato con el observador (Radar Phishing): los JSON de
/// `Analisis-de-comportamiento/contrato/` los valida el propio observador en
/// sus pruebas (`test_contrato.py`), así que coincidir con ellos asegura que
/// el servidor acepta lo que envía la app y que la app lee lo que responde.
void main() {
  const contrato = '../Analisis-de-comportamiento/contrato';
  const id = 'a3f9c2e17b4d48e0b6c1';

  Map<String, dynamic> leer(String nombre) =>
      jsonDecode(File('$contrato/$nombre').readAsStringSync())
          as Map<String, dynamic>;

  test('lee el plan del observador (plan.ejemplo.json)', () {
    final plan = PlanPersonalizado.fromJson(leer('plan.ejemplo.json'));
    expect(plan.idSeudonimo, id);
    expect(plan.origen, OrigenPlan.servidor);
    expect(plan.falencias, hasLength(3));
    expect(plan.falencias.first.indicio, Indicio.i1);
    expect(plan.falencias.first.estado, EstadoIndicio.debil);
    expect(plan.falencias.first.modulo, 'M1');
    expect(plan.falencias.first.motivos, isNotEmpty);
    expect(plan.mapa.estadoDe(Indicio.i1), EstadoIndicio.debil);
    expect(plan.mapa.estadoDe(Indicio.i3), EstadoIndicio.sinProbar);
    expect(plan.foco, Tipologia.t2);
    expect(plan.perfilEtiqueta, 'Sin perfil');
    expect(plan.confianza, 'MEDIA');
    expect(plan.observaciones, 3);
    expect(plan.precision, 0.5);
    expect(plan.debiles, {Indicio.i1, Indicio.i7, Indicio.i2});
  });

  test('una decisión viaja con el formato de observacion_decision.json', () {
    final esperado = leer('observacion_decision.json');
    final o = ObservacionConducta.decision(
      actividadId: 'M1-A2-01',
      itemId: 'M1-A2-01-t3',
      esEstafa: true,
      acerto: true,
      indicios: const [Indicio.i6, Indicio.i10],
      tipologia: Tipologia.t2,
      momento: DateTime.utc(2026, 11, 26, 15, 50, 3),
    );
    final json = o.toJson(
      idSeudonimo: id,
      tipos: {TipoUsuario.ex1},
      rangoEtario: RangoEtario.r30a49,
    );
    expect(json, {
      ...esperado,
      'momento': DateTime.parse(esperado['momento'] as String)
          .toUtc()
          .toIso8601String(),
    });
  });

  test('un simulacro y una verificación viajan con el formato acordado', () {
    final plantilla = plantillasPrueba.firstWhere(
      (p) => p.id == 'N2-EX1-reembolso',
    );
    final simulacro = ObservacionConducta.simulacro(
      correo: CorreoPrueba(
        simulacroId: 'sim-1',
        plantilla: plantilla,
        nivel: plantilla.nivel,
        enviadoEn: DateTime.utc(2026, 11, 26, 15),
        venceEn: DateTime.utc(2026, 11, 26, 15, 10),
      ),
      resultado: ResultadoSimulacro.clic,
      momento: DateTime.utc(2026, 11, 26, 15, 42, 10),
    ).toJson(idSeudonimo: id, tipos: {TipoUsuario.ex1});
    final esperado = leer('observacion_simulacro.json');
    for (final campo in [
      'id_seudonimo',
      'tipo',
      'tipos',
      'plantilla_id',
      'nivel',
      'tipologia',
      'indicios',
      'indicios_implicitos',
      'resultado',
    ]) {
      expect(simulacro[campo], esperado[campo], reason: campo);
    }

    final verificacion = ObservacionConducta.verificacion(
      semaforo: Semaforo.rojo,
      momento: DateTime.utc(2026, 11, 26, 16, 5),
    ).toJson(idSeudonimo: id, tipos: {TipoUsuario.ex1});
    expect(verificacion['tipo'], 'VERIFICACION');
    expect(
      verificacion['semaforo'],
      leer('observacion_verificacion.json')['semaforo'],
    );
  });

  test('se guarda en el dispositivo sin el código y se recupera igual', () {
    final o = ObservacionConducta.decision(
      actividadId: 'M1-A1-01',
      itemId: 'M1-A1-01-cuerpo:2',
      esEstafa: true,
      acerto: false,
      indicios: const [Indicio.i3],
      momento: DateTime.utc(2026, 11, 27, 9),
    );
    final guardado = o.toJson();
    expect(guardado.containsKey('id_seudonimo'), isFalse);
    final otra = ObservacionConducta.fromJson(guardado);
    expect(otra.toJson(), guardado);
  });
}
