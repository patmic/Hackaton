import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:capacitacion/src/application/providers.dart' as cap;
import 'package:capacitacion/src/data/actividad_repository.dart';
import 'package:capacitacion/src/presentation/rutas.dart' as cap_rutas;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/canales.dart';
import 'features/llm/cerebro.dart';
import 'ui/alerta_app.dart';
import 'ui/bienvenida_page.dart';
import 'ui/inicio_page.dart';
import 'ui/tema.dart';
import 'ui/web_escritorio.dart';

Future<void> _preparar() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Canales.cargar();
  unawaited(Cerebro.i.iniciar()); // si hay un modelo descargado lo carga en segundo plano
}

/// App principal.
Future<void> main() async {
  await _preparar();
  // Siempre vertical: más simple para personas mayores y el cóndor no se descuadra.
  if (!kIsWeb) await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  // Web: el árbol de accesibilidad siempre activo, para que los lectores de pantalla (NVDA, VoiceOver) lean la página.
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
  final yaConfigurado = (await SharedPreferences.getInstance()).getBool('bienvenida') ?? false;
  runApp(ProviderScope(
    // El aula virtual lee su catálogo desde el paquete del módulo de capacitación.
    overrides: [
      cap.actividadRepositoryProvider.overrideWithValue(
          AssetActividadRepository(ruta: 'packages/capacitacion/assets/data/actividades.json')),
    ],
    child: MaterialApp(
    // App Link del correo firmado ("Verificar en App") -> pantalla de verificación del módulo de capacitación.
    onGenerateRoute: cap_rutas.generarRuta,
    title: 'AIESS',
    debugShowCheckedModeBanner: false,
    theme: temaAIess(),
    // En web no hay permisos de Android que configurar: se entra directo.
    // Web angosta (celular en el navegador): la pantalla de la app, centrada sobre el azul.
    builder: (context, child) => kIsWeb && !WebEscritorio.cabe(context, MediaQuery.sizeOf(context).width)
        ? ColoredBox(
            color: const Color(0xFF0A1B3A),
            child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: child)),
          )
        : child!,
    // Web en computadora: diseño propio de dos columnas.
    home: kIsWeb
        ? LayoutBuilder(builder: (context, c) => WebEscritorio.cabe(context, c.maxWidth) ? const WebEscritorio() : const InicioPage())
        : (yaConfigurado ? const InicioPage() : const BienvenidaPage()),
  )));
}

/// Pop-up tipo Truecaller (lo abre AlertaActivity desde el lector de notificaciones).
@pragma('vm:entry-point')
Future<void> alertaMain() async {
  await _preparar();
  runApp(const AlertaApp());
}
