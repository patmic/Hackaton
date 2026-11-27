# CLAUDE.md · Escudo Cognitivo IESS (plataforma AIESS)

Contexto completo del producto para Claude Code. Hackatón **Código Confianza IESS 2026**, **Reto 1: «Seguridad inteligente, cultura consciente»**.
Producto: plataforma **web y móvil en Flutter** para concientizar sobre phishing a afiliados, jubilados y colaboradores del IESS (Ecuador), con backend **FastAPI**.

> Estado de cada decisión: **[DECIDIDO]** lo confirmó el equipo · **[PROPUESTO]** recomendación pendiente de aprobar · **[PENDIENTE]** sin resolver.
> Ante una contradicción entre secciones, manda lo marcado **[DECIDIDO]**. Si algo no está claro, pregunta antes de inventar.

---

## 1. Reglas para trabajar en este repo

1. **Idioma: español** en código visible al usuario, textos, comentarios de dominio y documentación. Los identificadores pueden ir en español sin tildes (`tipo_usuario`, `perfil_conducta`).
2. **Datos siempre ficticios.** Correos, dominios, personas y montos de demo son inventados. Los únicos datos reales son los canales oficiales de la sección 6, y hay que verificar su vigencia antes de publicarlos.
3. **LOPDP (Ecuador) por diseño.** Nunca se guardan cédula, nombre ni correo en claro en tablas de métricas. Se usa `id_seudonimo` (HMAC con clave del servidor). Los datos seudonimizados siguen siendo datos personales.
4. **Ninguna simulación pide ni guarda claves, datos personales o pagos reales.** Las páginas de destino de los correos de prueba no tienen formularios.
5. **Los correos de prueba nunca salen de `iess.gob.ec`.** Se envían desde un dominio de práctica propio, porque usar el dominio oficial contradice la lección de los indicios I2 e I7.
6. **Observatorio con umbral k = 10.** Ninguna métrica se muestra para un grupo de menos de 10 personas.
7. **Sin culpa.** Los textos de retroalimentación nunca avergüenzan. «Expuesto» no se muestra al usuario; se muestra como «en aprendizaje».
8. Toda cifra que se cite en documentos lleva año y fuente, o se marca «sin verificar».
9. No romper los contratos de API de la sección 12 sin avisar a los tres bloques.

## 2. Mapa del repo

| Ruta | Contenido |
| --- | --- |
| `readme.md` | Descripción general del repo |
| `recursos/` | Escenarios base y herramientas reutilizables |
| `recursos/Boilerplate/` | Plantillas base (por ejemplo `ThemeLight`, con tokens de color y `motion 14.14.0`) |
| `obsidian/` | Bóveda de investigación del reto. Tiene su **propio `CLAUDE.md`** con sus reglas; respétalas al trabajar ahí |
| `package.json` | Dependencia `motion` usada por el boilerplate |

Estructura propuesta para el código del producto **[PROPUESTO]**:

```text
app/        # Flutter (web y móvil) · Bloque 2
backend/    # FastAPI · Bloques 1 y 3
  emision/        # Bloque 1: sellado y envío oficial
  nucleo/         # Bloque 3: white/black list, verificación, observatorio
  capacitacion/   # Flujo «Quiero capacitarme», correos de prueba, escalera
data/       # dataset sintético del reto y plantillas de correos de prueba
docs/       # este contexto ampliado, diagramas
```

## 3. Equipo y bloques

| Bloque | Módulo | Responsables | Entregable MVP |
| --- | --- | --- | --- |
| 1 | Emisión y sellado ligero | Patric, Dani | Simulador de correo saliente por tipología, generador de sello y QR, registro en el núcleo |
| 2 | Recepción, verificación y app | Isaac, Sergio | App Flutter: bandeja, verificador, reportes, capacitación, flujo «Quiero capacitarme» |
| 3 | Núcleo central y observatorio | Luis, Jhair | API central (white/black list), base de datos, observatorio y cálculo de perfiles |

## 4. Problema y tesis

- El IESS sufre campañas constantes de phishing y smishing (falsos reembolsos, suplantación de trámites, engaños financieros) contra unos 3,6 M afiliados activos (sep. 2026) y unos 840.000 jubilados y pensionistas (proyección 2026). Las alertas genéricas llegan tarde.
- No se envían correos a una IA para analizarlos: colapsaría la infraestructura y violaría la minimización de la LOPDP.
- **Tres pilares:**
  1. **Tipologías** de comunicación oficial (T1, T2, T3).
  2. **Sellado criptográfico ligero:** solo hashes o firmas, nunca el cuerpo del correo.
  3. **Observatorio de seguridad cognitiva:** cada verificación o reporte se convierte en inteligencia por segmento para hipersegmentar la concientización.

### Tipologías oficiales

Fuente vigente: `tipologias-correo/tipologias.json` v1.0 (2026-11-26), que reemplaza a las tres tipologías del documento original (T3 y T4 se separaron; se agregaron T5 y T6). La app la lee de `Capacitacion/assets/data/tipologias.json`, una copia que una prueba compara con el original.

