# Marco legal, regulatorio y de política pública de seguridad de la información y protección de datos personales aplicable al IESS (Ecuador, corte 25-nov-2026)

Nota metodológica: notas elaboradas con 21 consultas web. El texto del Acuerdo MINTEL-MINTEL-2024-0003 (EGSI v3) se leyó directamente del PDF oficial. Gran parte de los datos de la LOPDP y de las resoluciones de la SPDP provienen de guías secundarias (advise.ec, piranirisk.com) y de los PDF de spdp.gob.ec vistos solo como resultados de búsqueda; conviene contrastarlos con el Registro Oficial antes de citarlos en el informe final. Los vacíos se marcan en cada sección.

## 1. LOPDP (2021), Reglamento (2023) y Superintendencia de Protección de Datos Personales (SPDP)

### Takeaway
El IESS es responsable del tratamiento de datos sensibles (salud y seguridad social) a gran escala. Debe tener delegado de protección de datos inscrito en la SPDP, hacer evaluaciones de impacto, notificar vulneraciones en 5 días (vía SISPDP y, desde la reforma de mayo de 2026, también al CSIRT) y responder ante un régimen sancionatorio vigente desde el 26-may-2023. Ese régimen incluye multas personales de 1 a 20 SBU para servidores públicos. La SPDP ya opera: emite normas técnicas desde 2025 y en noviembre y diciembre de 2025 impuso sus primeras multas, a la LigaPro y a la FEF.

### Cited Findings
**Instrumentos y fechas**
- LOPDP: Quinto Suplemento del Registro Oficial n.º 459, 26-may-2021. Rige desde su publicación (Disposición Final) — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/); [datospersonales.lat](https://datospersonales.lat/ley-datos-personales-ecuador-lopd-registro-oficial-459/)
- Reglamento General a la LOPDP: Decreto Ejecutivo 904, Tercer Suplemento del RO n.º 435, 13-nov-2023 — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
- Régimen sancionatorio exigible desde el 26-may-2023, al cumplirse los dos años de transición de la Disposición Transitoria Primera — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)

**Obligaciones del responsable (aplican al IESS como entidad pública)**
- Art. 47: políticas de protección de datos y medidas administrativas, técnicas, físicas, organizativas y jurídicas (núm. 2 y 4); confidencialidad del personal (art. 34; art. 47 núm. 10; Reglamento art. 41); designar e inscribir al delegado (art. 47 núm. 13; art. 48); reportar al Registro Nacional (art. 51) — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
- Art. 37 (seguridad): exige una metodología de análisis de riesgos. Arts. 40 y 41: cifrado y seudonimización. Art. 39: privacidad desde el diseño — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
- Art. 42 (evaluación de impacto): obligatoria antes de tratar categorías especiales a gran escala, perfiles con efectos jurídicos u observación sistemática a gran escala. Se desarrolla en los arts. 29 a 32 del Reglamento — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)

