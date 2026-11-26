# Centro de la campana: soluciones estándar de cultura de seguridad y prevención de riesgo digital en instituciones públicas

Nota de método: búsquedas web del 25-11-2026. Se evitó repetir la evidencia académica ya recogida en `D:\investigacion\reports\Cultura de ciberseguridad IESS.md` (Ho et al. 2025, Lain et al. 2022, CREST, AARP, PMT, fatiga de seguridad); aquí solo se citan esos estudios cuando sirven para marcar el límite de una solución concreta. Muchas cifras de precio vienen de marketplaces o agregadores y no de listas oficiales: se indica en cada caso. Escala: CENTRO / CONVERGENTE / PERIFERIA / ATÍPICO.

## 1. Plataformas comerciales de concienciación (KnowBe4, Proofpoint, Hoxhunt, SoSafe, Microsoft, Cofense, Terranova, Kaspersky ASAP)

### Takeaway
Todas venden el mismo paquete base: biblioteca de cursos en video/microlearning, simulaciones de phishing con plantillas, botón de reporte en el correo, capacitación "embebida" al fallar y un tablero de tasas de clic/reporte; se diferencian en la adaptación del nivel de dificultad (Hoxhunt), en la integración con el correo (Microsoft, Proofpoint) y en el precio. El rango de lista es de aprox. USD 1,6 a 5 por usuario y mes (USD 20-60 por usuario y año); para ~33.500 servidores del IESS eso equivale, a precio de lista, a varios cientos de miles de dólares al año, lo que las convierte en el "centro" que el jurado ya conoce y que un hackatón no puede ni debe replicar.

### Cited Findings

