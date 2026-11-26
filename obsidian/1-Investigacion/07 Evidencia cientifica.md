---
tags: [investigacion, evidencia, concienciacion, phishing, medicion]
fuente: "[[Informe completo]]"
fecha: 2026-11-25
---

↑ [[Indice Investigacion]]

# 07 Evidencia cientifica

## En pocas palabras
- Los dos mayores estudios de campo coinciden: la capacitación anual no tiene relación medible con la tasa de clic en phishing.
- Funcionan mejor el reporte colectivo, los avisos en contexto y la práctica con ejemplos reales (inoculación) con refuerzos.
- La autoeficacia pesa más que el miedo; el castigo y el exceso de decisiones empeoran la conducta y matan el reporte.
- La tasa de clic bruta y los cursos completados miden cumplimiento, no reducción del riesgo.

## Grandes estudios de campo
| Estudio | Muestra | Hallazgo | Fuente |
|---|---|---|---|
| Ho et al., IEEE S&P 2025 (ensayo controlado) | 19.789 empleados de UC San Diego Health, 8 meses, 10 campañas | Ninguna correlación entre capacitación anual reciente y clic. La capacitación embebida redujo el fallo en unos 2 puntos porcentuales; más de la mitad de las sesiones duró menos de 10 segundos y menos del 24 % se completó | [Ho et al.](https://sysnet.ucsd.edu/~voelker/pubs/phishtrain-oakland25.pdf) |
| Ho et al., efecto del señuelo | Ídem | La tasa de fallo varió entre 1,82 % y 30,80 % según el mensaje; los de política interna de recursos humanos fueron los más eficaces | Ho et al. |
| Lain, Kostiainen y Čapkun, IEEE S&P 2022 | 14.773 empleados, 15 meses | La capacitación embebida, tal como la aplica la industria, no aumenta la resiliencia y puede reducirla. Los avisos en el correo funcionaron; el reporte colectivo detectó campañas nuevas en pocos minutos y los empleados siguieron reportando durante largos periodos | [Lain et al.](https://arxiv.org/abs/2112.07498) |
| Seguimiento de 2024 (**preprint**) | | El phishing es «un problema de atención, no de conocimiento»; el efecto de la capacitación embebida viene del recordatorio periódico, no del contenido; las recompensas no mejoran la conducta | [arXiv 2409.01378](https://arxiv.org/abs/2409.01378) |
| DBIR 2025 de Verizon (vía resumen) | | La capacitación reciente influye más en el reporte (21 % frente a 5 %) que en el clic | [Keepnet Labs](https://keepnetlabs.com/blog/2025-verizon-data-breach-investigations-report). **Cifra de un proveedor, no verificada en el informe original** |

> **Implicación metodológica del informe.** Cualquier comparación de tasas de clic sin ajustar por dificultad y sin grupo de control es engañosa.

## Argumentos en contra
| Evidencia | Hallazgo | Fuente |
|---|---|---|
| Ho et al. | La capacitación interactiva completada redujo un 19 % (relativo) la probabilidad de caer en el siguiente señuelo | Ho et al. |
| Experimento de laboratorio del CREST | Todas las intervenciones mejoraron el comportamiento frente al grupo de control | [CREST](https://crestresearch.ac.uk/resources/simulated-phishing-and-employee-cybersecurity-behaviour-spec/) |
| Requisito normativo | El EGSI v3 exige un plan de concienciación; FISMA impone en EE. UU. formación anual | [NIST/FISSEA](https://csrc.nist.gov/presentations/2007/fisma-and-opm-awareness-and-training-requirements) |

Conclusión del informe: la formación no es inútil, pero sus efectos son pequeños, dependen del formato y desaparecen al medirse en condiciones reales. El cumplimiento formativo es necesario, pero no basta para demostrar reducción del riesgo.

## Qué mueve la conducta
| Factor | Hallazgo | Fuente |
|---|---|---|
| Autoeficacia y eficacia de la respuesta | Predicen la conducta segura más que la percepción de amenaza (metaanálisis de la Teoría de Motivación de Protección: Lowry et al. 2023, 341 artículos; Mou et al., 92 estudios) | [JMIS](https://www.jmis-web.org/articles/1641); [JAIS](https://aisel.aisnet.org/jais_preprints/15) |
| Apelaciones al miedo (fuera de seguridad) | Efecto modesto (d = 0,29), mayor si el mensaje incluye instrucciones de eficacia | [Tannenbaum et al., Psychological Bulletin](https://pubmed.ncbi.nlm.nih.gov/26501228/) |
| Fatiga de seguridad | Documentada en 25 de 40 entrevistas: el exceso de decisiones lleva a impulsividad e incumplimiento | [NIST, 2016](https://www.nist.gov/news-events/news/2016/10/security-fatigue-can-cause-computer-users-feel-hopeless-and-act-recklessly) |
| Castigo | Capacitación obligatoria y castigo se perciben como injustos y aumentan la ansiedad; es poco probable reportar si se temen represalias | [CREST, «Phishing your staff»](https://www.crestresearch.ac.uk/resources/phishing-your-staff/) |
| Consecuencias disciplinarias | Entrevista disciplinaria o despido reducen la aceptación de las simulaciones | [USEC 2025](https://ndss-symposium.org/wp-content/uploads/usec25-10.pdf) |

Lectura del informe: en el IESS, con sindicatos y un clima hospitalario tenso, una cultura percibida como vigilancia o castigo acabaría con el reporte, que es la conducta con mejor evidencia.

## Ciudadanos y personas mayores
| Estudio | Muestra | Hallazgo | Fuente |
|---|---|---|---|
| AARP, experimento nacional | Más de 4.000 adultos | Ver ejemplos simulados de estafas (inoculación activa) mejoró la detección sin reducir la confianza en comunicaciones legítimas, y se transfirió a otros tipos de estafa | [AARP](https://www.aarp.org/money/scams-fraud/info-2022/social-security-scams-studies.html) |
| Boston College CRR | Más de 1.000 participantes | La lectura estática no sirvió | [Boston College CRR](https://crr.bc.edu/people-can-spot-a-scam-after-seeing-fakes) |
| DeLiema et al., víctimas de fraude postal (**solo resumen de congreso**) | | Una carta redujo la revictimización un 8,6 %; varios envíos, un 22,4 % a los cuatro meses. El efecto se desvanece sin refuerzo | [DeLiema et al., PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11689558) |
| Estudio comparativo de formatos | | El formato de juego dejó de ser significativo a los 9 días, frente a un mes para texto o video; un refuerzo semanal prolongó la detección | [PMC11897321](https://pmc.ncbi.nlm.nih.gov/articles/PMC11897321/) |
| Revisiones sobre gamificación | Muestras pequeñas | Ganancias de conocimiento a corto plazo; ningún cambio de comportamiento demostrado a largo plazo. No existe metaanálisis cuantitativo | [Informing Science](https://www.informingscience.org/Publications/5601); [IJSG 2025](https://journal.seriousgamessociety.org/index.php/IJSG/article/download/825/578) |
| Vacío | | No se encontraron estudios de inoculación en adultos mayores latinoamericanos | Informe |

## IA y LLM
| Estudio o hecho | Hallazgo | Fuente |
|---|---|---|
| Experimento con 750 participantes (**preprint**) | Explicaciones generadas por LLM en avisos de phishing protegieron tanto como las de expertos | [arXiv 2507.07916](https://arxiv.org/html/2507.07916v1) |
| Estudio pequeño | Los usuarios aceptan más las sugerencias de la IA cuando suena segura, acierte o no | [arXiv 2505.03179](https://arxiv.org/html/2505.03179v1) |
| Vacío | No hay ensayos que comparen coaching personalizado con LLM frente a capacitación convencional en conducta real | Informe |
| Doble uso | Los mismos modelos abaratan el phishing personalizado | [Schneier, 2024](https://www.schneier.com/wp-content/uploads/2024/03/Devising_and_Detecting_Phishing_Emails_Using_Large_Language_Models.pdf) |
| Norma ecuatoriana | La SPDP ya reguló el tratamiento de datos personales con IA (Res. 2026-0009-R) | Informe |

Lectura del informe: un componente «inteligente», como sugiere el título del reto, tendría que justificar su exactitud, comunicar su incertidumbre y cumplir esa norma.

## Cómo medir sin engañarse
| Métrica o instrumento | Valoración del informe | Fuente |
|---|---|---|
| Tasa de clic bruta, cursos completados | Miden cumplimiento, no reducción del riesgo | Informe |
| Tasa de reporte | Apoyada por la evidencia | Informe |
| Tiempo hasta el primer reporte | Apoyada por la evidencia | Informe |
| Número de amenazas reales detectadas primero por los usuarios | Apoyada por la evidencia | Informe |
| Clic ajustado por dificultad (NIST Phish Scale) y comparado con grupo de control | Apoyada por la evidencia | [NIST TN 2276](https://csrc.nist.gov/pubs/tn/2276/final) |
| HAIS-Q | Actitudes; único instrumento con validación psicométrica revisada por pares localizado (validez convergente frente a desempeño en phishing, fiabilidad test-retest). **Sin versión validada en español ecuatoriano** | [Parsons et al., Computers & Security 2017](https://dblp.org/rec/journals/compsec/ParsonsCPBMZ17.html); [McCormac et al., AJIS](https://aisel.aisnet.org/ajis/vol21/iss1/29) |
| Ciclo de ENISA | Las campañas por sí solas no protegen lo suficiente; la cultura se gestiona en ciclo de diagnóstico, intervención y medición repetida, con patrocinio de la dirección | [ENISA, 2017](https://enisa.europa.eu/publications/cyber-security-culture-in-organisations) |

## Relacionadas
[[06 Referentes internacionales]] · [[09 Criterios de diseno]]
