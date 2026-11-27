// Preferencias de lectura (accesibilidad): tamaño de letra y «lectura fácil» para personas con dislexia
// o baja visión. Se guardan en el equipo y se aplican a TODA la app (web y celular).
//
// - Tamaño: multiplica el tamaño que ya pide el sistema (nunca lo achica por debajo de él). En la web, con
//   letra grande la pantalla pasa sola al diseño de una columna (reflujo, ver WebEscritorio.cabe).
// - Lectura fácil: más espacio entre letras, palabras y líneas (lo que más ayuda a leer con dislexia),
//   con la tipografía Atkinson Hyperlegible que ya usa AIESS (letras que no se confunden: b/d, I/l/1).
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Lectura extends ChangeNotifier {
  Lectura._();
  static final i = Lectura._();

  static const pasos = [1.0, 1.15, 1.3, 1.5];
  int _paso = 0;
  bool _facil = false;

  double get escala => pasos[_paso];
  bool get facil => _facil;
  bool get puedeAgrandar => _paso < pasos.length - 1;
  bool get puedeAchicar => _paso > 0;

  Future<void> cargar() async {
    final p = await SharedPreferences.getInstance();
    _paso = (p.getInt('lectura_paso') ?? 0).clamp(0, pasos.length - 1);
    _facil = p.getBool('lectura_facil') ?? false;
    notifyListeners();
  }

  Future<void> _guardar() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('lectura_paso', _paso);
    await p.setBool('lectura_facil', _facil);
  }

  void agrandar() => _cambiar(_paso + 1);
  void achicar() => _cambiar(_paso - 1);

  void _cambiar(int n) {
    final nuevo = n.clamp(0, pasos.length - 1);
    if (nuevo == _paso) return;
    _paso = nuevo;
    notifyListeners();
    _guardar();
  }

  void alternarFacil() {
    _facil = !_facil;
    notifyListeners();
    _guardar();
  }

  /// Tema con lectura fácil: los textos que no fijan su propio espaciado lo heredan de aquí.
  ThemeData tema(ThemeData base) {
    if (!_facil) return base;
    TextStyle? f(TextStyle? s) => s?.copyWith(
      letterSpacing: (s.letterSpacing ?? 0) < 0.6 ? 0.6 : s.letterSpacing,
      wordSpacing: 3,
      height: (s.height ?? 1.4) < 1.6 ? 1.6 : s.height,
    );
    final t = base.textTheme;
    return base.copyWith(
      textTheme: TextTheme(
        displayLarge: f(t.displayLarge),
        displayMedium: f(t.displayMedium),
        displaySmall: f(t.displaySmall),
        headlineLarge: f(t.headlineLarge),
        headlineMedium: f(t.headlineMedium),
        headlineSmall: f(t.headlineSmall),
        titleLarge: f(t.titleLarge),
        titleMedium: f(t.titleMedium),
        titleSmall: f(t.titleSmall),
        bodyLarge: f(t.bodyLarge),
        bodyMedium: f(t.bodyMedium),
        bodySmall: f(t.bodySmall),
        labelLarge: f(t.labelLarge),
        labelMedium: f(t.labelMedium),
        labelSmall: f(t.labelSmall),
      ),
    );
  }

  /// Aplica el tamaño elegido sobre el que pide el sistema.
  Widget escalar(BuildContext context, Widget child) {
    if (_paso == 0) return child;
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(mq.textScaler.scale(1) * escala),
      ),
      child: child,
    );
  }
}

/// Controles «letra más pequeña / más grande / Lectura fácil». [claro] = sobre fondo oscuro (panel izquierdo de la web).
class ControlesLectura extends StatelessWidget {
  const ControlesLectura({super.key, this.claro = false});
  final bool claro;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Lectura.i,
    builder: (context, _) {
      final l = Lectura.i;
      final color = claro ? Colors.white : const Color(0xFF14323A);
      final borde = claro ? Colors.white54 : const Color(0xFF9DB4B9);
      final estilo = OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: borde, width: 1.5),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: const StadiumBorder(),
      );
      return Semantics(
        container: true,
        label: 'Opciones de lectura',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Tooltip(
              message: 'Letra más pequeña',
              child: OutlinedButton(
                style: estilo,
                onPressed: l.puedeAchicar ? l.achicar : null,
                child: Semantics(
                  label: 'Letra más pequeña',
                  excludeSemantics: true,
                  child: const Icon(Icons.text_decrease_rounded, size: 24),
                ),
              ),
            ),
            Tooltip(
              message: 'Letra más grande',
              child: OutlinedButton(
                style: estilo,
                onPressed: l.puedeAgrandar ? l.agrandar : null,
                child: Semantics(
                  label:
                      'Letra más grande. Tamaño actual ${(l.escala * 100).round()} por ciento',
                  excludeSemantics: true,
                  child: const Icon(Icons.text_increase_rounded, size: 26),
                ),
              ),
            ),
            Semantics(
              toggled: l.facil,
              child: OutlinedButton.icon(
                style: estilo.copyWith(
                  backgroundColor: WidgetStatePropertyAll(
                    l.facil
                        ? (claro ? Colors.white : const Color(0xFF145962))
                        : Colors.transparent,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    l.facil
                        ? (claro ? const Color(0xFF14323A) : Colors.white)
                        : color,
                  ),
                ),
                onPressed: l.alternarFacil,
                icon: Icon(
                  l.facil
                      ? Icons.check_circle_rounded
                      : Icons.text_fields_rounded,
                  size: 20,
                ),
                label: const Text('Lectura fácil'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
