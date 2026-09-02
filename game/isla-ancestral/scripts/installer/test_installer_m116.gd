# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M116: Instalador — Test headless
# Valida: InstaladorConfig (plataformas, pasos, requisitos, soporte).
# Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M116] Test de Instalador ===")
	_test_config()
	_test_plataformas()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: instalador_config.json ---")
	var ic := root.get_node_or_null("InstaladorConfig")
	if ic == null:
		_check("InstaladorConfig autoload presente", false)
		_summary()
		quit(1)
		return
	_check("InstaladorConfig autoload presente", true)
	_check("3 plataformas", ic.plataformas().size() == 3, "size=%d" % ic.plataformas().size())
	_check("5 pasos", ic.pasos().size() == 5, "size=%d" % ic.pasos().size())
	_check("disco_min_mb 4096", ic.requisito("disco_min_mb") == 4096, "val=%d" % ic.requisito("disco_min_mb"))
	_check("ram_min_mb 8192", ic.requisito("ram_min_mb") == 8192)

func _test_plataformas() -> void:
	print("--- Plataformas soportadas ---")
	var ic := root.get_node_or_null("InstaladorConfig")
	_check("windows soportado", ic.soporta_plataforma("windows"))
	_check("macos soportado", ic.soporta_plataforma("macos"))
	_check("linux soportado", ic.soporta_plataforma("linux"))
	_check("nintendo no soportado", not ic.soporta_plataforma("nintendo"))
	_check("playstation no soportado", not ic.soporta_plataforma("playstation"))

func _summary() -> void:
	print("=== Resumen M116: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M116 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M116 OK — todos los checks pasaron")
		quit(0)