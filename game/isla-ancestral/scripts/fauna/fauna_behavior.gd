# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M36: Fauna - FaunaBehavior (Node3D por individuo).
# FSM basica de 8 estados segun el plan (seccion B). Iter 1 implementa
# la transicion entre estados y delega el movimiento real a M65 (Animales-IA)
# via callbacks (no acoplamiento directo). Si M65 no existe, la FSM corre
# en modo "stub" sin movimiento pero igualmente valida la logica.
#
# RF B:
#   - Estados: INACTIVO, DEAMBULAR, ALIMENTARSE, DESCANSAR, ALERTA, HUIDA, CURIOSA_ACERCARSE, OBSERVANDO_JUGADOR
#   - Velocidad de huida como multiplo del factor de miedo
#   - Factor de miedo individual +-10% por PRNG
#   - Pausa M29: behavior congelado sin desincronizar horarios

extends Node3D
class_name FaunaBehavior

enum Estado { INACTIVO, DEAMBULAR, ALIMENTARSE, DESCANSAR, ALERTA, HUIDA, CURIOSA_ACERCARSE, OBSERVANDO_JUGADOR }

const SpeciesRef = preload("res://scripts/fauna/fauna_species.gd")
const RegistryRef = preload("res://scripts/fauna/fauna_registry.gd")

signal estado_cambiado(nuevo: int, anterior: int)
signal solicitar_avistamiento(contexto: Dictionary)
signal solicitar_movimiento(destino: Vector3, velocidad: float)

var especie = null  # FaunaSpecies (duck-typed)
var factor_miedo: float = 1.0
var instancia_id: String = ""
var _estado: int = Estado.INACTIVO
var _rng: RandomNumberGenerator = null
var _pausa: bool = false
var _tiempo_en_estado: float = 0.0
var _ultimo_avistamiento: float = 0.0  # timestamp en segundos
var _pos_jugador: Vector3 = Vector3.ZERO
var _visible: bool = false
var _tiempo_visible: float = 0.0

func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	# Conectar a TimeCalendar si existe para pausa
	var gt := _get_time_calendar()
	if gt != null and gt.has_signal("dia_cambio"):
		gt.dia_cambio.connect(_on_dia_cambio)
	# M65: auto-registrarse en el manager de animal_ai (si existe)
	var ai := _get_animal_ai()
	if ai != null and ai.has_method("registrar"):
		ai.registrar(self)
	# Auto-impulsar la FSM cada frame: nadie mas llama FaunaBehavior.tick(),
	# asi que el behavior debe dirigir su propia maquina de estados y emitir
	# solicitar_movimiento para que M65 (animal_ai) ejecute el movimiento.
	set_process(true)
	# Cablear avistamiento al registry (M36) en gameplay real (el helper de test
	# no cubre el camino vivo).
	var reg := _get_fauna_registry()
	if reg != null and reg.has_method("registrar_avistamiento"):
		solicitar_avistamiento.connect(reg.registrar_avistamiento)

func _exit_tree() -> void:
	# M65: desregistrarse del manager de animal_ai (si existe)
	var ai := _get_animal_ai()
	if ai != null and ai.has_method("desregistrar"):
		ai.desregistrar(self)

func inicializar(sp, rng: RandomNumberGenerator = null) -> void:
	especie = sp
	if rng != null:
		_rng = rng
	# Generar ID unico si no se proveyó
	if instancia_id == "":
		instancia_id = "fauna_%d_%d" % [Time.get_ticks_msec(), _rng.randi()]
	# Factor de miedo individual
	if especie != null:
		factor_miedo = especie.generar_factor_miedo_individual(_rng)
	# Iniciar con DEAMBULAR tras un breve INACTIVO
	cambiar_estado(Estado.DEAMBULAR)

## ── API publica ─────────────────────────────────────────────

func get_estado() -> int:
	return _estado

func set_pausa(pausa: bool) -> void:
	_pausa = pausa

