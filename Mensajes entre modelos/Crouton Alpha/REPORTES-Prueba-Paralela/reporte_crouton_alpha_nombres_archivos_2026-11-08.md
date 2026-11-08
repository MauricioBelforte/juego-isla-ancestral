# Reporte: consistencia de nombres de archivos .gd en `game/isla-ancestral/scripts/`

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance analizado:** `game/isla-ancestral/scripts/` — **1260 archivos .gd** recursivos (conteo: `Get-ChildItem -Recurse -Filter "*.gd"`).
**Método:** inventario completo del árbol, detección de basenames duplicados, comparación `class_name` vs. nombre de archivo (snake_case), inspección de contenido de archivos representativos (primeras 8–25 líneas) y de pares conceptuales duplicados.

---

## 1. ¿Hay archivos .gd con nombres en inglés y español mezclados sin criterio?

**Sí. Es el hallazgo principal.** La mezcla no es ocasional: afecta a nombres de carpeta, a nombres de archivo y a `class_name` dentro del mismo módulo.

Evidencias (ruta:línea aproximada del encabezado, verificado en disco):

- Carpetas gemelas EN/ES para el mismo concepto, sin alias ni índice que lo explique:
  - `terrain/` vs `terrenos/` vs `terreno/` — tres carpetas para «terreno».
  - `localizacion/` vs `localization/` — ambas contienen `localization_manager.gd` (ver §4).
  - `map/` vs `mapa/`.
  - `data/` vs `datos/`.
  - `performance/` vs `rendimiento/` (este último con subcarpeta `memoria/`).
  - `historia/` vs `historias/`.
  - `shops/` vs `store/`.
  - `stream/` (todo en español: `pantalla_carga.gd`, `consejos_carga.gd`) conviviendo en la misma raíz con carpetas en inglés (`camera/`, `combat/`, `crafting/`).
- Archivos que mezclan ambos idiomas en el mismo nombre:
  - `accesibilidad/accesibilidad_aplicador.gd` y `accesibilidad/aplicador_accesibilidad.gd` — dos archivos en la misma carpeta, mismo módulo M58, orden de palabras invertido; el primero no declara `class_name` (líneas 1–7: comentario M58), el segundo declara `class_name AplicadorAccesibilidad` (línea 8).
  - `datos/serializador.gd:8` — archivo en español, `class_name Serializer` (línea 8).
  - `ruinas/generador_ruina.gd:8` — archivo en español, `class_name RuinaChozavil` (línea 8): ni siquiera coincide con el nombre del archivo.
  - `inventario/inventario_contenedor.gd` — `class_name ContenedorInventario` (orden invertido).
  - `motivacion/motor_variantes.gd` — `class_name MotorEventosVariantes` (nombre distinto, no solo orden).
  - `clock/w_reloj.gd` (línea 1–5: «Widget de Reloj (HUD)») y `clock/caso_reloj.gd` (línea 5: «escenario del test del reloj»), frente a `clock/reloj_hud.gd` en la misma carpeta: tres convenciones (`w_`, `caso_`, `reloj_hud`) para el mismo módulo M30.
  - `templos/templo_telemetria.gd` — `class_name TempleTelemetria` (inglés/español dentro de la propia clase).
  - `islas/generar_islas.gd`, `islas/sincronizar_islas_mapa.gd`, `fuentes/auditar_glifos.gd`, `fonts/font_auditor.gd` (misma carpeta `fonts/` con ambos idiomas).

**Conclusión parcial:** no hay un criterio declarado (p. ej. «carpetas en español, identificadores en inglés»). La mezcla es producto de iteraciones de distintos agentes sin una convención aplicada de forma retrospectiva.

---

## 2. ¿Hay archivos .gd con nombres muy cortos o crípticos?

**Pocos, pero los que hay son ambiguos en la raíz del proyecto:**

