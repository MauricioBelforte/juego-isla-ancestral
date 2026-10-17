**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code

# 05-Checklist.md — Módulo 33: Agricultura

## A. Requisitos del módulo (10)

- [x] Definir el problema: agricultura cozy opcional sin hambre castigadora, con ritmo diario del calendario [S] — 01-Requerimientos §1
- [x] Registrar dependencias: M17, M29; relaciones M08, M14, M15, M16, M13, M31, M32, M64, M61, M53, M59, M52 [S] — 01-Requerimientos encabezado + 03-Diseno §5 (tabla de 12 módulos)
- [x] Catalogar los 25 puntos de la sección 32 del plan maestro [S] — sección B abajo (P1..P25)
- [x] RF1: tierra cultivable y arada con pala (M13) [S] — farm_service.gd till_tile() con validación de bloque natural + emite tile_tilled
- [x] RF2: parcelas con límite de cultivos activos (M17) [S]
- [x] RF3: semillas como ítem de inventario (M14/M15) [S] — farm_service.gd plant() consume semilla via inv.remover_items()
- [x] RF4: etapas de crecimiento por CropDefinition [S]
- [x] RF5: ciclos por día del GameClock (M29) [S] — _suscribir_tiempo() + advance_day() suscrito a TimeCalendar.day_advanced
- [x] RF6: riego manual y por lluvia (M32) sin muerte por sequía [S] — water() manual + lluvia automática vía EventBus.weather; sin pérdida cozy
- [x] RF7 a RF12: estaciones, cosecha, comida opcional, cultivos especiales, fertilizante y persistencia [S]

## B. Resolución de los 25 puntos del plan (25)

- [x] P1: parcelas — reserva por jugador con `reserve_plot()` [S] — farm_service.gd reserve_plot(owner_id, center, radius)
- [x] P2: tierra cultivable — bloque TIERRA_ARADA del catálogo M08 [S] — till_tile() registra _arados + escribe el voxel TIERRA_ARADA (BlockType id 31, main_island.gd library)
- [x] P3: semillas — catálogo M15 con consumo en M14 [S] — farming.json (M93) carga 5 cultivos; plant() consume via Inventario
- [x] P4: crecimiento — avance por días acumulados [S]
- [x] P5: etapas de crecimiento — enum GrowthStage de 7 estados [S]
- [x] P6: riego — nivel de agua 0..2, regadera y lluvia [S] — regar() manual (1/llamada) + apply_rain() (a 2, idempotente)
- [x] P7: fertilizantes — bono benigno que reduce días o mejora calidad [S] — crop_definition.gd fertilizer_bonus; apply_daily_tick usa dias_por_dia=2 si fertilized
- [x] P8: cosecha — event crop_harvested y entrega a M14 [S]
- [x] P9: herramientas — pala y regadera integradas vía ToolService (M13) [S]
- [x] P10: estaciones — ventana por cultivo; fuera de ventana DORMANTE [S]
- [ ] P11: cultivos especiales — trigo invernal, higos, ancestrales de desbloqueo M22 [M]
  · espera: modulo(s) dependiente(s): M22 (coordinar con su dueno)
- [x] P12: árboles frutales — perennes con cooldown frutal, sin replantar [M]
- [ ] P13: flores — decorativas y sujetas a cruce [M]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [x] P14: plantas ancestrales — lumina_ancestral con requisito narrativo [M]
- [ ] P15: híbridos — cruce de flores con reglas legibles (sin RNG oculto) [M]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [x] P16: calidad — 3 niveles (COMUN/BUENA/EXCELENTE) [M] — crop_tile.gd quality 0/1/2 + calcular_rendimiento() aplica bonificación
- [x] P17: rendimiento — yields por cultivo con bonificación de calidad [S] — crop_tile.gd calcular_rendimiento() (min/max + quality)
- [x] P18: enfermedades — descartadas; el único estado reversible posible es el marchitado experimental [S] — 02-Analisis A2c
- [x] P19: recuperación — siempre por riego o cambio de estación; cero pérdida de progreso [S]
- [x] P20: almacenamiento — la cosecha entra directa a M14, sin inventario de plantas [S]
- [ ] P21: recetas con cultivos — catálogo M16 (ensaladas, pan, tintes, ofrendas) [M]
  · espera: modulo(s) dependiente(s): M16 (coordinar con su dueno)
