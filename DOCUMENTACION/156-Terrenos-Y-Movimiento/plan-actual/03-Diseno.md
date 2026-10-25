**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# M156 - Diseno - Terrenos y Movimiento Diferenciado

# 1. Arquitectura del Sistema

# 1.1 Diagrama de Componentes

```
+------------------------------------------+
|              TerrainSystem               |
+------------------------------------------+
|                                          |
|  +----------------+  +----------------+ |
|  | TerrainDetector|  |TerrainData     | |
|  |                |  |Provider        | |
|  | - raycast      |  |                | |
|  | - timer        |  | - terrain_data | |
|  | - last_terrain |  | - get(id)      | |
|  +-------+--------+  +-------+--------+ |
|          |                   |           |
|          v                   v           |
|  +-----------------------------------+  |
|  |        TerrainModifiers           |  |
|  |                                   |  |
|  | + calculate_speed(base,t,bonus) |  |
|  | + get_visual_feedback(t)        |  |
|  | + get_audio_feedback(t)         |  |
|  +-----------------------------------+  |
|                                          |
+------------------------------------------+
           |              |
           v              v
+----------+--+    +------+------+
|   M11       |    |   M155      |
| Personaje   |    | Equipacion  |
+-------------+    +-------------+
```

# 1.2 Script: TerrainDetector.gd

```gdscript
extends Node
class_name TerrainDetector

# Detecta el tipo de terreno bajo los pies del jugador usando raycast vertical

# Configuracion
@export var detection_interval: float = 0.1  # Segundos entre detecciones
@export var ray_length: float = 2.0  # Longitud del raycast

# Referencias
@onready var raycast: RayCast3D = $RayCast3D

# Estado
var current_terrain_id: int = -1
var detection_timer: float = 0.0

# Senales
signal terrain_changed(new_terrain_id: int)

func _ready() -> void:
    raycast.target_position = Vector3(0, -ray_length, 0)
    raycast.enabled = true

func _process(delta: float) -> void:
    detection_timer += delta
    if detection_timer >= detection_interval:
        detection_timer = 0.0
        _detect_terrain()

func _detect_terrain() -> void:
    if raycast.is_colliding():
        var collider = raycast.get_collider()
        if collider and collider.has_method("get_terrain_id"):
            var new_terrain_id = collider.get_terrain_id()
            if new_terrain_id != current_terrain_id:
                current_terrain_id = new_terrain_id
                terrain_changed.emit(current_terrain_id)

func get_current_terrain_id() -> int:
    return current_terrain_id
```

# 1.3 Script: TerrainDataProvider.gd

```gdscript
extends Node
class_name TerrainDataProvider

# Provee datos de terrenos desde ScriptableObjects

@export var terrain_resources: Array[TerrainData] = []

var _terrain_map: Dictionary = {}  # id -> TerrainData

func _ready() -> void:
    _build_map()

func _build_map() -> void:
    for terrain in terrain_resources:
        _terrain_map[terrain.terrain_id] = terrain

func get_terrain_data(terrain_id: int) -> TerrainData:
    return _terrain_map.get(terrain_id, null)

func get_speed_modifier(terrain_id: int) -> float:
    var data = get_terrain_data(terrain_id)
    return data.speed_modifier if data else 1.0

func get_visual_config(terrain_id: int) -> Dictionary:
    var data = get_terrain_data(terrain_id)
    return data.visual_config if data else {}

func get_audio_config(terrain_id: int) -> Dictionary:
    var data = get_terrain_data(terrain_id)
    return data.audio_config if data else {}
```

# 1.4 Script: TerrainModifiers.gd