- `scripts/main.gd` (86 líneas; línea 3: «Escena principal — Isla Ancestral», `extends Node3D`, sin `class_name`) convive con `scripts/main_island.gd` (422 líneas; línea 6: «Escena principal — Isla Raíz con generación procedural (M09/M10)», con `const MUNDO_RAIZ = preload(...)` en línea 4), `scripts/main_simple.gd`, `scripts/main_test.gd` (línea 3: «Escena de prueba simple») y `scripts/main_test2.gd`. Cuatro «main» sin que el nombre indique cuál es el canónico; el canónico real es `main_island.gd` según su contenido, no por su nombre.
- `scripts/minimal_test.gd` (línea 3: «Setup minimal según quick start de Voxel Tools») y `scripts/test_arquitectura.gd`, `scripts/test_terrain.gd` sueltos en la raíz, fuera de cualquier carpeta de tests.
- `scripts/follow_camera.gd` (línea 3: «Cámara estilo Animal Crossing — M12… portados de camera_rig.gd (código muerto → canónico)») duplica en la raíz lo que ya vive en `scripts/camera/camera_rig.gd` — la raíz actúa como segunda ubicación canónica.
- `scripts/simple_walk.gd` (`extends CharacterBody3D`, `SPEED = 5.0` línea 3, `add_to_group("player")` línea 8) es un jugador de demostración sin el prefijo `test_`/`demo_` que sí usan otros archivos equivalentes (`fauna/gaviota_demo.gd`).
- Nombres crípticos por abreviatura dentro de carpetas:
  - `progresion/debug_tc.gd` (línea 5: «Debug ToolController» — `tc` no se explica).
  - `clock/w_reloj.gd` (la `w_` no se documenta en el encabezado).
  - `ia_npc/state.gd` y `ia_npc/plan_stack.gd` (ver §3).
  - Raíz del proyecto Godot (fuera de `scripts/`): `_probe_col.gd` y `probe_save2.gd` — nombres de sonda abandonados en la raíz.
- Contrapunto: `scripts/shops/shop.gd` (4 letras) es corto pero **no** críptico: es el recurso «tienda» del módulo y su carpeta lo contextualiza.

**Conclusión parcial:** el problema no es la longitud, es la ubicación y la falta de rol en el nombre: los archivos de la raíz (`main*.gd`, `minimal_test.gd`, `simple_walk.gd`) no indican si son producción, demo o test.

---

## 3. ¿Hay archivos .gd cuyo nombre no coincide con la clase o contenido principal?

**Sí, 61 de 1260 archivos con `class_name` difieren del nombre de archivo en snake_case.** La mayoría son falsos positivos de la convención (`NPC`→`npc`, `UI`/`HUD`→`ui`/`hud`, sufijos `_` en `EventBus_`, `NotificationService_`, `TooltipService_` para evitar colisiones — p. ej. `core/event_bus.gd`, `ui/services/notification_service.gd`), pero hay casos reales:

| Archivo | `class_name` declarada | Problema |
|---|---|---|
| `ruinas/generador_ruina.gd:8` | `RuinaChozavil` | La clase es un tipo concreto («chozavil»); el archivo dice «generador» genérico. |
| `datos/serializador.gd:8` | `Serializer` | Archivo ES, clase EN. |
| `motivacion/motor_variantes.gd` | `MotorEventosVariantes` | Clase con una palabra más que el archivo. |
| `inventario/inventario_contenedor.gd` | `ContenedorInventario` | Orden invertido (mismo caso que §1). |
| `lore/pieza_lore.gd` | `PiezaDeLore` | La clase agrega la preposición `De`. |
| `ia_npc/state.gd` | `NPCState` | Archivo genérico `state.gd`, clase específica `NPCState`. |
| `ia_npc/plan_stack.gd` | `NPCPlanStack` | Idem: falta el prefijo `npc_` en el archivo. |
| `ia_npc/npc_agent.gd`, `npc_blackboard.gd`, `npc_needs.gd`, `npc_watchdog.gd` | `NPCAgent`, `NPCBlackboard`, `NPCNeeds`, `NPCWatchdog` | Conversión `NPC`→`npc` no estándar (la convención Godot suele dar `n_p_c` o mantener `npc`); inconsistente con `data/npc_visual_data.gd` → `NPCVisualData`. |
| `utils/data/item_data.gd`, `mission_data.gd`, `npc_data.gd`, `player_data.gd` | `ItemDataStruct`, `MissionDataStruct`, `NPCDataStruct`, `PlayerDataStruct` | El archivo omite el sufijo `Struct` de la clase. |
| `saving/save_provider.gd` | `ISaveProvider` | La interfaz pierde la `I` en el nombre de archivo (sí la conserva `interfaces/i_interactable.gd`). |
| `plataformas/iplatform_bridge.gd` | `IPlatformBridge` | `iplatform` pegado, sin separador tras la `I`. |
| `rendimiento/memoria/budget_registry.gd` | `MemoryBudgetRegistry` | La clase antepone `Memory`; el archivo no. |
| `terrain/terrain_detector.gd:4` | `TerrainDetectorLegacy` | La carpeta `terrain/` contiene la **versión legacy** (líneas 2–4: «RENOMBRADA… Esta variante es heredada… nadie la consume»); la vigente vive en `terrenos/terrain_detector.gd`. El nombre de carpeta sugiere lo contrario. |
| `debug/panel_base.gd` | `PanelBaseM110` | La clase lleva el sufijo de módulo `M110`; el archivo no. |
| `core/test_m66_handler.gd`, `core/test_m66_inv_ruta.gd` | `M66HandlerRegistro`, `M66InvRuta` | Archivos de test con `class_name` de producción: contaminan el espacio global de clases. |

