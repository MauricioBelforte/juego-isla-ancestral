Seguimos con **B: una escena `NPC_BASE` reutilizable en Godot**, con navegación, estados, interacción y animación vinculada al movimiento.

La idea es separar responsabilidades:

```text
NPC_BASE — CharacterBody3D
├── CollisionShape3D       ← Una sola colisión
├── NavigationAgent3D     ← Una sola navegación
└── Visual                ← ALTA / MEDIA / BAJA y animaciones
```

**El controlador será el mismo para los 35 NPCs.** Cada instancia cambia nombre, texto, escenas visuales y parámetros.

Esta entrega utiliza los scripts `NPCVisualLOD` y `NPCAnimado` que ya tenemos. No requiere modificar los modelos. **El código queda como implementación de referencia; no lo he ejecutado en tu proyecto.**

---

# 1. Extender el controlador visual con CAMINAR

Crea:

```text
res://npc/scripts/npc_visual_juego.gd
```

Este script hereda de `NPCAnimado` y añade:

- CAMINAR en bucle.
- Cambio entre IDLE y CAMINAR.
- Velocidad de reproducción basada en la velocidad real.
- Compatibilidad con SALUDO y el cambio de LOD.

```gdscript
class_name NPCVisualJuego
extends NPCAnimado

@export_category("Locomoción")
@export var source_walk: StringName = &""

# Velocidad de desplazamiento que corresponde a reproducción 1.0.
# Ajustar visualmente para reducir el deslizamiento de pies.
@export_range(0.1, 5.0, 0.05)
var walk_reference_speed: float = 0.85

@export_range(0.01, 0.5, 0.01)
var moving_threshold: float = 0.05

const WALK_CLIP: StringName = &"COZY_RUNTIME/CAMINAR"

var _has_walk: bool = false
var _is_moving: bool = false
var _movement_speed: float = 0.0


func _prepare_local_animations() -> bool:
	if not super._prepare_local_animations():
		return false

	if source_walk == &"":
		push_warning(
			"%s: no se configuró CAMINAR; se conservará IDLE." % name
		)
		return true

	if not _animation_player.has_animation(source_walk):
		push_warning(
			"%s: no existe el clip '%s'." % [name, source_walk]
		)
		return true

	var original := _animation_player.get_animation(source_walk)
	var copy := original.duplicate(true) as Animation

	if copy.length <= 0.0:
		push_warning("%s: CAMINAR tiene duración cero." % name)
		return true

	copy.loop_mode = Animation.LOOP_LINEAR

	var library := _animation_player.get_animation_library(
		RUNTIME_LIBRARY
	)

	var error := library.add_animation(&"CAMINAR", copy)
	if error != OK:
		push_warning("%s: no se pudo añadir CAMINAR." % name)
		return true

	_has_walk = true
	return true


func actualizar_locomocion(horizontal_speed: float) -> void:
	_movement_speed = maxf(horizontal_speed, 0.0)

	var now_moving := _movement_speed > moving_threshold

	if now_moving != _is_moving:
		_is_moving = now_moving

		# Un NPC que comienza a caminar deja de saludar.
		if _is_moving and _greeting_active:
			cancelar_saludo()

		_play_idle()

	# Actualizar la velocidad sin reiniciar el clip cada frame.
	if (
		_animation_ready
		and not _greeting_active
		and get_current_lod() == Level.HIGH
		and _animation_player.current_animation == WALK_CLIP
	):
		_animation_player.speed_scale = _walk_playback_speed()


func _walk_playback_speed() -> float:
	return clampf(
		_movement_speed / maxf(walk_reference_speed, 0.01),
		0.45,
		1.65
	)


# La clase padre llama a este método al terminar SALUDO
# y al regresar al LOD ALTA. Aquí elegimos la locomoción correcta.
func _play_idle() -> void:
	if not _animation_ready:
		return

	if _greeting_active:
		return

	if get_current_lod() != Level.HIGH:
		return

	var target: StringName = (
		WALK_CLIP if _is_moving and _has_walk else IDLE_CLIP
	)

	var speed := (
		_walk_playback_speed()
		if target == WALK_CLIP
		else playback_speed
	)

	if (
		_animation_player.current_animation != target
		or not _animation_player.is_playing()
	):
		_animation_player.play(
			target,
			crossfade_seconds,
			speed
		)
	else:
		_animation_player.speed_scale = speed


func saludar() -> bool:
	if _is_moving:
		return false

	return super.saludar()
```

