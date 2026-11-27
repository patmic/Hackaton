// Ilustración de cada módulo: una insignia con color propio y dos símbolos que cuentan de qué trata
// (lupa sobre el correo, escudo del canal oficial, megáfono para reportar, QR con alerta…).
// Así cada lección se reconoce de un vistazo, sin leer el código del módulo.
import 'package:material_ui/material_ui.dart';

import '../../application/logica/insignias.dart';
import 'animaciones.dart';

class EstiloModulo {
  const EstiloModulo(this.color, this.icono, this.acento, this.lema);
  final Color color;
  final IconData icono, acento;

  /// Frase corta para la portada del módulo.
  final String lema;
}

const _estilos = <String, EstiloModulo>{
  'M1': EstiloModulo(
    Color(0xFF145962),
    Icons.manage_search_rounded,
    Icons.warning_rounded,
    'Aprende a ver las trampas',
  ),
  'M2': EstiloModulo(
    Color(0xFF1F4E8C),
    Icons.verified_user_rounded,
    Icons.mark_email_read_rounded,
    'Verifica en el canal oficial',
  ),
  'M3': EstiloModulo(
    Color(0xFFA34B12),
    Icons.campaign_rounded,
    Icons.flag_rounded,
    'Avisar toma un toque',
  ),
  'M4': EstiloModulo(
    Color(0xFF7A5300),
    Icons.savings_rounded,
    Icons.gpp_bad_rounded,
    'Nadie regala ni cobra por adelantado',
  ),
  'M5': EstiloModulo(
    Color(0xFFA3233F),
    Icons.medical_services_rounded,
    Icons.event_available_rounded,
    'Citas y trámites reales',
  ),
  'M6': EstiloModulo(
    Color(0xFF5B2A86),
    Icons.qr_code_2_rounded,
    Icons.warning_rounded,
    'Un QR puede llevar a cualquier lado',
  ),
  'M7': EstiloModulo(
    Color(0xFF1E6B3A),
    Icons.elderly_rounded,
    Icons.shield_rounded,
    'Tu pensión no se bloquea por correo',
  ),
  'M8': EstiloModulo(
    Color(0xFF3D4A5C),
    Icons.business_rounded,
    Icons.receipt_long_rounded,
    'Glosas y planillas de verdad',
  ),
  'M9': EstiloModulo(
    Color(0xFF9A3412),
    Icons.payments_rounded,
    Icons.block_rounded,
    'Sin intermediarios ni comisiones',
  ),
  'M10': EstiloModulo(
    Color(0xFFA0285A),
    Icons.family_restroom_rounded,
    Icons.favorite_rounded,
    'Cuida a los tuyos',
  ),
  'M11': EstiloModulo(
    Color(0xFF3730A3),
    Icons.lock_person_rounded,
    Icons.key_rounded,
    'Tu cuenta institucional',
  ),
  'M12': EstiloModulo(
    Color(0xFF0E6B7A),
    Icons.outgoing_mail,
    Icons.verified_rounded,
    'Emitir con sello',
  ),
  'M13': EstiloModulo(
    Color(0xFF1B3A5B),
    Icons.radar_rounded,
    Icons.groups_rounded,
    'Responder a una campaña',
  ),
  'M14': EstiloModulo(
    Color(0xFF4A1D6B),
    Icons.smart_toy_rounded,
    Icons.visibility_rounded,
    'Estafas con IA y WhatsApp',
  ),
};

EstiloModulo estiloModulo(String codigo) =>
    _estilos[codigo.trim().toUpperCase()] ??
    const EstiloModulo(
      Color(0xFF145962),
      Icons.school_rounded,
      Icons.star_rounded,
      'Aprende a protegerte',
    );

/// Insignia del módulo: círculo con degradado, símbolo grande y un símbolo de acento.
class IlustracionModulo extends StatelessWidget {
  const IlustracionModulo({
    super.key,
    required this.codigo,
    this.tam = 64,
    this.animada = false,
    this.estilo,
    this.apagada = false,
  });
  final String codigo;
  final double tam;

  /// Entra con un pequeño salto (portadas).
  final bool animada;

  /// Otro color y símbolos (insignias de logro). Null: los del módulo.
  final EstiloModulo? estilo;

