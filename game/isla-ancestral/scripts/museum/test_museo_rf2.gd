# M37: test del slice RF2 (agnés-3-flash, 2026-10-08) — escena museum.tscn + posicionamiento.
# Verifica: la escena carga + instanciado → estructura (salas + vitrinas + curador) +
# placiar_en_mundo deja la coordenada XZ correcta (snapping al terreno si el locator está listo).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/museum/test_museo_rf2.gd
extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	# (a) La escena del museo carga.
	var escena: Variant = load("res://scenes/museo/museum.tscn")
	_check(escena != null, "museum.tscn carga (escena válida)")
	if escena == null:
		_fin()
		return
	# (b) Instanciar + añadir al árbol → _ready construye salas + vitrinas + curador.
	var museo = escena.instantiate()  # Variant (duck-typed: el componente Museum.gd)
	root.add_child(museo)
	await process_frame
	_check(museo.has_method("get_room"), "instancia tiene el componente Museum")
	_check(museo.call("get_room", "flora") != null, "instanciado tiene sala (estructura RF1)")
	_check(museo.call("get_curator") != null, "instanciado tiene curador (museo visitable)")
	_check(museo.call("get_vitrina", "flora", "baya_roja") != null, "vitrinas instanciadas en runtime")
	# (c) Placiar en el mundo deja la coordenada XZ correcta (RF2).
	var plac = museo.call("placiar_en_mundo")
	_check(is_equal_approx(museo.global_position.x, 3900.0), "museo X = MUSEO_POS.x (%f)" % museo.global_position.x)
	_check(is_equal_approx(museo.global_position.z, 3830.0), "museo Z = MUSEO_POS.z (%f)" % museo.global_position.z)
	# El snapping al terreno (get_height+1) solo aplica si el locator está listo; si no,
	# fallback a y base. Verifico que Y es un valor sensato (>= 0) y no un crash.
	_check(museo.global_position.y >= 0.0, "museo Y sensato tras placiar_en_mundo (%f)" % museo.global_position.y)
	print("[M37 RF2] placiar_en_mundo -> posicionado_sobre_terreno=%s, pos=%s" % [str(plac), str(museo.global_position)])
	# (d) El placer helper instancia + posiciona correctamente.
	var helper = load("res://scripts/museum/museum_placer.gd").new()
	var museo2 = helper.crear_en_mundo(root)
	_check(museo2 != null, "MuseumPlacer.crear_en_mundo instancia el museo")
	if museo2 != null:
		_check(museo2.has_method("get_room") and museo2.call("get_room", "peces") != null, "el museo colocado tiene salas (peces)")
		museo2.queue_free()
	museo.queue_free()
	_fin()

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _fin() -> void:
	print("=== TEST M37 RF2: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)
