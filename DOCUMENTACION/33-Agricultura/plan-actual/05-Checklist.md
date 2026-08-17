**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 33: Agricultura

## A. Requisitos del módulo (10)

- [x] Definir el problema: agricultura cozy opcional sin hambre castigadora, con ritmo diario del calendario [S]
- [x] Registrar dependencias: M17, M29; relaciones M08, M14, M15, M16, M13, M31, M32, M64, M61, M53, M59, M52 [S]
- [x] Catalogar los 25 puntos de la sección 32 del plan maestro [S]
- [x] RF1: tierra cultivable y arada con pala (M13) [S]
- [x] RF2: parcelas con límite de cultivos activos (M17) [S]
- [x] RF3: semillas como ítem de inventario (M14/M15) [S]
- [x] RF4: etapas de crecimiento por CropDefinition [S]
- [x] RF5: ciclos por día del GameClock (M29) [S]
- [x] RF6: riego manual y por lluvia (M32) sin muerte por sequía [S]
- [x] RF7 a RF12: estaciones, cosecha, comida opcional, cultivos especiales, fertilizante y persistencia [S]

## B. Resolución de los 25 puntos del plan (25)

- [x] P1: parcelas — reserva por jugador con `reserve_plot()` [S]
- [x] P2: tierra cultivable — bloque TIERRA_ARADA del catálogo M08 [S]
- [x] P3: semillas — catálogo M15 con consumo en M14 [S]
- [x] P4: crecimiento — avance por días acumulados [S]
- [x] P5: etapas de crecimiento — enum GrowthStage de 7 estados [S]
- [x] P6: riego — nivel de agua 0..2, regadera y lluvia [S]
- [x] P7: fertilizantes — bono benigno que reduce días o mejora calidad [S]
- [x] P8: cosecha — event crop_harvested y entrega a M14 [S]
- [x] P9: herramientas — pala y regadera integradas vía ToolService (M13) [S]
- [x] P10: estaciones — ventana por cultivo; fuera de ventana DORMANTE [S]
- [x] P11: cultivos especiales — trigo invernal, higos, ancestrales de desbloqueo M22 [M]
- [x] P12: árboles frutales — perennes con cooldown frutal, sin replantar [M]
- [x] P13: flores — decorativas y sujetas a cruce [M]
- [x] P14: plantas ancestrales — lumina_ancestral con requisito narrativo [M]
- [x] P15: híbridos — cruce de flores con reglas legibles (sin RNG oculto) [M]
- [x] P16: calidad — 3 niveles (COMUN/BUENA/EXCELENTE) [M]
- [x] P17: rendimiento — yields por cultivo con bonificación de calidad [S]
- [x] P18: enfermedades — descartadas; el único estado reversible posible es el marchitado experimental [S]
- [x] P19: recuperación — siempre por riego o cambio de estación; cero pérdida de progreso [S]
- [x] P20: almacenamiento — la cosecha entra directa a M14, sin inventario de plantas [S]
- [x] P21: recetas con cultivos — catálogo M16 (ensaladas, pan, tintes, ofrendas) [M]
- [x] P22: venta — integración M38/M39 con precios por calidad [M]
- [x] P23: semillas raras — reproducibles y con desbloqueo de progresión [M]
- [x] P24: cultivos de isla — palma de coco y flor de coral exclusivas [M]
- [x] P25: agricultura decorativa — helecho ornamental sin rendimiento [S]

## C. CropDefinition y catálogo (10)

- [x] Crear clase CropDefinition extends Resource con campos exportados [S]
- [x] Definir crop_id y display_name únicos por cultivo [S]
- [x] Definir seasons por cultivo contra enum de GameClock (M29) [S]
- [x] Definir grow_days y stage_count por cultivo [S]
- [x] Definir water_need (1 o 2) por cultivo [S]
- [x] Definir yields y yield_seeds como diccionarios de ítems [S]
- [x] Definir flags is_tree, is_flower, is_ancestral, decorative_only [S]
- [x] Crear catálogo base de 16 .tres en res://data/farm/crops [S]
- [x] Implementar CropCatalog.load_all con validación de IDs duplicados [M]
- [x] Implementar is_season_allowed y get_stage_visual_key [S]

## D. CropTile y estados (9)

