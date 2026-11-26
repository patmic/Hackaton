---
tags: [soluciones, atipicos-negativos, lineas-rojas, etica, lopdp]
fuente: "[[Mapa de soluciones completo]]"
fecha: 2026-11-25
---

↑ [[Indice Soluciones]]

# 06 Atipicos negativos y lineas rojas

## En pocas palabras
- Los fracasos documentados se agrupan en tres patrones: simulacros que juegan con la necesidad económica, sistemas automatizados opacos contra beneficiarios y soluciones «obvias» que fallan.
- Marcan las líneas que un jurado con perfiles de protección de datos y auditoría probablemente sancionaría.
- Robodebt, SyRI y el toeslagenaffaire terminaron en inocentes castigados, sentencias, multas y la caída de un gobierno.
- La biometría del INSS fue burlada con «dobles» humanos (fraude de R$86 millones) y con la «falsa prueba de vida».
- Ninguna campaña ciudadana compensa a un servidor que habilita el fraude.

## Patrón 1: simulacros que juegan con la necesidad económica
| Caso | Qué pasó | Fuente |
|---|---|---|
| Tribune Publishing (2020) | Señuelo de KnowBe4 que prometía bonos de USD 5.000 a 10.000 en plena época de recortes; luego se disculpó | [NewsGuild](https://newsguild.org/newsguild-condemns-tribune-hoax/) |
| GoDaddy | Unos 500 empleados cayeron en un falso bono navideño de USD 650 | [CBS News](https://www.cbsnews.com/news/godaddy-apologizes-insensitive-phishing-email-bonuses-employees) |
| West Midlands Trains (2021) | Falso bono por el trabajo en pandemia; el sindicato lo calificó de «cínico» | [TSSA](https://www.tssa.org.uk/news-and-events/tssa-news/anger-over-shocking-covid-bonus-stunt-at-west-midlands-trains) |

## Patrón 2: sistemas automatizados opacos contra beneficiarios
| Caso | Qué pasó | Fuente |
|---|---|---|
| Robodebt (Australia) | La Comisión Real lo calificó de «tosco y cruel»; 526.000 personas recibieron avisos de deuda; 57 recomendaciones, entre ellas la revisión independiente de las decisiones automatizadas | [iTnews](https://www.itnews.com.au/news/robodebt-report-calls-for-automated-decision-making-review-body-597734); [ACS](https://ia.acs.org.au/article/2023/crude-and-cruel-shameful-robodebt-findings-laid-bare.html) |
| SyRI (Países Bajos) | Un tribunal de La Haya declaró que violaba el artículo 8 del Convenio Europeo de Derechos Humanos | [Rechtspraak](https://www.rechtspraak.nl/organisatie-en-contact/organisatie/rechtbanken/rechtbank-den-haag/nieuws/2020/02/syri-legislation-in-breach-of-european-convention-on-human-rights) |
| Toeslagenaffaire (Países Bajos) | Usó la doble nacionalidad como indicador de riesgo; más de 33.000 familias reconocidas como víctimas; cayó el gobierno; la autoridad de datos impuso multas de €2,75 y €3,7 millones | [DutchNews](https://www.dutchnews.nl/2024/01/over-33000-families-acknowledged-as-benefit-scandal-victims/); [IAPP](https://iapp.org/news/a/dutch-dpa-fines-tax-authority-2-75m-euros) |
| INSS (Brasil), trabajador rural | Un juzgado anuló la negativa automática porque el sistema solo mira un registro que no captura el trabajo rural. Advertencia directa para el Seguro Social Campesino | [Migalhas](https://www.migalhas.com.br/depeso/431956/uso-de-ia-na-analise-de-requerimentos-administrativos-do-inss) |

## Patrón 3: soluciones «obvias» que fallan
| Caso | Qué pasó | Fuente |
|---|---|---|
| Biometría del INSS | Burlada con «dobles» humanos en un fraude de R$86 millones y con la «falsa prueba de vida», en la que delincuentes que se hacen pasar por servidores capturan el rostro del jubilado | [NSC Total](https://www.nsctotal.com.br/economia/fraude-de-r-86-milhoes-expoe-brechas-na-biometria-do-inss); [Santander](https://www.santander.com.br/blog/golpe-prova-de-vida-inss) |
| Scared Straight y programas de miedo | Aumentan la delincuencia (OR 1,68) | [Cochrane](https://www.cochrane.org/evidence/CD002796_scared-straight-and-other-juvenile-awareness-programs-preventing-juvenile-delinquency) |
| Publicar nombres de condenados | La OCDE duda de su eficacia en fraude a prestaciones | [OCDE](https://www.oecd.org/en/publications/countering-fraud-in-social-benefit-programmes_71df2657-en.html) |

## Advertencia estructural
| Caso | Qué pasó | Fuente |
|---|---|---|
| «Operação Sem Desconto» (Brasil) | Un delegado de la Policía Federal afirmó que hubo participación interna del INSS. Ninguna campaña ciudadana compensa a un servidor que habilita el fraude | [meutudo](https://meutudo.com.br/blog/noticias/2025/05/29/investigacao-da-pf-afirma-que-descontos-indevidos-foram-facilitados-pelo-inss/) |

## Antipatrones y líneas rojas para el Reto 1
| Antipatrón | Caso | Qué salió mal | Línea roja para el Reto 1 |
|---|---|---|---|
| Simulacro con cebo de bono, décimo o aumento de pensión | Tribune 2020, GoDaddy 2020, West Midlands Trains 2021 | Daño a la confianza laboral, conflicto sindical | Catálogo de cebos pactado; nunca simular con jubilados |
| Puntaje opaco de beneficiarios sospechosos | Robodebt, SyRI, toeslagenaffaire | Inocentes castigados, sentencias, multas, caída de un gobierno | Analítica que protege al afiliado y retiene, con revisión humana y sin variables de origen |
| Negativa automática por cruce de bases | INSS, trabajador rural | El registro no captura la realidad rural | No automatizar decisiones que afecten a campesinos |
| Biometría como prueba suficiente | INSS: R$86 M, falsa prueba de vida | El rostro se captura o se suplanta | No tratar «mostrar mi cara» ni «conocer mis datos» como legitimidad |
| Miedo y compromisos firmados | Scared Straight, «firmar arriba» retractado | Efecto contrario o datos fabricados | Mensajes de eficacia y fricción de proceso |
| Muro de la vergüenza | Irlanda del Norte | Sin eficacia probada; choca con presunción de inocencia y LOPDP | Descartado |
| Listas de «señales de estafa» | Kenia | Más desconfianza, misma precisión | Enseñar una acción, no señales |
| Complicidad interna ignorada | Operação Sem Desconto | La campaña ciudadana no detiene al servidor cómplice | Incluir EI en cualquier propuesta |

Nota: el registro de SIM de Filipinas (+225 % de llamadas fraudulentas) figura como atípico negativo N8 en la [[07 Tabla maestra]] y como contrapunto en [[02 Convergentes ciudadanas]], pero no en esta tabla del informe.

## Relacionadas
[[05 Atipicos]] · [[07 Tabla maestra]] (N1 a N8) · [[10 Criterios de decision]] · [[atipicos_valores_extremos]]
