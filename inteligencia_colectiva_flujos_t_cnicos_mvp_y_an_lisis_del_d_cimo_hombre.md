# Escudo Cognitivo IESS — Inteligencia Colectiva y MVP

Visión compartida del equipo para el Reto 1 **"Seguridad inteligente, cultura consciente"** (Hackatón Código Confianza IESS 2026): tesis, flujos técnicos del MVP y auditoría crítica (Décimo Hombre).

> **Cambios de esta versión (26/11/2026):** se elimina el QR. La verificación queda en **AIESS**, una IA con web y app hechas en **Flutter**: el correo trae un sello (hash) y un botón «Verificar» que abre AIESS; quien tenga la app con permiso de lectura de Outlook/Gmail recibe el aviso automáticamente. Se agrega una whitelist de remitentes/dominios y se incorpora el [Catálogo de indicios y canales oficiales](recursos-base/Catalogo_Indicios_y_Canales_Oficiales.md) como fuente de reglas.
>
> **Metáfora del pitch:** el sello de cera. Solo el IESS tiene el anillo (la llave secreta); cada correo sale sellado (el hash); AIESS revisa que el sello esté intacto y sea del IESS. Sello roto o ausente → alerta y capacitación.

---

## 1. Problema y tesis

**Problema.** Casi 4,85 millones de afiliados y pensionistas reciben phishing que suplanta al IESS (falsos reembolsos, trámites, amenazas de suspensión). Las alertas genéricas llegan tarde y no cambian el comportamiento.

**Tesis.** No enviamos millones de correos a una IA (colapsa la infraestructura y viola la minimización de la **LOPDP**). Proponemos cuatro pilares:

1. **Tipologías (`T1`, `T2`, `T3`):** el IESS estructura cómo comunica antes de proteger el canal.
2. **Sello ligero (solo hashes):** cada correo legítimo lleva un código de verificación derivado de un HMAC. El núcleo nunca guarda el cuerpo del correo.
3. **Motor de reglas:** whitelist de remitentes/dominios + los 11 indicios del catálogo oficial (`I1`–`I11`).
4. **Observatorio de Seguridad Cognitiva:** cada verificación o reporte se vuelve un evento anónimo para **hipersegmentar** la concientización por rango etario y tipología atacada.

**Regla de oro para el ciudadano** (alineada con el catálogo, sección 5): *"Si no tiene el sello del IESS, no es del IESS. El IESS nunca te pedirá escanear un QR, pagar ni entregar claves por correo. AIESS solo vive en `aiess.iess.gob.ec`."*

---

## 2. Roles y equipo

**Usuarios**
* **Asegurado (afiliado / pensionista):** recibe correos, los verifica con AIESS (botón «Verificar» en la web o aviso automático de la app) y recibe micro-cápsulas preventivas según su perfil.
* **Colaborador emisor (`E1`, `E2`…):** área interna que envía comunicaciones bajo una tipología permitida.
* **Tomador de decisiones (CSI / OSI):** usa el Observatorio para detectar campañas, perfiles atacados y lanzar alertas dirigidas.

| Bloque | Módulo | Responsables | Entregable MVP |
| :--- | :--- | :--- | :--- |
| **1** | Emisión y sellado | **Patric / Dani** | Simulador de correo saliente por tipología + cálculo de HMAC + código de verificación en el pie + registro asíncrono en el núcleo. |
| **2** | Recepción y verificación (AIESS) | **Isaac / Sergio** | AIESS en Flutter: web que abre el botón «Verificar» + app con lectura de Outlook/Gmail (OAuth) y notificación automática. |
| **3** | Núcleo y Observatorio | **Luis / Jhair** | API central (whitelist de hashes y remitentes, blacklist, motor de indicios) + dashboard de hipersegmentación. |

---

## 3. Tipologías de correo

| Código | Tipo | Regla de contenido |
| :--- | :--- | :--- |
| `T1` | Informativo (boletines, campañas, recordatorios) | Nunca enlaces de login, nunca pide transferencias. |
| `T2` | Financiero / previsional (aportes, pensiones, créditos BIESS) | Alto riesgo de suplantación. Nunca pide pagos ni claves por correo. |
| `T3` | Trámites / clínico (citas, certificados, expedientes) | Nunca pide escanear QR ni enviar documentos/selfies. |

