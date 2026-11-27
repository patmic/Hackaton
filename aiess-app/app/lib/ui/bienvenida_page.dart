import 'dart:ui' show FontVariation;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/mascota/pantera.dart';
import '../features/voz/voz.dart';
import 'inicio_page.dart';
import 'escena.dart';

/// Configuración guiada: un paso por pantalla, un botón por paso; el cóndor explica cada uno en voz alta.
class BienvenidaPage extends StatefulWidget {
  const BienvenidaPage({super.key, this.desdeAjustes = false});
  final bool desdeAjustes;

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _Paso {
  const _Paso(this.titulo, this.voz, this.boton, this.icono, this.accion, this.clave);
  final String titulo, voz, boton, clave;
  final IconData icono;
  final String? accion;
}

const _pasos = [
  _Paso('Hola, soy AIess', 'Hola, soy AIess, tu cóndor guardián. Te ayudo a descubrir estafas que usan el nombre del IESS. Vamos a prepararme en cuatro pasos.',
      'Empecemos', Icons.pets_rounded, null, ''),
  _Paso('Déjame ver tus avisos', 'Para cuidarte, necesito leer los avisos de tus correos. Nada sale de tu celular. Toca el botón y activa Guardián AIESS.',
      'Dar permiso', Icons.notifications_active_rounded, 'abrirAjustesNotificaciones', 'notificaciones'),
  _Paso('Déjame aparecer', 'Para avisarte a tiempo, necesito aparecer sobre otras aplicaciones. Toca el botón y activa el permiso para AIESS.',
      'Dar permiso', Icons.layers_rounded, 'abrirAjustesSuperposicion', 'superposicion'),
  _Paso('Déjame cuidarte siempre', 'Para avisarte aunque no tengas la app abierta, necesito trabajar en segundo plano. Toca el botón y elige Permitir.',
      'Dar permiso', Icons.battery_charging_full_rounded, 'abrirAjustesBateria', 'bateria'),
  _Paso('Déjame despertar solo', 'Tu celular apaga las apps para ahorrar batería. Toca el botón, busca AIESS y activa el interruptor de inicio automático.',
      'Abrir ajuste', Icons.power_settings_new_rounded, 'abrirInicioAutomatico', 'autoinicio'),
  _Paso('¡Listo!', 'Listo. Desde ahora reviso tus correos. Si llega algo sospechoso, aparezco y te digo por qué.',
      'Comenzar', Icons.check_rounded, null, ''),
];

class _BienvenidaPageState extends State<BienvenidaPage> with WidgetsBindingObserver {
  static const _plataforma = MethodChannel('aiess/plataforma');
  int _i = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _hablar());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _hablar() => Voz.i.decir(_pasos[_i].voz);

  /// Al volver de Ajustes, si el permiso ya está dado, avanza solo (poka-yoke).
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) async {
    if (s != AppLifecycleState.resumed) return;
    final p = _pasos[_i];
    if (p.clave.isEmpty) return;
    final permisos = Map<String, dynamic>.from(await _plataforma.invokeMethod('permisos'));
    if (permisos[p.clave] == true) _siguiente();
  }

  Future<void> _pulsar() async {
    final p = _pasos[_i];
    if (p.accion != null) {
      final permisos = Map<String, dynamic>.from(await _plataforma.invokeMethod('permisos'));
      if (permisos[p.clave] == true) {
        _siguiente();
      } else {
        await _plataforma.invokeMethod(p.accion!);
      }
      return;
    }
    if (_i == _pasos.length - 1) {
      (await SharedPreferences.getInstance()).setBool('bienvenida', true);
      if (!mounted) return;
      if (widget.desdeAjustes) {
        Navigator.pop(context);
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const InicioPage()));
      }
      return;
    }
    _siguiente();
  }

  void _siguiente() {
    if (_i >= _pasos.length - 1) return;
    setState(() => _i++);
    _hablar();
  }

  @override
  Widget build(BuildContext context) {
    final p = _pasos[_i];
    return EscenaPantera(
      estado: _i == _pasos.length - 1 ? EstadoPantera.seguro : EstadoPantera.reposo,
      titular: p.titulo,
      alTocarPantera: _hablar,
      izquierda: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.38), borderRadius: BorderRadius.circular(24)),
        child: Text('Paso ${_i + 1} de ${_pasos.length}', style: const TextStyle(fontFamily: 'Lexend', fontVariations: const [FontVariation('wght', 700)], color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      boton: BotonUnico(texto: p.boton, icono: p.icono, alPulsar: _pulsar),
    );
  }
}