| Código | Nombre | Para qué sirve | Nunca trae |
| --- | --- | --- | --- |
| T1 | Informativo y eventos | Boletines, horarios, mantenimientos, charlas, encuestas | Pedidos de datos, claves o pagos; adjuntos |
| T2 | Financiero y previsional | Aportes, planillas, pensiones, prestaciones, devoluciones ya procesadas | Enlaces para «cobrar»; pedido de cuenta o tarjeta; valores no solicitados |
| T3 | Trámites y certificados | Avance o cierre de solicitudes que la persona inició | Amenazas legales o multas; plazos de horas |
| T4 | Salud: turnos y citas | Confirmar, recordar o reprogramar citas | Códigos QR; pedido de cédula o pagos |
| T5 | Seguridad de cuenta | Confirmar cambios que la persona hizo y alertas preventivas | Enlaces para escribir la clave; amenazas de bloqueo |
| T6 | Interno para colaboradores | Reuniones, memorandos, circulares, informes | Pedido de clave institucional; adjuntos .zip o con macros |

`EXT` agrupa los correos legítimos ajenos al IESS (SRI, Microsoft, Zoom): no llevan Sello IESS y no son una tipología. El bloque 1 (`SellaLogo/app.js`) todavía usa T1-T3.

## 5. Arquitectura del sellado y la verificación

### 5.1 Lo que hay hoy (dos versiones que no coinciden) [PENDIENTE de unificar]

| Tema | Documento del equipo | Diagrama del equipo |
| --- | --- | --- |
| Sello | Un `HMAC_SHA256(emisor_id|tipologia|timestamp|sha256(asunto+cuerpo), SECRET)` | Hash 1 (envío + timestamp) y Hash 2 (remitente + salt) |
| QR | Payload de texto, escaneado **dentro** del canal oficial | Deep link con Hash 1 |
| Verificación | `POST /api/v1/verify` | `GET /verificar/{hash}` |
| Respuesta | `estado`, `semaforo`, `motivo`, `metadatos_oficiales`, `capsula_educativa` | `valido: true/false` |
| Reporte sin QR (camino B) | Sí, alimenta la black list | No aparece |
| Observatorio | Sí | No aparece |

Flujo del diagrama: Funcionario → `POST /enviar-correo` → backend FastAPI (genera hashes, crea QR, lo incrusta como CID) → BD (SQLite/PostgreSQL) → SMTP → ciudadano → escanea el QR → bot validador (Telegram/WhatsApp/Web) → `GET /verificar/{hash}` → «Correo válido» o «Alerta: posible phishing».

### 5.2 Mejoras recomendadas [PROPUESTO]

1. **Sello firmado Ed25519 ligado al destinatario**, en lugar de Hash 1 y Hash 2:
   `payload = {emisor, tipologia, asunto_corto, fecha, exp, rcpt: HMAC(email)[:8], jti}` + firma con la clave privada del IESS. La app verifica la firma sin conexión con la clave pública fijada; el servidor solo se consulta para revocación y para comparar `rcpt`. Si `rcpt` no coincide: «Sello auténtico, pero emitido para otra persona: es ESTAFA» (cierra el ataque de copiar y pegar un QR válido).
2. **Bandeja espejo** en la app: todo correo oficial aparece también en «Mis comunicaciones IESS». Verificar = «¿está en mi bandeja oficial?».
3. **Código corto + «Compartir a la app»** para quien lee el correo en el mismo celular y no puede escanear su propia pantalla.
4. **Código antiphishing personal:** palabra que el usuario define y que aparece en todo correo oficial.
5. **Nunca deep links abiertos en el QR.**
6. Capa institucional fuera del MVP: DMARC en `reject` y BIMI con Government Mark Certificate.

### 5.3 Fallos críticos que el diseño debe resistir (auditoría del décimo hombre)

| # | Fallo | Mitigación |
| --- | --- | --- |
| 1 | QR falso (quishing) | El QR no abre URLs; se escanea dentro del canal oficial |
| 2 | Reutilización del sello (replay) | Mostrar metadatos sellados; ligar el sello al destinatario (`rcpt`) |
| 3 | Rango de edad sin violar la LOPDP | Edad por rangos desde la sesión, o pregunta opcional de un clic |
| 4 | Emisor interno comprometido | Permisos por tipología y revocación por lote (`revocado = true`) |
| 5 | Usuario en pánico que no verifica | Radar comunitario: el 1% que reporta dispara alertas para el resto |
| 6 | Infraestructura heredada (AS-400) | Sellado desacoplado y no bloqueante, en modo *fail-open* |

## 6. Catálogo de indicios y canales oficiales (fuente: material del reto) [DECIDIDO]

Un correo es phishing si tiene **al menos un indicio**. El dataset `dataset_entrenamiento_IESS_1000.csv` (1.000 filas, 23 columnas, separador `;`, todo sintético) trae cada indicio como columna 0/1 y la columna `Phishing` (Sí/No).

