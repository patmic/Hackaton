# Soluciones convergentes para la cultura de seguridad del personal (lado interno) en instituciones públicas grandes y hospitales, incluida la prevención del riesgo interno con cultura justa

Notas de investigación para el Reto 1 «Seguridad inteligente, cultura consciente» (Hackatón Código Confianza IESS 2026). Fecha de corte: 25-11-2026. Escala usada: CENTRO (consenso fuerte y evidencia de campo), CONVERGENTE (varias fuentes independientes apuntan en la misma dirección, con evidencia parcial), PERIFERIA (práctica extendida con evidencia débil o mixta), ATÍPICO (idea poco común o con evidencia contraria).

Advertencia de método: hice unas 18 búsquedas y lecturas. Varios datos vienen de resúmenes de prensa especializada o de páginas de proveedores, y lo señalo en cada caso. Cuando un dato procede de mi conocimiento previo y no lo verifiqué en esta sesión, lo marco como "(no verificado en esta sesión)". Los costos son estimaciones mías, salvo cuando se indica fuente.

Contexto ya establecido en el estudio previo (no se repite aquí): la capacitación anual obligatoria no tiene relación medible con la tasa de clic (Ho et al., IEEE S&P 2025); el reporte colectivo funciona (Lain et al., IEEE S&P 2022); el EGSI v3 asigna el plan de concienciación al OSI; la LOPDP prevé multas personales a servidores; la regla de no sanción por fallar simulaciones es un criterio de diseño ([estudio previo, "Criterios que cualquier solución debería cumplir"](D:\investigacion\reports\Cultura de ciberseguridad IESS.md)).

## 1. Reporte en un clic con retroalimentación rápida, y redes de "security champions"

### Takeaway
El botón de reporte con detección colectiva es la intervención de personal con mejor evidencia de campo a gran escala (CENTRO): detecta campañas nuevas rápido, la carga operativa es aceptable y los empleados siguen reportando durante más de un año. Las redes de champions son práctica muy extendida (OWASP, empresas tecnológicas) pero su evidencia es casi solo de informes de experiencia, sin estudios comparativos (CONVERGENTE en diseño, PERIFERIA en evidencia de resultado).

