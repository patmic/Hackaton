import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/domain.dart';

/// Fuente de las tipologías y del Sello IESS.
///
/// `assets/data/tipologias.json` es una copia de
/// `tipologias-correo/tipologias.json` (raíz del repo). Flutter solo empaqueta
/// archivos de su propia carpeta; una prueba comprueba que la copia no se
/// desfase del original.
abstract interface class TipologiaRepository {
  Future<CatalogoTipologias> obtener();
}

CatalogoTipologias parsearTipologias(String json) =>
    CatalogoTipologias.fromJson(jsonDecode(json) as Map<String, dynamic>);

class AssetTipologiaRepository implements TipologiaRepository {
  AssetTipologiaRepository({
    AssetBundle? bundle,
    this.ruta = 'assets/data/tipologias.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String ruta;
  CatalogoTipologias? _cache;

  @override
  Future<CatalogoTipologias> obtener() async =>
      _cache ??= parsearTipologias(await _bundle.loadString(ruta));
}

class MemoriaTipologiaRepository implements TipologiaRepository {
  const MemoriaTipologiaRepository(this.catalogo);

  final CatalogoTipologias catalogo;

  @override
  Future<CatalogoTipologias> obtener() async => catalogo;
}
