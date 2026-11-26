---
tags: [soluciones, software, catalogo, venn, seta, pmi, reto1]
fuente: "Bóveda Hackaton-IESS-Reto1 (2-Soluciones: Indice, 07 Tabla maestra, 08 Donde convergen, 09 Huecos; 1-Investigacion: 01, 02, 04) + verificación web propia"
fecha: 2026-11-25
---

# Catálogo de soluciones de software · Reto 1 Código Confianza IESS 2026

«Seguridad inteligente, cultura consciente». Cuarenta ideas de software prototipables en un hackatón con datos ficticios. Parten del mapa de la bóveda (IDs C, V, P, X, N de [[07 Tabla maestra]]), pero aquí cada una está pensada como producto. El catálogo no elige ninguna.

## En pocas palabras
- 40 ideas: 3 de centro, 16 convergentes, 9 de periferia y 12 atípicas.
- En el Venn: 8 tocan los tres círculos (S∩E∩G), 9 S∩E, 11 S∩G, 9 E∩G y 3 un solo círculo.
- Los cinco huecos del mapa (clave prestada, servidor cooptado, kichwa, migrantes sin agencia, SMS sin efecto de inoculación) tienen al menos dos ideas cada uno. Ninguna tiene evidencia propia: son nivel D y ofrecen la primera medición.
- Hallazgo verificado (25-11-2026): Omnilingual ASR de Meta (Apache-2.0) incluye seis variedades de kichwa ecuatoriano, entre ellas Imbabura (qvi) y Chimborazo (qug). También existe un corpus Common Voice de kichwa de Imbabura con licencia CC0. Es la primera pieza abierta que permite escuchar en kichwa (ver S19).
- Dos piezas que suelen recomendarse ya no son código abierto OSI: RapidPro/TextIt (ahora BSL 1.1) y n8n (Sustainable Use License). Rasa Open Source estaría en modo mantenimiento (fuente secundaria). Con la prelación al software libre del Código Ingenios, conviene preferir Node-RED, Jambonz o Asterisk.

## Claves de lectura
| Clave | Significado |
|---|---|
| Eslabón | E1 obtener la clave · E2 cambiar correo, teléfono o cuenta · E3 préstamo quirografario BIESS o fondos de reserva · E4 la víctima se entera tarde · EI riesgo interno de servidores |
| Campana | Centro (lo más adoptado) · Convergente (anillo con las cifras grandes) · Periferia (inclusión, sin smartphone) · Atípico (hipótesis sin datos) |
| Venn | **S** Seguridad: corta un eslabón · **E** Educación SETA: cambia conducta · **G** Gestión PMI: viable y sostenible (costo, dueño, medición, dependencias) |
| Región | S∩E∩G, S∩E, S∩G, E∩G o un solo círculo |
| Evidencia | ID del mapa con su nivel A-D (ver [[00 Como leer el mapa]]) |
| **estimación propia** | Cifra calculada para este catálogo, sin cotización |
| **sin verificar** | Dato que no se pudo confirmar en una fuente primaria |
| Datos de demo | Todos ficticios. Las cédulas de demo deben fallar el dígito verificador y los nombres se marcan «ficticio» |

## Tabla resumen
| ID | Nombre | Familia | Eslabón | Usuario principal | Campana | Venn | Hueco que cubre | Base en el mapa |
|---|---|---|---|---|---|---|---|---|
| S01 | Pausa IESS (motor de enfriamiento y retención) | Fricción | E2→E3 | Afiliado, jubilado | Convergente | S∩E∩G | Clave prestada (protege aunque se haya prestado) | V1, C11, X1 |
| S02 | Candado BIESS voluntario | Fricción | E3, E2 | Jubilado y familia | Atípico | S∩E | Clave prestada | X1, V2, V3 |
| S03 | Cuenta-Titular (cédula = titular de la cuenta) | Fricción | E2, E3 | Sistema de registro de cuentas | Convergente | S∩G | Servidor cooptado (cuentas mula) | V4 |
| S04 | Centinela de Secuencia con revisión humana | Fricción | E2→E3, EI | Analista de fraude | Convergente | S∩G | Servidor cooptado, tramitador | V13, V22 |
| S05 | Pregunta en el Momento (pantalla con norma social) | Fricción y cultura | E1, E3 | Afiliado en portal y su ayudante | Periferia | S∩E∩G | Clave prestada | P11 |
| S06 | Ayudante Registrado (delegación acotada) | Delegación | E1 | Jubilado, campesino y su ayudante | Convergente | S∩E∩G | Clave prestada | V6 |
| S07 | Sesión Asistida para cibercafés y tramitadores acreditados | Delegación | E1 | Intermediario comercial, afiliado sin smartphone | Atípico | S∩E | Clave prestada (cibercafé) | V6 (variante), sin antecedente |
| S08 | Persona de Confianza sin poder de operar | Delegación | E4, E3 | Jubilado, migrante | Convergente | S∩G | Migrantes, celular compartido | V5 |
| S09 | Protocolo de Ventanilla Digital | Delegación y presencia | E2, E3, EI | Servidor de ventanilla | Periferia | S∩E∩G | Clave prestada (ayudante presencial) | P7 |
| S10 | «¿Es del IESS?» bot oficial con registro de envíos | Canal verificable | E1 | Afiliado con WhatsApp, familiares | Convergente | S∩E∩G | - | V7, P10 |
| S11 | Sello Verificable (registro público de comunicaciones) | Canal verificable | E1 | Prensa, verificadores, bancos, el bot | Atípico | S∩G | - | V9 (análogo) |
| S12 | «¿Me llamó el IESS?» (registro de llamadas salientes) | Canal verificable | E1 | Afiliado con teléfono básico | Atípico | S∩E | Kichwa y rural (voz) | V17, C12 |
| S13 | Palabra de Familia | Canal verificable | E1 | Migrantes y sus padres | Convergente | E∩G | Migrantes | V16 |
| S14 | Radar de Campañas (alertas de campañas activas) | Reporte | E1 (oferta) | Comunicación y DNSIPD | Atípico | S∩E∩G | SMS (respuesta por varios canales) | X6, X5, P12 |
| S15 | Reporta y lo Bajamos (retiro de sitios falsos) | Reporte | E1 (oferta) | SOC | Periferia | S∩G | - | P12 |
| S16 | «¿Real o falso?» con refuerzos por WhatsApp | Práctica | E1, E4 | Afiliados y jubilados con WhatsApp | Convergente | E∩G | - | V14 |
| S17 | SMS que Enseña (ensayo del canal SMS) | Práctica | E1 | Afiliado con teléfono básico | Atípico | E∩G | SMS sin efecto de inoculación | V14 (nulo en SMS) |
| S18 | Historias por Teléfono: juego de voz IVR en español y kichwa, con radionovela | Práctica | E1, E4 | Campesinos, kichwa hablantes, jubilados | Periferia | E∩G | Kichwa | P1, P2, P3 |
| S19 | Kichwa Rimay: reporte y menú por voz en kichwa | Inclusión | E4→E3, E1 | Kichwa hablantes | Atípico | S∩E | Kichwa | P2 |
| S20 | Vigía de Dominio (DMARC y dominios parecidos) | Higiene | E1 | DNTI, SOC | Centro | S∩G | - | C10 |
| S21 | Pantalla viva en sala de espera | Práctica | E1 | Pacientes y acompañantes | Periferia | E∩G | Rural sin smartphone | V15 |
| S22 | Centinela sin Conexión (PWA para monitores pares) | Inclusión | E1, E4 | Dirigentes de dispensarios del SSC | Periferia | E∩G | Kichwa y rural, apagones | P4, P9, P8 |
| S23 | Llave de Viaje (passkey y verificación remota) | Migrantes | E1, E2, E3 | Migrantes | Convergente | S∩G | Migrantes sin agencia | V10 |
| S24 | Tu Mes en el IESS (avisos por evento y resumen por voz) | E4 | E4 | Jubilados y afiliados | Convergente | S∩E | E4, kichwa | C11, V8 |
| S25 | «No Reconozco» con congelamiento | E4 | E4→E3 | Víctima o familiar | Convergente | S∩G | E4 | V8 |
| S26 | Ruta de la Víctima | E4 | E4 | Víctima, Defensoría, trabajo social | Atípico | S∩G | E4 (después del daño) | X15 (parcial) |
| S27 | Afiliado Auditor | E4 | E4 | Afiliado activo, jubilado con portal | Atípico | S∩E | E4 | X2 |
| S28 | Botón «Reportar al OSI» en Gmail con respuesta | Interno | E1 personal, EI | Servidores | Convergente | S∩E∩G | - | V18, V29 |
| S29 | Aviso Nocturno no punitivo por acceso indebido | Interno | EI | Servidores sanitarios y de ventanilla | Convergente | S∩E∩G | Servidor (curiosidad) | V20, V22 |
| S30 | Doble Llave (doble control y «romper el cristal») | Interno | E2, EI | Servidores con permisos de modificación | Convergente | S∩G | Servidor cooptado | V23, V21 |
| S31 | Jubilado Trampa (registros señuelo) | Interno | EI | Unidad de integridad | Atípico | S | Servidor cooptado | X3 |
| S32 | Código de Coacción del servidor | Interno | EI | Servidor presionado o extorsionado | Atípico | S∩E | Servidor cooptado | X8 (adaptado) |
| S33 | Canal Casi-Fraude confidencial | Interno | EI | Servidores | Atípico | S∩E | Servidor cooptado | X4 |
| S34 | Guardia IESS (extensión de navegador para servidores) | Interno | E1 personal, E2, EI | Servidores con equipos institucionales | Periferia | S∩E | Servidor cooptado (fricción justo a tiempo) | P18, P19, V21 |
| S35 | Recertificación de accesos | Interno | EI | Jefes de unidad | Convergente | S∩G | Servidor cooptado | V24 |
| S36 | Simulacro con cultura justa (GoPhish) | Interno | E1 personal | Servidores | Centro | E∩G | - | C2, V30, V26 |
| S37 | Escape room digital por turnos | Interno | E1, EI | Personal sanitario | Periferia | E | - | P13 |
| S38 | Tablero de Cultura OSI (tres capas SETA) | Medición | Medición | OSI, Comité de Seguridad | Convergente | E∩G | Medición | V25, C4 (contraejemplo) |
| S39 | Banco de Estafas EC (corpus y población sintética) | Medición | Transversal | Equipos, academia, OSI | Periferia | G | Canal (sin benchmark en español ni kichwa), medición | Vacío de canal (09) |
| S40 | Microcursos por rol (Moodle y H5P) | Interno | E1, EI | Servidores por rol | Centro | E∩G | - | C1, V27 |

«-»: la idea no apunta a un hueco declarado en [[09 Huecos]].

## Distribución
| Campana \ Venn | S∩E∩G | S∩E | S∩G | E∩G | Un círculo | Total |
|---|---|---|---|---|---|---|
| Centro | - | - | S20 | S36, S40 | - | 3 |
| Convergente | S01, S06, S10, S28, S29 | S24 | S03, S04, S08, S23, S25, S30, S35 | S13, S16, S38 | - | 16 |
| Periferia | S05, S09 | S34 | S15 | S18, S21, S22 | S37 (E), S39 (G) | 9 |
| Atípico | S14 | S02, S07, S12, S19, S27, S32, S33 | S11, S26 | S17 | S31 (S) | 12 |
| Total | 8 | 9 | 11 | 9 | 3 | 40 |

Lectura: las ideas de la intersección triple se concentran en el anillo convergente, igual que la evidencia del mapa. Las atípicas casi nunca llegan a G: dependen de una norma que no existe o de una legalidad sin verificar.

## Cobertura de huecos
| Hueco ([[09 Huecos]]) | Ideas que lo atacan | Qué mediría el piloto |
|---|---|---|
| Clave prestada a ayudante, cibercafé o tramitador | S06, S07, S05, S09, S01, S02 | Registros de ayudantes, caída de sesiones compartidas (mismo dispositivo con varias cédulas), pausas voluntarias |
| Servidor cooptado que cambia cuentas o registra aportes | S30, S31, S32, S33, S04, S03, S34, S35 | Cambios rechazados en doble control, toques a señuelos, usos del código de coacción, reportes de casi-fraude |
| Nada en kichwa | S18, S19, S22, S24 (voz), S12 | Llamadas completadas en kichwa, reportes por voz, error del reconocimiento de voz en telefonía |
| Migrantes sin agencia | S23, S08, S13 | Operaciones remotas con passkey frente a sin passkey, quejas por fricción |
| SMS sin efecto de inoculación | S17 (ensayo), S14 y S24 (SMS como canal de acción, no de enseñanza) | Aciertos a 4 y 8 semanas por canal |
| E4 (la víctima se entera tarde) | S24, S25, S26, S27, S08 | Tiempo del evento al reclamo, montos congelados |
| Medición | S38, S39, y la métrica de cada ficha | Línea base conductual (hoy no existe, ver [[01 Perfiles y canales del IESS]]) |
| Celular compartido como «canal anterior» | S08, S24 (llamada a número histórico), S09 | Avisos respondidos por un tercero |

