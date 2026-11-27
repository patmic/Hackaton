import 'package:material_ui/material_ui.dart';

/// Logo oficial del IESS (versión blanca, para fondos azules). Se usa sin alterar.
/// Funciona dentro de AIESS y cuando el módulo corre solo (por eso indica el paquete).
class LogoIess extends StatelessWidget {
  const LogoIess({super.key, this.alto = 30});
  final double alto;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/img/iess_logo_blanco.png',
    package: 'capacitacion',
    height: alto,
    filterQuality: FilterQuality.medium,
    semanticLabel: 'IESS',
  );
}

/// Título de la barra superior: logo del IESS + nombre de la sección.
class TituloConLogo extends StatelessWidget {
  const TituloConLogo(this.titulo, {super.key});
  final String titulo;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const LogoIess(alto: 28),
      Container(
        width: 1.5,
        height: 26,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.white.withValues(alpha: 0.5),
      ),
      Flexible(child: Text(titulo, overflow: TextOverflow.ellipsis)),
    ],
  );
}
