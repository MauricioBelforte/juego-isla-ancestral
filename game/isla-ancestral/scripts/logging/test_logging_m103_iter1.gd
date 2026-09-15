# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M103: Logging — suite de iter. 1 (reclamo §21.4.7 tras la reversión del
# 2026-09-14, que devolvió el módulo a 0/183 por cierre sin verificación real
# de agnes-2.5-flash). El objetivo NO es re-marcar por inspección: cada ítem
# discutible se convierte en un check ejecutable.
#
#   A. Autoload `GameLogger`, registro en ServiceRegistry ("logger") y API pública.
#   B. Niveles: filtrado por `min_level`, `is_level_enabled`, los 5 niveles.
#   C. Categorías: las 7 habilitadas por defecto, filtrado, re-habilitación.
#   D. Formato humano: [timestamp] [NIVEL] [CAT] mensaje + contexto.
#   E. Formato JSON: línea parseable, claves, contexto anidado, escapes.
#   F. Sanitización: IPs, tokens, passwords, bearer, rutas de usuario y contexto.
#   G. Exportación: export_all / _last_lines / _by_level / _by_category / _by_date
#      (formato humano Y JSON) + LogExporter a archivo.
#   H. Rotación: disparada DESDE `_log()` (arreglo de iter. 1) + LogRotator.
#   I. Persistencia inmediata en disco (sin flush explícito) + señal line_emitted.
#   J. Configuración: LoggingConfig + logging_config.tres + JSON huérfano sin lector.
#
# ⚠️ Guardián anti-falso-verde: en GDScript un error de script ABORTA la función
# en silencio y la suite imprimiría "0 fallos" igual. Por eso cada bloque
# registra su cierre con `_fin()` y `_summary()` exige que estén los 10. Además
# hay un watchdog en `_process()` que corta con exit 1 si `_run()` no termina.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/logging/test_logging_m103_iter1.gd

extends SceneTree

const MODULO := "M103 iter. 1"
const TIMEOUT_FRAMES := 900
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]

# Valores esperados de los enums (se contrastan contra los del autoload en A).
const LV_DEBUG := 0
const LV_INFO := 1
const LV_WARNING := 2
const LV_ERROR := 3
const LV_CRITICAL := 4
const CAT_BOOT := 0
const CAT_SYSTEM := 1
const CAT_GAMEPLAY := 2
const CAT_WORLD := 3
const CAT_NETWORKING := 4
const CAT_ANALYTICS := 5
const CAT_CRASH := 6

const DIR_TMP := "user://test_m103_iter1"

var _checks: int = 0
var _fallos: int = 0
var _bloque: String = ""
var _completados: Array[String] = []
var _checks_marca: int = 0
var _checks_por_bloque: Dictionary = {}
var _frames: int = 0
var _terminado: bool = false