Cada tipología tiene una **lista de indicios prohibidos**: si un correo sellado `T1` contiene `I3` o `I10`, el núcleo lo rechaza antes del envío (defensa contra *insider*).

---

## 4. Flujos técnicos del MVP

### A. Sello ligero (privacidad por diseño)

```text
huella   = SHA256(asunto + "|" + cuerpo_normalizado)
sello    = HMAC_SHA256(emisor_id | tipologia | timestamp_utc | SHA256(destinatario) | huella, SECRET_KEY)
codigo   = "IESS-" + tipologia + "-" + BASE32(sello)[0:8]      // ej. IESS-T2-7K4P-2QX9
```

* **Hash al enviar vs. hash al recibir (la duda del equipo):** al enviar, el proxy calcula la huella del correo y la guarda en la bóveda. Al recibir, AIESS calcula la huella de lo que llegó y la compara con la guardada. Iguales → el correo es del IESS y llegó intacto. Distintas → alguien lo alteró. Inexistente → nunca lo envió el IESS.
* El **código corto** viaja en el botón «Verificar» y en el pie del correo; permite buscar el sello aunque no se tenga el contenido completo (caso web).
* Incluir `SHA256(destinatario)` hace que **cada sello sea único por persona**: copiarlo en otro correo se detecta (ver Fallo 2).
* El núcleo recibe solo el sello, el código y metadatos no sensibles. **Nunca el cuerpo.**

### B. Flujo 1 · Emisión (Bloque 1)

1. El emisor redacta y elige tipología. El Bloque 1 valida que la tipología esté permitida para ese emisor y que el texto no tenga indicios prohibidos.
2. Calcula sello y código; inserta en el pie el botón **«Verificar con AIESS»** (`https://aiess.iess.gob.ec/v/IESS-T2-7K4P-2QX9`) y el código en texto.
3. Registro asíncrono (no bloquea el envío, *fail-open* con cola):

`POST /api/v1/hashes/register`
```json
{
  "emisor_id": "E2_PRESTACIONES",
  "remitente": "notificaciones@iess.gob.ec",
  "tipologia": "T2",
  "asunto_resumen": "Notificación de rol de pensión mensual",
  "sello": "8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4",
  "codigo": "IESS-T2-7K4P-2QX9",
  "destinatario_hash": "c1f0…",
  "timestamp": "2026-11-26T15:30:00Z",
  "ttl_dias": 30
}
```
4. El correo sale por SMTP con TLS y firma DKIM del dominio `iess.gob.ec`.

### C. Flujo 2a · AIESS web: el botón «Verificar» (Bloque 2)

AIESS está hecha en **Flutter**: un solo código para Android, iOS y Web.

1. El afiliado toca **«Verificar»** en el correo. En el celular, un App Link (Android) / Universal Link (iOS) abre la app AIESS si está instalada; si no, se abre la **web AIESS** en el navegador, también en escritorio.
2. AIESS busca el código en la bóveda y devuelve el veredicto con los datos oficiales (área, asunto, fecha) para que el afiliado compare con lo que lee.
3. Si el afiliado pega el texto o reenvía el correo, AIESS además recalcula la huella y aplica los 11 indicios.
4. Respuesta en lenguaje simple: **"Sí, este correo lo envió el IESS"** o **"¡Nooo! Ten cuidado… capacítate conmigo"** (cápsula de 1 minuto; la concientización se detalla en la siguiente fase).
5. Al núcleo solo viajan datos estructurados:

`POST /api/v1/verify`
```json
{
  "codigo": "IESS-T2-7K4P-2QX9",
  "remitente_dominio": "iess-servicios-tu2.xyz",
  "dominios_enlaces": ["t.ly"],
  "indicios": ["I2", "I3", "I4", "I6", "I7", "I10"],
  "tipologia_percibida": "T2",
  "rango_etario": "65+",
  "canal": "AIESS_WEB"
}
```

**Respuesta:**
```json
{
  "estado": "PHISHING_CONFIRMADO",
  "semaforo": "ROJO",
  "motivos": ["Remitente fuera de la whitelist con nombre que imita al IESS", "Código inexistente", "Pide claves (I3) y transferencia (I10)"],
  "metadatos_oficiales": null,
  "capsula_educativa": "El IESS nunca te pedirá claves ni transferencias por correo. Repórtalo a seguridad.informacion@iess.gob.ec."
}
```
Si es `VERDE`, `metadatos_oficiales` devuelve área emisora, tipología, asunto oficial y fecha para que el usuario compare con lo que lee.

