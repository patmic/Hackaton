// Pop-up tipo Truecaller: aparece sobre la app donde llegó el mensaje, el cóndor dice por qué es (o no) una estafa.
import 'dart:ui' show FontVariation;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/canales.dart';
import '../features/analisis/analizador.dart';
import '../features/analisis/motor.dart';
import '../features/llm/cerebro.dart';
import '../features/mascota/pantera.dart';
import '../features/voz/voz.dart';
import 'tema.dart';

class AlertaApp extends StatelessWidget {
  const AlertaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: temaAIess(),
        home: const _Alerta(),
      );
}

class _Alerta extends StatefulWidget {
  const _Alerta();

  @override
  State<_Alerta> createState() => _AlertaState();
}

class _AlertaState extends State<_Alerta> with SingleTickerProviderStateMixin {
  static const _canal = MethodChannel('aiess/alerta');
  late final _entrada = AnimationController(vsync: this, duration: const Duration(milliseconds: 420))..forward();
  Map<String, dynamic> _p = {};
  final _tarjeta = GlobalKey();
  double _altoInformado = 0;

  /// La ventana flotante nativa mide lo mismo que la tarjeta (el resto de la pantalla queda libre).
  void _informarTamano() {
    final caja = _tarjeta.currentContext?.findRenderObject() as RenderBox?;
    if (caja == null || !caja.hasSize) return;
    final alto = caja.size.height + 24;
    if ((alto - _altoInformado).abs() < 2) return;
    _altoInformado = alto;
    _canal.invokeMethod('tamano', {'alto': alto});
  }
  Veredicto? _v;

