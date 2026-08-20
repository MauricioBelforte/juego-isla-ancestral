**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 137: Prototipo

## 1. Archivos Involucrados

| Archivo | Tipo | Propósito |
|---|---|---|
| `scenes/prototipo/prototipo_isla.tscn` | Escena | Escena principal del prototipo |
| `scenes/prototipo/player_proto.gd` | Juego | Movimiento y cámara (M11/M12) |
| `scenes/prototipo/voxel_world_proto.gd` | Juego | Configuración VoxelTools (M08/M09/M10) |
| `scenes/prototipo/extraccion.gd` | Juego | Raycast + voxel_tool (M08/M13) |
| `scenes/prototipo/colocacion.gd` | Juego | Colocar bloque de madera |
| `scenes/prototipo/inventario_proto.gd` | Juego | Slot único (M14) |
| `scenes/prototipo/arbol_recurso.gd` | Juego | Árbol que da madera (M15/M50) |
| `scenes/prototipo/npc_guia.gd` | Juego | NPC de prueba con diálogo (M19/M21) |
| `scenes/prototipo/dialogo_proto.gd` | UI | Caja de diálogo placeholder |
| `scenes/prototipo/puzzle_puerta.gd` | Juego | Puzzle de puerta (M24/M25) |
| `scenes/prototipo/casa_proto.gd` | Juego | Casa con "dormir" (M18) |
| `scenes/prototipo/ciclo_dia_noche_proto.gd` | Juego | Sky ciclico (M31) |
| `scenes/prototipo/lluvia_proto.gd` | Juego | Lluvia de partículas (M32/M52) |
| `autoload/game_state_proto.gd` | Autoload | GameState mínimo (M59) |
| `autoload/save_manager_proto.gd` | Autoload | Guardado delta de chunks (M59/M60) |
| `tools/prototipo/playtest_runner.gd` | Tool | Log de eventos + FPS (M114/M61) |
| `tools/prototipo/encuesta_proto.rst` | Dato | Encuesta de playtest |
| `docs/prototipo/PLAYTEST.md` | Doc | Plan + resultados |
| `docs/prototipo/FILOSOFIA-CHECK.md` | Doc | Checks M152/M153 |
| `docs/prototipo/GONOGO.md` | Doc | Decisión final |
| `docs/prototipo/RETROSPECTIVA.md` | Doc | Lecciones → M138 |

## 2. Funciones Clave

### 2.1 `player_proto.gd` (extractos)

```gdscript
extends CharacterBody3D
## Movimiento y cámara del prototipo (M11/M12).

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const CAM_MIN := 2.0
const CAM_MAX := 8.0

@onready var _cam_arm: SpringArm3D = $CameraArm

func _physics_process(delta: float) -> void:
    var input := Input.get_vector("izq", "der", "adel", "atras")
    var dir := (transform.basis * Vector3(input.x, 0, input.y)).normalized()
    if dir:
        velocity.x = dir.x * SPEED
        velocity.z = dir.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)
    if Input.is_action_pressed("saltar") and is_on_floor():
        velocity.y = JUMP_VELOCITY
    move_and_slide()
```

### 2.2 `extraccion.gd` (raycast de minado)

```gdscript
extends Area3D
## Extrae bloques frente al jugador (radio 3 máx).

@export var radio_max := 3.0

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("usar"):
        var cam := get_viewport().get_camera_3d()
        var from := cam.global_position
        var to := from + -cam.global_transform.basis.z * radio_max
        var query := PhysicsRayQueryParameters3D.create(from, to)
        var hit := get_world_3d().direct_space_state.intersect_ray(query)
        if hit:
            _voxel.warp_block(hit.position, 0)  # 0 = aire
            _inventario.agregar("madera", 1)
```

### 2.3 `save_manager_proto.gd` (guardado delta)

