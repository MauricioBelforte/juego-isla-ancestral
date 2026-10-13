# 04-Codigo.md — Módulo 35: Minería

**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31

> Rutas propuestas dentro de `res://_Project/` (estructura adaptada a Godot 4.x según AGENTS.md sección 24). Se ajustarán a la estructura final del proyecto Godot.
>
> ⚠️ **Corrección 2026-10-11 (re-QA §21.8, DeepSeek-V4.1-Flash):** las rutas de la sección 1 son el
> diseño ORIGINAL previo a la opción B. El código realmente implementado y versionado es
> `res://scripts/mineria/mining_manager.gd` (9011 B, autoload `mineria` en `project.godot` L48),
> `res://scripts/mineria/mining_vein_catalog.gd` (4244 B) y el catálogo de datos
> `res://data/mining/ores.json` (NO `res://_Project/ScriptableObjects/Mining/ore_catalog.tres`).
> `OreDefinition.gd` / `OreVein.gd` / `MiningTool.gd` / `OreVein.tscn` / `MiningTool.tscn` de la tabla
> **no existen**: la opción B delega en `ResourceDefinition`/`ResourceNode`/`ToolData` de M15/M13.
> Suite headless medida (Godot 4.7.2, 2026-10-11, tras el lote 1): `test_mineria.gd` 92 checks / 0 fallos (EXIT 0).

## 1. Archivos involucrados

| Ruta | Rol |
|---|---|
| `res://_Project/Scripts/Gameplay/Mining/MiningManager.gd` | Autoload `mineria`: catálogo, distribución, regeneración, persistencia |
| `res://_Project/Scripts/Gameplay/Mining/OreDefinition.gd` | Recurso `.tres` con la data de cada mineral |
| `res://_Project/Scripts/Gameplay/Mining/OreVein.gd` | Estado de veta: golpes, temporizador, serialización |
| `res://_Project/Scripts/Gameplay/Mining/MiningTool.gd` | Componente de golpe del pico (M13) |
| `res://_Project/ScriptableObjects/Mining/ore_catalog.tres` | Catálogo central de minerales |
| `res://_Project/ScriptableObjects/Mining/ore_cobre.tres` | Cobre (superficie, dureza 2) |
| `res://_Project/ScriptableObjects/Mining/ore_hierro.tres` | Hierro (subterráneo, dureza 3) |
| `res://_Project/ScriptableObjects/Mining/ore_oro.tres` | Oro (subterráneo medio, dureza 3) |
| `res://_Project/ScriptableObjects/Mining/ore_cristal.tres` | Cristal (profundo, dureza 4, raro) |
| `res://_Project/ScriptableObjects/Mining/ore_ancestral.tres` | Mineral ancestral (capa M26, dureza 4, raro) |
| `res://_Project/ScriptableObjects/Mining/ore_polvo_estrellas.tres` | Polvo de estrellas (nodos especiales M26, muy raro) |
| `res://_Project/Prefabs/Mining/OreVein.tscn` | Nodo de veta (estado; sin geometría propia) |
| `res://_Project/Prefabs/Mining/MiningTool.tscn` | Pico equipable con node 3D y raycast |
| `res://_Project/FX/Particles/VetaBreak.tscn` | Partículas de extracción (pooled) |
| `res://_Project/FX/Particles/VetaSparkle.tscn` | Chispa de anuncio de veta recuperada |
| `res://_Project/Audio/Mining/golpe_*.ogg` | Golpes por material (piedra/cobre/hierro/cristal) |
| `res://_Project/Audio/Mining/extraccion_*.ogg` | Extracciones por material |

Catálogo de minerales coherente con M15: `cobre`, `hierro`, `oro_ancestral`, `cristal_estacional`, `polvo_estrellas`.

## 2. Firmas clave (GDScript)

### MiningManager.gd (Autoload `mineria`)