### D. Flujo 2b · App AIESS con aviso automático (tipo identificador de llamadas)

1. El afiliado instala la app y conecta su correo con **OAuth** (Gmail API o Microsoft Graph), con permiso **solo de lectura** y revocable cuando quiera.
2. La app revisa solo los correos que **dicen ser del IESS** (remitente, nombre visible o asunto que mencionen al IESS). Los demás no se tocan.
3. Para cada uno, en el teléfono: extrae el sello, recalcula la huella, aplica los 11 indicios y consulta la bóveda. **Solo viajan el código, la huella y los indicios**; el texto no sale del dispositivo.
4. Notificación automática: *"✓ Correo del IESS verificado"* o *"⚠ Cuidado: este correo no tiene el sello del IESS"*.

> **Puntos a resolver antes de producción:** Google clasifica la lectura de Gmail como alcance restringido (verificación de la app y evaluación de seguridad anual); Microsoft exige consentimiento del usuario. El MVP puede demostrarse con una cuenta de prueba. Consentimiento explícito e informado (LOPDP) en el primer uso.

### E. Motor de reglas: whitelist + indicios

Orden de evaluación (cada correo recibe `VERDE`, `AMARILLO` o `ROJO`):

| Paso | Regla | Resultado |
| :--- | :--- | :--- |
| 1 | Código válido, no revocado, destinatario coincide y metadatos coinciden | Sigue al paso 4 con presunción de `VERDE` |
| 2 | Remitente o enlaces fuera de la whitelist **y** el texto menciona al IESS | `ROJO` (`I7`/`I2`, suplantación) |
| 3 | Dominio parecido a uno oficial (distancia de edición, `iess` dentro de otro dominio) | `ROJO` + alta automática en blacklist |
| 4 | Cualquier indicio `I1`–`I11` presente, **aunque el remitente esté en la whitelist** | `ROJO` (definición del catálogo: ≥1 indicio = phishing) |
| 5 | Remitente es entidad pública o servicio conocido (SRI, Registro Civil, gob.ec, Microsoft, Google, Zoom) y sin indicios | `AMARILLO`: "No es del IESS; confirma con esa entidad" |
| 6 | Remitente oficial, código válido, sin indicios | `VERDE` |

**Whitelist inicial** (catálogo, sección 4): `iess.gob.ec`, `app.iess.gob.ec`, `denuncias.iess.gob.ec`, `gob.ec/iess`, buzones `notificaciones@`, `atencionalusuario@`, `gestiondenuncias@`, `seguridad.informacion@iess.gob.ec`, WhatsApp +593 9 62532338. Se gobierna desde el núcleo (alta/baja con aprobación del OSI).

### F. Núcleo y Observatorio (Bloque 3)

**Modelo de datos mínimo**
1. `emisores`: `id`, `nombre_area`, `correo_oficial`, `tipologias_permitidas`, `activo`.
2. `whitelist_remitentes`: `valor` (dominio o buzón), `tipo`, `aprobado_por`, `activo`.
3. `whitelist_hashes`: `sello` (PK), `codigo`, `emisor_id`, `tipologia`, `asunto_resumen`, `destinatario_hash`, `created_at`, `expires_at`, `revocado`.
4. `blacklist_patrones`: `tipo` (`DOMINIO`, `URL`, `FRASE`), `valor`, `tipologia_suplantada`, `reportes_count`.
5. `eventos_observatorio`: `timestamp`, `semaforo`, `indicios[]`, `tipologia`, `rango_etario`, `canal`. Sin cédula ni nombre.

**Dashboard** (`GET /api/v1/observatorio/metrics`)
* **Morfología del ataque:** tipología más suplantada, indicios más frecuentes, franja horaria.
* **Mapa de calor demográfico:** consultas e incidentes por rango (`18-29`, `30-49`, `50-64`, `65+`).
* **Hipersegmentación:** *"+40 % de phishing T2 con I6+I10 dirigido a 65+. Acción: cápsula de audio para pensionistas por WhatsApp oficial."*

---

## 5. Recursos base y uso futuro

En `recursos-base/` tenemos material oficial del reto que usamos para validar y que alimentará fases posteriores:

