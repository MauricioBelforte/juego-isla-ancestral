**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 35: Minería

> Rutas propuestas dentro de `res://_Project/` (estructura adaptada a Godot 4.x según AGENTS.md sección 24). Se ajustarán a la estructura final del proyecto Godot.

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

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Estado:** Diseño completo (delegable)

### Lo que hice
- Relevé los 24 puntos de la sección 34 del plan maestro y las dependencias reales del proyecto (M08, M13, M15, M26).
- Defini 4 componentes (OreDefinition, OreVein, MiningTool, MiningManager) con contratos API concretos.
- Diseñe los flujos completos de extracción, regeneración con validación de ocupacion, distribucion en chunks y persistencia, alineados con el catalogo de M15 (cobre, hierro, oro_ancestral, cristal_estacional, polvo_estrellas).
- Aplique la decision de regeneracion por tiempo de juego con respawn lento y limite suave por zona, sin agotamiento permanente.

### Lo que NO pude hacer (honestidad obligatoria)
- No hay codigo Godot ejecutable: el repositorio esta en fase de diseno/documentacion; las rutas `res://_Project/...` son propuestas y se ajustaran a la estructura final.

### Intentos fallidos / decisiones
- Descartada la edicion de vetas como prefabs flotantes (rompe el voxel M08).
- Descartado el golpe unico (elimina la progresion de picos M13).
- Descartadas las vetas permanentes (contradice el cozy y vacia recursos).

### Recomendaciones para el proximo agente
- Implementar tras M08 (hook de chunk), M13 (pico equipable) y M15 (agregar_recursos).
- Respetar la mascara de colision exclusiva de vetas para cerrar el hot path del raycast.
- Al conectar con M26, sembrar los nodos especiales desde eventos del Templo, no desde la distribucion general.