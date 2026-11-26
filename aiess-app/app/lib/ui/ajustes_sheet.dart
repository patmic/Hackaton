import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/llm/cerebro.dart';
import 'bienvenida_page.dart';
import 'tema.dart';

const _plataforma = MethodChannel('aiess/plataforma');

Future<void> mostrarAjustes(BuildContext context, {VoidCallback? alPracticar}) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Tono.niebla,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _Ajustes(alPracticar: alPracticar),
    );

class _Ajustes extends StatefulWidget {
  const _Ajustes({this.alPracticar});
  final VoidCallback? alPracticar;

  @override
  State<_Ajustes> createState() => _AjustesState();
}

class _AjustesState extends State<_Ajustes> {
  double? _progreso;
  String? _error;
  bool _red = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) => setState(() => _red = p.getBool('red') ?? false));
  }

  Future<void> _descargar(ModeloDescargable m) async {
    setState(() {
      _progreso = 0;
      _error = null;
    });
    try {
      await for (final p in Cerebro.i.descargar(m)) {
        if (mounted) setState(() => _progreso = p);
      }
    } catch (e) {
      setState(() => _error = 'No se pudo descargar. Revisa tu conexión a internet e inténtalo otra vez.');
    }
    if (mounted) setState(() => _progreso = null);
  }

  Future<void> _importar() async {
    final r = await FilePicker.pickFiles(type: FileType.any);
    final ruta = r.isEmpty ? null : r.single.path;
    if (ruta == null) return;
    if (!ruta.toLowerCase().endsWith('.gguf')) {
      setState(() => _error = 'Elige un archivo .gguf');
      return;
    }
    setState(() => _progreso = -1);
    final ok = await Cerebro.i.importar(ruta);
    setState(() {
      _progreso = null;
      _error = ok ? null : 'Ese archivo no es un modelo válido.';
    });
  }

  @override
  Widget build(BuildContext context) {
    const tinta = Tono.pelaje;
    final c = Cerebro.i;
    final nombre = c.ruta?.split(RegExp(r'[\\/]')).last;
    return DefaultTextStyle(
      style: const TextStyle(color: tinta, fontFamily: 'Atkinson', fontSize: 17),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(3)))),
              const SizedBox(height: 16),
              if (kIsWeb) ...[
                const Text('Versión web', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('En el navegador el cóndor revisa con sus reglas de seguridad. El modelo con IA, el aviso flotante de correos y la lectura de capturas están en la app de Android.'),
                const SizedBox(height: 12),
              ] else ...[
              const Text('Cerebro del cóndor', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(nombre == null
                  ? 'Sin cerebro descargado: el cóndor usa sus reglas de seguridad. Descárgalo una vez para que converse mejor; después funciona sin internet.'
                  : 'Usando $nombre${c.afinado ? ' (entrenado para el IESS)' : ''}. Todo se procesa en tu celular.'),
              const SizedBox(height: 12),
              if (_progreso != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(value: _progreso! < 0 ? null : _progreso, minHeight: 10, borderRadius: BorderRadius.circular(6)),
                )
              else ...[
                for (final m in modelosBase)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56), foregroundColor: tinta,
                          side: const BorderSide(color: tinta, width: 1.5), shape: const StadiumBorder()),
                      onPressed: () => _descargar(m),
                      child: Text('Descargar ${m.nombre} · ${m.mb} MB', style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                TextButton(onPressed: _importar, child: const Text('Usar un modelo entrenado (.gguf)', style: TextStyle(color: tinta, fontSize: 16))),
              ],
              if (_error != null) Text(_error!, style: const TextStyle(color: Color(0xFFB3261E))),
              ],
              const Divider(height: 32),
              if (!kIsWeb) SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _red,
                activeThumbColor: Tono.pelaje,
                title: const Text('Revisar enlaces en internet', style: TextStyle(color: tinta, fontSize: 17)),
                subtitle: const Text('Comprueba el certificado y las redirecciones sin abrir la página.', style: TextStyle(color: Colors.black54)),
                onChanged: (v) async {
                  (await SharedPreferences.getInstance()).setBool('red', v);
                  setState(() => _red = v);
                },
              ),
              if (widget.alPracticar != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sports_esports_outlined, color: tinta),
                  title: const Text('Practicar a detectar estafas', style: TextStyle(color: tinta)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.alPracticar!();
                  },
                ),
              if (!kIsWeb) ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_outlined, color: tinta),
                title: const Text('Probar el aviso', style: TextStyle(color: tinta)),
                onTap: () => _plataforma.invokeMethod('probarAlerta'),
              ),
              if (!kIsWeb) ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_user_outlined, color: tinta),
                title: const Text('Revisar permisos', style: TextStyle(color: tinta)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BienvenidaPage(desdeAjustes: true)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
