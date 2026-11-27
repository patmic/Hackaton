// Versión web para computadora: dos columnas. Izquierda, el cóndor y cómo funciona; derecha, el espacio de
// trabajo para pegar el correo y ver el veredicto (escrito y hablado). La IA corre en el servidor de AIESS.
import 'dart:ui' show FontVariation;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/canales.dart';
import '../features/analisis/analizador.dart';
import '../features/analisis/motor.dart';
import '../features/llm/remoto.dart';
import '../features/mascota/pantera.dart';
import '../features/voz/voz.dart';
import 'aula_virtual.dart';
import 'practicar_page.dart';
import 'texto_vivo.dart';

class _W {
  static const azul = Color(0xFF004294);
  static const azulOscuro = Color(0xFF183675);
  static const amarillo = Color(0xFFFCC602);
  static const papel = Color(0xFFF4F6FA);
  static const tinta = Color(0xFF14213D);
  static const gris = Color(0xFF5B6478);
  static const rojo = Color(0xFFC62828);
  static const verde = Color(0xFF1B7F3B);
}

class WebEscritorio extends StatefulWidget {
  const WebEscritorio({super.key});

  @override
  State<WebEscritorio> createState() => _WebEscritorioState();
}

class _WebEscritorioState extends State<WebEscritorio> {
  final _texto = TextEditingController();
  var _estado = EstadoPantera.reposo;
  Veredicto? _v;
  String? _aviso;
  List<String> _pasos = [];
  double? _progreso;
  bool _escuchando = false;

  bool get _ocupado => _estado == EstadoPantera.analizando || _escuchando;

