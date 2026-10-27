# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-27
#
# M48: Suite headless del validador de animaciones y de la plantilla de import.
#   Godot --headless --path game/isla-ancestral --script res://scripts/animacion/test_validacion_m48.gd
#
# Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
# + _summary() en call_deferred SEPARADO (un aborto de runtime no se lleva el resumen).
# Los class_name nuevos se cargan por preload (no se toca .godot/ en worktree compartido).

extends SceneTree

const VALIDADOR := preload("res://scripts/animacion/validacion/animation_validator.gd")
const DEFAULTS := preload("res://scripts/animacion/validacion/import_animation_defaults.gd")
const LIB_JUGADOR := "res://scripts/animacion/libraries/jugador_lib.tres"

const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F", "G"]
const CHECKS_MINIMOS := 50

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _cerrado: bool = false


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _summary() -> void:
	if _cerrado:
		return
	_cerrado = true
	for b in BLOQUES:
		if not _vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M48-validacion: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _tiene(lineas: Array[String], prefijo: String) -> bool:
	for l in lineas:
		if l.begins_with(prefijo):
			return true
	return false


func _clip(nombre: String, largo: float, categoria_fps: float = 30.0) -> Animation:
	var a: Animation = Animation.new()
	a.resource_name = nombre
	a.length = largo
	a.step = 1.0 / categoria_fps
	var t: int = a.add_track(Animation.TYPE_VALUE)
	a.track_set_path(t, NodePath("ModeloVoxel:position:y"))
	a.track_insert_key(t, 0.0, 0.0)
	a.track_insert_key(t, largo, 0.02)
	return a


