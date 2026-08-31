**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

# 05-Checklist.md — Módulo 33: Agricultura

## A. Requisitos del módulo (10)

- [ ] Definir el problema: agricultura cozy opcional sin hambre castigadora, con ritmo diario del calendario [S]
- [ ] Registrar dependencias: M17, M29; relaciones M08, M14, M15, M16, M13, M31, M32, M64, M61, M53, M59, M52 [S]
- [ ] Catalogar los 25 puntos de la sección 32 del plan maestro [S]
- [ ] RF1: tierra cultivable y arada con pala (M13) [S]
- [x] RF2: parcelas con límite de cultivos activos (M17) [S]
- [ ] RF3: semillas como ítem de inventario (M14/M15) [S]
- [ ] RF4: etapas de crecimiento por CropDefinition [S]
- [ ] RF5: ciclos por día del GameClock (M29) [S]
- [ ] RF6: riego manual y por lluvia (M32) sin muerte por sequía [S]
- [x] RF7 a RF12: estaciones, cosecha, comida opcional, cultivos especiales, fertilizante y persistencia [S]

## B. Resolución de los 25 puntos del plan (25)

- [ ] P1: parcelas — reserva por jugador con `reserve_plot()` [S]
- [ ] P2: tierra cultivable — bloque TIERRA_ARADA del catálogo M08 [S]
- [ ] P3: semillas — catálogo M15 con consumo en M14 [S]
- [x] P4: crecimiento — avance por días acumulados [S]
- [ ] P5: etapas de crecimiento — enum GrowthStage de 7 estados [S]
- [ ] P6: riego — nivel de agua 0..2, regadera y lluvia [S]
- [ ] P7: fertilizantes — bono benigno que reduce días o mejora calidad [S]
- [x] P8: cosecha — event crop_harvested y entrega a M14 [S]
- [ ] P9: herramientas — pala y regadera integradas vía ToolService (M13) [S]
- [x] P10: estaciones — ventana por cultivo; fuera de ventana DORMANTE [S]
- [ ] P11: cultivos especiales — trigo invernal, higos, ancestrales de desbloqueo M22 [M]
- [x] P12: árboles frutales — perennes con cooldown frutal, sin replantar [M]
- [ ] P13: flores — decorativas y sujetas a cruce [M]
- [ ] P14: plantas ancestrales — lumina_ancestral con requisito narrativo [M]
- [ ] P15: híbridos — cruce de flores con reglas legibles (sin RNG oculto) [M]
- [ ] P16: calidad — 3 niveles (COMUN/BUENA/EXCELENTE) [M]
- [ ] P17: rendimiento — yields por cultivo con bonificación de calidad [S]
- [ ] P18: enfermedades — descartadas; el único estado reversible posible es el marchitado experimental [S]
- [x] P19: recuperación — siempre por riego o cambio de estación; cero pérdida de progreso [S]
- [x] P20: almacenamiento — la cosecha entra directa a M14, sin inventario de plantas [S]
- [ ] P21: recetas con cultivos — catálogo M16 (ensaladas, pan, tintes, ofrendas) [M]
- [ ] P22: venta — integración M38/M39 con precios por calidad [M]
- [ ] P23: semillas raras — reproducibles y con desbloqueo de progresión [M]
- [ ] P24: cultivos de isla — palma de coco y flor de coral exclusivas [M]
- [ ] P25: agricultura decorativa — helecho ornamental sin rendimiento [S]

## C. CropDefinition y catálogo (10)

- [ ] Crear clase CropDefinition extends Resource con campos exportados [S]
- [ ] Definir crop_id y display_name únicos por cultivo [S]
- [ ] Definir seasons por cultivo contra enum de GameClock (M29) [S]
- [ ] Definir grow_days y stage_count por cultivo [S]
- [x] Definir water_need (1 o 2) por cultivo [S]
- [ ] Definir yields y yield_seeds como diccionarios de ítems [S]
- [ ] Definir flags is_tree, is_flower, is_ancestral, decorative_only [S]
- [ ] Crear catálogo base de 16 .tres en res://data/farm/crops [S]
- [ ] Implementar CropCatalog.load_all con validación de IDs duplicados [M]
- [ ] Implementar is_season_allowed y get_stage_visual_key [S]

## D. CropTile y estados (9)