**Conclusión parcial:** el incumplimiento es minoritario (61/1260 ≈ 5 %), pero los casos reales se concentran en archivos que un agente nuevo abre primero (`state.gd`, `terrain_detector.gd`, `main.gd`).

---

## 4. ¿Hay archivos .gd duplicados con funcionalidad similar pero nombres distintos?

**Sí. Es el hallazgo más costoso: 14 basenames duplicados en el árbol.**

- **Duplicados idénticos por nombre de archivo (14):**
  - `ui/hud/action_prompt_overlay.gd` = `ui/widgets/action_prompt_overlay.gd`
  - `ui/hud/clock_widget.gd` = `ui/widgets/clock_widget.gd`
  - `ui/hud/hotbar_widget.gd` = `ui/widgets/hotbar_widget.gd`
  - `ui/hud/interact_prompt.gd` = `ui/widgets/interact_prompt.gd`
  - `ui/hud/minimap_widget.gd` = `ui/widgets/minimap_widget.gd`
  - `ui/hud/resource_counter.gd` = `ui/widgets/resource_counter.gd`
  - `ui/hud/season_widget.gd` = `ui/widgets/season_widget.gd`
  - `ui/hud/status_bar.gd` = `ui/widgets/status_bar.gd`
  - `data/item_data.gd` = `utils/data/item_data.gd`
  - `localizacion/localization_manager.gd` = `localization/localization_manager.gd` (ambos autoload M87; encabezados casi idénticos, del 2026-08-30 y 2026-09-02)
  - `terrain/terrain_data.gd` (18 líneas) = `terrenos/terrain_data.gd` (32 líneas, `class_name TerrainDataM156`)
  - `terrain/terrain_detector.gd` = `terrenos/terrain_detector.gd` (legacy vs. vigente, ver §3)
  - `terrain/terrain_modifiers.gd` = `terrenos/terrain_modifiers.gd`
  - `ia_npc/state_machine.gd` = `utils/state_machine.gd` (orquestador específico `class_name NPCStateMachine` vs. genérico `class_name StateMachine`, `utils/state_machine.gd:3`)
- **Duplicados funcionales con nombres distintos:**
  - `accesibilidad/accesibilidad_aplicador.gd` vs `accesibilidad/aplicador_accesibilidad.gd` (misma carpeta, M58, iter. 1 vs iter. 3: el segundo es la evolución del primero; el primero quedó sin `class_name`).
  - `terrain/` vs `terrenos/` vs `terreno/`: tres ubicaciones para el terreno; `terreno/validador_isla_raiz.gd`, `terreno/captura_playa.gd`, `terreno/debug_alturas.gd` son utilidades sueltas del mismo dominio.
  - `data/` vs `datos/`: `datos/gestor_backups.gd` (ES) frente a `backup/backup_manager.gd` (EN) — mismo dominio, dos carpetas, dos idiomas.
  - `historias/quest_chain.gd` vs `historias/quest_chain_service.gd` (misma carpeta: ¿cuál es la fuente de verdad?).
  - `follow_camera.gd` (raíz) vs `camera/camera_rig.gd` (ver §2).
  - `main.gd` vs `main_island.gd` vs `main_simple.gd` (ver §2).
  - `debug/_probe_debug.gd`, `core/probe_runtime_bus_m14.gd`, `friendship/probe_gift_fix_gd.gd`, `rendimiento/memoria/probe_vram_tormenta.gd`: la familia `probe_*`/`sonda_*` (`interacciones/sonda_m70.gd`, `sonda_m70b.gd`) dispersa sondas de diagnóstico por todo el árbol sin carpeta común.
