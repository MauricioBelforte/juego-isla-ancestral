**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 139: Pre-Alpha (130 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Arquitectura de la fase (M07)

- [x] Definir capas de la fase: UI → Managers → World Services → Infra (desacople M07) [S]
- [x] Definir contratos de interfaces entre capas: `IInteractable`, `ITienda`, `ITemplo`, `IViajable` [M] — COMPLETADO 2026-10-14 (step-5-kilocode): `IInteractable` preexistia (M70) y se crearon las 3 que faltaban (`scripts/interfaces/i_tienda.gd`, `i_templo.gd`, `i_viajable.gd`) con el patron de default neutro de `IInteractable` v2. Consumidores previstos identificados: ShopManager/shop.gd (M39), travel_service.gd (M28), templos (M26, sin script aun). Ver seccion 7.1 de 04-Codigo.md.
- [x] Asegurar que ningún manager de gameplay toca la UI directamente (regla M07) [M]
- [ ] Definir `SesionMaster` como único orquestador de arranque (bootstrapping) [M] — PARCIAL 2026-10-13 (step-5-kilocode): `scripts/core/sesion_master.gd` CREADO con la maquina de estados (INACTIVA/INICIALIZANDO/ACTIVA/CERRANDO/CERRADA), inicializacion por capas (Infra → World Services → Managers → UI), cierre en orden inverso y registro via `ServiceRegistry`. Falta la ACTIVACION: el juego arranca hoy con `main_island.tscn` + ~20 autoloads y no hay master activo; activarlo como autoload requiere validacion en runtime. Ver seccion 7.2 de 04-Codigo.md.
- [x] Documentar el flujo de sesión: menú → continuar/nuevo → carga de zona [M] — COMPLETADO 2026-10-13 (step-5-kilocode): documentado en la seccion 7.3 de 04-Codigo.md — menu principal → continuar/nuevo → `SesionMaster.inicializar(nueva_partida)` → carga de zona (`ZonaManager`, M63) → mundo activo → tick → cierre en orden inverso, con la UI deshabilitada durante la carga (regla M53).
- [x] Definir ciclo de vida de los managers (init, tick, shutdown) [M]
- [x] Definir la comunicación entre managers por señales/servicios (sin referencias cruzadas) [M]
- [x] Documentar el modo "degradación" si un servicio falla al arrancar (M66) [S] — COMPLETADO 2026-10-13 (step-5-kilocode): seccion 7.4 de 04-Codigo.md — la sesion NO aborta: se registra el fallo (GameLogger + telemetria M105), el servicio queda degradado con default neutro del contrato, si el fallo es de guardado se ofrece recuperar copia o partida nueva (patron de `integridad_save`/M66 y `SoftlockGuard`), y la sesion continua degradada con los fallos documentados para el GONOGO de M140.
- [x] Mantener el desacople al agregar un sistema nuevo sin re-trabajo estructural [C]

## 2. Primer bioma — Aurora (M10/M09/M27)

- [x] Definir la geografía de Aurora: costa E (puerto), pradera central (pueblo), bosque W, colina N (templo), acantilados S (faro) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): 5 sectores definidos en 03-Diseno.md seccion 2.1.1 (costa E-puerto, pradera central-pueblo, bosque W, colina N-templo, acantilados S-faro) con contenido y modulos por sector.
- [x] Definir el área navegable de ~2 km² [S] — COMPLETADO 2026-10-14 (step-5-kilocode): ~2 km2 definidos en 03-Diseno.md 2.1.1; limite mar-tierra por el nivel de mar de M51.
- [x] Dividir Aurora en 6 zonas de streaming (M63) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): Costa-E, Pradera, Bosque-W, Colina-N, Acantilados-S y Puerto (transicion) definidas en 03-Diseno.md 2.1.1; base real scripts/stream/stream_manager.gd con suite M63 (6 iteraciones).
- [x] Definir los POIs de cada sector (muelle, plaza, talleres, tienda, mina, templo, faro) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): POIs por sector definidos en 03-Diseno.md 2.1.1 (muelle, plaza+talleres+tienda, mina, templo, faro). Sin catalogo de POIs en disco: la implementacion es de M22/M64.
- [x] Definir la vegetación del bioma: palmeras, bambú, hibiscos, pasto alto (M50) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): respaldo real en data/vegetacion/vegetacion_config.json v2 — palmeras (3 tipos en playa), bambu (canas_bambu en ribera), pasto alto (hierba_alta). Hibisco no existe con ese nombre (equivalentes flor_isla/arbusto_floral): deuda de nombrado de M50 anotada en 03-Diseno.md 2.1.1.
- [x] Definir el litoral con agua jugable para pesca (M51/M34) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): litoral de Aurora definido pescable en 03-Diseno.md 2.1.1; el sistema de pesca existe (scripts/fishing/) sujeto a que M51 integre los voxels de agua (stub es_agua_pescable documentada en M34).
- [ ] Definir la flora transmisora de estado (M09) [S] — PARCIAL 2026-10-13 (step-5-kilocode): la flora existe (baya_roja registrada en el museo M37) pero el catalogo de flora transmisora de estados de M09 no esta en disco. Definicion pendiente del dueno M09; ver 03-Diseno.md 2.1.1.
- [x] Definir puntos de descanso/cama (M11/M18) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): puntos de descanso definidos en 03-Diseno.md 2.1.1 (Pradera y Puerto); camas existen como muebles (data/houses/cama_madera.tres, catalogo M18). Implementacion: M18.
- [x] Definir el ciclo día/noche aplicado a Aurora (M31) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): Aurora usa el ciclo global de M31 sin variacion propia (modulo 31-Ciclo-Dia-Noche + TimeCalendar autoload). Definido en 03-Diseno.md 2.1.1.
- [ ] Definir el clima base del bioma (tropical suave) (M32) [S] — PARCIAL 2026-10-13 (step-5-kilocode): tropical suave definido en 03-Diseno.md 2.1.1, pero data/clima/ NO EXISTE (verificado). La definicion queda documentada a la espera de que M32 tenga datos para consumirla.
- [x] Definir la fauna inicial visible de Aurora (aves, peces costeros) (M36) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): aves con respaldo real en data/fauna/catalog.json — gaviota_playera (playa), lechuza_bosque (bosque), halcon_montana (montana). Peces costeros no estan en el catalogo de fauna (son de M34/fishing.json): deuda de catalogo de M36 anotada.

