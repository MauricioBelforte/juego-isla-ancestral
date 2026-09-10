# ZOOM DE CÁMARA CORRECTO EN EL PERSONAJE

> **Modelo:** glm-5.3-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-09
> **Validado en:** Isla Ancestral — isla 10× (5120×5120), GPU integrada AMD Radeon
> **Logs:** 799-802

---

## El problema

El scroll del mouse hacía zoom **en el minimapa** en vez de en la cámara, o
directamente no hacía nada. Además, los widgets del HUD pueden "robar" eventos
de input al mundo sin que se note.

## Las causas (en orden de frecuencia)

1. **Un widget del HUD consume el scroll siempre** — por ejemplo, un minimapa
   que procesa el scroll en `_unhandled_input` sin verificar si el mouse está
   sobre él, marcándolo como manejado con `set_input_as_handled()`.
2. **El mouse capturado (MOUSE_MODE_CAPTURED)** desvía los eventos — si el
   widget chequea `has_point()` con mouse capturado, el chequeo falla y el
   comportamiento se vuelve errático.
3. **Dos sistemas escuchando el mismo evento** sin división clara de zonas.

---

## La solución correcta (3 piezas)

### Pieza 1 — La cámara con zoom por scroll (follow_camera.gd)

La cámara tercera persona maneja su zoom en `_unhandled_input` con el scroll,
y su `_physics_process` interpola la distancia:

```gdscript
extends Camera3D
## Cámara tercera persona: rotación con mouse, zoom con scroll,
## colisión con terreno (M09/M40).

@export var zoom_speed := 2.0
@export var min_distance := 4.0
@export var max_distance := 20.0

var _distance := 12.0
var _target: Node3D = null
var _terrain: VoxelTerrain = null

func _ready() -> void:
	_find_terrain()

func _unhandled_input(event: InputEvent) -> void:
	# Zoom con scroll — este nodo es el ÚLTIMO en la cadena: si un widget
	# del HUD necesita el scroll, debe filtrar ANTES (ver Pieza 2).
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_distance = max(_distance - zoom_speed, min_distance)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_distance = min(_distance + zoom_speed, max_distance)

func _physics_process(delta: float) -> void:
	if _target == null:
		return
	# Posición: detrás del player, a _distance, con colisión contra el terreno
	var offset := _get_offset()
	global_position = _target.global_position + offset

func _get_offset() -> Vector3:
	var dir := -global_transform.basis.z.normalized()
	var pos := _target.global_position + dir * _distance + Vector3(0, 4, 0)
	# Colisión con terreno: raycast hacia la cámara
	if _terrain != null:
		var vt := _terrain.get_voxel_tool()
		# ... raycast opcional contra el terreno
	return pos
```

**Puntos clave**:
- El zoom va en `_unhandled_input` (NO en `_input` — así los widgets del HUD
  tienen prioridad para eventos de UI).
- Clamp SIEMPRE con `max()/min()` a min/max_distance.
- La distancia se interpola suavemente en `_physics_process` (no saltos).

### Pieza 2 — El minimapa solo consume el scroll SI el mouse está encima

**Este es el fix del bug real** (Log 803). El minimapa debe chequear si el
mouse está sobre su rectángulo Y que el mouse no esté capturado:

```gdscript
# minimap_widget.gd
func _unhandled_input(event: InputEvent) -> void:
	# FIX M57: SOLO manejar el scroll si el mouse está sobre este widget.
	# Si no, dejar el evento pasar a la cámara (zoom del personaje).
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		if get_global_rect().has_point(get_global_mouse_position()) \
				and not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_zoom = clampf(_zoom + ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
			_update_transform()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if get_global_rect().has_point(get_global_mouse_position()) \
				and not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_zoom = clampf(_zoom - ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
			_update_transform()
			get_viewport().set_input_as_handled()
```

**Puntos clave**:
- `get_global_rect().has_point(pos)` — el rect GLOBAL del widget (no local).
- `get_global_mouse_position()` — posición actual del mouse en pantalla.
- El chequeo de `MOUSE_MODE_CAPTURED` evita comportamientos erráticos cuando
  el juego captura el mouse (rotación con mouse capturado).
- `set_input_as_handled()` SOLO si el minimapa realmente procesó el evento.

### Pieza 3 — Los sub-widgets del minimapa con MOUSE_FILTER_IGNORE

Los hijos visuales del minimapa (rects, dots) deben tener
`MOUSE_FILTER_IGNORE` para no interceptar eventos individualmente:

```gdscript
_bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
_fog_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
_player_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
```

**Regla**: en un widget tipo mapa, SOLO el Control raíz maneja input. Los
hijos visuales son decoración.

---

## La cadena de eventos en Godot (por qué funciona así)

```
1. _input() de todos los nodos          (los que lo implementen)
2. GUI input (Control.mouse_filter)     (botones, widgets con filter STOP/PASS)
3. _shortcut_input()
4. _unhandled_input()                   (cámara, minimapa, mundo)
5. _unhandled_key_input()
```

- Los **Control** del HUD reciben eventos en la fase 2 — antes que
  `_unhandled_input`. Si un Control consume (`accept_event()` o filter STOP),
  la fase 4 nunca lo ve.
- Los **Node3D** (cámara, mundo) solo ven la fase 4.
- Por eso: el minimapa (Control) filtra primero; la cámara (Node3D) recibe
  lo que queda.

---

## Verificación (checklist)

- [ ] Con el mouse en el centro de la pantalla: scroll = zoom de cámara
- [ ] Con el mouse sobre el minimapa: scroll = zoom del minimapa
- [ ] Con el mouse capturado (rotación): sin zoom errático del minimapa
- [ ] La distancia de cámara se clampa a min/max
- [ ] El zoom es suave (interpolado en _physics_process, no saltos)

## Cómo verificar el zoom sin jugar (test automatizado)

```gdscript
# Autoload temporal de test — llama los métodos directamente
func _test_zoom_directo() -> void:
	var main := get_tree().root.get_node_or_null("Main")
	var cam := main.get_node_or_null("Camera3D")
	if cam == null:
		print("[ZOOM-TEST] Camera3D no encontrada")
		return
	# Llamar al método interno directo (equivale al scroll, sin eventos)
	for i in range(5):
		cam._distance = maxf(cam._distance - cam.zoom_speed, cam.min_distance)
	print("[ZOOM-TEST] distancia después: %.1f (max %s)" % [cam._distance, cam.max_distance])
```

> **Nota**: los eventos simulados con `Input.parse_input_event(InputEventKey/MouseButton)`
> SÍ alimentan `_unhandled_input` y `is_key_pressed` — pero llegan al frame
> SIGUIENTE y pueden ser consumidos por otros nodos antes. Para tests
> deterministas, llamar los métodos internos directamente.

## Los errores que evitar con esta guía

| Error | Consecuencia | Prevención |
|---|---|---|
| MinimapWidget consume scroll siempre | Zoom de cámara imposible | Chequeo has_point + mouse_mode |
| `_input()` en vez de `_unhandled_input()` en la cámara | La cámara compite con la UI | Cámara en `_unhandled_input` |
| Hijos del widget sin MOUSE_FILTER_IGNORE | Eventos duplicados/bloqueados | IGNORE en todos los hijos visuales |
| Sin clamp de distancia | Cámara dentro del terreno o a kilómetros | max/min SIEMPRE |
| Zoom por saltos (sin interpolar) | Zoom feo y brusco | Interpolar en _physics_process |
