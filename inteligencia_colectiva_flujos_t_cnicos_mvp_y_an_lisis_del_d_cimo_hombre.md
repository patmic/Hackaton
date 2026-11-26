# Escudo Cognitivo IESS — Documento de Inteligencia Colectiva y MVP

Este documento consolida la visión compartida del equipo para la problemática **"Seguridad inteligente, cultura consciente"** aplicada al IESS. Su objetivo es alinear a los tres frentes de desarrollo, definir los flujos técnicos del MVP y someter la propuesta a una auditoría crítica (Teoría del Décimo Hombre).

---

## 1. Contexto y Tesis de la Solución

### El Problema
El IESS enfrenta campañas constantes de *phishing* y *smishing* (correos de falsos reembolsos, suplantación de trámites y engaños financieros) que impactan de forma desigual a casi 4,85 millones de afiliados y pensionistas. Las alertas genéricas en redes sociales llegan tarde y no cambian el comportamiento del usuario.

### Nuestra Tesis
En lugar de enviar copias de millones de correos a una Inteligencia Artificial (lo cual colapsaría la infraestructura y violaría el principio de minimización de la **LOPDP**), proponemos un ecosistema basado en **tres pilares**:
1. **Estandarización por Tipologías (`T1, T2, T3...`):** Estructurar cómo comunica el IESS antes de proteger el canal.
2. **Sellado Criptográfico Ligero (Solo Hashes):** Validar la autenticidad de un correo sin almacenar ni exponer datos personales ni el contenido sensible del mensaje.
3. **Observatorio de Seguridad Cognitiva:** Transformar cada verificación o reporte ciudadano en inteligencia demográfica para **hipersegmentar** la concientización según el rango etario y el perfil que esté siendo atacado.

---

## 2. Roles del Ecosistema y División del Equipo

### Roles de Usuario
* **1. Asegurado (Afiliados y Pensionistas):** Recibe correos institucionales, verifica su legitimidad mediante QR/Bot y recibe micro-cápsulas preventivas adaptadas a su perfil.
* **2a. Colaborador Emisor (`E1, E2, E3...`):** Áreas internas del IESS que redactan y envían comunicaciones oficiales bajo una tipología asignada.
* **2b. Colaborador Tomador de Decisiones (CSI / OSI / Seguridad):** Analiza el Observatorio para detectar tendencias de *phishing*, rangos de edad más vulnerables y desplegar campañas de concientización dirigidas.

### Responsabilidades del Equipo en el Hackatón
| Bloque | Módulo | Responsables | Entregable MVP |
| :--- | :--- | :--- | :--- |
| **Bloque 1** | Emisión y Sellado Ligero | **Patric / Dani** | Simulador de correo saliente por tipología + generador de Hash/QR + envío de registro al núcleo. |
| **Bloque 2** | Recepción y Verificación | **Isaac / Sergio** | Cliente web/correo de prueba + Bot/Interfaz verificadora de QR y reportes de sospecha. |
| **Bloque 3** | Núcleo Central y Observatorio | **Luis / Jhair** | API Central (`White List` vs `Black List`), base de datos de hashes y Dashboard de Seguridad Cognitiva (hipersegmentación). |

---

## 3. Estandarización por Tipologías de Correo

Todo correo legítimo emitido desde el IESS debe pertenecer a una tipología oficial predefinida:

* **`T1` — Informativo:** Comunicados generales, campañas, recordatorios de fechas, boletines. *(Nunca incluye enlaces para ingresar contraseñas ni solicita transferencias).*
* **`T2` — Financiero / Previsional:** Notificaciones de aportes, pensiones, créditos BIESS, liquidaciones o pagos a prestadores. *(Alto riesgo de suplantación).*
* **`T3` — Trámites / Clínico:** Agendamiento de citas médicas, emisión de certificados, actualizaciones de expedientes.

---

## 4. Flujos Técnicos para el MVP

### A. Diseño del Hash Ligero (Privacidad por Diseño)
Para no enviar ni guardar el cuerpo del correo en el núcleo, el Bloque 1 genera un **HMAC-SHA256** combinando únicamente metadatos estructurales y la huella del contenido:

```text
Hash_Correo = HMAC_SHA256(
    emisor_id + "|" + tipologia + "|" + timestamp_utc + "|" + sha256(asunto + cuerpo_normalizado),
    SECRET_KEY_INSTITUCIONAL
)
```
*Nota:* El núcleo **nunca recibe el cuerpo del correo**, solo el `Hash_Correo` resultante (64 caracteres) y sus metadatos no sensibles.

---

### B. Flujo Técnico 1: Emisión y Sellado (Patric / Dani)
1. El Colaborador Emisor (`E1`) redacta un correo y selecciona su tipología (`T1`, `T2` o `T3`).
2. El interceptor de salida calcula el `Hash_Correo` y genera un código corto o QR verificable que se incrusta en el pie del correo.
3. El Bloque 1 envía una petición asíncrona al Núcleo Central para registrar el hash en la **White List**:

**Endpoint:** `POST /api/v1/hashes/register`
```json
{
  "emisor_id": "E2_PRESTACIONES",
  "emisor_nombre": "Dirección de Prestaciones y Pensiones",
  "tipologia": "T2",
  "asunto_resumen": "Notificación de rol de pensión mensual",
  "hash": "8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4",
  "timestamp": "2026-11-26T15:30:00Z",
  "ttl_dias": 30
}
```
4. El correo sale normalmente hacia la bandeja del Asegurado.

---

### C. Flujo Técnico 2: Verificación del Asegurado (Isaac / Sergio)
El Asegurado tiene dos caminos para verificar un correo recibido:

* **Camino A (Correo con QR/Código):** Escanea el QR desde el canal oficial (Bot o Web Verificadora) o pega el código de verificación.
* **Camino B (Correo sospechoso sin QR o con remitente dudoso):** Reenvía el dominio del remitente, enlace o captura/asunto al Bot.

El Bloque 2 consulta al Núcleo Central:

**Endpoint:** `POST /api/v1/verify`
```json
{
  "hash_recibido": "8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4",
  "remitente_reportado": "reembolsos@iess-tramites-ec.com",
  "tipologia_percibida": "T2",
  "rango_etario_usuario": "65+",
  "canal": "BOT_WHATSAPP"
}
```

**Respuesta del Núcleo al Bloque 2:**
```json
{
  "estado": "PHISHING_CONFIRMADO",
  "semaforo": "ROJO",
  "motivo": "Hash inexistente en White List y dominio presente en Black List.",
  "metadatos_oficiales": null,
  "capsula_educativa": "El IESS nunca te pedirá ingresar claves por correo para cobrar reembolsos en 24 horas. Bloquea este remitente."
}
```
*(Si el estado es `LEGITIMO` / `VERDE`, `metadatos_oficiales` devuelve el área emisora, la tipología y el resumen del asunto para que el usuario confirme que coincide con lo que está leyendo).*

---

### D. Flujo Técnico 3: Núcleo Central y Observatorio (Luis / Jhair)

#### Modelo de Datos Mínimo (MVP)
1. **`emisores`:** `id`, `nombre_area`, `correo_oficial`, `tipologias_permitidas` (ej. `["T1", "T2"]`), `activo`.
2. **`whitelist_hashes`:** `hash` (PK), `emisor_id`, `tipologia`, `asunto_resumen`, `created_at`, `expires_at`, `revocado`.
3. **`blacklist_patrones`:** `id`, `tipo` (`DOMINIO`, `URL`, `FRASE`), `valor`, `tipologia_suplantada`, `reportes_count`.
4. **`eventos_observatorio`:** `id`, `timestamp`, `resultado` (`VERDE`, `AMARILLO`, `ROJO`), `tipologia`, `rango_etario`, `canal`.

#### Dashboard para Tomadores de Decisiones
**Endpoint:** `GET /api/v1/observatorio/metrics`
El tablero de Seguridad Cognitiva procesa `eventos_observatorio` para mostrar en tiempo real:
* **Morfología del ataque:** Qué tipología (`T1`, `T2`, `T3`) está siendo más suplantada y en qué franjas horarias.
* **Mapa de calor demográfico:** Distribución de incidentes y consultas por rango de edad (ej. `18-29`, `30-49`, `50-64`, `65+`).
* **Motor de Hipersegmentación (Acción):** Recomendación automática de campaña. *Ejemplo: "Alerta: Aumento del 40% en phishing tipo T2 (Financiero) dirigido a usuarios 65+. Acción sugerida: Enviar cápsula de audio preventiva a pensionistas."*

---

## 5. Auditoría Crítica: Teoría del Décimo Hombre

> **Regla del Décimo Hombre:** Si nueve personas en la sala están convencidas de que la arquitectura es sólida, la décima tiene la obligación estricta de asumir que **va a fallar** y buscar cómo destruirla.

A continuación, los **6 fallos críticos** que un atacante real o un jurado técnico exigente encontrará en nuestra propuesta, junto con cómo debemos blindarlos desde el MVP:

### Fallo 1: El ataque de "QR Falso" (*Quishing*)
* **El ataque:** Un estafador diseña un correo falso del IESS e incluye su propio código QR. Cuando el asegurado lo escanea con la cámara de su celular, el QR lo lleva a una web falsa (`verifica-iess.com`) que muestra un gran sello verde diciendo: *"✅ Correo 100% verificado por el IESS"*.
* **Por qué rompe la propuesta:** Si el QR contiene una URL abierta, el ciudadano no sabrá distinguir nuestra web verificadora de la web falsa del atacante.
* **Mitigación obligatoria:** El QR **NO debe ser un enlace libre que abra el navegador del atacante**. Debe contener únicamente un **código/payload de texto** diseñado para ser escaneado **desde adentro** del Bot oficial del IESS o de la Web oficial (`iess.gob.ec/verifica`). Como regla cultural en el pitch: *"Nunca confíes en la página que abre un QR; verifica siempre dentro de tu canal oficial"*.