| Código | Indicio | Qué se revisa |
| --- | --- | --- |
| I1 | Urgencia artificial | Plazos muy cortos, presión para actuar ya |
| I2 | Enlace a dominio no oficial | El enlace lleva a un sitio que no es del IESS ni de una entidad conocida |
| I3 | Pide credenciales, claves, códigos o tarjeta | Usuario, contraseña, clave, código de verificación, tarjeta |
| I4 | Enlace acortado u oculto | Acortadores, o texto que muestra una dirección y lleva a otra |
| I5 | Adjunto o instalación sospechosa | .zip, .exe, .apk, .html, macros, «instale la aplicación» |
| I6 | Premio, bono o reembolso inesperado | Dinero o beneficios no solicitados |
| I7 | Remitente no oficial | Correo gratuito, dominio parecido, responder-a distinto |
| I8 | Amenaza o pérdida de beneficio | Suspensión, bloqueo, multa, embargo, pérdida de pensión |
| I9 | Pide datos personales o documentos | Cédula, fecha de nacimiento, foto del documento, selfie |
| I10 | Pide pago o transferencia | Depósito, tasa, multa, criptomonedas |
| I11 | Código QR hacia sitio no verificable | Pide escanear un QR cuyo destino no se comprueba |

Campos del dataset: `id`, `subject`, `body` (botones entre corchetes), `date` (dd/mm/aaaa), `url_count`, `urls`, `attachments_count`, `attachments_types`, `attachments_total_size`, `attachments_sizes`, `hops_count` (1 a 8), `Phishing`, `I1`…`I11`. El remitente no es columna (lo refleja I7).

Canales oficiales (verificar vigencia antes de difundir):

| Canal | Dato |
| --- | --- |
| Portal institucional | www.iess.gob.ec |
| Aplicaciones del afiliado | app.iess.gob.ec |
| Denuncias | denuncias.iess.gob.ec · gestiondenuncias@iess.gob.ec |
| WhatsApp institucional | +593 9 62532338 |
| Atención al usuario | atencionalusuario@iess.gob.ec · 593 2 3945666 |
| Seguridad de la información (reportes) | seguridad.informacion@iess.gob.ec |
| Portal de trámites | www.gob.ec/iess |

También se consideran oficiales las entidades públicas y servicios conocidos (SRI, Registro Civil, gob.ec, Microsoft, Google, Zoom).

## 7. Tipos de usuario [DECIDIDO]

Dos capas separadas: el **tipo** (quién es, desde una fuente oficial, nunca autodeclarado) y el **perfil de conducta** (cómo responde, calculado con métricas). Una persona puede tener varios tipos (un colaborador casi siempre es también afiliado).

| Código | Tipo | Zona | Fuente de verdad | Ataque típico |
| --- | --- | --- | --- | --- |
| EX1 | Afiliado activo | Externa | Padrón de afiliación | Falsos reembolsos, créditos BIESS (T2) |
| EX2 | Jubilado o pensionista | Externa | Padrón de pensiones | Bloqueo de pensión con urgencia (T2) |
| EX3 | Empleador | Externa | RUC registrado como empleador | Falsas glosas, multas, planillas (T2) |
| EX4 | Prestador externo de salud | Externa | Registro de prestadores | Falsos tramitadores de pagos (T2, T3) |
| EX5 | Ciudadano sin cuenta o familiar | Externa | Ninguna (anónimo) | Cualquiera; suele verificar por otra persona |
| IN1 | Colaborador general | Interna | Directorio @iess.gob.ec | Robo de credenciales, falso soporte de TI |
| IN2 | Colaborador emisor | Interna | Directorio + tabla `emisores` | Toma de cuenta para emitir desde dentro |
| IN3 | Analista de seguridad (CSI/OSI) | Interna | Directorio + rol asignado | Objetivo de alto valor |
| IN4 | Administrador de plataforma | Interna | Directorio + rol asignado | Objetivo de máximo valor |

- Marcas de riesgo que no son tipos: **alto privilegio** (unos 297 directivos, IN3, IN4) y **cuidador** (EX5 que verifica por otra persona).
- Identificación: sin sesión → EX5. Sesión institucional → zona interna (todos IN1; IN2-IN4 asignados por un IN4, con vencimiento y auditoría). Sesión ciudadana → se consulta el padrón y se asignan EX1-EX4; se guardan solo tipo, rango de edad y modalidad.
- Rangos de edad: `18-29`, `30-49`, `50-64`, `65+`.

### Perfiles de conducta (ventana de 90 días; umbrales de partida, se recalibran en el piloto)