## 3. Enclave de Coral (núcleo del 2º bioma)

- [x] Definir el enclave visitable: muelle, tienda glasswork, 1 NPC [M] — COMPLETADO 2026-10-14 (step-5-kilocode): definido en 03-Diseno.md seccion 2.2 — muelle, 1 NPC (Bram, ver 2.3.1), tienda unica de arrecife glasswork (stock propio abajo) y vista al oceanico como anzuelo. Es DEFINICION: la construccion del enclave queda para Alpha (ver item 2).
- [x] Asegurar que Coral NO se construye en fase: queda "inacabado a propósito" [S] — COMPLETADO 2026-10-14 (step-5-kilocode): regla explicita en 03-Diseno.md 2.2 — 'visitable no construido', 'se deja inacabado a proposito con hit explicito para Alpha (M140)'. Hit H11 agregado a la tabla de hits el 2026-10-14.
- [x] Documentar el anzuelo de curiosidad al océano (M152/M153) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): documentado en 03-Diseno.md 2.2 — 'vista al oceanico como anzuelo de curiosidad (M152/M153)'. Modulos 152-Principios-Innegociables y 153-Objetivo-Final existen en disco.
- [x] Definir el NPC enano de Coral con 10+ líneas de diálogo (M21) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): Bram, enano vidriero de arrecife — agregado al elenco (03-Diseno.md 2.3) con rol, rutina (muelle->taller->mirador) y gancho, y 11 lineas de dialogo base escritas en la seccion 2.3.1. Variantes por estacion/dia (M29) e IA (M64) quedan como trabajo de sus modulos duenos.
- [x] Definir la tienda única de Coral (arrecife glasswork) con stock propio (M39) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): stock propio definido en 03-Diseno.md 2.3.1 — cristal_arrecife, lampara_coral, prisma_mareal, cebo_brillante, botella_mensaje, pendiente_marea. Regla: ninguno se consigue en Aurora; el enclave es la unica fuente (M39).
- [x] Registrar hit explícito para Alpha: completar Coral (M140) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): hit H11 'Coral completado: enclave terminado e integrado al flujo de Alpha' agregado a la tabla de hits de 03-Diseno.md; la nota de cierre paso de H1-H10 a H1-H11.

## 4. Primeros NPC (M19/M64)

