---
tags: [investigacion, marco-legal, egsi, lopdp, ciberseguridad]
fuente: "[[Informe completo]]"
fecha: 2026-11-25
---

↑ [[Indice Investigacion]]

# 04 Marco legal

## En pocas palabras
- El EGSI v3 ya encarga expresamente la cultura de seguridad al Oficial de Seguridad de la Información (art. 9).
- La LOPDP permite multar personalmente a los servidores públicos (1 a 20 SBU) y limita cómo se puede medir a las personas.
- La Ley de Ciberseguridad de 2026 eleva el estándar (ISO 27000, NIST, CSIRT, catálogo de servicios esenciales).
- Accesibilidad web, software libre y viabilidad técnica son obligaciones que condicionan cualquier proyecto público.

## Resumen por norma (tabla del informe)
| Norma | Qué exige o permite | Implicación para cualquier solución del Reto 1 (según el informe) |
|---|---|---|
| EGSI v3, arts. 5, 7 y 9 | Plan de concienciación y cultura a cargo del OSI; difusión a cargo del Comité; ciclo anual que empieza en enero | Debe alimentar los informes del OSI y del Comité y alinearse con el ciclo anual |
| LOPDP y resoluciones de la SPDP | Evaluación de impacto, privacidad desde el diseño, notificación en 5 días, multas personales a servidores | Minimizar datos, seudonimizar métricas, base legal para medir a los servidores, contenido sobre plazos legales |
| Ley de Ciberseguridad 2026 | Catálogo de servicios esenciales, CSIRT, ISO/NIST, pruebas autorizadas | Usar marcos ISO/NIST como referencia; cuidar cómo se define el reporte de incidentes al CSIRT |
| RTE INEN 288 y NTE INEN-ISO/IEC 40500 | Accesibilidad web obligatoria | Como mínimo WCAG 2.0 AA, y en la práctica WCAG 2.2 AA por el perfil de los usuarios |
| Código Ingenios (arts. 147-148), Decreto 1014, Acuerdo MINTEL-2022-0032 | Prelación del software libre, publicación del código, viabilidad técnica | Preferir licencias libres, definir la propiedad intelectual y prever el trámite ante el MIT |

