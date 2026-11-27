# SellaCorreo

Sitio web anti-phishing para correo institucional, en **un solo servicio**: http://localhost:8090

| Página | Quién | Qué hace |
|---|---|---|
| **Login** `/login` | Personal del IESS | Ingreso con correo electrónico y contraseña; en modo demo, tarjeta **Acceso rápido de demostración** |
| **GenKey** `/genkey` | Personal con sesión | Elige la taxonomía del correo (comunicacional, informativo, recordatorio...) y genera un **enlace dinámico con hash** ligado a una **imagen de encabezado** para pegar en el correo |
| **CheckIn** `/checkin` | Cualquier destinatario | Al hacer clic en la imagen del correo llega aquí: valida el hash y la firma y muestra **Correo válido** o **Correo inválido** |

Capturas en `docs/capturas/`. Estilo: tokens y componentes de **ThemeLight** (boilerplate del proyecto);
marca neutra propia de SellaCorreo (no usa logotipos del IESS).

## Puesta en marcha

Requisitos: Docker Desktop abierto. Todo se ejecuta **dentro de la carpeta `SellaCorreo`**.

```powershell
cd C:\pat_mic\pat_dev\epnHackaton\SellaCorreo
python scripts\init_env.py      # solo la primera vez: crea .env y muestra usuarios y contraseñas demo
docker compose up --build -d     # -d: queda en segundo plano y la consola se libera
docker compose logs -f sellacorreo   # opcional: ver el log (Ctrl+C sale del log, el servicio sigue)
```

O con doble clic en `levantar.bat` (crea `.env` si falta y levanta el servicio).

Abra http://localhost:8090. En el login verá la tarjeta **Acceso rápido de demostración**: haga clic en
una cuenta para entrar directamente. Todas usan la contraseña de `SELLACORREO_DEMO_PASSWORD`
(por defecto `Demo2026`). También puede escribir el correo y la contraseña en el formulario.

Cada línea `SELLACORREO_USUARIO_N=usuario|Cargo|Unidad|correo|contraseña` define un usuario (hasta 5).
Si la contraseña va vacía usa la de demostración. En la base solo se guarda su hash scrypt.
La tarjeta solo aparece con `SELLACORREO_DEMO=true`; póngalo en `false` fuera de una demo.

### Base de datos

Todo (usuarios, taxonomías, sellos, log y verificaciones de CheckIn) se guarda en **un único archivo SQLite**,
`/data/sellacorreo.db`, dentro del volumen Docker `sellacorreo-data`, junto con la clave de firma.
No hay ningún otro motor de base de datos. Para inspeccionarla:
`docker compose exec sellacorreo python -c "import sqlite3;print(sqlite3.connect('/data/sellacorreo.db').execute('select usuario, emisor from usuarios').fetchall())"`

Detener: `docker compose down`. Borrar también la base y la clave de firma: `docker compose down -v`.

## Página de inicio

`http://localhost:8090/` muestra el título, el dial con la imagen central y dos accesos: **Validador** (CheckIn)
y **Sello** (GenKey; pide iniciar sesión). Debajo hay contadores de sellos, verificaciones y posibles phishing.

**Imagen central:** `sellacorreo/static/img/escudo-correo.png` (escudo azul con sobre, fondo transparente). El escudo IESS anterior sigue en `sellacorreo/static/img/inicio-iess.jpg`; para volver a usarlo, cambie el `src` de la imagen `sc-dial__img--base` en `main.py` a ese archivo y quite la clase `sc-dial__img--escudo`.
Para cambiarla, reemplace ese archivo por otra imagen con el mismo nombre (PNG con fondo transparente) y ejecute `docker compose up --build -d`.
`inicio-mascotas.jpg` queda como alternativa.

Al pasar el mouse o enfocar la tarjeta **Sello**, el dial cambia a `sellacorreo/static/img/sello.jpg` y el puntero
apunta a la tarjeta. En celular, el primer toque muestra la imagen y el segundo abre GenKey. Para hacer lo mismo
con **Validador**, basta con agregar `static/img/validador.jpg` y una segunda `<img class="sc-dial__img sc-dial__img--validador">`
en la página de inicio; el script la detecta solo.

## Flujo

1. **Login**: clic en una cuenta del acceso rápido, o correo + contraseña.
2. **GenKey** (mapa de nodos): a la izquierda elija la **taxonomía**; a la derecha active las **políticas de
   seguridad**; en el centro está su sello (avatar con anillo de progreso). Escriba el asunto (y, si quiere, el
   destinatario) y pulse *Generar enlace e imagen*. Ya no se pide el texto del correo. Obtendrá:
   - la imagen con su enlace, lista para **Copiar imagen con enlace** y pegar en Outlook o Gmail;
   - el enlace dinámico `http://localhost:8090/checkin/<token>.<huella>`;
   - el HTML `<a href=…><img src=…></a>` y la imagen PNG para descargar.
