import 'package:capacitacion/src/application/logica/logica.dart';
import 'package:capacitacion/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final catalogo = [
    actividad('t2-larga', tipologia: Tipologia.t2, duracion: 120),
    actividad('t2-corta', tipologia: Tipologia.t2, duracion: 60),
    actividad('t3-ex1', modulo: 'M5', tipologia: Tipologia.t3),
  ];

  ResultadoVerificacion rojo(Tipologia? t) => ResultadoVerificacion(
    estado: 'PHISHING_CONFIRMADO',
    semaforo: Semaforo.rojo,
    motivo: '',
    tipologiaSuplantada: t,
  );

  test('elige la tipología suplantada, pendiente y más corta', () {
    final a = actividadParaVerificacion(
      resultado: rojo(Tipologia.t2),
      actividades: catalogo,
      perfil: const Perfil(),
      progreso: const Progreso().marcarCompletada('t2-corta'),
    );
    expect(a?.id, 't2-larga');
  });

  test('solo ofrece lo que le corresponde al tipo', () {
    // M5 es para EX1, EX2 y EX4: un EX5 no lo ve.
    final a = actividadParaVerificacion(
      resultado: rojo(Tipologia.t3),
      actividades: catalogo,
      perfil: const Perfil(),
      progreso: const Progreso(),
    );
    expect(a, isNull);
  });

  group('con el análisis de la IA', () {
    ResultadoVerificacion conIndicios(List<Indicio> indicios) =>
        ResultadoVerificacion(
          estado: 'SELLO_INEXISTENTE',
          semaforo: Semaforo.rojo,
          motivo: '',
          tipologiaSuplantada: Tipologia.t2,
          analisis: AnalisisRiesgo(explicacion: '', indicios: indicios),
        );

    final conIndiciosCatalogo = [
      actividad('t2-general', tipologia: Tipologia.t2),
      actividad(
        'm1-qr',
        tipologia: Tipologia.t1,
        indicios: const [Indicio.i11],
      ),
      actividad(
        'm6-qr',
        modulo: 'M6',
        tipologia: Tipologia.t1,
        indicios: const [Indicio.i11],
      ),
    ];

    test('prefiere el módulo del microcurso del indicio', () {
      // I11 → «No confíes en la página que abre un QR» (M6).
      final r = conIndicios(const [Indicio.i11]);
      expect(microcursoParaVerificacion(r), Microcurso.paginaDelQr);
      final a = actividadParaVerificacion(
        resultado: r,
        actividades: conIndiciosCatalogo,
        perfil: const Perfil(),
        progreso: const Progreso(),
      );
      expect(a?.id, 'm6-qr');
    });

    test('si nadie trabaja el indicio, vuelve a la tipología', () {
      final r = conIndicios(const [Indicio.i5]);
      final a = actividadParaVerificacion(
        resultado: r,
        actividades: conIndiciosCatalogo,
        perfil: const Perfil(),
        progreso: const Progreso(),
      );
      expect(a?.id, 't2-general');
    });

    test('sin indicios no hay microcurso', () {
      expect(microcursoParaVerificacion(rojo(Tipologia.t2)), isNull);
    });
  });

  test('en verde usa la tipología de los metadatos', () {
    final a = actividadParaVerificacion(
      resultado: ResultadoVerificacion(
        estado: 'LEGITIMO',
        semaforo: Semaforo.verde,
        motivo: '',
        metadatosOficiales: MetadatosOficiales(
          emisorNombre: 'x',
          tipologia: Tipologia.t3,
          asuntoResumen: 'y',
          fecha: DateTime.utc(2026),
        ),
      ),
      actividades: catalogo,
      perfil: const Perfil(tipos: {TipoUsuario.ex1}),
      progreso: const Progreso(),
    );
    expect(a?.id, 't3-ex1');
  });
}