**Notificación de vulneraciones (plazos)**
- Art. 43: el responsable notifica a la SPDP (y al organismo de control competente) lo antes posible y a más tardar en 5 días desde que tuvo constancia. Si se pasa de ese plazo, debe explicar los motivos de la demora. El encargado notifica al responsable en 2 días — [piranirisk / búsqueda](https://www.piranirisk.com/es/hub-regulatorio/notificacion-vulneracion-datos-personales-ecuador-spdp); [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
- Según advise.ec, la reforma de mayo de 2026 añadió al CSIRT como destinatario de la notificación del art. 43. Es coherente con la Ley Orgánica para el Fortalecimiento de la Ciberseguridad, que reforma la LOPDP (sección 3) — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/); [dplnews](https://dplnews.com/entra-en-vigor-ley-de-ciberseguridad-en-ecuador/)
- Art. 46 (notificación al titular): 3 días cuando hay riesgo para sus derechos, según [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/). En cambio, el resumen de la Res. SPDP-SPD-2026-0040-R habla de notificar a los titulares "sin dilación" — [piranirisk](https://www.piranirisk.com/es/hub-regulatorio/notificacion-vulneracion-datos-personales-ecuador-spdp). Hay que verificarlo contra el texto oficial.
- Res. SPDP-SPD-2026-0040-R, norma técnica de notificación de vulneraciones: expedida el 9-sep-2026 y publicada en el Suplemento del RO 376 de 24-sep-2026. La notificación se hace por el SISPDP (Sistema Nacional de Registro de Datos Personales), y otros canales solo se admiten de forma excepcional, si el sistema no está disponible. Aplica a responsables públicos y privados y prevé un sistema experto auxiliar con IA y supervisión humana — [piranirisk](https://www.piranirisk.com/es/hub-regulatorio/notificacion-vulneracion-datos-personales-ecuador-spdp); [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)

**Delegado de Protección de Datos (DPD)**
- Arts. 48 a 50 LOPDP. El DPD se inscribe en la SPDP dentro de 15 días hábiles desde su designación (Res. SPDP-SPD-2025-0028-R, Reglamento del Delegado, art. 5; firmada el 30-jul-2025 y publicada en el RO 105 de 19-ago-2025). El art. 10 de esa resolución lista 14 tipos de entidades obligadas, entre ellas las de salud y las aseguradoras — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
- Una guía señala que el art. 48 exige DPD en el sector público — [resultado de búsqueda / siberson](https://www.siberson.com/regulation-ecuador-lopdp.html) (fuente secundaria).
- El EGSI v3 hace al DPD miembro del Comité de Seguridad de la Información de cada institución (art. 6 del Acuerdo MINTEL-MINTEL-2024-0003) — [MINTEL](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)

**Datos de salud y grupos vulnerables**
- Art. 25: categorías especiales, entre ellas los datos de salud, los de niñas, niños y adolescentes y los de personas con discapacidad. Art. 26: su tratamiento está prohibido salvo excepciones, como el consentimiento explícito, una orden judicial o el cumplimiento de obligaciones laborales y de seguridad social. Esta última es la base para buena parte del tratamiento del IESS — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
- Res. SPDP-SPD-2026-0005-R, sobre tratamiento a gran escala, publicada en el RO 231 de 25-feb-2026 — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/); [PDF Lexis](https://strapi.lexis.com.ec/uploads/SPDP_SPD_2026_0005_R_3fe7408041.pdf)

**Sanciones**
- Servidores públicos: de 1 a 10 SBU por infracción leve (art. 71) y de 10 a 20 SBU por infracción grave (art. 72). Para entidades se fijan porcentajes del volumen de negocios: de 0,1 % a 0,7 % (leve) y de 0,7 % a 1 % (grave). Hay medidas correctivas previas (arts. 65 y 66) — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/). Otra guía da "hasta 20 SBU" para graves en el sector público, lo que coincide — [búsqueda, varias guías](https://orizontel.ec/guia-lopdp-ecuador/)
- Res. SPDP-SPD-2025-0022-R, sobre cálculo de multas: firmada el 16-jul-2025 y publicada en el RO 92 de 30-jul-2025 — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)

**SPDP: autoridad, superintendente y normativa**
- El superintendente se designa de una terna enviada por el Presidente de la República, para cinco años (art. 77). Sus funciones constan en el art. 76 — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
- Superintendente: Fabrizio Peralta Díaz. Asumió el cargo tras su designación en la Asamblea Nacional "el 23 de abril"; la fuente no indica el año — [FTCS](https://ftcs.gob.ec/nueva-superintendencia/). Las resoluciones de 2025 y 2026 llevan su firma — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
- Resoluciones relevantes para el IESS:
  - 2025-0002-R: Plan Regulatorio Institucional 2025, 3-feb-2025 — [SPDP](https://spdp.gob.ec/wp-content/uploads/2025/02/PIR2025.pdf)
  - 2025-0003-R: gestión de riesgos y evaluación de impacto, RO 41 de 19-may-2025 — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
  - 2025-0006-R: cláusulas de protección de datos en contratos, RO 42 de 20-may-2025. Es relevante para contratar proveedores de soluciones de concienciación — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
  - 2025-0024-R: normativa general de aplicación de la LOPDP y su Reglamento, 25-jul-2025 — [SPDP](https://spdp.gob.ec/wp-content/uploads/2025/07/SPSP-SPD-2025-0024-R-Normativa-General-Aplicacion-de-la-LOPDP-y-su-Reglamento55-signed.pdf)
  - 2025-0028-R: Reglamento del Delegado — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
  - 2025-0030-R: seudonimización, anonimización, bloqueo y eliminación, RO 115 de 2-sep-2025 — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
  - 2025-0034-R: reglamento del procedimiento — [SPDP](https://spdp.gob.ec/wp-content/uploads/2025/09/SPDP-SPD-2025-0034-R-Reglamento-del-Procedimiento.pdf)
  - 2025-0040-R: protección de datos desde el diseño, RO 163 de 13-nov-2025 — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
  - 2025-0041-R: interés legítimo, Suplemento del RO 177 de 3-dic-2025 — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
  - 2026-0004-R: transferencias nacionales e internacionales, RO 225 de 13-feb-2026 — [SPDP](https://spdp.gob.ec/wp-content/uploads/2026/01/04.01.01-SPSP-SPD-2026-0004-R-Norma-general-de-transferencias-signed.pdf)
  - 2026-0009-R: inteligencia artificial, RO 240 de 10-mar-2026, reformada por la 2026-0037-R (RO 373 de 21-sep-2026) — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/); [Lexis](https://www.lexis.com.ec/noticias/superintendencia-de-proteccion-de-datos-personales-expide-norma-general-para-la-proteccion-de-datos-personales-en-el-uso-de-inteligencia-artificial)
  - 2026-0039-R: datos biométricos, RO 376 de 24-sep-2026 — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
  - 2026-0040-R: notificación de vulneraciones (ver arriba)
- Proyecto de norma sobre presentación y trámite de denuncias, de febrero de 2026 — [SPDP](https://spdp.gob.ec/wp-content/uploads/2026/02/Proyecto_presentacion_tramite_denuncias.pdf)

**Acciones de control y sanción (primeras multas)**
- LigaPro, infracción grave (28-nov-2025): USD 259.644,01. FEF, grave (28-nov-2025): USD 194.856,16. LigaPro, leve con reiteración (19-dic-2025): USD 95.502,63. FEF, grave (31-dic-2025): USD 194.496,85. La FEF apeló la primera — [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)
- Los temas de esas resoluciones fueron los datos biométricos (FAN ID) sin base legal clara ni privacidad desde el diseño (RES-SPDP-ICS-2025-0005, 19-dic-2025), una política de privacidad que no cumplía el art. 12 de la LOPDP sobre el derecho a la información (RES-SPDP-ICS-PASN-2025-0003) y la metodología de gestión de riesgos de la FEF (RES-SPDP-ICS-2025-0006, 31-dic-2025) — [SPDP 0005](https://spdp.gob.ec/wp-content/uploads/2026/01/RESOLUCION-Nro.-RES-SPDP-ICS-2025-0005VF-of.pdf); [SPDP PASN 0003](https://spdp.gob.ec/wp-content/uploads/2025/12/RESOLUCION-Nro.-RES-SPDP-ICS-PASN-2025-0003-f-signed_redacted-1.pdf); [SPDP 0006](https://spdp.gob.ec/wp-content/uploads/2026/01/RESOLUCION-Nro.-RES-SPDP-ICS-2025-0006-signed-2.pdf)

### Inferences
- El IESS cae casi con seguridad en los supuestos del art. 42 (categorías especiales a gran escala). Una solución de cultura de seguridad que procese datos de servidores, como resultados de simulaciones de phishing o métricas individuales de comportamiento, requiere base legal, cláusulas contractuales conformes a la Res. 2025-0006-R y quizá su propia evaluación de impacto o de riesgos (Res. 2025-0003-R).
- Como las multas personales de la LOPDP (1 a 20 SBU) recaen sobre servidores públicos, la formación tiene un argumento de reducción de riesgo individual: cada funcionario que trata datos responde personalmente.
- Los plazos de 5 días (SPDP y CSIRT), 3 días o "sin dilación" (titulares) y 2 días (encargados) deben formar parte de los contenidos de formación y de los ejercicios de respuesta a incidentes.
- Las primeras sanciones se dirigieron a entidades privadas del fútbol. No se encontraron sanciones públicas contra entidades del sector público.

### Gaps
- No se encontró en la LOPDP un artículo que obligue expresamente a capacitar al personal. Las fuentes consultadas no mencionan capacitación. Hay que revisar el texto oficial del art. 47 (la lista completa de numerales) y el Reglamento (Decreto 904), por si existe un deber de formación o concienciación.
- Falta el texto oficial de los arts. 71 y 72 (posible confusión de numeración: otras fuentes ubican las sanciones en los arts. 72 a 76). Conviene verificarlos en el RO 459.
- Falta la fecha exacta en que la SPDP empezó a operar y el año de la designación de Fabrizio Peralta (la fuente dice solo "23 de abril").
- No se encontró ninguna disposición específica sobre datos de adultos mayores en la LOPDP ni en las resoluciones de la SPDP.
- No se encontraron acciones de la SPDP dirigidas al IESS ni a otras entidades públicas.
- No se verificó el alcance exacto de la reforma de mayo de 2026 al art. 43 (incluir al CSIRT).

## 2. EGSI v3 (Acuerdo Ministerial MINTEL-MINTEL-2024-0003)

### Takeaway
El EGSI v3 es obligatorio para todo el sector público, incluido el IESS. Obliga a nombrar un Oficial de Seguridad de la Información (OSI) y a conformar un Comité de Seguridad de la Información en el que participa el DPD. El art. 9, núm. 6 y 7, encarga expresamente al OSI elaborar un Plan de concienciación y fomentar la cultura de seguridad. El esquema se basa en ISO/IEC 27001:2022 y exige reportes a MINTEL y ciclos anuales de mejora que empiezan en enero.

### Cited Findings
- Suscrito el 8-feb-2024 por el ministro César Antonio Martín Moreno. Deroga los AM 025-2019 (EGSI v2) y MINTEL-MINTEL-2021-0012 — [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Publicado en el Tercer Suplemento del RO n.º 509. Las fuentes discrepan sobre la fecha: 1-mar-2024 o 10-mar-2024 — [Gobierno Electrónico, RO](https://www.gobiernoelectronico.gob.ec/wp-content/uploads/2024/03/Registro-Oficial-Acuerdo-Ministerial-No.-0003-2024-EGSI-version-3.0.pdf); [GlobalSuite](https://www.globalsuitesolutions.com/es/egsi-nueva-version-esquema-gubernamental-seguridad-informacion/)
- Basado en ISO/IEC 27001:2022 — [Plan de Evaluación Interna EGSI v3](https://www.comunica.ec/library/Hitos/0.4/0_0_4%20Plan%20de%20Evaluaci%C3%B3n%20Interna%20EGSI-V3.pdf)
- Art. 2: obligatorio para entidades, organismos e instituciones del sector público, con base en el art. 225 de la Constitución y en los arts. 7 lit. o) y 20 de la Ley Orgánica para la Transformación Digital y Audiovisual (LOTDA). También es obligatorio para terceros que prestan servicios públicos por concesión — [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Art. 3: evaluación de riesgos de los activos de información en los procesos esenciales y un plan de tratamiento, según la "Guía para la gestión de riesgos de seguridad de la información" (Anexo). Además, un "Informe de cumplimiento de la Gestión de Riesgos" anual, firmado por el presidente del Comité de Seguridad de la Información (CSI) y puesto en conocimiento de la máxima autoridad — [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Art. 5: la máxima autoridad conforma la estructura de seguridad "con personal formado y experiencia" y asigna los recursos necesarios — [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Art. 6 (CSI): lo integran Planificación (que lo preside), Talento Humano, Administrativa, Comunicación Social, TI, Jurídica y el Delegado de protección de datos. El OSI asiste con voz pero sin voto — [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Art. 7 (funciones del CSI): núm. 8, "Promover la difusión de la seguridad de la información dentro de la institución"; núm. 6, supervisar incidentes de impacto alto; núm. 10, reunirse cada dos meses; núm. 11, informar cada seis meses a la máxima autoridad sobre el avance del EGSI — [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Art. 8 (OSI): lo designa la máxima autoridad y la designación se comunica de inmediato a la Subsecretaría de Gobierno Electrónico y Registro Civil del MINTEL. Perfil: formación o especialización y al menos 2 años de experiencia en seguridad de la información o ciberseguridad, funcionario de carrera (de preferencia de nivel jerárquico superior). Su área no puede pertenecer a procesos, riesgos, administrativo, financiero ni TI — [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Art. 9 (responsabilidades del OSI), las más relevantes para cultura de seguridad:
  - núm. 6: "Elaborar y coordinar el Plan de concienciación en Seguridad de la Información basado en el EGSI", con las áreas involucradas y en coordinación con comunicación institucional.
  - núm. 7: "Fomentar la cultura de seguridad de la información en la institución".
  - núm. 10: plan de respuesta a incidentes.
  - núm. 11: escalar los incidentes de alto impacto al CSIRT sectorial o nacional.
  - núm. 12: revisiones internas periódicas.
  - núm. 16: transferencia de conocimientos al terminar funciones, verificada por Talento Humano.
  - núm. 18: punto de contacto con MINTEL.
  - [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Art. 10: durante la implementación, las instituciones reportan su avance a MINTEL con las herramientas que este disponga y firman una declaración de responsabilidad sobre la veracidad del reporte — [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- El seguimiento se hace como proyecto en la herramienta GPR (Gobierno por Resultados), según un instructivo de MINTEL; el cierre del proyecto se fijó hasta el 28-feb (de 2025, según el contexto) — [Instructivo MINTEL](https://www.gobiernoelectronico.gob.ec/wp-content/uploads/2024/03/INSTRUCTIVO-Creacion-del-Proyecto-Implementacion-EGSIV3-en-GPR.pdf)
- Disposiciones generales: la Subsecretaría de Gobierno Electrónico monitorea, evalúa y controla el cumplimiento (Segunda); al vencer el plazo, evaluadores independientes miden el cumplimiento (Tercera); después de implementarlo, cada institución abre un nuevo proyecto de mejora continua en enero de cada año (Cuarta) — [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Disposiciones transitorias, con plazos contados desde la publicación en el RO:
  - Primera: designar al OSI en 30 días.
  - Segunda: implementar o actualizar el EGSI en 12 meses (hacia marzo de 2025).
  - Tercera: formato del Informe de Gestión de Riesgos en 60 días.
  - Cuarta: lineamientos de seguimiento en 90 días.
  - Quinta: instrumentos en el micrositio de gobiernoelectronico.gob.ec.
  - [MINTEL PDF](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- Instituciones públicas ya emitieron políticas de seguridad "EGSI v3", por ejemplo la DGAC (mayo de 2025) y la Superintendencia de Ordenamiento Territorial (firmada en 2025, publicada en enero de 2026) — [DGAC](https://www.aviacioncivil.gob.ec/wp-content/uploads/downloads/2025/05/pol%C3%ADtica_de_seguridad_de_la_informaci%C3%B3n_egsi-_v3_final-1-signed.pdf); [SOT](https://www.sot.gob.ec/wp-content/uploads/2026/01/0.5._politica_de_seguridad_de_la_informacion_-_egsi_v3-2025_signed_3-1.pdf)

### Inferences
- Una solución de cultura de ciberseguridad para el IESS encaja directamente en el art. 9 núm. 6 y 7 (Plan de concienciación y cultura, a cargo del OSI), en el art. 7 núm. 8 (difusión, a cargo del CSI) y en el art. 5 (personal formado). Además, debería producir evidencia para el informe semestral del CSI, el informe anual de riesgos, los reportes en GPR y las evaluaciones independientes de MINTEL.
- Como el esquema se basa en ISO/IEC 27001:2022, el control del Anexo A más pertinente es probablemente el 6.3 (concienciación, educación y formación). Esto no se verificó en el Anexo del EGSI.
- El ciclo de mejora que empieza en enero sugiere planificar las campañas de concienciación como entregables anuales alineados con ese ciclo.

### Gaps
- No se pudo leer el Anexo del EGSI v3, con la lista de controles y los hitos. Falta confirmar la numeración y redacción exactas del control de concienciación y formación y sus evidencias (por ejemplo, el hito 0.4 del Plan de Evaluación Interna).
- No se verificó si MINTEL emitió una versión posterior del EGSI (v3.1 o reformas) entre 2025 y 2026, ni los lineamientos de seguimiento de la Transitoria Cuarta.
- No se encontraron sanciones específicas por incumplir el EGSI. Probablemente se canalizan vía la Contraloría (Normas de Control Interno), lo que también está sin verificar.

## 3. Política Nacional de Ciberseguridad (2021), Estrategia Nacional (ENC) y Ley Orgánica para el Fortalecimiento de la Ciberseguridad (2026)

### Takeaway
La política de 2021 (AM 006-2021) dedica un pilar entero (el VII) a cultura y educación, y la ENC prevé un programa nacional de concienciación y cultura liderado por MINTEL. La principal novedad de 2026 es la Ley Orgánica para el Fortalecimiento de la Ciberseguridad (Quinto Suplemento del RO 290, 22-may-2026). Esta ley reforma la LOTDA, la LOPDP, el COIP, la LOT, la LOEI y la Ley de Comunicación; crea un Catálogo Nacional de Servicios Esenciales e Infraestructura Crítica Digital y fortalece al CSIRT y a MINTEL como rector.

### Cited Findings
- Política Nacional de Ciberseguridad: Acuerdo Ministerial 006-2021 (MINTEL, junio de 2021), con siete pilares. El VII, "cultura y educación", promueve la educación en seguridad del ciberespacio y la cultura de ciberseguridad, oferta académica de tercer y cuarto nivel y planes educativos en todos los niveles — [AM 006-2021](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2021/06/Acuerdo-No.-006-2021-Politica-de-Ciberseguridad.pdf); [Anexo](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2021/06/Acuerdo-No.-006-Anexo-Politica-de-Ciberseguridad..pdf)
- Estrategia Nacional de Ciberseguridad, v1.1 (2022): seis pilares, entre ellos "Habilidades y capacidades de ciberseguridad". Prevé un programa nacional de concienciación y cultura liderado por MINTEL y un plan nacional de educación en ciberseguridad liderado por el Ministerio de Educación — [ENC v1.1](https://aportecivico.gobiernoelectronico.gob.ec/system/documents/attachments/000/000/103/original/04bfdeb041e78cdc522f3d095f340a5dea2f0083.pdf); [Difusión ENC](https://www.gobiernoelectronico.gob.ec/wp-content/uploads/2022/10/Difusion-ENC.pdf)
- MINTEL publicó en diciembre de 2022 un diagnóstico de capacidades de ciberseguridad del Ecuador — [MINTEL](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2023/05/DIAGNO%CC%81STICO-DE-LAS-CAPACIDADES-DE-CIBERSEGURIDAD-Ecuador-Diciembre-2022_compressed.pdf)
- Política Pública para la Transformación Digital del Ecuador 2025-2030 (MINTEL, 2025): incluye un enfoque de cultura digital y el mandato de coordinar acciones de ciberseguridad — [MINTEL](https://www.gobiernoelectronico.gob.ec/wp-content/uploads/2025/03/INSTRUMENTO-Politica-Publica-para-la-Transformacion-Digital-Ecuador-2025-2030-MINTEL-signed_f.pdf)
- Ley Orgánica para el Fortalecimiento de la Ciberseguridad:
  - Aprobada por el Pleno el 10-feb-2026 con 82 votos. El Presidente Noboa presentó una objeción parcial el 12-mar-2026, y la Asamblea se allanó con 83 votos — [Asamblea Nacional](https://www.asambleanacional.gob.ec/es/node/115246); [El Telégrafo](https://www.eltelegrafo.com.ec/noticias/nacionales/210/asamblea-aprobo-ley-fortalecimiento-ciberseguridad)
  - Publicada en el Quinto Suplemento del RO 290 el 22-may-2026 — [Lexis](https://www.lexis.com.ec/noticias/registro-oficial-del-dia-ley-organica-para-el-fortalecimiento-de-la-ciberseguridad); [El Universo](https://www.eluniverso.com/noticias/politica/ley-fortalecimiento-ciberseguridad-registro-oficial-nota/)
  - Objeto: estándares nacionales de seguridad digital, mecanismos de gestión y notificación de incidentes y coordinación interinstitucional. Ámbito: entidades públicas que gestionan servicios esenciales o infraestructura crítica digital, prestadores de servicios digitales ("principio de responsabilidad compartida") y privados con incidencia directa en servicios esenciales — [Lexis](https://www.lexis.com.ec/noticias/registro-oficial-del-dia-ley-organica-para-el-fortalecimiento-de-la-ciberseguridad); [dplnews](https://dplnews.com/entra-en-vigor-ley-de-ciberseguridad-en-ecuador/)
  - Crea el Catálogo Nacional de Servicios Esenciales e Infraestructura Crítica Digital, a cargo del ente rector y revisable al menos cada dos años, y habilita el hacking ético y las pruebas de penetración con consentimiento — [Lexis](https://www.lexis.com.ec/noticias/registro-oficial-del-dia-ley-organica-para-el-fortalecimiento-de-la-ciberseguridad)
  - Refuerza a MINTEL como rector y da competencias al CSIRT para coordinar incidentes a nivel nacional. Incorpora estándares ISO 27000 y NIST. Reforma la LOEI para que escuelas, colegios y universidades implementen programas de formación en seguridad digital, ciberseguridad y protección de datos — [AENA](https://aena.com.ec/ecuador-aprueba-una-ambiciosa-ley-de-ciberseguridad-que-incorpora-la-educacion-digital-obligatoria/)
  - Otras reformas: la LOT (protección de redes e incidentes), la LOPDP (articula la protección de datos con la respuesta a incidentes), la LOTDA (obligaciones de ciberseguridad en la digitalización del Estado), la Ley de Comunicación y el COIP — [dplnews](https://dplnews.com/entra-en-vigor-ley-de-ciberseguridad-en-ecuador/)
  - Críticas por posible vigilancia y uso político — [Sufragio](https://sufragio.org/ecuador-aprueba-ley-de-ciberseguridad-en-medio-de-criticas-por-privacidad/)

### Inferences
- Es muy probable que el IESS, por gestionar pensiones, salud y prestaciones, entre en el Catálogo Nacional de Servicios Esenciales e Infraestructura Crítica Digital. Eso le sumaría obligaciones de notificación de incidentes al CSIRT además de las de la LOPDP. Falta confirmarlo.
- La mención expresa de ISO 27000 y NIST en la ley respalda que una solución de cultura de seguridad use marcos como NIST SP 800-50 y la ISO 27002 6.3 como referencia de diseño.

### Gaps
- No se obtuvo el texto de la ley de 2026. Faltan sus plazos de notificación de incidentes, la figura de un responsable u oficial de ciberseguridad, las obligaciones de capacitación para entidades públicas, las sanciones, las disposiciones transitorias y el plazo para el reglamento.
- No se encontró una Estrategia Nacional de Ciberseguridad nueva para 2025 en adelante, ni una evaluación oficial del avance de la ENC 2022-2025. Las fuentes discrepan en el número de pilares (siete en la política de 2021, seis en la ENC).
- No se sabe si el IESS está en el Catálogo Nacional ni si ese catálogo ya se emitió.

## 4. LOTDA, Ley de Comercio Electrónico, Ley de Seguridad Social, COIP, Convenio de Budapest

### Takeaway
La LOTDA (2023) da la base legal del EGSI (arts. 7 lit. o y 20) y en 2026 recibió obligaciones de ciberseguridad. En el COIP, la ley de 2026 reformó el art. 232 para excluir las pruebas autorizadas, y una reforma integral del COIP sigue en trámite. Ecuador fue invitado al Convenio de Budapest en marzo de 2022 y la Comisión de Seguridad Integral recomendó ratificarlo en junio de 2024. No se confirmó el depósito del instrumento.

### Cited Findings
- LOTDA, arts. 7 lit. o) y 20: base legal citada para la obligatoriedad del EGSI en el sector público — [MINTEL PDF EGSI](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf)
- La Ley de Ciberseguridad de 2026 se describe como reforma a la LOTDA e incorpora obligaciones de ciberseguridad en la digitalización del Estado — [Lexis](https://www.lexis.com.ec/noticias/registro-oficial-del-dia-ley-organica-para-el-fortalecimiento-de-la-ciberseguridad); [dplnews](https://dplnews.com/entra-en-vigor-ley-de-ciberseguridad-en-ecuador/)
- COIP: la ley de 2026 añade un inciso al final del art. 232 (ataque a la integridad de sistemas informáticos) para que no sean delito el acceso, la prueba o la evaluación autorizados expresamente por el titular del sistema, como pruebas de penetración o auditorías éticas — [El Universo / búsqueda](https://www.eluniverso.com/noticias/politica/ley-fortalecimiento-ciberseguridad-registro-oficial-nota/); [dplnews](https://dplnews.com/entra-en-vigor-ley-de-ciberseguridad-en-ecuador/)
- Una reforma integral del COIP, que unifica más de 80 propuestas, pasó el primer debate en 2026. El segundo debate estaba previsto entre octubre y noviembre; su estado actual no se confirmó — [Asamblea Nacional](https://www.asambleanacional.gob.ec/es/node/117067); [Asamblea Nacional](https://www.asambleanacional.gob.ec/es/node/116955)
- Un proyecto aparte, la Ley de Violencia Digital, propone tipificar la falsificación informática (incluido el phishing y el pharming) en fraudes bancarios — [Primicias](https://primicias.ec/noticias/sociedad/reformas-coip-delitos-bancarios)
- Convenio de Budapest (ETS 185):
  - La Cancillería expresó en diciembre de 2021 el interés en adherirse, y el Comité de Ministros del Consejo de Europa invitó a Ecuador en marzo de 2022, con un plazo de cinco años para completar la adhesión — [Corte Constitucional](https://esacc.corteconstitucional.gob.ec/storage/api/v1/10_DWL_FL/e2NhcnBldGE6J3NvcnRlbycsIHV1aWQ6J2NhMjI4OTQwLTY5YTUtNDEzOC04MzI5LTYzN2FlYzZlMjZkZC5wZGYnfQ==)
  - El Presidente Noboa envió la solicitud a la Asamblea en enero de 2024, y la Comisión de Seguridad Integral recomendó al Pleno aprobar la ratificación en junio de 2024 — [Asamblea Nacional](https://www.asambleanacional.gob.ec/es/noticia/97216-comision-de-seguridad-integral-recomienda-al-pleno)
  - Una columna de El Comercio menciona una aprobación del Pleno con 85 votos, sin que la fecha conste en el extracto — [El Comercio](https://www.elcomercio.com/opinion/convenio-budapest-delitos-ciberneticos-lorena-naranjo-columnista/)
  - Ecuador también firmó la Convención de la ONU contra la Ciberdelincuencia — [Expreso](https://www.expreso.ec/actualidad/politica/ecuador-enfrenta-el-cibercrimen-con-leyes-desactualizadas-263158.html)

### Inferences
- El plazo de cinco años desde la invitación de marzo de 2022 vencería hacia marzo de 2027. Si Ecuador no ha depositado aún el instrumento, el trámite estaría en su fase final a la fecha de corte.
- Para el contenido de formación del IESS conviene explicar los delitos informáticos del COIP, la excepción de 2026 para pruebas autorizadas y el riesgo penal de la revelación indebida de datos, pero sin citar artículos hasta verificarlos.

### Gaps
- No se obtuvo el texto vigente de los arts. 229 (revelación ilegal de bases de datos), 230, 231, 232 y 234 del COIP. Tampoco hay datos sobre agravantes para servidores públicos.
- No se verificaron las fechas ni los artículos de la LOTDA (en general se cita el Suplemento del RO 245 de 7-feb-2023, pero no se confirmó en esta búsqueda) ni de la Ley de Comercio Electrónico, Firmas Electrónicas y Mensajes de Datos (2002) y sus reformas.
- No se encontraron disposiciones de la Ley de Seguridad Social sobre sigilo o confidencialidad de la información de afiliados. Hay que consultar el texto vigente de la Ley de Seguridad Social y la normativa interna del IESS (Consejo Directivo).
- Falta confirmar en la lista oficial del Consejo de Europa (treaty office) si Ecuador ya es Estado Parte del Convenio de Budapest. La página Octopus del Consejo de Europa devolvió 403.

## 5. DINARP y el Sistema Nacional de Registro de Datos Públicos

### Takeaway
La DINARP (antes DINARDAP) administra el Sistema Nacional de Registro de Datos Públicos y la interoperabilidad entre registros públicos, conforme a la Ley del Sistema Nacional de Registro de Datos Públicos. El IESS, como fuente o consumidor de datos interoperados, está sujeto a sus resoluciones de acceso y entrega de datos, que siguieron emitiéndose en 2025 y 2026.

### Cited Findings
- La ley creó la Dirección Nacional de Registro de Datos Públicos (DINARDAP) como organismo de derecho público encargado de la interoperabilidad de los registros — [UNEP LEAP](https://leap.unep.org/en/countries/ec/national-legislation/ley-del-sistema-nacional-de-registro-de-datos-publicos); [WIPO Lex](https://www.wipo.int/wipolex/en/legislation/details/18936)
- La última reforma del Reglamento a la Ley se publicó en el Segundo Suplemento del RO 651, 25-sep-2024 — [búsqueda / ESPOL](https://www.dspace.espol.edu.ec/bitstream/123456789/68372/1/REGLAMENTO%20A%20LA%20LEY%20DEL%20SISTEMA%20NACIONAL%20DE%20REGISTRO%20DE%20DATOS%20P%c3%9aBLICOS.pdf)
- Resoluciones de la DINARP: 003-NG-DINARP-2023 (entrega de datos); 003-NG-DINARP-2025 (acceso a fuentes de información del sistema); 004-NG-DINARP-2025 y 007-NG-DINARP-2025; documento DINARP-DNO-2026-02-01-01-07 (julio de 2026) — [Asobanca 2023](https://asobanca.org.ec/wp-content/uploads/2023/07/Resolucion-003-NG-DINARP-2023.-Entrega-de-Datos.pdf); [Asobanca 003-2025](https://asobanca.org.ec/wp-content/uploads/2025/03/Resolucion-No.-003-NG-DINARP-2025.pdf); [Asobanca 007-2025](https://asobanca.org.ec/wp-content/uploads/2025/06/Resolucion-No.-007-NG-DINARP-2025.pdf); [Asobanca 2026](https://asobanca.org.ec/wp-content/uploads/2026/07/DINARP-DNO-2026-02-01-01-07.pdf)
- El trámite de "aprobación de acceso y visualización de información de registros públicos a través de interoperabilidad" está en gob.ec — [gob.ec/dinarp](https://www.gob.ec/dinarp/tramites/aprobacion-acceso-visualizacion-informacion-registros-publicos-traves-interoperabilidad)

### Inferences
- El acceso de los servidores del IESS a datos interoperados (Registro Civil, por ejemplo) es un vector de riesgo de uso indebido. Los contenidos de formación deberían cubrir el uso solo para la finalidad autorizada y la trazabilidad de las consultas.

### Gaps
- No se leyó el contenido de las resoluciones de la DINARP de 2025 y 2026, ni se confirmó si la ley se reformó en 2025 o 2026.
- No se confirmó la relación formal entre el SISPDP de la SPDP y el sistema de la DINARP.

## 6. Accesibilidad e inclusión en servicios digitales

### Takeaway
Ecuador adoptó la NTE INEN-ISO/IEC 40500 (equivalente a WCAG 2.0) en 2014 y el reglamento técnico RTE INEN 288 de accesibilidad web, vigente desde 2016. Una solución digital del IESS, cuya población incluye una alta proporción de adultos mayores y personas con discapacidad, debería cumplirlo. No se verificaron las bases legales concretas en la Ley Orgánica de Discapacidades ni en la Ley Orgánica de las Personas Adultas Mayores.

### Cited Findings
- La NTE INEN-ISO/IEC 40500 se aprobó en el RO n.º 171 de 28-ene-2014 y adopta la ISO/IEC 40500:2012 (WCAG 2.0) — [Oficio Ministerio de Gobierno](https://www.ministeriodegobierno.gob.ec/wp-content/uploads/downloads/2015/12/Oficio-Nro.-STD-STD-2015-4841-OF.pdf)
- El reglamento técnico RTE INEN 288, "Accesibilidad para el contenido web", entró en vigor el 8-ago-2016 según un trabajo académico, que sostiene que obliga a instituciones públicas y privadas y a desarrolladores web — [Scielo Senescyt / Cátedra](https://scielo.senescyt.gob.ec/pdf/catedra/v2n2/2631-2875-catedra-2-02-00055.pdf)
- El cumplimiento real es bajo: un estudio de 2019 encontró que ninguno de 220 portales universitarios cumplía la NTE INEN-ISO/IEC 40500 — [RUA Universidad de Alicante, RISTI 2019](https://rua.ua.es/dspace/bitstream/10045/99754/1/2019_Campoverde-Molina_etal_RISTI.pdf)

### Inferences
- Los contenidos de concienciación (videos, módulos, simulaciones) deberían cumplir WCAG 2.0 AA como mínimo, con subtítulos, contraste, navegación por teclado y lenguaje claro, por el RTE INEN 288 y por el perfil de los usuarios del IESS (jubilados, afiliados con discapacidad).

### Gaps
- No se verificó el texto de la Ley Orgánica de Discapacidades (2012; se cita su art. 63 sobre accesibilidad a la comunicación) ni el de la Ley Orgánica de las Personas Adultas Mayores (2019) sobre servicios digitales.
- No se verificó si existe una versión más reciente del RTE INEN 288 o una adopción de WCAG 2.1 o 2.2.
- No se encontraron fuentes sobre derechos lingüísticos (kichwa, shuar) en servicios digitales públicos (arts. 2 y 57 de la Constitución, Ley de Comunicación). Queda como vacío.

## 7. Contratación pública (SERCOP / LOSNCP) y software público o libre

### Takeaway
La adquisición de una solución por el IESS se rige por la LOSNCP y su Reglamento, y en software por la prelación del art. 148 del Código Ingenios: el software libre y de código abierto y el de valor agregado ecuatoriano tienen prioridad sobre el propietario extranjero. Si el software es de código abierto, el art. 147 obliga a publicar su código fuente. El Decreto 1014 (2008) fija el software libre como política de la Administración Pública Central.

### Cited Findings
- Decreto Ejecutivo 1014, 10-abr-2008: establece el uso de software libre como política para las entidades de la Administración Pública Central. El software propietario solo se admite si no hay alternativa libre que cumpla los requisitos, si hay riesgo para la seguridad nacional o si el proyecto llegó a un punto de no retorno — [Gobierno Electrónico](https://www.gobiernoelectronico.gob.ec/wp-content/uploads/2018/09/Decreto-Ejecutivo-N%C2%B0-1014-del-10-de-abril-del-2008.pdf); [ASLE](https://www.asle.ec/marco-legal-del-softwarelibre-en-ecuador/)
- Código Ingenios, art. 148, "Prelación en la adquisición de software por parte del sector público" (cinco niveles de prelación). El Reglamento (Decreto 1073) crea el Portal Único de Software Ecuatoriano y da preferencia al software con valor agregado ecuatoriano (VAE). SERCOP emitió una metodología VAE para software (RE-SERCOP-2020-0107) — [SERCOP Metodología VAE](https://portal.compraspublicas.gob.ec/sercop/wp-content/uploads/2020/09/Metodologia-_VAE_Software.pdf); [RE-SERCOP-2020-0107](https://www.fielweb.com/App_Themes/InformacionInteres/RE-SERCOP-2020-0107.pdf)
- Código Ingenios, art. 147: las entidades deben publicar el código fuente del software de código abierto que contraten o desarrollen — [búsqueda SERCOP / Código Ingenios](https://portal.compraspublicas.gob.ec/sercop/wp-content/uploads/downloads/2021/02/Presentaci%C3%B3n-Webinar-Nueva-Metodolog%C3%ADa-para-calculo-de-VAE-.pdf)
- MINTEL aplica las prelaciones 1 a 5 del art. 148 en su procedimiento de aprobación de proyectos de gobierno electrónico y software para el sector público (procedimientos firmados en 2026) — [gob.ec MINTEL](https://www.gob.ec/sites/default/files/sign/procedure-MIT-065-01-01-2026111109099-20518994-signed.pdf)
- El IESS publica la LOSNCP en su portal de transparencia — [IESS](https://www.iess.gob.ec/documents/10162/36257100/8.+Ley+Organica+del+Sistema+Nacional+de+Contratacion+Publica)
- SERCOP lista un Decreto Ejecutivo n.º 461 (junio de 2026) en su normativa; no se verificó su contenido — [SERCOP](https://portal.compraspublicas.gob.ec/sercop/normativa/n_r_decretos/https-portal-compraspublicas-gob-ec-sercop-wp-content-uploads-2026-07-decreto-ejecutivo-no-461-20260629212208-pdf)

### Inferences
- Si la solución de cultura de seguridad se desarrolla como software libre o público, cumple mejor el art. 148 y el Decreto 1014 y puede reutilizarse en otras entidades. Si es propietaria, la entidad tendría que justificar que no hay alternativa en los niveles superiores de prelación. Además, los proyectos TIC suelen requerir la aprobación o el dictamen de MINTEL.
- Los contratos con proveedores que traten datos de servidores del IESS deben incluir las cláusulas de la Res. SPDP-SPD-2025-0006-R (sección 1).

### Gaps
- No se obtuvo la redacción literal de los cinco niveles de prelación del art. 148 del Código Ingenios (RO Supl. 899, 9-dic-2016, fecha no verificada en esta búsqueda).
- No se verificó la versión vigente de la LOSNCP y su Reglamento (reformas 2024-2026), ni el contenido del Decreto 461 de 2026.
- No se verificó si el IESS, como entidad autónoma, está dentro de la "Administración Pública Central" del Decreto 1014. Probablemente sí está dentro del Código Ingenios, que alcanza a todo el sector público.
