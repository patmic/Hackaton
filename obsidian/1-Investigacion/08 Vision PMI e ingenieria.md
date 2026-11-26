---
tags: [investigacion, pmi, interesados, riesgos, ingenieria]
fuente: "[[Informe completo]]"
fecha: 2026-11-25
---

↑ [[Indice Investigacion]]

# 08 Vision PMI e ingenieria

## En pocas palabras
- Solo alrededor del 5 % de los proyectos de hackatón sigue activo cinco meses después: la adopción se decide antes de la final.
- La continuidad mejora con patrocinio y compromiso financiero previos y cuando se agrega valor a un servicio existente.
- Hay muchos interesados con poder desigual; DNSIPD, Delegado de Protección de Datos, DNTI y BIESS pueden habilitar o bloquear.
- Restricciones duras: sin datos reales, contratación limitada, baja ejecución presupuestaria, costo de mensajería e inestabilidad directiva.

## Marco de gestión
| Referencia | Contenido | Fuente |
|---|---|---|
| PMBOK 8.ª edición (noviembre de 2025) | Seis principios, entre ellos foco en el valor y sostenibilidad; siete dominios: gobernanza, alcance, cronograma, finanzas, interesados, recursos y riesgo | [PMI](https://www.pmi.org/standards/pmbok/about) |
| Modelo de prominencia (Mitchell, Agle y Wood) | Clasifica interesados por poder, legitimidad y urgencia | [DOI 10.5465/amr.1997.9711022105](https://doi.org/10.5465/amr.1997.9711022105) |

Por qué importa según el informe: el valor de una solución de cultura depende de la conducta de personas que no la encargaron.

## Mapa de interesados
> **Inferencia del informe, debe validarse con la DNSIPD.**

| Interesado | Poder | Interés | Qué le importa | Riesgo si se le ignora |
|---|---|---|---|---|
| Consejo Directivo y Dirección General | Alto | Medio | Reputación, cumplimiento, costo | Pérdida de patrocinio con la rotación (tres directores generales en 2025) |
| DNSIPD y OSI | Alto | Alto | Plan de Cultura 2026, informes del EGSI, métricas | Solución que no alimenta sus informes |
| Delegado de Protección de Datos | Medio-alto | Alto | Base legal, evaluación de impacto, minimización | Veto por tratamiento de datos de servidores o afiliados |
| DNTI | Alto | Medio | Integración, carga operativa, sistemas heredados | Nadie opera la solución tras el hackatón |
| Talento Humano y Comunicación Social | Medio | Medio | Inducción, plan de capacitación, marca institucional | Mensajes contradictorios o canales no oficiales |
| Servidores y sindicatos | Medio colectivo | Alto | Que no sea vigilancia ni sanción, carga de trabajo | Rechazo y supresión del reporte |
| Afiliados, jubilados, campesinos, migrantes | Bajo individual | Alto | Proteger su pensión y sus fondos, facilidad | Exclusión de los más vulnerables |
| BIESS | Alto | Alto | Préstamos quirografarios, fraude crediticio | Controles fragmentados entre IESS y BIESS |
| SPDP, DINARP, MINTEL/MIT, Contraloría, SERCOP | Alto (regulador) | Medio | Legalidad, interoperabilidad, viabilidad técnica, gasto | Bloqueo normativo o de contratación |
| Operadoras, proveedores de WhatsApp Business, EcuCERT, banca y cooperativas | Medio | Medio | Costos, reglas de remitentes, coordinación | Canales imitables y sin capacidad de derribo |
| Universidades y equipo del hackatón | Bajo | Alto | Reconocimiento, continuidad, propiedad intelectual | Se disuelve el equipo y se abandona el código |

## Qué miraría cada miembro del panel
> **Inferencia condicionada:** solo vale si la composición del panel aportada por quien encargó el estudio es correcta (no confirmada en fuentes públicas).

| Entidad | Foco probable |
|---|---|
| SPDP | Privacidad y base legal |
| DINARP | Uso de datos públicos e interoperables |
| DAMA Ecuador | Gobierno y calidad de los datos |
| ISACA Quito | Riesgo, control y auditabilidad |
| DNSIPD | Encaje con su plan |
| Universidades | Rigor metodológico |

Coincide con los criterios publicados por IT Ahora: utilidad, seguridad, privacidad, sostenibilidad, capacidad de responder al problema y viabilidad técnica y funcional ([IT Ahora](https://itahora.com/2026/11/18/codigo-confianza-2026-parte-de-la-estrategia-preventiva-del-iess/)). Ver [[Lo que se sabe del reto]].

## Restricciones
| Restricción | Dato | Marca | Fuente |
|---|---|---|---|
| Datos y sistemas | El prototipo no puede usar datos reales ni tocar sistemas en operación | Confirmado | [IT Ahora](https://itahora.com/2026/11/18/codigo-confianza-2026-parte-de-la-estrategia-preventiva-del-iess/) |
| Contratación: ínfima cuantía | 0,0000002 veces el Presupuesto Inicial del Estado: alrededor de USD 7.200 en 2025 | **Cálculo propio** del informe a partir de una guía de SERCOP | [PGE](https://biblioteca.pge.gob.ec/images/2023/INFOGRAFIAS_REFLEXIONES/OCTUBRE/Infografia%20-%20Infima_v3_compressed.pdf); [SERCOP](https://portal.compraspublicas.gob.ec/sercop/wp-content/uploads/2025/09/guia_fundamentos-signed-signed-signed.pdf) |
| Contratación: consultorías | La Ley de Integridad Pública exigiría concurso para consultorías de más de USD 10.000 | **No verificado** | [Primicias](https://www.primicias.ec/politica/ley-integridad-publica-contratacion-compras-publicas-sercop-ecuador-99467/) |
| Ejecución | El IESS ejecutó solo el 65,17 % de su Plan Anual de Contratación en 2025 | | [IESS, Rendición de Cuentas 2025](https://www.iess.gob.ec/documents/10162/39150634/Informe+Rendicion+de+Cuentas+2025) |
| Costo de canales | WhatsApp Business cobra por mensaje desde el 1 de julio de 2025; las plantillas de utilidad dentro de la ventana de 24 horas volvieron a cobrarse el 1 de octubre de 2026 | | [Meta for Developers](https://developers.facebook.com/documentation/business-messaging/whatsapp/pricing); [WATI](https://support.wati.io/en/articles/11561662-message-based-pricing-all-you-need-to-know) |
| Inestabilidad | Tres directores generales en 2025 y cambios en la presidencia del Consejo Directivo | | Informe |

## Registro de riesgos (tabla del informe)
| Riesgo (causa, evento, efecto) | Probabilidad | Impacto | Respuesta esperable en el diseño (según el informe) |
|---|---|---|---|
| Cambio de autoridades, pérdida del patrocinador y prototipo huérfano | Alta | Alto | Anclaje en un instrumento formal (Plan de Cultura, EGSI) y responsable con suplente |
| Medición de servidores sin base legal y observación de la SPDP | Media | Alto | Minimización, seudonimización, evaluación de impacto e intervención temprana del DPD |
| Percepción de vigilancia o castigo, rechazo sindical y caída del reporte | Media | Alto | Regla pública y pactada de no sanción por resultados de simulación |
| Canal de la solución imitado por estafadores y nuevo vector de fraude | Media | Alto | Canales verificables y regla de «nunca pedimos claves ni enviamos enlaces» coherente con la solución |
| Apagones o mala conectividad y servicio inservible para los más vulnerables | Media | Medio | Diseño liviano, asíncrono, con alternativa sin conexión o presencial |
| Costo recurrente sin partida y suspensión del servicio | Alta | Medio | Estimación del costo total de propiedad desde el pitch |
| Fatiga de mensajes y habituación | Alta | Medio | Pocos mensajes, oportunos y ligados a eventos de riesgo |
| Equipo voluntario disuelto y código sin mantenimiento | Alta | Alto | Código publicado, documentación y traspaso a un responsable del IESS |

## Qué dice la literatura sobre hackatones
| Hallazgo | Cifra | Fuente |
|---|---|---|
| Proyectos activos tras cinco meses | Alrededor del 5 % | [Nolte et al., NSF PAR](https://par.nsf.gov/servlets/purl/10284449) |
| Código escrito durante el evento | 9,14 % (el resto se reutiliza) | [Springer EMSE](https://link.springer.com/content/pdf/10.1007/s10664-022-10201-x.pdf) |
| Valor principal en hackatones cívicos | La relación institución y comunidad, más que el prototipo | [Public Management Review](https://ideas.repec.org/a/taf/rpxmxx/v23y2021i4p523-544.html) |
| Riesgo institucional | Posible «puerta trasera» de la contratación pública, con tensiones entre innovación y participación (Johnson y Robinson) | [Review of Policy Research](https://econpapers.repec.org/RePEc:bla:revpol:v:31:y:2014:i:4:p:349-357) |
| Factores de continuidad | Compromiso financiero y patrocinio antes del evento; agregar valor a un servicio existente en lugar de crear uno aislado | [NSF PAR](https://par.nsf.gov//servlets/purl/10341999) |

## Marcos de ingeniería verificables
| Marco | Uso | Fuente |
|---|---|---|
| NIST SSDF (SP 800-218) | Desarrollo seguro | [NIST SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final) |
| OWASP SAMM | Madurez de seguridad del software | [OWASP SAMM](https://owaspsamm.org/model/) |
| STRIDE | Amenazas de seguridad | Informe |
| LINDDUN | Amenazas de privacidad | [LINDDUN](https://linddun.org/) |
| WCAG 2.2 AA | Accesibilidad; incluye tamaño mínimo de objetivo y autenticación accesible, útiles para personas mayores | [W3C WCAG 2.2](https://www.w3.org/TR/WCAG22/) |
| ADKAR y 8 pasos de Kotter | Gestión del cambio, complementarios. **Fuentes canónicas no revisadas** en la investigación | [Prosci](https://www.prosci.com/methodology/adkar); [Kotter](https://www.kotterinc.com/methodology/8-steps/) |

## Caso de negocio: cifras con cautela
| Dato | Cifra | Fuente |
|---|---|---|
| Costo medio de brecha en salud | USD 7,42 millones en 2025, con 279 días para identificar y contener | [TechTarget](https://www.techtarget.com/healthtechsecurity/news/366628031/Healthcare-remains-costliest-industry-for-breaches-at-742M) |
| Costo medio de brecha en salud | USD 6,64 millones en 2026 | [Becker's](https://beckershospitalreview.com/healthcare-information-technology/cybersecurity/healthcare-data-breaches-cost-6-64m-on-average-report) |
| Costo para las víctimas del IESS | Deudas de USD 9.000 a 30.550 por jubilado, acciones de protección, intervención de la Defensoría y deterioro reputacional | Informe (ver [[02 Amenazas y fraude en Ecuador]]) |

> **Solo orden de magnitud.** Las cifras de brechas vienen sobre todo de empresas privadas de otros países; Ecuador no está en la muestra de IBM y los promedios para América Latina se contradicen entre fuentes.

## Relacionadas
[[04 Marco legal]] · [[09 Criterios de diseno]] · [[Lo que se sabe del reto]]
