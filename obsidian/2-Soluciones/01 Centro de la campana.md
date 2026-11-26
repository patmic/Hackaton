---
tags: [soluciones, centro, concienciacion, plataformas, hackaton]
fuente: "[[Mapa de soluciones completo]]"
fecha: 2026-11-25
---

↑ [[Indice Soluciones]]

# 01 Centro de la campana

## En pocas palabras
- Cuanto más cerca del centro está una solución, menos efecto medido tiene: cumple la norma y se demuestra con facilidad, pero casi no mueve conducta.
- Las plataformas comerciales venden el mismo paquete; para el IESS costarían entre USD 640.000 y 2 millones al año (**cálculo propio**).
- La campaña «nunca te pediremos la clave» es idéntica en toda la región y el material escrito no tuvo efecto en el ensayo SSA/AARP.
- Los ganadores de hackatón siguen cuatro plantillas, sin métricas, y solo cerca del 5 % de los proyectos sigue activo a los cinco meses.
- La higiene técnica (DMARC, aviso al canal anterior, segundo canal) funciona, pero no diferencia una propuesta.

## Plataformas comerciales
| Dato | Detalle | Fuente |
|---|---|---|
| Paquete base | Biblioteca de microcursos, simulaciones con plantillas, botón de reporte, capacitación al fallar y tablero de clics y reportes | KnowBe4, Proofpoint, Hoxhunt, SoSafe, Microsoft Attack Simulation Training, Cofense, Terranova, Kaspersky ASAP |
| Categoría | Gartner la trata como categoría propia; KnowBe4 y Proofpoint, proveedores representativos | [KnowBe4](https://blog.knowbe4.com/gartner-recognizes-knowbe4-as-a-representative-vendor-for-security-awareness-training-program-platforms) |
| Precio de lista KnowBe4 | USD 2,40 a 3,75 por usuario y mes, contratos de tres años, bandas pequeñas | [KnowBe4 pricing](https://knowbe4.com/pricing-security-awareness-training) |
| Precio en G2 | Ediciones entre USD 1,70 y 2,65 | [G2](https://g2.com/products/knowbe4-security-awareness-training/pricing) |
| Microsoft | Exige licencia E5 o Defender Plan 2 por cada usuario simulado | [Microsoft Learn](https://learn.microsoft.com/en-us/answers/questions/5291210/do-all-users-need-plan-2-to-run-attack-simulation) |
| Costo para el IESS | Unos 33.500 servidores a USD 1,6-5 por usuario y mes: **entre USD 640.000 y 2 millones al año**. **Cálculo propio** a precio de lista, sin cotización | Informe |
| Cifra de efecto que circula | «−79 % de vulnerabilidad al phishing tras un año»: benchmark del propio proveedor sin grupo de control. **Autoinformado** | [Nota de prensa KnowBe4](https://laopinion.com/latinowire/un-estudio-de-knowbe4-revela-que-la-vulnerabilidad-al-phishing-a-nivel-mundial-se-reduce-un-79-tras-un-ano-de-formacion-en-concienciacion-sobre-seguridad/) |
| Clientes en Ecuador | No se encontró ningún cliente gubernamental ecuatoriano | Informe |
| Alternativa «gratis» | GoPhish, kit de INCIBE, curso en Moodle y talleres del ministerio rector. Cero en licencias; el gasto pasa a horas de la DNSIPD y hereda las mismas limitaciones | [GoPhish](https://github.com/gophish/gophish); [INCIBE](https://www.incibe.es/empresas/blog/actualizate-ciberseguridad-el-nuevo-kit-concienciacion) |

## Lo que mide la evidencia sobre ese paquete
| Estudio | Hallazgo | Fuente |
|---|---|---|
| Ho et al., IEEE S&P 2025 (19.789 empleados de UC San Diego Health) | Sin relación entre capacitación anual y clic; la embebida redujo el fallo unos 2 puntos; **el fallo varió entre 1,82 % y 30,80 % según el señuelo**, lo que vuelve engañoso un tablero de clic sin ajuste | [Ho et al.](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf) |
| Lain, Kostiainen y Čapkun | La capacitación embebida, tal como la aplica la industria, no aumenta la resiliencia y puede tener efectos adversos | [arXiv 2112.07498](https://arxiv.org/abs/2112.07498) |
| Sanción por fallar | Reduce la aceptación de las simulaciones y se percibe como injusta | [USEC 2025](https://ndss-symposium.org/wp-content/uploads/usec25-10.pdf); [CREST](https://www.crestresearch.ac.uk/resources/phishing-your-staff/) |
| Cobertura | Ninguna plataforma cubre al afiliado o al jubilado ni aborda el préstamo de la clave a un tercero | Informe |

## Campaña ciudadana por defecto
| Dato | Detalle | Fuente |
|---|---|---|
| Fórmula | «La institución nunca te pedirá tu clave ni datos bancarios», lista de canales y canal de denuncia | Informe |
| Quién la usa | IESS; SRI (con lista de dominios autorizados, el patrón de verificación más concreto del país); ANSES; IMSS; Colpensiones; ChileAtiende | [Expreso](https://www.expreso.ec/actualidad/economia/prevenir-suplantacion-identidad-iess-entidades-241961.html); [El Diario, SRI](https://www.eldiario.ec/ecuador/sri-alerta-sobre-correos-llamadas-y-sitios-falsos-que-buscan-datos-de-contribuyentes-11022026/); [Ámbito, ANSES](https://www.ambito.com/informacion-general/advertencia-anses-estafas-que-hacer-estos-casos-y-como-prevenirlas-n6296806); [El Imparcial, IMSS](https://www.elimparcial.com/mexico/2026/03/15/imss-alerta-sobre-fraude-contra-pensionados-asi-operan-los-falsos-tramites-para-aumentar-la-pension/) |
| Cómo opera | Se reactiva con cada modalidad nueva, depende de la prensa y llega tarde: pese a los avisos siguieron los préstamos fraudulentos a jubilados de hasta USD 30.000 | [Primicias](https://primicias.ec/sociedad/jubilados-denuncian-suplantacion-identidad-prestamos-quirografarios-guayaquil-85104) |
| Ensayo SSA/AARP (Robb y Wendel, 4.164 participantes) | **Los consejos escritos y los materiales de aviso existentes de la SSA no tuvieron efecto significativo**; solo funcionó el entrenamiento interactivo | [PMC9786522](https://pmc.ncbi.nlm.nih.gov/articles/PMC9786522) |
| Kenia | Los consejos habituales («errores ortográficos, remitente desconocido, enlace acortado») no mejoraron la detección, aumentaron la desconfianza en mensajes legítimos y la confianza en respuestas igual de imprecisas | [VoxEU/CEPR](https://cepr.org/voxeu/columns/financial-fraud-developing-countries-common-scam-detection-tips-do-not-help) |
| Hueco | El mensaje no cubre el caso documentado en el IESS: el propio afiliado entrega la clave a un familiar o tramitador | Informe |

## Plantillas de los ganadores de hackatón (2022-2026)
| Plantilla | Ejemplos | Fuente |
|---|---|---|
| Detector de phishing (extensión o filtro, cada vez más con LLM) | CiberUGR-INCIBE 2025 premió un estimador de seguridad del dispositivo y un sistema anti-phishing, igual que en 2024 | [CiberUGR](https://catedras.ugr.es/ciberugr-incibe/informacion/noticias/retomayo2025) |
| «App integral de protección» | «Guardian App», ganadora en Perú | [UCH](https://www.uch.edu.pe/noticias/uch-triunfa-en-hackaton-de-ciberseguridad-con-propuesta-que-enfrenta-los-fraudes-digitales-en-el-peru/403) |
| Chatbot o clasificador de mensajes con lectura en voz para mayores | Clones casi idénticos en Devpost: PhisherCatcher, Safely, ScamShield v4 (clasifica con la API de Claude), ScamShield Seniors | [ScamShield v4](https://devpost.com/software/scamshield-v4); [ScamShield Seniors](https://devpost.com/software/scamshield-seniors) |
| Juego o quiz | Formato habitual | Informe |

| Límite | Dato | Fuente |
|---|---|---|
| Métricas y alcance | Ninguno publica métricas ni ataca el cambio de datos o el actor interno | Informe |
| Supervivencia | Cerca del **5 % de los proyectos de hackatón sigue activo cinco meses después** | [Nolte et al.](https://par.nsf.gov/servlets/purl/10284449) |
| Clasificadores con LLM | El usuario acepta más la respuesta cuando suena segura, acierte o no | [arXiv 2505.03179](https://arxiv.org/html/2505.03179v1) |
| Juegos | El formato de juego deja de tener efecto significativo a los 9 días | [PMC11897321](https://pmc.ncbi.nlm.nih.gov/articles/PMC11897321/) |

## Higiene técnica del centro
Controles baratos que funcionan, pero son higiene técnica y no cultura. Sirven como requisitos previos; no diferencian una propuesta.

| Control | Dato | Fuente |
|---|---|---|
| DMARC en p=reject | Bloqueó unos **500 millones de correos** que suplantaban a HMRC. Estado de DMARC de iess.gob.ec **sin verificar** | [ITPro](https://www.itpro.com/scams/31432/hmrc-takes-down-record-number-of-malicious-websites-in-scam-crackdown) |
| Aviso al canal anterior ante un cambio de datos | Práctica bancaria; el IESS ya lo hace con el correo desde mayo de 2025 | [Expreso, 12-05-2025](https://www.expreso.ec/actualidad/economia/jimena-naranjo-iess-lanzara-nuevo-sistema-suplantacion-242078) |
| Verificación por segundo canal | Devolver la llamada a un número de directorio; buena práctica estándar contra el fraude del CEO | Informe |

## Ocho piezas del centro que conviene no presentar solas
| Pieza del centro | Por qué el jurado ya la vio | Qué dice la evidencia | Qué la sacaría del centro |
|---|---|---|---|
| Curso anual en IESSEDUCA, talleres MINTEL u OEA, kits INCIBE | Es la evidencia estándar del plan de concienciación del EGSI | Sin relación con el clic (Ho et al.) | Formación por rol con análisis de necesidades (modelo NHS DSPT) |
| Simulación de phishing con capacitación embebida | Es el producto de todos los proveedores y de GoPhish | ≈2 pp; posible efecto adverso (Lain et al.) | Medir reporte y tiempo hasta el reporte, ajustar por dificultad con NIST Phish Scale |
| Tablero de % de clic y % de cursos completados | Es lo que muestra cualquier plataforma | La tasa depende del señuelo (1,82-30,8 %) | Tablero de tres capas: conducta, proceso y percepción |
| Sanción por fallar | Práctica frecuente | Reduce aceptación y reporte | Cultura justa pactada con sindicatos |
| Comunicado «nunca te pediremos la clave» | Lo emite cada instituto de la región | Material escrito sin efecto (SSA/AARP); consejos de señales empeoran la calibración (Kenia) | Inoculación interactiva con refuerzos y reglas institucionales que existen de verdad |
| Detector o extensión de phishing | Ganador recurrente desde 2024 | Sin métricas; requiere PC o smartphone | Solo como pieza secundaria de otra solución |
| Chatbot «¿es estafa?» con LLM genérico | Decenas de clones en Devpost | Sobreconfianza; sin exactitud publicada | Canal oficial verificado, registro de envíos oficiales y conexión con bloqueo |
| Juego, quiz o «app integral» | Formato habitual de hackatón | Ganancia de conocimiento que decae en días | Juego de voz narrativo con refuerzo (modelo Uganda) |

## Relacionadas
[[07 Tabla maestra]] (C1 a C13) · [[06 Atipicos negativos y lineas rojas]] · [[centro_soluciones_estandar]] · [[07 Evidencia cientifica]]
