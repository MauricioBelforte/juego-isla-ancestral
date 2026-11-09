# Reporte — Prefabs, escenas reutilizables, instancing y packing (Crouton Alpha)

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-09
**Alcance:** `game/isla-ancestral/scenes/` y `game/isla-ancestral/scripts/` — archivos `.tscn` y `.gd` relacionados con prefabs, escenas reutilizables, instancing, packing.
**Idioma:** español

## Resumen ejecutivo

- **Total `.tscn` en `game/isla-ancestral` (incl. addons y tests): 69.** Propios del juego (`scenes/`): 51. De ellos, 17 son escenas reutilizables (7 `huella_*`, 7 `particulas_*`, `Player.tscn`, `villager.tscn`, `npc_agent.tscn`, `museum.tscn`, `exhibit_slot.tscn`, `CameraRig.tscn`, `debug_menu.tscn`, `hud.tscn`).
- **Total `ext_resource` en todos los `.tscn`: 117.** Todos resuelven a archivos existentes: **0 referencias rotas** (ver §4).
- **Total llamadas `.instantiate()` en `scripts/` + `tests/`: 53** en **43 archivos distintos**. Solo **2 `preload(...tscn)`** en todo el juego; el resto usa `load()` en runtime.
- **Patrón dominante:** `load(ruta)` → null-guard → `PackedScene.instantiate()` → `add_child()`. No se usa `PackedScene.pack()` ni `SceneState` en código de juego (0 coincidencias fuera de Python `struct.pack`).
- **Hallazgos clave:**
  1. Instancing sin limpieza en previews y tests (ver §2, ítems B1–B3): `preview_assets.gd`, `asset_preview.gd`, `validate_lighting_m49.gd`, `sesion_m62_*`, `probe_vram_tormenta.gd` crean instancias que nunca hacen `queue_free()`/`free()`.
  2. Patrón inseguro `load(...tscn).instantiate()` en cadena (sin null-guard) en `scripts/museum/test_museo_rf3.gd:33`, `scripts/player/test_player_m11.gd:163` y `tests/test_bug125_bug126_fix.gd:122,130` — si `load()` devuelve null (headless, recurso movido), crashea con `Invalid call on null`.
  3. El pooling de terrenos (`terrain_particles.gd`, `terrain_footprints.gd`) evita el problema de forma ejemplar: precarga 7 `PackedScene`, reutiliza nodos vía `_pool` y libera con `queue_free()`/`_liberar()`.
  4. No hay problemas de packing/unpacking de escenas: el proyecto no empaqueta escenas en runtime; el único "packing" observado es `load()` de `.glb` (que en Godot 4 son `PackedScene` importadas) en fauna y vegetación.

## Metodología

1. Listado de `.tscn` con `glob` y verificación de `ext_resource path="res://..."` contra disco (script Python ad-hoc `_tmp_scan.py`, luego borrado).
2. Grep de `PackedScene|instantiate\(\)|preload\(.*\.tscn|load\(.*\.tscn` en `scripts/` y de `\.pack\(|pack_scene|SceneState` en todo `game/isla-ancestral/`.
3. Grep de `queue_free\(\)|\.free\(\)` para contrastar instanciación vs. limpieza.
4. Lectura directa de los patrones críticos: `terrain_particles.gd`, `terrain_footprints.gd`, `vegetation_spawner.gd`, `ia_npc/npc_manager.gd`, `npc/villager_manager.gd:587-616`, `fauna/tortuga_npc.gd:88-100`, `fauna/gaviota_npc.gd:116-128`, `museum/museum_placer.gd`, `world/validate_lighting_m49.gd:25-51`, `Player.tscn`, `assets/preview_assets.gd`.

---

## (1) ¿Cómo se instancian escenas reutilizables?

Hay **tres patrones** en el codebase.

### Patrón A — Precarga + pool (recomendado, solo M156 terrenos)

`scripts/terrenos/terrain_particles.gd:62-70` precarga las 7 escenas por terreno una sola vez en `_ready()`:

