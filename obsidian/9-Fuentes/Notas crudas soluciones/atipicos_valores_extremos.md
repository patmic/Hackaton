# Soluciones atípicas y valores extremos para cultura de seguridad y prevención del fraude digital (insumo para el Reto 1, Código Confianza IESS 2026)

> **Convenciones de estas notas.**
> - **Nivel de evidencia:** **A** = ensayo aleatorio o cuasiexperimento publicado con revisión por pares; **B** = datos administrativos o de desempeño publicados por la propia organización o el regulador (autoinformados, sin evaluación independiente); **C** = anecdótico, prensa o testimonio; **D** = propuesta teórica, modelo o prototipo sin despliegue medido.
> - **Escala de posición:** CENTRO (lo que todos hacen: capacitación anual, simulacros de phishing, afiches) / CONVERGENTE (prácticas que se están volviendo estándar: botón de reporte, MFA, prebunking) / PERIFERIA (existe en pocos lugares o en otro dominio, con algo de evidencia) / ATÍPICO (rara, contraintuitiva o trasplantada de lejos; más de 2-3 sigmas de la corriente principal).
> - En cada familia, los **hechos con fuente** están en "Cited Findings". La **lógica de transferencia al IESS, los riesgos, el porqué de lo atípico y la posición en la escala** son inferencias propias y están en "Inferences", en fichas por solución.
> - Contexto del IESS tomado del estudio previo (D:\investigacion\reports\Cultura de ciberseguridad IESS.md): el daño grave sigue la secuencia clave de un solo factor prestada o abusada, cambio de correo/teléfono/cuenta y cobro de préstamos BIESS o fondos de reserva; 3,89 M afiliados, 949.307 pensiones, ~33.500 servidores mayormente asistenciales; criterios de diseño: cultura justa, reporte por encima de la tasa de clic, inoculación con refuerzos, LOPDP, accesibilidad, baja conectividad, demostrable en 10 minutos con datos ficticios.

## 1. Trasplantes desde la salud pública: epidemiología, inoculación, vigilancia comunitaria

### Takeaway
La metáfora epidemiológica tiene más respaldo del que parece: la inoculación (prebunking) tiene un ensayo de campo con millones de personas que muestra un efecto pequeño pero real, y los modelos compartimentales de estafas sugieren que cortar el "ciclo de vida del estafador" rinde más que endurecer a cada víctima. Las versiones comunitarias (Cofacts en Taiwán, Senior Medicare Patrol en EE. UU.) escalan con voluntarios, pero casi no miden su efecto sobre el fraude.

### Cited Findings