| Perfil | Regla | Acción |
| --- | --- | --- |
| Centinela | Al menos 1 reporte confirmado y precisión ≥ 80% | Red de alerta temprana; mitad de frecuencia; acceso a M14 |
| Prudente | Verifica antes de actuar y precisión ≥ 60% | Ritmo base |
| Expuesto | Precisión < 60% o falló un simulacro (solo internos) | Doble frecuencia por 4 semanas, retroalimentación inmediata |
| Inactivo | Sin acciones en 90 días | Un mensaje de reactivación por otro canal |
| Sin perfil | Menos de 5 acciones en la ventana | No se clasifica |

**Precisión** = juicios correctos ÷ juicios (verificaciones y micro-retos).

## 8. Métricas y observatorio

### 8.1 Métricas base (12)

| Familia | Métrica | Cálculo |
| --- | --- | --- |
| Exposición | Tasa de alerta roja | Verificaciones ROJO ÷ verificaciones |
| Exposición | Tipología más suplantada | Reportes confirmados por T1/T2/T3 |
| Exposición | Campañas activas | Patrones nuevos en la black list por semana |
| Detección | Tasa de verificación | Correos verificados ÷ correos oficiales recibidos |
| Detección | Tasa de reporte | Reportes de phishing real ÷ usuarios activos |
| Detección | Tiempo hasta reportar | Mediana entre la primera detección de una campaña y cada reporte |
| Detección | Falsos positivos | Correos legítimos reportados ÷ reportes |
| Detección | Tasa de clic en simulacro | Clics ÷ simulacros (y correos de prueba aceptados) |
| Aprendizaje | Precisión en micro-retos | Aciertos ÷ intentos |
| Aprendizaje | Reincidencia | Expuestos dos ventanas seguidas ÷ Expuestos |
| Adopción | Usuarios activos | Al menos 1 acción en 30 días |
| Adopción | Protección activada | Usuarios con código antiphishing ÷ autenticados |

### 8.2 Métricas del observatorio (8)

| Nivel | Métrica | Cálculo |
| --- | --- | --- |
| Persona | Perfil de conducta | Reglas de la sección 7 |
| Persona | Racha de verificación | Semanas seguidas con al menos una verificación |
| Segmento | IRS (índice de resiliencia del segmento) | Promedio ponderado de precisión, reporte, verificación y (1 − falsos positivos), de 0 a 100; pesos iniciales de 25% cada uno |
| Segmento | Brecha de exposición | Tasa de alerta roja ÷ IRS |
| Campaña | Tiempo hasta detección | Horas entre el primer reporte de un patrón y su confirmación |
| Campaña | Cobertura de alerta | Personas alertadas del segmento ÷ tamaño del segmento, a 24 h |
| Capacitación | Conversión de cápsula | Verifican o reportan en los 14 días siguientes ÷ vieron la cápsula |
| Capacitación | Retención | Precisión a 30, 60 y 90 días comparada con el día 0 |

**Mapa de indicios por usuario [DECIDIDO]:** cada indicio I1-I11 queda como `DOMINADO` (reportó correos que lo tenían), `DEBIL` (hizo clic en un correo que lo tenía) o `SIN_PROBAR`. Alimenta la elección del siguiente correo de prueba y muestra en el observatorio qué indicio engaña más a cada segmento.

## 9. Hipersegmentación

```text
segmento = tipo × perfil × rango_etario × tipología_más_atacada × canal
           (9)    (4)      (4)            (3)                       (3: app, WhatsApp, correo)
```

Hay 1.296 combinaciones posibles; solo se activan las de 10 personas o más. La tipología más atacada la calcula el observatorio con los reportes de las últimas 4 semanas.

### Reglas de disparo (un IN3 aprueba todo disparo masivo)

| Regla | Condición | Acción |
| --- | --- | --- |
| R1 Campaña nueva | Patrón nuevo con 5 reportes confirmados en 24 h | Alerta a los segmentos de esa tipología, empezando por los de IRS más bajo |
| R2 Brecha de exposición | Brecha sube 40% o más frente a su promedio de 4 semanas | Ruta del segmento a intensidad Expuesto por 2 semanas |
| R3 Error individual | Falla un micro-reto, simulacro o correo de prueba | Retroalimentación inmediata en la misma pantalla |
| R4 Retención en caída | Precisión a 60 días cae más de 15 puntos frente al día 0 | Adelantar el siguiente refuerzo |
| R5 Inactividad | 90 días sin acción | Reactivación por otro canal |
| R6 Fecha de riesgo | Pago de pensiones, décimos, declaraciones | Recordatorio a EX2 o EX1 dos días antes |

## 10. Capacitación

### 10.1 Modelo 4R

Cada módulo recorre: **Reconocer** (señales) → **Reaccionar** (pausar y verificar en el canal oficial) → **Reportar** (un toque) → **Replicar** (enseñar a otro). Principios: practicar antes que leer, corregir en el momento, poco y seguido (1 a 5 min), aprender ayudando, sin culpa.

Evidencia que lo respalda: la capacitación anual muestra eficacia casi nula en evaluaciones aleatorizadas; la retroalimentación inmediata tras caer reduce la susceptibilidad; la eficacia de la capacitación embebida viene más del recordatorio periódico que del contenido; lo aprendido se olvida en 1 a 6 meses.

