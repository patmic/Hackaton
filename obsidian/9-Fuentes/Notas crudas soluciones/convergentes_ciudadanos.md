# Soluciones convergentes del lado del ciudadano contra fraude e ingeniería social en instituciones de prestaciones (catálogo para el Reto 1 IESS)

> Notas de investigación (25-11-2026). Alcance: controles de proceso y de canal del lado del afiliado/jubilado que varios países han adoptado de forma convergente, entre 2019 y 2026. Escala: **CENTRO** (práctica dominante, varios países y reguladores) / **CONVERGENTE** (varios países van hacia ahí, aún no es norma) / **PERIFERIA** (pocos casos, evidencia débil) / **ATÍPICO** (caso aislado).
>
> Cadena de fraude IESS usada para el mapeo: **E1** obtener la clave personal (prestada a ayudante/tramitador, phishing o abuso interno) → **E2** cambiar correo/teléfono/cuenta bancaria → **E3** tomar préstamo quirografario BIESS o retirar fondos de reserva → **E4** la víctima se entera tarde (cuotas descontadas) y reclama.
>
> Contexto del estudio previo (D:\investigacion\reports\Cultura de ciberseguridad IESS.md): la clave es de un solo factor; el IESS notifica al correo anterior y al nuevo cuando cambia el correo desde mayo de 2025; los criterios de diseño exigen atacar momentos de riesgo concretos (cambio de contacto o de cuenta), inclusión (mayores, rurales, apagones), no convertir "conocer mis datos" en prueba de legitimidad, que la solución no sea imitable por estafadores, privacidad conforme a la LOPDP y honestidad sobre lo que la cultura no resuelve. Cifras del estudio previo se citan aquí con su fuente original, marcadas "(vía informe previo)".
>
> Nota de método: se hicieron ~17 consultas. Varias cifras vienen de la propia institución o del sector bancario (autorreporte) y no de evaluaciones independientes; se indica en cada caso.

## 1. Periodos de enfriamiento, aviso a canales antiguos, autobloqueo ("kill switch") y bloqueo de préstamos por defecto

### Takeaway
Es el bloque con mayor convergencia y el que mejor corta los eslabones E2 y E3. Singapur (enfriamiento de 12 h, kill switch, Money Lock, retención de 24 h) y Brasil (consignado bloqueado al nacer el beneficio desde 2019; desde noviembre de 2025 bloqueo mensual que exige biometría para cada préstamo) son los referentes. En Brasil, las reclamaciones por consignado no reconocido bajaron entre 70 % y 88 % según el sector bancario, y en Singapur el paquete de medidas coincide con caídas de casos del 26 % al 27,6 %. Ningún país publica el efecto aislado de cada medida.

