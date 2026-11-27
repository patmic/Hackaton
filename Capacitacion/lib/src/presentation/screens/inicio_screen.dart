import 'package:material_ui/material_ui.dart';

import '../widgets/marca_iess.dart';
import '../widgets/responsivo.dart';
import 'catalogo_tab.dart';
import 'para_ti_tab.dart';
import 'progreso_tab.dart';
import 'verificar_tab.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _Seccion {
  const _Seccion(this.titulo, this.etiqueta, this.icono, this.iconoActivo);
  final String titulo, etiqueta;
  final IconData icono, iconoActivo;
}

class _InicioScreenState extends State<InicioScreen> {
  int _indice = 0;

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

  static const _paginas = [
    ParaTiTab(),
    VerificarTab(),
    CatalogoTab(),
    ProgresoTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final escritorio = MediaQuery.sizeOf(context).width >= anchoEscritorio;
    final cuerpo = IndexedStack(index: _indice, children: _paginas);
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