**Los LOD MEDIA y BAJA siguen siendo estáticos** si utilizas los archivos generados anteriormente. Se desplazarán con el personaje, pero no moverán las piernas; queda pendiente generar sus versiones con esqueleto.

---

# 2. Controlador del NPC

Crea:

```text
res://npc/scripts/npc_base.gd
```

Estados:

- **IDLE:** espera.
- **CAMINAR:** sigue un destino de navegación.
- **HABLAR:** se detiene y mira al jugador.

Incluye deambulación opcional alrededor del punto de aparición.

```gdscript
class_name CozyNPC
extends CharacterBody3D

signal interaction_started(npc: CozyNPC)
signal interaction_finished(npc: CozyNPC)
signal destination_reached(npc: CozyNPC)

enum State {
	IDLE,
	CAMINAR,
	HABLAR,
}

@export_category("Identidad")
@export var npc_id: StringName = &"LUNA"
@export var display_name: String = "Luna"
@export_multiline var greeting_text: String = (
	"¡Hola! Estoy buscando un color bonito para pintar el río."
)

@export_category("Movimiento")
@export_range(0.1, 5.0, 0.05)
var move_speed: float = 0.85

@export_range(0.1, 20.0, 0.1)
var acceleration: float = 3.5

@export_range(0.1, 20.0, 0.1)
var deceleration: float = 5.0

@export_range(0.1, 20.0, 0.1)
var turn_speed: float = 5.0

@export var gravity: float = 9.8

@export_category("Deambular")
@export var wander_enabled: bool = true

@export_range(0.5, 30.0, 0.5)
var wander_radius: float = 5.0

@export var idle_time_min: float = 3.0
@export var idle_time_max: float = 7.0

# Evita que una muestra fuera de la isla se proyecte a un punto lejano.
@export var max_navigation_projection: float = 2.0

@export_category("Interacción")
@export var interaction_distance: float = 3.0
@export var conversation_break_distance: float = 4.5
@export var greet_on_interaction: bool = false

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visual: NPCVisualJuego = $Visual

var state: State = State.IDLE

var _home_position: Vector3
var _idle_remaining: float = 0.0
var _interactor: Node3D

var _rng := RandomNumberGenerator.new()
var _stuck_time: float = 0.0
var _last_position: Vector3
var _path_requested: bool = false


func _ready() -> void:
	add_to_group("NPC_INTERACTUABLE")

	_rng.randomize()
	_home_position = global_position
	_last_position = global_position

	# Esta versión no usa evitación RVO.
	# No conectamos velocity_computed ni simulamos que evita multitudes.
	navigation_agent.avoidance_enabled = false
	navigation_agent.path_desired_distance = 0.25
	navigation_agent.target_desired_distance = 0.30

	_schedule_idle()


func _physics_process(delta: float) -> void:
	var desired_velocity := Vector3.ZERO

	match state:
		State.IDLE:
			_idle_remaining -= delta

			if wander_enabled and _idle_remaining <= 0.0:
				if not _choose_wander_target():
					_idle_remaining = 1.5

		State.CAMINAR:
			desired_velocity = _navigation_velocity()

		State.HABLAR:
			_update_conversation(delta)

	var rate := acceleration
	if desired_velocity.length_squared() < 0.0001:
		rate = deceleration

	velocity.x = move_toward(
		velocity.x,
		desired_velocity.x,
		rate * delta
	)
	velocity.z = move_toward(
		velocity.z,
		desired_velocity.z,
		rate * delta
	)

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	move_and_slide()

	var real_velocity := get_real_velocity()
	var horizontal := Vector3(
		real_velocity.x, 0.0, real_velocity.z
	)

	if state != State.HABLAR and horizontal.length() > 0.04:
		_turn_toward(global_position + horizontal, delta)

	visual.actualizar_locomocion(horizontal.length())
	_check_stuck(delta)


func _navigation_ready() -> bool:
	var map_rid := navigation_agent.get_navigation_map()

	return (
		map_rid.is_valid()
		and NavigationServer3D.map_get_iteration_id(map_rid) > 0
	)


func ir_a(world_position: Vector3) -> bool:
	if state == State.HABLAR:
		return false

	if not _navigation_ready():
		return false

	var map_rid := navigation_agent.get_navigation_map()
	var projected := NavigationServer3D.map_get_closest_point(
		map_rid,
		world_position
	)

	if projected.distance_to(world_position) > max_navigation_projection:
		return false

	if projected.distance_to(global_position) < 0.5:
		return false

	navigation_agent.target_position = projected
	_path_requested = true
	state = State.CAMINAR
	_stuck_time = 0.0

	return true


func _navigation_velocity() -> Vector3:
	if not _navigation_ready():
		_stop_walking()
		return Vector3.ZERO

	# Obtener el siguiente punto actualiza la consulta de ruta.
	var next_position := navigation_agent.get_next_path_position()

	if navigation_agent.is_navigation_finished():
		var arrived := navigation_agent.is_target_reached()
		_stop_walking()

		if arrived:
			destination_reached.emit(self)

		return Vector3.ZERO

	var direction := next_position - global_position
	direction.y = 0.0

	if direction.length_squared() < 0.0001:
		return Vector3.ZERO

	return direction.normalized() * move_speed


func _choose_wander_target() -> bool:
	if not _navigation_ready():
		return false

	for attempt in range(8):
		var angle := _rng.randf_range(0.0, TAU)
		var radius := sqrt(_rng.randf()) * wander_radius

		var candidate := _home_position + Vector3(
			cos(angle) * radius,
			0.0,
			sin(angle) * radius
		)

		if ir_a(candidate):
			return true

	return false


func _schedule_idle() -> void:
	state = State.IDLE
	_path_requested = false

	_idle_remaining = _rng.randf_range(
		maxf(0.1, idle_time_min),
		maxf(idle_time_min, idle_time_max)
	)


func _stop_walking() -> void:
	_schedule_idle()


func _check_stuck(delta: float) -> void:
	if state != State.CAMINAR or not _path_requested:
		_stuck_time = 0.0
		_last_position = global_position
		return

	var travelled := global_position.distance_to(_last_position)

	if travelled < 0.015 * delta:
		_stuck_time += delta
	else:
		_stuck_time = 0.0

	_last_position = global_position

	if _stuck_time > 2.5:
		# No insistir indefinidamente contra un obstáculo.
		_stop_walking()


func _turn_toward(target: Vector3, delta: float) -> void:
	var direction := target - global_position
	direction.y = 0.0

	if direction.length_squared() < 0.0001:
		return

	# Los modelos miran hacia -Z.
	var global_yaw := atan2(-direction.x, -direction.z)

	var rotation := visual.global_rotation
	rotation.y = lerp_angle(
		rotation.y,
		global_yaw,
		clampf(turn_speed * delta, 0.0, 1.0)
	)
	visual.global_rotation = rotation


func interactuar(actor: Node3D) -> bool:
	if not is_instance_valid(actor):
		return false

	if state == State.HABLAR:
		return false

	if global_position.distance_to(actor.global_position) > interaction_distance:
		return false

	_interactor = actor
	state = State.HABLAR
	_path_requested = false

	# Detención inmediata para no deslizar durante el diálogo.
	velocity.x = 0.0
	velocity.z = 0.0
	visual.actualizar_locomocion(0.0)

	if greet_on_interaction:
		visual.saludar()

	interaction_started.emit(self)
	return true


func terminar_conversacion() -> void:
	if state != State.HABLAR:
		return

	_interactor = null
	visual.cancelar_saludo()
	_schedule_idle()
	interaction_finished.emit(self)


func _update_conversation(delta: float) -> void:
	if not is_instance_valid(_interactor):
		terminar_conversacion()
		return

	if global_position.distance_to(
		_interactor.global_position
	) > conversation_break_distance:
		terminar_conversacion()
		return

	_turn_toward(_interactor.global_position, delta)
```