### Cited Findings
**Singapur (MAS/ABS)**
- Paquete MAS–ABS de enero de 2022 tras el caso de phishing de OCBC: retirada de enlaces clicables en SMS/correos bancarios, umbral de notificación de transacciones por defecto bajado a S$100 o menos, **periodo de retraso de al menos 12 horas para activar un token digital en un dispositivo nuevo**, notificación al teléfono/correo registrado previo al cambiar datos de contacto, "kill switch" para que el cliente congele sus cuentas por sí mismo, y hotlines de fraude reforzadas. — [MAS, nota de prensa 19-01-2022](https://www.mas.gov.sg/news/media-releases/2022/mas-and-abs-announce-measures-to-bolster-the-security-of-digital-banking); [Allen & Gledhill](https://www.allenandgledhill.com/sg/publication/articles/20112/mas-and-abs-announce-measures-to-bolster-digital-banking-security)
- El Shared Responsibility Framework (vigente desde 16-12-2024) obliga a los bancos a imponer un **enfriamiento de 12 horas** tras activar un token digital o iniciar sesión en un dispositivo nuevo, durante el cual no se permiten actividades de alto riesgo. El MAS dijo al Parlamento que 12 horas dan tiempo al cliente para reaccionar "limitando la fricción para usuarios legítimos". Si el banco no cumple sus deberes (incluidas las notificaciones), asume la pérdida. — [MAS, respuesta parlamentaria 2024 sobre SRF](https://www.mas.gov.sg/news/parliamentary-replies/2024/pq-on-shared-responsibility-framework); [Baker McKenzie](https://insightplus.bakermckenzie.com/bm/financial-institutions_1/singapore-shared-responsibility-framework-to-be-implemented-from-16-december-2024)
- Desde el 15-10-2025, cuando el banco detecta que una cuenta se está vaciando rápidamente, puede retener transacciones con un **enfriamiento de 24 horas** antes de liberarlas, o rechazarlas. — [ABS, 2025](https://abs.org.sg/docs/library/banks-to-launch-enhanced-safeguards-from-15-oct-2025-to-better-protect-accounts_.pdf)
- **Money Lock**: el cliente "aparta" fondos que no se pueden transferir digitalmente; solo se desbloquean en sucursal o cajero con verificación. El MAS informa que los bancos envían recordatorios periódicos para activarlo; también va eliminando progresivamente el OTP por SMS en operaciones de alto riesgo y anuncia para 2026 **más periodos de enfriamiento** y **notificaciones en la app para verificar que una llamada entrante es del banco**. — [MAS, respuesta escrita 13-01-2026](https://www.mas.gov.sg/news/parliamentary-replies/2026/written-reply-on-effectiveness-of-requirements-imposed-by-mas-on-banks-to-protect-against-scams)
- Resultados: los casos de estafa cayeron 26 % y las pérdidas 13 % en el primer semestre de 2025 frente al de 2024 (no atribuido a una medida concreta). — [MAS, 13-01-2026](https://www.mas.gov.sg/news/parliamentary-replies/2026/written-reply-on-effectiveness-of-requirements-imposed-by-mas-on-banks-to-protect-against-scams). En el año 2025 los casos bajaron 27,6 %, hasta 37.308 (vía informe previo). — [SPF, Annual Scam and Cybercrime Brief 2025](https://www.police.gov.sg/-/media/SPF/Advisories/Scams/Annual-Scam-and-Cybercrime-Brief-2025.pdf)
- Un resultado de búsqueda atribuye a las medidas de los grandes bancos minoristas "S$78 millones de pérdidas evitadas en los primeros siete meses" del año, pero el fragmento no indicaba el año y no se pudo verificar. — [MAS Annual Report 2025/26, Anti-Scam Measures](https://www.mas.gov.sg/publications/annual-report/2026/annual-report-2025-2026/responsible-and-trusted-financial-centre/mas-anti-scam-measures)
- Crítica en la consulta del SRF: un enfriamiento de 12 h "solo puede mitigar hasta cierto punto". — [MAS, Anexo B de la consulta SRF](https://www.mas.gov.sg/-/media/mas-media-library/publications/consultations/pd/2023/srf/annex-b---submissions-to-consultation-paper-on-shared-responsibility-framework.pdf)

**Brasil (INSS, consignado)**
- Todo beneficio concedido desde el **1-04-2019 nace bloqueado para préstamo consignado durante 90 días**. Desde el día 91 el titular puede pedir el desbloqueo en Meu INSS con biometría facial. También hay un bloqueo de 60 días tras cambiar el lugar de pago. El beneficiario puede volver a pedir el bloqueo en cualquier momento por los canales remotos del INSS (autobloqueo). — [Santander Brasil, blog](https://www.santander.com.br/blog/para-voce/inss-bloqueio-credito-consignado/); [Seu Crédito Digital](https://seucreditodigital.com.br/inss-bloqueio-90-dias-consignado/); [Meu Tudo, 24-08-2026](https://meutudo.com.br/blog/noticias/2026/08/24/consignado-nao-podera-mais-ser-contratado-em-nenhum-banco-ate-90-dias-do-beneficio-inss/) (fuentes secundarias del sector, no la norma original)
- Desde mayo de 2025 el desbloqueo para consignado se hace en Meu INSS **con biometría**. — [Agência Gov, 05-2025](https://agenciagov.ebc.com.br/noticias/202505/passa-a-valer-hoje-o-desbloqueio-do-beneficio-por-biometria-para-credito-consignado-no-meu-inss)
- Según Meu Tudo, la Instrução Normativa PRES/INSS nº 213/2026 cerró la excepción de 2024 que permitía contratar en el banco pagador dentro de los 90 días. Desde entonces se prohíbe cualquier consignado en ese plazo, aunque la portabilidad sigue permitida. — [Meu Tudo, 24-08-2026](https://meutudo.com.br/blog/noticias/2026/08/24/consignado-nao-podera-mais-ser-contratado-em-nenhum-banco-ate-90-dias-do-beneficio-inss/) (no se verificó el texto de la IN)
- Desde noviembre de 2025 hay un **"bloqueio padrão" que se renueva cada mes** y se aplica a todos los jubilados y pensionistas, incluidos los antiguos. Cada préstamo exige un desbloqueo específico con biometría y quedan prohibidos los desbloqueos por poder, por teléfono o por canales no oficiales. La medida sigue una recomendación del TCU y anticipa el PL 1.546/2024. Cifras del mismo artículo: el volumen de préstamos cayó 32 % entre enero y octubre de 2025, las medidas de mayo redujeron las concesiones un 67 % y las quejas por productos no solicitados bajaron 70 % entre 2021 y 2025. Además, se advirtió a más de 1.000 corresponsales y se excluyó a unos 113. — [ABC do ABC, 22-12-2025](https://abcdoabc.com.br/inss-bloqueia-consignado-mensal-travar-fraude/) (medio regional; no se localizó el acto normativo)
- Febraban y ABBC: las reclamaciones por consignado no reconocido **cayeron 88 % entre 2021 y 2024** y lo atribuyen a la confirmación por biometría facial (2022). — [IstoÉ](https://istoe.com.br/febraban-e-abbc-apontam-que-reclamacoes-por-consignado-nao-reconhecido-cairam-88-desde-2021) (cifra del sector bancario, sin auditoría independiente)
- Costes de inclusión: la ABBC señaló al menos 500.000 pedidos de jubilados pendientes de análisis en Dataprev, y un error de Dataprev interpretó solicitudes legítimas como fraude y bloqueó beneficios por equivocación. Según Correio da Manhã, el consignado INSS se redujo un 40 % en dos años. — [Correio da Manhã, 07-2026](https://www.correiodamanha.com.br/nacional/sao-paulo/estado-de-sao-paulo/2026/07/298739-consignado-do-inss-encolhe-40-em-dois-anos-com-novas-regras-e-fraudes.html); [Senado, documento](https://legis.senado.leg.br/sdleg-getter/documento/download/73899a32-d667-4f96-a395-f157407d3764)

**Reino Unido (Confirmation of Payee, CoP)**
- La PSR concluyó en 2021 que la fase 1 de CoP tuvo un impacto positivo y redujo los pagos mal dirigidos. — [PSR RP21/1, oct-2021](https://psr.org.uk/media/ktonkca3/psr-rp21-1-confirmation-of-payee-response-paper-oct-2021.pdf)
- Lloyds informó una reducción de hasta el 90 % de los pagos salientes erróneos en los casos que CoP puede prevenir (dato de un solo banco). — [Lloyds, whitepaper Sibos 2021](https://www.lloydsbank.com/assets/resource-centre/pdfs/sibos2021-cop-implementation-and-initial-learnings-whitepaper.pdf)
- Pay.UK cita una reducción del 59 % en la categoría de reclamaciones "cuenta incorrecta", según el Annual Fraud Report 2025 de UK Finance. CoP lo ofrecen casi 400 proveedores y cubre más del 99 % de los pagos de Faster Payments. — [Pay.UK](https://www.wearepay.uk/pay-uk-discusses-the-evolution-of-confirmation-of-payee-with-tell-money/) (autorreporte)

### Inferences
**Ficha 1.1 — Enfriamiento tras cambio sensible (contacto, cuenta bancaria, dispositivo nuevo)**
- Quién/dónde: Singapur (MAS/ABS 2022, SRF 2024), Brasil (bloqueo de 60 días tras cambiar el lugar de pago) y Australia (los bancos aplican retenciones; no se profundizó).
- Cómo funciona: tras cambiar el correo, el teléfono o la cuenta, o tras entrar desde un dispositivo nuevo, se bloquean las operaciones de alto riesgo durante 12 a 72 h, y en ese tiempo se avisa por los canales anteriores.
- Público: todos. Protege incluso al usuario engañado.
- Evidencia: resultados agregados (−26 % de casos en el 1S 2025 en Singapur), sin efecto aislado.
- Costo: bajo. Es una regla de negocio en el flujo de cambio de datos y en la solicitud de préstamo. El costo real es la fricción para usuarios legítimos y las llamadas a la línea de atención.
- Encaje con el IESS: muy alto. El eslabón crítico documentado es "cambia el correo y la cuenta y en horas saca el quirografario". Bastaría con impedir solicitudes de préstamo BIESS o de fondos de reserva durante X horas o días después de cambiar el correo, el celular o la cuenta, y avisar por el canal anterior (el IESS ya avisa al correo anterior desde mayo de 2025; faltan el celular anterior y la cuenta bancaria). Requiere coordinación con el BIESS. LOPDP: no implica datos nuevos, solo lógica de proceso.
- Eslabón: corta **E2→E3** y da tiempo para E4.
- Escala: **CENTRO** (Singapur es norma regulatoria; el principio "notificar al canal anterior y demorar" es práctica bancaria extendida).

**Ficha 1.2 — Aviso al canal anterior (correo/teléfono antiguo) ante cambios**
- Quién/dónde: Singapur (2022), banca en general. El IESS ya lo hace con el correo desde mayo de 2025.
- Cómo funciona: un mensaje al canal anterior con un enlace o número para revertir ("¿no fue usted? llame / bloquee"), que no debe ser un enlace clicable si se quiere coherencia con la regla "el IESS no envía enlaces".
- Evidencia: no hay medición aislada.
- Costo: muy bajo (SMS ~ centavos).
- Encaje: extenderlo al número de celular anterior y por SMS/IVR, porque muchos jubilados no leen el correo. Hace falta combinarlo con el enfriamiento (1.1): si el aviso llega cuando el préstamo ya está desembolsado, sirve de poco.
- Eslabón: **E4** (adelanta la detección) y **E2**.
- Escala: **CENTRO**.

**Ficha 1.3 — Autobloqueo / "kill switch" ciudadano**
- Quién/dónde: Singapur (kill switch bancario desde 2022) y Brasil (el beneficiario puede bloquear el consignado en cualquier momento en Meu INSS o por el 135).
- Cómo funciona: un botón o un número corto que congela la cuenta, o solo las operaciones de crédito y retiro, y cuyo desbloqueo exige verificación reforzada (presencial o biométrica).
- Evidencia: sin cifras públicas de uso ni de efecto.
- Costo: bajo a medio (IVR, opción en la app, integración con el BIESS).
- Encaje: alto. Permite que la familia (o una "persona de confianza", sección 2) active el bloqueo por teléfono si sospecha. Riesgo: que un tercero lo use para causar daño (bloqueo malicioso); se mitiga porque bloquear es fácil y desbloquear es lo difícil.
- Eslabón: **E3** y **E4**.
- Escala: **CONVERGENTE**.

**Ficha 1.4 — Préstamos bloqueados por defecto con desbloqueo explícito ("opt-in")**
- Quién/dónde: Brasil INSS (90 días al nacer el beneficio desde 2019; bloqueo mensual con biometría por préstamo desde noviembre de 2025) y Singapur Money Lock (fondos "cerrados" por opción del cliente).
- Cómo funciona: la capacidad de endeudarse o de retirar está apagada hasta que el titular la activa en persona o con biometría para una operación concreta y por un tiempo limitado.
- Evidencia: el sector bancario brasileño reporta −88 % (2021-2024) y −70 % (2021-2025) en reclamaciones por consignado no reconocido. El costo visible fue una caída del 32 % al 67 % en la concesión y colas de 500.000 pedidos en Dataprev.
- Costo: bajo en tecnología y alto en lo político y comercial, porque reduce el volumen de crédito del BIESS, que es un producto rentable.
- Encaje: es la medida más directa contra el patrón IESS. Variante inclusiva: que el quirografario y el retiro de fondos de reserva estén bloqueados por defecto para jubilados y que el desbloqueo se haga en agencia o con verificación reforzada, válido por 24-72 h. Brasil muestra que hay que dimensionar la capacidad de atención y la reversión de errores. LOPDP: si el desbloqueo es biométrico, se tratan datos sensibles y hace falta base legal y evaluación de impacto.
- Eslabón: **E3** (el más fuerte del catálogo).
- Escala: **CONVERGENTE** (Brasil es el caso más fuerte en prestaciones; Money Lock en Singapur; en América Latina no es norma).

**Ficha 1.5 — Verificación de beneficiario / nombre de titular en la cuenta destino (Confirmation of Payee y análogos)**
- Quién/dónde: Reino Unido (CoP desde 2020), UE (Verification of Payee obligatorio desde octubre de 2025 por el Reglamento de Pagos Instantáneos; no verificado en esta ronda) y Australia (en despliegue).
- Cómo funciona: antes de pagar, el banco del pagador consulta si el nombre coincide con el titular de la cuenta destino.
- Evidencia: −59 % en reclamaciones "cuenta incorrecta" (Pay.UK/UK Finance) y hasta −90 % en Lloyds. Sirve más contra errores que contra fraudes autorizados.
- Costo: medio (requiere una red interbancaria o una consulta al banco).
- Encaje con el IESS: análogo útil. Al registrar o cambiar una cuenta bancaria para acreditar el préstamo o los fondos, verificar con el banco que la cuenta está a nombre del mismo afiliado (cédula = titular). Ecuador no tiene un servicio CoP nacional conocido; el IESS/BIESS podría hacerlo por convenio bilateral con los bancos o exigir que la cuenta sea del titular (requisito que parece existir en la norma; no verificado). Corta el desvío a cuentas de terceros o mulas.
- Eslabón: **E2/E3**.
- Escala: **CENTRO** en pagos (Reino Unido y UE); **PERIFERIA** como control dentro de instituciones de prestaciones.

### Gaps
- Ningún regulador publica el efecto aislado del enfriamiento de 12 h, del kill switch ni de Money Lock (número de cuentas, montos bloqueados o usos). La cifra de S$78 M "evitados" no se pudo fechar.
- No se localizó la norma primaria del bloqueo mensual brasileño de noviembre de 2025 ni el texto de la IN 213/2026; las fuentes son medios del sector. Las fuentes discrepan sobre si la biometría se exige por préstamo o por desbloqueo mensual.
- No se investigaron en esta ronda los periodos de retención de los bancos australianos ni la "Scams Prevention Framework Act" de 2025.
- No se verificó si el BIESS ya exige que la cuenta destino sea del titular, ni si hay un periodo de espera entre el cambio de datos y la solicitud de préstamo.

## 2. Persona de confianza (trusted contact) y representación digital

### Takeaway
El "contacto de confianza" es norma regulatoria en la intermediación de valores de EE. UU. (FINRA 4512, desde 2018) y lo promueven los reguladores bancarios. Sin embargo, **no existe una evaluación cuantitativa de su efecto**. La evidencia es anecdótica o indirecta (leyes de retención). Para el IESS es atractivo como canal alternativo a la "ayuda" informal del tramitador, siempre que el contacto **no tenga poder de operar**.

### Cited Findings
- FINRA Rule 4512(a)(1)(F): las firmas deben hacer un "esfuerzo razonable" por obtener nombre y datos de un contacto de confianza en cuentas no institucionales. El cliente puede negarse y la cuenta igual se abre. El contacto sirve para administrar la cuenta, proteger activos y responder ante una posible explotación o capacidad disminuida. La Rule 2165 permite **retener temporalmente desembolsos** ante sospecha de explotación. — [FINRA, 2026 Annual Regulatory Oversight Report](https://www.finra.org/rules-guidance/guidance/reports/2026-finra-annual-regulatory-oversight-report/trusted-contact-persons); [FINRA Unscripted, Rules 2165 y 4512](https://www.finra.org/media-center/finra-unscripted/rules-2165-4512)
- Una solicitud de FINRA de 2026 señala que el contacto de confianza es útil para clientes de cualquier edad. — [SR-FINRA-2026-018](https://www.finra.org/sites/default/files/2026-08/SR-FINRA-2026-018.pdf)
- Prácticas: algunas firmas forman a sus representantes para pedir el contacto a todos los clientes, con guiones y formularios que responden a dudas de privacidad. — [FINRA, effective practices](https://www.finra.org/rules-guidance/key-topics/senior-investors/protecting-senior-investors-2015-2020/effective-practices-from-firms-senior-investor-protection-programs)
- Guía interagencial de reguladores bancarios de EE. UU.: los bancos pueden tener políticas de contacto de confianza. Salvo autorización aparte, el contacto **no puede ver la cuenta ni hacer transacciones**. — [Federal Reserve, Interagency Statement on Elder Financial Exploitation](https://www.federalreserve.gov/frrs/guidance/interagency-statement-on-elder-financial-exploitation.htm)
- Un estudio de 2025 sobre leyes estatales de retención encontró que la mitad de los bancos encuestados las había usado para pausar transacciones y aprovechar el tiempo para contactar a un familiar de confianza. — [FTC, State Hold Laws and Elder Financial Exploitation Prevention (2025)](https://consumer.ftc.gov/system/files/consumer_ftc_gov/pdf/State%20Hold%20Laws%20and%20Elder%20Financial%20Exploitation%20Prevention%20%282025%29.pdf)
- AARP BankSafe (formación de personal, no contacto de confianza): empleados de 500 sucursales en 11 estados evitaron cerca de USD 1 millón en pérdidas en seis meses. — [AARP, banks stop fraud](https://www.aarp.org/money/scams-fraud/banks-stop-fraud/)
- En FINRA, la evidencia sobre el efecto se limita a testimonios positivos en un podcast. Hay un trabajo preliminar (AEA 2021) que estudia la "delegación" en profesionales financieros mediante contactos de confianza, pero no se pudo confirmar su resultado. — [FINRA Unscripted](https://www.finra.org/media-center/finra-unscripted/senior-investor-protection-update); [AEA 2021, preliminar](https://www.aeaweb.org/conference/2021/preliminary/paper/RdetG2f5)
- Brasil: el bloqueo mensual de noviembre de 2025 **prohíbe desbloquear el consignado mediante procuración (poder)**, por teléfono o por canales no oficiales. — [ABC do ABC, 22-12-2025](https://abcdoabc.com.br/inss-bloqueia-consignado-mensal-travar-fraude/)

### Inferences
**Ficha 2.1 — Persona de confianza registrada (sin poder de operar)**
- Quién/dónde: EE. UU. (FINRA 4512, desde 2018; guía bancaria interagencial).
- Cómo funciona: el afiliado registra a un familiar o conocido al que el IESS/BIESS avisa (o consulta) ante eventos de riesgo: cambio de cuenta, préstamo solicitado, intento de autobloqueo. Esa persona no puede operar ni ver saldos.
- Público: jubilados, personas con discapacidad o con baja alfabetización digital.
- Evidencia: no hay medición de efecto. Es práctica regulatoria con respaldo anecdótico. Funciona mejor si va unida a una **facultad de retención** (FINRA 2165, leyes estatales).
- Costo: bajo (campo en el perfil, notificación por SMS, guion para el call center).
- Encaje con el IESS: formaliza la "ayuda" que hoy se da prestando la clave. Riesgos: el abuso viene a menudo del entorno cercano, así que el contacto no debe poder aprobar operaciones, y la elección y revocación deben ser presenciales o con verificación reforzada. LOPDP: el tercero es titular de datos y hace falta su consentimiento e información sobre el tratamiento.
- Eslabón: **E4** (aviso temprano) y, con una facultad de retención, **E3**.
- Escala: **CONVERGENTE** (norma en EE. UU.; poco presente en instituciones de seguridad social).

**Ficha 2.2 — Representación/poder digital acotado en lugar de clave prestada**
- Quién/dónde: principio presente en varios sistemas (p. ej., nominees de myGov en Australia o appointees del DWP en el Reino Unido; no se verificaron fuentes en esta ronda). Brasil, en cambio, **excluyó** la procuración para desbloquear préstamos.
- Cómo funciona: un tercero obtiene una credencial propia con permisos limitados (consultar, agendar citas) y se le niegan las operaciones de dinero.
- Evidencia: no se encontró medición.
- Costo: medio (cambio de modelo de identidad y autorización).
- Encaje: ataca de raíz el préstamo de la clave (E1) porque da al ayudante una vía legítima sin acceso a dinero. La lección brasileña es que la delegación no debe extenderse a crédito ni retiros.
- Eslabón: **E1**.
- Escala: **CONVERGENTE** como principio; las fuentes concretas están por verificar.

### Gaps
- No existe (o no se encontró) ninguna evaluación cuantitativa de la Rule 4512 ni de los contactos de confianza bancarios. El hallazgo de la CFPB citado por AARP no se pudo consultar.
- No se verificaron los mecanismos de nominee/appointee de Services Australia, del DWP ni de la "persona de confianza" en la banca latinoamericana.

## 3. Canales oficiales verificables y reporte ciudadano

### Takeaway
Los controles de canal (registro obligatorio de remitentes SMS, DMARC en dominios de gobierno, verificadores "¿es estafa?" y números cortos de reporte) son **CENTRO** y tienen las cifras de efecto más claras: −70 % de casos con SMS en Singapur, unos 500 millones de correos bloqueados por DMARC en HMRC, 460.000 URL retiradas por el NCSC y ₹8.189 crore salvados por el 1930 de la India. Australia volvió obligatorio su registro de remitentes en julio de 2026. El reporte solo reduce el daño si cierra el ciclo (derribo, bloqueo o congelamiento).

### Cited Findings
- **Singapur SSIR**: el registro obligatorio de remitentes SMS (desde el 31-01-2023) redujo un 70 % los casos con SMS fraudulentos en tres meses (vía informe previo). — [Smart Nation, SSIR](https://www.smartnation.gov.sg/initiatives/ssir)
- **Australia, SMS Sender ID Register (ACMA)**: obligatorio desde el **1-07-2026**. Solo se pueden enviar SMS o MMS con un sender ID registrado. Los no registrados aparecen como "Unverified" en un hilo único del teléfono. Las telcos se exponen a multas de hasta A$250.000 por infracción, y el sender ID debe coincidir con el nombre comercial, la marca o el dominio registrado. — [ACMA, "goes live", 06-2026](https://www.acma.gov.au/articles/2026-06/sms-sender-id-register-goes-live-help-protect-australians-scams); [ACMA, llamada a organizaciones, 11-2025](https://www.acma.gov.au/articles/2025-11/call-action-all-organisations-using-branded-sms); [business.gov.au](https://business.gov.au/news/new-rules-for-businesses-sending-text-messages). No se encontraron datos de resultado posteriores al lanzamiento.
- **ScamShield (Singapur, GovTech/OGP)**: bloquea llamadas de números marcados como estafa, filtra SMS de remitentes desconocidos a una carpeta de basura con un modelo **en el dispositivo** (los mensajes no salen al servidor) y permite consultar mensajes, llamadas, enlaces y capturas de pantalla, incluidos WhatsApp y Telegram. Desde mayo de 2022 ha bloqueado más de 120.000 entidades de estafa y suma más de 900.000 descargas (página sin fecha). En sus primeros seis meses recibió 722.865 SMS reportados y bloqueó 5.537 números; se le atribuye una precisión del 95 % en el lanzamiento. La SPF advierte que no es infalible. — [GovTech, ScamShield](https://www.tech.gov.sg/products-and-services/for-citizens/scam-prevention/scamshield/); [GovInsider](https://govinsider.asia/intl-en/article/meet-singapores-latest-weapon-against-scams-open-government-products-scamshield); [ScamShield, setup](https://www.scamshield.gov.sg/about-scamshield/scamshield-app/set-up-scamshield-app/)
- **Reino Unido**: el servicio de reporte de correos sospechosos del NCSC acumula más de 58,9 millones de reportes y unas 460.000 URL retiradas desde 2020 (vía informe previo). — [NCSC Annual Review 2026](https://www.ncsc.gov.uk/collection/annual-review-2026/building-strong-foundations/securing-uks-internet). HMRC atribuye a DMARC el bloqueo de unos 500 millones de correos de phishing (vía informe previo). — [ITPro](https://www.itpro.com/scams/31432/hmrc-takes-down-record-number-of-malicious-websites-in-scam-crackdown)
- **India 1930**: la línea permite congelar fondos en la "hora dorada" y evitó pérdidas por ₹8.189 crore entre 2021 y 2025 (vía informe previo, fuente periodística que cita una respuesta en el Rajya Sabha). — [Asianet Newsable](https://newsable.asianetnews.com/gallery/india/cyber-crime-controls-prevent-rs-8189-crore-loss-since-2021-govt-in-rajya-sabha-rncuib2)
- **España 017 (INCIBE)**: pasó de 98.546 consultas en 2024 a 138.003 en 2025 (+40 %), el 47 % por phishing, smishing o vishing (vía informe previo). — [INCIBE, balance 2024](https://www.incibe.es/incibe/sala-de-prensa/incibe-presenta-su-balance-de-ciberseguridad-2024-con-mas-de-97000-incidentes); [Min. Transformación Digital, 26-12-2025](https://digital.gob.es/gl/comunicacion/notas-prensa/secretaria-estado-telecomunicaciones-e-infraestructuras-digitales/2025/12/2025-12-26)
- **Contraejemplo**: en Filipinas, el registro de SIM no impidió que las llamadas fraudulentas subieran un 225 % en el 1T 2025 (vía informe previo). — [ABS-CBN](https://www.abs-cbn.com/news/nation/2025/4/3/dict-chief-appeals-for-the-use-of-cybertechnology-for-public-good-1751)
- **Singapur 2026**: el MAS anuncia notificaciones en la app bancaria para verificar si una llamada entrante es realmente del banco. — [MAS, 13-01-2026](https://www.mas.gov.sg/news/parliamentary-replies/2026/written-reply-on-effectiveness-of-requirements-imposed-by-mas-on-banks-to-protect-against-scams)

### Inferences
**Ficha 3.1 — Registro obligatorio de remitentes SMS (Sender ID)**
- Quién/dónde: Singapur (2023), Australia (2026) y Reino Unido (registro voluntario de protección de remitentes de Mobile Ecosystem Forum; no verificado en esta ronda).
- Cómo funciona: solo los remitentes alfanuméricos registrados llegan con su nombre; el resto se etiqueta o se bloquea.
- Evidencia: −70 % de casos con SMS en Singapur en tres meses. Australia aún sin datos.
- Costo: para el IESS, bajo (registrarse). La medida país depende de ARCOTEL y las operadoras.
- Encaje: el IESS no puede imponerlo solo, pero puede **impulsarlo** y, mientras tanto, usar siempre un remitente constante y publicado. Corresponde a otro reto o a una política pública; en el Reto 1 cuenta como dependencia.
- Eslabón: **E1** (phishing con marca IESS).
- Escala: **CENTRO**.

**Ficha 3.2 — DMARC p=reject en dominios gob.ec / iess.gob.ec**
- Evidencia: unos 500 millones de correos bloqueados en HMRC.
- Costo: muy bajo.
- Encaje: inmediato y técnico; conviene verificar el registro DMARC actual de iess.gob.ec (no comprobado).
- Eslabón: **E1**.
- Escala: **CENTRO**.

**Ficha 3.3 — Verificador "¿es oficial / es estafa?" (estilo ScamShield) y lista pública de canales oficiales**
- Cómo funciona: el ciudadano reenvía o consulta un número, enlace o captura y recibe un veredicto, con una lista cerrada de números, remitentes y cuentas oficiales del IESS.
- Evidencia: uso masivo en Singapur (900.000 descargas, 120.000 entidades bloqueadas), sin efecto causal publicado.
- Costo: medio. Una versión mínima (bot de WhatsApp o número corto que contesta "este número es o no es del IESS") es barata; un clasificador con IA cuesta más y exige gobernanza.
- Encaje: alto para el Reto 1, porque es demostrable con datos ficticios. Riesgo: un verificador falso imitado por estafadores (criterio "no imitable"). Debe vivir dentro de canales ya verificados (app IESS, número publicado, cuenta de WhatsApp Business verificada). LOPDP: minimizar y no guardar el contenido de los mensajes; el procesamiento en el dispositivo, como en ScamShield, es la referencia.
- Eslabón: **E1**.
- Escala: **CONVERGENTE**.

**Ficha 3.4 — Número corto nacional de reporte con capacidad de congelar (1930, 7726, 017)**
- Evidencia: India atribuye ₹8.189 crore salvados al congelamiento en la "hora dorada". El NCSC muestra que el reporte masivo alimenta los derribos.
- Encaje: para el IESS, una línea o botón "me robaron la clave / no reconozco este préstamo" que **dispare de inmediato el bloqueo** (ficha 1.3) y avise al BIESS. Sin esa conexión, el reporte no reduce el daño.
- Eslabón: **E4→E3** (frena el desembolso o la siguiente operación).
- Escala: **CENTRO**.

### Gaps
- No se obtuvieron datos posteriores al lanzamiento del registro australiano (julio de 2026) ni cifras actualizadas de ScamShield para 2025-2026.
- No se investigaron en esta ronda la verificación de cuentas de gobierno en WhatsApp Business ni los verificadores de números oficiales en América Latina.
- No se comprobó el estado de DMARC de iess.gob.ec ni si Ecuador tiene un registro de remitentes SMS.

## 4. Autenticación fuerte pero inclusiva y sus modos de fallo

### Takeaway
La convergencia va hacia **autenticación resistente al phishing (passkeys) y ligada a la acción** (Smart-ID+ en Estonia desde febrero de 2026), y hacia la biometría para operaciones de dinero (Brasil). Los modos de fallo están bien documentados: el usuario aprueba bajo engaño (Estonia, €29 M en 2025) y se burla la biometría con fotos y documentos manipulados (Brasil). En un país con 10 millones de fotos de cédula filtradas, la biometría sin detección de vida no es suficiente.

### Cited Findings
- Estonia: sus ciudadanos perdieron €29 millones en 2025, en gran parte porque los estafadores los convencían por teléfono de aprobar operaciones con su propio Smart-ID (vía informe previo). — [RIA](https://www.ria.ee/en/surge-scams-costs-estonian-people-29-million-euros)
- **Smart-ID+** entró en servicio en los e-servicios del Estado el **26-02-2026**. El inicio de sesión mediante QR asegura que la sesión queda ligada al dispositivo del usuario, y su objetivo declarado es reducir la ingeniería social y el fraude telefónico. Los bancos lo adoptan en 2026 (Bigbank fue el primero, en junio de 2026; Swedbank y SEB lo planificaban para ese año). — [RIA, 26-02-2026](https://ria.ee/en/news/smart-id-introduced-26-february-more-secure-login-state-e-services); [SK ID Solutions](https://www.skidsolutions.eu/news/estonias-government-adopts-smart-id-to-strengthen-security/); [EMTA](https://emta.ee/ru/novosti/s-26-fevralya-izmenilas-autentifikaciya-elektronnykh-uslug-s-pomoschyu-smart-id); [Bigbank](https://www.bigbank.eu/blog/bigbank-to-become-the-first-bank-to-adopt-the-more-secure-smart-id-authentication-protocol/); [ERR News](https://news.err.ee/1610054356/banks-taking-on-scammers-with-new-smart-id-upgrade). No hay resultados publicados del efecto de Smart-ID+.
- Los bancos estonios advierten que ni las medidas más estrictas protegen al cliente que comparte sus credenciales Smart-ID. — [ERR News](https://news.err.ee/1609913731/banks-even-strict-security-measures-may-not-protect-customers-from-fraud)
- Services Australia (myGov) promueve las passkeys porque no funcionan en sitios falsos. Detectó más de 10.000 suplantaciones únicas en 2023-24, el 86 % mencionando myGov (vía informe previo). — [Services Australia, passkey](https://www.servicesaustralia.gov.au/increase-security-your-mygov-account-with-passkey); [Services Australia, columna](https://www.servicesaustralia.gov.au/hank-jongens-may-column-scams)
- Singapur elimina progresivamente el OTP por SMS en operaciones de alto riesgo porque los estafadores lo obtienen con facilidad. — [MAS, 13-01-2026](https://www.mas.gov.sg/news/parliamentary-replies/2026/written-reply-on-effectiveness-of-requirements-imposed-by-mas-on-banks-to-protect-against-scams)
- Brasil exige biometría facial para consignados y para autorizar descuentos, y los defraudadores ya la habían burlado con fotos y documentos manipulados (vía informe previo). — [Metrópoles](https://www.metropoles.com/brasil/inss-vai-exigir-biometria-de-aposentados-para-autorizar-descontos); [Gazeta do Povo](https://www.gazetadopovo.com.br/economia/entidades-fotos-manipuladas-fraudar-biometria-inss/). Para quien no tiene biometría en las bases del gobierno se acepta el inicio de sesión gov.br hecho en el banco, y el INSS planea terminales biométricos para mayores y personas con discapacidad. — [Seu Crédito Digital](https://seucreditodigital.com.br/inss-desbloqueio-emprestimo-consignado/); [ABC do ABC](https://abcdoabc.com.br/inss-bloqueia-consignado-mensal-travar-fraude/)
- SEB (Estonia y región báltica) frenó más de la mitad de los intentos de fraude en 2025 con analítica de Feedzai (no atribuible a Smart-ID+). — [Baltic Times](https://www.baltictimes.com/seb_successfully_stopped_over_half_of_all_fraud_attempts_in_2025)

### Inferences
**Ficha 4.1 — Segundo factor y passkeys para el portal IESS**
- Cómo funciona: la passkey (FIDO2) en el teléfono del afiliado queda ligada al dominio real y no sirve en un sitio clonado.
- Público: afiliados activos con smartphone (57,7 % de la población tiene uno, según el informe previo). No resuelve el caso de los jubilados sin dispositivo propio.
- Evidencia: resistencia al phishing por diseño. No se encontró medición poblacional del efecto en el fraude.
- Costo: medio (integración en el portal y la app, soporte y recuperación de cuenta).
- Encaje: necesario, aunque no corta el préstamo voluntario de la clave. Si el afiliado entrega el teléfono o aprueba bajo engaño, el ataque sigue (lección de Estonia). Debe acompañarse de 1.1 y 1.4.
- Eslabón: **E1** (phishing). Débil frente al préstamo de la credencial.
- Escala: **CONVERGENTE** (myGov, eliminación del OTP SMS en Singapur, NIST).

**Ficha 4.2 — Aprobación ligada a la acción ("action binding": lo que apruebas es lo que ves)**
- Quién/dónde: Smart-ID+ (Estonia, 2026); en la UE, la autenticación reforzada con vinculación dinámica de PSD2.
- Cómo funciona: la aprobación muestra en el dispositivo del titular la operación concreta ("Préstamo quirografario USD 8.000 a la cuenta ****1234 del Banco X") y solo vale si la sesión la inició ese mismo dispositivo (QR o vinculación al dispositivo), lo que impide que un estafador inicie la sesión y la víctima la apruebe.
- Evidencia: no hay resultados publicados.
- Costo: medio a alto si se construye desde cero.
- Encaje: para el Reto 1 se puede prototipar como "pantalla de confirmación con contexto y pausa" en la solicitud de préstamo, con texto en lenguaje llano y audio.
- Eslabón: **E3**.
- Escala: **CONVERGENTE**.

**Ficha 4.3 — Biometría con detección de vida, presencial o asistida, para operaciones de dinero**
- Quién/dónde: Brasil INSS (2022-2025).
- Evidencia: el sector reporta −88 % en reclamaciones, pero hubo burlas con fotos manipuladas, errores de bloqueo y colas de 500.000 pedidos.
- Costo: medio a alto (proveedor de liveness, terminales en agencias).
- Encaje: válida para el desbloqueo del préstamo (1.4) solo con detección de vida certificada y alternativa presencial. LOPDP: los datos biométricos son datos sensibles y exigen base legal específica y una evaluación de impacto. Riesgo agravado por la filtración de fotos de cédula en Ecuador.
- Eslabón: **E3**.
- Escala: **CONVERGENTE**, con modo de fallo documentado.

**Ficha 4.4 — Autenticación basada en riesgo (dispositivo nuevo, IP o horario atípicos)**
- Encaje: dispara el enfriamiento (1.1) o una verificación extra. Es la versión dinámica del SRF de Singapur ("dispositivo nuevo → 12 h").
- Escala: **CENTRO** en banca.

### Gaps
- No hay datos públicos sobre el efecto de Smart-ID+ ni de las passkeys de myGov en el fraude.
- No se encontraron estudios de usabilidad de las passkeys en adultos mayores con baja alfabetización digital.
- No se verificó el artículo exacto de la LOPDP sobre datos biométricos y decisiones automatizadas (art. 20 sobre decisiones automatizadas: por verificar).

## 5. Analítica de fraude a nivel de transacción (cambio de datos → préstamo) y sus riesgos

### Takeaway
La detección de anomalías en la secuencia "dispositivo, contacto o cuenta nuevos y luego préstamo o retiro" es práctica bancaria central y el DWP la usa en prestaciones (modelo de anticipos de Universal Credit, al que atribuye haber reducido a menos de la mitad el fraude estimado). También muestra disparidades por edad, discapacidad y nacionalidad. Robodebt y el toeslagenaffaire marcan el límite: la analítica debe **retener y verificar**, nunca decidir sanciones ni deudas de forma automática.

### Cited Findings
- **DWP, modelo de aprendizaje automático para anticipos de Universal Credit**: en 2024-25 se concedieron 1,4 millones de anticipos por £0,8 mil millones. El DWP afirma que el modelo contribuyó a reducir "a más de la mitad" la escala estimada del problema. Su evaluación de equidad (julio de 2025) encontró disparidades estadísticas, pero concluyó que seguir usándolo es "razonable y proporcionado". El modelo se reentrena y el caso marcado lo revisa una persona. — [GOV.UK, Fairness assessment UC Advances 2024-25](https://www.gov.uk/government/publications/fairness-assessment-including-statistical-analysis-of-the-universal-credit-advances-machine-learning-model-1-april-2024-to-31-march-2025/universal-credit-advances-model-fairness-assessment); [Algorithmic Transparency Record](https://www.gov.uk/algorithmic-transparency-records/dwp-universal-credit-advances-model)
- Críticas: el NAO advirtió del riesgo inherente de sesgo contra grupos con características protegidas. El Public Law Project y Computer Weekly informaron de disparidades por edad, discapacidad y nacionalidad. — [UKAuthority, NAO](https://ukauthority.com/articles/nao-raises-questions-over-dwp-use-of-machine-learning); [Computer Weekly](https://www.computerweekly.com/news/366616983/DWP-fairness-analysis-reveals-bias-in-AI-fraud-detection-system); [Public Law Project](https://publiclawproject.org.uk/latest/dwp-needs-to-assess-bias-in-its-automated-systems-says-committee/)
- La IMA (Reino Unido) concluyó que el DWP tiene salvaguardas eficaces contra el sesgo por nacionalidad en el modelo de anticipos (página fechada el 06-08-2026). — [IMA](https://ima-citizensrights.org.uk/?p=10832)
- **Robodebt (Australia)**: la Comisión Real entregó su informe final el 7-07-2023 y lo calificó de mecanismo "tosco y cruel, ni justo ni legal". Hubo remisiones a la APSC, la NACC y la AFP. Los montos de los acuerdos varían según la fuente: A$1.200 millones en 2020 y un acuerdo adicional de A$475 millones, que otra fuente reporta como USD 309 millones (probablemente la misma cifra en otra moneda). — [PM, Final report](https://www.pm.gov.au/media/final-report-royal-commission-robodebt-scheme); [APRA, resumen](https://www.apra.gov.au/sites/default/files/2024-02/Robodebt%20Royal%20Commision%20-%20Overview%20of%20Final%20Report.pdf); [Canberra Times](https://www.canberratimes.com.au/story/9058440/bill-shorten-acoss-welcome-475m-settlement-for-robodebt-victims/); [Yahoo/Reuters](https://www.yahoo.com/news/articles/australia-agrees-record-309-million-045213909.html)
- **Toeslagenaffaire (Países Bajos)**: la autoridad de protección de datos (AP) multó a la Administración Tributaria con €2,75 millones (diciembre de 2021) por tratar durante años la (doble) nacionalidad de los solicitantes de ayuda para guardería de forma ilegal y discriminatoria. Los datos de doble nacionalidad de 1,4 millones de personas seguían en sus sistemas en mayo de 2018. En abril de 2022 llegó otra multa de €3,7 millones por una lista negra de sospechosos de fraude. — [IAPP](https://iapp.org/news/a/dutch-dpa-fines-tax-authority-2-75m-euros); [DutchNews, 04-2022](https://www.dutchnews.nl/2022/04/tax-office-fined-e3-7m-for-breaking-privacy-law-with-fraud-suspect-blacklist)
- Brasil: un comando erróneo de Dataprev interpretó solicitudes legítimas como fraude y bloqueó beneficios por error. — [Correio da Manhã, 07-2025](https://www.correiodamanha.com.br/economia/2025/07/211977-cresce-o-cerco-a-tentativas-de-golpes-contra-vulneraveis.html)
- Singapur: los bancos deben tener detección de fraude en tiempo real desde mediados de 2025 y retener 24 h las operaciones que vacían la cuenta rápidamente. — [Singapore Law Watch](https://singaporelawwatch.sg/Headlines/banks-to-have-real-time-fraud-detection-from-mid-2025-under-new-scam-prevention-framework); [ABS, 2025](https://abs.org.sg/docs/library/banks-to-launch-enhanced-safeguards-from-15-oct-2025-to-better-protect-accounts_.pdf)

### Inferences
**Ficha 5.1 — Regla/score de secuencia "cambio de datos → préstamo o retiro" con retención y verificación humana**
- Cómo funciona: reglas simples y explicables (cambio de correo o celular, más cuenta nueva, más solicitud de quirografario en menos de N días; operación desde un dispositivo nuevo; cuenta destino compartida por varios afiliados, señal típica de mula o tramitador; servidor que modifica datos de muchos afiliados) que llevan a una **retención** y a una verificación con el titular por el canal anterior, nunca a un rechazo o sanción automáticos.
- Quién/dónde: banca (Singapur, SEB/Feedzai), DWP (anticipos de UC) e INSS/Dataprev.
- Evidencia: el DWP afirma haber reducido el fraude en anticipos a menos de la mitad (autorreporte). SEB frenó más de la mitad de los intentos.
- Costo: bajo si se usan reglas; medio a alto con ML y la auditoría de equidad que exige.
- Encaje: alto, y muy demostrable con datos sintéticos. La regla "cuenta destino compartida por varios afiliados" ataca también al tramitador y al servidor cómplice (riesgo interno). LOPDP: es un tratamiento con perfilado; hace falta base legal (interés público o cumplimiento), información al titular, derecho a intervención humana y una evaluación de impacto. El caso neerlandés indica excluir variables como la nacionalidad o la etnia y no crear listas negras. El de Robodebt, no automatizar deudas ni sanciones. Hay que medir el sesgo por edad y por zona rural, porque los jubilados rurales podrían concentrar falsos positivos.
- Eslabón: **E3** (antes del desembolso) y **E4**.
- Escala: **CENTRO** en banca; **CONVERGENTE** en instituciones de prestaciones.

### Gaps
- No se obtuvo la tasa de falsos positivos del modelo del DWP ni el detalle de sus disparidades (el fragmento de Computer Weekly estaba incompleto).
- No se encontró información pública sobre los modelos antifraude de Dataprev/INSS para el consignado.
- Las cifras de los acuerdos de Robodebt discrepan entre fuentes; hay que verificarlas antes de citarlas.

## 6. Inoculación / prebunking con resultados medidos y necesidad de refuerzos

### Takeaway
La inoculación activa (practicar con ejemplos reales y falsos y recibir retroalimentación) mejora la detección de fraude unos 7 puntos porcentuales sin reducir la confianza en los mensajes legítimos, pero **el efecto decae en semanas**: es significativo a los 3,5 y 11,5 días y deja de serlo a las 4 semanas. Los avisos y folletos estáticos no tuvieron efecto. Las campañas de prebunking en video de Jigsaw logran mejoras pequeñas (1,8 % a 5,4 %) a escala de decenas de millones de visualizaciones, y no hay evaluaciones por edad. El refuerzo periódico es imprescindible.

### Cited Findings
- **Robb y Wendel (2022/2023, Journal of Consumer Policy 46(1):27-51)**, para la SSA/AARP: ensayos aleatorizados con 4.164 participantes (Prolific; muestras por cuotas representativas de adultos de EE. UU.). Cuatro brazos: entrenamiento interactivo, consejos escritos, materiales de aviso existentes de la SSA y control. Solo el entrenamiento interactivo tuvo efecto: los aciertos pasaron de 8,11 a 8,93 sobre 12 (p<0,001), unos 7 puntos porcentuales (~10 %). Los consejos escritos y los materiales de la SSA **no tuvieron efecto significativo**. El efecto se concentró en el correo; no lo hubo en SMS y en cartas fue solo sugerente. El aprendizaje se transfirió a otras marcas (Amazon, Cruz Roja) y a otra interfaz. Las etiquetas erróneas de mensajes reales como falsos bajaron de 1,65 a 1,26, sin pérdida de confianza. **Decaimiento**: +1,1 aciertos a los 3,5 días (mediana), +0,56 a los 11,5 días y sin diferencia significativa a las 4 semanas. — [PMC9786522](https://pmc.ncbi.nlm.nih.gov/articles/PMC9786522); [AARP](https://www.aarp.org/money/scams-fraud/info-2022/social-security-scams-studies.html); [Boston College CRR](https://crr.bc.edu/people-can-spot-a-scam-after-seeing-fakes)
- Antecedente: Scheibe, Notthoff, Menkin, Ross, Shadel, Deevy y Carstensen (2014), "Forewarning reduced fraud susceptibility in vulnerable consumers" (sus detalles no se consultaron). — [PMC6005691, lista de referencias](https://pmc.ncbi.nlm.nih.gov/articles/PMC6005691)
- **Jigsaw/Google/Moonshot**: en Alemania (2023) un video de prebunking en Facebook, Instagram y YouTube superó los 42 millones de visualizaciones y mejoró la detección de técnicas (whataboutism, descontextualización) un 5,4 % de media, con más efecto en los jóvenes; el público objetivo tenía entre 18 y 55 años. En Indonesia (2023, 18-34 años) la mejora fue del 1,8 %. En la campaña de Ucrania se incluyó a mayores de 55 años, pero no se hallaron resultados por edad. Son datos del diseñador de la campaña. — [Jigsaw, Medium](https://medium.com/jigsaw/prebunking-to-build-defenses-against-online-manipulation-tactics-in-germany-a1dbfbc67a1a); [Moonshot, Building Resilience to Misinformation in Europe](https://moonshotteam.com/wp-content/uploads/Building-Resilience-to-Misinformation-in-Europe.pdf)
- Un estudio de 2025 en *Communications Psychology* con 19.735 personas de 12 países de la UE encontró que videos cortos de prebunking reducen la susceptibilidad a la desinformación (campaña UE 2024). — [Springer, s44271-025-00379-3](https://link.springer.com/article/10.1038/s44271-025-00379-3)
- AARP Fraud Watch: la línea de ayuda atendió más de 100.000 llamadas en 2023 con más de 800 voluntarios formados durante al menos 20 horas (vía informe previo). — [Testimonio Nofziger, Senado de EE. UU.](https://www.banking.senate.gov/imo/media/doc/nofziger_testimony_9-12-24.pdf)
- Take Five (Reino Unido): solo el 20 % de los mayores de 65 conocía los fraudes comunes, aunque el 87 % se creía capaz de detectarlos (vía informe previo). — [UK Finance](https://www.ukfinance.org.uk/news-and-insight/press-release/eyes-down-remember-take-five)

### Inferences
**Ficha 6.1 — Inoculación interactiva con ejemplos de mensajes con marca IESS (reales y falsos) y refuerzos**
- Cómo funciona: microejercicios de 3 a 5 minutos ("¿real o falso?") con retroalimentación inmediata, en salas de espera, la app, WhatsApp o el IVR, más refuerzos cada 2 a 3 semanas, porque a las 4 semanas el efecto desaparece.
- Público: jubilados y afiliados. El formato debe ser audio y visual para quien tiene baja alfabetización.
- Evidencia: +7 pp en un ensayo aleatorizado, sin pérdida de confianza; los avisos estáticos no tuvieron efecto.
- Costo: bajo a medio (contenidos y distribución). El mayor costo es sostener los refuerzos.
- Encaje: es el componente "cultura" que encaja de lleno en el Reto 1. Los mensajes deben anclarse en reglas fijas e institucionales ("el IESS nunca pide tu clave", "nadie puede pedirte un préstamo a tu nombre", "si cambian tus datos te avisamos y tienes X horas para frenarlo"), lo que lo conecta con 1.1 a 1.4. El ensayo no encontró efecto en SMS, que es el canal dominante en Ecuador, así que hay que diseñar y medir específicamente para SMS y WhatsApp. Faltan escenarios de "ayudante" presencial (préstamo de clave), que el ensayo no cubre.
- Eslabón: **E1** (resistencia a pedir o entregar la clave) y **E4** (saber reconocer y reportar).
- Escala: **CONVERGENTE** (AARP, SSA, Jigsaw y UE; la evidencia es sólida pero su efecto se apaga rápido).

**Ficha 6.2 — Prebunking en video masivo (redes sociales, televisión, salas de espera)**
- Evidencia: efecto pequeño (1,8 % a 5,4 %) a gran escala; sin datos en mayores.
- Costo: medio (pauta publicitaria).
- Encaje: complemento, no núcleo. Útil en salas de espera del IESS y en radio comunitaria.
- Eslabón: **E1**.
- Escala: **CONVERGENTE** en desinformación; **PERIFERIA** aplicado al fraude de prestaciones.

### Gaps
- No se encontraron estudios de inoculación contra fraude **presencial** (tramitador, "ayudante") ni en población rural o indígena.
- No se localizó evidencia sobre la frecuencia óptima de refuerzo más allá del decaimiento observado a las 4 semanas.
- Jigsaw no publica resultados por edad; las cifras son del propio diseñador.

---

### Resumen de mapeo (para el redactor; las posiciones en la escala son inferencias de estas notas)

| # | Solución | Eslabón que corta | Escala | Evidencia de efecto | Costo para el IESS |
|---|---|---|---|---|---|
| 1.1 | Enfriamiento tras cambio de contacto, cuenta o dispositivo | E2→E3 | CENTRO | Agregada (Singapur −26 % de casos, 1S 2025) | Bajo |
| 1.2 | Aviso al canal anterior (correo **y** celular) | E2, E4 | CENTRO | Sin medición aislada | Muy bajo |
| 1.3 | Autobloqueo / kill switch (también activable por la familia) | E3, E4 | CONVERGENTE | Sin cifras | Bajo-medio |
| 1.4 | Préstamo y retiro bloqueados por defecto, con desbloqueo reforzado por operación | E3 | CONVERGENTE | Brasil: −70 % a −88 % en reclamaciones (sector) | Bajo técnico / alto comercial |
| 1.5 | Verificar que la cuenta destino es del titular (tipo CoP) | E2/E3 | CENTRO en pagos | Reino Unido: −59 % "cuenta incorrecta" | Medio |
| 2.1 | Persona de confianza sin poder de operar | E4 (E3 con retención) | CONVERGENTE | Sin medición | Bajo |
| 2.2 | Delegación digital acotada en vez de clave prestada | E1 | CONVERGENTE | Sin medición | Medio |
| 3.1 | Registro de remitentes SMS | E1 | CENTRO | Singapur −70 % | Bajo (depende de ARCOTEL) |
| 3.2 | DMARC p=reject | E1 | CENTRO | HMRC ~500 M correos | Muy bajo |
| 3.3 | Verificador "¿es oficial?" / ScamShield | E1 | CONVERGENTE | Uso masivo, sin efecto causal | Bajo-medio |
| 3.4 | Línea de reporte conectada a bloqueo inmediato | E4→E3 | CENTRO | India ₹8.189 crore | Bajo-medio |
| 4.1 | Passkeys / segundo factor | E1 | CONVERGENTE | Por diseño | Medio |
| 4.2 | Aprobación ligada a la acción con contexto | E3 | CONVERGENTE | Sin datos (Smart-ID+ 2026) | Medio-alto |
| 4.3 | Biometría con detección de vida para dinero | E3 | CONVERGENTE (fallo documentado) | Brasil, con burlas | Medio-alto, LOPDP sensible |
| 4.4 | Autenticación basada en riesgo | E1/E3 | CENTRO (banca) | Indirecta | Medio |
| 5.1 | Reglas de secuencia → retención y verificación humana | E3, E4 | CENTRO banca / CONVERGENTE prestaciones | DWP "más de la mitad" (autorreporte) | Bajo (reglas) a alto (ML) |
| 6.1 | Inoculación interactiva y refuerzos cada 2-3 semanas | E1, E4 | CONVERGENTE | ECA +7 pp, se apaga a las 4 semanas | Bajo-medio |
| 6.2 | Prebunking en video | E1 | CONVERGENTE / PERIFERIA | +1,8 % a 5,4 % | Medio |

Inferencia transversal: los únicos controles con resultados grandes y medidos (Brasil, Singapur, Reino Unido) **no dependen de que el usuario no se equivoque**. Añaden tiempo o fricción entre el cambio de datos y el dinero, y lo hacen sin depender de que el jubilado reconozca el engaño. La cultura (sección 6) gana efecto cuando enseña reglas institucionales que existen de verdad ("si cambian tus datos, el préstamo queda congelado X horas y te llamamos"). Para el Reto 1 conviene combinar una pieza de cultura (inoculación con refuerzo y reporte) con al menos una pieza de proceso (1.1, 1.3 o 1.4) presentada como dependencia que la cultura vuelve visible y utilizable.
