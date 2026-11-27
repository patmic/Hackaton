// «Mostrar sus partes sin abrir enlaces ni adjuntos» (paso 2 del reto): remitente, asunto, a dónde llevan
// DE VERDAD los enlaces y qué adjuntos trae. Todo sale del texto que ya está en la app: no se abre ningún
// enlace ni se descarga ningún adjunto.
import 'package:material_ui/material_ui.dart';

import '../core/canales.dart';
import '../features/osint/url_analyzer.dart';
import 'tema.dart';

class PartesCorreo {
  PartesCorreo({
    required this.remitente,
    required this.asunto,
    required this.enlaces,
    required this.adjuntos,
  });
  final String? remitente, asunto;

  /// (texto que se ve, destino real, ¿oficial o confiable?)
  final List<(String?, String, bool)> enlaces;
  final List<String> adjuntos;

  bool get vacio =>
      remitente == null &&
      asunto == null &&
      enlaces.isEmpty &&
      adjuntos.isEmpty;

  static final _linea = (String clave) => RegExp(
    '^\\s*(?:$clave)\\s*:\\s*(.+)\$',
    caseSensitive: false,
    multiLine: true,
  );

  static PartesCorreo de(String texto) {
    final remitente =
        _linea('de|from|remitente').firstMatch(texto)?.group(1)?.trim() ??
        RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+').firstMatch(texto)?.group(0);
    final asunto = _linea('asunto|subject').firstMatch(texto)?.group(1)?.trim();
    // Del lector .eml: «texto visible [destino real]».
    final visibles = <String, String>{
      for (final m in RegExp(
        r'([^\[\]\n]{2,80})\s\[(https?://[^\]\s]+)\]',
      ).allMatches(texto))
        m.group(2)!: m.group(1)!.trim(),
    };
    final enlaces = <(String?, String, bool)>[
      for (final u in analizarMensaje(texto).urls)
        (visibles[u.url], u.url, u.oficial || u.confiable),
    ];
    final ext = [
      ...Canales.i.extPeligrosas.where((e) => e != 'html' && e != 'htm'),
      'pdf',
      'docx',
      'xlsx',
    ].join('|');
    final adjuntos = <String>{
      ...?_linea('adjuntos|attachments?')
          .firstMatch(texto)
          ?.group(1)
          ?.split(',')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty),
      for (final m in RegExp(
        '\\b[\\w.-]+\\.($ext)\\b',
        caseSensitive: false,
      ).allMatches(texto))
        if (!m.group(0)!.contains('/') &&
            !RegExp(r'^www\.').hasMatch(m.group(0)!))
          m.group(0)!,
    }.toList();
    return PartesCorreo(
      remitente: remitente,
      asunto: asunto,
      enlaces: enlaces,
      adjuntos: adjuntos,
    );
  }
}

/// Panel plegable con las partes del correo. [color] = color del veredicto.
class PanelPartesCorreo extends StatelessWidget {
  const PanelPartesCorreo({super.key, required this.texto, this.color});
  final String texto;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = PartesCorreo.de(texto);
    if (p.vacio) return const SizedBox.shrink();
    final estilo = const TextStyle(
      fontSize: 16,
      color: Tono.tinta,
      height: 1.4,
    );
    Widget fila(IconData i, String titulo, Widget valor) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, size: 20, color: Tono.gris),
          const SizedBox(width: 10),
          Expanded(
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
                valor,
              ],
            ),
          ),
        ],
      ),
    );
    // Material transparente: la tarjeta de color de abajo sigue viéndose y el toque muestra su efecto.
    return Material(
      type: MaterialType.transparency,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 6),
          leading: const Icon(Icons.manage_search_rounded, color: Tono.tinta),
          title: const Text(
            'Partes del correo',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Tono.tinta,
            ),
          ),
          subtitle: const Text(
            'Sin abrir enlaces ni adjuntos',
            style: TextStyle(fontSize: 14, color: Tono.gris),
          ),
          children: [
            if (p.remitente != null)
              fila(
                Icons.person_outline_rounded,
                'Remitente',
                Text(p.remitente!, style: estilo),
              ),
            if (p.asunto != null)
              fila(
                Icons.subject_rounded,
                'Asunto',
                Text(p.asunto!, style: estilo),
              ),
            fila(
              Icons.link_rounded,
              'Enlaces (${p.enlaces.length}) · a dónde llevan de verdad',
              p.enlaces.isEmpty
                  ? Text('Ninguno', style: estilo)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (visible, destino, ok) in p.enlaces)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: ok ? '✓ oficial  ' : '✗ no oficial  ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: ok ? Tono.verde : Tono.rojo,
                                    ),
                                  ),
                                  if (visible != null && visible != destino)
                                    TextSpan(text: 'dice «$visible» → '),
                                  TextSpan(text: destino),
                                ],
                              ),
                              style: estilo,
                            ),
                          ),
                      ],
                    ),
            ),
            fila(
              Icons.attach_file_rounded,
              'Adjuntos (${p.adjuntos.length}) · no se abrieron',
              Text(
                p.adjuntos.isEmpty ? 'Ninguno' : p.adjuntos.join(', '),
                style: estilo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