### 10.2 Módulos (14)

| Módulo | Nivel | Tipos | Min | Objetivo | Actividades |
| --- | --- | --- | --- | --- | --- |
| M1 Señales universales | 1 | Todos | 3 | Nombrar urgencia, pedido de claves o dinero, remitente raro, enlace o QR externo | A1, A2 |
| M2 Tu canal oficial | 1 | EX1-EX4, IN1 | 3 | Verificar en la bandeja espejo y con el sello | A6 |
| M3 Reportar en un toque | 1 | Todos | 2 | Reportar desde la app o reenviando | A3 |
| M4 Estafas financieras (T2) | 2 | EX1, EX2 | 4 | Reconocer reembolsos, bloqueos, créditos BIESS falsos | A4, A2 |
| M5 Trámites y salud (T3) | 2 | EX1, EX2, EX4 | 3 | Distinguir citas y certificados reales | A1, A3 |
| M6 Comunicados falsos y QR (T1) | 2 | EX1-EX5 | 3 | No abrir páginas desde un QR | A1, A6 |
| M7 Pensión segura | 3 | EX2 | 1 por pieza | Ante urgencia sobre la pensión, parar y verificar | A7, A5 |
| M8 Obligaciones patronales seguras | 3 | EX3 | 4 | Verificar glosas, multas, planillas | A3, A4 |
| M9 Pagos sin tramitadores | 3 | EX4 | 4 | Rechazar comisiones por gestionar pagos | A4, A3 |
| M10 Cuida a los tuyos | 3 | EX5 y Centinelas | 4 | Configurar el código antiphishing a un familiar | A5 |
| M11 Defiende tu cuenta institucional | 3 | IN1-IN4 | 5 | Reportar simulacros, proteger credenciales | A8, A3 |
| M12 Emisión segura | 3 | IN2 | 5 | Emitir solo su tipología | A3, A8 |
| M13 Respuesta a campañas | 3 | IN3, IN4 | 30 | Detectar, segmentar y alertar (ejercicio de mesa) | A9 |
| M14 Centinela: ataques avanzados | 4 | Centinelas | 5 | Suplantación con IA y por WhatsApp | A4, A5 |

### 10.3 Mecánicas interactivas (9 componentes Flutter reutilizables)

| Código | Mecánica | Cómo funciona |
| --- | --- | --- |
| A1 | Caza la señal | Mensaje simulado con 3 o 4 indicios escondidos; el usuario los toca y cada uno se explica |
| A2 | ¿Real o estafa? | Tarjetas deslizables, 5 por ronda, con explicación |
| A3 | Bandeja simulada | 5 mensajes; Confiar, Verificar o Reportar; puntaje |
| A4 | Chat con el estafador | Conversación ramificada estilo WhatsApp |
| A5 | Ayuda a tu vecino | Elegir qué consejo darle a un personaje |
| A6 | Verifica en 3 pasos | Verificador real con sello de prueba, incluido uno copiado |
| A7 | Audio-reto | Audio de 60 s y dos botones grandes (EX2) |
| A8 | Simulacro con momento enseñable | Solo internos; quien hace clic ve al instante qué no vio |
| A9 | Ejercicio de mesa | Escenario por etapas para IN3 e IN4 |

### 10.4 Rutas

| Tipo | Arranque | Ciclo de refuerzo | Ritmo base |
| --- | --- | --- | --- |
| EX1 | M1 → M2 → M3 | M4, M5 o M6 según el ataque activo; A5 al mes | Cada 2 semanas |
| EX2 | M1 (audio) → M7 | Una pieza de M7 por semana; M4 en audio si hay campaña T2 | Semanal |
| EX3 | M1 → M2 → M8 | M8 con los patrones del mes | Mensual |
| EX4 | M1 → M2 → M9 | M9 y M5 por campaña | Por campaña |
| EX5 | M1 exprés tras su primera verificación | M10 si verifica por otra persona | Opcional |
| IN1 | M1 → M3 → M11 | Un simulacro y un módulo de 5 min al mes | Mensual |
| IN2 | M11 → M12 (obligatorio antes del rol) | M12 | Trimestral |
| IN3 | M11 → M13 | M13 con escenario nuevo | Trimestral |
| IN4 | M11 → M13 | M13 con foco en privilegios | Semestral |

## 11. Flujo «Quiero capacitarme» [DECIDIDO]

**Alcance del MVP:** botón para **internos y externos**; **solo correo**; **solo dos señales: clic y reporte**. Sin formulario de clave, sin SMS, sin WhatsApp. En la demo **se envía un correo real**.

1. El usuario toca «Quiero capacitarme», acepta el consentimiento (qué se mide, frecuencia, cómo salir) y se confirma su correo (doble opt-in si no viene de la cuenta).
2. Se envía **en ese momento** un correo de prueba de **nivel 2**, elegido por tipo de usuario.
3. Reacción dentro de la ventana (**10 min en la demo, 48 h en producción**) → diagnóstico general:

| Reacción | Nivel inicial | Qué pasa |
| --- | --- | --- |
| Reportó sin hacer clic | Avanzado | «¡Lo detectaste!» y los indicios que vio; ruta con ritmo Centinela |
| No hizo nada | Intermedio | Correo de seguimiento con los indicios; empieza por M3 |
| Hizo clic | Básico | Momento enseñable inmediato con el microcurso del indicio; ritmo Expuesto |

Si reporta después de hacer clic, el nivel sigue siendo Básico, pero el reporte cuenta para el perfil.

4. Cada microcurso terminado habilita el siguiente correo de prueba (**escalera**):

| Nivel del correo | Indicios presentes |
| --- | --- |
| 1 Fácil | 4 o más, obvios |
| 2 Medio | 2 o 3 |
| 3 Difícil | 1, sutil |

Reglas: reportó → sube un nivel; ignoró → mismo nivel; clic → baja un nivel y llega el microcurso del indicio que no vio; dos reportes seguidos en nivel 3 → Centinela, con un correo al mes. El siguiente correo incluye al menos un indicio `DEBIL` o `SIN_PROBAR`. **Límites:** máximo un correo de prueba por semana, nunca dos en 48 h, y se puede pausar o salir desde la app.

### Primer correo por tipo (plantillas simuladas)

| Tipo | Asunto | Indicios |
| --- | --- | --- |
| EX1 | «Tienes un reembolso pendiente de $187,40, vence hoy» | I6, I1, I7 |
| EX2 | «Tu pensión será suspendida si no actualizas tus datos hoy» | I8, I1, I9 |
| EX3 | «Glosa por aportes impagos: evita la coactiva cancelando la tasa hoy» | I8, I10, I7 |
| EX4 | «Liquidación de planillas retenida: revisa el detalle adjunto» | I5, I7, I1 |
| EX5 | «Tu certificado de afiliación está listo. Escanea el QR para descargarlo» | I11, I7, I1 |
| IN1-IN4 | «Tu buzón institucional está lleno. Valida tu usuario y contraseña» | I3, I1, I2 |

### Microcurso que se dispara por indicio

| Indicio | Microcurso |
| --- | --- |
| I1 | «La prisa es la trampa» (M1) |
| I2, I7 | «Tus canales oficiales» (M2) |
| I3, I9 | «El IESS nunca te pide tu clave» (M1) |
| I4 | «Mira a dónde lleva de verdad un enlace» (M6) |
| I5 | «Adjuntos que no esperabas» (M11 internos; M8 o M9 externos) |
| I6, I10 | «Nadie regala ni cobra por adelantado» (M4) |
| I8 | «El IESS no bloquea por correo» (M7 para EX2; M4 los demás) |
| I11 | «No confíes en la página que abre un QR» (M6) |

Las plantillas se arman a partir del dataset sintético filtrando por indicios y nivel, adaptadas al tipo de usuario.

### Tecnología de envío

| Uso | Herramienta | Notas |
| --- | --- | --- |
| Envío en la demo [DECIDIDO que se envía; PROPUESTO el proveedor] | **Resend** (SDK de Python) | Plan gratis: 3.000 al mes, 100 al día, 1 dominio |
| Respaldo | **Brevo** | Plan gratis: 300 al día, API REST y SMTP |
| Desarrollo local | **Mailpit** | Atrapa correos sin enviarlos |
| Simulacros internos en fase 2 | GoPhish | Código abierto, servidor propio |
| Descartados | SendGrid (sin plan gratis desde 2025), Gmail personal (spam o bloqueo) | |

Requisitos: comprar un **dominio de práctica** que no imite al IESS, verificarlo en Resend con **SPF y DKIM**, y probar con Gmail y Outlook el día anterior a la demo.

### Reglas de medición

- Un clic **solo cuenta con el `POST` del botón «Continuar»** de la página de destino. `GET /p/{token}` no cuenta, porque los filtros de Gmail y Outlook visitan los enlaces solos.
- **No se miden aperturas** (las imágenes de seguimiento dan datos falsos).
- **El reporte = reenviar el correo**, como indica el catálogo. Producción: seguridad.informacion@iess.gob.ec. Demo: dirección de reportes del dominio de práctica con webhook de recepción entrante. Alternativa si el plan gratuito no tiene recepción: botón «Reportar correo» en la app.
- El token se envía en las URL y en la cabecera `X-Simulacro-Ref`; en la BD se guarda solo su SHA-256.

## 12. Contratos de API

### Existentes o del documento original

| Endpoint | Bloque | Uso |
| --- | --- | --- |
| `POST /api/v1/hashes/register` | 1 → 3 | Registrar un sello en la white list (`emisor_id`, `emisor_nombre`, `tipologia`, `asunto_resumen`, `hash`, `timestamp`, `ttl_dias`) |
| `POST /api/v1/verify` | 2 → 3 | Verificar (`hash_recibido`, `remitente_reportado`, `tipologia_percibida`, `rango_etario_usuario`, `canal`) → `estado`, `semaforo`, `motivo`, `metadatos_oficiales`, `capsula_educativa` |
| `GET /api/v1/observatorio/metrics` | 3 | Métricas; filtros `tipo`, `rango`, `tipologia`; vacío si la celda tiene < 10 personas |

