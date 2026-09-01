**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

# 03-Diseno.md — Módulo 35: Minería

## 1. Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                  MiningManager (Autoload)                   │
│  registro de definiciones · distribución en chunks · regen  │
│  límites por zona · persistencia · señales de eventos       │
└───────┬────────────────────┬───────────────────┬────────────┘
        │ API                │ API               │ API
┌───────▼─────────┐  ┌───────▼────────┐  ┌───────▼────────────┐
│   OreVein       │  │  MiningTool    │  │  M08 Mundo Voxel   │
│ estado de veta  │  │ pico (M13)     │  │ edición de bloques │
│ golpes restantes│  │ raycast·golpe  │  │ remeshing diferido │
│ temporizador    │  │ durabilidad    │  │ iluminación        │
└───────┬─────────┘  └───────┬────────┘  └────────────────────┘
        │ OreDefinition      │ drops
┌───────▼─────────┐          │
│  OreDefinition  │  ┌───────▼─────────┐   ┌──────────────────┐
│ (Resource .tres)│  │  M15 Recursos   │   │ M26 Templo Sub.  │
│ id·dureza·drops │  │ inventario      │   │ capa ancestral   │
└─────────────────┘  └─────────────────┘   └──────────────────┘
```

**Patrones:** Composición (OreVein usa OreDefinition), Service Locator (MiningManager autoload), capa de datos en Resources (`.tres`), señales para eventos de gameplay. La UI consume señales; ninguna clase de UI se referencia desde los managers.

## 2. Componentes

### 2.1 OreDefinition (Resource)

Datos puros de un mineral, instanciable como `.tres` en el catálogo.

| Propiedad | Tipo | Descripción |
|---|---|---|
| `id` | StringName | Identificador único (coincide con M15) |
| `display_name` | String | Nombre en español |
| `rarity` | enum (COMUN/RARO/ANCESTRAL) | Rareza para colecciones |
| `depth_min` / `depth_max` | int | Banda de profundidad en bloques |
| `hardness` | int | Golpes por bloque (2-4) |
| `drop_min` / `drop_max` | int | Cantidad de recurso por bloque |
| `double_drop_chance` | float 0..1 | Probabilidad base de doble drop |
| `respawn_days` | float | Días de juego para regenerar |
| `brightness` | Color | Brillo/emisivo de la veta |
| `particle_scene` | PackedScene | Partículas de extracción |
| `sound_hit` / `sound_break` | AudioStream | Sonidos del mineral |

### 2.2 OreVein (Node3D)

Estado de una veta en el mundo. **No duplica geometría**: la geometría es del voxel M08.

| Propiedad | Tipo | Descripción |
|---|---|---|
| `ore_id` | StringName | Mineral de la veta |
| `blocks` | Array[Vector3i] | Posiciones de los bloques en el voxel |
| `state` | enum (INTACTA / AGOTADA / REGENERANDO) | Estado actual |
| `blocks_remaining` | int | Bloque actual a golpear |
| `golpes_actual` | int | Golpes restantes del bloque actual |
| `regen_remaining` | float | Tiempo de juego restante (días) |

**Señales:** `vein_depleted(vein)` · `vein_recovered(vein)`

### 2.3 MiningTool (Node3D)

Equivalente funcional del pico de M13. Se monta en el pico equipado.

| Propiedad | Tipo | Descripción |
|---|---|---|
| `tool_power` | int | Poder del pico (1-3) |
| `cooldown` | float | Segundos entre golpes (0.6 base) |
| `range` | float | Alcance del raycast (3-4 bloques) |
| `durability_current` / `durability_max` | int | Durabilidad (compartida con M13) |

**Señales:** `swing_started()` · `hit_vein(vein, drops)` · `hit_air()`

### 2.4 MiningManager (Autoload `mineria`)

Orquestador global.

| Señal | Descripción |
|---|---|
| `ore_dropped(ore: OreDefinition, amount: int, world_pos: Vector3)` | Recursos entregados a M15 |
| `vein_recovered_global(vein_id: int)` | Veta regenerada en el mundo |
| `zone_exhausted(zona: StringName)` | Límite diario suave alcanzado |

## 3. Flujos (texto)

### Flujo F1 — Extracción

1. Jugador equipa el pico (M13) y apunta a un bloque de veta.
2. `MiningTool.use()` valida `can_use()` (cooldown, durabilidad).
3. Raycast con máscara exclusiva de vetas; si no hay veta -> `hit_air()`, sin gasto de durabilidad.
4. Si hay veta: `OreVein.hit(tool_power)` descuenta golpes; swing + partículas + sonido.
5. Si `golpes_actual == 0` y `blocks_remaining > 0`: siguiente bloque, sin drops intermedios.
6. Si `blocks_remaining == 0`: `MiningManager.on_vein_depleted(vein)` calcula drops con PRNG M29 y `double_drop_chance + tool_power`.
7. MiningManager entrega los drops a **M15** (`agregar_recursos`), emite `ore_dropped` y la UI muestra texto flotante.
8. La veta pasa a `AGOTADA`; se registra `regen_remaining = respawn_days` y se persiste.

### Flujo F2 — Regeneración (respawn lento)

1. Cada tick de juego (M30), `MiningManager.process_regen(delta)` avanza `regen_remaining` solo si el juego no está en pausa.
2. Cuando `regen_remaining <= 0`: **validación de ocupación** en el voxel M08 para cada bloque de la veta.
3. Si la zona está libre -> bloques restaurados, `state = INTACTA`, chispa de anuncio visual y `vein_recovered_global`.
4. Si la zona está ocupada (construcción M17, otro bloque, jugador dentro) -> se difiere 1 tick y se reintenta (máx. 3 intentos).
5. Si el jugador está en un bloque de la veta -> desplazamiento suave de 0.5 bloques al espacio libre más cercano.
6. Tras 3 reintentos fallidos la veta espera hasta el siguiente día de juego, evitando ciclos de spin.

### Flujo F3 — Distribución en el mundo (M08)

1. M08 genera un chunk y emite el hook de post-generación.
2. `MiningManager.place_veins_in_chunk(origin, rng)` decide con PRNG M29 si el chunk tiene veta y cuántas (densidad por zona: cantera > superficie > zona ancestral M26).
3. Selección de mineral por profundidad (`depth_min`/`depth_max`) y bioma.
4. Se escriben 1-3 bloques en el voxel (capa mineral), con soporte garantizado (nunca flotan).
5. Se crea el `OreVein` registrado en el manager y se persiste su estado.

### Flujo F4 — Persistencia

1. Al guardar: `MiningManager.serialize()` devuelve Dict con definiciones usadas, vetas (estado, golpes, temporizador, posición) y contadores de zona.
2. Al cargar: `deserialize()` reinstancia las vetas, sincroniza bloques con el voxel y reanuda temporizadores con acumulación (sin reset por guardado).

## 4. Contratos API (GDScript)

### OreDefinition

```gdscript
class_name OreDefinition
extends Resource