## Tick del comportamiento. dt: delta en segundos.
func tick(dt: float, pos_jugador: Vector3) -> void:
	if _pausa:
		return
	_tiempo_en_estado += dt
	_pos_jugador = pos_jugador
	match _estado:
		Estado.INACTIVO:
			_tick_inactivo(dt)
		Estado.DEAMBULAR:
			_tick_deambular(dt)
		Estado.ALIMENTARSE:
			_tick_alimentarse(dt)
		Estado.DESCANSAR:
			_tick_descansar(dt)
		Estado.ALERTA:
			_tick_alerta(dt)
		Estado.HUIDA:
			_tick_huida(dt)
		Estado.CURIOSA_ACERCARSE:
			_tick_curiosa(dt)
		Estado.OBSERVANDO_JUGADOR:
			_tick_observando(dt)
	# Detectar avistamiento: jugador dentro de radio de alarma o curiosidad
	_procesar_avistamiento(dt)

## Marca que el animal está visible en pantalla (RF D). Llamado por el sistema
## de UI/render cuando el bounding box del mesh está en pantalla.
func set_visible_en_pantalla(visible: bool) -> void:
	if visible and not _visible:
		_tiempo_visible = 0.0
	elif not visible and _visible:
		_tiempo_visible = 0.0
	_visible = visible

## ── Auto-impulso de la FSM (integracion M36<->M65) ───────

func _process(delta: float) -> void:
	tick(delta, _get_player_position())

func _get_player_position() -> Vector3:
	var p = get_tree().get_first_node_in_group("player")
	if p != null:
		return p.global_position
	return Vector3.ZERO

## ── Tick handlers (RF B) ──────────────────────────────────

func _tick_inactivo(_dt: float) -> void:
	# Permanecer inactivo hasta que cambien las condiciones externas
	pass

func _tick_deambular(_dt: float) -> void:
	# Comportamiento: deambular por puntos cercanos. Iter 1: emitir solicitud
	# de movimiento al consumidor (M65 o stub) y quedarse en este estado.
	if especie == null:
		return
	# Distancia al jugador: si está dentro del radio de alarma -> HUIDA o ALERTA
	var d: float = global_position.distance_to(_pos_jugador)
	if d <= especie.radio_alarma:
		# ¿Es huida instintiva o alerta? Por comportamiento:
		if especie.comportamiento == SpeciesRef.Comportamiento.HUIDA_INSTINTIVA:
			cambiar_estado(Estado.HUIDA)
		else:
			cambiar_estado(Estado.ALERTA)
		return
	# Si el comportamiento es curioso y el jugador está quieto y dentro del radio -> CURIOSA
	if especie.comportamiento == SpeciesRef.Comportamiento.CURIOSA and d <= especie.radio_curiosidad:
		cambiar_estado(Estado.CURIOSA_ACERCARSE)
		return
	# Emite solicitud de movimiento a un punto aleatorio cercano (stub)
	var dir: Vector3 = Vector3(_rng.randf_range(-1.0, 1.0), 0, _rng.randf_range(-1.0, 1.0)).normalized()
	var destino: Vector3 = global_position + dir * 4.0
	solicitar_movimiento.emit(destino, especie.velocidad_deambular)

func _tick_alimentarse(_dt: float) -> void:
	# Iter 1: permanecer aqui; M65 decide cuanto tarda
	if _tiempo_en_estado > 5.0:
		cambiar_estado(Estado.DEAMBULAR)

func _tick_descansar(_dt: float) -> void:
	# Iter 1: descansar
	if _tiempo_en_estado > 10.0:
		cambiar_estado(Estado.DEAMBULAR)

func _tick_alerta(_dt: float) -> void:
	# Alerta: no correr, solo detectar. Si jugador se acerca mas -> HUIDA.
	var d: float = global_position.distance_to(_pos_jugador)
	if especie == null:
		return
	if d <= especie.radio_alarma * 0.5:
		cambiar_estado(Estado.HUIDA)
		return
	if d > especie.radio_alarma * 1.5:
		# Jugador se alejo -> volver a deambular
		cambiar_estado(Estado.DEAMBULAR)

