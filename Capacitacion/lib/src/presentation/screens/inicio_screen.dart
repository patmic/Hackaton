import 'package:material_ui/material_ui.dart';

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
    'Para ti',
    'Verificar correo',
    'Catálogo',
    'Mi progreso',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indice])),
      body: IndexedStack(
        index: _indice,
        children: const [
          ParaTiTab(),
          VerificarTab(),
          CatalogoTab(),
          ProgresoTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            label: 'Para ti',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            label: 'Verificar',
          ),
          NavigationDestination(icon: Icon(Icons.list), label: 'Catálogo'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Progreso'),
        ],
      ),
    );
  }
}
