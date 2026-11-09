# Reporte de rendimiento — `game/isla-ancestral/scripts/`

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08  
**Alcance:** análisis estático de scripts GDScript bajo `game/isla-ancestral/scripts/`, con foco en rendimiento/FPS, rutas calientes (`_process`/`_physics_process`), bucles costosos, culling/LOD y oportunidades de mejora.

## Resumen ejecutivo

- **Sí hay medición de FPS/frame-related data**, pero principalmente en herramientas de **debug/UI de depuración** y pruebas, no como telemetría de rendimiento integrada al gameplay runtime.
- Existen **varios `_process`/`_physics_process` en runtime**; algunos son razonables (timers/acumuladores), pero hay puntos con riesgo de coste: búsqueda/reintento de nodos por frame (`TerrainLocator`), instanciación masiva diferida en vegetación, generación procedural con bucles anidados en terreno/mundo, y procesamiento de colas.
- **No se observan bucles infinitos evidentes** en runtime de gameplay; sí hay `while` acotados en generación/streaming (`terreno_horizonte.gd`, `stream_manager.gd` en contexto de presupuesto/reintentos según uso). No hay un O(n²) obvio en una ruta caliente de gameplay por frame, pero sí **bucles anidados** en generación/carga que pueden ser costosos cuando se ejecutan.
- **Sí hay culling/LOD parciales**: configuración lógica en `graphics_config.gd`, LOD/culling conceptual en VFX (`vfx_loops.gd`), coronas LOD/pisos en streaming (`stream_manager.gd`), y lógica de distancia/radio. Sin embargo, parte del LOD/culling está **modelado como datos/mapeo** o depende de integración runtime (M50/M53), no siempre aplicado automáticamente al render.
- Se recomiendan 2 mejoras prioritarias: (1) eliminar/restringir el polling por frame en `TerrainLocator` y cachear referencias; (2) diferir y presupuestar la carga/instanciación de vegetación y generación de horizonte para evitar picos.

## 1) ¿Hay medición de FPS o frame time?

### Evidencia encontrada

- **Overlay/contador de FPS en debug (UI):** `game/isla-ancestral/scripts/debug/debug_menu_ui.gd`
  - L31: comentario indica lectura de `Engine.get_frames_per_second()`.
  - L42-43: refresco cada 0.5 s (`FPS_INTERVALO`).
  - L131-147: crea `FpsOverlay` + `Timer` y conecta `_actualizar_fps`.
  - L214: `_fps_overlay.text = "FPS: %d" % Engine.get_frames_per_second()`.
- **Métricas de rendimiento en debug backend:** `game/isla-ancestral/scripts/debug/debug_menu.gd`
  - L509: actualiza texto FPS con `Engine.get_frames_per_second()` (con refresco acotado).
  - L623-626, L823-826, L846: usa `Performance.get_monitor(...)` (`TIME_FPS`, `OBJECT_COUNT`, `OBJECT_NODE_COUNT`, `OBJECT_ORPHAN_NODE_COUNT`, `MEMORY_STATIC`).
- **Límite/cap de FPS configurable:** `game/isla-ancestral/scripts/settings/graphics_config.gd`
  - L120-122: opciones de FPS (`30, 60, 120, 0`).
  - L406-413: `apply_fps_cap()` aplica `Engine.max_fps`.
- **Presupuesto por frame en streaming:** `game/isla-ancestral/scripts/stream/stream_manager.gd`
  - L10, L45: menciona objetivo/presupuesto `delta < 50 ms` / `PRESUPUESTO_MS = 40.0`.
  - L237+: `_process(delta)` procesa cola con presupuesto temporal (`Time.get_ticks_usec()`), lo cual es una forma de control de frame budget.
- **Pruebas/headless usan monitores de rendimiento:** p. ej. `game/isla-ancestral/scripts/rendimiento/memoria/test_m62_*.gd` consulta `Performance.OBJECT_COUNT` / huérfanos.

### Conclusión punto 1