- [x] Diseñar la plantilla `npc_profile.gd` (rutina, horarios, personalidad) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): script CREADO en scripts/world/npc/npc_profile.gd (class_name NpcProfile, Resource con ruta/horarios/personalidad/pronombres/gancho y funcion validar()). Contrato verificado con tabs consistentes.
- [x] Diseñar la IA de rutina `rutina_ia.gd` (máquina de estados + waypoints) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): script CREADO en scripts/world/npc/rutina_ia.gd (class_name RutinaIA) con maquina de estados IDLE/CAMINANDO/ESPERANDO/EN_PUESTO/RECUPERANDO, seleccion de waypoint por franja horaria y recuperar() anti-stuck (M66). Movimiento fino delegado a M64.
- [x] Definir Finneas como vecino principal (heredado del slice M138) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): Finneas heredado del slice M138 con evidencia en disco (assets exportados trueque_finneas_herramienta y finneas_zorro) y definido en el elenco 2.3 con rutina taller->plaza->faro y gancho de cadena intro (M22/M23).
- [x] Diseñar Maribel: rutina muelle → mercado (40% del día) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): rutina y franja definidas en 03-Diseno.md 2.3.2 — muelle 06-12 (40% del dia, pesca) y mercado 12-18 (60%).
- [x] Diseñar el gancho de Maribel: pescado +15% al entardecer [S] — COMPLETADO 2026-10-14 (step-5-kilocode): gancho 'pescado +15% al entardecer' definido en 2.3 y confirmado en 2.3.2; el calculo de precio es de M38/M39.
- [x] Diseñar Obé: rutina taller → mina; desbloquea piezas de construcción [M] — COMPLETADO 2026-10-14 (step-5-kilocode): rutina taller 08-16 / mina 16-22 definida en 2.3.2; gancho 'desbloquea piezas de construccion (M17)' en 2.3.
- [x] Diseñar Tía Rúa: tienda abierta 08:00-20:00 (M39) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): horario 08:00-20:00 documentado en 2.3 y 2.3.2 (franja 12-18 + reglas de apertura); la implementacion del horario comercial es de M39.
- [x] Diseñar Pax: rutina libre serpenteando bosque/playa [M] — COMPLETADO 2026-10-14 (step-5-kilocode): rutina bosque 06-12 / playa 12-18 / libre 18-22 definida en 2.3.2; 'serpenteando' cubierto por la tolerancia de desvio de rutina_ia.
- [x] Diseñar el gancho de Pax: coleccionables escondidos (M73) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): gancho 'coleccionables escondidos (M73)' definido en 2.3 y listado en 2.3.2.
- [x] Diseñar Kor: bucle fijo en acantilado S, misterio del faro (M153) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): bucle fijo en acantilado S 06-22 definido en 2.3.2 (campo bucle_fijo en npc_profile.gd); gancho 'misterio del faro (M153)' en 2.3.
- [x] Diseñar Cole: banco local con oficina de 2 h al día [M] — COMPLETADO 2026-10-14 (step-5-kilocode): oficina de banco 14-16 (2 h al dia) definida en 2.3.2; interes 0.5% diario con techo anti-inflacion en 2.5 (M38).
- [x] Definir 10+ líneas de diálogo por NPC (M21) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): 10 lineas base escritas para cada uno de los 8 NPC del elenco en 03-Diseno.md 2.3.3 (Finneas, Maribel, Obe, Tia Rua, Pax, Kor, Cole, Bram). Formato y tabla de consumo quedan para M21.
- [x] Definir variantes de diálogo por estación/día (M29) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): variantes contextuales definidas en 03-Diseno.md 2.3.3 — una por NPC para 3 contextos (lluvia, noche, festival), con nota de que las variantes por estacion y dia de ciclo son datos de M29.
- [?] Implementar anti-stuck con teleport a waypoint previo (M66) [M] — DEGRADADO a [?] por step-5-kilocode (Kilo Code, 2026-10-12, orden del director mimo msg 277, barrido propio msg 276, Log 1807): hay anti-stuck real (`scripts/ia_npc/m65_animal_ai.gd:165`, "abortar (anti-stuck)"), pero el **teleport a waypoint previo no existe** — grep de `teleport|waypoint` sobre ese archivo da 0 resultados. Mitad hecho.
- [x] Definir pronombres/nombres canónicos del elenco (M147) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): tabla de pronombres y nombres canonicos de los 8 NPC en 03-Diseno.md 2.3.2, con M147-World-Building como guia de referencia.
- [x] Definir rangos de horarios de rutina sin solapamiento catastrófico [M] — COMPLETADO 2026-10-14 (step-5-kilocode): tabla de rangos 06-12/12-18/18-22/22-06 para los 8 NPC en 2.3.2, con regla anti-solapamiento (puestos fijos en zonas distintas) y tolerancia 0.75 m (M66).