### Nuevos

| Endpoint | Uso |
| --- | --- |
| `GET /api/v1/me` | Tipos, zona y perfil del usuario actual (decide las pantallas en Flutter) |
| `POST /api/v1/eventos` | Eventos de la app con tipo y perfil, sin identificador personal |
| `POST /api/v1/capacitacion/inscribir` | Consentimiento, elección de plantilla (nivel 2), envío del primer correo de prueba |
| `GET /p/{token}` | Página neutra con botón «Continuar»; **no cuenta clic** |
| `POST /p/{token}/clic` | Registra CLIC, actualiza el mapa de indicios, muestra el momento enseñable |
| `POST /api/v1/reportes/entrante` | Webhook de recepción: busca el token en el correo reenviado y registra REPORTO |
| `POST /api/v1/capacitacion/siguiente` | Interno: aplica la escalera y envía el siguiente correo si se respetan los límites |

Un proceso programado (APScheduler en la demo) revisa cada minuto las simulaciones vencidas, las marca IGNORO y envía el seguimiento.

### Eventos de la app (`POST /api/v1/eventos`)

| Evento | Datos clave |
| --- | --- |
| `ACTIVIDAD_INICIADA` | `actividad_id`, `modulo` |
| `SENAL_ENCONTRADA` | `senal_id`, `segundos_desde_inicio` |
| `DECISION_TOMADA` | `item_id`, `opcion`, `es_correcta` |
| `ACTIVIDAD_COMPLETADA` | `aciertos`, `total`, `duracion_seg` |
| `RESPUESTA_EVALUACION` | `pregunta_id`, `opcion`, `es_correcta`, `momento` (BASE, POST, D30, D60, D90) |
| `SIMULACRO_RESULTADO` | `simulacro_id`, `resultado` (REPORTO, CLIC, IGNORO) |

### Formato JSON de una actividad (la app la interpreta con uno de los 9 componentes)

```json
{
  "id": "M1-A1-01",
  "modulo": "M1",
  "mecanica": "A1_CAZA_SENAL",
  "paso_4r": ["RECONOCER"],
  "tipos": ["EX1", "EX2", "EX3", "EX4", "EX5", "IN1"],
  "tipologia": "T2",
  "indicios": ["I7", "I1", "I3", "I2"],
  "variante_ex2": "M1-A7-01",
  "duracion_seg": 60,
  "mensaje": {
    "etiqueta": "SIMULACIÓN",
    "remitente": "devoluciones@iess-pagos-ec.net",
    "asunto": "Tienes un reembolso pendiente de $187,40, vence HOY",
    "cuerpo": "Estimado afiliado: ..."
  },
  "senales": [
    { "id": "I7", "zona": "remitente", "feedback": "Los correos del IESS terminan en iess.gob.ec." },
    { "id": "I1", "zona": "asunto", "feedback": "La prisa no te deja pensar." },
    { "id": "I3", "zona": "cuerpo:2", "feedback": "El IESS nunca te pide tu clave por correo." },
    { "id": "I2", "zona": "boton", "feedback": "Entra tú mismo a la app oficial." }
  ],
  "mensaje_clave": "Si te apura, te pide claves o dinero, o viene de un remitente raro: para y verifica."
}
```

`variante_ex2`: si el usuario es EX2, la app muestra la versión audio.

## 13. Modelo de datos consolidado

| Tabla | Campos | Bloque |
| --- | --- | --- |
| `emisores` | `id`, `nombre_area`, `correo_oficial`, `tipologias_permitidas`, `activo` | 3 |
| `whitelist_hashes` | `hash` (PK), `emisor_id`, `tipologia`, `asunto_resumen`, `created_at`, `expires_at`, `revocado` | 3 |
| `blacklist_patrones` | `id`, `tipo` (DOMINIO, URL, FRASE), `valor`, `tipologia_suplantada`, `reportes_count` | 3 |
| `eventos_observatorio` | `id`, `timestamp`, `resultado` (VERDE, AMARILLO, ROJO), `tipologia`, `rango_etario`, `canal`, `tipo_usuario`, `perfil_conducta`, `es_cuidador`, `accion` (VERIFICAR, REPORTAR, RETO, CAPSULA, SIMULACRO) — **sin `id_seudonimo`** | 3 |
| `usuarios` | `id_seudonimo`, `zona`, `rango_etario`, `modalidad`, `canal_preferido`, `creado_en` | 3 |
| `usuario_tipos` | `id_seudonimo`, `tipo` (EX1…IN4), `otorgado_por`, `vence_en` | 3 |
| `perfiles_conducta` | `id_seudonimo`, `perfil`, `precision`, `tasa_reporte`, `ultima_actividad`, `calculado_en` (cálculo nocturno) | 3 |
| `simulaciones_correo` | `id`, `id_seudonimo`, `tipo_usuario`, `nivel` (1-3), `indicios`, `plantilla_id`, `token_hash`, `enviado_en`, `vence_en`, `resultado` (PENDIENTE, REPORTO, CLIC, IGNORO), `resultado_en`, `microcurso_enviado` | 3 |
| `mapa_indicios` | `id_seudonimo`, `indicio` (I1-I11), `estado` (DOMINADO, DEBIL, SIN_PROBAR), `actualizado_en` | 3 |

