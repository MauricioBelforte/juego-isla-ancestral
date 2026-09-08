# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-07
#
# TEMPORAL (M09): BOT DE PASEO REALISTA — camina como el usuario: simula W
# (avanzar) vía _update_move_direction del Player, GIRA el player hacia el
# waypoint objetivo, y si hay agua/nada delante usa vuelo de dev (sube y
# avanza). Monitorea: caída al vacío, atascado (sin progreso 6s), FPS.
# Cada waypoint: captura + resumen del tramo. "PASEO EXITOSO" al final.

extends Node

## Waypoints del paseo (diagonal spawn→montañas→vuelta por el sur)
const WAYPOINTS: Array[Vector3] = [
	Vector3(3860.0, 0.0, 3860.0),
	Vector3(3660.0, 0.0, 3660.0),
	Vector3(3360.0, 0.0, 3360.0),
	Vector3(3060.0, 0.0, 3060.0),
	Vector3(2860.0, 0.0, 2860.0),   # borde de la laguna
	Vector3(2660.0, 0.0, 2660.0),   # valle central
	Vector3(2460.0, 0.0, 2460.0),   # subiendo la montaña
	Vector3(2260.0, 0.0, 2260.0),
	Vector3(2060.0, 0.0, 2060.0),
	Vector3(1960.0, 0.0, 1960.0),   # cruzando al oeste
	Vector3(1860.0, 0.0, 2160.0),
	Vector3(1960.0, 0.0, 2460.0),
	Vector3(2160.0, 0.0, 2760.0),   # regreso por el sur
	Vector3(2460.0, 0.0, 3060.0),
	Vector3(2860.0, 0.0, 3360.0),
	Vector3(3260.0, 0.0, 3560.0),
	Vector3(3660.0, 0.0, 3760.0),
]

const TIMEOUT_WP := 25.0        # seg máx por waypoint
const STUCK_UMBRAL := 6.0       # seg sin progreso = atascado → volar
const DIST_LLEGADA := 40.0      # "llegué" a menos de 40m
const Y_VUELO_MIN := 30.0       # altura mínima en modo vuelo
const DELAY_BOOT := 12.0

var _wp_idx := 0
var _delay := DELAY_BOOT
var _stage := "esperando"   # esperando → caminando → listo
var _bugs: Array[String] = []
var _capturas := 0
var _ultimo_frame := Time.get_ticks_msec()
var _pos_inicial_tramo := Vector3.ZERO
var _tiempo_tramo := 0.0
var _vuelo := false
var _player: Node3D = null
var _main: Node = null
var _rescates := 0


## Switch ON/OFF (petición usuario): el bot SOLO corre si el juego se lanza
## con `-- paseo`. Sin ese flag se apaga solo (modo humano: el jugador mueve
## el personaje con WASD normalmente).
##   Modo bot:    Godot.exe --path . -- paseo
##   Modo humano: Godot.exe --path .   (normal — el bot se auto-desactiva)
func _ready() -> void:
	_activo = false
	for arg in OS.get_cmdline_user_args():
		if arg == "paseo":
			_activo = true
			break
	if not _activo:
		set_process(false)
		print("[BOT] Desactivado (modo humano — lanza con `-- paseo` para activar el paseo automático)")
		return
	print("[BOT] Paseo realista: %d waypoints caminando/volando" % WAYPOINTS.size())


var _activo := false


func _process(delta: float) -> void:
	if not _activo:
		return
	# Detección de tilde (frame congelado >2s)
	var ahora := Time.get_ticks_msec()
	if ahora - _ultimo_frame > 2000:
		_bugs.append("TILDE: %dms en wp %d" % [ahora - _ultimo_frame, _wp_idx])
		_ultimo_frame = ahora
		return
	_ultimo_frame = ahora

	match _stage:
		"esperando":
			_delay -= delta
			if _delay <= 0.0:
				_comenzar()
		"caminando":
			_tick_caminando(delta)
		_:
			pass


func _comenzar() -> void:
	_main = get_tree().root.get_node_or_null("Main")
	_player = _main.get_node_or_null("Player") as Node3D if _main != null else null
	if _player == null:
		_bugs.append("Player no encontrado")
		_terminar()
		return
	_stage = "caminando"
	print("[BOT] Comenzando paseo realista desde %s" % str(_player.global_position))
	_ir_a_waypoint()


