---
tags: [soluciones, convergentes, personal, riesgo-interno, cultura-justa, medicion]
fuente: "[[Mapa de soluciones completo]]"
fecha: 2026-11-25
---

↑ [[Indice Soluciones]]

# 03 Convergentes internas

## En pocas palabras
- Para el personal, la convergencia premia el reporte y el aviso inmediato no punitivo.
- El botón de reporte tiene la mejor evidencia de campo: 1.543 empleados reportaron 4.075 correos en 15 meses (Lain et al.).
- Un correo esa misma noche bajó la reincidencia de accesos indebidos de 40 % a 1,8 % (un ensayo, con **discrepancia** de diseño).
- Contra el servidor con acceso pesan más los controles de proceso (doble control, recertificación, baja oportuna) que la conciencia.
- La medición converge en un tablero de tres capas y la gobernanza, en una cultura justa; la IA sirve más para explicar que para simular.

## Botón de reporte
| Dato | Detalle | Fuente |
|---|---|---|
| Estudio de Lain et al. | Más de 14.000 empleados, 15 meses; el 32,10 % hizo clic en al menos un phishing | [ar5iv 2112.07498](https://ar5iv.labs.arxiv.org/html/2112.07498) |
| Reporte | De unos 6.300 empleados con botón, **1.543 reportaron al menos un correo y en total reportaron 4.075** | Ídem |
| Conclusión de los autores | La detección colectiva identifica rápido las campañas nuevas, con carga operativa aceptable y empleados activos durante mucho tiempo | Ídem |
| Métricas propuestas por Hoxhunt | Tasa de reporte, tiempo hasta el reporte, omisión y reincidencia en lugar de finalización o clic. **Discrepancia**: sus metas se contradicen (más de 20 % en un documento, al menos 70 % en otro) | [Hoxhunt](https://hoxhunt.com/blog/how-do-you-prove-security-awareness-is-working); [Hoxhunt, métricas](https://hoxhunt.com/guide/security-awareness-training-metrics) |
| Costo en el IESS | El IESS migró su correo a Google Workspace; la función nativa de reporte cuesta poco. **Inferencia** | Informe |
| Encaje | Métrica agregada, compatible con la LOPDP y aceptable para los sindicatos; extensible a «reportar un pedido raro» (un tramitador que pide cambiar una cuenta), lo que lo conecta con EI | Informe |

## Referentes de seguridad («security champions»)
| Dato | Detalle | Fuente |
|---|---|---|
| Evidencia | Práctica extendida; evidencia de resultado casi solo de informes de experiencia | Informe |
| OWASP | Documenta un fracaso: el programa existía para mostrar avances | [OWASP](https://securitychampions.owasp.org/assets/artifacts/Security%20Champions%20Guide%20-%20Secure%20management%20support%20-%20Four%20Approaches%20to%20Security%20Champions%20Programs.pdf) |
| LinkedIn | Formó más de 50 referentes sin publicar resultados | Informe |
| Forrester | Los roles poco claros sobrecargan a los referentes | [Forrester](https://www.forrester.com/blogs/four-things-you-should-know-about-security-champions-networks-but-probably-dont/) |
| Riesgo en el IESS | En 102 unidades médicas con personal bajo presión, crear una carga sin reconocimiento | Informe |

## Aviso inmediato tras un acceso indebido
| Dato | Detalle | Fuente |
|---|---|---|
| Diseño | Centro médico académico de EE. UU.: 444 empleados marcados por acceder a historias clínicas sin motivo laboral; 219 recibieron esa misma noche un correo que indicaba que el acceso violaba la privacidad; 225 de control, sin correo | [HIPAA Journal](https://www.hipaajournal.com/on-the-spot-email-interventions-reduce-repeat-medical-record-snooping-incidents-by-95/) |
| Resultado | Reincidencia entre 20 y 70 días: **4/219 (1,8 %) frente a 90/225 (40 %)**, sin sanción disciplinaria durante el ensayo | Ídem |
| **Discrepancia** de diseño | El título dice «no aleatorizado» y el registro NCT05251844 lo lista como aleatorizado; los autores advierten que puede no generalizarse | [ClinicalTrials.gov](https://clinicaltrials.gov/study/NCT05251844) |
| Auditoría basada en explicaciones | En la Universidad de Michigan, plantillas descubiertas automáticamente explicaron **más del 94 % de los accesos** (cita, turno o trámite) en un sistema con más de 4 millones de registros semanales; reduce falsos positivos | [arXiv 1109.6880](https://arxiv.org/pdf/1109.6880) |
| «Romper el cristal» | Justificación obligatoria, estándar en historia clínica; un estudio en Ámsterdam muestra que separar lo legítimo de lo ilegítimo es difícil | [IGI Global](https://www.igi-global.com/gateway/article/208128) |
| Encaje IESS | Muy alto: el IMSS atribuyó la venta de datos de pensionados de 2025 al «uso indebido de accesos» del personal | [UnoTV](https://www.unotv.com/tecnologia/roban-datos-de-20-millones-de-pensionados-imss-niega-hackeo-y-habla-de-filtracion/) |
| Condiciones | Base legal, aviso previo y pacto sindical para tratar datos de servidores; la primera vez debe ser informativa | Informe |

## El aviso genérico previo rinde poco
| Medida | Hallazgo | Fuente |
|---|---|---|
| Etiqueta [EXTERNO] | En gran parte ineficaz en un hospital universitario alemán; muchos reaccionaron a la simulación con miedo, vergüenza y culpa | [heise](https://heise.de/-11092684) |
| Avisos centrados en el enlace frente a banners | Funcionaron mejor los centrados en el enlace (701 participantes) | [CHI 2019](https://jpetelka.github.io/files/chi_2019_phishing.pdf) |
| Banner «este sistema está monitoreado» | No redujo la frecuencia de intrusiones; CrimeSolutions lo califica de ineficaz | [CrimeSolutions](https://www.crimesolutions.ojp.gov/ratedprograms/555) |
| Lo que funciona | Retroalimentación personal tras un hecho concreto | Informe |

## Contra el servidor con acceso, controles de proceso
| Dato | Detalle | Fuente |
|---|---|---|
| Referencia convergente | Guía de riesgo interno del CERT/SEI, 7.ª edición (2022), 22 prácticas | [SEI](https://www.sei.cmu.edu/library/common-sense-guide-to-mitigating-insider-threats-seventh-edition/) |
| CCSS (Costa Rica) | La Contraloría cuestionó cerca de **9.000 permisos** de acceso al expediente digital, incluso de funcionarios fallecidos; antes del ataque de 2022, TIC había recibido 37 oficios de auditoría con advertencias | [El Financiero CR](https://www.elfinancierocr.com/tecnologia/contraloria-cuestiona-cerca-de-9000-permisos-de/MPCMUS6HEFGE5CRTQOBPUCJENA/story/); [Semanario Universidad](https://semanariouniversidad.com/?p=249505) |
| IESS, Guayaquil 2024 | Dos funcionarios y tres direcciones IP en al menos 20 préstamos | [Expreso, 13-12-2024](https://www.expreso.ec/actualidad/economia/iess-biess-investigan-fraude-detectan-funcionarios-ips-implicados-estafas-jubilados-224394.html) |
| Lectura del informe | La falla típica en la región es la gestión de cuentas, no la falta de conciencia | Informe |

| Pieza | Zona | Detalle |
|---|---|---|
| Doble control (cuatro ojos o verificación fuera de banda) | Convergente | Para cambios de cuenta, correo y teléfono hechos por un servidor |
| Recertificación periódica de accesos | Convergente | Versión «cultural»: pantalla simple en la que el jefe confirma quién de su equipo necesita qué |
| Baja oportuna al cambiar de cargo | Convergente | |
| UEBA comercial | Periferia | Cara, sin evaluaciones independientes en hospitales y con carga de vigilancia laboral que exige evaluación de impacto |

## Medir con tres capas
| Dato | Detalle | Fuente |
|---|---|---|
| NIST SP 800-50 Rev. 1 | Publicada en septiembre de 2024; integra la privacidad y propone métricas | [NIST](https://csrc.nist.gov/pubs/sp/800/50/r1/final) |
| HAIS-Q | Cuestionario validado más usado; adaptación con 165 enfermeras griegas; versión breve de tres preguntas en hospitales daneses; sin versión validada en español para personal sanitario | [IOS Press](https://ebooks.iospress.nl/pdf/doi/10.3233/SHTI210248); [Thieme](https://thieme-connect.de/products/ejournals/html/10.1055/a-2424-2103) |
| Piloto industrial | Rendir mejor en simulaciones no indica una cultura más robusta | [arXiv 2508.20811](https://arxiv.org/pdf/2508.20811) |
| NHS | Dejó de exigir el 95 % de finalización y pide «comprensión adecuada» por rol. **Discrepancia**: fuentes contradictorias sobre si el 95 % sigue vigente para algunos organismos | [DSPT](https://www.dsptoolkit.nhs.uk/News/Training) |
| HICP 2023 del HHS | Materiales gratuitos; incluyen la pérdida de datos interna entre las cinco amenazas principales del sector salud | [hhscyber](https://hhscyber.hhs.gov/) |

| Capa del tablero | Indicadores |
|---|---|
| Conducta | Tasa de reporte, tiempo hasta el primer reporte, reincidencia de accesos no justificados, clic ajustado con la NIST Phish Scale |
| Proceso | Cuentas recertificadas, tiempo de baja, cambios con doble control |
| Percepción | HAIS-Q breve y una pregunta de justicia percibida |

## Cultura justa
| Conducta | Respuesta |
|---|---|
| Error honesto | Aprendizaje sin registro individual |
| Conducta de riesgo | Coaching |
| Temeridad o dolo | Proceso disciplinario y penal |

| Dato | Detalle | Fuente |
|---|---|---|
| Prueba directa | Débil: un proveedor reconoce que ningún estudio midió el efecto de castigar sobre la tasa de reporte | [Hook Security](https://www.hooksecurity.co/blog/should-you-punish-employees-who-fail-phishing-simulations) |
| Argumento IESS | La LOPDP prevé multas personales de **1 a 20 salarios básicos** a servidores | [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/) |
| Riesgo | Sin una regla explícita, el miedo a la multa puede empujar a ocultar incidentes. **Inferencia** | Informe |

## IA para el personal: explicar más que simular
| Estudio | Hallazgo | Fuente |
|---|---|---|
| Experimento con 750 participantes (**preprint**) | Explicaciones de avisos generadas por Claude 3.5 Sonnet y Llama 3.3 70B protegieron de forma comparable a las de expertos; las basadas en características fueron más eficaces ante phishing real y las contrafactuales redujeron falsos positivos | [arXiv 2507.07916](https://arxiv.org/html/2507.07916v2) |
| Heiding, Schneier y colegas | Spear phishing totalmente automatizado: **54 % de clics, igual que expertos humanos**, frente a 12 % del control | [arXiv 2412.00586](https://arxiv.org/abs/2412.00586) |
| Lectura del informe | Justifica simulaciones realistas, pero hiperpersonalizarlas con datos del servidor choca con la minimización y con la cultura justa | Informe |
| Coaching personalizado con LLM tras clic o reporte | Sin ensayos de conducta real; es periferia | Informe |

## Relacionadas
[[07 Tabla maestra]] (V18 a V30) · [[09 Huecos]] · [[convergentes_internos]] · [[seguridad_inteligente_ia]]
