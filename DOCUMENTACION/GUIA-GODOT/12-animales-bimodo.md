# Animales Bimodo — Design Patterns

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §12
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## 1. Estado dual: Caminar ↔ Volar

Los animales bimodo tienen dos estados principales:

| Estado | Movimiento | Transformación |
|---|---|---|
| **Tierra** | Caminar/Correr | Piernas extendidas, cuerpo cerca del suelo |
| **Vuelo** | Volar/Planear | Piernas retraídas, cuerpo elevado |

---

## 2. Máquina de estados simple

```gdscript
extends CharacterBody3D

enum State { GROUND, AIR }
var current_state: State = State.GROUND

func _physics_process(delta: float) -> void:
    match current_state:
        State.GROUND:
            _process_ground(delta)
        State.AIR:
            _process_air(delta)

func _process_ground(delta: float) -> void:
    # Movimiento terrestre
    velocity.y -= gravity * delta
    move_and_slide()

func _process_air(delta: float) -> void:
    # Movimiento aéreo
    velocity.y -= gravity * delta * 0.5  # Gravedad reducida
    move_and_slide()
```

---

## 3. Transformación de piernas con Quaternion (§12.1)

### Problema

Rotar huesos de piernas con `rotation.x` causa gimbal lock y orientaciones incorrectas.

### Solución: Quaternion

```gdscript
func _deploy_legs() -> void:
    # Retraer piernas durante el vuelo
    var target_quat := Quaternion(Basis.IDENTITY)
    var deploy_quat := Quaternion(Vector3.RIGHT, deg_to_rad(-45.0))

    # Interpolación suave
    left_leg.quaternion = left_leg.quaternion.slerp(deploy_quat, 0.1)
    right_leg.quaternion = right_leg.quaternion.slerp(deploy_quat, 0.1)
```

### ¿Por qué Quaternion?

- Evita gimbal lock.
- Permite interpolación suave entre orientaciones.
- Es la forma nativa de representar rotaciones en 3D.

---

## 4. Ground snapping — Evitar flotar (§12.2)

### Problema

Los animales "flotan" sobre el terreno porque su posición no se adapta a la superficie.

### Solución: Raycast hacia abajo

```gdscript
func _snap_to_ground() -> void:
    var ray_origin := global_position
    var ray_end := global_position + Vector3.DOWN * 10.0

    var space_state := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    query.collision_mask = 1  # Solo terreno

    var result := space_state.intersect_ray(query)

    if result:
        var target_y := result.position.y + GROUND_OFFSET
        global_position.y = lerp(global_position.y, target_y, 0.2)
    else:
        # Si no hay suelo, cambiar a estado AIR
        current_state = State.AIR
```

### Parámetros importantes

- `GROUND_OFFSET`: distancia mínima entre el animal y el suelo (ej: 0.5m).
- `collision_mask`: máscara de colisión para ignorar agua, etc.
- `lerp factor`: qué tan rápido se adapta al terreno (0.1 = suave, 0.5 = rápido).

---

## 5. Patrones de diseño

### State Machine Pattern

```
Animal
├── StateMachine
│   ├── GroundState
│   ├── AirState
│   └── SwimState (opcional)
└── MeshInstance3D
```

### Component Pattern

```
Animal (Node3D)
├── MovementComponent ((CharacterBody3D))
├── AnimationComponent (AnimationPlayer)
├── GroundDetector (RayCast3D)
└── MeshComponent (MeshInstance3D)
```

---

## 6. Checklist de implementación

- [ ] Definir estados (GROUND, AIR, SWIM)
- [ ] Implementar máquina de estados
- [ ] Configurar Quaternion para piernas
- [ ] Implementar ground snapping con raycast
- [ ] Configurar gravedad por estado
- [ ] Agregar animaciones por estado
- [ ] Testear transiciones suaves
- [ ] Optimizar raycast (no cada frame si no es necesario)
