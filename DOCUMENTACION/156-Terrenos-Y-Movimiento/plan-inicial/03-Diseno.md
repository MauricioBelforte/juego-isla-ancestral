**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# M156 - Diseno - Terrenos y Movimiento Diferenciado

## 1. Arquitectura del Sistema

### 1.1 Diagrama de Componentes

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

### 1.2 Script: TerrainDetector.gd

```gdscript
extends Node
class_name TerrainDetector

## Detecta el tipo de terreno bajo los pies del jugador usando raycast vertical

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

### 1.3 Script: TerrainDataProvider.gd

```gdscript
extends Node
class_name TerrainDataProvider

## Provee datos de terrenos desde ScriptableObjects

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

### 1.4 Script: TerrainModifiers.gd

```gdscript
extends RefCounted
class_name TerrainModifiers

## Calcula modificadores de velocidad finales

## Calcula la velocidad efectiva basada en terreno y equipacion
static func calculate_effective_speed(
    base_speed: float,
    terrain_modifier: float,
    equipment_bonus: float
) -> float:
    return base_speed * terrain_modifier * (1.0 + equipment_bonus)

## Obtiene el modificador de terreno desde el provider
static func get_terrain_modifier(provider: TerrainDataProvider, terrain_id: int) -> float:
    return provider.get_speed_modifier(terrain_id)

## Obtiene la bonificacion de equipacion desde M155
static func get_equipment_bonus(equipment_system, terrain_id: int) -> float:
    if equipment_system and equipment_system.has_method("get_terrain_bonus"):
        return equipment_system.get_terrain_bonus(terrain_id)
    return 0.0

## Calculo completo con todas las fuentes
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

### 1.5 Resource: TerrainData.gd

```gdscript
extends Resource
class_name TerrainData

## Datos configurables de un tipo de terreno

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

## 2. Integracion con M11 (Personaje Jugador)

### 2.1 Modificacion en PlayerMovement.gd

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

### 2.2 Contrato de Integracion con M11

El sistema M156 no modifica directamente el movimiento de M11. En su lugar:
1. M11 consulta a TerrainDetector para obtener el terreno actual
2. M11 consulta a TerrainDataProvider para obtener el modificador
3. M11 consulta a M155 para la bonificacion de equipacion
4. M11 calcula la velocidad efectiva usando TerrainModifiers
5. M11 aplica la velocidad efectiva a su movimiento

Esto mantiene el desacoplamiento y permite que M11 funcione sin M156 si es necesario.

## 3. Integracion con M155 (Equipacion)

### 3.1 Contrato de Interfaz

M155 debe exponer:
```
func get_terrain_bonus(terrain_id: int) -> float
```

Esta funcion retorna la bonificacion total del equipo actual para el terreno dado:
- 0.0 si no hay bonificacion
- Valor positivo entre 0.05 y 0.35 segun el equipo equipado

### 3.2 Ejemplo de Implementacion en M155

```gdscript
# En EquipmentSystem.gd de M155

func get_terrain_bonus(terrain_id: int) -> float:
    var total_bonus: float = 0.0
    for slot in equipped_slots:
        if slot.item and slot.item.has_method("get_terrain_bonus"):
            total_bonus += slot.item.get_terrain_bonus(terrain_id)
    return min(total_bonus, 0.5)  # Cap al 50% para evitar overpowered
```

## 4. Tabla de Bonificaciones por Terreno

### 4.1 Bonificaciones Base por Equipacion

| Equipacion | Terreno 0 (Ceped) | Terreno 1 (Barro) | Terreno 2 (Pavimento) | Terreno 3 (Arena) | Terreno 4 (Agua) | Terreno 5 (Nieve) | Terreno 6 (Rocas) |
|------------|-------------------|-------------------|----------------------|-------------------|------------------|-------------------|-------------------|
| Botas de barro | 0.0 | +0.35 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 |
| Botas de nieve | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | +0.30 | 0.0 |
| Botas de agua | 0.0 | 0.0 | 0.0 | 0.0 | +0.25 | 0.0 | 0.0 |
| Botas de arena | 0.0 | 0.0 | 0.0 | +0.20 | 0.0 | 0.0 | 0.0 |
| Botas todoterreno | +0.10 | +0.10 | +0.10 | +0.10 | +0.10 | +0.10 | +0.10 |
| Botas urbanas | 0.0 | 0.0 | +0.15 | 0.0 | 0.0 | 0.0 | 0.0 |

