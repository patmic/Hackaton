# Catálogo de indicios, diccionario de datos y canales oficiales del IESS

> Reto 1 · Seguridad inteligente, cultura consciente · Hackatón Código Confianza IESS 2026 · Datos sintéticos
> Transcripción a Markdown de `Catalogo_Indicios_y_Canales_Oficiales.pdf`.

*Material de apoyo del dataset sintético de entrenamiento y de los correos de práctica.*

## 1. Cómo se usa

Cada correo del dataset tiene 11 columnas de indicios (`I1` a `I11`) con valor `1` si el indicio está presente y `0` si no. La columna `Phishing` (Sí/No) es la conclusión: **un correo es phishing cuando presenta al menos un indicio de esta tabla**. Todos los correos, enlaces, dominios y personas del dataset son inventados; solo se usan como referencia los canales oficiales de la sección 4.

## 2. Diccionario de datos

El archivo `dataset_entrenamiento_IESS_1000.csv` tiene 23 columnas y 1000 filas (una por correo).

| Campo | Qué contiene | Formato | Ejemplo |
| :--- | :--- | :--- | :--- |
| `id` | Identificador del correo | `E001` a `E1000` | `E042` |
| `subject` | Asunto del correo | Texto | Reembolso pendiente de su afiliación |
| `body` | Cuerpo del correo, sin remitente. Los botones aparecen entre corchetes | Texto, con saltos de línea | Estimado afiliado: … [Continuar] |
| `date` | Fecha del correo | `dd/mm/aaaa` | 18/12/2025 |
| `url_count` | Cantidad de enlaces del correo | Número entero | 2 |
| `urls` | Direcciones reales a las que llevan los enlaces (no el texto que se ve) | Lista `[a],[b]`; vacío si no hay | `[https://cshort.jp/0hut1qrj]` |
| `attachments_count` | Cantidad de adjuntos | Número entero | 1 |
| `attachments_types` | Tipo (extensión) de cada adjunto | Lista `[a],[b]`; vacío si no hay | `[zip]` |
| `attachments_total_size` | Suma de los tamaños de los adjuntos | Bytes; 0 si no hay | 140027 |
| `attachments_sizes` | Tamaño de cada adjunto | Lista en bytes `[a],[b]`; vacío si no hay | `[140027]` |
| `hops_count` | Saltos del correo hasta llegar al destinatario (cabeceras `Received`) | Número entero, de 1 a 8 | 4 |
| `Phishing` | Conclusión: `Sí` si el correo es phishing, `No` si es legítimo | `Sí` / `No` | Sí |
| `I1` a `I11` | Indicios del catálogo (sección 3): 1 si el indicio está presente, 0 si no | `0` / `1` (11 columnas) | `I2 = 1`, `I4 = 0` |

**Cómo se relacionan `Phishing` e indicios:** los indicios son la evidencia y `Phishing` es la conclusión. Un correo es `Sí` cuando tiene al menos un indicio en 1; un correo `No` tiene todos en 0. La columna `Phishing` la define la organización al generar el dato y es la respuesta que el modelo debe aprender a predecir.

**Otras reglas:** el remitente no es una columna del dataset (el indicio `I7` sí lo refleja); un correo sin adjuntos o sin enlaces tiene el contador en 0 y los campos de lista vacíos; todo el texto está en español y el archivo usa separador `;`.

## 3. Los 11 indicios

| Código | Indicio | Qué se revisa | Ejemplo (sintético) |
| :--- | :--- | :--- | :--- |
| `I1` | Urgencia artificial | Plazos muy cortos o presión para actuar de inmediato. | «Este trámite debe completarse hoy mismo.» |
| `I2` | Enlace a dominio no oficial | El enlace lleva a un sitio que no es del IESS ni de una entidad pública o servicio conocido. | `iess-afiliados-xxxx.test` en lugar de `iess.gob.ec` |
| `I3` | Pide credenciales, claves, códigos o tarjeta | Solicita usuario, contraseña, clave de afiliado, códigos de verificación o datos de tarjeta. | «Ingrese su usuario y contraseña en el portal.» |
| `I4` | Enlace acortado u oculto | Usa un acortador (bit.ly, cutt.ly…) o el texto muestra una dirección y el enlace lleva a otra. | `https://cshort.jp/…` ; texto «www.iess.gob.ec» que abre otro sitio |
| `I5` | Adjunto o instalación sospechosa | Archivo `.zip`, `.exe`, `.apk`, `.html` o con macros, o pide instalar una aplicación. | `Factura_1234.zip` ; «Instale la aplicación…» |
| `I6` | Premio, bono o reembolso inesperado | Ofrece dinero o beneficios que la persona no solicitó. | «Usted tiene derecho a un reembolso único de USD…» |
| `I7` | Remitente no oficial | Correo gratuito, dominio parecido al oficial, o responder-a distinto del remitente. | `notificaciones@iess-serviciosxx.xyz` |
| `I8` | Amenaza o pérdida de beneficio | Advierte de suspensión, bloqueo, multa, embargo o pérdida de la pensión o afiliación. | «De no hacerlo, su cuenta será suspendida.» |
| `I9` | Pide datos personales o documentos | Solicita cédula, fecha de nacimiento, foto del documento o selfie. | «Envíe una selfie sosteniendo su documento de identidad.» |
| `I10` | Pide pago o transferencia | Solicita depósito, tasa, multa, criptomonedas o transferencia. | «Cancele una tasa administrativa de $4,50.» |
| `I11` | Código QR hacia sitio no verificable | Pide escanear un QR cuyo destino no se puede comprobar. | «Escanee el código QR adjunto con su celular.» |

## 4. Canales oficiales del IESS

Un enlace o remitente que no coincida con estos canales (ni con entidades públicas o servicios conocidos como SRI, Registro Civil, gob.ec, Microsoft, Google o Zoom) debe tratarse como no oficial.

| Canal | Dato |
| :--- | :--- |
| Portal institucional | `www.iess.gob.ec` |
| Aplicaciones en línea (afiliado) | `app.iess.gob.ec` — gestión del afiliado, turnero en línea y desbloqueo público |
| Denuncias | `denuncias.iess.gob.ec` ; `gestiondenuncias@iess.gob.ec` |
| WhatsApp institucional | +593 9 62532338 |
| Atención al usuario | `atencionalusuario@iess.gob.ec` ; teléfono 593 2 3945666 |
| Seguridad de la información | `seguridad.informacion@iess.gob.ec` (confirmado por el responsable del reto) |
| Portal de trámites del Estado | `www.gob.ec/iess` |

*Fuente: sitios públicos del IESS consultados para este reto. Verificar vigencia de los datos antes de difundirlos.*

## 5. Ante la duda

- No abra enlaces ni adjuntos del correo.
- Compare el dominio con los canales oficiales de la sección 4.
- Escriba o llame por un canal oficial para confirmar.
- Reporte el correo a `seguridad.informacion@iess.gob.ec`.
