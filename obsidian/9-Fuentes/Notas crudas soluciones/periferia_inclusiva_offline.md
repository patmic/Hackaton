# Soluciones periféricas pero probadas: canales inclusivos, de baja tecnología y resistentes a apagones para cultura antifraude (Reto 1 IESS)

> Alcance: catálogo de canales y enfoques comunitarios que llegan a mayores, población rural, indígena, de baja alfabetización y con poca conectividad, con evidencia 2015-2026. Fecha de corte: 25-11-2026. Escala usada: CENTRO (práctica dominante de cultura de seguridad), CONVERGENTE (se está acercando al centro), PERIFERIA (probada en otro sector o población, poco usada en ciberseguridad institucional), ATÍPICO (rara, sin precedentes claros en el sector). La asignación de escala y el "encaje IESS" son inferencias del investigador, no datos de las fuentes.
>
> Criterios de diseño del estudio previo que condicionan este catálogo ([informe local "Cultura de ciberseguridad IESS"]): atacar conductas concretas (prestar la clave, cambio de contacto/cuenta, mensajes con marca IESS); inclusión como condición de entrada (30 % de mayores con dificultad funcional, analfabetismo indígena 11,9 %); resiliencia ante apagones de 14 h (camino sin conexión, agencias y salas de espera); que la solución no pueda ser imitada por estafadores (sin enlaces de cobro ni pedido de claves); costo recurrente asumible; demostrable con datos ficticios.

## 1. Voz (IVR), USSD, SMS simple y llamada perdida para inclusión financiera y servicios públicos con uso antifraude

### Takeaway
La evidencia más fuerte de todo este catálogo es de voz: un juego IVR de historias interactivas en Uganda (IPA + Viamo, 2025) redujo la victimización por fraude de 7,1 % a 5,7 % y subió 50 % el reporte, sin necesidad de alfabetización ni smartphone, a un costo de desarrollo menor a USD 150.000 y costo marginal casi nulo. En cambio, los "consejos para detectar estafas" por texto no mejoran la precisión (Kenia, 2023) y solo vuelven a la gente más desconfiada; no encontré IVR antifraude en kichwa, quechua o lenguas mayas.

### Cited Findings

