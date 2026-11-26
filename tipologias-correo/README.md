# Tipologías de correo IESS y Sello IESS

Versión 1.0 · 26 de noviembre de 2026 · Insumo del frente de tipologías para el resto del equipo.

Este directorio entrega dos cosas:

1. **Las 6 tipologías** de correo oficial del IESS.
2. **El Sello IESS**, el distintivo de legitimidad que complementa a los indicios de phishing.

Los indicios I1 a I11 responden "¿qué tiene de sospechoso este correo?". El sello responde la pregunta contraria: "¿cómo sé que este correo sí es del IESS?".

| Archivo | Contenido |
| --- | --- |
| `tipologias.json` | Las tipologías y el sello en formato de datos, para el proxy SMTP, el modelo de IA, la app y capacitación |
| `README.md` | Este documento: explica cada tipología, el sello y las decisiones tomadas |

## 1. Las 6 tipologías

Todo correo oficial pertenece a una sola tipología, que el funcionario elige al enviarlo. Las tipologías salen de los correos legítimos del dataset y de los correos de práctica.

| Tipo | Nombre | Para qué sirve | Ejemplo real | Siempre trae | Nunca trae |
| --- | --- | --- | --- | --- | --- |
| T1 | Informativo y eventos | Boletines, horarios, mantenimientos, charlas, encuestas | "Nuevo horario de atención en agencias" | Asunto "IESS Informa"; enlaces solo a iess.gob.ec, zoom o teams | Pedidos de datos, claves o pagos; adjuntos |
| T2 | Financiero y previsional | Aportes, planillas, pensiones, prestaciones y devoluciones ya procesadas | "Planilla de aportes de enero disponible" (práctica P02) | Monto y período exactos; referencia `IESS-AAAA-NNNNN` consultable en la app | Enlaces para "cobrar"; pedido de cuenta bancaria o tarjeta; valores no solicitados |
| T3 | Trámites y certificados | Avance o cierre de solicitudes que la persona inició | "Su solicitud N.° SOL-2025-78062 fue registrada" | Número de trámite que la persona reconoce; estado del trámite | Amenazas legales, multas o plazos de horas |
| T4 | Salud: turnos y citas | Confirmar, recordar o reprogramar citas médicas | "Su turno en línea fue registrado" | Especialidad, fecha, hora y unidad médica | Códigos QR; pedido de cédula o pagos |
| T5 | Seguridad de cuenta | Confirmar cambios que la persona hizo y alertas preventivas | "Cambio de clave registrado" | Fecha y canal del cambio | Enlaces para escribir la clave; amenazas de bloqueo |
| T6 | Interno para colaboradores | Reuniones, memorandos, circulares e informes entre áreas | "Convocatoria a reunión de coordinación" | Remitente con nombre de persona @iess.gob.ec; firma con cargo y extensión | Pedido de clave institucional; adjuntos .zip o con macros |

Un séptimo grupo, **EXT**, agrupa los correos legítimos que no son del IESS (SRI, Registro Civil, Microsoft, Google, Zoom), como el aviso de Microsoft del correo de práctica P04. No llevan Sello IESS y se evalúan solo con los indicios.

Decisiones detrás de esta tabla:

- **T3 y T4 se separaron.** El documento original unía trámites y salud. El phishing con QR ataca sobre todo los turnos médicos (práctica P05), y conviene que T4 tenga reglas propias.
- **Se agregaron T5 y T6.** T5 es lo que más se imita para robar claves. T6 existe porque el reto incluye a los colaboradores.
- **Ninguna tipología permite indicios.** El Catálogo define que un correo legítimo tiene los 11 indicios en 0. Lo que cambia entre tipologías es qué contiene, qué enlaces y adjuntos puede llevar, y con qué indicios se la suplanta más (`suplantacion_frecuente` en el JSON).

## 2. El Sello IESS

**Principio: el correo no lleva datos personales. El sello visual solo aparece dentro de la app oficial, después de verificar.**

### En el correo

El correo solo lleva un elemento que conecta con la app, sin datos de la persona:

- **Código de verificación** `IESS-XXXX-XXXX`, forma corta del Hash 2 que genera el proxy SMTP.
- **Botón "Verificar en App".**
- **Texto fijo:** "Abra usted mismo la app IESS para verificar este correo. El IESS nunca le pedirá claves, pagos ni datos por correo."

