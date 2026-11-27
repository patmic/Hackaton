import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/logica/logica.dart';
import '../../application/providers.dart';
import '../widgets/ilustracion_modulo.dart';
import '../widgets/marca_iess.dart';
import '../widgets/responsivo.dart';
import 'catalogo_tab.dart';
import 'para_ti_tab.dart';
import 'progreso_tab.dart';
import 'verificar_tab.dart';

class InicioScreen extends ConsumerStatefulWidget {
  const InicioScreen({super.key});

  @override
  ConsumerState<InicioScreen> createState() => _InicioScreenState();
}

class _Seccion {
  const _Seccion(this.titulo, this.etiqueta, this.icono, this.iconoActivo);
  final String titulo, etiqueta;
  final IconData icono, iconoActivo;
}

class _InicioScreenState extends ConsumerState<InicioScreen> {
  int _indice = 0;

  /// «Mi avance», donde están las insignias.
  static const _indiceProgreso = 3;

  /// Insignias ya celebradas en esta visita (mientras se terminan de guardar).
  final _celebradas = <String>{};

  static const _secciones = [
    _Seccion(
      'Aula virtual',
      'Para ti',
      Icons.home_outlined,
      Icons.home_rounded,
    ),
    _Seccion(
      'Verificar correo',
      'Verificar',
      Icons.verified_user_outlined,
      Icons.verified_user_rounded,
    ),
    _Seccion(
      'Todas las lecciones',
      'Catálogo',
      Icons.menu_book_outlined,
      Icons.menu_book_rounded,
    ),
    _Seccion(
      'Mi avance',
      'Progreso',
      Icons.insights_outlined,
      Icons.insights_rounded,
    ),
  ];

  /// Al ganar una insignia (en cualquier lección abierta encima del aula) se
  /// guarda en el progreso y se avisa una sola vez.
  void _alCambiarInsignias(
    AsyncValue<ResumenInsignias>? _,
    AsyncValue<ResumenInsignias> siguiente,
  ) {
    // Mientras se recalcula, el valor anterior puede traer insignias ya guardadas.
    if (siguiente.isLoading) return;
    if (siguiente case AsyncData(value: final resumen)) {
      final nuevas = [
        for (final i in resumen.nuevas)
          if (!_celebradas.contains(i.id)) i,
      ];
      if (nuevas.isEmpty) return;
      _celebradas.addAll(nuevas.map((i) => i.id));
      unawaited(
        ref.read(progresoProvider.notifier).otorgarInsignias({
          for (final i in nuevas) i.id,
        }),
      );
      // Fuera de la construcción del cuadro: el aviso cambia el estado del ScaffoldMessenger.
      scheduleMicrotask(() {
        if (mounted) _avisar(nuevas);
      });
    }
  }

  void _avisar(List<Insignia> nuevas) {
    final primera = nuevas.first;
    final texto = nuevas.length == 1
        ? '¡Ganaste la insignia «${primera.nombre}»!'
        : '¡Ganaste ${nuevas.length} insignias!';
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const ValueKey('aviso-insignia'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          content: Row(
            children: [
              InsigniaVista(insignia: primera, tam: 40, animada: true),
              const SizedBox(width: 12),
              Expanded(child: Text(texto)),
            ],
          ),
          action: SnackBarAction(label: 'Ver', onPressed: _verInsignias),
        ),
      );
  }

  /// Cierra la lección que esté abierta y muestra «Mi avance».
  void _verInsignias() {
    if (!mounted) return;
    final propia = ModalRoute.of(context);
    Navigator.of(context).popUntil((r) => r == propia || r.isFirst);
    setState(() => _indice = _indiceProgreso);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(insigniasProvider, _alCambiarInsignias);
    final escritorio = MediaQuery.sizeOf(context).width >= anchoEscritorio;
    final paginas = [
      ParaTiTab(
        onVerInsignias: () => setState(() => _indice = _indiceProgreso),
      ),
      const VerificarTab(),
      const CatalogoTab(),
      const ProgresoTab(),
    ];
    final cuerpo = IndexedStack(index: _indice, children: paginas);
    return Scaffold(
      // Logo del IESS + dónde estoy (visibilidad del estado y confianza).
      appBar: AppBar(title: TituloConLogo(_secciones[_indice].titulo)),
      // Computadora: menú lateral con nombres a la vista y el contenido en una columna cómoda.
      body: escritorio
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NavigationRail(
                  extended: true,
                  minExtendedWidth: 220,
                  selectedIndex: _indice,
                  onDestinationSelected: (i) => setState(() => _indice = i),
                  destinations: [
                    for (final s in _secciones)
                      NavigationRailDestination(
                        icon: Icon(s.icono),
                        selectedIcon: Icon(s.iconoActivo),
                        label: Text(s.etiqueta),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: AnchoLectura(maximo: 1180, child: cuerpo)),
              ],
            )
          : cuerpo,
      // Celular: ícono + texto siempre; el ícono lleno marca la pestaña actual.
      bottomNavigationBar: escritorio
          ? null
          : NavigationBar(
              selectedIndex: _indice,
              onDestinationSelected: (i) => setState(() => _indice = i),
              destinations: [
                for (final s in _secciones)
                  NavigationDestination(
                    icon: Icon(s.icono),
                    selectedIcon: Icon(s.iconoActivo),
                    label: s.etiqueta,
                  ),
              ],
            ),
    );
  }
}
