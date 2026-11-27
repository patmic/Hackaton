import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/providers.dart';
import '../../domain/domain.dart';
import '../widgets/animaciones.dart';
import '../widgets/responsivo.dart';

/// Mecánica A1 «Caza la señal»: un correo de práctica con trampas escondidas.
/// Se toca cada parte sospechosa: si hay trampa se ilumina y se explica; si no, el correo hace "no".
class CazaSenalScreen extends ConsumerStatefulWidget {
  const CazaSenalScreen({super.key, required this.actividad});
  final Actividad actividad;

  @override
  ConsumerState<CazaSenalScreen> createState() => _CazaSenalScreenState();
}

class _CazaSenalScreenState extends ConsumerState<CazaSenalScreen> {
  late final ContenidoCazaSenal _c =
      widget.actividad.contenido as ContenidoCazaSenal;
  final _encontradas = <String>{};
  SenalEscondida? _ultima;
  String? _fallo;
  int _sacudidas = 0;
  int _pistas = 0;
  String? _pista;
  bool _guardado = false;

  int get _total => _c.senales.length;
  bool get _terminado => _encontradas.length == _total;

  SenalEscondida? _senalEn(ZonaMensaje z) {
    for (final s in _c.senales) {
      if (s.zona.tipo == z.tipo &&
          (s.zona.parrafo == null || s.zona.parrafo == z.parrafo))
        return s;
    }
    return null;
  }

  void _tocar(ZonaMensaje z) {
    if (_terminado) return;
    final s = _senalEn(z);
    setState(() {
      _pista = null;
      if (s == null) {
        _fallo = 'Aquí no hay trampa. ¡Sigue buscando!';
        _sacudidas++;
      } else if (_encontradas.add(s.zona.codigo)) {
        HapticFeedback.heavyImpact();
        _ultima = s;
        _fallo = null;
      }
    });
    if (_terminado) _guardar();
  }

  void _darPista() {
    final falta = _c.senales.firstWhere(
      (s) => !_encontradas.contains(s.zona.codigo),
    );
    setState(() {
      _pistas++;
      _pista = falta.zona.codigo;
      _fallo = 'Mira la parte que brilla.';
    });
  }