  /// En gris y tenue: insignia que todavía no se gana.
  final bool apagada;

  @override
  Widget build(BuildContext context) {
    final e = estilo ?? estiloModulo(codigo);
    final insignia = ExcludeSemantics(
      child: SizedBox(
        width: tam,
        height: tam,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.lerp(e.color, Colors.white, 0.18)!, e.color],
                ),
                boxShadow: [
                  BoxShadow(
                    color: e.color.withValues(alpha: 0.35),
                    blurRadius: tam * 0.18,
                    offset: Offset(0, tam * 0.06),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(e.icono, color: Colors.white, size: tam * 0.52),
            ),
            Positioned(
              right: -tam * 0.04,
              bottom: -tam * 0.04,
              child: Container(
                width: tam * 0.42,
                height: tam * 0.42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: e.color, width: tam * 0.035),
                ),
                alignment: Alignment.center,
                child: Icon(e.acento, color: e.color, size: tam * 0.25),
              ),
            ),
          ],
        ),
      ),
    );
    final vista = apagada
        ? Opacity(
            opacity: 0.45,
            child: ColorFiltered(colorFilter: _grises, child: insignia),
          )
        : insignia;
    return animada ? Saltar(child: vista) : vista;
  }
}

const _grises = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// Color y símbolos de las insignias de logro (las de módulo usan [estiloModulo]).
const _estilosLogro = <String, EstiloModulo>{
  Insignias.primerPaso: EstiloModulo(
    Color(0xFF1E6B3A),
    Icons.flag_rounded,
    Icons.star_rounded,
    'Empezaste a protegerte',
  ),
  Insignias.meCapacito: EstiloModulo(
    Color(0xFF1F4E8C),
    Icons.school_rounded,
    Icons.mark_email_read_rounded,
    'Practicas con correos de prueba',
  ),
  Insignias.detective: EstiloModulo(
    Color(0xFFA34B12),
    Icons.policy_rounded,
    Icons.campaign_rounded,
    'Viste la trampa y avisaste',
  ),
  Insignias.constancia: EstiloModulo(
    Color(0xFF7A5300),
    Icons.trending_up_rounded,
    Icons.bolt_rounded,
    'Poco y seguido se aprende más',
  ),
  Insignias.ojoDeLince: EstiloModulo(
    Color(0xFF5B2A86),
    Icons.visibility_rounded,
    Icons.check_rounded,
    'No se te escapó ninguna',
  ),
  Insignias.centinela: EstiloModulo(
    Color(0xFF3730A3),
    Icons.shield_rounded,
    Icons.notifications_active_rounded,
    'Tus reportes cuidan a otras personas',
  ),
  Insignias.rutaCompleta: EstiloModulo(
    Color(0xFF8A5A00),
    Icons.emoji_events_rounded,
    Icons.workspace_premium_rounded,
    'Terminaste toda tu ruta',
  ),
};

EstiloModulo estiloInsignia(Insignia insignia) => insignia.esDeModulo
    ? estiloModulo(insignia.modulo!)
    : _estilosLogro[insignia.id] ?? estiloModulo('');

/// Medalla de una insignia: a color si se ganó, en gris si falta ganarla.
class InsigniaVista extends StatelessWidget {
  const InsigniaVista({
    super.key,
    required this.insignia,
    this.tam = 64,
    this.animada = false,
  });
  final Insignia insignia;
  final double tam;
  final bool animada;

  @override
  Widget build(BuildContext context) => IlustracionModulo(
    codigo: insignia.modulo ?? '',
    estilo: estiloInsignia(insignia),
    tam: tam,
    animada: animada,
    apagada: !insignia.ganada,
  );
}

/// Portada de una lección: franja con el color del módulo, la insignia grande y su lema.
class PortadaModulo extends StatelessWidget {
  const PortadaModulo({super.key, required this.codigo, required this.nombre});
  final String codigo, nombre;

  @override
  Widget build(BuildContext context) {
    final e = estiloModulo(codigo);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [e.color, Color.lerp(e.color, Colors.black, 0.25)!],
        ),
      ),
      child: Row(
        children: [
          IlustracionModulo(codigo: codigo, tam: 84, animada: true),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  e.lema,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
