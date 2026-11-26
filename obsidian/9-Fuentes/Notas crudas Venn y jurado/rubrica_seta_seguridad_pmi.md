---
tags: [rubrica, venn, seta, seguridad, pmi, reto1, iess]
fecha: 2026-11-25
contexto: "Hackatón Código Confianza IESS 2026, Reto 1 «Seguridad inteligente, cultura consciente»"
reutiliza: "1-Investigacion/07, 08, 09 y 2-Soluciones/10 (bóveda Hackaton-IESS-Reto1)"
---

# Rúbrica S · E · G para clasificar ideas del Reto 1 en un diagrama de Venn

## En pocas palabras
| Punto | Contenido |
|---|---|
| Qué es | 21 criterios (7 por círculo) que un equipo puntúa de 0 a 2 en un minuto cada uno, más 5 criterios transversales de inclusión |
| Regla para «tocar» un círculo | Al menos **8 de 14 puntos** en ese círculo **y** el criterio puerta del círculo (S1, E1 o G1) en **2** |
| Veto | Si S6 = 0 (la idea crea un vector de fraude) o la idea coincide con un atípico negativo N1 a N8, queda **fuera del Venn**, en zona roja, sin importar sus puntos |
| Inclusión | No es un cuarto círculo: es un modificador (0 a 10) que se dibuja como color del punto y que condiciona la entrada al centro S∩E∩G para ideas dirigidas a ciudadanos |
| Coherencia con la bóveda | Los criterios recogen y no contradicen [[09 Criterios de diseno]], [[07 Evidencia cientifica]], [[08 Vision PMI e ingenieria]] y [[10 Criterios de decision]]; las señales de alarma de esa nota se reutilizan |
| Corrección a la consigna | **NIST SP 800-16 Rev. 1 nunca se publicó como versión final** (borradores de 2009, 2013 y 2014). La SP 800-50 Rev. 1 (septiembre de 2024) reemplaza tanto a la SP 800-16 de 1998 como a la SP 800-50 de 2003 |

Marcas usadas: **[V]** verificado en la fuente primaria durante esta investigación; **[S]** verificado solo en fuente secundaria; **[B]** tomado de la bóveda sin volver a verificar; **[NV]** no verificado.

---

## 1. Base de la rúbrica

