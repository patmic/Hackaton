# Evidencia científica sobre qué funciona para construir cultura de ciberseguridad y cambiar el comportamiento (organizaciones y ciudadanía)

Nota de método: búsqueda web realizada el 25-nov-2026 (≈21 consultas/lecturas). Se leyó el texto completo del artículo de Ho et al. (IEEE S&P 2025); del resto se leyeron resúmenes, páginas institucionales o síntesis de buscador. Se marca cada hallazgo como **[PR]** = revisado por pares, **[INST]** = organismo público/estándar (NIST, ENISA), **[PREPRINT]** = arXiv sin revisión confirmada, **[VENDOR]** = informe o blog de proveedor comercial, **[PRENSA]** = nota universitaria o de prensa que resume un estudio.

Escala de evidencia usada en las inferencias: **A** = varios estudios de campo grandes y/o ECA concordantes; **B** = un estudio de campo grande o varios experimentos controlados; **C** = estudios pequeños, de laboratorio o solo autorreporte; **D** = afirmaciones de proveedores o de opinión.

## 1. Capacitación y simulaciones de phishing: ¿funcionan? (Lain et al. 2022, Ho et al. 2025, capacitación embebida, NIST Phish Scale, capacitación anual, decaimiento)

### Takeaway
Los dos estudios de campo más grandes (ETH Zúrich, ~14.000 empleados, 15 meses; UC San Diego Health, ~19.500 empleados, 8 meses, ECA con grupos de control) concluyen que la capacitación anual obligatoria no tiene relación medible con hacer clic, y que la capacitación "embebida" tras caer en una simulación reduce la tasa de fallo en apenas ~2 puntos porcentuales o incluso puede empeorarla. Lo que sí mostró valor es el botón de reporte (detección colectiva) y los avisos/banners en el correo; la dificultad del señuelo pesa mucho más que la capacitación sobre el resultado.