## EGSI v3 (Acuerdo MINTEL-MINTEL-2024-0003)
Fuentes: [MINTEL, Acuerdo 2024-0003](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2024/04/Acuerdo-Nro.-MINTEL-MINTEL-2024-0003-Esquema-Gubernamental-Seguridad-de-la-Informacion-EGSI.pdf); [Instructivo GPR](https://www.gobiernoelectronico.gob.ec/wp-content/uploads/2024/03/INSTRUCTIVO-Creacion-del-Proyecto-Implementacion-EGSIV3-en-GPR.pdf).

| Elemento | Contenido |
|---|---|
| Alcance | Obligatorio para todo el sector público; basado en ISO/IEC 27001:2022 |
| Art. 9, núm. 6 (OSI) | «Elaborar y coordinar el Plan de concienciación en Seguridad de la Información» |
| Art. 9, núm. 7 (OSI) | «Fomentar la cultura de seguridad de la información en la institución» |
| Art. 7, núm. 8 (Comité de Seguridad de la Información) | «Promover la difusión»; el Delegado de Protección de Datos es miembro del comité |
| Informes | Semestrales a la máxima autoridad e informe anual de riesgos |
| Mejora continua | Proyecto que comienza en enero de cada año, con seguimiento en la herramienta GPR de MINTEL |

Lectura del informe: lo que produzca evidencia utilizable en esos informes tiene una vía institucional ya trazada.

## LOPDP y SPDP
Fuentes: [advise.ec](https://advise.ec/guias/ley-de-proteccion-de-datos-ecuador-lopdp/); [Pirani](https://www.piranirisk.com/es/hub-regulatorio/notificacion-vulneracion-datos-personales-ecuador-spdp).

| Elemento | Contenido |
|---|---|
| Datos del IESS | Salud y seguridad social a gran escala: categorías especiales (arts. 25 y 26) |
| Evaluación de impacto | Obligatoria (art. 42) |
| Privacidad desde el diseño | Art. 39 y Res. SPDP-SPD-2025-0040-R |
| Notificación de vulneraciones | Máximo 5 días por el sistema SISPDP; desde la reforma de mayo de 2026 también al CSIRT (Res. SPDP-SPD-2026-0040-R) |
| Sanciones a servidores públicos | 1 a 10 SBU por infracción leve; 10 a 20 SBU por infracción grave |

| La SPDP ya actúa | Detalle | Fuente |
|---|---|---|
| Multas a LigaPro y FEF (noviembre y diciembre de 2025) | Entre USD 95.502 y USD 259.644, por datos biométricos sin base legal clara, políticas de privacidad deficientes y metodología de riesgos | [SPDP, RES-SPDP-ICS-2025-0005](https://spdp.gob.ec/wp-content/uploads/2026/01/RESOLUCION-Nro.-RES-SPDP-ICS-2025-0005VF-of.pdf); advise.ec |
| Inteligencia artificial | Res. 2026-0009-R | Informe |
| Datos biométricos | Res. 2026-0039-R | Informe |
| Cláusulas contractuales | Res. 2025-0006-R | Informe |

Lectura del informe: medir el comportamiento individual de los servidores (resultados de simulaciones, perfiles de riesgo) es tratamiento de datos personales; requiere base legal, minimización y, con probabilidad, evaluación de riesgos. El argumento también juega a favor de la formación: cada servidor que trata datos responde personalmente.

## Ley de Ciberseguridad 2026
Ley Orgánica para el Fortalecimiento de la Ciberseguridad, Quinto Suplemento del RO 290, 22-05-2026 ([Lexis](https://www.lexis.com.ec/noticias/registro-oficial-del-dia-ley-organica-para-el-fortalecimiento-de-la-ciberseguridad); [dplnews](https://dplnews.com/entra-en-vigor-ley-de-ciberseguridad-en-ecuador/); [AENA](https://aena.com.ec/ecuador-aprueba-una-ambiciosa-ley-de-ciberseguridad-que-incorpora-la-educacion-digital-obligatoria/)).

| Elemento | Contenido |
|---|---|
| Catálogo | Crea el Catálogo Nacional de Servicios Esenciales e Infraestructura Crítica Digital |
| Instituciones | Fortalece al CSIRT y a MINTEL como rector |
| Estándares | Incorpora ISO 27000 y NIST |
| Reformas | LOPDP, LOTDA y COIP |
| COIP art. 232 | Deja de considerar delito las pruebas de penetración autorizadas |
| LOEI | Exige formación en seguridad digital en escuelas y universidades |
| **Sin confirmar** | No se sabe si el IESS figura en el catálogo ni si este ya se publicó; no se obtuvo el texto completo |

Antecedente: la Política Nacional de Ciberseguridad de 2021 dedica su pilar VII a la cultura y la educación ([AM 006-2021](https://www.telecomunicaciones.gob.ec/wp-content/uploads/2021/06/Acuerdo-No.-006-2021-Politica-de-Ciberseguridad.pdf)).

## Accesibilidad
Fuentes: [Oficio Ministerio de Gobierno](https://www.ministeriodegobierno.gob.ec/wp-content/uploads/downloads/2015/12/Oficio-Nro.-STD-STD-2015-4841-OF.pdf); [Scielo Senescyt](https://scielo.senescyt.gob.ec/pdf/catedra/v2n2/2631-2875-catedra-2-02-00055.pdf); [RISTI 2019](https://rua.ua.es/dspace/bitstream/10045/99754/1/2019_Campoverde-Molina_etal_RISTI.pdf).

| Norma o hecho | Detalle |
|---|---|
| NTE INEN-ISO/IEC 40500 (WCAG 2.0) | Adoptada en 2014 |
| RTE INEN 288 de accesibilidad web | Rige desde 2016 |
| Cumplimiento real | Bajo: un estudio de 2019 no encontró ninguno de 220 portales universitarios que cumpliera la norma |

## Software, contratación e interoperabilidad
| Norma | Contenido | Fuente |
|---|---|---|
| Código Ingenios, art. 148 | Prelación al software libre y al de valor agregado ecuatoriano | [Gobierno Electrónico, Decreto 1014](https://www.gobiernoelectronico.gob.ec/wp-content/uploads/2018/09/Decreto-Ejecutivo-N%C2%B0-1014-del-10-de-abril-del-2008.pdf); [SERCOP, Metodología VAE](https://portal.compraspublicas.gob.ec/sercop/wp-content/uploads/2020/09/Metodologia-_VAE_Software.pdf) |
| Código Ingenios, art. 147 | Obliga a publicar el código abierto que se contrate o desarrolle | Ídem |
| Decreto 1014 (2008) | Software libre como política pública | Ídem |
| Acuerdo MINTEL-2022-0032 | Todo proyecto de gobierno electrónico necesita aprobación de viabilidad técnica del ente rector; el trámite aparece ahora bajo el MIT | [gob.ec](https://www.gob.ec/regulaciones/norma-tecnica-regula-procedimiento-aprobacion-viabilidad-tecnica-proyectos-gobierno-electronico-autorizacion-criticidad-software-servicios-relacionados-al-software); [gob.ec MIT](https://www.gob.ec/mit/tramites/autorizacion-viabilidad-tecnica-adquisiciones-software-proyectos-gobierno-electronico-traves-sistema-especializado) |
| DINARP | Gobierna la interoperabilidad de los registros públicos: cualquier validación de identidad pasaría por esos servicios a través del IESS, no directamente desde un prototipo | [gob.ec/dinarp](https://www.gob.ec/dinarp/tramites/aprobacion-acceso-visualizacion-informacion-registros-publicos-traves-interoperabilidad) |

Contratación pública (ínfima cuantía, Ley de Integridad Pública): ver [[08 Vision PMI e ingenieria]].

## Relacionadas
[[08 Vision PMI e ingenieria]] · [[09 Criterios de diseno]] · [[10 Preguntas abiertas]]
