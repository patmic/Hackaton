# API de Capacitación · Escudo Cognitivo IESS

Bloque **`backend/capacitacion/`** del proyecto (CLAUDE.md §2 y §12). Implementa
el flujo **«Quiero capacitarme»**: cuando un usuario se inscribe, genera y envía
un **correo de phishing _simulado_** (ficticio), convincente y adaptado a su tipo
de usuario y a la **tipología** de `tipologias-correo/tipologias.json`, mide su
reacción (clic o reporte), aplica la **escalera** de dificultad y alimenta al
**Observatorio**.

> Es una herramienta **defensiva** de concientización (estilo GoPhish/KnowBe4),
> con consentimiento previo (doble opt-in). No es, y no debe usarse como,
> infraestructura para phishing real.

---

## 1. Dónde encaja en la arquitectura

En el diagrama (`diagramas/diagrama.drawio.xml`) es el nodo **«API de
Capacitación»** de la Zona Externa, conectado con la **App Oficial** (Bloque 2) y
con el **Núcleo/Observatorio** (Bloque 3).

```
App Flutter (Bloque 2)                 API de Capacitación (este bloque)
  «Quiero capacitarme» ───inscribir──▶  genera correo simulado por tipo+tipología
  bandeja / estado     ◀──estado──────  escalera + límites de envío
                                        │
  correo de prueba  ◀──envío (Resend/Mailpit/consola)
  página /p/{token} ──clic/reporte────▶  mide reacción → momento enseñable
                                        │
                              observación sin dato personal
                                        ▼
                         Observatorio (Bloque 3, SellaCorreo)
                         POST /api/v1/observatorio/observaciones
```

La app ya tiene el **contrato cliente** (`Capacitacion/lib/src/data/capacitacion_api.dart`)
y un mock. Este servicio es la implementación real de ese contrato.

---

## 2. Garantías de seguridad (reglas 4 y 5 de CLAUDE.md)

Estas propiedades están **forzadas en el código**, no solo documentadas:

| Garantía | Dónde |
| --- | --- |
| La página de destino **no tiene formularios**; nunca pide clave, datos ni pago. Solo un botón «Continuar». | `landing.py` |
| El enlace del botón **siempre** apunta a `/p/{token}` (página neutra). El dominio sospechoso solo se *muestra* como texto (indicios I2/I4). | `generador_correo.py` |
| Ningún correo sale de `iess.gob.ec`. Sin I7 usa el dominio de práctica; con I7, un dominio «parecido» (la lección). | `config.validar()`, `envio._verificar_dominio()` |
| El adjunto de I5 es un marcador **inofensivo** con la extensión sospechosa, nunca un binario real. El QR codifica solo la URL de la página. | `generador_correo.py` |
| Solo cuenta el clic con el **POST** de «Continuar»; no se miden aperturas. | `landing.py` |
| LOPDP: en las métricas solo viaja `id_seudonimo` (HMAC); el token se guarda como SHA-256. | `seudonimo.py`, `observatorio.py` |
| Cada correo lleva `X-Simulacro-Ref`, `X-Entrenamiento-IESS` y `List-Unsubscribe` → `/salir/{token}`. | `generador_correo.py` |
| Modo de envío por defecto `consola`: **no envía**, solo escribe `.eml`. | `config.py`, `envio.py` |

---

## 3. Cómo generar correos sin levantar nada

Solo requiere Python 3.10+ (no necesita FastAPI):

```bash
python -m backend.capacitacion.ejemplos.generar_demo
```

Escribe los 20 `.eml` en `backend/capacitacion/ejemplos/salida_demo/` y muestra
un resumen (tipo, tipología, nivel, indicios, asunto, remitente, adjuntos). Ábrelos
en Gmail/Outlook/Thunderbird para verlos como los vería la persona.

## 4. Cómo correr la API

```bash
pip install -r backend/capacitacion/requirements.txt
uvicorn backend.capacitacion.main:app --reload --port 8080
# Documentación interactiva: http://localhost:8080/docs
```

### Recorrer el flujo de la demo (con curl)

```bash
# 1) Inscribirse (EX1 afiliado) → se genera y "envía" (modo consola) el 1.er correo
curl -X POST localhost:8080/api/v1/capacitacion/inscribir \
  -H 'Content-Type: application/json' \
  -d '{"consentimiento":{"version":"2026-11-v1","aceptado":true},
       "correo":"afiliado@correo.test","tipos":["EX1"],"rango_etario":"30-49"}'

# 2) Ver el estado (el correo generado aparece en correo_actual)
curl localhost:8080/api/v1/capacitacion/estado -H 'X-Usuario-Correo: afiliado@correo.test'

# 3a) Camino CLIC: abre el .eml de salida/ y pulsa "Continuar"
#     (o simula con el simulacro_id del estado):
curl -X POST 'localhost:8080/api/v1/demo/reaccion?simulacro_id=sim-XXXX&resultado=CLIC'

# 3b) Camino REPORTE: reenviar el correo al buzón de reportes (webhook):
curl -X POST localhost:8080/api/v1/reportes/entrante \
  -H 'Content-Type: application/json' \
  -d '{"cabeceras":{"X-Simulacro-Ref":"<token del correo>"}}'

# 4) Avanzar el reloj 11 min → los no reaccionados pasan a IGNORO
curl -X POST 'localhost:8080/api/v1/demo/avanzar?minutos=11'
```