  @override
  void initState() {
    super.initState();
    _canal.setMethodCallHandler((c) async {
      if (c.method == 'nuevo') _procesar(Map<String, dynamic>.from(c.arguments as Map));
    });
    _canal.invokeMethod('payload').then((p) => _procesar(Map<String, dynamic>.from(p as Map)));
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  Future<void> _procesar(Map<String, dynamic> p) async {
    setState(() {
      _p = p;
      _v = null;
    });
    final app = p['app'] as String? ?? '';
    final esCorreo = RegExp(r'(gmail|outlook|correo|mail)', caseSensitive: false).hasMatch(app);
    final e = Entrada(p['texto'] as String? ?? '', canal: 'notificación de $app (vista previa)', remitente: esCorreo ? p['titulo'] as String? : null);

    // 1) Al instante: reglas OSINT (milisegundos). Con modelo cargado, solo se adelanta una estafa CLARA;
    //    un "seguro" por reglas en una vista previa corta no es confiable, así que se espera al modelo.
    final rapido = await Analizador.analizar(e, usarModelo: false);
    if (!mounted || !identical(_p, p)) return;
    final hayModelo = Cerebro.i.afinado;
    Future<void> hablando = Future.value();
    if (!hayModelo || rapido.phishing) {
      HapticFeedback.heavyImpact();
      setState(() => _v = rapido);
      hablando = Voz.i.decir(rapido.phishing ? rapido.voz : 'Este correo parece seguro.');
    }

    // 2) Segundos después: el modelo entrenado confirma; si cambia algo, la tarjeta se actualiza sola.
    if (hayModelo) {
      final v = await Analizador.analizar(e);
      if (!mounted || !identical(_p, p)) return;
      final yaMostrado = _v != null;
      if (!yaMostrado || v.phishing != rapido.phishing || v.voz != rapido.voz) {
        HapticFeedback.heavyImpact();
        setState(() => _v = v);
        if (!yaMostrado) {
          hablando = Voz.i.decir(v.phishing ? v.voz : 'Este correo parece seguro.');
        } else if (v.phishing != rapido.phishing) {
          hablando = Voz.i.decir(v.phishing ? v.voz : 'Revisé mejor: este correo parece seguro.');
        }
      }
    }
    await hablando;
    final fin = _v;
    if (fin != null && !fin.phishing) {
      // Como un identificador de llamadas: si es seguro, se cierra solo.
      await Future.delayed(const Duration(seconds: 4));
      if (mounted && identical(_v, fin)) await _cerrar();
    }
  }

  Future<void> _cerrar() async {
    await Voz.i.callar();
    await _canal.invokeMethod('cerrar');
  }

  Future<void> _avisar() async {
    final c = Canales.i.contacto;
    final cuerpo = 'Recibí este mensaje sospechoso (${_p['app']}):\n\n${_p['titulo']}\n${_p['texto']}\n\nSeñales: ${_v?.explicacion ?? ''}';
    await launchUrl(Uri.parse('mailto:${c['seguridad_informacion']}?subject=${Uri.encodeComponent('Reporte de posible phishing (AIESS)')}'
        '&body=${Uri.encodeComponent(cuerpo)}'));
    await _cerrar();
  }

  Future<void> _verDetalle() async {
    await Voz.i.callar();
    await _canal.invokeMethod('abrirApp', {'texto': '${_p['titulo'] ?? ''}\n${_p['texto'] ?? ''}'});
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _informarTamano());
    final v = _v;
    final estado = v == null ? EstadoPantera.analizando : (v.phishing ? EstadoPantera.alerta : EstadoPantera.seguro);
    // Tarjeta de UN color, como el identificador de llamadas: rojo estafa, verde seguro, azul IESS analizando.
    final color = v == null ? const Color(0xFF004294) : (v.phishing ? const Color(0xFFC62828) : const Color(0xFF1B7F3B));
    final veredicto = v == null ? 'Revisando correo…' : (v.phishing ? 'Posible estafa' : 'Correo seguro');
    final titulo = (_p['titulo'] as String?)?.trim() ?? '';
    final origen = [(_p['app'] as String?) ?? '', titulo].where((x) => x.isNotEmpty).join(' · ');
    const blanco = Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // La tarjeta se mide a su altura NATURAL (sin el límite de la ventana flotante), y la ventana se ajusta a ella.
      body: UnconstrainedBox(
        constrainedAxis: Axis.horizontal,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -1.1), end: Offset.zero).animate(CurvedAnimation(parent: _entrada, curve: Curves.easeOutCubic)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AnimatedContainer(
              key: _tarjeta,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 20, offset: Offset(0, 8))],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
              child: DefaultTextStyle(
                style: const TextStyle(fontFamily: 'Atkinson', color: blanco),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Marca + cerrar
                  Row(children: [
                    const Icon(Icons.shield_rounded, size: 16, color: Color(0xFFFCC602)),
                    const SizedBox(width: 6),
                    Text('AIESS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: blanco.withValues(alpha: 0.9), letterSpacing: 0.4)),
                    const Spacer(),
                    // Repetir el análisis del mismo correo.
                    Semantics(
                      button: true,
                      label: 'Analizar de nuevo',
                      child: InkResponse(
                        onTap: v == null
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                _procesar(Map<String, dynamic>.from(_p));
                              },
                        radius: 22,
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.refresh_rounded, color: blanco.withValues(alpha: v == null ? 0.4 : 1), size: 24)),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Cerrar',
                      child: InkResponse(
                        onTap: _cerrar,
                        radius: 22,
                        child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.close_rounded, color: blanco, size: 24)),
                      ),
                    ),
                  ]),
                  // Avatar + veredicto + origen
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: blanco),
                      padding: const EdgeInsets.all(2.5),
                      child: ClipOval(
                        child: SizedBox(
                          width: 58,
                          height: 58,
                          child: Pantera(estado: estado, tam: 58, encuadre: Encuadre.cara, alTocar: v == null ? null : () => Voz.i.decir('${v.explicacion} ${v.queHacer}')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(veredicto, style: const TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.1)),
                        const SizedBox(height: 3),
                        Text(origen, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, color: blanco.withValues(alpha: 0.85))),
                      ]),
                    ),
                    const SizedBox(width: 8),
                  ]),
                  if (v == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(minHeight: 5, color: const Color(0xFFFCC602), backgroundColor: blanco.withValues(alpha: 0.2)),
                      ),
                    )
                  else ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(v.voz, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, height: 1.38)),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(children: [
                        Expanded(
                          child: _PildoraPopup(
                            texto: v.phishing ? 'Avisar al IESS' : 'Listo',
                            icono: v.phishing ? Icons.campaign_rounded : Icons.check_rounded,
                            relleno: true,
                            color: color,
                            onTap: v.phishing ? _avisar : _cerrar,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _PildoraPopup(texto: 'Ver detalle', icono: Icons.open_in_new_rounded, relleno: false, color: color, onTap: _verDetalle)),
                      ]),
                    ),
                  ],
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PildoraPopup extends StatelessWidget {
  const _PildoraPopup({required this.texto, required this.icono, required this.relleno, required this.color, required this.onTap});
  final String texto;
  final IconData icono;
  final bool relleno;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: texto,
        child: Material(
          color: relleno ? Colors.white : Colors.transparent,
          shape: StadiumBorder(side: relleno ? BorderSide.none : const BorderSide(color: Colors.white, width: 1.6)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: SizedBox(
              height: 52,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icono, size: 22, color: relleno ? color : Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(texto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 600)], fontSize: 17, fontWeight: FontWeight.w600, color: relleno ? color : Colors.white)),
                ),
              ]),
            ),
          ),
        ),
      );
}