### Sobre la navegación

Este código espera un `NavigationRegion3D` con su `NavigationMesh` generado.

El agente:

- Calcula rutas.
- Sigue los puntos de la ruta.
- Se detiene si no consigue avanzar.
- No implementa todavía evitación de multitudes.

**La colisión y la navegación son sistemas diferentes.** La región navegable debe excluir paredes, agua no transitable y otras zonas donde el NPC no pueda caminar.

---

# 3. Escena `NPC_BASE.tscn`

Guarda:

```text
res://npc/scenes/NPC_BASE.tscn
```

```ini
[gd_scene load_steps=4 format=3]

[ext_resource type="Script" path="res://npc/scripts/npc_base.gd" id="1_body"]
[ext_resource type="Script" path="res://npc/scripts/npc_visual_juego.gd" id="2_visual"]

[sub_resource type="CapsuleShape3D" id="Capsule_npc"]
radius = 0.22
height = 1.8

[node name="NPC_BASE" type="CharacterBody3D"]
collision_layer = 2
collision_mask = 1
floor_snap_length = 0.25
script = ExtResource("1_body")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
position = Vector3(0, 0.9, 0)
shape = SubResource("Capsule_npc")

[node name="NavigationAgent3D" type="NavigationAgent3D" parent="."]
path_desired_distance = 0.25
target_desired_distance = 0.3
radius = 0.25
height = 1.8
avoidance_enabled = false

[node name="Visual" type="Node3D" parent="."]
script = ExtResource("2_visual")
```