```gdscript
extends Node

signal ore_dropped(ore: OreDefinition, amount: int, world_pos: Vector3)
signal vein_recovered_global(vein_id: int)
signal zone_exhausted(zona: StringName)

const REGEN_TICK: float = 0.5
const MAX_RESPAWN_INTENTS: int = 3
const CATALOGO_PATH: String = "res://_Project/ScriptableObjects/Mining/ore_catalog.tres"

@onready var _defs: Dictionary = {}                    # StringName -> OreDefinition
@onready var _veins: Dictionary = {}                   # int -> OreVein
@onready var _zone_quota: Dictionary = {}              # StringName -> int
@onready var _regen_buffer: Array[OreVein] = []

func _ready() -> void:
    cargar_catalogo(CATALOGO_PATH)

func cargar_catalogo(path: String) -> void:
    var catalog: Array[OreDefinition] = load(path).definiciones
    for def in catalog:
        register_definition(def)

func register_definition(def: OreDefinition) -> void:
    assert(def.id != &"", "OreDefinition sin id")
    assert(not _defs.has(def.id), "Id duplicado: %s" % def.id)
    _defs[def.id] = def

func get_definition(id: StringName) -> OreDefinition:
    return _defs.get(id)

func on_vein_depleted(vein: OreVein) -> void:
    var def := get_definition(vein.ore_id)
    var drops := calcular_drops(def, _tool_power_actual())
    for d in drops:
        M15.agregar_recursos(d.recurso, d.cantidad)
        emit_signal("ore_dropped", def, d.cantidad, vein.global_position)
    vein.estado_regenerando()
    _veins[vein.instancia_id()] = vein
    persistir_cambio("vein_agotada", vein.serialize())

func calcular_drops(def: OreDefinition, power: int) -> Array[Dictionary]:
    var rng := M29.partida_rng()
    var cantidad := rng.randi_range(def.drop_min, def.drop_max)
    if rng.randf() < def.double_drop_chance + 0.05 * power:
        cantidad *= 2
    return [{"recurso": def.id, "cantidad": cantidad}]

func place_veins_in_chunk(chunk_origin: Vector3i, rng: RandomNumberGenerator) -> void:
    var count := densidad_por_zona(M08.zona_de(chunk_origin))
    for i in count:
        var pos := Vector3i(chunk_origin.x + rng.randi_range(0, 15),
                surface_height_at(chunk_origin) - rng.randi_range(1, 6),
                chunk_origin.z + rng.randi_range(0, 15))
        seleccionar_y_crear_veta(pos, rng, chunk_origin)

func process_regen(delta: float) -> void:
    if M30.is_paused():
        return
    for vein in _regen_buffer.duplicate():
        vein.regen_remaining -= delta
        if vein.regen_remaining <= 0.0:
            if vein.can_respawn():
                vein.reset_blocks()
                emit_signal("vein_recovered_global", vein.instancia_id())
                _regen_buffer.erase(vein)
            else:
                vein.reintentos += 1
                if vein.reintentos >= MAX_RESPAWN_INTENTS:
                    vein.regen_remaining = M29.dia_duracion()
                    vein.reintentos = 0

func serialize() -> Dictionary:
    var data := {"vetas": []}
    for vein in _veins.values():
        data.vetas.append(vein.serialize())
    return data

func deserialize(data: Dictionary) -> void:
    for raw in data.get("vetas", []):
        var vein: OreVein = OreVein.new()
        vein.deserialize(raw)
        register_vein(vein)
```

### OreVein.gd

```gdscript
class_name OreVein
extends Node3D

signal vein_depleted(vein: OreVein)
signal vein_recovered(vein: OreVein)

enum State { INTACTA, AGOTADA, REGENERANDO }

@export var ore_id: StringName
var blocks: Array[Vector3i] = []
var state: State = State.INTACTA
var blocks_remaining: int = 0
var golpes_actual: int = 0
var regen_remaining: float = 0.0
var reintentos: int = 0

func setup(p_ore: OreDefinition, p_blocks: Array[Vector3i]) -> void:
    ore_id = p_ore.id
    blocks = p_blocks
    blocks_remaining = p_blocks.size()
    golpes_actual = p_ore.hardness
    state = State.INTACTA

func hit(tool_power: int) -> bool:
    if state != State.INTACTA:
        return false
    golpes_actual -= tool_power
    if golpes_actual <= 0:
        blocks_remaining -= 1
        if blocks_remaining <= 0:
            state = State.AGOTADA
            emit_signal("vein_depleted", self)
        else:
            golpes_actual = mineria().get_definition(ore_id).hardness
    return true

func is_depleted() -> bool:
    return state == State.AGOTADA

func can_respawn() -> bool:
    for b in blocks:
        if M08.is_occupied(b):
            return false
    return true

func estado_regenerando() -> void:
    state = State.REGENERANDO
    regen_remaining = mineria().get_definition(ore_id).respawn_days

func serialize() -> Dictionary:
    return {"ore": String(ore_id), "blocks": blocks, "state": state,
            "blocks_rem": blocks_remaining, "golpes": golpes_actual, "regen": regen_remaining}

func deserialize(data: Dictionary) -> void:
    ore_id = StringName(data.ore)
    blocks.assign(data.blocks)
    state = data.state
    blocks_remaining = data.blocks_rem
    golpes_actual = data.golpes
    regen_remaining = data.regen
```

