# Patrones del dataset IESS

Filas válidas: 1000 | balance: {'phishing': 500, 'legitimo': 500} | avisos de limpieza: 0 | split: {'train': 800, 'val': 100, 'test': 100}

## Indicios
- I1 Urgencia artificial: 252
- I2 Enlace a dominio no oficial: 430
- I3 Pide credenciales, claves, códigos o tarjeta: 159
- I4 Enlace acortado u oculto: 106
- I5 Adjunto o instalación sospechosa: 62
- I6 Premio, bono o reembolso inesperado: 117
- I7 Remitente no oficial: 440
- I8 Amenaza o pérdida de beneficio: 198
- I9 Pide datos personales o documentos: 176
- I10 Pide pago o transferencia: 123
- I11 Código QR hacia sitio no verificable: 28

## Co-ocurrencias más frecuentes
I2+I7 (372), I1+I7 (223), I1+I2 (211), I7+I8 (176), I2+I8 (167), I2+I9 (156), I7+I9 (156), I2+I3 (143), I3+I7 (138), I1+I8 (124), I7+I10 (113), I2+I4 (106)

## N-gramas distintivos de phishing (z log-odds)
- enlace (z=8.86, 314/51)
- siguiente (z=6.9, 157/16)
- datos (z=6.82, 181/28)
- proceso (z=6.18, 120/8)
- verificacion (z=5.96, 112/8)
- ingrese (z=5.45, 174/0)
- identidad (z=5.42, 137/27)
- usd (z=5.4, 171/0)
- continuar (z=5.28, 114/19)
- cedula (z=5.0, 124/26)
- debe (z=4.71, 130/0)
- horas (z=4.62, 125/0)
- confirme (z=4.62, 125/0)
- pago (z=4.21, 82/16)
- aqui (z=4.11, 99/0)
- notificacion (z=4.02, 66/11)
- codigo (z=4.0, 94/0)
- numero (z=3.98, 93/0)
- mantener (z=3.71, 53/8)
- sera (z=3.62, 94/26)

## N-gramas por indicio
- I1: enlace; proceso; datos; siguiente; horas; identidad; verificacion; usd
- I2: enlace; datos; siguiente; proceso; verificacion; identidad; continuar; ingrese
- I3: enlace; datos; identidad; verificacion; proceso; siguiente; mantener; continuar
- I4: enlace; siguiente; datos; identidad; verificacion; continuar; proceso; como
- I5: archivo; documento; adjunto; detalle; proceso; importante; enlace; caso
- I6: datos; devolucion; pago; enlace; siguiente; usd; verificacion; identidad
- I7: enlace; siguiente; datos; proceso; verificacion; continuar; usd; ingrese
- I8: enlace; proceso; sera; notificacion; caso; siguiente; verificacion; acceso
- I9: cedula; datos; enlace; fecha; identidad; verificacion; siguiente; proceso
- I10: enlace; continuar; cancelar; proceso; verificacion; siguiente; datos; usd
- I11: adjunta; acudir; ninguna; proceso; imagen; png; confirmado; turno medico

## Asuntos típicos de phishing
afiliado; devolucion; medico; reembolso; importante; pendiente; datos; notificacion; fwd; verificacion; documento; confirme; afiliacion; proceso; suspension

## Botones (CTA) en phishing
Solicitar el reembolso (25), Continuar (18), Descargar documento (17), Privacidad (15), Confirmar datos (15), Verificar mi cuenta (15), HAGA CLIC AQUÍ (14), Términos (11), Ayuda (11), Iniciar verificación (11), Actualizar ahora (10), Ver detalle (10), Acceder al documento (8), Reclamar ahora (7)

## Dominios de phishing
storage.googleapis.com (9), shorturl.at (8), bit.ly (7), rebrand.ly (6), fiscalia-notificacion.invalid (5), t.ly (5), afiliado-iess.example (5), www.correo-institucional-verificacion.example (5), iess-tramites.invalid (5), cshort.jp (5), unidad-judicial-virtual.invalid (5), mi-iess.invalid (5), promos-beneficios.invalid (5), portal-iess.example (5), citaciones-judiciales.example (4), sri-notificaciones.example (4), is.gd (4), verificacion-segura.invalid (4), cutt.ly (4), www.consulta-multas-ant.invalid (4), sri-devoluciones.test (4), tinyurl.com (4), www.afiliado-iess.test (4), www.microsoft-cuentas-seguridad.example (4), www.webmail-actualizacion.example (4)

TLDs: [('invalid', 97), ('example', 89), ('com', 76), ('test', 63), ('top', 41), ('xyz', 38), ('site', 30), ('info', 23), ('ly', 22), ('net', 20), ('online', 20), ('io', 9), ('at', 8), ('jp', 5), ('gd', 4)]
Acortadores: ['bit.ly', 'cshort.jp', 'cutt.ly', 'is.gd', 'rebrand.ly', 'shorturl.at', 't.ly', 'tinyurl.com']
Dominios en ambas clases: []
Legítimos fuera de la lista oficial: []
Texto visible ≠ enlace real (phishing): 63

## Adjuntos
{'phishing': [('png', 28), ('pdf', 26), ('zip', 19), ('docm', 11), ('exe', 7), ('html', 7), ('iso', 7), ('xlsm', 2)], 'legitimo': [('pdf', 37), ('xlsx', 6), ('docx', 4), ('jpg', 2), ('pptx', 1), ('png', 1)]}

Saltos (hops) medios: {'phishing': 4.92, 'legitimo': 3.78}

## Léxico de evidencia (recall en Ik=1 / FP en legítimos)
- I1: recall 0.813, FP 0.03
- I3: recall 0.994, FP 0.072
- I5: recall 0.935, FP 0.0
- I6: recall 1.0, FP 0.034
- I8: recall 0.732, FP 0.012
- I9: recall 1.0, FP 0.064
- I10: recall 0.691, FP 0.062
- I11: recall 1.0, FP 0.0

## Reglas OSINT vs etiquetas
{"I2": {"tp": 430, "fp": 0, "fn": 0, "tn": 570, "precision": 1.0, "recall": 1.0}, "I4": {"tp": 106, "fp": 9, "fn": 0, "tn": 885, "precision": 0.922, "recall": 1.0}}
URLs de phishing marcadas (>=30): 0.996 | falsas alarmas en URLs legítimas: 0.0
