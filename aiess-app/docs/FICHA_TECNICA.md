# AIESS · Ficha técnica

> Hackatón Código Confianza 2026 · Reto «Seguridad inteligente, cultura consciente» · 27-11-2026
> Versión con diseño para presentar: `ficha_tecnica.html` (ábrela en el navegador; se puede imprimir a PDF).

## Problema
Los afiliados, jubilados, pensionistas y colaboradores del IESS reciben correos que se hacen pasar por el
Instituto para robarles la clave, los datos o el dinero. La mayoría no tiene perfil técnico y no sabe qué revisar,
qué le puede pasar ni dónde reportarlo.

## Solución
**AIESS**: app con un robot guardián que habla. La persona carga el correo (.eml, PDF, captura o texto) y el robot:
1. muestra las partes del correo (remitente, asunto, a dónde llevan de verdad los enlaces, adjuntos) **sin abrir nada**;
2. busca los indicios I1–I11 del catálogo con reglas locales, un modelo de IA local y fuentes públicas;
3. da el veredicto **«Phishing: SÍ · N indicios»** o **«NO · 0 indicios»**;
4. lo explica con voz y subtítulos: cada indicio, qué te podría pasar, el aviso de **deepfake**;
5. dice qué hacer y prepara el **reporte al IESS** (simulado en la demo).

Además: sello digital del IESS (SellaCorreo, firma Ed25519) que el robot verifica, aula virtual con
microlecciones y Observatorio anónimo de comportamiento.

## Usuarios
| Grupo | Cómo lo usa |
|---|---|
| Afiliados, jubilados y pensionistas | App Android o web; letra grande, voz, «Lectura fácil», sin tecnicismos |
| Colaboradores del IESS | Web en la PC del puesto, con la IA corriendo en la misma PC |
| Seguridad de la Información (IESS) | Recibe los reportes; ve tendencias en el Observatorio (sin datos personales) |

## Arquitectura

```text
 Correo (.eml / PDF / captura / texto)
              │   todo se lee EN EL EQUIPO
              ▼
 ┌─────────────────── Celular o PC ───────────────────┐
 │ Lector .eml/OCR → Partes del correo (sin abrir)    │
 │        → Reglas I1–I11 ──┐                          │
 │        → IA local LFM2 ──┴─► Veredicto + Robot      │
 │          (llama.cpp)          voz y subtítulos      │
 │        → Reporte simulado al IESS                   │
 └──────────────┬─────────────────────────────────────┘
                │ solo sale: el DOMINIO (RDAP), la huella SHA-256 del asunto (sello)
                │ y semáforo + códigos I1–I11 con seudónimo (Observatorio, se apaga)
                ▼
   rdap.org · SellaCorreo (sello IESS) · Observatorio
   OpenPhish: la lista se descarga y se compara en el equipo
```

**Decisión clave:** la IA no decide sola. El veredicto y la lista de indicios salen siempre de las reglas del
catálogo; el modelo solo agrega explicación cuando coincide con ellas.

## OSINT local (sin red)
Cada enlace se analiza **sin visitarlo** (`lib/features/osint/url_analyzer.dart`, espejo de `ml/aiess_ml/osint_rules.py`).

| Señal | Qué detecta | Indicio | Peso |
|---|---|---|---|
| `TYPOSQUATTING` | Imita una marca con letras cambiadas (Damerau-Levenshtein + homoglifos `rn→m`, `0→o`) | I2 | 40 |
| Enlace engañoso | El texto muestra un sitio y el destino real es otro | I4 | 60 |
| `USUARIO_EN_URL` | Destino escondido detrás de una `@` | I4 | 35 |
| `ACORTADOR` | bit.ly y similares | I4 | 35 |
| `IP_DIRECTA` | IP en lugar de dominio | I2 | 35 |
| `SUBDOMINIO_ENGANOSO` | `iess.gob.ec.sitio-falso.com` | I2 | 35 |
| `PUNYCODE` | Caracteres especiales (`xn--`) | I2 | 30 |
| `DOMINIO_NO_OFICIAL` | No es del IESS ni de una entidad conocida | I2 | 30 |
| `SUPLANTA_MARCA` / `ALOJAMIENTO_GENERICO` | Usa una marca sin ser su sitio / alojamiento gratuito | I2 | 25 |
| `TLD_RIESGOSO`, `SIN_HTTPS`, `RUTA_SENSIBLE`, `MUCHOS_SUBDOMINIOS` | Señales de apoyo | — | 10–20 |
| Remitente | Correo gratuito o dominio no oficial | I7 | 40 |

## CTI pública (declarada y mínima)
Solo para los enlaces **no oficiales** (hasta 3); si una fuente no responde en 5–6 s, siguen las reglas locales
(`lib/features/osint/cti.dart`).

