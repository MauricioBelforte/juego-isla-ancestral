# Informe consolidado de evaluación — Nemotron-3.5-Super-VL

**Supervisora:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-18 18:00 UTC  
**Modelos evaluados:** Glyph Cluster, Reflection-Beam-1.0  
**Período:** 06:00 UTC del 18-nov al 18:00 UTC del 18-nov

---

## 1. Resumen ejecutivo

Se recibieron 2 reportes nuevos en el período (1 de Glyph Cluster, 1 de Beam). Ambos cumplen el formato obligatorio: archivo:línea, severidad, accionable y 2 mejoras de diseño concretas.

**Glyph Cluster** entregó auditoría de arquitectura del módulo 04-Game-Engine con 11 hallazgos (3 Altos, 5 Medios, 3 Bajos, 1 Ruido) y 2 mejoras de diseño concretas (orquestador único de flujo/registro declarativo de servicios).

**Reflection-Beam-1.0** entregó auditoría de consistencia de contadores del módulo 105-Telemetría con 15 hallazgos (2 Altos, 7 Medios, 4 Bajos/Bajo-Medio, 1 subsumido) y 2 mejoras de diseño concretas (registro atómico de métricas + capa de validación y reconciliación).

Ambos modelos han cubierto todas las tareas disponibles en sus nichos. No quedan tareas nuevas sin repetir.

---

## 2. Hallazgos Críticos y Altos con archivo:línea

### Glyph Cluster

| # | Severidad | Archivo:línea | Hallazgo |
|---|-----------|---------------|----------|
| GC-20 | Alto | scripts/core/bootstrap.gd:36,49-55,60-83,90-115,122-133,175-183; scripts/core/scene_manager.gd:13-15,32-49,61-73,81-88,94-128,133-137,141-160; scripts/core/game_flow_manager.gd:27,31-46,64-73 | Orquestación de arranque/flujo fragmentada: Bootstrap, SceneManager y GameFlowManager mantienen canales paralelos de estado, canales de notificación duplicados y mutaciones cruzadas de FSM sin un único propietario. |
| GC-21 | Alto | scripts/core/service_registry.gd:11,22-38,52-68,74-75; scripts/core/bootstrap.gd:16-18,23-33,64-83,136-160,175-183,216-218; scripts/core/contratos.gd:1-39 | Acoplamiento global por Service Locator con strings mágicos y registro inconsistente; accesos directos a `/root/*` coexisten con contratos sin que exista fuente única de verdad efectiva. |
| GC-22 | Alto | scripts/saving/save_manager.gd:21-50,80-120,231,317 | `SaveManager` concentra persistencia, política de autosave e integración de dominios EventBus (marcar dirty, disparar/bloquear autosave, acceso directo a `/root/EventManager` y `/root/DataStore`), generando alto radio de impacto ante cambios. |
| GC-23 | Medio | scripts/core/softlock_guard.gd:13-22,57-66,70-80 | `SoftlockGuard` acoplado rígido a implementaciones concretas (`_IRecoverable`, `Jugador/Mision/Npc/ObjetoClave/Vehiculo/PuzzleInvariant`, `CofreRecuperacion`, `CheckpointManager`) y consulta directa a `/root/EventBus` y `/root/SaveManager`. |
| GC-24 | Medio | scripts/core/project.godot:22,25-27,30,34,40,44,95-96,99,106; scripts/core/bootstrap.gd:49-55,90-95; scripts/logging/logger.gd:89-100; scripts/saving/save_manager.gd:84-91 | Dependencias ocultas por orden de inicialización de autoloads; la corrección depende del orden textual en `project.godot` y compensaciones con `call_deferred`. |
| GC-25 | Medio | scripts/core/scene_manager.gd:32-49,61-73,94-128,133-137; scripts/core/game_flow_manager.gd:13-25,31-46,64-73; scripts/core/bootstrap.gd:90-115 | Acoplamiento bidireccional de orquestación entre `SceneManager` y `GameFlowManager`: conocimiento mutuo de estados/enums, fallbacks cruzados y sincronización en ambos sentidos. |
| GC-26 | Medio | scripts/logging/logger.gd:33,71,80-100 | `Logger` con dependencias ocultas (precarga `CrashLogBridge`, ruta fija de log, autoregistro vía `/root`, conexión diferida `CrashReporter`) y múltiples responsabilidades (config, formato/sanitización, IO/rotación, eco consola, señal UI). |
| GC-27 | Medio | scripts/core/terrain_locator.gd:14,16-24,25-41,45-52,56-73 | `TerrainLocator` acoplado a estructura de escena (búsqueda por nombre `VoxelTerrain`), reintento cada `_process` y API interna del generador (`_get_island_gen().get_height(...)`). |

### Reflection-Beam-1.0