### 1.1 SETA: definiciones y niveles
| Fuente (año) | Qué dice | Uso en la rúbrica | Marca |
|---|---|---|---|
| D'Arcy, Hovav y Galletta, *Information Systems Research* 20(1):79-98 (2009). [DOI 10.1287/isre.1070.0160](https://doi.org/10.1287/isre.1070.0160) | Origen del término SETA en la literatura de SI. Con 269 usuarios de 8 empresas: conocer las políticas, los programas SETA y el monitoreo aumenta la severidad y certeza percibidas de la sanción y reduce la intención de mal uso; la severidad pesa más que la certeza y el efecto varía con la moral individual | E7 (riesgo interno: dejar claras las consecuencias del abuso deliberado) y S5 | [S] (resumen y fichas bibliográficas) |
| NIST SP 800-16 (1998), *Information Technology Security Training Requirements: A Role- and Performance-Based Model*. [CSRC](https://csrc.nist.gov/pubs/sp/800/16/final) | Continuo de aprendizaje: *awareness* («la concienciación no es formación»: solo enfoca la atención), formación basada en el rol y el desempeño, y educación. Bada et al. (2019) citan textualmente la definición | E2 (rol), E1 (la concienciación sola no basta) | [S] (cita en Bada et al.); página CSRC [NV] |
| NIST SP 800-16 Rev. 1, *A Role- and Performance-Based Model* (borrador inicial 2009; 2.º borrador 2013; 3.er borrador 14-03-2014). [CSRC](https://csrc.nist.gov/pubs/sp/800/16/r1/ipd) | Formación por rol para personal con «responsabilidades significativas de seguridad», según FISMA y OPM. **Quedó en borrador** | E2 | [V] (estado de borrador) |
| NIST SP 800-50 Rev. 1, *Building a Cybersecurity and Privacy Learning Program* (12-09-2024). [CSRC](https://csrc.nist.gov/pubs/sp/800/50/r1/final) · [PDF](https://doi.org/10.6028/NIST.SP.800-50r1) | Reemplaza a SP 800-16 (1998) y SP 800-50 (2003). Abandona el continuo rígido *awareness-training-education* porque los términos se usaban de forma inconsistente (§1, refs. Haney et al. 2022) y habla de un «programa de aprendizaje» (CPLP) cuyo fin es el **cambio de conducta** y una cultura de seguridad y privacidad. Ciclo de vida: planificación y estrategia; análisis y diseño; desarrollo e implementación; evaluación y mejora (§1.3) | Marco general del círculo E | [V] |
| SP 800-50r1, §2.5 | Tres segmentos de audiencia: todos los usuarios; titulares de cuentas con acceso privilegiado; personal con responsabilidades significativas (formación por rol). Se solapan | E2 | [V] |
| SP 800-50r1, §2.7 | Elementos del programa: actividades de concienciación **continuas durante el año**, aprendizaje experiencial (simulaciones de phishing, smishing y vishing, juegos, ejercicios de mesa) y formación (síncrona, asíncrona, pódcast, cyber range) | E4, E5 | [V] |
| SP 800-50r1, §2.7.2 | Las simulaciones de phishing deben avisarse de forma general, **no ser punitivas** ni señalar a nadie; el área legal revisa los cebos para no usar marcas legítimas; recomienda la NIST Phish Scale y el botón de reporte | E7, S6 | [V] |
| SP 800-50r1, §2.4 | Métricas sugeridas, entre ellas «cambio de conducta por participante» (porcentaje que reportó correctamente un correo de prueba) y costo por participante | E6, G2 | [V] |
| SP 800-50r1, §5.2.3.3, tabla 3 | Adopta los 4 niveles de Kirkpatrick: reacción, aprendizaje, conducta y resultados (cita a Kirkpatrick 1994, *Evaluating Training Programs: The Four Levels*, Berrett-Koehler) | E6 | [V] |
| Kirkpatrick, artículos originales en *Journal of ASTD* (1959) | Origen del modelo de cuatro niveles | E6 | [NV] (fecha conocida, no consultada) |
| Puhakainen y Siponen, *MIS Quarterly* 34(4):757-778 (2010). [AISeL](https://aisel.aisnet.org/misq/vol34/iss4/9) | Investigación-acción: formación basada en teoría (teoría instruccional constructiva universal y modelo de probabilidad de elaboración). Funcionó cuando el contenido y el método **activaban el procesamiento cognitivo sistemático** del aprendiz, y hizo falta un **proceso de comunicación continuo** para sostener el cumplimiento | E3, E5 | [S] (resumen) |
| Karjalainen y Siponen, *JAIS* 12(8):518-555 (2011). [AISeL](https://aisel.aisnet.org/jais/vol12/iss8/3) · DOI 10.17705/1jais.00274 | Metateoría basada en los tres niveles de pensamiento de Hare: define **cuatro requisitos pedagógicos** para diseñar y evaluar formación en seguridad y concluye que ningún enfoque existente los cumplía todos | E3 | [S]; **los cuatro requisitos no se pudieron leer** (texto completo bloqueado) [NV] |
| Bada, Sasse y Nurse, «Cyber Security Awareness Campaigns: Why do they fail to change behaviour?», ICCSSS 2015; arXiv 2019. [arXiv 1901.02672](https://arxiv.org/abs/1901.02672) | La información no basta: la persona debe entender y poder aplicar el consejo y estar motivada. Fallan cuando no se alinean con riesgos, no miden progreso ni valor, suponen mal la motivación o se quedan en cumplimiento. Recomiendan: preparación profesional; **no usar el miedo**; educación **dirigida, accionable, realizable y con retroalimentación**; formación y retroalimentación continuas durante el cambio; atender el **contexto cultural**; reglas simples y consistentes que den sensación de control; medir por **reducción del riesgo**, no por lo que la gente sabe | E1, E3, E4, E6, E7, I3 | [V] |
| Prümmer, van Steen y van den Berg, *Computers & Security* 136 (2024). [DOI 10.1016/j.cose.2023.103585](https://doi.org/10.1016/j.cose.2023.103585) | Revisión sistemática de 142 estudios: la mayoría reporta efectos positivos, pero con diseños débiles (pre-post sin control, muestras pequeñas, poblaciones no laborales); el juego es el método más usado. Un metaanálisis posterior de los mismos autores encontraría efecto global d = 0,75 que **no se replica en medidas de conducta** | E6 (exigir medición de conducta) | Revisión [S]; metaanálisis [NV] |
| ISO/IEC 27001:2022, cláusula 7.3. [ISO](https://www.iso.org/standard/27001) | Las personas que trabajan bajo control de la organización deben conocer la política de seguridad, su contribución a la eficacia del SGSI y las implicaciones de no cumplir | E1, E7 | [S] (norma de pago; paráfrasis de [ISMS.online](https://www.isms.online/iso-27001/requirements-2022/7-3-awareness-2022/) y [Advisera](https://advisera.com/iso27001/clause-7-3-awareness/)) |
| ISO/IEC 27001:2022, Anexo A, control 6.3 «Concienciación, educación y formación en seguridad de la información» | El personal y las partes interesadas pertinentes reciben concienciación, educación y formación **adecuadas a su función** y actualizaciones periódicas de políticas y procedimientos (antes A.7.2.2 de 2013) | E2, E5 | [S] ([Advisera](https://advisera.com/iso27001/control-6-3-information-security-awareness-education-and-training/)) |
| EGSI v3, Acuerdo MINTEL-MINTEL-2024-0003 (08-02-2024). [MINTEL](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf) | Art. 9, núm. 6: el OSI debe «elaborar y coordinar el Plan de concienciación» con las áreas y con comunicación institucional; núm. 7: «fomentar la cultura»; núm. 15: informar avances al Comité. Art. 6: el Comité incluye Talento Humano, Comunicación Social y el Delegado de Protección de Datos. Disposición general cuarta: ciclo de mejora que empieza **en enero de cada año** | E5, G1, G6 | [V] |

### 1.2 Seguridad
| Fuente (año) | Qué aporta | Criterio | Marca |
|---|---|---|---|
| Cadena de fraude E1-E4 y EI (bóveda, a partir de [Expreso](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html) y [Primicias](https://www.primicias.ec/economia/iess-denuncia-falsificacion-aportes-jubilacion-fiscalia-110018/)) | El daño ocurre cuando una credencial delegada o un rol abusado permite cambiar datos y mover dinero | S1 | [B] |
| ISO/IEC 27002:2022, atributos de control. [ISO](https://www.iso.org/standard/75652.html) | Atributo «tipo de control»: preventivo, detectivo, correctivo; atributo «conceptos de ciberseguridad»: identificar, proteger, detectar, responder, recuperar (ISO/IEC TS 27110) | S2 | [S] ([Splunk](https://www.splunk.com/en_us/blog/learn/iso-27002.html), [EY](https://www.ey.com/en_be/financial-services/financial-services-alerts/what-does-the-updated-iso-27002-2022-mean-for-you)) |
| LOPDP (2021), arts. 10 (principios, incluida minimización), 20 (no ser objeto de decisiones basadas única o parcialmente en valoraciones automatizadas), 25-26 (categorías especiales: salud), 39 (protección de datos desde el diseño y por defecto), 40 (análisis de riesgos), 42 (evaluación de impacto) | Privacidad por diseño y límites a la automatización | S3, S4 | Arts. 20, 40 y 42 [S]; arts. 25-26 y 39 [B] |
| Res. SPDP-SPD-2026-0009-R, norma general sobre IA (firmada 12-02-2026; RO 240 de 10-03-2026). [NMS Law](https://nmslaw.com.ec/blog/2026/02/23/spdp-norma-proteccion-datos-inteligencia-artificial-ecuador/) · [texto en FielWeb](https://www.fielweb.com/App_Themes/InformacionInteres/Resoluci_n_N_SPDP_SPD_2026_0009_R_1771459633.pdf) | Aplica a todo sistema de IA que trate datos de titulares ecuatorianos; define roles (desarrollador, desplegador, etc.); **EIPD obligatoria antes de lanzar un sistema de IA de riesgo**; reafirma el art. 20 | S3, S4 | [S] |
| Res. SPDP-SPD-2026-0037-R (firmada 09-09-2026) | Reforma la norma de IA y acota las obligaciones de los encargados | S4 | [S]; **publicación en RO no confirmada** [NV] |
| Res. SPDP 2025-0040-R (privacidad desde el diseño), 2026-0039-R (biometría), 2025-0006-R (cláusulas) | Normas secundarias citadas en la bóveda | S3 | [B] |
| NIST SP 800-53 Rev. 5, controles AC-5 (separación de funciones) y AC-6 (mínimo privilegio). [CSRC](https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final) | Cada usuario o proceso solo con el acceso necesario; funciones críticas repartidas | S5 | [NV] (catálogo conocido, no consultado en esta sesión) |
| Guía CERT de amenaza interna (bóveda, V23, V24) | Doble control de cambios de cuenta; recertificación de accesos | S5 | [B] |
| OWASP Abuse Case Cheat Sheet. [OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Abuse_Case_Cheat_Sheet.html); STRIDE; [LINDDUN](https://linddun.org/) | Modelar cómo un atacante usaría la propia solución (casos de abuso) y amenazas de privacidad | S6, S3 | [NV] OWASP; LINDDUN [B] |
| Phishing con marca IESS ([Lupa Media](https://lupa.com.ec/verificaciones/iess-sms-reembolso-estafa/)); atípicos negativos N1-N8 de la bóveda | La solución no debe enseñar a hacer clic ni crear un canal clonable («activa tu candado») | S6, veto | [B] |
| NIST SP 800-218 SSDF v1.1 (2022). [CSRC](https://csrc.nist.gov/pubs/sp/800/218/final); OWASP SAMM | Desarrollo seguro mínimo del prototipo | S7 | [B] |
| Bases del hackatón según [IT Ahora (18-11-2026)](https://itahora.com/2026/11/18/codigo-confianza-2026-parte-de-la-estrategia-preventiva-del-iess/) | Sin datos reales ni acceso a sistemas en operación | S7 | [B] |

### 1.3 Gestión (PMI) y supervivencia del prototipo
| Fuente (año) | Qué aporta | Criterio | Marca |
|---|---|---|---|
| PMI, *PMBOK Guide*, 8.ª ed. (noviembre de 2025, 408 pp.). [PMI](https://www.pmi.org/standards/pmbok) | Seis principios: visión holística, **foco en el valor**, calidad integrada, **liderazgo responsable**, **sostenibilidad**, equipos empoderados. Siete dominios de desempeño: **gobernanza, alcance, cronograma, finanzas, interesados, recursos y riesgo**. Conserva la base de principios y dominios de la 7.ª edición | G1-G7 | [S] (páginas de producto de PMI, no el texto; nombres exactos de los principios [NV]) |
| PMI, *Benefits Realization Management: A Practice Guide* (2019; PMI también lista diciembre de 2018). [PMI](https://www.pmi.org/standards/benefits-realization) | Definiciones y principios de realización de beneficios: identificar, ejecutar y sostener beneficios con dueño | G2 | [S]; contenido de registro y dueño del beneficio [NV] |
| HM Treasury, *Green Book* y modelo de cinco casos (estratégico, económico, comercial, financiero, de gestión), ed. 2022. [GOV.UK](https://www.gov.uk/government/publications/the-green-book-appraisal-and-evaluation-in-central-government) | Plantilla de caso de negocio para el sector público, útil para estructurar G2, G5 y G7 | G2, G5, G7 | [NV] |
| Mitchell, Agle y Wood (1997), modelo de prominencia. [DOI](https://doi.org/10.5465/amr.1997.9711022105) | Interesados por poder, legitimidad y urgencia | G3 | [B] |
| Mapa de interesados y registro de riesgos de la bóveda ([[08 Vision PMI e ingenieria]]) | DNSIPD/OSI, DPD, DNTI, BIESS, sindicatos, SPDP; riesgos de patrocinador huérfano, costo sin partida, canal imitado | G3, G4 | [B] |
| Nolte, Chounta y Herbsleb (2020), «What Happens to All These Hackathon Projects?». [NSF PAR](https://par.nsf.gov/servlets/purl/10284449) | La continuidad cae en los primeros días; **solo alrededor del 5 %** sigue más de 5 meses; continuidad corta y larga son fenómenos distintos | G1, G7 | [S] |
| Factores de continuidad de hackatones. [NSF PAR 10341999](https://par.nsf.gov//servlets/purl/10341999) | Compromiso financiero y patrocinio **antes** del evento; agregar valor a un servicio existente | G1, G6 | [B] |
| Imam et al. (2021), «The Secret Life of Hackathon Code». [arXiv 2103.01145](https://arxiv.org/abs/2103.01145v2) | Solo una fracción del código se escribe en el evento; el resto se reutiliza (la bóveda da 9,14 %, versión EMSE) | G7 | [B] |
| WhatsApp Business: cobro por mensaje desde 01-07-2025; utilidad en ventana de 24 h cobrada otra vez desde 01-10-2026. [Meta](https://developers.facebook.com/documentation/business-messaging/whatsapp/pricing) | Costo recurrente de canal | G5 | [B] |
| Ínfima cuantía ≈ USD 7.200 en 2025 (cálculo propio de la bóveda); concurso para consultorías > USD 10.000 según la Ley de Integridad Pública | Ruta de compra | G7 | [B]; umbral LOIP [NV] |
| Código Ingenios, arts. 147-148; Decreto 1014 | Prelación del software libre y publicación del código | G7 | [B] |
| IESS, Rendición de Cuentas 2025: ejecución del PAC del 65,17 % | Riesgo de ejecución | G4, G7 | [B] |

---

## 2. Cómo se puntúa

| Regla | Detalle |
|---|---|
| Escala | 0 = no / no lo sabemos; 1 = parcial o solo como propuesta; 2 = sí, y el equipo lo puede mostrar en la demo o en una ficha |
| Tiempo | Un minuto por criterio; si el equipo no puede responder en un minuto, vale 0 (la duda también es información) |
| Quién puntúa | El propio equipo y una segunda persona ajena; si difieren en más de 1 punto en un criterio, se discute solo ese |
| Evidencia mínima | Cada 2 debe apuntar a algo concreto: un paso del recorrido ficticio, una línea del registro de riesgos, una cifra con fuente |
| Puertas | S1, E1 y G1 definen el núcleo de cada círculo (ver §4) |

---

## 3. Criterios

### 3.1 S · Seguridad (7 criterios, máximo 14)
| ID | Nombre | Pregunta (0-2) | Fuente | Señal de alarma |
|---|---|---|---|---|
| **S1** (puerta) | Eslabón cortado | ¿La idea pone un **control** (no solo un consejo) en E2, E3, E4 o EI? 2 = control en E2→E3, E4 o EI que funciona aunque la víctima ya entregó la clave; 1 = actúa solo en E1 o solo mediante conocimiento; 0 = no se puede señalar el eslabón | Bóveda, cadena de fraude ([Expreso](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html)) [B]; [[10 Criterios de decision]] | Solo enseña a «no hacer clic» |
| S2 | Tipo y momento del control | ¿Se puede decir si es preventivo, detectivo o correctivo y **antes de qué** actúa? 2 = preventivo antes del desembolso, o detectivo más correctivo que revierte antes de que salga el dinero; 1 = solo detecta o avisa después; 0 = no se sabe | ISO/IEC 27002:2022, atributo «tipo de control» (2022) [S]; NIST CSF 2.0 (2024) [NV] | «Avisamos al afiliado» sin decir cuándo ni qué puede hacer |
| S3 | Privacidad desde el diseño | ¿Trata el mínimo de datos, seudonimiza métricas, tiene base legal y prevé EIPD si toca salud, servidores o IA? 2 = flujo de datos dibujado con minimización y EIPD prevista; 1 = se menciona la LOPDP sin flujo; 0 = no se ha pensado | LOPDP arts. 10, 39, 40, 42 (2021) [S/B]; Res. SPDP 2026-0009-R (2026) [S]; LINDDUN [B] | Recolecta cédula, rostro o voz «por si acaso»; métricas individuales de servidores visibles para jefes |
| S4 | Persona en el bucle y reversibilidad | Toda acción que afecta al afiliado o al servidor (bloqueo, retención, alerta, puntaje) ¿la revisa una persona y se puede revertir por un canal accesible? 2 = sí, con plazo y canal; 1 = revisión prevista sin canal; 0 = decisión automática | LOPDP art. 20 [S]; Res. SPDP 2026-0009-R, EIPD previa para IA de riesgo [S]; Robodebt, SyRI ([[06 Atipicos negativos y lineas rojas]]) [B] | Rechazo o sanción automática; la IA «decide» si es fraude |
| S5 | Mínimo privilegio y separación de funciones | ¿Nadie (ayudante, servidor, operador del bot, la propia solución) obtiene más acceso del necesario, y los cambios críticos requieren a dos personas o dos canales? 2 = sí, explícito; 1 = parcial; 0 = la solución concentra acceso | NIST SP 800-53r5 AC-5 y AC-6 (2020) [NV]; guía CERT (V23, V24) [B]; D'Arcy et al. (2009) para la disuasión del abuso interno [S] | El ayudante o el estudiante voluntario conoce la clave; un solo operador puede cambiar cuenta y aprobar |
| S6 | Resistencia a abuso e imitación | ¿Se escribieron al menos tres casos de abuso (clonación del canal, bloqueo malicioso, ingeniería social del soporte) con su respuesta, y la solución nunca pide clave ni envía enlaces de cobro? 2 = sí; 1 = se pensó pero sin respuesta; 0 = crea un canal o mensaje fácil de imitar (**veto**) | OWASP Abuse Case Cheat Sheet [NV]; STRIDE [B]; phishing con marca IESS ([Lupa Media](https://lupa.com.ec/verificaciones/iess-sms-reembolso-estafa/)) [B]; SP 800-50r1 §2.7.2 sobre no usar marcas legítimas en cebos (2024) [V] | «Haz clic aquí para activar tu protección»; número no verificado; cebos de bono (N1) |
| S7 | Demo segura y software seguro | ¿La demo usa solo datos sintéticos y sin integración viva, y el repositorio muestra revisión de código, análisis de dependencias y secretos fuera del código? 2 = las dos cosas; 1 = solo datos sintéticos; 0 = datos reales o claves en el repositorio | Bases del hackatón ([IT Ahora, 2026](https://itahora.com/2026/11/18/codigo-confianza-2026-parte-de-la-estrategia-preventiva-del-iess/)) [B]; NIST SP 800-218 (2022) [B] | Captura de pantalla de un sistema real del IESS; token de API en el código |

### 3.2 E · Educación (SETA) (7 criterios, máximo 14)
| ID | Nombre | Pregunta (0-2) | Fuente | Señal de alarma |
|---|---|---|---|---|
| **E1** (puerta) | Conducta objetivo observable | ¿La idea nombra **una conducta concreta** que cambia en un momento de riesgo concreto («cuelga y llama al número impreso», «reporta el cambio que no hiciste», «registra a tu ayudante en vez de prestar la clave»)? 2 = conducta, momento y público; 1 = tema general («conciencia sobre phishing»); 0 = solo informar | Bada, Sasse y Nurse (2015/2019) [V]; SP 800-50r1, propósito de cambio de conducta (2024) [V]; ISO 27001:2022 cl. 7.3 [S] | Objetivo «concienciar» o «sensibilizar» sin verbo de conducta |
| E2 | Audiencia y rol | ¿Distingue públicos (servidores de ventanilla, sanitarios, cuentas privilegiadas, jubilados urbanos y campesinos, migrantes, afiliados activos) y adapta contenido y canal a cada uno? 2 = al menos dos públicos con contenido propio, incluida la formación por rol de quien tiene acceso privilegiado si toca EI; 1 = un público bien definido; 0 = mensaje único para todos | SP 800-50r1 §2.5, tres segmentos (2024) [V]; SP 800-16 (1998) y Rev. 1 borrador [S]; ISO 27001:2022 A.6.3 «según su función» [S] | «Para todos los afiliados» |
| E3 | Diseño basado en teoría y autoeficacia | ¿Puede el equipo decir qué mecanismo psicológico usa (elaboración activa, autoeficacia, inoculación, norma social) y por qué lleva a la conducta, sin apelar al miedo? 2 = mecanismo nombrado y mensaje de eficacia («qué hacer y que es fácil»); 1 = mecanismo implícito; 0 = miedo o advertencia general | Puhakainen y Siponen (2010) [S]; Karjalainen y Siponen (2011) [S]; Bada et al. (no usar el miedo) [V]; metaanálisis TMP, Lowry et al. 2023 ([[07 Evidencia cientifica]]) [B] | Imágenes de hackers, «tu pensión está en peligro» sin acción clara |
| E4 | Práctica activa con retroalimentación | ¿El público **practica la decisión** (simulación, historia con elección, juego de roles, ejemplo real o falso) y recibe retroalimentación inmediata? 2 = práctica y retroalimentación en el momento; 1 = práctica sin retroalimentación o retroalimentación sin práctica; 0 = material para leer o ver | SP 800-50r1 §2.7.2, aprendizaje experiencial (2024) [V]; Bada et al., «dirigida, accionable, realizable, con retroalimentación» [V]; AARP y Boston College CRR ([[07 Evidencia cientifica]]) [B] | Afiche, folleto o video sin interacción como pieza principal |
| E5 | Refuerzo continuo y encaje en el plan del OSI | ¿Hay calendario de refuerzos (cada 2-3 semanas o ligados a eventos de riesgo) y la idea se inserta en el Plan de concienciación que el OSI debe elaborar, con su ciclo anual? 2 = calendario y punto de inserción en el plan; 1 = uno de los dos; 0 = evento único | Puhakainen y Siponen, comunicación continua (2010) [S]; SP 800-50r1 §2.7.1, concienciación durante todo el año (2024) [V]; ISO 27001:2022 A.6.3, actualizaciones periódicas [S]; EGSI v3 art. 9 núm. 6-7 y disposición general cuarta (2024) [V]; decaimiento a los 9 días ([PMC11897321](https://pmc.ncbi.nlm.nih.gov/articles/PMC11897321/)) [B] | «Campaña de lanzamiento» sin segunda fecha |
| E6 | Evaluación en niveles 3-4 de Kirkpatrick | ¿Qué nivel mide? 2 = nivel 3 (conducta: tasa de reporte, tiempo hasta el primer reporte, cambios revertidos) o nivel 4 (resultados: pérdidas, reincidencia) con línea base y grupo de comparación en 90 días; 1 = nivel 2 (conocimiento pre y post); 0 = nivel 1 (satisfacción), descargas o cursos completados | SP 800-50r1 §5.2.3.3, tabla 3, y §2.4 «cambio de conducta por participante» (2024) [V]; Kirkpatrick (1994) [V vía NIST]; Bada et al., medir por reducción de riesgo [V]; Prümmer et al. (2024) [S]; Ho et al. 2025 y NIST Phish Scale ([[07 Evidencia cientifica]]) [B] | Tasa de clic bruta o «número de vistas» como indicador principal |
| E7 | Cultura justa y consecuencias claras | ¿El error y el reporte tardío no se castigan, y a la vez quedan claras las consecuencias del **abuso deliberado** por servidores? 2 = regla de no sanción por fallar simulaciones, pactada o pactable con sindicatos, y política conocida para el abuso intencional; 1 = solo una de las dos; 0 = sanción por fallar o ninguna regla | SP 800-50r1 §2.7.2, ejercicios no punitivos (2024) [V]; CREST y USEC 2025 ([[07 Evidencia cientifica]]) [B]; D'Arcy et al. (2009): la severidad percibida disuade el mal uso [S]; ISO 27001:2022 cl. 7.3 (implicaciones de no cumplir) [S] | Lista de «los que cayeron» visible para jefes; puntaje individual |

Nota sobre E7: D'Arcy et al. (2009) y la regla de no sanción no se contradicen. La primera trata del mal uso **intencional** (riesgo interno EI), donde conocer las sanciones disuade; la segunda trata del **error** en simulaciones, donde el castigo reduce el reporte (bóveda, [[07 Evidencia cientifica]]).

### 3.3 G · Gestión (PMI) (7 criterios, máximo 14)
| ID | Nombre | Pregunta (0-2) | Fuente | Señal de alarma |
|---|---|---|---|---|
| **G1** (puerta) | Dueño y patrocinador | ¿Hay una unidad del IESS que puede adoptar la idea mañana (DNSIPD/OSI, Talento Humano, Comunicación, DNTI, BIESS) con un responsable y un suplente nombrados por cargo? 2 = unidad, cargo y suplente, y el equipo sabe qué informe del EGSI alimenta; 1 = unidad probable sin cargo; 0 = «el IESS» | PMBOK 8.ª ed., dominio de gobernanza y principio de liderazgo responsable (2025) [S]; Nolte et al. (2020), ~5 % sigue a los 5 meses [S]; NSF PAR 10341999, patrocinio previo [B]; EGSI v3 arts. 5 y 9 (2024) [V] | Ningún cargo nombrado; depende de una autoridad que puede rotar (tres directores generales en 2025, bóveda) |
| G2 | Valor y beneficios medibles | ¿El equipo escribe el beneficio en una línea, con indicador, línea base, meta a 90 días y dueño del beneficio? 2 = las cinco cosas; 1 = beneficio sin indicador o sin dueño; 0 = «mejorar la cultura» | PMBOK 8.ª ed., principio de foco en el valor (2025) [S]; PMI, *Benefits Realization Management* (2019) [S]; *Green Book*, caso estratégico y económico (2022) [NV] | Beneficio medido en descargas, likes o asistentes |
| G3 | Interesados y bloqueadores | ¿Identificó quién puede **vetar** (DPD, DNTI, BIESS, sindicatos, SPDP, SERCOP) y qué le importa a cada uno, con una acción de involucramiento? 2 = mapa con al menos tres bloqueadores y su acción; 1 = lista sin acción; 0 = solo usuarios finales | PMBOK 8.ª ed., dominio de interesados (2025) [S]; Mitchell, Agle y Wood (1997) [B]; mapa de interesados ([[08 Vision PMI e ingenieria]]) [B] | Ignorar al Delegado de Protección de Datos o a los sindicatos |
| G4 | Riesgos del proyecto | ¿Tiene al menos cinco riesgos en formato causa-evento-efecto con probabilidad, impacto y respuesta (incluidos patrocinador huérfano, observación de la SPDP, canal imitado, costo sin partida, equipo disuelto)? 2 = sí; 1 = lista sin respuesta; 0 = ninguno | PMBOK 8.ª ed., dominio de riesgo (2025) [S]; registro de riesgos de la bóveda [B] | «No hay riesgos» o solo riesgos técnicos |
| G5 | Costo total y recurrente | ¿Hay estimación de costo total de propiedad a 3 años (mensajería, hosting, contenidos, mantenimiento, evaluación) con la partida o fuente que lo pagaría? 2 = cifra y fuente; 1 = cifra sin fuente; 0 = no se sabe | PMBOK 8.ª ed., dominio de finanzas (2025) [S]; precios de WhatsApp Business ([Meta](https://developers.facebook.com/documentation/business-messaging/whatsapp/pricing)) [B]; costo por participante, SP 800-50r1 §2.4 [V] | Licencia por usuario sin partida; costo por mensaje no calculado |
| G6 | Integración en canales y procesos existentes | ¿Se monta sobre algo que el IESS ya opera (IESSEDUCA, call center, ventanillas, dispensarios del Seguro Campesino, correo de aviso de cambios, Plan de Cultura 2026) en vez de crear una isla? 2 = sí, con el punto de enganche nombrado; 1 = compatible pero sin enganche; 0 = app o portal nuevo como único canal | NSF PAR 10341999, agregar valor a un servicio existente [B]; PMBOK 8.ª ed., principio de sostenibilidad (2025) [S]; EGSI v3 art. 9 (2024) [V] | «Nuestra app» que el afiliado tendría que descargar |
| G7 | Ruta post-hackatón y compra pública | ¿Hay ruta concreta: piloto de 90 días, mecanismo de contratación viable (convenio, ínfima cuantía, desarrollo interno), licencia libre y código publicado, documentación de traspaso? 2 = ruta con mecanismo nombrado y licencia; 1 = intención sin mecanismo; 0 = nada | Código Ingenios arts. 147-148 [B]; ínfima cuantía ≈ USD 7.200 en 2025 (cálculo propio de la bóveda) [B]; Ley de Integridad Pública [NV]; ejecución del PAC 2025 del 65,17 % [B]; Imam et al. (2021) [B] | Dependencia de un proveedor con licencia propietaria; código sin licencia |

---

## 4. Reglas para ubicar una idea en el Venn

### 4.1 Umbral
| Regla | Valor | Justificación |
|---|---|---|
| Toca un círculo | Puntos del círculo ≥ 8 de 14 **y** criterio puerta = 2 | (a) 8 de 14 es más de la mitad: con la puerta en 2, los otros seis criterios necesitan al menos 6 de 12, es decir un promedio de 1 («cumple en parte» en todos o del todo en la mitad). (b) La puerta impide que una idea toque un círculo por acumulación de puntos accesorios: sin S1 no hay seguridad para este reto (la cadena E2→E3 y EI es donde ocurre el daño); sin E1 se vuelve la «concienciación» genérica que Bada et al. muestran que falla; sin G1 la idea entra en el ~95 % de proyectos de hackatón que no siguen (Nolte et al. 2020). (c) Una escala 0-2 con anclas reduce la discrepancia entre evaluadores frente a escalas de 5 puntos (**supuesto razonable, sin fuente verificada**) |
| Veto (zona roja, fuera del Venn) | S6 = 0, o la idea coincide con N1-N8 | Una idea que crea un vector de fraude o repite un fracaso documentado no debe aparecer como «solo débil»: debe verse como descartada ([[06 Atipicos negativos y lineas rojas]]) |
| Fuera de los tres círculos | No toca ninguno | Idea a reformular, no necesariamente mala |
| Posición dentro de la región | Se puede dibujar el punto más cerca del borde del círculo en que más puntúa | Solo para lectura visual; no cambia la región |
| Sensibilidad | Si una idea queda a 1 punto del umbral, se marca «frontera» con un contorno punteado | Evita discusiones largas por un punto en un minuto de evaluación |

### 4.2 Las siete regiones
Los ejemplos son una **clasificación preliminar** aplicando la rúbrica a la ficha de la [[07 Tabla maestra]]; cambian según cómo cada equipo diseñe la idea. No es una recomendación.

| Región | Qué significa | Ejemplo del mapa | Por qué cae ahí (lectura de la ficha) |
|---|---|---|---|
| **S** | Control fuerte que no educa ni tiene aún ruta de adopción | V13 Reglas de secuencia con retención y verificación humana | Corta E3, E4 y EI (S1 = 2) con verificación humana (S4), pero no enseña una conducta (E1 ≤ 1) y depende del BIESS, de EIPD y de perfilado (G1 y G5 débiles) |
| **E** | Buena pieza educativa sin control ni dueño | P3 Radionovela con trama central | Conducta y práctica narrativa (E1, E4), resiste apagones; actúa solo en E1 (S1 = 1); costo «no obtenido» y sin unidad que la opere (G1 ≤ 1). La bóveda advierte que el arte no sirve solo |
| **G** | Viable e institucionalizable, pero sin efecto demostrado | C1 Curso anual en LMS (IESSEDUCA) | Dueño, canal y costo conocidos (G1, G5, G6 altos); sin conducta concreta (E1 ≤ 1, evidencia «A nulo») y sin eslabón (S1 = 0) |
| **S∩E** | Control que además enseña en el momento, pero difícil de adoptar tal como está | V20 Aviso inmediato por acceso no justificado | Actúa en EI (S1 = 2) y educa con retroalimentación inmediata no punitiva (E4, E7); necesita registros de acceso y base legal para datos de servidores, que el reto no permite tocar (G1 o G6 débiles) |
| **S∩G** | Control viable sobre canales existentes, sin componente educativo | C11 Aviso al canal anterior ante cambios, ampliado a SMS e IVR | Corta E2 y E4 (S1 = 2), muy bajo costo y el IESS ya lo hace por correo (G5, G6); no entrena una conducta (E1 ≤ 1) salvo que se añada qué hacer al recibirlo |
| **E∩G** | Programa SETA bien gestionado que no corta un eslabón | V27 Formación por rol con materiales HICP | Públicos por rol (E2), materiales libres y muy bajo costo, encaja en el Plan de Cultura (G6); solo transmite conocimiento sobre E1 y EI (S1 = 1) |
| **S∩E∩G** | Cultura que enseña una regla institucional real, con control y dueño | «Cultura con un ancla de proceso»: inoculación con refuerzo y línea de reporte (V14 + V8) más enfriamiento (V1) presentado como dependencia | Corta E2→E3 y E4 (S1 = 2), entrena una conducta con práctica y refuerzo (E1, E4, E5), y puede montarse en call center y canales existentes con dueño en la DNSIPD (G1, G6). Llega a S∩E∩G solo si el equipo nombra la dependencia del BIESS y la ruta de contratación |
| Zona roja | Vetada | N1 Simulacro con cebo de bono; N2 Puntaje opaco de beneficiarios | Daño laboral o decisión automatizada sin supervisión (S4, S6 = 0) |

---

## 5. Criterios transversales de inclusión

### 5.1 Criterios
| ID | Nombre | Pregunta (0-2) | Dato que lo justifica | Señal de alarma |
|---|---|---|---|---|
| I1 | Adultos mayores y limitaciones funcionales | ¿Cumple WCAG 2.2 AA (tamaño de objetivo, autenticación accesible), usa lenguaje llano y una sola acción por mensaje, y tiene alternativa de audio o presencial? 2 = sí y se probó con un usuario que simula baja visión o motricidad; 1 = previsto; 0 = no | 30,2 % de las personas de 65+ con alguna dificultad funcional (Censo 2022, [INEC](https://www.ecuadorencifras.gob.ec/mas-de-2-700-personas-son-centenarias-en-ecuador-segun-el-censo/)) [B]; [WCAG 2.2](https://www.w3.org/TR/WCAG22/) (2023) [B]; RTE INEN 288 [B] | Letra pequeña, CAPTCHA, códigos que caducan en 30 s |
| I2 | Zonas rurales y baja conectividad | ¿Funciona con poca señal, de forma asíncrona y liviana? 2 = sí, mostrado; 1 = en parte; 0 = requiere banda ancha | Hogares con internet: 76,6 % urbano y 58,7 % rural (2025, [Primicias](https://www.primicias.ec/sociedad/ecuador-acceso-internet-brecha-digital-usos-informe-politecnica-113472/)) [B] | Video en alta definición como único formato |
| I3 | Kichwa y lenguas originarias | ¿Tiene versión o plan de versión en kichwa (u otra lengua) validado con hablantes, y formato oral para quien no lee? 2 = pieza en kichwa en la demo; 1 = plan con aliado nombrado; 0 = solo castellano escrito | Analfabetismo indígena del 11,9 % (Censo 2022, según nota cruda, [INEC](https://www.ecuadorencifras.gob.ec/reduccion-del-analfabetismo-en-ecuador-mas-de-199-000-personas-libres-de-esta-condicion-desde-2010/)) [B]; Bada et al., contexto cultural [V]. **Cifra de hablantes de lenguas originarias no obtenida** [NV] | Traducción automática sin revisión |
| I4 | Sin smartphone | ¿Llega por voz, SMS, IVR, teléfono básico, radio o presencia en agencias y dispensarios? 2 = canal sin smartphone en la demo; 1 = previsto; 0 = app o web como único canal | 57,7 % con teléfono inteligente y 61,3 % con celular activado (2024, [INEC TIC](https://www.ecuadorencifras.gob.ec/tecnologias-de-la-informacion-y-comunicacion-tic-2024/)) [B]; IVR de Uganda (P1) [B] | «Descarga la app» |
| I5 | Apagones y modo degradado | ¿Tiene un camino sin red (papel, radio, ventanilla, tarjeta de bolsillo) y sigue siendo segura en modo degradado (no se desactivan los controles)? 2 = tres capas mostradas; 1 = alternativa sin probar; 0 = depende de internet y electricidad | Cortes de hasta 14 h diarias durante unos tres meses en 2024 ([Primicias](https://primicias.ec/economia/crisis-electricidad-cortes-luz-resumen2024-86508)) [B]; P9 diseño en tres capas [B] | Sin plan B; «cuando vuelva la luz» |

### 5.2 Cómo se suman
| Regla | Detalle | Justificación |
|---|---|---|
| No es un cuarto círculo | La suma I1-I5 (máximo 10) se dibuja como **color del punto** en el Venn: 0-3 rojo, 4-6 ámbar, 7-10 verde | La consigna pide tres círculos; un cuarto haría ilegible el diagrama |
| Condición para el centro | Una idea dirigida a ciudadanos (afiliados, jubilados, campesinos, migrantes) solo se ubica en S∩E∩G si I ≥ 6; si no, se dibuja en S∩E∩G con contorno punteado y nota «centro condicionado» | La bóveda trata la inclusión como **condición de entrada** ([[09 Criterios de diseno]]) |
| Ideas internas | Para ideas dirigidas solo a servidores, se exige I1 ≥ 1 e I5 ≥ 1 (accesibilidad y contingencia de servicio) y no I3 ni I4 | El riesgo interno no depende del idioma ni del teléfono del afiliado; sí de la continuidad del servicio |
| Desempate | Entre dos ideas de la misma región, gana la de mayor I | Prioriza a quien más sufre el fraude (adultos mayores, 30 % de las estafas digitales reportadas según Asobanca, vía [Vistazo 2026](https://www.vistazo.com/negocios/sectores/2026-07-08-adultos-mayores-ecuador-excluidos-servicios-financieros-digital-como-integrarlos-ecuador-CB11103504)) [B] |
| No compensa | Los puntos de I **no se suman** a S, E ni G | Evita que una idea inclusiva pero inútil parezca segura o viable |

---

## 6. Hoja de puntuación para el equipo (copiar y llenar)
| Idea: | S1* | S2 | S3 | S4 | S5 | S6† | S7 | ΣS | E1* | E2 | E3 | E4 | E5 | E6 | E7 | ΣE | G1* | G2 | G3 | G4 | G5 | G6 | G7 | ΣG | I1 | I2 | I3 | I4 | I5 | ΣI | Región |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| | | | | | | | | /14 | | | | | | | | /14 | | | | | | | | /14 | | | | | | /10 | |

\* Criterio puerta: debe valer 2 para tocar el círculo. † S6 = 0 veta la idea.

---

## 7. Vacíos y lo no verificado
| Vacío | Estado | Qué haría falta |
|---|---|---|
| Los cuatro requisitos pedagógicos de Karjalainen y Siponen (2011) | Solo se confirmó que existen y que se basan en Hare; el texto completo devolvió error 403 | Leer el artículo en AISeL o el repositorio de Oulu |
| Texto de ISO/IEC 27001:2022 cl. 7.3 y A.6.3 | Paráfrasis de consultoras; la norma es de pago | Cotejar con la norma (INEN puede tener la adopción NTE INEN-ISO/IEC 27001) [NV] |
| Nombres exactos de los seis principios del PMBOK 8.ª ed. | Los dominios coinciden en dos fuentes; los principios se tomaron de un resumen de las páginas de PMI | Revisar el libro |
| PMI *Benefits Realization Management* | Fecha discrepante (2018 o 2019) y contenido no leído | Revisar la guía |
| Kirkpatrick 1959 | Fecha original no consultada; NIST cita el libro de 1994 | Opcional |
| NIST SP 800-53r5 AC-5/AC-6, OWASP Abuse Case, NIST CSF 2.0, *Green Book* | Citados de conocimiento previo, no abiertos en esta sesión | Abrir los enlaces antes de citarlos ante el jurado |
| Res. SPDP 2026-0037-R | Firmada el 09-09-2026; publicación en RO no confirmada al 17-09-2026 | Revisar el Registro Oficial |
| Texto exacto de LOPDP art. 39 | No apareció en fuentes; se usa lo que dice la bóveda | Revisar el texto de la ley |
| Metaanálisis de Prümmer et al. (d = 0,75, sin efecto equivalente en conducta) | Mencionado en el repositorio de Leiden; no leído | Leerlo antes de citar la cifra |
| Ruta de compra pública de innovación en Ecuador (convenios con universidades, régimen especial) | No se encontró fuente específica; solo ínfima cuantía y Código Ingenios desde la bóveda | Consultar SERCOP o la reforma a la LOSNCP de octubre de 2025 |
| Umbral 8/14 con puerta | Propuesta propia, no calibrada | Probarla con 5-10 ideas del mapa y dos evaluadores; ajustar si más de la mitad cae en S∩E∩G o casi ninguna toca un círculo |
| Fiabilidad entre evaluadores de escalas 0-2 | Supuesto razonable sin fuente verificada | Medir concordancia (por ejemplo, kappa) en una prueba piloto |
| Evidencia SETA en adultos mayores latinoamericanos y en kichwa | La bóveda ya reporta que no hay estudios | Ofrecer la primera medición como valor de la propuesta ([[10 Criterios de decision]]) |

## Relacionadas
[[07 Evidencia cientifica]] · [[08 Vision PMI e ingenieria]] · [[09 Criterios de diseno]] · [[10 Criterios de decision]] · [[07 Tabla maestra]] · [[08 Donde convergen las vertientes]]
