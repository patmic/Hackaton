# Quién es más vulnerable al fraude y a los riesgos digitales en el IESS

Resumen legible de `vulnerabilidad_datos.json`. Fecha de corte: 25-11-2026. No se hicieron búsquedas web: todas las cifras salen de las notas de `research_notes/Cultura de ciberseguridad IESS/` y del informe `reports/Cultura de ciberseguridad IESS.md`. No se interpolaron valores. Los únicos números derivados son restas o complementos de cifras de la misma fuente y van marcados como «calculado». Cuando dos fuentes discrepan se usa la cifra del informe y la discrepancia queda anotada.

**Eslabones de la cadena de fraude** (según el informe «Mapa de soluciones Reto 1 IESS»):

| Eslabón | Qué ocurre |
|---|---|
| E1 | Obtener la clave (prestada, phishing o abuso) |
| E2 | Cambiar correo, teléfono o cuenta bancaria |
| E3 | Pedir un préstamo quirografario BIESS o fondos de reserva |
| E4 | La víctima se entera tarde y sigue pagando |
| EI | Riesgo interno de servidores con permisos |

> **Aviso sobre el Venn.** El diagrama es conceptual. No existe ningún dato oficial cruzado (por ejemplo, jubilados campesinos indígenas sin smartphone): cada factor se publica por separado, con universos, años y definiciones distintos. La ubicación de los perfiles en las intersecciones es un juicio cualitativo basado en mecanismos y casos citados. El tamaño de los círculos y de las regiones **no está a escala**. Los tamaños de perfil corresponden al universo más cercano que tiene cifra y no se pueden sumar, porque se solapan.

## 1. Factores de vulnerabilidad (círculos del Venn)

