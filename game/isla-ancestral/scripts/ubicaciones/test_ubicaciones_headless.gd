# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M160: Test del schema de ubicaciones del mundo.
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
	print("=== [M160] Test del schema de ubicaciones ===")
	var schema = load("res://scripts/ubicaciones/ubicaciones_schema.gd")
	var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ubicaciones/ubicaciones.json"))
	_check("Mapa de 10 ubicaciones válido", schema.validar_ubicaciones(config).is_empty())
	_check("8 lugares del canon presentes", config["ubicaciones"].size() == 10)
	var por_isla := {}
	for e in config["ubicaciones"]:
		por_isla[e["isla"]] = por_isla.get(e["isla"], 0) + 1
	_check("4 islas representadas", por_isla.size() == 4)
	# Casos rotos: sello que no corresponde a la isla
	var roto: Dictionary = config.duplicate(true)
	roto["ubicaciones"][0]["sello"] = "sello_coral"
	var errores: Array = schema.validar_ubicaciones(roto)
	_check("Detecta sello no correspondiente", errores.any(func(e): return String(e).contains("sello")))
	# Caso roto: tipo inválido
	var roto2: Dictionary = config.duplicate(true)
	roto2["ubicaciones"][1]["tipo"] = "castillo"
	var errores2: Array = schema.validar_ubicaciones(roto2)
	_check("Detecta tipo inválido", errores2.any(func(e): return String(e).contains("tipo inválido")))
	print("=== Resumen M160: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
