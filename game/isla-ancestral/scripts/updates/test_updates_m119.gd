# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M119: Actualizaciones — Test headless
# Valida: UpdateManager (carga versions.json, canales, comparación de
# versiones, hay_actualizacion, set_canal, política). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M119] Test de Actualizaciones ===")
	_test_config()
	_test_versiones()
	_test_canales()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: versions.json ---")
	var um := root.get_node_or_null("UpdateManager")
	if um == null:
		_check("UpdateManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("UpdateManager autoload presente", true)
	_check("3 canales", um.config.get("canales", {}).size() == 3, "size=%d" % um.config.get("canales", {}).size())
	_check("canal inicial estable", um.canal_actual == "estable")
	_check("versión juego 1.0.0", um.version_juego == "1.0.0", "v=%s" % um.version_juego)

func _test_versiones() -> void:
	print("--- Comparación de versiones ---")
	var um := root.get_node_or_null("UpdateManager")
	_check("1.0.0 == 1.0.0", um.comparar_versiones("1.0.0", "1.0.0") == 0)
	_check("1.1.0 > 1.0.0", um.comparar_versiones("1.1.0", "1.0.0") == 1)
	_check("1.0.1 > 1.0.0", um.comparar_versiones("1.0.1", "1.0.0") == 1)
	_check("1.0.0 < 2.0.0", um.comparar_versiones("1.0.0", "2.0.0") == -1)
	_check("con sufijo -beta", um.comparar_versiones("1.1.0-beta", "1.1.0") == 0)

func _test_canales() -> void:
	print("--- Canales: actualización y cambio ---")
	var um := root.get_node_or_null("UpdateManager")
	# En estable la versión local es 1.0.0 y la remota también -> no update
	_check("estable sin actualización", um.hay_actualizacion("1.0.0") == false)
	# Cambiar a dev: remota 1.1.0-dev.3 > local 1.0.0 -> update
	_check("set_canal dev ok", um.set_canal("dev"))
	_check("hay actualización en dev", um.hay_actualizacion("1.0.0"))
	_check("set_canal inexistente falla", um.set_canal("no_existe") == false)
	_check("versión remota dev", um.version_remota() == "1.1.0-dev.3", "v=%s" % um.version_remota())
	_check("política con aviso previo", um.politica().get("aviso_previa", false) == true)

func _summary() -> void:
	print("=== Resumen M119: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M119 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M119 OK — todos los checks pasaron")
		quit(0)