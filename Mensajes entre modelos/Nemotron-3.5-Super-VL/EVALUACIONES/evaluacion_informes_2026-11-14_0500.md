# Informe consolidado de evaluación — Nemotron-3.5-Super-VL

**Supervisora:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-14 05:00 UTC  
**Modelos evaluados:** Glyph Cluster, Reflection-Beam-1.0  
**Período:** reportes entregados 2026-11-13 (desde el último informe consolidado)

---

## 1. Resumen ejecutivo

Se recibieron 12 reportes nuevos (8 de Glyph Cluster, 4 de Reflection-Beam-1.0) el 2026-11-13. Ambos modelos cubrieron la totalidad de las tareas disponibles en sus respectivos nichos; no quedan tareas sin asignar sin repetir.

Se detectaron **17 hallazgos Críticos/Altos** consolidados (8 Glyph Cluster / 9 Beam). Los más graves:
- Glyph Cluster: colisión de `class_name ActionPromptOverlay`, NPC sin `CollisionShape3D`, otorgamiento de hitos sin verificar condición, acoplamiento SceneManager↔GameFlowManager.
- Beam: 5 IDs duplicados en CHECKLIST-GLOBAL, desincronización String vs StringName en coleccionables, contadores de barter sin validar, reconciliación saldo/historial ausente.

Todas las 3 sesiones Agent Manager están `idle`. No hay tareas nuevas que asignar a ninguno de los dos modelos sin repetir tareas ya completadas.

---

## 2. Hallazgos Críticos y Altos con archivo:línea

### Glyph Cluster

| # | Severidad | Archivo:línea | Hallazgo |
|---|-----------|---------------|----------|
| GC-01 | Crítica | scripts/ui/widgets/action_prompt_overlay.gd:1 | Duplicación de `class_name ActionPromptOverlay` con scripts/ui/hud/action_prompt_overlay.gd:1 (colisión global, script incompatible con escena HUD). |
| GC-02 | Alta | scripts/ia_npc/npc_agent.gd:9 | `NPCAgent` extiende `CharacterBody3D` sin `CollisionShape3D` asignado; `move_and_slide()` no produce colisiones reales, NPCs atraviesan geometría. |
| GC-03 | Alta | scripts/core/scene_manager.gd:95-128 | Acoplamiento fuerte `SceneManager` ↔ `GameFlowManager`: conoce ruta `/root`, enum `Estado` por nombre, y llama `cambiar_estado` directamente. |
| GC-04 | Alta | scripts/core/softlock_guard.gd:92,151,169,173 | Acoplamiento fuerte a `SoftlockRules` vía `class_name` global (no autoload en project.godot). |
| GC-05 | Alta | scripts/core/terrain_locator.gd:14,49 | Acoplamiento fuerte a `VoxelTerrain` concreta y método `_get_island_gen()` en lugar de interfaz `ITerrainHeightProvider`. |
| GC-06 | Alta | scripts/ui/core/ui_manager.gd:222-226,480-486 | `push_layer` sobre `DialogLayer` no garantiza apertura (aborta si ya está en stack); `dialog_requested` puede no mostrarse. |
| GC-07 | Alta | scripts/ui/layers/dialog_layer.gd:10-14,41-58 | Dos implementaciones de diálogo (M53 `DialogLayer` y M21 `DialogueUI`) con rutas paralelas de activación. |
| GC-08 | Alta | scripts/ui/ui_root.gd:13,36 + scenes/ui/hud.tscn:14-16 | `UIRoot` y `HUDScreen` comparten `layer = 100`; orden de dibujo entre HUD y modales depende del árbol de escena. |
| GC-09 | Crítica | scripts/progresion/progression_manager.gd:248-253 | `_reevaluar()` otorga hito vía `marcar_hito()` sin verificar que la condición del hito sea verdadera (rompe invariante umbral→otorgamiento). |
| GC-10 | Alta | scripts/progresion/progression_manager.gd:43-47,378-406 | Caché de evaluación `_evaluacion_cache` nunca se invalida ante cambios de estadísticas; lecturas stale permanentes. |
| GC-11 | Alta | scripts/progresion/progression_manager.gd:933-958 | `restore_save_data` restaura hitos/stats pero no reconcilia ni reevalúa hitos pendientes contra stats restauradas. |

### Reflection-Beam-1.0

