# Panorama de amenazas digitales en Ecuador (2019-2026): sector público, ciudadanos y fraude

Notas de investigación. Fecha de corte: 25 de noviembre de 2026. Cada cifra lleva año y fuente. Cuando una fuente es secundaria, comercial o no confirmada, se indica.

## 1. Incidentes cibernéticos mayores contra instituciones públicas y críticas (2019-2026)

### Takeaway
Ecuador acumula una cadena de incidentes graves contra el Estado: la filtración de Novaestrat (2019, ~20 millones de registros, con datos del Registro Civil, BIESS e IESS), una ola de ransomware en 2021 (CNT, Ministerio de Finanzas, Consejo de Comunicación, Banco Pichincha), ataques al voto telemático (2023), un ataque de saturación al Registro Civil (enero 2025) y una presunta filtración de 14,8 millones de registros de identidad con 10,6 millones de fotos de cédula (mayo 2026). El patrón dominante no es un hackeo sofisticado sino servidores mal configurados, intermediarios con acceso a bases estatales, ex funcionarios con datos y ransomware sobre sistemas sin parches. No se encontró ningún ciberataque confirmado contra la infraestructura del IESS, pero sí fraude con credenciales e insiders (ver sección 5).

### Cited Findings

**Novaestrat (septiembre 2019)**
- Un servidor inseguro ubicado en Miami, propiedad de la empresa ecuatoriana Novaestrat, expuso información de más de 20 millones de personas (Ecuador tenía ~17 millones de habitantes; incluye fallecidos y duplicados) — [INCIBE-CERT](https://www.incibe.es/en/incibe-cert/publications/cybersecurity-highlights/data-leak-millions-ecuadorians)
- La empresa fue creada en 2017 por dos ex funcionarios que trabajaron en Senplades, Secom y el Banco Nacional de Fomento; la defensa sostuvo que había duplicaciones, por lo que la cifra real sería menor — [INCIBE-CERT](https://www.incibe.es/en/incibe-cert/publications/cybersecurity-highlights/data-leak-millions-ecuadorians)
- El gobierno fue informado oficialmente el 11 de septiembre de 2019 y la filtración se hizo pública el 16 de septiembre de 2019 — [Autonomía Digital, análisis de la filtración](https://autonomia.digital/2019/09/28/analysis-novaestrat.html)
- La base contenía información proveniente del Registro Civil, del BIESS y datos de propietarios de vehículos; el gobierno denunció ante Fiscalía que ex funcionarios del gobierno de Rafael Correa estaban detrás — [El Universo, 17-09-2019](https://www.eluniverso.com/noticias/2019/09/17/nota/7522132/exfuncionarios-detras-filtracion-datos)
- El gerente de Novaestrat fue detenido en Esmeraldas; la Fiscalía investigó por presunta violación a la intimidad; Fiscalía investiga también a Databook — [La Hora](https://www.lahora.com.ec/noticias/bases-de-datos-personales-se-venden-hasta-en-portales-de-ventas-en-linea/); [INCIBE-CERT](https://www.incibe.es/en/incibe-cert/publications/cybersecurity-highlights/data-leak-millions-ecuadorians)
- CNT (empresa pública) había comprado información a Databook, la empresa protagonista del escándalo — [Primicias](https://www.primicias.ec/noticias/tecnologia/cnt-contrato-databook-empresa-investigada-filtracion-masiva-datos/)
- Contexto: el caso fue catalizador del debate que llevó a la Ley Orgánica de Protección de Datos Personales; GK lo describió como un problema "profundo, urgente y subestimado" de venta de bases de datos — [GK, 22-09-2019](https://gk.city/2019/09/22/filtracion-de-datos-en-ecuador/); [Plan V](https://planv.com.ec/historias/sociedad/la-peor-filtracion-datos-la-historia-del-ecuador-al-descubierto/)

**CNT, ransomware (julio 2021; nota: no fue en 2022)**
- Un ataque informático apagó las computadoras de la Corporación Nacional de Telecomunicaciones; ocurrió alrededor del 14 de julio de 2021 — [Infobae, 19-07-2021](https://www.infobae.com/america/america-latina/2021/07/19/un-ataque-informatico-apago-las-computadoras-de-la-corporacion-nacional-de-telecomunicaciones-del-ecuador/)
- El gobierno declaró en emergencia a CNT; la ministra de Telecomunicaciones Vianna Maino lo anunció — [Bloomberg Law](https://news.bloomberglaw.com/tech-and-telecom-law/ecuador-state-telecom-in-emergency-amid-ransomware-attack)
- Atribuido al grupo RansomEXX, que afirmó haber robado más de 190 GB de datos (atribución presunta) — [Latest Hacking News, 20-07-2021](https://latesthackingnews.com/2021/07/20/ecuador-telecom-giant-cnt-suffered-cyber-attack-ransomware-suspected/)
- El ataque cifró servidores críticos y dejó fuera de servicio la atención al cliente y los portales de pago durante varios días; las autoridades negaron fuga de datos, pero la prensa reportó versiones contradictorias — [Multidominio360 (análisis secundario)](https://www.multidominio360.com/post/en-la-mira-de-la-dark-web-el-asedio-cibern%C3%A9tico-al-sector-privado-ecuatoriano)

**Otros ataques estatales 2021 (Ministerio de Finanzas, Consejo de Comunicación)**
- En agosto de 2021, el Consejo de Comunicación fue atacado por ransomware que cifró sus bases de datos; Infobae señaló que el Ministerio de Finanzas y el Banco Pichincha también fueron víctimas de este tipo de ciberdelito en 2021 — [Infobae, 04-08-2021](https://www.infobae.com/america/america-latina/2021/08/04/nuevo-ataque-cibernetico-a-un-organismo-estatal-ecuatoriano/)

**Banco Pichincha (octubre 2021)**
- El banco más grande del país reconoció el 11 de octubre de 2021 un incidente de ciberseguridad que inhabilitó parcialmente sus servicios electrónicos — [Infobae/agencias, 15-10-2021](https://www.infobae.com/america/agencias/2021/10/15/el-mayor-banco-de-ecuador-sufre-un-ciberataque/); [Revista Seguridad 360](https://revistaseguridad360.com/noticias/hackeo-al-banco-pichincha/)
- La Superintendencia de Bancos envió un equipo de supervisión, afirmó que no hubo afectación a depósitos y ordenó auditoría forense externa e informática/financiera — [Superintendencia de Bancos](https://www.superbancos.gob.ec/bancos/acciones-de-la-super-de-bancos-frente-a-ciberataque-de-entidad-controlada/); [La Hora](https://www.lahora.com.ec/pais/superintendencia-analiza-ataque-banco-pichincha/)
- La superintendenta Ruth Arregui atribuyó el ataque a actores internacionales ante la Asamblea; un portal especializado mencionó ransomware con Cobalt Strike (no confirmado por el banco) — [El Universo](https://www.eluniverso.com/noticias/economia/ciberataque-a-banco-pichincha-fue-realizado-por-atacantes-internacionales-se-revela-en-comision-de-desarrollo-economico-nota/)
- MINTEL pidió al banco informar sobre el grado de vulnerabilidad — [El Comercio](https://www.elcomercio.com/actualidad/negocios/mintel-banco-pichincha-grado-vulnerabilidad-ataque/)

**Petroecuador / Petroamazonas**
- Una fuente secundaria afirma que Petroecuador sufrió un ataque de ransomware en 2020 que detuvo operaciones varios días (fuente única, no verificada) — [ODINT Atlas](https://odint.io/atlas/ecuador/energy-oil-telecom/)
- Un grupo brasileño reivindicó la filtración de 15 GB de datos de empleados de Petroamazonas y CEPAM; no hubo pronunciamiento oficial — [Imago](https://www.imago.com.ar/en/actualidad/39499/brazilian-hacker-group-claims-massive-15gb-data-leak-of-ecuadors-petroamazonas-and-cepam-employees)
- SOCRadar lista 14 incidentes de ransomware en Ecuador y afirma que los sistemas de Petroecuador fueron comprometidos (agregador sin fechas ni fuentes) — [SOCRadar](https://socradar.io/free-tools/ransomware-intelligence/countries/ecuador)

**CNE / voto telemático (elecciones seccionales de febrero 2023) y Asamblea Nacional**
- La autoridad electoral informó que ciberataques originados en siete países interrumpieron el voto en línea de ecuatorianos en el exterior; unos 120.000 se habían registrado para votar de forma telemática — [The Record](https://therecord.media/ecuador-national-assembly-cyberattack)
- La Asamblea Nacional dijo haber identificado y contrarrestado intentos de piratas informáticos de acceder a información confidencial; The Record lo sitúa una semana después de una elección general en la que Daniel Noboa no obtuvo mayoría absoluta (la fecha exacta no se pudo verificar; probablemente febrero 2025) — [The Record](https://therecord.media/ecuador-national-assembly-cyberattack)

**Registro Civil (2025-2026)**
- Enero 2025: el Registro Civil denunció ante Fiscalía un ataque que saturó su Agencia Virtual y su web, con miles de peticiones simultáneas desde IP de Brasil, México y Colombia; el sistema más afectado fue el agendamiento de turnos para cédulas y pasaportes — [Ecuavisa](https://www.ecuavisa.com/noticias/ecuador/registro-civil-denuncia-ciberataque-sistemas-informaticos-pagina-web-YF8700436)
- El Registro Civil reportó más de 3,5 millones de intentos de ciberataque en 2024-2025, que dice haber neutralizado — [Infobae, 06-05-2026](https://www.infobae.com/america/america-latina/2026/05/06/casi-15-millones-de-datos-de-identidad-de-ecuatorianos-aparecieron-en-redes-y-foros-clandestinos-autoridades-investigan-una-nueva-filtracion-masiva/)
- Mayo 2026: la plataforma VECERT Analyzer alertó (4 de mayo) sobre una base atribuida al Registro Civil en Dark Forums con ~14,8 millones de registros y más de 10 millones de imágenes de cédula en alta resolución; incluiría nombres, número de cédula, fotos, firmas y datos biométricos (huellas, firmas digitalizadas); parte se compartió como muestra gratuita — [Infobae, 06-05-2026](https://www.infobae.com/america/america-latina/2026/05/06/casi-15-millones-de-datos-de-identidad-de-ecuatorianos-aparecieron-en-redes-y-foros-clandestinos-autoridades-investigan-una-nueva-filtracion-masiva/); [Primicias](https://www.primicias.ec/ciencia-tecnologia/filtracion-registro-civil-ecuador-fotos-cedula-datos-biometricos-122005/)
- El Registro Civil (Digercic) negó vulneración del "repositorio actual" y sugirió que los datos vendrían de registros históricos o integraciones con terceros; luego lo atribuyó a robo de información por dos ex funcionarios que accedieron a datos durante el gobierno de la "revolución ciudadana" — [Infobae](https://www.infobae.com/america/america-latina/2026/05/06/casi-15-millones-de-datos-de-identidad-de-ecuatorianos-aparecieron-en-redes-y-foros-clandestinos-autoridades-investigan-una-nueva-filtracion-masiva/); [Vistazo, 05-05-2026](https://www.vistazo.com/actualidad/nacional/2026-05-05-hackeo-informacion-registro-civil-ecuador-ley-proteccion-datos-criterios-GK10925892)
- La Superintendencia de Protección de Datos Personales abrió investigación y calificó la tesis de "no filtración" como "hipótesis sujeta a verificación"; puede requerir información a entidades con bases de identidad interoperables — [Infobae](https://www.infobae.com/america/america-latina/2026/05/06/casi-15-millones-de-datos-de-identidad-de-ecuatorianos-aparecieron-en-redes-y-foros-clandestinos-autoridades-investigan-una-nueva-filtracion-masiva/); [KCH FM, 07-05-2026](https://kchcomunicacion.com/2026/05/07/mas-de-40-millones-de-datos-personales-de-ecuatorianos-a-la-venta-reciclaje-negacion-oficial-y-un-gran-riesgo-biometrico/)
- Una oferta relacionada en BreachForums ("EcuaBúsqueda") anunciaba 199 GB de información a la venta — [Newschu (Substack)](https://newschu.substack.com/p/venta-datos-ecuabusqueda-en-foro-hacking)
- Semanas antes (2026), la ANT descartó una filtración de 17 millones de datos que incluiría teléfonos y direcciones — [Primicias](https://www.primicias.ec/ciencia-tecnologia/ant-filtracion-datos-ecuador-telefonos-direcciones-vehiculos-estafas-121504/)
- Expreso analizó por qué los sistemas públicos siguen siendo vulnerables al robo de datos — [Extra/Expreso](https://www.extra.ec/noticia/premium/robo-datos-ecuador-sistemas-siguen-siendo-vulnerables-155958.html)

**Ransomware 2025 según EcuCERT**
- EcuCERT registró 15 víctimas de ransomware y 32 filtraciones de datos en 2025 (81% data breach, 19% data leak); grupos: Qilin, RansomHub, Danger21, Trigona, INC Ransomware, Crytox, Warlock, Gentlemen; sectores afectados: eléctrico, gobierno, comercial, alimentos, financiero, inmobiliario, salud, petróleos, construcción, desarrollo de software, educación, minero — [EcuCERT/ARCOTEL, "Estado de la ciberseguridad año 2025" (PDF, enero 2026)](https://www.ecucert.gob.ec/wp-content/uploads/2026/01/estado-de-ciber-seguridad.pdf); [Security-CHU](https://www.security-chu.com/2026/01/informe-de-ecucert-reporta-15-casos-de-ransomware.html)

### Inferences
- La lista de sectores afectados por ransomware en 2025 (gobierno, salud, eléctrico) indica que hubo víctimas públicas y sanitarias, aunque no se identificaron por nombre en las fuentes revisadas.
- Las bases del Registro Civil, BIESS e IESS han aparecido juntas en filtraciones desde 2019; cualquier dato de identidad que un estafador presente a un afiliado del IESS (cédula, foto, firma, dirección) debe suponerse ya disponible en el mercado criminal. La "verificación por datos personales" no sirve como control de autenticación.
- El vector recurrente es el acceso legítimo mal gobernado (intermediarios, ex funcionarios, integraciones con terceros) más que la intrusión técnica.

### Gaps
- No se encontraron reportes confirmados de ransomware contra CNEL, el Ministerio de Salud Pública u hospitales públicos específicos en 2023-2026. Los casos de CNEL encontrados son de corrupción en facturación, no ciberataques (más de 400.000 cuentas manipuladas por funcionarios) — [Ecuador Brief](https://www.ecuadorbrief.com/articles/cnel-corruption-300-million-46-officials-400000-accounts-decade).
- No se encontró ningún ciberataque confirmado contra los sistemas del IESS (sí fraude interno y de credenciales).
- Causa raíz técnica del ataque a CNT 2021 y del Ministerio de Finanzas 2021: no hay informe oficial público.
- No se pudo verificar la fecha exacta del incidente de la Asamblea Nacional.
- El artículo de La Hora "Cinco de cada diez instituciones públicas han sufrido algún tipo de ataque cibernético en los últimos cuatro años" no estaba disponible (404); solo se conoce el titular.

## 2. Estadísticas: EcuCERT/ARCOTEL, rankings de proveedores, ITU GCI y NCSI

### Takeaway
Ecuador figura entre los 3-5 países más atacados de América Latina en varias métricas de proveedores (Kaspersky: 4.º en ransomware, 3.º en amenazas móviles; Check Point: 3.º más atacado en 2024). EcuCERT reportó en 2025 unas 97.250 direcciones IP con incidentes (alza frente a 2024) y 156.170 filtraciones de contraseñas, 14% de ellas del sector gobierno. En los índices de madurez, Ecuador está en Tier 2 "Advancing" del ITU GCI 2024 (puntaje 87,11), pero cayó al puesto 100 del NCSI (40,83 puntos, versión de marzo 2026), lo que muestra una brecha entre el marco normativo y la capacidad operativa.

### Cited Findings

**EcuCERT/ARCOTEL "Estado de la ciberseguridad año 2025"** (infografía publicada en enero 2026; texto extraído del PDF) — [EcuCERT](https://www.ecucert.gob.ec/wp-content/uploads/2026/01/estado-de-ciber-seguridad.pdf)
- Direcciones IP notificadas con incidentes: 70.975 (2024) frente a 97.250 (2025), diferencia de 26.275; el informe lo describe como un alza del 34%. (Nota: 26.275/70.975 da ~37%; la infografía es ambigua sobre la base del cálculo.)
- Direcciones IP con vulnerabilidades: 344.339 (2024) frente a 228.583 (2025), diferencia de 115.756; el informe lo describe como una baja del 27% (115.756/344.339 da ~34%; los porcentajes parecen cruzados en la infografía).
- Incidentes por tipo (top 5): Sinkhole HTTP 37% (equipos infectados que contactan servidores de botnets intervenidos), Scanners 28%, Malware 14%, Pass_LEAK (filtración de contraseñas) 11%, Sinkhole DNS 4%.
- Filtraciones de contraseñas (leaks): 156.170, de las cuales 86% sector educación, 14% gobierno, 1% Fuerzas Armadas.
- Top 5 vulnerabilidades: CWMP (IPv4 e IPv6) 22%, Telnet abierto 22%, DNS open resolver 12%, SNMP abierto 6%, SSH abierto 4%.
- Ciudades con más sistemas vulnerables: Quito 42%, Guayaquil 20%, Cuenca 8%, Ambato 6%, Machala 4%, Samborondón 4%, Ibarra/Portoviejo/Manta ~3%.
- Ransomware: 15 víctimas; filtraciones de datos: 32.
- Publicaciones de alerta de phishing: 90% suplantación de identidad, 10% falso beneficio; 64 alertas y 11 avisos de seguridad emitidos; 5.340 beneficiarios de sensibilización en 31 organizaciones (educación, telecomunicaciones, GAD, minero, petróleo, financiero, función electoral, FF.AA., sector público).
- EcuCERT publica campañas de phishing con suplantación de entidades en su biblioteca de alertas (sin totales) — [EcuCERT alertas](https://www.ecucert.gob.ec/bibliotecadealertas/)

**Kaspersky (Panorama de Amenazas LatAm)**
- Ransomware, agosto 2024 a junio 2025: Ecuador 4.º en América Latina con 37.000 detecciones, detrás de Brasil (549.000), México (237.000) y Chile (43.000); Colombia 5.º (35.000) — [Kaspersky LatAm](https://latam.kaspersky.com/about/press-releases/ataques-de-ransomware-superan-11-millones-de-intentos-en-america-latina)
- Ataques a Mac, agosto 2024 a julio 2025: Ecuador 3.º con 35.000 (Brasil 180.000, México 84.000) — [Kaspersky LatAm](https://latam.kaspersky.com/about/press-releases/america-latina-registra-mas-de-726-mil-ciberataques-a-sistemas-linux-y-mas-de-431-mil-a-mac-en-un-ano)
- Amenazas móviles bloqueadas: Ecuador 3.º con 402.000, detrás de Brasil (1,8 millones) y México (835.000) — [ITSitio](https://www.itsitio.com/seguridad/kaspersky-ataques-crecen-70/)
- Malware, septiembre 2025 a septiembre 2026: Ecuador con 18,4 millones de intentos de infección bloqueados, entre los primeros puestos de la región (dato del resumen de búsqueda; no se leyó el texto completo) — [El Comercio Perú](https://elcomercio.pe/tecnologia/ciberseguridad/latinoamerica-registro-592-millones-de-ataques-de-malware-en-un-ano-18-menos-que-el-periodo-anterior-kaspersky-noticia/)

**Check Point**
- 2024: Ecuador fue el tercer país más atacado de la región, detrás de Perú y Colombia, con un aumento de 4,9% en amenazas — [Canal RTU, 18-02-2025](https://canalrtu.tv/2025/02/18/ciberseguridad-en-riesgo-ecuador-entre-los-mas-atacados-en-america-latina/)
- Primer semestre 2025 (regional): 2.716 ataques semanales promedio por organización en LatAm, 39% más que el promedio global (1.955) — [Check Point Research](https://blog.checkpoint.com/research/latin-america-2025-mid-year-cyber-snapshot-reveals-39-surge-in-attacks-as-ai-threats-escalate-regional-risk/)

**Fortinet**
- Primer semestre 2025: Ecuador recibió 380 millones de intentos de ciberataque (sin ranking por país) — [Canal News Ecuador, 19-08-2025](https://canalnews.ec/2025/08/19/fortinet-asegurando-la-infraestructura-critica-en-ecuador/)
- Año 2025 (regional): cerca de 15.000 millones de intentos de explotación en América Latina — [Tabulado](https://www.tabulado.net/fortinet-registro-cerca-de-15-000-millones-de-intentos-de-explotacion-en-america-latina-durante-2025/)

**Índices de madurez**
- ITU Global Cybersecurity Index 2024 (5.ª edición): Ecuador en Tier 2 "Advancing" (rango 85-95) — [ITU GCI 2024](https://www.itu.int/epublications/publication/global-cybersecurity-index-2024)
- Puntaje GCI 2024 de Ecuador: 87,11 (datos ITU vía World Bank Data360) — [Statbase](https://statbase.org/datasets/indexes-and-ratings/global-cybersecurity-index/); [Statranker](https://statranker.org/digital-innovation/top-100-countries-by-global-cybersecurity-index-2026-snapshot-based-on-latest-official-2024-data/)
- Un blog cita un GCI de 26,3 para Ecuador, contradictorio con ITU; se descarta como no fiable — [Mixmode](https://www.mixmode.ai/blog/global-cybercrime-report-2024-which-countries-face-the-highest-risk)
- NCSI (e-Governance Academy): Ecuador en el puesto 100 con 40,83 puntos (versión de marzo 2026) — [NCSI Ecuador](https://www.ncsi.ega.ee/country/ec/)
- NCSI edición 2022: Ecuador puesto 67 con 53,25 puntos — [NCSI Ecuador 2022](https://ncsi.ega.ee/country/ec_2022/)

### Inferences
- El 14% de contraseñas filtradas del sector gobierno en 2025 (~21.900 si se aplica el porcentaje a 156.170) sugiere que el robo de credenciales de funcionarios es un riesgo material para cualquier institución pública, incluido el IESS.
- La alta proporción de "Sinkhole HTTP" y malware indica una base grande de equipos infectados (botnets, infostealers) en redes ecuatorianas; los infostealers son la fuente típica de credenciales robadas.
- La caída en el NCSI (67 a 100) puede deberse en parte a cambios metodológicos, pero indica que Ecuador no ha acreditado capacidades operativas (CSIRT sectoriales, protección de servicios esenciales, gestión de crisis) al ritmo de otros países.

### Gaps
- EcuCERT no publica en forma accesible el número absoluto de incidentes gestionados por año (más allá de IP notificadas); no se encontraron series 2019-2023 comparables.
- No hay ranking de Check Point o Fortinet específico de Ecuador para 2025 por sector gobierno o salud.
- No se encontró la cifra de ataques semanales por organización en Ecuador (Check Point) para 2025.

## 3. Fraude contra ciudadanos: phishing, smishing, vishing, WhatsApp, SIM swap, suplantación, préstamos

### Takeaway
La apropiación fraudulenta por medios electrónicos (COIP art. 190) es el delito informático dominante: 3.696 denuncias en 2024 (94% de los delitos informáticos contra clientes financieros) y 4.733 entre enero y noviembre de 2025 (+28% aproximado). Entre enero 2022 y mayo 2025 hubo 20.602 denuncias por ciberdelitos. La suplantación de identidad superó las 4.700 denuncias en 2025, y la estafa general pasó las 15.000 denuncias hasta julio de 2026. WhatsApp y SMS son los canales principales. Faltan cifras públicas de la Superintendencia de Bancos y Asobanca.

### Cited Findings

**Fiscalía General del Estado (vía prensa)**
- 2023: 3.644 denuncias de delitos informáticos por clientes del sistema financiero (~303/mes) — [Primicias, 15-06-2025](https://www.primicias.ec/economia/tarjetas-credito-delitos-informaticos-estafas-cuentas-bancos-98471/)
- 2024: 3.913 denuncias (~326/mes, +7% frente a 2023) — [Primicias, 15-06-2025](https://www.primicias.ec/economia/tarjetas-credito-delitos-informaticos-estafas-cuentas-bancos-98471/)
- 2024 por tipo: apropiación fraudulenta por medios electrónicos (art. 190) 3.696 (94%); transferencia electrónica de activo patrimonial (art. 231) 171 (166 en 2023); revelación ilegal de base de datos (art. 229) 45 (29 en 2023); interceptación ilegal de datos (art. 230) 1 (Loja) — [Primicias](https://www.primicias.ec/economia/tarjetas-credito-delitos-informaticos-estafas-cuentas-bancos-98471/)
- 2025 (1 enero a 21 marzo): 831 denuncias; art. 231 ~50; revelación de base de datos 12 — [Primicias](https://www.primicias.ec/economia/tarjetas-credito-delitos-informaticos-estafas-cuentas-bancos-98471/)
- Provincias con más denuncias: Pichincha, Guayas y Manabí — [Primicias](https://www.primicias.ec/economia/tarjetas-credito-delitos-informaticos-estafas-cuentas-bancos-98471/)
- El titular de Primicias resume "más de 300 denuncias al día"; los datos del cuerpo del artículo dan ~326 al mes. El titular parece inexacto; usar la cifra mensual — [Primicias](https://www.primicias.ec/economia/tarjetas-credito-delitos-informaticos-estafas-cuentas-bancos-98471/)
- Enero a noviembre 2025: 4.733 denuncias de apropiación fraudulenta a nivel nacional, frente a 3.701 en 2024 (según resumen de búsqueda; fuente: El Universo editorial / prensa) — [El Universo, editorial "Robos digitales"](https://www.eluniverso.com/opinion/editoriales/robos-digitales-una-alerta-en-ecuador-nota/)
- Enero 2022 a mayo 2025: 20.602 denuncias por ciberdelitos; 11.833 por apropiación fraudulenta y 4.567 por estafa por medios electrónicos — [Expreso](https://www.expreso.ec/ciencia-y-tecnologia/ciberdelitos-ecuador-aumentan-conoce-fraudes-comunes-atacan-247638.html)
- Hasta octubre 2024: 3.385 casos de apropiación fraudulenta (corte parcial) — [Ecuador Chequea](https://ecuadorchequea.com/7-pasos-para-no-exponerse-a-ciberdelitos/)
- Suplantación de identidad: 4.784 denuncias entre enero y octubre de 2025 — [Expreso](https://www.expreso.ec/actualidad/economia/suplantacion-identidad-mal-aterra-multiplica-241350.html); más de 4.700 víctimas en 2025 — [Radio Pichincha](https://www.radiopichincha.com/suplantacion-identidad-ecuador-victimas/)
- Estafa: más de 15.000 denuncias hasta julio de 2026, segundo delito más denunciado tras el robo (fuente comercial que cita a Fiscalía; verificar) — [Acavir](https://www.acavir.com/articulos/las-estafas-digitales-se-consolidan-como-una-de-las-principales-amenazas-para-los)

**Modalidades y canales**
- El phishing (correos o SMS con enlaces que imitan bancos y cooperativas) es el método más común en delitos de interceptación — [Primicias](https://www.primicias.ec/economia/tarjetas-credito-delitos-informaticos-estafas-cuentas-bancos-98471/)
- WhatsApp (43%) y SMS (40%) son los canales favoritos de las estafas con IA en Ecuador (estudio citado, metodología no especificada) — [KCH FM, 15-09-2026](https://kchcomunicacion.com/2026/09/15/whatsapp-y-sms-las-puertas-de-entrada-de-las-estafas-con-ia-en-ecuador/)
- Los atacantes generan mensajes, audios o videos hiperrealistas de aparentes bancos o empresas para obtener claves y códigos SMS — [Radio Pichincha](https://www.radiopichincha.com/suplantacion-identidad-ecuador-victimas/)
- Toma de cuentas de WhatsApp: recomendación de revisar dispositivos vinculados, cerrar sesiones y activar verificación en dos pasos; estafas de ventas falsas por WhatsApp — [Extra](https://www.extra.ec/noticia/tecnologia/estafas-whatsapp-asi-buscan-robar-dinero-datos-bancarios-ecuador-165756_amp.html); [El Diario, alerta de Aduana, 16-07-2026](https://www.eldiario.ec/seguridad/aduana-de-ecuador-alerta-sobre-estafas-asi-operan-las-falsas-ventas-por-whatsapp-16072026/)
- Estafas con códigos QR vía WhatsApp — [La Prensa Riobamba](https://laprensa.com.ec/alerta-por-estafa-a-traves-de-whatsapp-y-codigos-qr-en-ecuador/)
- Créditos falsos: alertas por 134 entidades no autorizadas que ofrecen préstamos por redes sociales y WhatsApp y exigen "encajes previos" (2026) — [El Comercio](https://www.elcomercio.com/actualidad/negocios/falsos-creditos-alertas-fraude-financiero-134-entidades-ecuador-2026/)
- Portabilidad no autorizada de línea (vector de SIM swap): caso de un adulto mayor de 80 años citado por un legislador, con suplantación y contratación fraudulenta de planes (2026) — [El Diario, 19-09-2026](https://www.eldiario.ec/ecuador/adultos-mayores-proteccion-fraudes-digitales-19092026/)
- Phishing con marca IESS (septiembre 2026): correos que ofrecen falsas devoluciones de dinero a afiliados y piden "verificar identidad" y "actualizar datos" en un enlace — [Radio Pichincha](https://www.radiopichincha.com/nueva-estafa-iess-falsas-devoluciones-dinero/); [KCH FM, 09-09-2026](https://kchcomunicacion.com/2026/09/09/nueva-estafa-usa-el-nombre-del-iess-para-ofrecer-falsas-devoluciones-de-dinero-a-afiliados/)
- Los trámites del IESS son gratuitos; denuncias en denuncias.iess.gob.ec y WhatsApp institucional — [El Comercio](https://www.elcomercio.com/actualidad/ecuador/iess-detecto-aportes-faltas-para-jubilacion-en-ecuador/)
- Operación Kaerb: caso de ciberdelincuencia transnacional Ecuador-Colombia analizado como ejemplo del uso de IA por redes criminales — [UNIR Revista](https://www.unir.net/revista/ciencias-seguridad/operacion-kaerb-ciberdelincuencia-transnacional-lecciones-ecuador-y-colombia-ia/)

### Inferences
- Las denuncias de apropiación fraudulenta crecieron ~7% en 2024 y ~28% en los primeros 11 meses de 2025; el crecimiento se acelera.
- Para un afiliado del IESS, el escenario más probable es un mensaje por WhatsApp/SMS/correo con marca IESS o BIESS (devoluciones, créditos, actualización de datos) que lleva a robar credenciales del portal IESS o claves bancarias.
- Las denuncias formales subestiman el fenómeno: requieren acudir en persona y muchas víctimas no denuncian.

### Gaps
- No se encontraron cifras públicas de la Superintendencia de Bancos ni de Asobanca sobre fraude, reclamos o montos perdidos 2023-2026.
- No hay cifras ecuatorianas cuantificadas de toma de cuentas de WhatsApp, SIM swapping o vishing.
- No se encontraron datos de la Unidad Nacional de Ciberdelito de la Policía.
- Montos totales perdidos por fraude electrónico: no disponibles.

## 4. Amenazas dirigidas a adultos mayores y jubilados

### Takeaway
El caso más relevante para el IESS es la suplantación de jubilados para obtener créditos quirografarios del BIESS (desde 2024): con datos personales y credenciales del portal del IESS, los delincuentes cambiaban celular, correo y cuenta bancaria del afiliado y cobraban préstamos de USD 9.000 a 30.550 que luego se descontaban de la pensión. El IESS/BIESS identificó tres IP y dos funcionarios sospechosos. A esto se suman phishing con marca IESS, portabilidad fraudulenta de líneas y estafas presenciales ("cambiazo", falsos médicos).

### Cited Findings
- Diciembre 2024: jubilados denunciaron descuentos por créditos quirografarios que nunca pidieron; el IESS/BIESS identificó tres direcciones IP y dos funcionarios (Carlos E. y Jessica A.) que habrían incumplido protocolos de seguridad en el uso de sus roles; al menos 20 casos; casi 100 jubilados protestaron en Guayaquil el 10-12-2024 — [Expreso, 13-12-2024](https://www.expreso.ec/actualidad/economia/iess-biess-investigan-fraude-detectan-funcionarios-ips-implicados-estafas-jubilados-224394.html); [Primicias](https://www.primicias.ec/sociedad/iess-jubilados-afiliados-suplantacion-identidad-prestamos-85325/)
- Víctor Hugo Flores (72 años) dice que tomaron sus datos y claves del sistema del IESS para un crédito de USD 25.000; Nidia Castillo (78 años) fue a un cibercafé por consejo del IESS para pedir USD 5.000, le sacaron USD 14.000 y solo recibió 5.000; el personal del cibercafé tenía sus credenciales (testimonio no verificado) — [Expreso, 13-12-2024](https://www.expreso.ec/actualidad/economia/iess-biess-investigan-fraude-detectan-funcionarios-ips-implicados-estafas-jubilados-224394.html)
- El IESS presentó denuncia ante Fiscalía; sus equipos técnicos analizan "posibles vulneraciones a las seguridades" — [Expreso](https://www.expreso.ec/actualidad/economia/iess-biess-investigan-fraude-detectan-funcionarios-ips-implicados-estafas-jubilados-224394.html)
- Modo de operación según víctimas: acceso a datos personales, cambio de celular y correo en sistemas del IESS, cambio de cuenta bancaria para transferir fondos; sospecha de red interna con cómplices en el BIESS (no probado) — [Expreso, 08-12-2025](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html)
- Cifras BIESS: ~20 casos reconocidos inicialmente en 2024; 14 créditos fraudulentos detectados hasta junio de 2025; la Defensoría del Pueblo del Guayas tramitó más de 10 acciones de protección (5 con sentencia) — [Expreso, 08-12-2025](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html)
- Montos: USD 20.000 (80% de la pensión destinada al pago), 30.550, 9.000 (víctima que entregó su cédula a cambio de USD 80) y 25.000 — [Expreso, 08-12-2025](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html)
- El BIESS exige en teoría firma presencial y fotografía, pero los casos continuaron; el IESS dijo que los créditos son competencia exclusiva del BIESS — [Expreso, 08-12-2025](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html)
- Proyecto legislativo de protección de adultos mayores ante fraudes digitales (septiembre 2026), con el caso de portabilidad no autorizada de un hombre de 80 años — [El Diario, 19-09-2026](https://www.eldiario.ec/ecuador/adultos-mayores-proteccion-fraudes-digitales-19092026/)
- Octubre 2026: cuatro detenidos en Quito y Alausí por engañar a adultos mayores haciéndose pasar por médicos o funcionarios de salud — [Ecuadorinmediato](https://www.ecuadorinmediato.com/noticias/policia-detiene-a-cuatro-sospechosos-de-estafar-a-adultos-mayores-mediante-el)
- La Policía desarticuló una red del "cambiazo" (cambio de tarjeta en cajeros) cuyas víctimas principales eran adultos mayores — [PoliNoticias](https://noticias.policia.gob.ec/policia-nacional-desarticulo-red-delictiva-que-estafaba-a-adultos-mayores-mediante-la-modalidad-del-cambiazo/)

### Inferences
- Los intermediarios informales (cibercafés, "tramitadores") que gestionan trámites del IESS para jubilados con poca alfabetización digital reciben sus credenciales y son un vector clave de fraude.
- Los controles débiles son el cambio de celular, correo y cuenta bancaria del afiliado sin verificación fuerte ni notificación al canal anterior. Son los puntos donde el IESS/BIESS tiene control directo.
- La víctima carga con la deuda mientras dura la investigación; el daño reputacional para el IESS/BIESS es alto aunque la entidad no reconozca un "ciberataque".

### Gaps
- No hay cifras oficiales desagregadas por edad de víctimas de fraude digital en Ecuador.
- No se encontraron datos ecuatorianos específicos de vishing o estafas por WhatsApp dirigidas a jubilados (varios resultados eran de Argentina, PAMI/ANSES, y se descartaron).
- Resultado judicial de la investigación de los funcionarios del BIESS: desconocido.

## 5. Amenazas internas y corrupción con datos en instituciones públicas

### Takeaway
El riesgo interno está documentado en el propio IESS: en noviembre de 2025 el IESS denunció a una funcionaria por registrar irregularmente cinco años de aportes falsos para una jubilación (peculado, cohecho, falsificación informática, revelación de bases de datos), y en 2024 dos funcionarios del IESS/BIESS fueron señalados en el fraude de créditos. A nivel país, las filtraciones de 2019 y 2026 se atribuyen a ex funcionarios o intermediarios con acceso legítimo. En otros servicios públicos (Registro Civil, CNEL) hay redes de tramitadores y funcionarios que manipulan sistemas.

### Cited Findings
- Noviembre 2025: el IESS denunció ante Fiscalía a una funcionaria por registrar de forma irregular cinco años de aportes a una afiliada, y detectó a un externo que ofrecía alterar registros; delitos señalados: peculado, cohecho, falsificación informática y revelación de bases de datos — [Primicias](https://www.primicias.ec/economia/iess-denuncia-falsificacion-aportes-jubilacion-fiscalia-110018/); [Expreso](https://www.expreso.ec/actualidad/economia/iess-denuncia-falsificacion-de-aportes-esto-es-lo-que-se-sabe-265330.html); [Notimundo](https://fmmundo.com/notimundo/actualidad/iess-denuncia-red-falsificacion-aportes-obtener-jubilaciones-forma-ilegal-n81993)
- 2024: dos empleados del IESS/BIESS (Carlos E. y Jessica A.) sospechosos de incumplir protocolos en el uso de sus roles en el fraude de créditos a jubilados — [Expreso, 13-12-2024](https://www.expreso.ec/actualidad/economia/iess-biess-investigan-fraude-detectan-funcionarios-ips-implicados-estafas-jubilados-224394.html)
- 2019: Novaestrat fue creada por ex funcionarios de Senplades, Secom y BNF; la base incluía datos del Registro Civil y del BIESS — [INCIBE-CERT](https://www.incibe.es/en/incibe-cert/publications/cybersecurity-highlights/data-leak-millions-ecuadorians); [El Universo](https://www.eluniverso.com/noticias/2019/09/17/nota/7522132/exfuncionarios-detras-filtracion-datos)
- 2026: el Registro Civil atribuyó la presunta filtración de 14,8 millones de registros a robo de información por dos ex funcionarios — [Vistazo](https://www.vistazo.com/actualidad/nacional/2026-05-05-hackeo-informacion-registro-civil-ecuador-ley-proteccion-datos-criterios-GK10925892)
- Venta de datos personales de ecuatorianos en la red por hasta USD 30.000 — [El Comercio](https://www.elcomercio.com/actualidad/seguridad/datos-personales-ofertan-red-ecuatorianos/)
- Bases de datos personales vendidas incluso en portales de ventas en línea — [La Hora](https://www.lahora.com.ec/noticias/bases-de-datos-personales-se-venden-hasta-en-portales-de-ventas-en-linea/)
- Revelación ilegal de base de datos: 29 denuncias (2023), 45 (2024), 12 (hasta 21-03-2025) — [Primicias](https://www.primicias.ec/economia/tarjetas-credito-delitos-informaticos-estafas-cuentas-bancos-98471/)
- Registro Civil: 36 detenidos por falsificar turnos en 2025 (corte agosto 2025); 11 detenidos y 32 operativos en un corte anterior de 2025 — [Teleamazonas](https://www.teleamazonas.com/actualidad/noticias/seguridad/36-detenidos-falsificar-turnos-registro-civil-ecuador-2025-100465/); [Expreso](https://www.expreso.ec/actualidad/venta-ilegal-turnos-registro-civil-32-operativos-11-detenidos-232294.html)
- CNEL: funcionarios manipularon datos de facturación de más de 400.000 cuentas durante más de una década; pérdidas de más de USD 300 millones y 46 funcionarios implicados (fuente en inglés, secundaria) — [Ecuador Brief](https://www.ecuadorbrief.com/articles/cnel-corruption-300-million-46-officials-400000-accounts-decade)
- Derechos Digitales publicó en mayo 2026 un análisis sobre la filtración de millones de datos y la capacidad de protección — [Derechos Digitales (PDF)](https://www.derechosdigitales.org/wp-content/uploads/2026/05/Filtracion-de-millones-de-datos_-¿se-puede-proteger-ante-la-vulneracion_.pdf)

### Inferences
- En el IESS el riesgo interno no es hipotético: los dos casos documentados (créditos 2024, aportes falsos 2025) muestran que funcionarios con roles de modificación de datos (historia laboral, datos de contacto, cuentas bancarias) pueden ser cooptados por redes externas.
- Controles recomendables: segregación de funciones, registros de auditoría inmutables sobre cambios de datos sensibles, alertas por cambios atípicos y revocación oportuna de accesos de ex funcionarios.

### Gaps
- No se encontraron casos ecuatorianos documentados de venta de bases de datos en Telegram con detenciones (los resultados de Telegram eran de México).
- No hay cifras sobre sanciones de la Superintendencia de Protección de Datos Personales por incidentes en entidades públicas.

## 6. Crimen organizado, "conflicto armado interno" (2024) y extorsión digital

### Takeaway
La extorsión pasó de 1.616 denuncias en 2019 a 23.080 en 2024 (pico) y 16.130 en 2025, según la Fiscalía. La Fiscalía y la Policía reportan una baja en 2025, pero las alertas al ECU 911 marcaron un récord (3.092 entre enero y mayo de 2025, +81% frente a 2023). Gran parte de la extorsión se gestiona desde las cárceles y por teléfono o redes, y existen "call centers" de extorsión. Las fuentes revisadas no vinculan explícitamente el decreto de conflicto armado interno (enero 2024) con la extorsión digital.

### Cited Findings
- Fiscalía: 1.616 denuncias de extorsión en 2019 y 16.130 en 2025 (89 por 100.000 habitantes), +898%; estudio del Observatorio Ecuatoriano del Crimen Organizado (Crime-Lab II, Fundación Panamericana para el Desarrollo); vincula la extorsión con el "chulco" (préstamos usureros) como fase de cobro — [Primicias, 18-09-2026](https://www.primicias.ec/seguridad/extorsiones-dispararon-ecuador-ultimos-seis-anos-llegaron-16-130-casos-2025-estudio-132905/)
- 2024: 23.080 casos de extorsión (más de 1.300% sobre 2019); 2025: 16.131, una caída del 30% y el menor total desde 2022 (Fiscalía) — [InSight Crime](https://insightcrime.org/news/ecuadors-authorities-say-extortion-down-reality-more-complicated/)
- La Policía reporta una caída del 64% entre los primeros nueve meses de 2024 y de 2025 — [InSight Crime](https://insightcrime.org/news/ecuadors-authorities-say-extortion-down-reality-more-complicated/)
- ECU 911: récord de 3.092 alertas por extorsión entre enero y mayo de 2025, frente a 1.699 en el mismo periodo de 2023 (+81%); Guayaquil es el epicentro — [Primicias](https://www.primicias.ec/seguridad/extorsiones-ecuador-guayaquil-llamadas-emergencia-ecu911-record-alertas-98878/); [El Diario](https://www.eldiario.ec/seguridad/extorsiones-en-ecuador-aumentan-un-81-en-2025-con-guayaquil-como-epicentro-19062025/)
- Entre 70% y 84% de las víctimas de extorsión no denuncia por miedo (estimación citada en guía; fuente secundaria) — [Radar de Seguridad](https://www.radardeseguridad.com/ec/guias/extorsion-y-vacunas-en-ecuador-como-protegerte)
- Crisis Group: el control criminal de las prisiones impulsa la extorsión; según un funcionario, la gran mayoría de exigencias de extorsión en la provincia costera proviene de sus cárceles — [International Crisis Group, informe n.º 109, noviembre 2025 (PDF)](https://www.crisisgroup.org/sites/default/files/2025-11/109-ecuador-organised-crime-spanish_0.pdf)
- Un "call center" de extorsión en Quito facturaba hasta USD 67.000 al mes, con llamadas, montajes y víctimas en Ecuador, Colombia y México, ligado a créditos — [Primicias](https://www.primicias.ec/sucesos/call-center-extorsion-quito-llamadas-montajes-victimas-ecuador-colombia-mexico-creditos-102364/)

### Inferences
- Las bases de datos filtradas (direcciones, teléfonos, familiares, fotos de cédula) alimentan la extorsión personalizada y el "secuestro virtual". La filtración del Registro Civil de 2026 eleva este riesgo para afiliados y jubilados.
- La extorsión ligada a préstamos informales ("gota a gota", créditos por apps o WhatsApp) cruza con el fraude financiero: el jubilado que busca liquidez es víctima potencial de ambos.

### Gaps
- No hay cifras oficiales ecuatorianas de llamadas extorsivas desde cárceles ni de "secuestro virtual" (el dato de 14.097 llamadas desde cárceles corresponde a Colombia/Inpec y se descartó).
- No se encontró un análisis que vincule cuantitativamente el decreto de conflicto armado interno (Decreto Ejecutivo 111, enero 2024) con la evolución de la extorsión digital; las cifras muestran el pico en 2024 y descenso en denuncias en 2025.
- No hay datos sobre extorsión por sextorsión o redes sociales separada de la extorsión física.