```gdscript
const RUTA_PARTICULA := "res://scenes/terrenos/particulas_%s.tscn"  # L33
# ...
func _precargar_escenas() -> void:  # L63
	for tid in SLUGS.keys():
		var ruta := RUTA_PARTICULA % SLUGS[tid]
		var escena: PackedScene = load(ruta)
		if escena == null:
			push_warning(...)
			continue
		_escenas[tid] = escena
```

Y reutiliza emisores vía pool con límite `max_emisores = 6` (`L37`, `L103-105`):

```gdscript
func _obtener_nodo() -> CPUParticles3D:  # L123
	if _pool.size() > 0:
		return _pool.pop_back()
	var escena: PackedScene = _escenas.get(_terrain_id)  # L126
	var inst: Node = escena.instantiate()  # L129
	if not inst is CPUParticles3D:
		inst.free()  # L131 — limpieza en el camino de error
		return null
	add_child(nodo)
	return nodo
```

`scripts/terrenos/terrain_footprints.gd:63-79` sigue la misma idea pero es aún más eficiente: en `_cargar_escenas()` hace `load(ruta)` → `instantiate()` → extrae el `mesh` compartido → `inst.free()` (`L76-79`), y luego `_obtener_nodo()` (`L147-158`) crea `MeshInstance3D.new()` crudo con el mesh compartido en vez de instanciar la escena cada vez. El pool (`L49`, `L215-219`) y el fade-out con tween (`L191-211`) cierran el ciclo sin fugas.

### Patrón B — `preload` puntual + `instantiate` (2 casos, correcto)

- `scripts/ia_npc/npc_manager.gd:202-216` — `_create_npc_agent()`:

```gdscript
func _create_npc_agent(villager: Node) -> Object:  # L202
	var agent_scene := preload("res://scenes/npc/npc_agent.tscn")  # L205
	if agent_scene == null:
		var agent := NPCAgentScript.new()  # fallback por script
		villager.add_child(agent)
		return agent
	var instance: Object = agent_scene.instantiate()  # L213
	villager.add_child(instance)
	return instance
```

- `scripts/clock/caso_reloj_tests.gd:21,156,178` — `const ESCENA_CASO := preload("res://scenes/caso_reloj.tscn")` y `ESCENA_CASO.instantiate()` en tests.

### Patrón C — `load()` en runtime + `instantiate()` (dominante, 21 casos)

El `load()` dinámico es la norma. Dos sub-patrónes:

**C1. Con null-guard y limpieza de errores** (bien hecho):

- `scripts/museum/museum_placer.gd:11-21`:

```gdscript
var escena: Variant = load(MUSEO_TSCN)  # L12  MUSEO_TSCN = "res://scenes/museo/museum.tscn" (L7)
if escena == null:
	push_error("[M37] No cargó la escena del museo: %s" % MUSEO_TSCN)  # L14
	return null
var museo: Node3D = escena.instantiate()  # L16
```

- `scripts/fauna/tortuga_npc.gd:88-100`, `scripts/fauna/gaviota_npc.gd:121-128`, `scripts/fauna/jabali_npc.gd:90-94`, `scripts/fauna/cangrejo_npc.gd:66-70`, `scripts/fauna/gaviota_demo.gd:103-104` — todas hacen `ResourceLoader.exists()` + `load()` + null-guard antes de `instantiate()`. Ejemplo tortuga (`L84-93`):

```gdscript
if not ResourceLoader.exists(glb):
	push_warning("[Tortuga] GLB no encontrado: %s — usando placeholder" % glb)
	_instanciar_placeholder()
	return
var escena: PackedScene = load(glb)
if escena == null:
	push_warning("[Tortuga] load() -> null para %s - placeholder (BUG-121)" % glb)
	_instanciar_placeholder()
	return
var modelo: Node3D = escena.instantiate()
```

- `scripts/npc/villager_manager.gd:587-591` — `_spawn_vecino_de_perfil()` con ternario:

```gdscript
var escena := load("res://scenes/npc/villager.tscn") if ResourceLoader.exists("res://scenes/npc/villager.tscn") else null
var nodo: Node = null
if escena != null:
	nodo = escena.instantiate()  # L591
else:
	nodo = Node3D.new()
```