enum Rarity { COMUN, RARO, ANCESTRAL }

@export var id: StringName
@export var display_name: String
@export var rarity: Rarity = Rarity.COMUN
@export var depth_min: int = 0
@export var depth_max: int = 64
@export var hardness: int = 2
@export var drop_min: int = 1
@export var drop_max: int = 2
@export_range(0.0, 1.0) var double_drop_chance: float = 0.1
@export var respawn_days: float = 2.0
@export var brightness: Color = Color.SILVER
@export var particle_scene: PackedScene
@export var sound_hit: AudioStream
@export var sound_break: AudioStream
```

### OreVein

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

func setup(p_ore: OreDefinition, p_blocks: Array[Vector3i]) -> void
func hit(tool_power: int) -> bool
func is_depleted() -> bool
func can_respawn() -> bool
func apply_occupancy_shift() -> Vector3i   # desplazamiento si el jugador ocupa
func serialize() -> Dictionary
func deserialize(data: Dictionary) -> void
```

### MiningTool

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

func can_use() -> bool
func use() -> Dictionary   # {"acierto": bool, "drops": Array[Dictionary]}
func _raycast_vein() -> OreVein
func consume_durability(amount: int) -> void
```

### MiningManager (Autoload `mineria`)

```gdscript
extends Node

