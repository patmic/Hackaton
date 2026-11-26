import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/mascota/pantera.dart';
import '../features/voz/voz.dart';
import 'escena.dart';

/// Juego: el cóndor muestra un mensaje de práctica (del dataset) y tú decides. Dos botones grandes, nada más.
class PracticarPage extends StatefulWidget {
  const PracticarPage({super.key});

  @override
  State<PracticarPage> createState() => _PracticarPageState();
}

class _PracticarPageState extends State<PracticarPage> {
  List<Map<String, dynamic>> _ejercicios = [];
  Map<String, String> _pistas = {};
  Map<String, dynamic>? _actual;
  bool? _acerto;
  int _racha = 0;
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final j = jsonDecode(await rootBundle.loadString('assets/data/simulaciones.json')) as Map<String, dynamic>;
    _ejercicios = List<Map<String, dynamic>>.from(j['ejercicios'] as List);
    _pistas = Map<String, String>.from(j['pistas'] as Map);
    _racha = (await SharedPreferences.getInstance()).getInt('racha') ?? 0;
    _siguiente();
  }

  void _siguiente() {
    setState(() {
      _actual = _ejercicios[_rnd.nextInt(_ejercicios.length)];
      _acerto = null;
    });
    Voz.i.decir('Lee este mensaje. ¿Es una estafa o es seguro?');
  }

  Future<void> _responder(bool diceEstafa) async {
    final esEstafa = _actual!['respuesta'] == 'PHISHING';
    final ok = diceEstafa == esEstafa;
    HapticFeedback.heavyImpact();
    _racha = ok ? _racha + 1 : 0;
    (await SharedPreferences.getInstance()).setInt('racha', _racha);
    setState(() => _acerto = ok);
    final pistas = List<String>.from(_actual!['pistas'] as List).take(2).join(' ');
    await Voz.i.decir(ok
        ? (esEstafa ? '¡Muy bien! Era una estafa. $pistas' : '¡Muy bien! Era un mensaje seguro.')
        : (esEstafa ? 'Cuidado, era una estafa. $pistas' : 'Este era seguro. $pistas'));
  }

  @override
  void dispose() {
    Voz.i.callar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = _actual;
    final estado = _acerto == null
        ? EstadoPantera.reposo
        : (a!['respuesta'] == 'PHISHING' ? EstadoPantera.alerta : EstadoPantera.seguro);
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
              child: Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Paleta.tintaPetroleo, size: 30), tooltip: 'Salir'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Paleta.petroleo, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.local_fire_department_rounded, color: Paleta.ambar, size: 20),
                    const SizedBox(width: 4),
                    Text('$_racha', style: const TextStyle(color: Paleta.ambar, fontSize: 18, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
            ),
            Expanded(
              child: a == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), child: _Tarjeta(a, _acerto != null, _pistas)),
            ),
            SizedBox(
              height: 300,
              child: PanelOla(
                color: Paleta.panel(estado),
                linea: Paleta.linea(estado),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(bottom: 20),
                    child: Column(children: [
                      Row(children: [
                        Pantera(estado: estado, tam: 64, encuadre: Encuadre.cara),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _acerto == null ? '¿Estafa o seguro?' : (_acerto! ? '¡Correcto!' : 'Casi…'),
                            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.8),
                          ),
                        ),
                      ]),
                      const Spacer(),
                      if (_acerto == null)
                        Row(children: [
                          Expanded(child: _Opcion('Estafa', Icons.gpp_bad_rounded, Paleta.bermellon, () => _responder(true))),
                          const SizedBox(width: 12),
                          Expanded(child: _Opcion('Seguro', Icons.verified_user_rounded, Paleta.hoja, () => _responder(false))),
                        ])
                      else
                        BotonUnico(texto: 'Otro mensaje', icono: Icons.arrow_forward_rounded, alPulsar: _siguiente),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion(this.texto, this.icono, this.color, this.alPulsar);
  final String texto;
  final IconData icono;
  final Color color;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: alPulsar,
          child: SizedBox(
            height: 80,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icono, color: color, size: 30),
              const SizedBox(width: 8),
              Text(texto, style: TextStyle(color: color, fontSize: 23, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );
}

/// El mensaje de práctica. Los enlaces se muestran como texto (nunca se pueden tocar).
/// Tras responder, se resaltan las frases que delatan la estafa.
class _Tarjeta extends StatelessWidget {
  const _Tarjeta(this.e, this.revelar, this.pistas);
  final Map<String, dynamic> e;
  final bool revelar;
  final Map<String, String> pistas;

  @override
  Widget build(BuildContext context) {
    final cuerpo = e['cuerpo'] as String;
    final marcas = revelar ? List<Map<String, dynamic>>.from(e['resaltados'] as List) : <Map<String, dynamic>>[];
    marcas.sort((x, y) => (x['inicio'] as int).compareTo(y['inicio'] as int));
    final trozos = <TextSpan>[];
    var pos = 0;
    for (final m in marcas) {
      final ini = m['inicio'] as int, fin = m['fin'] as int;
      if (ini < pos || fin > cuerpo.length) continue;
      trozos.add(TextSpan(text: cuerpo.substring(pos, ini)));
      trozos.add(TextSpan(text: cuerpo.substring(ini, fin), style: const TextStyle(backgroundColor: Color(0xFFFFE08A), fontWeight: FontWeight.w700)));
      pos = fin;
    }
    trozos.add(TextSpan(text: cuerpo.substring(pos)));
    final enlaces = List<Map<String, dynamic>>.from(e['enlaces'] as List);
    const tinta = Color(0xFF14213D);
    final esSms = e['tipo'] == 'sms';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(esSms ? 28 : 18)),
      child: DefaultTextStyle(
        style: const TextStyle(color: tinta, fontSize: 18, height: 1.45, fontFamily: 'Atkinson'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(esSms ? Icons.sms_rounded : Icons.mail_rounded, color: Paleta.petroleo, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text((e['asunto'] as String).isEmpty ? 'Mensaje de texto' : e['asunto'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19)),
            ),
          ]),
          const SizedBox(height: 12),
          Text.rich(TextSpan(children: trozos)),
          for (final l in enlaces)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(children: [
                const Icon(Icons.link_off_rounded, size: 20, color: Colors.black45),
                const SizedBox(width: 6),
                Expanded(child: Text(l['url'] as String, style: const TextStyle(color: Colors.black54, fontSize: 15))),
              ]),
            ),
          const SizedBox(height: 14),
          const Text('Mensaje de práctica. No es real.', style: TextStyle(color: Colors.black45, fontSize: 14)),
        ]),
      ),
    );
  }
}
