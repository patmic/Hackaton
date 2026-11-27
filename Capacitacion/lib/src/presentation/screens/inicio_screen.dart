import 'package:material_ui/material_ui.dart';

import '../widgets/marca_iess.dart';
import 'catalogo_tab.dart';
import 'para_ti_tab.dart';
import 'progreso_tab.dart';
import 'verificar_tab.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _indice = 0;

  static const _titulos = [
    'Aula virtual',
    'Verificar correo',
    'Todas las lecciones',
    'Mi avance',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Logo del IESS + dónde estoy (visibilidad del estado y confianza).
      appBar: AppBar(title: TituloConLogo(_titulos[_indice])),
      body: IndexedStack(
        index: _indice,
        children: const [
          ParaTiTab(),
          VerificarTab(),
          CatalogoTab(),
          ProgresoTab(),
        ],
      ),
      // Ícono + texto siempre; el ícono lleno marca la pestaña actual.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Para ti',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user_rounded),
            label: 'Verificar',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }
}