| Recurso | Qué es | Uso en el MVP | Uso futuro |
| :--- | :--- | :--- | :--- |
| `Catalogo_Indicios_y_Canales_Oficiales.md` (y `.pdf`) | 11 indicios, diccionario de datos y canales oficiales | Fuente de las reglas `I1`–`I11` y de la whitelist inicial | Mantener sincronizado con nuevos indicios que detecte el Observatorio |
| `P01.eml` … `P05.eml` | 5 correos sintéticos de práctica (cabeceras + cuerpo) | Casos de prueba del parser y del motor de reglas; demo en la presentación | Fixtures de pruebas automáticas; base para probar la lectura de correos de la app AIESS |
| `INTERNO_practica_hoja_de_respuestas.csv` | Respuesta esperada (Phishing, indicios, remitente) de los 5 correos | Medir si el motor acierta (meta: 5/5) | Ampliar a métricas de precisión/recall |
| `dataset_entrenamiento_IESS_1000.csv` *(citado en el catálogo, aún no está en la carpeta)* | 1000 correos etiquetados con `I1`–`I11` | — | Entrenar/evaluar un clasificador de indicios que complemente las reglas |

**Lo que enseñan los 5 correos de práctica:**

| Correo | Remitente | ¿Whitelist? | Respuesta oficial | Lección |
| :--- | :--- | :--- | :--- | :--- |
| P01 | `notificaciones9894@iess-servicios-tu2.xyz` | No (imita al IESS) | Phishing · I2 I3 I4 I6 I7 I10 | La whitelist lo atrapa. |
| P02 | `notificaciones@iess.gob.ec` | Sí | Legítimo | Caso `VERDE`. |
| P03 | `fernando.freire@iess.gob.ec` | **Sí** | **Phishing · I2** | **Remitente oficial con enlace a `iessgob-09c.site`. La whitelist sola lo marcaría como legítimo.** |
| P04 | `…@accountprotection.microsoft.com` | No (no es IESS) | Legítimo | Una whitelist "todo lo demás es phishing" daría **falso positivo**. |
| P05 | `servicio89761@portal-seguro.invalid` (Reply-To distinto) | No | Phishing · I7 I9 I11 | Pide escanear QR: confirma que el IESS no debe usar QR. |

Nota: los `.eml` son sintéticos y no traen cabeceras `Authentication-Results` (SPF/DKIM/DMARC). En producción el remitente debe validarse con DMARC, no solo leyendo el campo `From`.

---

## 6. Décimo Hombre: ¿la whitelist sostiene los fallos?

> **Regla:** si nueve personas creen que la arquitectura es sólida, la décima asume que **va a fallar** y busca cómo romperla.

**Respuesta corta: no por sí sola.** La whitelist resuelve la suplantación burda (P01, P05) y es la base del indicio `I7`, pero no cubre ataques desde dominios oficiales (P03, *insider*), no sirve si el `From` se falsifica sin DMARC, y genera falsos positivos con terceros legítimos (P04). Funciona como **una capa** junto al sello, el motor de indicios y el canal fuera de banda.

### Fallos originales re-evaluados

| # | Fallo | ¿La whitelist lo resuelve? | Mitigación vigente |
| :--- | :--- | :--- | :--- |
| 1 | QR falso (*quishing*) | **Resuelto por diseño.** Ya no usamos QR; cualquier QR es `I11` → `ROJO`. | Mensaje cultural: "El IESS nunca te pide escanear un QR". |
| 2 | Reutilización del sello (*replay*) | Parcial: si el sello se pega en un correo de dominio no oficial, la whitelist lo marca. Si se pega en un correo reenviado, no. | Sello atado al destinatario (`SHA256(destinatario)`); AIESS muestra los datos oficiales para comparar y recalcula la huella cuando tiene el texto. |
| 3 | Rango de edad sin violar la LOPDP | No aplica. | Rango etario en *buckets*: desde la sesión autenticada (app/portal) o pregunta opcional de 1 clic al final. Nunca cédula. |
| 4 | *Insider* / cuenta de emisor robada | **Empeora** la confianza: el correo sale desde un dominio de la whitelist. | Tipologías permitidas por emisor; indicios prohibidos por tipología bloqueados antes de enviar; alerta por volumen anómalo; revocación por lote de los sellos de un emisor. |
| 5 | Usuario en pánico no verifica | Ayuda si la app marca automáticamente. | La app avisa automáticamente (no depende de que el usuario actúe); radar comunitario: pocos reportes bastan para alertar al resto. |
| 6 | Infraestructura heredada (AS-400) | No aplica. | Sellado en la pasarela de salida (SMTP relay o webhook), asíncrono y *fail-open* con cola. |

