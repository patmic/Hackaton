---
tags: [investigacion, criterios, requisitos]
fuente: "[[Informe completo]]"
fecha: 2026-11-25
---

↑ [[Indice Investigacion]]

# 09 Criterios de diseno

## En pocas palabras
- Son criterios de evaluación que salen de la investigación y no dependen de la solución elegida. No son una propuesta.
- El daño grave ocurre cuando una credencial delegada o un rol abusado permite cambiar datos y mover dinero; el clic es solo una vía de entrada.
- La medición forma parte del diseño, no es un añadido.
- La inclusión es condición de entrada: limitaciones funcionales, mala conexión rural, analfabetismo indígena y apagones.

## Tres premisas del informe
| Premisa | Base |
|---|---|
| Entender qué problema se ataca: enseñar solo a «no hacer clic» se queda corto, e ignorar la dimensión interna (servidores con acceso, intermediarios, ética del dato) deja fuera la mitad de los casos documentados | [[02 Amenazas y fraude en Ecuador]] |
| La medición es parte del diseño: la DNSIPD pide gestión «medible», la evidencia desaconseja la tasa de clic bruta y el EGSI exige evidencia periódica | [[01 Perfiles y canales del IESS]]; [[07 Evidencia cientifica]]; [[04 Marco legal]] |
| La inclusión es condición de entrada: un tercio de los mayores tiene limitaciones funcionales, el mundo rural tiene peor conexión, el analfabetismo indígena triplica el nacional (no se obtuvo la cifra de hablantes de lenguas originarias) y el país sufrió apagones de 14 horas | [[03 Factores socioeconomicos]] |

Nota del informe sobre el alcance: el Reto 1 trata de cultura y otros retos del hackatón abordan fraude, protección de datos e incidentes; el reto ganador probablemente tendrá que mostrar cómo la cultura modifica conductas observables en ambos frentes sin duplicar a los demás.