**Sí existe medición de FPS y señales relacionadas con frame/performance**, pero está concentrada en **debug**, **configuración de cap** y **tests**. No se identificó un sistema runtime de gameplay que registre continuamente frame time/FPS para telemetría productiva o adaptación automática (más allá del presupuesto del stream manager).

## 2) ¿Hay procesos pesados en `_process`/`_physics_process` que puedan causar caídas de FPS?

### Hallazgos relevantes

- **`TerrainLocator` reintenta búsqueda en cada frame hasta encontrar terreno:** `game/isla-ancestral/scripts/core/terrain_locator.gd`
  - L20-23: `_process(_delta)` ejecuta `_buscar_terreno()` si `_terrain` es nulo/inválido.
  - L25-35: `_buscar_terreno()` hace `get_node_or_null("VoxelTerrain")` y fallback `_find_in_tree(get_tree().root)`.
  - L37-43: `_find_in_tree()` recorre hijos recursivamente.
  - **Riesgo:** coste bajo una vez resuelto, pero puede ser **costoso y repetitivo por frame** durante arranque/escenas donde el terreno tarda en aparecer o nunca existe; la búsqueda recursiva sobre el árbol completo es especialmente sensible.

- **Detección de terreno por raycast con temporizador (razonable, pero en física):** `game/isla-ancestral/scripts/terrenos/terrain_detector.gd`
  - L63-67 aprox. (`_physics_process`): acumula `detection_timer += delta` y hace detección periódica (patrón habitual).
  - **Riesgo:** moderado; depende de frecuencia de raycasts y coste del provider. No se ve O(n²), pero conviene validar intervalo/capas.

- **Partículas y huellas por terreno en física:**  
  - `game/isla-ancestral/scripts/terrenos/terrain_particles.gd` L78-87, L138+: `_physics_process` gestiona activos, timers y emisión de ráfagas.
  - `game/isla-ancestral/scripts/terrenos/terrain_footprints.gd` L87-88, L180+: `_physics_process` gestiona activos/tiempos.
  - **Riesgo:** controlado por pooling (`max_emisores`, reutilización) y duración; puede escalar mal con muchos emisores/jugadores si se amplía sin límites.

- **Vegetación: carga e instanciación diferida, pero potencialmente pesada en un único pase:** `game/isla-ancestral/scripts/vegetacion/vegetation_spawner.gd`
  - L43-51: usa `_process` solo para esperar 2 frames y luego desactiva proceso + llama `_poblar()`.
  - L53-109: `_poblar()` genera plan e itera **todos los ítems**; por ítem hace `FileAccess.file_exists`, `load(ruta)`, `instantiate()`, consultas al locator, y `add_child()`.
  - **Riesgo alto de pico (hitch)** al poblar, no por frame continuo, pero sí por **trabajo masivo síncrono** en el momento de población.

- **Terreno/horizonte procedural con bucles y generación progresiva:** `game/isla-ancestral/scripts/world/terreno_horizonte.gd`
  - L114-125: `_process` avanza generación por filas con límite `FILAS_POR_FRAME` (buena práctica).
  - L160-191, L231-316: bucles `while`/`for` anidados para tiles, corona y malla.
  - **Riesgo:** puede ser pesado según tamaño de malla/tiles; el fraccionamiento por frame mitiga, pero la complejidad total es alta.

- **Streaming con presupuesto temporal:** `game/isla-ancestral/scripts/stream/stream_manager.gd`
  - L237+: `_process` drena cola respetando `PRESUPUESTO_MS` (40 ms) y reencola operaciones threaded en progreso.
  - **Riesgo mitigado:** diseño consciente de presupuesto; aun así, callables/cargas pueden introducir variabilidad.

- **Carga visual simple sin bucles pesados:** `game/isla-ancestral/scripts/stream/pantalla_carga.gd` L173+: `_process` para rotación/fundido; coste bajo.

- **Prototipo de jugador:** `game/isla-ancestral/scripts/prototipo/player_proto.gd` L8: `_physics_process` básico (gravedad). Bajo riesgo.

### Conclusión punto 2