### Fallos nuevos que trae el cambio de diseño

| # | Fallo | Ataque | Mitigación |
| :--- | :--- | :--- | :--- |
| 7 | **Botón «Verificar» clonado** | El estafador copia el botón y lo enlaza a su propia web, que imita a AIESS y muestra un sello verde falso. | AIESS solo vive en `aiess.iess.gob.ec`; App Links/Universal Links verificados: un enlace falso no abre la app, abre el navegador ("si se abrió el navegador en otro dominio, es falso"). La app con lectura de correo avisa **sin depender del botón**. Sin la llave del IESS no se puede fabricar un sello que exista en la bóveda. |
| 8 | **Remitente falsificado (*spoofing*)** | El atacante pone `From: notificaciones@iess.gob.ec` sin serlo. Una whitelist que solo lee el `From` lo deja pasar. | Política DMARC `p=reject` en `iess.gob.ec` con SPF y DKIM; el motor valida `Authentication-Results`. Revisar también `Reply-To` (P05) y el nombre visible (P01 dice "IESS" con dominio falso). |
| 9 | **Phishing desde dominio oficial** | P03: remitente `@iess.gob.ec` con enlace a `iessgob-09c.site`. | El motor de indicios corre **siempre**, aunque el remitente esté en la whitelist. Un indicio basta para `ROJO`. Whitelist también para **dominios de enlaces**, no solo para remitentes. |
| 10 | **Falsos positivos con terceros legítimos** | P04 (Microsoft) quedaría marcado como phishing. Pierde credibilidad: el usuario deja de creer en la alerta. | Tres estados: `VERDE` (IESS sellado), `AMARILLO` (no es del IESS, entidad conocida, sin indicios), `ROJO`. Lista de servicios conocidos del catálogo. |
| 11 | **Dominios parecidos** | `iess-servicios-tu2.xyz`, `iessgob-09c.site`: infinitas variantes, imposible tenerlas todas en blacklist. | Detección por similitud (distancia de edición, "iess" dentro de un dominio no oficial, homoglifos) → alta automática en blacklist y en el Observatorio. |
| 12 | **Privacidad del contenido** | Para recalcular la huella y buscar indicios hay que leer el texto, que trae nombre, cédula o montos. | El análisis corre en el dispositivo (app Flutter o navegador); al núcleo solo viajan código, huella, dominios e indicios. Nunca el cuerpo. |
| 13 | **Permiso de lectura del correo** | Leer la bandeja es invasivo; Gmail lo trata como alcance restringido (verificación y auditoría anual) y Microsoft exige consentimiento. | OAuth solo lectura y revocable; se procesan únicamente los correos que dicen ser del IESS; consentimiento explícito (LOPDP); sin la app, el botón abre la web AIESS. Para el MVP, cuenta de prueba. |
| 14 | **Gobierno de la whitelist** | Un proveedor de envío masivo o una nueva área del IESS envía desde un dominio no registrado; o alguien agrega un dominio malicioso a la lista. | Alta/baja con doble aprobación (OSI + TI), registro de auditoría y revisión periódica; los proveedores envían con subdominio de `iess.gob.ec` firmado con DKIM. |
| 15 | **Usuario sin app ni web** | Adultos mayores sin smartphone o sin datos. | WhatsApp institucional (+593 9 62532338) y teléfono 593 2 3945666 como canales de verificación; el Observatorio prioriza cápsulas de audio y mensajes a familiares. |

### Capas de defensa (resumen para el pitch)

1. **Sello + código** → demuestra qué envió el IESS.
2. **Whitelist con DMARC** → demuestra desde dónde se envió.
3. **Motor de 11 indicios** → demuestra qué pide el correo, venga de donde venga.
4. **AIESS (web + app Flutter)** → un toque o un aviso automático; el usuario no tiene que acordarse de verificar.
5. **Observatorio** → convierte cada verificación en alerta temprana dirigida.

Ninguna capa sola cubre los 15 fallos; juntas cubren los ataques conocidos con datos mínimos.