El código existe para quien no puede usar el botón: se puede escribir en la app, dictar por teléfono o enviar al WhatsApp oficial (+593 9 62532338).

### En la app, después de verificar

La app muestra un sello visual con uno de tres estados:

| Estado | Color | Qué muestra | Mensaje |
| --- | --- | --- | --- |
| Verificado | Verde | Tipología, área emisora, asunto oficial, fecha de envío y la imagen de seguridad de la persona | "Compare el asunto y la fecha con el correo que está leyendo. Si no coinciden, no es este correo." |
| No válido | Rojo | Motivo: código inexistente, revocado o contenido que no coincide | "No abra enlaces ni adjuntos. Reporte a seguridad.informacion@iess.gob.ec." |
| Sin sello | Gris | Aviso de que el correo no trae Sello IESS | "Si dice ser del IESS, es sospechoso. Se revisan los indicios I1 a I11." |

### Qué ataque frena cada parte

| Parte del sello | Qué frena | Límite |
| --- | --- | --- |
| Código en el correo | Un código inventado no existe en el servidor | Se puede copiar de un correo real a uno falso |
| Asunto y fecha en el sello verde | La copia: si el código vino de otro correo, el asunto y la fecha no coinciden con lo que la persona lee | La persona tiene que comparar |
| Imagen de seguridad de la persona | Una página o app falsa que imite el sello verde no conoce la imagen elegida | Es opcional y la persona debe configurarla |
| Regla de coherencia con la tipología | Una cuenta oficial comprometida: un sello válido en un correo que contradice su tipo (un T4 que pide pago) se trata como phishing | Depende de que el proxy registre la tipología al enviar |

### Por qué se cambió la propuesta anterior

- **Se quitaron el nombre y los dígitos de la cédula del correo.** Ponerlos en cada correo expone datos personales y va contra la minimización de la LOPDP. Además aportan poco, porque circulan millones de imágenes de cédulas ecuatorianas.
- **El sello visual vive en la app, no en el correo.** Una imagen dentro del correo se copia con facilidad. Dentro de la app, el sello se genera con datos del servidor.
- **El correo conserva un código sin datos personales.** Sin algo en el correo, la app no tiene cómo saber qué correo verificar.
- **La imagen de seguridad reemplaza al dato personal.** Cumple la misma función, probar que quien muestra el sello es el IESS, sin viajar por correo.
- **Código y no QR.** El indicio I11 del Catálogo enseña a desconfiar de los QR en correos, y un QR no se escanea desde el mismo celular donde se lee el correo.

## 3. Cómo se decide si un correo es legítimo

El sello se revisa antes que los indicios. Los indicios siguen siendo necesarios para los correos sin sello.

| Situación | Resultado |
| --- | --- |
| Sello verificado, asunto y fecha coinciden, y el contenido respeta su tipología | Legítimo |
| Código inexistente, revocado, o asunto y fecha que no coinciden | Phishing |
| Sello verificado pero el correo contradice su tipología | Phishing (cuenta comprometida) |
| Dice ser del IESS pero no trae sello | Sospechoso: se revisan los indicios I1 a I11 |
| No dice ser del IESS (SRI, Microsoft, Zoom) | Se decide solo con los indicios I1 a I11 |

Mensaje para capacitar, en una línea: **"Todo correo del IESS trae un código de verificación. Verifíquelo abriendo usted mismo la app: si ve su imagen de seguridad y el sello verde, es oficial."**

## 4. Qué necesita cada frente

- **Proxy SMTP:** registrar la tipología elegida junto con el Hash 2, y generar el código corto `IESS-XXXX-XXXX`. Usar `dominios_enlace_permitidos` y `adjuntos_permitidos` de cada tipología en la Fase 2.
- **API de verificación:** `GET /verificar/{codigo}` debe devolver tipología, área, asunto, fecha y estado, no solo válido o inválido.
- **App:** mostrar los tres estados del sello y permitir elegir la imagen de seguridad.
- **Modelo de IA:** usar la tipología como contexto para explicar ("dice ser T2 pero pide una transferencia").
- **Capacitación:** usar `nunca_trae` y `capsula` de cada tipología como contenido.
