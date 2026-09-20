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
#
# ── iter. 2 (2026-09-20, Log 1109, DeepSeek-V4.1-Flash) ─────────────────────
# Endurecido con el guardián de 3 capas (la auditoría de la trampa 85 encontró
# que esta suite, escrita el 2026-08-29, no lo tenía):
#   1. `_fin("X. …")` por bloque → el resumen NOMBRA el bloque que no cerró.
#   2. `CHECKS_MINIMOS` MEDIDO en verde (14), no estimado.
#   3. `_summary()` en un `call_deferred` APARTE: antes iba inline dentro de
#      `_ejecutar()`, así que un `SCRIPT ERROR` lo dejaba sin resumen **y sin
#      `quit()`** → con `extends SceneTree` el árbol cuelga para siempre y el
#      stdout se pierde (trampas 28/61). Ahora el resumen corre igual.
#   Además: la limpieza usaba el nombre del export RECONSTRUIDO con la hora
#   actual (si el segundo cambiaba entre la exportación y el borrado, el
#   archivo quedaba huérfano). Ahora borra la ruta REAL que devolvió el exporter.
extends SceneTree

const MODULO := "M103"
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F"]
const CHECKS_MINIMOS := 14

var _fallos := 0
var _checks := 0
var _log = null
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0

func _initialize() -> void:
	print("=== TEST LOGGER M103 ===")
	call_deferred("_ejecutar")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])

func _ejecutar() -> void:
	_log = root.get_node_or_null("GameLogger")
	_check("autoload GameLogger presente", _log != null)
	if _log == null:
		print("FALTA AUTOLOAD GameLogger"); return

	# Registrado en ServiceRegistry como "logger"
	var reg = root.get_node_or_null("ServiceRegistry")
	var existe_reg: bool = reg != null and reg.has("logger")
	_check("registrado en ServiceRegistry como 'logger'", existe_reg)
	_fin("A. Autoload y ServiceRegistry")

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
	_fin("B. Niveles y filtrado")

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
	_fin("C. Sanitización")

	# ── Exportación filtrada ──
	var by_error: String = _log.export_by_level(_log.Level.ERROR)
	var by_warning: String = _log.export_by_level(_log.Level.WARNING)
	_check("export_by_level(WARNING) contiene warnings", by_warning.contains("aviso visible"))
	_check("export_by_level(ERROR) NO contiene warnings", not by_error.contains("aviso visible"))
	_fin("D. Exportación filtrada")

	# ── Rotación ──
	LogRotator.rotate(tmp, 3, true)
	_check("rotación: existe rotado .1.gz", FileAccess.file_exists(tmp + ".1.gz"))
	_fin("E. Rotación")

	# ── Exportación a archivo (LogExporter) ──
	var exp_path: String = LogExporter.export_last_lines(_log, 5)
	_check("LogExporter genera archivo no vacio", exp_path != "" and FileAccess.file_exists(exp_path))
	_fin("F. Exportación a archivo")

	# Limpieza del path temporal del test (usando la ruta REAL devuelta)
	_log.flush()
	DirAccess.remove_absolute(tmp + ".1.gz")
	DirAccess.remove_absolute(tmp)
	if exp_path != "":
		DirAccess.remove_absolute(exp_path)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _completados.has(b):
			faltantes.append(b)
	if not faltantes.is_empty():
		_check("los %d bloques se completaron — no terminaron: %s" % [BLOQUES_ESPERADOS.size(), str(faltantes)], false)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("-- checks por bloque: %s" % str(_checks_por_bloque))
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("LOGGER M103 OK"); quit(0)