3. Pegue la imagen al inicio del correo y envíelo.
4. El destinatario hace clic en la imagen → **CheckIn**:
   - **Correo válido**: el token existe, la huella coincide con el hash registrado y la firma Ed25519 es válida.
     Se muestran asunto, taxonomía, emisor y fecha para comparar con el correo recibido.
   - **Correo inválido**: token inexistente, huella o token alterados, o firma rota → posible phishing.
   - Si se indicó destinatario en GenKey, CheckIn ofrece «¿Le llegó a usted?»: si quien verifica no es el
     destinatario real (alguien copió la imagen en un correo falso), también muestra **Correo inválido**.

## Políticas de seguridad (GenKey, bloque «Hash de seguridad»)

| Política | Qué hace | Qué se guarda |
|---|---|---|
| **Palabra segura** | El emisor acuerda antes una palabra con el destinatario. CheckIn la muestra en grande **solo si el correo es válido**; en cualquier resultado inválido (enlace alterado, registro manipulado, caducado, destinatario distinto) no aparece. Un phishing que copie la imagen no puede mostrarla. Es **por sello** (cada correo puede llevar la suya). | Cifrada con AES-GCM (clave derivada de `SELLACORREO_HMAC_KEY` + token) y un HMAC corto que entra en el hash. Nunca en claro. |
| **Caducidad del enlace** | 24 h, 7, 30 o 90 días. Pasada la fecha, CheckIn responde **Correo inválido: caducó**. | `expira_utc` (forma parte del hash: moverla invalida el sello). |
| **Exigir emisor** | CheckIn pide el correo del remitente (el que aparece en el correo recibido). Solo si coincide con el emisor del sello muestra «válido». Se incluye en el hash, así que quitarla de la base invalida el sello. Los sellos anteriores no cambian. |
| **Exigir destinatario** | Obliga a indicar el destinatario. CheckIn no dice «válido» ni muestra la palabra segura hasta que quien verifica escribe el correo al que llegó y coincide. | Solo la huella HMAC del destinatario. |

## Cómo funciona el sello

- **Hash compuesto**: `H = SHA-256(usuario | HMAC(emisor-destinatario) | ts_utc | tamaño | SHA-256(contenido))`.
  El contenido es `Subject: <asunto>\n\npoliticas: caduca=…; palabra=<tag>; destinatario=…` canonicalizado
  (NFC, LF, sin espacios finales). CheckIn **recalcula H** con los datos guardados, así que alterar el asunto o
  las políticas en la base también da «Correo inválido».
  El HMAC usa `SELLACORREO_HMAC_KEY`; el destinatario nunca se guarda en claro.
- **Firma**: Ed25519 sobre `H|id|ts_utc|taxonomía|kid`. La clave se genera al primer arranque en el volumen
  `sellacorreo-data` (`/data/ed25519.pem`); la pública está en `/.well-known/sellacorreo-key`.
- **Enlace**: token aleatorio (`secrets.token_urlsafe`) + 16 primeros caracteres de `H`. Sin IDs secuenciales.
- **Log**: cada sello queda en una tabla encadenada (`prev_hash` → `entry_hash`) y firmada; auditable con
  `GET /api/v1/integridad` (requiere sesión).
- **Seguridad web**: sesión en cookie HttpOnly firmada (HMAC), CSRF en formularios, límite de consultas por IP
  en CheckIn y en login, CSP estricta.
- **Taxonomías**: comunicacional, informativo y recordatorio vienen en el esquema; agregue más con
  `SELLACORREO_TAXONOMIAS` en `.env`.

## Pruebas

```bash
pip install -r requirements-dev.txt
pytest            # 10 casos + políticas (palabra segura, caducidad, destinatario, migración) + acceso rápido + SQLite (no necesita Docker) + 1 e2e contra :8090
```

| # | Caso |
|---|---|
| 01 | Login correcto, clave mala y GenKey sin sesión |
| 02 | Contraseñas solo como hash scrypt; sesión firmada (cookie alterada = sin sesión) |
| 03 | Taxonomías configurables en GenKey |
| 04 | GenKey genera enlace dinámico, imagen PNG y HTML para pegar |
| 05 | Hash compuesto recalculable y firma Ed25519 válida |
| 06 | CheckIn de un enlace auténtico → Correo válido |
| 07 | CheckIn de enlaces alterados o inventados → Correo inválido |
| 08 | Confirmación de destinatario (imagen copiada) |
| 09 | CSRF, validaciones y límite por IP |
| 10 | Log encadenado y firmado; ningún destinatario en claro |

## Estructura

```
docker-compose.yml   Dockerfile   requirements.txt   .env.example
sellacorreo/        aplicación (main.py, store.py, firma.py, schema.sql, static/)
common/autenticidad canonicalización, hash compuesto, imagen de encabezado (fuente DejaVu)
scripts/            init_env.py, levantar.py
tests/              test_sellacorreo.py (10 casos), test_e2e.py
```
