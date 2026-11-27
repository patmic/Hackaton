import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/domain.dart';

/// Guarda el progreso solo en el dispositivo. No se envía al Núcleo.
abstract interface class ProgresoRepository {
  Future<Progreso> cargar();
  Future<void> guardar(Progreso progreso);
}

class PreferenciasProgresoRepository implements ProgresoRepository {
  PreferenciasProgresoRepository({SharedPreferencesAsync? preferencias})
    : _prefs = preferencias ?? SharedPreferencesAsync();

  static const clave = 'capacitacion.progreso.v1';

  final SharedPreferencesAsync _prefs;

  @override
  Future<Progreso> cargar() async {
    final texto = await _prefs.getString(clave);
    if (texto == null) return const Progreso();
    try {
      return Progreso.fromJson(jsonDecode(texto) as Map<String, dynamic>);
    } on FormatException {
      return const Progreso();
    }
  }

  @override
  Future<void> guardar(Progreso progreso) =>
      _prefs.setString(clave, jsonEncode(progreso.toJson()));
}

class MemoriaProgresoRepository implements ProgresoRepository {
  MemoriaProgresoRepository([this._progreso = const Progreso()]);

  Progreso _progreso;

  @override
  Future<Progreso> cargar() async => _progreso;

  @override
  Future<void> guardar(Progreso progreso) async => _progreso = progreso;
}