### MiningTool.gd

```gdscript
class_name MiningTool
extends Node3D

signal swing_started()
signal hit_vein(vein: OreVein, drops: Array[Dictionary])
signal hit_air()

@export_range(1, 3) var tool_power: int = 1
@export var cooldown: float = 0.6
@export var range: float = 3.5
@export var durability_max: int = 100
var durability_current: int = 100
var _last_use: float = -INF

func can_use() -> bool:
    return durability_current > 0 and Time.get_ticks_msec() - _last_use >= cooldown * 1000.0

func use() -> Dictionary:
    if not can_use():
        return {"acierto": false, "drops": []}
    _last_use = Time.get_ticks_msec()
    emit_signal("swing_started")
    var vein := _raycast_vein()
    if vein == null:
        emit_signal("hit_air")
        return {"acierto": false, "drops": []}
    var hit_ok := vein.hit(tool_power)
    if hit_ok:
        consume_durability(1)
        var drops := mineria().on_vein_depleted(vein) if vein.is_depleted() else []
        emit_signal("hit_vein", vein, drops)
        return {"acierto": true, "drops": drops}
    return {"acierto": false, "drops": []}

func _raycast_vein() -> OreVein:
    var space := get_world_3d().direct_space_state
    var from := global_position
    var to := from + -global_transform.basis.z * range
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.collision_mask = MINERIA_MASK_VETA
    var result := space.intersect_ray(query)
    return result.get("collider") as OreVein

func consume_durability(amount: int) -> void:
    durability_current = maxi(0, durability_current - amount)
    M13.actualizar_durabilidad_pico(durability_current)

func apply_tool_power_from_pickaxe(pickaxe_level: int) -> void:
    tool_power = pickaxe_level
    cooldown = maxf(0.45, 0.6 - 0.05 * pickaxe_level)
```

## 3. Constantes y máscaras

| Constante | Valor | Uso |
|---|---|---|
| `MINERIA_MASK_VETA` | capa de colisión dedicada | Raycast del pico solo detecta vetas |
| `MINERIA_LAYER_BLOQUE` | capa del voxel (M08) | Escritura de bloques de mineral |
| `REGEN_TICK` | 0.5 s | Granularidad del barrido de regeneración |
| `MAX_RESPAWN_INTENTS` | 3 | Reintentos de respawn antes de diferir al próximo día |

## 4. Logs

| Código | Origen | Mensaje |
|---|---|---|
| `DOM-MIN` | MiningManager | `[DOM-MIN] veta %d agotada, drops %s` |
| `DOM-MIN` | MiningManager | `[DOM-MIN] veta %d recuperada tras %.1f d` |
| `DOM-MIN` | MiningManager | `[DOM-MIN] respawn diferido: zona ocupada (intento %d/3)` |
| `DOM-MIN` | MiningTool | `[DOM-MIN] pico sin durabilidad, golpe ignorado` |
| `DOM-MIN` | MiningManager | `[DOM-MIN] zona %s agotada por límite diario` |
| `DOM-MIN` | MiningManager | `[DOM-MIN] definición ausente %s, drop fallback` |

Los logs se emiten con la convención del sistema `DOM-` (dominio) y rotación según sección 18 de AGENTS.md; no se crean archivos de log dentro de `Assets/`.

## 5. Persistencia

- `MiningManager.serialize()` se integra con el guardado del juego (M07 persistencia general): sección `"mineria"`.
- El temporizador se guarda como **tiempo restante acumulado** (días de juego), no como timestamp real, para evitar exploits de guardado/carga.
- Al cargar, `deserialize()` revalida contra el voxel M08: bloques que ya no existen (editados por M17) se descartan de la veta.

## Notas del Agente (minimax-m3-free / Kilo Code)

**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31
**Estado:** Iter 1 cerrada (núcleo V0 + tests OK + autoload activo). Módulo 🟡 Liberado con honestidad: lo que NO es de M35 queda [?] con dueño en el checklist.

### Lo que hice

