import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/domain.dart';

/// Lo que el dispositivo guarda para aprender de la persona. Se queda en el
/// dispositivo; solo llega al Radar Phishing si la persona activa
/// [compartir].
class DatosObservador {
  const DatosObservador({
    required this.idSeudonimo,
    this.observaciones = const [],
    this.compartir = false,
    this.enviadas = 0,
  });

  /// Código aleatorio del dispositivo. No sale de datos personales.
  factory DatosObservador.nuevo([Random? azar]) {
    final r = azar ?? Random.secure();
    final id = [
      for (var i = 0; i < 16; i++)
        r.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
    return DatosObservador(idSeudonimo: id);
  }

  factory DatosObservador.fromJson(Map<String, dynamic> json) =>
      DatosObservador(
        idSeudonimo: json['id_seudonimo'] as String,
        compartir: json['compartir'] as bool? ?? false,
        enviadas: json['enviadas'] as int? ?? 0,
        observaciones: [
          for (final o in json['observaciones'] as List<dynamic>? ?? const [])
            ObservacionConducta.fromJson(o as Map<String, dynamic>),
        ],
      );

  /// Máximo guardado en el dispositivo: con el olvido de 60 días, lo más
  /// viejo casi no pesa.
  static const maximo = 500;

  final String idSeudonimo;
  final List<ObservacionConducta> observaciones;

  /// La persona aceptó compartir sus prácticas con el Radar Phishing.
  final bool compartir;

  /// Cuántas de [observaciones] ya recibió el Radar Phishing.
  final int enviadas;

  List<ObservacionConducta> get pendientes =>
      observaciones.sublist(enviadas.clamp(0, observaciones.length));

  /// Agrega una observación y descarta las más viejas si pasa de [maximo].
  DatosObservador con(ObservacionConducta o) {
    final todas = [...observaciones, o];
    final sobran = todas.length - maximo;
    if (sobran <= 0) return copyWith(observaciones: todas);
    return copyWith(
      observaciones: todas.sublist(sobran),
      enviadas: (enviadas - sobran).clamp(0, maximo),
    );
  }

  DatosObservador copyWith({
    List<ObservacionConducta>? observaciones,
    bool? compartir,
    int? enviadas,
  }) => DatosObservador(
    idSeudonimo: idSeudonimo,
    observaciones: observaciones ?? this.observaciones,
    compartir: compartir ?? this.compartir,
    enviadas: enviadas ?? this.enviadas,
  );

  Map<String, dynamic> toJson() => {
    'id_seudonimo': idSeudonimo,
    'compartir': compartir,
    'enviadas': enviadas,
    'observaciones': [for (final o in observaciones) o.toJson()],
  };
}

abstract interface class AlmacenObservador {
  Future<DatosObservador> cargar();
  Future<void> guardar(DatosObservador datos);
}

class PreferenciasAlmacenObservador implements AlmacenObservador {
  PreferenciasAlmacenObservador({SharedPreferencesAsync? preferencias})
    : _prefs = preferencias ?? SharedPreferencesAsync();

  static const clave = 'capacitacion.observador.v1';

  final SharedPreferencesAsync _prefs;

  @override
  Future<DatosObservador> cargar() async {
    final texto = await _prefs.getString(clave);
    if (texto != null) {
      try {
        return DatosObservador.fromJson(
          jsonDecode(texto) as Map<String, dynamic>,
        );
      } on Object {
        // Datos dañados o de otra versión: se empieza de nuevo.
      }
    }
    final nuevo = DatosObservador.nuevo();
    await guardar(nuevo);
    return nuevo;
  }

  @override
  Future<void> guardar(DatosObservador datos) =>
      _prefs.setString(clave, jsonEncode(datos.toJson()));
}

class MemoriaAlmacenObservador implements AlmacenObservador {
  MemoriaAlmacenObservador([DatosObservador? datos])
    : _datos =
          datos ?? const DatosObservador(idSeudonimo: 'dispositivo-de-prueba');

  DatosObservador _datos;

  DatosObservador get datos => _datos;

  @override
  Future<DatosObservador> cargar() async => _datos;

  @override
  Future<void> guardar(DatosObservador datos) async => _datos = datos;
}

/// Contrato del observador (Radar Phishing), montado en SellaCorreo con el
/// prefijo `/api/v1/observatorio` (`Analisis-de-comportamiento/README.md`).
abstract interface class ObservadorApi {
  /// `POST /observaciones` con `{"observaciones": [...]}`.
  Future<void> registrar(List<Map<String, dynamic>> observaciones);