### Cited Findings
- **[PR] Ho et al. (IEEE S&P 2025), diseño:** ECA de 8 meses, 10 campañas simuladas, más de 19.500 empleados de UC San Diego Health; tras limpieza de datos quedaron 19.789 empleados activos a tiempo completo; análisis con modelos lineales generalizados mixtos (GLME) controlando por tipo de señuelo y fallos previos — [Ho et al., "Understanding the Efficacy of Phishing Training in Practice" (PDF)](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- **[PR] Ho et al.: capacitación anual:** "no correlation" entre cuán recientemente un usuario completó la capacitación anual de concientización y si hizo clic en los enlaces de las simulaciones — [Ho et al. (PDF)](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- **[PR] Ho et al.: capacitación embebida:** reducción estadísticamente significativa de la tasa media de fallo, pero de solo ~2% en términos absolutos — [Ho et al. (PDF)](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf); [EurekAlert](https://www.eurekalert.org/news-releases/1098573)
- **[PR] Ho et al.: el señuelo domina el resultado:** las tasas medias de fallo por señuelo fueron de 1,82% a 30,80%; los temas de política interna de RR. HH. (código de vestimenta, política de vacaciones) estuvieron en el extremo alto (~28-31%), y los genéricos de contraseña/login en el bajo (~2%). Los autores concluyen que toda evaluación debe tener un grupo de control sin capacitación, algo "rarely included in research or practice" — [Ho et al. (PDF)](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- **[PR] Ho et al.: por qué no entrena:** en cada simulación solo "falla" una mediana del 10%, así que la mayoría nunca recibe la capacitación; más del 56% de los usuarios hizo clic al menos una vez durante el estudio, con o sin capacitación; más de la mitad de las sesiones de capacitación embebida terminan en menos de 10 segundos y menos del 24% la completa formalmente — [Ho et al. (PDF)](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- **[PR] Ho et al.: formato:** entre quienes completan la capacitación, el contenido estático se asoció negativamente con resultados futuros, mientras que la capacitación interactiva redujo en 19% (relativo) la probabilidad de caer en el siguiente señuelo; efecto pequeño en términos absolutos y posiblemente por autoselección. Para ciertos contenidos, recibir y completar más capacitaciones se asoció con mayor probabilidad de fallar después — [Ho et al. (PDF)](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- **[PRENSA] Ho et al.: recomendación de los autores:** priorizar defensas técnicas (MFA, detección automatizada de phishing) sobre más capacitación — [UC San Diego Today](https://today.ucsd.edu/story/cybersecurity-training-programs-dont-prevent-employees-from-falling-for-phishing-scams); [UChicago CS](https://cs.uchicago.edu/news/new-study-reveals-gaps-in-common-types-of-cybersecurity-training/)
- **[PR] Lain, Kostiainen y Čapkun (IEEE S&P 2022), diseño:** 15 meses (jul-2019 a oct-2020), más de 14.000 empleados (14.773 participantes) de una empresa socia recibieron emails simulados en su contexto normal de trabajo; se desplegó un botón de reporte en el cliente de correo — [arXiv 2112.07498](https://arxiv.org/abs/2112.07498)
- **[PR] Lain et al.: capacitación embebida:** "as commonly deployed in the industry" no hizo más resilientes a los empleados y "can have unexpected side effects" que los vuelven más susceptibles; contradice práctica industrial y estudios previos — [arXiv 2112.07498](https://arxiv.org/abs/2112.07498)
- **[PR] Lain et al.: avisos y reporte:** los avisos (warnings) en los emails fueron efectivos; el reporte colectivo por empleados es práctico en organizaciones grandes, permite detectar campañas nuevas rápido con carga operativa aceptable, y los empleados siguieron reportando durante largos periodos — [arXiv 2112.07498](https://arxiv.org/abs/2112.07498)
- **[PR] Lain et al.: velocidad de detección:** la velocidad de reporte indica que campañas nuevas pueden detectarse "within few minutes" de su lanzamiento; los empleados reportaron miles de emails sospechosos que representaban cientos de campañas reales no vistas antes. Extrapolación del paper: en una empresa de 1.000 empleados con 100 destinatarios, se esperarían 8-25 reportes, uno de ellos en menos de 5 minutos con alta probabilidad (modelado, no medición directa) — [ar5iv HTML del artículo](https://ar5iv.labs.arxiv.org/html/2112.07498)
- **[PREPRINT] Lain et al. (seguimiento ETH, arXiv 2409.01378):** el efecto de la capacitación embebida proviene de su efecto "nudge" (recordatorio periódico de la amenaza), no del contenido; el contenido casi no se consume (falta de tiempo, se percibe inútil); las recompensas/incentivos no mejoran el comportamiento; diferir la capacitación a un momento con menos presión es tan efectivo como la inmediata; phishing es "un problema de atención, no de conocimiento", por lo que forzar capacitación no ayuda ni siquiera a los más susceptibles — [arXiv 2409.01378](https://arxiv.org/abs/2409.01378)
- **[INST] NIST Phish Scale:** creada en 2019 con datos empíricos reales; asigna una calificación de dificultad a cada email de phishing para explicar la variabilidad de las tasas de clic; guía de usuario actual NIST TN 2276 (nov-2023) con hojas de trabajo; NIST sostiene que la tasa de clic sola no da una imagen completa de por qué se cae — [NIST TN 2276](https://csrc.nist.gov/pubs/tn/2276/final); [PDF](https://nvlpubs.nist.gov/nistpubs/TechnicalNotes/NIST.TN.2276.pdf); [Presentación NIST 2023](https://csrc.nist.gov/presentations/2023/phishing-with-a-net-the-nist-phish-scale-and-cyber)
- **[VENDOR/INFORME SECTORIAL] Verizon DBIR 2025 (según síntesis de terceros):** la capacitación reciente afecta mucho más al reporte que al clic: tasa mediana de reporte del 21% en personas capacitadas en los últimos 30 días frente al 5% en no capacitadas; el impacto en la tasa de clic fue "way less prominent" — [Keepnet Labs, resumen DBIR 2025](https://keepnetlabs.com/blog/2025-verizon-data-breach-investigations-report); [Abnormal, resumen DBIR 2025](https://abnormal.ai/blog/verizon-2025-dbir-key-takeaways)

### Inferences
- (Evidencia A) Un "curso anual + simulación con página de capacitación al hacer clic" es el modelo más estudiado y el que peor sale en campo. Un equipo de hackathon no debería construir otro LMS de capacitación anual ni otra plataforma de simulación con landing page de "has sido phisheado".
- (Evidencia B) La palanca útil es convertir a los empleados en sensores: botón de reporte de un clic, retroalimentación rápida al que reporta, y triage automatizado de reportes. Las métricas deben centrarse en reporte, no en clic.
- (Evidencia B) Si se hacen simulaciones, sirven como recordatorio periódico (nudge) y como medición calibrada por dificultad (NIST Phish Scale), siempre con grupo de control; comparar tasas de clic entre campañas sin ajustar por dificultad del señuelo es engañoso (rango 1,8%-30,8% solo por el señuelo).
- (Evidencia C) Si se incluye contenido, que sea interactivo y breve; el estático parece no servir o empeorar.
- Decaimiento: ninguno de los dos estudios grandes muestra un efecto de capacitación sostenido que pueda "decaer"; el efecto principal es nulo o muy pequeño desde el inicio. El DBIR 2025 sugiere que el efecto sobre reporte está ligado a capacitación de los últimos 30 días, lo que apunta a refuerzos frecuentes y cortos.

### Gaps
- No se obtuvieron cifras específicas de Lain et al. sobre tasas de clic por grupo, proporción de "repetidores" ni el porcentaje exacto de campañas detectadas por reporte (la cifra "90%" que circula no pudo verificarse).
- No se verificaron estudios específicos de decaimiento temporal de la capacitación en phishing (p. ej. trabajos de Reinheimer et al. 2020 sobre retención a 4-6-12 meses); quedan sin cita.
- Proofpoint "State of the Phish" 2024-2026 no se consultó directamente; sus cifras serían [VENDOR].
- No se verificaron las cifras DBIR directamente en el informe de Verizon, solo en resúmenes de proveedores; un resumen menciona un DBIR 2026 con 62% de elemento humano, no confirmado.

## 2. Modelos y medición de cultura de seguridad (ENISA 2017, SANS, KnowBe4/CLTRe, ISF, HAIS-Q, NIST SP 800-50 Rev.1, ISO/IEC 27001:2022)

### Takeaway
Los marcos institucionales (ENISA) insisten en que las campañas de concientización por sí solas no bastan y proponen ciclos de diagnóstico-intervención-medición. El único instrumento de medición con validación psicométrica revisada por pares encontrado es el HAIS-Q, que correlaciona con desempeño en un experimento de phishing de laboratorio. Los índices de cultura comerciales (KnowBe4/CLTRe) y el modelo de madurez de SANS no tienen validación independiente localizada en esta búsqueda.

### Cited Findings
- **[INST] ENISA, "Cyber Security Culture in Organisations" (nov-2017, publicado feb-2018):** define la cultura de ciberseguridad como conocimientos, creencias, actitudes, normas y valores de las personas sobre ciberseguridad y cómo se manifiestan al interactuar con TI; afirma que las campañas de concientización sobre amenazas por sí solas no ofrecen protección suficiente; propone un marco de implementación en ocho pasos; entre las buenas prácticas, que la ciberseguridad sea punto permanente en la agenda del directorio — [ENISA, página de la publicación](https://enisa.europa.eu/publications/cyber-security-culture-in-organisations); [ENISA, informe completo](https://www.enisa.europa.eu/sites/default/files/publications/WP2017%20O-3-3-1%20Cyber%20Security%20Cultures%20in%20Organizations.pdf); [ENISA, nota de prensa](https://www.enisa.europa.eu/news/enisa-news/strong-cybersecurity-culture-as-efficient-firewall-for-organisations)
- **[INST] ENISA (dic-2018), guía de aspectos conductuales:** propone un modelo de concientización, análisis e intervención para organizaciones — [ENISA, Cybersecurity Culture Guidelines: Behavioural Aspects](https://enisa.europa.eu/publications/cybersecurity-culture-guidelines-behavioural-aspects-of-cybersecurity/@@download/fullReport)
- **[PR] HAIS-Q (Parsons et al., Computers & Security 66, 2017, pp. 40-51):** Estudio 1: 112 universitarios respondieron el HAIS-Q y luego hicieron un experimento de phishing en laboratorio; mayor puntuación HAIS-Q se asoció a mejor desempeño (validez convergente). Estudio 2: 505 trabajadores australianos; análisis factorial apoya validez de constructo — [dblp, registro del artículo](https://dblp.org/rec/journals/compsec/ParsonsCPBMZ17.html); [Connections QJ](https://connections-qj.org/article/human-aspects-information-security-questionnaire-hais-q-two-further-validation-studies)
- **[PR] HAIS-Q fiabilidad (McCormac et al.):** 197 trabajadores australianos respondieron el HAIS-Q dos veces con ~4 semanas de diferencia; instrumento fiable test-retest y con consistencia interna — [AJIS, Australasian Journal of Information Systems](https://aisel.aisnet.org/ajis/vol21/iss1/29)

### Inferences
- (Evidencia C) HAIS-Q es la opción más defendible para un diagnóstico de línea base por encuesta (gratuito, validado), pero mide conocimiento-actitud-comportamiento autorreportado; debe combinarse con métricas conductuales (reporte, tiempo a reporte).
- (Evidencia D) Los "índices de cultura" de proveedores sirven como benchmarking comercial, no como evidencia de cambio de comportamiento.
- Para una institución pública, el marco de ENISA (diagnóstico → objetivos → intervención → medición repetida, con patrocinio del directorio) es una estructura más útil que un producto de concientización.

### Gaps
- **NIST SP 800-50 Rev.1 (2024)** "Building a Cybersecurity and Privacy Learning Program": no se recuperó en la búsqueda; no se pueden citar sus recomendaciones de métricas. (Conocimiento previo no verificado: reemplaza SP 800-50 de 2003 y se integra con SP 800-16; habría que consultarlo en csrc.nist.gov.)
- **ISO/IEC 27001:2022**, cláusula 7.3 (Concientización) y control del Anexo A 6.3 (Concientización, educación y formación en seguridad de la información): no verificado con fuente en esta sesión; los textos ISO son de pago.
- **SANS Security Awareness Maturity Model**, **KnowBe4 / CLTRe Security Culture Index** e **ISF**: no se encontró validación independiente ni se consultaron sus documentos; tratarlos como [VENDOR]/marcos de práctica.

## 3. Ciencia del comportamiento: nudges, defaults, fatiga de seguridad, miedo vs. eficacia (PMT), crítica al "firewall humano", cultura de reporte, cultura justa vs. culpa

### Takeaway
Los metaanálisis de la Teoría de Motivación de Protección muestran que la autoeficacia y la eficacia de la respuesta predicen el comportamiento seguro más que la amenaza; apelar al miedo funciona modestamente solo si va acompañado de un mensaje de eficacia. NIST documentó la "fatiga de seguridad" (demasiadas decisiones llevan a conductas impulsivas o al incumplimiento). Castigar a quien falla una simulación aumenta la ansiedad, se percibe injusto y desincentiva el reporte.

### Cited Findings
- **[PR] Lowry et al. (2023, JMIS):** MASEM sobre 341 artículos empíricos de seguridad (383 estudios); la eficacia predice la motivación de protección con más fuerza que la amenaza; el miedo importa más que la amenaza percibida; el "costo de respuesta" como se mide actualmente no es efectivo — [Journal of Management Information Systems](https://www.jmis-web.org/articles/1641)
- **[PR/PREPRINT] Mou et al. (JAIS):** metaanálisis de 92 estudios; autoeficacia y eficacia de respuesta tienen los mayores efectos promedio sobre el comportamiento de seguridad; sin apoyo para costo de respuesta — [AIS eLibrary, JAIS preprints](https://aisel.aisnet.org/jais_preprints/15)
- **[PR] Sommestad et al. (2015, IJISP):** síntesis de 28 encuestas PMT; correlaciones ligeramente mayores para conductas voluntarias que obligatorias (+0,03), para conductas específicas (+0,05) y para amenaza dirigida al individuo (+0,08) — [IGI Global](https://www.igi-global.com/article/a-meta-analysis-of-studies-on-protection-motivation-theory-and-information-security-behaviour/145408)
- **[PR] Tannenbaum et al. (2015, Psychological Bulletin), fuera de seguridad:** 127 artículos; efecto positivo de las apelaciones al miedo en actitudes, intenciones y conductas, d = 0,29 (efectos aleatorios); los mensajes de eficacia aumentan la efectividad — [PubMed 26501228](https://pubmed.ncbi.nlm.nih.gov/26501228/)
- **[PR/INST] NIST, "Security Fatigue" (Stanton, Theofanos, Prettyman, Furman; IT Professional, sep-oct 2016, DOI 10.1109/MITP.2016.84):** la fatiga apareció en 25 de 40 entrevistas; se vincula a fatiga de decisión; produce evitación de decisiones, elegir la opción más fácil, impulsividad e incumplimiento de reglas. Recomendaciones: limitar el número de decisiones de seguridad, facilitar la elección correcta y diseñar para decisiones consistentes — [NIST, nota de prensa 2016](https://www.nist.gov/news-events/news/2016/10/security-fatigue-can-cause-computer-users-feel-hopeless-and-act-recklessly); [EurekAlert](https://www.eurekalert.org/news-releases/540786). (Nota: una página de NIST lista el venue como IEEE Software; el DOI respalda IT Professional.)
- **[PR, lab] CREST (Reino Unido), simulación de phishing y castigo:** en experimento de laboratorio, todas las intervenciones mejoraron el comportamiento frente al control, pero la capacitación obligatoria y el castigo se perciben como relativamente injustos y aumentan la ansiedad de estado; el castigo además afecta negativamente la equidad percibida y la carga mental — [CREST, resumen ejecutivo](https://crestresearch.ac.uk/resources/simulated-phishing-and-employee-cybersecurity-behaviour-spec/); [CREST, "Phishing your staff"](https://www.crestresearch.ac.uk/resources/phishing-your-staff/)
- **[INST/policy brief] CREST:** es poco probable que las personas reporten rápido, o reporten en absoluto, si temen castigo — [CREST, "Phishing your staff"](https://www.crestresearch.ac.uk/resources/phishing-your-staff/)
- **[PR] NDSS/USEC 2025:** consecuencias como "entrevista con el empleado" o "terminación del contrato" redujeron la aceptación de las simulaciones; se recomienda consentimiento informado y comunicar claramente las consecuencias — [USEC 2025 (PDF)](https://ndss-symposium.org/wp-content/uploads/usec25-10.pdf)
- **[PR] Ho et al. (2025), crítica implícita al "firewall humano":** los autores citan que su propia institución exhorta a "Be a Human Firewall" y concluyen que el entrenamiento, tal como se practica, ofrece poco valor y que hay que priorizar defensas técnicas — [Ho et al. (PDF)](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- **[VENDOR/opinión] ISC2 (2025) y CybSafe (2019):** las medidas disciplinarias suprimen el reporte y generan miedo; pueden generar resentimiento hacia el equipo de seguridad y sensación de engaño — [ISC2 Insights 2025](https://www.isc2.org/Insights/2025/08/phishing-training-encouragement-over-punishment); [CybSafe](https://www.cybsafe.com/blog/lets-punish-phishing-victims-er-you-want-to-do-what)

### Inferences
- (Evidencia A para PMT) Los mensajes deben enfocarse en "qué hacer y que es fácil" (autoeficacia, eficacia de la respuesta) más que en asustar. Fear appeals sin instrucción concreta: evitar.
- (Evidencia B-C) Diseñar para menos decisiones: defaults seguros, MFA sin fricción, filtros técnicos, banners automáticos ("remitente externo"), en vez de pedir juicio humano constante (fatiga).
- (Evidencia C) Nada de rankings de "culpables", castigos ni "muros de la vergüenza"; modelo de cultura justa: agradecer el reporte, incluso el tardío o el de quien ya hizo clic.

### Gaps
- No se encontró un estudio de campo grande que compare tasas de reporte bajo regímenes punitivos vs. no punitivos.
- No se buscaron metaanálisis específicos de nudges/defaults en seguridad (p. ej. revisiones de Zimmermann & Renaud 2021 sobre nudges de ciberseguridad); queda pendiente.
- No se verificaron coeficientes exactos de Lowry et al. ni de Mou et al.

## 4. Adultos mayores y baja alfabetización digital (educación anti-estafas, inoculación/prebunking, programas intergeneracionales, avisos en apps bancarias)

### Takeaway
La evidencia más sólida para ciudadanía viene de experimentos de inoculación en adultos de la población general: la exposición a ejemplos simulados de estafa mejora la detección sin reducir la confianza en comunicaciones legítimas, mientras que la lectura estática no. Para mayores específicamente, el mejor indicio con resultado real es un ECA de campañas postales a víctimas de fraude por correo (reducción de revictimización de 8,6% con una carta y 22,4% con varias), disponible solo como resumen de congreso. La inoculación decae en días o semanas sin refuerzos.

### Cited Findings
- **[PR, resumen de congreso] DeLiema et al. (2024):** ECA con direcciones de adultos mayores víctimas conocidas de fraude postal: una carta, carta + cinco envíos de concientización, o sin contacto; a 4 meses, revictimización (medida por correo de víctimas interceptado) −8,6% con una carta y −22,4% con envíos múltiples — [PMC11689558](https://pmc.ncbi.nlm.nih.gov/articles/PMC11689558); [RTI](https://www.rti.org/publication/a-fraud-awareness-mail-campaign-significantly-reduces-rates-of-re)
- **[INST/ONG] AARP (estudios sobre estafas de la Seguridad Social):** experimento nacional representativo con más de 4.000 adultos en EE. UU.; la inoculación aumentó la detección de fraudes sin reducir la confianza en comunicaciones reales y se transfirió a otras estafas (p. ej. suplantación de Amazon) — [AARP](https://www.aarp.org/money/scams-fraud/info-2022/social-security-scams-studies.html)
- **[INST académico] Boston College CRR:** con más de 1.000 participantes, solo la capacitación con emails de estafa simulados mejoró el reconocimiento; la capacitación estática de lectura no; no está claro si se transfiere a SMS — [Boston College CRR, "People Can Spot a Scam After Seeing Fakes"](https://crr.bc.edu/people-can-spot-a-scam-after-seeing-fakes)
- **[PR] Maertens, Roozenbeek, Basol, van der Linden (2021, J. Exp. Psych.: Applied), desinformación (juego Bad News):** el efecto de inoculación puede mantenerse 3 meses si se evalúa regularmente; sin evaluaciones intermedias deja de ser significativo a los 2 meses — [Ovid / APA](https://www.ovid.com/journals/jepap/pdf/10.1037/xap0000315~long-term-effectiveness-of-inoculation-against); [Oxford Psychology](https://www.psy.ox.ac.uk/publication/1564291)
- **[PR] Estudio posterior sobre duración de la inoculación (texto, video, juego):** texto y video pueden mantenerse efectivos un mes; el formato juego dejó de ser significativo a los ~9 días; un refuerzo a la semana prolonga la detección hasta un mes; atrición alta (hasta 60% a 30 días) — [PMC11897321](https://pmc.ncbi.nlm.nih.gov/articles/PMC11897321/); [APA Spotlight](https://www.apa.org/pubs/highlights/spotlight/issue-243)
- **[PREPRINT] arXiv 2601.12324 (2026):** la educación anti-fraude para mayores ha sido mayoritariamente estática; prueba una simulación basada en roles más interactiva (resultados no verificados) — [arXiv 2601.12324](https://arxiv.org/html/2601.12324v2)

### Inferences
- (Evidencia B) Para ciudadanos: "mostrar ejemplos reales de estafas y practicar distinguirlos" (inoculación activa) supera a folletos y charlas de lectura. Incluir ejemplos legítimos para no generar desconfianza generalizada.
- (Evidencia B) Hay que diseñar refuerzos (recordatorios periódicos) desde el inicio: el efecto decae en semanas; los juegos solos pueden decaer más rápido que texto o video.
- (Evidencia C) Las campañas dirigidas a quien ya fue víctima (alto riesgo de revictimización) muestran el efecto real más claro; segmentar por riesgo puede rendir más que campañas masivas.

### Gaps
- No se encontraron evaluaciones publicadas del "Phishing Quiz" de Google/Jigsaw sobre comportamiento real.
- No se localizaron estudios de Stanford Center on Longevity, FINRA Foundation ni de programas intergeneracionales con resultados medidos.
- No se encontró evidencia revisada por pares sobre la efectividad de avisos/fricción en apps bancarias (p. ej. "confirmation of payee", avisos de "¿te están presionando?"); sería [VENDOR]/regulador y quedó sin buscar.
- Evidencia de inoculación específica en adultos mayores de América Latina: no encontrada.

## 5. Gamificación y juegos serios para concientización: metaanálisis y evidencia

### Takeaway
No se encontró ningún metaanálisis cuantitativo específico de gamificación en concientización de seguridad; solo revisiones sistemáticas y de alcance que concluyen que hay ganancias de conocimiento a corto plazo, muestras pequeñas y que el cambio de comportamiento a largo plazo no está demostrado. La evidencia de inoculación sugiere que el formato juego puede decaer más rápido que texto o video.

### Cited Findings
- **[PR] Revisión de alcance (Int. J. Information Security, Springer, 2026):** cataloga juegos serios de concientización; los juegos digitales son el tipo más común — [Springer s10207-026-01239-9](https://link.springer.com/article/10.1007/s10207-026-01239-9)
- **[PR] Revisión sistemática (Int. J. Serious Games, 2024), gamificación para no profesionales de TI:** los efectos a largo plazo están poco comprendidos; piden estudios de habituación — [DOAJ](https://doaj.org/article/50f54189a3e042a4a273f542562106e5)
- **[PR] Revisión sistemática (Int. J. Serious Games, 2025), juegos serios de privacidad y seguridad:** potencial, pero la mayoría están en etapa temprana y se probaron con grupos pequeños; falta en sectores como salud — [IJSG](https://journal.seriousgamessociety.org/index.php/IJSG/article/download/825/578)
- **[PR] Informing Science, "Gamified Cybersecurity Initiatives: The Trend, Limits and Lessons":** la efectividad real de la gamificación en ciberseguridad sigue incierta; recomienda medir comportamiento seguro y cumplimiento en vez de engagement a corto plazo — [Informing Science](https://www.informingscience.org/Publications/5601)
- **[PR, estudio único] CyberAware (Karafili et al., Southampton):** ganancia media de conocimiento de 41,6% tras una sesión (medición inmediata, no comportamiento) — [eprints Southampton (PDF)](https://eprints.soton.ac.uk/510065/1/PaperID_326_Karafili_CyberAware.pdf)
- **[PREPRINT] ETH (2024):** los incentivos/recompensas no mejoraron el comportamiento seguro ante phishing — [arXiv 2409.01378](https://arxiv.org/abs/2409.01378)
- **[PR] Duración de la inoculación:** el formato juego dejó de ser significativo a ~9 días frente a ~1 mes para texto/video — [PMC11897321](https://pmc.ncbi.nlm.nih.gov/articles/PMC11897321/)

### Inferences
- (Evidencia C) Un juego más de "aprende a detectar phishing" con puntos y medallas mejorará el conocimiento inmediato, pero no hay evidencia de que cambie el comportamiento real; si un equipo lo construye, debe medir reporte/detección en contexto real a semanas, no un test al final.
- (Evidencia C) Los incentivos (puntos, premios) no mostraron efecto en el estudio de campo de ETH; la gamificación basada en recompensas no es una apuesta segura.

### Gaps
- Metaanálisis con tamaño de efecto agrupado para juegos serios de seguridad: no encontrado.
- No se verificaron estudios de campo de gamificación con medición de comportamiento a más de 3 meses.

## 6. IA/LLMs para concientización (coaching personalizado, chatbot "¿es esto una estafa?", riesgos de deepfake de voz), evidencia y riesgos 2025-2026

### Takeaway
La evidencia controlada más fuerte (750 participantes) muestra que las explicaciones generadas por LLM en diálogos de aviso de phishing protegen de forma comparable a las redactadas por expertos. Hay estudios pequeños de colaboración humano-IA y de entrenamiento conversacional con LLM (ScamPilot, N=150) que mejoran autoeficacia, pero no hay ensayos que comparen coaching LLM personalizado con capacitación convencional en comportamiento real. Un riesgo documentado es la sobreconfianza: los usuarios aceptan sugerencias de la IA cuando suena segura, sea o no correcta.

### Cited Findings
- **[PREPRINT] "Can Large Language Models Improve Phishing Defense?" (arXiv 2507.07916, 2025):** experimento entre sujetos con 750 participantes; explicaciones de aviso generadas por LLM alcanzan protección estadísticamente comparable a mensajes de expertos; las generadas por Claude mostraron desempeño particularmente robusto — [arXiv 2507.07916](https://arxiv.org/html/2507.07916v1)
- **[PREPRINT] "Bridging Expertise Gaps" (arXiv 2505.03179):** 58 no expertos (34 en la tarea de phishing); la colaboración con LLM mejora la precisión al filtrar falsos positivos; los usuarios aceptan más las sugerencias cuando el modelo suena seguro, independientemente de su exactitud — [arXiv 2505.03179](https://arxiv.org/html/2505.03179v1)
- **[PREPRINT] APOLLO:** herramienta basada en GPT que detecta emails de phishing y genera explicaciones para advertir al usuario — [arXiv 2410.07997](https://arxiv.org/pdf/2410.07997)
- **[PREPRINT/síntesis de buscador] ScamPilot:** interfaz conversacional con LLM que usa juego de roles para enseñar a reconocer estafas; en estudio entre sujetos (N=150), combinar consejo e interacción dio mayor autoeficacia que el control — sin URL primaria verificada (apareció en resultados de búsqueda sin enlace directo); tratar como no confirmado.
- **[INFORME, Schneier] Uso ofensivo de LLM:** trabajos alojados por Schneier evalúan la capacidad de LLM para idear y detectar emails de phishing y para automatizar ataques — [Devising and Detecting Phishing Emails Using LLMs (PDF)](https://www.schneier.com/wp-content/uploads/2024/03/Devising_and_Detecting_Phishing_Emails_Using_Large_Language_Models.pdf); [Evaluating LLMs' Ability to Automate (PDF, 2026)](https://www.schneier.com/wp-content/uploads/2026/02/Evaluating-Large-Language-Models-Ability-to-Automate.pdf)

### Inferences
- (Evidencia B-C) El uso de LLM con mejor respaldo es "just-in-time": explicar en lenguaje claro, en el momento, por qué un mensaje concreto es sospechoso (aviso contextual o asistente "¿es esto una estafa?"), no un curso.
- (Evidencia C) Riesgos de diseño: sobreconfianza en la IA (calibrar y mostrar incertidumbre, nunca decir "es seguro" de forma tajante), alucinaciones, privacidad de los mensajes que el usuario pega, y que el asistente mismo sea suplantado. Combinar el veredicto del LLM con señales deterministas (listas de dominios, verificación de remitente) y con un canal de reporte humano.
- Contexto de amenaza: los LLM abaratan el phishing personalizado, lo que refuerza los argumentos de Ho et al. y Lain et al. de priorizar defensas técnicas y reporte sobre "detección por ojo humano".

### Gaps
- No se encontró ningún ensayo que compare coaching personalizado con LLM frente a capacitación convencional sobre comportamiento real.
- No se buscó evidencia sobre deepfakes de voz (fraude del "familiar en apuros" o del CEO) ni sobre la efectividad de "palabras clave familiares"; queda pendiente.
- No se encontraron evaluaciones publicadas de chatbots públicos tipo "¿es esto una estafa?" (p. ej. de bancos o gobiernos).

## 7. Métricas/KPI para medir cambio de cultura (tasa de reporte vs. clic, tiempo a reporte, etc.)

### Takeaway
La tasa de clic es una métrica pobre y fácilmente manipulable: depende sobre todo de la dificultad del señuelo y exige grupos de control para interpretarse. La evidencia apoya métricas centradas en reporte (tasa de reporte, tiempo al primer reporte, reportes de amenazas reales) junto con calibración de dificultad (NIST Phish Scale) y, para actitudes, instrumentos validados como HAIS-Q.

### Cited Findings
- **[PR]** La tasa de fallo varía de 1,8% a 30,8% según el señuelo, superando por mucho cualquier beneficio de la capacitación; por eso las evaluaciones deben compararse siempre con un grupo de control sin capacitación — [Ho et al. (PDF)](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- **[PR]** "Time on page" de la capacitación como métrica de engagement: más de la mitad de las sesiones < 10 s y < 24% de finalización — [Ho et al. (PDF)](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- **[PR]** Tiempo al primer reporte: campañas nuevas detectables en pocos minutos gracias a reportes de empleados; volumen de reportes de amenazas reales (miles de emails, cientos de campañas reales) — [arXiv 2112.07498](https://arxiv.org/abs/2112.07498); [ar5iv](https://ar5iv.labs.arxiv.org/html/2112.07498)
- **[INST]** Dificultad del señuelo (NIST Phish Scale) para contextualizar la tasa de clic; la tasa de clic sola no explica por qué se cae — [NIST TN 2276](https://csrc.nist.gov/pubs/tn/2276/final)
- **[VENDOR/INFORME] DBIR 2025:** tasa mediana de reporte 21% (capacitados en últimos 30 días) vs. 5% (no capacitados); impacto mucho menor en clic — [Keepnet Labs](https://keepnetlabs.com/blog/2025-verizon-data-breach-investigations-report)
- **[VENDOR/INFORME] DBIR 2025, contexto:** elemento humano en ~60% de las brechas confirmadas (68% en DBIR 2024); 12.195 brechas confirmadas de 22.052 incidentes; cifras de phishing como vector inicial difieren entre resúmenes (14% vs. ~15%) — [Mimecast](https://www.mimecast.com/en/blog/verizon-60-of-breaches-involve-human-error/); [ClearanceJobs](https://news.clearancejobs.com/2025/04/30/60-of-breaches-still-tied-to-human-mistakes-what-the-2025-dbir-means-for-fsos-and-leaders/); [Abnormal](https://abnormal.ai/blog/verizon-2025-dbir-key-takeaways)
- **[PR]** HAIS-Q como medida de conocimiento/actitud/comportamiento con validez convergente frente a desempeño en phishing y fiabilidad test-retest — [dblp](https://dblp.org/rec/journals/compsec/ParsonsCPBMZ17.html); [AJIS](https://aisel.aisnet.org/ajis/vol21/iss1/29)

### Inferences
- Tablero recomendado (síntesis, Evidencia B-C): (1) tasa de reporte y tasa de "reporte sin clic" por campaña; (2) mediana del tiempo al primer reporte y tiempo a contención; (3) número de amenazas reales detectadas primero por usuarios; (4) tasa de clic **solo** ajustada por dificultad (Phish Scale) y frente a grupo de control; (5) clic seguido de reporte (señal de cultura justa: quien se equivoca lo dice); (6) HAIS-Q o similar en línea base y cada 6-12 meses; (7) métricas de "salud" del programa (quejas, percepción de justicia, ansiedad) dado el riesgo de efectos adversos.
- Evitar como KPI principal: % de finalización de cursos y tasa de clic bruta; son métricas de cumplimiento, no de reducción de riesgo.

### Gaps
- No se verificó qué métricas recomienda NIST SP 800-50 Rev.1 (2024).
- Proofpoint "State of the Phish" (tasas de reporte de referencia del sector) no consultado.
- No hay datos de referencia de tasas de reporte para el sector público latinoamericano o de seguridad social.
