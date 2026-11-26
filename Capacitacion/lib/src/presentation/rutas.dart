import 'package:material_ui/material_ui.dart';

import '../domain/domain.dart';
import 'screens/verificacion_screen.dart';

/// Rutas con nombre de la app.
///
/// Flutter entrega aquí el App Link del botón «Verificar en App»: como ruta
/// inicial si la app estaba cerrada, o con `pushRoute` si estaba abierta.
/// Solo se aceptan los enlaces de [EnlaceVerificacion].
Route<void>? generarRuta(RouteSettings settings) {
  final codigo = EnlaceVerificacion.codigoDesde(settings.name);
  if (codigo == null) return null;
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => VerificacionScreen(codigo: codigo),
  );
}

/// Cualquier otro enlace que llegue a la app.
Route<void> rutaDesconocida(RouteSettings settings) => MaterialPageRoute<void>(
  settings: settings,
  builder: (_) => const EnlaceDesconocidoScreen(),
);

class EnlaceDesconocidoScreen extends StatelessWidget {
  const EnlaceDesconocidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enlace no reconocido')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Este enlace no es de verificación del IESS. Si llegó en un correo, '
          'no confíes en él y repórtalo.',
        ),
      ),
    );
  }
}