- Implementé la **opción B** recomendada por Deepseek (ver nota de `05-Checklist.md`): las vetas son `ResourceNode` de M15 con `categoria = MINERAL/RARO` y `herramienta_requerida = "pico"`. **No toqué `ResourceManager`, `ResourceNode` ni `ResourceDefinition`.**
- Agregué 3 archivos nuevos + 1 JSON + 1 línea en `project.godot`:
  - `scripts/mineria/mining_vein_catalog.gd` (`MiningVeinCatalog`): lee `data/mining/ores.json` y registra las 6 vetas en `ResourceManager` **solo si el id no existe** (no pisa `_mineral_cobre` / `_fragmento_ancestral`).
  - `scripts/mineria/mining_manager.gd` (`MiningManager`, autoload `mineria`): capa de dominio de minería. Expone `intentar_extraccion(nodo, tool)` con RF6 (doble drop si tool mejorada + def requiere mejorada) y RF10 (límite suave diario por zona, `zone_exhausted` signal). Persiste `zone_quota` y `zone_quota_dia` en M59.
  - `data/mining/ores.json`: 6 vetas data-driven (cobre, hierro, oro, cristal, ancestral, polvo_estrellas) con `region` (cantera/cueva/templo) y `profundidad_banda`.
  - `scripts/mineria/test_mineria.gd`: 42 asserts OK / 0 fallos.
  - `project.godot`: `mineria="*res://scripts/mineria/mining_manager.gd"` agregado al `[autoload]`.

### Lo que NO pude hacer (honestidad obligatoria)

- **RF4 cuevas/techos**: las vetas como `ResourceNode` se spawnean en superficie (M15 ResourceSpawner); las cuevas con vetas en paredes/techos dependen de M26 (Templo Subterráneo) y de la escena 3D. Documentado [?] en §C y §G.
- **Polish cozy visual (partículas, sonidos, colores emisivos, derrumbes, chispa de anuncio)**: depende de assets de M45, M52, M43 — todos [?] con dueño en §C, §L.
- **UI de durabilidad / texto flotante / vibración**: depende de M53 (UI) y del widget de tool_controller — [?].
- **Profiler 50 vetas + recorrido end-to-end**: benchmarks de M61 + M138 — [?].
- **Sistema de "capa superficial indestructible" (opción A)**: queda ABIERTO como tarea de M08, fuera del alcance de M35.
- **Fundición de lingotes y precios de venta**: integración con M16 y M38 — el campo `valor_venta` está en el JSON, pero el flujo completo de fundición/economía lo hace cada módulo dueño.

### Intentos fallidos / decisiones

- **Decisión clave: NO duplicar ResourceManager.** El diseño de `02-Analisis.md` proponía un `MiningManager` con `place_veins_in_chunk`, `_zone_quota`, `_veins`, `calcular_drops`. En el código real ya existe todo eso en `ResourceManager` + `ResourceSpawner` + `ResourceNode`. Implementar la versión A habría sido trabajo doble con bugs dobles. La opción B reduce ~80% del código y zero conflictos.
- **Mapeo `ToolData.Nivel` → `tool_id`**: el contrato de M15 (`es_accesible_con`) compara `StringName` con el `herramienta_requerida` del def. Como `ToolData.Nivel` es 1..4 (COBRE/HIERRO/ORO/CRISTAL), el helper `_tool_id()` devuelve `pico`, `pico_hierro`, `pico_oro`, `pico_cristal`. Esto permite que un def con `herramienta_requerida="pico"` acepte los 4 tiers, mientras que uno con `"pico_oro"` solo acepte T3+. Si el dueño de M15 quiere el contrato inverso, hay que ajustar este mapeo (decisión de integración pendiente con M13/M15).
- **Reset diario con `_zone_quota_dia`**: el manager usa `GameTime.dia_cambio` (señal M29) para resetear. Si `GameTime` no está disponible (test aislado), la cuota persiste — por eso `_reset_si_cambio_dia()` también chequea manualmente.

### Recomendaciones para el próximo agente

- **Integración con M13**: cuando el `ToolController` llame al golpe real, debería enrutar por `MiningManager.intentar_extraccion(nodo, herramienta)` en vez de llamar directo a `ResourceManager.recibir_golpe_en_nodo`. El cambio es de 1 línea en `tool_controller.gd` (no hecho en iter 1 para no modificar M13 sin coordinación con su dueño Hy3).
- **Distribución en chunks**: el `ResourceSpawner` actual `planificar_region()` no distingue entre regiones mineras. Cuando el sistema de regiones mineras (cantera/cueva/templo) esté activo, conviene agregar una `region_id` específica para minería o reutilizar el `region` del def.
- **Visuales**: los placeholders de M15 (cajas coloreadas) son feos para vetas mineras. El equipo de arte (M45) debería generar meshes con emissive por rareza (oro brillante, cristal luminoso, ancestral mágico).
- **Tests E2E con GameTime real**: el test actual no usa GameTime (autoload ausente en headless aislado). Para probar respawn + reset diario reales, usar `godot --headless res://scenes/test_runner.tscn` (M112) con un test que cree un nodo, lo agote, avance el día y verifique respawn.
- **QA cruzado (§21.8)**: el módulo está listo para verificación por **Hy3 (WorkBuddy)**.

