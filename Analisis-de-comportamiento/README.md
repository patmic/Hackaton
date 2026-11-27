# Análisis de comportamiento · Observador

Módulo del **Escudo Cognitivo IESS (AI-IESS)** que aprende de cómo reacciona cada persona a los correos de prueba del flujo «Quiero capacitarme» y a las actividades de la app, y arma una **capacitación personalizada según sus falencias**. También aprende de toda la población para el **Observatorio** de SellaCorreo.

- Paquete Python `observador/`, **solo biblioteca estándar** (FastAPI solo para `observador/api.py`).
- Se monta en SellaCorreo (`/observatorio` y `/api/v1/observatorio/*`), en el mismo contenedor.
- Lo consumen la app Flutter (`Capacitacion/`) y la API de Capacitación (`backend/capacitacion/`).

## Flujo

```text
Quiero capacitarme ─► correo de prueba ─► reacción (REPORTO / CLIC / IGNORO)
        ▲                                        │  POST /observaciones
        │                                        ▼
 plan personalizado ◄── observador ◄── actividades de la app (DECISION) y verificaciones
 (falencias, foco,        │
  siguiente correo,       └─► Observatorio (k ≥ 10): qué engaña a cada segmento,
  ritmo)                       dificultad real de cada plantilla, perfiles
```

## Cómo aprende

### 1. Por persona (`modelo.py`)

Cada observación deja evidencia sobre los indicios I1 a I11 que tenía el correo o el ítem:

| Observación | Evidencia por indicio |
|---|---|
| Correo de prueba **reportado** | acierto × peso del nivel: 0,6 (nivel 1), 1,0 (nivel 2), 1,4 (nivel 3) |
| Correo de prueba con **clic** | fallo × peso del nivel: 1,4 (nivel 1), 1,0 (nivel 2), 0,6 (nivel 3) |
| Correo **ignorado** | nada: no se miden aperturas (§11), así que no se sabe si lo vio |
| Decisión en una actividad | acierto o fallo × 0,5: practicar en la app pesa menos que la conducta real |
| Indicios implícitos (I7 e I2 de todo correo de práctica) | la mitad del peso |

- **Dificultad (NIST Phish Scale).** Reportar un correo sutil dice más que reportar uno obvio. Caer en uno obvio dice más que caer en uno sutil.
- **Olvido.** La evidencia pierde la mitad de su peso cada 60 días. Lo aprendido se olvida en 1 a 6 meses (CLAUDE.md §10.1), así que un indicio dominado hace tiempo vuelve a «por repasar».
- **Estimación.** La probabilidad de reconocer cada indicio es la media de una Beta(0,5 + aciertos, 0,5 + fallos). El estado visible respeta el mapa [DECIDIDO] de §8.2:
  - `SIN_PROBAR`: evidencia menor que 0,25.
  - `DOMINADO`: probabilidad mayor o igual que 0,6.
  - `DEBIL`: el resto. Se muestra como «Para practicar».
  - Un reporte deja el indicio en DOMINADO y un clic en DEBIL. Reportar después de un clic lo deja en DEBIL.
- **Conducta (§7, ventana de 90 días).** Precisión, tasa de reporte, mediana hasta reportar y **clic ajustado por dificultad**: clics observados ÷ clics esperados según la dificultad de cada correo. Con eso se calcula el perfil (Centinela, Prudente, «En aprendizaje», Inactivo, Sin perfil) y la regla **R4**: si la precisión cae más de 15 puntos frente a las primeras semanas, se adelanta el refuerzo.

### 2. Por población (`poblacion.py`)

- **Por segmento** (tipo de usuario × rango de edad): qué indicios y qué tipologías engañan más. Sirve como punto de partida para una persona nueva (arranque en frío) y alimenta el Observatorio.
- **Por plantilla**: la tasa de clic real de cada correo de prueba recalibra su dificultad. Si una plantilla «de nivel 2» engaña como una de nivel 3, el Observatorio lo marca.
- **k = 10.** Ninguna celda con menos de 10 personas distintas se publica ni se usa como punto de partida (regla 6).

### 3. Plan personalizado (`plan.py`)

```text
prioridad(indicio) = riesgo × relevancia + exploración + repaso
```

| Término | Qué es |
|---|---|
| riesgo | 1 − probabilidad de reconocerlo. Con poca evidencia propia, se apoya en su segmento |
| relevancia | 0,5 a 1, según cuánto se usa ese indicio para suplantar las tipologías que recibe la persona (`suplantacion_frecuente` y `publico` de `tipologias-correo/tipologias.json`). **1 si ya le engañó alguna vez**: su propia evidencia manda |
| exploración | +0,1 si nunca se probó: la escalera exige al menos un indicio DEBIL o SIN_PROBAR (§11) |
| repaso | +0,1 si lo dominaba hace más de 60 días |