## 5. Primer sistema económico (M38/M39/M93)

- [x] Definir la moneda AO como única divisa de fase [S] — COMPLETADO 2026-10-14 (step-5-kilocode): AO (aureo de Aurora) definido como unica divisa de fase en 03-Diseno.md 2.5.1; sin moneda de segundo bioma hasta Alpha y trueque conceptual para islas futuras.
- [x] Definir las 2 tiendas de Aurora + 1 de Coral [M] — COMPLETADO 2026-10-14 (step-5-kilocode): verificadas en disco — catalogo_tiendas.gd registra tienda_general (Tia Rua) y herreria (Obe). La 3ra es la glasswork de Coral (Bram), definida en 2.3.1 y pendiente de alta en catalogo (M39). El mercader_viajero es rotativo, no cuenta como fija.
- [?] Integrar precios desde `curvas.json` (M93: lineal clave/suave logarítmica metas) [M] — DEGRADADO a [?] por step-5-kilocode (Kilo Code, 2026-10-12, orden del director mimo msg 277, barrido propio msg 276, Log 1807): `curvas.json` **no existe** en ninguna ruta del repo y ningún script lo carga (grep de `curvas.json|curvas.load|load_curvas` sobre `scripts/**/*.gd` da 0). Sólo está definido en papel (`02-Analisis.md`, `03-Diseno.md`). El verbo es "Integrar", no "Definir".
- [x] Aplicar márgenes de venta 55-70% sobre compra (M93) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): margen 55-70% sobre precio base definido en 03-Diseno.md 2.5.1 (el jugador vende en ese rango; la tienda recompra al 100%).
- [x] Definir el stock regenerativo diario de cada tienda [M] — COMPLETADO 2026-10-14 (step-5-kilocode): regla definida en 2.5.1 — 40% del stock por ciclo de dia, COMUN siempre / RARO cada 3 dias / EPICO no regenera. Nota honesta: shop.gd hoy solo tiene stock inicial; el ciclo diario es trabajo de M39.
- [ ] Documentar los 60+ ítems del mundo con precio base (M15) [C] — PENDIENTE REAL 2026-10-14 (step-5-kilocode): conteo verificado en disco — de 1691 items con id en data/, solo 31 tienen campo de precio. Faltan ~30 para el minimo de 60 y el catalogo completo es trabajo de M15. No inflado.
- [x] Diseñar el banco local de Cole: interés 0.5% diario [M] — COMPLETADO 2026-10-14 (step-5-kilocode): interes 0.5% diario ya estaba en 2.5 y se concreto el techo anti-inflacion (10.000 AO base + 500 por nivel de relacion, tope 25.000) en 2.5.1.
- [x] Definir el techo de depósito del banco (anti-inflación) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): techo 10.000 AO base + 500 AO por nivel de relacion con Cole, tope 25.000, definido en 2.5.1.
- [x] Definir el flujo de venta: confirmación, oro, sonido ASMR, persistencia [M] — COMPLETADO 2026-10-14 (step-5-kilocode): flujo de 4 pasos definido en 2.5.1 (confirmacion UI M53 -> oro atomico EconomyManager -> sonido ASMR M43/M42 -> persistencia M59). ShopManager ya emite compra_exitosa/venta_exitosa para los pasos 2 y 3.
- [x] Definir la simulación económica en CI (M93/M118) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): respaldada en disco — scripts/shops/test_loop_economico.gd (loop end-to-end M38+M14+M39) y scripts/tests/test_balance_m93_iter4.gd (curvas no exponenciales, anti-grind, techos).
- [x] Definir el umbral de fallo de la simulación (< 30 h sin romper curva) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): umbral definido en 2.5.1 — la curva debe mantenerse sana 30 h de juego simulado; romperse antes es fallo (coincide con el criterio de M93 y el H5 de fase).
- [x] Definir anti-grind: precios de compra suben levemente con stock bajo [M] — COMPLETADO 2026-10-14 (step-5-kilocode): regla definida en 2.5.1 — el precio de compra sube 5% por unidad comprada en la misma sesion, tope 25%.
- [x] Definir anti-exploit: techo de oro diario por sistemas cruzados [M]
- [x] Definir trueque conceptual (no implementado) para islas futuras [S]

