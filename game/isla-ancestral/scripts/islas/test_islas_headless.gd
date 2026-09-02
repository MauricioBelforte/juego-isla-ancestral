# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M27: Test del schema de islas (config data-driven).
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
	print("=== [M27] Test del schema de islas ===")
	var schema = load("res://scripts/islas/islas_schema.gd")
	var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/islas/islas.json"))
	_check("Config de 4 islas válida", schema.validar_islas(config).is_empty())
	_check("La isla Raíz tiene radio 256", float(config["islas"]["RIZ"]["radio"]) == 256.0)
	_check("La isla Aurora tiene 3 biomas", config["islas"]["AUR"]["biomas"].size() == 3)
	# Caso roto: color inválido
	var roto: Dictionary = config.duplicate(true)
	roto["islas"]["COR"]["color_agua"] = "azul"
	var errores: Array = schema.validar_islas(roto)
	_check("Detecta color inválido", errores.any(func(e): return String(e).contains("color_agua")))
	# Caso roto: falta isla
	var roto2: Dictionary = config.duplicate(true)
	roto2["islas"].erase("AUR")
	var errores2: Array = schema.validar_islas(roto2)
	_check("Detecta isla faltante", errores2.any(func(e): return String(e).contains("falta la isla AUR")))
	print("=== Resumen M27: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