**Sí hay procesos con potencial de impacto en FPS/frame pacing**. Los más relevantes son: **`TerrainLocator._process` con búsqueda recursiva repetida**, **población síncrona de vegetación** (pico puntual), y **generación procedural del horizonte/mundo** (coste alto aunque parcialmente fraccionado). Otros `_process/_physics_process` observados son mayormente temporizadores/gestión de pools con riesgo moderado.

## 3) ¿Hay bucles infinitos o operaciones O(n^2) en rutas calientes?

### Evidencia

- **No se identificaron bucles infinitos evidentes** (`while true` sin salida clara) en scripts runtime revisados. Los `while` observados tienen condiciones acotadas:
  - `terreno_horizonte.gd`: `while _fila_actual < _fila_max ...`, `while x < x_max`, `while z < t_z1` (L118, L160, L180, L182).
  - `stream_manager.gd`: bucle de procesamiento condicionado por cola/presupuesto (patrón de drenado acotado).
- **Bucles anidados presentes (coste potencialmente alto, no necesariamente O(n^2) por frame de gameplay):**
  - `game/isla-ancestral/scripts/world/world_generator.gd` L39-44: triple bucle anidado `for z / for x / for y` sobre volumen (`size.x*size.y*size.z`) — **costoso**, pero típicamente generación/carga, no per-frame gameplay.
  - `game/isla-ancestral/scripts/world/terreno_horizonte.gd` L170-191: bucles anidados por tiles/celdas para construir geometría — **costoso**; mitigado parcialmente por `FILAS_POR_FRAME`.
- **Riesgo O(n^2) no confirmado en hot paths por frame:** las iteraciones sobre arrays de activos en partículas/huellas son lineales sobre elementos activos; no se ve comparación todos-con-todos. El mayor riesgo algorítmico observado es **complejidad volumétrica/anidada en generación**.

### Conclusión punto 3

**No hay evidencia clara de bucles infinitos ni O(n²) en rutas calientes de gameplay por frame.** Sí existen **bucles anidados y recorridos volumétricos** en generación de mundo/horizonte y un bucle lineal de instanciación masiva en vegetación, que pueden provocar **picos de CPU** cuando se ejecutan.

## 4) ¿Hay culling o LOD para reducir carga?

### Evidencia

- **Configuración lógica de culling/LOD:** `game/isla-ancestral/scripts/settings/graphics_config.gd`
  - L75-83: define `CULLING` (`frustum`, `por_distancia`) y `LOD` (`habilitado`, `distancia`, `niveles`), con nota de que LOD por objeto depende de M50.
  - L385-391: `mapeo_culling()` expone flags y `cull_distance_metros`.
  - L488+: `mapeo_lod()` expone mapeo lógico.
  - **Importante:** estas funciones son **mapeo/lógica de configuración**; la aplicación efectiva al motor/escena depende de integraciones runtime (M53/M90/M50). La búsqueda no mostró uso runtime amplio de `mapeo_culling/mapeo_lod` fuera de settings/tests.

- **LOD/culling en VFX por distancia:** `game/isla-ancestral/scripts/particles/vfx_loops.gd`
  - L8-11: menciona “loops registrados con culling” y “LOD de emisores (25% lejos)”.
  - L24-25, L84-90, L101: factores `LOD_CERCA/LOD_LEJOS`, `factor_lod()` y reducción de cantidad por distancia.
  - L72: culling por distancia al centro de la zona.

- **Streaming por región/coronas LOD/pisos:** `game/isla-ancestral/scripts/stream/stream_manager.gd`
  - L22: menciona “coronas LOD del océano, pisos del subterráneo”.
  - L35-36: pesos `chunk_lod0/chunk_lod1`.
  - L284, L462+: lógica relacionada con tipos LOD/coronas (según resultados de búsqueda).
  - Esto actúa como **gestión de carga/descarga por nivel de detalle/región**, complementaria al render culling.

- **Vegetación/instancias:** `game/isla-ancestral/scripts/vegetacion/vegetation_spawner.gd` instancia ítems del plan y omite casos (sin archivo, en agua), pero **no se observa LOD dinámico ni culling por distancia** en el spawner revisado.