## Criterios (tabla del informe)
| Criterio | Por qué (evidencia) | Cómo podría demostrarse en la final con escenarios ficticios |
|---|---|---|
| Atacar conductas y momentos de riesgo concretos (compartir la clave, cambio de contacto o cuenta, mensajes con marca IESS, uso indebido de accesos), no «conciencia» genérica | Los fraudes documentados siguen la secuencia credencial, cambio de datos y cobro ([Expreso](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html)) | Recorrer un caso ficticio de principio a fin y mostrar en qué punto actúa la solución |
| Distinguir públicos (servidores asistenciales y administrativos, afiliados activos, jubilados urbanos y campesinos, migrantes, prestadores) y no ofrecer un único mensaje | La exposición y las capacidades difieren mucho ([IESS](https://www.iess.gob.ec/documents/10162/39150634/Informe+Rendicion+de+Cuentas+2025); [INEC](https://www.ecuadorencifras.gob.ec/tecnologias-de-la-informacion-y-comunicacion-tic-2024/)) | Personas ficticias con trayectorias distintas |
| Incluir el riesgo interno y la ética del acceso para los servidores | Casos de 2024 y 2025 en el IESS; IMSS ([Primicias](https://www.primicias.ec/economia/iess-denuncia-falsificacion-aportes-jubilacion-fiscalia-110018/)) | Escenario de un servidor presionado o tentado y la respuesta prevista |
| Favorecer el reporte y la retroalimentación rápida por encima de la evaluación individual del clic | Lain et al. y Ho et al. ([arXiv](https://arxiv.org/abs/2112.07498)) | Métrica de reporte y tiempo hasta el primer reporte en la demostración |
| Usar práctica activa con ejemplos reales y legítimos (inoculación) y refuerzos periódicos, no material estático | AARP, Boston College, estudios de decaimiento ([AARP](https://www.aarp.org/money/scams-fraud/info-2022/social-security-scams-studies.html); [PMC11897321](https://pmc.ncbi.nlm.nih.gov/articles/PMC11897321/)) | Calendario de refuerzos y prueba de que no aumenta la desconfianza en los mensajes legítimos |
| Mensajes centrados en la eficacia («qué hacer y que es fácil») y en reducir decisiones, sin apelar solo al miedo | Metaanálisis de la Teoría de Motivación de Protección; fatiga de seguridad ([JMIS](https://www.jmis-web.org/articles/1641); [NIST](https://www.nist.gov/news-events/news/2016/10/security-fatigue-can-cause-computer-users-feel-hopeless-and-act-recklessly)) | Ejemplos de mensajes con una sola acción clara |
| Cultura justa: no sancionar por fallar una simulación, agradecer el reporte incluso tardío y pactarlo con los sindicatos | CREST y USEC 2025 ([CREST](https://www.crestresearch.ac.uk/resources/phishing-your-staff/)) | Regla de no sanción explícita en la gobernanza propuesta |
| No convertir «conocer mis datos» en prueba de legitimidad, y enseñar que el estafador puede conocerlos | Novaestrat, Registro Civil 2026, ANSES ([Infobae](https://www.infobae.com/america/america-latina/2026/05/06/casi-15-millones-de-datos-de-identidad-de-ecuatorianos-aparecieron-en-redes-y-foros-clandestinos-autoridades-investigan-una-nueva-filtracion-masiva/)) | Escenario en el que el estafador cita datos reales ficticios |
| Que la propia solución no pueda ser imitada por estafadores: canales verificables, sin pedir claves ni enviar enlaces de cobro, coherente con los mensajes oficiales | Phishing con marca IESS; multiplicidad de canales ([Lupa Media](https://lupa.com.ec/verificaciones/iess-sms-reembolso-estafa/)) | Modelado de amenazas STRIDE de la propia solución |
| Privacidad desde el diseño conforme a la LOPDP: minimización, seudonimización de métricas, base legal, evaluación de impacto si corresponde, IA conforme a la Res. 2026-0009-R | LOPDP y resoluciones de la SPDP ([advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/)) | Análisis LINDDUN y flujo de datos sin datos reales |
| Accesibilidad WCAG 2.2 AA, lenguaje llano, alternativas de audio o presenciales, consideración de lenguas originarias | RTE INEN 288; 30 % de los mayores con dificultad funcional; analfabetismo indígena del 11,9 % ([INEC](https://www.ecuadorencifras.gob.ec/mas-de-2-700-personas-son-centenarias-en-ecuador-segun-el-censo/)) | Revisión de accesibilidad y prueba con un usuario que simule baja visión o motricidad |
| Resiliencia ante baja conectividad y apagones: liviana, asíncrona, con camino sin conexión o en agencias y salas de espera | Cortes de 14 h en 2024; brecha rural ([Primicias](https://primicias.ec/noticias/economia/telefonia-celular-internet-movil-cortes-luz-ecuador)) | Demostración en modo degradado |
| Medición seria: línea base, grupo de comparación, métricas de reporte, clic ajustado por dificultad, instrumento validado y salud del programa (percepción de justicia) | Ho et al., NIST Phish Scale, HAIS-Q, ENISA ([NIST](https://csrc.nist.gov/pubs/tn/2276/final)) | Tablero con métricas definidas y método de evaluación de 90 días |
| Encaje institucional: alimentar el Plan de Cultura 2026, los informes del OSI y del Comité, el ciclo anual del EGSI y los canales existentes del IESS, sin crear islas | EGSI v3; evidencia de continuidad de hackatones ([MINTEL](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf); [NSF PAR](https://par.nsf.gov//servlets/purl/10341999)) | Mapa de integración con procesos y responsables |
| Sostenibilidad: costo total de propiedad a 3-5 años (mensajería, hosting, contenidos, mantenimiento, evaluación), viable por convenio o ínfima cuantía, con software libre y propiedad intelectual definida | Restricciones de SERCOP, Código Ingenios, precios de WhatsApp ([Meta](https://developers.facebook.com/documentation/business-messaging/whatsapp/pricing)) | Estimación del costo total y ruta de contratación |
| Seguridad del propio software: SDLC mínimo (revisión de código, análisis de dependencias, gestión de secretos), alineado con SSDF y SAMM | Exigencia de la DNSIPD y del rector ([NIST SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final)) | Evidencia en el repositorio |
| Demostrable en 10 minutos con escenarios ficticios, sin datos reales ni acceso a sistemas en operación | Reglas del hackatón ([IT Ahora](https://itahora.com/2026/11/18/codigo-confianza-2026-parte-de-la-estrategia-preventiva-del-iess/)). El formato de 10 minutos **no está confirmado en fuentes públicas** | Datos sintéticos y plan B grabado |
| Honestidad sobre los límites: lo que la cultura no resuelve (autenticación de un solo factor, controles del BIESS) se nombra y se deriva a quien corresponde | La cultura no compensa procesos débiles (Singapur, Estonia, Brasil) ([RIA](https://www.ria.ee/en/surge-scams-costs-estonian-people-29-million-euros)) | Sección explícita de supuestos y dependencias |

## Relacionadas
[[07 Evidencia cientifica]] · [[08 Vision PMI e ingenieria]] · [[10 Preguntas abiertas]]
