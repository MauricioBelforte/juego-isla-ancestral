# Registro de reportes de mis agentes — Nemotron-3.5-Super-VL

**Supervisora:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-13  
**Propósito:** Registro de todo lo que le pido a los agentes bajo mi cargo, con su modelo LLM, tarea, estado y carpeta de reporte.

---

## 1. Agentes bajo mi cargo

| Modelo LLM | Plataforma | Nicho | Carpeta de reportes |
|------------|------------|-------|---------------------|
| Glyph Cluster | Kilo Code | Arquitectura de sistemas Godot, análisis GDScript, acoplamiento, dependencias circulares, arquitecturas de UI, progresión, físicas, colisiones | `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/` |
| Reflection-Beam-1.0 | Kilo Code | Auditoría de consistencia, contadores, fórmulas, off-by-one, verificación CHECKLIST-GLOBAL, conteos exactos | `Mensajes entre modelos/Reflection-Beam-1.0/REPORTES-Prueba-Paralela/` |
| HY4 Flash | Kilo Code | Tareas de alto volumen repetitivo, limpieza de backlogs, revisión de formato/documentación, verificación de checklists (formato, no contenido profundo), deep search ligero, documentación de tareas, bug triage asistido (no root-cause profundo), tareas de escritorio/oficina | `Mensajes entre modelos/HY4/REPORTES-Prueba-Paralela/` |

---

## 2. Tareas asignadas (historial)

| # | Fecha | Modelo | Tarea | Sesión Agent Manager | Estado | Carpeta de reporte | Archivo de reporte entregado |
|---|-------|--------|-------|---------------------|--------|--------------------|------------------------------|
| 1 | 2026-11-13 | Glyph Cluster | Acoplamiento fuerte y dependencias circulares entre autoloads en `scripts/core/` | `ses_e2d5d4e33ffe9FPJB5Yy6dFGeo` | Entregado | `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/` | `reporte_glyph_cluster_event_bus_2026-11-13.md` (entrega previa, 13-nov) |
| 2 | 2026-11-13 | Reflection-Beam-1.0 | Re-verificación de CHECKLIST-GLOBAL (IDs duplicados, bloqueos stale, drift de progreso) | `ses_e2d5d3ab2ffe2EPlen1BFw6Hm0` | Entregado | `Mensajes entre modelos/Reflection-Beam-1.0/REPORTES-Prueba-Paralela/` | `reporte_beam_reverificacion_checklist_global_2026-11-13.md` |
| 3 | 2026-11-13 | Glyph Cluster | Auditoría de arquitecturas de UI (`scenes/ui/`, `scripts/ui/`): mouse_filter, diálogo duplicado, CanvasLayer, señales | `ses_e2d5d4e33ffe9FPJB5Yy6dFGeo` | Entregado | `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/` | `reporte_glyph_cluster_ui_auditoria_2026-11-13.md` |
| 4 | 2026-11-13 | Reflection-Beam-1.0 | Auditoría de contadores en `scripts/economia/` y `scripts/progresion/`: validación de entrada, cachés, off-by-one, validación cruzada | `ses_e29ad8426ffe4s8jdBizgijfbB` | Entregado | `Mensajes entre modelos/Reflection-Beam-1.0/REPORTES-Prueba-Paralela/` | `reporte_beam_contadores_economia_progresion_2026-11-13.md` |
| 5 | 2026-11-13 | Glyph Cluster | Auditoría de arquitectura UI: capas de diálogo duplicadas, orden CanvasLayer, `mouse_filter` | `ses_e2921bc74ffe2ya1Llti9hViGL` | Entregado | `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/` | `reporte_glyph_cluster_ui_arquitectura_2026-11-13.md` |
| 6 | 2026-11-13 | Glyph Cluster | Dependencias circulares entre autoloads en `scripts/core/` | `ses_e2d5d4e33ffe9FPJB5Yy6dFGeo` | Entregado | `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/` | `reporte_glyph_cluster_dependencias_circulares_core_2026-11-13.md` |
| 7 | 2026-11-13 | Glyph Cluster | Acoplamiento fuerte entre autoloads en `scripts/core/` | `ses_e2921bcbcffeWnh7XHMMHPGLbg` | Entregado | `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/` | `REPORTE-2026-11-13_Acoplado-Core-Autoloads.md` |
| 8 | 2026-11-13 | Reflection-Beam-1.0 | Auditoría de contadores en `scripts/coleccionables/` no cubiertos | `ses_e29ad8426ffe4s8jdBizgijfbB` | Entregado | `Mensajes entre modelos/Reflection-Beam-1.0/REPORTES-Prueba-Paralela/` | `reporte_beam_contadores_coleccionables_2026-11-13.md` |
| 9 | 2026-11-13 | Reflection-Beam-1.0 | Verificación de fórmulas de balance de combate y economía | `ses_e29ad8426ffe4s8jdBizgijfbB` | Entregado | `Mensajes entre modelos/Reflection-Beam-1.0/REPORTES-Prueba-Paralela/` | `reporte_beam_formulas_balance_2026-11-13.md` |
| 10 | 2026-11-13 | Glyph Cluster | Sistemas de progresión: contratos de misión, hitos, umbrales en `scripts/progresion/` | `ses_e2d5d4e33ffe9FPJB5Yy6dFGeo` | Entregado | `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/` | `reporte_glyph_cluster_progresion_2026-11-13.md` |
| 11 | 2026-11-13 | Glyph Cluster | Auditoría de físicas y colisiones (cuerpos sin shape, capas/máscaras, acoplamiento gameplay-física) | `ses_e2921bcbcffeWnh7XHMMHPGLbg` | Entregado | `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/` | `REPORTE-2026-11-13_Fisicas-Colisiones.md` |

