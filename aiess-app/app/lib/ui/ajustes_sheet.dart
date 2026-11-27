import 'dart:ui' show FontVariation;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/llm/cerebro.dart';
import '../features/llm/remoto.dart';
import '../features/osint/cti.dart';
import '../features/sello/sello.dart';
import '../features/observatorio/observatorio.dart';
import 'aula_virtual.dart';
import 'bienvenida_page.dart';
import 'tema.dart';
import 'lectura.dart';

const _plataforma = MethodChannel('aiess/plataforma');

Future<void> mostrarAjustes(
  BuildContext context, {
  VoidCallback? alPracticar,
}) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  // No se mete debajo de la barra de estado; con mucho contenido se desplaza (ver build).
  useSafeArea: true,
  backgroundColor: Tono.fondo2,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  builder: (_) => _Ajustes(alPracticar: alPracticar),
);

class _Ajustes extends StatefulWidget {
  const _Ajustes({this.alPracticar});
  final VoidCallback? alPracticar;

  @override
  State<_Ajustes> createState() => _AjustesState();
}

class _AjustesState extends State<_Ajustes> {
  final _url = TextEditingController(text: ServidorIA.i.url);
  final _clave = TextEditingController(text: ServidorIA.i.clave);
  bool _probando = false;
  double? _progreso;
  String? _error;
  bool _red = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then(
      (p) => setState(() => _red = p.getBool('red') ?? false),
    );
    Observatorio.activo().then((v) => setState(() => _observatorio = v));
  }

  bool _observatorio = true;

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
      setState(
        () => _error =
            'No se pudo descargar. Revisa tu conexión a internet e inténtalo otra vez.',
      );
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
    const tinta = Tono.tinta;
    final c = Cerebro.i;
    final nombre = c.ruta?.split(RegExp(r'[\\/]')).last;
    return DefaultTextStyle(
      style: const TextStyle(
        color: tinta,
        fontFamily: 'packages/theme_light/ThemeLightAtkinson',
        fontSize: 17,
      ),
      child: SafeArea(
        top: false,
        // Se desplaza: en celulares chicos o con letra grande no cabe todo. Deja sitio para el teclado
        // (los campos del servidor están al final) y para la barra de navegación del sistema.
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Tono.borde,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ---------- Lectura (accesibilidad: letra grande y lectura fácil para dislexia)
              Semantics(
                header: true,
                child: const Text(
                  'Lectura',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              const ControlesLectura(),
              const SizedBox(height: 20),
              // ---------- Servidor de IA (modo principal)
              const Text(
                'Inteligencia del robot',
                style: TextStyle(
                  fontFamily: 'packages/theme_light/ThemeLightLexend',
                  fontVariations: const [FontVariation('wght', 700)],
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              // IA local (requisito: el modelo corre en el equipo y el correo no sale).
              Row(
                children: [
                  Icon(
                    Cerebro.i.ruta != null
                        ? Icons.phone_android_rounded
                        : Icons.info_outline_rounded,
                    color: Cerebro.i.ruta != null ? Tono.verde : Tono.ambar,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Cerebro.i.ruta != null
                          ? 'IA local activa: el modelo entrenado corre en este celular y tu correo no sale de él.'
                          : kIsWeb
                          ? 'En la web la IA corre en el servidor desde el que abriste la página.'
                          : 'Aún no hay modelo en este celular: el robot revisa con sus reglas, o con el servidor si lo activas.',
                    ),
                  ),
                ],
              ),
              if (!kIsWeb)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Usar también el servidor de AIESS'),
                  subtitle: const Text(
                    'Más rápido, pero el texto del correo (sin tus datos personales) sale del celular. '
                    'Apagado, todo se revisa aquí.',
                  ),
                  value: ServidorIA.i.permitido,
                  onChanged: (v) async {
                    await ServidorIA.i.permitir(v);
                    if (v) await ServidorIA.i.comprobar();
                    if (mounted) setState(() {});
                  },
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    ServidorIA.i.disponible
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                    color: ServidorIA.i.disponible ? Tono.verde : Tono.rojo,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ServidorIA.i.disponible
                          ? 'Conectado al servidor${ServidorIA.i.afinado ? ' con el modelo entrenado para el IESS' : ''}.'
                          : 'Sin conexión al servidor: el robot revisa con sus reglas de seguridad.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _AvisoPrivacidad(),
              // Fuentes OSINT y CTI declaradas (requisito del reto): solo dominio o URL.
              const SizedBox(height: 10),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                leading: const Icon(Icons.travel_explore_rounded),
                title: const Text('Fuentes que consulto (OSINT y CTI)'),
                subtitle: const Text(
                  'Solo el dominio o el enlace, nunca tu correo',
                ),
                children: [
                  for (final f in FuentesCti.declaracion)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline_rounded),
                      title: Text(f),
                    ),
                ],
              ),
              if (!kIsWeb) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(color: tinta),
                  decoration: const InputDecoration(
                    labelText: 'Dirección del servidor',
                    hintText: 'https://ia.aiess.ec',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _clave,
                  obscureText: true,
                  style: const TextStyle(color: tinta),
                  decoration: const InputDecoration(
                    labelText: 'Clave del servidor (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: Tono.lima,
                ),
                onPressed: _probando
                    ? null
                    : () async {
                        setState(() => _probando = true);
                        if (kIsWeb) {
                          await ServidorIA.i.comprobar();
                        } else {
                          await ServidorIA.i.guardar(_url.text, _clave.text);
                        }
                        if (mounted) setState(() => _probando = false);
                      },
                icon: _probando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Tono.sobreLima,
                        ),
                      )
                    : const Icon(Icons.wifi_tethering_rounded),
                label: Text(
                  kIsWeb ? 'Probar conexión' : 'Guardar y probar conexión',
                ),
              ),
              const Divider(height: 32),
              if (!kIsWeb) ...[
                const Text(
                  'Modelo en este celular (respaldo, más lento)',
                  style: TextStyle(
                    fontFamily: 'packages/theme_light/ThemeLightLexend',
                    fontVariations: const [FontVariation('wght', 700)],
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nombre == null
                      ? 'Solo se usa si no hay conexión al servidor. Ocupa entre 230 y 730 MB.'
                      : 'Respaldo: $nombre. Se usa si no hay conexión al servidor.',
                ),
                const SizedBox(height: 12),
                if (_progreso != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(
                      value: _progreso! < 0 ? null : _progreso,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  )
                else ...[
                  for (final m in modelosBase)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          foregroundColor: tinta,
                          side: const BorderSide(color: tinta, width: 1.5),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => _descargar(m),
                        child: Text(
                          'Descargar ${m.nombre} · ${m.mb} MB',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: _importar,
                    child: const Text(
                      'Usar un modelo entrenado (.gguf)',
                      style: TextStyle(color: tinta, fontSize: 16),
                    ),
                  ),
                ],
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Tono.rojo)),
              ],
              const Divider(height: 32),
              // Observatorio del IESS: resultado anónimo de cada revisión (rúbrica: solo datos mínimos).
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _observatorio,
                activeThumbColor: Tono.sobreLima,
                activeTrackColor: Tono.lima,
                title: const Text(
                  'Ayudar al Observatorio del IESS',
                  style: TextStyle(color: tinta, fontSize: 17),
                ),
                subtitle: const Text(
                  'Envía solo el resultado (rojo, amarillo o verde) y los códigos de los indicios (I1 a I11), '
                  'con un código al azar. Nunca el correo, el asunto ni tus datos.',
                  style: TextStyle(color: Tono.gris),
                ),
                onChanged: (v) async {
                  await Observatorio.activar(v);
                  setState(() => _observatorio = v);
                },
              ),
              if (!kIsWeb)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _red,
                  activeThumbColor: Tono.sobreLima,
                  activeTrackColor: Tono.lima,
                  title: const Text(
                    'Revisar enlaces en internet',
                    style: TextStyle(color: tinta, fontSize: 17),
                  ),
                  subtitle: const Text(
                    'Comprueba el certificado y las redirecciones sin abrir la página.',
                    style: TextStyle(color: Tono.gris),
                  ),
                  onChanged: (v) async {
                    (await SharedPreferences.getInstance()).setBool('red', v);
                    setState(() => _red = v);
                  },
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.school_outlined, color: tinta),
                title: const Text(
                  'Aula virtual: microlecciones',
                  style: TextStyle(color: tinta),
                ),
                onTap: () {
                  final nav = Navigator.of(context);
                  nav.pop();
                  abrirAulaVirtual(nav.context);
                },
              ),
              // Demo del reto: crear un correo con el sello del IESS (SellaCorreo, cuentas de prueba) para
              // enviarlo y ver cómo el guardián lo reconoce. Se abre en el navegador.
              if (Sello.servidor.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.forward_to_inbox_outlined,
                    color: tinta,
                  ),
                  title: const Text(
                    'Demo: enviar un correo sellado',
                    style: TextStyle(color: tinta),
                  ),
                  subtitle: const Text(
                    'Crea el sello en SellaCorreo, pégalo en tu correo y envíalo.',
                  ),
                  onTap: () => launchUrl(
                    Uri.parse('${Sello.servidor}/login'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              if (widget.alPracticar != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.sports_esports_outlined,
                    color: tinta,
                  ),
                  title: const Text(
                    'Practicar a detectar estafas',
                    style: TextStyle(color: tinta),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.alPracticar!();
                  },
                ),
              if (!kIsWeb)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: tinta,
                  ),
                  title: const Text(
                    'Probar el aviso',
                    style: TextStyle(color: tinta),
                  ),
                  onTap: () => _plataforma.invokeMethod('probarAlerta'),
                ),
              if (!kIsWeb)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.verified_user_outlined,
                    color: tinta,
                  ),
                  title: const Text(
                    'Revisar permisos',
                    style: TextStyle(color: tinta),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const BienvenidaPage(desdeAjustes: true),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aviso de privacidad del análisis en el servidor (escrito; el robot también lo dice la primera vez).
class _AvisoPrivacidad extends StatelessWidget {
  const _AvisoPrivacidad();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Tono.superficie,
      border: Border.all(color: Tono.linea),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, color: Tono.lima),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Antes de salir de tu celular, AIESS tapa tus datos personales: nombre, cédula, teléfono, cuentas, tarjetas y tu dirección de correo. '
            'Solo viajan las señales del engaño (enlaces, dominios, montos). El servidor lo procesa en memoria y lo borra al terminar: '
            'no se guarda en archivos, no queda en registros y no se usa para entrenar.',
            style: TextStyle(color: Tono.tinta, fontSize: 15, height: 1.35),
          ),
        ),
      ],
    ),
  );
}
