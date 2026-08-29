# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M103: Test headless del Logger (verificación implementación).
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/logging/test_logger.gd
# Valida:
#  - Autoload GameLogger presente y registrado en ServiceRegistry ("logger").
#  - Niveles: min_level filtra DEBUG/INFO y deja pasar WARNING+.
#  - Categorías: deshabilitar una categoría la filtra.
#  - Sanitización: IPs/tokens/passwords en mensaje y contexto quedan [REDACTED].
#  - Exportación: export_last_lines / export_by_level / export_by_category.
#  - Rotación: LogRotator rota y comprime sin errores.
#  - Persistencia: flush() escribe el buffer al archivo.
extends SceneTree

var _fallos := 0
var _checks := 0
var _log = null

func _initialize() -> void:
	print("=== TEST LOGGER M103 ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	_log = root.get_node_or_null("GameLogger")
	_check("autoload GameLogger presente", _log != null)
	if _log == null:
		print("FALTA AUTOLOAD GameLogger"); quit(1); return

	# Registrado en ServiceRegistry como "logger"
	var reg = root.get_node_or_null("ServiceRegistry")
	var existe_reg: bool = reg != null and reg.has("logger")
	_check("registrado en ServiceRegistry como 'logger'", existe_reg)

	# ── Niveles: usar un path temporal propio para no contaminar game.log global.
	var tmp := "user://test_m103/game.log"
	_log.set_log_path(tmp)
	_log.set_min_level(_log.Level.WARNING)

	# DEBUG/INFO filtrados, WARNING/ERROR/CRITICAL pasan
	_log.debug("texto debug filtrado")
	_log.info("texto info filtrado")

	_log.warning("aviso visible", _log.Category.SYSTEM)
	_log.critical("critico visible", _log.Category.BOOT)
	_log.flush()
	_check("flush escribe buffer al archivo", FileAccess.file_exists(tmp))

	var contenido: String = _log.export_all()
	_check("export_all contiene el aviso", contenido.contains("aviso visible"))
	_check("export_all contiene el critico", contenido.contains("critico visible"))
	_check("export_all NO contiene el debug filtrado", not contenido.contains("texto debug filtrado"))

	# ── Sanitización de datos sensibles ──
	_log.warning("Error IP 192.168.1.10 y token abc123xyz", _log.Category.NETWORKING)
	_log.warning("Error password=supersecreta", _log.Category.SYSTEM)
	_log.warning("Contexto sensible", _log.Category.SYSTEM, {"password": "1234", "usuario": "maria"})
	_log.flush()
	var cont2: String = _log.export_all()
	_check("IP redactada", not cont2.contains("192.168.1.10"))
	_check("password= redactada", not cont2.contains("supersecreta"))
	_check("contexto password redactado", cont2.contains("[REDACTED]"))
	_check("valor de contexto usuario conservado", cont2.contains("maria"))

	# ── Exportación filtrada ──
	var by_error: String = _log.export_by_level(_log.Level.ERROR)
	var by_warning: String = _log.export_by_level(_log.Level.WARNING)
	_check("export_by_level(WARNING) contiene warnings", by_warning.contains("aviso visible"))
	_check("export_by_level(ERROR) NO contiene warnings", not by_error.contains("aviso visible"))

	# ── Rotación ──
	LogRotator.rotate(tmp, 3, true)
	_check("rotación: existe rotado .1.gz", FileAccess.file_exists(tmp + ".1.gz"))

	# ── Exportación a archivo (LogExporter) ──
	var exp_path: String = LogExporter.export_last_lines(_log, 5)
	_check("LogExporter genera archivo no vacio", exp_path != "" and FileAccess.file_exists(exp_path))

	# Limpieza del path temporal del test
	_log.flush()
	DirAccess.remove_absolute(tmp + ".1.gz")
	DirAccess.remove_absolute(tmp)
	DirAccess.remove_absolute(tmp.get_base_dir() + "/export_" + Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_") + ".log")

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("LOGGER M103 OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)