func _run() -> void:
	var v = VALIDADOR.new()
	var d = DEFAULTS.new()

	# ---------------- A. Naming (E1 / E5) y clasificacion por accion ----------------
	var ok: Animation = _clip("anim_jugador_minar", 1.2)
	var malo: Animation = _clip("Minar", 1.2)
	var sin_prefijo: Animation = _clip("anim_minar", 1.2)
	var solo_nv: bool = true
	for l in v.validar_clip(ok, "accion"):
		if VALIDADOR.es_error(l) or VALIDADOR.es_aviso(l):
			solo_nv = false
	_check(v.nombre_valido("anim_jugador_minar"), "A1 nombre canonico aceptado")
	_check(not v.nombre_valido("Minar"), "A2 sin prefijo anim_ rechazado")
	_check(not v.nombre_valido("anim_minar"), "A3 falta <accion> rechazado")
	_check(solo_nv, "A4 clip canonico sin hallazgos E/A (solo NV1 declarado)")
	_check(_tiene(v.validar_clip(malo, "accion"), "E1"), "A5 E1 en nombre invalido")
	_check(_tiene(v.validar_clip(sin_prefijo, "accion"), "E1"), "A6 E1 en nombre incompleto")
	_check(_tiene(v.validar_clip(ok, "accion", "", "anim_jugador_otro"), "E5"), "A7 E5 clave != resource_name")
	_check(VALIDADOR.categoria_de("anim_jugador_minar") == "accion", "A8 categoria por accion = accion")
	_check(VALIDADOR.categoria_de("anim_jugador_idle") == "locomocion", "A9 categoria por accion = locomocion")
	_check(VALIDADOR.categoria_de("anim_jugador_zzz") == "", "A10 accion desconocida = vacio")
	_fin("A")

	# ---------------- B. Duracion (A1 / E3) y clip vacio (E4) ----------------
	var largo: Animation = _clip("anim_jugador_correr", 2.0)
	_check(_tiene(v.validar_clip(largo, "locomocion"), "A1"), "B1 A1 al exceder tope de locomocion (1.6)")
	_check(not _tiene(v.validar_clip(_clip("anim_jugador_correr", 1.5), "locomocion"), "A1"), "B2 dentro del tope no dispara A1")
	var cero: Animation = _clip("anim_jugador_correr", 0.0)
	_check(_tiene(v.validar_clip(cero, "locomocion"), "E3"), "B3 E3 con duracion 0 (length medido %s)" % str(cero.length))
	var vacio: Animation = Animation.new()
	vacio.resource_name = "anim_jugador_idle"
	vacio.length = 1.0
	_check(_tiene(v.validar_clip(vacio, "locomocion"), "E4"), "B4 E4 con clip sin tracks")
	_check(_tiene(v.validar_clip(ok, "inexistente"), "E2"), "B5 E2 con categoria desconocida")
	_fin("B")

	# ---------------- C. Grilla de fps (A2) y redundancia (A4) ----------------
	var en_grilla: Animation = Animation.new()
	en_grilla.resource_name = "anim_jugador_idle"
	en_grilla.length = 1.0
	var tg: int = en_grilla.add_track(Animation.TYPE_VALUE)
	en_grilla.track_set_path(tg, NodePath("ModeloVoxel:position:y"))
	en_grilla.track_insert_key(tg, 0.0, 0.0)
	en_grilla.track_insert_key(tg, 0.5, 0.02)
	en_grilla.track_insert_key(tg, 1.0, 0.0)
	_check(not _tiene(v.validar_clip(en_grilla, "locomocion"), "A2"), "C1 keys en grilla 30 fps sin A2")
	var fuera: Animation = Animation.new()
	fuera.resource_name = "anim_jugador_idle"
	fuera.length = 1.0
	var tf: int = fuera.add_track(Animation.TYPE_VALUE)
	fuera.track_set_path(tf, NodePath("ModeloVoxel:position:y"))
	fuera.track_insert_key(tf, 0.0, 0.0)
	fuera.track_insert_key(tf, 0.25, 0.02)
	fuera.track_insert_key(tf, 1.0, 0.0)
	_check(_tiene(v.validar_clip(fuera, "locomocion"), "A2"), "C2 key en 0.25 s (7.5 frames) dispara A2")
	_check(not _tiene(v.validar_clip(fuera, "ui"), "A2"), "C3 el mismo key SI cae en grilla de 60 fps")
	var redundante: Animation = Animation.new()
	redundante.resource_name = "anim_jugador_idle"
	redundante.length = 1.0
	var tr: int = redundante.add_track(Animation.TYPE_VALUE)
	redundante.track_set_path(tr, NodePath("ModeloVoxel:position:y"))
	redundante.track_insert_key(tr, 0.0, 0.0)
	redundante.track_insert_key(tr, 0.5, 0.0)
	redundante.track_insert_key(tr, 1.0, 0.0)
	_check(_tiene(v.validar_clip(redundante, "locomocion"), "A4"), "C4 keys con mismo valor disparan A4")
	_fin("C")

	# ---------------- D. Libreria REAL del jugador (medicion, no supuesto) ----------------
	var lib: Resource = load(LIB_JUGADOR)
	_check(lib != null and lib is AnimationLibrary, "D1 jugador_lib.tres carga como AnimationLibrary")
	if lib is AnimationLibrary:
		var inf: Dictionary = v.validar_libreria(lib, "")
		var errs: Array = inf["errores"]
		var avis: Array = inf["avisos"]
		var nvs: Array = inf["no_verificable"]
		_check(int(inf["clips"]) == 3, "D2 la libreria tiene 3 clips (medido %d)" % int(inf["clips"]))
		_check(errs.is_empty(), "D3 0 errores de contrato en la libreria real (medido %d)" % errs.size())
		_check(avis.size() == 2, "D4 2 avisos justificables (medido %d)" % avis.size())
		var hay_a1: bool = false
		var hay_a2: bool = false
		for a in avis:
			var s: String = str(a)
			if s.begins_with("A1") and s.contains("idle"):
				hay_a1 = true
			if s.begins_with("A2") and s.contains("run"):
				hay_a2 = true
		_check(hay_a1, "D5 A1 sobre anim_jugador_idle (2.0 s > 1.6 s)")
		_check(hay_a2, "D6 A2 sobre anim_jugador_run (key en 0.25 s)")
		_check(nvs.size() == 5, "D7 5 no-verificables declarados (3 NV1 + NV2 + NV3), medido %d" % nvs.size())
	_fin("D")

	# ---------------- E. Plantilla de import (loop por sufijo, fps, remapeo, subset) ----------------
	var clip_loop: Animation = Animation.new()
	clip_loop.resource_name = "anim_jugador_idle_loop"
	clip_loop.length = 1.0
	clip_loop.step = 0.1
	clip_loop.loop_mode = Animation.LOOP_NONE
	var th: int = clip_loop.add_track(Animation.TYPE_POSITION_3D)
	clip_loop.track_set_path(th, NodePath("Skeleton3D:mixamorig_Hips"))
	clip_loop.track_insert_key(th, 0.0, Vector3.ZERO)
	clip_loop.track_insert_key(th, 1.0, Vector3(0.0, 1.0, 0.0))
	var res: Dictionary = d.aplicar(clip_loop, "locomocion", "anim_jugador_idle_loop")
	_check(is_equal_approx(clip_loop.step, 1.0 / 30.0), "E1 step normalizado a 30 fps")
	_check(clip_loop.loop_mode == Animation.LOOP_LINEAR, "E2 sufijo _loop -> LOOP_LINEAR")
	_check(str(clip_loop.track_get_path(0)) == "Skeleton3D:Hips", "E3 prefijo de vendor removido del hueso")
	var cambios: Array = res["cambios"]
	_check(cambios.size() >= 3, "E4 el informe declara los cambios aplicados (%d)" % cambios.size())
	var clip_oneshot: Animation = Animation.new()
	clip_oneshot.resource_name = "anim_jugador_minar"
	clip_oneshot.length = 1.0
	clip_oneshot.loop_mode = Animation.LOOP_LINEAR
	var res2: Dictionary = d.aplicar(clip_oneshot, "accion", "anim_jugador_minar")
	_check(clip_oneshot.loop_mode == Animation.LOOP_NONE, "E5 sin sufijo _loop -> LOOP_NONE")
	_check(not bool(res2["loop"]), "E6 el informe dice loop=false")
	_check(d.debe_loopear("anim_jugador_idle_loop"), "E7 debe_loopear por sufijo")
	_check(not d.debe_loopear("anim_jugador_idle"), "E8 sin sufijo no loopea")
	_check(d.id_sin_sufijo("anim_jugador_idle_loop") == "anim_jugador_idle", "E9 id sin sufijo")
	_check(_tiene(d.validar_subset("humanoide", 41), "A3"), "E10 subset humanoide (40) excedido")
	_check(d.validar_subset("ave", 22).is_empty(), "E11 subset ave (22) respetado")
	_check(_tiene(d.validar_subset("robot", 3), "E9"), "E12 familia desconocida -> E9")
	_check(d.no_verificable().size() == 3, "E13 se declaran 3 no-verificables de import")
	_check(is_equal_approx(d.fps_de("ui"), 60.0), "E14 UI = 60 fps")
	_fin("E")

	# ---------------- F. Presupuesto de actor (E6 / E7 / E8) ----------------
	var sobre: Array[String] = v.validar_actor({
		"actores_plenos": 61,
		"blend_nodos": 5,
		"estados": ["idle", "walk", "volar"],
		"clips": ["idle", "walk"],
	})
	_check(_tiene(sobre, "E6"), "F1 E6 con 61 actores plenos")
	_check(_tiene(sobre, "E7"), "F2 E7 con 5 nodos de blend")
	_check(_tiene(sobre, "E8"), "F3 E8 con un estado sin clip")
	var dentro: Array[String] = v.validar_actor({
		"actores_plenos": 60,
		"blend_nodos": 4,
		"estados": ["idle", "walk"],
		"clips": ["idle", "walk"],
	})
	_check(dentro.is_empty(), "F4 en el limite exacto no hay hallazgos")
	_fin("F")

	# ---------------- G. Agregacion por severidad ----------------
	var lib_mixta: AnimationLibrary = AnimationLibrary.new()
	lib_mixta.add_animation("anim_jugador_idle", _clip("anim_jugador_idle", 1.0))
	lib_mixta.add_animation("Malo", _clip("Malo", 1.0))
	var inf_m: Dictionary = v.validar_libreria(lib_mixta, "")
	_check(int(inf_m["clips"]) == 2, "G1 dos clips contados")
	var e_m: Array = inf_m["errores"]
	var a_m: Array = inf_m["avisos"]
	_check(e_m.size() == 2, "G2 dos errores en el clip 'Malo' (E1 nombre + E2 categoria), medido %d" % e_m.size())
	_check(a_m.is_empty(), "G3 los NV de la libreria NO se cuentan como aviso")
	var nv_m: Array = inf_m["no_verificable"]
	_check(nv_m.size() == 3, "G4 NV agregados: 1 clip sin hueso + NV2 + NV3 = 3, medido %d" % nv_m.size())
	_check(VALIDADOR.es_error("E1 x") and not VALIDADOR.es_error("A1 x"), "G5 clasificador de severidad")
	_check(VALIDADOR.blend_de("accion") == 200 and VALIDADOR.blend_de("fauna") == 300, "G6 blend por categoria de tabla 3.1")
	_fin("G")

	_summary()