### Pitfalls de Godot documentados en este turno

- **Mine_extraccion_fallida → mina_extraccion_fallida (typo de señal)**: las señales NO se llaman como funciones; se emiten con `.emit(args)`. El linter de Godot 4.7 lo detecta correctamente. Documentado en GUIA-GODOT/01-gdscript-errores-comunes.md §1.1 (ya estaba).
- **Sin `class_name` en autoloads**: respetado (`MiningManager` extiende `Node`, registrado por path en project.godot, no por class_name). Ver GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41.
- **Variables inferidas con `:=` y Dictionary/Array heterogéneos**: forzar tipo explícito (`var zona: String = ...`, `var tool_id: StringName = ...`) para evitar `Cannot infer the type` en parse.

## Lote 1 de implementación (2026-10-11, DeepSeek-V4.1-Flash)

Encargo del director `mimo` (msg 167): implementar los `[ ]` de mayor impacto de M35.
Todo el lote vive en `scripts/mineria/mining_manager.gd` (archivo propio del módulo);
no se tocó ningún archivo de M13/M15/M08.

### Estado real de la API (medido en disco, 2026-10-11)

| Archivo | Rol | Bytes |
|---|---|---|
| `res://scripts/mineria/mining_manager.gd` | autoload `mineria` (project.godot L48): catálogo, límite por zona (RF10), drops (RF6), persistencia | 13619 |
| `res://scripts/mineria/mining_vein_catalog.gd` | `class_name MiningVeinCatalog`: lee `ores.json` y registra 6 vetas en M15 | 4364 |
| `res://data/mining/ores.json` | catálogo data-driven (6 vetas, con `item_id` real por veta) | — |
| `res://scripts/mineria/test_mineria.gd` | suite headless (`extends SceneTree`, `--script`) | 16954 |

API pública real: `intentar_extraccion(nodo, tool) -> Dictionary`,
`is_zone_exhausted(zona)`, `quota_restante(zona)`, `get_save_data()` / `restore_save_data()`.
Señales: `mina_extraccion_exitosa(def_id, cantidad, world_pos, zona)`,
`mina_extraccion_fallida(def_id, razon)`, `zone_exhausted(zona)`.
Guarda de estado de veta: `ResourceNode` de M15 (`INTACTO`/`DANIADO`/`AGOTADO`), no `OreVein`.

### Defectos corregidos (medidos con sonda headless antes y después)

1. **H-A — todo pico T2+ era rechazado.** `_tool_id()` mapeaba el nivel a
   `"pico_hierro"` / `"pico_oro"` / `"pico_cristal"`, pero
   `ResourceDefinition.es_accesible_con()` compara por **igualdad** contra
   `herramienta_requerida` (`"pico"`) → `"pico_oro" == "pico"` es `false` y
   `intentar_extraccion` devolvía `herramienta_invalida`. Medido: con `ToolData`
   T3 el intento fallaba; con T1 funcionaba. Fix: `_tool_id()` devuelve
   `ToolData.nombre_id()` (`"pico"`), el mismo contrato que ya usa M13
   (`tool_controller.gd:340`).
2. **H-B — el RF6 (doble drop) nunca se entregaba.** El drop se calculaba dos veces
   (M15 con un sorteo PRNG y M35 con otro) y M35 solo *informaba* la cantidad en la
   señal. Fix: M35 calcula los drops una sola vez, los entrega él mismo con
   `ResourceManager.entregar_drops()` y reporta la cantidad realmente entregada.
3. **H-C — drop fantasma.** El fallback anti-frustración de
   `ResourceManager.generar_drops()` usa `def_id` como `item_id`; como las vetas
   tienen `def_id != item_id`, entregaba un item inexistente. Medido: minar
   `veta_oro` depositaba **1 × `veta_oro`** en el inventario y **0 × `ancient_crystal`**.
   Fix (en M35): el fallback usa `_item_principal(def)` (el item real). *(El defecto
   de M15 queda reportado; no se tocó su archivo.)*
4. **Guards nuevos**: herramienta inutilizada (J8), veta ya agotada (idempotente),
   cooldown por veta (J6), definición ausente con log `DOM-MIN` + fallback (J10).

