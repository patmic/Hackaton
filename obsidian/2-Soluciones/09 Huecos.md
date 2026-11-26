---
tags: [soluciones, huecos, vacios, preguntas-abiertas]
fuente: "[[Mapa de soluciones completo]]"
fecha: 2026-11-25
---

↑ [[Indice Soluciones]]

# 09 Huecos

## En pocas palabras
- Los huecos del mapa coinciden con el vector principal del IESS.
- Hueco central: nadie ha evaluado una intervención contra la entrega presencial de la clave a un ayudante o tramitador.
- Segundo hueco: el servidor cooptado con permisos de modificación; la única evidencia interna fuerte trata de curiosidad sobre expedientes clínicos.
- Otros cinco vacíos: medición, canal (SMS, español y kichwa), migrantes, E4 y lo jurídico y de datos internos.

## Matriz de eslabón por población
Cada celda muestra la mejor opción disponible con su nivel de evidencia, o «hueco» cuando ninguna fuente aporta una solución evaluada. «-»: celda vacía en el informe.

| Eslabón | J jubilados urbanos | C campesinos y kichwa | M migrantes | A afiliados activos | S/V servidores |
|---|---|---|---|---|---|
| E1 obtener la clave | Inoculación (A, solo correo); delegación acotada (C/D). **Hueco: entrega presencial al ayudante sin evaluar** | IVR narrativo (A-/B, Uganda). **Hueco: nada en kichwa** | Palabra clave (D); bot oficial (B de adopción) | DMARC, remitentes (B); passkeys (D) | Botón de reporte (A) |
| E2 cambiar contacto o cuenta | Aviso al canal anterior (D), enfriamiento (B agregado), ventanilla (B) | Aviso por SMS o voz (D). **Hueco: el canal anterior puede ser un celular compartido (inferencia)** | **Hueco: ninguna verificación remota evaluada que no exija agencia** | Autenticación por riesgo (C) | Doble control (D) |
| E3 préstamo o fondos | Bloqueo por defecto (B, Brasil); candado (B, otro dominio) | **Hueco: sin datos de exposición ni de desbloqueo accesible** | **Hueco: desbloqueo reforzado sin presencia física** | Aprobación ligada a la acción (D); reglas de secuencia (B) | Regla de cuenta compartida (D) |
| E4 la víctima se entera tarde | Persona de confianza (C), kill switch (D), reembolso (B contradictorio) | Monitores (C). **Hueco: sin canal de alerta temprana evaluado** | Contacto de confianza en el exterior (D) | Notificaciones (D) | - |
| EI riesgo interno | - | - | - | - | Sanitario: aviso inmediato (A, un ensayo). **Hueco: nada evaluado para el servidor cooptado que cambia cuentas o registra aportes** |

## Los dos huecos principales
| Hueco | Por qué es hueco | Qué hay, y con qué nivel |
|---|---|---|
| El «ayudante» presencial | El vector documentado del IESS es la clave entregada a un familiar, un cibercafé o un tramitador. Ningún ensayo de inoculación cubre ese escenario (los de AARP son de correo, SMS y cartas) | La delegación acotada y el contacto de confianza lo atacan de raíz, pero no tienen ninguna cifra de uso ni de efecto, ni en Brasil, ni en el NHS, ni en FINRA |
| El servidor cooptado con permisos de modificación | La única evidencia fuerte del lado interno (el aviso de esa noche) se refiere a la curiosidad sobre expedientes clínicos, no a funcionarios que cambian cuentas o registran aportes falsos para redes externas | El honeytoken y el canal de casi-fraude apuntan a ese problema, pero son nivel D |

## Otros cinco vacíos
| Vacío | Detalle | Fuente |
|---|---|---|
| Medición | Ninguna campaña latinoamericana publica su efecto; ningún regulador aísla el efecto del enfriamiento, del kill switch o de Money Lock; las cifras brasileñas vienen del sector bancario | Informe |
| Canal | El único ensayo grande de inoculación no encontró efecto en SMS, canal dominante en Ecuador junto con WhatsApp. No hay benchmarks públicos de LLM para detectar estafas en español ni en kichwa. La detección de Google en el Galaxy S26 está limitada a hablantes de inglés en EE. UU. | [Android Authority](https://www.androidauthority.com/google-scam-detection-samsung-galaxy-s26-3643942/) |
| Migrantes | El enfriamiento, el bloqueo por defecto y el desbloqueo presencial castigan justo sus trámites remotos; ninguna fuente ofrece una alternativa evaluada | Informe |
| E4 | Casi todo el mapa actúa antes del daño; solo el reembolso (PSR, INSS) atiende a la víctima que sigue pagando cuotas, con evidencia contradictoria y costo alto | Informe |
| Jurídico y de datos internos | Ver tabla siguiente | Informe |

## Lo que no se verificó o no se obtuvo
| Pendiente | Estado |
|---|---|
| Legalidad en Ecuador de los sorteos institucionales | **Sin verificar** |
| Legalidad de los registros señuelo | **Sin verificar** |
| Legalidad de la inmunidad por reportar | **Sin verificar** |
| Texto oficial de la Res. 2026-0009-R | No obtenido |
| Texto oficial de la norma de biométricos | No obtenido |
| Si el BIESS exige que la cuenta sea del titular | No se sabe |
| Si hay espera entre cambio de datos y préstamo | No se sabe |
| Estado de DMARC de iess.gob.ec | No se sabe |
| Casos de deepfake contra afiliados o personal del IESS | Faltan |
| Evidencia sobre palabras clave familiares, tarjetas o adhesivos | Falta |

## Relacionadas
[[08 Donde convergen las vertientes]] · [[10 Criterios de decision]] · [[10 Preguntas abiertas]]
