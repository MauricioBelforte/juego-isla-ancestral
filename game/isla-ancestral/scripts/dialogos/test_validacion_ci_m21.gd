# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M21 (iter 7): Test headless del gate de validacion de dialogos (lado CI).
# Valida TODOS los JSON de res://data/dialogues/ con DialogGraphValidator y afirma
# que ninguno tiene problemas (espejo de validate_all_dialogues.gd).
# Complementa test_validacion_grafo_m21.gd (que valida grafos rotos en memoria).
#
# Ejecutar: Godot --headless --path game/isla-ancestral \
#           --script res://scripts/dialogos/test_validacion_ci_m21.gd

extends SceneTree

var _fallos: int = 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var validador = load("res://scripts/dialogos/dialog_graph_validator.gd")
	var dir := DirAccess.open("res://data/dialogues/")
	if dir == null:
		_fallos += 1
		print("FALLO: no se pudo abrir res://data/dialogues/")
		print("=== TEST VALIDACION CI M21 (gate carpeta): 1 fallo(s) ===")
		quit(1)
		return
	var archivos := dir.get_files()
	archivos.sort()
	var validados := 0
	for nombre in archivos:
		if not nombre.ends_with(".json"):
			continue
		validados += 1
		var res = validador.validar_archivo("res://data/dialogues/" + nombre, [])
		_check(res.ok, "%s valido (0 problemas)" % nombre)
		if not res.ok:
			for p in res.problemas:
				print("    - " + str(p))
	_check(validados > 0, "se validaron archivos de dialogo en la carpeta")
	print("=== TEST VALIDACION CI M21 (gate carpeta): %d fallo(s) | %d archivo(s) ===" % [_fallos, validados])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)