- **Obsolescencia mal señalizada:** los archivos obsoletos conviven con los vigentes en la misma carpeta (`clock/Obsoletos/2026-08-26_19-35-00_w_reloj.gd`, `legal/Obsoletos/2026-11-06_22-18-40_merch_manager.gd`, `fauna/Obsoletos/2026-09-04_02-10-00_gaviota_npc_backup_v10.gd`) en vez de moverse a un `Obsoletos/` central o eliminarse; el nombre con fecha es el único marcador.

**Conclusión parcial:** los duplicados de `ui/hud/` vs `ui/widgets/` y `terrain/` vs `terrenos/` son el grueso del problema: dos árboles paralelos para el mismo dominio, sin un puntero «esta es la copia legacy» en el nombre (la nota de legacy solo existe dentro del contenido de `terrain/terrain_detector.gd:2-4`).

---

## 5. Mejoras de nomenclatura sugeridas (2)

### Mejora 1 — Unificar el idioma de carpetas y archivos en inglés (con alias ES donde se necesite), empezando por los 7 pares gemelos

**Qué:** adoptar **inglés snake_case para carpetas y archivos** como convención única (es el idioma mayoritario del árbol: `camera`, `combat`, `crafting`, `fauna`, `fishing`, `terrain`, `world`, `ui`) y renombrar las 7 carpetas gemelas para que quede una sola por dominio:

| Hoy | Queda | Acción |
|---|---|---|
| `terrain/` + `terrenos/` + `terreno/` | `terrain/` | Mover `terrenos/*` a `terrain/`, `terreno/validador_isla_raiz.gd` → `terrain/isla_raiz_validator.gd`, `terreno/captura_playa.gd` → `terrain/beach_capture.gd`, `terreno/debug_alturas.gd` → `terrain/height_debug.gd`; renombrar la carpeta legacy `terrain/` actual a `terrain_legacy/` o eliminarla (su propio encabezado `terrain/terrain_detector.gd:2-4` dice que nadie la consume). |
| `localizacion/` + `localization/` | `localization/` | Quedarse con `localization/localization_manager.gd` (M87, .po) y eliminar `localizacion/localization_manager.gd`. |
| `data/` + `datos/` | `data/` | `datos/serializador.gd` → `data/serializer.gd` (coincide con su `class_name Serializer`), `datos/gestor_backups.gd` → `data/backup_manager.gd` y fusionar con `backup/backup_manager.gd`. |
| `map/` + `mapa/` | `map/` | `mapa/mapa_manager.gd` → `map/map_manager.gd`, `mapa/mapa_busqueda.gd` → `map/map_search.gd`. |
| `performance/` + `rendimiento/` | `performance/` | `rendimiento/memoria/*` → `performance/memory/*`, conservando la subcarpeta. |
| `historia/` + `historias/` | `stories/` o `historia/` | Elegir uno; `historia/` y `historias/` difieren en una letra y son indistinguibles en un listado. |
| `shops/` + `store/` | `shops/` | `store/store_page_validator.gd` → `shops/shop_page_validator.gd`. |

**Por qué ayuda:** elimina los 7 pares gemelos y los 14 basenames duplicados de §4 de raíz; un agente nuevo deja de preguntarse «¿`terrain/` o `terrenos/`?» antes de cada búsqueda. El costo es bajo: Godot resuelve por ruta `res://`, así que basta con mover archivos y actualizar los `preload`/`extends` con ruta (verificar con `grep -r "scripts/terrenos"` antes de mover).

### Mejora 2 — Prefijo de rol obligatorio para archivos no productivos y raíz limpia de `scripts/`

**Qué:** todo archivo que no sea código de producción lleva un prefijo de rol en el nombre, y la raíz de `scripts/` queda solo con archivos de producción:

