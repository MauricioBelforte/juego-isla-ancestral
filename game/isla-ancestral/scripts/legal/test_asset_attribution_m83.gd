# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M83: Licencias de Software — Test del AssetAttributionGenerator
# Valida el generador de atribución de assets para build output:
#   - generar_compacto / generar_detallado sobre LicenseProfile
#   - contar_requieren_atribucion
#   - guardar_compacto (escribe archivo)
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/legal/test_asset_attribution_m83.gd
# Exit 0 si todo OK, 1 si falla.

extends SceneTree

const _GEN := preload("res://scripts/legal/asset_attribution_generator.gd")
const _LP := preload("res://scripts/licensing/license_profile.gd")

var _checks: int = 0
var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _check(mensaje: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("OK  " + mensaje)
	else:
		_fallos += 1
		print("FAIL " + mensaje)


func _hacer_lp(nombre: String, tipo: String, atrib: bool, src: bool = false) -> LicenseProfile:
	var lp: LicenseProfile = _LP.new()
	lp.dependency_name = nombre
	lp.version = "1.0"
	lp.license_type = tipo
	lp.commercial_use = true
	lp.attribution_required = atrib
	lp.source_offer_required = src
	lp.license_url = "https://spdx.org/licenses/%s" % tipo
	lp.notes = "nota " + nombre
	return lp


func _run() -> void:
	print("=== [M83] Test del AssetAttributionGenerator ===")

	var gen: RefCounted = _GEN.new()

	var con_atrib := _hacer_lp("GLAD", "MIT", true)
	var con_src := _hacer_lp("Box2D", "zlib", false, true)
	var sin_req := _hacer_lp("Zlib", "zlib", false)

	# compacto: incluye solo los con atribucion requerida
	var compacto: String = gen.generar_compacto([con_atrib, con_src, sin_req])
	_check("compacto incluye dep con atrib (GLAD)", compacto.contains("GLAD"))
	_check("compacto NO incluye dep sin req (Zlib)", not compacto.contains("Zlib"))
	_check("compacto muestra tipo de licencia (MIT)", compacto.contains("MIT"))

	# compacto vacio: solo sin requerir
	var solo_sin := [sin_req]
	_check("compacto sin requeridas -> mensaje de vacío", gen.generar_compacto(solo_sin).contains("No hay assets"))

	# detallado: incluye todas
	var detallado: String = gen.generar_detallado([con_atrib, con_src, sin_req])
	_check("detallado incluye GLAD", detallado.contains("GLAD"))
	_check("detallado incluye Box2D", detallado.contains("Box2D"))
	_check("detallado incluye Zlib", detallado.contains("Zlib"))
	_check("detallado muestra uso comercial", detallado.contains("Uso comercial"))
	_check("detallado muestra offer de fuente (Box2D)", detallado.contains("Ofrecer fuente"))

	# contar
	var n: int = gen.contar_requieren_atribucion([con_atrib, con_src, sin_req])
	_check("contar_requieren_atribucion = 2 (GLAD atrib + Box2D src)", n == 2)
	_check("contar sobre lista vacia = 0", gen.contar_requieren_atribucion([]) == 0)

	# guardar compacto (user temp)
	var ruta := "user://_test_m83_atrib.txt"
	var ok: bool = gen.guardar_compacto([con_atrib, con_src, sin_req], ruta)
	_check("guardar_compacto escribe", ok)
	if ok:
		var f := FileAccess.open(ruta, FileAccess.READ)
		var contenido: String = f.get_as_text()
		f.close()
		_check("archivo guardado contiene GLAD", contenido.contains("GLAD"))
		DirAccess.remove_absolute(ruta)

	_fin()


func _fin() -> void:
	print("=== [M83] Resultado: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos == 0:
		print("[M83] OK")
		quit(0)
	else:
		print("[M83] FALLOS: %d" % _fallos)
		quit(1)