signal ore_dropped(ore: OreDefinition, amount: int, world_pos: Vector3)
signal vein_recovered_global(vein_id: int)
signal zone_exhausted(zona: StringName)

const REGEN_TICK := 0.5

func register_definition(def: OreDefinition) -> void
func get_definition(id: StringName) -> OreDefinition
func place_veins_in_chunk(chunk_origin: Vector3i, rng: RandomNumberGenerator) -> void
func register_vein(vein: OreVein) -> void
func process_regen(delta: float) -> void
func get_zone_density(zona: StringName) -> float
func consume_zone_quota(zona: StringName) -> void
func is_zone_exhausted(zona: StringName) -> bool
func serialize() -> Dictionary
func deserialize(data: Dictionary) -> void
```

## 5. Integración con otros módulos

### M08 (mundo voxel)
- Hook de post-generación de chunk -> `place_veins_in_chunk`.
- Minería edita bloques vía la API de edición de M08 (`set_block`) con capa de mineral; remeshing diferido solo del chunk afectado.
- Validación de ocupación y soporte (bloque debajo) reutilizan la API de lectura de M08.

### M13 (herramientas)
- `MiningTool` es el componente de golpe del pico equipado; `tool_power` se deriva de la mejora del pico (M13).
- Durabilidad compartida: la UI de M13 muestra el mismo valor; el descuento ocurre solo con acierto sobre veta.

### M15 (recursos)
- Los drops son recursos existentes del catálogo M15 (cobre, hierro, oro_ancestral, cristal_estacional, polvo_de_estrellas).
- MiningManager entrega vía `M15.agregar_recursos(...)`; Minería no conoce inventario interno.
- `OreDefinition.id` debe coincidir con el `id` de M15 para no duplicar definiciones.

### M26 (Templo Subterráneo)
- La capa ancestral solo existe en las cuevas de M26; los nodos especiales (veta gigante de cristal) se siembran por eventos de M26.
- El Templo no bloquea puzzles con vetas: ninguna veta interfiere con mecanismos (checklist específico).
- Al completar el Templo, la densa zona ancestral queda accesible permanentemente.

### M29 / M30 / M36 / M73
- PRNG M29 para eventos de drops y distribución; calendario de días para `respawn_days`.
- Reloj M30 congela `process_regen` en pausa (leyendo `M30.is_paused()`).
- Los lingotes/fundición y precios se definen en M16/M36; Minería solo entrega materia prima.
- Festivales M73 pueden duplicar temporalmente la probabilidad de doble drop (evento festivo).

## 6. Estados de la veta (diagrama de texto)

```
        [generación de chunk]
                 |
                 v
           +----------+  blocks_remaining==0   +----------+
           | INTACTA  | ----------------------> | AGOTADA  |
           +----------+                         +----------+
                 ^                                  |
                 |  veín recuperada                 | regen_remaining = respawn_days
                 |  (validación de ocupación)       v
                 +-------------------------- +-------------------+
                                              | REGENERANDO      |
                                              | tick = process_  |
                                              +-------------------+
```

## 7. Decisiones de diseño clave

1. **Geometría en M08, estado en OreVein**: la veta es un bloque especial del voxel; OreVein solo administra estado. Evita duplicación de meshes y colisiones.
2. **Respawn con validación de ocupación** (D1): nunca se regenera sobre construcciones ni sobre el jugador.
3. **Durabilidad sin castigo**: errar un golpe no gasta durabilidad; solo cuenta el acierto.
4. **Límite suave por zona** (D5): no prohíbe, desalienta y empuja a explorar.
5. **Cero acoplamiento con UI**: los managers emiten señales; la capa de presentación las consume.