import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/domain.dart';

/// Fuente del catálogo de actividades. Hoy es un JSON local; luego puede ser
/// la API de Capacitación sin cambiar la lógica.
abstract interface class ActividadRepository {
  Future<List<Actividad>> obtenerTodas();
}

/// Convierte el JSON del catálogo en actividades.
List<Actividad> parsearActividades(String json) {
  final lista = jsonDecode(json) as List<dynamic>;
  return lista.cast<Map<String, dynamic>>().map(Actividad.fromJson).toList();
}

class AssetActividadRepository implements ActividadRepository {
  AssetActividadRepository({
    AssetBundle? bundle,
    this.ruta = 'assets/data/actividades.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String ruta;
  List<Actividad>? _cache;

  @override
  Future<List<Actividad>> obtenerTodas() async =>
      _cache ??= parsearActividades(await _bundle.loadString(ruta));
}

class MemoriaActividadRepository implements ActividadRepository {
  const MemoriaActividadRepository(this.actividades);

  final List<Actividad> actividades;

  @override
  Future<List<Actividad>> obtenerTodas() async => actividades;
}