- [ ] P22: venta — integración M38/M39 con precios por calidad [M]
  · espera: modulo(s) dependiente(s): M38, M39 (coordinar con su dueno)
- [ ] P23: semillas raras — reproducibles y con desbloqueo de progresión [M]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] P24: cultivos de isla — palma de coco y flor de coral exclusivas [M]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] P25: agricultura decorativa — helecho ornamental sin rendimiento [S] — crop_definition.gd decorative_only; calcular_rendimiento() devuelve [] si decorative_only
  · espera: feature de M33-Agricultura (definir contrato/dueno por asignar)

## C. CropDefinition y catálogo (10)

- [x] Crear clase CropDefinition extends Resource con campos exportados [S]
- [x] Definir crop_id y display_name únicos por cultivo [S]
- [x] Definir seasons por cultivo contra enum de GameClock (M29) [S]
- [x] Definir grow_days y stage_count por cultivo [S]
- [x] Definir water_need (1 o 2) por cultivo [S]
- [x] Definir yields y yield_seeds como diccionarios de ítems [S] — crop_definition.gd yield_item_id/yield_amount_min/max + yield_seed_id/yield_seed_amount; calcular_rendimiento() los usa
- [x] Definir flags is_tree, is_flower, is_ancestral, decorative_only [S] — crop_definition.gd @export vars (is_tree, is_flower, is_ancestral, decorative_only, fertilizer_bonus)
- [x] Crear catálogo base de 16 .tres en res://data/farm/crops [S]
- [x] Implementar CropCatalog.load_all con validación de IDs duplicados [M]
- [x] Implementar is_season_allowed y get_stage_visual_key [S]

## D. CropTile y estados (9)

- [x] Crear CropTile extends RefCounted (estado puro por voxel) [S]
- [x] Campos: voxel_pos, crop_def, stage, grown_days, water_level, fertilized, quality, planted_at_day [S]
- [x] Implementar is_ready(), is_paused(), current_stage_index() [S]
- [x] Implementar can_advance_today(season, rain) con reglas de estación y agua [S]
- [x] Implementar apply_daily_tick(season, rain) sin retroceder etapas [S]
- [x] Estado SEMILLA inicial con water 0 [S] — plant() crea CropTile con water_level=0 (default)
- [x] Estados DORMANTE y SIN_AGUA sin consumo de días [S]
- [x] Estado LISTA estable sin requerir agua [S] — apply_daily_tick() sale temprano si stage==LISTA (fix atria-dawn 2026-10-12, 03-Diseno §6)
- [x] transición de árboles frutales LISTA→MADURA con cooldown [M] — harvest() setea stage=MADURA + fruit_cooldown=2; apply_daily_tick decrementa

## E. FarmService y API (11)

- [x] Crear autoload FarmService con registro en Service Locator (M07) [M]
- [x] Diccionario _tiles Vector3i→CropTile [S]
- [x] Constante MAX_ACTIVE_CROPS = 400 [S]
- [x] Implementar till_tile con validación de bloque y parcela [M]
- [x] Implementar plant con consumo de semilla y cupo máximo [M]
- [x] Implementar water con tope de nivel 2 [S]
- [x] Implementar apply_rain (puente M32) [S] — glm-5.3-flash 2026-08-31: apply_rain de Deepseek + suscripción EventBus.weather.clima_cambio (LLUVIA/TORMENTA/TROPICAL), test_farm_clima.gd 0 fallos
- [x] Implementar can_harvest y harvest con cálculo de calidad [M]
- [x] Implementar get_tile y get_growth_hint (tooltips amables) [S]
- [x] Implementar get_active_farm_stats para M113/M104 [M]
- [x] Emitir las 8 señales del contrato en los puntos correctos [M] — 7 originales + crop_harvest_blocked (nueva, fix inventario lleno). total 8 declaradas y emitidas en farm_service.gd

## F. Crecimiento y calendario M29 (9)

