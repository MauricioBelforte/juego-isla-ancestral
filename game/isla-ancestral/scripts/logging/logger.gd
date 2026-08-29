# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M103: Logging — Logger (servicio autoload).
# Implementación del diseño 03 (SWE-1.6/Devin).
# API pública:
#   debug/info/warning/error/critical(message, category, context)
#   set_min_level / set_category_enabled / reload_config
#   export_all / export_last_lines / export_by_level / export_by_category / export_by_date
#   flush / get_log_file_path / is_level_enabled
# Godot 4.7: usa FileAccess/DirAccess (no File/Dir antiguos).
# Se registra como autoload "Logger" en project.godot y en ServiceRegistry ("logger").

extends Node

## Niveles de log (mayor = más severo)
enum Level { DEBUG, INFO, WARNING, ERROR, CRITICAL }

## Categorías (para filtros)
enum Category { BOOT, SYSTEM, GAMEPLAY, WORLD, NETWORKING, ANALYTICS, CRASH }

## Señal cuando se emite una línea (para la consola in-game de M110)
signal line_emitted(level: int, category: int, line: String)

## Prefijos de nivel para la línea humana
const LEVEL_TAG := {Level.DEBUG: "DEBUG", Level.INFO: "INFO", Level.WARNING: "WARNING", Level.ERROR: "ERROR", Level.CRITICAL: "CRITICAL"}
const CATEGORY_TAG := {Category.BOOT: "BOOT", Category.SYSTEM: "SYSTEM", Category.GAMEPLAY: "GAMEPLAY", Category.WORLD: "WORLD", Category.NETWORKING: "NETWORKING", Category.ANALYTICS: "ANALYTICS", Category.CRASH: "CRASH"}

## Configuración por defecto (se reemplaza en _ready con logging_config.tres)
var min_level: int = Level.DEBUG
var categories_enabled: Dictionary = {}  # int(Category) -> bool
var max_file_size_mb: float = 10.0
var max_rotated_files: int = 5
var compress_old_logs: bool = true
var json_output: bool = false
var sanitize_sensitive: bool = true

var log_buffer: PackedStringArray = PackedStringArray()
var _log_path: String = "user://logs/game.log"

## Directorio y archivo creados en _ready (FileAccess abierto)
var _file: FileAccess = null

func _ready() -> void:
	_load_config()
	_open_log_file()
	# Registrar en ServiceRegistry como servicio "logger" (M07)
	var reg = get_node_or_null("/root/ServiceRegistry")
	if reg != null and reg.has_method("register"):
		reg.register("logger", self)
	info("Logger inicializado", Category.BOOT)

## ── Carga de configuración ──────────────────────────────
func _load_config() -> void:
	var cfg_path := "res://data/logging/logging_config.tres"
	if ResourceLoader.exists(cfg_path):
		var cfg: Resource = load(cfg_path)
		if cfg != null and cfg.has_method("get_level_min"):
			min_level = cfg.get_level_min()
			max_file_size_mb = cfg.get_max_file_size_mb()
			max_rotated_files = cfg.get_max_rotated_files()
			compress_old_logs = cfg.get_compress_old_logs()
			json_output = cfg.get_json_output()
			sanitize_sensitive = cfg.get_sanitize_sensitive()
			for c in cfg.get_categories_enabled():
				var cint := int(c)
				if CATEGORY_TAG.has(cint):
					categories_enabled[cint] = true
			return
	# Fallback: habilitar todas
	for c in CATEGORY_TAG:
		categories_enabled[c] = true

## ── Archivo de log ──────────────────────────────────────
func _open_log_file() -> void:
	var dir: String = _log_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	# Modo texto en append; crea si no existe.
	_file = FileAccess.open(_log_path, FileAccess.WRITE)
	if _file == null:
		push_warning("Logger: no se pudo abrir archivo de log %s (err %d)" % [_log_path, FileAccess.get_open_error()])
## ── API pública de log ──────────────────────────────────
func debug(message: String, category: int = Category.SYSTEM, context: Dictionary = {}) -> void:
	_log(Level.DEBUG, message, category, context)

func info(message: String, category: int = Category.SYSTEM, context: Dictionary = {}) -> void:
	_log(Level.INFO, message, category, context)

func warning(message: String, category: int = Category.SYSTEM, context: Dictionary = {}) -> void:
	_log(Level.WARNING, message, category, context)

func error(message: String, category: int = Category.SYSTEM, context: Dictionary = {}) -> void:
	_log(Level.ERROR, message, category, context)

func critical(message: String, category: int = Category.SYSTEM, context: Dictionary = {}) -> void:
	_log(Level.CRITICAL, message, category, context)