### Conclusión punto 4

**Sí hay mecanismos parciales de culling/LOD**: LOD por distancia en VFX, streaming con nociones de LOD/región, y configuración de culling/LOD en `GraphicsConfig`. Sin embargo, el **culling/LOD de render/objetos** no parece estar completamente aplicado de forma centralizada desde `GraphicsConfig` en runtime; parte queda como diseño/mapeo o dependencia de módulos posteriores.

## 5) Sugerencias de mejora de rendimiento (2)

### Mejora 1 — Eliminar polling recursivo por frame en `TerrainLocator`
- **Archivo/líneas:** `game/isla-ancestral/scripts/core/terrain_locator.gd` L20-43.
- **Problema:** `_process` reintenta `_buscar_terreno()` cada frame mientras el terreno no está disponible; el fallback recorre recursivamente todo el árbol (`_find_in_tree(get_tree().root)`).
- **Acción propuesta:**
  - Reemplazar el polling continuo por **búsqueda diferida con backoff** (p. ej. cada 0.5–1.0 s usando acumulador de delta) o por **señales/eventos** cuando el `VoxelTerrain` se registre.
  - Cachear el resultado y desconectar/desactivar `_process` al encontrar el terreno.
  - Limitar `_find_in_tree` a grupos/nombres conocidos o registrar el terreno en un autoload/singleton al crearse.
- **Impacto esperado:** reduce CPU desperdiciada en arranque/escenas sin terreno y evita recorridos costosos del árbol por frame.

### Mejora 2 — Presupuestar/diferir la instanciación de vegetación y generación pesada
- **Archivos/líneas:**
  - `game/isla-ancestral/scripts/vegetacion/vegetation_spawner.gd` L53-109 (`_poblar()` carga/instancia todo el plan en una pasada).
  - `game/isla-ancestral/scripts/world/terreno_horizonte.gd` L114-191 (generación progresiva, pero con bucles anidados por tile/celda).
- **Problema:** `VegetationSpawner` hace `FileAccess.file_exists`, `load()` e `instantiate()` para cada ítem del plan en un solo bloque; esto puede causar **stutter/hitch** perceptible. El horizonte ya fracciona por filas, pero la construcción de tiles/corona puede seguir siendo pesada.
- **Acción propuesta:**
  - Convertir `_poblar()` en **proceso incremental**: cola de ítems y procesar N ítems por frame con presupuesto de ms (patrón similar a `StreamManager.PRESUPUESTO_MS`).
  - Reutilizar recursos con cache de `PackedScene` por ruta (`load()` una vez por tipo) y considerar `ResourceLoader.load_threaded_request()` para assets grandes.
  - Para horizonte, mantener/ajustar `FILAS_POR_FRAME` dinámicamente según frame time, o mover generación de mallas pesadas a pasos más pequeños/hilos cuando sea viable.
- **Impacto esperado:** mejora frame pacing en carga inicial/poblado, reduce picos de frametime y hace el coste escalable al tamaño del plan/mundo.

## Observaciones adicionales

- `GraphicsConfig` define capacidades de rendimiento (culling/LOD/FPS/upscaling), pero conviene verificar que `apply_fps_cap()` y los mapeos se invoquen en el flujo real de arranque/menú de opciones.
- Hay abundante instrumentación en tests (`Performance.get_monitor`, mediciones de objetos/huérfanos), lo cual es positivo para detectar regresiones; faltaría un **smoke/perf check runtime** opcional en builds de desarrollo.

## Conclusión final

El proyecto **tiene bases de control de rendimiento** (cap de FPS, presupuesto en streaming, overlays/monitores en debug, LOD/culling en VFX y configuración lógica), pero presenta **riesgos concretos de picos de CPU** por polling recursivo en `TerrainLocator` y por carga/instanciación masiva síncrona en vegetación/generación. Priorizar la eliminación del polling por frame y la fragmentación presupuestada de cargas/instanciaciones aportaría la mejora más directa al frame pacing.
