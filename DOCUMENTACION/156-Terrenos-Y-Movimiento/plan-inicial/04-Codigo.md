**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# M156 - Codigo - Terrenos y Movimiento Diferenciado

## 1. Archivos Involucrados

### 1.1 Archivos Nuevos (M156)

| Archivo | Tipo | Descripcion |
|---------|------|-------------|
| scripts/terrain/terrain_detector.gd | Node | Deteccion de terreno via raycast |
| scripts/terrain/terrain_data_provider.gd | Node | Proveedor de datos de terrenos |
| scripts/terrain/terrain_modifiers.gd | RefCounted | Calculo de modificadores |
| scripts/terrain/terrain_data.gd | Resource | Datos de terreno (ScriptableObject) |
| scripts/terrain/terrain_footstep_audio.gd | Node3D | Sistema de audio de pasos |
| resources/terrain/ | Directorio | TerrainData resources (7 archivos .tres) |
| scenes/terrain/ | Directorio | Escenas de huellas y particulas |

### 1.2 Archivos Modificados (M11)

| Archivo | Cambio |
|---------|--------|
| scripts/player/player_movement.gd | Agregar referencia a TerrainDetector y TerrainDataProvider |
| scripts/player/player_movement.gd | Modificar _process() para usar velocidad efectiva |

### 1.3 Archivos Modificados (M155)

| Archivo | Cambio |
|---------|--------|
| scripts/equipment/equipment_system.gd | Agregar metodo get_terrain_bonus(terrain_id) |

### 1.4 Archivos Dependientes (no modificados)

