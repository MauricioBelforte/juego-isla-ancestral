# Reporte: Prefabs, escenas reutilizables, instancing y packing — Isla Ancestral

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scenes/` y `game/isla-ancestral/scripts/`

## Resumen ejecutivo

Se analizaron 49 archivos `.tscn` en `scenes/` y ~96 sitios de `instantiate`/`PackedScene` en `scripts/`. El patrón dominante es **instancing en editor** (`ext_resource PackedScene` + `node instance=`) para el jugador y **instancing en runtime** con `load() + instantiate()` para NPC, fauna, vegetación, museo y previews. Hay **pooling correcto** en huellas y partículas, **1 sitio con limpieza parcial** (villagers) y **una clase de referencia rota tipo BUG-121** ya documentada en el proyecto (GLB ausente en headless sin null-guard). No se encontraron referencias rotas de escena externa en los `.tscn` verificados; no se encontró uso runtime de `pack()`/`PackedScene.pack()`.

---

## (1) ¿Cómo se instancian escenas reutilizables?

### A) Instancing en editor (.tscn → .tscn)

Solo 6 escenas instancian otra escena vía `ext_resource type="PackedScene"` + `instance=`:

| Escena contenedora | Escena instanciada | Línea |
|---|---|---|
| `scenes/main.tscn` | `res://scenes/player/Player.tscn` | `scenes/main.tscn:6` y `:33` |
| `scenes/main_simple.tscn` | `res://scenes/player/Player.tscn` | `scenes/main_simple.tscn:5` y `:32` |
| `scenes/main_test.tscn` | `res://scenes/player/Player.tscn` | `scenes/main_test.tscn:5` y `:50` |
| `scenes/main_test2.tscn` | `res://scenes/player/Player.tscn` | `scenes/main_test2.tscn:4` y `:38` |
| `scenes/main_island.tscn` | `res://scenes/player/Player.tscn` | `scenes/main_island.tscn:9` y `:72` |
| `scenes/player/Player.tscn` | `res://assets/3d/media/45-Arte3D_jugador_voxel.glb` (GLB importado como `PackedScene`) | `scenes/player/Player.tscn:4` y `:23` (`[node name="ModeloVoxel" instance=ExtResource("2_voxel")]`) |

El resto de las escenas reutilizables (`villager.tscn`, `npc_agent.tscn`, `museum.tscn`, `exhibit_slot.tscn`, las 14 escenas de `scenes/terrenos/huella_*.tscn` y `particulas_*.tscn`) **no se referencian desde ningún otro `.tscn`**: se cargan solo por código.

### B) Instancing en runtime (GDScript)

**Patrón canónico: `load(ruta)` → `PackedScene.instantiate()` → `add_child()`.** Casos principales:

| Sistema | Archivo:línea | Ruta |
|---|---|---|
| Villager | `scripts/npc/villager_manager.gd:588-591` | `load("res://scenes/npc/villager.tscn")` + guard `ResourceLoader.exists`, fallback `Node3D.new()` |
| Villager | `scripts/npc/villager_manager.gd:603-608` | `get_tree().current_scene.add_child(nodo)` o `add_child(nodo)` como padre lógico en headless |
| NPCAgent | `scripts/ia_npc/npc_manager.gd:205-213` | `preload("res://scenes/npc/npc_agent.tscn")` + `instantiate()` |
| Museo | `scripts/museum/museum_placer.gd:12-16` | `load("res://scenes/museo/museum.tscn")` + `instantiate()` |
| Vegetación | `scripts/vegetacion/vegetation_spawner.gd:75-79` | `load("res://assets/3d/media/%s.glb")` + `instantiate()` (lote único, ~100 ítems) |
| Fauna (tortuga, jabalí, gaviota) | `scripts/fauna/tortuga_npc.gd:88-93`, `scripts/fauna/jabali_npc.gd:90-94`, `scripts/fauna/gaviota_npc.gd:121-125` | `load(GLB)` + `instantiate()` + null-guard con `push_warning` (ver §4) |
| Previews de assets | `scripts/assets/preview_assets.gd:40-44`, `scripts/assets/asset_preview.gd:36-40` | `load(ruta)` + `instantiate()` + `add_child` |
| Ruinas / build ghost | `scripts/ruinas/colocar_props_m25.gd:77-81`, `scripts/construccion/build_ghost.gd:132-135` | `PackedScene.instantiate()` + `inst.free()` tras extraer la malla (`build_ghost.gd:135`) |
| Raíz / main | `scripts/core/probe_runtime_bus_m14.gd:85` | `ps.instantiate()` |
| Tests | `scripts/debug/test_panels_m110.gd:297-302`, `scripts/debug/test_refactor_m110.gd:275-280`, `scripts/debug/test_m110_ui3.gd:52-55`, `scripts/museum/test_museo_rf3.gd:33`, `scripts/player/test_player_m11.gd:91-92`, `scripts/player/test_player_cableado_m11.gd:266-267` | `load(...tscn)` + `instantiate()` + `add_child` / `queue_free` |