```gdscript
extends RefCounted
class_name TerrainModifiers

# Calcula modificadores de velocidad finales

# Calcula la velocidad efectiva basada en terreno y equipacion
static func calculate_effective_speed(
    base_speed: float,
    terrain_modifier: float,
    equipment_bonus: float
) -> float:
    return base_speed * terrain_modifier * (1.0 + equipment_bonus)

# Obtiene el modificador de terreno desde el provider
static func get_terrain_modifier(provider: TerrainDataProvider, terrain_id: int) -> float:
    return provider.get_speed_modifier(terrain_id)

# Obtiene la bonificacion de equipacion desde M155
static func get_equipment_bonus(equipment_system, terrain_id: int) -> float:
    if equipment_system and equipment_system.has_method("get_terrain_bonus"):
        return equipment_system.get_terrain_bonus(terrain_id)
    return 0.0

# Calculo completo con todas las fuentes
static func calculate_full(
    base_speed: float,
    provider: TerrainDataProvider,
    terrain_id: int,
    equipment_system
) -> float:
    var terrain_mod = get_terrain_modifier(provider, terrain_id)
    var equip_bonus = get_equipment_bonus(equipment_system, terrain_id)
    return calculate_effective_speed(base_speed, terrain_mod, equip_bonus)
```

# 1.5 Resource: TerrainData.gd

```gdscript
extends Resource
class_name TerrainData

# Datos configurables de un tipo de terreno

@export var terrain_id: int = 0
@export var terrain_name: String = ""
@export var speed_modifier: float = 1.0

# Configuracion visual
@export var visual_config: Dictionary = {
    "footprint_scene": null,  # PackedScene
    "particle_scene": null,   # PackedScene
    "footprint_intensity": 0.5,
    "particle_intensity": 0.5
}

# Configuracion audio
@export var audio_config: Dictionary = {
    "footstep_sounds": [],    # Array de AudioStream
    "volume": 0.5,
    "pitch_variation": 0.05
}

# Colores para debug
@export var debug_color: Color = Color.WHITE
```

# 2. Integracion con M11 (Personaje Jugador)

# 2.1 Modificacion en PlayerMovement.gd

```gdscript
# En PlayerMovement.gd de M11

@export var terrain_detector: TerrainDetector
@export var terrain_provider: TerrainDataProvider
@export var equipment_system  # Referencia a M155

var _current_effective_speed: float = 0.0

func _ready() -> void:
    if terrain_detector:
        terrain_detector.terrain_changed.connect(_on_terrain_changed)
    _update_effective_speed()

func _on_terrain_changed(new_terrain_id: int) -> void:
    _update_effective_speed()

func _update_effective_speed() -> void:
    var terrain_id = terrain_detector.get_current_terrain_id() if terrain_detector else -1
    var terrain_mod = terrain_provider.get_speed_modifier(terrain_id) if terrain_provider else 1.0
    var equip_bonus = 0.0
    if equipment_system and equipment_system.has_method("get_terrain_bonus"):
        equip_bonus = equipment_system.get_terrain_bonus(terrain_id)
    _current_effective_speed = TerrainModifiers.calculate_effective_speed(
        base_speed, terrain_mod, equip_bonus
    )

func get_current_speed() -> float:
    return _current_effective_speed
```

# 2.2 Contrato de Integracion con M11

El sistema M156 no modifica directamente el movimiento de M11. En su lugar:
1. M11 consulta a TerrainDetector para obtener el terreno actual
2. M11 consulta a TerrainDataProvider para obtener el modificador
3. M11 consulta a M155 para la bonificacion de equipacion
4. M11 calcula la velocidad efectiva usando TerrainModifiers
5. M11 aplica la velocidad efectiva a su movimiento

Esto mantiene el desacoplamiento y permite que M11 funcione sin M156 si es necesario.

# 3. Integracion con M155 (Equipacion)

# 3.1 Contrato de Interfaz

M155 debe exponer:
```
func get_terrain_bonus(terrain_id: int) -> float
```

Esta funcion retorna la bonificacion total del equipo actual para el terreno dado:
- 0.0 si no hay bonificacion
- Valor positivo entre 0.05 y 0.35 segun el equipo equipado

# 3.2 Ejemplo de Implementacion en M155