| Archivo | Relacion |
|---------|----------|
| scripts/core/game_manager.gd | Instanciar TerrainSystem |
| scenes/player/player.tscn | Agregar nodos TerrainDetector y TerrainDataProvider |
| resources/terrain/*.tres | TerrainData resources |

## 2. Contratos de Integracion

### 2.1 TerrainDetector -> M11

```
SEÑAL terrain_changed(new_terrain_id: int)

METODO get_current_terrain_id() -> int
```

M11 debe:
1. Conectar a terrain_changed en _ready()
2. Llamar get_current_terrain_id() cuando necesite el terreno actual

### 2.2 TerrainDataProvider -> M11

```
METODO get_speed_modifier(terrain_id: int) -> float
METODO get_visual_config(terrain_id: int) -> Dictionary
METODO get_audio_config(terrain_id: int) -> Dictionary
```

M11 debe:
1. Tener referencia al TerrainDataProvider
2. Llamar get_speed_modifier() al calcular velocidad
3. Llamar get_visual_config() y get_audio_config() para efectos

### 2.3 M155 -> M156

```
METODO get_terrain_bonus(terrain_id: int) -> float
```

M155 debe:
1. Implementar get_terrain_bonus()
2. Retornar la bonificacion total del equipo actual para el terreno dado
3. Retornar 0.0 si no hay bonificacion

### 2.4 TerrainModifiers (Utilidad Estatica)

```
METODO ESTATICO calculate_effective_speed(
    base_speed: float,
    terrain_modifier: float,
    equipment_bonus: float
) -> float
```

No tiene dependencias. Es puro calculo matematico.

## 3. Flujo de Ejecucion

### 3.1 Flujo Principal (por frame)

```
1. TerrainDetector._process(delta)
   ├── detection_timer += delta
   ├── if timer >= interval:
   │   └── _detect_terrain()
   │       ├── raycast.is_colliding()
   │       ├── collider.get_terrain_id()
   │       └── emit terrain_changed(terrain_id)
   
2. M11._on_terrain_changed(terrain_id)
   ├── _update_effective_speed()
   │   ├── terrain_detector.get_current_terrain_id()
   │   ├── terrain_provider.get_speed_modifier(terrain_id)
   │   ├── equipment_system.get_terrain_bonus(terrain_id)
   │   └── _current_effective_speed = calculate(...)
   └── _update_visual_effects()
       └── terrain_provider.get_visual_config(terrain_id)

3. M11._process(delta)
   └── velocity = direction * _current_effective_speed
       └── move_and_slide()
```

### 3.2 Flujo de Audio

```
1. M11._on_footstep_event()  [trigger de animacion]
   └── terrain_footstep_audio.play_footstep(terrain_id)
       ├── terrain_provider.get_audio_config(terrain_id)
       ├── Seleccionar sonido aleatorio
       └── audio_player.play()
```

### 3.3 Flujo de Efectos Visuales

```
1. M11._on_moving()
   ├── if velocity.length() > threshold:
   │   └── spawn_visual_effect(terrain_id)
   │       ├── terrain_provider.get_visual_config(terrain_id)
   │       ├── Instanciar huella/particula
   │       └── Configurar segun terreno
   └── else:
       └── Detener efectos
```

## 4. Configuracion de Layers

### 4.1 Layers de Terreno

| Layer | Nombre | Uso |
|-------|--------|-----|
| 1 | Default | Configuracion por defecto |
| 2 | Terrain_Grass | Ceped |
| 3 | Terrain_Mud | Barro |
| 4 | Terrain_Pavement | Pavimento |
| 5 | Terrain_Sand | Arena |
| 6 | Terrain_Water | Agua poco profunda |
| 7 | Terrain_Snow | Nieve |
| 8 | Terrain_Rock | Rocas |

### 4.2 Configuracion del Raycast

```
RayCast3D:
  target_position: (0, -2, 0)  # 2 metros hacia abajo
  collision_mask: 0b11111110  # Todas las layers de terreno (2-8)
  enabled: true
```

### 4.3 Cada Terreno debe tener:

```
Node3D (ej: "MudBlock"):
  StaticBody3D:
    CollisionShape3D (Shape Box o Mesh)
    collision_layer: 4  # Terrain_Mud (bit 3)
  script: terrain_block.gd  # Implementa get_terrain_id()
```

## 5. Script Base: terrain_block.gd

```gdscript
extends StaticBody3D
class_name TerrainBlock

## Script base para bloques de terreno
## Cada bloque debe tener este script o uno que herede de el

@export var terrain_id: int = 0

func get_terrain_id() -> int:
    return terrain_id
```

## 6. TerrainData Resources

### 6.1 Estructura de Archivos

```
resources/terrain/
├── terrain_ceped.tres
├── terrain_barro.tres
├── terrain_pavimento.tres
├── terrain_arena.tres
├── terrain_agua.tres
├── terrain_nieve.tres
└── terrain_rocas.tres
```

### 6.2 Ejemplo: terrain_ceped.tres

```
[gd_resource type="Resource" script_class="TerrainData"]

[resource]
script = ExtResource("1_terrain_data")
terrain_id = 0
terrain_name = "Ceped"
speed_modifier = 1.0
visual_config = {
"footprint_scene": ExtResource("2_ceped_footprint"),
"particle_scene": ExtResource("3_ceped_particles"),
"footprint_intensity": 0.3,
"particle_intensity": 0.4
}
audio_config = {
"footstep_sounds": [ExtResource("4_step_grass_1"), ExtResource("5_step_grass_2")],
"volume": 0.4,
"pitch_variation": 0.05
}
debug_color = Color(0.2, 0.8, 0.2, 1)
```

## 7. Items Pendientes de Implementacion

### 7.1 Codigo Pendiente

- [ ] Crear terrain_detector.gd completo con manejo de edge cases
- [ ] Crear terrain_data_provider.gd con validacion
- [ ] Crear terrain_modifiers.gd con tests unitarios
- [ ] Crear terrain_data.gd como Resource
- [ ] Crear terrain_footstep_audio.gd con sincronizacion
- [ ] Crear terrain_block.gd como script base
- [ ] Modificar player_movement.gd de M11
- [ ] Agregar get_terrain_bonus() a M155

### 7.2 Assets Pendientes

- [ ] Crear 7 TerrainData resources (.tres)
- [ ] Crear escenas de huellas (7 tipos)
- [ ] Crear sistemas de particulas (7 tipos)
- [ ] Crear samples de audio de pasos (7 tipos, 2-3 variaciones cada uno)
- [ ] Crear iconos de UI para terrenos

### 7.3 Configuracion Pendiente

- [ ] Configurar Layers de terreno en Godot
- [ ] Configurar CollisionShape3D en todos los bloques de terreno
- [ ] Asignar terrain_id a cada bloque de terreno
- [ ] Configurar RayCast3D en el jugador
- [ ] Conectar senales en escena del jugador

## 8. Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

### Lo que se documento
- Arquitectura completa del sistema
- Contratos de integracion entre modulos
- Flujo de ejecucion paso a paso
- Configuracion de Layers necesaria
- TerrainData resources a crear
- Items pendientes de implementacion

### Limitaciones conocidas
- El sistema depende de que cada terreno tenga el script terrain_block.gd
- El RayCast3D debe estar correctamente configurado en el jugador
- Las Layers deben estar asignadas en el editor de Godot
- Los assets de audio y particulas deben crearse externamente

### Recomendaciones para implementacion
1. Empezar creando los TerrainData resources antes que el codigo
2. Configurar las Layers en Godot antes de probar
3. Crear un nivel de prueba con todos los tipos de terreno
4. Implementar el sistema de debug para ver el terreno actual
5. Probar con diferentes combinaciones de equipo y terreno