**Ficha 1.1 – IVR "Beera Mubangule" (Sé consciente), Uganda**
- Quién/dónde: Innovations for Poverty Action (IPA) con Viamo; entregado por la plataforma 161 de Airtel, Uganda; publicado 28-03-2025 (autores Rafe Mazer, Matthew Bird, Anthony Kamwesigye, Jessica Massie) — [IPA, 2025](https://poverty-action.org/how-interactive-storytelling-protecting-ugandans-mobile-money-fraud)
- Cómo funciona: historias de audio tipo "elige tu propia aventura" por IVR; el usuario responde con el teclado en momentos clave y la historia cambia; marco "Stop, Check, Act" (detente, consulta a alguien de confianza, actúa); juego de dos niveles de unos 18 minutos — [IPA, 2025](https://poverty-action.org/how-interactive-storytelling-protecting-ugandans-mobile-money-fraud); [GASA](https://gasa.org/knowledge-base/blog/what-ugandas-ivr-trial-shows-about-practice-based-scam-prevention)
- Público: usuarios de dinero móvil con baja alfabetización, sin smartphone, rurales — [GASA](https://gasa.org/knowledge-base/blog/what-ugandas-ivr-trial-shows-about-practice-based-scam-prevention)
- Evidencia (tratamiento vs. control, todo estadísticamente significativo según IPA): pérdida de dinero por fraude 7,1 % → 5,7 % (mujeres 8,3 % → 5,7 %); reporte de fraude 35,6 % vs. 23,2 %; quejas formales 24,7 % vs. 18,7 %; compartir PIN/teléfono/SIM 19,7 % → 17,6 %; verificación de registro SIM 21,2 % → 24,9 %; ahorro en dinero móvil 37 % → 39,9 %; 93 % de quienes empezaron completaron ambos niveles y 58 % repitió — [IPA, 2025](https://poverty-action.org/how-interactive-storytelling-protecting-ugandans-mobile-money-fraud). La página no indica tamaño muestral ni si fue aleatorizado formalmente (habla de grupo de tratamiento y control).
- Hallazgo clave para el IESS: la conciencia sobre fraude no redujo la confianza en las finanzas digitales — [GASA](https://gasa.org/knowledge-base/blog/what-ugandas-ivr-trial-shows-about-practice-based-scam-prevention)
- Costo: prueba y desarrollo de contenido < USD 150.000; costo marginal por usuario casi cero si la operadora libera (zero-rating) voz/SMS; proyección para 1 millón de usuarios: ~14.000 víctimas menos y USD 546.000 en pérdidas evitadas — [IPA, 2025](https://poverty-action.org/how-interactive-storytelling-protecting-ugandans-mobile-money-fraud). Viamo opera IVR en más de 20 mercados, adaptable por traducción — [GASA](https://gasa.org/knowledge-base/blog/what-ugandas-ivr-trial-shows-about-practice-based-scam-prevention)

**Ficha 1.2 – Experimento sobre "consejos antiestafa", Kenia (evidencia negativa)**
- Quién/dónde: Kubilay y Raiber et al., experimento en línea con ~1.000 participantes en Kenia, Journal of Development Economics/Public Economics 2023 (la columna VoxEU/CEPR lo resume; hay variación en cómo se cita la autoría y la revista) — [VoxEU/CEPR](https://cepr.org/voxeu/columns/financial-fraud-developing-countries-common-scam-detection-tips-do-not-help); [Essex repository](https://repository.essex.ac.uk/35913/1/1-s2.0-S0304387823001025-main.pdf)
- Cómo: los participantes clasificaban mensajes reales (estafas y oficiales); a la mitad se le daban los consejos habituales (errores ortográficos, remitente desconocido, enlace acortado, pedido de datos privados) — [VoxEU/CEPR](https://cepr.org/voxeu/columns/financial-fraud-developing-countries-common-scam-detection-tips-do-not-help)
- Evidencia: los consejos no mejoran la capacidad de distinguir estafa de mensaje genuino; vuelven más cautelosos (todo parece estafa), marcan como estafa mensajes legítimos que contienen un "marcador", y aumentan la confianza en las propias respuestas sin mejorar la precisión — [VoxEU/CEPR](https://cepr.org/voxeu/columns/financial-fraud-developing-countries-common-scam-detection-tips-do-not-help)
- Recomendación de los autores: que los mensajes legítimos de los proveedores eviten los "marcadores de estafa" — [VoxEU/CEPR](https://cepr.org/voxeu/columns/financial-fraud-developing-countries-common-scam-detection-tips-do-not-help)

**Ficha 1.3 – Diseño de USSD contra fraude, Kenia (recomendación, no programa)**
- Presentación CGAP/Fraud-Vigilance Kenya recomienda menús en idiomas locales y alargar los tiempos de sesión USSD (diseño, no evaluación) — [CGAP, "Doing Digital Finance Right" 2015](https://www.cgap.org/sites/default/files/publications/multimedia/CGAP_Annual_Report_2015/files/strategy-highlights/focus-note-doing-digital-finance-right-jun-2015.pdf); [CGAP blog fraude](https://www.cgap.org/blog/fraud-in-digital-finance-crisis-calling-for-ecosystem-solutions)
- Safaricom lanzó en septiembre de 2025 "Fintech 2.0" con IA para detección de fraude en M-Pesa (control técnico, no educativo) — según resumen de búsqueda sobre [Visa Economic Empowerment Institute](https://corporate.visa.com/en/sites/visa-economic-empowerment-institute/fraud-undermines-financial-inclusion.html) (no verificado en fuente primaria)
- Perú: 11 % de usuarios que sufrieron fraude dejaron de usar servicios financieros digitales y 25 % redujo su uso (dato CGAP citado) — [Visa EEI](https://corporate.visa.com/en/sites/visa-economic-empowerment-institute/fraud-undermines-financial-inclusion.html)

**Ficha 1.4 – Líneas de voz y asistentes en lenguas originarias, Perú**
- Línea Social 101 del MIDIS: gratuita, informa elegibilidad, afiliación y trámites de programas sociales (Juntos, etc.) y recibe alertas/denuncias de fraude; en 2025 recibía más de 1.000 llamadas malintencionadas al mes — [Andina](https://andina.pe/agencia/noticia-midis-pide-uso-responsable-linea-101-informa-sobre-tramites-programas-sociales-1063330.aspx); [El Peruano](https://www.elperuano.pe/noticia/289328--midis-impulsa-campana-para-el-uso-responsable-de-la-linea-gratuita-social-101)
- "MarIA", chatbot con IA del programa Juntos, responde 24 h en castellano y quechua (texto, no voz) — [El Peruano](https://elperuano.pe/noticia/295134-maria-el-chatbot-con-inteligencia-artificial-del-programa-juntos-que-orientara-las-24-horas)
- Línea 1855 del MTC atiende en castellano, quechua y aimara (tema antenas, no programas sociales) — [Expreso Perú](https://www.expreso.com.pe/actualidad/mtc-lanza-linea-telefonica-de-orientacion-sobre-antenas-de-telecomunicaciones/)
- Banco de la Nación (Perú) publica una sección "Alto al fraude" — [BN](https://www.bn.com.pe/altoalfraude/seguridad-publicidad-enganosa.asp)

### Inferences
- **Encaje IESS (1.1 IVR narrativo):** muy alto. Reproducible como "Juego de voz IESS" en castellano y kichwa sobre los tres guiones reales (el "ayudante" que pide la clave, la llamada que pide cambiar la cuenta, el SMS de reembolso). Funciona en teléfono básico (cubre al 42 % sin smartphone) y con baterías durante apagones, aunque depende de que la red celular siga activa. Demostrable en la final con un número de prueba o simulador web de IVR. Riesgo: que un estafador imite la línea; mitigación con un número corto oficial único que solo recibe llamadas (nunca llama). **Escala: PERIFERIA** (probado en inclusión financiera, ausente en seguridad social de la región).
- **Encaje (1.2):** convierte un hallazgo negativo en criterio de diseño: el IESS debe auditar sus propios SMS/correos para que no contengan enlaces acortados ni pidan datos, y el programa debe enseñar una acción ("cuelga y llama al número impreso") en vez de una lista de señales. **Escala: CONVERGENTE** (la idea de "procedimiento, no señales" se está acercando al centro).
- **Encaje (1.4):** el IESS ya tiene call center; añadir un menú IVR en kichwa con mensaje fijo antifraude ("el IESS nunca te pide la clave") es de bajo costo. **Escala: PERIFERIA.**
- **Llamada perdida (missed call):** no encontré ejemplos antifraude documentados; un "llama y cuelga a este número y te devolvemos una llamada grabada del IESS" sería **ATÍPICO** y tiene el riesgo de cobrar saldo o de normalizar devoluciones de llamada (vector de estafa wangiri).

### Gaps
- No encontré programas IVR/USSD antifraude en kichwa, quechua, aimara o lenguas mayas, ni en Bolivia ni Guatemala.
- No encontré evaluaciones de las campañas de educación antifraude de M-Pesa/Safaricom ni de India (missed-call, IVR) dentro del tiempo disponible.
- No verifiqué si el estudio de Uganda fue un RCT formal ni su tamaño muestral (la página de IPA no lo dice).
- No obtuve tarifas de IVR/SMS de operadoras ecuatorianas (Claro, Movistar, CNT) ni la existencia de números cortos gratuitos para el IESS.

## 2. Radio comunitaria y edu-entretenimiento (radionovelas, telenovelas) para educación financiera/antifraude

### Takeaway
Las telenovelas con mensajes financieros tienen evaluaciones aleatorizadas con efectos acotados a los temas tratados ("Scandal!" Sudáfrica; "Josefa" Perú rural), y la identificación emocional con los personajes es el mecanismo que importa. En Ecuador existe una red de radios comunitarias kichwa (CORAPE) con antecedentes en educación financiera, pero no encontré campañas antifraude ni evaluaciones de impacto.

### Cited Findings

**Ficha 2.1 – "Scandal!" (telenovela con trama financiera), Sudáfrica**
- Quién/dónde: Gunhild Berg y Bilal Zia (Banco Mundial), evaluación aleatorizada con diseño de estímulo simétrico: un grupo fue invitado a ver la telenovela con mensajes financieros y otro una telenovela similar sin ellos; documento de trabajo 2013, publicado en revista 2017 (las fuentes difieren en el año) — [World Bank Open Knowledge](https://openknowledge.worldbank.org/bitstreams/aaee66f9-021f-5c45-bd35-35adbc1fbe7e/download); [IGC/LSE](https://researchonline.lse.ac.uk/id/eprint/81913/1/Fighting%20poverty%20with%20soap%20operas%20-%20IGC.pdf)
- Evidencia: espectadores ~9 pp más propensos a pedir préstamos a instituciones formales, ~5 pp menos a apostar, 4 pp más a evitar compras a plazos; mejor conocimiento solo en los temas destacados de la trama, sin efecto en alfabetización financiera general ni en búsqueda de asesoría (atribuido a un personaje externo que no conectó emocionalmente) — [World Bank](https://openknowledge.worldbank.org/bitstreams/aaee66f9-021f-5c45-bd35-35adbc1fbe7e/download); [NextBillion](https://nextbillion.net/soap-operas-and-cell-phones/)
- Fecha fuera de rango estricto (2013-2017); se incluye por ser la referencia clásica.

**Ficha 2.2 – "Josefa", telenovela de ahorro en zonas rurales de Perú**
- Quién: Alberto Chong y Martín Valdivia (GRADE), telenovela de cinco episodios con asignación aleatoria a mujeres rurales — [GRADE](https://grade.org.pe/en/publicaciones/edutainment-savings-and-empowerment-in-rural-areas-of-peru/); [CEDLAS](https://www.cedlas.econo.unlp.edu.ar/wp/wp-content/uploads/Valdivia-Chong.pdf)
- Evidencia: mejores actitudes pro ahorro y empoderamiento de la mujer en el hogar; no aumentó la confianza en instituciones financieras — [GRADE](https://grade.org.pe/en/publicaciones/edutainment-savings-and-empowerment-in-rural-areas-of-peru/)

**Ficha 2.3 – "Mucho Corazón", México**
- Telenovela apoyada por el Banco Mundial (2014), solo evaluación cualitativa: quienes más se identificaban con los personajes tendían más a cambiar de conducta — [World Bank, 2014](https://www.worldbank.org/en/results/2014/09/04/using-a-soap-opera-as-a-vehicle-for-financial-education-in-mexico) (fuera del rango 2015-2026).
- En Camboya, televisión para trabajadoras textiles podría transmitir alfabetización financiera básica de forma costo-efectiva — [IMTFI/UCI](https://www.imtfi.uci.edu/files/docs/2015/Pushkar_Crawford%20et%20al_Final%20Report.pdf)

**Ficha 2.4 – CORAPE y la Red Kichwa, Ecuador**
- La Coordinadora de Radio Popular Educativa del Ecuador (CORAPE) se constituyó legalmente en 1990, con raíces en las Escuelas Radiofónicas Populares del Ecuador (ERPE) de Mons. Leónidas Proaño (alfabetización); su Red Kichwa está formada mayoritariamente por radios de hablantes kichwa — [UPS, tesis](https://dspace.ups.edu.ec/bitstream/123456789/2565/6/UPS-QT00731.pdf)
- Informe del Consejo de Comunicación (2017) sobre acciones afirmativas para medios comunitarios menciona programas de educación financiera y una reunión de coordinación entre una institución financiera y CORAPE (sin detalle de idioma ni resultados) — [Consejo de Comunicación, 2017](https://repositorio.consejodecomunicacion.gob.ec/bitstream/CONSEJO_REP/226/1/informe_acciones_afirmativas_comunitarios_2017.pdf)
- Radio comunitaria en pandemia en Ecuador como canal de información en zonas rurales — [UPS](https://dspace.ups.edu.ec/bitstream/123456789/20972/4/RADIO%20COMUNITARIA%20EN%20PANDEMIA.pdf)

### Inferences
- **Encaje IESS (radionovela kichwa/castellano con CORAPE):** alto para el SSC; la radio a pilas o en el celular sin datos funciona durante apagones, a diferencia del internet. Una serie corta de 5 episodios (formato Josefa) con un personaje jubilado campesino y un "ayudante" que pide la clave ataca la conducta crítica. La evidencia indica que solo cambia lo que la trama muestra explícitamente, así que cada episodio debe cerrar con una única acción. Combinable con el IVR narrativo (ficha 1.1): el mismo guion en radio y en juego de voz. Costo: no encontré tarifas de producción ni pauta en CORAPE. **Escala: PERIFERIA.**
- La ausencia de efecto en "confianza en instituciones" (Josefa) y el temor a que la educación antifraude asuste (refutado en Uganda) sugieren medir ambos indicadores.

### Gaps
- No encontré campañas de CORAPE sobre fraude, ciberseguridad ni seguridad social, ni costos de producción/pauta.
- No encontré evaluaciones J-PAL/IPA de radionovelas antifraude en América Latina ni del "MTV Shuga" aplicado a finanzas (no buscado por límite de tiempo).
- No hay cifra de cuántos afiliados del SSC escuchan radio comunitaria.

## 3. Promotores comunitarios, educadores pares y programas intergeneracionales

### Takeaway
El formato "monitores pares" en seguridad social existe (IPS Chile, campaña "Pago Seguro" con PDI y Senama) y los programas donde universitarios enseñan a mayores muestran mejoras en alfabetización digital, pero las evaluaciones son pre/post con muestras pequeñas y ninguna mide fraude. Plan Ibirapitá (Uruguay) tiene escala (227.000 tabletas, 3.227 talleres) pero no evaluación de impacto independiente localizada.

### Cited Findings

**Ficha 3.1 – Campaña "Pago Seguro" y formación de monitores, IPS Chile (Tarapacá)**
- Quién: Instituto de Previsión Social (IPS) con Senama y la Brigada de Delitos Económicos de la PDI; taller de cierre en Iquique dirigido por la directora regional del IPS — [Mintrab Chile](https://www.mintrab.gob.cl/pgm/CanalRegional/Tarapaca/formacion-de-monitores-pone-fin-a-campana-de-prevencion-de-estafas-del-ips/)
- Cómo: forma "monitores preventivos" entre dirigentes de clubes y asociaciones de pensionados para replicar mensajes entre pares; incluyó obra de teatro sobre estafas y robos a mayores, orientación del IPS sobre cobro seguro de pensiones, señales de vulneración de derechos (Senama) y técnicas de estafa (PDI) — [Mintrab Chile](https://www.mintrab.gob.cl/pgm/CanalRegional/Tarapaca/formacion-de-monitores-pone-fin-a-campana-de-prevencion-de-estafas-del-ips/)
- Evidencia: sin cifras de alcance ni resultados; solo testimonio de una participante. La página no muestra fecha de publicación — [Mintrab Chile](https://www.mintrab.gob.cl/pgm/CanalRegional/Tarapaca/formacion-de-monitores-pone-fin-a-campana-de-prevencion-de-estafas-del-ips/)
- Similares: Ministerio de Seguridad de Mendoza (Argentina) recorre centros de jubilados con charlas sobre estafas telefónicas y datos personales, en sus reuniones habituales — [Gobierno de Mendoza](https://www.mendoza.gov.ar/prensa/el-ministerio-de-seguridad-y-justicia-recorre-centros-de-jubilados-con-charlas-para-prevenir-fraudes-y-estafas/); SERNAC Ñuble (Chile), diálogo participativo "Seguridad en tus manos" con mayores, 2025 — [SERNAC](https://www.sernac.cl/portal/604/w3-article-86229.html)

**Ficha 3.2 – Charlas del Seguro Social Campesino (capacidad instalada, no antifraude)**
- El IESS documenta charlas educativas en dispensarios del SSC de Sucumbíos sobre salud bucal, cáncer de mama e hipertensión — [IESS, "Compromiso con la comunidad"](https://iess.gob.ec/documents/10162/25839896/Compromiso+con+la+comunidad%28Charlas+Educativas%29)
- No encontré material del IESS o del SSC sobre charlas antifraude para jubilados rurales (búsqueda en esta sesión).

**Ficha 3.3 – Programas intergeneracionales (universitarios enseñan a mayores)**
- Chile: intervención de cinco sesiones presenciales más refuerzo remoto por tres meses, impartida por universitarios capacitados a personas de 60+; efecto significativo en alfabetización digital (r = 0,27) en el grupo experimental (pre/post) — [Frontiers in Psychology, 2024](https://www.frontiersin.org/articles/10.3389/fpsyg.2024.1305569/full)
- Chile: piloto cuasi-experimental de cuatro sesiones sobre uso del smartphone con 71 participantes de 60+; los autores concluyen que programas pequeños, personalizados y participativos reducen la brecha digital gris — [Universidad de Atacama, repositorio](https://repositorioacademico.uda.cl/bitstreams/4510b862-a5e3-40c7-9cb8-adc595d38e05/download)
- España: "Digi-Life", universitarios forman a mayores en competencias digitales; mejora la autonomía digital y la comprensión de los estudiantes sobre esta población; muestra pequeña (21 mayores, 18 estudiantes) — [Revista RIO, 2025](https://www.revista-rio.org/index.php/revista_rio/article/download/480/550/2506)
- Uruguay, Plan Ibirapitá (BPS/Presidencia): tabletas gratuitas a jubilados de bajos ingresos con talleres; 227.000 tabletas y 3.227 talleres al cuarto aniversario; meta original 400.000 en cinco años; luego reemplazo por teléfonos celulares — [gub.uy, 4 años](https://www.gub.uy/ministerio-trabajo-seguridad-social/comunicacion/noticias/amaro-es-derecho-tenemos-quedar-margen-avances-tecnologicos); [BPS](https://www.bps.gub.uy/19620/programa-ibirapita:-nuevos-digitos-habilitados.html)
- Ibirapitá: un artículo predice (no mide) que la tableta es la variable de infraestructura con mayor efecto individual sobre la brecha gris de mujeres de 65+ — [Informatio, 2019 vía DOAJ](https://doaj.org/article/d5cc872d977844a6b56864efcffc366b); tesis cualitativa sobre vínculos sociales en Maldonado — [Udelar](https://sifp.psico.edu.uy/sites/default/files/trabajos_finales/archivos/version_definitiva_tfg_ana_perez.pdf)

### Inferences
- **Encaje IESS (monitores pares en clubes de jubilados y dispensarios SSC):** alto y barato. El SSC ya tiene 659 dispensarios con rutina de charlas de salud: añadir un módulo de 10 minutos "mi clave es mía" y formar un monitor por organización campesina replica el modelo IPS Chile. La debilidad es la misma que en Chile: nadie mide resultados. La propuesta del hackatón podría aportar justamente la medición (encuesta corta pre/post por IVR, reportes de intentos). **Escala: CONVERGENTE** (charlas a jubilados son comunes; monitores pares con medición, no).
- **Encaje (intergeneracional):** las universidades del panel (UDLA, USFQ, EPN) pueden aportar estudiantes en vinculación con la sociedad o prácticas preprofesionales que enseñen a mayores en salas de espera y clubes. La evidencia chilena apoya formato corto + refuerzo remoto. Ojo: el estudiante no debe convertirse en otro "ayudante" que conoce la clave; el guion debe prohibir pedirla. **Escala: PERIFERIA** para seguridad (convergente para alfabetización digital).
- Ibirapitá muestra que repartir dispositivos sin componente de seguridad crea nuevos objetivos; el IESS no debería replicar entrega de equipos.

### Gaps
- No encontré evaluaciones de "Mayores Conectados" (España) ni de "Conectando Generaciones" (Chile) por nombre.
- No encontré información sobre brigadas del Registro Civil o del CNE en Ecuador como canal para mensajes de seguridad, ni sobre redes parroquiales o juntas parroquiales en temas de fraude.
- No encontré datos sobre corresponsales no bancarios ("Mi Vecino", "Tu Banco Banco Aquí") como educadores antifraude en Ecuador.

## 4. Intervenciones en el punto de servicio: ventanillas, cajeros de banco, salas de espera

### Takeaway
El "Banking Protocol" británico es el ejemplo mejor documentado de intervención en ventanilla: entre 2016 y 2022 los empleados de sucursal hicieron 45.488 llamadas de emergencia a la policía, evitaron £258,2 millones en fraude y llevaron a 1.202 detenciones. En Canadá y Australia los bancos capacitan al personal (CBA "Safe and Savvy", BMO, TD), pero no encontré resultados medidos independientes; tampoco encontré evaluaciones de intervenciones en salas de espera de salud.

### Cited Findings

**Ficha 4.1 – Banking Protocol, Reino Unido**
- Quién: UK Finance, National Trading Standards y las policías locales; desde octubre de 2016 — [UK Finance, 2023](https://www.ukfinance.org.uk/news-and-insight/press-release/over-ps55-million-fraud-prevented-in-2022-rapid-response-scheme)
- Cómo: el personal de sucursal (y de oficinas de correo/sociedades de crédito) detecta a un cliente que retira o transfiere una suma inusual bajo presión (estafas de suplantación a mayores y vulnerables), llama a un número policial de emergencia, la policía acude a la sucursal y puede detener a sospechosos presentes — [UK Finance](https://www.ukfinance.org.uk/blogs/benefits-banking-protocol); [Action Fraud](https://www.actionfraud.police.uk/news/100-million-of-fraud-stopped-through-bank-branch-rapid-response-scheme)
- Evidencia (cifras autorreportadas por la industria): 2018: £38 M evitados y 231 detenciones — [Action Fraud](https://www.actionfraud.police.uk/news/bank-branch-response-scheme-prevents-victims-losing-38m-to-fraud-in-2018); 2020: £45,3 M, acumulado £142 M y 843 detenciones — [UK Finance](https://www.ukfinance.org.uk/press/press-releases/finance-industry-and-police-team-stop-over-%25C2%25A345-million-fraud-2020); 2021: £60,7 M y 162 detenciones, acumulado £202,8 M y 1.005 — [UK Finance](https://www.ukfinance.org.uk/press/press-releases/over-%25C2%25A3200-million-fraud-stopped-rapid-scam-response-scheme); 2022: £55,5 M y 11.643 llamadas; acumulado £258,2 M, 1.202 detenciones y 45.488 llamadas — [UK Finance, 2023](https://www.ukfinance.org.uk/news-and-insight/press-release/over-ps55-million-fraud-prevented-in-2022-rapid-response-scheme)
- No encontré cifras de 2023-2025 en esta búsqueda. Las cifras no tienen grupo de comparación (son montos interceptados, no reducción neta de fraude).

**Ficha 4.2 – Personal bancario en Canadá y Australia**
- Canadá: TD introdujo un formulario para retiros grandes en efectivo contra la "estafa del nieto"; una sucursal BMO bloqueó un retiro de miles de dólares; la Asociación de Banqueros dice que el personal está entrenado para "hacer preguntas" ante transacciones inusuales — [CTV News](https://toronto.ctvnews.ca/here-s-how-canada-s-big-six-banks-are-responding-to-the-grandparent-scam-1.6603428). BMO desplegó protocolos de primera línea a nivel nacional (premio Innovatio 2019, autoevaluación) — [Canadian Lawyer](https://www.canadianlawyermag.com/surveys-reports/innovatio-awards/2019-innovatio-awards-company-wide-leadership/bmo-financial-group-2019-innovatio-award-winner/304394)
- Australia: Commonwealth Bank, programa "Safe and Savvy" (2018), capacitación para identificar abuso financiero de mayores en casi 1.000 sucursales — [CBA](https://www.commbank.com.au/guidance/newsroom/cba-response-to-call-for-elder-abuse-action-201806.html); guía sectorial de la Australian Banking Association sobre abuso financiero — [ABA](https://ausbanking.org.au/banks-unite-to-help-customers-experiencing-financial-abuse); la Comisión de Reforma Legal (ALRC) recogió que capacitar al personal fue la medida más sugerida — [ALRC Report 131](https://www.alrc.gov.au/publication/elder-abuse-a-national-legal-response-alrc-report-131/9-banking/the-reasonable-steps/)
- Canadá 2026: código de conducta para prevenir el abuso económico (informe NIA) — [National Institute on Ageing, 2026](https://niageing.ca/wp-content/uploads/2026/03/031826_Code-of-Conduct-for-the-Prevention-of-Economic-Abuse_Report.pdf)

### Inferences
- **Encaje IESS ("Protocolo de ventanilla IESS/BIESS"):** alto. El equivalente ecuatoriano sería que el personal de agencias del IESS y del BIESS, ante un cambio de cuenta bancaria, correo o teléfono hecho por un tercero, o un préstamo quirografario pedido con acompañante insistente, aplique un guion ("¿alguien más conoce su clave?") y una ruta de derivación (Fiscalía/Policía, bloqueo temporal). Ataca el punto exacto del fraude documentado (cambio de datos + cobro). Requiere acuerdo interinstitucional, no tecnología; la propuesta del hackatón puede aportar el guion, la tarjeta de decisión del servidor y el tablero de casos. **Escala: PERIFERIA** en seguridad social latinoamericana (en banca británica es CENTRO).
- **Salas de espera (102 unidades médicas, 16,9 M de atenciones en 2025):** lugar natural para la radionovela en pantalla/altavoz, el juego de voz con código QR y número corto, y los monitores estudiantiles. No encontré evaluaciones de intervenciones antifraude en salas de espera de salud. **Escala: ATÍPICO** como canal antifraude.

### Gaps
- Cifras 2023-2025 del Banking Protocol y cualquier evaluación independiente.
- Evaluaciones de intervenciones en farmacias, puntos de pago o salas de espera de hospitales.
- Volumen de trámites presenciales del IESS/BIESS de cambio de cuenta o datos.

## 5. Ayudas físicas y analógicas: tarjetas de verificación, adhesivos con el número oficial, palabra clave familiar, compromisos escritos

### Takeaway
La "palabra secreta familiar" es recomendada por el FBI, expertos y campañas (Stay Safe Online), pero no encontré ninguna evaluación de su efectividad; para tarjetas de verificación, adhesivos con el número oficial o compromisos escritos "no comparto mi clave" tampoco hallé evidencia empírica. Son baratos, resisten apagones y son coherentes con el hallazgo de Kenia (enseñar una acción, no señales), pero su efecto es una suposición.

### Cited Findings
- El FBI recomienda acordar una palabra o frase secreta familiar contra suplantación con voz clonada (reporte secundario) — [PC Gamer](https://pcgamer.com/software/ai/fbi-recommends-coming-up-with-a-secret-word-or-phrase-to-make-sure-your-family-know-youre-you-and-not-some-hellish-ai-copycat)
- Scientific American aconseja acordar la contraseña en persona; Hany Farid sugiere "pruebas sorpresa" periódicas para no olvidarla — [Scientific American](https://www.scientificamerican.com/article/a-safe-word-can-protect-against-ai-impostor-scams/); [Yahoo UK](https://uk.news.yahoo.com/ai-voice-scammers-posing-loved-163642532.html)
- ESET advierte que la palabra segura no impide el deepfake pero puede reducir el éxito de la estafa — [WeLiveSecurity/ESET](https://www.welivesecurity.com/en/cybersecurity/safe-word-what-why-need-one/)
- Campaña "Safe Word" de la National Cybersecurity Alliance — [Stay Safe Online](https://www.staysafeonline.org/campaigns/safeword)
- Caso de octubre de 2026 de una familia que adoptó palabra segura tras una estafa de secuestro con voz clonada (caso único, no estudio) — [Fortune, 24-10-2026](https://fortune.com/2026/10/24/ai-voice-cloning-scam-fake-kidnapping-safe-word/)
- La SSA de EE. UU. difunde en español mensajes fijos: el Seguro Social nunca amenaza con arresto ni suspende el número — [SSA español](https://www.ssa.gov/espanol/estafas/); [SSA, 2026](https://www.ssa.gov/news/es/mip/2026-06-01-b.html)

### Inferences
- **Encaje IESS ("Kit de bolsillo"):** tarjeta impresa (tamaño cédula) entregada en dispensarios y agencias con: (a) los únicos números y dominio oficiales del IESS; (b) tres frases fijas ("el IESS nunca te pide la clave, nunca te pide cambiar tu cuenta por teléfono, nunca te cobra por un trámite"); (c) espacio para la palabra clave familiar; (d) un compromiso firmado "mi clave es solo mía; si alguien me ayuda, uso el registro de apoderado". Adhesivo para el teléfono con el número oficial. Funciona sin luz ni datos y es legible por un familiar si la persona no lee (añadir pictogramas). Costo: impresión, muy bajo. Riesgo: el estafador puede imprimir tarjetas falsas con otro número; mitigar con el número impreso en documentos oficiales ya en poder del afiliado (carné, rol de pago). **Escala: PERIFERIA** (palabra clave familiar es CONVERGENTE en consumo; tarjetas en seguridad social, periféricas).
- La palabra clave familiar es especialmente pertinente para migrantes (remesas récord, trámites a distancia): acuerdo entre el migrante y el jubilado para verificar llamadas de "familiar en apuros".
- Medir: se podría probar en un piloto A/B por dispensario (con tarjeta vs. sin tarjeta) usando reportes de intentos de fraude.

### Gaps
- No encontré estudios que midan el efecto de la palabra clave familiar, de tarjetas de verificación impresas, adhesivos o compromisos escritos sobre la victimización.
- No verifiqué en fuente primaria la recomendación del FBI ni si la FTC la recomienda.

## 6. Diseño para apagones y pocos datos: offline-first, SMS de respaldo, procedimientos impresos, lecciones CCSS Costa Rica

### Takeaway
Los apagones de 2024 en Ecuador degradaron la red móvil y el internet fijo (las operadoras no pudieron garantizar el servicio y propusieron el SMS gratuito como canal de urgencia), y el ataque de ransomware a la CCSS (2022) mostró que el "plan B digital" falla si también cae: los hospitales volvieron al papel. Para el Reto 1, eso favorece canales que no dependan del internet (radio, voz, SMS, papel) y rutinas de procedimiento impresas.

### Cited Findings
- Ecuador 2024: cortes de hasta 14 horas; el ministro de Telecomunicaciones los describió como intermitencia, no suspensión total — [Teleamazonas, 31-10-2024](https://www.teleamazonas.com/entrevista-cesar-martin-ministro-telecomunicaciones-internet-apagones/)
- Las antenas dependen de energía; las baterías y generadores de respaldo son limitados; las operadoras admitieron que no podían garantizar internet fijo y móvil durante los cortes — [Primicias](https://primicias.ec/noticias/economia/telefonia-celular-internet-movil-cortes-luz-ecuador); [Teleamazonas](https://www.teleamazonas.com/telefono-celular-no-funciona-sin-luz-razon/)
- Asetel propuso enviar SMS gratuitos por ser el medio técnicamente más adecuado para comunicación urgente — [Expreso](https://www.expreso.ec/actualidad/economia/apagones-telefonicas-acuerdos-depago-remediacion-servicio-218829.html); las empresas invirtieron USD 27 M en respaldo energético y GSMA pidió coordinar horarios de corte — [Extra](https://www.extra.ec/noticia/ecuador/cortes-luz-gsma-pide-coordinar-horarios-mantener-servicio-movil-ecuador-115190.html)
- El apagón nacional causó intermitencias en la página del SRI (servicio público en línea) — [Primicias](https://www.primicias.ec/noticias/economia/apagon-nacional-ecuador-cortes-luz-sri)
- CCSS Costa Rica: ataque de Hive el 31-05-2022; se apagaron todos los sistemas y los hospitales volvieron al expediente de papel — [WeLiveSecurity](https://www.welivesecurity.com/la-es/2022/06/01/ransomware-hive-ataca-ccss-costa-rica/); [Nación](https://www.nacion.com/el-pais/salud/hospitales-de-ccss-vuelven-a-usar-expedientes/CVTOIGSHZJGPVKTOBUTJDIYYDI/story/)
- El apagado impidió usar el "EDUS desconectado" (plan B); los respaldos fueron de lo primero cifrado — [Revista E&N](https://www.revistaeyn.com/lasclavesdeldia/costa-rica-hospitales-de-ccss-usan-expedientes-medicos-de-papel-tras-hackeo-DA8424612); [Observador](https://observador.cr/ciberataque-en-la-ccss-cumple-un-mes-sistema-edus-sigue-pendiente-para-las-autoridades/)
- En la CCSS se infectaron 9.600 de 39.650 terminales (27 %); en el Hospital Ciudad Neily, 120 de 315 (38 %); hubo retrasos y cancelación de citas y cirugías — [Repertorio Científico UNED](https://revistas.uned.ac.cr/index.php/repertorio/article/download/4744/6544/21245)
- En marzo de 2025 volvió a caer el EDUS por falla de infraestructura (no ciberataque según MICITT) — [Delfino, 2025](https://delfino.cr/2025/03/ccss-reporta-incidencia-en-centro-de-datos-edus-y-pagina-web-fuera-de-servicio)

### Inferences
- **Encaje IESS ("modo degradado"):** el prototipo debe tener tres capas: (1) en línea (web/WhatsApp), (2) sin datos (IVR, SMS, radio), (3) sin red (tarjeta impresa, afiche en dispensario, guion del monitor). Una PWA offline-first puede guardar en caché el contenido educativo y el juego, pero no resuelve el caso sin batería ni red; la radio a pilas y el papel sí. Mostrar en la final una demostración en "modo apagón". **Escala: CONVERGENTE** para offline-first en salud pública; **PERIFERIA** para cultura de seguridad.
- La lección CCSS para cultura: durante una caída, los estafadores pueden ofrecer "ayuda" para trámites (riesgo de suplantación); los mensajes fijos impresos de antemano ("en caso de caída del sistema, el IESS no llama para pedir datos") preparan a la gente. Esto es inferencia, no hallazgo de la CCSS.

### Gaps
- No encontré informe oficial de lecciones aprendidas de la CCSS ni evidencia de campañas a la ciudadanía contra fraudes durante su caída.
- No encontré evaluaciones de PWA offline-first en servicios sociales de América Latina.
- No encontré datos de cobertura de radio o de cuántos hogares tienen radio a pilas en Ecuador.

## 7. Legitimar a los "ayudantes": delegación segura en lugar de prestar la clave

### Takeaway
Hay modelos maduros de delegación con identidad propia del ayudante: la procuración electrónica del Meu INSS (Brasil), que exige cuentas gov.br prata/ouro, verificación en dos pasos del procurador y lista de servicios autorizados, y el "proxy access" del NHS inglés, que separa la cuenta del ayudante y deja rastro de auditoría (compartir la clave no lo deja). El representante de pago de la SSA muestra el riesgo de la delegación sin supervisión: 12 % de las denuncias de fraude a la OIG en 2016 eran de representantes.

### Cited Findings

**Ficha 7.1 – Procuração eletrônica en Meu INSS, Brasil**
- Cómo: el afiliado registra a un procurador; ambos deben tener cuenta gov.br nivel prata u ouro y el procurador debe tener activada la verificación en dos pasos; se indican los servicios del Meu INSS que el procurador podrá usar; el procurador entra con su propio CPF y clave y elige "Acessar como Procurador"; la solicitud puede iniciarla el afiliado o el representante (cambio de portaria) — [NSC Total](https://www.nsctotal.com.br/economia/procuracao-eletronica-meu-inss-seguranca-idosos); [gov.br, Portaria Conjunta 2025, alterada 12-06-2026](https://www.gov.br/inss/pt-br/centrais-de-conteudo/legislacao/portarias-conjuntas/2025/ptcj10dti-dirben-inss-alterada12-6-2026.pdf/@@download/file); [cartilla INSS](https://www.gov.br/inss/pt-br/centrais-de-conteudo/imagens/copy_of_AcessoaoMeuINSScomProcuraoEletrnicaVersoPDFimpresso1.pdf)
- Alternativa tradicional: servicio "Atualizar Procurador e Representante Legal" con poder y Termo de Responsabilidade; permite excluir al procurador; se recomienda cambiar la clave si fue compartida — [gov.br](https://www.gov.br/pt-br/servicos/atualizar-procurador-e-representante-legal)
- Los medios lo presentan explícitamente como forma de autorizar a un hijo o abogado "sin exponer la clave" — [Gazeta SP](https://www.gazetasp.com.br/economia/procuracao-eletronica-meu-inss/); [Viva](https://viva.com.br/tecnologia/aprenda-a-cadastrar-um-procurador-no-app-meu-inss-sem-expor-sua-senha.html); la OAB orienta a los abogados sobre el acceso profesional — [OAB](https://www.oab.org.br/noticia/64215/oab-nacional-orienta-advocacia-sobre-acesso-profissional-ao-meu-inss-por-procuracao-eletronica)
- Divergencia: una fuente dice que el registro solo puede hacerse en el sitio web y otras describen el flujo en la app — [resumen de búsqueda; ver NSC Total](https://www.nsctotal.com.br/noticias/como-cadastrar-procuracao-eletronica-no-meu-inss)
- No encontré cifras de uso ni evaluaciones de reducción de fraude.

**Ficha 7.2 – Proxy access del NHS, Inglaterra**
- El consultorio de medicina general concede a una persona de confianza acceso delegado a los servicios en línea de otra (citas, recetas, historia); el acceso formal usa una cuenta separada; el acceso "informal" (compartir el usuario del paciente) no deja rastro de quién accedió — [NHS England](https://www.england.nhs.uk/long-read/proxy-access/); [NHS](https://www.nhs.uk/nhs-services/gps/gp-services-for-someone-else-proxy-access/what-is-proxy-access)
- Existe un servicio de solicitud en línea y guía específica para personal de residencias de mayores (pedido de medicamentos) — [NHS, cómo obtener proxy](https://www.nhs.uk/nhs-services/gps/gp-services-for-someone-else-proxy-access/how-to-get-proxy-access); [NHS England, residencias](https://england.nhs.uk/ourwork/clinical-policy/proxy-access-to-gp-online-services-by-care-home-staff-guidance-for-care-homes-and-gp-practices/how-proxy-access-works)

**Ficha 7.3 – Representative payee de la SSA, EE. UU. (lección de supervisión)**
- En el año fiscal 2016 la OIG de la SSA recibió 143.285 denuncias de fraude, 16.577 (~12 %) relacionadas con representantes de pago; la SSA hizo solo 2.590 entrevistas presenciales de supervisión a representantes ese año — [SSA OIG, testimonio 22-03-2017](https://oig.ssa.gov/congressional-testimony/2017-03-22-newsroom-congressional-testimony-march22-representative-payee/)
- El número de beneficiarios que necesitan representante creció casi 20 % entre 2002 y 2011 — [GAO-13-473](https://www.gao.gov/assets/d13473.pdf)

### Inferences
- **Encaje IESS ("Ayudante registrado"):** muy alto y ataca la causa raíz del estudio previo (clave prestada a ayudantes, cibercafés y tramitadores). Propuesta conceptual demostrable con datos ficticios: el afiliado registra en agencia, dispensario o en línea a un ayudante con su propia cédula y clave; el ayudante solo ve trámites autorizados (p. ej., consultar y agendar citas, no cambiar cuenta bancaria ni pedir préstamos); cada acción queda registrada y el afiliado recibe SMS/llamada de aviso; revocación en un paso. La "cultura" está en el mensaje: "no prestes tu clave, registra a tu ayudante". Limitación: el hackatón prohíbe intervenir sistemas del IESS, así que sería un prototipo de flujo y una propuesta normativa (poder, LOPDP); depende de Reto 2 (fraude) y de la autenticación del IESS. **Escala: CONVERGENTE** (en Brasil y el Reino Unido es CENTRO; en Ecuador sería nuevo).
- La lección SSA: la delegación sin supervisión se convierte en vector de fraude; por eso los permisos acotados, los avisos al titular y la prohibición de cambiar datos bancarios por el delegado son esenciales.
- Para migrantes: el familiar en el exterior podría ser el ayudante registrado del jubilado (o viceversa) en lugar de pedirle la clave por WhatsApp.

### Gaps
- No encontré cifras de uso de la procuración electrónica del INSS ni de proxy access del NHS, ni evaluaciones de su impacto en fraude.
- No investigué el marco legal ecuatoriano de poder digital/firma electrónica para delegación ante el IESS, ni si el IESS ya tiene una figura de apoderado en línea.
- No encontré datos sobre cibercafés o tramitadores registrados/acreditados como modelo (p. ej., "agentes autorizados").
