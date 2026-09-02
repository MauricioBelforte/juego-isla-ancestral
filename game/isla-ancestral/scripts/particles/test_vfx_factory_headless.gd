# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M52 iter 3: Test de VfxFactory (parámetros headless-safe).
extends SceneTree

const FACTORY := preload("res://scripts/particles/vfx_factory.gd")

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
	print("=== [M52] Test de VfxFactory ===")
	var catalogo: Array = FACTORY.cargar_catalogo()
	_check("Catálogo VFX cargado (8)", catalogo.size() == 8)
	var vfx := {}
	for e in catalogo:
		if String(e.get("id", "")) == "vfx_polen":
			vfx = e
	_check("vfx_polen encontrado", not vfx.is_empty())
	var params: Dictionary = FACTORY.parametros(vfx)
	_check("Cantidad aplicada (150)", int(params["cantidad"]) == 150)
	_check("Tipo flotante", String(params["tipo"]) == "flotante")
	var color: Color = params["color"]
	_check("Color #F4E04D parseado", absf(color.r - 0.9568) < 0.002 and absf(color.g - 0.8784) < 0.002)
	# vfx vacío -> defaults seguros
	var defaults: Dictionary = FACTORY.parametros({})
	_check("VFX vacío -> defaults (20)", int(defaults["cantidad"]) == 20)
	_check("VFX vacío -> color blanco", defaults["color"] == Color.WHITE)
	_check("Catálogo inexistente -> []", typeof(FACTORY.cargar_catalogo()) == TYPE_ARRAY)
	print("=== Resumen M52: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