| # | Severidad | Archivo:línea | Hallazgo |
|---|-----------|---------------|----------|
| BM-01 | Crítica | CHECKLIST-GLOBAL.md:150,151 | ID 48 duplicado en dos filas (debe unificarse en una). |
| BM-02 | Crítica | CHECKLIST-GLOBAL.md:52,53 | ID 115 duplicado en dos filas. |
| BM-03 | Crítica | CHECKLIST-GLOBAL.md:66,67 | ID 127 duplicado en dos filas. |
| BM-04 | Crítica | CHECKLIST-GLOBAL.md:81,83 | ID 139 duplicado en dos filas. |
| BM-05 | Crítica | CHECKLIST-GLOBAL.md:93,94 | ID 148 duplicado en dos filas. |
| BM-06 | Crítica | scripts/coleccionables/coleccionables_manager.gd:156-168 | `restore_save_data` desincroniza por tipo de clave: `_collected` usa `StringName`, `_categoria_collected` usa `String`; `collected_count()` devuelve 0 tras cargar. |
| BM-07 | Crítica | scripts/economia/barter_system.gd:137 | `_usos[npc_id]` incrementado sin validar signo ni magnitud; valores negativos desactivan el límite diario de trueques. |
| BM-08 | Crítica | scripts/economia/barter_system.gd:213-214 | `restore_save_data` restaura `_usos` sin saneamiento (valores negativos de save manipulan el límite). |
| BM-09 | Crítica | scripts/economia/economy_manager.gd:143-155 + 196-227 | No existe reconciliación entre `saldo` y suma de deltas del `historial`; save manipulado no se detecta. |
| BM-10 | Alto | CHECKLIST-GLOBAL.md:106 | Bloqueo stale M158: estado 🔵 En curso, agente agnes-3-flash, última actividad 2026-09-04 (68 días). |
| BM-11 | Alto | CHECKLIST-GLOBAL.md:83 | Bloqueo stale M139: estado 🔵 En curso, agente Hy4, última actividad 2026-10-14. |
| BM-12 | Alto | CHECKLIST-GLOBAL.md:81,83 | Drift M139: declarado 138/142 y 139/142, real 136/142. |
| BM-13 | Alto | CHECKLIST-GLOBAL.md:119 | Drift M17: declarado 135/175, real 141/175 (sobre-declaración de +6). |
| BM-14 | Alto | scripts/economia/progression_manager.gd:380-405 | `_evaluacion_cache` nunca se invalida; condiciones `false` quedan congeladas, hitos no se desbloquean vía `evaluar_condicion_id`. |
| BM-15 | Alto | scripts/economia/price_manager.gd:551-567 | Caché `_descuento_amistad` solo invalida por señal `nivel_amistad_cambio`; cambios de amistad por otras vías dejan descuento stale. |
| BM-16 | Alto | scripts/economia/progression_manager.gd:153,155 | Valores de señal (`q`, `cost`) pasados a `_stat()` sin validar signo; eventos negativos decrementan stats monotónicas. |
| BM-17 | Alto | scripts/economia/price_manager.gd:307-313 | `_cache_tabla_valida` no se invalida al cambiar de día si no hay ventas; UI muestra ventas del día anterior. |

---

## 3. Cubrimiento de tareas disponibles

| Modelo | Tareas disponibles | Completadas hoy | Restantes |
|--------|-------------------|-----------------|-----------|
| Glyph Cluster | acoplamiento core, UI, progresión, físicas/colisiones | 7 (event_bus, ui_auditoria, ui_arquitectura, dependencias_circulares_core, acoplamiento_core, progresión, físicas/colisiones) | 0 |
| Reflection-Beam-1.0 | CHECKLIST-GLOBAL, contadores economia/progresión, contadores coleccionables, fórmulas balance | 4 (reverificación_checklist_global, contadores_economia_progresion, contadores_coleccionables, fórmulas_balance) | 0 |

**Conclusión:** todos los trabajos disponibles para ambos modelos están completados. No hay tareas nuevas que asignar sin repetir. Las 3 sesiones Agent Manager permanecen `idle`.

---

## 4. Decisión requerida del director (agnes-3-flash)

Opciones `[ ]` para acción:

[ ] **A** Liberar a ambos modelos de supervisión activa (todas sus tareas disponibles completadas); mantener sesiones sin tarea hasta que surjan nuevos módulos en sus nichos.

[ ] **B** Mantener supervisión pero sin asignar tareas nuevas hasta que el usuario o el director defina nuevas áreas de auditoría para Glyph Cluster y Beam.

[ ] **C** Reasignar a Glyph Cluster una tarea ya completada (re-auditoría) — **NO recomendado** (violaría regla de no repetir).

[ ] **D** Reasignar a Beam una tarea ya completada — **NO recomendado** (violaría regla de no repetir).

**Recomendación del supervisor:** opción **A** o **B**. Ambos modelos entregaron reportes de calidad con archivo:línea y mejoras concretas; no hay justificación para re-asignar tareas ya hechas.

---

## 5. Nuevas tareas asignadas a cada modelo

| Modelo | Sesión | Tarea asignada | Estado |
|--------|--------|----------------|--------|
| Glyph Cluster | ses_e2921bcbcffeWnh7XHMMHPGLbg | Auditoría de físicas y colisiones (cuerpos sin shape, capas/máscaras, acoplamiento gameplay-física) | Entregado (REPORTE-2026-11-13_Fisicas-Colisiones.md) |
| Glyph Cluster | ses_e2921bc74ffe2ya1Llti9hViGL | — (sin tareas restantes) | Idle |
| Reflection-Beam-1.0 | ses_e2921bd21ffeOLG3GoKH08ZiGo | Re-verificación CHECKLIST-GLOBAL (IDs duplicados, bloqueos stale, drift) | Entregado (reporte_beam_reverificacion_checklist_global_2026-11-13.md) |

---

## 6. Próximo reporte al director

Programado para 2026-11-14 06:00 UTC (múltiplo de 6, minuto 0), si hay reportes nuevos desde este informe.

---

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-14 05:00 UTC
