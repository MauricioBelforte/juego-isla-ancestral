# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M110: Debug Menu — Test headless
# Valida: DebugMenu (config data-driven, pestañas, comandos, flags, métricas).
# Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M110] Test de Debug Menu ===")
	_test_config()
	_test_comandos()
	_test_metricas()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: debug_menu_config.json ---")
	var dm := root.get_node_or_null("DebugMenu")
	if dm == null:
		_check("DebugMenu autoload presente", false)
		_summary()
		quit(1)
		return
	_check("DebugMenu autoload presente", true)
	_check("3 pestañas", dm.pestanas().size() == 3, "size=%d" % dm.pestanas().size())
	_check("12 comandos", dm.config.get("comandos", {}).size() == 12, "size=%d" % dm.config.get("comandos", {}).size())

func _test_comandos() -> void:
	print("--- Comandos: teleport/spawn/time/flags/exportar ---")
	var dm := root.get_node_or_null("DebugMenu")
	var teleport = dm.ejecutar_comando("teleport_casa")
	_check("teleport_casa ok", teleport.get("ok", false) == true)
	var spawn = dm.ejecutar_comando("spawn_madera")
	_check("spawn_madera ok", spawn.get("ok", false) == true and String(spawn.get("resultado", "")).contains("wood"))
	var hora = dm.ejecutar_comando("cambiar_hora")
	_check("cambiar_hora ok", hora.get("ok", false) == true and String(hora.get("resultado", "")).contains("12"))
	var flag = dm.ejecutar_comando("toggle_debug")
	_check("toggle_debug ok", flag.get("ok", false) == true)
	var exportar = dm.ejecutar_comando("exportar_diagnostico")
	_check("exportar ok", exportar.get("ok", false) == true)
	var inexistente = dm.ejecutar_comando("no_existe")
	_check("comando inexistente -> !ok", inexistente.get("ok", false) == false)
	_check("contador = 5 (inexistente no cuenta)", dm.comandos_ejecutados() == 5, "count=%d" % dm.comandos_ejecutados())

func _test_metricas() -> void:
	print("--- Métricas de sistema ---")
	var dm := root.get_node_or_null("DebugMenu")
	var m = dm.metricas_sistema()
	_check("fps > 0", m.get("fps", 0) > 0, "fps=%s" % str(m.get("fps", 0)))
	_check("objetos >= 0", m.get("objetos", -1) >= 0)
	_check("memoria definida", m.has("memoria_mb"))

func _summary() -> void:
	print("=== Resumen M110: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M110 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M110 OK — todos los checks pasaron")
		quit(0)