## 14. App Flutter (Bloque 2)

- `RoleGuard` en el router (por ejemplo `go_router`) que lee `GET /api/v1/me`: bandeja espejo para externos, consola web para internos.
- EX2: interfaz simplificada (letra grande, menos pasos, audio), activada por tipo y no por edad declarada.
- EX5: verificación sin cuenta; pregunta opcional de rango de edad y «¿verificas por otra persona?».
- Consola interna solo web: emitir (IN2), observatorio y revocación (IN3), roles (IN4).
- Botón «Quiero capacitarme» en el inicio para todos los tipos; pantalla de consentimiento; mensaje final «Revisa tu correo como lo harías cualquier día».
- Las 9 mecánicas son componentes reutilizables que consumen el JSON de actividad.

## 15. Plan por fases

| Fase | Cuándo | Contenido | Puerta de salida |
| --- | --- | --- | --- |
| 0 Definición | Hackatón, día 1 | Catálogo de tipos y perfiles, diccionario de métricas, esquema de eventos, datos de prueba | Contrato de `/me` y `/eventos` acordado |
| 1 MVP | Hackatón, día 2 | Login simulado con dos proveedores, `RoleGuard`, eventos, observatorio por tipo, perfiles con reglas fijas, flujo «Quiero capacitarme» con correo real | Demo completa con un usuario ficticio por tipo |
| 2 Piloto | Después | Grupo piloto, simulacros solo internos, recalibrar umbrales, grupo de control | Evaluación de impacto LOPDP aprobada |
| 3 Escala | Con aval del IESS | Padrón real y directorio, campañas automáticas, revisión de privilegios | |

### Guion de la demo (unos 3 min)

1. Un voluntario elige «Afiliado», toca «Quiero capacitarme» y acepta.
2. Llega a su bandeja el correo del reembolso (I6, I1, I7).
3. Camino clic: abre, toca «Continuar», ve el momento enseñable; el observatorio marca I6, I1 e I7 como débiles.
4. Camino reporte: otro voluntario reenvía el correo; la app muestra «¡Lo detectaste!» y sube a Avanzado.
5. Adaptación: el primero termina el microcurso y le llega un correo de nivel 1 centrado en su indicio más débil.

## 16. Decisiones abiertas [PENDIENTE]

- Unificar el sello: HMAC único, Hash 1 + Hash 2, o firma Ed25519 con `rcpt` (recomendado).
- Unificar el endpoint de verificación y su respuesta (`POST /api/v1/verify` con metadatos, recomendado).
- ¿EX5 tiene perfil por dispositivo o queda siempre sin perfil?
- Responsable del tratamiento de datos dentro del IESS y firma de la evaluación de impacto.
- Umbrales de 80% y 60%: ¿fijos en la demo o configurables?
- ¿Derechohabientes como tipo propio en la fase 2?
- Proveedor de envío definitivo y si el plan gratuito permite recepción de correo para los reportes.
- Nombre y compra del dominio de práctica.

## 17. Glosario

| Término | Significado |
| --- | --- |
| Sello | Hash o firma que prueba que un correo salió del IESS |
| White list / black list | Sellos válidos / patrones de phishing confirmados |
| Bandeja espejo | Copia en la app de los correos oficiales del usuario |
| Indicio | Señal de phishing del catálogo oficial (I1-I11) |
| Tipología | Clase de comunicación oficial (T1, T2, T3) |
| Perfil de conducta | Centinela, Prudente, Expuesto, Inactivo |
| IRS | Índice de resiliencia del segmento (0 a 100) |
| Momento enseñable | Explicación que aparece en el instante del error |
| Escalera | Ajuste de dificultad del siguiente correo de prueba |
| Mapa de indicios | Estado de cada indicio por usuario: dominado, débil, sin probar |
| 4R | Reconocer, Reaccionar, Reportar, Replicar |

## 18. Documentos de referencia

- Documento de trabajo con las cuatro pestañas (tipos y métricas, observatorio y capacitación, material de capacitación, flujo «Quiero capacitarme»): https://claude.ai/artifact/1ZwcpJEzaNDFPztffj9aXt
- Catálogo de indicios, diccionario de datos y canales oficiales del IESS (material del reto, PDF).
- Investigación previa del reto: `obsidian/` (ver `obsidian/CLAUDE.md`).