```gdscript
# En EquipmentSystem.gd de M155

func get_terrain_bonus(terrain_id: int) -> float:
    var total_bonus: float = 0.0
    for slot in equipped_slots:
        if slot.item and slot.item.has_method("get_terrain_bonus"):
            total_bonus += slot.item.get_terrain_bonus(terrain_id)
    return min(total_bonus, 0.5)  # Cap al 50% para evitar overpowered
```

# 4. Tabla de Bonificaciones por Terreno

# 4.1 Bonificaciones Base por Equipacion

| Equipacion | Terreno 0 (Ceped) | Terreno 1 (Barro) | Terreno 2 (Pavimento) | Terreno 3 (Arena) | Terreno 4 (Agua) | Terreno 5 (Nieve) | Terreno 6 (Rocas) |
|------------|-------------------|-------------------|----------------------|-------------------|------------------|-------------------|-------------------|
| Botas de barro | 0.0 | +0.35 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 |
| Botas de nieve | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | +0.30 | 0.0 |
| Botas de agua | 0.0 | 0.0 | 0.0 | 0.0 | +0.25 | 0.0 | 0.0 |
| Botas de arena | 0.0 | 0.0 | 0.0 | +0.20 | 0.0 | 0.0 | 0.0 |
| Botas todoterreno | +0.10 | +0.10 | +0.10 | +0.10 | +0.10 | +0.10 | +0.10 |
| Botas urbanas | 0.0 | 0.0 | +0.15 | 0.0 | 0.0 | 0.0 | 0.0 |

# 4.2 Velocidades Efectivas (Base = 5.0 m/s)

| Equipo \ Terreno | Ceped | Barro | Pavimento | Arena | Agua | Nieve | Rocas |
|------------------|-------|-------|-----------|-------|------|-------|-------|
| Sin equipo | 5.0 | 3.0 | 5.0 | 3.75 | 3.5 | 4.0 | 4.25 |
| Botas de barro | 5.0 | 4.05 | 5.0 | 3.75 | 3.5 | 4.0 | 4.25 |
| Botas de nieve | 5.0 | 3.0 | 5.0 | 3.75 | 3.5 | 5.2 | 4.25 |
| Botas todoterreno | 5.5 | 3.3 | 5.5 | 4.125 | 3.85 | 4.4 | 4.675 |

# 5. Feedback Visual

# 5.1 Sistema de Huellas

Cada terreno tiene un PackedScene de huella que se instancia al caminar:
- Ceped: Huella ligera en hierba ( Sprite3D con alpha )
- Barro: Huella profunda con deformacion (MeshInstance3D)
- Pavimento: Marcas claras (Sprite3D)
- Arena: Huella que se rellena gradualmente (AnimationPlayer)
- Agua: Ondas concentricas (ShaderMaterial)
- Nieve: Huella profunda blanca (MeshInstance3D)
- Rocas: Marcas de desgaste (Sprite3D)

# 5.2 Sistema de Particulas

Cada terreno tiene un ParticleProcessMaterial configurado:
- Ceped: Particulas verdes, baja intensidad
- Barro: Salpicaduras marrones, media intensidad
- Pavimento: Minimo, destellos ocasionales
- Arena: Nube de arena, alta intensidad
- Agua: Salpicaduras azules, media-alta intensidad
- Nieve: Copos y polvo blanco, media intensidad
- Rocas: Polvo gris y chispas, baja-media intensidad

# 5.3 Trigger de Efectos

Los efectos se activan:
1. Solo cuando el jugador se esta moviendo (velocity.length() > threshold)
2. Con la frecuencia configurada por terreno (no cada paso)
3. Con la intensidad configurada por terreno
4. Se desactivan al detenerse

# 6. Feedback Audio

# 6.1 Sistema de Pasos

Cada terreno tiene un array de AudioStream para pasos:
- Se reproduce uno aleatorio en cada paso
- Con variacion de pitch configurable por terreno
- Con volumen configurable por terreno
- Se silencian si el jugador esta detenido

# 6.2 Timing de Pasos

El sistema de audio sincroniza con la animacion de caminata:
- Evento de animacion triggers paso de audio
- No reproducir dos pasos seguidos demasiado rapido
- Fade in/out al cambiar de terreno

