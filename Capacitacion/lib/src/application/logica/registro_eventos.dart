import '../../data/capacitacion_api.dart';
import '../../domain/domain.dart';

/// Envía los eventos de la app a `POST /api/v1/eventos`.
///
/// Nunca interrumpe a la app: si la API no responde, guarda los eventos
/// (hasta [maximoPendientes]) y los reintenta con el siguiente. Los envíos
/// no se solapan, para no duplicar eventos.
class RegistroEventos {
  RegistroEventos({
    required this._api,
    required this._contexto,
    required this._reloj,
  });

  static const maximoPendientes = 50;

  final CapacitacionApi _api;
  final ContextoEvento Function() _contexto;
  final DateTime Function() _reloj;
  final List<EventoApp> _pendientes = [];
  bool _enviando = false;

  DateTime ahora() => _reloj();

  int get pendientes => _pendientes.length;

  Future<void> registrar(EventoApp evento) async {
    _pendientes.add(evento.conContexto(_contexto()));
    if (_enviando) return;
    _enviando = true;
    try {
      while (_pendientes.isNotEmpty) {
        final lote = List<EventoApp>.of(_pendientes);
        await _api.registrarEventos(lote);
        _pendientes.removeRange(0, lote.length);
      }
    } on Exception {
      if (_pendientes.length > maximoPendientes) {
        _pendientes.removeRange(0, _pendientes.length - maximoPendientes);
      }
    } finally {
      _enviando = false;
    }
  }
}