- [x] Crear CropTile extends RefCounted (estado puro por voxel) [S]
- [x] Campos: voxel_pos, crop_def, stage, grown_days, water_level, fertilized, quality, planted_at_day [S]
- [x] Implementar is_ready(), is_paused(), current_stage_index() [S]
- [x] Implementar can_advance_today(season, rain) con reglas de estación y agua [S]
- [x] Implementar apply_daily_tick(season, rain) sin retroceder etapas [S]
- [x] Estado SEMILLA inicial con water 0 [S]
- [x] Estados DORMANTE y SIN_AGUA sin consumo de días [S]
- [x] Estado LISTA estable sin requerir agua [S]
- [x] transición de árboles frutales LISTA→MADURA con cooldown [M]

## E. FarmService y API (11)

- [x] Crear autoload FarmService con registro en Service Locator (M07) [M]
- [x] Diccionario _tiles Vector3i→CropTile [S]
- [x] Constante MAX_ACTIVE_CROPS = 400 [S]
- [x] Implementar till_tile con validación de bloque y parcela [M]
- [x] Implementar plant con consumo de semilla y cupo máximo [M]
- [x] Implementar water con tope de nivel 2 [S]
- [x] Implementar apply_rain (puente M32) [S]
- [x] Implementar can_harvest y harvest con cálculo de calidad [M]
- [x] Implementar get_tile y get_growth_hint (tooltips amables) [S]
- [x] Implementar get_active_farm_stats para M113/M104 [M]
- [x] Emitir las 8 señales del contrato en los puntos correctos [M]

## F. Crecimiento y calendario M29 (9)

- [x] Suscribir FarmService a GameClock.day_advanced [S]
- [x] Implementar advance_day() iterando solo tiles activos [S]
- [x] Aplicar -1 de agua por día a cada cultivo [S]
- [x] Detectar SIN_AGUA cuando water_level < water_need [S]
- [x] Detectar DORMANTE cuando la estación no es apta [S]
- [x] Incrementar grown_days y recalcular etapa solo si procede [S]
- [x] Emitir crop_ready solo en la transición a LISTA [S]
- [x] Guardar planted_at_day para determinismo entre cargas [S]
- [x] No usar tiempo real ni reloj del sistema (regla anti-exploit, M30) [S]

## G. Riego y agua (8)

- [x] Nivel de agua 0..2 persistente por cultivo [S]
- [x] Regadera (M13) suma 1 con feedback visual y sonoro [S]
- [x] Lluvia (M32) rellena cultivos expuestos sin techo [M]
- [x] Exceso de riego sin castigo (feedback juguetón) [S]
- [x] Visual de suelo húmedo (variante húmeda del bloque TIERRA_ARADA) [M]
- [x] Tooltip "Echó de menos el agua" cuando SIN_AGUA [S]
- [x] Sin muerte por falta de agua (regla innegociable M152) [S]
- [x] VFX de gotas (M52) de bajo costo al regar [M]

## H. Herramientas e interacción (8)

- [x] Pala (M13) convierte TIERRA en TIERRA_ARADA [M]
- [x] Interacción F sobre tierra arada abre selector de semillas (M70/M53) [M]
- [x] Interacción sobre cultivo en LISTA cosecha [S]
- [x] Interacción sobre cultivo en otros estados muestra hint contextual [S]
- [x] Animación de la herramienta sincronizada con el evento (M44) [M]
- [x] Cancelación segura del selector sin consumir semillas [S]
- [x] Rango de uso limitado al alcance del jugador (M11) [S]
- [x] Debounce de interacción para evitar dobles plantas [M]

## I. Integración mundo voxel M08 (9)

- [x] Añadir bloque TIERRA_ARADA al catálogo de bloques [S]
- [x] Añadir variante húmeda de tierra arada [S]
- [x] Aplicar dif de chunk al convertir tierra [M]
- [x] Colisión correcta de la tierra arada (no es un hueco) [M]
- [x] Registrar instancias de planta vía VoxelInstanceModifier [C]
- [x] Consistencia entre diccionario FarmService y mundo voxel al cargar [C]
- [x] Actualización parcial del chunk al cosechar (vuelve a tierra arada) [M]
- [x] Nieve (M32/M08) sobre tierra arada no borra el estado [C]
- [x] Evitar plantar sobre bloques no expuestos (validación de cara superior) [M]