# 7. Indicador de UI

# 7.1 Elementos de UI

- Icono de terreno actual (TextureRect)
- Texto con nombre del terreno (Label)
- Barra de velocidad efectiva (ProgressBar)
- Tooltip con detalies al hacer hover

# 7.2 Actualizacion de UI

- Se actualiza cuando cambia el terreno (terrain_changed signal)
- No actualiza cada frame para ahorrar rendimiento

# 8. Script: TerrainFootstepAudio.gd

```gdscript
extends Node3D
class_name TerrainFootstepAudio

# Reproduce sonidos de pasos segun el terreno actual

@export var audio_player: AudioStreamPlayer3D
@export var terrain_provider: TerrainDataProvider
@export var detection_interval: float = 0.1

var _last_terrain_id: int = -1
var _timer: float = 0.0

func _ready() -> void:
    if audio_player:
        audio_player.bus = "SFX"

func play_footstep(terrain_id: int) -> void:
    if terrain_id == _last_terrain_id and _timer < detection_interval:
        return

    _last_terrain_id = terrain_id
    _timer = 0.0

    if not terrain_provider or not audio_player:
        return

    var config = terrain_provider.get_audio_config(terrain_id)
    if config.is_empty():
        return

    var sounds: Array = config.get("footstep_sounds", [])
    if sounds.is_empty():
        return

    var sound = sounds[randi() % sounds.size()]
    audio_player.stream = sound
    audio_player.volume_db = linear_to_db(config.get("volume", 0.5))
    audio_player.pitch_scale = 1.0 + randf_range(
        -config.get("pitch_variation", 0.05),
        config.get("pitch_variation", 0.05)
    )
    audio_player.play()
```

# 9. Diagrama de Secuencia

```
Jugador (M11)     TerrainDetector   TerrainDataProvider   M155
     |                  |                  |                |
     |--- mover() ----->|                  |                |
     |                  |--- raycast ----->|                |
     |                  |<-- terrain_id ---|                |
     |                  |--- changed? ---->|                |
     |<-- speed_update -|                  |                |
     |                  |                  |                |
     |--- get_bonus() ------------------------------>------|
     |<-- bonus_value -------------------------------------|
     |                  |                  |                |
     |--- calculate_effective_speed() -->|                |
     |<-- effective_speed                 |                |
     |                  |                  |                |
     |--- apply_movement()               |                |
     |                  |                  |                |
     |--- play_effects() ---------------->|                |
     |<-- visual/audio config             |                |
```

# 10. Consideraciones de Implementacion

# 10.1 Orden de Ejecucion
1. TerrainDetector actualiza terrain_id
2. Senal terrain_changed emite
3. M11 recibe senal y consulta datos
4. M11 calcula velocidad efectiva
5. M11 aplica movimiento
6. M11 activa efectos visuales/audio

# 10.2 Manejo de Edge Cases
- Jugador en aire: mantener ultimo terreno detectado
- Cambio rapido de terreno: usar debounce para evitar flickering
- Terreno no encontrado: usar modificador 1.0 (default)
- Sin equipacion: usar bonus 0.0 (sin cambio)

# 10.3 Testing
- Unit tests para TerrainModifiers.calculate_effective_speed()
- Unit tests para TerrainDataProvider.get_terrain_data()
- Integration tests para flujo completo M11 + M156 + M155

# Protocolos de medicion (S56b â€” G-5.3-Flash-Agente, 2026-10-23: definicion en papel; la EJECUCION queda para quien tenga el proyecto abierto en editor â€”Godot visual V2/V4â€” o el permiso de GO de integracion)

**P1 â€” audio no causa lag (L327):** QUE: frame-time con el mezclador activo
y N sfx simultaneos. HERRAMIENTA: profiler interno de Godot (pestanÃ±a
Audio) + frame-time monitor. ESCENA: plaza del prototipo con 10 sfx
simultaneos (pasos + ambiente + viento + ui). UMBRAL: 0 frames > 100 ms
atribuibles al bus audio; pico de CPU del mezclador < 2% por frame.