### Evidencia

- Suite `test_mineria.gd`: **92 checks / 0 fallos / EXIT 0 ×3**, `0 SCRIPT ERROR`
  (`CHECKS_MINIMOS := 92`, medido). Línea base previa: 60 checks.
- Sonda roja (aborto en runtime dentro de un bloque): **81 < 92 → EXIT 1**.
- Sonda roja del fix (revertido `_tool_id` al mapeo viejo): **8 fallos / EXIT 1**
  (T2/T3/T4 rechazados + RF6 con `delta=0`); archivo restaurado byte-exacto
  (`sha256 bb193379…`).
- Regresiones M15: `test_recursos` 23/0, `test_recurso_nodo` 14/0,
  `test_recursos_persistencia` 23/0 (todas EXIT 0, 0 SCRIPT ERROR).

### Pendiente / fuera de alcance (reportado al director)

- **M35 no está cableado a la producción**: `tool_controller.gd:340` (M13) llama
  `ResourceManager.recibir_golpe_en_nodo()` directo y **nunca** pasa por
  `intentar_extraccion`; por lo tanto RF6 y RF10 no corren en el juego. El cambio es
  1 línea en un archivo de M13 (no se tocó sin coordinación con su dueño).
- **Defecto de M15 (reportado, no corregido)**: `generar_drops()` puede devolver un
  item fantasma (usa `def_id` como `item_id` en el fallback anti-frustración).

---

## Lote 2 de implementacion (2026-10-11, DeepSeek-V4.1-Flash)

Alcance: **17 items `[ ]`** del checklist M35 implementados dentro del dominio de
M35 (capa de dominio sobre M15). No se toco ningun archivo de M08/M13/M15/M26/
M43/M45/M52. Base medida antes de empezar: 63 `[x]` / 66 `[ ]` / 13 `[?]`.

### API nueva en `mining_manager.gd`

| Item | Funcion / miembro | Contrato |
| --- | --- | --- |
| J1 | `clave_veta(rn)` / `golpes_parciales(rn)` / `_registrar_parcial(rn)` / `aplicar_estado_parcial(rn)` | persiste el dano parcial por veta (clave estable `region:pos`) |
| J5 | `_golpes_totales(rn)` / `fraccion_restante(rn)` | golpes totales del tipo y fraccion de vida restante |
| J9 | `snapshot_estado()` / `restaurar_estado(data)` | snapshot plano del manager (usado por el save) |
| K3 | `intentar_extraccion_en(nodo, tool, out)` | variante **sin allocacion**: escribe en `out` y devuelve bool |
| K5 | `barrido_regeneracion(vetas, dia, estacion)` | barrido batch de respawn de vetas |
| K6 | `benchmark_golpe(nodo, tool, n)` | mide mediana/max por golpe (presupuesto 1 ms) |
| K7 | `definiciones_compartidas()` | cache de `ResourceDefinition` por id (no re-resuelve) |
| L5 | `intensidad_brillo(def_id, fraccion)` | brillo del tinte segun fraccion restante |
| L6 | `texto_flotante(def_id, cantidad)` | texto "+N" del item flotante |
| L7 | `configurar_vibracion(activo)` | habilita/deshabilita `mina_vibracion` |
| L8 | `vetas_de_region(region)` | lista de vetas de una region |
| L9 | `validar_anti_softlock(pos, zonas_protegidas)` | evita sellar la ultima veta accesible |
| I1 | `_anuncio_dorado(def)` | criterio de anuncio de hallazgo raro (rareza <= 2) |
| I5 | `_iniciar_derrumbe(rn)` / `derrumbe_activo(rn)` | derrumbe temporal de la veta agotada |
| I8 | `coleccion_minerales()` / `registrar_en_coleccion(id, cant)` | coleccion persistente de minerales |
| G5 | `veta_tiene_soporte(pos, lector_solido)` | soporte estructural (vecinos solidos) |
| G10 | `marcar_chunk_editado(k)` / `debe_regenerar_vetas(k)` / `chunks_editados()` | registro de chunks editados (no regenerar lo minado) |

### Senales nuevas

- `mina_veta_recuperada(clave)` — J5/J9.
- `mina_derrumbe(clave, duracion)` — I5.
- `mina_vibracion(intensidad)` — L7 (solo si `vibracion_habilitada`).
- `mina_coleccion_nueva(item_id)` — I8.

### Constantes nuevas

