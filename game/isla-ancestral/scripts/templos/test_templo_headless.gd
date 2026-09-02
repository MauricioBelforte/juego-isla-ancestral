# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M26: Test del schema del templo subterráneo (layout data-driven).
extends SceneTree

var _fallos := 0
var _checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M26] Test del schema del templo subterráneo ===")
	var schema = load("res://scripts/templos/templo_schema.gd")
	var templo: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/templos/templo_subterraneo.json"))
	_check("Layout válido (0 problemas)", schema.validar_layout(templo).is_empty())
	# Templo roto: salas sin checkpoint final
	var roto: Dictionary = templo.duplicate(true)
	roto["salas"][3]["checkpoint"] = false
	var errores: Array = schema.validar_layout(roto)
	_check("Detecta ausencia de checkpoint final", errores.has("la sala final debe tener checkpoint"))
	# Puzzle sin receptor
	var roto2: Dictionary = templo.duplicate(true)
	roto2["puzzles"][0]["receptor"] = ""
	var errores2: Array = schema.validar_layout(roto2)
	_check("Detecta puzzle sin receptor", errores2.any(func(e): return String(e).begins_with("puzzle puz_asas sin receptor")))
	# Sala final con salida rota
	var roto3: Dictionary = templo.duplicate(true)
	roto3["salas"][1]["salida_a"] = "sala_inexistente"
	var errores3: Array = schema.validar_layout(roto3)
	_check("Detecta salida inexistente", errores3.any(func(e): return String(e).contains("sala_inexistente")))
	print("=== Resumen M26: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