La escena queda deliberadamente **sin GLB asignados**. Así puedes instanciarla para cualquier personaje.

### Capas físicas utilizadas

| Capa | Uso |
|---|---|
| 1 | Suelo, paredes y entorno |
| 2 | NPCs |

Con esta configuración los NPCs chocan con el entorno, pero **no se bloquean entre sí**. Es una opción inicial cómoda para el juego cozy; si quieres separación física entre vecinos, conviene añadir evitación antes de activar colisión mutua.

---

# 4. Crear Luna como primera instancia

En una escena nueva, instancia `NPC_BASE.tscn` y guárdala como:

```text
res://npc/scenes/NPC_LUNA.tscn
```

Configura el nodo raíz:

```text
Npc Id: LUNA
Display Name: Luna
Greeting Text: ¡Hola! Hoy el río tiene unos colores preciosos.
Move Speed: 0.85
Wander Radius: 4.0
Greet On Interaction: false
```

En `Visual`:

```text
High Scene:    SM_NPC_LUNA_RIG.glb
Medium Scene:  SM_NPC_LUNA_MEDIA.glb
Low Scene:     SM_NPC_LUNA_BAJA.glb

Source Idle:      nombre real de IDLE
Source Walk:      nombre real de CAMINAR
Source Greeting:  nombre real de SALUDO
```

**Desactiva inicialmente el saludo de Luna**, porque lleva una paleta en una mano y un pincel en la otra. Podremos darle después un gesto apropiado sin levantar la herramienta a través de la cabeza.

Para ancianos y guardianes modifica también la cápsula:

| Tipo | Altura | Centro Y | Radio inicial |
|---|---:|---:|---:|
| Adulto | 1,8 | 0,90 | 0,22 |
| Anciano | 1,7 | 0,85 | 0,21 |
| Guardia | 1,9 | 0,95 | 0,26 |

Estos radios son de **colisión**, no el ancho visual total del personaje.

---

# 5. Interacción desde el jugador

Crea un `Node` hijo del jugador:

```text
PLAYER
├── Camera3D
└── NPCInteractor
```

Añade al Input Map:

```text
interactuar
```

Asígnale **E**.

Guarda el siguiente script como:

```text
res://npc/scripts/npc_interactor.gd
```

Incluye un panel mínimo de conversación para probar el flujo completo.