## J. Integración M14/M15/M16 (8)

- [x] Consumo de semilla vía InventoryService.try_remove [S]
- [x] Entrega de cosecha vía InventoryService.try_add con sobrante [S]
- [x] Referencia de item_id del catálogo M15 en CropDefinition [S]
- [x] Recetas M16 consumen cultivos ya cosechados (sin tocar CropTile) [S]
- [x] Notificación de objetos obtenidos al cosechar (M53) [S]
- [x] Iconos de cultivos y semillas definidos en M45/M46 [M]
- [x] Venta de cosechas con precios por calidad (M38/M39) [M]
- [x] Sin acoplamiento inverso: M14/M15 nunca escriben estado de FarmService [S]

## K. Edge cases (12)

- [x] Cultivo plantado el último día de la estación apta [S]
- [x] Cultivo en DORMANTE al pasar a estación apta: retoma sin pérdida [S]
- [x] Sequía prolongada: pausa indefinida sin muerte [S]
- [x] Pisoteo de NPC: agitación visual sin pérdida de progreso [M]
- [x] Navegación M64 evita celdas cultivadas cuando hay ruta alternativa [C]
- [x] Dos jugadores (futuro M76) no pueden plantar el mismo voxel [C]
- [x] Cosecha con inventario lleno: sobrante devuelto con notificación [M]
- [x] Árbol frutal en invierno: entra en DORMANTE y conserva cooldown [S]
- [x] Carga de guardado con tile corrupto: FarmStateStore.validate lo aísla y loguea [M]
- [x] Borrado de parcela (M17) con cultivos activos: aviso previo y devolución de semillas [M]
- [x] Guardado a mitad del avance de día: el tick es idempotente [C]
- [x] Lluvia sobre cultivo ya regado: no excede el máximo [S]

## L. Optimización M61 (8)

- [x] Evaluación diaria ≤ 2 ms con 400 cultivos [C]
- [x] Visual por MultiMesh agrupado por especie/etapa [C]
- [x] LOD de 2 niveles para instancias [M]
- [x] Sway por shader de instancing sin nodos por planta [C]
- [x] Sin procesamiento por frame en estados pausados [S]
- [x] CropTile como RefCounted (cero nodos por cultivo) [S]
- [x] Estadísticas de farm en el profiler de M113 [M]
- [x] Prueba de stress: 400 cultivos + lluvia global en 1 tick [C]

## M. UI, audio y polish cozy (10)

- [x] HUD agrícola: indicador de estado por cultivo apuntado (M53) [M]
- [x] Notificación cozy al madurar cultivos [S]
- [x] Tooltip con hints legibles y cálidos [S]
- [x] Tutorial amable: "La comida es opcional aqui" (M92, M152) [S]
- [x] Sonido de arar (M43/M44) con capa ASMR de tierra [M]
- [x] Sonido de regar con goteo suave [S]
- [x] Sonido de cosecha satisfactoria [S]
- [x] VFX de polvo al arar y brillo al madurar (M52) [M]
- [x] Animación de sway según el viento del clima (M31/M32) [M]
- [x] Cambios estacionales visibles en el campo (tono de plantas) [M]

## N. Pruebas y QA (8)

- [x] Test: ciclo completo arar/plantar/regar/cosechar en una sesión [M]
- [x] Test: determinismo entre guardado y recarga (mismo día, mismo estado) [M]
- [x] Test: 4 estaciones con cultivo de ventana parcial [M]
- [x] Test: 30 días sin agua: pausa, nunca muerte [M]
- [x] Test: pisoteo de NPC sobre campo con ruta y sin ruta [C]
- [x] Test: invierno con nieve sobre tierra arada [C]
- [x] Test: inventario lleno al cosechar [S]
- [x] Recorrido M114: 3 días de juego con granja funcional [C]

## O. Delegación y cierre (8)

- [x] Módulo marcado delegable (requiere M08, M14, M29 implementados) [S]
- [x] 5 alternativas descartadas documentadas en 02-Analisis [S]
- [x] API estable del FarmService definida en 03-Diseno [S]
- [x] Implementación → AGENTE DELEGADO [S]
- [x] Prototipo sugerido: 3 cultivos + riego manual + avance diario [S]
- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis, 03-Diseno y 04-Codigo creados y firmados [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]