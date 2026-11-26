import 'dart:convert';

import 'package:flutter/services.dart';

/// Canales oficiales y listas de referencia (assets/data/canales_oficiales.json, mismo archivo que usa Python).
class Canales {
  Canales._(this._j);
  final Map<String, dynamic> _j;
  static Canales? _inst;

  static Future<Canales> cargar() async =>
      _inst ??= Canales._(jsonDecode(await rootBundle.loadString('assets/data/canales_oficiales.json')));
  static Canales get i => _inst!;

  List<String> _l(String k) => List<String>.from(_j[k] as List);
  List<String> get dominiosIess => _l('dominios_iess');
  List<String> get confiables => _l('dominios_confiables');
  List<String> get acortadores => _l('acortadores');
  List<String> get alojamiento => _l('alojamiento_generico');
  List<String> get tldsRiesgosos => _l('tlds_riesgosos');
  List<String> get correoGratuito => _l('proveedores_correo_gratuito');
  List<String> get marcas => _l('marcas_vigiladas');
  List<String> get extPeligrosas => _l('extensiones_peligrosas');
  Map<String, String> get contacto => Map<String, String>.from(_j['contacto'] as Map);
}

/// minúsculas sin tildes (equivale a plegar() de Python).
String plegar(String s) {
  const de = 'áàäâãéèëêíìïîóòöôõúùüûñÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÑ';
  const a = 'aaaaaeeeeiiiiooooouuuunaaaaaeeeeiiiiooooouuuun';
  final b = StringBuffer();
  for (final r in s.runes) {
    final c = String.fromCharCode(r);
    final i = de.indexOf(c);
    b.write(i >= 0 ? a[i] : c);
  }
  return b.toString().toLowerCase();
}

final urlRe = RegExp(r'''(?:https?://|www\.)[^\s\[\]<>"«»,;)]+''', caseSensitive: false);
