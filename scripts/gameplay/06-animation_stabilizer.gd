extends NPCVisualLOD

signal greeting_started
signal greeting_finished
signal greeting_cancelled

@export_category("Clips importados")
# Copia aquí los nombres exactos que imprime el AnimationPlayer.
@export var source_idle: StringName = &""
@export var source_greeting: StringName = &""

@export_category("Reproducción")
@export_range(0.0, 1.0, 0.01) var crossfade_seconds: float = 0.20
@export_range(0.1, 3.0, 0.05) var playback_speed: float = 1.0

@export_category("Seguridad del saludo")
# Déjalo desactivado hasta revisar la trayectoria del brazo.
@export var greeting_enabled: bool = false
@export_range(0.0, 30.0, 0.5) var greeting_cooldown: float = 4.0

# Protección frente a un clip que no termina como se esperaba.
@export_range(1.0, 30.0, 0.5) var greeting_timeout: float = 8.0

@export_category("Diagnóstico")
@export var print_imported_clips: bool = true

const RUNTIME_LIBRARY: StringName = &"COZY_RUNTIME"
const IDLE_CLIP: StringName = &"COZY_RUNTIME/IDLE"
const GREETING_CLIP: StringName = &"COZY_RUNTIME/SALUDO"

var _animation_player: AnimationPlayer
var _greeting_timer: Timer

var _animation_ready: bool = false
var _has_greeting: bool = false
var _greeting_active: bool = false

var _next_greeting_time: float = 0.0


func _ready() -> void:
	# Conectamos antes de que la clase base seleccione el primer LOD.
	lod_changed.connect(_on_visual_lod_changed)

	super._ready()

	if _visuals.size() != 3:
		return

	_animation_player = _find_animation_player(_visuals[Level.HIGH])

	if _animation_player == null:
		push_error(
			"%s: el visual ALTA no contiene AnimationPlayer." % name
		)
		return

	if print_imported_clips:
		print(
			"%s — clips importados: %s"
			% [name, _animation_player.get_animation_list()]
		)

	if not _prepare_local_animations():
		return

	_animation_player.animation_finished.connect(
		_on_animation_finished
	)

	_greeting_timer = Timer.new()
	_greeting_timer.name = "GREETING_WATCHDOG"
	_greeting_timer.one_shot = true
	add_child(_greeting_timer)
	_greeting_timer.timeout.connect(_on_greeting_timeout)

	_animation_ready = true

	if get_current_lod() == Level.HIGH:
		_play_idle()
	else:
		_animation_player.stop()


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer

	for child in node.get_children():
		var result := _find_animation_player(child)

		if result != null:
			return result

	return null


func _prepare_local_animations() -> bool:
	if source_idle == &"":
		push_error(
			"%s: configura source_idle con el nombre real del clip."
			% name
		)
		return false

	if not _animation_player.has_animation(source_idle):
		push_error(
			"%s: no existe el clip IDLE '%s'."
			% [name, source_idle]
		)
		return false

	# El nombre se reserva para esta instancia.
	if _animation_player.has_animation_library(RUNTIME_LIBRARY):
		push_error(
			"%s: ya existe una biblioteca llamada %s."
			% [name, RUNTIME_LIBRARY]
		)
		return false

	var library := AnimationLibrary.new()

	var idle_original := _animation_player.get_animation(source_idle)
	var idle_copy := idle_original.duplicate(true) as Animation

	if idle_copy.length <= 0.0:
		push_error("%s: el clip IDLE tiene duración cero." % name)
		return false

	# Configuramos el bucle sobre una copia, no sobre el GLB importado.
	idle_copy.loop_mode = Animation.LOOP_LINEAR
	library.add_animation(&"IDLE", idle_copy)

	_has_greeting = false

	if source_greeting != &"":
		if _animation_player.has_animation(source_greeting):
			var greeting_original := _animation_player.get_animation(
				source_greeting
			)
			var greeting_copy := greeting_original.duplicate(true) as Animation

			if greeting_copy.length > 0.0:
				greeting_copy.loop_mode = Animation.LOOP_NONE
				library.add_animation(&"SALUDO", greeting_copy)
				_has_greeting = true
			else:
				push_warning(
					"%s: SALUDO tiene duración cero; se desactiva."
					% name
				)
		else:
			push_warning(
				"%s: no existe el clip SALUDO '%s'."
				% [name, source_greeting]
			)

	var error := _animation_player.add_animation_library(
		RUNTIME_LIBRARY,
		library
	)

	if error != OK:
		push_error(
			"%s: no se pudo crear la biblioteca local de animaciones."
			% name
		)
		return false

	return true


func _play_idle() -> void:
	if not _animation_ready:
		return

	if get_current_lod() != Level.HIGH:
		return

	_animation_player.play(
		IDLE_CLIP,
		crossfade_seconds,
		playback_speed
	)


func saludar() -> bool:
	if not _animation_ready:
		return false

	if not greeting_enabled or not _has_greeting:
		return false

	if get_current_lod() != Level.HIGH:
		return false

	if _greeting_active:
		return false

	var now := Time.get_ticks_msec() / 1000.0

	if now < _next_greeting_time:
		return false

	_greeting_active = true
	_next_greeting_time = now + greeting_cooldown

	_animation_player.play(
		GREETING_CLIP,
		crossfade_seconds,
		playback_speed
	)

	_greeting_timer.start(greeting_timeout)
	greeting_started.emit()

	return true


func cancelar_saludo() -> void:
	if not _greeting_active:
		return

	_greeting_active = false
	_greeting_timer.stop()

	if _animation_ready:
		_animation_player.stop()

	greeting_cancelled.emit()

	if get_current_lod() == Level.HIGH:
		_play_idle()


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != GREETING_CLIP:
		return

	if not _greeting_active:
		return

	_greeting_active = false
	_greeting_timer.stop()

	greeting_finished.emit()
	_play_idle()


func _on_greeting_timeout() -> void:
	if not _greeting_active:
		return

	push_warning(
		"%s: el saludo superó el tiempo de seguridad; se cancela."
		% name
	)

	cancelar_saludo()


func _on_visual_lod_changed(
	_previous_lod: int,
	current_lod: int
) -> void:
	# La primera señal puede llegar durante super._ready().
	if not _animation_ready:
		return

	if current_lod == Level.HIGH:
		_play_idle()
		return

	if _greeting_active:
		cancelar_saludo()
	else:
		_animation_player.stop()
```

### Configuración