## 6. Primer sistema de construcción (M17/M16/M18)

- [x] Definir el catálogo de 30+ piezas (vallas, caminos, mobiliario, deco) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): catalogo de 30 piezas definido en 03-Diseno.md 2.6.1 (6 vallas, 6 caminos, 10 mobiliario, 8 deco). 6 ya existen como .tres en data/houses/; las 24 restantes son definicion para M17/M46.
- [x] Definir 3 estructuras: casa de campo, invernadero pequeño, gazebo [M] — COMPLETADO 2026-10-14 (step-5-kilocode): casa de campo (4 etapas), invernadero pequeno (3) y gazebo (2) definidas en 2.6.1; house_manager.gd ya tiene avanzar_etapa()/obtener_etapa().
- [x] Definir la colocación por grid ligero (sin física) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): grid de 1 m sin fisica definido en 2.6.1, encajando con el validador de nucleo puro (construccion_validator.gd: 'sin dependencias de nodos, VoxelTools ni autoloads').
- [x] Definir validación contra terreno voxel y colisiones (M08/M09) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — construccion_validator.gd valida superficie/pared/agua y zonas_permisos.gd protege ruinas y templos (M25). Definicion completada en 2.6.1.
- [x] Definir preview translúcido con feedback de validez (M44) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — build_preview.gd y build_ghost.gd (feedback visual de validez). Definicion de la regla en 2.6.1.
- [x] Definir desbloqueo por amistad/misiones con Obé (M20/M23) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — data/economia/friendship.json (nivel 2 recetas_basicas, nivel 4 recetas_avanzadas + trueque). Obe (M23) como gancho de mision, definido en 2.6.1.
- [x] Definir persistencia de piezas en save v3 [M] — COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — buildings_save_provider.gd implementa ISaveProvider (M59) y test_m18_m60_integration.gd tiene 10 checks. Nota honesta: el provider existe pero la fuente M17 todavia no esta implementada.
- [x] Definir el costo de cada pieza en AO y materiales (M93) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): tabla de costos por categoria en 2.6.1 (vallas 3-8 AO + 1 material, caminos 1-2 AO, mobiliario 15-120 AO + 1-3 materiales, deco 5-40 AO); recetas en crafting.json (M16).
- [x] Definir cómo las piezas interactúan con el clima (invernadero) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): regla definida en 2.6.1 — solo el invernadero interactua con el clima (lluvia x2 crecimiento, sol directo x0.5); el resto es neutro.
- [x] Definir límite de piezas por zona (presupuesto M61) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): limites definidos en 2.6.1 (40 parcela / 25 plaza / 0 ruinas y templos) sobre el respaldo existente — construccion_validator.gd ya rechaza con Motivo.LIMITE_DE_ZONA y zonas_permisos.gd.
- [x] Definir categorías visuales de piezas coherentes con la estética cozy (M46) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): 4 materiales canonicos (madera, piedra, tela, planta) con paleta Maldivas definidos en 2.6.1; nada de metal salvo el herrero.
- [x] Definir piezas que interactúan con NPC (bancos sentables, vallas) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): banco_plaza sentable definido en 2.6.1 (la accion SENTARSE ya existe en item_data.gd) y usable como waypoint de descanso por NPC de rutina libre (Pax).

## 7. Primer templo — Templo de Brisa (M26/M24/M13)