| Fuente | Qué aporta | Qué sale del equipo | Regla |
|---|---|---|---|
| **RDAP** (rdap.org) | Fecha de registro del dominio | Solo el dominio registrable, por HTTPS | Creado hace ≤ 30 días → I2 |
| **OpenPhish** | Lista pública de phishing activo | Nada: se descarga (caché 1 h) y se compara en el equipo | URL o dominio en la lista → I2, riesgo máximo |
| **Sello SellaCorreo** | Firma Ed25519 del IESS | El enlace del sello o la huella SHA-256 del asunto | Válido → NO · falso → SÍ + I2/I4 · sin sello → deciden los indicios |

Cada resultado muestra «Lo que salió del equipo», construido con lo que de verdad se consultó.

## Requisitos técnicos
| Pieza | Requisito |
|---|---|
| App Android | Android 8 o superior, 64 bits (arm64), ~1 GB libre para el modelo (730 MB) |
| PC (web + IA local) | Windows 10/11, 8 GB de RAM, CPU x64; `servidor/iniciar_windows.bat` abre `http://localhost:8090` |
| Modelo | LFM2-1.2B afinado, GGUF Q4_K_M (~730 MB), corre en CPU sin GPU |
| SellaCorreo / Observatorio | Docker; 1 VM pequeña (probado en Oracle Cloud Always Free, ARM 4 OCPU / 24 GB) detrás de Cloudflare Tunnel |
| Sin conexión | Funciona: reglas e IA local siguen; solo se pierde la edad del dominio (RDAP) |

## Seguridad y datos
- El correo no sale del equipo; a internet sale solo el dominio o la huella del asunto.
- No se abren enlaces ni adjuntos; los enlaces se muestran como texto.
- Android: solo HTTPS; el servidor de IA remoto viene apagado (opt-in).
- Anonimización (cédula, RUC, teléfono, tarjeta, cuenta, correo) antes de cualquier envío; borrado al terminar.
- Alineado a LOPDP (minimización, consentimiento), ISO/IEC 27001:2022 y OWASP MASVS.

## Resultados y evidencia
| Prueba | Resultado |
|---|---|
| Correos de práctica P01–P05 (veredicto + conjunto exacto de indicios) | 5 de 5 (`docs/evidencia/pruebas_P01_P05.txt`) |
| Reglas frente a 100 correos del dataset | Exactitud 0,90 · recall de phishing 0,98 (`ml/reports/eval_reglas.json`) |
| Indicios (micro) frente al dataset | Precisión 0,82 · recall 0,53 → mejora prevista en el piloto |
| Accesibilidad | Pruebas automáticas de botones de 48 dp, contraste y letra grande |

## Camino a piloto (3 meses)
| Mes | Actividad |
|---|---|
| 1 | Seguridad de la Información del IESS revisa el código y la evaluación de impacto (LOPDP). Se conecta el reporte simulado a un buzón real de pruebas. Se pide a OpenPhish la licencia o permiso escrito (sus términos gratuitos no cubren uso institucional) o se cambia por una lista propia del IESS |
| 2 | Piloto cerrado: ~100 colaboradores y ~100 jubilados voluntarios. El IESS empieza a sellar con SellaCorreo los correos de una tipología (por ejemplo, avisos de pensión) |
| 3 | Medición, ajuste del léxico y del modelo con los casos reales reportados, y decisión de ampliar |

**Métricas del piloto:** tasa de reporte de correos sospechosos, % de clics en simulacros éticos (antes/después),
falsos positivos reportados por los usuarios, tiempo hasta el reporte y uso del aula.

## Costo estimado del piloto
| Concepto | Estimación |
|---|---|
| IA | 0 por consulta: corre en el celular o en la PC del usuario |
| Servidor (SellaCorreo + Observatorio) | Nube gratuita o 1 VM institucional pequeña existente |
| Licencias de software | 0: todo el software usado es de código abierto (ver «Fuentes y licencias» en `DOCUMENTACION_RETO.md`); a confirmar solo OpenPhish |
| Personas | El equipo del IESS que administre el sello y atienda los reportes |

*Cifras orientativas: el costo real depende de la infraestructura que asigne el IESS.*

## Encaje institucional
Apoya la cultura de seguridad del IESS: concientiza (aula, robot), detecta (indicios), canaliza el reporte a
Seguridad de la Información y da al Instituto una forma de firmar sus correos para que los afiliados distingan
los verdaderos de los falsos.

Más detalle: `DOCUMENTACION_RETO.md` (requisitos, rúbrica, IA declarada, licencias) y `ARQUITECTURA.md`.