---

## 5. Endpoints (contratos de CLAUDE.md §12)

| Método y ruta | Uso |
| --- | --- |
| `GET  /api/v1/me` | Tipos, zona y perfil del usuario (cabeceras `X-Usuario-Correo`, `X-Usuario-Tipos`) |
| `POST /api/v1/eventos` | Eventos de la app, sin identificador personal |
| `POST /api/v1/capacitacion/inscribir` | Consentimiento, (doble opt-in) y 1.er correo de prueba |
| `POST /api/v1/capacitacion/confirmar` | Doble opt-in: envía el 1.er correo tras confirmar |
| `GET  /api/v1/capacitacion/estado` | Estado del flujo del usuario |
| `GET  /api/v1/capacitacion/plan` | Plan personalizado desde el Observatorio (o respaldo local) |
| `POST /api/v1/capacitacion/pausar` · `/reanudar` · `/salir` | Control del usuario |
| `POST /api/v1/capacitacion/siguiente` | Interno: aplica la escalera y envía el siguiente |
| `POST /api/v1/reportes/entrante` | Webhook: reenviar el correo = reportar |
| `GET  /api/v1/observatorio/metrics` | Métricas agregadas (supresión k=10) |
| `GET  /p/{token}` | Página neutra con botón «Continuar» (**no** cuenta clic) |
| `POST /p/{token}/clic` | Cuenta el CLIC y muestra el momento enseñable |
| `GET  /salir/{token}` | `List-Unsubscribe`: baja de las prácticas |
| `POST /api/v1/demo/avanzar` · `/demo/reaccion` | Solo demo (no es contrato de producción) |

---

## 6. Cómo se genera un correo convincente

1. La **plantilla** (`plantillas.py`, espejo de `plantillas_prueba.dart`) fija el
   tipo, el nivel, la **tipología** que imita y los **indicios** a incluir.
2. La **tipología** aporta la «piel legítima» (remitente, área que firma, párrafo
   de apertura, referencia creíble), tomada de `tipologias.json`.
3. Cada **indicio** se *realiza* en el cuerpo con `fragmentos.py`:
   I1 urgencia, I3 pide clave, I5 adjunto, I6 premio, I7 remitente parecido,
   I8 amenaza, I9 pide datos, I10 pide pago, I11 QR, I2/I4 enlace falso/acortado.
4. El resultado es un MIME real (texto + HTML + adjuntos/QR) con las cabeceras de
   simulacro. El mismo `token` produce siempre el mismo correo (determinista).

### Escalera (CLAUDE.md §11)

Reportó → sube un nivel (indicios `DOMINADO`). Ignoró → mismo nivel. Clic → baja
un nivel (indicios `DEBIL`) y llega el microcurso. Dos reportes seguidos en nivel
3 → **Centinela** (un correo al mes). Límites: máximo uno por semana, nunca dos en
48 h. Está en `escalera.py` y se corresponde con `escalera.dart`.

---

## 7. Configuración (variables de entorno)

| Variable | Default | Para qué |
| --- | --- | --- |
| `ENTORNO` | `demo` | `demo` (ventana 10 min) o `produccion` (48 h) |
| `ENVIO_MODO` | `consola` | `consola` (no envía), `mailpit`, `resend`, `brevo` |
| `DOMINIO_PRACTICA` | `escuela-antiphishing.ec` | Dominio propio de envío (**nunca** iess.gob.ec) |
| `BUZON_REPORTES` | `reportes@escuela-antiphishing.ec` | Reenviar aquí = reportar |
| `BASE_URL` | `http://localhost:8080` | Base de las páginas `/p/{token}` |
| `SECRETO_SEUDONIMO` | *(dev)* | Clave HMAC del `id_seudonimo` (cámbiala) |
| `NUCLEO_URL` | *(vacío)* | Base del Observatorio; reenvía observaciones, consulta `/personas/{id}/siguiente` y borra al salir |
| `PROCESAR_VENCIDAS_SEG` | `60` | Intervalo en segundos del scheduler de simulaciones vencidas (`0` para desactivar) |
| `RESEND_API_KEY` / `BREVO_API_KEY` | — | Claves de envío real |
| `MAILPIT_HOST` / `MAILPIT_PORT` | `127.0.0.1` / `1025` | Mailpit local |

---

## 8. Modelo de datos (mapeo a CLAUDE.md §13)

El almacén en memoria (`almacen.py`) es un sustituto de la BD del Bloque 3:

| Clase en memoria | Tabla §13 |
| --- | --- |
| `Simulacion` | `simulaciones_correo` |
| `Inscripcion.mapa` | `mapa_indicios` |
| `Inscripcion` (tipos, rango, etc.) | parte de `usuarios` / `usuario_tipos` |
| observaciones reenviadas | `eventos_observatorio` (**sin** `id_seudonimo`) |

Para producción se cambia `almacen.py` por el cliente de la BD sin tocar la
lógica de `servicio.py`, `escalera.py` ni `generador_correo.py`.
