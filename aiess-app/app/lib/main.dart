import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/canales.dart';
import 'features/llm/cerebro.dart';
import 'ui/alerta_app.dart';
import 'ui/bienvenida_page.dart';
import 'ui/inicio_page.dart';
import 'ui/tema.dart';

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
  final yaConfigurado = (await SharedPreferences.getInstance()).getBool('bienvenida') ?? false;
  runApp(MaterialApp(
    title: 'AIESS',
    debugShowCheckedModeBanner: false,
    theme: temaAIess(),
    // En web no hay permisos de Android que configurar: se entra directo.
    home: (yaConfigurado || kIsWeb) ? const InicioPage() : const BienvenidaPage(),
  ));
}

/// Pop-up tipo Truecaller (lo abre AlertaActivity desde el lector de notificaciones).
@pragma('vm:entry-point')
Future<void> alertaMain() async {
  await _preparar();
  runApp(const AlertaApp());
}