**P2 â€” sonidos diferentes por terreno (L375):** QUE: cada material de
terreno dispara su sfx propio. HERRAMIENTA: tabla de mapping
material->sfx (fuente: dataset M42/M43) + auditoria de la senal de paso
del jugador. ESCENA: 6 materiales (pasto, arena, piedra, madera, metal,
agua somera) x 5 pasos cada uno. UMBRAL: 6/6 materiales con sfx distinto y
0 por defecto-genÃ©rico.

**P3 â€” huellas diferentes por terreno (L376):** QUE: cada material deja
su decal/huella. HERRAMIENTA: inspector de decals en escena + captura por
terreno. ESCENA: misma del P2. UMBRAL: 6/6 materiales con huella visible
diferenciada y 0 fuga de decals (purge al cambiar chunk).

**P4 â€” particulas diferentes por terreno (L377):** QUE: cada material
produce su particula (polvo/salpicadura/hoja). HERRAMIENTA: contador de
particulas del profiler + pool M52. ESCENA: misma del P2. UMBRAL: 6/6 con
particles propio del material y 0 asignaciones cruzadas.

**P5 â€” indicador de UI actualiza (L378):** QUE: el HUD refleja el estado
(herramienta, recurso, estamina) al instante. HERRAMIENTA: captura en
video + comparacion frame al frame con el estado logico (la senal del
estado debe preceder al cambio de UI en <= 2 frames). ESCENA: cambio de
herramienta x 10 + pickup x 10. UMBRAL: 100% de cambios de estado
reflejados en <= 2 frames.

**P6 â€” jugador nunca se bloquea (L379):** QUE: el jugador no queda atascado
en la geometria. COMO/HERRAMIENTA: script de recorrido autonomico (nav
agent) cruzando las 12 estructuras del prototipo + registro de posiciones
congeladas (> 5 s sin desplazamiento). ESCENA: plaza + 12 estructuras +
laderas. UMBRAL: 0 congela mientos > 5 s; 1 recuperacion automatica si
ocurre (nudge).

**P7 â€” FPS estable a 60 (L380):** QUE: framerate medio >= 60 en gameplay
estandar. HERRAMIENTA: REPORTE-FPS.md (bench_slice.gd, TC13 de M138) con
captura del 1% low. ESCENA: plaza del prototipo con fauna del mundo +
vegetacion M50. UMBRAL: >= 60 fps promedio, 1% low >= 45 fps, 0 picos
> 250 ms.

**P8 â€” sin errores en consola (L381):** QUE: la consola del editor no
emite errores/fatals en sesion canonica. HERRAMIENTA: get_debug_output
(godot-mcp) con filtro por severidad ERROR/FATAL. ESCENA: recorridoe de
la Tanda canÃ³nica de 15 min (boot -> plaza -> prado -> construccion ->
guardado). UMBRAL: 0 ERROR/FATAL de sesiÃ³n (los warnings W permitidos
documentados).

**P9 â€” coherencia visual total (L393):** QUE: el material del terreno/props
cumple la paleta y estilo del canon. COMO/HERRAMIENTA: style-guide check
visual del dueÃ±o de arte (V1/V2) con la lista de materiales canon M50. ESCENA:
los 6 materiales del prototipo en la misma escena de referencia. UMBRAL: 100% de
materiales dentro del canon (aprobacion del dueÃ±o de arte, no del agente).

**P10 â€” coherencia audio total (L394):** QUE: el mix de ambiente/SFX/USO del
jugador cumple el map de audio por zona. COMO/HERRAMIENTA: mezclador de
Godot (buses Ambiente/SFX/USO) + tabla de volumen por zona del M42.
ESCENA: las 6 zonas del prototipo en las 2 franjas (dia/noche). UMBRAL:
100% de zonas con staff ambiente propio y 0 SFX fuera de su zona canon.

# Protocolos de medicion (S56b â€” G-5.3-Flash-Agente, 2026-10-23: definicion en papel; la EJECUCION queda para quien tenga el proyecto abierto en editor â€”Godot visual V2/V4â€” o el permiso de GO de integracion)

