import 'dart:async';
// Pop-up tipo Truecaller: aparece sobre la app donde llegó el mensaje, el robot dice por qué es (o no) una estafa.
import 'dart:ui' show FontVariation;
import 'package:material_ui/material_ui.dart';

import '../features/sello/sello.dart';
import 'package:flutter/services.dart';

import '../features/analisis/motor.dart';
import '../features/mascota/robot_guardia.dart';
import '../features/voz/voz.dart';
import 'reporte_simulado.dart';
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
  late final _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();
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
      if (c.method == 'nuevo')
        _procesar(Map<String, dynamic>.from(c.arguments as Map));
    });
    _canal
        .invokeMethod('payload')
        .then((p) => _procesar(Map<String, dynamic>.from(p as Map)));
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  bool _verificando = false;

  /// El guardián solo vio el ASUNTO (y solo porque habla del IESS). El robot verifica SOLO el sello con
  /// SellaCorreo (envía únicamente el asunto): sellado = del IESS; sin sello = estafa. No lee el correo.
  Future<void> _procesar(Map<String, dynamic> p) async {
    setState(() {
      _p = p;
      _v = null;
      _verificando = true;
    });
    HapticFeedback.mediumImpact();
    unawaited(
      Voz.i.decir('Llegó un correo que dice ser del IESS. Verifico su sello.'),
    );
    final r = await Sello.porAsunto('${p['texto'] ?? ''}');
    if (!mounted) return;
    final v = Sello.veredictoPorAsunto(r, '${p['texto'] ?? ''}');
    setState(() {
      _v = v;
      _verificando = false;
    });
    HapticFeedback.heavyImpact();
    await Voz.i.decir(v.locucion);
  }

  Future<void> _cerrar() async {
    await Voz.i.callar();
    await _canal.invokeMethod('cerrar');
  }

  /// Reporte SIMULADO (reglas del reto): se arma el caso con el asunto (sin datos personales) y se guarda en el
  /// celular; no se envía nada. La ventana flotante es chica: el número de caso se muestra en la misma tarjeta.
  Future<void> _avisar() async {
    final v = _v;
    if (v == null) return;
    final r = ReporteSimulado.preparar(v, 'Asunto: ${_p['texto'] ?? ''}');
    await r.guardar();
    if (!mounted) return;
    setState(
      () => _v = v.copiar(
        voz:
            'Reporte preparado (simulación), caso ${r.caso}, para ${r.destinatario}. En la demo no sale del celular.',
      ),
    );
    await Voz.i.decir(
      'Listo, preparé el reporte. En la demo no sale de tu celular.',
    );
  }

  Future<void> _verificar() async {
    await Voz.i.callar();
    await _canal.invokeMethod('abrirApp', {
      'texto': '$marcaAvisoIess${_p['texto'] ?? ''}',
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _informarTamano());
    final v = _v;
    final estado = v == null
        ? EstadoRobot.reposo
        : (v.phishing ? EstadoRobot.alerta : EstadoRobot.seguro);
    // Tarjeta de UN color, como el identificador de llamadas: rojo estafa, verde seguro, azul IESS analizando.
    final color = v == null
        ? Tono.azulSuave
        : (v.phishing
              ? Tono.rojoSuave
              : (v.sinConfirmar ? Tono.azulSuave : Tono.verdeSuave));
    final veredicto = v == null
        ? '¿Es del IESS de verdad?'
        : (v.phishing
              ? 'Es una estafa'
              : (v.sinConfirmar
                    ? 'Sin sello: cuidado'
                    : 'Sellado por el IESS'));
    final asunto = (_p['texto'] as String?)?.trim() ?? '';
    final origen = (_p['app'] as String?) ?? '';
    const blanco = Tono.tinta;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // La tarjeta se mide a su altura NATURAL (sin el límite de la ventana flotante), y la ventana se ajusta a ella.
      body: UnconstrainedBox(
        constrainedAxis: Axis.horizontal,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -1.1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: _entrada, curve: Curves.easeOutCubic),
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AnimatedContainer(
              key: _tarjeta,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x59000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: 'packages/theme_light/ThemeLightAtkinson',
                  color: blanco,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Marca + cerrar
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          size: 16,
                          color: Tono.lima,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AIESS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: blanco.withValues(alpha: 0.9),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const Spacer(),
                        Semantics(
                          button: true,
                          label: 'Cerrar',
                          child: InkResponse(
                            onTap: _cerrar,
                            radius: 22,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.close_rounded,
                                color: blanco,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Avatar + veredicto + origen
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: blanco,
                          ),
                          padding: const EdgeInsets.all(2.5),
                          child: ClipOval(
                            child: SizedBox(
                              width: 58,
                              height: 58,
                              child: RobotGuardia(
                                estado: estado,
                                tam: 58,
                                alTocar: v == null
                                    ? null
                                    : () => Voz.i.decir(
                                        '${v.explicacion} ${v.queHacer}',
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                veredicto,
                                style: const TextStyle(
                                  fontFamily:
                                      'packages/theme_light/ThemeLightLexend',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                origen,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: blanco.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    if (v == null) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          asunto.isEmpty
                              ? 'Llegó un correo que dice ser del IESS.'
                              : 'Asunto: «$asunto»',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17, height: 1.38),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          _verificando
                              ? 'Verificando su sello con el IESS… (solo envío el asunto)'
                              : 'Solo leí el asunto.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            color: blanco.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _PildoraPopup(
                                texto: 'Ahora no',
                                icono: Icons.close_rounded,
                                relleno: false,
                                color: color,
                                onTap: _cerrar,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          // Solo se vio el asunto: sin sello y sin indicios no se dice «seguro», se avisa.
                          v.sinConfirmar
                              ? '${v.avisoSello} Ábrelo en AIESS para revisarlo completo.'
                              : v.voz,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17, height: 1.38),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _PildoraPopup(
                                texto: v.phishing ? 'Avisar al IESS' : 'Listo',
                                icono: v.phishing
                                    ? Icons.campaign_rounded
                                    : Icons.check_rounded,
                                relleno: true,
                                color: color,
                                onTap: v.phishing ? _avisar : _cerrar,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PildoraPopup(
                                texto: 'Abrir AIESS',
                                icono: Icons.open_in_new_rounded,
                                relleno: false,
                                color: color,
                                onTap: _verificar,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PildoraPopup extends StatelessWidget {
  const _PildoraPopup({
    required this.texto,
    required this.icono,
    required this.relleno,
    required this.color,
    required this.onTap,
  });
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
      color: relleno ? Tono.lima : Colors.transparent,
      shape: StadiumBorder(
        side: relleno
            ? BorderSide.none
            : const BorderSide(color: Tono.borde, width: 1.6),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                size: 22,
                color: relleno ? Tono.sobreLima : Tono.tinta,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'packages/theme_light/ThemeLightLexend',
                    fontVariations: const [FontVariation('wght', 600)],
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: relleno ? Tono.sobreLima : Tono.tinta,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
