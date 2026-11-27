// Tutorial corto: cómo copiar el contenido de un correo para pegarlo en AIESS (o guardarlo como .eml y subirlo).
// Lo usan la web de escritorio (debajo del cuadro del correo) y la pantalla del celular (en una hoja).
// El robot puede leer los pasos en voz alta.
import 'package:material_ui/material_ui.dart';

import '../features/voz/voz.dart';
import 'tema.dart';

enum _Donde {
  computadora('En la computadora', Icons.computer_rounded, [
    'Abre el correo que te parece raro (en Gmail, Outlook u otro).',
    'Selecciona todo el texto: haz clic antes del remitente y arrastra hasta el final del correo.',
    'Cópialo con Ctrl + C (en Mac, Cmd + C) o con clic derecho y «Copiar».',
    'Vuelve a AIESS, haz clic en el cuadro del correo y pégalo con Ctrl + V (en Mac, Cmd + V).',
  ]),
  celular('En el celular', Icons.smartphone_rounded, [
    'Abre el correo en la aplicación de correo de tu celular.',
    'Mantén el dedo sobre el texto hasta que se marque y toca «Seleccionar todo».',
    'Toca «Copiar».',
    'Vuelve a AIESS y toca «Pegar y revisar».',
  ]),
  archivo('Como archivo', Icons.attach_email_rounded, [
    'En Gmail: abre el correo, toca el menú de tres puntos y elige «Descargar mensaje».',
    'En otros programas: busca «Descargar» o «Guardar como» en el menú del correo.',
    'En AIESS toca «Subir correo» (en el celular, «Escanear o subir») y elige el archivo.',
  ]);

  const _Donde(this.titulo, this.icono, this.pasos);
  final String titulo;
  final IconData icono;
  final List<String> pasos;
}

/// Pasos para copiar un correo. [enComputadora] elige la pestaña con la que empieza.
class TutorialCopiar extends StatefulWidget {
  const TutorialCopiar({super.key, this.enComputadora = true});
  final bool enComputadora;

  @override
  State<TutorialCopiar> createState() => _TutorialCopiarState();
}

class _TutorialCopiarState extends State<TutorialCopiar> {
  late var _donde = widget.enComputadora ? _Donde.computadora : _Donde.celular;

  void _escuchar() {
    final pasos = [
      for (final (i, p) in _donde.pasos.indexed) 'Paso ${i + 1}: $p',
    ];
    Voz.i.decir(
      '${_donde.titulo}. ${pasos.join(' ')} Copia también el remitente y el asunto.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Tono.superficie,
        borderRadius: BorderRadius.circular(Radios.lg),
        border: Border.all(color: Tono.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text('Cómo copiar un correo', style: textos.titleMedium),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in _Donde.values)
                ChoiceChip(
                  avatar: Icon(d.icono, size: 20),
                  label: Text(d.titulo),
                  selected: _donde == d,
                  onSelected: (_) => setState(() => _donde = d),
                ),
            ],
          ),
          const SizedBox(height: 14),
          for (final (i, paso) in _donde.pasos.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Tono.lima,
                    foregroundColor: Tono.sobreLima,
                    child: Text(
                      '${i + 1}',
                      style: textos.labelLarge?.copyWith(color: Tono.sobreLima),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(paso, style: textos.bodyLarge)),
                ],
              ),
            ),
          Text(
            'Copia también el remitente y el asunto: ayudan a reconocer la estafa.',
            style: textos.bodyMedium?.copyWith(color: Tono.gris),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: _escuchar,
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('Escuchar los pasos'),
          ),
        ],
      ),
    );
  }
}

/// Celular: el tutorial en una hoja que sube desde abajo.
Future<void> mostrarTutorialCopiar(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Tono.fondo,
      builder: (_) => const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: TutorialCopiar(enComputadora: false),
        ),
      ),
    );