  Future<void> _revisar() async {
    final t = _texto.text.trim();
    if (t.length < 8) {
      setState(() => _aviso = 'Pega primero el texto del correo o el enlace que te parezca raro.');
      Voz.i.decir(_aviso!);
      return;
    }
    final motivo = motivoNoEsMensaje(t);
    if (motivo != null && !(urlRe.hasMatch(t) && t.length < 300)) {
      setState(() {
        _aviso = '$motivo Pega el texto del correo o el enlace sospechoso.';
        _v = null;
      });
      Voz.i.decir(_aviso!);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _estado = EstadoPantera.analizando;
      _aviso = null;
      _v = null;
      _pasos = [];
      _progreso = null;
    });
    final v = await Analizador.analizar(Entrada(t, canal: 'correo pegado en la web'), alAvanzar: (paso, p) {
      if (!mounted) return;
      setState(() {
        if (_pasos.isEmpty || _pasos.last != paso) _pasos = [..._pasos, paso];
        _progreso = p;
      });
    });
    if (!mounted) return;
    setState(() {
      _v = v;
      _estado = v.phishing ? EstadoPantera.alerta : EstadoPantera.seguro;
      _pasos = [];
    });
    Voz.i.decir(v.voz);
  }

  Future<void> _hablar() async {
    setState(() => _escuchando = true);
    final dicho = await Voz.i.escuchar();
    if (!mounted) return;
    setState(() => _escuchando = false);
    if (dicho != null) {
      _texto.text = dicho;
      await _revisar();
    }
  }

  Future<void> _reportar() async {
    final c = Canales.i.contacto;
    await launchUrl(Uri.parse('mailto:${c['seguridad_informacion']}?subject=${Uri.encodeComponent('Reporte de posible phishing (AIESS)')}'
        '&body=${Uri.encodeComponent('Recibí este mensaje sospechoso:\n\n${_texto.text}\n\nSeñales: ${_v?.explicacion ?? ''}')}'));
  }

  void _limpiar() {
    Voz.i.callar();
    setState(() {
      _texto.clear();
      _v = null;
      _aviso = null;
      _estado = EstadoPantera.reposo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _W.papel,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------------- Izquierda: el cóndor y cómo funciona
          Expanded(
            flex: 5,
            child: Container(
              color: _W.azul, // mismo azul de la barra del aula virtual
              padding: const EdgeInsets.fromLTRB(56, 48, 56, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.shield_rounded, color: _W.amarillo, size: 26),
                    const SizedBox(width: 10),
                    const Text('AIESS', style: TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const Spacer(),
                    _EstadoServidor(),
                  ]),
                  const Spacer(flex: 2),
                  Center(child: Pantera(estado: _estado, tam: 260, encuadre: Encuadre.medallon, alTocar: () => _v == null ? Voz.i.decir('Pega un correo y te digo si es una estafa.') : Voz.i.decir('${_v!.explicacion} ${_v!.queHacer}'))),
                  const Spacer(),
                  const Text('Tu cóndor guardián\ncontra estafas',
                      style: TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], color: Colors.white, fontSize: 44, fontWeight: FontWeight.w700, height: 1.08, letterSpacing: -1)),
                  const SizedBox(height: 16),
                  Text('Pega un correo raro y te digo, con voz y por escrito, si es una estafa.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 20, height: 1.45)),
                  const Spacer(),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.lock_outline_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          'Antes de revisarlo quitamos tu nombre, cédula, teléfono y cuentas. Luego se borra todo. Nunca te pediremos claves.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 16, height: 1.45)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          // ---------------- Derecha: espacio de trabajo
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(64, 56, 64, 48),
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Pega aquí el correo sospechoso',
                          style: TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], color: _W.tinta, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.6)),
                      const SizedBox(height: 8),
                      const Text('Sirve el texto completo, un SMS o solo el enlace.',
                          style: TextStyle(color: _W.gris, fontSize: 18, height: 1.4)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _texto,
                        minLines: 8,
                        maxLines: 14,
                        style: const TextStyle(color: _W.tinta, fontSize: 18, height: 1.45),
                        decoration: InputDecoration(
                          labelText: 'Texto del correo',
                          alignLabelWithHint: true,
                          labelStyle: const TextStyle(fontSize: 18),
                          hintText: 'Ejemplo: "IESS: su afiliación será suspendida hoy. Actualice su clave en https://…"',
                          hintStyle: const TextStyle(color: Color(0xFF9AA3B5)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFD5DBE6), width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: _W.azul, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: _W.azul,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                textStyle: const TextStyle(fontFamily: 'Lexend', fontVariations: [FontVariation('wght', 600)], fontSize: 19, fontWeight: FontWeight.w600),
                              ),
                              onPressed: _ocupado ? null : _revisar,
                              icon: _estado == EstadoPantera.analizando
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                  : const Icon(Icons.manage_search_rounded, size: 26),
                              label: Text(_estado == EstadoPantera.analizando ? 'Revisando…' : 'Revisar con AIess'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _BotonTexto(
                          icono: _escuchando ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                          texto: _escuchando ? 'Te escucho…' : 'Dictar',
                          activo: _escuchando,
                          onTap: _ocupado ? null : _hablar,
                        ),
                        const SizedBox(width: 12),
                        _BotonTexto(icono: Icons.backspace_outlined, texto: 'Borrar', onTap: _limpiar),
                      ]),
                      const SizedBox(height: 28),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _resultado(),
                      ),
                      const SizedBox(height: 32),
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        OutlinedButton.icon(
                          onPressed: () => abrirAulaVirtual(context),
                          icon: const Icon(Icons.school_rounded),
                          label: const Text('Aprender con microlecciones'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PracticarPage())),
                          icon: const Icon(Icons.sports_esports_rounded),
                          label: const Text('Practicar'),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultado() {
    if (_pasos.isNotEmpty) {
      return Container(
        key: const ValueKey('pasos'),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _W.azulOscuro, borderRadius: BorderRadius.circular(20)),
        child: PasosCarga(pasos: _pasos, progreso: _progreso, color: Colors.white, acento: _W.amarillo),
      );
    }
    if (_aviso != null) {
      return Container(
        key: ValueKey(_aviso),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFFFF4CC), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF7A5B00)),
          const SizedBox(width: 12),
          Expanded(child: Text(_aviso!, style: const TextStyle(color: Color(0xFF5C4400), fontSize: 17, height: 1.4))),
        ]),
      );
    }
    final v = _v;
    if (v == null) return const SizedBox(key: ValueKey('vacio'));
    final color = v.phishing ? _W.rojo : _W.verde;
    return Semantics(
      key: ValueKey(v),
      liveRegion: true,
      child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: color,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
          child: Row(children: [
            Icon(v.phishing ? Icons.gpp_bad_rounded : Icons.verified_user_rounded, color: Colors.white, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Text(v.phishing ? 'Posible estafa' : 'Parece seguro',
                  style: const TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextoVivo(v.voz, estilo: const TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 600)], color: _W.tinta, fontSize: 20, height: 1.45, fontWeight: FontWeight.w600)),
            if (v.phishing && v.indicios.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text('Señales que encontré', style: TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], color: _W.gris, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              for (final k in v.indicios.take(3))
                if (motivoVoz[k] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.error_outline_rounded, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(motivoVoz[k]!, style: const TextStyle(color: _W.tinta, fontSize: 17, height: 1.35))),
                    ]),
                  ),
            ],
            const SizedBox(height: 14),
            Text(v.queHacer, style: const TextStyle(color: _W.gris, fontSize: 16, height: 1.45)),
            const SizedBox(height: 18),
            Row(children: [
              if (v.phishing)
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: color, minimumSize: const Size(0, 52), shape: const StadiumBorder()),
                  onPressed: _reportar,
                  icon: const Icon(Icons.campaign_rounded),
                  label: const Text('Avisar al IESS', style: TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: _W.tinta, minimumSize: const Size(0, 52), shape: const StadiumBorder()),
                onPressed: () => Voz.i.decir('${v.voz} ${v.queHacer}'),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Escuchar de nuevo', style: TextStyle(fontSize: 17)),
              ),
              const SizedBox(width: 10),
              TextButton.icon(onPressed: _limpiar, icon: const Icon(Icons.forward_to_inbox_rounded), label: const Text('Revisar otro correo', style: TextStyle(fontSize: 17))),
            ]),
          ]),
        ),
      ]),
    ));
  }
}

/// Botón secundario con ícono + texto (60 dp de alto).
class _BotonTexto extends StatelessWidget {
  const _BotonTexto({required this.icono, required this.texto, required this.onTap, this.activo = false});
  final IconData icono;
  final String texto;
  final VoidCallback? onTap;
  final bool activo;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 60,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            backgroundColor: activo ? _W.azul : Colors.white,
            foregroundColor: activo ? Colors.white : _W.azul,
            side: const BorderSide(color: _W.azul, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontFamily: 'Lexend', fontVariations: [FontVariation('wght', 600)], fontSize: 18, fontWeight: FontWeight.w600),
          ),
          onPressed: onTap,
          icon: Icon(icono, size: 26),
          label: Text(texto),
        ),
      );
}

/// Indicador del servidor de IA (verde: modelo entrenado conectado).
class _EstadoServidor extends StatefulWidget {
  @override
  State<_EstadoServidor> createState() => _EstadoServidorState();
}

class _EstadoServidorState extends State<_EstadoServidor> {
  @override
  void initState() {
    super.initState();
    ServidorIA.i.comprobar().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ok = ServidorIA.i.afinado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: ok ? const Color(0xFF22C55E) : _W.amarillo)),
        const SizedBox(width: 8),
        Text(ok ? 'IA conectada' : 'Revisión por reglas', style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]),
    );
  }
}