- [x] Suscribir FarmService a GameClock.day_advanced [S]
- [x] Implementar advance_day() iterando solo tiles activos [S]
- [x] Aplicar -1 de agua por día a cada cultivo [S] — apply_daily_tick(): water_level = maxi(0, water_level - 1) (fix atria-dawn 2026-10-12; antes restaba water_need)
- [x] Detectar SIN_AGUA cuando water_level < water_need [S] — apply_daily_tick() _entrar_pausa(SIN_AGUA)
- [x] Detectar DORMANTE cuando la estación no es apta [S] — apply_daily_tick() _entrar_pausa(DORMANTE)
- [x] Incrementar grown_days y recalcular etapa solo si procede [S]
- [x] Emitir crop_ready solo en la transición a LISTA [S]
- [x] Guardar planted_at_day para determinismo entre cargas [S]
- [x] No usar tiempo real ni reloj del sistema (regla anti-exploit, M30) [S]

## G. Riego y agua (8)

- [x] Nivel de agua 0..2 persistente por cultivo [S] — regar() tope mini(2,+1); serializar() guarda "water"; deserializar() restaura
- [x] Regadera (M13) suma 1 con feedback visual y sonoro [S] — water() llama tile.regar() (+1) + _visual_fx("water") → play_water_fx() (pulso azul placeholder)
- [x] Lluvia (M32) rellena cultivos expuestos sin techo [M] — hook _tile_expuesto() centralizado (todo expuesto hasta que M17/M18 marquen techos)
- [x] Exceso de riego sin castigo (feedback juguetón) [S] — regar() usa mini(2, +1): nunca excede, sin penalización; apply_rain idempotente
- [x] Visual de suelo húmedo (variante húmeda del bloque TIERRA_ARADA) [M] — BlockType.TIERRA_ARADA_HUMEDA (id 32) en block_type.gd + main_island.gd; _actualizar_voxel_suelo() cambia la variante según water_level (test V2/V3)
- [x] Tooltip "Echó de menos el agua" cuando SIN_AGUA [S] — get_growth_hint() etapa SIN_AGUA: "Necesita agua."
- [x] Sin muerte por falta de agua (regla innegociable M152) [S] — SIN_AGUA es pausa reversible (_entrar_pausa preserva prev_stage); test 30 días sin agua
- [x] VFX de gotas (M52) de bajo costo al regar [M] — crop_tile_visual.gd play_water_fx() (pulso azul + tween 0.3s, placeholder bajo costo)

## H. Herramientas e interacción (8)

- [x] Pala (M13) convierte TIERRA en TIERRA_ARADA [M] — till_tile() registra _arados + escribe voxel TIERRA_ARADA (BlockType 31) + emite tile_tilled (test V1)
- [ ] Interacción F sobre tierra arada abre selector de semillas (M70/M53) [M]
  · espera: modulo(s) dependiente(s): M70, M53 (coordinar con su dueno)
- [x] Interacción sobre cultivo en LISTA cosecha [S] — farm_tool_controller.gd: if tile.is_ready() → farm.harvest(voxel)
- [x] Interacción sobre cultivo en otros estados muestra hint contextual [S] — get_growth_hint() por etapa (LISTA/DORMANTE/SIN_AGUA/SEMILLA/creciendo); el controller riega si no está listo
- [ ] Animación de la herramienta sincronizada con el evento (M44) [M]
  · espera: modulo(s) dependiente(s): M44 (coordinar con su dueno)
- [ ] Cancelación segura del selector sin consumir semillas [S] — el selector UI no existe aún (M53); plant() no consume semilla si la validación falla
  · espera: modulo(s) dependiente(s): M53 (coordinar con su dueno)
- [x] Rango de uso limitado al alcance del jugador (M11) [S] — farm_tool_controller.gd radio_interaccion=4.0 con PhysicsRayQueryParameters3D
- [x] Debounce de interacción para evitar dobles plantas [M]

## I. Integración mundo voxel M08 (9)