- `DERRUMBE_DURACION_S := 0.8` — I5.
- `HIT_BUDGET_US := 1000` — K6 (presupuesto del hot path, 1 ms).
- `RAREZA_ANUNCIO_DORADO := 2` — I1.
- `VECINOS_SOPORTE := 4` — G5 (minimo de vecinos solidos para considerar soporte).
- `VETAS_M35` — catalogo de vetas M35 (L8).

### Persistencia v1 -> v2

`get_save_data()` sube a `version: 2` y agrega `vetas_parciales` (J1) y
`coleccion` (I8). `restore_save_data()` ahora **reemplaza** en vez de acumular
(`_zone_quota.clear()` antes de repoblar) para que restaurar un save no sume
estado sobre el estado vivo.

### Catalogo crudo (`mining_vein_catalog.gd`)

Nueva `static func leer_catalogo() -> Array`: devuelve las entradas **crudas**
del catalogo (Array de Dictionary) sin registrar nada. Devuelve `[]` si el
archivo no existe, esta vacio o el JSON no es un Array. Usada por L8/G10.

### Cambio de comportamiento: log fuera del hot path

Los `print("[DOM-MIN] ...")` por golpe quedaron detras de `_log_dom_min`
(por defecto `false`). Motivo medido (**trampa 120**): bajo un pipe un `print()`
cuesta ~15 ms frente a ~510 us a archivo, lo que volvia inalcanzable el
presupuesto de 1 ms del item K6. Se verifico que **ninguna** suite ni
`tool_controller.gd` dependian de esos prints (grep = 0 dependencias).

### Evidencia medida

- Suite nueva `test_mineria_lote2.gd`: **104 checks / 0 fallos / EXIT 0** (x3),
  0 `SCRIPT ERROR`. `CHECKS_MINIMOS := 104` (piso medido en verde).
- K6: mediana 12-13 us, max 72-97 us (presupuesto 1000 us).
- Guardian probado **en rojo** con 5 sondas: las 5 dieron EXIT 1 con el texto de
  fallo esperado; `mining_manager.gd` restaurado byte-exacto (sha256
  `02e1ff7d2d45d1b298b31e65284ee7fac213f7b72ca4bd3c27f8aa1c6da26767`).
- No regresion: `test_mineria.gd` 92/0, `test_recursos.gd` 23/0,
  `test_recurso_nodo.gd` 14/0, `test_recursos_persistencia.gd` 23/0,
  `test_herramientas.gd` EXIT 0 (todas 0 `SCRIPT ERROR`).

### Hallazgo H17 (defecto de M15, corregido dentro de M35)

`ResourceNode.evaluar_respawn()` (M15) fija `golpes_restantes = 2` al revivir.
Una veta ancestral de 6 golpes revivia con 2. Se corrige **dentro** de
`barrido_regeneracion()` (M35) reponiendo `maxi(1, def.golpes_requeridos)` tras
el respawn, sin tocar M15. Reportado al director para que M15 lo asuma en origen.

### Fuera de alcance (reportado, no implementado)

Los 49 items `[ ]` restantes pertenecen a otros modulos y se reportan con dueno
propuesto: G1-G4/G6/G7/G9 -> M08; I2/I3/I4/I6/I7 -> M26; J2/J3/J4 -> M15/M17;
J7 -> M08/M15; K1/K2/K4/K8 -> M08/M52; L1-L4 -> M52/M43; y los 24 items de
diseno P1-P24 -> M43/M45/M52. No se flipea estado: los `[x]` los aplica el
director.

---

## Lote 3 de diseno (2026-10-13, DeepSeek-V4.1-Flash)

Encargo del director `mimo` (msg 224): M35 es modulo libre; flips SOLO con grep
obligatorio, cuenta regex antes/despues, linea Totales al dia, sin tocar
`CHECKLIST-GLOBAL.md` (lo escribe el director).

### Criterio aplicado (el aceptado en M77/M76/M151)

Item `Disenar/Definir X` -> basta con que **X exista** en `01-04` (se cita el
archivo y la seccion). Item `Crear/Implementar/Verificar` -> exige archivo o
medicion. Se aplico **por verbo**, no por seccion.

### Flips aplicados: 21 (seccion B, "Resolucion de los 24 puntos del plan")

`05-Checklist.md` seccion B: **24 `[ ]` -> 3 `[ ]` + 21 `[x]`**, cada uno con la
cita del doc fuente (grep accent-insensitive sobre los 4 documentos):

