---
tags: [resumen, equipo, moc]
fecha: 2026-11-26
---

# Resumen para el equipo

> Todo lo que investigamos, en una sola nota (unos 15 minutos de lectura). Cada sección enlaza a su nota de detalle.
> Lienzo con todo conectado: [[Mapa del equipo.canvas]]. Herramienta interactiva (Venn, rúbrica oficial, 40 ideas, jurado, vulnerables): [Brújula Reto 1](https://claude.ai/artifact/1EJv5aH1UrZMnQ4LoxJdvV).

**La idea central en tres frases.** El fraude al IESS no entra por falta de conocimiento: entra por la confianza (una clave de un solo factor que se presta, se roba o se abusa desde dentro). Lo que más funciona en el mundo no es educar más, sino poner tiempo, fricción o una segunda persona entre el cambio de datos y el dinero, y que la educación acompañe ese momento. Nadie ha resuelto aún la clave prestada en persona, el servidor cooptado, el kichwa ni al migrante: ahí está nuestra oportunidad.

---

## 1. El hackatón y cómo se gana
Detalle: [[Bases y criterios oficiales]] · [[Agenda del Foro]] · [[Lo que se sabe del reto]]

| Dato | Qué sabemos |
|---|---|
| Organiza | IESS, Dirección Nacional de Seguridad de la Información y Protección de Datos (DNSIPD), director Fernando Coral |
| Retos | **3**: Reto 1 «Seguridad inteligente, cultura consciente» (el nuestro) · Reto 2 «Tus datos, tus derechos» · Reto 3 «Inteligencia de amenazas» |
| Participantes | 12 equipos de 8 universidades, mínimo 4 integrantes presentes |
| Datos | Ficha del reto y **datos sintéticos** que entrega el IESS. Prohibido usar datos reales o tocar sistemas en operación |
| Cierre de entregas | **Viernes 27, 16h15** (prototipo, documentación y evidencias). El lunes no se agregan funciones |
| Demo Day | Viernes 16h15: 12 min (5 problema y propuesta, 3 demo en vivo, 3 preguntas, 1 cambio). Pasan 2 por reto |
| Gran final | Lunes 30, 11h15, IESS Matriz piso 10: 10 min por equipo |
| Mentorías | Jue 12h00: problema, pertinencia, riesgos, viabilidad · Vie 12h00: seguridad, privacidad, experiencia de usuario, funcionamiento |

| Demo Day (viernes) | Pts | Gran final (lunes) | Pts |
|---|---|---|---|
| Problema | **25** | Impacto | **30** |
| Funcionalidad | 20 | Problema | 20 |
| Seguridad / datos | 20 | Aplicabilidad | 20 |
| Innovación | 15 | Innovación | 15 |
| Viabilidad | 10 | Sostenibilidad | 10 |
| Experiencia | 5 | Presentación | 5 |
| Evidencia | 5 | | |

**Qué significa para nosotros:** el problema vale 45 puntos entre los dos días (nuestra investigación es la ventaja); el viernes el demo tiene que funcionar en vivo y ser seguro (40 puntos); el lunes manda el impacto y cómo lo usaría el IESS de verdad (50 puntos). No invadir el Reto 2 (derechos del titular, ARCO) ni el Reto 3 (detección de campañas, inteligencia de amenazas).

---

## 2. El IESS: a quién servimos
Detalle: [[01 Perfiles y canales del IESS]]

| Público | Cifra | Por qué importa |
|---|---|---|
| Afiliados | 3,89 M (dic-2025); otra serie oficial da 3,54 M «activos» | Mayoría joven: el grupo más grande tiene 31-40 años (1,03 M) |
| Pensiones | 949.307 prestaciones; 75,8 % por vejez | La pensión sirve de garantía para préstamos: blanco rentable |
| Jubilado urbano (vejez) | 575.109; pensión promedio **USD 632** | El perfil con más fraude grave documentado |
| Jubilado campesino | 144.176; pensión **USD 121,75** | Rural, lejos de agencias, a veces indígena |
| Seguro Social Campesino | 342.612 jefes de familia; 659 dispensarios | Canal presencial enorme y sin contenido antifraude |
| Migrantes | 25.099 voluntarios en el exterior (+15,9 %); ~8.000 trámites a distancia | Justo las operaciones que preceden al fraude |
| Beneficiarios de salud | 7,3 M; 102 unidades médicas; 16,9 M atenciones en 2025 | Las salas de espera son un canal masivo |
| Servidores | ~33.500 (27 % médicos); la DNSIPD capacitó a ~8.000 en 2025 | Cobertura ≈ 24 % (cálculo propio). No hay línea base de conducta |

**Cómo entra la gente:** cédula + «clave personal» (un solo factor, se recupera con preguntas y una imagen). El BIESS usa la misma clave para préstamos quirografarios (USD 4.474 M en 2,8 M operaciones en 2025). Los servidores sí tienen doble factor en Google Workspace; los ciudadanos no. Canales: portal web, WebBot, WhatsApp, Messenger, línea 140. Hasta la prensa confunde cuál WhatsApp es oficial para qué: el afiliado también.

---

## 3. El problema: cómo se roba hoy
Detalle: [[02 Amenazas y fraude en Ecuador]]

| Eslabón | Qué pasa | Casos documentados |
|---|---|---|
| **E1** Obtener la clave | Se presta a un «ayudante», cibercafé o tramitador; phishing con marca IESS («reembolso», «devolución») | SMS falso de reembolso con plazo de 24 h (mar-2026); correos de devoluciones (sep-2026) |
| **E2** Cambiar datos | Cambian celular, correo y cuenta bancaria | Robo de fondos de reserva por «ayudantes» (2025) |
| **E3** Sacar el dinero | Préstamo quirografario BIESS o retiro de fondos | Guayaquil, oct-dic 2024: préstamos de **USD 9.000 a 30.550** por víctima; 14 casos reconocidos por el BIESS |
| **E4** Enterarse tarde | La víctima sigue pagando cuotas mientras se investiga | Casi 100 jubilados protestaron el 10-12-2024 |
| **EI** Riesgo interno | Un servidor con permisos ayuda | 2 funcionarios señalados (2024); funcionaria que registró 5 años de aportes falsos (2025) |

**Contexto país:**
- Identidad ya expuesta: Novaestrat 2019 (~20 M registros, con datos del BIESS) y presunta filtración del Registro Civil en mayo de 2026 (14,8 M registros y más de 10 M fotos de cédula). Que alguien sepa tus datos no prueba que sea legítimo.
- Ciberdelito: 20.602 denuncias entre ene-2022 y may-2025; 4.784 por suplantación de identidad en ene-oct 2025; apropiación fraudulenta es el 94 % de los delitos informáticos financieros.
- Canales del fraude: WhatsApp 43 % y SMS 40 %.
- Extorsión: de 1.616 casos (2019) a 23.080 (2024); homicidios 50,9 por 100.000 en 2025, el récord.
- País: ITU GCI 87,11 (nivel 2); NCSI bajó del puesto 67 al 100; EcuCERT notificó 97.250 IP con incidentes en 2025.
- No hay ciberataque confirmado contra sistemas del IESS en 2023-2026: el problema dominante es el fraude a personas y el riesgo interno.

---

## 4. Quiénes son más vulnerables
Detalle: [[03 Factores socioeconomicos]] · Venn interactivo en la Brújula, pestaña «Vulnerables»

| Factor | Cifra clave |
|---|---|
| Edad 65+ | 1,52 M personas (9 %); 30,2 % con alguna dificultad funcional; reciben el **30 % de las estafas** digitales reportadas (Asobanca) |
| Brecha digital | Solo **57,7 %** tiene smartphone (2024); el indicador oficial de analfabetismo digital ni siquiera mide a los mayores de 49 |
| Precariedad | Pobreza 24 %; informalidad 54,5 %; empleo adecuado 35,9 %. La falta de crédito predice caer en fraude |
| Rural e indígena | Hogares rurales con internet 58,7 % (urbanos 76,6 %); analfabetismo indígena 11,9 % (nacional 3,7 %) |
| Lejanía y migración | Remesas récord USD 7.729 M en 2025; trámites a distancia sin agencia |
| Riesgo interno | Servidores con permisos de modificación; capacitación de ~24 % |

**Datos nuevos (26-11-2026):**

| Dato | Cifra | Fuente |
|---|---|---|
| Smartphone por edad (2020, último dato por edad) | 65+: **20,5 %** · 25-34: 81,6 % | INEC Multipropósito 2020 |
| Adultos mayores que usan internet | **35,1 %** (nacional 77,2 %, otra encuesta); 276.084 viven solos | INEC, nota del 11-07-2024 |
| Smartphone e internet en indígenas (2025) | 37,9 % y 57,3 % (mestizos 62,4 % y 83,6 %) | ENEMDU TIC 2025 (cotejar con el gráfico) |
| Fraude con tarjetas resuelto contra el cliente | **73 %** en ene-jul 2025: él mismo entregó sus datos | Superintendencia de Bancos |
| Sentencias por estafa con tarjetas | 2 de 570 casos | Fiscalía |
| Estafa | 2.º delito más denunciado en 2025 (25.517 de 341.784) | Fiscalía |
| Avisar a 1 M de jubilados | WhatsApp ≈ USD 11.300 · SMS USD 250.000-430.000 (cálculo propio) | Tarifas Meta y Twilio/Plivo 2026 |
| Hablan un idioma indígena | 3,9 % de la población (4,9 % en 2010) | Censo 2022 |
| Clientes 60+ en canales digitales | 51 % frente a 80 % del total | Banco Pichincha |

**Perfiles más expuestos (intersecciones, no a escala):**
1. Jubilado campesino indígena: edad + brecha + precariedad + rural (muy alto).
2. Jubilado urbano con préstamo BIESS: edad + brecha (muy alto).
3. Jubilado que delega en cibercafé o tramitador (muy alto, sin cifra).
4. Adulto mayor con dificultad funcional: 459.218 personas (muy alto).
5. Servidor de ventanilla con permisos (muy alto).
6. Migrante voluntario, afiliada del trabajo no remunerado del hogar, afiliado que retira fondos de reserva, personal de hospital (alto).

Mecanismos (evidencia internacional): la susceptibilidad a estafas se asocia con deterioro cognitivo incipiente; la soledad y la fragilidad financiera predicen el engaño; en EE. UU. los mayores de 60 perdieron USD 4.885 M en 2024 (+43 %).

Contexto que agrava: apagones de hasta 14 h diarias en 2024 (cayeron datos móviles), deuda del Estado con el IESS de USD 27.389 M (cifra del IESS), tres directores generales en 2025.

---

## 5. La ley que nos obliga y nos ayuda
Detalle: [[04 Marco legal]]

| Norma | Qué dice | Cómo la usamos |
|---|---|---|
| **EGSI v3** (MINTEL-2024-0003) | Art. 9, núm. 6 y 7: el Oficial de Seguridad de la Información elabora el **plan de concienciación** y fomenta la cultura; Comité de Seguridad cada 2 meses | Nuestra solución es una herramienta para el OSI: decirlo explícitamente |
| **LOPDP** (2021) y Reglamento (2023) | Brechas: 5 días para notificar a la SPDP; delegado de protección de datos; multas **personales** a servidores de 1 a 20 salarios básicos | Medir conducta de servidores es tratar datos personales: evaluación de impacto y minimización |
| **SPDP** (superintendente Fabrizio Peralta) | Res. 2026-0009-R sobre IA: avisar que se usa IA, evaluación de riesgo, **supervisión humana**. Primeras multas en dic-2025 (LigaPro y FEF) | Si usamos IA: solo alerta y pasa a un humano |
| **Ley de Ciberseguridad** (RO 290, 22-05-2026) | Reforma LOPDP, COIP y otras; catálogo de infraestructura crítica; CSIRT | Mencionarla da actualidad |
| Política y Estrategia Nacional de Ciberseguridad | Pilar de cultura y educación | Alineación con política pública |
| Accesibilidad | INEN 40500 (WCAG 2.0), RTE INEN 288 | Diseño para adultos mayores |
| Compras y software | Decreto 1014 y Código Ingenios: prelación del software libre | Usar piezas de código abierto |

---

## 6. Qué hicieron otros países
Detalle: [[05 Casos en Latinoamerica]] · [[06 Referentes internacionales]]

| País | Qué pasó | Lección |
|---|---|---|
| Costa Rica 2022 | Conti y Hive tumbaron Hacienda y la CCSS (800 servidores, 9.000 equipos, 28.348 citas afectadas); hospitales volvieron al papel | Continuidad: plan para operar sin sistema. Había 37 advertencias previas de auditoría |
| Brasil 2025 | «Operação Sem Desconto»: R$ 6.300 M en descuentos no autorizados a jubilados, 9 M afectados, con complicidad interna | Respuesta: bloqueo de préstamos por defecto y biometría, aunque la burlaron con fotos manipuladas |
| México 2025 | Venta de datos de ~20 M pensionados del IMSS por uso indebido de accesos de su personal | El riesgo interno es real en seguridad social |
| Argentina | Datos de 45 M del RENAPER filtrados por usuarios con acceso legítimo | Igual: el abuso viene de dentro |
| Chile | Ley 21.663 (2024), agencia ANCI, reporte en 3 h; IPS con campaña «Más vale prevenir» | Regulación fuerte; sin medición del efecto de campañas |
| Colombia | Colpensiones: phishing recurrente, campaña #ActivaTuModoSospecha | Campañas sin medición |
| Singapur | Registro obligatorio de remitentes SMS: **−70 %** de estafas por SMS en 3 meses; espera de 12 h tras activar token | Cambiar el canal funciona más que educar |
| Reino Unido | 58,9 M reportes al buzón de phishing, 460.000 URL retiradas; DMARC bloqueó ~500 M correos de HMRC | Reportar fácil y ver resultado |
| India | Línea 1930 con congelamiento rápido: ₹8.189 crore salvados | Velocidad de respuesta tras el fraude (E4) |
| España | Línea 017 de INCIBE: 138.003 consultas en 2025 (+40 %) | Una línea humana de ayuda escala |
| Estonia | Identidad digital fuerte y aun así €29 M perdidos en 2025 por engaño | La tecnología fuerte sola no basta |

**Conclusión:** los países que bajaron pérdidas cambiaron procesos y canales, no solo educaron. **Ninguna institución latinoamericana publica la medición del efecto de sus campañas.**

---

## 7. Qué dice la ciencia
Detalle: [[07 Evidencia cientifica]]

| No funciona o funciona poco | Sí funciona |
|---|---|
| Capacitación anual: sin relación con el clic (Ho et al. 2025, 19.789 empleados) | Reporte colectivo con un botón: detecta campañas en minutos (Lain et al. 2022, 14.000 empleados) |
| Capacitación que aparece al fallar un simulacro: −2 puntos, y puede empeorar | Avisos dentro del correo o en el momento de riesgo |
| Listas de «señales de estafa»: la gente desconfía más pero no acierta más | Práctica activa con ejemplos reales (inoculación), con refuerzo cada 2-3 semanas: el efecto se va a las 4 semanas |
| Mensajes de miedo y castigo: suprimen el reporte | Mensajes de autoeficacia («qué hacer»), más que de amenaza |
| Gamificación con puntos: sin evidencia de cambio de conducta | Cultura justa: el error no se castiga; el abuso deliberado sí, con consecuencias claras |
| Inoculación por SMS: sin efecto medido | Explicaciones escritas por IA protegen igual que las de expertos (750 personas), con riesgo de exceso de confianza |

**Qué medir:** tasa de reporte y tiempo hasta el primer reporte, no solo la tasa de clic. Comparar siempre con grupo de control.

---

## 8. Gestión del proyecto (visión PMI)
Detalle: [[08 Vision PMI e ingenieria]]

- **Supervivencia:** solo ~5 % de los proyectos de hackatón sigue vivo a los 5 meses. Sobreviven los que tienen patrocinador antes del evento, se integran en un servicio existente y tienen costo recurrente bajo.
- **PMBOK 8 (2025):** dominios de gobierno, alcance, cronograma, finanzas, interesados, recursos y riesgo.
- **Costo de una brecha:** salud es el sector más caro (USD 7,42 M en 2025 según IBM).
- **Interesados clave:** DNSIPD y su OSI (dueño natural), BIESS (préstamos), Dirección de TI, Talento Humano, sindicatos, SPDP, afiliados y jubilados.
- **Compra pública:** rutas de menos a más fricción: desarrollo interno, convenio con universidad, ínfima cuantía (~USD 7.200, cálculo propio), procedimientos normales.
- **Restricciones:** apagones (diseño en tres capas: en línea, voz o SMS, papel), WhatsApp Business cobra por mensaje desde jul-2025, software libre preferido.
- **Ingeniería:** privacidad desde el diseño, desarrollo seguro (NIST SSDF, OWASP SAMM), modelado de amenazas (STRIDE y LINDDUN), WCAG 2.2.

---

## 9. El mapa de soluciones: de lo común a lo atípico
Detalle: [[Indice Soluciones]] · [[07 Tabla maestra]] (90 soluciones)

La posición en la campana mide **qué tan común es**, no qué tan buena. Lo curioso: **cuanto más común, menos efecto medido.**

| Zona | Ejemplos | Evidencia |
|---|---|---|
| **Centro** (lo que hace todo el mundo) | Curso anual, simulacro de phishing con tablero de clics, KnowBe4 y similares (USD 0,6-2 M al año para el IESS, cálculo propio), «el IESS nunca te pedirá tu clave», y en hackatones el detector o chatbot con IA | Poca o ninguna. Es lo que el jurado ya vio |
| **Convergente** (varios países llegaron a lo mismo) | Bloqueo de préstamos por defecto (Brasil: −88 % de reclamos), espera tras cambio de datos (Singapur: −26 % de estafas), aviso al canal anterior, aviso nocturno no punitivo por acceso indebido (reincidencia 40 % → 1,8 %), botón de reporte, inoculación con refuerzo | La mejor, aunque casi toda autoinformada |
| **Periferia** (probado, poco común, inclusivo) | Juego de voz por teléfono (Uganda: fraude 7,1 % → 5,7 %, reporte 23 % → 36 %), radionovela, promotores pares, «ayudante registrado» (procuración de Brasil), protocolo de ventanilla (Reino Unido: £258 M evitados) | Buena para quien no tiene smartphone |
| **Atípico** (raro o trasplantado) | Candado voluntario de préstamos, registros señuelo de «jubilado trampa», canal de casi-incidentes como en aviación, auditoría ciudadana con sorteo, teatro y escape room (96 trabajadores de salud, efecto a un mes) | Sin medición en seguridad social |
| **Atípico negativo** | Simulacro con cebo de bono, Robodebt (526.000 deudas automáticas), SyRI, biometría burlada en Brasil, muro de la vergüenza | Lo que el jurado castigaría |

---

## 10. Dónde convergen y dónde está el hueco
Detalle: [[08 Donde convergen las vertientes]] · [[09 Huecos]]

**Cuatro hilos aparecen en casi todas las vertientes:**
1. **Fricción entre el cambio y el dinero:** tiempo, aviso o segunda persona antes del préstamo.
2. **Ayudante legítimo:** dar permisos acotados en lugar de prestar la clave.
3. **Reporte que cierra el ciclo:** reportar es fácil y la persona ve qué pasó.
4. **Práctica narrativa con refuerzo:** historias y ejemplos reales, repetidos.

**Huecos (nadie lo ha resuelto ni evaluado):**
- La clave prestada **en persona** a un ayudante o tramitador.
- El **servidor cooptado** que cambia cuentas o registra aportes falsos.
- Nada en **kichwa**.
- El **migrante** sin passkey ni agencia cerca.
- El **SMS** como canal para enseñar (la inoculación no funcionó ahí).
- El celular compartido anula los avisos al «canal anterior».

---

## 11. Líneas rojas
Detalle: [[06 Atipicos negativos y lineas rojas]]

- Simulacro con cebo de bono, décimo o aumento de pensión.
- Puntaje opaco de beneficiarios o negativa automática por IA: la IA solo **frena y pasa a un humano**, nunca decide sanciones ni deudas.
- Biometría como prueba suficiente.
- Miedo, compromisos firmados o muro de la vergüenza.
- Listas de «señales de estafa» como solución principal.
- Usar datos reales o tocar sistemas del IESS.

---

## 12. Las 50 ideas de software
Detalle: Brújula, pestaña «Software» (flujo, piezas de código abierto con licencia, demo de 10 minutos, riesgos y costo)

| Región del Venn | Ideas |
|---|---|
| **Seguridad ∩ Educación ∩ Gestión** (8) | S01 Pausa IESS (espera tras cambio de datos) · S05 Pregunta en el momento · S06 Ayudante Registrado · S09 Protocolo de ventanilla digital · S10 «¿Es del IESS?» bot oficial · S14 Radar de campañas · S28 Botón «Reportar al OSI» · S29 Aviso nocturno no punitivo |
| Seguridad ∩ Educación (9) | S02 Candado BIESS · S07 Sesión asistida en cibercafés · S12 «¿Me llamó el IESS?» · S19 Kichwa Rimay · S24 Tu mes en el IESS · S27 Afiliado auditor · S32 Código de coacción · S33 Canal casi-fraude · S34 Guardia IESS (extensión) |
| Seguridad ∩ Gestión (11) | S03 Cuenta-titular · S04 Centinela de secuencia · S08 Persona de confianza · S11 Sello verificable · S15 Reporta y lo bajamos · S20 Vigía de dominio · S23 Llave de viaje (migrantes) · S25 «No reconozco» · S26 Ruta de la víctima · S30 Doble llave · S35 Recertificación de accesos |
| Educación ∩ Gestión (9) | S13 Palabra de familia · S16 «¿Real o falso?» · S17 SMS que enseña · S18 Historias por teléfono (español y kichwa) · S21 Pantalla en sala de espera · S22 Centinela sin conexión · S36 Simulacro con cultura justa · S38 Tablero de cultura OSI · S40 Microcursos por rol |
| Un solo círculo (3) | S31 Jubilado trampa · S37 Escape room · S39 Banco de estafas EC |

**10 ideas nuevas (S41-S50), pensadas para los huecos:**

| ID | Idea | Región | Hueco que ataca |
|---|---|---|---|
| S41 | Presté mi Clave: renovación sin culpa | S∩E∩G | Clave prestada en persona: cierra sesiones, cambia preguntas de recuperación y revisa cambios de 30 días |
| S42 | Reparto Ciego de trámites sensibles | S∩G | Servidor cooptado: el aprobador se sortea con semilla pública y se vigilan pares tramitador-funcionario |
| S43 | Rimak: intérprete kichwa en la ventanilla | S∩E∩G | Kichwa: el intérprete del IESS confirma a solas con el titular, no el «traductor» que trae el ayudante |
| S44 | Doble Ancla Migrante (visto consular) | S∩E | Migrantes: código entregado en el consulado o brigada, porque la selfie con cédula ya no prueba nada |
| S45 | Mi Plan Si-Entonces | E∩G | SMS que no enseña: se ensaya en persona y el SMS solo recuerda la tarjeta escrita a mano |
| S46 | Tarjeta de Confirmación en papel | S∩E∩G | Sin smartphone, celular compartido y apagones: segundo factor en papel |
| S47 | Modo Apagón Seguro | S∩G | Si el aviso no llegó por un apagón, la ventana de espera no corre |
| S48 | Entrenador de Llamadas Difíciles | E∩G | Servidor presionado por teléfono: simulador con modelo local y cultura justa |
| S49 | Aporte con Testigo | S∩G | Aportes falsos: el empleador confirma los aportes retroactivos |
| S50 | Equipo Compartido: modo consulta | S∩E∩G | Cibercafé o tramitador: un equipo con muchas cédulas solo permite consultar |

Datos nuevos para el pitch: el flujo oficial del IESS para el exterior valida con selfie con cédula y video, justo lo que la filtración de más de 10 M de fotos de cédula vuelve débil; en 2012 la Policía detuvo a 14 servidores del IESS y BIESS que liberaron ~USD 1 M usando claves de afiliados; el IESS abrió una brigada en el consulado de Madrid el 27-09-2026.

**Cuidado:** S14, S15 y S20 rozan el Reto 3. Herramientas útiles: Keycloak (passkeys desde v26.4), Asterisk o Jambonz para voz, Omnilingual ASR de Meta reconoce kichwa de Imbabura. RapidPro y n8n ya no son código abierto.

---

## 13. El jurado
Detalle: Brújula, pestaña «Jurado»

El jurado real no está publicado. Armamos 8 perfiles con las instituciones del panel (IESS DNSIPD, SPDP, DINARP, DAMA Ecuador, ISACA Quito, UDLA, USFQ, EPN):

| Perfil | Pesa más | Le encanta | Lo rechaza |
|---|---|---|---|
| Seguridad del IESS (DNSIPD) | Educación | Indicadores de conducta, encaje con el EGSI y el Comité, plan para operar después | Sin métricas ni dueño |
| Regulador de datos (SPDP) | Seguridad | Evaluación de impacto, privacidad desde el diseño, IA con humano | Medir servidores sin base legal |
| Registros públicos (DINARP) | Seguridad | Acceso mínimo y trazable, sin copias de cédulas | Duplicar bases de identidad |
| Gobierno de datos (DAMA) | Gestión | Dueño de cada dato, ficha de cada indicador, retención | Datos sin dueño |
| Auditor (ISACA) | Gestión | Evidencia de que el control funciona, riesgo en dólares | «Tener un control no es que funcione» |
| Académico técnico (EPN) | Seguridad | Modelo de amenazas, desarrollo seguro | Que la herramienta sea un nuevo vector |
| Académico de formación (UDLA/USFQ) | Educación | Kirkpatrick, pruebas con usuarios, accesibilidad | Curso sin evaluación |
| Autoridad del IESS | Gestión | Costo del primer año, protección del jubilado, continuidad | Caro o dependiente de un proveedor |

En promedio pesa más la **gestión** (39 %) que la seguridad (33 %) y la educación (28 %): una diapositiva de costo, dueño y plan posterior rinde mucho.

**Frases y marcos para usar:** EGSI v3, Oficial de Seguridad de la Información, LOPDP, evaluación de impacto, privacidad desde el diseño, supervisión humana, cultura justa, niveles 3 y 4 de Kirkpatrick, NIST SP 800-50 Rev. 1 (2024), COBIT, DMBOK, «preventiva, transversal y medible» (palabras del director de la DNSIPD).

---

## 14. Cómo decidir la idea
Detalle: [[10 Criterios de decision]] · [[09 Criterios de diseno]] · Brújula, pestaña «Clasificar idea»

**Rúbrica que armamos (Venn):** 21 criterios de 0 a 2, siete por círculo. Una idea toca un círculo con **8 de 14** puntos y su criterio puerta en 2 (S1 eslabón cortado, E1 conducta observable, G1 dueño y patrocinador). La inclusión (adultos mayores, rural, kichwa, sin smartphone, apagones) pinta el punto. La Brújula convierte esto en una estimación de la **rúbrica oficial**.

**Preguntas para elegir:**
1. ¿Qué eslabón corta? E2-E3 o EI valen más que E1.
2. ¿Funciona en vivo con los datos sintéticos antes del viernes 16h15?
3. ¿Quién del IESS sería su dueño y qué haría con ella el lunes siguiente?
4. ¿Cuánto cuesta al año y usa canales que el IESS ya tiene?
5. ¿Sirve a un jubilado sin smartphone o durante un apagón?
6. ¿Es distinta de lo que el jurado ya vio (curso, detector, chatbot)?
7. ¿Cómo mediríamos que cambió la conducta (reporte, tiempo, fraudes frenados)?
8. ¿Se queda en el Reto 1 sin invadir el 2 ni el 3?

**Combinación que más se repite en la investigación (no es decisión, es punto de partida):** fricción en el cambio de datos (S01) + ayudante legítimo (S06) + educación en el momento del riesgo (S05) + reporte que cierra el ciclo (S28 o S10), con una capa de voz para quien no tiene smartphone.

---

## 15. Plan del pitch
| Bloque | Viernes (12 min) | Lunes (10 min) |
|---|---|---|
| Problema y usuarios | 5 min: un caso de jubilado, la cadena E1-E4, las cifras | 3 min: impacto en personas y en dinero |
| Demo | 3 min en vivo con datos sintéticos | 3 min, la misma versión (sin funciones nuevas) |
| Por qué funciona | Evidencia y ley en una diapositiva | Aplicabilidad: dueño, canal, costo, plan de 90 días |
| Preguntas | 3 min | Lo que pida el jurado |

---

## 16. Lo que no sabemos
Detalle: [[10 Preguntas abiertas]]
- El texto exacto de la ficha del Reto 1 y los datos sintéticos (se entregan hoy).
- La composición real del jurado.
- Si el IESS ya mide algo de conducta de sus servidores (IESSEDUCA).
- Cifras de fraude por edad en Ecuador, salvo el 30 % de Asobanca.
- Si los registros señuelo, la inmunidad por reportar o los sorteos son legales en Ecuador.
- Cuántos afiliados del Seguro Social Campesino hablan kichwa.

---

## Fuentes
Informes completos en [[Indice Fuentes]]: estudio del problema, mapa de soluciones y notas crudas (rúbrica, catálogo de software, jurado, vulnerabilidad). Todas las cifras llevan año y fuente en sus notas de detalle.