**Paquete estándar común (qué incluye casi siempre)**
- Gartner trata estos productos como una categoría propia ("Security Awareness Computer-Based Training") y en su Market Guide de 27-07-2020 (Reed, Addiscott, Mandy) nombró a KnowBe4 y Proofpoint como "Representative Vendors" — [KnowBe4 blog](https://blog.knowbe4.com/gartner-recognizes-knowbe4-as-a-representative-vendor-for-security-awareness-training-program-platforms); [Proofpoint](https://www.proofpoint.com/us/blog/security-awareness-training/security-awareness-training-spotlight-gartner-market-guide-security)
- En Gartner Peer Insights de la categoría aparecen como productos Hoxhunt, Cofense (Phishing Defense Platform), Terranova (hoy bajo Fortra: "Terranova Security Awareness Platform") y Kaspersky — [Gartner Peer Insights](https://www.gartner.com/reviews/market/security-awareness-computer-based-training/vendors); [Gartner Kaspersky](https://www.gartner.com/reviews/market/security-awareness-computer-based-training/vendor/kaspersky). Peer Insights es un listado de reseñas, no el Market Guide.

**Ficha: KnowBe4 (KMSAT / HRM+)**
- Quién/dónde: proveedor estadounidense, líder de volumen del mercado; tiene equipo comercial LatAm (vacante "Senior Manager of Sales – LATAM", remoto en Florida) — [Greenhouse KnowBe4](https://job-boards.greenhouse.io/knowbe4/jobs/8464612002)
- Cómo funciona: biblioteca de contenidos, simulación de phishing, "Real-time Coaching" añadido en la página de precios; para sector público vende "HRM+" para "gestión de políticas, captura automatizada de evidencias" (cumplimiento) — [KnowBe4 pricing](https://www.knowbe4.com/pricing); [KnowBe4 Public Sector](https://www.knowbe4.com/industries/public-sector)
- Costo: precio de lista mensual por usuario en contrato de 3 años desde USD 2,40 (Foundation) a USD 3,75 (Advanced) para la banda de 25-50 usuarios, precios en USD de enero 2025 para Norteamérica — [KnowBe4 pricing](https://knowbe4.com/pricing-security-awareness-training). G2 (actualizado 03-01-2025) reporta 5 ediciones entre USD 1,70 y 2,65 por usuario/mes; Diamond 501-1000 ≈ USD 2,35 — [G2](https://g2.com/products/knowbe4-security-awareness-training/pricing). AWS Marketplace: Diamond 36 meses = USD 117 por usuario (25-50 usuarios) y USD 61,20 por usuario (3001-5000), totales a 3 años — [AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-6zkl5atdaqizq). Vendr menciona descuentos por volumen en umbrales de 250/500/1.000/2.500 usuarios — [Vendr](https://www.vendr.com/marketplace/knowbe4)
- Evidencia de efecto (del propio proveedor): KnowBe4 afirma que la vulnerabilidad al phishing se reduce un 79 % tras un año de formación (estudio de benchmarking propio, sin grupo de control independiente) — [La Opinión/Latinowire, nota de prensa KnowBe4](https://laopinion.com/latinowire/un-estudio-de-knowbe4-revela-que-la-vulnerabilidad-al-phishing-a-nivel-mundial-se-reduce-un-79-tras-un-ano-de-formacion-en-concienciacion-sobre-seguridad/)
- Ecuador: caso de éxito publicado con Location World (Quito, telemática/IoT, sector privado) — [KnowBe4 case study](https://knowbe4.com/case-study/technology/location-world). No se halló ningún cliente gubernamental en Ecuador, Colombia o México en fuentes públicas.
- Posición: CENTRO.

**Ficha: Proofpoint Security Awareness (hoy "ZenGuide")**
- Quién: Proofpoint (EE. UU.), integrado con su pasarela de correo; G2 ya lista el producto como "Proofpoint ZenGuide" — [G2 ZenGuide](https://www.g2.com/products/proofpoint-zenguide/pricing)
- Costo: Proofpoint no publica precios (G2); estimación de compradores USD 12-24 por usuario/año (fuente secundaria, baja fiabilidad) — [G2](https://www.g2.com/products/proofpoint-zenguide/pricing); [CiphersSecurity](https://cipherssecurity.com/?p=16542)
- Posición: CENTRO.

**Ficha: Hoxhunt**
- Quién: Finlandia. Diferenciador: simulaciones adaptativas por usuario, gamificación y foco en la tasa de reporte. Precio solo bajo cotización — [Hoxhunt blog](https://hoxhunt.com/blog/best-security-awareness-training). Estimación externa USD 25-70 por usuario/año, con tabla internamente inconsistente — [Tech-insider](https://tech-insider.org/?p=18120)
- Posición: CENTRO en mercados europeos/corporativos; CONVERGENTE en cuanto al enfoque (reporte + adaptación) frente al paquete clásico.

**Ficha: SoSafe**
- Quién: Alemania (fuerte en Europa). G2: plan de 3 años, 501-1.000 usuarios, USD 2,79 por usuario/mes (≈ USD 33,5/año) — [G2 comparativa](https://www.g2.com/compare/hoxhunt-vs-sosafe-vs-knowbe4-security-awareness-training). Estimación secundaria €2-5 por usuario/mes — [CiphersSecurity](https://cipherssecurity.com/?p=16542)
- Posición: CENTRO (Europa).

**Ficha: Microsoft Defender for Office 365 – Attack Simulation Training**
- Cómo funciona: simulaciones de phishing y capacitación dentro del tenant de Microsoft 365. Requiere licencia Microsoft 365 E5 o Defender for Office 365 Plan 2, y la licencia debe estar asignada a cada usuario incluido en la simulación; Business Premium no basta — [Microsoft Learn Q&A](https://learn.microsoft.com/en-us/answers/questions/5291210/do-all-users-need-plan-2-to-run-attack-simulation); [Microsoft Learn](https://learn.microsoft.com/en-us/office365/securitycompliance/attack-simulator)
- Costo: Plan 2 ≈ USD 5 por usuario/mes (precio de terceros, no lista oficial) — [G2](https://g2.com/products/microsoft-defender-for-office-365-mdo/pricing); [Medha Cloud](https://medhacloud.com/tools/m365-license-navigator/plans/defender-office-p2-addon)
- Encaje IESS: solo viable si el IESS ya tiene E5/Plan 2 (no verificado). Es la opción "por defecto" de cualquier organización con Microsoft 365.
- Posición: CENTRO.

**Ficha: Cofense**
- Quién: EE. UU.; históricamente "PhishMe", conocido por el botón de reporte (Reporter) y el triage de reportes; listado en Peer Insights como "Phishing Defense Platform" — [Gartner Peer Insights](https://www.gartner.com/reviews/market/security-awareness-computer-based-training/vendors). No se obtuvieron precios.
- Posición: CENTRO (el botón de reporte es hoy estándar en todos los proveedores).

**Ficha: Terranova Security (Fortra)**
- Quién: Canadá, adquirido por Fortra; fuerte en contenidos multilingües (incl. español) — [Gartner Peer Insights](https://www.gartner.com/reviews/market/security-awareness-computer-based-training/vendors). Precios no obtenidos.
- Posición: CENTRO.

**Ficha: Kaspersky ASAP (Automated Security Awareness Platform)**
- Cómo funciona: plataforma automatizada de microcursos; la venta es por socios o filiales locales; en el sudeste asiático la oferta exige mínimo 500 y máximo 2.000 licencias por organización (no confirmado para LatAm) — [Kaspersky SEA](https://www.kaspersky.com/go/sea-kasap); [Kaspersky soporte licencias](https://support.kaspersky.co.uk/ASAP/1.0/en-US/210374.htm)
- Datos: la prueba gratuita deja elegir región de almacenamiento y sugiere Europa si la región no aparece, "aceptable" para LatAm según Kaspersky — [Kaspersky ASAP regiones](https://asap.kaspersky.com/regions)
- Sector público LatAm: Kaspersky publica un caso del Gobierno del Estado de Guanajuato (México), sin precios — [Kaspersky National Cybersecurity](https://www.kaspersky.com/enterprise-security/national-cybersecurity?ignoreredirects=true); su crecimiento en LatAm se atribuye a la demanda de ciberseguridad — [BNamericas](https://www.bnamericas.com/en/news/digital-threat-scenario-cyber-demands-bolster-kaspersky-in-latam)
- Posición: CENTRO (especialmente en organismos de presupuesto bajo en LatAm).

**Limitaciones conocidas del paquete comercial (evidencia)**
- La capacitación anual no se correlaciona con la tasa de clic y la capacitación embebida al fallar baja la tasa ~2 puntos; la tasa de fallo varía 1,82 %-30,80 % según el señuelo, lo que invalida los "tableros de % de clic" sin ajustar dificultad — [Ho et al., IEEE S&P 2025](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- La capacitación embebida tal como la aplica la industria no aumenta la resiliencia y puede tener efectos adversos; lo que sí funcionó fue el aviso en el correo y el reporte colectivo — [Lain et al., IEEE S&P 2022](https://arxiv.org/abs/2112.07498)
- Las cifras de mejora de los proveedores (p. ej. "-79 %") provienen de benchmarks propios sin grupo de control — [nota KnowBe4](https://laopinion.com/latinowire/un-estudio-de-knowbe4-revela-que-la-vulnerabilidad-al-phishing-a-nivel-mundial-se-reduce-un-79-tras-un-ano-de-formacion-en-concienciacion-sobre-seguridad/)
- Todas están diseñadas para empleados con correo corporativo; no cubren al ciudadano (afiliado/jubilado) ni el préstamo de la clave a terceros, que es el vector central en el IESS (ver estudio previo).

### Inferences
- Costo estimado para el IESS a precio de lista (33.500 usuarios × USD 1,6-5/mes) ≈ USD 640.000-2.000.000 al año; incluso con descuentos de volumen de 50 % sigue siendo una contratación grande vía SERCOP. Cálculo propio, no cotizado.
- Para el jurado, "un tablero de simulaciones de phishing con cursos" es lo ya visto: cualquier propuesta del Reto 1 que se parezca a KnowBe4 será comparada con un producto maduro y perderá.
- La tendencia de producto (reporte, coaching en tiempo real, "Human Risk Management") es la parte CONVERGENTE del mercado; el módulo "curso anual + test" es CENTRO puro.

### Gaps
- No se obtuvo el Market Guide vigente de Gartner (desde 2022-2023 Gartner habla de "Security Behavior and Culture Programs"; no verificado en esta sesión) ni el Forrester Wave.
- No hay precios publicados de Cofense, Terranova, Proofpoint ni Kaspersky ASAP para LatAm.
- No se encontraron clientes públicos ecuatorianos confirmados de ninguno de estos proveedores.
- La búsqueda en SERCOP (compraspublicas.gob.ec) por "concienciación", "phishing" o "capacitación seguridad de la información" no devolvió procesos indexados; el buscador SOCE requiere consulta directa. Solo apareció la Política de Seguridad de la Información del propio SERCOP (2025) y su comité (2026) — [SERCOP normativa 2025-0004](https://portal.compraspublicas.gob.ec/sercop/normativa/2025/sercop-2025-0004); [SERCOP 2026-0536-R](https://portal.compraspublicas.gob.ec/sercop/wp-content/uploads/2026/10/SERCOP-SERCOP-2026-0536-R.pdf)

## 2. Líneas base gratuitas y de código abierto (GoPhish, CISA/NCSC/INCIBE, OEA/CICTE, MINTEL, Moodle/IESSEDUCA)

### Takeaway
La alternativa "gratis" estándar en el sector público latinoamericano es la combinación GoPhish (simulación) + kit de materiales (INCIBE u otro CSIRT) + curso en el Moodle institucional + talleres del ministerio rector. Cubre el cumplimiento del EGSI a costo de licencia cero, pero traslada el costo al personal interno y hereda las mismas limitaciones de efecto que las plataformas comerciales.

### Cited Findings

**Ficha: GoPhish**
- Quién/cómo: marco de simulación de phishing de código abierto (licencia MIT), autoalojado: plantillas de correo, páginas de captura, grupos y métricas de apertura/clic/envío de datos — [GitHub gophish/gophish](https://github.com/gophish/gophish) (repositorio conocido; actividad de versiones no verificada en esta sesión).
- Público: servidores con correo institucional. Costo: USD 0 de licencia; costo real = servidor, dominio, tiempo de un analista.
- Evidencia de efecto: la misma que la simulación comercial (ver sección 1: efecto pequeño, depende del señuelo).
- Encaje IESS: es la herramienta típica en tesis y proyectos universitarios ecuatorianos y en unidades de TI con poco presupuesto (inferencia; ver Gaps).
- Posición: CENTRO.

**Ficha: Kit de concienciación de INCIBE (España)**
- Gratuito para empresas; la versión de 2020 incluía ataques dirigidos simulados para evaluar al personal en el correo, pósteres, trípticos, consejos, 9 recursos formativos con test, y un manual de implantación pensado para un año; soporte por formulario y teléfono 017 — [INCIBE blog kit](https://www.incibe.es/empresas/blog/actualizate-ciberseguridad-el-nuevo-kit-concienciacion); [INCIBE formulario](https://www.incibe.es/empresas/te-ayudamos/formulario-contacto-empresas)
- Posición: CENTRO (modelo copiado por muchos CSIRT nacionales).

**Ficha: Materiales gratuitos CISA (EE. UU.) / NCSC (Reino Unido)**
- CISA difunde la campaña "Secure Our World" (contraseñas fuertes, MFA, reconocer phishing, actualizar) — [CISA Secure Our World](https://www.cisa.gov/secure-our-world); NCSC ofrece formación e-learning gratuita "Top Tips for Staff" — [NCSC](https://www.ncsc.gov.uk/training/top-tips-for-staff-scorm-v2). (URLs de referencia conocidas; contenido no reverificado en esta sesión).
- Posición: CENTRO.

**Ficha: OEA/CICTE**
- El Programa de Ciberseguridad de la OEA/CICTE coorganiza cursos virtuales gratuitos para público general, p. ej. "Nuestras redes, nuestra seguridad" con Agesic (Uruguay), sin requisitos técnicos — [gub.uy, Agesic](https://www.gub.uy/agencia-gobierno-electronico-sociedad-informacion-conocimiento/comunicacion/noticias/cuarta-edicion-del-curso-nuestras-redes-nuestra-seguridad)
- Uruguay (Agesic) también corre el concurso "SheSecures" para acercar mujeres a la ciberseguridad — [gub.uy SheSecures](https://www.gub.uy/agencia-gobierno-electronico-sociedad-informacion-conocimiento/comunicacion/noticias/finalizo-shesecures-iniciativa-promueve-participacion-mujeres-ciberseguridad)
- Posición: CENTRO.

**Ficha: MINTEL Ecuador**
- MINTEL impulsa talleres para fortalecer las capacidades técnicas de funcionarios públicos frente a amenazas digitales — [DPL News](https://dplnews.com/?p=284492); organizó en Quito el Cyberdrill regional de la UIT (junio 2026) con capacitaciones a instituciones públicas y privadas — [DPL News](https://dplnews.com/?p=317995); [KCH Comunicación](https://kchcomunicacion.com/?p=424811)
- Ecuador cuenta con un diagnóstico de capacidades de ciberseguridad (dic. 2022) — [CyberIL Portal](https://cybilportal.org/wp-content/uploads/2023/05/DIAGNOSTICO-DE-LAS-CAPACIDADES-DE-CIBERSEGURIDAD-Ecuador-Diciembre-2022_compressed.pdf)
- Comparables regionales: MinTIC Colombia + Cisco ofrecen cursos gratis de ciberseguridad por convocatoria — [MinTIC](https://mintic.gov.co/portal/inicio/Sala-de-prensa/Noticias/438848:Cursos-gratis-de-ciberseguridad-y-productividad-digital-MinTIC-y-Cisco-abren-nueva-convocatoria)
- Posición: CENTRO.

**Ficha: LMS Moodle institucional (IESSEDUCA)**
- Patrón: curso virtual obligatorio con cuestionario final y certificado, que sirve como evidencia del plan de concienciación del EGSI. Según el estudio previo, la capacitación del IESS llega a aproximadamente uno de cada cuatro servidores — [estudio previo, sección "33.500 servidores"](D:\investigacion\reports\Cultura de ciberseguridad IESS.md)
- Evidencia: ninguna relación medible entre haber hecho el curso anual y caer en phishing — [Ho et al. 2025](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf)
- Posición: CENTRO.

### Inferences
- La "solución gratis" no es gratis: el costo de un programa con GoPhish + Moodle está en horas de la DNSIPD/OSI para crear plantillas, analizar resultados y actualizar contenidos; para un hackatón esto sugiere que un aporte útil sería reducir ese costo de operación, no añadir otra herramienta del mismo tipo.
- Los materiales de INCIBE/CISA están escritos para empresas o para ciudadanos de otros contextos; no cubren el patrón "clave prestada a un tramitador" ni el vocabulario del IESS/BIESS.

### Gaps
- No se encontró información pública sobre el contenido actual de IESSEDUCA en seguridad ni sobre si el IESS usa GoPhish o una plataforma comercial.
- No se confirmó ningún curso MINTEL-OEA específico para servidores públicos ecuatorianos en 2025-2026.
- No se verificó la versión vigente del kit INCIBE (si mantiene la herramienta de simulación).

## 3. Campañas ciudadanas estándar de gobiernos e institutos de seguridad social (Ecuador y LatAm)

### Takeaway
La campaña ciudadana "por defecto" es idéntica en todas partes: comunicado de prensa y redes con la fórmula "la institución nunca te pedirá tu clave/datos bancarios por teléfono, correo o WhatsApp", lista de canales y dominios oficiales, y un canal de denuncia. Se reactiva cada vez que aparece una nueva modalidad (bonos, reembolsos, aumentos de pensión), lo que la convierte en reactiva, dependiente de la prensa y sin medición de efecto.

### Cited Findings

**Ficha: IESS (Ecuador)**
- Mensaje: el IESS no pide la clave personal ni actualizaciones de datos por correo o teléfono; no entregar la clave a terceros — [El Telégrafo](https://www.eltelegrafo.com.ec/noticias/masqmenos-2/220/servicios-34) (fecha no visible). "Tengan mucho cuidado a quién le confían la clave" y revisen con frecuencia fondos de reserva y cesantía — [Expreso](https://www.expreso.ec/actualidad/economia/prevenir-suplantacion-identidad-iess-entidades-241961.html)
- Alertas puntuales: correos falsos de "reembolso único" por supuesto sobrepago de seguro — [KCH/Radio Pichincha](https://kchcomunicacion.com/?p=534501); el presidente del IESS denunció el uso de su nombre para pedir dinero — [Expreso](https://www.expreso.ec/actualidad/politica/bernardo-cordovez-denuncia-uso-de-su-nombre-para-pedir-dinero-y-gestiones-en-iess-271022.html); [Primicias](https://www.primicias.ec/sociedad/iess-denuncia-alertas-suplantacion-identidad-dinero-cargos-publicos-113774/); canales para denunciar ofrecimientos de "subida de años de aportes" — [KCH](https://kchcomunicacion.com/?p=268958)
- Campaña de actualización de datos desde agosto 2025 vía iess.gob.ec con cédula y clave, acompañada de aclaraciones de rumores — [Extra](https://www.extra.ec/noticia/servicios-y-tramites/consecuencias-de-no-actualizar-tus-datos-en-el-iess-que-debes-saber-135052.html); [El Comercio](https://www.elcomercio.com/actualidad/negocios/iess-aclara-rumores-sobre-actualizacion-datos/); [El Comercio, alerta](https://www.elcomercio.com/actualidad/negocios/iess-alerta-sobre-actualizacion-datos-para-afiliados-jubilados/)
- Trámites de clave en gob.ec (generar/recuperar, desbloqueo) — [gob.ec](https://www.gob.ec/iess/tramites/generar-recuperar-clave-afiliado-acceso-al-portal-iess); [gob.ec desbloqueo](https://www.gob.ec/iess/tramites/desbloqueo-clave-afiliado-acceso-al-portal-iess-1)
- Límite observado: a pesar de los avisos, siguieron los casos de préstamos fraudulentos de hasta USD 30.000 — [Primicias](https://primicias.ec/sociedad/jubilados-denuncian-suplantacion-identidad-prestamos-quirografarios-guayaquil-85104); [El Universo, editorial](https://www.eluniverso.com/opinion/editoriales/una-suplantacion-perjudica-a-jubilados-nota/)
- Posición: CENTRO.

**Ficha: SRI (Ecuador)**
- Alertas repetidas nov-2025, feb-2026 y 2026: suplantación por correo, SMS, llamadas, webs, perfiles en redes y apps falsas; notificaciones oficiales solo desde dominios autorizados (infosri.gob.ec, clavesri.gob.ec); nunca pide contraseñas ni claves bancarias — [Lexis](https://www.lexis.com.ec/noticias/sri-emite-alerta-por-suplantacion-de-identidad-en-fraudes-tributarios); [El Diario](https://www.eldiario.ec/ecuador/sri-alerta-sobre-correos-llamadas-y-sitios-falsos-que-buscan-datos-de-contribuyentes-11022026/); [Primicias](https://www.primicias.ec/economia/sri-alerta-fraude-estafas-correos-mensajes-impuestos-109914/); [Teleamazonas, 7 modalidades](https://www.teleamazonas.com/actualidad/noticias/economia/sri-advierte-sobre-siete-modalidades-estafa-enganar-contribuyentes-110550/); [Vistazo 21-11-2025](https://www.vistazo.com/actualidad/nacional/2025-11-21-alerta-sri-detectan-nuevas-modalidades-estafa-contribuyentes-FA10455473)
- La lista de dominios publicada como "verificación de canal" es el patrón más concreto de verificación en Ecuador.
- Posición: CENTRO.

**Ficha: ANSES (Argentina)**
- Mensaje constante 2022-2026: ningún empleado está autorizado a pedir datos, claves ni información bancaria; canales oficiales anses.gob.ar, Mi ANSES (CUIL + Clave de la Seguridad Social) y línea 130; denuncia en Mi ANSES o denunciar@anses.gob.ar — [Ámbito, 08-07-2026](https://www.ambito.com/informacion-general/advertencia-anses-estafas-que-hacer-estos-casos-y-como-prevenirlas-n6296806); [Noticias NQN, 17-09-2026](https://www.noticiasnqn.com.ar/noticias/2026/09/17/352885-llaman-a-jubilados-en-nombre-de-anses-y-prometen-beneficios-como-detectar-la-estafa); [Diario de Cuyo, 10-03-2026](https://www.diariodecuyo.com.ar/economia/anses-alerto-estafas-advierten-jubilados-y-beneficiarios-n6567866); [Bloomberg Línea, 2022](https://www.bloomberglinea.com/2022/12/31/alerta-jubilados-y-pensionados-los-consejos-de-anses-para-prevenir-estafas/)
- Posición: CENTRO.

**Ficha: IMSS (México) y Bienestar**
- 2025-2026: alertas por documentos falsos por WhatsApp y depósitos en tiendas para "aumentos de pensión"; "la atención es gratuita y sólo por canales oficiales"; aclaración de que el registro biométrico no condiciona pagos; alerta por cuentas falsas en redes — [El Imparcial, 15-03-2026](https://www.elimparcial.com/mexico/2026/03/15/imss-alerta-sobre-fraude-contra-pensionados-asi-operan-los-falsos-tramites-para-aumentar-la-pension/); [ADN40, 30-08-2026](https://www.adn40.mx/mexico/2026-08-30/si-cobras-pension-del-imss-no-confies-en-este-mensaje-el-instituto-nunca-te-va-a-pedir-esto-por-telefono/); [El Imparcial, 14-05-2026](https://www.elimparcial.com/dinero/2026/05/14/imss-aclara-que-es-falso-que-registro-de-datos-biometricos-condiciona-pagos-a-pensionados-y-alerta-sobre-fraudes-que-intentan-robar-informacion-personal/); Banco/Secretaría del Bienestar: alertas por SMS y "no ofrece créditos" — [UnoTV](https://www.unotv.com/pensiones/bienestar-alerta-fraude-pensionados-no-ofrece-creditos-prestamos/)
- Posición: CENTRO.

**Ficha: Colpensiones (Colombia)**
- Sep-2025: alerta por estafa de bonos con enlace a página que imita sus portales; nunca pide claves o datos bancarios por SMS (sorteo BEPS); oct-2026 nueva alerta por fraudes digitales — [Noticias RCN](https://www.noticiasrcn.com/economia/colpensiones-llamado-por-estafas-por-bonos-939495); [Occidente, 10-10-2026](https://occidente.co/colombia/fraudes-digitales-en-nombre-de-colpensiones-estafas/)
- Posición: CENTRO.

**Ficha: ChileAtiende / IPS Chile y ChileCompra**
- ChileAtiende (red del IPS) publica la campaña "Más Vale Prevenir" — [ChileAtiende](https://www.chileatiende.gob.cl/fichas/81544-campana-mas-vale-prevenir) (contenido no revisado en detalle). ChileCompra tiene una página de ciberseguridad para proveedores ("protégete del phishing y cuida tus claves") — [ChileCompra](https://www.chilecompra.cl/ciberseguridad-en-las-compras-publicas/)
- Posición: CENTRO.

**Limitaciones conocidas de la campaña estándar**
- La lectura estática de consejos no mejora la detección; sí lo hace ver ejemplos simulados (inoculación) — [Boston College CRR](https://crr.bc.edu/people-can-spot-a-scam-after-seeing-fakes); [AARP](https://www.aarp.org/money/scams-fraud/info-2022/social-security-scams-studies.html)
- "Nunca te pediremos la clave" no cubre el caso en que el propio usuario entrega la clave voluntariamente a un familiar, ayudante o tramitador, que es el patrón documentado en el IESS (estudio previo).
- Las alertas se emiten después de que una modalidad ya circula (reactivas) y su difusión depende de la prensa: casi todas las fuentes anteriores son notas de medios, no páginas oficiales permanentes.

### Inferences
- Una página/bot de "verifica si este mensaje es del IESS" o "lista de canales oficiales" es la extensión natural de esta campaña y, por tanto, también CENTRO; solo deja de serlo si se combina con algo que el estándar no hace (medición, inoculación activa, fricción en el proceso).
- El estándar es igual en todos los institutos de seguridad social de la región: el jurado lo ha visto en cada comunicado del IESS y del SRI.

### Gaps
- No se encontró una página oficial permanente del IESS de "canales oficiales / verificación" equivalente a la lista de dominios del SRI.
- No se encontró ninguna evaluación de impacto de estas campañas en LatAm (alcance, recordación o reducción de fraude).
- No se revisaron Registro Civil Ecuador ni IPS Chile en detalle por límite de búsquedas.

## 4. Ganadores estándar de hackatones de concienciación/ciberseguridad en LatAm y España (2022-2026)

### Takeaway
Los proyectos que aparecen como ganadores o finalistas siguen pocas plantillas: detector de phishing (extensión de navegador o filtro de correo, cada vez más con LLM), "app integral de protección" contra fraude, chatbot/clasificador de mensajes con IA para adultos mayores, y en menor medida juegos y medidores de nivel de seguridad. La documentación pública de los ganadores suele ser escasa (nombre del equipo y categoría, sin métricas ni continuidad).

### Cited Findings
- **Desafío Tecnológico CiberUGR-INCIBE 2025 (Universidad de Granada, España)**, 5-16 mayo 2025: ganadores ex aequo "Msecure" (estimador de nivel de seguridad del dispositivo, Reto 1) y "yo" (sistema anti-phishing/anti-spam, Reto 2); premio: trofeo y diplomas — [CiberUGR noticia](https://catedras.ugr.es/ciberugr-incibe/informacion/noticias/retomayo2025). La edición 2024 ya tenía un reto de sistema anti-phishing/anti-spam para filtrar correos — [CiberUGR 2024](https://catedras.ugr.es/ciberugr-incibe/print/pdf/node/19)
- **Hackatón de ciberseguridad "Perú Hub Digital – Universitario 2025"** (Unity Perú, Colegio de Ingenieros del Perú, Asociación Peruana de Data Center; 14-15 nov 2025, Callao): primer lugar UCH con "Guardian App", "arquitectura de protección integral" para anticipar, detectar y mitigar riesgos frente a fraude, robo de identidad y pérdida de datos; tecnología y premio no especificados — [UCH](https://www.uch.edu.pe/noticias/uch-triunfa-en-hackaton-de-ciberseguridad-con-propuesta-que-enfrenta-los-fraudes-digitales-en-el-peru/403)
- **Hackathon 404 (México)**: herramientas para prevenir, detectar o reducir riesgos digitales para menores; capital semilla de USD 25.000 al ganador (nombre no obtenido) — [Hackathon 404](https://www.hackathon404.com/)
- **Ecuador**: no se encontró un hackatón de ciberseguridad/concienciación con ganadores documentados. Lo más cercano: MediaHack (Quito, feb-2025) contra desinformación electoral, tres ganadores con USD 1.200 en total, entre ellos "Goddard" (IA que analiza noticias y detecta discurso de odio) — [Global Voices](https://es.globalvoices.org/2025/03/18/mediahack-36-horas-contra-la-desinformacion-electoral-en-ecuador/); World Hackathon Ecuador 2025, ganó ESPOCH con "Legado" (herencia digital con contratos inteligentes) — [Diario Los Andes](https://www.diariolosandes.com.ec/estudiantes-de-la-espoch-ganan-primer-lugar-en-el-world-hackathon-ecuador-2025/); Banco Guayaquil ganó el Hackathon CLAIN 2025 de FELABAN (detalle no revisado) — [FELABAN](https://felaban.com/banco-guayaquil-de-ecuador-gana-el-hackathon-clain-2025/)
- **Premios Líder IT Ecuador 2025, Proyectos de Seguridad de la Información** (no es hackatón): 1.º Teojama Comercial (gestión de vulnerabilidades con inteligencia predictiva); 2.º CEDIA (proyecto DALIA) — [IT Ahora, 05-01-2026](https://itahora.com/2026/01/05/premios-lider-it-ecuador-2025-proyectos-seguridad-de-la-informacion/); edición 2026 publicada el 24-11-2026 — [IT Ahora](https://itahora.com/2026/11/24/premios-lider-it-2026-ganadores-proyectos-seguridad-de-la-informacion-y-lider-ciso/) (no revisada)
- **Competencias tipo CTF/Cybersec Challenge**: Costa Rica Cybersec Challenge 2024 y 2025 (ganadores por categoría, el primero pasa al equipo nacional para el desafío europeo) — [CRHoy 2024](https://crhoy.com/tecnologia/estos-son-los-ganadores-del-cybersec-challenge-2024/); [CRHoy 2025](https://crhoy.com/estos-son-los-ganadores-del-cybersec-challenge-2025/); Liga de Ciberseguridad en HackOn 2025 (España) — [CODDII](https://www.coddii.org/entregados-los-premios-de-la-liga-de-ciberseguridad-en-el-marco-de-hackon-2025/). Son competencias técnicas, no de cultura.
- **Patrón Devpost (internacional, 2024-2026)**: proliferan proyectos casi idénticos: PhisherCatcher (extensión con Gemini que evalúa sitios en tiempo real, menciona a adultos mayores), Safely (extensión Chrome con explicación por IA y narración por voz), ScamShield v4 (clasifica mensajes SCAM/SUSPICIOUS/SAFE con la API de Claude, lectura en voz alta y galería de 8 tipos de estafa), ScamShield Seniors (Streamlit con letra grande y lectura en voz), FishAlert, Dory Defense; no se confirmó su condición de ganadores — [PhisherCatcher](https://devpost.com/software/phishsercatcher); [Safely](https://devpost.com/software/safely-398y1j); [ScamShield v4](https://devpost.com/software/scamshield-v4); [ScamShield Seniors](https://devpost.com/software/scamshield-seniors); [FishAlert](https://devpost.com/software/fishalert); [Dory Defense](https://devpost.com/software/update-later)
- **Juegos gubernamentales de concienciación**: "Gana al Hacker" (Agència de Ciberseguretat de Catalunya), juego interactivo ciudadano — [Ciberseguretat Gencat](https://ciberseguretat.gencat.cat/es/ciutadania/activitats-interactives/guanya-el-hacker); app gratuita "Cordi" (Mendoza, Argentina) para que adultos mayores detecten estafas telefónicas, no es ganadora de hackatón — [Los Andes](https://www.losandes.com.ar/sociedad/la-app-gratuita-que-creo-un-mendocino-evitar-caer-estafas-telefonicas-n6015522)
- **Limitación general**: solo ~5 % de los proyectos de hackatón sigue activo cinco meses después — [Nolte et al., NSF PAR](https://par.nsf.gov/servlets/purl/10284449) (ya citado en el estudio previo)

### Inferences
- El "proyecto ganador típico" que el jurado ya ha visto: (a) detector de phishing por extensión o correo, (b) chatbot/clasificador de mensajes con LLM y lectura en voz para mayores, (c) app "integral" de protección, (d) juego/quiz de concienciación. Todos son CENTRO en el contexto de hackatones 2024-2026.
- Ninguno de los ejemplos encontrados ataca el proceso (cambio de contacto/cuenta, delegación de la clave, abuso interno) ni presenta medición de efecto; ese vacío es consistente con los criterios del estudio previo.
- Los clasificadores con LLM son hoy tan comunes en Devpost que ya no se distinguen por sí solos; además, su sobreconfianza es un riesgo documentado (estudio previo, arXiv 2505.03179).

### Gaps
- No se encontraron ganadores documentados de hackatones de concienciación en Ecuador 2022-2026 ni ediciones previas de Código Confianza del IESS.
- No se revisó el detalle de proyectos del Hackathon CLAIN 2025 (FELABAN), del INCIBE Hackathon (página sin año ni ganadores) ni de HackOn 2025.
- No se pudo confirmar qué proyectos de Devpost ganaron premio.

## 5. Limitaciones conocidas de cada enfoque estándar (resumen con escala)

### Takeaway
Las cinco piezas del centro de la campana (curso anual en LMS, simulación de phishing con dashboard de clic, plataforma comercial, campaña "nunca te pediremos tu clave" y detector/chatbot de hackatón) cumplen la norma y son fáciles de mostrar, pero la evidencia indica efectos pequeños o no medidos sobre la conducta, y ninguna toca el vector principal del IESS (clave delegada o abusada que permite cambiar datos y mover dinero).

### Cited Findings
| Solución estándar | Límite principal | Evidencia | Escala |
|---|---|---|---|
| Curso anual obligatorio (Moodle/IESSEDUCA, MINTEL, OEA) | Sin relación medible con la tasa de clic | [Ho et al. 2025](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf) | CENTRO |
| Simulación de phishing + capacitación embebida (GoPhish, KnowBe4, Microsoft AST) | Reducción ~2 pp; puede reducir la resiliencia; tasa depende del señuelo (1,8-30,8 %) | [Ho et al. 2025](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf); [Lain et al. 2022](https://arxiv.org/abs/2112.07498) | CENTRO |
| Castigo/consecuencias por fallar simulaciones | Reduce la aceptación y el reporte | [CREST](https://www.crestresearch.ac.uk/resources/phishing-your-staff/); [USEC 2025](https://ndss-symposium.org/wp-content/uploads/usec25-10.pdf) | CENTRO (práctica frecuente) |
| Botón de reporte + reporte colectivo | Funciona mejor que la formación; depende de no castigar | [Lain et al. 2022](https://arxiv.org/abs/2112.07498) | CONVERGENTE |
| Avisos contextuales en el correo (banners) | Funcionaron en el estudio de 14.773 empleados | [Lain et al. 2022](https://arxiv.org/abs/2112.07498) | CONVERGENTE |
| Comunicados "nunca te pediremos tu clave" + lista de canales oficiales | Lectura estática no mejora detección; reactivos; no cubren entrega voluntaria de la clave | [Boston College CRR](https://crr.bc.edu/people-can-spot-a-scam-after-seeing-fakes) | CENTRO |
| Inoculación con ejemplos simulados para ciudadanos | Mejora detección sin bajar confianza en mensajes legítimos; decae sin refuerzo | [AARP](https://www.aarp.org/money/scams-fraud/info-2022/social-security-scams-studies.html); [PMC11897321](https://pmc.ncbi.nlm.nih.gov/articles/PMC11897321/) | CONVERGENTE |
| Gamificación/juegos de concienciación | Ganancias de conocimiento a corto plazo; formato juego dejó de ser significativo a los 9 días | [PMC11897321](https://pmc.ncbi.nlm.nih.gov/articles/PMC11897321/); [Informing Science](https://www.informingscience.org/Publications/5601) | CENTRO en hackatones |
| Detector/extensión/chatbot con LLM | Sobreconfianza del usuario en la IA acierte o no; abundan clones | [arXiv 2505.03179](https://arxiv.org/html/2505.03179v1); ejemplos Devpost sección 4 | CENTRO en hackatones |
| Benchmarks de proveedores ("-79 % en un año") | Sin grupo de control ni ajuste de dificultad | [nota KnowBe4](https://laopinion.com/latinowire/un-estudio-de-knowbe4-revela-que-la-vulnerabilidad-al-phishing-a-nivel-mundial-se-reduce-un-79-tras-un-ano-de-formacion-en-concienciacion-sobre-seguridad/) | CENTRO |

### Inferences
- La frontera entre CENTRO y CONVERGENTE en este mercado está en pasar de "medir clics y dar cursos" a "medir reportes, avisar en el momento y practicar con casos reales sin castigo". Los proveedores comerciales ya se están moviendo hacia esa frontera (Hoxhunt, "Real-time Coaching" de KnowBe4), así que el jurado probablemente también la conoce.
- Para el IESS, lo que ninguna solución estándar cubre es el momento del proceso (cambio de correo/teléfono/cuenta, solicitud de préstamo o fondos) y el actor interno; ese es el espacio donde una propuesta podría salir del centro de la campana.

### Gaps
- No se hallaron evaluaciones independientes de Hoxhunt, SoSafe o Microsoft AST con grupo de control.
- No hay datos públicos sobre el resultado de campañas de phishing simulado en instituciones públicas ecuatorianas.