---

## 3. Evaluaciones entregadas (resumen)

### Glyph Cluster — `reporte_glyph_cluster_ui_auditoria_2026-11-13.md`

| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| M1 | Fondos oscurecedores con `MOUSE_FILTER_IGNORE` permiten click-through | `dialog_layer.gd:126`, `pause_layer.gd:37`, `inventory_layer.gd:64`, etc. | Medio |
| M2 | Ausencia de escudo fullscreen `MOUSE_FILTER_STOP` en popups/menús | `confirm_popup.gd:28-100`, `menus_layer.gd:34-39` | Bajo |
| D1 | Dos implementaciones de diálogo escuchan mismas señales de `DialogueManager` | `dialog_layer.gd:41-58`, `dialogue_ui.gd:107-119` | Alto |
| D2 | Rutas de apertura de diálogo solapadas `UIManager` vs `DialogLayer` | `ui_manager.gd:53-54`, `dialog_layer.gd:55-56` | Medio |
| L1 | Colisión `layer = 100` entre HUD y UIRoot | `hud.tscn:14-15`, `ui_root.gd:14,36` | Alto |
| L2 | Servicios globales sin `layer` explícito (`NotificationService`, `TooltipService`) | `project.godot:42-43`, `notification_service.gd:1`, `tooltip_service.gd:1` | Medio |
| S1 | `HUDScreen._connect_event_bus` omite suscripciones por retornos tempranos | `hud_screen.gd:115-135` | Alto |

**2 mejoras propuestas:** tabla de capas `UILayerZ` + input shield modal; unificar UI de diálogo y conexión idempotente de señales.

### Glyph Cluster — `reporte_glyph_cluster_ui_arquitectura_2026-11-13.md`

| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| — | Duplicación de arquitectura de diálogo: `DialogLayer` (M53) y `DialogueUI` (M21) | `dialog_layer.gd:13,34-36`, `dialogue_ui.gd:19-21` | Alta |
| — | Colisión de orden CanvasLayer: HUD y UIRoot comparten `layer = 100` | `hud.tscn:14-15`, `ui_root.gd:14,36` | Alta |
| — | Servicios CanvasLayer sin `layer` explícito | `notification_service.gd:1`, `tooltip_service.gd:1` | Media |
| — | `mouse_filter = IGNORE` en dimmers de capas modales | `dialog_layer.gd:126`, `pause_layer.gd:37`, etc. | Media |
| — | Variantes de `ActionPromptOverlay` (Control vs CanvasLayer) | `widgets/action_prompt_overlay.gd:1`, `hud/action_prompt_overlay.gd:1` | Baja |

**2 mejoras propuestas:** mapa de capas explícito único + fallback de diálogo encapsulado en un punto; normalizar semántica de `mouse_filter` para modales y retirar stub duplicado.

### Glyph Cluster — `reporte_glyph_cluster_dependencias_circulares_core_2026-11-13.md`

| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| — | Acoplamiento bidireccional implícito `SceneManager` ↔ `GameFlowManager` (ruta `/root`, enum `Estado`, `cambiar_estado`) | `scene_manager.gd:95-128` | Alta |
| — | Arranque sensible al orden de `call_deferred` y disponibilidad tardía de autoloads | `bootstrap.gd:44-58,91-117` | Alta |
| — | `SoftlockGuard` acoplado a señales de infraestructura (`EventBus.infra`, `SaveManager`) | `softlock_guard.gd:70-77` | Media |
| — | Dependencias runtime ocultas de invariantes/recovery hacia servicios externos (`/root/Diary`, `SaveWriter`) | `mision_invariant.gd:68-75`, `checkpoint_manager.gd:64` | Media |
| — | `SesionMaster` define contrato pero no está activo como autoload | `sesion_master.gd:1-47` | Baja |

**Veredicto de cyclicalidad:** LIMPIO (no hay dependencias circulares entre autoloads core).

**2 mejoras propuestas:** puerto de flujo inyectable (`FlowPort`) para desacoplar `SceneManager` de `GameFlowManager`; fase de arranque explícita en `Bootstrap` con readiness checks.

### Glyph Cluster — `REPORTE-2026-11-13_Acoplado-Core-Autoloads.md`

| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| H-01 | Acoplamiento fuerte a `SoftlockRules` (clase concreta, no autoload) | `softlock_guard.gd:92,151,169,173` | Alta |
| H-02 | Acoplamiento fuerte a `VoxelTerrain` concreta y `_get_island_gen()` | `terrain_locator.gd:14,49` | Alta |
| H-03 | Acoplamiento fuerte a clases concretas de invariantes y recuperación | `softlock_guard.gd:13-22,81-86,113-115,125-127` | Medio |
| H-04 | Acoplamiento fuerte y dinámico a forma concreta de `EventBus.infra` | `game_flow_manager.gd:67-73`, `scene_manager.gd:81-88`, `bootstrap.gd:129-132` | Medio |
| H-05 | Acoplamiento fuerte a enum `Estado` de `GameFlowManager` | `scene_manager.gd:102-109`, `bootstrap.gd:101-103,110-111` | Medio |
| H-06 | `SoftlockRules` vía `class_name` global sin ser autoload | `softlock_rules.gd:9` | Medio |
| H-07 | Referencias cruzadas de editor (sin ciclo, ruido) | `editor/_colector_sintaxis.gd:154-155` | Ruido |

**Veredicto de cyclicalidad:** LIMPIO (grafo DAG convergiendo en EventBus/ServiceRegistry).

**2 mejoras propuestas:** interfaz de configuración para `SoftlockRules` (registrar como autoload o inyectar) + interfaz `ITerrainHeightProvider` para `TerrainLocator`.

### Glyph Cluster — `reporte_glyph_cluster_progresion_2026-11-13.md`

| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| — | Contrato de hitos "primera vez" sin puente de activación en runtime | `progression_manager.gd:308-310,785-786`, `player_profile.gd:59-65` | Alta |
| — | Dependencias `hito_previo`/`condiciones` sin `stat_id` no se indexan para reevaluación | `progression_manager.gd:109-124,791-808` | Alta |
| — | Conexión a `ToolController` frágil (autoload en `_ready`, cableado explícito requerido) | `progression_manager.gd:184-199,202-221` | Media |
| — | Integración runtime parcial y heterogénea (EventBus + autoloads directos) | `progression_manager.gd:147-183,224-239` | Media |
| — | `hitos_proximos()` filtra solo tipos cuantificables, omite compuestas/sellos/capítulos | `progression_manager.gd:849-870` | Baja |
| — | `_reevaluar()` otorga hito sin verificar condición (invariante roto) | `progression_manager.gd:248-253,791-808` | Crítica |
| — | `marcar_hito()` no es guardián de condición; dos rutas con garantías distintas | `progression_manager.gd:408-416,791-808` | Alta |
| — | Umbrales negativos no rechazados al evaluar/otorgar en runtime | `progression_manager.gd:528-605,660-697,700-750` | Media |
| — | `activar_desbloqueo` y recompensas no validan formato/semántica | `progression_manager.gd:800-808,887-892` | Media |
| — | `PlayerProfile.incrementar`/`set_stat` aceptan valores sin saneamiento (negativos, NaN, INF) | `player_profile.gd:31-41` | Alta |
| — | `_stat()` delega incrementos sin clamp/validación desde señales externas | `progression_manager.gd:153-165,224-244` | Media |
| — | `ProgressCalculator` no valida entradas (pesos negativos/no enteros) | `progress_calculator.gd:13-35` | Media |
| — | Caché `_evaluacion_cache` nunca se invalida (lecturas stale permanentes) | `progression_manager.gd:43-47,378-406` | Alta |
| — | `restore_save_data` no reconcilia ni reevalúa hitos pendientes | `progression_manager.gd:933-958` | Alta |
| — | Otorgamiento por `_reevaluar` sin verificar condición = desincronización | `progression_manager.gd:248-253` | Media |
| — | Indexación solo por `stat_id` impide reevaluación de condiciones no-stat | `progression_manager.gd:109-124,901-903` | Media |

**2 mejoras propuestas:** otorgamiento seguro unificado (`intentar_otorgar_hito` que valida condición) + saneamiento de entradas y reconciliación/invalidación de caché en carga (`reconciliar_tras_carga`).

### Glyph Cluster — `REPORTE-2026-11-13_Fisicas-Colisiones.md`

| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| F-01 | `Area3D` de interacción con `collision_layer=0` y `collision_mask=0` (invisible al broadphase) | `crafting_station.gd:119,120` | Medio |
| F-02 | `CharacterBody3D` de NPC sin `CollisionShape3D` asignado | `ia_npc/npc_agent.gd:9,51-60` | Alta |
| F-03 | Máscara de colisión hardcodeada a 1 en raycast de cámara de foto | `foto/navigator.gd:83` | Medio |
| F-04 | Acoplamiento fuerte: estados de IA llaman `controller.move_and_slide()` directamente | `ia_npc/states/movement_state.gd:33`, `social_state.gd:32` | Medio |
| F-05 | `camera_spring.gd` es código muerto (deprecated) | `camera/camera_spring.gd:1-147` | Ruido |
| F-06 | Player `CharacterBody3D` sin configuración de capas/máscara visible en script | `main.gd:9` | Bajo |

**2 mejoras propuestas:** agregar `CollisionShape3D` a `NPCAgent` con capas/máscara configuradas; encapsular llamada a física en `controller.move_towards()` y eliminar `move_and_slide()` de estados de IA.

### Reflection-Beam-1.0 — `reporte_beam_contadores_coleccionables_2026-11-13.md`

| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| H1 | `registrar()` infla `_categoria_collected` para ids inexistentes y categorías fantasma | `coleccionables_manager.gd:60-78` | Alta |
| H2 | `restore_save_data()` desincroniza por tipo de clave (String vs StringName) | `coleccionables_manager.gd:156-168` | Crítica |
| H3 | `restore_save_data()` no limpia `_categoria_collected` antes de restaurar | `coleccionables_manager.gd:159-167` | Alta |
| H4 | `porcentaje_categoria()` y `porcentaje_total()` sin clamp; pueden superar 1.0 | `coleccionables_manager.gd:115-119,122-130` | Media |
| H5 | señal `categoria_progress_changed` declarada pero nunca emitida | `coleccionables_manager.gd:23` | Media |
| H6 | `validate_collectibles.validar()` cuenta entradas inválidas en `total` | `validate_collectibles.gd:44-90` | Media |
| H7 | `CollectibleCategory.esta_completa()` retorna true con collected > total | `collectible_category.gd:52-56` | Baja |
| H8 | `_on_especie_avistada()` mapea varias especies al mismo slot sin documentar | `coleccionables_manager.gd:175-183` | Baja |

**2 mejoras propuestas:** reconciliación automática de contadores en `restore` y `_ready` (desde `_collected` consultando el catálogo) + validación de entrada en `registrar()` y emisión de `categoria_progress_changed`.

### Reflection-Beam-1.0 — `reporte_beam_formulas_balance_2026-11-13.md`

| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| H1 | `multiplicador_precio_venta()` definido pero nunca consumido (drift fórmula vs runtime) | `shops/reputacion_tienda.gd:65-70` | Media |
| H2 | `rango_gemas_categoria()` duplica `rango_gemas()` de `enemy_data.gd` (dos tablas canónicas) | `combat/gem_currency.gd:73-84` | Media |
| H3 | `depositar_monedas` suma `ajustar_reputacion(1)` por depósito sin importar monto (farmeo) | `economia/economy_manager.gd:136` | Media |
| H4 | `take_damage` devuelve daño solicitado, no aplicado (drift daño reportado vs real) | `utils/components/health_component.gd:105-113` | Baja-Media |
| H5 | `get_progreso` no clampea a 1.0 al exceder umbral de nivel máximo | `friendship/vecino_amistad.gd:44-50` | Baja |
| H6 | `progreso_nivel` divide sin `maxi(1,...)`; riesgo de div/0 con umbrales desincronizados | `shops/reputacion_tienda.gd:54-60` | Baja |
| H7 | `reputacion()` con `amistad_normalizada < 0` ignora pesos 60/40 (sobreestima) | `progresion/player_profile.gd:70-78` | Baja |
| H8 | `precio_rebajado_hoy` usa `>` (coherente, sin off-by-one) | `economia/price_manager.gd:295-296` | Info |
| H9 | Caché `_cache_desc_amistad` puede quedar stale si señal no conectada | `economia/price_manager.gd:551-575` | Info |

**2 mejoras propuestas:** aplicar bonus de reputación al precio de venta en `precio_venta_vigente` + centralizar rangos de gemas en `EnemyData.rango_gemas` (delegación).

### Reflection-Beam-1.0 — `reporte_beam_reverificacion_checklist_global_2026-11-13.md`

| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| — | ID 48 duplicado en CHECKLIST-GLOBAL | `CHECKLIST-GLOBAL.md:150,151` | Crítico |
| — | ID 115 duplicado en CHECKLIST-GLOBAL | `CHECKLIST-GLOBAL.md:52,53` | Crítico |
| — | ID 127 duplicado en CHECKLIST-GLOBAL | `CHECKLIST-GLOBAL.md:66,67` | Crítico |
| — | ID 139 duplicado en CHECKLIST-GLOBAL | `CHECKLIST-GLOBAL.md:81,83` | Crítico |
| — | ID 148 duplicado en CHECKLIST-GLOBAL | `CHECKLIST-GLOBAL.md:93,94` | Crítico |
| — | Bloqueo stale M158 (68 días sin actividad) | `CHECKLIST-GLOBAL.md:106` | Alto |
| — | Bloqueo stale M139 (sin actividad desde 2026-10-14) | `CHECKLIST-GLOBAL.md:83` | Alto |
| — | Drift M139: declarado 138/142, real 136/142 | `CHECKLIST-GLOBAL.md:81,83` | Alto |
| — | Drift M17: declarado 135/175, real 141/175 | `CHECKLIST-GLOBAL.md:119` | Alto |