## Registro de piezas de código abierto verificadas
Verificación del 25-11-2026: archivo LICENSE del repositorio (raw.githubusercontent.com), API de GitHub o ficha de Hugging Face. «Activo» significa que hubo commits en 2026.

| Pieza | Uso en el catálogo | Enlace | Licencia verificada | Nota |
|---|---|---|---|---|
| Keycloak | Identidad, roles, passkeys, delegación | [github.com/keycloak/keycloak](https://github.com/keycloak/keycloak) | Apache-2.0 | Passkeys con soporte oficial desde 26.4 ([Keycloak](https://www.keycloak.org/2025/09/passkeys-support-26-4)); token exchange estándar RFC 8693 desde 26.2 ([Keycloak](https://www.keycloak.org/2025/05/standard-token-exchange-kc-26-2)); claim `act` en impersonación desde 26.8 (según búsqueda; **verificar en notas de versión** [26.8.0](https://www.keycloak.org/2026/10/keycloak-2680-released)) |
| OpenFGA | Relaciones «ayudante de», «contacto de confianza» | [github.com/openfga/openfga](https://github.com/openfga/openfga) | Apache-2.0 | Activo |
| Open Policy Agent (OPA) | Políticas de enfriamiento, doble control | [github.com/open-policy-agent/opa](https://github.com/open-policy-agent/opa) | Apache-2.0 | Activo |
| Cedar | Alternativa a OPA | [github.com/cedar-policy/cedar](https://github.com/cedar-policy/cedar) | Apache-2.0 | - |
| Temporal | Temporizadores durables (ventanas de 72 h) | [github.com/temporalio/temporal](https://github.com/temporalio/temporal) | MIT | Activo |
| Flowable | Flujos BPMN de aprobación y escalamiento | [github.com/flowable/flowable-engine](https://github.com/flowable/flowable-engine) | Apache-2.0 | Activo |
| Asterisk | Centralita e IVR | [github.com/asterisk/asterisk](https://github.com/asterisk/asterisk) | GPL-2.0 (con licencia alternativa de Sangoma) | Activo |
| FreePBX (framework, core) | Interfaz de Asterisk | [github.com/FreePBX/framework](https://github.com/FreePBX/framework) | GPL-3.0 | Hay módulos comerciales aparte |
| Jambonz | Plataforma de voz programable (IVR por API) | [github.com/jambonz/jambonz-feature-server](https://github.com/jambonz/jambonz-feature-server) | MIT | - |
| Ink (inkle) | Guion ramificado para historias | [github.com/inkle/ink](https://github.com/inkle/ink) | MIT | - |
| Twine | Guion ramificado (alternativa visual) | [github.com/klembot/twinejs](https://github.com/klembot/twinejs) | GPL-3.0 | - |
| Omnilingual ASR (Meta) | Reconocimiento de voz en kichwa | [github.com/facebookresearch/omnilingual-asr](https://github.com/facebookresearch/omnilingual-asr) | Apache-2.0 (código y modelos); corpus CC-BY-4.0 | Lista con qvi, qug, qxr, qvj, qvo, qvz. CER reportado por Meta (modelo 7B): qvi 3,5; qug 17,5; qvj 3,8 ([tabla](https://github.com/facebookresearch/omnilingual-asr/blob/main/per_language_results_table_7B_llm_asr.csv)). **No medido en audio telefónico** |
| Common Voice Kichwa (Imbabura, qvi) v25 | Evaluar el reconocimiento de voz | [Mozilla Data Collective](https://prod.datacollective.mozillafoundation.org/datasets/cmn2cigqs01d3o107mzljz8gp) | CC0-1.0 | 12,53 h, 15 hablantes; los términos prohíben re-alojar e identificar hablantes (fuente: búsqueda sobre la ficha). También hay kichwa de Loja (qvj) |
| MMS-TTS (Meta) | Voz sintética de maqueta en kichwa | [huggingface.co/facebook/mms-tts-qvo](https://huggingface.co/facebook/mms-tts-qvo) | CC-BY-NC-4.0 | Existen modelos para Cañar (qxr), Napo (qvo), Pastaza norte (qvz), Tena (quw) y Salasaca (qxl); **no se encontraron** para Imbabura (qvi) ni Chimborazo (qug). Licencia no comercial: solo maqueta |
| Vosk | Voz a texto en español sin conexión | [github.com/alphacep/vosk-api](https://github.com/alphacep/vosk-api) | Apache-2.0 | - |
| Whisper | Voz a texto en español | [github.com/openai/whisper](https://github.com/openai/whisper) | MIT | - |
| sherpa-onnx | Voz en el dispositivo | [github.com/k2-fsa/sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) | Apache-2.0 | - |
| Piper (piper1-gpl) | Texto a voz en español | [github.com/OHF-Voice/piper1-gpl](https://github.com/OHF-Voice/piper1-gpl) | GPL-3.0 | El repositorio original cambió de dueño y de licencia |
| Qwen3 (4B, 8B) | LLM local para explicar y redactar | [huggingface.co/Qwen/Qwen3-8B](https://huggingface.co/Qwen/Qwen3-8B) | Apache-2.0 | - |
| Mistral Small 3.1 | LLM local | [huggingface.co/mistralai](https://huggingface.co/mistralai/Mistral-Small-3.1-24B-Instruct-2503) | Apache-2.0 | - |
| Granite 3.3 8B (IBM) | LLM local | [huggingface.co/ibm-granite](https://huggingface.co/ibm-granite/granite-3.3-8b-instruct) | Apache-2.0 | - |
| Phi-4-mini | LLM pequeño | [huggingface.co/microsoft/Phi-4-mini-instruct](https://huggingface.co/microsoft/Phi-4-mini-instruct) | MIT | - |
| Llama 3.1 y Gemma 3 | LLM local | [Llama 3.1](https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct), [Gemma 3](https://huggingface.co/google/gemma-3-4b-it) | Licencias propias (llama3.1, gemma), no OSI | Preferir Apache-2.0 por el Código Ingenios |
| Ollama, llama.cpp, vLLM | Servir el LLM | [ollama](https://github.com/ollama/ollama), [llama.cpp](https://github.com/ggml-org/llama.cpp), [vLLM](https://github.com/vllm-project/vllm) | MIT, MIT, Apache-2.0 | - |
| Presidio | Quitar datos personales de reportes | [github.com/data-privacy-stack/presidio](https://github.com/data-privacy-stack/presidio) | MIT | Antes estaba en microsoft/presidio |
| Cofacts (rumors-api, rumors-line-bot) | Modelo de base comunitaria de mensajes | [github.com/cofacts/rumors-api](https://github.com/cofacts/rumors-api) | MIT | Activo |
| WhatsApp Cloud API (Meta) | Canal del bot | [developers.facebook.com](https://developers.facebook.com/docs/whatsapp/pricing) | Servicio comercial | Cobro por mensaje de plantilla desde el 01-07-2025 |
| Twilio u otro agregador SMS | Canal SMS | [twilio.com/sms/pricing/ec](https://www.twilio.com/sms/pricing/ec) | Servicio comercial | Precio para Ecuador **no legible** en la página oficial; terceros dan USD 0,18-0,38 por segmento |
| Node-RED | Automatización de flujos | [github.com/node-red/node-red](https://github.com/node-red/node-red) | Apache-2.0 | Preferido frente a n8n |
| n8n | Automatización de flujos | [github.com/n8n-io/n8n](https://github.com/n8n-io/n8n) | Sustainable Use License (no OSI) | Choca con la prelación al software libre |
| RapidPro / TextIt (nyaruka/temba) | Flujos SMS, IVR, WhatsApp | [github.com/nyaruka/temba](https://github.com/nyaruka/temba) | BSL 1.1 (no OSI); pasa a AGPL-3.0 el 25-11-2028 | El repositorio rapidpro redirige a temba |
| Rasa | Bot conversacional | [github.com/RasaHQ/rasa](https://github.com/RasaHQ/rasa) | Apache-2.0 | Modo mantenimiento según fuente secundaria (**sin verificar** en fuente oficial); el desarrollo pasó a Rasa Pro, de pago |
| Wazuh | SIEM, reglas sobre registros | [github.com/wazuh/wazuh](https://github.com/wazuh/wazuh) | GPL-2.0 (motor AGPL-3.0) | Activo |
| OpenSearch | Índice de eventos | [github.com/opensearch-project/OpenSearch](https://github.com/opensearch-project/OpenSearch) | Apache-2.0 | - |
| Canarytokens | Señuelos (documentos, DNS, URL) | [github.com/thinkst/canarytokens](https://github.com/thinkst/canarytokens) | GPL-3.0 con aclaraciones y excepciones propias | Tipos confirmados por fuentes secundarias: DNS, URL, Word, Excel, SQL Server |
| OpenCanary | Servicios señuelo | [github.com/thinkst/opencanary](https://github.com/thinkst/opencanary) | BSD-3-Clause | - |
| GoPhish | Simulación de phishing | [github.com/gophish/gophish](https://github.com/gophish/gophish) | MIT | Último push en 09-2024: poco mantenimiento |
| Shuffle | Orquestación del SOC | [github.com/Shuffle/Shuffle](https://github.com/Shuffle/Shuffle) | AGPL-3.0 | - |
| DFIR-IRIS | Gestión de casos del SOC | [github.com/dfir-iris/iris-web](https://github.com/dfir-iris/iris-web) | LGPL-3.0 | - |
| MISP | Compartir indicadores con EcuCERT | [github.com/MISP/MISP](https://github.com/MISP/MISP) | AGPL-3.0 | - |
| GlobaLeaks | Canal de reporte confidencial | [github.com/globaleaks/globaleaks-whistleblowing-software](https://github.com/globaleaks/globaleaks-whistleblowing-software) | AGPL-3.0 | - |
| Zammad | Mesa de casos | [github.com/zammad/zammad](https://github.com/zammad/zammad) | AGPL-3.0 | - |
| Chatwoot | Bandeja multicanal | [github.com/chatwoot/chatwoot](https://github.com/chatwoot/chatwoot) | MIT (salvo el directorio enterprise) | - |
| docassemble | Entrevistas guiadas que generan documentos | [github.com/jhpyle/docassemble](https://github.com/jhpyle/docassemble) | MIT | - |
| Metabase | Tableros | [github.com/metabase/metabase](https://github.com/metabase/metabase) | AGPL-3.0 (salvo el directorio enterprise) | - |
| Apache Superset | Tableros | [github.com/apache/superset](https://github.com/apache/superset) | Apache-2.0 | - |
| Grafana | Tableros operativos | [github.com/grafana/grafana](https://github.com/grafana/grafana) | AGPL-3.0 | - |
| LimeSurvey | Encuestas de percepción (HAIS-Q) | [github.com/LimeSurvey/LimeSurvey](https://github.com/LimeSurvey/LimeSurvey) | GPL-2.0 o posterior | - |
| OpenDP | Privacidad diferencial en métricas | [github.com/opendp/opendp](https://github.com/opendp/opendp) | MIT | - |
| River, PyOD | Anomalías en flujo y por lotes | [river](https://github.com/online-ml/river), [pyod](https://github.com/yzhao062/pyod) | BSD-3-Clause, BSD-2-Clause | - |
| Label Studio | Cola de revisión y etiquetado humano | [github.com/HumanSignal/label-studio](https://github.com/HumanSignal/label-studio) | Apache-2.0 | - |
| Apache Kafka | Flujo de eventos | [github.com/apache/kafka](https://github.com/apache/kafka) | Apache-2.0 | Opcional en el prototipo |
| Trillian | Registro de solo-anexado verificable | [github.com/google/trillian](https://github.com/google/trillian) | Apache-2.0 | - |
| minisign | Firma de mensajes oficiales | [github.com/jedisct1/minisign](https://github.com/jedisct1/minisign) | ISC | - |
| SimpleWebAuthn | Passkeys en web | [github.com/MasterKale/SimpleWebAuthn](https://github.com/MasterKale/SimpleWebAuthn) | MIT | - |
| Jitsi Meet | Videollamada autoalojada | [github.com/jitsi/jitsi-meet](https://github.com/jitsi/jitsi-meet) | Apache-2.0 | - |
| Workbox, Dexie.js | PWA sin conexión | [workbox](https://github.com/GoogleChrome/workbox), [Dexie.js](https://github.com/dexie/Dexie.js) | MIT, Apache-2.0 | - |
| ODK Collect | Formularios sin conexión en Android | [github.com/getodk/collect](https://github.com/getodk/collect) | Apache-2.0 | - |
| Xibo CMS | Pantallas de sala de espera | [github.com/xibosignage/xibo-cms](https://github.com/xibosignage/xibo-cms) | AGPL-3.0 | - |
| Moodle, H5P (h5p-php-library) | Microcursos y juegos | [moodle](https://github.com/moodle/moodle), [h5p-php-library](https://github.com/h5p/h5p-php-library) | GPL-3.0, GPL-3.0 | Que IESSEDUCA use Moodle **sin verificar** |
| Unleash | Banderas y pruebas A/B | [github.com/Unleash/unleash](https://github.com/Unleash/unleash) | AGPL-3.0 | - |
| parsedmarc, dnstwist | Informes DMARC, dominios parecidos | [parsedmarc](https://github.com/domainaware/parsedmarc), [dnstwist](https://github.com/elceef/dnstwist) | Apache-2.0, Apache-2.0 | - |
| urlscan-python | Captura de evidencia de URL | [github.com/urlscan/urlscan-python](https://github.com/urlscan/urlscan-python) | MIT (cliente; el servicio es comercial) | - |
| Google Password Alert | Alerta al escribir la clave institucional fuera de Google | [github.com/google/password-alert](https://github.com/google/password-alert) | Apache-2.0 | Último push en 03-2025; compatibilidad con Manifest V3 **sin verificar**. Google ofrece la misma función como política nativa de Chrome ([Google](https://support.google.com/a/answer/6197508)) |
| libphonenumber | Normalizar números | [github.com/google/libphonenumber](https://github.com/google/libphonenumber) | Apache-2.0 | - |
| Faker, Mimesis | Población sintética | [faker](https://github.com/joke2k/faker), [mimesis](https://github.com/lk-geimfari/mimesis) | MIT, MIT | Evitar SDV (BSL 1.1) y Gretel (licencia source-available) |
| pyca/cryptography | Hash con sal, firmas | [github.com/pyca/cryptography](https://github.com/pyca/cryptography) | Apache-2.0 o BSD | - |

## Supuestos de costo (estimación propia)
| Concepto | Valor usado | Base |
|---|---|---|
| Servidor virtual pequeño | USD 500-1.200 por año | Precios de nube públicos típicos; **estimación propia** |
| GPU para LLM de 4B a 8B o para el reconocimiento de voz de 1B a 7B | USD 3.000-8.000 de hardware o alquiler equivalente por año | **Estimación propia**; Omnilingual pide de 5 a 17 GiB de VRAM según el modelo (README) |
| SMS a Ecuador | USD 0,18-0,38 por segmento a precio de lista internacional | Plivo USD 0,2516 base (Claro 0,2969, Movistar 0,4267); terceros para Twilio ≈0,181. La tarifa por convenio con operadoras locales sería menor (**sin verificar**) |
| Plantilla de utilidad de WhatsApp | ≈USD 0,011 | [[07 Tabla maestra]] (V7). Una tabla de SleekFlow da 0,013 para «resto de Latinoamérica» (**sin verificar** la columna). Meta publica tarifas vigentes desde el 01-07-2026 |
| Mensajes de utilidad dentro de la ventana de 24 h abierta por el usuario | Gratis según Meta | Wati dice que vuelven a cobrarse desde el 01-10-2026: **discrepancia** |
| Minuto de llamada IVR | USD 0,02-0,05 | **Sin verificar**; depende del troncal SIP local |
| Analista o servidor a tiempo completo | USD 15.000-22.000 por año con cargas | **Estimación propia, sin verificar** escalas salariales del IESS |

---

## Fichas

### Familia A · Fricción entre el cambio y el dinero

#### S01 Pausa IESS · motor de enfriamiento y retención
| Campo | Contenido |
|---|---|
| Problema y eslabón | Hoy un tercero con la clave cambia correo, teléfono y cuenta y pide el préstamo en minutos. Corta **E2→E3**: protege aunque la clave ya se haya entregado |
| Usuario | Afiliado y jubilado (protegidos); unidad de fraude IESS/BIESS (opera) |
| Flujo | 1. Un evento de cambio (correo, teléfono, cuenta, dispositivo nuevo) llega al motor. 2. OPA evalúa la política según tipo de cambio, canal, antigüedad del dato anterior y si hay passkey, y abre una ventana de retención de 72 h sobre préstamos, fondos de reserva y nuevos cambios. 3. Temporal programa avisos al canal **anterior**: SMS, llamada IVR y correo con «si no fuiste tú, marca 1 o responde NO», sin enlaces. 4. «No fui yo» revierte el cambio, congela y abre un caso; si nadie responde, la ventana vence y libera. 5. El tablero muestra cambios revertidos, operaciones retenidas y tiempos |
| Pila | OPA (Apache-2.0), Temporal (MIT), Jambonz (MIT) o Asterisk (GPL-2.0) para la llamada, FastAPI, PostgreSQL, ntfy (Apache-2.0) para avisos internos |
| Demo en 10 min | Tres casos ficticios. (a) Jubilada de Guayaquil: el «sobrino» cambia la cuenta y 20 min después pide USD 9.000; el préstamo queda retenido, suena la llamada al número viejo, ella marca 1 y el cambio se revierte. (b) Afiliada joven cambia su número: nada pasa y a las 72 h se libera. (c) Migrante con passkey: ventana corta (enlace con S23) |
| Evidencia | V1 (B: −26 % de casos en Singapur, paquete, autoinformado); C11 (D); X1; fondos de reserva desde mayo de 2025, con aviso al correo anterior y al nuevo, el único control de fricción documentado en el IESS ([[01 Perfiles y canales del IESS]]). No se sabe si hoy hay espera entre cambio y préstamo ([[09 Huecos]]) |
| Riesgo legal y ético | No trata datos nuevos; privacidad desde el diseño (LOPDP art. 39). Puede retrasar a quien necesita dinero urgente, así que hace falta una excepción con verificación presencial. El aviso es imitable, por eso nunca pide datos, solo «marca 1 para bloquear». El canal anterior puede ser un celular compartido (inferencia del mapa); combinar con S08 |
| Costo de operación | USD 1.000-2.500 por año de infraestructura más mensajería por evento (SMS a USD 0,18-0,38 a precio de lista). **Estimación propia**. Dueños: DNTI y BIESS |
| Campana | Convergente |
| Venn | **S∩E∩G** |
| S | Rompe la secuencia cambio→dinero sin depender de que la víctima acierte |
| E | Convierte una regla en un mensaje que se puede enseñar: «si cambian tus datos, tu préstamo espera 3 días y te llamamos» (la inferencia transversal de [[08 Donde convergen las vertientes]]) |
| G | Reglas declarativas sin ML, métrica a 90 días (cambios revertidos); la dependencia del BIESS queda nombrada como dependencia |

#### S02 Candado BIESS voluntario
| Campo | Contenido |
|---|---|
| Problema y eslabón | El jubilado que nunca pide préstamos está igual de expuesto. Corta **E3** y el cambio de cuenta de **E2** |
| Usuario | Jubilado y su familia; ventanilla |
| Flujo | 1. Se activa por IVR (opción del 140), ventanilla, portal o persona de confianza; la persona de confianza solo puede activarlo, nunca quitarlo. 2. Con el candado puesto, préstamos, fondos y cambio de cuenta se rechazan con el mensaje «candado activo». 3. Para quitarlo: solicitud, espera de 48-72 h, aviso al titular y al contacto, y desbloqueo si nadie objeta; en ventanilla, con presencia, es inmediato. 4. Cada intento sobre una cuenta con candado se envía como señal a S04 |
| Pila | Keycloak (Apache-2.0) con atributo de usuario, OPA, Temporal, Asterisk y FreePBX (GPL-2.0 y GPL-3.0), FastAPI |
| Demo en 10 min | Activación por un IVR simulado con teclado en pantalla; un «tramitador» ficticio pide un préstamo y es rechazado; solicitud de desbloqueo y aviso a la hija |
| Evidencia | X1 (B en otro dominio: Monzo, Money Lock, Pix nocturno); V2 (D); V3 (B: −88 % en Brasil, autoinformado) |
| Riesgo legal y ético | Urgencias médicas; bloqueo malicioso por un familiar (por eso solo el titular lo quita); phishing tipo «activa tu candado», así que nunca se activa por enlace. Límite legal frente al derecho al crédito **sin verificar** |
| Costo de operación | USD 1.000-3.000 por año de infraestructura; el costo real está en la comunicación. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩E** |
| S | Corta E3 aunque el tramitador tenga la clave |
| E | Activarlo es una decisión consciente que se puede contar y enseñar a otros |
| G (no toca) | Depende del BIESS y de una adopción voluntaria incierta; no hay cifras de uso |

#### S03 Cuenta-Titular
| Campo | Contenido |
|---|---|
| Problema y eslabón | El dinero termina en cuentas mula de terceros. Corta **E2** y **E3** |
| Usuario | Sistema de registro de cuentas; servidor de ventanilla |
| Flujo | 1. Al registrar una cuenta bancaria, se pregunta al banco (API simulada) si la cédula del afiliado coincide con la del titular. 2. Respuestas posibles: coincide, coincide en parte (cuenta conjunta), no coincide o sin respuesta, sin revelar nombres. 3. «No coincide» bloquea o exige presencia; «en parte» alarga la ventana de S01. 4. Una cuenta que aparece en varias cédulas genera alerta en S04 |
| Pila | FastAPI, OPA, bancos simulados con Faker o Mimesis (MIT), PostgreSQL, cédula guardada como hash con sal (pyca/cryptography) |
| Demo en 10 min | Tres bancos ficticios; la cuenta del «sobrino» registrada a la cédula de una jubilada devuelve «no coincide» |
| Evidencia | V4 (B: −59 % de pagos a «cuenta incorrecta» con Confirmation of Payee en el Reino Unido). No se sabe si el BIESS ya exige que la cuenta sea del titular ([[09 Huecos]]) |
| Riesgo legal y ético | El intercambio con bancos necesita base legal y convenio; minimizar la respuesta a sí o no; la validación de identidad pasa por la DINARP ([[04 Marco legal]]) |
| Costo de operación | Infraestructura baja; costo medio por el convenio con bancos. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩G** |
| S | Corta el destino del dinero, incluso cuando lo opera un servidor cooptado |
| G | Servicio de sí o no, sin datos nuevos, reutilizable por otras instituciones; dependencia nombrada: bancos y Asobanca |
| E (no toca) | El ciudadano no lo ve |

#### S04 Centinela de Secuencia con revisión humana
| Campo | Contenido |
|---|---|
| Problema y eslabón | Patrones que ninguna persona ve sola: cambio + cuenta nueva + préstamo en N días; una IP o un dispositivo con muchas cédulas; una cuenta destino en varias cédulas; un servidor que cambia datos de afiliados de otra zona. En Guayaquil 2024 aparecieron 3 IP y 2 funcionarios. Corta **E2→E3** y **EI** |
| Usuario | Analista de fraude |
| Flujo | 1. Eventos sintéticos entran a un flujo (Kafka opcional). 2. Reglas explicables en YAML, más un puntaje de anomalía no supervisado (River o PyOD) que solo ordena la cola y nunca decide. 3. Los casos prioritarios activan la retención de S01 y pasan a una cola humana con la explicación («misma IP que 14 cédulas en 3 días»). 4. El analista llama al número histórico, resuelve, y su etiqueta realimenta las reglas. 5. Informe de sesgo: tasa de alertas por edad, provincia y ruralidad; está prohibido usar nacionalidad, etnia o discapacidad |
| Pila | River (BSD-3-Clause), PyOD (BSD-2-Clause), Apache Kafka (Apache-2.0), OpenSearch (Apache-2.0), Label Studio (Apache-2.0) o Zammad (AGPL-3.0) como cola, Superset (Apache-2.0) |
| Demo en 10 min | 50.000 eventos sintéticos con una red de tramitador inyectada (3 IP, 20 jubilados); el panel muestra el racimo, el analista retiene y «llama» |
| Evidencia | V13 (B, autorreporte bancario); V22 (B: 94 %, Universidad de Michigan); caso Guayaquil 2024 ([Expreso, 13-12-2024](https://www.expreso.ec/actualidad/economia/iess-biess-investigan-fraude-detectan-funcionarios-ips-implicados-estafas-jubilados-224394.html)). Líneas rojas N2 y N3 |
| Riesgo legal y ético | Perfilado: evaluación de impacto (LOPDP art. 42), intervención humana, Res. SPDP 2026-0009-R (texto no obtenido). Cada alerta solo produce fricción, nunca una negativa, y cada decisión queda registrada |
| Costo de operación | Con reglas: 1 VM y medio analista, USD 9.000-13.000 por año; con ML, medio. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩G** |
| S | Detecta redes de tramitadores y servidores cooptados en E2, antes del desembolso |
| G | Empieza con reglas baratas y escala; mide precisión y sesgo a 90 días |
| E (no toca) | No cambia la conducta de nadie |

#### S05 Pregunta en el Momento
| Campo | Contenido |
|---|---|
| Problema y eslabón | En el momento del préstamo o del cambio de cuenta, el ayudante está sentado al lado. Actúa sobre **E1** y **E3** |
| Usuario | Afiliado en el portal o en el BIESS, y el ayudante que lee la pantalla |
| Flujo | 1. Al pedir un préstamo o cambiar la cuenta aparece una pantalla breve: «¿Alguien te está ayudando ahora con tu clave?». 2. Si la respuesta es sí, un mensaje que no culpa: «la mayoría de jubilados de tu provincia hace esto solo o con un ayudante registrado», con la opción de registrar al ayudante (S06) y de pausar 24 h. 3. Botón «quiero que me llame el IESS» al número histórico. 4. Prueba A/B de variantes; métricas: pausas voluntarias, préstamos cancelados y reclamos posteriores |
| Pila | Componente web accesible (WCAG 2.2 AA), Unleash (AGPL-3.0) para variantes, FastAPI, Piper (GPL-3.0) para leer en voz alta |
| Demo en 10 min | Portal BIESS simulado con dos variantes y 1.000 sesiones sintéticas cuyos resultados se marcan como ficticios |
| Evidencia | P11 (A en otro dominio: +15 pp, BIT y HMRC en impuestos). La norma social exige un dato real: no se puede inventar la proporción |
| Riesgo legal y ético | Mensaje verdadero o ninguno; no culpar a la víctima; el ayudante puede contestar por ella; informar del uso de pruebas A/B con ciudadanos |
| Costo de operación | Costo marginal casi nulo; solo desarrollo. **Estimación propia** |
| Campana | Periferia |
| Venn | **S∩E∩G** |
| S | Mete una pausa justo antes de E3 |
| E | Enseña en el momento de riesgo con una regla y una norma social |
| G | Costo marginal nulo y efecto medible con A/B en semanas |

### Familia B · Delegación legítima y presencia

#### S06 Ayudante Registrado
| Campo | Contenido |
|---|---|
| Problema y eslabón | La clave se presta porque no existe una vía legal para ayudar. Ataca la causa raíz de **E1** |
| Usuario | Jubilado o campesino, y su ayudante (hijo, nieto, vecino o dirigente) |
| Flujo | 1. El titular registra al ayudante en ventanilla, en un dispensario o por IVR con un código de un solo uso; el ayudante crea su propia credencial (passkey o clave propia). 2. OpenFGA guarda la relación «ayudante de» con permisos acotados: consultar aportes, agendar citas, bajar certificados y planillas; nunca cambiar cuenta o contacto, pedir préstamos ni retirar fondos. 3. El ayudante entra con su credencial y elige «actuar por Rosa»; Keycloak emite un token delegado (token exchange) y todo queda registrado como «ayudante X por Rosa». 4. El titular recibe por SMS o IVR un resumen semanal de lo que hizo su ayudante y lo revoca con una tecla. 5. Campaña: «No prestes tu clave: registra a tu ayudante» |
| Pila | Keycloak 26.x (Apache-2.0) con token exchange estándar (26.2) y claim `act` (26.8, **verificar**); OpenFGA (Apache-2.0); OPA; Asterisk; FastAPI |
| Demo en 10 min | Rosa (ficticia) registra a su nieto; el nieto agenda una cita (permitido) e intenta cambiar la cuenta (denegado con explicación); Rosa escucha su resumen por IVR |
| Evidencia | V6 (C/D: Meu INSS en Brasil, NHS proxy access). Es el hueco principal de [[09 Huecos]]: no hay cifras de uso ni de efecto |
| Riesgo legal y ético | Registro de un tercero (consentimiento, minimización). El ayudante puede ser el explotador: por eso no toca dinero. Hace falta una reforma normativa, porque hoy la clave es «personal e intransferible» ([[02 Amenazas y fraude en Ecuador]]) |
| Costo de operación | USD 2.000-5.000 por año de infraestructura más soporte de registro en ventanilla. **Estimación propia** |
| Campana | Convergente (nuevo en Ecuador) |
| Venn | **S∩E∩G** |
| S | Quita la necesidad de prestar la clave, que es el vector documentado del IESS |
| E | Ofrece una conducta alternativa concreta en lugar de una prohibición |
| G | Componentes maduros; se puede pilotar en un dispensario y medir registros y caída de sesiones compartidas |

#### S07 Sesión Asistida para cibercafés y tramitadores acreditados
| Campo | Contenido |
|---|---|
| Problema y eslabón | El cibercafé y el tramitador comercial (la jubilada de 78 años que pidió USD 5.000 y terminó con USD 14.000 de deuda). **E1** |
| Usuario | Intermediario comercial acreditado; afiliado sin smartphone |
| Flujo | 1. El intermediario se acredita (RUC, curso corto, código de conducta) y recibe una credencial de operador. 2. Abre una «sesión asistida» para una cédula; el sistema llama al teléfono básico del afiliado: «Don X, en el cibercafé Y, quiere ayudarte con [trámite]. Marca 1 para autorizar solo eso por 30 minutos». 3. La sesión queda limitada a ese trámite, siempre sin dinero, y registra al operador. 4. El afiliado recibe un código para reclamar; reclamos y valoraciones alimentan un registro público de acreditados, con revocación |
| Pila | Keycloak (roles de operador), OpenFGA, Jambonz (MIT) para la llamada de aprobación, FastAPI, PostgreSQL |
| Demo en 10 min | Un operador ficticio pide un certificado de aportes para una jubilada; suena el teléfono simulado; ella aprueba; el intento de préstamo se bloquea |
| Evidencia | Sin antecedente evaluado (D); testimonio del cibercafé ([Expreso, 13-12-2024](https://www.expreso.ec/actualidad/economia/iess-biess-investigan-fraude-detectan-funcionarios-ips-implicados-estafas-jubilados-224394.html)); la directora de Fondos de Terceros atribuye el fraude a «terceros a quienes los afiliados piden ayuda» ([[02 Amenazas y fraude en Ecuador]]) |
| Riesgo legal y ético | Puede legitimar el mercado de tramitadores; trata datos del operador; excluye a quien no tiene teléfono, por lo que necesita alternativa en ventanilla |
| Costo de operación | Medio: la acreditación es un proceso, más el costo de las llamadas por sesión. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩E** |
| S | El intermediario nunca conoce la clave ni toca dinero |
| E | Enseña que se autoriza un trámite, no que se «entrega la clave» |
| G (no toca) | Acreditar intermediarios es un proceso pesado y políticamente delicado |

#### S08 Persona de Confianza sin poder de operar
| Campo | Contenido |
|---|---|
| Problema y eslabón | La víctima se entera tarde y el «canal anterior» puede ser un celular compartido con el propio estafador. **E4**, y **E3** cuando hay pausa |
| Usuario | Jubilado; migrante (contacto en el exterior o padres en Ecuador) |
| Flujo | 1. El afiliado designa un contacto que no ve saldos ni opera. 2. Ante un evento de riesgo (cambio de cuenta o teléfono, préstamo sobre un umbral) el contacto recibe aviso por WhatsApp, SMS o IVR. 3. El contacto puede pulsar «pausar 24 h y que llamen a mi familiar», pero no revertir. 4. El IESS llama al titular por el número histórico y abre caso |
| Pila | FastAPI, Temporal, WhatsApp Cloud API (servicio comercial), Jambonz (MIT), OpenFGA para la relación |
| Demo en 10 min | La hija en Madrid (ficticia) recibe un WhatsApp: «se pidió un préstamo a nombre de tu papá»; pulsa pausar y el préstamo queda retenido |
| Evidencia | V5 (C: FINRA 4512 y banca de EE. UU.); E4 es hueco en [[09 Huecos]] |
| Riesgo legal y ético | El contacto puede ser el explotador, por eso no opera; consentimiento del tercero; datos mínimos en el aviso |
| Costo de operación | Bajo: ≈USD 0,011 por aviso de WhatsApp (verificar tarifa 2026) sobre la infraestructura de S01. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩G** |
| S | Segunda línea de detección en E4 y freno en E3 |
| G | Reutiliza el motor de S01; costo por aviso muy bajo |
| E (no toca) | Solo indirecta, para el contacto |

#### S09 Protocolo de Ventanilla Digital
| Campo | Contenido |
|---|---|
| Problema y eslabón | El jubilado llega a ventanilla con un «ayudante» para cambiar la cuenta o pedir un préstamo, y el servidor no tiene guion. **E2**, **E3** y **EI** (el servidor que mira para otro lado) |
| Usuario | Servidor de ventanilla IESS y BIESS; supervisor |
| Flujo | 1. Al iniciar un cambio de cuenta o un préstamo para un mayor de 65 con acompañante, la tablet muestra una tarjeta de decisión de cinco preguntas sobre conducta, no sobre edad. 2. Con dos o más señales, guía un «momento a solas» con pregunta abierta. 3. Escala al supervisor y, si hay convenio, a la policía comunitaria. 4. El caso se registra sin datos de salud; el servidor recibe después el desenlace; el OSI ve un tablero de casos |
| Pila | PWA sin conexión con Workbox (MIT) y Dexie.js (Apache-2.0), Flowable (Apache-2.0) para el escalamiento, Metabase (AGPL-3.0) |
| Demo en 10 min | Juego de rol: servidor ficticio con tablet; el «sobrino» responde por la jubilada; la tarjeta lleva al escalamiento |
| Evidencia | P7 (B: £258,2 millones evitados y 1.202 detenciones, Banking Protocol del Reino Unido) |
| Riesgo legal y ético | Discriminación por edad: los criterios deben ser de conducta. Datos mínimos en el caso |
| Costo de operación | USD 5.000-15.000 para un piloto en una agencia (desarrollo y capacitación), sobre tablets existentes (**sin verificar**). **Estimación propia** |
| Campana | Periferia |
| Venn | **S∩E∩G** |
| S | Frena E2 y E3 en el lugar donde se entrega la clave |
| E | Formación embebida en el momento real del trabajo del servidor |
| G | Barato, se pilota en una agencia, métrica de casos frenados |

### Familia C · Canales verificables y reporte que cierra el ciclo

#### S10 «¿Es del IESS?» · bot oficial con registro de envíos
| Campo | Contenido |
|---|---|
| Problema y eslabón | Mensajes falsos por WhatsApp y SMS («reembolso pendiente», «actualiza tus datos»). **E1** |
| Usuario | Afiliado con WhatsApp; familiares de jubilados |
| Flujo | 1. Cada envío oficial (SMS, WhatsApp, correo) se registra con hash del texto, remitente, fecha y campaña. 2. El usuario reenvía el mensaje, una captura o un número al bot oficial verificado. 3. El bot coteja y responde en tres niveles: «Oficial» si coincide con el registro; «Estafa conocida: no respondas; si diste tu clave, llama al 140» si coincide con la base de estafas; «No es un envío registrado del IESS: no lo uses, llama al 140» si es desconocido. El LLM local solo redacta la explicación y nunca declara algo oficial. 4. El reporte alimenta S14. 5. Presidio quita datos personales antes de guardar y todo se borra a los 30 días |
| Pila | WhatsApp Cloud API (comercial), FastAPI, PostgreSQL, Presidio (MIT), Qwen3-4B u 8B (Apache-2.0) con Ollama (MIT), base al estilo Cofacts (rumors-api, MIT). Rasa no se recomienda por su estado de mantenimiento |
| Demo en 10 min | Reenviar cuatro mensajes ficticios: el SMS de reembolso en 24 h (estafa conocida), un recordatorio de cita registrado (oficial), un texto nuevo (desconocido) y una captura |
| Evidencia | V7 (B en adopción, sin dato de exactitud; ScamShield en Singapur); P10 (B/C, Cofacts); C7 (centro: el detector con LLM genera sobreconfianza). La diferencia es que aquí decide el registro, no el LLM |
| Riesgo legal y ético | Datos de terceros en los reenvíos (minimizar y borrar); Res. SPDP 2026-0009-R; la API de Meta implica transferencia internacional (Res. 2026-0004-R); el bot puede clonarse, por eso hace falta número verificado y difundir un número único |
| Costo de operación | USD 3.000-8.000 por año (CPU o GPU pequeña); los mensajes que inicia el usuario serían gratuitos dentro de la ventana de servicio, con la discrepancia ya señalada. **Estimación propia** |
| Campana | Convergente (en la frontera del centro) |
| Venn | **S∩E∩G** |
| S | Corta E1 antes de que se entregue la clave o se abra el enlace |
| E | Cada respuesta enseña una acción única («llama al 140»), no una lista de señales (N7) |
| G | Barato, en el canal dominante (WhatsApp, 43 % según una fuente sin metodología) y con métrica de reportes |

#### S11 Sello Verificable · registro público de comunicaciones oficiales
| Campo | Contenido |
|---|---|
| Problema y eslabón | Ni la prensa sabe qué número sirve para qué ([[01 Perfiles y canales del IESS]]: WhatsApp de citas o de denuncias). **E1** |
| Usuario | Prensa, verificadores (Lupa Media), bancos, ciudadanos y el propio bot S10 |
| Flujo | 1. Cada campaña oficial (texto, canales, remitentes, números, fechas) se publica firmada en un registro de solo-anexado. 2. Página pública y API: «¿este número, remitente o texto es del IESS?». 3. Directorio canónico de canales (qué número sirve para qué), también firmado. 4. Monitores externos comprueban que nadie reescribió la historia |
| Pila | Trillian (Apache-2.0), minisign (ISC), sitio estático y una API pequeña |
| Demo en 10 min | Publicar una campaña ficticia, verificar un texto y mostrar que alterar el registro rompe la prueba |
| Evidencia | Contradicción de fuentes sobre el WhatsApp del IESS (01); V9 como análogo (B: −70 % de casos por SMS con registro de remitentes). Para el sello en sí: D |
| Riesgo legal y ético | Bajo: no hay datos personales |
| Costo de operación | USD 500-1.500 por año. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩G** |
| S | Quita la ambigüedad que aprovecha el estafador |
| G | Barato, auditable, reutilizable por MINTEL para todo el Estado |
| E (no toca) | El ciudadano no aprende nada nuevo solo con el registro |

#### S12 «¿Me llamó el IESS?»
| Campo | Contenido |
|---|---|
| Problema y eslabón | Llamadas de falsos funcionarios que citan datos filtrados reales (Novaestrat, Registro Civil 2026). **E1** por voz |
| Usuario | Afiliado con teléfono básico, también en zonas rurales |
| Flujo | 1. Toda llamada saliente oficial (call center, agencias) se registra: número destino con hash, hora y área. 2. Regla pública: «El IESS nunca pide tu clave. Si te llaman, cuelga y marca 140, opción 9». 3. En la opción 9, el sistema reconoce el número desde el que llama la persona y responde «en las últimas 24 h te llamó el área de Citas» o «no te llamamos: fue un intento de estafa», con opción de reportar. 4. Los reportes van a S14 |
| Pila | Asterisk y FreePBX (GPL) o Jambonz (MIT), libphonenumber (Apache-2.0), PostgreSQL, hash con sal |
| Demo en 10 min | Un teléfono simulado recibe una llamada falsa «del IESS»; la persona marca 140-9 y escucha «no te llamamos» |
| Evidencia | V17 (A: enseñar un procedimiento funciona mejor que enseñar señales); C12 (D); identidad filtrada ([[02 Amenazas y fraude en Ecuador]]). Sin antecedente localizado del registro: D |
| Riesgo legal y ético | El registro de llamadas salientes es un dato personal mínimo; el celular compartido sigue siendo un problema |
| Costo de operación | Bajo sobre el IVR existente. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩E** |
| S | Verifica sin que el afiliado tenga que detectar nada |
| E | Enseña un único procedimiento que se puede practicar: colgar y marcar |
| G (no toca) | Exige que todas las áreas registren sus llamadas salientes; dependencia de la DNTI y del 140 no resuelta |

#### S13 Palabra de Familia
| Campo | Contenido |
|---|---|
| Problema y eslabón | Voz clonada o WhatsApp falso del «hijo migrante en apuros». **E1** para migrantes y sus familias |
| Usuario | Migrantes y sus padres jubilados |
| Flujo | 1. Un mini-flujo en el bot S10, o una tarjeta, genera una frase de dos palabras en español o kichwa que la familia acuerda por una vía conocida; el sistema no la guarda. 2. Ensayo avisado: el bot muestra un mensaje genérico «mamá, estoy en problemas, manda plata» y guía a pedir la palabra. 3. Recordatorio trimestral |
| Pila | Bot de S10; generador en el navegador con lista de palabras; Piper (GPL-3.0) con una voz genérica, nunca clonada |
| Demo en 10 min | Generar una frase y hacer el ensayo de un minuto |
| Evidencia | V16 (D: FBI, Starling Bank); falta evidencia sobre palabras clave ([[09 Huecos]]) |
| Riesgo legal y ético | Nunca almacenar la palabra; avisar del ensayo antes, sin engaño |
| Costo de operación | Casi cero. **Estimación propia** |
| Campana | Convergente |
| Venn | **E∩G** |
| E | Conducta concreta y ensayada |
| G | Costo cero, se monta sobre S10 |
| S (no toca) | No corta un eslabón del fraude IESS documentado; protege contra un vector vecino |

#### S14 Radar de Campañas · generador de alertas de campañas activas
| Campo | Contenido |
|---|---|
| Problema y eslabón | Las estafas llegan en olas y el comunicado sale tarde (C6). **E1** del lado de la oferta |
| Usuario | Comunicación y DNSIPD; aliados (EcuCERT, verificadores) |
| Flujo | 1. Entran reportes del bot S10, el 140, denuncias.iess.gob.ec, el botón de S28 y la prensa. 2. Se agrupan por similitud en «brotes», con conteo por provincia y canal. 3. Al pasar un umbral se genera un borrador de alerta 2-2-2 (menos de 2 h, 2 imágenes, menos de 200 caracteres) en español y un guion para grabar en kichwa; una persona lo aprueba. 4. Difusión: canal de WhatsApp, mensaje del día en el IVR, pantallas de S21, Workspace interno e indicadores en MISP para EcuCERT. 5. La curva de cada brote sirve para evaluar |
| Pila | MISP (AGPL-3.0), Node-RED (Apache-2.0; se evita n8n por su licencia), Qwen3 (Apache-2.0) con Ollama para borradores, OpenSearch, Grafana (AGPL-3.0) o Superset |
| Demo en 10 min | Inyectar 200 reportes ficticios de «reembolso pendiente»; el radar marca un brote en Guayas; el borrador está listo en un minuto y se aprueba en pantalla |
| Evidencia | X6 (D); X5 (C: Taiwán 2020); P12 (B); la combinación «Brote IESS» es la más demostrable en 10 minutos según [[08 Donde convergen las vertientes]] |
| Riesgo legal y ético | Datos personales en los reportes (Presidio); el humor del formato 2-2-2 no debe trivializar a las víctimas |
| Costo de operación | USD 5.000-12.000 por año de infraestructura más un cuarto de tiempo de comunicación. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩E∩G** |
| S | Reduce la ventana de exposición de cada campaña |
| E | Alerta con una acción única en el momento de la ola, que es cuando la gente presta atención |
| G | Reutiliza reportes que ya existen; métrica: tiempo del reporte a la alerta |

#### S15 Reporta y lo Bajamos
| Campo | Contenido |
|---|---|
| Problema y eslabón | Sitios y perfiles falsos siguen activos durante días. **E1** del lado de la oferta |
| Usuario | SOC y DNSIPD |
| Flujo | 1. Una URL o un perfil reportado se captura como evidencia. 2. Se genera la solicitud de baja al registrador, al hosting o a Meta con una plantilla. 3. Se sigue el caso hasta la baja. 4. Un tablero público muestra los sitios bajados y el tiempo medio |
| Pila | urlscan-python (MIT; el servicio es comercial) o Chromium sin interfaz, Shuffle (AGPL-3.0), DFIR-IRIS (LGPL-3.0), alimentado por S20 |
| Demo en 10 min | El dominio ficticio `iess-reembolsos.test` se detecta, se captura y genera su caso de baja |
| Evidencia | P12 (B: servicio de retiro del NCSC británico) |
| Riesgo legal y ético | Bajo; las capturas pueden contener datos de víctimas |
| Costo de operación | Medio recurrente por horas de analista. **Estimación propia** |
| Campana | Periferia |
| Venn | **S∩G** |
| S | Reduce la oferta de sitios falsos |
| G | Proceso repetible con indicador público |
| E (no toca) | Solo indirecta, si el tablero se difunde |

### Familia D · Práctica narrativa con refuerzo e inclusión

#### S16 «¿Real o falso?» con refuerzos
| Campo | Contenido |
|---|---|
| Problema y eslabón | El efecto de la inoculación desaparece a las cuatro semanas. **E1** y **E4** |
| Usuario | Afiliados activos, jubilados con WhatsApp, familiares |
| Flujo | 1. Inscripción voluntaria en el canal oficial. 2. Cada 2-3 semanas, tres ejemplos «¿real o falso?» tomados del guion del IESS, incluidos mensajes sin marcadores obvios, con botones. 3. Retroalimentación inmediata con la regla institucional. 4. Repetición espaciada: lo que falla vuelve antes. 5. Ensayo aleatorio con grupo en lista de espera; métricas: aciertos y reportes reales a S10 |
| Pila | WhatsApp Cloud API, FastAPI, banco de ítems en JSON, H5P (GPL-3.0) para la versión web, LimeSurvey (GPL-2.0+) para medir antes y después |
| Demo en 10 min | Recorrido de tres ítems y panel de aciertos de una cohorte sintética |
| Evidencia | V14 (A: +7 pp de aciertos, sin diferencia significativa a las 4 semanas y sin efecto en SMS; AARP y SSA, Robb y Wendel, 4.164 participantes) |
| Riesgo legal y ético | Bajo; respuestas seudonimizadas |
| Costo de operación | Plantillas de marketing de WhatsApp, tarifa 2026 **sin verificar**; infraestructura USD 1.000-2.000 por año. **Estimación propia** |
| Campana | Convergente |
| Venn | **E∩G** |
| E | Tiene la mejor evidencia cultural del mapa y diseña el refuerzo que le faltaba |
| G | Bajo costo y un ensayo con comparación en 90 días |
| S (no toca) | No corta un eslabón por sí misma |

#### S17 SMS que Enseña · ensayo del canal SMS
| Campo | Contenido |
|---|---|
| Problema y eslabón | La inoculación no tuvo efecto por SMS, uno de los dos canales dominantes en Ecuador. **E1** |
| Usuario | Afiliado con teléfono básico |
| Flujo | 1. Inscripción por SMS a un código corto. 2. Microejercicio: «Te llegó esto: [texto de estafa sin enlace, rotulado SIMULACRO]. Responde 1 si es falso, 2 si es real». 3. Respuesta inmediata con la regla. 4. Diseño 2x2: con o sin refuerzo, con o sin una llamada IVR de 30 segundos. 5. Prueba a las 4 y 8 semanas |
| Pila | Agregador SMS (Twilio u operador local, comerciales), Node-RED (Apache-2.0), PostgreSQL. TextIt/RapidPro es opción, pero con BSL 1.1 |
| Demo en 10 min | Teléfono simulado con tres SMS y el resultado en el panel |
| Evidencia | V14 (sin efecto en SMS). Esta idea es el experimento que falta, no una solución probada |
| Riesgo legal y ético | Simulacros dirigidos a ciudadanos: solo con inscripción, rotulados, sin enlaces y nunca con cebo de bono (N1) |
| Costo de operación | 10.000 participantes × 12 SMS = USD 21.600-45.600 a precio de lista. **Estimación propia** |
| Campana | Atípico |
| Venn | **E∩G** |
| E | Prueba si el SMS puede enseñar con otro formato |
| G | Produce una medición que la región no tiene, con costo acotado por el tamaño de la muestra |
| S (no toca) | No corta ningún eslabón |

#### S18 Historias por Teléfono · juego de voz IVR en español y kichwa, con radionovela
| Campo | Contenido |
|---|---|
| Problema y eslabón | Campesinos y jubilados sin smartphone; no hay nada en kichwa. **E1** y **E4** |
| Usuario | Jubilados campesinos, hablantes de kichwa, oyentes de radio comunitaria |
| Flujo | 1. Llamada gratuita a un número único. 2. Elección de idioma: 1 español, 2 kichwa. 3. Episodio de tres minutos grabado por hablantes nativos que termina en una decisión («el sobrino pide la clave: 1 se la doy, 2 le digo que se registre como ayudante») y su consecuencia narrada. 4. Refuerzo: episodio nuevo cada dos semanas por llamada saliente para quien se inscribe; una radionovela en radios comunitarias remite al mismo número para «votar el final». 5. Métricas: episodios completados, aciertos, llamadas al 140 |
| Pila | Ink (MIT) o Twine (GPL-3.0) para el guion ramificado, exportado a un diálogo IVR en Asterisk y FreePBX (GPL) o Jambonz (MIT); grabaciones humanas. MMS-TTS (CC-BY-NC-4.0) solo para maqueta, y solo en las variedades que tienen modelo |
| Demo en 10 min | Llamada desde un softphone; episodio en español y en kichwa (grabación de maqueta); tablero de votos ficticios |
| Evidencia | P1 (A-/B: la pérdida por fraude bajó de 7,1 % a 5,7 % en Uganda, IPA y Viamo, con costo menor a USD 150.000); P2 (D); P3 (A en otro dominio) |
| Riesgo legal y ético | Mínimo. Traducción validada por hablantes de cada variedad; no imitar la voz de personas reales |
| Costo de operación | USD 20.000-60.000 el primer año, sobre todo producción; costo por minuto **sin verificar**. **Estimación propia** |
| Campana | Periferia |
| Venn | **E∩G** |
| E | Ensaya la decisión con su consecuencia: es la práctica narrativa con refuerzo |
| G | Costo marginal bajo, funciona con teléfono básico y durante apagones |
| S (no toca) | El efecto sobre E1 es indirecto |

#### S19 Kichwa Rimay · reporte y menú por voz en kichwa
| Campo | Contenido |
|---|---|
| Problema y eslabón | Quien habla kichwa no puede reportar ni consultar en su idioma. Abre **E4→E3** (reporte que congela) y apoya **E1** |
| Usuario | Hablantes de kichwa; operadores bilingües |
| Flujo | 1. Línea con menú en kichwa; la persona cuenta con su voz qué pasó. 2. Omnilingual ASR transcribe (variedades qvi o qug) y un clasificador sencillo detecta la intención: estafa, «no reconozco el préstamo» o consulta. 3. El caso llega a un operador bilingüe con audio y transcripción; «no reconozco» dispara S25. 4. Los audios se borran al resolver y las transcripciones se seudonimizan |
| Pila | Omnilingual ASR (Apache-2.0, códigos de kichwa verificados en `lang_ids.py`); Common Voice Kichwa (CC0) solo para evaluar en local; Vosk (Apache-2.0) para español; Jambonz o Asterisk |
| Demo en 10 min | Cinco audios grabados por el equipo con guion ficticio: transcripción, intención y caso abierto |
| Evidencia | P2 (D: Línea 101 y MarIA en Perú); hueco kichwa ([[09 Huecos]]); Killkan, primer corpus de reconocimiento de voz en kichwa ([LREC-COLING 2024](https://aclanthology.org/2024.lrec-main.852)). El CER de Meta para qvi (3,5) y qug (17,5) **no está medido en audio telefónico** |
| Riesgo legal y ético | La voz es dato personal; sería biométrica solo si se usa para identificar (Res. 2026-0039-R, texto no obtenido). Evaluación de impacto; Res. 2026-0009-R; los errores del reconocimiento exigen siempre revisión humana |
| Costo de operación | Hardware de GPU USD 3.000-8.000 (de 5 a 17 GiB de VRAM según el modelo) más operadores bilingües. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩E** |
| S | Da canal de reporte que congela a quien hoy no lo tiene |
| E | Trata el idioma como canal de cultura, no como traducción de última hora |
| G (no toca) | Desempeño en telefonía real sin medir; disponibilidad de operadores bilingües **sin verificar** |

#### S20 Vigía de Dominio · DMARC y dominios parecidos
| Campo | Contenido |
|---|---|
| Problema y eslabón | Suplantación del dominio y de dominios parecidos; el estado de DMARC de iess.gob.ec no se conoce ([[09 Huecos]]). **E1** |
| Usuario | DNTI y SOC |
| Flujo | 1. parsedmarc procesa los informes agregados de DMARC y muestra quién envía en nombre de iess.gob.ec. 2. Plan por etapas para pasar a p=reject. 3. dnstwist vigila dominios parecidos a iess.gob.ec y biess.fin.ec y alimenta S15 y S34. 4. Tablero |
| Pila | parsedmarc (Apache-2.0), dnstwist (Apache-2.0), OpenSearch y Grafana |
| Demo en 10 min | Informes DMARC sintéticos, un remitente no autorizado y un dominio parecido detectado |
| Evidencia | C10 (B: unos 500 millones de correos bloqueados, HMRC) |
| Riesgo legal y ético | Ninguno relevante |
| Costo de operación | USD 500-1.500 por año. **Estimación propia** |
| Campana | Centro |
| Venn | **S∩G** |
| S | Corta la suplantación del dominio real |
| G | Muy barato y con indicador claro |
| E (no toca) | Higiene técnica, no cultura |

#### S21 Pantalla viva en sala de espera
| Campo | Contenido |
|---|---|
| Problema y eslabón | 16,9 millones de atenciones al año pasan por salas de espera: es el canal masivo hacia quien menos usa lo digital. **E1** |
| Usuario | Pacientes y acompañantes en 102 unidades médicas y en dispensarios |
| Flujo | 1. Xibo programa videos de 30-60 segundos que explican la técnica del estafador (no listas de señales), en español y kichwa, con subtítulos. 2. Las alertas del Radar (S14) se insertan en vivo. 3. Un número corto por unidad invita a jugar S18 o S16. 4. Las llamadas por unidad miden el alcance |
| Pila | Xibo CMS (AGPL-3.0); videos propios; S14 |
| Demo en 10 min | La pantalla muestra una alerta un minuto después de detectarse el brote en S14 |
| Evidencia | V15 (A: 1,8-5,4 %, sin datos en mayores); [[01 Perfiles y canales del IESS]] (salas de espera como canal) |
| Riesgo legal y ético | Bajo; accesibilidad (subtítulos, contraste) |
| Costo de operación | Reproductores de USD 100-200 por pantalla; que existan pantallas en las unidades está **sin verificar**. **Estimación propia** |
| Campana | Periferia |
| Venn | **E∩G** |
| E | Enseña la técnica antes de la exposición, en un momento de espera |
| G | Usa infraestructura física que ya existe y se mide por unidad |
| S (no toca) | No corta eslabones |

#### S22 Centinela sin Conexión · PWA para monitores pares
| Campo | Contenido |
|---|---|
| Problema y eslabón | Los dirigentes de 659 dispensarios del Seguro Social Campesino trabajan con poca conectividad y con apagones. **E1** y **E4** |
| Usuario | Monitores pares, dirigentes y promotores del SSC |
| Flujo | 1. PWA instalable con contenido sin conexión: guiones, audios y la tarjeta «antes de ayudar». 2. Registro de sesiones y casos sospechosos sin datos personales (conteos y tipo). 3. Sincroniza al recuperar señal; ante un caso urgente, un botón arma el SMS al 140. 4. Reconocimiento a los monitores (certificados) |
| Pila | Workbox (MIT), Dexie.js (Apache-2.0), ODK Collect (Apache-2.0) como alternativa en Android, FastAPI |
| Demo en 10 min | En modo avión se registra una sesión; al reconectar aparece en el tablero |
| Evidencia | P4 (C: IPS Chile, Mendoza, SERNAC); P9 (C); P8 (D) |
| Riesgo legal y ético | El monitor puede convertirse en tramitador (P4): nunca maneja claves; registro de monitores |
| Costo de operación | USD 2.000-6.000 por año. **Estimación propia** |
| Campana | Periferia |
| Venn | **E∩G** |
| E | Sostiene la enseñanza entre pares con material y refuerzo |
| G | Barata, resiste apagones y deja medición agregada |
| S (no toca) | Solo indirecta, por la escalada al 140 |

### Familia E · Migrantes y víctima que se entera tarde

#### S23 Llave de Viaje · passkey y verificación remota para migrantes
| Campo | Contenido |
|---|---|
| Problema y eslabón | El enfriamiento y la presencialidad castigan justo los trámites remotos del migrante (unos 8.000 en 2025) y ya hubo retiros de cesantía con documentos falsos. **E1**, **E2** y **E3** |
| Usuario | Migrantes (25.099 afiliados voluntarios en el exterior) |
| Flujo | 1. Registro de una passkey FIDO2 en consulado, ventanilla o desde un dispositivo ya verificado antes de viajar. 2. Las operaciones remotas con passkey tienen una ventana de enfriamiento corta (política de S01). 3. Sin passkey: videollamada agendada con dos servidores de áreas distintas (doble control), sin usar el rostro como prueba única. 4. Aviso a la persona de confianza en Ecuador (S08) |
| Pila | Keycloak 26.4+ (Apache-2.0, passkeys con soporte oficial), SimpleWebAuthn (MIT), Jitsi Meet (Apache-2.0) autoalojado, Flowable |
| Demo en 10 min | Migrante ficticio en Madrid registra una passkey en el navegador; su cambio de cuenta sale con ventana de 12 h; otro sin passkey agenda la videollamada |
| Evidencia | V10 (D, por diseño); hueco de migrantes ([[09 Huecos]]); N4 (biometría como bala de plata) |
| Riesgo legal y ético | La grabación de la videollamada es dato personal; usar el rostro para identificar sería biometría (Res. 2026-0039-R), así que se evita; servidor de video dentro del país para no transferir datos |
| Costo de operación | Medio: infraestructura baja, pero horas de servidores para las videollamadas. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩G** |
| S | Credencial ligada al dominio real: no funciona en un sitio falso ni se dicta por teléfono (aunque sí se puede prestar el dispositivo) |
| G | Piezas maduras; evita castigar al migrante con la fricción pensada para otros |
| E (no toca) | No cambia conducta por sí misma |

#### S24 Tu Mes en el IESS · avisos por evento y resumen por voz
| Campo | Contenido |
|---|---|
| Problema y eslabón | La víctima se entera meses después, por los descuentos. **E4** |
| Usuario | Jubilados y afiliados |
| Flujo | 1. Cada evento sensible (préstamo aprobado, cambio de cuenta o contacto, retiro de fondos, acceso desde un dispositivo nuevo) genera aviso inmediato al canal histórico. 2. Resumen mensual por llamada IVR de 40 segundos en español o kichwa para quien se inscribe: «este mes: ningún préstamo, un cambio de teléfono». 3. «Si no lo reconoces, marca 1» lleva a S25. 4. Métrica: tiempo del evento al reclamo |
| Pila | Temporal, Jambonz o Asterisk, WhatsApp Cloud API, agregador SMS, grabaciones con variables (o Piper, GPL-3.0, para el español) |
| Demo en 10 min | Línea de tiempo ficticia con un préstamo fraudulento; la llamada llega a los 5 minutos y se abre el reclamo |
| Evidencia | C11 (D); V8 (B); «mientras la Fiscalía investiga, la víctima sigue pagando» ([[02 Amenazas y fraude en Ecuador]]) |
| Riesgo legal y ético | Mensajes imitables: sin enlaces, solo «marca 1». Con celular compartido, el ayudante escucha el aviso (combinar con S08) |
| Costo de operación | Con 2,8 millones de operaciones quirografarias (2025), un SMS por operación costaría USD 0,5-1,1 millones al año a precio de lista; por WhatsApp, unos USD 31.000. Conviene WhatsApp primero y SMS o voz solo para jubilados. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩E** |
| S | Acorta E4 de meses a minutos |
| E | Hace visible el propio historial, base de la vigilancia del afiliado |
| G (no toca) | El costo del SMS a escala es alto si no se prioriza por perfil |

#### S25 «No Reconozco» con congelamiento
| Campo | Contenido |
|---|---|
| Problema y eslabón | Hoy reportar no detiene el daño. **E4→E3** |
| Usuario | Víctima o familiar |
| Flujo | 1. Una sola frase en cualquier canal: «NO RECONOZCO» por WhatsApp, opción del 140, ventanilla o voz en kichwa (S19). 2. El sistema congela desembolsos y descuentos pendientes (BIESS simulado), suspende cambios y abre un caso con número. 3. Verificación por el número histórico en menos de 24 h. 4. Seguimiento por SMS y derivación a S26 |
| Pila | Zammad (AGPL-3.0) o Chatwoot (MIT salvo enterprise), Flowable (Apache-2.0), API simulada del BIESS |
| Demo en 10 min | Reporte por WhatsApp; el préstamo pasa a «congelado»; el ticket aparece en la mesa |
| Evidencia | V8 (B: línea 1930 de India, ₹8.189 crore; 017 de España) |
| Riesgo legal y ético | Bloqueo malicioso de un tercero: el congelamiento dura 72 h y siempre se verifica |
| Costo de operación | Bajo-medio sobre una mesa existente. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩G** |
| S | El reporte se convierte en una acción que detiene el dinero |
| G | Proceso simple con métrica de montos congelados |
| E (no toca) | No cambia la conducta previa |

#### S26 Ruta de la Víctima
| Campo | Contenido |
|---|---|
| Problema y eslabón | La víctima sigue pagando cuotas mientras la Fiscalía investiga; en Guayas hubo más de 10 acciones de protección. **E4** después del daño |
| Usuario | Víctima, familiar, Defensoría del Pueblo, trabajo social del IESS |
| Flujo | 1. Entrevista guiada (web, WhatsApp o ventanilla) que recoge hechos mínimos. 2. Genera borradores: denuncia para la Fiscalía, pedido de suspensión de descuentos, carta al BIESS y lista de pruebas. 3. Expediente con estados, plazos y recordatorios. 4. Tablero agregado sin nombres para la Defensoría y la DNSIPD: tiempos y créditos reconocidos |
| Pila | docassemble (MIT), Flowable, PostgreSQL |
| Demo en 10 min | Un caso ficticio produce tres documentos en dos minutos |
| Evidencia | X15 (B contradictorio: reembolso, PSR y INSS); [Expreso, 08-12-2025](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html) (14 créditos reconocidos hasta junio de 2025) |
| Riesgo legal y ético | Datos sensibles; no sustituye a un abogado ni a la Defensoría |
| Costo de operación | Bajo. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩G** |
| S | Reduce el daño que se sigue acumulando en E4 |
| G | Proceso medible (tiempo hasta suspender descuentos) con dueño claro |
| E (no toca) | Atiende después del daño |

#### S27 Afiliado Auditor
| Campo | Contenido |
|---|---|
| Problema y eslabón | Casi nadie revisa su historial. **E4** |
| Usuario | Afiliado activo y jubilado con acceso al portal |
| Flujo | 1. Recordatorio mensual sin enlace: «revisa tu historial en el portal, toma 30 segundos». 2. Lista de eventos con «lo reconozco» o «no lo reconozco». 3. Cada confirmación da una participación en un sorteo simbólico o un reconocimiento no monetario; «no lo reconozco» lleva a S25. 4. Métricas: porcentaje que revisa y detecciones |
| Pila | Vista web accesible, WhatsApp Cloud API, FastAPI |
| Demo en 10 min | Historial ficticio con un evento extraño, marcado como no reconocido, que abre un caso |
| Evidencia | X2 (A en otro dominio, con lotería sola débil; Nota Fiscal Paulista) |
| Riesgo legal y ético | Legalidad de los sorteos institucionales **sin verificar**; un estafador puede copiar «revisa tu historial aquí», por eso nunca se envía enlace |
| Costo de operación | Bajo-medio. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩E** |
| S | Adelanta la detección en E4 |
| E | Crea el hábito de revisar el propio historial |
| G (no toca) | Legalidad del incentivo sin resolver |

### Familia F · Frente interno (servidores)

#### S28 Botón «Reportar al OSI» en Gmail con respuesta
| Campo | Contenido |
|---|---|
| Problema y eslabón | Reportar no tiene retorno, así que nadie reporta. **E1** del personal y **EI** |
| Usuario | Servidores con Google Workspace |
| Flujo | 1. Complemento de Gmail con permisos mínimos (solo el mensaje abierto). 2. Un clic envía cabeceras y mensaje a la cola del SOC. 3. Clasificación automática (reglas y URL) más un analista. 4. Respuesta en minutos: «gracias, era real; lo retiramos de 37 buzones» o «era un simulacro, bien visto». 5. Explicación opcional con un LLM local; tablero por equipo, nunca individual |
| Pila | Complemento de Gmail con Apps Script (plataforma de Google), Shuffle (AGPL-3.0), DFIR-IRIS (LGPL-3.0), Qwen3 (Apache-2.0) con Ollama, Metabase |
| Demo en 10 min | Correo ficticio de «derivación urgente» en una cuenta de prueba de Workspace; clic; respuesta en la bandeja |
| Evidencia | V18 (A: 1.543 empleados reportaron 4.075 correos en 15 meses, Lain et al.); V29 (A, preprint) |
| Riesgo legal y ético | Los correos pueden contener datos de salud: evaluación de impacto; LLM local, no una API extranjera |
| Costo de operación | Bajo sobre Workspace existente más horas de analista. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩E∩G** |
| S | Convierte a cada servidor en un sensor que detecta campañas antes |
| E | La respuesta rápida refuerza la conducta de reportar |
| G | Nativo en la plataforma que ya existe; métrica de tasa y tiempo de reporte |

#### S29 Aviso Nocturno no punitivo
| Campo | Contenido |
|---|---|
| Problema y eslabón | Accesos a expedientes y a datos de afiliados sin razón de trabajo. **EI** |
| Usuario | Servidores sanitarios y de ventanilla; supervisores |
| Flujo | 1. Registros de acceso (sintéticos en la demo). 2. Filtro por explicaciones: cita, turno, derivación o ventanilla asignada. 3. Los accesos sin explicación reciben esa misma noche un correo: «hoy a las 15:42 consultaste un registro que no tiene cita contigo; si fue por trabajo, responde con el motivo; esto es informativo». 4. Solo a la segunda vez se informa al supervisor. 5. La métrica es la reincidencia |
| Pila | Wazuh (GPL-2.0) u OpenSearch, Python, Gmail API para el envío, Metabase |
| Demo en 10 min | 10.000 accesos sintéticos, 30 sin explicación, correos generados y curva de reincidencia simulada |
| Evidencia | V20 (A: reincidencia de 40 % a 1,8 %, un solo ensayo, con discrepancia de diseño); V22 (B: 94 % de accesos explicables) |
| Riesgo legal y ético | Datos de servidores: base legal, aviso previo y pacto sindical; cultura justa (V26); nada se publica |
| Costo de operación | Medio. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩E∩G** |
| S | Detecta y frena el acceso indebido |
| E | La primera vez es informativa: aprender, no castigar |
| G | Tiene la mejor cifra interna del mapa y una métrica clara de reincidencia |

#### S30 Doble Llave · doble control y «romper el cristal»
| Campo | Contenido |
|---|---|
| Problema y eslabón | Un servidor puede cambiar una cuenta o registrar aportes falsos sin que nadie lo revise (caso de 2025). **E2** y **EI** |
| Usuario | Servidores con permisos de modificación |
| Flujo | 1. Un cambio de cuenta o contacto hecho por un servidor crea una tarea para otro servidor de otra unidad. 2. Ese segundo servidor verifica por el número histórico antes de aprobar. 3. Abrir registros de otra jurisdicción pide un motivo (romper el cristal) y queda para revisión posterior. 4. Política: nadie aprueba su propio cambio, y una misma pareja no puede aprobarse más de N veces al mes, para detectar colusión |
| Pila | Flowable (Apache-2.0), OPA, Keycloak, OpenSearch |
| Demo en 10 min | El servidor A intenta cambiar la cuenta de una jubilada; B, de otra provincia, recibe la tarea, «llama» y rechaza; se muestra la rotación de parejas |
| Evidencia | V23 (D); V21 (B/C); aportes falsos de 2025 ([Primicias](https://www.primicias.ec/economia/iess-denuncia-falsificacion-aportes-jubilacion-fiscalia-110018/)); Guayaquil 2024 |
| Riesgo legal y ético | Bajo; carga operativa adicional |
| Costo de operación | Bajo técnico, medio en proceso. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩G** |
| S | Exige colusión entre dos personas de unidades distintas para cometer el fraude |
| G | Control conocido, fácil de auditar y de presentar al Comité |
| E (no toca) | Es control, no aprendizaje |

#### S31 Jubilado Trampa · registros señuelo
| Campo | Contenido |
|---|---|
| Problema y eslabón | El servidor cooptado busca víctimas rentables (mayores de 80 sin préstamos). **EI** |
| Usuario | Unidad de integridad |
| Flujo | 1. Se crean registros sintéticos de jubilados, con cédulas que fallan el dígito verificador, y cuentas señuelo. 2. Cualquier consulta o modificación sin razón de trabajo dispara una alerta silenciosa. 3. Canarytokens en exportes (Word, Excel, DNS, URL) avisan si una planilla sale de la red. 4. Revisión humana de cada alerta |
| Pila | Canarytokens (GPL-3.0 con aclaraciones) autoalojado, OpenCanary (BSD-3-Clause), triggers de PostgreSQL, reglas de Wazuh |
| Demo en 10 min | Un servidor ficticio busca «jubilados mayores de 80 sin préstamo» y abre el señuelo: alerta en 5 segundos; un exporte filtrado «llama a casa» por DNS |
| Evidencia | X3 (B/C en detección, D en pensiones); hueco del servidor cooptado |
| Riesgo legal y ético | Legalidad de los registros señuelo **sin verificar**; deben quedar aislados en lo contable; comunican desconfianza, por eso se anuncia que existen sin decir cuáles; evaluación de impacto |
| Costo de operación | Bajo-medio. **Estimación propia** |
| Campana | Atípico |
| Venn | **S** |
| S | Detecta el abuso interno con muy pocos falsos positivos |
| E (no toca) | No forma a nadie; si se percibe como espionaje, puede dañar la cultura |
| G (no toca) | Legalidad sin verificar y necesidad de pacto sindical |

#### S32 Código de Coacción del servidor
| Campo | Contenido |
|---|---|
| Problema y eslabón | Servidores presionados o extorsionados por redes externas (en el Teodoro Maldonado Carbo la prensa describe extorsión al personal). **EI** |
| Usuario | Servidor con permisos de modificación |
| Flujo | 1. Cada servidor con permisos tiene un gesto de coacción, por ejemplo un motivo de cambio con un código. 2. Al usarlo, el cambio parece hecho pero queda en cuarentena sin efecto financiero, y sale una alerta silenciosa a integridad. 3. Contacto posterior seguro con el servidor y medidas de protección. 4. Mensaje de cultura: «si te presionan, tienes una salida» |
| Pila | OPA, Flowable, Keycloak, Shuffle (AGPL-3.0) |
| Demo en 10 min | Un servidor ficticio «presionado» registra un cambio con el código; el panel de integridad lo muestra en cuarentena |
| Evidencia | X8 (C: PIN de coacción de Discovery Bank); entorno hospitalario ([Primicias, 14-10-2026](https://www.primicias.ec/sociedad/iess-hospital-guayaquil-teodoro-maldonado-violencia-corrupcion-funcionarios-134797/)) |
| Riesgo legal y ético | Carga cognitiva; riesgo para el servidor si la red lo descubre; no debe usarse para entrampar |
| Costo de operación | Bajo técnico. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩E** |
| S | Neutraliza el cambio forzado sin exponer al servidor en el momento |
| E | Le dice al personal que pedir ayuda es una opción real |
| G (no toca) | Necesita un protocolo de protección que hoy no existe |

#### S33 Canal Casi-Fraude confidencial
| Campo | Contenido |
|---|---|
| Problema y eslabón | Ofertas de redes, pedidos de clave entre compañeros o tramitadores en la puerta nunca se reportan por miedo a las multas personales de la LOPDP. **EI** |
| Usuario | Servidores |
| Flujo | 1. Reporte confidencial de «lo que casi pasó» con código de seguimiento. 2. Quitar datos identificables antes del análisis. 3. Boletín trimestral de lecciones. 4. Protección pactada para quien reporta |
| Pila | GlobaLeaks (AGPL-3.0) autoalojado, Presidio (MIT), Metabase |
| Demo en 10 min | Reporte ficticio («me ofrecieron USD 200 por cambiar una cuenta»), anonimizado, que aparece en el boletín |
| Evidencia | X4 (D: propuesta estilo ASRS de 2018, nunca creada) |
| Riesgo legal y ético | La legalidad de la inmunidad por reportar está **sin verificar** (Contraloría, multas LOPDP) |
| Costo de operación | Bajo. **Estimación propia** |
| Campana | Atípico |
| Venn | **S∩E** |
| S | Revela intentos de cooptación antes del daño |
| E | Cultura justa: reportar atenúa en lugar de castigar |
| G (no toca) | Inmunidad sin base legal verificada |

#### S34 Guardia IESS · extensión de navegador para servidores
| Campo | Contenido |
|---|---|
| Problema y eslabón | Credenciales institucionales escritas en sitios falsos, y cambios sensibles hechos sin verificar. **E1** del personal, **E2** y **EI** |
| Usuario | Servidores en equipos institucionales con Chrome administrado |
| Flujo | 1. Política nativa de Chrome de alerta de contraseña (o Password Alert) cuando se escribe la clave de Workspace fuera de Google. 2. En las pantallas sensibles de la aplicación interna (simulada), un recordatorio justo a tiempo: «¿el afiliado está presente? ¿verificaste el número histórico?». 3. Aviso al visitar dominios parecidos (lista de S20). 4. Acceso directo al botón de S28 |
| Pila | Extensión Chrome Manifest V3, Google Password Alert (Apache-2.0, compatibilidad con MV3 **sin verificar**) o la política nativa de Chrome, lista de dnstwist |
| Demo en 10 min | Escribir la clave de prueba en un sitio falso local dispara la alerta; abrir la pantalla de cambio de cuenta muestra el recordatorio |
| Evidencia | P18 (D); P19 (A mixto); V21 (B/C) |
| Riesgo legal y ético | La extensión observa la navegación: limitar a dominios institucionales y declararlo |
| Costo de operación | Bajo. **Estimación propia** |
| Campana | Periferia |
| Venn | **S∩E** |
| S | Corta el robo de credenciales del personal y añade fricción a los cambios |
| E | Recordatorio en el momento exacto de la decisión |
| G (no toca) | Necesita despliegue por política en miles de equipos, inventario **sin verificar** |

#### S35 Recertificación de accesos
| Campo | Contenido |
|---|---|
| Problema y eslabón | Permisos que sobran y que nadie retira (lección de la CCSS). **EI** |
| Usuario | Jefes de unidad |
| Flujo | 1. Cada mes, el jefe recibe en Google Chat o en un formulario la lista de permisos de su equipo, sacada de Keycloak (simulado). 2. Confirma o retira. 3. Los accesos sin uso por más de 60 días se suspenden. 4. Los permisos se retiran solos al cambiar de unidad |
| Pila | API de administración de Keycloak, Apps Script, Python |
| Demo en 10 min | Un jefe ficticio revisa 12 permisos y retira 3; un acceso dormido queda suspendido |
| Evidencia | V24 (B, caso negativo de la CCSS) |
| Riesgo legal y ético | Bajo |
| Costo de operación | Bajo. **Estimación propia** |
| Campana | Convergente |
| Venn | **S∩G** |
| S | Reduce la superficie de abuso interno |
| G | Control barato y auditable para el informe del EGSI |
| E (no toca) | Es control, no formación |

#### S36 Simulacro con cultura justa
| Campo | Contenido |
|---|---|
| Problema y eslabón | Simulaciones que castigan y miden lo que no importa. **E1** del personal |
| Usuario | Servidores |
| Flujo | 1. Escenarios del contexto IESS: falsa derivación, prestador que cobra comisión, inicio de sesión falso de Workspace. 2. Nunca cebos de bono (N1). 3. Microlección embebida de dos minutos al fallar. 4. Resultados por equipo, no por persona. 5. La métrica principal es la tasa de reporte en S28, no el clic |
| Pila | GoPhish (MIT; poco mantenido desde 2024) |
| Demo en 10 min | Campaña ficticia a 20 buzones de prueba con tablero por equipo |
| Evidencia | C2 (A: unos 2 pp, con posible efecto adverso); V30; V26 |
| Riesgo legal y ético | Medir individuos es tratar datos de servidores: base legal y pacto sindical |
| Costo de operación | Licencia 0; horas de diseño. **Estimación propia** |
| Campana | Centro |
| Venn | **E∩G** |
| E | Práctica con retroalimentación, sin castigo |
| G | Barata y conocida por el jurado |
| S (no toca) | Efecto pequeño sobre E1 y no toca la clave del ciudadano |

#### S37 Escape room digital por turnos
| Campo | Contenido |
|---|---|
| Problema y eslabón | El personal sanitario no tiene tiempo para cursos. **E1** y **EI** |
| Usuario | Personal sanitario |
| Flujo | 1. Juego de 15 minutos en equipos de 3-4 durante el turno. 2. Retos: correo de derivación falsa, una memoria USB encontrada, una llamada de «soporte técnico». 3. Cierre con una regla institucional por reto |
| Pila | H5P (GPL-3.0) en Moodle (GPL-3.0) |
| Demo en 10 min | Un equipo del jurado resuelve un reto en cinco minutos |
| Evidencia | P13 (A-: muestra pequeña, 96 participantes, Universidad de Twente) |
| Riesgo legal y ético | Bajo |
| Costo de operación | Medio por facilitación. **Estimación propia** |
| Campana | Periferia |
| Venn | **E** |
| E | Aprendizaje en equipo con práctica |
| S (no toca) | No corta eslabones |
| G (no toca) | Costo de facilitación y evidencia escasa |

#### S38 Tablero de Cultura OSI · tres capas SETA
| Campo | Contenido |
|---|---|
| Problema y eslabón | No hay línea base conductual y el OSI mide cursos completados. **Medición** |
| Usuario | OSI, Comité de Seguridad, Delegado de Protección de Datos |
| Flujo | 1. Capa de conducta: tasa y tiempo de reporte (S28), reincidencia de accesos (S29). 2. Capa de proceso: cambios revertidos (S01), casos de ventanilla (S09), retenciones (S04). 3. Capa de percepción: encuesta HAIS-Q en LimeSurvey. 4. Conteos con ruido (OpenDP) y grupos de al menos 10 personas. 5. Exportación al informe semestral del EGSI |
| Pila | Metabase (AGPL-3.0) o Superset (Apache-2.0), LimeSurvey (GPL-2.0+), OpenDP (MIT) |
| Demo en 10 min | Tablero con datos sintéticos de tres unidades y su exportación a informe |
| Evidencia | V25 (C/D: NIST SP 800-50r1, HAIS-Q); C4 como contraejemplo (A: el porcentaje de clic es engañoso) |
| Riesgo legal y ético | Exposición individual si no se agrega; por eso el umbral y el ruido |
| Costo de operación | Bajo. **Estimación propia** |
| Campana | Convergente |
| Venn | **E∩G** |
| E | Mide conducta, no asistencia |
| G | Da al OSI la evidencia «medible» que pide el Plan 2026 y el EGSI |
| S (no toca) | Mide, no corta |

### Familia G · Transversal

#### S39 Banco de Estafas EC · corpus y población sintética
| Campo | Contenido |
|---|---|
| Problema y eslabón | No hay benchmarks públicos de detección de estafas en español ni en kichwa, y cada prototipo inventa sus propios datos. **Transversal** |
| Usuario | Equipos del hackatón, academia, OSI |
| Flujo | 1. Población sintética con la forma de los datos del IESS (afiliados, cuentas, eventos) y los escenarios del guion E1-E4. 2. Corpus de mensajes de estafa sintéticos y de casos públicos verificados, usados con permiso. 3. Traducciones al kichwa hechas por personas. 4. Tablas de evaluación para detectores y bots |
| Pila | Faker (MIT), Mimesis (MIT); se evitan SDV (BSL 1.1) y Gretel (source-available); Label Studio (Apache-2.0) para etiquetar |
| Demo en 10 min | Generar 10.000 afiliados ficticios con una red de fraude y evaluar S04 y S10 sobre ellos |
| Evidencia | Vacío de canal ([[09 Huecos]]) |
| Riesgo legal y ético | Que los datos sintéticos no reconstruyan personas reales; licencias de los casos públicos |
| Costo de operación | Bajo. **Estimación propia** |
| Campana | Periferia |
| Venn | **G** |
| G | Hace que todo el catálogo sea demostrable y medible sin datos reales, como exige el reto |
| S (no toca) | Solo indirecta, al permitir evaluar detectores |
| E (no toca) | No forma a nadie |

#### S40 Microcursos por rol
| Campo | Contenido |
|---|---|
| Problema y eslabón | El curso anual llega a cerca de 1 de cada 4 servidores y no mueve conducta. **E1** y **EI** |
| Usuario | Servidores según su rol: enfermería, ventanilla, médicos, administrativos |
| Flujo | 1. Cinco microcursos de cinco minutos por rol con escenarios del IESS. 2. Materiales libres HICP adaptados. 3. Enlazados con S36 como formación embebida. 4. Medición en S38 |
| Pila | Moodle (GPL-3.0), H5P (GPL-3.0) |
| Demo en 10 min | Un microcurso de ventanilla con su escenario |
| Evidencia | C1 (A nulo); V27 (D) |
| Riesgo legal y ético | Bajo |
| Costo de operación | Bajo. **Estimación propia** |
| Campana | Centro |
| Venn | **E∩G** |
| E | Formación por rol, mejor que el curso genérico |
| G | Encaja en la plataforma y el ciclo anual del EGSI |
| S (no toca) | Evidencia nula del formato curso |

---

## Vacíos que quedan
| Vacío | Por qué sigue abierto |
|---|---|
| Efecto de cualquier idea sobre la clave prestada en persona | S06, S07, S05 y S09 son nivel D: nadie lo ha medido en ningún país |
| Servidor cooptado | S30-S33 detectan o disuaden, pero ninguna tiene evidencia en seguridad social; la legalidad de los señuelos y de la inmunidad está sin verificar |
| Kichwa en telefonía real | El reconocimiento de voz existe (Omnilingual), pero el CER publicado no es de audio telefónico; no hay texto a voz abierto para Imbabura ni Chimborazo; hacen falta hablantes para grabar y validar |
| Migrantes sin passkey ni dispositivo propio | S23 depende de una videollamada con servidores; no hay alternativa remota evaluada que no pida agencia digital |
| SMS como canal de enseñanza | S17 es un experimento, no una solución |
| Celular compartido | Todos los avisos al «canal anterior» fallan si el estafador tiene ese teléfono; S08 lo mitiga solo si hay un contacto de confianza |
| Costo real de mensajería en Ecuador | Las tarifas de SMS por convenio local y la tarifa 2026 de WhatsApp para Ecuador no se obtuvieron |
| Dependencias institucionales | Casi todo lo de la familia A necesita al BIESS, y S06 necesita una reforma normativa. El reto prohíbe tocar sistemas en operación, así que deben presentarse como dependencias |
| E4 después del daño | S26 orienta a la víctima, pero el reembolso (X15) sigue sin resolverse |

## Lo no verificado
| Afirmación | Estado |
|---|---|
| Claim `act` en tokens de impersonación desde Keycloak 26.8 | Según búsqueda; verificar en las notas de versión |
| Rasa Open Source en modo mantenimiento | Fuente secundaria; no se confirmó en fuente oficial |
| Compatibilidad de Google Password Alert con Manifest V3 | Sin confirmar |
| Tarifa de SMS de Twilio para Ecuador | No legible en la página oficial; cifras de terceros |
| Tarifa de plantilla de WhatsApp para Ecuador en 2026 | No obtenida; se usa la cifra de la bóveda (≈USD 0,011) |
| Gratuidad de los mensajes de utilidad dentro de la ventana de servicio después del 01-10-2026 | Meta y Wati se contradicen |
| Desempeño de Omnilingual ASR en audio telefónico en kichwa | No medido |
| Que IESSEDUCA use Moodle | Sin verificar |
| Pantallas en salas de espera y tablets en ventanillas | Sin verificar |
| Escalas salariales para los costos de personal | Sin verificar |
| Legalidad de sorteos institucionales, registros señuelo e inmunidad por reportar | Sin verificar (ya señalado en [[09 Huecos]]) |
| Textos de las Res. SPDP 2026-0009-R (IA) y 2026-0039-R (biométricos) | No obtenidos |
| Lista oficial completa de tipos de Canarytokens | Solo fuentes secundarias |

## Fuentes
- Bóveda: [[Indice Soluciones]], [[07 Tabla maestra]], [[08 Donde convergen las vertientes]], [[09 Huecos]], [[10 Criterios de decision]], [[01 Perfiles y canales del IESS]], [[02 Amenazas y fraude en Ecuador]], [[04 Marco legal]], [[Lo que se sabe del reto]].
- Licencias: archivos LICENSE de cada repositorio enlazado en el registro de piezas y fichas de modelos en Hugging Face, consultados el 25-11-2026.
- Keycloak: [passkeys en 26.4](https://www.keycloak.org/2025/09/passkeys-support-26-4), [token exchange estándar en 26.2](https://www.keycloak.org/2025/05/standard-token-exchange-kc-26-2), [26.8.0](https://www.keycloak.org/2026/10/keycloak-2680-released).
- Kichwa: [Omnilingual ASR](https://github.com/facebookresearch/omnilingual-asr) y su [tabla por idioma](https://github.com/facebookresearch/omnilingual-asr/blob/main/per_language_results_table_7B_llm_asr.csv); [Common Voice Kichwa v25](https://prod.datacollective.mozillafoundation.org/datasets/cmn2cigqs01d3o107mzljz8gp); [Killkan](https://arxiv.org/abs/2404.15501v1); modelos [MMS-TTS](https://huggingface.co/facebook/mms-tts-qvo).
- Mensajería: [precios de WhatsApp Business Platform](https://developers.facebook.com/docs/whatsapp/pricing); [Wati](https://support.wati.io/en/articles/11561662-message-based-pricing-all-you-need-to-know); [SleekFlow](https://help.sleekflow.io/en_US/whatsapp/pricing); [Twilio Ecuador](https://www.twilio.com/sms/pricing/ec); [Plivo Ecuador](https://www.plivo.com/sms/pricing/ec/); [sent.dm](https://www.sent.dm/en/resources/sms-pricing/ecuador-sms-pricing).
- Google: [Password Alert FAQ](https://support.google.com/a/answer/6197508); [Prevenir phishing con Password Alert](https://support.google.com/a/answer/6197480).
- Rasa: [Rasa Pro en PyPI](https://pypi.org/project/rasa-pro/3.14.25/); [guía de terceros sobre el modo mantenimiento](https://www.issoh.co.jp/md/tech/8262).
- Canarytokens: [documentación](https://docs.canarytokens.org/guide/examples).