## ── Lógica principal ────────────────────────────────────
func _log(level: int, message: String, category: int, context: Dictionary) -> void:
	if level < min_level:
		return
	if not categories_enabled.has(category):
		return

	var final_message := message
	if sanitize_sensitive:
		final_message = SensitiveDataSanitizer.sanitize_string(final_message)
		if context.size() > 0:
			context = SensitiveDataSanitizer.sanitize_context(context)

	var ts := Time.get_datetime_string_from_system()
	var level_str: String = LEVEL_TAG.get(level, "INFO")
	var cat_str: String = CATEGORY_TAG.get(category, "SYSTEM")

	var line: String
	if json_output:
		var ctx_json := ""
		if context.size() > 0:
			ctx_json = " \"context\": %s" % JSON.stringify(context)
		line = "{\"timestamp\":\"%s\",\"level\":\"%s\",\"category\":\"%s\",\"message\":\"%s\"%s}" % [ts, level_str, cat_str, _json_escape(final_message), ctx_json]
	else:
		line = "[%s] [%s] [%s] %s" % [ts, level_str, cat_str, final_message]
		if context.size() > 0:
			line += " %s" % str(context)

	line_emitted.emit(level, category, line)
	print(line)

	# Buffer + flush periódico (cada 100 líneas)
	log_buffer.append(line)
	if _file != null and log_buffer.size() >= 100:
		_flush()

## Escapa caracteres para JSON payload.
func _json_escape(s: String) -> String:
	return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n")

## ── Configuración dinámica ──────────────────────────────
func set_min_level(level: int) -> void:
	min_level = level

func set_category_enabled(category: int, enabled: bool) -> void:
	if enabled:
		categories_enabled[category] = true
	else:
		categories_enabled.erase(category)

## Indica si un nivel está habilitado (para evitar construir mensajes caros).
## Las categorías se evalúan por separado; los mensajes caros usan is_level_enabled(DEBUG).
func is_level_enabled(level: int) -> bool:
	return level >= min_level

## Reincorpora config desde un recurso LoggingConfig.
func reload_config(cfg: Resource) -> void:
	if cfg == null:
		return
	if cfg.has_method("get_level_min"):
		min_level = cfg.get_level_min()
		max_file_size_mb = cfg.get_max_file_size_mb()
		max_rotated_files = cfg.get_max_rotated_files()
		compress_old_logs = cfg.get_compress_old_logs()
		json_output = cfg.get_json_output()
		sanitize_sensitive = cfg.get_sanitize_sensitive()
		for c in cfg.get_categories_enabled():
			var cint := int(c)
			if CATEGORY_TAG.has(cint):
				categories_enabled[cint] = true
## ── Exportación ─────────────────────────────────────────
func export_all() -> String:
	return _read_file(_log_path)

func export_last_lines(lines: int) -> String:
	var all := export_all()
	var arr := all.split("\n", false)
	if arr.size() > lines:
		arr = arr.slice(arr.size() - lines)
	return "\n".join(arr)

func export_by_level(min_level: int) -> String:
	var out := PackedStringArray()
	for line in _read_file(_log_path).split("\n", false):
		_append_if_level(out, line, min_level)
	return "\n".join(out)

func export_by_category(category: int) -> String:
	var out := PackedStringArray()
	var tag: String = CATEGORY_TAG.get(category, "")
	for line in _read_file(_log_path).split("\n", false):
		if tag != "" and line.contains("] [" + tag + "]"):
			out.append(line)
	return "\n".join(out)

func export_by_date(hours: int) -> String:
	var out := PackedStringArray()
	var now := Time.get_datetime_dict_from_system()
	for line in _read_file(_log_path).split("\n", false):
		var m := RegEx.new()
		m.compile("^\\[(\\d{4})-(\\d{2})-(\\d{2}) ")
		var res := m.search(line)
		if res:
			var y := int(res.get_string(1)); var mo := int(res.get_string(2)); var d := int(res.get_string(3))
			var dias := (int(now["year"]) - y) * 360 + (int(now["month"]) - mo) * 30 + (int(now["day"]) - d)
			if dias * 24 <= hours:
				out.append(line)
		else:
			out.append(line)
	return "\n".join(out)

func _append_if_level(arr: PackedStringArray, line: String, min_level: int) -> void:
	for tag in LEVEL_TAG:
		if int(tag) >= min_level and line.contains("] [" + LEVEL_TAG[tag] + "] "):
			arr.append(line)
			return

func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var txt: String = f.get_as_text()
	f.close()
	return txt

## ── Flush / rotación ───────────────────────────────────
func flush() -> void:
	_flush()

func _flush() -> void:
	if _file == null:
		return
	for line in log_buffer:
		_file.store_line(line)
	_file.flush()
	log_buffer.clear()
	# Verificar rotación tras escribir.
	if _file != null and FileAccess.file_exists(_log_path) and FileAccess.get_file_as_string(_log_path).length() > int(max_file_size_mb * 1024 * 1024):
		_rotate()

func _rotate() -> void:
	if _file != null:
		_file.close()
	LogRotator.rotate(_log_path, max_rotated_files, compress_old_logs)
	_open_log_file()

func get_log_file_path() -> String:
	return _log_path

## Mueve el archivo de log (útil para tests aislados).
func set_log_path(p: String) -> void:
	if _file != null:
		_file.close()
	_log_path = p
	_open_log_file()