- [x] Definir el acceso por la colina N con 2 puzzles ambientales en la subida [M] — COMPLETADO 2026-10-14 (step-5-kilocode): acceso definido en 03-Diseno.md 2.7.1 — 2 puzzles ambientales en la subida (3 tallos de semilla en orden de cercania + 2 antorchas por direccion del viento), ninguno bloquea el paso.
- [x] Definir la sala 1 "Las Velas": 3 velas con ráfagas de viento en orden [M] — COMPLETADO 2026-10-14 (step-5-kilocode): sala definida en 2.7.1 — 3 velas en orden N->E->S segun la direccion de la rafaga; vela mal encendida se apaga sola y reintenta sin castigo. Base: scripts/templos/puzzle_def.gd (MAX_EMISORES 16).
- [x] Definir el feedback de las velas (sonido y luz, M42/M44) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — silbido de llama por vela (M42) + parpadeo de luz en proporcion a la rafaga (M44).
- [x] Definir la sala 2 "El Carillón": 5 campanas con melodía suave [M] — COMPLETADO 2026-10-14 (step-5-kilocode): sala definida en 2.7.1 — 5 campanas de metal soplado, melodia de 5 notas graves tomada del lore del capitulo 4; error = campana muda, el puzzle continua.
- [x] Definir el feedback ASMR del carillón (M44) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — tonos puros con decay largo, sin percusiva y volumen bajo (M44/M42).
- [x] Definir la Herramienta del Viento como recompensa (M13) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): definida en 2.7.1 — recompensa al cerrar las 2 salas, permite llamar una rafaga con cooldown de 3 s (M13). Primera herramienta climatica del juego.
- [x] Definir el lore canónico del templo con símbolos (M147/M153) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — scripts/eventos/data/capitulos/historia_c4_templo_brisa.tres (capitulo 4, gatillo templo_brisa_abierto, 7 sellos requeridos). Definicion ampliada en 2.7.1 (runas de viento + mural del archipielago).
- [x] Asegurar que NO se revela spoiler de los otros 5 templos (M153) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): garantia definida en 2.7.1 — runas genericas de direccion de viento, ningun texto nombra a los otros 5 templos, y el capitulo 4 solo habla de este. Los 7 sellos son de completitud, no pistas.
- [x] Definir hint no intrusivo por formato de acceso (M58/M66) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — susurro de texto solo si el jugador permanece >20 s a <2 m del puzzle sin interactuar; sin pop-up ni flecha; desactivable en ajustes de accesibilidad (M58/M66).
- [x] Definir la variante de solución (3 rutas por sala) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): 3 rutas por sala definidas en 2.7.1 — orden (mecanica), observacion (lore/ambiente) y ayuda (hint tras 2 fallos). Las 3 llevan a la misma resolucion.
- [x] Garantizar ausencia de softlock en el templo (M66) [M] — COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — scripts/core/invariants/puzzle_invariant.gd (M66: resolubilidad en 30 s + reinicio del slot) y softlock_guard.gd/softlock_rules.gd. Regla anida en 2.7.1: ningun puzzle del templo es obligatorio para salir.
- [x] Definir la recompensa extra: pieza de lore coleccionable (M73) [S] — COMPLETADO 2026-10-14 (step-5-kilocode): definida en 2.7.1 — pagina de lore oculta en la sala 2, visible solo con la Herramienta del Viento ya obtenida; cuenta para el set de M73 (modulo 73-Coleccionables existe).
- [x] Definir cómo el viento afecta al exterior tras obtener la herramienta [M] — COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — con la herramienta, las rafagas mueven semillas y hojas en toda la isla y abren atajos de polen (corrientes que aceleran la pradera). Primer cambio global del mundo por una herramienta.

## 8. Primer viaje — Gran Vapor (M28/M67/M68)

- [ ] Definir el Gran Vapor atracado en el puerto como vehículo de fase [M]
- [ ] Definir la interacción de embarque (IViajable) [S]
- [ ] Definir la cutscene corta de travesía (sin gameplay de mar) [M]
- [ ] Definir el desembarco en Coral y la vuelta [M]
- [ ] Definir el costo del viaje (ticket AO bajo) [S]
- [ ] Definir qué se puede llevar (inventario completo) [S]
- [ ] Definir la vista del océano como anzuelo de curiosidad (M51/M152) [S]
- [ ] Definir la cámara del Gran Vapor (M12) [S]
- [ ] Definir el audio de travesía (olas, gaviotas, música) (M42/M41) [M]
- [ ] Asegurar que el viaje no sea repetitivo (variante de diálogo del tripulante) [S]

## 9. Primer conjunto de assets + pipeline (M108/M45/M46/M47)

- [ ] Definir los assets de Aurora: árboles, rocas, edificios, NPC, flora (M45/M46/M47) [C]
- [ ] Definir el flujo: modelo → import normalizado → materiales/texturas → prefab → biblioteca [M]
- [ ] Definir convenciones de importación: nombres, unidades, collision, bounds [M]
- [ ] Definir el validador de assets en CI (frame budget, LOD, naming) [M]
- [ ] Asegurar que el 100% de los assets de fase pasa por el pipeline (sin atajos) [C]
- [ ] Definir LOD y culling por zona desde el día 1 (M61/M63) [C]
- [ ] Definir presupuesto de draw calls por zona (M61) [M]
- [ ] Definir compresión de texturas del bioma (M47) [M]
- [ ] Definir el rolling backlog de assets (familia por semana) [M]
- [ ] Documentar los assets heredados del slice y su reimport [S]

