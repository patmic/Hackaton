// Fuentes OSINT y CTI externas (declaradas, requisito del reto: solo se consulta el dominio o la URL).
//
// 1) RDAP (rdap.org, registro público de dominios): se envía SOLO el dominio, para saber su edad.
//    Un dominio creado hace pocos días es una señal típica de phishing.
// 2) OpenPhish (lista pública de enlaces de phishing activos): se descarga la lista completa y se compara
//    EN EL EQUIPO; no se envía ni el dominio (la lista pública está en GitHub y admite pedidos del navegador).
//
// Nunca se envía el texto del correo, el remitente ni datos de la persona. Si una fuente no responde,
// el análisis sigue con las reglas locales.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'url_analyzer.dart';

class FuentesCti {
  static const rdap = 'https://rdap.org/domain/';
  static const openphish =
      'https://raw.githubusercontent.com/openphish/public_feed/refs/heads/main/feed.txt';

  /// Declaración que se muestra a la persona y en la documentación.
  static const declaracion = [
    'Reglas locales de AIESS: dominios parecidos al IESS, acortadores, enlaces que dicen una cosa y llevan a otra.',
    'RDAP (registro público de dominios): edad del dominio. Solo se envía el dominio.',
    'OpenPhish (lista pública de phishing): se descarga y se compara en el equipo. No se envía nada.',
  ];
}

const _diasNuevo = 30;
Set<String>? _listaOpenPhish;
DateTime? _listaCuando;

/// Consulta las fuentes externas para los enlaces NO oficiales del correo. Agrega lo encontrado a [o].
Future<void> consultarCti(AnalisisOsint o, {http.Client? cliente}) async {
  final dudosos = o.urls
      .where((u) => !u.confiable && u.host.isNotEmpty)
      .take(3)
      .toList();
  if (dudosos.isEmpty) return;
  final c = cliente ?? http.Client();
  await Future.wait([
    for (final d in {for (final u in dudosos) dominioRegistrable(u.host)})
      _rdap(o, d, c),
    _openPhish(o, dudosos, c),
  ]);
}

Future<void> _rdap(AnalisisOsint o, String dominio, http.Client c) async {
  o.consultados.add('el dominio $dominio a RDAP');
  try {
    final r = await c
        .get(Uri.parse('${FuentesCti.rdap}$dominio'))
        .timeout(const Duration(seconds: 5));
    if (r.statusCode != 200) return;
    final d = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    final eventos = (d['events'] as List? ?? const []).cast<Map>();
    final reg = eventos.firstWhere(
      (e) => e['eventAction'] == 'registration',
      orElse: () => const {},
    );
    final fecha = DateTime.tryParse('${reg['eventDate'] ?? ''}');
    if (fecha == null) return;
    final dias = DateTime.now().toUtc().difference(fecha.toUtc()).inDays;
    if (dias <= _diasNuevo) {
      o.cti.add(
        'RDAP: el dominio $dominio se creó hace ${dias <= 1 ? '1 día' : '$dias días'} (los estafadores usan dominios recién creados)',
      );
      o.ctiPuntaje = o.ctiPuntaje < 55 ? 55 : o.ctiPuntaje;
    } else {
      o.cti.add(
        'RDAP: el dominio $dominio existe desde hace ${dias ~/ 30} meses',
      );
    }
  } catch (_) {}
}

Future<void> _openPhish(
  AnalisisOsint o,
  List<AnalisisUrl> dudosos,
  http.Client c,
) async {
  try {
    final vieja =
        _listaCuando == null ||
        DateTime.now().difference(_listaCuando!) > const Duration(hours: 1);
    if (_listaOpenPhish == null || vieja) {
      final r = await c
          .get(Uri.parse(FuentesCti.openphish))
          .timeout(const Duration(seconds: 6));
      if (r.statusCode != 200) return;
      _listaOpenPhish = {
        for (final l in const LineSplitter().convert(utf8.decode(r.bodyBytes)))
          if (l.trim().isNotEmpty) l.trim().toLowerCase(),
      };
      _listaCuando = DateTime.now();
    }
    final lista = _listaOpenPhish!;
    final hosts = {for (final l in lista) Uri.tryParse(l)?.host ?? ''};
    for (final u in dudosos) {
      if (lista.contains(u.url.toLowerCase()) ||
          hosts.contains(u.host.toLowerCase())) {
        o.cti.add(
          'OpenPhish: ${u.host} está en la lista pública de sitios de phishing activos',
        );
        o.ctiPuntaje = 95;
      }
    }
  } catch (_) {}
}

/// Para pruebas: reemplaza la lista descargada.
@visibleForTesting
void fijarListaOpenPhish(Set<String>? lista) {
  _listaOpenPhish = lista;
  _listaCuando = lista == null ? null : DateTime.now();
}