  /// `GET /personas/{id}/plan?tipos=EX1&rango=30-49`.
  Future<PlanPersonalizado> plan(
    String idSeudonimo, {
    Set<TipoUsuario> tipos = const {},
    RangoEtario? rangoEtario,
  });

  /// `DELETE /personas/{id}`: derecho de eliminación (LOPDP).
  Future<void> borrar(String idSeudonimo);
}

/// El Radar Phishing no respondió o rechazó la solicitud.
class ObservadorNoDisponible implements Exception {
  const ObservadorNoDisponible([this.detalle = '', this.estadoHttp]);

  final String detalle;
  final int? estadoHttp;

  /// El servidor respondió y no lo acepta (4xx): reintentar no sirve. Un
  /// 429 (demasiadas solicitudes) sí se reintenta.
  bool get rechazado =>
      estadoHttp != null &&
      estadoHttp! >= 400 &&
      estadoHttp! < 500 &&
      estadoHttp != 429;

  @override
  String toString() => 'ObservadorNoDisponible: $detalle';
}

class HttpObservadorApi implements ObservadorApi {
  HttpObservadorApi(
    this.base, {
    http.Client? cliente,
    this.espera = const Duration(seconds: 5),
  }) : _cliente = cliente ?? http.Client();

  /// Servidor del Radar Phishing (secreto de compilación). Si falta, se usa
  /// el de SellaCorreo (`AIESS_SELLO`), que es donde vive el observador.
  static const urlEntorno = String.fromEnvironment(
    'OBSERVADOR_URL',
    defaultValue: String.fromEnvironment('AIESS_SELLO'),
  );

  /// Null si la app se compiló sin servidor: todo se calcula en el
  /// dispositivo.
  static HttpObservadorApi? desdeEntorno() {
    final uri = Uri.tryParse(urlEntorno.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return HttpObservadorApi(uri);
  }

  /// El observador acepta hasta 200 por envío (todo o nada).
  static const maximoLote = 200;
  static const prefijo = '/api/v1/observatorio';

  final Uri base;
  final Duration espera;
  final http.Client _cliente;

  Uri _uri(String ruta, [Map<String, String>? consulta]) {
    final raiz = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(
      path: '$raiz$prefijo$ruta',
      queryParameters: consulta == null || consulta.isEmpty ? null : consulta,
    );
  }

  @override
  Future<void> registrar(List<Map<String, dynamic>> observaciones) async {
    for (var i = 0; i < observaciones.length; i += maximoLote) {
      final lote = observaciones.sublist(
        i,
        min(i + maximoLote, observaciones.length),
      );
      await _pedir(
        () => _cliente.post(
          _uri('/observaciones'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'observaciones': lote}),
        ),
      );
    }
  }

  @override
  Future<PlanPersonalizado> plan(
    String idSeudonimo, {
    Set<TipoUsuario> tipos = const {},
    RangoEtario? rangoEtario,
  }) async {
    final resp = await _pedir(
      () => _cliente.get(
        _uri('/personas/${Uri.encodeComponent(idSeudonimo)}/plan', {
          if (tipos.isNotEmpty)
            'tipos': [
              for (final t in TipoUsuario.values)
                if (tipos.contains(t)) t.codigo,
            ].join(','),
          'rango': ?rangoEtario?.codigo,
        }),
      ),
    );
    try {
      return PlanPersonalizado.fromJson(
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>,
      );
    } on Object catch (e) {
      throw ObservadorNoDisponible('plan con otra forma: $e');
    }
  }

  @override
  Future<void> borrar(String idSeudonimo) async {
    await _pedir(
      () => _cliente.delete(
        _uri('/personas/${Uri.encodeComponent(idSeudonimo)}'),
      ),
    );
  }

  Future<http.Response> _pedir(Future<http.Response> Function() pedido) async {
    final http.Response resp;
    try {
      resp = await pedido().timeout(espera);
    } on Object catch (e) {
      throw ObservadorNoDisponible('$e');
    }
    if (resp.statusCode >= 300) {
      throw ObservadorNoDisponible('HTTP ${resp.statusCode}', resp.statusCode);
    }
    return resp;
  }
}