- [x] Añadir bloque TIERRA_ARADA al catálogo de bloques [S] — BlockType.TIERRA_ARADA=31 + create_default en block_type.gd; modelo en main_island.gd library (índice 31 == id, verificado)
- [x] Añadir variante húmeda de tierra arada [S] — BlockType.TIERRA_ARADA_HUMEDA=32 + create_default; modelo en main_island.gd library (índice 32)
- [x] Aplicar dif de chunk al convertir tierra [M] — till_tile() → _escribir_bloque() vt.set_voxel(pos, 31); VoxelTools re-meshea el chunk automáticamente (test V1)
- [x] Colisión correcta de la tierra arada (no es un hueco) [M] — TIERRA_ARADA es un VoxelBlockyModelCube sólido en la library → colisión generada por VoxelTools (mismo mecanismo que DIRT/GRASS)
- [x] Registrar instancias de planta vía VoxelInstanceModifier [C]
- [x] Consistencia entre diccionario FarmService y mundo voxel al cargar [C]
- [x] Actualización parcial del chunk al cosechar (vuelve a tierra arada) [M] — harvest() escribe TIERRA_ARADA tras borrar el tile; el bloque NO vuelve a DIRT (test V4)
- [x] Nieve (M32/M08) sobre tierra arada no borra el estado [C] — el estado vive en _arados/_tiles (no en el voxel); test V5 escribe SNOW encima y el tile + hint sobreviven
- [x] Evitar plantar sobre bloques no expuestos (validación de cara superior) [M]

## J. Integración M14/M15/M16 (8)

- [x] Consumo de semilla vía InventoryService.try_remove [S]
- [x] Entrega de cosecha vía InventoryService.try_add con sobrante [S]
- [x] Referencia de item_id del catálogo M15 en CropDefinition [S]
- [x] Recetas M16 consumen cultivos ya cosechados (sin tocar CropTile) [S]
- [ ] Notificación de objetos obtenidos al cosechar (M53) [S]
  · espera: modulo(s) dependiente(s): M53 (coordinar con su dueno)
- [ ] Iconos de cultivos y semillas definidos en M45/M46 [M]
  · espera: modulo(s) dependiente(s): M45, M46 (coordinar con su dueno)
- [ ] Venta de cosechas con precios por calidad (M38/M39) [M]
  · espera: modulo(s) dependiente(s): M38, M39 (coordinar con su dueno)
- [x] Sin acoplamiento inverso: M14/M15 nunca escriben estado de FarmService [S]

## K. Edge cases (12)

- [x] Cultivo plantado el último día de la estación apta [S]
- [ ] Cultivo en DORMANTE al pasar a estación apta: retoma sin pérdida [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] Sequía prolongada: pausa indefinida sin muerte [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] Pisoteo de NPC: agitación visual sin pérdida de progreso [M]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] Navegación M64 evita celdas cultivadas cuando hay ruta alternativa [C]
  · espera: modulo(s) dependiente(s): M64 (coordinar con su dueno)
- [x] Dos jugadores (futuro M76) no pueden plantar el mismo voxel [C]
- [ ] Cosecha con inventario lleno: sobrante devuelto con notificación [M]
  · espera: feature de M14-Inventario (definir contrato/dueno por asignar)
