# Cámara, Input y Movimiento — Errores Comunes

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §9.1/9.16/9.23/9.25/9.29/9.30/9.32
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## 1. Vector up colineal con dirección (§9.1)

**Error:** `Target and up vectors are colinear, which is not supported by look_at.`

**Causa:** Ocurre cuando la dirección de la cámara es casi vertical (up = down o similar). `look_at()` no puede calcular una orientación estable porque el vector up y la dirección forman un ángulo de 0° o 180°.

**Solución:** Detectar el caso y usar un up alternativo:

```gdscript
func _orient_camera_up(delta: float) -> void:
    var forward := _get_forward()
    var desired_up := Vector3.UP

    # Si forward es casi vertical, usar un up alternativo
    if abs(forward.dot(Vector3.UP)) > 0.99:
        desired_up = Vector3.FORWARD

    global_transform = global_transform.looking_at(
        global_transform.origin + forward,
        desired_up
    )
```

---

## 2. Movimiento relativo a la cámara (§9.30)

**Error:** El jugador se mueve en dirección fija independiente de la cámara.

**Causa:** Se usa `Vector3.FORWARD` o una dirección世界 fixa en vez de la dirección de la cámara.

**Solución:** Obtener la dirección de la cámara y calcular movimiento relativo:

```gdscript
func _get_camera_forward_flat() -> Vector3:
    var cam := get_viewport().get_camera_3d()
    if cam == null:
        return Vector3.FORWARD
    var forward := -cam.global_transform.basis.z
    forward.y = 0.0
    return forward.normalized()
```

---

## 3. Cálculo de right vector de cámara (§9.32)

**Error:** El jugador se mueve en dirección incorrecta al presionar teclas laterales.

**Causa:** Se usa `Vector3.RIGHT`世界 fixa en vez del vector right de la cámara.

**Solución:**
```gdscript
func _get_camera_right_flat() -> Vector3:
    var cam := get_viewport().get_camera_3d()
    if cam == null:
        return Vector3.RIGHT
    var right := cam.global_transform.basis.x
    right.y = 0.0
    return right.normalized()
```

---

## 4. Movimiento relativo a la dirección de la cámara — Tank controls (§9.33)

```gdscript
func _process(delta: float) -> void:
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var cam := get_viewport().get_camera_3d()

    if cam == null or input_dir == Vector2.ZERO:
        return

    # Dirección de la cámara en el plano horizontal
    var cam_forward := -cam.global_transform.basis.z
    cam_forward.y = 0.0
    cam_forward = cam_forward.normalized()

    var cam_right := cam.global_transform.basis.x
    cam_right.y = 0.0
    cam_right = cam_right.normalized()

    # Movimiento relativo a la cámara
    var move_dir := (cam_forward * input_dir.y + cam_right * input_dir.x)
    if move_dir.length() > 0.001:
        move_dir = move_dir.normalized()
        _apply_movement(move_dir, delta)
        _rotate_body(move_dir, delta)
```

---

## 5. Cámara rota pero competía con edición de bloques (§9.25, §9.29)

**Error:** La cámara rota cuando el jugador está editando bloques.

**Causa:** El script de cámara está procesando input de rotación aunque el juego esté en modo edición.

**Solución:** Verificar el modo del juego antes de procesar input de cámara:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    # Solo procesar rotación si no estamos en modo edición
    if GameMode.get_current_mode() == GameMode.Mode.BUILD:
        return

    if event is InputEventMouseMotion:
        _handle_camera_rotation(event.relative)
```

---

## 6. Cámara sigue al jugador pero con smoothing excesivo (§9.37)

**Error:** La cámara se mueve demasiado lento o rápido respecto al jugador.

**Causa:** `position_smoothing_speed` demasiado bajo o alto, o la cámara está procesando movimiento en `_process()` en vez de `_physics_process()`.

**Solución:**
```gdscript
# En el Camera3D
position_smoothing_enabled = true
position_smoothing_speed = 5.0  # Ajustar según necesidad
```

---

## 7. Input en Godot 4 — Métodos obsoletos (§9.5)

| ❌ Godot 3.x | ✅ Godot 4.x |
|---|---|
| `Input.get_mouse_speed()` | `InputEventMouseMotion.relative` |
| `Input.get_current_input_device_state()` | `InputEvent` en `_unhandled_input()` |
| `Input.set_mouse_mode()` | `Input.mouse_mode = Input.MOUSE_MODE_CAPTURED` |

```gdscript
# ❌ Incorrecto
func _process(delta: float) -> void:
    for event in Input.get_current_input_device_state():
        if event is InputEventMouseMotion:
            var mouse_delta := event.relative

# ✅ Correcto
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var mouse_delta := event.relative
```
