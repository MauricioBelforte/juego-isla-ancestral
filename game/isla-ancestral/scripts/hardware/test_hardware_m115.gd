# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M115: Hardware — Test headless
# Valida: HardwareManager (perfiles, requisitos por plataforma).
# Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M115] Test de Hardware ===")
	_test_config()
	_test_perfiles()
	_test_plataformas()
	_test_calidad()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: hardware_profiles.json ---")
	var hm := root.get_node_or_null("HardwareManager")
	if hm == null:
		_check("HardwareManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("HardwareManager autoload presente", true)
	_check("3 perfiles", hm.perfiles_ids().size() == 3, "size=%d" % hm.perfiles_ids().size())
	_check("3 plataformas", hm.config.get("plataformas", {}).size() == 3, "size=%d" % hm.config.get("plataformas", {}).size())

func _test_perfiles() -> void:
	print("--- Perfiles de hardware ---")
	var hm := root.get_node_or_null("HardwareManager")
	var baja = hm.perfil("baja")
	_check("perfil baja existe", not baja.is_empty() and baja.get("fps_objetivo", 0) == 30)
	var alta = hm.perfil("alta")
	_check("perfil alta existe", not alta.is_empty() and String(alta.get("gpu", "")) == "RTX3060/RX6700")
	_check("perfil inexistente -> {}", hm.perfil("no_existe").is_empty())

func _test_plataformas() -> void:
	print("--- Requisitos por plataforma ---")
	var hm := root.get_node_or_null("HardwareManager")
	_check("windows mínimo baja", hm.perfil_minimo("windows") == "baja")
	_check("windows recomendado media", hm.perfil_recomendado("windows") == "media")
	_check("macos mínimo baja", hm.perfil_minimo("macos") == "baja")
	_check("plataforma inexistente -> ''", hm.perfil_minimo("nintendo") == "")

func _test_calidad() -> void:
	print("--- Calidad por perfil actual (M90) ---")
	var hm := root.get_node_or_null("HardwareManager")
	hm.set_perfil_actual("baja")
	_check("render scale baja 0.75", hm.render_scale() == 0.75, "val=%s" % str(hm.render_scale()))
	_check("AA baja FXAA", hm.antialiasing() == "FXAA")
	_check("texture baja", hm.texture_quality() == "baja")
	hm.set_perfil_actual("alta")
	_check("render scale alta 1.25", hm.render_scale() == 1.25, "val=%s" % str(hm.render_scale()))
	_check("AA alta MSAA4", hm.antialiasing() == "MSAA4")
	_check("perfil inexistente no cambia", hm.set_perfil_actual("ultra") == false)
	_check("perfil_actual sigue alta", hm.perfil_actual == "alta")

func _summary() -> void:
	print("=== Resumen M115: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M115 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M115 OK — todos los checks pasaron")
		quit(0)