- `scripts/world/validate_lighting_m49.gd:37-50` — valida `packed is PackedScene` antes de instanciar (modelo para validadores headless).

**C2. Sin null-guard (crashea si `load()` falla)** — ver §2/B y §3:

- `scripts/museum/test_museo_rf3.gd:33`: `var museo: Node = load("res://scenes/museo/museum.tscn").instantiate()` — sin guard.
- `scripts/player/test_player_m11.gd:163`: `var tmp = load("res://scenes/player/Player.tscn").instantiate()`.
- `tests/test_bug125_bug126_fix.gd:122,130`: `load("res://scenes/preview_reloj.tscn").instantiate()` y `load("res://scenes/player/Player.tscn").instantiate()`.

### Escenas referenciadas como "prefab" en `.tscn` (instancing en editor)

`scenes/player/Player.tscn:4,23` instancia el modelo GLB como `PackedScene` externa:

```
[ext_resource type="PackedScene" path="res://assets/3d/media/45-Arte3D_jugador_voxel.glb" id="2_voxel"]   # L4
[node name="ModeloVoxel" parent="." instance=ExtResource("2_voxel")]                                     # L23
```

Y `scenes/main.tscn:6`, `scenes/main_simple.tscn:5`, `scenes/main_test.tscn:5`, `scenes/main_test2.tscn:4`, `scenes/main_island.tscn:9` instancian `scenes/player/Player.tscn` vía `instance=ExtResource(...)`. Es el uso canónico de Godot: el `.tscn` como prefab componible.

### `PackedScene` como atributo serializado

- `scripts/data/item_data.gd:86`: `@export var modelo_3d: PackedScene = null`
- `scripts/eventos/event_definition.gd:60`: `## PackedScene del recinto del evento. null = evento sin escena`

### Vegetación ( caso especial: `load()` por ítem del plan )

`scripts/vegetacion/vegetation_spawner.gd:68-116`:

```gdscript
for item in plan:  # L68
	var ruta := "res://assets/3d/media/%s.glb" % tipo
	if not FileAccess.file_exists(ruta):  # L71
		continue
	var res = load(ruta)  # L75
	if res == null:
		continue
	var inst = res.instantiate()  # L79
	# ...
	if h < 3:  # BUG-022: no plantar sobre agua
		inst.free()  # L88 — limpieza del descarte
		continue
	_contenedor.add_child(inst)  # L108
```

El autoload cuelga las instancias de un nodo propio (`_contenedor`, `L25-34`) — fix del BUG-129 documentado en `L10-16` — y las libera en `_exit_tree()` (`L37-41`). Es el **único spawner masivo con limpieza correcta de descartes**.

---

## (2) ¿Hay escenas `.tscn` que se instancian repetidamente sin limpieza?

**Sí. Hay tres grupos con evidencia.**

### B1. Previews que cargan N GLB e instancian sin liberar nunca

`scripts/assets/preview_assets.gd:40-47`:

```gdscript
func _cargar(ruta: String, pos: Vector3) -> void:  # L39
	var res: PackedScene = load(ruta)
	if res == null:
		return
	var inst: Node3D = res.instantiate()  # L44
	inst.position = pos
	add_child(inst)  # nunca queue_free
```

El `_ready()` (`L11-47`) llama `_cargar()` 4 veces (palmera, helecho, hongo, arbusto, `L33-36`). El script **no tiene `queue_free()` ni `_exit_tree`** (confirmado por el escaneo: `asset_preview.gd` y `preview_assets.gd` están en la lista INST_SIN_FREE). Como es una escena de preview de vida corta, la fuga es menor, pero si `preview_assets.tscn` se re-instancia en tests o en el menú de assets, cada visita acumula 4 nodos GLB.

Mismo síntoma en `scripts/assets/asset_preview.gd:36-40` (`var asset: Node = empaquetada.instantiate()` + `add_child`, sin `free`).

### B2. Validadores y sondas headless que instancian la escena raíz sin liberar