func _tick_caminando(delta: float) -> void:
	var objetivo := WAYPOINTS[_wp_idx]
	var pos := _player.global_position
	_tiempo_tramo += delta

	# ¿Llegó?
	var dist_xz := Vector2(pos.x, pos.z).distance_to(Vector2(objetivo.x, objetivo.z))
	if dist_xz < DIST_LLEGADA:
		_llego()
		return

	# Girar el player hacia el waypoint (el movimiento de W va hacia donde mira)
	var hacia := Vector3(objetivo.x - pos.x, 0.0, objetivo.z - pos.z).normalized()
	_player.rotation.y = atan2(-hacia.x, -hacia.z)

	# Volar si: hay agua/terreno bajo delante o quedó atascado (el vuelo de
	# dev flota — activo al mantener C... en realidad sube con espacio; el
	# modo vuelo del bot: sostiene "saltar" y sube velocidad — simplificado:
	# si el terreno delante es más alto o agua, mantener salto)
	var gen = _generador()
	var h_delante := 4.0
	if gen != null:
		var adelante := pos + hacia * 40.0
		h_delante = float(gen.get_height(int(adelante.x), int(adelante.z)))
	var agua_delante := h_delante < 4.0
	# Andar como el usuario: simular la TECLA W real (parse_input_event —
	# Input.is_key_pressed(KEY_W) la lee el player cada frame)
	var ev_press := InputEventKey.new()
	ev_press.keycode = KEY_W
	ev_press.pressed = true
	Input.parse_input_event(ev_press)
	# Mantener espacio (nadar/subir) si hay agua delante o el player está en agua
	if agua_delante or pos.y < 4.5:
		var ev_esp := InputEventKey.new()
		ev_esp.keycode = KEY_SPACE
		ev_esp.pressed = true
		Input.parse_input_event(ev_esp)

	# Monitoreo
	_monitorear(delta, pos, dist_xz)


func _monitorear(delta: float, pos: Vector3, dist_xz: float) -> void:
	var gen = _generador()
	var h_gen := -100.0
	if gen != null:
		h_gen = float(gen.get_height(int(pos.x), int(pos.z)))
	# Caída al vacío: muy por debajo del terreno esperado
	if pos.y < h_gen - 5.0 and pos.y < 2.0:
		_rescatar("CAIDA AL VACIO (y=%.1f, gen=%.1f)" % [pos.y, h_gen])
		return
	# Atascado: sin progreso horizontal en 6s → activar vuelo sobre obstáculos
	if pos.distance_to(_pos_inicial_tramo) < 8.0 and _tiempo_tramo > STUCK_UMBRAL:
		_rescatar("ATASCADO (sin progreso %.0fs)" % _tiempo_tramo)
		return
	# Timeout del waypoint
	if _tiempo_tramo > TIMEOUT_WP:
		_rescatar("TIMEOUT waypoint (%.0fs)" % _tiempo_tramo)


## Rescate: teleport corto hacia el waypoint (como si el usuario usara el
## modo dev) y activa vuelo hasta el próximo tramo.
func _rescatar(motivo: String) -> void:
	_rescates += 1
	var msg := "wp %d: %s — rescate #%d (vuelo activado)" % [_wp_idx, motivo, _rescates]
	_bugs.append(msg)
	print("[BOT][RESCATE] " + msg)
	# Vuelo: subir a altura segura y avanzar directo (teleport corto de 100m)
	var objetivo := WAYPOINTS[_wp_idx]
	var pos := _player.global_position
	var hacia := (Vector3(objetivo.x, 0.0, objetivo.z) - Vector3(pos.x, 0.0, pos.z)).normalized()
	var nuevo := Vector3(objetivo.x, maxf(pos.y, Y_VUELO_MIN + 10.0), objetivo.z)
	_player.global_position = nuevo
	_player.velocity = Vector3.ZERO
	_pos_inicial_tramo = nuevo
	_tiempo_tramo = 0.0


func _llego() -> void:
	var ev_up := InputEventKey.new()
	ev_up.keycode = KEY_W
	ev_up.pressed = false
	Input.parse_input_event(ev_up)
	print("[BOT] wp %d alcanzado (dist<%dm, %.1fs)" % [_wp_idx, DIST_LLEGADA, _tiempo_tramo])
	_vuelo = false
	_capturar()
	_wp_idx += 1
	if _wp_idx >= WAYPOINTS.size():
		_terminar()
	else:
		_ir_a_waypoint()


func _ir_a_waypoint() -> void:
	_pos_inicial_tramo = _player.global_position
	_tiempo_tramo = 0.0
	_tramo_bugs_reportados.clear()
	print("[BOT] → wp %d en %s" % [_wp_idx, str(WAYPOINTS[_wp_idx])])

var _tramo_bugs_reportados: Array[String] = []


func _capturar() -> void:
	var img := get_viewport().get_texture().get_image()
	if img != null:
		var dir := "user://capturas_m51"
		DirAccess.make_dir_recursive_absolute(dir)
		img.save_png("%s/paseo_%02d.png" % [dir, _wp_idx])
		_capturas += 1


func _terminar() -> void:
	var ev_up := InputEventKey.new()
	ev_up.keycode = KEY_W
	ev_up.pressed = false
	Input.parse_input_event(ev_up)
	print("==========================================")
	print("PASEO TERMINADO: %d/%d waypoints, %d capturas, %d rescates" % [_wp_idx, WAYPOINTS.size(), _capturas, _rescates])
	if _bugs.is_empty():
		print("PASEO EXITOSO — 0 bugs detectados")
	else:
		print("PASEO CON OBSERVACIONES: %d" % _bugs.size())
		for b in _bugs:
			print("  - " + b)
	print("==========================================")
	get_tree().quit()


func _generador():
	if _main == null:
		return null
	var terrain := _main.get_node_or_null("VoxelTerrain")
	if terrain != null and terrain.generator != null and terrain.generator.has_method("_get_island_gen"):
		return terrain.generator._get_island_gen()
	return null