var _log: Node = null
var _capturadas: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	_frames += 1
	if not _terminado and _frames > TIMEOUT_FRAMES:
		_terminado = true
		_checks += 1
		_fallos += 1
		print("!! WATCHDOG: _run() no terminó en %d frames (posible SCRIPT ERROR que abortó la función)" % TIMEOUT_FRAMES)
		print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
		quit(1)
	return false


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s%s" % [nombre, "" if detalle.is_empty() else "  << %s" % detalle])


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("-- %s" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _on_line(level: int, category: int, line: String) -> void:
	_capturadas.append("%d|%d|%s" % [level, category, line])


# ── Utilidades ──────────────────────────────────────────────────────────────

## Devuelve la última línea no vacía del archivo de log aislado.
func _ultima_linea() -> String:
	var txt: String = _log.export_all()
	var arr: PackedStringArray = txt.split("\n", false)
	if arr.is_empty():
		return ""
	return arr[arr.size() - 1]


## Reabre el path aislado (trunca) y devuelve el path absoluto de trabajo.
func _reset_log(ruta: String) -> String:
	_log.set_log_path(ruta)
	return ruta


func _limpiar_tmp() -> void:
	var d := DirAccess.open(DIR_TMP)
	if d != null:
		for f in d.get_files():
			DirAccess.remove_absolute(DIR_TMP + "/" + f)
	DirAccess.remove_absolute(DIR_TMP)


## Cuenta en cuántos .gd de producción (excluye `test_*`) bajo `dir` aparece `aguja`.
func _contar_referencias(dir: String, aguja: String) -> int:
	var total: int = 0
	var pendientes: Array[String] = [dir]
	while not pendientes.is_empty():
		var actual: String = pendientes.pop_back()
		var d := DirAccess.open(actual)
		if d == null:
			continue
		for sub in d.get_directories():
			pendientes.append(actual + "/" + sub)
		for f in d.get_files():
			if not f.ends_with(".gd") or f.begins_with("test_") or f.begins_with("_tmp_"):
				continue
			if FileAccess.get_file_as_string(actual + "/" + f).contains(aguja):
				total += 1
	return total


# ── Suite ───────────────────────────────────────────────────────────────────

func _run() -> void:
	print("=== TEST LOGGING %s ===" % MODULO)

	_log = root.get_node_or_null("GameLogger")
	if _log == null:
		print("!! FALTA AUTOLOAD GameLogger — no se puede continuar")
		_terminado = true
		quit(1)
		return

	_bloque_a_autoload()
	_bloque_b_niveles()
	_bloque_c_categorias()
	_bloque_d_formato_humano()
	_bloque_e_formato_json()
	_bloque_f_sanitizacion()
	_bloque_g_exportacion()
	_bloque_h_rotacion()
	_bloque_i_persistencia_senal()
	_bloque_j_configuracion()

	_limpiar_tmp()
	_summary()


func _bloque_a_autoload() -> void:
	_ini("A. Autoload, registro y API pública")
	_check("autoload GameLogger presente", _log != null)
	var reg = root.get_node_or_null("ServiceRegistry")
	_check("ServiceRegistry presente", reg != null)
	_check("registrado en ServiceRegistry como 'logger'",
		reg != null and reg.has_method("has") and reg.has("logger"))

	for m in ["debug", "info", "warning", "error", "critical",
			"set_min_level", "set_category_enabled", "is_level_enabled", "reload_config",
			"export_all", "export_last_lines", "export_by_level", "export_by_category",
			"export_by_date", "flush", "get_log_file_path", "set_log_path"]:
		_check("API: %s()" % m, _log.has_method(m))

	# Los enums del autoload deben coincidir con los valores esperados.
	_check("Level.DEBUG == 0", int(_log.Level.DEBUG) == LV_DEBUG)
	_check("Level.INFO == 1", int(_log.Level.INFO) == LV_INFO)
	_check("Level.WARNING == 2", int(_log.Level.WARNING) == LV_WARNING)
	_check("Level.ERROR == 3", int(_log.Level.ERROR) == LV_ERROR)
	_check("Level.CRITICAL == 4", int(_log.Level.CRITICAL) == LV_CRITICAL)
	_check("Category.BOOT == 0", int(_log.Category.BOOT) == CAT_BOOT)
	_check("Category.SYSTEM == 1", int(_log.Category.SYSTEM) == CAT_SYSTEM)
	_check("Category.GAMEPLAY == 2", int(_log.Category.GAMEPLAY) == CAT_GAMEPLAY)
	_check("Category.WORLD == 3", int(_log.Category.WORLD) == CAT_WORLD)
	_check("Category.NETWORKING == 4", int(_log.Category.NETWORKING) == CAT_NETWORKING)
	_check("Category.ANALYTICS == 5", int(_log.Category.ANALYTICS) == CAT_ANALYTICS)
	_check("Category.CRASH == 6", int(_log.Category.CRASH) == CAT_CRASH)
	_check("señal line_emitted declarada", _log.has_signal("line_emitted"))
	_fin("A. Autoload, registro y API pública")


func _bloque_b_niveles() -> void:
	_ini("B. Niveles y filtrado")
	_reset_log(DIR_TMP + "/niveles.log")
	_log.set_min_level(LV_WARNING)

	_log.debug("niv_debug_filtrado")
	_log.info("niv_info_filtrado")
	_log.warning("niv_warning_pasa", CAT_SYSTEM)
	_log.error("niv_error_pasa", CAT_SYSTEM)
	_log.critical("niv_critical_pasa", CAT_SYSTEM)

	var txt: String = _log.export_all()
	_check("DEBUG filtrado con min_level=WARNING", not txt.contains("niv_debug_filtrado"))
	_check("INFO filtrado con min_level=WARNING", not txt.contains("niv_info_filtrado"))
	_check("WARNING pasa", txt.contains("niv_warning_pasa"))
	_check("ERROR pasa", txt.contains("niv_error_pasa"))
	_check("CRITICAL pasa", txt.contains("niv_critical_pasa"))

	_check("is_level_enabled(DEBUG) == false", not bool(_log.is_level_enabled(LV_DEBUG)))
	_check("is_level_enabled(WARNING) == true", bool(_log.is_level_enabled(LV_WARNING)))
	_check("is_level_enabled(CRITICAL) == true", bool(_log.is_level_enabled(LV_CRITICAL)))

	# Bajar el mínimo a DEBUG: ahora sí entra el DEBUG.
	_reset_log(DIR_TMP + "/niveles.log")
	_log.set_min_level(LV_DEBUG)
	_log.debug("niv_debug_ahora_pasa", CAT_SYSTEM)
	_check("DEBUG pasa con min_level=DEBUG", _log.export_all().contains("niv_debug_ahora_pasa"))
	_check("is_level_enabled(DEBUG) == true", bool(_log.is_level_enabled(LV_DEBUG)))

	_log.set_min_level(LV_DEBUG)
	_fin("B. Niveles y filtrado")


func _bloque_c_categorias() -> void:
	_ini("C. Categorías")
	_reset_log(DIR_TMP + "/categorias.log")
	_log.set_min_level(LV_DEBUG)

	# Por defecto (logging_config.tres) las 7 categorías están habilitadas.
	var faltantes: Array[int] = []
	for c in [CAT_BOOT, CAT_SYSTEM, CAT_GAMEPLAY, CAT_WORLD, CAT_NETWORKING, CAT_ANALYTICS, CAT_CRASH]:
		if not _log.categories_enabled.has(c):
			faltantes.append(c)
	_check("las 7 categorías habilitadas por defecto", faltantes.is_empty(), str(faltantes))

	_log.set_category_enabled(CAT_NETWORKING, false)
	_reset_log(DIR_TMP + "/categorias.log")
	_log.info("cat_net_filtrada", CAT_NETWORKING)
	_log.info("cat_sys_pasa", CAT_SYSTEM)
	var txt: String = _log.export_all()
	_check("categoría deshabilitada filtra su línea", not txt.contains("cat_net_filtrada"))
	_check("categoría habilitada sigue pasando", txt.contains("cat_sys_pasa"))

	_log.set_category_enabled(CAT_NETWORKING, true)
	_reset_log(DIR_TMP + "/categorias.log")
	_log.info("cat_net_rehabilitada", CAT_NETWORKING)
	_check("categoría re-habilitada vuelve a pasar", _log.export_all().contains("cat_net_rehabilitada"))

	# Una categoría fuera de rango nunca debe colarse.
	_reset_log(DIR_TMP + "/categorias.log")
	_log.info("cat_invalida", 99)
	_check("categoría inválida (99) descartada", not _log.export_all().contains("cat_invalida"))
	_fin("C. Categorías")


func _bloque_d_formato_humano() -> void:
	_ini("D. Formato humano")
	_log.json_output = false
	_reset_log(DIR_TMP + "/humano.log")
	_log.set_min_level(LV_DEBUG)
	_log.info("mensaje_humano", CAT_GAMEPLAY)

	var linea: String = _ultima_linea()
	_check("empieza con '[' (timestamp)", linea.begins_with("["))
	_check("contiene '[INFO]'", linea.contains("[INFO]"))
	_check("contiene '[GAMEPLAY]'", linea.contains("[GAMEPLAY]"))
	_check("contiene el mensaje", linea.contains("mensaje_humano"))
	_check("timestamp con formato YYYY-MM-DD", linea.contains(Time.get_datetime_string_from_system().substr(0, 10)))

	# Con contexto, el Dictionary se anexa a la línea.
	_reset_log(DIR_TMP + "/humano.log")
	_log.info("mensaje_con_ctx", CAT_SYSTEM, {"slot": 3})
	var linea2: String = _ultima_linea()
	_check("contexto anexado a la línea humana", linea2.contains("slot"))

	# El nivel correcto se escribe para cada método.
	_reset_log(DIR_TMP + "/humano.log")
	_log.warning("w_tag", CAT_SYSTEM)
	_log.error("e_tag", CAT_SYSTEM)
	_log.critical("c_tag", CAT_SYSTEM)
	var txt: String = _log.export_all()
	_check("WARNING etiquetado", txt.contains("[WARNING]"))
	_check("ERROR etiquetado", txt.contains("[ERROR]"))
	_check("CRITICAL etiquetado", txt.contains("[CRITICAL]"))
	_fin("D. Formato humano")


func _bloque_e_formato_json() -> void:
	_ini("E. Formato JSON")
	_log.json_output = true
	_reset_log(DIR_TMP + "/json.log")
	_log.set_min_level(LV_DEBUG)
	_log.warning("mensaje_json", CAT_WORLD, {"chunk": 7})

	var linea: String = _ultima_linea()
	_check("línea JSON empieza con '{'", linea.begins_with("{"))
	var obj = JSON.parse_string(linea)
	_check("línea JSON parseable", obj != null)
	if typeof(obj) == TYPE_DICTIONARY:
		_check("clave 'timestamp' presente", obj.has("timestamp"))
		_check("clave 'level' == WARNING", obj.get("level", "") == "WARNING")
		_check("clave 'category' == WORLD", obj.get("category", "") == "WORLD")
		_check("clave 'message' correcta", obj.get("message", "") == "mensaje_json")
		_check("clave 'context' anidada con 'chunk'", typeof(obj.get("context", null)) == TYPE_DICTIONARY and int(obj["context"].get("chunk", -1)) == 7)
	else:
		_check("clave 'timestamp' presente", false)
		_check("clave 'level' == WARNING", false)
		_check("clave 'category' == WORLD", false)
		_check("clave 'message' correcta", false)
		_check("clave 'context' anidada con 'chunk'", false)

	# Los escapes de iter. 1: comillas, tabulador y salto de línea.
	_reset_log(DIR_TMP + "/json.log")
	_log.info("con \"comillas\" y\ttabulador", CAT_SYSTEM)
	var linea_esc: String = _ultima_linea()
	_check("comillas escapadas (JSON sigue siendo parseable)", JSON.parse_string(linea_esc) != null)
	_check("tabulador escapado como \\t", linea_esc.contains("\\t"))
	_check("no quedan tabuladores crudos", not linea_esc.contains("\t"))

	_log.json_output = false
	_fin("E. Formato JSON")


func _bloque_f_sanitizacion() -> void:
	_ini("F. Sanitización de datos sensibles")
	_log.json_output = false
	_log.sanitize_sensitive = true
	_reset_log(DIR_TMP + "/sanitiza.log")
	_log.set_min_level(LV_DEBUG)

	_log.warning("conexion a 192.168.1.10:8080 rechazada", CAT_NETWORKING)
	var t_ip: String = _log.export_all()
	_check("IPv4 redactada (octetos tras el primero)", not t_ip.contains("192.168.1.10"))
	_check("IPv4 conserva el primer octeto", t_ip.contains("192."))

	_reset_log(DIR_TMP + "/sanitiza.log")
	_log.warning("token=abc123xyz", CAT_SYSTEM)
	_check("token=... redactado", not _log.export_all().contains("abc123xyz"))

	_reset_log(DIR_TMP + "/sanitiza.log")
	_log.warning("password=supersecreta", CAT_SYSTEM)
	_check("password=... redactado", not _log.export_all().contains("supersecreta"))

	_reset_log(DIR_TMP + "/sanitiza.log")
	_log.warning("Authorization: Bearer abc.def-123", CAT_NETWORKING)
	_check("Bearer <token> redactado", not _log.export_all().contains("abc.def-123"))

	_reset_log(DIR_TMP + "/sanitiza.log")
	_log.warning("guardado en C:\\Users\\maria\\save.dat", CAT_SYSTEM)
	var t_path: String = _log.export_all()
	_check("ruta de usuario redactada", not t_path.contains("Users\\maria"))
	_check("ruta de usuario → %USERPROFILE%", t_path.contains("%USERPROFILE%"))

	# Contexto: claves sensibles redactadas, no sensibles preservadas.
	_reset_log(DIR_TMP + "/sanitiza.log")
	_log.info("ctx_sensible", CAT_SYSTEM, {"password": "1234", "usuario": "maria"})
	var t_ctx: String = _log.export_all()
	_check("contexto: password → [REDACTED]", t_ctx.contains("[REDACTED]"))
	_check("contexto: password NO aparece", not t_ctx.contains("1234"))
	_check("contexto: valor no sensible preservado", t_ctx.contains("maria"))

	# Contexto anidado.
	_reset_log(DIR_TMP + "/sanitiza.log")
	_log.info("ctx_anidado", CAT_SYSTEM, {"meta": {"token": "zzz999"}})
	_check("contexto anidado: token redactado", not _log.export_all().contains("zzz999"))

	# Con la sanitización desactivada, el dato crudo debe verse.
	_log.sanitize_sensitive = false
	_reset_log(DIR_TMP + "/sanitiza.log")
	_log.warning("token=crudo123", CAT_SYSTEM)
	_check("sanitize_sensitive=false deja el dato crudo", _log.export_all().contains("crudo123"))
	_log.sanitize_sensitive = true
	_fin("F. Sanitización de datos sensibles")


func _bloque_g_exportacion() -> void:
	_ini("G. Exportación")
	_log.json_output = false
	_log.set_min_level(LV_DEBUG)
	_reset_log(DIR_TMP + "/export.log")
	for i in range(1, 6):
		_log.info("linea_%d" % i, CAT_SYSTEM)
	_log.warning("aviso_export", CAT_SYSTEM)
	_log.error("error_export", CAT_GAMEPLAY)

	_check("export_all contiene todo", _log.export_all().contains("linea_1") and _log.export_all().contains("error_export"))

	var ultimas: String = _log.export_last_lines(2)
	_check("export_last_lines(2) devuelve 2 líneas", ultimas.split("\n", false).size() == 2)
	_check("export_last_lines(2) termina en el error", ultimas.contains("error_export"))

	var solo_error: String = _log.export_by_level(LV_ERROR)
	_check("export_by_level(ERROR) incluye error", solo_error.contains("error_export"))
	_check("export_by_level(ERROR) excluye info", not solo_error.contains("linea_1"))
	_check("export_by_level(ERROR) excluye warning", not solo_error.contains("aviso_export"))

	var solo_warn: String = _log.export_by_level(LV_WARNING)
	_check("export_by_level(WARNING) incluye warning y error", solo_warn.contains("aviso_export") and solo_warn.contains("error_export"))
	_check("export_by_level(WARNING) excluye info", not solo_warn.contains("linea_1"))

	var por_cat: String = _log.export_by_category(CAT_GAMEPLAY)
	_check("export_by_category(GAMEPLAY) incluye su línea", por_cat.contains("error_export"))
	_check("export_by_category(GAMEPLAY) excluye SYSTEM", not por_cat.contains("linea_1"))

	var por_fecha: String = _log.export_by_date(24)
	_check("export_by_date(24h) incluye las líneas recién escritas", por_fecha.contains("linea_1"))
	# Prueba de que el filtro REALMENTE discrimina (bug de iter. 1: el regex exigía un
	# espacio y Godot emite 'T', así que ninguna línea coincidía y el `else` devolvía
	# TODO). Con una ventana negativa nada debe entrar.
	_check("export_by_date(-1h) NO incluye lo recién escrito (el filtro discrimina de verdad)",
		not _log.export_by_date(-1).contains("linea_1"))

	# export_by_level / export_by_category en formato JSON (arreglo de iter. 1).
	_log.json_output = true
	_reset_log(DIR_TMP + "/export_json.log")
	_log.info("j_info", CAT_SYSTEM)
	_log.error("j_error", CAT_GAMEPLAY)
	_check("JSON: export_by_level(ERROR) incluye error", _log.export_by_level(LV_ERROR).contains("j_error"))
	_check("JSON: export_by_level(ERROR) excluye info", not _log.export_by_level(LV_ERROR).contains("j_info"))
	_check("JSON: export_by_category(GAMEPLAY) incluye su línea", _log.export_by_category(CAT_GAMEPLAY).contains("j_error"))
	_check("JSON: export_by_category(GAMEPLAY) excluye SYSTEM", not _log.export_by_category(CAT_GAMEPLAY).contains("j_info"))
	_log.json_output = false

	# LogExporter: escribe a archivo.
	var exp_path: String = LogExporter.export_last_lines(_log, 2)
	_check("LogExporter.export_last_lines devuelve ruta existente", exp_path != "" and FileAccess.file_exists(exp_path))
	if exp_path != "" and FileAccess.file_exists(exp_path):
		var contenido: String = FileAccess.get_file_as_string(exp_path)
		_check("LogExporter escribe contenido no vacío", contenido.length() > 0)
		DirAccess.remove_absolute(exp_path)
	var exp_all: String = LogExporter.export_all(_log)
	_check("LogExporter.export_all devuelve ruta existente", exp_all != "" and FileAccess.file_exists(exp_all))
	if exp_all != "" and FileAccess.file_exists(exp_all):
		DirAccess.remove_absolute(exp_all)
	_fin("G. Exportación")


func _bloque_h_rotacion() -> void:
	_ini("H. Rotación (disparada desde _log) + LogRotator")
	_log.json_output = false
	_log.set_min_level(LV_DEBUG)
	_log.max_rotated_files = 3

	# ── H1: rotación disparada DESDE _log(), con compresión ──
	_log.compress_old_logs = true
	_log.max_file_size_mb = 0.0002  # ≈209 bytes: pocas líneas lo superan
	var ruta: String = _reset_log(DIR_TMP + "/rota.log")
	# ⚠️ NO se llama a flush(): la rotación debe dispararse DESDE _log() (arreglo iter. 1).
	for i in range(0, 40):
		_log.info("linea_de_rotacion_%d_con_relleno_para_superar_el_umbral" % i, CAT_SYSTEM)
	_check("rotación disparada desde _log() → existe .1.gz", FileAccess.file_exists(ruta + ".1.gz"))
	_check("archivo activo reiniciado tras rotar (< umbral)",
		LogRotator.get_size(ruta) <= int(_log.max_file_size_mb * 1024.0 * 1024.0), str(LogRotator.get_size(ruta)))
	_check("no se conserva el rotado más allá de max_rotated_files (sin .4.gz)",
		not FileAccess.file_exists(ruta + ".4.gz"))

	# ── H2: rotación disparada desde _log() SIN compresión ──
	_log.compress_old_logs = false
	var ruta2: String = _reset_log(DIR_TMP + "/rota_plain.log")
	for i in range(0, 40):
		_log.info("linea_plana_%d_con_relleno_para_superar_el_umbral" % i, CAT_SYSTEM)
	_check("rotación sin compresión → existe .1", FileAccess.file_exists(ruta2 + ".1"))
	_check("rotación sin compresión → NO crea .1.gz", not FileAccess.file_exists(ruta2 + ".1.gz"))
	_check("activo reiniciado tras rotar sin compresión",
		LogRotator.get_size(ruta2) <= int(_log.max_file_size_mb * 1024.0 * 1024.0))
	_log.max_file_size_mb = 10.0
	_log.compress_old_logs = true

	# ── H3: LogRotator.get_size devuelve BYTES (arreglo de iter. 1) ──
	var contenido_prueba := "áéíóúñ"  # 6 caracteres, 12 bytes en UTF-8
	var f := FileAccess.open(DIR_TMP + "/tam.log", FileAccess.WRITE)
	f.store_string(contenido_prueba)
	f.close()
	_check("LogRotator.get_size devuelve bytes (12), no caracteres (6)",
		LogRotator.get_size(DIR_TMP + "/tam.log") == 12, str(LogRotator.get_size(DIR_TMP + "/tam.log")))
	_check("LogRotator.get_size de inexistente == 0", LogRotator.get_size(DIR_TMP + "/no_existe.log") == 0)

	# ── H4: LogRotator.rotate directo sobre un archivo CERRADO ──
	# ⚠️ Hallazgo de iter. 1: no se puede rotar un archivo que el logger mantiene
	# abierto — en Windows el rename falla y el error se ignora en silencio. Por eso
	# aquí se usa un archivo propio, ya cerrado.
	var g := FileAccess.open(DIR_TMP + "/rota_directa.log", FileAccess.WRITE)
	g.store_string("contenido_para_rotar_directo\n")
	g.close()
	LogRotator.rotate(DIR_TMP + "/rota_directa.log", 2, false)
	_check("rotate(compress=false) crea .1 sin .gz", FileAccess.file_exists(DIR_TMP + "/rota_directa.log.1"))
	_check("rotate() deja el activo vacío", LogRotator.get_size(DIR_TMP + "/rota_directa.log") == 0)

	var h := FileAccess.open(DIR_TMP + "/rota_directa_gz.log", FileAccess.WRITE)
	h.store_string("contenido_para_rotar_directo_gz\n")
	h.close()
	LogRotator.rotate(DIR_TMP + "/rota_directa_gz.log", 2, true)
	_check("rotate(compress=true) crea .1.gz", FileAccess.file_exists(DIR_TMP + "/rota_directa_gz.log.1.gz"))
	_fin("H. Rotación (disparada desde _log) + LogRotator")


func _bloque_i_persistencia_senal() -> void:
	_ini("I. Persistencia inmediata + señal line_emitted")
	_log.json_output = false
	_log.set_min_level(LV_DEBUG)
	var ruta: String = _reset_log(DIR_TMP + "/persist.log")

	_capturadas.clear()
	_log.line_emitted.connect(_on_line)
	_log.warning("linea_inmediata", CAT_SYSTEM)
	# ⚠️ Sin flush(): la línea debe estar ya en disco (fix 2026-09-02).
	var en_disco: bool = FileAccess.file_exists(ruta) and FileAccess.get_file_as_string(ruta).contains("linea_inmediata")
	_check("línea en disco SIN llamar a flush()", en_disco)

	_check("line_emitted emitió al menos una línea", _capturadas.size() >= 1)
	var primera: String = "" if _capturadas.is_empty() else _capturadas[0]
	_check("line_emitted trae el nivel correcto (2=WARNING)", primera.begins_with("2|"))
	_check("line_emitted trae la categoría correcta (1=SYSTEM)", primera.contains("|1|"))
	_check("line_emitted trae la línea formateada", primera.contains("[WARNING]"))

	_log.line_emitted.disconnect(_on_line)
	_log.flush()
	_check("flush() no falla y conserva el contenido", _log.export_all().contains("linea_inmediata"))
	_fin("I. Persistencia inmediata + señal line_emitted")


func _bloque_j_configuracion() -> void:
	_ini("J. Configuración")
	# Valores por defecto de la clase LoggingConfig.
	var cfg = LoggingConfig.new()
	_check("LoggingConfig.level_min por defecto == 0", int(cfg.get_level_min()) == 0)
	_check("LoggingConfig.max_file_size_mb por defecto == 10.0", is_equal_approx(float(cfg.get_max_file_size_mb()), 10.0))
	_check("LoggingConfig.max_rotated_files por defecto == 5", int(cfg.get_max_rotated_files()) == 5)
	_check("LoggingConfig.categories_enabled por defecto = 7", cfg.get_categories_enabled().size() == 7)
	_check("LoggingConfig tiene los 7 getters",
		cfg.has_method("get_level_min") and cfg.has_method("get_categories_enabled")
		and cfg.has_method("get_max_file_size_mb") and cfg.has_method("get_max_rotated_files")
		and cfg.has_method("get_compress_old_logs") and cfg.has_method("get_json_output")
		and cfg.has_method("get_sanitize_sensitive"))

	# El .tres real debe cargar y ser coherente.
	var cfg_path := "res://data/logging/logging_config.tres"
	_check("logging_config.tres existe", ResourceLoader.exists(cfg_path))
	var real: Resource = load(cfg_path)
	_check("logging_config.tres carga como Resource", real != null)
	if real != null and real.has_method("get_level_min"):
		_check("tres: level_min == 0 (DEBUG)", int(real.get_level_min()) == 0)
		_check("tres: max_file_size_mb == 10.0", is_equal_approx(float(real.get_max_file_size_mb()), 10.0))
		_check("tres: max_rotated_files == 5", int(real.get_max_rotated_files()) == 5)
		_check("tres: las 7 categorías habilitadas", real.get_categories_enabled().size() == 7)
		_check("tres: sanitize_sensitive == true", bool(real.get_sanitize_sensitive()))
	else:
		_check("tres: level_min == 0 (DEBUG)", false)
		_check("tres: max_file_size_mb == 10.0", false)
		_check("tres: max_rotated_files == 5", false)
		_check("tres: las 7 categorías habilitadas", false)
		_check("tres: sanitize_sensitive == true", false)

	# reload_config aplica los campos del recurso.
	_log.set_min_level(LV_CRITICAL)
	_log.reload_config(real)
	_check("reload_config restaura min_level desde el .tres", int(_log.min_level) == int(real.get_level_min()))

	# `data/logging/logger_config.json` es un archivo HUÉRFANO: ningún script de
	# producción lo lee. Se comprueba por evidencia ejecutable recorriendo
	# `res://scripts/` entero y contando referencias (excluyendo los tests).
	var referencias: int = _contar_referencias("res://scripts", "logger_config.json")
	_check("logger_config.json no lo lee ningún script de producción (huérfano)", referencias == 0, "referencias=%d" % referencias)
	_check("logger_config.json existe en data/logging (a documentar/limpiar)",
		FileAccess.file_exists("res://data/logging/logger_config.json"))

	# Restaurar el estado de configuración del autoload.
	_log.set_min_level(LV_DEBUG)
	_log.set_log_path("user://logs/game.log")
	_fin("J. Configuración")


func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _completados.has(b):
			faltantes.append(b)
	var detalle: String = "" if faltantes.is_empty() else " — bloques que no terminaron: %s" % str(faltantes)
	_check("los %d bloques se completaron (sin abortos silenciosos)%s" % [BLOQUES_ESPERADOS.size(), detalle],
		faltantes.is_empty())
	_terminado = true
	print("-- checks por bloque: %s" % str(_checks_por_bloque))
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos == 0:
		print("TEST %s OK — todos los checks pasaron" % MODULO)
		quit(0)
	else:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