**Patrón con pooling (ejemplar):**

- `scripts/terrenos/terrain_footprints.gd:68-79` — precarga las 7 escenas `huella_%s.tscn` (líneas 68-79), instancia una vez por escena para capturar el `mesh` compartido y `inst.free()` inmediatamente; en runtime `_obtener_nodo()` (`:147-158`) reutiliza `MeshInstance3D` de pool.
- `scripts/terrenos/terrain_particles.gd:63-70` — precarga las 7 escenas `particulas_%s.tscn`; `_obtener_nodo()` (`:123-135`) instancia + `add_child()` solo si el pool está vacío.

---

## (2) ¿Hay escenas .tscn que se instancian repetidamente sin limpieza?

### Sin limpieza real en producción

**No se detectó instancing repetido sin limpieza en el código de juego fuera de tests.** Los casos de mayor volumen tienen limpieza:

- **Huellas**: `terrain_footprints.gd:215-219` (`_liberar`) devuelve el nodo al pool; `_gestionar_activas` (`:180-186`) y `_desvanecer` (`:191-203`) lo reciclan tras fade. Límite `max_huellas = 24` (`:35`) con descarte de la más vieja (`:116-118`). Limpieza correcta.
- **Partículas**: `terrain_particles.gd:147-152` (`_liberar`) apaga (`emitting=false`, `visible=false`) y devuelve al pool; `_gestionar_activos` (`:138-144`) y límite `max_emisores = 6` (`:37`, `:103-105`). Limpieza correcta.
- **Vegetación**: `vegetation_spawner.gd:37-41` (`_exit_tree`) hace `_contenedor.queue_free()`; además `inst.free()` al descartar por agua (`:88`). Aunque instincia una sola vez en `_poblar()` (`:53-116`), existe la corrección BUG-129 (`:10-16`, `:103-114`): antes colgaba de `current_scene` y dejaba huérfanos en headless.
- **NPCAgent**: `npc_manager.gd:219-227` (`_remove_agent`) borra del diccionario `_agents` y emite `npc_removed`; la instancia vive colgada del villager y muere con el villager. Limpieza indirecta pero válida.

**Solo tests instancian repetidamente**, y ahí sí hay limpieza (`queue_free`/`free`, p. ej. `test_panels_m110.gd:316`, `test_m110_ui3.gd:66`, `test_consola_m110.gd:282-289`).

### Parcial: scene_tree huérfana en villager headless

- `villager_manager.gd:603-608`: si no hay `current_scene`, el villager se cuelga del manager (`add_child(nodo)`). Es un padre válido dentro del árbol, no un huérfano; pero si el manager muere con el autoload, todos los villagers mueren juntos. Riesgo bajo (bootstrap, no runtime).

---

## (3) ¿Hay problemas de packing/unpacking de escenas?

**No se encontró ningún uso runtime de `pack()`/`PackedScene.pack()` en `scripts/`** (grep de `\.pack\(` + `PackedScene.*pack` + `ResourceSaver` solo devolvió `ResourceSaver.save` de `.tres`/`.tres` de datos, p. ej. `scripts/data/world_locations.gd:149`, `scripts/islas/generar_islas.gd:64,85`, `scripts/legal/generar_catalogo_tres_m131.gd:38`).

**Problema arquitectónico vinculado: `instantiate()` sin `add_child()` ni `free()` en `build_ghost.gd` y `colocar_props_m25.gd` (medición).**

- `scripts/construccion/build_ghost.gd:132-135`: `instantiate()` → extrae malla → `inst.free()`. Correcto y eficiente.
- `scripts/ruinas/colocar_props_m25.gd:45-46`: `medir_z_min` instancia y usa la instancia para medir sin llamar a `free()` en el snippet visible. Este es el patrón "unpack momentáneo sin pack" más riesgoso: instancia una `PackedScene` descartable de forma efímera.

**No hay `change_scene_to_packed` / `change_scene_to_file` para escenas reutilizables** en el grep (solo instancing en raíz).

---

## (4) ¿Hay prefabs con referencias rotas a escenas externas?

