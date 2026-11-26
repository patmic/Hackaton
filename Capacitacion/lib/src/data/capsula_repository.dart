import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/domain.dart';

/// Fuente del catálogo de cápsulas. Hoy es un JSON local; luego puede ser
/// la API del Núcleo sin cambiar la lógica.
abstract interface class CapsulaRepository {
  Future<List<Capsula>> obtenerTodas();
}

/// Convierte el JSON del catálogo en cápsulas.
List<Capsula> parsearCatalogo(String json) {
  final lista = jsonDecode(json) as List<dynamic>;
  return lista.cast<Map<String, dynamic>>().map(Capsula.fromJson).toList();
}

class AssetCapsulaRepository implements CapsulaRepository {
  AssetCapsulaRepository({
    AssetBundle? bundle,
    this.ruta = 'assets/data/capsulas.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String ruta;
  List<Capsula>? _cache;

  @override
  Future<List<Capsula>> obtenerTodas() async =>
      _cache ??= parsearCatalogo(await _bundle.loadString(ruta));
}

class MemoriaCapsulaRepository implements CapsulaRepository {
  const MemoriaCapsulaRepository(this.capsulas);

  final List<Capsula> capsulas;

  @override
  Future<List<Capsula>> obtenerTodas() async => capsulas;
}