### Cited Findings
- Lain, Kostiainen y Čapkun (ETH Zúrich; arXiv 2021, IEEE S&P 2022): estudio de 15 meses con más de 14.000 empleados (14.733 o 14.773 según la fuente) de una empresa; el 32,10 % (4.729) hizo clic en al menos un phishing durante el estudio — [arXiv 2112.07498](https://arxiv.org/abs/2112.07498); [ar5iv](https://ar5iv.labs.arxiv.org/html/2112.07498).
- En ese estudio se añadió un botón de reporte al cliente de correo, anunciado por boletín interno. De unos 6.300 empleados fuera del experimento que tenían el botón, 1.543 reportaron al menos un correo sospechoso y en total reportaron 4.075 correos — [ar5iv](https://ar5iv.labs.arxiv.org/html/2112.07498).
- Los autores concluyen que la detección colectiva permite detectar rápido campañas nuevas, que la carga operativa para la organización es aceptable y que los empleados se mantienen activos durante largos periodos — [ar5iv](https://ar5iv.labs.arxiv.org/html/2112.07498).
- El mismo estudio encontró que la formación incrustada en la simulación (la página de "has caído") no hizo más resilientes a los empleados y puede tener efectos secundarios que los vuelvan más susceptibles — [arXiv 2112.07498](https://arxiv.org/abs/2112.07498); resumen en [SecurityWeek](https://securityweek.com/research-simulated-phishing-tests-make-organizations-less-secure).
- Hoxhunt (proveedor) propone medir cuatro conductas: tasa de reporte, tiempo hasta el reporte (dwell time), tasa de omisión y reducción de reincidentes, en lugar de tasa de finalización o de clic — [Hoxhunt, blog](https://hoxhunt.com/blog/how-do-you-prove-security-awareness-is-working).
- Hoxhunt define el tiempo hasta el reporte como el intervalo entre la llegada del correo y el primer reporte de un usuario; afirma que el 5 % más rápido de usuarios reporta phishing real en unos 71 segundos. Son datos de su propia plataforma — [Hoxhunt, informe de tendencias](https://hoxhunt.com/guide/phishing-trends-report).
- Contradicción interna del proveedor: un artículo de Hoxhunt sitúa el umbral de cambio real de conducta en una tasa de reporte superior al 20 % (frente a ~10 % de los programas basados en finalización), mientras otra guía recomienda una meta de al menos 70 % — [Hoxhunt, métricas](https://hoxhunt.com/guide/security-awareness-training-metrics); [Hoxhunt, 4 métricas](https://www.hoxhunt.com/blog/4-essential-phishing-metrics).
- Security champions: OWASP publica una guía con cuatro escenarios reales, incluido un fracaso en el que el programa existía sobre todo para mostrar avances a las partes interesadas — [OWASP Security Champions Guide](https://securitychampions.owasp.org/assets/artifacts/Security%20Champions%20Guide%20-%20Secure%20management%20support%20-%20Four%20Approaches%20to%20Security%20Champions%20Programs.pdf).
- LinkedIn informó (2018) más de 50 champions formados, sin publicar datos de resultado — [LinkedIn Engineering](https://engineering.linkedin.com/blog/2018/04/scaling-linkedin-s-security-champions-program).
- Forrester advierte que las expectativas de rol poco claras sobrecargan a los champions y debilitan el programa — [Forrester](https://www.forrester.com/blogs/four-things-you-should-know-about-security-champions-networks-but-probably-dont/).
- No localicé estudios controlados ni de muestra grande que midan si los programas de champions reducen incidentes; la base es de informes de experiencia y opinión experta (resultado de búsqueda en [CSO Online](https://www.csoonline.com/article/3648338/5-steps-to-run-a-successful-cybersecurity-champions-program.html), [TechTarget](https://www.techtarget.com/cybersecurity/tip/How-to-build-a-successful-security-champions-program?amp=1)).

### Inferences

**Ficha 1.1. Botón de reporte en un clic con circuito de respuesta ("gracias, era phishing / era legítimo")**
- Quién/dónde: ETH Zúrich con empresa socia (Lain et al. 2022); productos comerciales (Hoxhunt, KnowBe4 PAB, Microsoft Report Message) y abiertos.
- Cómo funciona: botón en el cliente de correo que envía el mensaje al equipo de seguridad; clasificación (manual o automática) y respuesta al reportante en minutos u horas; los reportes tempranos permiten purgar el mismo correo de otros buzones.
- Público: todo el personal con correo institucional; en el IESS, administrativos y personal asistencial con cuenta.
- Evidencia: CENTRO. Campo, 15 meses, más de 14.000 personas; métricas de reporte y tiempo hasta el primer reporte.
- Costo (estimación): bajo si se usa la función nativa del cliente de correo (Outlook/Exchange o Google Workspace) y un buzón del SOC; medio si se contrata plataforma (licencia por usuario). Requiere tiempo de analista para clasificar.
- Encaje IESS: alto. Alimenta indicadores "medibles" para el OSI y el Comité (tasa de reporte, tiempo hasta el primer reporte) sin evaluar a personas, lo que es compatible con LOPDP (métrica agregada) y aceptable para sindicatos. Se extiende a "reportar un acceso o un pedido raro" (p. ej., que un tramitador pida a un servidor cambiar una cuenta bancaria), que conecta con el riesgo interno.
- Posición: CENTRO.

**Ficha 1.2. Red de referentes de seguridad (security champions) por unidad médica**
- Quién/dónde: OWASP (desarrollo), empresas tecnológicas; en salud, el modelo es parecido a los referentes de calidad o de control de infecciones (inferencia mía, sin fuente específica de hospitales en esta sesión).
- Cómo funciona: un voluntario por unidad o servicio, con tiempo protegido, canal directo con el OSI, materiales breves y reconocimiento.
- Público: 102 unidades médicas y direcciones provinciales.
- Evidencia: PERIFERIA en resultados (sin estudios comparativos); CONVERGENTE en recomendaciones de diseño (patrocinio directivo, rol claro, tiempo protegido).
- Costo (estimación): bajo en dinero, alto en tiempo de personas; el riesgo es sobrecargar al personal asistencial.
- Encaje IESS: medio-alto. Permite llegar al 76 % que la capacitación no alcanza, en el idioma de cada servicio. Debe pactarse con sindicatos para que no sea una carga sin reconocimiento.
- Posición: CONVERGENTE (como práctica), con evidencia de resultado débil.

### Gaps
- No encontré evaluaciones publicadas de redes de champions en hospitales (NHS u otros) con métricas de resultado.
- Las cifras de referencia de Hoxhunt son del propio proveedor y se contradicen; no hallé un benchmark independiente de tasa de reporte para sector público o salud.

## 2. Avisos contextuales en el flujo de trabajo (banners, exportación, registros VIP, "break-the-glass", cartas de retroalimentación por acceso indebido)

### Takeaway
La intervención con mejor evidencia en el lado interno de salud es el aviso inmediato y personal después de un acceso indebido al expediente: en un ensayo con 444 empleados, un correo esa misma noche redujo la reincidencia de 40 % a 1,8 % (CENTRO/CONVERGENTE). En cambio, la etiqueta genérica [EXTERNO] en el correo funcionó poco en un hospital universitario alemán, y los avisos que se colocan en el enlace o exigen atención funcionan mejor que los banners (PERIFERIA para el banner genérico).

### Cited Findings
- Ensayo "Effectiveness of Email Warning on Reducing Hospital Employees' Unauthorized Access to Protected Health Information" (Michigan State University, Johns Hopkins y Protenus; JAMA Network Open, abril de 2022; autor de correspondencia Ge Bai): 444 profesionales de un gran centro médico académico, marcados entre el 1 de enero y el 31 de julio de 2018 por acceder a expedientes sin motivo laboral ni pertenecer al equipo de atención — [HIPAA Journal](https://www.hipaajournal.com/on-the-spot-email-interventions-reduce-repeat-medical-record-snooping-incidents-by-95/).
- El grupo de intervención (219) recibió esa misma noche un correo que les indicaba que habían accedido a un expediente sin motivo laboral y que eso era una violación de privacidad; el grupo control (225) no recibió nada — [HIPAA Journal](https://www.hipaajournal.com/on-the-spot-email-interventions-reduce-repeat-medical-record-snooping-incidents-by-95/).
- Resultado: reincidencia entre 20 y 70 días de 4/219 (≈1,8 %) frente a 90/225 (40 %), una reducción relativa de ~95 % — [HIPAA Journal](https://www.hipaajournal.com/on-the-spot-email-interventions-reduce-repeat-medical-record-snooping-incidents-by-95/); [TechTarget](https://www.techtarget.com/healthtechsecurity/news/366594838/Employee-Email-Warnings-Reduce-EHR-Snooping-Unauthorized-PHI-Access).
- Durante el ensayo no hubo sanción disciplinaria; los empleados fueron sancionados después según la política del centro — [HIPAA Journal](https://www.hipaajournal.com/on-the-spot-email-interventions-reduce-repeat-medical-record-snooping-incidents-by-95/).
- Discrepancia de diseño: el título dice "no aleatorizado", el artículo dice que se seleccionó "aleatoriamente", y el registro en ClinicalTrials.gov (NCT05251844) lo lista como aleatorizado con 444 inscritos — [ClinicalTrials.gov](https://clinicaltrials.gov/study/NCT05251844); [Becker's](https://www.beckershospitalreview.com/healthcare-information-technology/cybersecurity/how-email-warnings-can-stop-snooping-hospital-employees/).
- Los autores advierten que los resultados pueden no generalizarse a otros hospitales — [HIPAA Journal](https://www.hipaajournal.com/on-the-spot-email-interventions-reduce-repeat-medical-record-snooping-incidents-by-95/).
- Auditoría basada en explicaciones (Fabbri y LeFevre, Universidad de Michigan, 2011): la mayoría de los accesos al expediente se explican con otros datos (p. ej., una cita que vincula médico y paciente); con plantillas de explicación descubiertas automáticamente, el modelo explicó más del 94 % de los accesos en registros del University of Michigan Health System, que generaba más de 4 millones de registros de acceso por semana — [arXiv 1109.6880](https://arxiv.org/pdf/1109.6880). (Es anterior a 2018; se incluye como base técnica.)
- Un artículo en PMC sostiene que el marcado por reglas genera muchos falsos positivos y que el filtrado por explicación lo complementa — [PMC5977720](https://pmc.ncbi.nlm.nih.gov/articles/PMC5977720).
- Break-the-glass: Stark y colegas analizaron el uso en el Academic Medical Center (Ámsterdam) y clasificaron más de 60.000 transacciones como plausibles o cuestionables con un método sin datos etiquetados; señalan que el personal médico a menudo necesita acceder sin motivo obvio, lo que dificulta separar lo legítimo de lo ilegítimo (Int. J. of Information Security and Privacy, 2018) — [IGI Global](https://www.igi-global.com/gateway/article/208128); [ResearchGate](https://www.researchgate.net/publication/351835470_Misuse_of_'Break-the-Glass'_Policies_in_Hospitals_Detecting_Unauthorized_Access_to_Sensitive_Patient_Health_Data).
- En atención primaria, los proveedores rompieron el cristal en 6 de 43 pacientes (14 %) con restricciones de visualización frente a 0 de 46 sin restricciones (J Gen Intern Med, 2014-2015, fuera del rango temporal; se cita como contexto) — [Springer](https://link.springer.com/article/10.1007/s11606-014-3053-0).
- Una revisión de 2021 indica que el acceso por autoautorización debe verificarse y que el mal uso claro debe tratarse como brecha de datos; en registros simulados, random forest, árboles de decisión y SVM fueron los algoritmos más útiles — [PMC8734935](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8734935/).
- Etiqueta [EXTERNAL]: en una gran simulación en un hospital universitario alemán, la etiqueta resultó en gran parte ineficaz; los filtros técnicos sí funcionaron, y muchos empleados reaccionaron a la simulación con miedo, vergüenza y culpa — [heise](https://heise.de/-11092684); publicación en [KIT](https://publikationen.bibliothek.kit.edu/1000175479/155241752).
- CHI 2019 (Petelka et al., 701 participantes): los avisos centrados en el enlace redujeron los clics frente a los banners; los avisos que fuerzan la atención fueron los más efectivos — [CHI 2019](https://jpetelka.github.io/files/chi_2019_phishing.pdf).
- En Lain et al., ambos tipos de aviso en el correo ayudaron de forma significativa, lo que matiza el resultado alemán — [arXiv 2112.07498](https://arxiv.org/pdf/2112.07498).
- ISACA (2019, artículo de práctica, no estudio) advierte que los banners en todos los correos pueden producir habituación y el efecto contrario — [ISACA](https://www.isaca.org/resources/news-and-trends/industry-news/2019/email-warning-banners-are-we-using-them-effectively).
- Mensajes de disuasión ("este sistema está monitoreado"): en experimentos con honeypots contra intrusos externos, el banner no redujo la frecuencia de intrusión pero sí su duración (Maimon et al., Criminology 2014); CrimeSolutions (DOJ) califica el programa de banner como "Ineficaz" con más de un estudio — [CrimeSolutions](https://www.crimesolutions.ojp.gov/ratedprograms/555); [GSU](https://scholarworks.gsu.edu/gpl_policybriefs/21).
- Testa et al. (2017): los intrusos con privilegios administrativos no se disuadieron con el banner; los que no tenían privilegios introdujeron menos comandos — [GSU policy brief](https://scholarworks.gsu.edu/gpl_policybriefs/19).

### Inferences

**Ficha 2.1. Aviso inmediato y personal por acceso no justificado (modelo "correo de esa noche")**
- Quién/dónde: centro médico académico de EE. UU. con Protenus, publicado en JAMA Netw Open 2022.
- Cómo funciona: el sistema de auditoría marca accesos sin relación de atención; el servidor recibe un mensaje breve y no punitivo el mismo día ("detectamos un acceso a un expediente sin motivo registrado; si fue por trabajo, indique el motivo aquí").
- Público: personal asistencial y administrativo con acceso a historia clínica (AS400/MIS en el IESS) y a datos de afiliados y jubilados.
- Evidencia: CONVERGENTE tirando a CENTRO: un solo ensayo grande con efecto enorme, sin replicación localizada.
- Costo (estimación): medio. Requiere registros de acceso y una regla mínima de relación de atención; el envío es barato.
- Encaje IESS: muy alto. Es la traducción directa del caso IMSS (uso indebido de accesos por personal) y de los casos de aportes falsos. Es preventivo, medible (tasa de reincidencia) y compatible con cultura justa si la primera vez es informativa. Debe tener base legal y aviso previo bajo la LOPDP (tratamiento de datos de servidores) y pactarse con sindicatos.
- Posición: CONVERGENTE (con aspiración a CENTRO).

**Ficha 2.2. "Romper el cristal" con justificación obligatoria y revisión posterior**
- Quién/dónde: práctica estándar en sistemas de historia clínica (Epic, Cerner), estudiada en Ámsterdam (AMC).
- Cómo funciona: los expedientes sensibles (personal del propio IESS, VIP, jubilados con préstamos activos, salud mental) piden un motivo antes de abrirse; los accesos quedan para revisión.
- Público: personal asistencial y de atención al afiliado.
- Evidencia: CONVERGENTE en práctica; la investigación muestra que separar lo legítimo es difícil y que hace falta revisión posterior.
- Costo: medio-alto si exige cambiar el sistema central; en el hackatón solo puede demostrarse como prototipo.
- Encaje IESS: alto para registros VIP y de jubilados; el reto prohíbe intervenir sistemas en operación, así que se presenta como diseño y simulación.
- Posición: CONVERGENTE.

**Ficha 2.3. Auditoría basada en explicaciones (filtrar lo ya explicado antes de alertar)**
- Cómo funciona: se descartan automáticamente los accesos explicados por una cita, un turno o un trámite, y solo se revisa el resto.
- Evidencia: CONVERGENTE técnica (94 % explicados en Michigan), con menos falsos positivos, lo que protege la confianza del personal.
- Encaje IESS: alto como pieza que hace viable la ficha 2.1 sin acusar a inocentes.
- Posición: CONVERGENTE.

**Ficha 2.4. Banner genérico de correo externo**
- Evidencia: mixta; ineficaz en un hospital alemán, útil en Lain et al.; mejor el aviso en el enlace o contextual.
- Costo: casi nulo.
- Posición: PERIFERIA. Los avisos contextuales específicos (al exportar, al consultar un registro sensible) son más prometedores, pero no encontré estudios de campo sobre avisos en la exportación de datos.

**Ficha 2.5. Mensaje de disuasión "su acceso queda registrado"**
- Evidencia: en intrusos externos, poco o ningún efecto en frecuencia (calificado ineficaz por CrimeSolutions). No encontré estudios en empleados.
- Inferencia: lo que sí tiene evidencia es la retroalimentación personal tras un hecho concreto (ficha 2.1), no el aviso genérico previo.
- Posición: PERIFERIA.

### Gaps
- No pude abrir el artículo original de JAMA Netw Open; los datos vienen de prensa especializada y del registro de ensayo.
- No encontré la fuente primaria sobre "Care Record Guarantee" del NHS ni estudios de Vanderbilt o Kaiser sobre auditoría de accesos en esta sesión.
- No hallé estudios de campo sobre avisos al exportar datos o al consultar un registro VIP.

## 3. Programas de riesgo interno compatibles con la privacidad (mínimo privilegio, segregación de funciones, revisión de accesos, UEBA, caso IMSS)

### Takeaway
La guía CERT/SEI (7.ª ed., 2022, 22 prácticas) es la referencia convergente; los controles de proceso (mínimo privilegio, doble control, baja oportuna de cuentas) son el núcleo, y los casos latinoamericanos muestran que la falla típica es la gestión de cuentas y permisos, no la falta de conciencia. El IMSS atribuyó su filtración de 2025 a uso indebido de accesos por su personal, sin publicar qué controles cambió.

### Cited Findings
- CERT/SEI publicó la 7.ª edición del Common Sense Guide to Mitigating Insider Threats en septiembre de 2022, con 22 buenas prácticas; la práctica 22, nueva, es "aprender de incidentes internos pasados"; la edición incorpora investigación de ciencias de la gestión — [SEI, 2022 Year in Review](https://www.sei.cmu.edu/annual-reviews/2022-year-in-review/keeping-ahead-of-insider-risk); [SEI biblioteca](https://www.sei.cmu.edu/library/common-sense-guide-to-mitigating-insider-threats-seventh-edition/).
- La práctica 16 trata de acuerdos explícitos de seguridad con servicios en la nube, incluidas restricciones de acceso y capacidad de monitoreo — [SEI](https://www.sei.cmu.edu/library/common-sense-guide-to-mitigating-insider-threats-seventh-edition/).
- IMSS (México, 2025): una base llamada "pensionados IMSS 2025" de ~1,4 GB se ofrecía desde agosto por 50.000 pesos; incluiría nombre, CURP, NSS y padecimientos; la cifra de ~20 millones es presunta según expertos — [Xataka México](https://www.xataka.com.mx/seguridad/filtran-venden-base-datos-imss-20-millones-pensionados-nombre-curp-nss-padecimientos-circulan-dark-web); [El Cronista](https://www.cronista.com/mexico/actualidad-mx/hackeo-masivo-al-imss-venden-base-de-datos-con-informacion-de-20-millones-de-pensionados-por-solo-50000-pesos).
- El IMSS negó un hackeo y reconoció posibles filtraciones por uso indebido de accesos por parte del personal; dijo que reforzaría sus medidas de seguridad de forma permanente y cooperaría con autoridades — [UnoTV](https://www.unotv.com/tecnologia/roban-datos-de-20-millones-de-pensionados-imss-niega-hackeo-y-habla-de-filtracion/); [El Cronista](https://www.cronista.com/mexico/finanzas-economia/el-imss-alerto-a-los-pensionados-de-todo-el-pais-por-una-filtracion-interna-de-datos-personales-esto-es-lo-que-podria-ocurrir-con-tu-pension).
- CCSS (Costa Rica): la Contraloría General emitió en abril de 2022 un informe sobre permisos de acceso al Expediente Digital Único en Salud (EDUS); la causa principal fueron debilidades en la gestión de accesos, en especial no dar seguimiento a las cuentas al cambiar la situación laboral, y ordenó revisar roles y perfiles — [La Nación](https://www.nacion.com/el-pais/salud/hasta-funcionarios-fallecidos-tienen-entrada-facil/IUQADLMAGBGQNI7J6WZC34AD4U/story/); [El Financiero CR](https://www.elfinancierocr.com/tecnologia/contraloria-cuestiona-cerca-de-9000-permisos-de/MPCMUS6HEFGE5CRTQOBPUCJENA/story/).
- El titular de La Nación indica que incluso funcionarios fallecidos conservaban acceso; El Financiero titula que la Contraloría cuestionó cerca de 9.000 permisos — [La Nación](https://www.nacion.com/el-pais/salud/hasta-funcionarios-fallecidos-tienen-entrada-facil/IUQADLMAGBGQNI7J6WZC34AD4U/story/); [El Financiero CR](https://www.elfinancierocr.com/tecnologia/contraloria-cuestiona-cerca-de-9000-permisos-de/MPCMUS6HEFGE5CRTQOBPUCJENA/story/).
- Antes del ataque de 2022, la Dirección de TIC de la CCSS había recibido 37 oficios e informes de Auditoría Interna con advertencias de ciberseguridad — [Semanario Universidad](https://semanariouniversidad.com/?p=249505).
- HHS 405(d) incluye "pérdida de datos interna, accidental o maliciosa" entre las cinco amenazas principales del sector salud — [HHS 405(d) / hhscyber](https://hhscyber.hhs.gov/).

### Inferences

**Ficha 3.1. Doble control (cuatro ojos) para cambios de cuenta bancaria, correo y teléfono del afiliado**
- Quién/dónde: control clásico de segregación de funciones recogido en las guías CERT (no verifiqué en esta sesión el número exacto de práctica).
- Cómo funciona: un cambio de datos de cobro o contacto exige aprobación de un segundo servidor o una verificación fuera de banda con el afiliado, con período de enfriamiento.
- Evidencia: CONVERGENTE (consenso normativo); en el estudio previo, los fraudes BIESS siguen la secuencia credencial, cambio de datos y cobro.
- Costo: bajo en tecnología, medio en tiempo de proceso.
- Encaje IESS: muy alto; es el punto exacto de los casos documentados. Toca procesos del BIESS, que otro reto o actor debe ejecutar.
- Posición: CENTRO como control, aunque sea "proceso" más que "cultura".

**Ficha 3.2. Campañas de revisión de accesos (recertificación) y baja automática al cambiar de cargo**
- Evidencia: CONVERGENTE; el caso CCSS/EDUS muestra el costo de no hacerlo.
- Encaje IESS: alto; el OSI puede reportar al Comité el porcentaje de cuentas revisadas y el tiempo de baja tras la salida o el cambio de puesto. Una versión cultural: el jefe confirma "quién de mi equipo necesita qué" en una pantalla simple.
- Posición: CONVERGENTE.

**Ficha 3.3. Analítica de comportamiento (UEBA) con privacidad desde el diseño**
- Cómo funciona: alertas sobre patrones anómalos (consultas masivas de jubilados, exportaciones, horarios), con seudonimización hasta que un revisor justifique levantarla, y filtrado previo por explicación (ficha 2.3).
- Evidencia: técnica, CONVERGENTE en salud (auditoría de accesos); no encontré evaluaciones independientes de UEBA comerciales en hospitales.
- Costo: alto con productos comerciales; medio con reglas propias sobre registros existentes.
- Encaje IESS: medio; requiere evaluación de impacto bajo la LOPDP y acuerdo sindical sobre vigilancia laboral.
- Posición: PERIFERIA (como producto), CONVERGENTE (como auditoría de accesos acotada).

### Gaps
- No obtuve la lista completa de las 22 prácticas CERT ni su texto sobre segregación de funciones y mínimo privilegio (PDF disponible en la biblioteca SEI, no leído).
- No hallé un documento oficial del IMSS con los controles internos adoptados tras la filtración de 2025.
- No encontré estudios independientes sobre UEBA respetuosa de la privacidad en sector público.

## 4. Medición de la cultura (HAIS-Q, ENISA, SANS, NIST SP 800-50r1, ISO 27001) y tableros para el OSI y el Comité

### Takeaway
NIST SP 800-50 Rev. 1 (septiembre de 2024) es la referencia más reciente y ya integra privacidad y métricas; HAIS-Q es el instrumento validado más usado, con adaptaciones en hospitales pero sin versión hospitalaria validada formalmente. Lo convergente es combinar métricas de conducta (reporte, tiempo hasta el reporte, reincidencia de accesos indebidos) con un cuestionario validado y con indicadores de proceso.

### Cited Findings
- NIST publicó la SP 800-50 Rev. 1, "Building a Cybersecurity and Privacy Learning Program", el 12-09-2024; reemplaza la SP 800-50 (2003) y la SP 800-16 (1998); integra la privacidad e incluye métricas y métodos de evaluación sugeridos — [NIST CSRC](https://csrc.nist.gov/pubs/sp/800/50/r1/final); [NIST noticias](https://www.nist.gov/news-events/news/2024/09/building-cybersecurity-and-privacy-learning-program-nist-publishes-sp-800); [PDF](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-50r1.pdf).
- HAIS-Q: validación original fuera de salud (Pattinson et al. 2017; 112 estudiantes con experimento de phishing y 505 trabajadores australianos) — [catálogo](https://katalog.lib.cas.cz/KNAV/EdsRecord/edsair,edsair.doi...........471c633c830aa2cb9c8c8c691ddb831a).
- Adaptaciones en salud: HAIS-Q adaptado con 165 enfermeras de siete hospitales griegos (Magdalinou et al.), con pruebas de consistencia interna — [IOS Press, SHTI210248](https://ebooks.iospress.nl/pdf/doi/10.3233/SHTI210248); en hospitales daneses se redujeron las siete dimensiones a una evaluación breve de tres preguntas (Appl Clin Inform 2025) — [Thieme](https://thieme-connect.de/products/ejournals/html/10.1055/a-2424-2103).
- Un estudio piloto en una organización industrial crítica encontró que un mejor desempeño en simulaciones de phishing no indica necesariamente una cultura más robusta — [arXiv 2508.20811](https://arxiv.org/pdf/2508.20811).
- NIST Phish Scale permite ajustar la tasa de clic por dificultad del mensaje (citado en el estudio previo) — [NIST TN 2276](https://csrc.nist.gov/pubs/tn/2276/final).
- NHS: el DSPT mide el desempeño con los 10 estándares de seguridad de datos del National Data Guardian; la formación es el estándar 3 y exige un análisis de necesidades por rol — [NHS England, guía 3](https://digital.nhs.uk/cyber-and-data-security/guidance-and-resources/data-security-and-protection-toolkit-assessment-guides/guide-3---staff-training).

### Inferences

**Ficha 4.1. Tablero del OSI y del Comité con tres capas**
- Capa de conducta: tasa de reporte, tiempo hasta el primer reporte, reincidencia de accesos no justificados (ficha 2.1), clic ajustado por dificultad (NIST Phish Scale).
- Capa de proceso: porcentaje de cuentas recertificadas, tiempo de baja de cuentas, cambios de cuenta bancaria con doble control.
- Capa de percepción: HAIS-Q breve adaptado (modelo danés) y una pregunta de justicia percibida ("si reporto un error mío, me tratarán con justicia").
- Evidencia: CONVERGENTE (NIST 800-50r1, HAIS-Q, Hoxhunt en métricas de conducta).
- Costo: bajo (datos agregados, software libre).
- Encaje IESS: muy alto: responde a "preventiva, transversal y medible" y a la evidencia periódica del EGSI; ISO 27001:2022 control 6.3 (concienciación, educación y formación) exige evidencia similar (dato de norma, no verificado en esta sesión).
- Posición: CONVERGENTE.

### Gaps
- No verifiqué en esta sesión el contenido de las directrices de cultura de ENISA (2018) ni el modelo de madurez de SANS; deben consultarse en sus sitios oficiales.
- No extraje la lista concreta de métricas de la SP 800-50r1 (solo consta que incluye métricas y métodos de evaluación).
- No hay versión validada de HAIS-Q en español para personal de salud ecuatoriano; habría que adaptar y validar.

## 5. Cultura justa y seguridad psicológica en salud aplicada a la seguridad de la información; evidencia de que el castigo suprime el reporte

### Takeaway
Hay convergencia en que el castigo por fallar simulaciones se percibe como injusto y provoca miedo y vergüenza, pero la prueba directa de que el castigo reduce el reporte es débil: los estudios citados por proveedores no midieron ese efecto. El principio de cultura justa (distinguir error, conducta de riesgo y conducta temeraria) es compatible con la ficha 2.1: primera vez informativa, reincidencia con consecuencias.

### Cited Findings
- CREST (Reino Unido): la formación breve en simulaciones cambió conducta sin dañar el bienestar; las personas ven la formación obligatoria y el castigo como relativamente injustos — [CREST](https://crestresearch.ac.uk/resources/phishing-your-staff/).
- En el hospital universitario alemán, muchos empleados reaccionaron a la simulación de phishing con miedo, vergüenza y culpa — [heise](https://heise.de/-11092684).
- Hook Security (proveedor) sostiene que el castigo enseña a ocultar errores, pero reconoce que ningún estudio midió el efecto directo de una política de castigo sobre el reporte — [Hook Security](https://www.hooksecurity.co/blog/should-you-punish-employees-who-fail-phishing-simulations).
- NIST (Beyond the Click) recoge opinión experta sobre los programas de formación en phishing — [NIST](https://tsapps.nist.gov/publication/get_pdf.cfm?pub_id=961992).
- En el ensayo de JAMA Netw Open 2022, el aviso no disciplinario inicial redujo la reincidencia en ~95 %, y las sanciones se aplicaron después, según la política del centro — [HIPAA Journal](https://www.hipaajournal.com/on-the-spot-email-interventions-reduce-repeat-medical-record-snooping-incidents-by-95/).

### Inferences
**Ficha 5.1. Política de cultura justa para seguridad, pactada con sindicatos**
- Cómo funciona: matriz pública de respuestas: error honesto o clic en simulación = aprendizaje sin registro individual; conducta de riesgo (compartir clave) = coaching; conducta temeraria o dolosa (vender datos, registrar aportes falsos) = proceso disciplinario y penal. Reportar el propio error atenúa.
- Evidencia: CONVERGENTE en principio (CREST, hospital alemán, prácticas de seguridad del paciente); evidencia directa débil sobre castigo y reporte.
- Encaje IESS: muy alto, y necesario por la LOPDP (multas personales): sin regla explícita, el miedo a la multa puede llevar a ocultar incidentes. Esto es una inferencia mía.
- Costo: bajo.
- Posición: CONVERGENTE.

### Gaps
- No busqué en esta sesión literatura de seguridad del paciente (Dekker, Reason, AHRQ) aplicada a ciberseguridad; queda pendiente.
- No encontré un estudio controlado que mida directamente el efecto de sancionar sobre la tasa de reporte.

## 6. Programas específicos de salud (NHS, HHS 405(d) HICP, ejercicios de mesa de ransomware, procedimientos de contingencia y lecciones de la CCSS)

### Takeaway
HICP 2023 (HHS 405(d)) y el DSPT del NHS son los marcos de salud de referencia, gratuitos y con materiales reutilizables; el NHS pasó en 2023/24 de una meta del 95 % de finalización a exigir "comprensión adecuada" por rol. La CCSS de Costa Rica muestra que, tras el ransomware de 2022, los hospitales volvieron al expediente en papel, y que las alertas previas de auditoría y la gestión de accesos fueron los puntos débiles.

### Cited Findings
- HHS 405(d) publicó una actualización de HICP en 2023 ("What's New In HICP 2023") con documento principal y dos volúmenes técnicos (organizaciones pequeñas y medianas/grandes), una lista de verificación OCCI 2024 y un análisis de resiliencia hospitalaria — [hhscyber.hhs.gov](https://hhscyber.hhs.gov/); [HICP principal](https://hhscyber.hhs.gov/Documents/HICP/HICP-Main-508.pdf); [Novedades 2023](https://hhscyber.hhs.gov/Documents/HICP/HHS-hicp-highlight_R.pdf).
- Las cinco amenazas de HICP: ingeniería social, ransomware, pérdida o robo de equipos o datos, pérdida de datos interna (accidental o maliciosa) y ataques a dispositivos médicos conectados; hay módulos de formación por amenaza y carteles gratuitos — [hhscyber](https://hhscyber.hhs.gov/); [cartel de higiene](https://hhscyber.hhs.gov/Documents/Posters_and_awareness/HHS-cyber-hygiene-poster-2024_R.pdf).
- NHS DSPT: desde 2023/24, en lugar del requisito del 95 % de formación, se exige que todo el personal tenga una "comprensión adecuada" de gobernanza de la información y ciberseguridad; el e-learning nacional "Data Security Awareness" sigue siendo opción, o formación local equivalente — [DSPT noticias](https://www.dsptoolkit.nhs.uk/News/Training); [DSPT FAQ](https://dsptoolkit.nhs.uk/Help/30).
- Contradicción: una diapositiva del NHS England mantiene el 95 % para organizaciones de categoría 3 y 4, y un blog de un tercero afirma que el 95 % sigue vigente para trusts en el ítem 3.2.1 del cuaderno 2026-27; no pude confirmarlo con fuente oficial — [DSPT adjunto](https://dsptoolkit.nhs.uk/News/Attachment/760); [LearnSignal](https://www.learnsignal.com/blog/information-governance-training-requirement-dspt-explained/).
- CCSS: Hive atacó el 31-05-2022 tras la ola de Conti iniciada el 17-04-2022; se desplegó en al menos 30 de 1.500 servidores y obligó a apagar el expediente digital — [TechCrunch](https://techcrunch.com/2022/06/01/costa-ricas-public-health-system-hit-by-hive-ransomware-following-conti-attacks/); [Wikipedia](https://en.wikipedia.org/wiki/2022_Costa_Rican_ransomware_attack).
- Los hospitales volvieron a usar expedientes físicos; dos meses después la CCSS seguía restableciendo sistemas por etapas — [CRHoy](https://crhoy.com/nacionales/dos-meses-despues-hackeo-sigue-siendo-un-dolor-de-cabeza-para-la-ccss/); [El Financiero CR](https://www.elfinancierocr.com/tecnologia/hackeo-deja-a-la-caja-trabajando-con-expedientes/KRVBGWKCKJHDRMQ6QADJTKSFEM/story/).
- Una auditoría informó un 0 % de implementación del sistema de gestión de seguridad informática en la CCSS, y otra (2025, publicada en 2026) encontró al menos 7.282 equipos desactualizados — [CRHoy](https://crhoy.com/tecnologia/auditoria-implementacion-del-sistema-de-gestion-de-seguridad-informatica-en-la-caja-es-del-0/); [Diario Extra](https://www.diarioextra.com/noticia/ccss-expuesta-a-un-nuevo-hackeo/).
- La Contraloría advirtió que el grupo creado para atender ciberataques perdió fuerza y dejó de sesionar — [El Observador](https://observador.cr/grupo-que-creo-este-gobierno-para-atender-ciberataques-perdio-fuerza-y-dejo-de-sesionar-advierte-contraloria/).

### Inferences

**Ficha 6.1. Adaptar HICP 2023 y sus materiales gratuitos al IESS**
- Evidencia: CONVERGENTE (marco oficial, consenso sector salud EE. UU.); no es un estudio de efecto.
- Costo: muy bajo (materiales libres, traducción y adaptación).
- Encaje: alto, sobre todo la amenaza "pérdida de datos interna", que cubre casos IESS e IMSS.
- Posición: CONVERGENTE.

**Ficha 6.2. Formación por rol en lugar de meta de finalización (modelo NHS DSPT 2023/24)**
- Encaje: alto; el IESS alcanza ~24 %, y la evidencia indica que la finalización no mueve conducta. Un análisis de necesidades por rol (médico, enfermería, ventanilla, préstamos) es más defendible ante el EGSI.
- Posición: CONVERGENTE.

**Ficha 6.3. Ejercicios de mesa de ransomware y simulacros de contingencia en papel por unidad médica**
- Evidencia: CONVERGENTE como práctica (CCSS operó en papel); no localicé evaluaciones de efecto en esta sesión.
- Costo: bajo (guion, 2 horas, facilitador).
- Encaje: alto en el contexto ecuatoriano de apagones; el mismo plan de contingencia sirve para ransomware y cortes de luz (inferencia).
- Posición: CONVERGENTE.

### Gaps
- No obtuve la lista de las 10 prácticas de HICP ni los materiales de ejercicios de mesa de 405(d) en esta sesión.
- No encontré un documento oficial de lecciones aprendidas de la CCSS ni estudios académicos sobre su operación en papel (se menciona un estudio de Datta y Acton, 2023, no verificado).
- No verifiqué el contenido actual del e-learning "Data Security Awareness" del NHS ni la "Care Record Guarantee".