**1.1 Cofacts (Taiwán, desde ~2017): verificación comunitaria dentro de LINE**
- Funcionamiento: el usuario reenvía un mensaje dudoso al chatbot de Cofacts en LINE; editores voluntarios lo verifican en una base de datos abierta y el bot devuelve automáticamente la verificación existente cuando el mismo mensaje reaparece. — [Nieman Lab, 08-2018](https://www.niemanlab.org/2018/08/line-is-another-chat-app-rife-with-spam-scams-and-bad-information-the-volunteer-supported-cofacts-is-fact-checking-them-in-the-open/)
- Escala (2018): en tres meses recibió más de 46.000 mensajes y el bot respondió automáticamente 35.180; la capacidad humana era el cuello de botella (unos 250 mensajes nuevos por semana y menos de 12 editores activos). LINE era descrito como "plagado" de spam y estafas (p. ej., stickers gratis falsos). — [Nieman Lab, 08-2018](https://www.niemanlab.org/2018/08/line-is-another-chat-app-rife-with-spam-scams-and-bad-information-the-volunteer-supported-cofacts-is-fact-checking-them-in-the-open/)
- Estudio cualitativo de 2026 que encuadra Cofacts como "economía solidaria digital" y lo compara con el mecanismo de verificación propio de LINE. — [Chen, Internet Policy Review 2026](https://policyreview.info/pdf/policyreview-2026-1-2074.pdf)
- Existe un chatbot hermano, "Auntie Meiyu", integrado en grupos privados de LINE, estudiado en un artículo ACM de 2025. — [ACM, DOI 10.1145/3701189](https://api.crossref.org/works/10.1145%2F3701189)
- Nivel: B/C. No se encontró un estudio que mida el efecto de Cofacts sobre las estafas.

**1.2 "Humor over rumor" (Taiwán, Audrey Tang, 2020)**
- Regla "2-2-2": responder a un rumor viral en menos de 2 horas, con 2 imágenes y menos de 200 caracteres; se usó contra la compra de pánico de papel higiénico en febrero de 2020, con memes (p. ej., un perro Shiba Inu) y explicación en lenguaje llano. — [GovInsider](https://govinsider.asia/intl-en/article/audrey-tang-digital-minister-how-taiwan-used-memes-to-fight-pandemic-rumours); [Quartz](https://qz.com/1863931/taiwan-is-using-humor-to-quash-coronavirus-fake-news); [moda.gov.tw](https://moda.gov.tw/press/background-information/3110)
- Discrepancia: otras fuentes hablan de 20 minutos y 200 palabras; Tang dio después un promedio de 16 minutos, nunca más de dos horas. Su enfoque enfatiza responder "sin retirar contenidos" (no takedown). — [Swissinfo](https://www.swissinfo.ch/eng/politics/freedom-of-expression-humour-over-rumour-lessons-from-taiwan-in-digital-democracy/46592080); [Asia Society](https://asiasociety.org/node/31715)
- Nivel: C (testimonio de la autoridad; sin evaluación independiente localizada).

**1.3 Inoculación a escala: prebunking en anuncios de YouTube (Google Jigsaw + Cambridge/Bristol, 2022)**
- Diseño: videos cortos de prebunking como anuncios pre-roll (saltables a los 5 s) en un ensayo aleatorio de campo; unos 5,4 millones de usuarios de EE. UU. los vieron y cerca de 1 millón los miró al menos 30 s; la capacidad de reconocer técnicas de manipulación subió en promedio 5 %. — [Universidad de Cambridge, 2022](https://www.cam.ac.uk/stories/inoculateexperiment); [Universidad de Bristol, 2022](https://www.bristol.ac.uk/news/2022/august/misinformation-media-release.html)
- Nieman Lab lo resume como una mejora de 5-10 % frente al control. — [Nieman Lab, 08-2022](https://niemanlab.org/2022/08/can-you-inoculate-people-against-misinformation-before-they-even-see-it-this-study-says-yes)
- Advertencia: un estudio preregistrado posterior (2025) de Roozenbeek y colegas con anuncios similares en Twitter/X obtuvo resultados nulos en algunos casos y advirtió contra interpretar ruido como señal. (Dato tomado de un resumen de búsqueda; la referencia exacta no se verificó en texto completo.) — [HKS Misinformation Review](https://misinforeview.hks.harvard.edu/?p=14874)
- Nivel: A (efecto pequeño, replicación mixta).

**1.4 Modelos epidemiológicos de propagación de estafas**
- Tijani, Ghosh, Oloniiju y Fatoyinbo (arXiv, 08-2025) proponen un modelo compartimental de cinco compartimentos calibrado con denuncias del Canadian Anti-Fraud Centre; concluyen que la proliferación de estafas depende más del ciclo de vida de los estafadores (reclutamiento, abandono, arresto) que de la susceptibilidad de las víctimas, de modo que perturbar a los estafadores es el control más eficaz. — [arXiv 2508.19817](https://arxiv.org/abs/2508.19817)
- Nwaibeh y Chikwendu (2023) modelan la difusión de "rumores de estafa" en una red heterogénea y simulan políticas de gobierno o plataformas. — [Mathematics and Computers in Simulation, 2023](https://ideas.repec.org/a/eee/matcom/v207y2023icp111-129.html)
- Huo et al. (2022) aplican un SIR al fraude de captación de fondos; las simulaciones sugieren que reducir la publicidad del fraude, elevar la conciencia de riesgo y reforzar la supervisión reducen las víctimas. — [MDPI Mathematics, 2022](https://ideas.repec.org/a/gam/jmathe/v10y2022i10p1709-d817203.html)
- Nivel: D (modelos; sin intervención evaluada).

**1.5 Senior Medicare Patrol (EE. UU., desde 1997): "agentes comunitarios" contra el fraude**
- Red de voluntarios y personal que educa a beneficiarios mayores para revisar sus propios estados de cuenta y reportar fraude. En 2024: 5.643 miembros activos, 22.752 eventos grupales y 283.724 interacciones individuales en 54 proyectos. — [HHS-OIG, 2025](https://oig.hhs.gov/reports/all/2025/2024-performance-data-for-the-senior-medicare-patrol-projects)
- La OIG reconoce que no puede medir el "efecto centinela" (el ahorro por beneficiarios que revisan sus facturas, lo que disuade fraude y error) ni cuántos beneficiarios reportan después de ser educados. En 2023 los proyectos emitieron 26 "notificaciones especiales" sobre nuevas tendencias de fraude. — [HHS-OIG, 2025](https://oig.hhs.gov/reports/all/2025/2024-performance-data-for-the-senior-medicare-patrol-projects); [HHS-OIG, 2024](https://oig.hhs.gov/reports/all/2024/2023-performance-data-for-the-senior-medicare-patrol-projects)
- Los ahorros reportados cayeron 82 % entre 2009 y 2010 (de USD 214.060 a USD 39.031), lo que muestra lo frágil de la métrica. — [HHS-OIG, 2011](https://oig.hhs.gov/reports/all/2011/performance-data-for-the-senior-medicare-patrol-projects-may-2011-performance-report/)
- Nivel: B.

### Inferences

| Solución | Por qué es atípica | Transferencia al IESS | Riesgos | Escala |
|---|---|---|---|---|
| **Cofacts IESS ("¿Es del IESS?")**: línea de WhatsApp donde afiliados y servidores reenvían mensajes con marca IESS; base pública de verificaciones con respuesta automática al reenvío repetido | La verificación comunitaria nació contra la desinformación política, no contra el fraude a una institución; casi ninguna entidad de seguridad social abre su base de mensajes falsos al público | Mapea la debilidad "multiplicidad de canales" del estudio previo; voluntarios de universidades (los jurados incluyen UDLA, USFQ, EPN) como editores; demostrable con mensajes ficticios | El canal mismo puede ser suplantado (criterio "no imitable"); costo de WhatsApp Business; cuello de botella humano (Cofacts tenía menos de 12 editores); datos personales en mensajes reenviados (LOPDP) | PERIFERIA |
| **Regla 2-2-2 de respuesta institucional** a campañas virales con marca IESS (humor, una sola acción) | En gobiernos la norma es el comunicado formal y tardío; responder con memes en 2 horas es contracultural | Unidad pequeña de comunicación + DNSIPD con plantillas preaprobadas | El humor puede trivializar la pérdida de una víctima; riesgo reputacional si el tono falla con jubilados; evidencia solo testimonial | ATÍPICO |
| **Inoculación pre-roll** (micro-videos de 30 s con la técnica, no el caso: "urgencia", "bono", "te pido tu clave") en salas de espera y en el portal antes de operar | La inoculación por técnica es convergente en desinformación pero rara en seguridad social | Pantallas de salas de espera de hospitales del IESS (audiencia cautiva, sin conexión del usuario) | Efecto de ~5 % y decaimiento; posible desconfianza en mensajes legítimos | CONVERGENTE / PERIFERIA |
| **"Vigilancia epidemiológica" de campañas**: tratar cada campaña de phishing con marca IESS como un brote (caso índice, curva, R efectivo, cerco) y priorizar cortar la oferta (dominios, números, cuentas mula) sobre "vacunar" a todos | El modelo de Tijani et al. invierte la prioridad habitual (víctima) por la del atacante | Tablero centinela alimentado por los reportes (línea Cofacts, call center, agencias); conecta con el reto de fraude sin duplicarlo | Modelos no validados en Ecuador; riesgo de "teatro de datos" sin capacidad real de takedown | ATÍPICO |
| **Patrulla del Jubilado** (modelo Senior Medicare Patrol): jubilados voluntarios capacitados que enseñan a sus pares a revisar su propio historial y movimientos BIESS | Usa a la población vulnerable como sensor y docente, no como objeto de campañas | Asociaciones de jubilados, Seguro Social Campesino, clubes del adulto mayor del IESS | La OIG no logra medir el efecto; voluntarios pueden convertirse en nuevos "tramitadores" de confianza; necesita supervisión | PERIFERIA |

### Gaps
- No se encontró evaluación del efecto de Cofacts ni de "humor over rumor" sobre estafas (solo sobre desinformación, y solo testimonial).
- No se localizó ningún caso de "rastreo de contactos" formal de campañas de estafa operado por una entidad de seguridad social.
- No se verificó en texto completo la réplica nula de 2025 del prebunking en X.

## 2. Trasplantes desde aviación, medicina, seguridad vial y cultura ciudadana

### Takeaway
El trasplante más maduro es el "stop the line" en ventanilla: el Banking Protocol británico da al personal de sucursal un guion para llamar a la policía cuando sospecha que un cliente está siendo estafado, con cifras autoinformadas de más de £200 M frenados. El reporte de casi-incidentes al estilo ASRS se ha propuesto para ciberseguridad desde 2018, pero no se ha creado. Los mimos de Mockus son el ejemplo icónico de cultura ciudadana, con resultados que no pueden aislarse de la infraestructura y la sanción y que retrocedieron sin continuidad.

### Cited Findings

**2.1 Reporte de casi-incidentes (ASRS) trasplantado a ciberseguridad**
- Bair, Bellovin, Manley, Reid y Shostack (Colorado Technology Law Journal, 2018) proponen un Cyber Safety Reporting System inspirado en los sistemas de aviación para aprender de los "casi incidentes". — [Colorado Law Scholarly Commons](https://scholar.law.colorado.edu/faculty-articles/1189/)
- Lógica: reportar un ataque frustrado es menos revelador y evita la cuestión de responsabilidad; el modelo es el lema de ASRS "Confidencial. Voluntario. No punitivo."; los abogados de las empresas necesitan garantías de no exponerse. — [Bellovin, blog Columbia, 12-2017](https://www.cs.columbia.edu/~smb/blog/2017-12/2017-12-04.html)
- ASRS recibe unos 100.000 reportes de casi-incidentes al año; un taller de Belfer (2021) con más de 70 expertos concluyó que la industria TI no tiene procesos sólidos para extraer lecciones, y advirtió que el anonimato es más difícil en informática que en aviación. — [Belfer Center, 2021](https://www.belfercenter.org/sites/default/files/pantheon_files/files/publication/Learning%20from%20Cyber%20Incidents.pdf)
- No se encontró evidencia de que el sistema de ciber casi-incidentes se haya creado. — [Belfer Center, 2021](https://www.belfercenter.org/sites/default/files/pantheon_files/files/publication/Learning%20from%20Cyber%20Incidents.pdf)
- Nivel: D para ciberseguridad (A/B para aviación, fuera del alcance de estas notas).

**2.2 Banking Protocol (Reino Unido, desde 2016): "stop the line" en la ventanilla**
- El personal de sucursal que sospecha que un cliente está siendo estafado llama a la policía local, que acude a la sucursal y puede arrestar a sospechosos presentes; lo desarrollaron UK Finance, National Trading Standards y la policía. — [UK Finance](https://www.ukfinance.org.uk/press/press-releases/over-%25C2%25A3200-million-fraud-stopped-rapid-scam-response-scheme)
- Resultados autoinformados: en 2021, 10.072 llamadas, 162 arrestos y £60,7 M frenados; desde 2016, £202,8 M y 1.005 arrestos. Se usa sobre todo contra estafas de suplantación de policía o banco que llevan a la víctima a retirar dinero. — [UK Finance](https://www.ukfinance.org.uk/press/press-releases/over-%25C2%25A3200-million-fraud-stopped-rapid-scam-response-scheme); [Action Fraud, 2020](https://www.actionfraud.police.uk/news/bank-branch-staff-and-police-team-up-to-stop-19-million-of-fraud-in-first-half-of-2020)
- Nivel: B.

**2.3 Mimos de Antanas Mockus y "cultura ciudadana" (Bogotá, 1995-2003)**
- Mockus usó mimos para dirigir el tránsito y ridiculizar a los infractores, y repartió unas 350.000 tarjetas de "pulgar arriba/abajo" para que los ciudadanos aprobaran o desaprobaran pacíficamente la conducta vial de otros. — [Wikipedia, Antanas Mockus](https://en.wikipedia.org/wiki/Antanas_Mockus); [Beautiful Trouble](https://beautifultrouble.org/toolbox/tool/replacing-cops-with-mimes)
- Entre 1996 y 2006 la mortalidad vial de Bogotá cayó entre 50 % y más de 60 % según la fuente, dentro de un paquete ("La vida es sagrada") que combinó sanción, mercadeo social, educación e infraestructura; la atribución a los mimos no puede aislarse. — [ODI](https://www.odi.org/en/about/features/bogot%C3%A1/); [WRI](https://www.wri.org/index%2Ephp/insights/life-sacred-surprising-link-between-reducing-homicide-and-traffic-fatalities-bogota)
- Retroceso: la mortalidad subió levemente entre 2006 y 2017 por falta de continuidad; en 2024 volvió a aumentar. — [ODI](https://www.odi.org/features/securing-safe-roads/road-safety-bogota); [Johns Hopkins BIGRS, 2025](https://publichealth.jhu.edu/sites/default/files/2026-05/v8_2025_0915_BIGRS_BOGOTA_Eng_PAGES.pdf)
- Nivel: C (asociación, sin atribución causal; número de mimos inconsistente entre fuentes, no verificado).

**2.4 Cultura justa (just culture) aplicada al phishing**
- El estudio previo recoge de CREST y USEC 2025 que no sancionar por fallar simulaciones y agradecer el reporte tardío es condición para que el reporte funcione. — [CREST](https://www.crestresearch.ac.uk/resources/phishing-your-staff/)
- El estudio de campo de Lain, Kostiainen y Čapkun (IEEE S&P 2022) con 14.773 empleados durante 15 meses mostró que la detección colectiva (crowdsourcing de reportes) puede ser eficaz, rápida y práctica. — [arXiv 2112.07498](https://ar5iv.labs.arxiv.org/html/2112.07498); [ETH Research Collection](https://www.research-collection.ethz.ch/entities/publication/f198243a-72d8-490c-ba98-5d6fee78ac43)
- Nivel: A.

### Inferences

| Solución | Por qué es atípica | Transferencia al IESS | Riesgos | Escala |
|---|---|---|---|---|
| **"Casi-fraude" IESS (ASRS para servidores)**: canal confidencial, voluntario y no punitivo para que médicos, enfermeras y administrativos reporten presiones de tramitadores, claves compartidas en turnos o accesos indebidos que *casi* pasaron, con ventana de inmunidad si se reporta en X días | Nunca se implementó ni en ciberseguridad general; en el sector salud el reporte de eventos adversos ya existe, lo que permite reusar la costumbre clínica | Encaja con el EGSI (evidencia periódica) y con el criterio de riesgo interno; puede colgarse de los comités de calidad hospitalarios existentes | La inmunidad choca con la responsabilidad administrativa personal (multas de 1 a 20 SBU); sindicatos y Contraloría deben pactarlo; anonimato difícil en unidades pequeñas (advertencia de Belfer) | ATÍPICO |
| **Protocolo Ventanilla IESS/BIESS** (modelo Banking Protocol): guion para que el personal de agencias y del call center detenga una operación cuando un jubilado llega con un "ayudante" que habla por él, con línea directa a Policía o Fiscalía | Traslada el "stop the line" de la industria (Toyota/medicina) a la atención al público | Agencias, Contact Center y BIESS; métrica: llamadas, montos frenados | Discriminación por edad o por apariencia del acompañante; sin un aliado policial el guion no tiene dientes; datos autoinformados | PERIFERIA |
| **Mimos/teatro callejero de cultura ciudadana en agencias** (personaje que ridiculiza amablemente al "tramitador" y al que presta la clave) + tarjetas de aprobación social | Cultura ciudadana como regulación por vergüenza amable; casi no se ha aplicado a la seguridad digital | Filas de agencias y hospitales; bajo costo; muy demostrable en una final | Efecto no aislable y efímero sin sanción ni cambio de proceso (Bogotá); riesgo de humillar a adultos mayores | ATÍPICO |

### Gaps
- No se encontró ninguna entidad pública que opere un sistema de casi-incidentes de ciberseguridad o fraude para su personal.
- No se halló evaluación independiente del Banking Protocol ni datos posteriores a 2021.
- No se buscaron listas de verificación (checklists) aplicadas al fraude en ventanilla.

## 3. Rarezas de la economía conductual: loterías, normas sociales, dispositivos de compromiso

### Takeaway
Las loterías de recibos funcionan cuando convierten al ciudadano en auditor y van con un incentivo fiscal (Nota Fiscal Paulista, efecto medido en AER), pero la lotería por sí sola mostró poco efecto en Portugal. Las cartas de norma social del BIT son de las intervenciones mejor replicadas. El dispositivo de compromiso más trasplantable es el bloqueo voluntario con período de enfriamiento (Monzo). El estudio clásico de "firmar arriba" fue retractado por datos fabricados.

### Cited Findings

**3.1 Nota Fiscal Paulista (São Paulo, desde 2007): consumidores como auditores**
- Devuelve impuestos y da boletos de lotería mensuales a quien pide factura, y ofrece un canal en línea para denunciar a las empresas; tanto la devolución como los boletos crecen con el gasto mensual. — [Naritomi, American Economic Review 2019](https://www.aeaweb.org/doi/10.1257/aer.20160658)
- Resultado: las ventas declaradas subieron cerca de 21 % en cuatro años y la recaudación neta de premios subió 9,3 %, aunque las empresas también declararon más gastos. — [Naritomi, AER 2019](https://www.aeaweb.org/doi/10.1257/aer.20160658)
- Crítica: un artículo de Carta Capital (sin fecha en los resultados) sostiene que el programa desvió fondos de municipios y educación. — [Carta Capital](https://www.cartacapital.com.br/?p=30511)
- Nivel: A.

**3.2 Lotería de facturas de Taiwán (desde el 1-1-1951)**
- Creada para que los consumidores exijan el recibo y las empresas no oculten ventas; los premios se financian con el 3 % de la recaudación anual del impuesto a las empresas; el premio mayor llega a NT$10 M con sorteo bimestral. — [Focus Taiwan, 2023](https://focustaiwan.tw/society/202306050009); [Wikipedia, Uniform Invoice](https://en.wikipedia.org/wiki/Uniform_Invoice)
- La afirmación de que la recaudación de 1951 subió 75 % (de NT$29 M a NT$51 M) proviene de fuentes secundarias no verificadas. — [Yu-kai Chou](https://yukaichou.com/gamification-study/taiwanese-government-gamified-tax-collection-1951/)
- Nivel: C para el efecto (B para la operación).

**3.3 Fatura da Sorte (Portugal, 2014; algunas fuentes dicen 2012): el contraejemplo**
- Un estudio de 2019 (Wilks, Cruz y Sousa) concluyó que los beneficios fiscales influyen más que la lotería en la solicitud de facturas; un trabajo de la Universidad de Coimbra no encontró influencia relevante de la lotería. — [IJSSP, 2019](https://www.emeraldinsight.com/doi/abs/10.1108/IJSSP-07-2018-0120?af=R); [Universidad de Coimbra](https://estudogeral.sib.uc.pt/bitstream/10316/116179/1/Tab_Reposit%c3%b3rio.pdf)
- Mecánica: un cupón por cada 10 euros facturados con NIF. — [Universidad de Coimbra](https://estudogeral.sib.uc.pt/bitstream/10316/116179/1/Tab_Reposit%c3%b3rio.pdf)
- Nivel: A/B (resultado nulo o débil para la lotería aislada).

**3.4 Cartas de norma social del Behavioural Insights Team con HMRC (Reino Unido, 2011-2012)**
- Dos experimentos de campo con unas 100.000 personas que habían declarado pero no pagado; las cartas con norma social aumentaron el pago. — [Hallsworth, List, Metcalfe y Vlaev, NBER w20007](https://www.nber.org/papers/w20007.pdf)
- La versión local ("9 de cada 10 personas en Exeter pagan a tiempo") elevó en unos 15 puntos porcentuales el pago antes del plazo frente al control; la norma nacional tuvo efecto menor. — [Tax Policy Center](https://taxpolicycenter.org/taxvox/can-behavioral-science-improve-tax-compliance); [Policy Options, 2013](https://policyoptions.irpp.org/2013/06/making-inroads/)
- Nivel: A.

**3.5 Dispositivo de compromiso con enfriamiento: Monzo Gambling Block (Reino Unido, 2018)**
- El cliente activa un bloqueo de pagos de apuestas y fija un período de enfriamiento (de 2 días a 1 año) durante el cual no puede desactivarlo; al inicio, desactivarlo exigía 48 horas y hablar con personal. — [Monzo](https://monzo.com/blog/weve-improved-our-gambling-block); [Monzo, 2018](https://monzo.com/blog/2018/06/19/gambling-block-self-exclusion)
- Datos autoinformados: el bloqueo frenó £9 M en pagos de apuestas en 2024; menos del 10 % de quienes lo activaron lo desactivó definitivamente; el enfriamiento promedio elegido pasó de 3 a 10 meses. — [GamCare, 2024](https://gamcare.org.uk/news-and-blog/news/monzo-block-9-million-in-gambling-transactions-in-2024-alone); [Monzo](https://monzo.com/blog/weve-improved-our-gambling-block)
- El Defensor Financiero británico registró un caso en que Monzo no pudo negarse a quitar el bloqueo cuando el cliente insistió, lo que muestra el límite legal del compromiso. — [Financial Ombudsman DRN-4572354](https://financial-ombudsman.org.uk/decision/DRN-4572354.pdf)
- Nivel: B.

### Inferences

| Solución | Por qué es atípica | Transferencia al IESS | Riesgos | Escala |
|---|---|---|---|---|
| **"Afiliado Auditor" (Nota Fiscal Paulista invertida)**: el afiliado que revisa su historial (cambios de correo, teléfono, cuenta; préstamos BIESS) y confirma o reporta anomalías gana participaciones en un sorteo (premio no monetario o simbólico) | Lleva la lógica de "consumidor como auditor" del IVA a la integridad de la propia cuenta de seguridad social; no se encontró antecedente | Ataca la detección temprana de la secuencia clave-cambio-cobro; Brasil muestra que el beneficiario puede ver su extracto (Meu INSS); demostrable con perfiles ficticios | Portugal muestra que la lotería sola rinde poco; base legal para sorteos de una entidad pública y costo; incentivo a reportes falsos; recompensar el reporte no debe castigar al que no revisa | ATÍPICO |
| **Carta/SMS de norma social local** ("9 de cada 10 jubilados de Loja nunca prestan su clave") en el momento de riesgo (renovación de clave, solicitud de préstamo) | Las normas sociales se usan en impuestos, casi nunca en higiene de credenciales | Notificaciones del portal y SMS oficiales; A/B testing barato | Hay que tener el dato real (no inventar la norma); una norma descriptiva negativa ("muchos prestan su clave") puede normalizar la conducta | PERIFERIA |
| **"Candado de préstamos" con enfriamiento (Monzo aplicado al BIESS)**: el afiliado o jubilado activa voluntariamente un bloqueo de préstamos quirografarios y de cambio de cuenta bancaria; desbloquearlo exige un período de 48-72 h y aviso a un contacto de confianza | Dispositivo de compromiso tomado de la ludopatía; invierte el paradigma "más fácil = mejor" | Ataca directamente el escenario de clave prestada: aunque el tramitador tenga la clave, no puede cobrar rápido. Requiere al BIESS como patrocinador | El cambio de proceso pertenece a otro reto o a otra entidad; liquidez de urgencia del jubilado; límite legal para negar el desbloqueo (caso Ombudsman) | ATÍPICO (ver también familia 5) |

### Gaps
- No se encontró ninguna lotería o sorteo que premie *reportar estafas* (las loterías estudiadas premian pedir facturas).
- No se verificó la legalidad de sorteos organizados por el IESS en Ecuador.
- Faltan datos independientes sobre el bloqueo de Monzo.

## 4. Rarezas ofensivo-defensivas: señuelos, cebos y engaño al estafador

### Takeaway
El engaño al atacante pasó de pasatiempo a producto: O2 desplegó "Daisy", una abuela IA que hace perder tiempo a estafadores telefónicos, y los honeytokens (registros falsos que alertan cuando se consultan) son baratos y maduros para detectar abuso interno. La evidencia de impacto es casi toda autoinformada, y en salud hay una objeción cultural seria: un señuelo comunica desconfianza hacia el personal.

### Cited Findings

**4.1 Daisy, la "abuela IA" de Virgin Media O2 (Reino Unido, 11-2024)**
- O2 "sembró" números falsos en sitios que los estafadores usan para buscar víctimas (number seeding), de modo que el número de Daisy acabó en sus listas. — [NPR, 12-2024](https://www.npr.org/2024/12/10/nx-s1-5220362/daisy-ai-granny-o2-fraud-spam-prevention)
- Según O2, mantuvo a estafadores al teléfono hasta 40 minutos (luego se habló de hasta 50) y tuvo más de 1.000 conversaciones en sus primeras semanas. — [Virgin Media O2](https://news.virginmediao2.co.uk/o2-unveils-daisy-the-ai-granny-wasting-scammers-time/); [CBS News](https://www.cbsnews.com/news/ai-grandma-daisy-uk-anti-fraud-scammers-virgin-media-o2); [Marketing Week](https://www.marketingweek.com/o2-ai-granny-scammers-public/)
- O2 no anunció planes de escalarlo; las cifras no tienen verificación independiente. — [TechRadar](https://techradar.com/computing/artificial-intelligence/daisy-the-ai-grandma-has-just-been-unleashed-on-scammers-here-are-the-satisfying-results)
- Nivel: B/C (principalmente pieza de marketing).

**4.2 Kitboga y el scambaiting**
- El streamer estadounidense finge ser una persona mayor vulnerable y usa un banco falso para enredar a estafadores de "reembolso". — [NPR, 04-2024](https://npr.org/2024/04/15/1243189142/scam-baiter-kitboga)
- En 2023 colaboró con el exchange Kraken, que rastreó billeteras usadas por un call center de estafa cripto. — [BeInCrypto](https://beincrypto.com/youtuber-kraken-crypto-scam-operation)
- Su proyecto de bots IA llama en paralelo a un centro de estafas para ocupar a todos los operadores (fuente de tono promocional). — [Frank on Fraud](https://frankonfraud.com/?p=26782)
- Nivel: C.

**4.3 Honeytokens y canarytokens para detectar abuso interno**
- Los canarytokens de Thinkst son señuelos gratuitos y de código abierto; un registro canario de base de datos es una fila falsa (p. ej., un cliente) que dispara una alerta al consultarse o exportarse. — [Zeltser](https://zeltser.com/honeytokens-canarytokens-setup); [Decryption Digest](https://www.decryptiondigest.com/blog/canarytokens-deception-based-threat-detection-guide)
- Thinkst afirma que Grafana publicó que los Canarytokens fueron el mecanismo que detectó su brecha. — [Thinkst blog](https://blog.thinkst.com/home)
- La investigación académica sobre documentos señuelo para amenazas internas existe desde 2009-2010 (Columbia). — [Bowen et al., Columbia 2009](https://www.cs.columbia.edu/~angelos/Papers/2009/DecoyDocumentsSECCOM09.pdf); [Columbia, capítulo sobre insiders](https://www.cs.columbia.edu/~angelos/Papers/2010/insider-bookchapter.pdf)
- En salud: "HoneyDetails" (2020) probó registros clínicos señuelo, pero contra atacantes externos. — [Health Informatics Journal, 2020](https://api.crossref.org/works/10.1177%2F1460458219894479)
- Objeción: una consultora de privacidad sanitaria sostiene que un honeypot "comunica implícitamente que no confiamos en nuestro personal" y que solo atrapa a quien ya estaba predispuesto; los hospitales prefieren auditoría de accesos y analítica de comportamiento (p. ej., alertar cuando un empleado abre el expediente de un familiar). — [Becker's Hospital Review](https://www.beckershospitalreview.com/ehrs/ehr-snooping-best-efforts-to-bust-punish-and-prevent-it.html); [TechTarget](https://www.techtarget.com/healthtechsecurity/feature/Insider-threats-How-health-systems-can-stop-EHR-snooping)
- Nivel: B/C para detección; sin estudios de efecto disuasorio.

### Inferences

| Solución | Por qué es atípica | Transferencia al IESS | Riesgos | Escala |
|---|---|---|---|---|
| **"Jubilado trampa"**: registros sintéticos de pensionistas (con cédulas inválidas o reservadas y sin pago real) sembrados en los sistemas de consulta; cualquier consulta, cambio de cuenta o solicitud de préstamo sobre ellos dispara alerta al OSI. Variante "préstamo-miel": solicitudes BIESS señuelo | Lleva la deception tecnológica a la escala de los procesos de negocio de la seguridad social; no se encontró antecedente en instituciones de pensiones | Ataca el riesgo interno documentado (servidores que consultan y alteran datos) sin vigilar a todos; en la final se demuestra en un entorno sintético | Comunica desconfianza (objeción sanitaria); contamina estadísticas actuariales e informes de rendición de cuentas; un señuelo mal aislado podría generar un pago real; base legal y aval de la SPDP (los registros sintéticos no son datos personales, pero las alertas sí registran a servidores); debe pactarse con sindicatos y enmarcarse en cultura justa | ATÍPICO |
| **"Abuela Daisy" ecuatoriana**: bot que responde SMS y WhatsApp de phishing con marca IESS desde números sembrados, para recolectar URL, números y cuentas mula y alimentar el takedown | Combina scambaiting con inteligencia de amenazas; en el mundo hay un solo despliegue corporativo conocido | Alimenta la "vigilancia epidemiológica" (familia 1) y el takedown (familia 7) | Riesgo legal (interacción con delincuentes, grabaciones), represalias, costo de IA; acento y jerga locales; las cifras de O2 son de marketing | ATÍPICO |
| **Contenido estilo Kitboga** (videos de scambaiting narrado por un creador ecuatoriano) como inoculación entretenida | El entretenimiento de "estafar al estafador" como pedagogía | Redes del IESS, alianzas con creadores | Puede glorificar la confrontación con delincuentes; revictimización si se ridiculiza | PERIFERIA |
| **Pruebas de "cliente oculto"** de tramitadores y del call center (un afiliado ficticio pide "ayuda" para sacar un préstamo) | Auditoría de integridad del recorrido real del ciudadano en lugar de pruebas de phishing al personal | Red-team del recorrido ciudadano; complementa al ISACA (auditoría) del jurado | Puede leerse como entrampamiento; requiere base legal y protocolo; sin fuente comparable localizada | ATÍPICO |

### Gaps
- No se encontró ningún caso documentado de honeytokens en una institución de seguridad social o pensiones.
- No se confirmó la existencia ni los resultados del programa "Usuario Simulado" de la Secretaría de la Función Pública de México (la búsqueda no devolvió fuentes); no se encontró evidencia de pruebas de cliente oculto contra tramitadores.
- No hay evaluación independiente del efecto de Daisy o Kitboga sobre la actividad de los estafadores.

## 5. Identidad, criptografía y fricción deliberada: candados, límites, PIN de coacción

### Takeaway
Los cambios que bajaron pérdidas en otros países añadieron fricción a operaciones peligrosas: Singapur deja "guardar" dinero que solo se desbloquea en persona; Brasil limitó Pix a R$1.000 de noche; Japón restringe transferencias por cajero a mayores de 70 años; Estonia hizo que el PIN de Smart-ID no baste sin el inicio desde el dispositivo propio. Casi ninguno publicó una evaluación de efecto. Los PIN de coacción existen (Discovery Bank) pero son frágiles si el atacante los conoce.

### Cited Findings

**5.1 Money Lock (OCBC) y digiVault (DBS), Singapur, 11-2023**
- El cliente "bloquea" una parte de sus fondos, que no puede transferirse digitalmente; para desbloquear hay que ir a una sucursal o a un cajero de OCBC con tarjeta física y PIN; unos 2 millones de clientes de OCBC pudieron usarlo desde el 30-11-2023; los fondos bloqueados siguen generando interés. — [OCBC, 2023](https://www.ocbc.com/group/media/release/2023/ocbc-rolls-out-money-lock-anti-scam-security-feature.page); [Mothership, 11-2023](https://mothership.sg/2023/11/money-lock)
- Limitación: los fondos bloqueados no sirven para débitos programados; un comentario de NTU advierte que los clientes podrían ser llevados a sitios falsos "para activar el candado". — [OCBC](https://ocbc.com/personal-banking/help-and-support/digital-banking/moneylock); [NTU](https://ntu.edu.sg/business/news-events/news/story-detail/in-banking-security-and-convenience-don-t-mix)
- No se encontraron datos de eficacia. Nivel: B (operación), sin evidencia de efecto.

**5.2 Límites por edad en cajeros (Japón, 2025)**
- Osaka modificó una ordenanza para limitar a ¥100.000 diarios las transferencias por cajero de personas de 70 años o más que no hayan hecho transferencias por cajero en los tres años anteriores, con vigencia prevista desde octubre de 2025; en Osaka, el 70,9 % de las víctimas de "fraude especial" eran mayores de 65. — [Malay Mail, 09-2025](https://www.malaymail.com/news/malaysia/2025/09/06/how-malaysia-can-fight-scams-japan-shows-the-way-with-atm-limits-for-older-people/189994)
- La Agencia Nacional de Policía estudiaba un tope nacional de ¥300.000 diarios para retiros y transferencias de mayores de 75 años (algunas fuentes dicen 70); más de 400 bancos ya habían suspendido, a pedido policial, las transferencias por cajero de mayores sin uso reciente; el fraude especial alcanzó el récord de ¥72.150 M en 2024. — [Japan Times, 03-2025](https://www.japantimes.co.jp/news/2025/03/25/japan/japan-atm-elderly-limit); [Nippon.com](https://nippon.com/en/news/yjj2025032500550); [SCMP](https://www.scmp.com/week-asia/economics/article/3304007/japan-police-propose-atm-curbs-elderly-combat-fraud)
- No se confirmó si el tope nacional se aprobó. Nivel: B/C.

**5.3 Límite nocturno de Pix (Brasil, 10-2021)**
- Desde el 4-10-2021, el Banco Central limita a R$1.000 el total de transferencias entre personas físicas entre las 20 h y las 6 h; bajar el límite es inmediato y subirlo tarda 24 a 48 horas; el umbral se fijó porque el 90 % de las transferencias nocturnas es menor a R$500. Se adoptó tras secuestros exprés y estafas. — [InfoMoney](https://www.infomoney.com.br/?p=1688627); [Canaltech](https://canaltech.com.br/seguranca/pix-tem-limite-noturno-e-outras-medidas-a-partir-de-hoje-4-veja-o-que-muda-197759/)
- No se encontró medición de su efecto. Nivel: B (operación), sin evidencia de efecto.

**5.4 Smart-ID+ (Estonia, 2025)**
- La autoridad estonia RIA lanzó Smart-ID+ contra el phishing: la app solo escanea códigos QR de inicio de sesión cuando el usuario inició el proceso, y una vez activada en un servicio, conocer el PIN ya no basta para completar una operación; sin costo adicional; despliegue gradual, con bancos que todavía evaluaban adoptarlo. — [ERR News](https://news.err.ee/1610054356/banks-taking-on-scammers-with-new-smart-id-upgrade); [SK ID Solutions](https://www.skidsolutions.eu/news/estonias-government-adopts-smart-id-to-strengthen-security/); [ERR (estonio)](https://www.err.ee/1609925093/pangad-alles-kaaluvad-turvalisema-smart-id-kasutusele-votmist)
- Contexto: el estudio previo cita que las estafas costaron a los estonios 29 M de euros. — [RIA](https://www.ria.ee/en/surge-scams-costs-estonian-people-29-million-euros)
- Nivel: B.

**5.5 PIN de coacción / código de pánico**
- Discovery Bank (Sudáfrica) permite configurar un "código de pánico" que se introduce en lugar del PIN normal y alerta silenciosamente al banco mientras la app parece funcionar con normalidad; responde a secuestros con app bancaria. — [TechCentral](https://techcentral.co.za/discovery-bank-panic-code-app-kidnappings/261422/)
- Bancos nigerianos que lanzaron "modos pánico" enfrentaron complicaciones. — [WeeTracker, 10-2025](https://weetracker.com/2025/10/07/panic-mode-banking-nigeria-duress-features)
- Límite: el atacante puede pedir el PIN por adelantado o conocer la existencia del código alterno. — [DEV Community](https://dev.to/darca/why-banking-security-still-breaks-in-real-life-coercion-scenarios-o8l)
- Nivel: C.

**5.6 Contacto de confianza (FINRA 4512) y retención temporal (FINRA 2165), EE. UU., 2018**
- Las corredoras deben hacer esfuerzos razonables por obtener un contacto de confianza adulto al que pueden llamar ante sospecha de explotación; la regla 2165 permite retener temporalmente desembolsos. — [FINRA](https://www.finra.org/media-center/finra-unscripted/rules-2165-4512)
- La evidencia de eficacia es testimonial; FINRA propuso cambios (Regulatory Notice 26-02) para aumentar la adopción, lo que sugiere baja adopción. — [FINRA RN 26-02](https://www.finra.org/rules-guidance/notices/26-02)
- Nivel: C.

### Inferences

| Solución | Por qué es atípica | Transferencia al IESS | Riesgos | Escala |
|---|---|---|---|---|
| **"Modo jubilado" / "Candado IESS"** que combina Money Lock + límite nocturno + enfriamiento: por defecto (opt-out) o voluntario (opt-in), los cambios de cuenta bancaria, correo y teléfono y las solicitudes de préstamo quedan con espera de 48-72 h, horario diurno y aviso al contacto de confianza; desbloqueo inmediato solo en agencia | Pocos países ponen "candados" de producto pensados para la edad; en seguridad social no se encontró ninguno | Rompe la secuencia clave-cambio-cobro aunque la clave ya esté en manos del tramitador; puede presentarse como "compromiso" cultural (el afiliado lo elige) | Pertenece a procesos y al BIESS, no a "cultura": debe nombrarse como dependencia; discriminación por edad (las medidas japonesas son polémicas); urgencias médicas; el phishing puede imitar el "activa tu candado" (advertencia NTU) | ATÍPICO |
| **Contacto de confianza IESS**: el afiliado designa a una persona que recibe aviso de cambios sensibles y puede ser consultada | Instrumento regulatorio de corredoras de bolsa trasplantado a una caja pública | Familias de jubilados migrantes; reduce la dependencia del "ayudante" informal | El contacto puede ser el explotador (el puerto seguro de FINRA no protege ese caso); baja adopción en EE. UU. | PERIFERIA |
| **PIN de coacción para jubilados** (código alterno que muestra un saldo reducido y alerta al IESS) | Tomado de la banca antisecuestro y de las billeteras cripto | Escenario de jubilado presionado por un familiar o tramitador en persona | Si se publicita, los atacantes lo piden por adelantado; complejidad cognitiva para mayores; falsas alarmas | ATÍPICO |
| **Smart-ID+ a la ecuatoriana** (la clave por sí sola no basta; la operación debe iniciarse en un dispositivo vinculado) | Estonia es un valor extremo de identidad digital | Sería la solución de fondo al "un solo factor"; el estudio previo lo deriva a quien corresponde | Brecha de teléfonos inteligentes (57,7 %); fuera del alcance del Reto 1 | CONVERGENTE en Europa / ATÍPICO para Ecuador |

### Gaps
- No se encontraron evaluaciones del efecto de Money Lock, el límite nocturno de Pix ni las restricciones japonesas.
- No se buscó evidencia sobre credenciales verificables o identidad autosoberana para delegación (mandatos o poderes digitales); queda pendiente cómo modelar la delegación legítima a un familiar sin prestar la clave.
- No se encontraron llaves de hardware distribuidas a pensionistas a escala.

## 6. Cultura y arte: teatro, telenovela, música, escape rooms, fútbol, influencers

### Takeaway
La pieza con mejor evidencia es el entretenimiento educativo con trama central (MTV Shuga, ensayo aleatorio en Nigeria). En ciberseguridad hay evaluaciones pequeñas pero positivas de escape rooms con profesionales de la salud (Twente) y de teatro interactivo con adultos mayores (Virginia Tech). La música contra estafas abunda en Asia, pero con críticas de "autopromoción policial" y sin medición. No se encontraron campañas de cumbia o reguetón, ni con clubes de fútbol latinoamericanos.

### Cited Findings

**6.1 Teatro interactivo para adultos mayores (Virginia Tech, 2023-2026)**
- Parti y Midkiff evaluaron un programa de teatro interactivo para la conciencia de ciberseguridad de adultos mayores (creado en 2023, rediseñado en 2024): con encuestas (N=332) y entrevistas (N=27) encontraron que los mayores de 60 prefieren formatos estructurados y reflexivos y los más jóvenes formatos interactivos y rápidos; ambos grupos valoraron el formato. — [VTechWorks, 2026](https://vtechworks.lib.vt.edu/items/c58662ca-b010-4b44-9740-ec33fd28f944)
- El teatro foro de Augusto Boal tiene efectos positivos documentados (seguridad psicológica, confianza, conciencia crítica) en trabajo social, no en ciberseguridad. — [British Journal of Social Work](https://academic.oup.com/bjsw/article/55/5/2441/8090590)
- No se encontró un estudio que combine teatro foro de Boal y ciberseguridad. Nivel: B/C.

**6.2 Escape room de ciberseguridad para profesionales de la salud (Universidad de Twente)**
- Koning y Bullee evaluaron una escape room móvil con 96 profesionales sanitarios (29 como grupo control) en diseño pre/post: efecto positivo inmediato que persistió al mes; los autores advierten que no está claro qué componente causó el efecto. — [Universidad de Twente](https://research.utwente.nl/en/publications/cybersecurity-on-the-move-investigating-the-efficacy-of-a-movable/)
- Otros pilotos (más de 200 empleados de pymes) reportan compromiso y aumento de la conciencia, con evidencia más débil. — [Computers (MDPI), 2024](https://www.mdpi.com/2073-431x/13/8/205)
- Nivel: A- (muestra pequeña) / B.

**6.3 Entretenimiento educativo: MTV Shuga (Nigeria, 2013-2014)**
- Ensayo aleatorio con 4.986 jóvenes de 18 a 25 años en siete ciudades: quienes vieron la serie se hicieron más pruebas de VIH, supieron más y estigmatizaron menos; las mujeres tuvieron menos clamidia. Las menciones breves al condón en subtramas no cambiaron el uso, y añadir contenido sobre valores entre pares no aportó efecto extra; la lección para los guionistas fue poner el contenido educativo en la trama principal. — [J-PAL](https://www.povertyactionlab.org/case-study/improving-youth-sexual-health-through-educational-entertainment)
- Algunos espectadores simpatizaron con el personaje abusador (efecto boomerang parcial). — [J-PAL](https://www.povertyactionlab.org/case-study/improving-youth-sexual-health-through-educational-entertainment)
- Nivel: A.

**6.4 Música y baile contra estafas (Asia y Canadá, 2022-2025)**
- Policía de Hiroshima (Japón): agentes bailando una canción antiestafas cantada por niños de jardín de infantes; 10,7 millones de vistas. — [Mothership, 10-2024](https://mothership.sg/2024/10/japanese-police-officers-dance-scam-prevention)
- Hong Kong: concurso de composición y canto de letras antiestafa "Music Fights Crime" (2024) y la "Hang Seng Anti-Fraud Band" de un banco. — [Policía de Hong Kong](https://police.gov.hk/ppp_en/04_crime_matters/cpa/lws_compet_2024.html); [LBB Online](https://lbbonline.com/news/catchy-cantopop-to-combat-cybercrime-in-new-campaign-by-hang-seng-bank)
- India: WhatsApp reescribió una canción popular como "Scam Se Bacho", que luego adoptaron policías estatales. — [Ads of the World](https://www.adsoftheworld.com/campaigns/scam-se-bacho)
- Canadá: "Scamtones" de la BC Securities Commission convierte tonos de llamada en avisos para mayores. — [Strategy, 06-2025](https://strategyonline.ca/2025/06/12/bcsc-scamtones)
- Críticas: el video musical de la policía de Malasia fue calificado de autopromoción; la canción del DSI tailandés recibió críticas. — [SoyaCincau, 01-2023](https://soyacincau.com/2023/01/06/pdrms-be-smart-stay-alert-anti-scam-music-video-is-more-of-a-blatant-self-promo/); [The Nation Thailand](https://www.nationthailand.com/in-focus/40013723)
- Nivel: C (alcance, no efecto).

**6.5 Fútbol**
- Lloyds Bank y el Home Office británico (campaña Stop! Think Fraud) usan el Mundial 2026 para alertar a hinchas; Lloyds informa un aumento de 36 % en estafas de entradas en seis meses, la mayoría iniciadas en Facebook o Instagram y luego movidas a WhatsApp. — [Lloyds Bank, 2026](https://www.lloydsbank.com/news-and-insights/2026/football-fans-urged-to-show-fraudsters-the-red-card.html); [GOV.UK](https://www.gov.uk/government/news/football-fans-urged-to-show-fraudsters-the-red-card-ahead-of-world-cup)
- Nivel: C.

**6.6 "Granfluencers" y creadores mayores**
- No se encontró ninguna campaña gubernamental con influencers mayores contra estafas. Sí se documentó lo contrario: estafadores editan clips de personas mayores para que parezca que promocionan productos. — [CP24, 03-2026](https://www.cp24.com/news/canada/2026/03/17/how-seniors-are-unknowingly-helping-scammers-on-social-media/)
- Singapur advierte de estafas que empiezan con anuncios de actividades sociales para mayores en Facebook o TikTok (al menos 8 víctimas y S$69.000 desde abril de 2026). — [ScamShield (ask.gov.sg)](https://ask.gov.sg/scamshield/questions/cmqrqgzef001c4401gkqh1dqs)

### Inferences

| Solución | Por qué es atípica | Transferencia al IESS | Riesgos | Escala |
|---|---|---|---|---|
| **Teatro foro en salas de espera** (escena de 7 minutos: el "sobrino" que pide la clave del abuelo; el público detiene la escena y reemplaza al protagonista) | Boal casi nunca se ha usado para seguridad digital; convierte al espectador en ensayador de la negativa | Hospitales y agencias del IESS con audiencias cautivas; elencos universitarios; funciona sin conexión y en apagones | Costo por función y escala; difícil de medir; con mayores conviene un formato más reflexivo (Virginia Tech) | ATÍPICO |
| **Escape room móvil para personal sanitario** ("la clave del turno") | Hay evidencia justo para el público objetivo (profesionales de salud, Twente) | Rotación por hospitales del IESS; mide conocimiento al mes | Muestra pequeña; logística en turnos; efecto en conducta no medido | PERIFERIA |
| **Radionovela o telenovela corta con trama central sobre la clave prestada** (y versión en kichwa) | El edu-entretenimiento sanitario rara vez se usa para fraude | Radios comunitarias y del Seguro Social Campesino; WhatsApp en audio | La lección de Shuga: si el tema va en una subtrama no cambia la conducta; posible simpatía con el estafador | PERIFERIA |
| **Canción o tono de llamada antiestafa (pasillo, cumbia, bomba del Chota)** con concurso abierto como en Hong Kong | Inexistente en Latinoamérica según esta búsqueda | Concurso universitario; jingles en el call center | Autopromoción institucional sin acción clara (críticas en Malasia y Tailandia); alcance no es igual a cambio | ATÍPICO |
| **Alianza con LigaPro o clubes** (estafas de entradas como puerta de entrada al "no prestes tu clave") | Usa la identidad de hincha en vez de la de "afiliado" | Afiliados activos jóvenes, que usan poco el portal hasta que piden préstamos | Costo de patrocinio; mensaje diluido; no hay antecedente en seguridad social | ATÍPICO |
| **"Ciberabuelos" creadores verificados** | No se encontró ningún programa oficial | Jubilados que enseñan en TikTok o WhatsApp | Sus videos pueden ser clonados por estafadores (caso CP24): se necesita un canal verificable | ATÍPICO |

### Gaps
- No se encontraron campañas de cumbia, reguetón o música andina contra estafas, ni alianzas de seguridad social con clubes de fútbol en Latinoamérica.
- No se encontraron fotonovelas o cómics antifraude evaluados (no se buscaron a fondo).
- No se buscaron cyber-ranges para ciudadanos.

## 7. Rarezas económicas y organizacionales: takedown, reembolso obligatorio, nombrar y avergonzar, veedurías

### Takeaway
El reporte ciudadano masivo conectado a un servicio de takedown real (NCSC, Reino Unido) es el mejor ejemplo de "cerrar el ciclo": millones de reportes y cientos de miles de sitios retirados. El reembolso obligatorio a víctimas (PSR, Reino Unido) devolvió £173 M en un año, aunque las cifras sobre si redujo el fraude se contradicen. Publicar nombres de condenados tiene defensores y críticos y poca evidencia. Ecuador ya tiene veedurías ciudadanas sobre el IESS y el BIESS, con resultados modestos.

### Cited Findings

**7.1 Suspicious Email Reporting Service + Takedown Service (NCSC, Reino Unido, desde 04-2020)**
- En sus dos primeros meses recibió 1 millón de reportes y retiró 10.200 URL maliciosas de 3.485 sitios. — [Infosecurity Magazine, 2020](https://www.infosecurity-magazine.com/news/ncsc-million-phishing/)
- En 2022 se reportaron 7,1 millones de correos y URL sospechosos; el servicio alcanzó 10 millones de reportes y 76.000 estafas retiradas. — [NCSC Annual Review 2022](https://www.ncsc.gov.uk/collection/annual-review-2022/resilience/active-cyber-defence)
- Cifra acumulada citada por Computer Weekly: 21 millones de reportes y más de 235.000 sitios maliciosos retirados (fecha de corte no clara). — [Computer Weekly](https://www.computerweekly.com/news/366542377/Nearly-quarter-of-a-million-malicious-websites-reported-and-removed-through-NCSC-service)
- En junio de 2026 la participación del Reino Unido en el phishing mundial era de 1,06 %, la más baja desde 2016. — [NCSC Annual Review 2026](https://www.ncsc.gov.uk/collection/annual-review-2026/building-strong-foundations/securing-uks-internet)
- Nivel: B.

**7.2 Reembolso obligatorio de fraudes de pago autorizado (PSR, Reino Unido, desde 7-10-2024)**
- En el primer año (7-10-2024 a 30-9-2025) se devolvieron unos £173 M a víctimas; cerca del 85 % de los reclamos se reembolsó en cinco días; los rechazos por falta de cuidado del consumidor fueron de alrededor del 3 %. — [PSR](https://www.psr.org.uk/news-and-updates/latest-news/news/one-year-on-impact-of-app-reimbursement-on-victims/); [PSR dashboard](https://www.psr.org.uk/information-for-consumers/app-scams-reimbursement-dashboard)
- Contradicciones: la tasa de reembolso aparece como 86-88 % en reportes del regulador y como un alza de 54 % a 65 % en una evaluación independiente de julio de 2026; esa evaluación halló una caída de 21 % del fraude (£73 M anuales), mientras UK Finance reportó un aumento de 19 % en 2025. — [Regulation Tomorrow, 07-2026](https://www.regulationtomorrow.com/2026/07/payment-fraud-falls-by-73m-following-psr-reimbursement-scheme/); [FStech](https://www.fstech.co.uk/fst/PSR_Reveals_88_Of_Money_Lost_To_APP_Scams_Reimbursed.php); [Crowdfund Insider, 10-2025](https://www.crowdfundinsider.com/2025/10/254198-uk-app-reimbursement-rules-help-return-funds-to-victims-but-fraud-remains-high/)
- Nivel: B (con datos contradictorios).

**7.3 Brasil: el INSS asume el reembolso tras el fraude de descuentos indebidos (2025)**
- La Policía Federal y la CGU lanzaron la "Operação Sem Desconto" el 23-4-2025 contra descuentos asociativos no autorizados en jubilaciones y pensiones: unos R$6.300 M entre 2019 y 2024, con hasta 4,1 millones de beneficiarios potencialmente afectados. — [InfoMoney](https://www.infomoney.com.br/politica/como-funcionava-a-fraude-ao-inss-por-meio-de-descontos-nas-aposentadorias/); [Diario de Pernambuco, 04-2025](https://www.diariodepernambuco.com.br/noticia/economia/2025/04/fraude-no-inss-entenda-o-esquema-e-saiba-se-voce-teve-desconto.html)
- Un delegado de la PF afirmó ante la Cámara que hubo participación interna del INSS. — [meutudo, 05-2025](https://meutudo.com.br/blog/noticias/2025/05/29/investigacao-da-pf-afirma-que-descontos-indevidos-foram-facilitados-pelo-inss/)
- El gobierno anunció un reembolso íntegro con corrección monetaria, con recursos del presupuesto federal si fuera necesario. — [AGU](https://www.gov.br/agu/pt-br/comunicacao/noticias/vitimas-de-fraudes-no-inss-deverao-ser-reembolsadas-em-parcela-unica-ate-o-fim-do-ano/LiveINSSPerguntaseRespostas.pdf/@@download/file)
- Nivel: B/C.

**7.4 Publicar nombres de condenados por fraude ("muro de la vergüenza")**
- Irlanda del Norte reintrodujo la publicación de nombres de condenados por fraude a prestaciones como disuasión; una académica de Ulster University calificó de "equivocado" el énfasis. — [AOL/BBC](https://www.aol.com/articles/benefit-fraud-complaints-rise-naming-061447055.html)
- La OCDE concluye que los mensajes centrados en el castigo son necesarios pero no del todo eficaces y recomienda probar los mensajes disuasorios. — [OCDE, Countering fraud in social benefit programmes](https://www.oecd.org/en/publications/countering-fraud-in-social-benefit-programmes_71df2657-en.html)
- En los paneles de experiencia de Escocia, algunos participantes creían que la comunicación pública sobre fraude hace más daño que bien. — [Gobierno de Escocia](https://gov.scot/publications/social-security-experience-panels-fraud-error-report/pages/6)
- Nivel: C.

**7.5 Veedurías ciudadanas sobre el IESS (CPCCS, Ecuador)**
- El CPCCS convocó veedurías sobre designaciones de autoridades de unidades médicas del IESS (2019-2020), inversiones del BIESS (2020) y acciones de IESS-SOLCA (2022); en abril de 2020 tres informes de veedores señalaron que, pese a reunirse con autoridades, no lograron ciertos avances. — [CPCCS, 04-2020](https://cpccs.gob.ec/2020/04/pleno-del-cpccs-conoce-avances-en-veedurias-ciudadanas-que-vigilan-designacion-de-autoridades-del-iess-y-contrataciones-publicas-relacionadas-a-covid-19); [CPCCS, 10-2020](https://www.cpccs.gob.ec/2020/10/cpccs-convocara-veeduria-biess); [CPCCS, 01-2022](https://www.cpccs.gob.ec/2022/01/veeduria-a-la-gestion-publica-realizada-por-solca-y-el-iess)
- Las veedurías son entidades ciudadanas independientes del CPCCS, cívicas, voluntarias y neutrales. — [CPCCS, convocatoria](https://www.cpccs.gob.ec/wp-content/uploads/2020/02/texto_convocat_cargos_iess.pdf)
- Nivel: B (operación), sin evaluación de efecto.

### Inferences

| Solución | Por qué es atípica | Transferencia al IESS | Riesgos | Escala |
|---|---|---|---|---|
| **"Reporta y lo bajamos" (SERS + takedown IESS)**: botón o número único para reportar páginas, perfiles y números falsos con marca IESS, con tablero público de cuántos se retiraron y en cuánto tiempo | Cierra el ciclo (el ciudadano ve que su reporte tuvo efecto), algo raro en entidades públicas | Contratar takedown por servicio o convenir con CSIRT/EcuCERT; recompensa simbólica al reportante (familia 3) | Costo recurrente; sin capacidad real de retiro, el botón genera frustración; las plataformas responden lento | CONVERGENTE en Reino Unido / PERIFERIA en la región |
| **Fondo de garantía o reembolso para víctimas de suplantación** (modelo PSR/INSS) con regla de cuidado razonable | Traslada el costo del fraude a quien puede prevenirlo, lo que crea incentivos institucionales para la fricción | Responde al dolor del estudio previo (la víctima sigue pagando cuotas mientras investiga la Fiscalía) | Riesgo moral; costo; requiere decisión del BIESS y normativa; la evidencia de que reduce el fraude es contradictoria | ATÍPICO para la seguridad social |
| **Veeduría ciudadana de seguridad digital** (estudiantes y jubilados auditan el recorrido de reporte y la respuesta del IESS) | Usa una institución constitucional ecuatoriana para la ciberseguridad, que suele quedar fuera del control social | Encaja con el CPCCS y con la auditoría (ISACA en el jurado) | Las veedurías previas lograron poco; politización; acceso a información sensible | PERIFERIA |
| **"Muro de la vergüenza" de tramitadores condenados** | Disuasión por reputación, mencionada en la región | — | Vulnera la protección de datos, la presunción de inocencia y la cultura justa; la OCDE duda de su eficacia; no recomendado | ATÍPICO negativo |

### Gaps
- No se encontraron programas de recompensa (bounty) para reportar páginas o perfiles falsos de una entidad pública.
- No se localizó el documento de la ISSA que mencionaría la publicación de nombres de defraudadores.
- No se encontraron seguros contra fraude vendidos a pensionistas.

## 8. Valores atípicos negativos: lo que salió mal (advertencias)

### Takeaway
Los fracasos se agrupan en tres patrones: (1) simulacros de phishing con cebos de bonos en tiempos de penuria, que dañaron la confianza laboral (Tribune 2020, GoDaddy 2020, West Midlands Trains 2021); (2) sistemas automatizados y opacos de detección de fraude que castigaron a inocentes y derribaron gobiernos (Robodebt, SyRI, toeslagenaffaire); (3) intervenciones "obvias" que no funcionan o empeoran las cosas (Scared Straight, firmar arriba, biometría sin control de vida). El caso brasileño del INSS muestra además que la complicidad interna derrota cualquier campaña de concienciación.

### Cited Findings

**8.1 Simulacros de phishing con bono falso**
- **Tribune Publishing (09-2020, no 2021):** correo que prometía bonos de USD 5.000 a 10.000 en plena época de recortes salariales y despidos; era una plantilla de simulación de KnowBe4; quienes hicieron clic recibieron capacitación obligatoria; la empresa se disculpó y la calificó de "engañosa e insensible". — [NewsGuild](https://newsguild.org/newsguild-condemns-tribune-hoax/); [KnowBe4](https://blog.knowbe4.com/tribune-publishing-apologizes-for-fake-bonus-offer-in-phishing-simulation-email); [SC Media](https://www.scworld.com/news/insensitive-phishing-test-stirs-debate-over-ethics-of-security-training)
- **GoDaddy (12-2020):** correo "GoDaddy Holiday Party" con un bono de USD 650; unos 500 empleados hicieron clic y llenaron un formulario; dos días después se les dijo que habían fallado; la empresa se disculpó. — [Engadget](https://www.engadget.com/godaddy-sent-fake-phising-email-promising-holiday-bonus-220756457.html); [CBS News](https://www.cbsnews.com/news/godaddy-apologizes-insensitive-phishing-email-bonuses-employees)
- **West Midlands Trains (04/05-2021):** bono de agradecimiento por el trabajo durante la pandemia; unos 2.500 destinatarios según el sindicato TSSA (más de 400 según ITV); el sindicato lo llamó "cínico e impactante" y exigió un bono real; la empresa defendió el test. — [TSSA](https://www.tssa.org.uk/news-and-events/tssa-news/anger-over-shocking-covid-bonus-stunt-at-west-midlands-trains); [ITV, 11-5-2021](https://itv.com/news/central/2021-05-11/cynical-and-shocking-west-midlands-railway-offers-bonus-to-staff-in-cyber-security-test)
- Evidencia de fondo: el seguimiento del grupo de Lain menciona "resultados paradójicos", como empleados que rinden mejor sin capacitación embebida. — [Lain et al., arXiv 2409.01378](https://arxiv.org/html/2409.01378v1)
- Nivel: C (casos) + A (evidencia de fondo).

**8.2 Robodebt (Australia, 2015-2020)**
- La Comisión Real (7-7-2023) halló que el promedio de ingresos era ilegal y violaba la equidad procesal; se cobraron indebidamente unos A$721 M a unas 381.000 personas (las cifras varían según la fuente; el gobierno habla de más de 500.000 víctimas); un tribunal federal lo declaró ilegal en 2019; la Comisión vinculó el esquema a angustia, penuria e incluso muertes; hubo remisiones para procesos civiles y penales. — [Primer Ministro de Australia](https://www.pm.gov.au/media/final-report-royal-commission-robodebt-scheme); [Law Society Journal](https://lsj.com.au/articles/crude-cruel-and-unlawful-robodebt-royal-commission-findings/); [Jurist, 07-2023](https://www.jurist.org/news/2023/07/australia-robodebt-royal-commission-hands-down-findings-recommends-referrals-for-prosecution/)
- La Comisión del Servicio Público halló que 12 funcionarios violaron su código de conducta 97 veces. — [SBS](https://www.sbs.com.au/news/article/human-services-officials-breached-code-of-conduct-over-robodebt-taskforce-finds/t1rkgglsg)
- Nivel: A (investigación oficial).

**8.3 SyRI (Países Bajos, sentencia del 5-2-2020)**
- El tribunal de distrito de La Haya declaró ilegal el sistema de puntuación de riesgo de fraude en prestaciones por violar el art. 8 del Convenio Europeo de Derechos Humanos, por falta de equilibrio entre detección y privacidad y por opacidad de sus indicadores; se había dirigido a barrios de bajos ingresos y minorías. — [Human Rights Watch](https://www.hrw.org/news/2020/02/06/dutch-ruling-victory-rights-poor); [TechCrunch](https://techcrunch.com/2020/02/06/blackbox-welfare-fraud-detection-system-breaches-human-rights-dutch-court-rules); [ASIL](https://www.asil.org/ILIB/netherlands-district-court-rules-benefits-fraud-detection-tool-violates-human-rights)
- Nivel: A (sentencia).

**8.4 Toeslagenaffaire (Países Bajos, 2013-2019)**
- Alrededor de 26.000 familias fueron acusadas falsamente de fraude en subsidios de cuidado infantil; errores menores se trataron como fraude y la nacionalidad se usó como factor de riesgo; el tercer gabinete de Rutte renunció en enero de 2021; más de 33.000 familias fueron reconocidas como víctimas para 2024. — [DutchNews, 01-2024](https://www.dutchnews.nl/2024/01/over-33000-families-acknowledged-as-benefit-scandal-victims/); [IamExpat](https://www.iamexpat.nl/expat-info/dutch-news/dutch-cabinet-resigns-wake-childcare-benefit-scandal); [Courthouse News](https://www.courthousenews.com/child-welfare-scandal-topples-dutch-government/)
- Nivel: A (investigación parlamentaria).

**8.5 Biometría eludida o capturada (Brasil)**
- Un fraude de R$86 M expuso brechas en la biometría del INSS con identidades ficticias y "dobles" humanos. — [NSC Total](https://www.nsctotal.com.br/economia/fraude-de-r-86-milhoes-expoe-brechas-na-biometria-do-inss)
- "Golpe de la falsa prueba de vida": delincuentes que se hacen pasar por servidores del INSS o repartidores capturan la biometría facial de jubilados para pedir préstamos consignados en su nombre. — [Santander Brasil](https://www.santander.com.br/blog/golpe-prova-de-vida-inss); [Folha PE](https://www.folhape.com.br/economia/golpe-da-falsa-prova-de-vida-inss-faz-alerta-sobre-fraude-a/512637/)
- Un reportaje titula que los mayores tienen una tasa de error cinco veces mayor en biometría facial (solo se vio el titular). — [Bem Paraná](https://www.bemparana.com.br/noticias/economia/idosos-tem-taxa-de-erro-cinco-vezes-maior-em-biometria-facial-e-sofrem-com-golpes-e-restricoes/amp/)
- Nivel: C.

**8.6 Intervenciones de miedo o compromiso que no funcionan**
- Scared Straight: el metaanálisis de Petrosino et al. (Campbell/Cochrane, 2013; 9 estudios, 946 participantes) halló que estos programas aumentan la delincuencia frente a no hacer nada (OR 1,68; IC 95 % 1,20-2,36). — [Cochrane](https://www.cochrane.org/evidence/CD002796_scared-straight-and-other-juvenile-awareness-programs-preventing-juvenile-delinquency)
- "Firmar arriba": el estudio de 2012 que mostraba más honestidad al firmar al inicio del formulario fue retractado por PNAS el 21-9-2021 tras hallarse datos fabricados en el experimento con una aseguradora; una réplica de 2020 de los mismos autores no encontró efecto. — [BuzzFeed News](https://www.buzzfeednews.com/stephaniemlee/dan-ariely-honesty-study-retraction); [Big Think](https://bigthink.com/the-present/honesty-pledge-study-fraud-dan-ariely/)
- Nivel: A.

### Inferences

| Antipatrón | Lección para el IESS | Escala |
|---|---|---|
| Simulacro de phishing con "bono", "décimo" o "aumento de pensión" | Prohibir cebos que jueguen con la necesidad económica de servidores o jubilados (crisis, deuda del Estado con el IESS); pactar el catálogo de cebos con sindicatos; nunca simular a jubilados | ATÍPICO negativo (aunque muy frecuente) |
| Puntuación algorítmica opaca de "afiliados sospechosos" (Robodebt, SyRI, toeslagen) | Toda analítica antifraude debe ser explicable, contestable, sin variables proxy de origen o pobreza, y con evaluación de impacto (LOPDP, SPDP); conviene poner el foco en el atacante y en el servidor con acceso, no en el beneficiario | ATÍPICO negativo |
| Biometría como bala de plata | La biometría se captura (falsa prueba de vida); no tratar "conocer mis datos" ni "mostrar mi cara" como prueba de legitimidad | ATÍPICO negativo |
| Campañas de miedo y "firmar el compromiso" | El miedo puede salir caro (Scared Straight); los compromisos firmados no tienen respaldo tras la retractación; usar mensajes de eficacia y fricción de proceso | ATÍPICO negativo |
| Complicidad interna (INSS 2025) | Una campaña al ciudadano no sirve si un servidor habilita el fraude; el Reto 1 debe incluir la ética del acceso y el riesgo interno | Advertencia estructural |

### Gaps
- No se encontraron casos documentados de "dedos de silicona" contra el INSS (solo en cajeros bancarios en general).
- No se encontraron evaluaciones del daño a la confianza laboral tras los simulacros de bonos (solo prensa y sindicatos).

## 9. Síntesis: qué combinaciones de periferia y atípico encajan con los criterios del Reto 1

### Takeaway
Las ideas atípicas más defendibles ante un jurado de seguridad, protección de datos, auditoría y registros públicos combinan tres cosas: un mecanismo raro con al menos evidencia B en otro dominio, que actúe sobre la secuencia clave-cambio-cobro o sobre el riesgo interno, y que sea demostrable con datos sintéticos. Las candidatas más fuertes son el "Candado IESS" con enfriamiento y contacto de confianza, el "jubilado trampa" como honeytoken de procesos bajo cultura justa, el canal de "casi-fraude" para servidores y la verificación comunitaria con takedown visible.

### Cited Findings
- El estudio previo fija como criterios: atacar conductas y momentos de riesgo concretos, incluir el riesgo interno, favorecer el reporte sobre el clic, cultura justa, que la solución no pueda ser imitada por estafadores, privacidad desde el diseño, accesibilidad, resiliencia ante apagones, medición seria y demostración en 10 minutos sin datos reales. — [Estudio previo, basado en Lain et al.](https://arxiv.org/abs/2112.07498); [CREST](https://www.crestresearch.ac.uk/resources/phishing-your-staff/)
- Los modelos compartimentales sugieren priorizar la perturbación del ciclo del estafador sobre la susceptibilidad de la víctima. — [arXiv 2508.19817](https://arxiv.org/abs/2508.19817)
- La fricción voluntaria con enfriamiento muestra baja tasa de abandono en su dominio de origen (autoinformado). — [Monzo](https://monzo.com/blog/weve-improved-our-gambling-block)
- Los ciudadanos como auditores tienen evidencia A en impuestos. — [Naritomi, AER 2019](https://www.aeaweb.org/doi/10.1257/aer.20160658)
- El reporte masivo conectado a un retiro real escala a millones. — [NCSC Annual Review 2022](https://www.ncsc.gov.uk/collection/annual-review-2022/resilience/active-cyber-defence)

### Inferences
- **Propuesta tipo A, "Candado IESS + Afiliado Auditor":** un candado voluntario con enfriamiento sobre cambios sensibles y préstamos (Monzo, Money Lock, Pix nocturno), notificación a un contacto de confianza (FINRA) y un sorteo simbólico para quien revisa y confirma su historial (Nota Fiscal Paulista). Es atípico por combinar un dispositivo de compromiso con ciudadanos auditores. Debe presentarse como "cultura de compromiso" que exige un cambio de proceso del BIESS, y nombrarse como dependencia (criterio de honestidad sobre los límites).
- **Propuesta tipo B, "Jubilado trampa + Casi-fraude":** honeytokens de procesos (pensionistas y préstamos sintéticos) que detectan abuso interno, combinados con un canal confidencial y no punitivo de casi-incidentes para servidores. Así el mensaje cultural es "te protegemos si reportas" y no solo "te vigilamos". Exige pacto sindical, evaluación de impacto ante la SPDP y aislar contablemente los señuelos.
- **Propuesta tipo C, "Brote IESS":** una línea comunitaria tipo Cofacts, una respuesta 2-2-2 con humor y un tablero epidemiológico de campañas conectado a un takedown con resultados visibles, más un bot señuelo tipo Daisy como fuente opcional de indicadores. Es el más demostrable en 10 minutos y el más cercano a la periferia. Su punto débil es el costo recurrente y la dependencia de que las plataformas retiren el contenido.
- **Capa cultural transversal** (elegir una): teatro foro en salas de espera, escape room móvil para personal sanitario (con evidencia en profesionales de salud), radionovela con trama central o un concurso de canciones. Ninguna sirve sola: Bogotá y Shuga muestran que el arte funciona dentro de un paquete con sanción, proceso y continuidad.
- **Lo que un jurado de SPDP, DAMA e ISACA probablemente penalizaría:** el muro de la vergüenza, la puntuación opaca de beneficiarios, los simulacros con cebos de bonos, la biometría como solución única y los compromisos firmados como prueba de eficacia.
- **Medición atípica sugerida:** en vez de la tasa de clic, medir el tiempo desde la primera víctima hasta el retiro del sitio, el número de reportes por campaña, la proporción de cambios de cuenta revertidos dentro del enfriamiento, las alertas de honeytoken por cada 1.000 servidores y la percepción de justicia del programa.

### Gaps
- No se verificó la viabilidad jurídica en Ecuador de sorteos institucionales, registros señuelo en sistemas públicos ni inmunidad por reporte de casi-incidentes; son preguntas para la SPDP, la Contraloría y Asesoría Jurídica del IESS.
- No se encontró evidencia de ninguna de estas combinaciones aplicada a una institución de seguridad social; todas son extrapolaciones.
- No se obtuvieron costos de takedown por servicio, bots de voz IA ni producción de teatro o radionovela en Ecuador.