- [x] Crear CropTile extends RefCounted (estado puro por voxel) [S]
- [x] Campos: voxel_pos, crop_def, stage, grown_days, water_level, fertilized, quality, planted_at_day [S]
- [ ] Implementar is_ready(), is_paused(), current_stage_index() [S]
- [x] Implementar can_advance_today(season, rain) con reglas de estación y agua [S]
- [ ] Implementar apply_daily_tick(season, rain) sin retroceder etapas [S]
- [ ] Estado SEMILLA inicial con water 0 [S]
- [x] Estados DORMANTE y SIN_AGUA sin consumo de días [S]
- [ ] Estado LISTA estable sin requerir agua [S]
- [ ] transición de árboles frutales LISTA→MADURA con cooldown [M]

## E. FarmService y API (11)

- [ ] Crear autoload FarmService con registro en Service Locator (M07) [M]
- [x] Diccionario _tiles Vector3i→CropTile [S]
- [ ] Constante MAX_ACTIVE_CROPS = 400 [S]
- [ ] Implementar till_tile con validación de bloque y parcela [M]
- [ ] Implementar plant con consumo de semilla y cupo máximo [M]
- [ ] Implementar water con tope de nivel 2 [S]
- [ ] Implementar apply_rain (puente M32) [S]
- [ ] Implementar can_harvest y harvest con cálculo de calidad [M]
- [ ] Implementar get_tile y get_growth_hint (tooltips amables) [S]
- [ ] Implementar get_active_farm_stats para M113/M104 [M]
- [ ] Emitir las 8 señales del contrato en los puntos correctos [M]

## F. Crecimiento y calendario M29 (9)

- [ ] Suscribir FarmService a GameClock.day_advanced [S]
- [ ] Implementar advance_day() iterando solo tiles activos [S]
- [ ] Aplicar -1 de agua por día a cada cultivo [S]
- [ ] Detectar SIN_AGUA cuando water_level < water_need [S]
- [ ] Detectar DORMANTE cuando la estación no es apta [S]
- [ ] Incrementar grown_days y recalcular etapa solo si procede [S]
- [ ] Emitir crop_ready solo en la transición a LISTA [S]
- [ ] Guardar planted_at_day para determinismo entre cargas [S]
- [ ] No usar tiempo real ni reloj del sistema (regla anti-exploit, M30) [S]

## G. Riego y agua (8)

- [ ] Nivel de agua 0..2 persistente por cultivo [S]
- [ ] Regadera (M13) suma 1 con feedback visual y sonoro [S]
- [ ] Lluvia (M32) rellena cultivos expuestos sin techo [M]
- [ ] Exceso de riego sin castigo (feedback juguetón) [S]
- [ ] Visual de suelo húmedo (variante húmeda del bloque TIERRA_ARADA) [M]
- [ ] Tooltip "Echó de menos el agua" cuando SIN_AGUA [S]
- [ ] Sin muerte por falta de agua (regla innegociable M152) [S]
- [ ] VFX de gotas (M52) de bajo costo al regar [M]

## H. Herramientas e interacción (8)

- [ ] Pala (M13) convierte TIERRA en TIERRA_ARADA [M]
- [ ] Interacción F sobre tierra arada abre selector de semillas (M70/M53) [M]
- [ ] Interacción sobre cultivo en LISTA cosecha [S]
- [ ] Interacción sobre cultivo en otros estados muestra hint contextual [S]
- [ ] Animación de la herramienta sincronizada con el evento (M44) [M]
- [ ] Cancelación segura del selector sin consumir semillas [S]
- [ ] Rango de uso limitado al alcance del jugador (M11) [S]
- [ ] Debounce de interacción para evitar dobles plantas [M]

## I. Integración mundo voxel M08 (9)

- [ ] Añadir bloque TIERRA_ARADA al catálogo de bloques [S]
- [ ] Añadir variante húmeda de tierra arada [S]
- [ ] Aplicar dif de chunk al convertir tierra [M]
- [ ] Colisión correcta de la tierra arada (no es un hueco) [M]
- [ ] Registrar instancias de planta vía VoxelInstanceModifier [C]
- [ ] Consistencia entre diccionario FarmService y mundo voxel al cargar [C]
- [ ] Actualización parcial del chunk al cosechar (vuelve a tierra arada) [M]
- [ ] Nieve (M32/M08) sobre tierra arada no borra el estado [C]
- [ ] Evitar plantar sobre bloques no expuestos (validación de cara superior) [M]