### Fallo 2: Ataque de "Reutilización de Hash" (*Replay / Copy-Paste*)
* **El ataque:** Un atacante está afiliado al IESS, recibe un correo legítimo `T1` (un boletín cualquiera) con un QR/Hash válido. El atacante copia esa imagen del QR y la pega dentro de un correo de *phishing* que pide claves del BIESS. Cuando la víctima verifica el QR, el sistema busca el hash en la `White List`, lo encuentra ¡y le dice que es **VERDE / LEGÍTIMO**!
* **Por qué rompe la propuesta:** Un sello válido pegado en un mensaje falso genera una falsa sensación de seguridad letal.
* **Mitigación obligatoria:** Al devolver un resultado `VERDE`, el Bot/Web **nunca debe decir solo "Es válido"**. Debe mostrar los metadatos sellados:
  > *"✅ Sello auténtico emitido por: **Dirección de Afiliación** | Tipo: **Informativo (T1)** | Asunto oficial: **'Recordatorio de actualización de datos'** | Fecha: **26/11/2026**. Si el correo que estás leyendo te pide dinero, claves o trata de otro tema, es una **ESTAFA**."*

### Fallo 3: ¿De dónde sale el rango de edad sin violar la LOPDP?
* **El ataque del jurado:** *"Dijeron que no guardan datos personales y que el usuario consulta de forma rápida en un bot. Entonces, ¿cómo sabe el Observatorio si el que cayó en phishing tiene 25 o 70 años para hipersegmentar?"*
* **Por qué rompe la propuesta:** Si pides la cédula antes de verificar un correo sospechoso, agregas fricción (el usuario abandona) y almacenas datos sensibles. Si no la pides, el Observatorio queda ciego en edad.
* **Mitigación obligatoria:** Implementar un esquema híbrido con **anonimización por rangos (*buckets*)**:
  1. Si el asegurado ya está autenticado en el portal o bot oficial del IESS, el sistema consulta únicamente su **rango etario** (`65+`) al vuelo y guarda el evento **sin cédula ni nombre**.
  2. Si consulta de forma anónima, el Bot entrega el veredicto inmediato y al final hace una pregunta opcional de 1 clic (*"Para ayudarnos a proteger a más personas como tú, ¿en qué rango de edad estás?"*).

### Fallo 4: Compromiso interno (*Insider* o cuenta de emisor robada)
* **El ataque:** Un atacante roba las credenciales del colaborador `E1` (o un funcionario deshonesto abusa de su acceso) y envía un correo malicioso usando el servidor oficial del IESS. El Bloque 1 le genera un Hash legítimo automáticamente.
* **Por qué rompe la propuesta:** La `White List` legitima un ataque originado desde adentro.
* **Mitigación obligatoria:**
  1. **Control de permisos por tipología:** El emisor `E1` (Comunicación) solo puede generar hashes `T1`; si intenta emitir un `T2` (Financiero), el Bloque 1 lo bloquea y alerta al OSI.
  2. **Botón de Revocación en el Núcleo:** El Observatorio permite revocar por lote todos los hashes de un emisor comprometido en segundos (`revocado = true`).

### Fallo 5: La paradoja de la adopción (El usuario en pánico no verifica)
* **El ataque:** Las estafas exitosas juegan con la urgencia emocional (*"Tu pensión será bloqueada en 2 horas"*). Un adulto mayor asustado hace clic directo en el enlace falso sin acordarse de escanear el QR o abrir el Bot.
* **Por qué rompe la propuesta:** Si solo depende de que el usuario verifique proactivamente, el impacto inicial puede ser bajo.
* **Mitigación obligatoria:** Posicionar el sistema como un **radar de alerta temprana comunitaria**: basta con que el **1% de usuarios más desconfiados** (o familiares) reporte/verifique una campaña nueva de *phishing* para que el Observatorio detecte el patrón (`Black List`), identifique la tipología y edad objetivo, y **dispare una alerta preventiva masiva** antes de que caiga el 99% restante.

### Fallo 6: Fricción de integración con infraestructura heredada del IESS
* **El ataque del jurado:** *"El IESS tiene sistemas antiguos (como AS-400) y múltiples servidores de correo. ¿Cómo conectan el Bloque 1 sin rehacer toda la infraestructura ni detener el envío de correos si su API falla?"*
* **Por qué rompe la propuesta:** Si el sellado bloquea el envío de correos institucionales, el área de TI del IESS jamás aprobaría su paso a producción.
* **Mitigación obligatoria:** Arquitectura **desacoplada y no bloqueante** (vía *SMTP Relay* o *webhook* asíncrono). El correo se sella en milisegundos al pasar por la pasarela de salida sin tocar el *core* AS-400, y con modo *fail-open* (si el servicio de registro falla, el correo no se detiene, se encola el registro del hash).