### 4.2 Velocidades Efectivas (Base = 5.0 m/s)

| Equipo \ Terreno | Ceped | Barro | Pavimento | Arena | Agua | Nieve | Rocas |
|------------------|-------|-------|-----------|-------|------|-------|-------|
| Sin equipo | 5.0 | 3.0 | 5.0 | 3.75 | 3.5 | 4.0 | 4.25 |
| Botas de barro | 5.0 | 4.05 | 5.0 | 3.75 | 3.5 | 4.0 | 4.25 |
| Botas de nieve | 5.0 | 3.0 | 5.0 | 3.75 | 3.5 | 5.2 | 4.25 |
| Botas todoterreno | 5.5 | 3.3 | 5.5 | 4.125 | 3.85 | 4.4 | 4.675 |

## 5. Feedback Visual

### 5.1 Sistema de Huellas

Cada terreno tiene un PackedScene de huella que se instancia al caminar:
- Ceped: Huella ligera en hierba ( Sprite3D con alpha )
- Barro: Huella profunda con deformacion (MeshInstance3D)
- Pavimento: Marcas claras (Sprite3D)
- Arena: Huella que se rellena gradualmente (AnimationPlayer)
- Agua: Ondas concentricas (ShaderMaterial)
- Nieve: Huella profunda blanca (MeshInstance3D)
- Rocas: Marcas de desgaste (Sprite3D)

### 5.2 Sistema de Particulas

Cada terreno tiene un ParticleProcessMaterial configurado:
- Ceped: Particulas verdes, baja intensidad
- Barro: Salpicaduras marrones, media intensidad
- Pavimento: Minimo, destellos ocasionales
- Arena: Nube de arena, alta intensidad
- Agua: Salpicaduras azules, media-alta intensidad
- Nieve: Copos y polvo blanco, media intensidad
- Rocas: Polvo gris y chispas, baja-media intensidad

### 5.3 Trigger de Efectos

Los efectos se activan:
1. Solo cuando el jugador se esta moviendo (velocity.length() > threshold)
2. Con la frecuencia configurada por terreno (no cada paso)
3. Con la intensidad configurada por terreno
4. Se desactivan al detenerse

## 6. Feedback Audio

### 6.1 Sistema de Pasos

Cada terreno tiene un array de AudioStream para pasos:
- Se reproduce uno aleatorio en cada paso
- Con variacion de pitch configurable por terreno
- Con volumen configurable por terreno
- Se silencian si el jugador esta detenido

### 6.2 Timing de Pasos

El sistema de audio sincroniza con la animacion de caminata:
- Evento de animacion triggers paso de audio
- No reproducir dos pasos seguidos demasiado rapido
- Fade in/out al cambiar de terreno

## 7. Indicador de UI

### 7.1 Elementos de UI

- Icono de terreno actual (TextureRect)
- Texto con nombre del terreno (Label)
- Barra de velocidad efectiva (ProgressBar)
- Tooltip con detalies al hacer hover

### 7.2 Actualizacion de UI

- Se actualiza cuando cambia el terreno (terrain_changed signal)
- No actualiza cada frame para ahorrar rendimiento

## 8. Script: TerrainFootstepAudio.gd

```gdscript
extends Node3D
class_name TerrainFootstepAudio

## Reproduce sonidos de pasos segun el terreno actual

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

## 9. Diagrama de Secuencia

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

## 10. Consideraciones de Implementacion

### 10.1 Orden de Ejecucion
1. TerrainDetector actualiza terrain_id
2. Senal terrain_changed emite
3. M11 recibe senal y consulta datos
4. M11 calcula velocidad efectiva
5. M11 aplica movimiento
6. M11 activa efectos visuales/audio

### 10.2 Manejo de Edge Cases
- Jugador en aire: mantener ultimo terreno detectado
- Cambio rapido de terreno: usar debounce para evitar flickering
- Terreno no encontrado: usar modificador 1.0 (default)
- Sin equipacion: usar bonus 0.0 (sin cambio)

### 10.3 Testing
- Unit tests para TerrainModifiers.calculate_effective_speed()
- Unit tests para TerrainDataProvider.get_terrain_data()
- Integration tests para flujo completo M11 + M156 + M155
