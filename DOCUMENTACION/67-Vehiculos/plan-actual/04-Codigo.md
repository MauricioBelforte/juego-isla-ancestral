**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 67: Vehículos

## 1. Archivos Involucrados

| Archivo | Ruta | Rol |
|---|---|---|
| `vehicle_preset.gd` | `Assets/_Project/Vehicles/data/` | Modelo: tipo, física, capacidades, mejoras |
| `vehicles_catalog.tres` | `Assets/_Project/Vehicles/data/` | Catálogo: barco, dirigible, submarino, locomotora-plantilla |
| `vehicle_manager.gd` | `Assets/_Project/Vehicles/service/` | Autoload: estado, vehículo activo, entrada/salida, dock |
| `vehicle_controller.gd` | `Assets/_Project/Vehicles/service/` | Física acotada: velocidad/giro/frenado/altitud |
| `vehicle_streaming.gd` | `Assets/_Project/Vehicles/service/` | chunk_target del vehículo, LOD por altitud (M10/M61) |
| `vehicle_cargo.gd` | `Assets/_Project/Vehicles/service/` | Baúl (M14), mejoras, personalización, persistencia (M59) |
| `vehicle_dock.gd` | `Assets/_Project/Vehicles/service/` | Docking con magnetismo suave (M28) |
| `vehicle_hud.gd` | `Assets/_Project/Vehicles/ui/` | HUD del vehículo en M53: velocidad, dirección, baúl |
| `vehicle_customize.gd` | `Assets/_Project/Vehicles/ui/` | Pintura, banderas, nombre (M46/M87) |
| `validate_vehicles.gd` | `Assets/_Project/Vehicles/validators/` | Física, streaming, colisiones, presupuestos |

## 2. Funciones Clave y Logs Relacionados

### 2.1 `vehicle_manager.gd` (autoload)
```gdscript
func enter(vehicle: Vehicle) -> void:
    if not _can_enter(vehicle): return  # docked y superficie (barco)
    _active = vehicle
    VehicleController.enable(vehicle.preset)
    VehicleStreaming.set_target(vehicle)  # M10/M61: chunk_target
    VehicleHud.show(vehicle)
    CameraRig.enter_vehicle(vehicle.preset)  # 3ª persona, M57
    Audio.play(vehicle.preset.sounds)  # M43 con LOD
    VehicleEvents.enter.emit(vehicle)
    LOGS.vehicle("VEH-ENTER", {"id": vehicle.id})

func exit() -> void:
    VehicleController.disable()
    VehicleStreaming.set_target(Global.player)  # volver al jugador
    VehicleHud.hide(); CameraRig.exit_vehicle()
    Audio.stop_all_vehicle()  # M43: sin fugas
    LOGS.vehicle("VEH-EXIT", {})
```

### 2.2 `vehicle_controller.gd` (física acotada)
```gdscript
func _physics_process(delta: float) -> void:
    var p: VehiclePreset = _preset
    _speed = move_toward(_speed, _input_throttle() * p.max_speed, p.accel * delta)
    _yaw += _input_steer() * p.turn_rate * delta
    if _preset.type == PRESET_SUBMARINE:
        _depth += _input_dive() * p.dive_rate * delta  # límite −40 m
    elif _preset.type == PRESET_AIRSHIP:
        _alt = clamp(_alt + _input_climb() * p.climb_rate * delta, 0.0, p.max_alt)
    var surface_y: float = Water.surface_y(_pos)  # M51: solo lectura visual
    _pos += _dir * _speed * delta
    _clamp_to_bounds()  # no atravesar islas/rocas (M50)
    VehicleStreaming.notify_position(_pos)  # M10/M61
```

### 2.3 `vehicle_dock.gd` (magnetismo suave)
```gdscript
func try_dock(mooring: Mooring) -> bool:
    var angle_diff := _angle_to(mooring.global_rotation)
    if angle_diff > MAX_DOCK_ANGLE: return false  # permitir reintento
    _active.global_position = mooring.dock_position
    _active.global_rotation = mooring.dock_rotation
    VehicleEvents.docked.emit(mooring)
    LOGS.vehicle("VEH-DOCK", {"mooring": mooring.id})
    return true
```

## 3. Contratos de Integración (Eventos del EventBus M07)

| Evento | Emisor | → Vehículos |
|---|---|---|
| `VEHICLE_ENTERED` | vehicle_manager | M53 HUD, M57 cámara, M43 audio |
| `VEHICLE_EXITED` | vehicle_manager | M53/M57 restauración, M43 stop |
| `VEHICLE_DOCKED` | vehicle_dock | M28 viajes, M59 persistencia |
| `VEHICLE_UPGRADED` | vehicle_cargo | M14 baúl, persistencia M59 |
| `PHOTO_POSE_REQUEST` | M56 | Pasajeros posan si aplica (foto del barco) |

## 4. Logs Relacionados (Sistema de Logs del Proyecto)

El módulo usa el sistema central de logs de consola (M118): prefijo `[VEH]` en desarrollo y canal depurado en builds (sección 18 de AGENTS.md); rotación automática fuera de `Assets/`.

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Parcial (con dudas)

### Lo que hice
- Documenté el módulo 67 completo (diseño técnico de Godot 4): presets de 3 vehículos + plantilla locomotora condicional, física acotada sin fluidos, streaming con chunk_target y LOD por altitud, docking con magnetismo suave, baúl (M14) y mejoras persistentes (M59), personalización cozy, audio/animaciones con LOD y validación.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Verificar en runtime: no hay editor Godot ni build en este entorno; los `.gd` de esta documentación son prototipos de diseño que se escribirán en la fase de implementación.
- `[?]` Confirmar si la locomotora existe: el plan maestro la marca "si existe" — depende de que M68 (Transporte y Navegación) defina el ferrocarril; por eso está como plantilla condicional.
- `[?]` Confirmar la interacción exacta con la superficie del agua (M51): el diseño asume lectura visual de la superficie, sin simulación de olas sobre el casco.

### Intentos fallidos / decisiones
- Decidí NO usar simulación de fluidos (costo alto); el barco lee la superficie de M51.
- Decidí que el vehículo es el chunk_target del loader (M10/M61): es la única forma de que el dirigible no rompa el streaming.
- Decidí sin combustible (cozy) y con reparaciones opcionales (M15) — alineado con la filosofía del proyecto.

### Recomendaciones para el próximo agente
- Al implementar: coordinar con M68 el contrato de la locomotora (si el ferrocarril existe) y con M51 la API de la superficie del agua.
- Probar a fondo: dirigible a 60 m sobre terreno no generado (LOD), barco contra rompeolas, submarino en cuevas subacuáticas (M25).
- Probar la cámara con Reduce Motion (M58) — el mareo es el riesgo #1 de los vehículos.