func _tick_huida(_dt: float) -> void:
	# HUIDA: correr en direccion opuesta al jugador
	if especie == null:
		return
	# Velocidad: velocidad_huida * factor_miedo (RF B: multiplo configurado)
	var vel: float = especie.velocidad_huida * factor_miedo
	var away: Vector3 = (global_position - _pos_jugador)
	away.y = 0
	if away.length() > 0.01:
		away = away.normalized()
	else:
		away = Vector3(_rng.randf_range(-1.0, 1.0), 0, _rng.randf_range(-1.0, 1.0)).normalized()
	var destino: Vector3 = global_position + away * 8.0
	solicitar_movimiento.emit(destino, vel)
	# Reevaluar: si la distancia es segura, volver a deambular
	var d: float = global_position.distance_to(_pos_jugador)
	if d > especie.radio_alarma * 2.5:
		cambiar_estado(Estado.DEAMBULAR)

func _tick_curiosa(_dt: float) -> void:
	if especie == null:
		return
	# Acercarse al jugador (rapido pero sin huir)
	var dir: Vector3 = (_pos_jugador - global_position)
	dir.y = 0
	if dir.length() > 0.01:
		dir = dir.normalized()
	# Si está muy cerca, parar y observar
	var d: float = global_position.distance_to(_pos_jugador)
	if d < especie.radio_alarma * 0.5:
		cambiar_estado(Estado.OBSERVANDO_JUGADOR)
		return
	solicitar_movimiento.emit(_pos_jugador, especie.velocidad_deambular * 0.6)
	# Si el jugador se mueve (cambio brusco de pos), volver a alerta
	pass

func _tick_observando(_dt: float) -> void:
	# Observar: no emitir movimiento, solo quedarse
	if _tiempo_en_estado > 3.0:
		cambiar_estado(Estado.DEAMBULAR)

## ── Deteccion de avistamiento (RF D) ────────────────────────

func _procesar_avistamiento(dt: float) -> void:
	if not _visible:
		_tiempo_visible = 0.0
		return
	_tiempo_visible += dt
	if _tiempo_visible < RegistryRef.TOLERANCIA_PANTALLA_S:
		return
	var d: float = global_position.distance_to(_pos_jugador)
	if d > RegistryRef.DISTANCIA_AVISTAMIENTO_M:
		return
	if especie == null:
		return
	# Emitir contexto para que el registry lo registre
	var contexto: Dictionary = {
		"instancia_id": instancia_id,
		"especie_id": String(especie.id),
		"distancia": d,
		"tiempo_pantalla_s": _tiempo_visible,
		"estado": _estado,
	}
	solicitar_avistamiento.emit(contexto)

## ── Transiciones ──────────────────────────────────────────

func cambiar_estado(nuevo: int) -> void:
	if nuevo == _estado:
		return
	var anterior: int = _estado
	_estado = nuevo
	_tiempo_en_estado = 0.0
	estado_cambiado.emit(nuevo, anterior)

func _on_dia_cambio(_info: Dictionary) -> void:
	# M29 cambio de dia: si el comportamiento depende de la hora, ajustar.
	# Iter 1: si es de ventana nocturna y ahora es de noche -> DEAMBULAR
	# Si era de ventana diurna y ahora es de noche -> DESCANSAR
	if especie == null:
		return
	var gt := _get_time_calendar()
	if gt == null or not gt.has_method("get_hora"):
		return
	var hora: int = int(gt.get_hora())
	var activa: bool = especie.activa_en_hora(hora)
	if not activa and _estado != Estado.DESCANSAR:
		cambiar_estado(Estado.DESCANSAR)
	elif activa and _estado == Estado.DESCANSAR:
		cambiar_estado(Estado.DEAMBULAR)

func _get_time_calendar() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("TimeCalendar")

func _get_animal_ai() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("animal_ai")

func _get_fauna_registry() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("fauna_registry")