El plan trae:
- las 3 falencias, cada una con sus motivos y su microcurso (§11);
- la tipología foco y su cápsula;
- el siguiente correo de prueba (nivel por escalera, indicios objetivo y tipología);
- el ritmo (INTENSIVO para «En aprendizaje», MENSUAL para Centinela, BASE para el resto);
- su nivel de confianza.

`elegir_plantilla(plan, candidatas)` escoge el correo que mejor trabaja ese plan.

**Equidad.** Lo que la persona ve como dominado o por practicar sale **solo de sus acciones**. El segmento solo decide qué practicar primero: nadie queda etiquetado por su edad o su tipo de cuenta.

## ¿Aprende de verdad?

`python -m observador simular` crea 400 personas ficticias con vulnerabilidades ocultas por segmento. Por ejemplo, la amenaza sobre la pensión engaña más a jubilados de 65+. La simulación les envía correos elegidos por el propio observador. Sin conocer esas vulnerabilidades, el observador encuentra la principal en la mayoría de los segmentos:

```text
EX2 · 65+     más engañan: I9 43%, I8 27%, I1 26%   (vulnerabilidad oculta: I8, I9, I1)
EX4 · 50-64   más engañan: I5 65%, I7 32%, I1 29%   (vulnerabilidad oculta: I5, I1)
IN1 · 50-64   más engañan: I3 43%, I2 41%, I1 36%   (vulnerabilidad oculta: I3, I6, I5)
```

También detecta que los seis «primeros correos por tipo» de §11 engañan como un nivel 3. Apuntan justo al ataque típico de cada tipo, así que conviene recalibrarlos. La prueba `test_el_observador_descubre_las_vulnerabilidades_ocultas` lo verifica.

**Por persona.** Entre las personas sintéticas que ya cayeron alguna vez en su vulnerabilidad oculta, ¿su plan (solo con sus acciones, sin datos del segmento) la muestra entre sus 3 falencias? Medido el 2026-11-27 en 3 poblaciones de 400 (semillas 7, 11 y 2026); los segmentos, en 5 (además 42 y 99):

| Relevancia | La muestra en el top 3 | La pone primera | Segmentos que la descubren (1.ª / top 3) |
|---|---|---|---|
| Solo por tipología (antes) | 9 % | 2 % | 63 % / 91 % |
| Máxima si ya le engañó (ahora) | 56 % | 23 % | 65 % / 91 % |

Antes, un indicio poco usado contra su tipo de cuenta (por ejemplo «pide pago», I10, para un afiliado: relevancia 0) nunca llegaba a su plan aunque le hubiera engañado: lo tapaban los indicios sin probar. La prueba `test_aprende_la_debilidad_de_cada_persona` exige al menos 45 %.

## Contrato HTTP (prefijo `/api/v1/observatorio`)

| Método y ruta | Quién | Qué hace |
|---|---|---|
| `POST /observaciones` | App, API de Capacitación | Una observación o `{"observaciones": [...]}` (máximo 200; si una es inválida no se guarda ninguna) |
| `GET /personas/{id}/plan?tipos=EX1&rango=30-49` | App | Plan personalizado. `tipos` y `rango` sirven para arrancar sin historial |
| `POST /personas/{id}/siguiente` | API de Capacitación | `{"ya_enviadas": [...], "candidatas"?: [...]}` → plantilla elegida |
| `DELETE /personas/{id}` | App al salir | Borra todo lo de esa persona (derecho de eliminación, LOPDP) |
| `GET /resumen` | Panel con sesión | Agregados con k = 10 |

Ejemplos en `contrato/`:
- `observacion_simulacro.json`
- `observacion_decision.json`
- `observacion_verificacion.json`
- `plan.ejemplo.json`, que genera una prueba y lee la app.

## Cómo lo usa la app (aula virtual de `Capacitacion/`)

