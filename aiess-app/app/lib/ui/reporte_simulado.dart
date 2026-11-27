// Reporte al IESS SIMULADO (reglas del reto: «solo se simula el canal de reporte y la integración con el IESS»).
// No se abre el correo ni se envía nada: se arma el reporte que en producción iría al IESS, con un número de caso,
// y se guarda en el equipo un registro mínimo como evidencia (hora, caso y la HUELLA del correo, nunca su texto).
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/canales.dart';
import '../features/analisis/anonimizar.dart';
import '../features/analisis/motor.dart';
import '../features/osint/url_analyzer.dart';
import 'partes_correo.dart';
import 'tema.dart';

class ReporteSimulado {
  ReporteSimulado({
    required this.caso,
    required this.destinatario,
    required this.indicios,
    required this.dominios,
    required this.asunto,
    required this.huella,
    required this.hora,
  });
  final String caso, destinatario, asunto, huella;
  final List<String> indicios, dominios;
  final DateTime hora;

  /// Arma el reporte SIN el cuerpo del correo y SIN datos personales (asunto anonimizado).
  static ReporteSimulado preparar(
    Veredicto v,
    String texto, {
    DateTime? ahora,
  }) {
    final t = ahora ?? DateTime.now();
    const letras = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    final sufijo = String.fromCharCodes(
      List.generate(4, (_) => letras.codeUnitAt(r.nextInt(letras.length))),
    );
    String dos(int n) => n.toString().padLeft(2, '0');
    final asunto = PartesCorreo.de(texto).asunto ?? '';
    return ReporteSimulado(
      caso: 'AIESS-${t.year}${dos(t.month)}${dos(t.day)}-$sufijo',
      destinatario: Canales.i.contacto['seguridad_informacion'] ?? '',
      indicios: indiciosValidos(v.indicios),
      dominios: {
        for (final u in analizarMensaje(texto).urls)
          if (!u.confiable && u.host.isNotEmpty) u.host,
      }.toList(),
      asunto: anonimizar(asunto).texto,
      huella: sha256.convert(utf8.encode(texto.trim())).toString(),
      hora: t,
    );
  }

  /// Registro local (evidencia): hora, número de caso y huella del correo. Nunca el texto.
  Map<String, String> get registro => {
    'hora': hora.toUtc().toIso8601String(),
    'caso': caso,
    'huella_correo': huella,
  };

  Future<void> guardar() async {
    final p = await SharedPreferences.getInstance();
    final lista = p.getStringList('reportes_simulados') ?? [];
    lista.add(jsonEncode(registro));
    await p.setStringList('reportes_simulados', lista);
  }
}

/// Prepara el reporte, lo guarda en el equipo y lo muestra. No sale nada del equipo.
Future<void> mostrarReporteSimulado(
  BuildContext context,
  Veredicto v,
  String texto,
) async {
  final r = ReporteSimulado.preparar(v, texto);
  await r.guardar();
  if (!context.mounted) return;
  const estilo = TextStyle(fontSize: 17, color: Tono.tinta, height: 1.4);
  Widget fila(String titulo, String valor) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Tono.gris,
          ),
        ),
        Text(valor, style: estilo),
      ],
    ),
  );
  await showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      icon: const Icon(
        Icons.assignment_turned_in_rounded,
        size: 36,
        color: Tono.tinta,
      ),
      title: const Text('Reporte preparado (simulación)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fila('Para', r.destinatario),
            fila('Número de caso', r.caso),
            fila(
              'Indicios (${r.indicios.length})',
              r.indicios.isEmpty
                  ? 'Ninguno'
                  : r.indicios.map((k) => '$k ${nombreIndicio[k]}').join('\n'),
            ),
            fila(
              'Dominios sospechosos',
              r.dominios.isEmpty ? 'Ninguno' : r.dominios.join(', '),
            ),
            if (r.asunto.isNotEmpty)
              fila('Asunto (sin datos personales)', r.asunto),
            const SizedBox(height: 4),
            const Text(
              'No incluye el texto del correo ni tus datos. En producción esto se enviaría al IESS; '
              'en la demo no sale del equipo.',
              style: TextStyle(fontSize: 15, color: Tono.gris, height: 1.4),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(c),
          style: FilledButton.styleFrom(minimumSize: const Size(120, 52)),
          child: const Text('Listo', style: TextStyle(fontSize: 18)),
        ),
      ],
    ),
  );
}
