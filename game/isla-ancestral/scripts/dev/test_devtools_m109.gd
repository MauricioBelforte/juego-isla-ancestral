# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M109: Herramientas Internas — Test headless
# Valida: DevTools (carga dev_tools.json, flags, atajos de comando,
# toggle, contador de ejecuciones). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M109] Test de Herramientas Internas ===")
	_test_config()
	_test_flags()
	_test_atajos()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: dev_tools.json ---")
	var dt := root.get_node_or_null("DevTools")
	if dt == null:
		_check("DevTools autoload presente", false)
		_summary()
		quit(1)
		return
	_check("DevTools autoload presente", true)
	_check("4 atajos", dt.config.get("atajos", {}).size() == 4, "size=%d" % dt.config.get("atajos", {}).size())
	_check("3 flags", dt.config.get("flags", {}).size() == 3, "size=%d" % dt.config.get("flags", {}).size())

func _test_flags() -> void:
	print("--- Flags: defaults y toggle ---")
	var dt := root.get_node_or_null("DevTools")
	_check("mostrar_ui default true", dt.flag("mostrar_ui") == true)
	_check("mostrar_debug default false", dt.flag("mostrar_debug") == false)
	var nuevo = dt.toggle_flag("mostrar_debug")
	_check("toggle mostrar_debug -> true", nuevo == true and dt.flag("mostrar_debug") == true)
	dt.set_flag("mostrar_debug", false)
	_check("set_flag mostrar_debug -> false", dt.flag("mostrar_debug") == false)
	_check("flag inexistente -> false", dt.flag("no_existe") == false)

func _test_atajos() -> void:
	print("--- Atajos: teleport/spawn/toggle ---")
	var dt := root.get_node_or_null("DevTools")
	var teleport = dt.ejecutar_atajo("teleport_casa")
	_check("teleport_casa ok", teleport.get("ok", false) == true and String(teleport.get("comando", "")) == "teleport")
	var spawn = dt.ejecutar_atajo("spawn_madera")
	_check("spawn_madera ok", spawn.get("ok", false) == true and String(spawn.get("comando", "")) == "spawn")
	var toggle = dt.ejecutar_atajo("toggle_debug")
	_check("toggle_debug ok", toggle.get("ok", false) == true and String(toggle.get("comando", "")) == "toggle_flag")
	_check("toggle_debug cambió flag", dt.flag("mostrar_debug") == true)
	var inexistente = dt.ejecutar_atajo("no_existe")
	_check("atajo inexistente -> !ok", inexistente.get("ok", false) == false)
	_check("contador de ejecuciones = 3", dt.comandos_ejecutados() == 3, "count=%d" % dt.comandos_ejecutados())

func _summary() -> void:
	print("=== Resumen M109: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M109 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M109 OK — todos los checks pasaron")
		quit(0)