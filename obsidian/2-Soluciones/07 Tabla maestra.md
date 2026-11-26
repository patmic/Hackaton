---
tags: [soluciones, tabla-maestra, campana]
fuente: "[[Mapa de soluciones completo]]"
fecha: 2026-11-25
---

↑ [[Indice Soluciones]]

# 07 Tabla maestra

## En pocas palabras
- Resume cada solución del mapa con su posición en la campana: 90 filas sin recortar (13 de centro, 30 convergentes, 23 de periferia, 16 atípicas y 8 atípicas negativas; conteo de esta nota).
- Los identificadores agrupan por zona: C centro, V convergente, P periferia, X atípico y N atípico negativo.
- Donde las notas dan posiciones distintas según el ámbito, se indica entre paréntesis.
- Las fuentes de cada fila están citadas en las notas de zona ([[01 Centro de la campana]] a [[06 Atipicos negativos y lineas rojas]]).

## Claves de lectura
| Columna | Cómo leerla |
|---|---|
| Evid. | Nivel A a D (ver [[00 Como leer el mapa]]); «A nulo» es un estudio fuerte que no encontró efecto; «otro dominio» indica que la evidencia viene de fuera del fraude |
| Eslabón | E1 clave, E2 cambio de datos, E3 préstamo o fondos, E4 víctima se entera tarde, EI riesgo interno |
| Encaje | J jubilados urbanos, C campesinos y rurales, M migrantes, A afiliados activos, S personal sanitario, V ventanilla y roles con permisos |
| Celda con «-» | El informe deja la celda vacía |

