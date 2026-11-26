# Nuevos datos cuantitativos: fraude digital y cultura de seguridad (IESS, Reto 1)

Búsqueda hecha el 26-11-2026. Este archivo complementa `vulnerabilidad_resumen.md` y no repite sus series. Las series graficables están en `nuevas_series.json` (20 series, validadas con node, sin ids repetidos).

**Convenciones**
- **(V)**: verificado en la página o el PDF original.
- **(R)**: viene solo de un resumen de búsqueda o de un fragmento.
- Los cálculos propios se marcan como tales.

---

## 1. Uso de TIC por edad (prioridad 1)

### 1.1 Hallazgo principal

El INEC sí publicó un desagregado por edad, pero solo hasta 2020, en la Encuesta Multipropósito TIC. Desde 2022 la ENEMDU de julio ya no lo publica, y tampoco publica el uso de internet por edad: solo celular, smartphone y computadora. No se descargaron ni procesaron los microdatos 2024 y 2025 (ZIP en SPSS y CSV): el desagregado actual sigue pendiente.

Fuente: INEC, Multipropósito TIC 2020, [principales resultados](https://www.ecuadorencifras.gob.ec/documentos/web-inec/Estadisticas_Sociales/TIC/2020/202012_Principales_resultados_Multiproposito_TIC.pdf) y [boletín](https://www.ecuadorencifras.gob.ec/documentos/web-inec/Estadisticas_Sociales/TIC/2020/202012_Boletin_Multiproposito_Tics.pdf) (V).

| Indicador (% del grupo) | 55-64, 2019 | 55-64, 2020 | 65+, 2019 | 65+, 2020 | 25-34, 2020 |
|---|---|---|---|---|---|
| Celular activado | 75,4 | 74,3 | 47,3 | 48,2 | 88,1 |
| Smartphone (sobre la población) | 42,0 | 46,3 | 18,9 | 20,5 | 81,6 |
| Smartphone (sobre quienes tienen celular) | 55,7 | 62,3 | 40,1 | 42,5 | — |
| Usa computadora | 19,9 | 18,6 | 7,8 | 6,4 | 43,5 |

- Para 65+, el smartphone pasó de 1,2 % en 2013 a 20,5 % en 2020. El cambio 2019-2020 no es estadísticamente significativo según el INEC.
- Hay un cambio de fuente en 2018: ENEMDU de diciembre hasta 2017 y Multipropósito desde 2018.

### 1.2 Adultos mayores: nota del INEC del 11-07-2024 (V)

Fuente: [INEC, nota institucional](https://www.ecuadorencifras.gob.ec/institucional/?p=5636).

| Indicador | % de adultos mayores |
|---|---|
| Tiene celular | 57,7 |
| Usa internet | 35,1 |
| Usa computador | 11,5 |
| Usa tablet | 5,5 |

- La nota no nombra la encuesta ni define la edad. Da 1.520.590 adultos mayores (9 %), que es la población de 65+ del Censo 2022, así que es probable que sean datos censales (inferencia).
- La revista del Consejo de Comunicación (publicada el 20-06-2026) cita las mismas cifras.
- Esto confirma y amplía la serie `adultos_mayores_dispositivos`, que antes no estaba verificada.

**Comparación de contexto, con otra fuente y que no debe ir en el mismo eje:** el uso nacional de internet en la población de 5+ años fue de 77,2 % (ENEMDU, jul-2024). Los 65+ usan internet a menos de la mitad de esa tasa.

### 1.3 Otros datos de la misma nota del INEC (V)

- 1.173.896 hogares (22,6 %) tienen al menos un adulto mayor.
- 276.084 adultos mayores (18,2 %) viven solos.
- 459.218 (30,2 %) tienen alguna dificultad funcional, ya incluida en otra serie.
- 18 % de los hogares tienen un adulto mayor como representante.

Esto cubre en parte el vacío de hogares con adultos mayores.

### 1.4 ENEMDU julio 2025: brechas por grupo (V)

Fuentes: PDFs de principales resultados [TIC 2025](https://www.ecuadorencifras.gob.ec/documentos/web-inec/Estadisticas_Sociales/TIC/2025/202507_Tecnologia_de_la_Informacion_y_Comunicacion-TICs.pdf) y [TIC 2024](https://www.ecuadorencifras.gob.ec/documentos/web-inec/Estadisticas_Sociales/TIC/2024/202407_Tecnologia_de_la_Informacion_y_Comunicacion-TICs.pdf).

| % de la población de 5+ años | 2024 | 2025 |
|---|---|---|
| Usa internet, nacional | 77,2 | 80,1 |
| Usa internet, rural | 59,8 | 68,5 |
| Usa internet, indígena | 49,7 | 57,3 |
| Usa internet, quintil 1 | 58,4 | 65,5 |
| Smartphone, nacional | 57,7 | 59,3 |
| Smartphone, rural | 42,0 | 48,3 |
| Smartphone, indígena | 27,6 | 37,9 |
| Celular activado, nacional | 61,3 | 61,9 |
| Analfabetismo digital (15-49 años) | 5,4 | 2,1 |

- Las cifras por etnia y quintil se extrajeron del texto de los gráficos y se asignaron por el orden de las etiquetas. Hay que cotejarlas visualmente antes de publicar.
- En 2025, el uso de internet tiene como primera finalidad las comunicaciones telefónicas (76,8 %), seguidas del entretenimiento (13,0 %).

### 1.5 Estudios locales de 2026, vía Teleamazonas del 01-10-2026 (V)

Fuente: [Teleamazonas](https://www.teleamazonas.com/actualidad/noticias/sociedad/adultos-mayores-conectados-celular-brecha-digital-ecuador-129318/). Son muestras pequeñas y no representativas, así que no se graficaron.

| Estudio | Muestra | Resultado |
|---|---|---|
| Universidad Técnica de Ambato, ene-jun 2026 | 183 adultos mayores | 90,2 % usa redes sociales; 56,8 % se conecta solo desde el celular; Facebook 31,1 % |
| Universidad Técnica de Cotopaxi, abr-ago 2026 | 191 adultos mayores | 58 % usa al menos una red social; 68 % dice no saber lo suficiente; 49 % no recibe apoyo familiar; 68 % quiere capacitarse |

Otro dato de la misma nota: la Arcotel aplica desde febrero de 2026 un descuento del 50 % en planes básicos para mayores de 65, que incluyen al menos 5 GB y 2 GB para mensajería.

---

## 2. WhatsApp y plataformas (prioridad 2)

| Dato | Valor | Fuente | Calidad |
|---|---|---|---|
| Usuarios de internet | 15,6 M (84,2 %), oct-2026; 15,4 M (83,9 %), oct-2025 | [DataReportal Digital 2027](https://datareportal.com/reports/digital-2027-ecuador) y [Digital 2026](https://datareportal.com/reports/digital-2026-ecuador) | V |
| Identidades en redes sociales | 17,2 M (93,1 %), oct-2026 | DataReportal | V; no son personas únicas |
| WhatsApp en DataReportal | No publica cifras de WhatsApp para Ecuador | — | V |
| WhatsApp Messenger, usuarios activos | 8,7 M (T1-2024); 12,6 M «semanales» (T2-2025); 10,6 M (T4-2025) | Sensor Tower, resúmenes automáticos de su blog | V, pero incoherente y con métrica sin definir: **no usar como serie** |
| WhatsApp Business, usuarios activos | 873 mil (T1-2024); 3,1 M (T2-2025); 3,3 M (T4-2025) | Sensor Tower | Igual que la fila anterior |
| Números de WhatsApp de Ecuador expuestos | Más de 16 M (puesto 38 de 236 países); casi la mitad con foto de perfil | Estudio de la Universidad de Viena y SBA Research (fines de 2025), vía Vistazo y Primicias | R |
| Mentinno, «Ecuador Digital: Perspectivas 2026» | Conexiones a Google y YouTube: 18,5 M (oct-2025); TikTok 17,3 M cuentas (+20,8 %) | [El Universo, 06-01-2026](https://www.eluniverso.com/noticias/informes/185-millones-de-dispositivos-se-conectan-a-google-y-youtube-en-ecuador-nota/) | V; sin cifra de WhatsApp |
| Mentinno, «Estado Digital» (abr-2025) | TikTok, red más usada: 15,5 M (feb-2025) | El Mercurio | R |
| El IESS usa WhatsApp | Tiene un chatbot de quejas en WhatsApp | [IESS, Rendición de Cuentas 2025](https://www.iess.gob.ec/documents/10162/39150634/Informe+Rendicion+de+Cuentas+2025) | V |
| Uso de WhatsApp por edad | 65+: 15,5 %; 25-34 años: 73,8 % | El Comercio (27-08-2020) | V; año y fuente sin precisar en el artículo, probablemente INEC 2016-2019: **no usar sin confirmar** |

---

## 3. Fraude digital: víctimas, denuncias y reclamos (prioridad 3)

| Dato | Valor | Fuente | Calidad |
|---|---|---|---|
| Reclamos por fraude con tarjetas ante la SB | 374 (ene-jul 2024) y 273 (ene-jul 2025); 75 % y 73 % resueltos en contra del cliente porque entregó sus datos | [Primicias, 06-09-2025](https://www.primicias.ec/economia/tarjetas-credito-debito-robo-estafas-denuncia-virtual-104275/) | V |
| Denuncias por estafa con tarjetas en la Fiscalía | 265 (2023), 194 (2024), 111 (hasta el 15-08-2025); 2 sentencias en 570 casos | Ídem | V |
| Estafa, total de noticias del delito en 2025 | 25.517 (2.º delito más denunciado); total de delitos: 341.784 | [Teleamazonas, 07-04-2026](https://www.teleamazonas.com/actualidad/noticias/judicial/cinco-delitos-cometieron-ecuador-fiscalia-113949/) | V; otra nota da 25.452 (R) |
| Apropiación fraudulenta por medios electrónicos, 2025 | 4.732 | Fiscalía vía Lupa Media (dic-2025), citada por [Primicias, 31-10-2026](https://www.primicias.ec/revistagestion/tu-dinero/ahorros-adultos-mayores-prevencion-fraude-financiero-136141/) | V en Primicias; la serie existente da 4.733 para ene-nov, así que 4.732 podría no ser el año completo |
| Asobanca: % de estafas digitales contra adultos mayores | 30 % | Vistazo, 08-07-2026 | V en el artículo, sin año ni base. **Discrepancia:** el texto dice «mayores de 65»; un resumen de búsqueda dice «mayores de 60» |
| Fundación Bien Estar: adultos mayores excluidos de servicios financieros digitales | Más de 800.000; menos de 25 % hace transacciones en línea; entre 20 % y 70 % no usa internet (rango no explicado) | Vistazo, 08-07-2026 | V; estimaciones sin metodología |
| Banco Pichincha: mayores de 65 que no identifican fácilmente una estafa | 72 %; además, 1 de cada 3 ecuatorianos no reconoce señales básicas y más de 50 % de usuarios digitales nunca recibió formación en seguridad | [KCH, 11-12-2025](https://kchcomunicacion.com/?p=280089) (material del banco) | V en la nota; sin metodología |
| Banco Pichincha: clientes de 60+ que usan canales digitales | 51 % | Ídem | V |
| Banco Pichincha: canales digitales en general | 83 % de las transacciones; 8 de cada 10 clientes; 5,5 M de usuarios activos | [Primicias, 02-10-2026](https://www.primicias.ec/economia/banco-pichincha-concentra-transacciones-canales-digitales-134017/) | V |
| Sistema financiero: dinero por canales digitales | 67 % | Ídem | V |
| Entidades financieras falsas identificadas por la SB | 60 o 68 (2025); 78 hasta mediados de sep-2026; 117 «en lo que va de 2026» | Varios medios | R, discrepantes |
| Plan Nacional de Seguridad Integral: incidentes | Filtración de datos 136 (2024) y 174 (2025); phishing 18 y 0 | [Expreso, 14-07-2026](https://www.expreso.ec/ciencia-y-tecnologia/filtraciones-datos-crecieron-ecuador-nuevo-plan-nacional-seguridad-289220.html) | V en Expreso; parecen incidentes institucionales |

**No se encontró:** víctimas por edad de la Fiscalía, la Policía o la SB; montos totales perdidos; cifras de SIM swapping, robo de cuentas de WhatsApp o «familiar en apuros». Una tesis ecuatoriana de 2026 (UPS) afirma que el Estado no conoce el número de adultos mayores afectados (R).

---

## 4. Lenguas indígenas y discapacidad (prioridad 4)

| Dato | Valor | Fuente | Calidad |
|---|---|---|---|
| Habla algún idioma indígena (1+ año) | 4,9 % (2010) y 3,9 % (2022; el texto dice 3,95 %) | [INEC, resultados clave del Censo 2022, lámina 34](https://www.censoecuador.gob.ec/wp-content/uploads/2023/09/Presentacio%CC%81n_ResultadosClave_Censo_2022.pdf) | V |
| Se autoidentifica como indígena | 7,7 % | Ídem | V |
| Lengua de señas ecuatoriana | 0,1 % (2022) | Ídem | V |
| Hablantes de lengua indígena perdidos entre 2010 y 2022 | Unos 36.000; entre los niños de 0 a 4 años, casi −50 % | El Universo, columna del 19-07-2024 | V en la columna |
| Hablantes de kichwa | 527.333 (de 645.821 hablantes de lenguas indígenas) frente a 591.448 | Kiddle (enciclopedia infantil) y tesis de la UPS | R, discrepantes y sin tabla oficial: **no usar** |
| Personas con discapacidad registradas | 476.360 (CONADIS, 2020) y 480.776 (MSP, 2023; 2,67 % de la población) | El Universo (2020) y El Oriente (jul-2026) | R; registros distintos, no comparables con 1,1 M del censo |
| Discapacidad 65+ (CONADIS) | No se encontró; la página de estadísticas del CONADIS no carga datos | — | — |

---

## 5. Extorsión 2019-2025 (prioridad 5)

| Año | OECO 2024 (Fiscalía) | Otras cifras |
|---|---|---|
| 2019 | 862 | 1.616 (OECO 2026, vía Primicias) |
| 2020 | 1.282 | 1.210 extorsiones telefónicas (Policía, vía El Comercio; R) |
| 2021 | 1.600 | 2.797 y 2.799 (Primicias, Fiscalía); 1.628 telefónicas (Policía; R) |
| 2022 | 4.701 | 6.475 en ene-oct (Primicias, Fiscalía); 7.740 (Dialnet; R); 8.399 (Primicias; R) |
| 2023 | 21.811 | 13.627 (Policía, serie existente) |
| 2024 | — | 23.080 (Fiscalía, serie existente) |
| 2025 | — | 16.129 (rendición de cuentas), 16.130 y 16.131 |

- Fuente de la serie OECO: [OECO-PADF, «Radiografía de la extorsión en Ecuador», mayo 2024, gráfico 1](https://oeco.padf.org/wp-content/uploads/2024/05/OECO_Radiografia-de-la-extorsion-en-Ecuador-1.pdf) (V).
- La serie 2019-2023 completa el hueco, pero 2019 no coincide con el estudio OECO de 2026 (862 frente a 1.616). Es probable que las fuentes usen criterios distintos (con o sin tentativas). Graficar con un aviso de cambio de fuente.

---

## 6. IESS, BIESS y la DNSIPD en 2026 (prioridad 6)

| Dato | Valor | Fuente | Calidad |
|---|---|---|---|
| Préstamos quirografarios del BIESS en 2025 | 2,7 M de créditos por USD 4.475 M (99,26 % de la meta); tope de 2026: USD 38.560 | [El Universo, 20-06-2026](https://eluniverso.com/noticias/informes/biess-pide-dos-nuevos-requisitos-para-acceder-a-prestamos-quirografarios-nota/) | V |
| Nuevos controles del BIESS (jun-2026) | Foto obligatoria en créditos de menos de USD 10.000 por el buzón virtual; visita presencial y firma en agencia para más de USD 10.000; justificados «por seguridad», sin mencionar fraude | Ídem | V |
| Fraude interno con aportes | Una funcionaria cargó 5 años de aportes falsos para una jubilación indebida; el caso se denunció a la Fiscalía; sin montos | [El Diario, 21-11-2025](https://www.eldiario.ec/ecuador/iess-actos-irregulares-manipulacion-aportes-registros-laborales-21112025/) | V |
| Canal de denuncia | Canal ante falsas ofertas de cargos públicos a nombre del IESS (ene-2026) | Primicias | R |
| Alertas oficiales | IESS y MSP contra estafas a prestadores de salud (20-10-2026); correos falsos de «reembolso» de prima | Teleamazonas y KCH | R |
| Monto de casos de suplantación de jubilados | USD 85.000 con 10 afectados | elyex.com (sitio secundario) | R, no confiable |
| DNSIPD | Más de 8.000 servidores capacitados (IESSEDUCA) y 426 presenciales, ya en la serie existente. En abr-2026 se creó el Comité de Seguridad de la Información (resolución IESS-DG-2026) | IESS | V para la capacitación; R para el comité |
| Cifra consolidada de fraudes contra afiliados 2022-2026 | No se encontró | — | — |

Del informe de rendición de cuentas 2025 también salen: USD 10.316 M recuperados en 2025 frente a 10.008 M en 2024, y 43.296 empleadores «reconocidos» por pago oportuno, que no es el total de empleadores.

---

## 7. Costos de mensajería en 2026 (prioridad 7)

| Canal | USD por mensaje | Fuente |
|---|---|---|
| WhatsApp autenticación o utilidad | 0,0113 | Tarifa de Meta para «Resto de América Latina», vía [Zernio](https://zernio.com/blog/whatsapp-business-api-pricing) (actualizado 12-10-2026) |
| WhatsApp marketing | 0,0740 | Ídem |
| SMS, Twilio | 0,339 | [Twilio](https://www.twilio.com/sms/pricing/ec) (vigente a nov-2026) |
| SMS, Plivo | 0,2516 (otros operadores), 0,2969 (Claro), 0,4267 (Movistar) | [Plivo](https://www.plivo.com/sms/pricing/ec/) |
| SMS, agregadores europeos | 0,03 a 0,14 EUR | BulkGate, BudgetSMS, Messaggio (R) |

- **Discrepancia:** SleekFlow publica 0,0851 y 0,0130, que es la tarifa de Meta más 15 % (cálculo propio), es decir, el margen del revendedor.
- Meta confirma que Ecuador está en «Rest of Latin America» y que esa región no cambió de tarifa en enero ni en octubre de 2026.
- Desde el 1-10-2026, Meta cobra los mensajes de utilidad dentro de la ventana de atención. Los mensajes de servicio tienen 1.000 gratis al mes por número.
- Para escala, cálculo propio: un aviso de utilidad a 1 millón de jubilados por WhatsApp costaría unos USD 11.300, frente a unos USD 250.000 a 430.000 por SMS con API internacional. No incluye IVA ni costos de plataforma. Las tarifas locales de SMS no son públicas.

---

## 8. Empleadores registrados en el IESS (prioridad 8)

No se encontró el número total de empleadores. Datos cercanos:

- 6.673 acuerdos de pago parcial con empleadores entre enero y mayo de 2026 (El Comercio; R).
- 43.296 empleadores reconocidos por pago oportuno (rendición de cuentas 2025; V).
- Empleo registrado en el IESS: 3,4 M (mar-2026) según el REESS del INEC. El boletín REESS de mayo de 2026 no publica el número de empleadores (V).

---

## 9. Discrepancias nuevas

| Tema | Fuente A | Fuente B | Comentario |
|---|---|---|---|
| Extorsión 2019 | 862 (OECO 2024) | 1.616 (OECO 2026) | La misma institución da cifras distintas |
| Extorsión 2021 | 1.600 (OECO y Expreso) | 2.797 (Primicias, Fiscalía) | Posible inclusión de tentativas |
| Extorsión 2022 | 4.701 | 6.475 solo ene-oct | Ídem |
| WhatsApp, usuarios activos | 12,6 M (T2-2025) | 10,6 M (T4-2025) | Sensor Tower con métricas sin definir |
| Tarifa de WhatsApp marketing | 0,0740 | 0,0851 | La segunda incluye margen del revendedor |
| Asobanca, 30 % | «mayores de 65» (texto de Vistazo) | «mayores de 60» (resumen) | Sigue sin fuente primaria |
| Estafa 2025 | 25.517 | 25.452 | Mismo informe de la Fiscalía |
| Población urbana (DataReportal) | 65,4 % (informe 2026) | 78,7 % (informe 2027) | Cambio de método |

---

## 10. Vacíos que siguen

- **TIC por edad después de 2020.** No hay internet, smartphone ni WhatsApp por edad (55-64 y 65+) en las publicaciones TIC 2022-2025. Solo procesando los microdatos de la ENEMDU TIC 2025 (ZIP en SPSS o CSV, no descargados) o con el tabulado censal de 2022.
- **WhatsApp.** No hay ningún % de población o de internautas que use WhatsApp con fuente seria y reciente. DataReportal no lo publica. No se halló el PDF de Mentinno 2025-2026.
- **Víctimas de fraude por edad y montos totales perdidos.** Nada en la Fiscalía, la Policía ni la SB. El 30 % de Asobanca sigue sin fuente primaria.
- **SIM swapping, robo de cuentas de WhatsApp, vishing y «familiar en apuros».** Sin cifras ecuatorianas.
- **Kichwa.** No se halló la tabla oficial del INEC con el número absoluto de hablantes. Falta también el cruce con afiliados del SSC.
- **Discapacidad en 65+ (CONADIS).** No se halló. El registro total solo existe vía resúmenes (476 mil a 481 mil).
- **Extorsión.** La serie 2019-2025 existe, pero con fuentes no homogéneas. Falta la serie oficial de la Fiscalía con un criterio único (portal de estadísticas o pedido de transparencia).
- **Fraudes contra afiliados y jubilados del IESS y el BIESS 2022-2026.** Sigue sin cifra consolidada ni resultado judicial. No hay incidentes publicados por la DNSIPD.
- **Número total de empleadores registrados en el IESS.**
- **Tarifas locales de SMS masivo en Ecuador** (Claro y Movistar empresas, agregadores locales).

## 11. Notas metodológicas

- Los PDFs del INEC, del OECO y del IESS se descargaron automáticamente al leerlos con la herramienta de lectura web. Su texto se extrajo con PyMuPDF para leer los valores de los gráficos. No se descargaron tabulados xlsx ni microdatos.
- Las cifras de los gráficos del INEC se asignaron según el orden de las etiquetas. En las series por edad se comprobaron con las tablas del boletín y con razones internas. En las de etnia y quintil no hay tabla de control: cotejarlas antes de publicar.