**P1 â€” audio no causa lag (L327):** QUE: frame-time con el mezclador activo
y N sfx simultaneos. HERRAMIENTA: profiler interno de Godot (pestanÃ±a
Audio) + frame-time monitor. ESCENA: plaza del prototipo con 10 sfx
simultaneos (pasos + ambiente + viento + ui). UMBRAL: 0 frames > 100 ms
atribuibles al bus audio; pico de CPU del mezclador < 2% por frame.

**P2 â€” sonidos diferentes por terreno (L375):** QUE: cada material de
terreno dispara su sfx propio. HERRAMIENTA: tabla de mapping
material->sfx (fuente: dataset M42/M43) + auditoria de la senal de paso
del jugador. ESCENA: 6 materiales (pasto, arena, piedra, madera, metal,
agua somera) x 5 pasos cada uno. UMBRAL: 6/6 materiales con sfx distinto y
0 por defecto-genÃ©rico.

**P3 â€” huellas diferentes por terreno (L376):** QUE: cada material deja
su decal/huella. HERRAMIENTA: inspector de decals en escena + captura por
terreno. ESCENA: misma del P2. UMBRAL: 6/6 materiales con huella visible
diferenciada y 0 fuga de decals (purge al cambiar chunk).

**P4 â€” particulas diferentes por terreno (L377):** QUE: cada material
produce su particula (polvo/salpicadura/hoja). HERRAMIENTA: contador de
particulas del profiler + pool M52. ESCENA: misma del P2. UMBRAL: 6/6 con
particles propio del material y 0 asignaciones cruzadas.

**P5 â€” indicador de UI actualiza (L378):** QUE: el HUD refleja el estado
(herramienta, recurso, estamina) al instante. HERRAMIENTA: captura en
video + comparacion frame al frame con el estado logico (la senal del
estado debe preceder al cambio de UI en <= 2 frames). ESCENA: cambio de
herramienta x 10 + pickup x 10. UMBRAL: 100% de cambios de estado
reflejados en <= 2 frames.

**P6 â€” jugador nunca se bloquea (L379):** QUE: el jugador no queda atascado
en la geometria. COMO/HERRAMIENTA: script de recorrido autonomico (nav
agent) cruzando las 12 estructuras del prototipo + registro de posiciones
congeladas (> 5 s sin desplazamiento). ESCENA: plaza + 12 estructuras +
laderas. UMBRAL: 0 congela mientos > 5 s; 1 recuperacion automatica si
ocurre (nudge).

**P7 â€” FPS estable a 60 (L380):** QUE: framerate medio >= 60 en gameplay
estandar. HERRAMIENTA: REPORTE-FPS.md (bench_slice.gd, TC13 de M138) con
captura del 1% low. ESCENA: plaza del prototipo con fauna del mundo +
vegetacion M50. UMBRAL: >= 60 fps promedio, 1% low >= 45 fps, 0 picos
> 250 ms.

**P8 â€” sin errores en consola (L381):** QUE: la consola del editor no
emite errores/fatals en sesion canonica. HERRAMIENTA: get_debug_output
(godot-mcp) con filtro por severidad ERROR/FATAL. ESCENA: recorridoe de
la Tanda canÃ³nica de 15 min (boot -> plaza -> prado -> construccion ->
guardado). UMBRAL: 0 ERROR/FATAL de sesiÃ³n (los warnings W permitidos
documentados).

**P9 â€” coherencia visual total (L393):** QUE: el material del terreno/props
cumple la paleta y estilo del canon. COMO/HERRAMIENTA: style-guide check
visual del dueÃ±o de arte (V1/V2) con la lista de materiales canon M50. ESCENA:
los 6 materiales del prototipo en la misma escena de referencia. UMBRAL: 100% de
materiales dentro del canon (aprobacion del dueÃ±o de arte, no del agente).