```gdscript
extends Node
## Guarda SOLO chunks modificados (M59/M60).

func guardar(path: String) -> void:
    var data := {
        "version": 1,
        "seed": world_seed.SEED,
        "player": { "pos": player.global_position, "yaw": player.rotation.y },
        "inventory": inventario.serializar(),
        "modified_chunks": voxel.modified_chunks_to_dict(),
        "flags": puzzle_puerta.flags
    }
    FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(data))

func cargar(path: String) -> Result:
    var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
    if data.get("seed") != world_seed.SEED:
        return Result.ERR_SEED_MISMATCH   # aviso: mundo inválido
    player.global_position = data["player"]["pos"]
    inventario.deserializar(data["inventory"])
    voxel.apply_modified_chunks(data["modified_chunks"])
    puzzle_puerta.flags = data["flags"]
    return Result.OK
```

### 2.4 `playtest_runner.gd` (medición, M114/M61)

```gdscript
extends Node
## En modo tool: graba eventos y FPS durante el playtest.

var _log: Array = []
var _fps_samples: Array = []

func _process(_delta: float) -> void:
    _fps_samples.append(Engine.get_frames_per_second())

func registrar_evento(nombre: String) -> void:
    _log.append({"t": Time.get_ticks_msec() / 1000.0, "e": nombre})

func generar_reporte() -> void:
    var media_fps := _fps_samples.reduce(func(a, b): return a + b, 0) / float(_fps_samples.size())
    var reporte := {"eventos": _log, "fps_medio": media_fps, "fps_min": _fps_samples.min()}
    FileAccess.open("res://docs/prototipo/reporte_fps.json", FileAccess.WRITE) \
        .store_string(JSON.stringify(reporte, "\t"))
```

## 3. Logs Relacionados

| Mensaje | Nivel | Cuándo |
|---|---|---|
| `PROTO seed=20260819 cargada` | info | Inicio |
| `PROTO evento: {nombre}` | info | Playtest (playtest_runner) |
| `PROTO FPS medio {n}` | info | Cierre de sesión |
| `PROTO save seed mismatch` | error | Carga con seed distinta |
| `PROTO bloque roto: {textura}` | warning | Extracción de bloque con texto |

## 4. Definición del Entregable (Checklist de Cierre)

1. Sesión completa de 15 min sin bugs bloqueantes.
2. Reporte FPS (M61) guardado.
3. Encuestas de ≥ 3 testers en `PLAYTEST.md`.
4. Checks de filosofía completados en `FILOSOFIA-CHECK.md`.
5. `GONOGO.md` con los 6 criterios y la decisión.
6. Tag git `prototipo-v1` y push.
7. Retrospectiva escrita (insumos para M138).

## 5. Tests (M112)

- `test_proto_save.gd`: guardar→cargar con 0 pérdidas; corrupción de JSON → aviso.
- `test_proto_voxel.gd`: extraer/colocar en bordes de chunk sin crashes.
- `test_proto_camara.gd`: la cámara no atraviesa terreno en 10 posiciones de prueba.
- Ejecución: `godot --headless -s res://tests/prototipo/run_tests.gd`.

## 6. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-19 05:05
**Estado:** Documentación completa

### Lo que hice
- Documenté el módulo Prototipo completo (5 archivos, plan-inicial y plan-actual idénticos al inicio).
- Checklist de 130 ítems verificables, derivados de la sección 136 del plan maestro (19 ítems) + análisis de riesgo de producción (Plan-de-produccion.md sección 1) + alineación M152/M153/M114/M61.

### Lo que NO pude hacer
- Ningún ítem quedó `[?]`: la documentación es diseño de hito; el gameplay real se implementa cuando el usuario arranque la fase de producción.

### Recomendaciones para el próximo agente
- Ejecutar el prototipo antes que cualquier otro sistema de gameplay: es la puerta de entrada de la fase de producción.
- El tag `prototipo-v1` debe crearse en el commit de cierre del hito.
- M138 (Vertical Slice) depende directamente de las lecciones de este prototipo.