```text
¿Real o estafa? (cada tarjeta) ─┐
Caza la señal (cada señal) ─────┤  ObservacionConducta    observadorProvider
correo de prueba (mock) ────────┼──────────────────────▶ (guarda en el dispositivo)
verificar un código ────────────┘                           │            │ solo si la persona
                                                            ▼            ▼ activa «Compartir»
                                      ObservadorLocal (mismo modelo)   POST /observaciones
                                                            │            GET /personas/{id}/plan
                                                            ▼            ▼
                                            planPersonalizadoProvider (servidor si ya tiene todo;
                                                            │           si no, el del dispositivo)
                              ┌─────────────────────────────┼───────────────────────────┐
                              ▼                             ▼                           ▼
                 MotorRecomendacion: «Para ti»   PlanPersonalCard: «Lo que más    MockCapacitacionApi:
                 sube lo que le costó            te conviene practicar»           el 2.º correo de prueba
                                                                                  en adelante trabaja eso
```

- **Sin servidor también aprende.** `ObservadorLocal` (Dart) es el mismo modelo de `modelo.py` y la relevancia de `plan.py`, sin el arranque por segmento. Una prueba de Flutter compara su mapa de indicios con `contrato/plan.ejemplo.json`; otra lee ese plan con `PlanPersonalizado.fromJson`.
- **Compartir es opcional** (interruptor en la tarjeta, apagado al empezar). La app envía al Radar Phishing con un código aleatorio del dispositivo (32 hex), nunca nombre, cédula ni correo. Sin conexión reintenta con la siguiente práctica; un lote rechazado (4xx) se descarta para no frenar a los demás.
- **«Borrar mis prácticas»** llama a `DELETE /personas/{id}`, borra lo guardado y crea un código nuevo.
- **Servidor:** `--dart-define=OBSERVADOR_URL=https://…` o, si falta, `AIESS_SELLO` (el observador vive en SellaCorreo). El origen web debe estar en `SELLACORREO_OBSERVATORIO_ORIGENES` (por defecto solo localhost).
- **[PENDIENTE]** Con la API de Capacitación real, la persona tiene dos códigos: el HMAC de su correo (correos de prueba) y el del dispositivo (aula). Falta que `/me` o `/estado` devuelvan el `id_seudonimo` para que el aula use el mismo.

## Privacidad (reglas 3 y 6 de CLAUDE.md)

- Solo se guardan `id_seudonimo`, tipos, rango de edad y códigos (indicios, tipologías, niveles, resultados). Nunca cédula, nombre, correo ni IP.
- El `id_seudonimo` es el HMAC del servidor (API de Capacitación) o, en la app sin cuenta, un identificador aleatorio del dispositivo. Igual que `mapa_indicios` y `perfiles_conducta` de §13, son datos seudonimizados: siguen siendo personales.
- Los agregados se publican con k ≥ 10 y sin identificadores.
- `DELETE /personas/{id}` borra todo. La app lo llama al salir de la capacitación.
- Los datos sintéticos de la demo llevan `origen = "sintetico"` y se borran aparte.

## Uso

```bash
# Pruebas (sin Python local, con Docker):
docker run --rm -v "$PWD/..:/repo" -w /repo/Analisis-de-comportamiento python:3.12-slim \
  sh -c "pip install -q pytest && python -m pytest"

# Lo que aprende de la población sintética:
python -m observador simular --personas 400

# Desde Python (por ejemplo, backend/capacitacion):
from observador import Observador, Almacen
obs = Observador(Almacen("observador.db"))
obs.registrar({...})          # contrato/observacion_simulacro.json
plan = obs.plan("a3f9c2e17b4d48e0b6c1")
```

Datos compartidos:
- `datos/plantillas.json` se exporta desde `Capacitacion/lib/src/domain/plantillas_prueba.dart`. Una prueba de Flutter falla si se desfasa.
- `tipologias.json` se lee de `tipologias-correo/` (variable `OBSERVADOR_TIPOLOGIAS`).

## Supuestos y límites

- **[SUPUESTO]** Pesos por nivel, vida media de 60 días, umbral de 0,6 y tasas de clic esperadas (8 %, 18 %, 30 %, dentro del 1,8 % a 30,8 % de Ho et al., IEEE S&P 2025). Se recalibran en el piloto con grupo de control.
- **[SUPUESTO]** IRS (§8.2) con tres componentes: precisión, reporte y 1 − falsos positivos. La tasa de verificación necesita saber cuántos correos oficiales recibió cada persona.
- **[SUPUESTO]** Quien acierta pero nunca verifica ni reporta queda «Sin perfil»: §7 no lo define.
- **Décimo hombre.**
  - Todo correo de práctica lleva I7 (sale del dominio de práctica) e I2 (su botón va a ese dominio), también los de nivel 3 con «1 indicio». Por eso pesan la mitad.
  - Ignorar un correo no prueba que se vio: no suma ni resta dominio.
  - Con menos de 10 personas por segmento no hay punto de partida colectivo, y el plan lo dice en su campo `confianza`.
