# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M122: Crash Reporting — Test headless
# Valida: CrashReporter (reportar_crash → dump JSON, enviar_dump con
# reintentos, dumps_pendientes). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M122] Test de Crash Reporting ===")
	_test_reporter()
	_test_envio()
	_test_dumps()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_reporter() -> void:
	print("--- CrashReporter: dump JSON ---")
	var cr := root.get_node_or_null("CrashReporter")
	if cr == null:
		_check("CrashReporter autoload presente", false)
		_summary()
		quit(1)
		return
	_check("CrashReporter autoload presente", true)
	var ruta = cr.reportar_crash("null_error", "objeto null", ["func_a:10", "func_b:20"])
	_check("dump escrito", ruta != "" and FileAccess.file_exists(ruta))
	if FileAccess.file_exists(ruta):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
		_check("dump JSON válido", typeof(parsed) == TYPE_DICTIONARY)
		_check("dump con stack", (parsed as Dictionary).get("stack", []).size() == 2)
		_check("dump con sesión", String((parsed as Dictionary).get("session", "")) != "")

func _test_envio() -> void:
	print("--- CrashReporter: envío con reintentos ---")
	var cr := root.get_node_or_null("CrashReporter")
	var ruta = cr.reportar_crash("script_error", "parse", ["a:1"])
	_check("envío 1er intento ok", cr.enviar_dump(ruta) == true)
	_check("envío 2do intento ok", cr.enviar_dump(ruta) == true)
	_check("envío 3er intento ok", cr.enviar_dump(ruta) == true)
	_check("envío 4to intento falla (máx 3)", cr.enviar_dump(ruta) == false)
	_check("envío ruta inexistente falla", cr.enviar_dump("user://no_existe.json") == false)

func _test_dumps() -> void:
	print("--- CrashReporter: dumps pendientes ---")
	var cr := root.get_node_or_null("CrashReporter")
	var cantidad: int = cr.cantidad_dumps()
	_check("dumps en disco (>=2)", cantidad >= 2, "count=%d" % cantidad)
	var pendientes = cr.dumps_pendientes()
	_check("dumps_pendientes lista JSON", pendientes.size() >= 2)

func _summary() -> void:
	print("=== Resumen M122: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M122 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M122 OK — todos los checks pasaron")
		quit(0)