**P10 â€” coherencia audio total (L394):** QUE: el mix de ambiente/SFX/USO del
jugador cumple el map de audio por zona. COMO/HERRAMIENTA: mezclador de
Godot (buses Ambiente/SFX/USO) + tabla de volumen por zona del M42.
ESCENA: las 6 zonas del prototipo en las 2 franjas (dia/noche). UMBRAL:
100% de zonas con staff ambiente propio y 0 SFX fuera de su zona canon.

# Presupuestos de terreno (Beam 346, produce-first)
### ProgressBar para velocidad efectiva
- Spec: ProgressBar que muestra la velocidad efectiva del jugador sobre el terreno (0-100%).
- Cap: TerrainModifiers static cap 50% (testeado Â§4.2) â€” cap clampf 0-0.5.
- Coherente con M11 (movimiento) y M61 (rendimiento).

### Nota de coherencia (Beam 410)
os clasACES de item (M156 catalogo) usan el mismo budget generator (ref Beam 381/383). 1 edge de coherencia entre mis propios presupuestos.

# Notas de coherencia (Beam 418, produce-first)
### Coherencia de generacion procedural
- world_generator.gd usa world_seed=42 (semilla fija) + IslandGenerator. No menciona chunks explicitamente.
- Coherente con M10 (generacion) y M27 (islas). La generacion procedural es determinista (semilla fija).

### Budget de NPCs por isla
- Nota: el budget de NPCs por isla se gestiona en M27 (islas) + M64 (IA de NPC). M156 no tiene un budget propio de NPCs.
- Coherente con M27 (islas) y M64 (IA de NPC).
# Spec TerrainBlock (Beam 478)
### Crear terrain_block.gd
- Spec: script 	errain_block.gd (extends StaticBody3D) que encapsula un bloque de terreno: terrain_id, collider, y carga de datos desde data/terrenos/terrenos.json. Coherente con M156 (terrenos) y M08 (voxel).

### Requerir CollisionShape3D hijo
- Spec: cada TerrainBlock requiere un CollisionShape3D hijo con BoxShape3D para colisión. Validación en _ready().

### Crear escena base terrain_block.tscn
- Spec: escena base 	errain_block.tscn con TerrainBlock root + CollisionShape3D hijo. Instanciable por el generador de terreno.

### Configurar CollisionShape3D con BoxShape3D
- Spec: el CollisionShape3D usa BoxShape3D con tamaño derivado del bloque (1x1x1 voxel). Coherente con M08 (voxel).

### Asignar terrain_id correcto
- Spec: terrain_id se asigna desde data/terrenos/terrenos.json vía _load_from_data(). El id identifica el tipo de terreno para efectos (pasos, VFX).

### play_footstep(terrain_id)
- Spec: play_footstep(terrain_id) reproduce un sonido de paso según el terreno (M42). Aplica variación de pitch y volumen configurables. Coherente con M42 (sonido) y M156 (terrenos).

### Volumen configurable
- Spec: volumen del footstep configurable por terreno (volumen_db). Coherente con M42 (sonido).
# Spec feedback de terreno (Beam 479)
### Fade al cambiar terreno
- Spec: al cambiar de terreno, se aplica un fade de audio/visual suave (crossfade) para evitar cortes bruscos. Coherente con M42 (sonido) y M156 (terrenos).

### Collision layer por terrain_block
- Spec: cada terrain_block asigna collision_layer según su tipo (7 tipos → 7 layers). Definido en _layer_for_type(). Coherente con M08 (voxel) y M156 (terrenos).

### ProgressBar de velocidad efectiva
- Spec: UI (M53) muestra un ProgressBar con la velocidad efectiva (cap 50% por TerrainModifiers). Coherente con M53 (UI) y M156 (terrenos).
# Spec TerrainFootstepAudio (Beam 480)
### Agregar TerrainFootstepAudio al jugador
- Spec: 	errain_footstep_audio.gd (extends Node) se agrega como hijo del jugador (M11). Consume 	errain_changed del TerrainDetector y reproduce el footstep correspondiente vía play_footstep(terrain_id). Coherente con M11 (movimiento) y M156 (terrenos).