- `scripts/world/validate_lighting_m49.gd:44` — `_escena = packed.instantiate()` (instancia **`main_island.tscn`**, la escena más pesada del proyecto) y **nunca lo libera**: no hay `_exit_tree`, `free()` ni `queue_free()` en las 144 líneas del archivo. Si el validador se corre en bucle (CI/gate), cada corrida deja la isla completa en memoria hasta que el proceso muere.
- `scripts/rendimiento/memoria/probe_vram_tormenta.gd:10-11` — `var packed: PackedScene = load("res://scenes/main_island.tscn")` + `packed.instantiate()`, sin `free`.
- `scripts/rendimiento/memoria/sesion_m62_*.gd` (5 archivos: `sesion_m62_30min.gd:71-77`, `sesion_m62_baselines.gd:134-140`, `sesion_m62_clima_30min.gd:134-140`, `sesion_m62_limite.gd:70-76`, `sesion_m62_voxel_500.gd:107-113`, `test_m62_chunks_presupuesto.gd:71-77`) — mismo patrón `load(ESCENA)` + `instantiate()` sin `free` visible. Son sondas de sesión de 30 min: si la sonda itera dentro del mismo proceso, la memoria crece linealmente con las iteraciones.
- `scripts/core/probe_runtime_bus_m14.gd:85` — `var escena: Node = ps.instantiate()` sin limpieza en el archivo.

### B3. Fauna NPC que instancia GLB una vez por animal sin `free` de reemplazos

`scripts/fauna/tortuga_npc.gd:88-100`, `gaviota_npc.gd:121-128`, `jabali_npc.gd`, `cangrejo_npc.gd`, `gaviota_demo.gd:103-104` hacen `add_child(modelo)` y **nunca liberan el modelo anterior** si `_instanciar_modelo()` se llama dos veces (p. ej. cambio de variante LOD). No hay `if _modelo: _modelo.queue_free()` antes de la segunda instanciación. En gameplay normal (cada animal instancia 1 vez en `_ready`) no es fuga activa, pero es una trampa si alguien re-llama al método.

### B4. (No es fuga, pero es riesgo documentado) — los 20 archivos INST_SIN_FREE

El escaneo encontró **20 archivos** que llaman `.instantiate()` y no contienen `queue_free()` ni `.free()` (lista completa en el apéndice). La mayoría son previews y tests de vida corta (riesgo bajo), pero `museum_placer.gd`, `npc_manager.gd` y `villager_manager.gd` son código de juego real. En `villager_manager.gd` la "limpieza" es delegada al `Node` padre (`get_tree().current_scene.add_child(nodo)` en `L603-608`), así que no es fuga mientras el manager viva; pero si un villager muere/desaparece sin que el manager lo remueva, el nodo queda.

**Contraste positivo:** M156 terrenos y `vegetation_spawner.gd` demuestra que el proyecto **sabe** hacerlo bien (pooling + `_liberar()` + `_exit_tree()`). El problema es que el resto no replica el patrón.

---

## (3) ¿Hay problemas de packing/unpacking de escenas?

**No se detectó ningún problema de packing/unpacking, porque el proyecto no hace packing en runtime.**

- `grep \.pack\(|pack_scene|SceneState` en `game/isla-ancestral/` → **0 coincidencias** en código GDScript (los 20 hits son `struct.pack` de Python en `tools/font_subsetter.py`, no relacionados con escenas).
- No hay `PackedScene.pack()`, ni `ResourceSaver.save()` sobre escenas, ni serialización/deserialización manual de `SceneState`.
- Lo que existe es **unpacking implícito**: `load(".glb")` devuelve un `PackedScene` (Godot importa cada GLB como escena) y se instancia con `instantiate()`. Esto se hace en fauna (`tortuga_npc.gd:88`, `gaviota_npc.gd:121`), vegetación (`vegetation_spawner.gd:75`) y previews (`preview_assets.gd:40`). Es el uso correcto de Godot 4 para modelos; no hay packing manual ni corrupción.
- El único bug conocido de esta familia ya está documentado en el propio código: `scripts/backup/test_backup_m107.gd:11` comenta `# load(.glb) devuelve null en headless y no hay null-guard antes de .instantiate()` — es la clase de fallo que el patrón C2 (`load().instantiate()` en cadena) reproduce.