## Tabla completa
| ID | Solución | Zona | Cómo funciona | Quién la usó | Evid. | Costo | Riesgo legal y ético (LOPDP, SPDP) | Eslabón | Encaje con la población del IESS |
|---|---|---|---|---|---|---|---|---|---|
| C1 | Curso anual en LMS, talleres y kits gratuitos | Centro | Curso con test y certificado; afiches y consejos | IESSEDUCA, MINTEL, OEA, INCIBE, CISA, NCSC | A nulo | Bajo en licencia, alto en horas | Bajo | Ninguno directo | S/V: llega a ~1 de cada 4; no aplica a ciudadanos |
| C2 | Simulación de phishing con capacitación embebida | Centro | Señuelos y microcurso al fallar | GoPhish, KnowBe4, Microsoft AST | A (≈2 pp; posible efecto adverso) | Licencia 0 (GoPhish) o ver C3 | Medir individuos es tratar datos de servidores: base legal, sindicato | E1 (personal) | S/V con correo; no cubre al ciudadano |
| C3 | Plataforma comercial de concienciación | Centro | Biblioteca, simulación, botón, tablero | KnowBe4, Proofpoint, Hoxhunt, SoSafe, Terranova, Kaspersky | B (−79 % del proveedor, sin control) | USD 1,6-5 por usuario/mes; ≈0,64-2 M/año | Transferencia internacional (2026-0004-R), cláusulas (2025-0006-R) | E1 (personal) | S/V; el jurado la compara con un producto maduro |
| C4 | Tablero de % de clic y % de cursos completados | Centro | Indicador principal del programa | Práctica general | A (engañoso: 1,82-30,8 % según señuelo) | Muy bajo | Exposición individual si no se agrega | Ninguno | Mide cumplimiento, no riesgo |
| C5 | Sanción por fallar simulaciones | Centro (práctica frecuente) | Entrevista o consecuencias al que cae | Empresas en general | B/C (reduce aceptación y reporte) | Muy bajo | Con multas personales LOPDP empuja a ocultar | Empeora E1 y EI | S/V: rechazo sindical |
| C6 | Campaña «nunca te pediremos la clave» y alertas en prensa | Centro | Comunicado y redes tras cada modalidad | IESS, SRI, ANSES, IMSS, Colpensiones, ChileAtiende | A nulo (material escrito) | Bajo | Bajo | E1 débil; no cubre entrega voluntaria | Todos; llega tarde |
| C7 | Detector o chatbot clasificador con LLM | Centro en hackatones | Clasifica un mensaje o sitio y explica | CiberUGR, clones de Devpost | C/D; sobreconfianza | Bajo (prototipo) | Res. 2026-0009-R; API extranjera implica transferencia | E1 | A; bajo en J/C (requiere PC o smartphone) |
| C8 | «App integral de protección» | Centro en hackatones | Suma detección, alertas y consejos | Guardian App (Perú) | D | Medio | Variable | E1 difuso | Adopción improbable |
| C9 | Juego, quiz o gamificación | Centro en hackatones | Puntos y niveles sobre conocimiento | Gana al Hacker, Cordi | A (decae a los 9 días) | Bajo | Bajo | E1 | A, S; J con ayuda |
| C10 | DMARC en p=reject | Centro técnico | Rechaza correo que suplanta el dominio | HMRC y gobiernos | B (~500 M correos) | Muy bajo | Ninguno | E1 | Todos; higiene, no cultura |
| C11 | Aviso al canal anterior ante cambios | Centro (banca) | Mensaje al contacto previo con vía para revertir | Singapur, banca; IESS (correo) | D | Muy bajo | Ninguno nuevo | E2, E4 | J/C: falta celular, SMS e IVR |
| C12 | Verificación por segundo canal | Centro (buena práctica) | Devolver la llamada a número de directorio antes de pagar o cambiar | Banca, fraude del CEO | D | Bajo | Ninguno | E2, EI | V alto |
| C13 | Autenticación basada en riesgo | Centro (banca) | Dispositivo, IP u horario atípicos piden verificación | Banca, Singapur | C | Medio | Perfilado leve; informar | E1, E3 | A; J si activa el enfriamiento |
| V1 | Enfriamiento tras cambio de contacto, cuenta o dispositivo | Convergente (centro en Singapur) | Sin préstamos ni retiros durante 12-72 h; aviso por canal previo | MAS/ABS 2022, SRF 2024; Brasil (60 días) | B (−26 % casos, paquete) | Bajo técnico; fricción | Sin datos nuevos | E2→E3 | J/C alto; M sufre fricción |
| V2 | Autobloqueo («kill switch») | Convergente | Botón o número que congela crédito y retiros | Singapur, Brasil (Meu INSS, 135) | D | Bajo-medio | Bloqueo malicioso | E3, E4 | J: activable por familia; C por teléfono básico |
| V3 | Préstamo y retiro bloqueados por defecto | Convergente | Crédito apagado hasta desbloqueo reforzado por operación | INSS Brasil (2019, mensual desde 11-2025) | B (−88 % / −70 % reclamos) | Bajo técnico; alto comercial | Biometría: dato sensible, 2026-0039-R, EIPD | E3 | J muy alto; C/M necesitan desbloqueo accesible |
| V4 | Cuenta destino a nombre del titular | Convergente (centro en pagos UK/UE) | Validar con el banco cédula = titular | Confirmation of Payee (UK) | B (−59 % «cuenta incorrecta») | Medio (convenio bancario) | Intercambio con bancos: base legal | E2, E3 | Todos; corta cuentas mula |
| V5 | Persona de confianza sin poder de operar | Convergente | Contacto avisado ante eventos de riesgo; no ve ni opera | FINRA 4512, banca de EE. UU. | C | Bajo | Tercero titular: consentimiento | E4 (E3 con retención) | J/M alto; riesgo si es el explotador |
| V6 | Ayudante registrado (delegación acotada) | Convergente (centro en Brasil y NHS) | El ayudante entra con su credencial a servicios sin dinero; queda registro | Meu INSS, NHS proxy access | C/D | Medio | Registro del delegado; auditoría | E1 (causa raíz) | J/C/M muy alto |
| V7 | Bot oficial «¿es del IESS?» con registro de envíos oficiales | Convergente (centro si es genérico) | Reenvío, cotejo y respuesta en tres niveles | ScamShield (Singapur) | B (adopción, sin exactitud) | Bajo-medio (≈USD 0,011 por plantilla) | Datos de terceros: minimizar y borrar; 2026-0009-R | E1 | A/M alto; J vía familia; C bajo |
| V8 | Línea de reporte conectada a congelamiento | Convergente | «No reconozco este préstamo» bloquea y avisa al BIESS | India 1930, España 017 | B (₹8.189 crore) | Bajo-medio | Bajo | E4→E3 | Todos (voz) |
| V9 | Registro obligatorio de remitentes SMS | Convergente | Solo remitentes registrados llegan con nombre | Singapur, Australia | B (−70 % casos SMS) | Bajo; depende de ARCOTEL | Bajo | E1 | Todos |
| V10 | Passkeys o segundo factor | Convergente | Credencial ligada al dominio real | myGov; Singapur sin OTP SMS | D (por diseño) | Medio | Bajo | E1 (no frena la entrega voluntaria) | A alto; J/C bajo |
| V11 | Aprobación ligada a la acción | Convergente | Se aprueba lo que se ve; sesión ligada al dispositivo | Smart-ID+ (Estonia), PSD2 | D | Medio-alto | Bajo | E3 | A; J con audio y pausa |
| V12 | Biometría con detección de vida | Convergente con fallo documentado | Desbloqueo facial certificado y alternativa presencial | INSS Brasil | B (con burlas) | Medio-alto | Dato sensible; 10 M fotos de cédula filtradas | E3 | Ambivalente en J; acceso en C/M |
| V13 | Reglas de secuencia con retención y verificación humana | Convergente (centro en banca) | Cambio + cuenta nueva + préstamo en N días → retener y llamar | Banca, DWP, SEB | B (autorreporte) | Bajo (reglas) a alto (ML) | Perfilado: EIPD, intervención humana, sin nacionalidad | E3, E4, EI | Todos; medir sesgo por edad y ruralidad |
| V14 | Inoculación interactiva con refuerzos | Convergente | «¿Real o falso?» con retroalimentación cada 2-3 semanas | AARP/SSA | A (+7 pp; nulo a las 4 semanas; sin efecto en SMS) | Bajo-medio | Bajo | E1, E4 | J/A alto; C con audio |
| V15 | Prebunking en video corto | Convergente (periferia en fraude) | Video sobre la técnica antes de exponerse | Jigsaw, UE | A (1,8-5,4 %) | Medio (pauta) | Bajo | E1 | Salas de espera; sin datos en mayores |
| V16 | Palabra clave familiar | Convergente | Frase acordada en persona | FBI, Starling Bank | D | ≈0 | Ninguno | E1 (voz clonada) | M/J alto |
| V17 | Enseñar un procedimiento, no señales | Convergente | «Cuelga y llama al número impreso»; mensajes propios sin marcadores | Kenia, Uganda | A (las señales fallan) | Muy bajo | Ninguno | E1 | Todos |
| V18 | Botón de reporte con respuesta rápida | Convergente (hacia centro) | Un clic envía al SOC; respuesta y purga | Lain et al.; Gmail y Outlook | A (15 meses, >14.000) | Bajo (nativo) | Métrica agregada | E1 personal, EI | S/V alto |
| V19 | Referentes de seguridad por unidad médica | Convergente (diseño) / periferia (resultado) | Voluntario con tiempo protegido y canal al OSI | OWASP, LinkedIn | C | Bajo en dinero, alto en tiempo | Bajo | E1, EI | S medio-alto; pacto sindical |
| V20 | Aviso inmediato por acceso no justificado | Convergente | Correo esa noche pidiendo justificar el acceso | Centro académico de EE. UU. (JAMA 2022) | A (40 % → 1,8 %; un ensayo) | Medio | Datos de servidores: aviso previo, base legal | EI | S/V muy alto |
| V21 | «Romper el cristal» con justificación | Convergente | Registros sensibles piden motivo; revisión posterior | Epic, Cerner; AMC Ámsterdam | B/C | Medio-alto (solo diseño en el reto) | Datos de salud (arts. 25-26) | EI | S |
| V22 | Auditoría basada en explicaciones | Convergente (técnica) | Descarta accesos explicados antes de alertar | Universidad de Michigan (94 %) | B | Medio | Reduce falsos positivos | EI | S/V; hace viable V20 |
| V23 | Doble control de cambios de cuenta y contacto | Convergente (centro como control) | Segundo servidor o verificación fuera de banda | Guía CERT | D | Bajo técnico, medio en proceso | Bajo | E2, EI | V muy alto |
| V24 | Recertificación de accesos y baja oportuna | Convergente | El jefe confirma quién necesita qué | CERT; lección CCSS | B (caso negativo) | Bajo | Bajo | EI | V/S |
| V25 | Tablero de tres capas | Convergente | Conducta, proceso y percepción | NIST SP 800-50r1, HAIS-Q, Phish Scale | C/D | Bajo | Agregado; privacidad diferencial opcional | Medición | Encaja con el EGSI |
| V26 | Cultura justa pactada | Convergente | Matriz error, riesgo, temeridad; reportar atenúa | CREST; seguridad del paciente | B/C | Bajo | Mitiga ocultamiento por multas | E1, EI | S/V |
| V27 | Formación por rol y materiales HICP | Convergente | Necesidades por rol; materiales libres | NHS DSPT, HHS 405(d) | D | Muy bajo | Bajo | E1, EI | S alto |
| V28 | Ejercicios de mesa y contingencia en papel | Convergente | Simulacro breve por unidad | HHS; lección CCSS | C | Bajo | Bajo | Continuidad | S; útil ante apagones |
| V29 | Explicaciones de aviso generadas por LLM | Convergente | Explica por qué un correo es sospechoso | Cau et al. (750) | A (preprint) | Bajo (modelo abierto) | Contenido de correos: EIPD, 2026-0009-R | E1 | S/V |
| V30 | Simulaciones generadas por IA | Convergente | Señuelos realistas a bajo costo | Proveedores; Heiding et al. | A (amenaza: 54 % de clic) | Bajo | Hiperpersonalización y cebos sensibles | E1 | S solo con cultura justa |
| P1 | Juego de voz IVR «elige tu historia» | Periferia | Historias con decisiones por teclado; Stop-Check-Act | IPA y Viamo (Uganda) | A-/B (7,1 % → 5,7 %) | <USD 150.000; marginal ≈0 | Mínimo | E1, E4 | C/J muy alto; teléfono básico |
| P2 | IVR o asistente en lenguas originarias | Periferia | Mensaje fijo antifraude en kichwa | Línea 101 y MarIA (Perú) | D | Bajo | Bajo | E1 | C alto |
| P3 | Radionovela o telenovela con trama central | Periferia | Serie corta con una acción por episodio | Scandal!, Josefa, Shuga; CORAPE | A (otro dominio) | No obtenido | Bajo | E1 | C/J alto; resiste apagones |
| P4 | Monitores pares en clubes y dispensarios | Periferia (convergente si se mide) | Dirigentes formados replican mensajes | IPS Chile, Mendoza, SERNAC | C | Bajo | El monitor puede volverse tramitador | E1, E4 | J/C alto (659 dispensarios) |
| P5 | Universitarios que enseñan a mayores | Periferia | 4-5 sesiones y refuerzo remoto | Chile, Digi-Life (España) | B (alfabetización, no fraude) | Bajo | El estudiante no debe conocer la clave | E1 | J |
| P6 | Patrulla del jubilado | Periferia | Mayores enseñan a revisar el propio historial | Senior Medicare Patrol | B (efecto no medible) | Bajo | Supervisión | E4 | J |
| P7 | Protocolo de ventanilla IESS/BIESS | Periferia (centro en banca UK) | Guion para frenar la operación y llamar a la policía | Banking Protocol, TD, CBA, AARP BankSafe | B (£258,2 M; 1.202 detenciones) | Bajo técnico; convenio policial | Discriminación por edad | E2, E3 | J muy alto; V |
| P8 | Kit de bolsillo (tarjeta, adhesivo, frases fijas) | Periferia | Números oficiales y tres reglas impresas | SSA (mensajes fijos en español) | D | Muy bajo | Tarjetas falsas | E1 | C/J; sin luz |
| P9 | Diseño en modo degradado de tres capas | Periferia (convergente en salud) | En línea, sin datos y sin red | Lecciones de apagones y CCSS | C | Bajo | Bajo | Transversal | C alto |
| P10 | Verificación comunitaria abierta | Periferia / atípico | Base pública; respuesta automática al reenvío repetido | Cofacts, Auntie Meiyu | B/C | Bajo (código abierto) | Datos personales en reenvíos | E1 | J vía grupos familiares |
| P11 | Mensaje de norma social local en el momento de riesgo | Periferia | «9 de cada 10 jubilados de tu provincia…» al pedir préstamo | BIT y HMRC (impuestos) | A (otro dominio, +15 pp) | Bajo; prueba A/B | Exige dato real | E1, E3 | J/A |
| P12 | «Reporta y lo bajamos» con tablero público | Periferia regional (convergente en UK) | Reporte con retiro visible | NCSC | B | Medio recurrente | Bajo | E1 (oferta) | Todos |
| P13 | Escape room móvil para personal sanitario | Periferia | Juego presencial en equipo | Universidad de Twente (96) | A- (muestra pequeña) | Medio | Bajo | E1, EI | S alto |
| P14 | Honeypot de inteligencia con bots | Periferia | Números trampa y agentes que extraen guiones y cuentas | Apate.ai con CommBank y TPG | B/C | Alto | Interceptación: coordinar con Fiscalía | E1 (oferta) | Indirecto |
| P15 | Filtros de IA en la red del operador | Periferia para Ecuador | Bloqueo en tránsito | Airtel, operadores UK | B (−12 % respuesta) | Del operador | Inspección de contenido | E1 | Todos; depende de ARCOTEL |
| P16 | Aprendizaje federado entre IESS, BIESS y bancos | Periferia | Detectar mulas sin centralizar datos | Premios PETs 2023 | D | Alto | Sigue siendo tratamiento | E2, E3 | Hoja de ruta |
| P17 | Detectores automáticos de voz clonada | Periferia | Clasifican audio | Proveedores, academia | A (fallan en condiciones reales) | Medio-alto | Biometría de voz | E1 | Bajo |
| P18 | Coaching con LLM tras clic o reporte | Periferia | Microlección por rol | Propuesta | D | Bajo | EIPD | E1 | S/V |
| P19 | Banner genérico [EXTERNO] | Periferia | Etiqueta en todo correo externo | Hospital universitario alemán | A mixto | ≈0 | Bajo | E1 | S |
| P20 | Aviso disuasorio «su acceso queda registrado» | Periferia | Mensaje genérico previo | Experimentos con intrusos | A nulo | ≈0 | Bajo | EI | Mejor V20 |
| P21 | UEBA comercial con seudonimización | Periferia | Alertas por patrones anómalos | Proveedores | D | Alto | Vigilancia laboral: EIPD, sindicato | EI | V |
| P22 | Veeduría ciudadana de seguridad digital | Periferia | Ciudadanos auditan el recorrido de reporte | Veedurías del CPCCS | B (resultados modestos) | Bajo | Acceso a información sensible | E4, EI | J |
| P23 | Contenido de scambaiting narrado | Periferia | Creador que enreda a estafadores | Kitboga | C | Bajo | Glorificar la confrontación | E1 | A jóvenes |
| X1 | Candado IESS voluntario con enfriamiento | Atípico | Bloqueo elegido de préstamos y cambios; desbloqueo en 48-72 h con aviso a contacto | Monzo, Money Lock, Pix nocturno, Japón | B (otro dominio) | Bajo técnico; requiere BIESS | Urgencias; límite legal; phishing «activa tu candado» | E2, E3 | J alto |
| X2 | Afiliado auditor con sorteo simbólico | Atípico | Revisar y confirmar el historial da participaciones | Nota Fiscal Paulista (invertida) | A (otro dominio); lotería sola débil | Bajo-medio | Legalidad de sorteos sin verificar | E4 | A, J con portal |
| X3 | «Jubilado trampa» (honeytokens de procesos) | Atípico | Registros sintéticos que alertan al ser tocados | Canarytokens, señuelos de Columbia | B/C (detección); D en pensiones | Bajo-medio | Comunica desconfianza; EIPD; aislar contablemente | EI | V |
| X4 | Canal de casi-fraude estilo ASRS | Atípico | Reporte confidencial y no punitivo de lo que casi pasó | Propuesta de 2018, nunca creada | D | Bajo | Inmunidad frente a multas y Contraloría | EI | S/V alto |
| X5 | Respuesta 2-2-2 con humor | Atípico | <2 h, 2 imágenes, <200 caracteres | Taiwán (2020) | C | Bajo | Trivializar a la víctima | E1 | A |
| X6 | Vigilancia epidemiológica de campañas | Atípico | Cada campaña como brote; prioriza la oferta | Modelos compartimentales | D | Medio | Bajo | E1 (oferta) | Indirecto |
| X7 | Bot cebo tipo «abuela Daisy» | Atípico | IA que conversa con estafadores | O2 (Reino Unido) | C | Medio | Grabación de terceros | E1 (oferta) | Campaña, no cultura |
| X8 | PIN de coacción | Atípico | Código alterno que alerta en silencio | Discovery Bank | C | Medio | Carga cognitiva; el atacante lo exige | E3 | J bajo |
| X9 | Teatro foro en salas de espera | Atípico | El público detiene la escena y ensaya la negativa | Boal; Virginia Tech | C | Medio por función | Bajo | E1 | J/C alto; sin conexión |
| X10 | Mimos y cultura ciudadana | Atípico | Personaje que ridiculiza al tramitador | Mockus (Bogotá) | C (no aislable) | Bajo | Humillar a mayores | E1 | Riesgoso en J |
| X11 | Canción o tono antiestafa con concurso | Atípico | Jingle o tono de llamada | Hiroshima, Hong Kong, India, BCSC | C (alcance) | Bajo | Autopromoción | E1 | A |
| X12 | Alianza con clubes de fútbol | Atípico | Estafas de entradas como puerta de entrada | Lloyds y Home Office | C | Medio-alto | Socio sancionado por la SPDP | E1 | A jóvenes |
| X13 | «Ciberabuelos» creadores verificados | Atípico | Jubilados que enseñan en redes | Sin antecedente oficial | D | Bajo | Clonación de clips | E1 | J |
| X14 | Cliente oculto de tramitadores y call center | Atípico | Afiliado ficticio pide «ayuda» | Sin antecedente localizado | D | Bajo-medio | Entrampamiento; base legal | E1, EI | V |
| X15 | Fondo de reembolso a víctimas | Atípico en seguridad social | Reembolso rápido con regla de cuidado razonable | PSR (UK), INSS (Brasil) | B (contradictorio) | Alto | Riesgo moral | E4 | J muy alto |
| X16 | Llamada perdida con devolución grabada | Atípico | El afiliado cuelga y recibe un mensaje oficial | Sin ejemplos | D | Bajo | Normaliza devoluciones (wangiri) | E1 | C |
| N1 | Simulacro con cebo de bono | Atípico negativo | Señuelo que explota la necesidad | Tribune, GoDaddy, West Midlands Trains | C | - | Daño laboral | Empeora EI | Prohibido |
| N2 | Puntaje opaco de beneficiarios | Atípico negativo | Algoritmo que perfila al afiliado | Robodebt, SyRI, toeslagenaffaire | A (comisiones, sentencias) | - | Discriminación; decisión sin supervisión | - | Daño a J y M |
| N3 | Negativa automática por cruce de bases | Atípico negativo | Rechazo sin persona | INSS Brasil | B/C | - | Castiga lo rural no registrado | - | Daño a C |
| N4 | Biometría como bala de plata | Atípico negativo | El rostro como prueba suficiente | INSS Brasil | C | - | Dato sensible capturado | - | J |
| N5 | Miedo y compromisos firmados | Atípico negativo | Intimidar o hacer firmar | Scared Straight; «firmar arriba» | A | - | - | - | - |
| N6 | Muro de la vergüenza | Atípico negativo | Publicar nombres de condenados | Irlanda del Norte | C | - | Presunción de inocencia, LOPDP | - | - |
| N7 | Listas de «señales de estafa» | Atípico negativo (aunque frecuente) | Enumerar errores y remitentes | Kenia | A | Bajo | - | - | Todos |
| N8 | Registro de SIM como solución | Atípico negativo | Identificar líneas | Filipinas | B (+225 % llamadas) | - | Datos masivos | - | - |

## Relacionadas
[[00 Como leer el mapa]] · [[08 Donde convergen las vertientes]] · [[09 Huecos]]
