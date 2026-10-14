# M48 — Test headless de la API de reproducción (Fase 1).
#
# Verifica end-to-end: AnimationService.play(actor, estado) -> AnimationPlayer.
#   - estado con clip  -> animation_started + clip actual correcto
#   - estado sin clip  -> animation_missing + fallback idle documentado
#   - actor sin player -> animation_missing
#
# Guardia anti-falso-verde: CHECKS_MINIMOS medido + bloque obligatorio.
# Ejecutar:
#   Godot_v4.7.2 --headless --path game/isla-ancestral \
#       --script res://scripts/animacion/test_animacion_play_m48.gd
#
# Modelo: step-5-kilocode | Plataforma: Kilo Code | Fecha: 2026-10-10

extends SceneTree

const CHECKS_MINIMOS := 11
const RUTA_LIB := "res://scripts/animacion/libraries/jugador_lib.tres"

var _checks: int = 0
var _fallos: int = 0
var _bloque_visto: bool = false

var _started: int = 0
var _missing: int = 0
var _ultimo_started: StringName = &""
var _ultimo_missing: StringName = &""


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("  ok: " + msg)


func _armar_actor() -> Node3D:
	var actor := Node3D.new()
	actor.name = "ActorFalso"
	var player := AnimationPlayer.new()
	player.name = "AnimationPlayer"
	actor.add_child(player)
	var lib := ResourceLoader.load(RUTA_LIB) as AnimationLibrary
	if lib == null:
		_fallos += 1
		print("FALLO: no cargo la biblioteca")
		return actor
	var err := player.add_animation_library("", lib)
	if err != OK:
		_fallos += 1
		print("FALLO: add_animation_library devolvio %d" % err)
	return actor


func _initialize() -> void:
	print("=== Test M48: API de reproduccion (Fase 1) ===")

	var svc := root.get_node_or_null("AnimationService")
	if svc == null:
		_fallos += 1
		print("FALLO: AnimationService autoload no encontrado en root")
		print("=== Resumen M48 play: %d checks, %d fallos ===" % [_checks, _fallos])
		quit(1)
		return
	svc.animation_started.connect(_on_started)
	svc.animation_missing.connect(_on_missing)

	# --- Bloque: biblioteca ---
	_bloque_visto = true
	var actor := _armar_actor()
	var player := actor.get_node("AnimationPlayer") as AnimationPlayer
	var lib_ok := player.get_animation_library("") != null
	_check(lib_ok, "biblioteca cargada en el AnimationPlayer")
	if lib_ok:
		var lista: Array = player.get_animation_library("").get_animation_list()
		_check(lista.size() == 3, "biblioteca tiene 3 clips (tiene %d)" % lista.size())

	# --- Bloque: estado CON clip ---
	svc.play(actor, &"idle")
	_check(_started == 1, "play('idle') emitio animation_started (%d)" % _started)
	_check(_ultimo_started == &"idle", "animation_started con estado idle (%s)" % _ultimo_started)
	_check(player.current_animation == "anim_jugador_idle",
		"clip actual = anim_jugador_idle (%s)" % player.current_animation)

	svc.play(actor, &"walk")
	_check(_started == 2, "play('walk') emitio animation_started (%d)" % _started)
	_check(player.current_animation == "anim_jugador_walk",
		"clip actual = anim_jugador_walk (%s)" % player.current_animation)

	svc.play(actor, &"run")
	_check(player.current_animation == "anim_jugador_run",
		"clip actual = anim_jugador_run (%s)" % player.current_animation)

	# --- Bloque: estado SIN clip -> fallback idle ---
	var antes := _missing
	svc.play(actor, &"jump")  # JUMP no tiene clip
	_check(_missing == antes + 1, "play('jump') emitio animation_missing (%d)" % _missing)
	_check(_ultimo_missing == &"jump", "animation_missing con estado jump (%s)" % _ultimo_missing)
	_check(player.current_animation == "anim_jugador_idle",
		"fallback a idle tras estado sin clip (%s)" % player.current_animation)

	# --- Bloque: actor SIN AnimationPlayer ---
	var actor_sin := Node3D.new()
	actor_sin.name = "ActorSinPlayer"
	var antes2 := _missing
	svc.play(actor_sin, &"idle")
	_check(_missing == antes2 + 1, "actor sin AnimationPlayer emite animation_missing (%d)" % _missing)

	# --- Guardia anti-falso-verde ---
	if not _bloque_visto:
		_fallos += 1
		print("FALLO: bloque obligatorio no ejecutado")
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: checks %d < piso medido %d" % [_checks, CHECKS_MINIMOS])

	print("=== Resumen M48 play: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _on_started(actor: Node, estado: StringName) -> void:
	_started += 1
	_ultimo_started = estado


func _on_missing(actor: Node, estado: StringName) -> void:
	_missing += 1
	_ultimo_missing = estado