**Conclusión §3:** no hay corrupción de escenas ni drift de packing. El riesgo real es el **null-guard ausente** (§2/B2), no el packing.

---

## (4) ¿Hay prefabs con referencias rotas a escenas externas?

**No. Cero referencias rotas.**

- Verificación automática de los 69 `.tscn`: cada `ext_resource path="res://..."` se contrastó con disco. **BROKEN = 0** (117 `ext_resource` totales, todos existen).
- Las escenas reutilizables externas referenciadas (únicas fuentes de verdad de instancing en editor):

| Escena reutilizable | Referenciada desde |
|---|---|
| `scenes/player/Player.tscn` | `scenes/main.tscn:6`, `scenes/main_simple.tscn:5`, `scenes/main_test.tscn:5`, `scenes/main_test2.tscn:4`, `scenes/main_island.tscn:9` |
| `scenes/player/Player.tscn` (modelo) | `scenes/player/Player.tscn:4` → `res://assets/3d/media/45-Arte3D_jugador_voxel.glb` |
| `scenes/npc/npc_agent.tscn` | `scripts/ia_npc/npc_manager.gd:205` (preload) |
| `scenes/npc/villager.tscn` | `scripts/npc/villager_manager.gd:588` (load + exists) |
| `scenes/museo/museum.tscn` | `scripts/museum/museum_placer.gd:7,12` |
| `scenes/terrenos/particulas_*.tscn` (7) | `scripts/terrenos/terrain_particles.gd:33,66` |
| `scenes/terrenos/huella_*.tscn` (7) | `scripts/terrenos/terrain_footprints.gd:32,71` |

- Observación de higiene (no es bug): `scenes/museo/exhibit_slot.tscn`, `scenes/npc/npc_agent.tscn`, `scenes/npc/villager.tscn` son escenas "hijas" que solo se instancian por código, sin ninguna escena madre que las referencie en `.tscn`. Es correcto (prefabs vía código), pero significa que su única validación es el `ResourceLoader.exists()`/`preload` del spawner — que ya existe.

---

## (5) Sugerencias (2 mejoras)

### Mejora 1 — Extender el pooling de M156 al resto de spawners (mata §2/B1–B3 de raíz)

Crear un autoload/helper `ScenePool` reutilizable (por ejemplo `scripts/core/scene_pool.gd`) con la API ya probada en `terrain_particles.gd:123-135` / `terrain_footprints.gd:147-219`:

```gdscript
class_name ScenePool
extends Node

# pool: PackedScene -> Array[Node]   tipo: tipo de nodo -> máx
# conseguir(escena) -> Node     liberar(nodo) -> void     _exit_tree(): queue_free de todo
```

Aplicarlo en orden de impacto:
1. **Fauna NPC** (`scripts/fauna/*_npc.gd`, 5 archivos): cachear la `PackedScene` del GLB en `_ready()` (`load` una vez, no por llamada) y antes de re-instanciar hacer `if _modelo: _modelo.queue_free()`. Cierra B3 y elimina el `load()` repetido.
2. **Validadores/sondas** (`scripts/world/validate_lighting_m49.gd:44`, `scripts/rendimiento/memoria/*`): envolver la instancia en `add_child` + `queue_free()` en `_exit_tree()` o al final del `_run()`. En `validate_lighting_m49.gd` basta agregar tras `_run()`: `_escena.queue_free()` antes de `quit()` (`L61-63`).
3. **Previews** (`scripts/assets/preview_assets.gd`, `asset_preview.gd`): agregar `_exit_tree()` que haga `queue_free()` de los hijos instanciados, o reutilizar `ScenePool` con `max = 4`.

**Coste estimado:** S (1 archivo nuevo + 5-8 ediciones de 3-5 líneas). **Beneficio:** elimina las 3 familias de fuga y fija un único patrón de instancing para todo el proyecto.

### Mejora 2 — Guard anti-null en cadena `load().instantiate()` (mata el crash §2/B2 y §3)

Añadir a `scripts/validadores/` (o a la guía `GUIA-GODOT/01-gdscript-errores-comunes.md`) un chequeo estático —o mejor, un helper— que prohíba `load(...).instantiate()` en cadena:

```gdscript
# Helper propuesto: scripts/core/scene_loader.gd
static func instanciar(ruta: String, padre: Node) -> Node:
	if not ResourceLoader.exists(ruta):
		push_warning("[SceneLoader] no existe: ", ruta)
		return null
	var ps := load(ruta) as PackedScene
	if ps == null:
		push_warning("[SceneLoader] load() -> null: ", ruta)
		return null
	var inst := ps.instantiate()
	if padre != null:
		padre.add_child(inst)
	return inst
```

Y reemplazar los 4 sitios inseguros:
- `scripts/museum/test_museo_rf3.gd:33`
- `scripts/player/test_player_m11.gd:163`
- `tests/test_bug125_bug126_fix.gd:122,130`

**Coste estimado:** S (1 helper + 3-4 líneas por sitio). **Beneficio:** convierte un crash silencioso (`Invalid call on null` en headless/CI) en un warning accionable, y documenta el patrón BUG-121 ya conocido en fauna.

*(Mejora alternativa si se prefiere no tocar fauna: priorizar el fix de `scripts/world/validate_lighting_m49.gd` — agregar `_escena.queue_free()` en `_run_fin()` (`L61-63`) — es un one-liner que evita cargar `main_island.tscn` en memoria por cada gate de CI.)*

---

## Conclusión final

El sistema de escenas reutilizables del proyecto es **sano en estructura e instancing en editor** (0 referencias rotas, `Player.tscn` compuesto correctamente, 14 prefabs de terreno limpios) y **ejemplar en su zona más caliente** (M156 terrenos y vegetación usan pooling/precarga con limpieza). El riesgo no está en el packing (no se hace) ni en referencias rotas (no hay), sino en la **disciplina de limpieza fuera de esa zona**: 20 archivos instancian sin `free`, 3 previews/validadores acumulan instancias huérfanas y 3 sitios usan `load().instantiate()` sin null-guard. Las dos mejoras propuestas (pool generalizado + helper de carga segura) son de bajo coste y replican patrones que el propio proyecto ya validó. No se modificó ningún archivo del juego; este reporte es solo lectura.

## Apéndice — Evidencia técnica

- `.tscn` totales: **69** (51 propios en `scenes/` + 2 en `scripts/ui/` + 2 en `tests/fixtures/` + 14 de `addons/gdUnit4/`).
- `ext_resource`: **117**, **0 rotas**.
- `.instantiate()`: **53** llamadas en **43 archivos** (`scripts/` + `tests/`).
- `preload(.tscn)`: **2** (`scripts/ia_npc/npc_manager.gd:205`, `scripts/clock/caso_reloj_tests.gd:21`).
- `load(.tscn)`: **21** sitios (lista completa en §1/C).
- `.pack(`/`SceneState`: **0** en GDScript.
- Archivos con `instantiate()` pero **sin** `queue_free()`/`.free()` (20): `assets/asset_preview.gd`, `assets/preview_assets.gd`, `backup/test_backup_m107.gd`, `clock/caso_reloj_tests.gd`, `core/probe_runtime_bus_m14.gd`, `debug/test_debug_m110.gd`, `fauna/Obsoletos/2026-09-04_02-10-00_gaviota_npc_backup_v10.gd`, `fauna/cangrejo_npc.gd`, `fauna/gaviota_demo.gd`, `fauna/gaviota_npc.gd`, `fauna/jabali_npc.gd`, `fauna/tortuga_npc.gd`, `ia_npc/npc_manager.gd`, `legal/test_legal_m78_v2.gd`, `museum/museum_placer.gd`, `npc/villager_manager.gd`, `performance/medir_runtime_m61.gd`, `rendimiento/memoria/probe_vram_tormenta.gd`, `rendimiento/memoria/sesion_m62_30min.gd`, `rendimiento/memoria/sesion_m62_baselines.gd`.

*Reporte generado por Crouton Alpha (Kilo Code) el 2026-11-09 mediante grep/glob/lectura directa. No se modificó ningún archivo del juego.*