| # | Severidad | Archivo:línea | Hallazgo |
|---|-----------|---------------|----------|
| BM-28 | Alto | scripts/telemetry/telemetry_director.gd:378-421 | 6 de 13 trackers no registran `METRIC_TIME_TO_FIRST_DISCOVERY` (`track_museum_first_visited`, `track_festival_first_participated`, `track_community_project_first_completed` y otros omiten discovery); si la primera discovery es viaje/museo/festival/proyecto, el contador queda en 0. |
| BM-29 | Alto | scripts/telemetry/telemetry_director.gd:405-408 | `track_travel_first_completed` registra solo `METRIC_TIME_TO_FIRST_TRAVEL`, omitiendo `discovery` (subsumido en BM-28, mantenido por trazabilidad independiente). |
| BM-30 | Medio-Alto | scripts/telemetry/telemetry_director.gd:434-441 | `track_difficulty_perceived` no valida `rating` (1-5), no deduplica por `puzzle_id`, bypassa `_track_first` y `_registrar_metrica`, y emite aunque `ads == null`. |
| BM-31 | Medio | scripts/telemetry/telemetry_director.gd:463-479 | `complete_puzzle` emite `PUZZLE_FIRST_COMPLETED` en cada completado (no solo el primero), inflando el contador de eventos "first" vs la métrica `METRIC_TIME_TO_FIRST_PUZZLE` que sí deduplica. |
| BM-32 | Medio | scripts/telemetry/telemetry_director.gd:490-496 | `start_puzzle` sobrescribe `_puzzle_inicio[puzzle_id]` si se llama dos veces sin completar, perdiendo el tiempo transcurrido y reiniciando la ventana de abandono. |
| BM-33 | Medio | scripts/telemetry/telemetry_director.gd:507-512 | `enter_zone` sobrescribe `_zona_entrada` si se llama dos veces, mismo patrón de sobrescritura. |
| BM-34 | Medio | scripts/telemetry_bridge.gd:120-180 / `_despachar` (líneas ~182-195) | `_despachos` se incrementa en cada despacho aunque `track_*` no emita nada (opt-out o dedup); `_descartes` solo cuenta null/inválido/método ausente. Drift entre "despachos" y eventos realmente aceptados. |
| BM-35 | Medio | scripts/telemetry/analytics_director.gd:80-85 | `_agregados[tipo]` se incrementa en cada `registrar_evento`, pero `pop_front()` al superar `max_buffer` (500) no decrementa `_agregados`. Totales agregados > eventos retenidos → drift entre buffer y agregado. |
| BM-36 | Bajo-Medio | scripts/telemetry/analytics_director.gd:133-138 + scripts/telemetry/telemetry_director.gd:334-337 | `_duracion_sesion()` de Analytics usa `_inicio_sesion_ms` propio (seteado en `_ready`), mientras Telemetry usa el suyo propio (seteado en `_iniciar_sesion`). Diferencia ms vs segundos → `session_duration` y `duracion_seg` pueden diferir. |

---

## 3. Mejoras de diseño propuestas (por modelo)

**Glyph Cluster:**
1. Unificar el orquestador de flujo y carga (Composition Root de runtime): introducir un único punto de control que exponga operaciones atómicas como `iniciar_boot()`, `ir_a_mundo()`, `solicitar_cambio_escena(ruta, estado_objetivo)`.
2. Registro declarativo y contratos obligatorios para servicios de motor: manifiesto único de composición (recurso `res://data/core_services.tres`/JSON o módulo de registro generado desde `Contratos`) que defina contrato, autoload/implementación, fase de inicialización y dependencias requeridas.

**Reflection-Beam-1.0:**
1. Registro atómico de métricas en `_track_first`: extender para que, al primer éxito, registre todas las métricas asociadas en una sola operación (incluyendo `METRIC_TIME_TO_FIRST_DISCOVERY` por defecto salvo exclusión explícita).
2. Capa de validación de entrada + reconciliación: añadir `_validar_id(id)` en `start_puzzle`, `enter_zone`, `track_*`; clampear `rating` a [1,5] en `track_difficulty_perceived` con dedup por puzzle; guards de reentrada; y un método `verificar_consistencia()` que compare keys de `_tracked` vs métricas registradas y reporte drift.

---

## 4. Decisión requerida del director (agnes-3-flash)

Opciones `[ ]` para acción:

[ ] **A** Mantener supervisión de ambos modelos sin asignar tareas nuevas hasta que el director defina nuevas áreas de auditoría.

[ ] **B** Reasignar a Glyph Cluster una tarea ya completada — **NO recomendado** (violaría regla de no repetir).

[ ] **C** Reasignar a Beam una tarea ya completada — **NO recomendado** (violaría regla de no repetir).

**Recomendación del supervisor:** opción **A**.

---

## 5. Nuevas tareas asignadas a cada modelo

| Modelo | Sesión | Tarea asignada | Estado |
|--------|--------|----------------|--------|
| Glyph Cluster | ses_e1050bb20ffeCV2UQsZFHUI0Sr | Auditar arquitectura del motor de juego (04-Game-Engine) | Entregado (2026-11-18 17:23) |
| Reflection-Beam-1.0 | ses_e1049bbe8ffeXvYXk4QcXf5jOj | Auditar consistencia de contadores de telemetría (105-Telemetría) | Entregado (2026-11-18) |

**Nota:** No hay tareas nuevas que asignar a ninguno de los dos modelos sin repetir tareas ya entregadas. Ambas sesiones están `idle`.

---

## 6. Próximo reporte al director

Programado para 2026-11-19 00:00 UTC (múltiplo de 6, minuto 0), si hay reportes nuevos desde este informe.

---

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-18 18:00 UTC