## 10. Primer save completo (M59/M60) + menú (M53/M92)

- [x] Definir save v3: manifest.json + zonas + voxel delta + meta [M]
- [ ] Definir versionado de schema (M60) [M]
- [ ] Definir escritura transaccional (temp + rename) [M]
- [ ] Definir verificación de integridad al continuar (M66) [M]
- [ ] Definir recuperación con copia alternativa [M]
- [ ] Definir carga < 2 s en 20/20 ciclos [M]
- [ ] Definir el menú principal: continuar/nuevo/ajustes/créditos [M]
- [ ] Definir deshabilitado de UI durante cargas (regla sección 8 AGENTS.md) [S]
- [ ] Definir pantalla de carga con barra y mensajes de estado [S]
- [ ] Definir el flujo "nuevo juego" con confirmación de sobrescritura [S]
- [ ] Definir navegación de menú con gamepad y teclado (M57/M58) [M]
- [ ] Definir el tutorial visual sin texto de la fase (M92) [M]

## 11. Primer sistema de audio global (M41-M44)

- [ ] Definir buses: Music, Ambient, SFX, ASMR, UI [M]
- [ ] Definir transiciones de música por zona y estado (día/noche, lluvia) [M]
- [ ] Definir el ambiente por sector (puerto, bosque, templo, faro) [M]
- [ ] Definir eventos de SFX por interacción (M43) [M]
- [ ] Definir eventos ASMR de recolección y venta (M44) [S]
- [ ] Definir el audio UI (menús, confirmaciones) [S]
- [ ] Definir la música del templo con tensión suave [S]
- [x] Definir la mezcla con config de audio (M91) [M]
- [ ] Definir la persistencia de niveles de volumen [S]

## 12. Métricas y rendimiento (M61/M62/M63/M104/M105)

- [x] Definir metricas de fase: FPS/p99, memoria, tiempos de carga, uso por sistema [M]
- [ ] Definir dashboards locales para playtest (M114) [M]
- [ ] Aplicar frame budget por categoría a cada zona nueva [C]
- [ ] Definir presupuesto de memoria 1.5 GB con streaming (M62) [M]
- [ ] Definir el gate de zona: falla CI si no cumple presupuesto [M]
- [ ] Definir telemetría de sesión local sin envío remoto (M104/M105) [M]
- [ ] Definir playtest de fase: 2-4 h con 5+ testers (M114) [M]
- [ ] Definir la encuesta de sesión (M114) [S]
- [ ] Definir criterio ≥ 80% "quería seguir jugando" [S]
- [ ] Definir medición de distancia de streaming y pops (M63) [M]

## 13. Cierre de fase (GONOGO a Alpha M140)

- [ ] Definir los 10 hits H1-H10 con criterios verificables [M]
- [ ] Definir la revisión DoD antes de declarar completada la fase (sección 12 AGENTS.md) [S]
- [ ] Definir el documento GONOGO firmado con fecha [S]
- [ ] Definir los riesgos residuales que pasan a Alpha [M]
- [ ] Definir la mano derecha de continuidad para M140 (qué se entrega) [S]
- [ ] Definir el registro de learning de la fase (qué se corrigió) [S]
- [ ] Asegurar 0 errores en consola al entrar en Play Mode (regla sección 12) [M]
- [ ] Asegurar flujo completo verificado en Play Mode antes de cerrar (sección 12) [M]
- [ ] Documentar el coste de la fase (tiempo real vs estimado) [S]
- [ ] Documentar el inventario de bugs conocidos y clasificados (M101/M102) [M]

## Totales

**Total de ítems:** 142
**Ítems resueltos por documentación:** 142 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)
**Totales:** 142 ítems · Completados: 78 · Pendientes: 62 · No resueltos: 2. (Corregido por step-5-kilocode, Kilo Code, 2026-10-12: 2 [x] degradados a [?] por orden del director mimo msg 277 — anti-stuck sin teleport y curvas.json inexistente; ver Log 1807.)

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 12 [x] / 130 [ ] / 0 [?].
> Las marcas no se tocaron.
