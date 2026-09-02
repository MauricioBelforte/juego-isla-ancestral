# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M103: Logging — Test headless de verificación del núcleo existente
# (logger.gd implementado por ox-alpha). Valida la API pública y la
# persistencia. Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M103] Test de Logging (verificación núcleo) ===")
	var gl := root.get_node_or_null("GameLogger")
	if gl == null:
		_check("GameLogger autoload presente", false)
		_summary()
		quit(1)
		return
	_check("GameLogger autoload presente", true)
	_check("tiene método info", gl.has_method("info"))
	_check("tiene método debug", gl.has_method("debug"))
	_check("tiene método warning", gl.has_method("warning"))
	_check("tiene método error", gl.has_method("error"))
	_check("tiene método critical", gl.has_method("critical"))
	_check("tiene export_all", gl.has_method("export_all"))
	_check("tiene export_last_lines", gl.has_method("export_last_lines"))
	_check("tiene set_min_level", gl.has_method("set_min_level"))
	_check("tiene get_log_file_path", gl.has_method("get_log_file_path"))
	# Probar escritura
	gl.info("test_info_m103")
	gl.warning("test_warn_m103")
	var ruta: String = gl.get_log_file_path()
	_check("ruta de log definida", ruta != "")
	_check("archivo de log existe", FileAccess.file_exists(ruta))
	if FileAccess.file_exists(ruta):
		var contenido := FileAccess.get_file_as_string(ruta)
		_check("contenido tiene test_info_m103", contenido.contains("test_info_m103"))
	_check("export_all devuelve texto", gl.export_all().length() > 0)
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _test_export() -> void:
	print("--- Exportación por nivel/categoría ---")
	var gl := root.get_node_or_null("GameLogger")
	gl.info("export_test_info")
	var all := gl.export_all()
	_check("export_all contiene info", all.contains("export_test_info"))
	var ultimas := gl.export_last_lines(3)
	_check("export_last_lines no vacío", ultimas.length() > 0)
	var path: String = gl.get_log_file_path()
	_check("log file path no vacío", path != "")

func _test_rotation() -> void:
	print("--- Rotación configurada ---")
	var gl := root.get_node_or_null("GameLogger")
	_check("tiene flush", gl.has_method("flush"))
	_check("tiene set_min_level", gl.has_method("set_min_level"))
	_check("tiene set_category_enabled", gl.has_method("set_category_enabled"))
	_check("tiene export_by_level", gl.has_method("export_by_level"))
	_check("tiene export_by_category", gl.has_method("export_by_category"))
	_check("tiene export_by_date", gl.has_method("export_by_date"))
	_check("tiene get_log_file_path", gl.has_method("get_log_file_path"))
	_check("tiene set_log_path", gl.has_method("set_log_path"))

func _summary() -> void:
	print("=== Resumen M103: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M103 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M103 OK — todos los checks pasaron")
		quit(0)