## J. Integración M14/M15/M16 (8)

- [ ] Consumo de semilla vía InventoryService.try_remove [S]
- [ ] Entrega de cosecha vía InventoryService.try_add con sobrante [S]
- [ ] Referencia de item_id del catálogo M15 en CropDefinition [S]
- [ ] Recetas M16 consumen cultivos ya cosechados (sin tocar CropTile) [S]
- [ ] Notificación de objetos obtenidos al cosechar (M53) [S]
- [ ] Iconos de cultivos y semillas definidos en M45/M46 [M]
- [ ] Venta de cosechas con precios por calidad (M38/M39) [M]
- [ ] Sin acoplamiento inverso: M14/M15 nunca escriben estado de FarmService [S]

## K. Edge cases (12)

- [ ] Cultivo plantado el último día de la estación apta [S]
- [ ] Cultivo en DORMANTE al pasar a estación apta: retoma sin pérdida [S]
- [ ] Sequía prolongada: pausa indefinida sin muerte [S]
- [ ] Pisoteo de NPC: agitación visual sin pérdida de progreso [M]
- [ ] Navegación M64 evita celdas cultivadas cuando hay ruta alternativa [C]
- [ ] Dos jugadores (futuro M76) no pueden plantar el mismo voxel [C]
- [ ] Cosecha con inventario lleno: sobrante devuelto con notificación [M]
- [ ] Árbol frutal en invierno: entra en DORMANTE y conserva cooldown [S]
- [ ] Carga de guardado con tile corrupto: FarmStateStore.validate lo aísla y loguea [M]
- [ ] Borrado de parcela (M17) con cultivos activos: aviso previo y devolución de semillas [M]
- [ ] Guardado a mitad del avance de día: el tick es idempotente [C]
- [ ] Lluvia sobre cultivo ya regado: no excede el máximo [S]

## L. Optimización M61 (8)

- [ ] Evaluación diaria ≤ 2 ms con 400 cultivos [C]
- [ ] Visual por MultiMesh agrupado por especie/etapa [C]
- [ ] LOD de 2 niveles para instancias [M]
- [ ] Sway por shader de instancing sin nodos por planta [C]
- [ ] Sin procesamiento por frame en estados pausados [S]
- [ ] CropTile como RefCounted (cero nodos por cultivo) [S]
- [ ] Estadísticas de farm en el profiler de M113 [M]
- [ ] Prueba de stress: 400 cultivos + lluvia global en 1 tick [C]

## M. UI, audio y polish cozy (10)

- [ ] HUD agrícola: indicador de estado por cultivo apuntado (M53) [M]
- [ ] Notificación cozy al madurar cultivos [S]
- [ ] Tooltip con hints legibles y cálidos [S]
- [ ] Tutorial amable: "La comida es opcional aqui" (M92, M152) [S]
- [ ] Sonido de arar (M43/M44) con capa ASMR de tierra [M]
- [ ] Sonido de regar con goteo suave [S]
- [ ] Sonido de cosecha satisfactoria [S]
- [ ] VFX de polvo al arar y brillo al madurar (M52) [M]
- [ ] Animación de sway según el viento del clima (M31/M32) [M]
- [ ] Cambios estacionales visibles en el campo (tono de plantas) [M]

## N. Pruebas y QA (8)

- [ ] Test: ciclo completo arar/plantar/regar/cosechar en una sesión [M]
- [ ] Test: determinismo entre guardado y recarga (mismo día, mismo estado) [M]
- [ ] Test: 4 estaciones con cultivo de ventana parcial [M]
- [ ] Test: 30 días sin agua: pausa, nunca muerte [M]
- [ ] Test: pisoteo de NPC sobre campo con ruta y sin ruta [C]
- [ ] Test: invierno con nieve sobre tierra arada [C]
- [ ] Test: inventario lleno al cosechar [S]
- [ ] Recorrido M114: 3 días de juego con granja funcional [C]

## O. Delegación y cierre (8)

- [ ] Módulo marcado delegable (requiere M08, M14, M29 implementados) [S]
- [ ] 5 alternativas descartadas documentadas en 02-Analisis [S]
- [ ] API estable del FarmService definida en 03-Diseno [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Prototipo sugerido: 3 cultivos + riego manual + avance diario [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis, 03-Diseno y 04-Codigo creados y firmados [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]