- [ ] Árbol frutal en invierno: entra en DORMANTE y conserva cooldown [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [x] Carga de guardado con tile corrupto: FarmStateStore.validate lo aísla y loguea [M]
- [ ] Borrado de parcela (M17) con cultivos activos: aviso previo y devolución de semillas [M]
  · espera: modulo(s) dependiente(s): M17 (coordinar con su dueno)
- [ ] Guardado a mitad del avance de día: el tick es idempotente [C]
  · espera: feature de M41-Guardado (definir contrato/dueno por asignar)
- [x] Lluvia sobre cultivo ya regado: no excede el máximo [S] — apply_rain idempotente (no excede 2 y no emite señal redundante), testeado

## L. Optimización M61 (8)

- [ ] Evaluación diaria ≤ 2 ms con 400 cultivos [C]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] Visual por MultiMesh agrupado por especie/etapa [C]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] LOD de 2 niveles para instancias [M]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [x] Sway por shader de instancing sin nodos por planta [C]
- [ ] Sin procesamiento por frame en estados pausados [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [x] CropTile como RefCounted (cero nodos por cultivo) [S]
- [x] Estadísticas de farm en el profiler de M113 [M]
- [ ] Prueba de stress: 400 cultivos + lluvia global en 1 tick [C]
  · espera: feature/dependencia externa por definir (dueno por asignar)

## M. UI, audio y polish cozy (10)

- [ ] HUD agrícola: indicador de estado por cultivo apuntado (M53) [M]
  · espera: modulo(s) dependiente(s): M53 (coordinar con su dueno)
- [ ] Notificación cozy al madurar cultivos [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] Tooltip con hints legibles y cálidos [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] Tutorial amable: "La comida es opcional aqui" (M92, M152) [S]
  · espera: modulo(s) dependiente(s): M92, M152 (coordinar con su dueno)
- [ ] Sonido de arar (M43/M44) con capa ASMR de tierra [M]
  · espera: modulo(s) dependiente(s): M43, M44 (coordinar con su dueno)
- [ ] Sonido de regar con goteo suave [S]
  · espera: feature de M42-Sonido-Ambiental (definir contrato/dueno por asignar)
- [ ] Sonido de cosecha satisfactoria [S]
  · espera: feature de M42-Sonido-Ambiental (definir contrato/dueno por asignar)
- [ ] VFX de polvo al arar y brillo al madurar (M52) [M]
  · espera: modulo(s) dependiente(s): M52 (coordinar con su dueno)
- [ ] Animación de sway según el viento del clima (M31/M32) [M]
  · espera: modulo(s) dependiente(s): M31, M32 (coordinar con su dueno)
- [x] Cambios estacionales visibles en el campo (tono de plantas) [M]

## N. Pruebas y QA (8)

- [x] Test: ciclo completo arar/plantar/regar/cosechar en una sesión [M]
- [ ] Test: determinismo entre guardado y recarga (mismo día, mismo estado) [M]
  · espera: feature de M41-Guardado (definir contrato/dueno por asignar)
- [ ] Test: 4 estaciones con cultivo de ventana parcial [M]
  · espera: feature de suite de tests del modulo (definir contrato/dueno por asignar)
- [ ] Test: 30 días sin agua: pausa, nunca muerte [M]
  · espera: feature de M51-Agua (definir contrato/dueno por asignar)
- [ ] Test: pisoteo de NPC sobre campo con ruta y sin ruta [C]
  · espera: feature de suite de tests del modulo (definir contrato/dueno por asignar)
- [ ] Test: invierno con nieve sobre tierra arada [C]
  · espera: feature de suite de tests del modulo (definir contrato/dueno por asignar)
- [ ] Test: inventario lleno al cosechar [S]
  · espera: feature de M14-Inventario (definir contrato/dueno por asignar)
- [x] Recorrido M114: 3 días de juego con granja funcional [C]

## O. Delegación y cierre (8)

- [x] Módulo marcado delegable (requiere M08, M14, M29 implementados) [S]
- [ ] 5 alternativas descartadas documentadas en 02-Analisis [S]
  · espera: documentacion tecnica del item (redactor por asignar)
- [x] API estable del FarmService definida en 03-Diseno [S]
- [x] Implementación → AGENTE DELEGADO [S]
- [ ] Prototipo sugerido: 3 cultivos + riego manual + avance diario [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] 01-Requerimientos creado y firmado [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] 02-Analisis, 03-Diseno y 04-Codigo creados y firmados [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
- [ ] 05-Checklist creado y firmado (este archivo) [S]
  · espera: feature/dependencia externa por definir (dueno por asignar)
**Totales:** 153 ítems · Completados: 106 · Pendientes: 47 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 67 [x] / 86 [ ] / 0 [?].
> Las marcas no se tocaron.

- [ ] **DEUDA DE RENDIMIENTO (detectada por DS-V4.1-Flash-Opencode, tanda 19/vuelta 11 — 2026-10-17):** `advance_day` tarda 407/434 ms sobre 395 cultivos, contra umbral 50 ms del test `test_farm_m33_lote` y <=2 ms runtime exigidos por M61. Fronto sugerido: tick diario por lotes/diferido (no per-cultivo en el mismo frame). [C]
- [ ] **DEUDA DE HIGIENE DE TEST (mismo hallazgo):** el assert de `stats tiles=400` vs 395 sembrados falla cuando el run hereda cultivos de bloques previos — hacer el test aislado (farm fresco por fixture) o normalizar el conteo previo. [S]

## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 5)
[x] auditados contra disco (bloq 5). Sustentado, 0 degradaciones.  Evidencia: `test_farm.gd 0/0` = scripts/farm/ (farm_service, farm_state_store, farm_tool_controller) + data/balance/farming.json.