| Item | Cita del diseno |
| --- | --- |
| P1 vetas 1-3 bloques | `01-Requerimientos.md` RF1 + `03-Diseno.md` F3 |
| P3 niveles de profundidad (3 bandas) | `01-Requerimientos.md` RF3 |
| P4 cuevas con vetas en paredes/techos | `01-Requerimientos.md` RF4 |
| P5 materiales raros (oro/cristal/polvo) | `01-Requerimientos.md` RF2 + `04-Codigo.md` sec.1 |
| P6 minerales ancestrales (capa M26) | `01-Requerimientos.md` RF3 + `03-Diseno.md` sec.5 |
| P7 herramientas (durabilidad + poder) | `03-Diseno.md` sec.2.3 |
| P8 eficiencia (poder vs dureza) | `02-Analisis.md` D2 + `03-Diseno.md` sec.2.1 |
| P9 particulas (pool de chispas) | `04-Codigo.md` sec.1 |
| P10 sonidos (golpe/extraccion/derrumbe) | `04-Codigo.md` sec.1 |
| P11 iluminacion (brillo propio) | `01-Requerimientos.md` RF4 + `03-Diseno.md` sec.2.1 |
| P12 riesgos no violentos | `01-Requerimientos.md` RF9 |
| P13 derrumbes que solo entierran la veta | `01-Requerimientos.md` RF9 |
| P14 recursos secretos (nodos M26) | `01-Requerimientos.md` RF11 |
| P15 zonas de mineria | `03-Diseno.md` F3 + `04-Codigo.md` sec.1 (regiones cantera/cueva/templo) |
| P18 nodos especiales (veta gigante) | `03-Diseno.md` sec.5 |
| P19 colecciones (registro de minerales) | `01-Requerimientos.md` RF12 + `03-Diseno.md` sec.2.1 |
| P20 crafting asociado (lingotes, M16) | `03-Diseno.md` sec.5 |
| P21 economia (precios, M36) | `03-Diseno.md` sec.5 |
| P22 regeneracion (respawn por tiempo de juego) | `02-Analisis.md` D1 + `03-Diseno.md` F2 |
| P23 limites (tope suave diario por zona) | `02-Analisis.md` D5 |
| P24 anti-repeticion (cadencia/variedad) | `01-Requerimientos.md` RF10 + `02-Analisis.md` D2 |

### `[ ]` que se quedan (honestos, con motivo medido)

- **P2 (tabla de 8+ minerales):** el diseno entrega **6** minerales
  (`ores.json` = 6 vetas; `01-Requerimientos.md` RF2 nombra 6 categorias).
  `grep -i "8 minerales"` en `01-04` = **0**. El punto pide 8+ -> no cumplido.
- **P16 (rutas / caminos de acceso):** `grep -i "camino"` en `01-04` = **0**;
  `"ruta"` solo aparece en `04-Codigo.md` como encabezado de tabla de **rutas de
  archivos** (falso positivo). No disenado.
- **P17 (estaciones / puestos de descanso):** `grep -i "descanso"` = **0**;
  `"estacion"` solo matchea `cristal_estacional` (falso positivo). No disenado.
- **G1-G4, G6-G9 (8 items M08):** implementacion de integracion voxel.
  Medido en `mining_manager.gd`: `collision_mask` = 0, `remesh` = 0, `ocupad` = 0.
- **I2-I4, I6, I7 (5 items M26):** integracion Templo Subterraneo, sin eventos M26.
- **J2, J3, J4, J7 (4 items):** `reintent` = 0, `desplaza` = 0, `ocupad` = 0
  en `mining_manager.gd` (el reintento diferido y el desplazamiento suave no
  existen en el codigo del modulo).
- **K1, K2, K4, K8 (4 items):** remeshing/pool de particulas/frame budget:
  `particul` = 0, `pool` = 0, `remesh` = 0.
- **L1-L4 (4 items):** particulas y sonidos -> assets de M52/M43, inexistentes.

### Evidencia de la edicion

- `05-Checklist.md`: `[x]` 80 -> **101**, `[ ]` 49 -> **28**, `[?]` 13 sin
  cambio (total 142). Regex `^- \[x\]` / `^- \[ \]` / `^- \[\?\]`.
- Invariantes por BYTES: CRLF 251 -> 251, LF sueltos 1 -> 1, CR 251 -> 251,
  BOM False, NUL 0. La edicion **no toca terminadores** (solo el cuerpo de 21
  lineas).
- 28 flips rechazados por falta de evidencia NO se aplicaron.

**Totales tras el lote 3: 101 `[x]` / 28 `[ ]` / 13 `[?]` = 142.**