  Future<void> _guardar() async {
    if (_guardado) return;
    _guardado = true;
    final aciertos = (_total - _pistas).clamp(0, _total);
    await ref
        .read(progresoProvider.notifier)
        .registrarResultado(
          ResultadoActividad(
            actividadId: widget.actividad.id,
            aciertos: aciertos,
            total: _total,
          ),
        );
    await ref
        .read(progresoProvider.notifier)
        .marcarCompletada(widget.actividad.id);
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final m = _c.mensaje;
    Widget zona(ZonaMensaje z, Widget hijo) => _Zona(
      encontrada:
          _senalEn(z) != null &&
          _encontradas.contains(_senalEn(z)!.zona.codigo),
      pista: _pista != null && _senalEn(z)?.zona.codigo == _pista,
      alTocar: () => _tocar(z),
      child: hijo,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Caza la señal')),
      body: AnchoLectura(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Aparecer(
                    child: Text(
                      _terminado
                          ? '¡Las encontraste todas!'
                          : 'Toca las $_total trampas escondidas en este correo',
                      style: textos.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Aparecer(
                    orden: 1,
                    child: _Marcador(
                      total: _total,
                      hechas: _encontradas.length,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Aparecer(
                    orden: 2,
                    child: Sacudir(
                      disparo: _sacudidas,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Chip(
                                  avatar: const Icon(
                                    Icons.science_rounded,
                                    size: 18,
                                  ),
                                  label: Text(m.etiqueta),
                                ),
                              ),
                              const SizedBox(height: 8),
                              zona(
                                const ZonaMensaje(TipoZona.remitente),
                                _Linea(etiqueta: 'De', texto: m.remitente),
                              ),
                              zona(
                                const ZonaMensaje(TipoZona.asunto),
                                _Linea(
                                  etiqueta: 'Asunto',
                                  texto: m.asunto,
                                  fuerte: true,
                                ),
                              ),
                              const Divider(height: 20),
                              for (var i = 0; i < m.parrafos.length; i++)
                                zona(
                                  ZonaMensaje(TipoZona.cuerpo, parrafo: i + 1),
                                  Text(m.parrafos[i], style: textos.bodyLarge),
                                ),
                              if (m.adjunto != null)
                                zona(
                                  const ZonaMensaje(TipoZona.adjunto),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_file_rounded),
                                      const SizedBox(width: 6),
                                      Flexible(child: Text(m.adjunto!)),
                                    ],
                                  ),
                                ),
                              if (m.tieneQr)
                                zona(
                                  const ZonaMensaje(TipoZona.qr),
                                  const Row(
                                    children: [
                                      Icon(Icons.qr_code_2_rounded, size: 40),
                                      SizedBox(width: 8),
                                      Text('Escanea este código'),
                                    ],
                                  ),
                                ),
                              if (m.boton != null)
                                zona(
                                  const ZonaMensaje(TipoZona.boton),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: esquema.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        m.boton!,
                                        style: TextStyle(
                                          color: esquema.onPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lo que se acaba de descubrir (o el "sigue buscando").
                  AnimatedSwitcher(
                    duration: sinMovimiento(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 380),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, .15),
                          end: Offset.zero,
                        ).animate(a),
                        child: c,
                      ),
                    ),
                    child: _fallo != null
                        ? _Globo(
                            key: ValueKey('f$_sacudidas$_pistas'),
                            icono: Icons.search_rounded,
                            texto: _fallo!,
                          )
                        : _ultima != null
                        ? _Globo(
                            key: ValueKey(_ultima!.zona.codigo),
                            icono: Icons.warning_amber_rounded,
                            titulo: _ultima!.indicio.nombre,
                            texto: _ultima!.feedback,
                            alerta: true,
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  if (_terminado) ...[
                    Saltar(
                      child: Card(
                        color: esquema.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 56,
                                color: esquema.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _pistas == 0
                                    ? '¡Sin pistas! Tienes ojo de guardián.'
                                    : 'Las encontraste con $_pistas pista${_pistas == 1 ? '' : 's'}.',
                                textAlign: TextAlign.center,
                                style: textos.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.actividad.mensajeClave,
                                textAlign: TextAlign.center,
                                style: textos.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Rebote(
                      child: SizedBox(
                        height: 60,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Terminar'),
                        ),
                      ),
                    ),
                  ] else
                    Rebote(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _darPista,
                          icon: const Icon(Icons.lightbulb_rounded),
                          label: const Text('Dame una pista'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_terminado) const Positioned.fill(child: Confeti()),
          ],
        ),
      ),
    );
  }
}

/// Parte del correo que se puede tocar. Encontrada: se ilumina con una insignia que salta.
class _Zona extends StatelessWidget {
  const _Zona({
    required this.encontrada,
    required this.pista,
    required this.alTocar,
    required this.child,
  });
  final bool encontrada, pista;
  final VoidCallback alTocar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final dur = sinMovimiento(context)
        ? Duration.zero
        : const Duration(milliseconds: 320);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Semantics(
        button: true,
        label: encontrada
            ? 'Trampa encontrada'
            : 'Tocar para revisar esta parte',
        child: Rebote(
          escala: 0.97,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: alTocar,
              child: AnimatedContainer(
                duration: dur,
                curve: Curves.easeOut,
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: encontrada
                      ? esquema.error.withValues(alpha: 0.12)
                      : pista
                      ? esquema.primary.withValues(alpha: 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: encontrada
                        ? esquema.error
                        : (pista ? esquema.primary : esquema.outlineVariant),
                    width: encontrada || pista ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: child),
                    if (encontrada)
                      Saltar(
                        child: Icon(
                          Icons.flag_rounded,
                          color: esquema.error,
                          semanticLabel: 'Trampa',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  const _Linea({
    required this.etiqueta,
    required this.texto,
    this.fuerte = false,
  });
  final String etiqueta, texto;
  final bool fuerte;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$etiqueta: ',
            style: t.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          TextSpan(text: texto, style: (fuerte ? t.titleMedium : t.bodyLarge)),
        ],
      ),
    );
  }
}

/// Puntos que se llenan con un salto al encontrar cada trampa.
class _Marcador extends StatelessWidget {
  const _Marcador({required this.total, required this.hechas});
  final int total, hechas;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Semantics(
      label: '$hechas de $total trampas encontradas',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < total; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedContainer(
                duration: sinMovimiento(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < hechas ? esquema.error : Colors.transparent,
                  border: Border.all(
                    color: i < hechas ? esquema.error : esquema.outline,
                    width: 2,
                  ),
                ),
                child: i < hechas
                    ? Saltar(
                        child: Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: esquema.onError,
                        ),
                      )
                    : null,
              ),
            ),
          const SizedBox(width: 4),
          Text(
            '$hechas de $total',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _Globo extends StatelessWidget {
  const _Globo({
    super.key,
    required this.icono,
    required this.texto,
    this.titulo,
    this.alerta = false,
  });
  final IconData icono;
  final String texto;
  final String? titulo;
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Card(
        color: alerta
            ? esquema.error.withValues(alpha: 0.08)
            : esquema.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icono,
                color: alerta ? esquema.error : esquema.primary,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titulo != null) Text(titulo!, style: t.titleMedium),
                    Text(texto, style: t.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