**2 mejoras propuestas:** automatizar reconciliación de CHECKLIST-GLOBAL con `scripts/generar_checklist_global.py --dry-run` antes de cada commit; eliminar filas duplicadas y liberar bloqueos stale >24h.


| ID | Hallazgo | Archivo:línea | Severidad |
|----|----------|---------------|-----------|
| — | `registrar_venta` sin validar `cantidad >= 0` / `dia >= 0` | `price_manager.gd:280-293` | Media |
| — | `incrementar()` acepta `cantidad` negativo; `set_stat()` no sincroniza `_dia`/`_contribucion` | `player_profile.gd:31-42` | Media |
| — | `restore_save_data()` acepta `_usos` sin clamp | `barter_system.gd:209-215` | Baja |
| — | `invalidar_cache_amistad` no invalida `_cache_tabla_dia` | `price_manager.gd:572-574`, `307-312` | Media |
| — | `deserializar()` no resetea cachés | `price_manager.gd:360-372` | Media |
| — | `get_save_data`/`restore_save_data` no serializan `_depositos_clampeados` | `economy_manager.gd:196-224` | Baja |
| — | `_evaluacion_cache` nunca se invalida (falsos permanentes) | `progression_manager.gd:380-405`, `933-960` | Alta |
| — | `_indexar_condicion()` no registra `riqueza_acumulada` | `progression_manager.gd:109-122` | Media |
| — | `set_stat()` no sincroniza `_dia`/`_contribucion` | `player_profile.gd:39-42`, `95-118` | Media |
| — | `append` sin deduplicar en `restore_save_data` de hitos | `progression_manager.gd:933-942` | Baja |
| — | Caché `_evaluate_cache_set` elimina primera clave con comparación `>=` | `progression_manager.gd:392-405` | Baja |
| — | `_usos[npc_id]` límite inconsistente | `barter_system.gd:137`, `108`, `144-153` | Baja |
| — | `retirar_monedas` sin re-verificación de saldo ni reconciliación | `economy_manager.gd:103-112` | Media |
| — | `_on_transaccion_registrada()` confía en `tx.monto` sin verificar | `progression_manager.gd:226-240` | Media |
| — | Rollback `inv.agregar_items` ignora retorno | `barter_system.gd:120-133` | Media |
| — | `_recargos_clampeados` sin trazabilidad de motivo | `price_manager.gd:138-148` | Baja |

**2 mejoras propuestas:** reconciliación centralizada de saldo vs historial en `economy_manager.gd`; invalidación consolidada de cachés y validación de entrada en `price_manager.gd`.

**Resumen de severidad:** Alta 1, Media 8, Baja 6.

---

## 4. Modelos dejados de lado

Ninguno hasta la fecha (todos han entregado al menos un reporte).

---

## 5. Próximas tareas por asignar

| Modelo | Tarea candidata | Estado |
|--------|-----------------|--------|
| Glyph Cluster | — (todas las tareas disponibles del nicho completadas) | Ninguna restante |
| Reflection-Beam-1.0 | — (todas las tareas disponibles del nicho completadas) | Ninguna restante |

**Nota:** No hay tareas nuevas que asignar a ninguno de los dos modelos sin repetir tareas ya entregadas. Mantener sesiones `idle` hasta que surjan nuevos módulos en sus nichos.

---

**Firma:** Nemotron-3.5-Super-VL / Kilo Code — 2026-11-13
