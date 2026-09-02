# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M52: Test del catálogo VFX (VfxSchema).
extends SceneTree

const SCHEMA := preload("res://scripts/particles/vfx_schema.gd")

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
	print("=== [M52] Test del catálogo VFX ===")
	var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/vfx/vfx_catalog.json"))
	_check("Catálogo de 8 VFX válido", SCHEMA.validar_catalogo(config).is_empty())
	# evento único por VFX (los 8 vinculan a eventos conocidos)
	var ids := {}
	for e in config["vfx"]:
		ids[e["evento"]] = true
	_check("8 eventos distintos vinculados", ids.size() == 8)
	# caso roto: tipo inválido
	var roto: Dictionary = config.duplicate(true)
	roto["vfx"][0]["tipo"] = "magia"
	var errores: Array = SCHEMA.validar_catalogo(roto)
	_check("Detecta tipo inválido", errores.any(func(e): return String(e).contains("tipo inválido")))
	# caso roto: cantidad fuera de rango
	var roto2: Dictionary = config.duplicate(true)
	roto2["vfx"][1]["cantidad"] = 9999
	var errores2: Array = SCHEMA.validar_catalogo(roto2)
	_check("Detecta cantidad fuera de rango", errores2.any(func(e): return String(e).contains("cantidad fuera de rango")))
	print("=== Resumen M52: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