| id | Factor | Cifra clave | Por qué aumenta el riesgo (mecanismo) | Fuente |
|---|---|---|---|---|
| `edad` | Edad avanzada (65+) | 1.520.590 personas de 65+ (9 % en 2022, 6,2 % en 2010); 30,2 % con dificultad funcional; 30 % de las estafas digitales reportadas frente a 9 % de la población | Su ingreso fijo garantiza el préstamo quirografario; la susceptibilidad a estafas se asocia con deterioro cognitivo incipiente (Rush Memory and Aging Project, el doble de riesgo de deterioro cognitivo leve o Alzheimer), con la soledad y con la falta de apoyo; menos del 25 % hace transacciones en línea, así que recibe el mensaje pero no puede comprobarlo; en el Reino Unido el 87 % se cree capaz de detectar fraudes y solo el 20 % los conoce | [INEC Censo 2022](https://www.ecuadorencifras.gob.ec/mas-de-2-700-personas-son-centenarias-en-ecuador-segun-el-censo/); [Asobanca vía Vistazo](https://www.vistazo.com/negocios/sectores/2026-07-08-adultos-mayores-ecuador-excluidos-servicios-financieros-digital-como-integrarlos-ecuador-CB11103504); AARP; UF; HRS; UK Finance |
| `brecha` | Brecha digital: sin smartphone propio o sin habilidad para verificar | 57,7 % tiene smartphone frente a 77,2 % que usa internet (2024); 38 % de hogares sin educación formal tiene internet; el indicador oficial excluye a los mayores de 49 | Quien no puede hacer el trámite solo presta la clave, que es de un solo factor. Fondos de Terceros atribuye los robos de fondos de reserva a «ayudantes» que cambian clave, teléfono y cuenta, y a una jubilada un cibercafé le sacó USD 14.000. El 76,8 % del uso de internet es comunicación, así que el estafador llega por el chat. Activa E1 | [INEC TIC 2024](https://www.ecuadorencifras.gob.ec/tecnologias-de-la-informacion-y-comunicacion-tic-2024/); [EPN vía Primicias](https://www.primicias.ec/sociedad/ecuador-acceso-internet-brecha-digital-usos-informe-politecnica-113472/); [Expreso 12-05-2025](https://www.expreso.ec/actualidad/economia/jimena-naranjo-iess-lanzara-nuevo-sistema-suplantacion-242078) |
| `precariedad` | Precariedad económica e informalidad | 24 % de pobreza, 10,4 % de pobreza extrema, 35,9 % de empleo adecuado (27,9 % en mujeres), 54,5 % de informalidad (jun-2025); pensión campesina de USD 121,75 | La restricción de crédito predice la victimización con independencia de la educación financiera (China, World Bank). La volatilidad del ingreso y la fragilidad financiera elevan el fraude (CFPB, HRS). En Ecuador abundan los créditos falsos (134 entidades), los bonos falsos y el chulco ligado a la extorsión | [Bloomberg Línea / INEC](https://www.bloomberglinea.com/latinoamerica/ecuador/desempleo-en-ecuador-llega-al-35-en-junio-como-esta-el-empleo-adecuado-y-el-subempleo/); World Bank Blog; El Comercio |
| `rural_indigena` | Ruralidad, pueblo indígena y baja alfabetización | Internet en el 58,7 % de los hogares rurales frente al 76,6 % de los urbanos; analfabetismo indígena del 11,9 % frente al 3,7 % nacional; analfabetismo digital indígena del 10 %; 342.612 jefes de familia en el SSC | Los materiales escritos en castellano los excluyen. La lejanía de agencias los empuja hacia intermediarios y hacia estafas presenciales, como los falsos médicos detenidos en Alausí y Quito en 2026. Como análogo, en Australia las pérdidas de Primeras Naciones crecieron un 73,1 % | [INEC analfabetismo](https://www.ecuadorencifras.gob.ec/reduccion-del-analfabetismo-en-ecuador-mas-de-199-000-personas-libres-de-esta-condicion-desde-2010/); EPN; IESS; NASC |
| `lejania` | Lejanía institucional: migrantes y trámites a distancia | 25.099 voluntarios en el exterior (+15,9 %); unos 8.000 trámites a distancia en 2025; remesas de USD 7.729 M | Hacen a distancia justo las operaciones que preceden al fraude (E2). Ya hubo retiros de cesantía con documentos falsos. Sus familias quedan expuestas al «familiar en apuros» (inferencia sin cifra). Los múltiples canales oficiales son fáciles de imitar | [IESS, Rendición de Cuentas 2025](https://www.iess.gob.ec/documents/10162/39150634/Informe+Rendicion+de+Cuentas+2025); [Primicias](https://www.primicias.ec/sociedad/iess-extranjero-fraude-documentos-falsos-fondos-cesantia-ecuador-104801/); Lupa Media |
| `interno` | Exposición interna: servidores con permisos o bajo presión | 33.545 servidores (27 % médicos); capacitación de alrededor del 24 % (cálculo propio); 14 % de 156.170 contraseñas filtradas son del gobierno | Los roles que modifican datos pueden ser cooptados: dos funcionarios en 2024 y una funcionaria con aportes falsos en 2025. Las credenciales se filtran, el entorno hospitalario sufre extorsión, y la revelación de bases de datos pasó de 29 a 45 denuncias. Es EI, que habilita E2 y E3 | El Comercio; IESS; [EcuCERT 2025](https://www.ecucert.gob.ec/wp-content/uploads/2026/01/estado-de-ciber-seguridad.pdf); Expreso; Primicias |

## 2. Perfiles ubicados en las intersecciones

| id | Perfil | Factores | Tamaño aprox. (universo con cifra) | Eslabones | Nivel | Casos documentados |
|---|---|---|---|---|---|---|
| `jubilado_urbano_biess` | Jubilado urbano por vejez con préstamo BIESS | edad + brecha | 575.109 prestaciones de vejez SG (no personas) | E1-E4 | **muy alto** | Guayaquil 2024 (≥20 casos, 3 IP, 2 funcionarios); deudas de USD 9.000-30.550; SMS de «reembolso» de 2026 ([Expreso](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html)) |
| `jubilado_delega_cibercafe` | Jubilado sin smartphone que delega en cibercafé, tramitador o familiar | edad + brecha + precariedad | Sin cifra (más de 800.000 adultos mayores excluidos de lo digital, como indicio) | E1-E4 | **muy alto** | Jubilada de 78 años: USD 14.000 sacados en un cibercafé; cédula vendida por USD 80 que acabó en una deuda de USD 9.000 ([Expreso](https://www.expreso.ec/actualidad/economia/iess-biess-investigan-fraude-detectan-funcionarios-ips-implicados-estafas-jubilados-224394.html)) |
| `jubilado_campesino_indigena` | Jubilado del SSC, rural e indígena | edad + brecha + precariedad + rural_indigena | 144.176 prestaciones de vejez campesina (sin desagregado étnico) | E1, E4 | **muy alto** | Falsos médicos o funcionarios detenidos en Quito y Alausí (2026); bonos falsos por WhatsApp (2026) |
| `adulto_mayor_dificultad_funcional` | 80+ con dificultad visual, auditiva o cognitiva | edad + brecha | 459.218 personas de 65+ con dificultad (toda la población, no solo IESS) | E1, E2, E4 | **muy alto** | Portabilidad no autorizada a un hombre de 80 años (2026); red del «cambiazo» |
| `pensionista_montepio` | Pensionista de montepío (sobreviviente) | edad + precariedad | 170.037 prestaciones de montepío SG | E1-E4 | alto | Ninguno específico hallado |
| `padre_madre_de_migrante` | Adulto mayor con hijos migrantes | edad + lejania | Sin cifra | E1 | alto | Ninguno en Ecuador (perfil inferido) |
| `migrante_voluntario_exterior` | Migrante afiliado voluntario | lejania | 25.099 | E1-E4 | alto | Retiro de cesantía con documentos falsos ([Primicias](https://www.primicias.ec/sociedad/iess-extranjero-fraude-documentos-falsos-fondos-cesantia-ecuador-104801/)) |
| `afiliada_tnrh` | Afiliada del Trabajo No Remunerado del Hogar | precariedad + brecha | 264.931 | E1 | alto | Suplantadores que engañan a beneficiarios del bono; bonos falsos |
| `afiliado_joven_informal` | Afiliado joven urbano con empleo precario | precariedad | 892.082 afiliados de hasta 30 años | E1 | medio | Cargos públicos falsos con el nombre del IESS (2026); 134 entidades de crédito falso |
| `afiliado_fondos_reserva` | Afiliado activo que pide ayuda para retirar fondos | brecha + precariedad | Más de 500.000 que retiraron en 2024 | E1-E4 | alto | Robos de fondos de reserva por «ayudantes» (2025) |
| `servidor_ventanilla_permisos` | Servidor de ventanilla, préstamos o historia laboral | interno | Sin cifra de roles (nómina total 33.545) | EI, E2, E3 | **muy alto** | Dos funcionarios IESS/BIESS (2024); funcionaria con aportes falsos (2025) |
| `personal_sanitario_hospital` | Médico, enfermera o administrativo de hospital | interno | ≈9.057 médicos (27 % de 33.545, cálculo propio) | EI, E1 | alto | HTMC: corrupción, sabotaje, extorsión (2026); ransomware en el sector salud (EcuCERT 2025) |

Justificación de los niveles «muy alto». El jubilado urbano concentra el fraude grave documentado. El jubilado que delega une la edad con una credencial prestada por necesidad. El campesino indígena acumula cuatro factores con la pensión más baja. El 80+ con dificultad funcional presenta el mecanismo más fuerte en la literatura y, además, pierde la línea móvil, que es el canal de aviso. El servidor con permisos es vector: un solo servidor cooptado afecta a muchos afiliados. En el JSON, cada perfil tiene sus amenazas, su justificación completa y la URL de cada caso.

## 3. Series para gráficas (56)

### Brecha digital

| id | Título | Tipo | Datos | Fuente |
|---|---|---|---|---|
| `tic_acceso_uso_2022_2024` | Acceso y uso TIC 2022-2024 | línea (4 subseries) | Uso de internet 69,7 / 72,7 / 77,2; hogares con internet 60,4 / 62,2 / 66,0; celular activado 58,8 / 59,6 / 61,3; smartphone 52,2 / 55,6 / 57,7 (%) | [INEC TIC 2024](https://www.ecuadorencifras.gob.ec/tecnologias-de-la-informacion-y-comunicacion-tic-2024/) |
| `tic_analfabetismo_digital_2022_2024` | Analfabetismo digital (15-49 años) | línea | 8,2 / 7,6 / 5,4 % | INEC TIC 2024 |
| `hogares_internet_area_2025` | Hogares con internet: nacional, urbano y rural | barras | 71,3 / 76,6 / 58,7 % | [EPN vía Primicias](https://www.primicias.ec/sociedad/ecuador-acceso-internet-brecha-digital-usos-informe-politecnica-113472/) |
| `hogares_internet_quintil_2025` | Por quintil | barras | Más rico 84,37 %; más pobre 50,87 % | EPN |
| `hogares_internet_educacion_2025` | Por educación | barras | Superior 88,57 %; sin educación formal ≈38 % | EPN |
| `hogares_internet_2013_2025` | Hogares con internet 2013 y 2025 | línea | 28 % y 71,3 % | EPN |
| `uso_internet_finalidad_2025` | Para qué se usa internet | proporción | Comunicaciones 76,8; entretenimiento 13; educación 6,9; trabajo 1,9; información 1,1 % | EPN |
| `analfabetismo_digital_grupos_2025` | Analfabetismo digital en grupos rezagados | barras | Sin educación formal 11,1 %; indígena 10 % | EPN |
| `adultos_mayores_dispositivos` | Adultos mayores que usan tableta o computadora | barras | 5,5 % y 11,5 % (**no verificada**) | Revista del Consejo de Comunicación |

### Demografía, etnia y edad

| id | Título | Tipo | Datos | Fuente |
|---|---|---|---|---|
| `analfabetismo_autoidentificacion_2010_2022` | Analfabetismo por etnia, 2010 y 2022 | barras agrupadas | Nacional 6,8 → 3,7; indígena 20,4 → 11,9; montubia 12,9 → 8,4; afro 7,6 → 4,3 % | [INEC](https://www.ecuadorencifras.gob.ec/reduccion-del-analfabetismo-en-ecuador-mas-de-199-000-personas-libres-de-esta-condicion-desde-2010/) |
| `poblacion_65_proporcion_2010_2022` | 65+ como % de la población | línea | 6,2 % y 9,0 % | INEC / Primicias |
| `adultos_mayores_dificultad_funcional_2022` | 65+ con dificultad funcional | proporción | 30,2 % (459.218) / 69,8 % (complemento calculado) | INEC |
| `adultos_mayores_sexo_2022` | 65+ por sexo | proporción | Mujeres 54 % / hombres 46 % | INEC |

### Afiliados y pensionistas del IESS

| id | Título | Tipo | Datos | Fuente |
|---|---|---|---|---|
| `afiliados_regimen_dic2025` | Afiliados por régimen, dic-2025 (11 categorías) | barras | Privado 2.071.196; público 642.386; SSC 342.612; independientes 291.884; TNRH 264.931; voluntarios en Ecuador 219.465; en el exterior 25.099; jubilados activos SSC 16.319; pasantes 11.355 + 8.295; artistas 541 | [IESS, Rendición de Cuentas 2025](https://www.iess.gob.ec/documents/10162/39150634/Informe+Rendicion+de+Cuentas+2025) |
| `afiliados_regimen_2024_2025` | Variación dic-2024 → dic-2025 (8 regímenes × 2) | barras agrupadas | Exterior +15,9 %; voluntarios Ecuador +5,5 %; TNRH −1,6 %; jubilados activos SSC −10,4 % | IESS |
| `afiliados_edad_sep2026` | Afiliados por edad (tramos incompletos) | barras | ≤30: 892.082; 31-40: 1.026.532; 41-50: 827.763; 71-80: 28.821 | [Primicias](https://www.primicias.ec/economia/iess-afiliacion-afiliados-jovenes-empleo-septiembre2026-seguro-social-134736/) |
| `afiliados_activos_sexo_dic2025` | Afiliados activos por sexo | proporción | 1.864.237 hombres / 1.670.915 mujeres | IESS IE-DNAC-DP-45 |
| `pensiones_tipo_dic2025` | Prestaciones por tipo (9) | barras | Vejez SG 575.109; montepío SG 170.037; vejez campesina 144.176; ... (total 949.307) | IESS |
| `pension_promedio_tipo_2025` | Pensión promedio | barras | Discapacidad 745,98; vejez SG 632,23; montepío 302,59; vejez campesina 121,75 USD | IESS |
| `jubilacion_vejez_cobertura_provincia_2024` | % de 65+ con jubilación IESS, por provincia | barras | Pichincha 61; Galápagos 50; Azuay 36; Pastaza 33; Guayas 32 % | kchcomunicacion / La Hora; El Universo |
| `poblacion65_vs_jubilados_pichincha_guayas_2024` | 65+ frente a jubilados | barras agrupadas | Pichincha 296.512 / 182.063; Guayas 367.830 / 116.637 | kchcomunicacion / La Hora |
| `beneficiarios_iess_composicion_2025` | Composición de los beneficiarios | proporción | Activos 53,33; dependientes 34,30; pensionistas 12,37 % | IESS |
| `montos_prestamos_fraudulentos_jubilados` | Deuda por víctima en casos documentados | barras | 30.550; 25.000; 20.000; 14.000; 9.000 USD | [Expreso](https://www.expreso.ec/actualidad/economia/suplantados-y-endeudados-los-jubilados-esperan-justicia-267075.html) |

### Fraude y delitos en Ecuador

| id | Título | Tipo | Datos | Fuente |
|---|---|---|---|---|
| `denuncias_delitos_informaticos_financieros_2023_2024` | Delitos informáticos de clientes financieros | línea | 3.644 y 3.913 | [Fiscalía vía Primicias](https://www.primicias.ec/economia/tarjetas-credito-delitos-informaticos-estafas-cuentas-bancos-98471/) |
| `delitos_informaticos_tipo_2024` | Por artículo del COIP | barras | Art. 190: 3.696; art. 231: 171; art. 229: 45; art. 230: 1 | Fiscalía vía Primicias |
| `revelacion_bases_datos_2023_2024` | Revelación de bases de datos | línea | 29 y 45 | Fiscalía vía Primicias |
| `apropiacion_fraudulenta_2024_2025` | Apropiación fraudulenta, 2024 frente a ene-nov 2025 | barras | 3.701 y 4.733 | [El Universo](https://www.eluniverso.com/opinion/editoriales/robos-digitales-una-alerta-en-ecuador-nota/) |
| `ciberdelitos_composicion_2022_2025` | Ciberdelitos, ene-2022 a may-2025 | proporción | Apropiación 11.833; estafa electrónica 4.567; otros 4.202 (calculado) | Expreso |
| `canales_estafas_ia_2026` | Canales de estafas con IA | barras | WhatsApp 43 %; SMS 40 % | [KCH FM](https://kchcomunicacion.com/2026/09/15/whatsapp-y-sms-las-puertas-de-entrada-de-las-estafas-con-ia-en-ecuador/) |
| `asobanca_estafas_vs_poblacion_adultos_mayores` | Adultos mayores: estafas frente a población | barras | 30 % frente a 9 % | Asobanca vía Vistazo; INEC |
| `adultos_mayores_finanzas_digitales` | Usan productos financieros frente a excluidos de lo digital | barras | ≈1.020.000 y más de 800.000 | Vistazo |

### Extorsión, violencia y contexto económico

| id | Título | Tipo | Datos | Fuente |
|---|---|---|---|---|
| `extorsion_denuncias_fiscalia` | Extorsión (Fiscalía) | línea, años no consecutivos | 2019: 1.616; 2024: 23.080; 2025: 16.130 | [Primicias](https://www.primicias.ec/seguridad/extorsiones-dispararon-ecuador-ultimos-seis-anos-llegaron-16-130-casos-2025-estudio-132905/); InSight Crime |
| `extorsion_denuncias_policia` | Extorsión (Policía) | línea | 2023: 13.627; 2024: 14.579 | InSight Crime (ES) |
| `extorsion_alertas_ecu911_ene_may` | Alertas ECU 911 (ene-may) | barras | 1.699 (2023) y 3.092 (2025) | Primicias |
| `homicidios_tasa_2023_2025` | Homicidios por 100.000 habitantes | línea | 47,25 / 38,8 / 50,91 | El Comercio |
| `pobreza_empleo_2024_2025` | Pobreza, pobreza extrema, empleo adecuado e informalidad, jun-2024 y jun-2025 | barras agrupadas | 25,5 → 24,0; 10,6 → 10,4; 35,4 → 35,9; 53,5 → 54,5 % | [Bloomberg Línea / INEC](https://www.bloomberglinea.com/latinoamerica/ecuador/desempleo-en-ecuador-llega-al-35-en-junio-como-esta-el-empleo-adecuado-y-el-subempleo/) |
| `empleo_adecuado_sexo_2025` | Empleo adecuado por sexo | barras | Hombres 41,5 %; mujeres 27,9 % | Bloomberg Línea |
| `remesas_2024_2025` | Remesas | línea | 6.539,8 y 7.729 M USD | El Comercio |
| `deuda_estado_iess` | Deuda del Estado con el IESS | línea | 24.233 (nov-2024) y 27.389 M USD (may-2025) | Primicias; El Diario |
| `aporte_estatal_solicitado_vs_asignado` | Aporte estatal: solicitado frente a asignado | barras agrupadas | 2025: 4.469 / 2.560; 2026: 3.448,1 / 2.684 M USD | Primicias; El Diario |

### Entorno técnico (EcuCERT, proveedores e índices)

| id | Título | Tipo | Datos | Fuente |
|---|---|---|---|---|
| `ecucert_ip_incidentes_2024_2025` | IP con incidentes | barras | 70.975 y 97.250 | [EcuCERT 2025](https://www.ecucert.gob.ec/wp-content/uploads/2026/01/estado-de-ciber-seguridad.pdf) |
| `ecucert_ip_vulnerabilidades_2024_2025` | IP con vulnerabilidades | barras | 344.339 y 228.583 | EcuCERT |
| `ecucert_incidentes_tipo_2025` | Incidentes por tipo (top 5) | proporción | Sinkhole HTTP 37; scanners 28; malware 14; Pass_LEAK 11; Sinkhole DNS 4 % | EcuCERT |
| `ecucert_filtraciones_contrasenas_sector_2025` | Contraseñas filtradas por sector | proporción | Educación 86; gobierno 14; FF. AA. 1 % | EcuCERT |
| `ecucert_alertas_phishing_tipo_2025` | Alertas de phishing según gancho | proporción | Suplantación 90 %; falso beneficio 10 % | EcuCERT |
| `ecucert_sistemas_vulnerables_ciudad_2025` | Sistemas vulnerables por ciudad | barras | Quito 42; Guayaquil 20; Cuenca 8; Ambato 6; Machala 4; Samborondón 4 % | EcuCERT |
| `kaspersky_ransomware_latam` | Ransomware LatAm (ago-2024 a jun-2025) | barras | Brasil 549.000 ... Ecuador 37.000 (4.º) | Kaspersky |
| `kaspersky_moviles_latam` | Amenazas móviles LatAm | barras | Brasil 1,8 M; México 835.000; Ecuador 402.000 | Kaspersky vía ITSitio |
| `ncsi_ecuador_2022_2026` | NCSI de Ecuador | línea | 53,25 (puesto 67, 2022) y 40,83 (puesto 100, mar-2026) | NCSI |

### Servidores del IESS

| id | Título | Tipo | Datos | Fuente |
|---|---|---|---|---|
| `capacitacion_seguridad_vs_nomina` | Capacitados frente a nómina | barras | 33.545 / más de 8.000 / 426 (cobertura ≈24 %, cálculo propio) | IESS; El Comercio |
| `personal_htmc_composicion` | Personal del HTMC (2.559) | proporción | Enfermería 38; médicos 23; administrativo 23; diagnóstico 16 % | Primicias |

### Comparación internacional (pérdidas y víctimas por edad o perfil)

| id | Título | Tipo | Datos | Fuente |
|---|---|---|---|---|
| `ic3_perdidas_60mas_2023_2024` | EE. UU.: pérdidas de personas de 60+ | línea | Más de 3.400 (2023) y 4.885 M USD (2024, +43 %) | [FBI IC3 2024](https://ic3.gov/AnnualReport/Reports/2024_IC3Report.pdf); FBI Elder Fraud 2023 |
| `ic3_cripto_60mas_vs_poblacion_2024` | 60+: pérdidas cripto frente a población | barras | ≈30 % frente a ≈17 % | IC3 vía Decrypt / AARP |
| `australia_perdidas_grupos_2024` | Australia: 65+ y Primeras Naciones | barras | A$99,6 M y A$6,5 M (+73,1 %) | [NASC](https://www.nasc.gov.au/news/australians-better-protected-as-reported-scam-losses-fell-by-almost-26-per-cent) |
| `take_five_mayores65_confianza_vs_conocimiento` | Reino Unido: 65+ que confían frente a los que conocen | barras | 87 % y 20 % | UK Finance |
| `brasil_inss_afectados_descuentos` | Brasil: afectados INSS | barras | Al menos 9 M con descuento; 6.362.898 impugnaciones; 1,8 M con devolución | Agência Brasil |

## 4. Discrepancias entre fuentes

| Dato | Cifra usada (informe) | Alternativa | Comentario |
|---|---|---|---|
| Total de afiliados, dic-2025 | 3.894.083 | 3.535.152 «afiliados activos» | La segunda probablemente excluye a los semicontributivos |
| Pensionistas | 949.307 prestaciones | Más de 706.320 jubilados y pensionistas (mar-2025) | Prestaciones de todos los seguros frente a personas del SG |
| Pobreza extrema, jun-2025 | 10,4 % | 10,45 % (Primicias); 8 % (vocera de Gobierno) | La cifra de la vocera no coincide con el INEC |
| Apropiación fraudulenta 2024 | 3.701 (El Universo) | 3.696 (Primicias, art. 190); 3.385 hasta oct-2024 | No está claro si 3.701 es el año completo |
| Extorsión 2024 | 23.080 (Fiscalía) | 14.579 (Policía) | Series distintas; 2025: 16.130 o 16.131 |
| IP con incidentes 2024-2025 | +34 % (infografía) | ≈37 % calculado | Porcentajes ambiguos en EcuCERT |
| IP con vulnerabilidades | −27 % (infografía) | ≈34 % calculado | Ídem |
| Deuda del Estado con el IESS | USD 27.389 M (IESS) | No conciliada con Finanzas | El MEF pide auditarla |
| Asobanca, 30 % | Sin año ni base | — | No se halló la fuente primaria |

## 5. Vacíos

- No hay uso de internet, smartphone ni WhatsApp para los 65+. El INEC no publica ese desagregado y los microdatos no se procesaron.
- No hay víctimas de fraude digital por edad en Ecuador (Fiscalía, Policía, Superintendencia de Bancos). El único dato por edad es el 30 % de Asobanca.
- No hay montos totales perdidos por fraude electrónico en Ecuador.
- Falta una cifra consolidada de fraudes contra afiliados y jubilados del IESS entre 2022 y 2026, y su resultado judicial.
- Falta la distribución por edad, sexo y zona de los jubilados del IESS, así como los tramos de 51 a 70 años de los afiliados.
- No se sabe cuántos afiliados del SSC son indígenas o hablan kichwa.
- Faltan el analfabetismo y la escolaridad de los 65+, la discapacidad total y en 65+ (CONADIS) y las tablas del UNFPA de 2025.
- No se ha medido el uso de intermediarios (cibercafés, tramitadores, familiares) por jubilados.
- Falta el número de hogares con adultos mayores y familiares migrantes. No hay cifras de la estafa del «familiar en apuros».
- Faltan cifras ecuatorianas de SIM swapping, toma de cuentas de WhatsApp y vishing.
- Falta el número de servidores con permisos de modificación de datos, así como cualquier encuesta de prácticas de seguridad del personal.
- No hay resultados ni línea base de las 8.000 capacitaciones de IESSEDUCA.
- Falta la serie de extorsión de la Fiscalía para 2020-2023.
- Faltan pérdidas por edad en otros países. Para Australia solo existe el grupo de 65+, y en Singapur el titular dice que los jóvenes fueron los más afectados en 2025, sin cifra en las notas.
- Los prestadores externos de salud (alerta de extorsión de oct-2026) no se incluyeron como perfil porque no encajan en los seis factores ni tienen cifra de tamaño.

## 6. Notas para graficar

- Las series con «serie» en los datos son **barras agrupadas** o **líneas múltiples**: `tic_acceso_uso_2022_2024`, `analfabetismo_autoidentificacion_2010_2022`, `afiliados_regimen_2024_2025`, `poblacion65_vs_jubilados_pichincha_guayas_2024`, `pobreza_empleo_2024_2025` y `aporte_estatal_solicitado_vs_asignado`. No hay series apiladas en sentido estricto.
- `extorsion_denuncias_fiscalia` tiene un hueco entre 2019 y 2024: no unir con línea continua.
- `afiliados_edad_sep2026` está incompleta: no presentarla como distribución.
- `adultos_mayores_dispositivos` no está verificada. `canales_estafas_ia_2026` tiene metodología desconocida.
- Las series internacionales (IC3, Australia, Take Five, Brasil) son de contexto y no deben mezclarse en el mismo eje con las de Ecuador.