```gdscript
extends Node

@export var actor: Node3D
@export var camera: Camera3D
@export var interaction_range: float = 3.0

# Capa 1: entorno, para que una pared bloquee el rayo.
# Capa 2: NPCs.
@export_flags_3d_physics var ray_collision_mask: int = 3

var _active_npc: CozyNPC

var _canvas: CanvasLayer
var _panel: PanelContainer
var _name_label: Label
var _text_label: Label


func _ready() -> void:
	_create_dialogue_panel()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interactuar"):
		return

	if is_instance_valid(_active_npc):
		_active_npc.terminar_conversacion()
	else:
		_try_interact()

	get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	# También cerrar la UI si desaparece el NPC.
	if _panel.visible and not is_instance_valid(_active_npc):
		_panel.hide()


func _try_interact() -> void:
	if not is_instance_valid(actor) or not is_instance_valid(camera):
		return

	var origin := camera.global_position
	var direction := -camera.global_transform.basis.z
	var end := origin + direction * interaction_range

	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = ray_collision_mask
	query.collide_with_areas = false
	query.collide_with_bodies = true

	if actor is CollisionObject3D:
		query.exclude = [(actor as CollisionObject3D).get_rid()]

	var hit := actor.get_world_3d().direct_space_state.intersect_ray(query)

	if hit.is_empty():
		return

	var node := hit["collider"] as Node
	var npc: CozyNPC = null

	while node != null:
		if node is CozyNPC:
			npc = node as CozyNPC
			break
		node = node.get_parent()

	if npc == null:
		return

	if not npc.interactuar(actor):
		return

	_active_npc = npc
	npc.interaction_finished.connect(
		_on_conversation_finished,
		CONNECT_ONE_SHOT
	)

	_name_label.text = npc.display_name
	_text_label.text = npc.greeting_text + "\n\n[E] Terminar conversación"
	_panel.show()


func _on_conversation_finished(npc: CozyNPC) -> void:
	if npc != _active_npc:
		return

	_active_npc = null
	_panel.hide()


func _create_dialogue_panel() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 20
	add_child(_canvas)

	var screen := Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.add_child(screen)

	_panel = PanelContainer.new()
	screen.add_child(_panel)

	_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_left = 32
	_panel.offset_right = -32
	_panel.offset_top = -190
	_panel.offset_bottom = -24
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	_panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 24)
	column.add_child(_name_label)

	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(_text_label)

	_panel.hide()
```

En el Inspector de `NPCInteractor`, asigna:

- **Actor:** el `CharacterBody3D` del jugador.
- **Camera:** la cámara activa.

La interacción se hace apuntando al cuerpo del NPC. El rayo también detecta paredes, por lo que no debería permitir hablar a través de ellas si están en la capa 1.

**El panel es de prueba**, no un sistema completo de diálogos. El jugador conserva su movimiento; si se aleja demasiado, el NPC termina la conversación.

---

# 6. Preparar el escenario navegable

En tu escena de prueba:

```text
TEST_NPC
├── NavigationRegion3D
│   └── Suelo y geometría utilizada para el bake
├── WorldEnvironment
├── DirectionalLight3D
├── PLAYER
└── NPC_LUNA
```

1. Añade un recurso `NavigationMesh` al `NavigationRegion3D`.
2. Configura el bake para incluir la geometría transitable.
3. Utiliza un radio de agente compatible con tus NPCs; **0,26 m** es un punto inicial para incluir a los guardianes.
4. Genera la malla navegable.
5. Coloca al NPC sobre ella.
6. Activa **Debug → Visible Navigation** durante la prueba.

No coloques el NPC dentro del suelo ni sobre una superficie sin colisión. El `NavigationMesh` calcula rutas, pero **no sostiene físicamente al personaje**.

---

# 7. Qué deberías poder probar

| Acción | Resultado |
|---|---|
| Iniciar escena | El NPC espera en IDLE |
| Esperar unos segundos | Elige un punto cercano y camina |
| Llegar al destino | Vuelve a IDLE |
| Apuntar y pulsar E | Se detiene, gira hacia el jugador y abre el panel |
| Pulsar E otra vez | Cierra el panel y vuelve a esperar |
| Alejarse durante la conversación | La conversación termina |
| Alejar la cámara | Cambia de LOD |
| Acercarse | ALTA retoma IDLE o CAMINAR según corresponda |

## Lo que dejamos para el siguiente bloque

Con esto queda la base de **un NPC jugable e interactuable**. Para extenderlo ordenadamente a los 35 faltan:

1. **Fichas `Resource` por personaje**, en lugar de repetir valores en escenas.
2. **Spawner por isla**, con posiciones definidas.
3. Horarios y puntos de actividad.
4. Diálogos con varias líneas y condiciones.
5. LOD MEDIA animado y evitación entre vecinos.
6. Ajustar velocidad del ciclo para minimizar deslizamiento de pies.

**La estructura ya separa visual, navegación e interacción**, por lo que podremos añadir esos sistemas sin modificar los meshes ni duplicar el controlador para cada vecino.