**Verificación exhaustiva de `ext_resource` en los 49 `.tscn` de `scenes/`: 0 referencias rotas.** Todos los `path="res://..."` resuelven a archivos existentes en `game/isla-ancestral/`. El único `PackedScene` externo (`Player.tscn:4`, GLB `45-Arte3D_jugador_voxel.glb`) existe en disco.

**Pero sí hay una clase de referencia rota en runtime (GLB ausente en headless), ya documentada como BUG-121.** La evidencia:

- `scripts/backup/test_backup_m107.gd:9-11`: "load(.glb) devuelve null en headless y no hay null-guard antes de `.instantiate()`".
- `scripts/debug/test_debug_m110.gd:11` y `scripts/legal/test_legal_m78_v2.gd:12`: misma nota literal.
- Para `tortuga_npc.gd:90`, `jabali_npc.gd:92` y `gaviota_npc.gd:123` sí hay null-guard con `push_warning` — esos ya están corregidos con placeholder/sin-modelo.

**Referencia externa menos frágil pero dependiente del FS: `vegetation_spawner.gd:70-78`.** Usa `FileAccess.file_exists(ruta)` + `load(ruta)` con conteo de errores (`sin_archivo`, `omitidas`), por lo que una referencia rota no crashea: degrada a omisión silenciosa con contadores.

---

## (5) Sugerencias (2 mejoras)

### Mejora 1: Pool de instancias marcado como descartable para fauna y vegetación (bajar presión de `instantiate`)

Extender el patrón ya probado de `terrain_footprints.gd` / `terrain_particles.gd` a `vegetation_spawner.gd` y fauna NPC. Hoy la vegetación instancia N GLB una sola vez (`vegetation_spawner.gd:79`) y los fauna NPC instancian **cada vez que se resetean** (`tortuga_npc.gd:88-100`, `gaviota_npc.gd:121-128`) sin reutilización.

Implementación sugerida (sin código completo):
- En `vegetation_spawner.gd`, cachear las `PackedScene` por tipo en lugar de `load()` por ítem (`:75`) y exponer un pool `_pool_vegetacion: Dictionary` keyed por tipo.
- En `gaviota_npc.gd:116`, parametrizar `_instanciar_modelo()` para que el nodo `Modelo` se reutilice vía `get_node_or_null("Modelo")` antes de `load()`.

Beneficio: menos llamadas a `instantiate()` repetidas en pantallas con fauna numerosa y menos churn de nodos efímeros.

### Mejora 2: Null-guard + cleanup único para `instantiate()` de GLB/scene y `pack()` limitado a editor

Cerrar BUG-121 en los tres sitios que lo citeaban y centralizar la creación de instancias:

- Agregar null-guard pre-`instantiate()` en `gaviota_npc.gd:121-125`, `tortuga_npc.gd:88-93`, `jabali_npc.gd:90-94` donde falte (el log de `test_backup_m107.gd:11` indica que aún hay sitios sin guard; aplicar el patrón válido de `vegetation_spawner.gd:75-78`).
- Introducir un helper `ScenePool.instanciar(ruta, padre)` reutilizable que wrappee `load + instantiate + add_child + free` para medición, replicando el patrón ya correcto de `build_ghost.gd:132-135`, y usarlo para eliminar el `instantiate()` efímero de `colocar_props_m25.gd:46` (medir `z_min`) sin pisar la lógica de medición.
- Reservar `PackedScene.pack()` (hoy ausente) solo a scripts de editor/tools; no instanciar ni empaquetar en runtime.

Beneficio: elimina la clase BUG-121 de forma estructural y evita que futuras escenas reutilizables nazcan sin limpieza.

---

## Conclusión final

El proyecto resuelve correctamente lo esencial: **instancing en editor para el Player** y **instancing en runtime con pooling para efectos efímeros** (`terrain_footprints.gd` y `terrain_particles.gd` son el estándar a seguir). La vegetación y los agentes NPC tienen limpieza aceptable (`vegetation_spawner.gd:37-41`, `npc_manager.gd:219-227`). No hay escenas `.tscn` instanciadas repetidamente sin limpieza en producción; la única clase de error vivo es **BUG-121** (GLB ausente en headless, ya documentado en `test_backup_m107.gd:9-11`), a la que ya le faltan null-guards en parte de la fauna, y una **descarga efímera sin `free()` visible** en `colocar_props_m25.gd:46`. No hay referencias rotas en los `.tscn` verificados ni problemas de `pack()`/`PackedScene.pack()` en runtime. Las dos mejoras propuestas (pool para fauna/vegetación + helper `ScenePool.instanciar` con null-guard) atacan exactamente esos dos únicos frentes abiertos.
