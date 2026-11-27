// Genera los íconos de la app (web y Android) dibujando el robot guardián con el mismo widget de la app.
// Uso:  flutter test tool/generar_iconos_test.dart   (deja build/iconos/robot_1024.png)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aiess/features/mascota/robot_guardia.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('icono del robot', (t) async {
    t.view.physicalSize = const Size(1024, 1024);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final clave = GlobalKey();
    await t.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1024, 1024), disableAnimations: true),
        child: Center(
          child: RepaintBoundary(
            key: clave,
            child: const SizedBox(width: 1024, height: 1024, child: RobotGuardia(estado: EstadoRobot.reposo, tam: 1024, forma: Forma.plena)),
          ),
        ),
      ),
    ));
    await t.pump(const Duration(milliseconds: 500));
    await t.runAsync(() async {
      final caja = clave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await caja.toImage(pixelRatio: 1);
      final datos = await img.toByteData(format: ui.ImageByteFormat.png);
      Directory('build/iconos').createSync(recursive: true);
      File('build/iconos/robot_1024.png').writeAsBytesSync(datos!.buffer.asUint8List());
    });
  });
}