| Archivo hoy | Archivo propuesto | Motivo |
|---|---|---|
| `scripts/main.gd` | `scripts/main_island.gd` (fusionar; `main.gd` pasa a `scripts/Obsoletos/2026-11-08_main.gd` o se elimina) | Un solo «main» canónico; hoy hay 4 (`main.gd`, `main_island.gd`, `main_simple.gd`, `main_test.gd`) |
| `scripts/main_test.gd`, `main_test2.gd`, `minimal_test.gd`, `test_arquitectura.gd`, `test_terrain.gd` | `scripts/tests/<mismo nombre>.gd` | Los tests sueltos en la raíz no se distinguen de producción |
| `scripts/simple_walk.gd` | `scripts/tests/demo_simple_walk.gd` | Es una demo sin marcador de rol |
| `scripts/follow_camera.gd` | `scripts/camera/follow_camera.gd` | Ya existe `camera/`; la raíz no debe ser segunda ubicación |
| `progresion/debug_tc.gd` | `progresion/debug_tool_controller.gd` | `tc` críptico (ver §2) |
| `clock/w_reloj.gd` | `clock/clock_widget.gd` | `w_` críptico; además coincide con `ui/widgets/clock_widget.gd` (duplicado, ver §4) |
| `ia_npc/state.gd` | `ia_npc/npc_state.gd` | Coincide con su `class_name NPCState` (ver §3) |
| `ia_npc/plan_stack.gd` | `ia_npc/npc_plan_stack.gd` | Coincide con su `class_name NPCPlanStack` |
| `datos/serializador.gd` | `data/serializer.gd` | Coincide con su `class_name Serializer` |
| `ruinas/generador_ruina.gd` | `ruinas/ruina_chozavil.gd` | Coincide con su `class_name RuinaChozavil` |
| `saving/save_provider.gd` | `saving/i_save_provider.gd` | Coincide con su `class_name ISaveProvider` (y con `interfaces/i_interactable.gd`) |
| `plataformas/iplatform_bridge.gd` | `plataformas/i_platform_bridge.gd` | Separa la `I` de interfaz del nombre |
| `*/probe_*.gd`, `*/sonda_*.gd`, `*/diag_*.gd` | `tools/probes/probe_<dominio>_<tema>.gd` | Las sondas de diagnóstico dejan de dispersarse por el árbol (hoy en `core/`, `debug/`, `friendship/`, `rendimiento/memoria/`, `interacciones/`) |
| `*/qa_*.gd`, `*/test_*.gd` | sin cambio de nombre, pero fuera de carpetas de producción o con subcarpeta `tests/` por módulo | Hoy hay 151 archivos con `qa_`/`test_`/`probe`/`diag`/`debug` mezclados en carpetas de producción |

**Por qué ayuda:** el nombre pasa a responder «¿qué es este archivo?» sin abrirlo; la raíz de `scripts/` deja de ser un segundo índice del proyecto (hoy tiene 10 `.gd` sueltos) y las sondas dejan de parecer código de producción.

---

## Conclusión final

El árbol de 1260 archivos .gd es **funcionalmente completo pero nomenclaturalmente inconsistente en tres ejes**:

1. **Idioma:** la mezcla EN/ES no sigue criterio (7 pares de carpetas gemelas, archivos ES con `class_name` EN y viceversa). No es un problema de calidad, es de convención ausente.
2. **Duplicación:** 14 basenames duplicados, concentrados en `ui/hud/` vs `ui/widgets/` y `terrain/` vs `terrenos/`; más pares funcionales con nombres distintos (`accesibilidad_aplicador.gd` vs `aplicador_accesibilidad.gd`, `main.gd` vs `main_island.gd`, `follow_camera.gd` vs `camera/camera_rig.gd`). La carpeta `terrain/` es la copia **legacy** de `terrenos/`, según su propio encabezado (`terrain/terrain_detector.gd:2-4`), pero el nombre de la carpeta dice lo contrario.
3. **Rol no marcado:** nombres cortos o crípticos son pocos (2 con ≤4 letras, ninguno tipo `x.gd`/`tmp.gd`/`data.gd`), pero los archivos de la raíz (`main*.gd`, `minimal_test.gd`, `simple_walk.gd`) y las ~151 sondas/QA/tests dispersos no indican su rol en el nombre.

Solo 61 archivos (5 %) incumplen `class_name` = nombre de archivo, y la mayoría son conversiones mecánicas (`NPC`→`npc`, sufijos `_` anti-colisión). **La inconsistencia real no está en cada archivo, está en el índice:** carpetas gemelas y duplicados hacen que un agente nuevo no sepa dónde vive cada dominio.

Las dos mejoras propuestas (unificar carpetas gemelas en inglés; prefijo de rol y raíz limpia) atacan ese índice sin tocar lógica: son renombres mecánicos verificables con `grep` de `preload`/`extends` antes de mover, y eliminan de raíz los 14 duplicados de §4 y los 7 pares gemelos de §1. Se recomienda aplicarlas antes de seguir creciendo el árbol, porque cada módulo nuevo que repite la mezcla duplica el costo de búsqueda.
