# Modelo: kimi-k3 (Moonshot AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-19
#
# M106 T-007: Test headless del archivo .env.local de desarrollo (RF2/RF4).
# Valida: existe, es parseable KEY=VALUE, tiene placeholders (NO secrets reales),
# APP_ENV=dev. Lógica pura + headless-safe. Guardián anti-falso-verde.
# Nota: la cobertura de .gitignore se verifica aparte con `git check-ignore`.

extends SceneTree

const RUTA_ENV_LOCAL := "res://../.env.local"  # raíz del proyecto (un nivel sobre game/)

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M106] Test .env.local (desarrollo) ===")
	_bloque = "A"
	_test_existe_y_parseable()
	_bloque = "B"
	_test_placeholders_no_secrets()
	_summary()

## Resuelve la ruta absoluta del .env.local en la RAÍZ del proyecto (2 niveles sobre res://,
## que apunta a game/isla-ancestral/). Headless-safe: globalize_path + get_base_dir.
func _ruta_env_local() -> String:
	var base := ProjectSettings.globalize_path("res://")  # .../game/isla-ancestral/
	var raiz := base.get_base_dir().get_base_dir().get_base_dir()  # raíz del repo (sobre game/)
	return raiz.path_join(".env.local")

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## Parsea un texto .env (KEY=VALUE, ignora comentarios # y líneas vacías).
func _parse_env(contenido: String) -> Dictionary:
	var out: Dictionary = {}
	for linea in contenido.split("\n"):
		var l := linea.strip_edges()
		if l == "" or l.begins_with("#"):
			continue
		var idx := l.find("=")
		if idx <= 0:
			continue
		out[l.substr(0, idx).strip_edges()] = l.substr(idx + 1).strip_edges()
	return out

## ── A. existe y es parseable ─────────────────────────────
func _test_existe_y_parseable() -> void:
	print("--- A. .env.local existe y es parseable ---")
	var ruta := _ruta_env_local()
	_check(".env.local existe en la raíz", FileAccess.file_exists(ruta), "ruta=%s" % ruta)
	if not FileAccess.file_exists(ruta):
		_check("fin A", _fin())
		return
	var env := _parse_env(FileAccess.get_file_as_string(ruta))
	_check("tiene claves parseables", env.size() >= 4, "n=%d" % env.size())
	_check("APP_ENV presente", env.has("APP_ENV"))
	_check("APP_ENV=dev (desarrollo)", env.get("APP_ENV", "") == "dev")
	_check("API_BASE_URL presente", env.has("API_BASE_URL"))
	_check("API_BASE_URL es localhost (dev)", str(env.get("API_BASE_URL", "")).contains("localhost"))
	_check("fin A", _fin())

## ── B. placeholders (NO secrets reales) ──────────────────
func _test_placeholders_no_secrets() -> void:
	print("--- B. placeholders, NO secrets reales ---")
	var ruta := _ruta_env_local()
	if not FileAccess.file_exists(ruta):
		_check("fin B (sin archivo)", _fin())
		return
	var env := _parse_env(FileAccess.get_file_as_string(ruta))
	# la clave dev debe ser un placeholder, no un secret real
	var key_dev := str(env.get("API_KEY_DEV", ""))
	_check("API_KEY_DEV presente", key_dev != "")
	_check("API_KEY_DEV es placeholder (no real)", key_dev.begins_with("__") or key_dev.contains("REEMPLAZAR"), "val=%s" % key_dev)
	# telemetría desactivada por defecto en dev (privacidad)
	_check("TELEMETRY_ENABLED=false", str(env.get("TELEMETRY_ENABLED", "")) == "false")
	_check("CRASH_REPORTING_ENABLED=false", str(env.get("CRASH_REPORTING_ENABLED", "")) == "false")
	# nivel de log DEBUG en dev
	_check("LOG_LEVEL=DEBUG", str(env.get("LOG_LEVEL", "")) == "DEBUG")
	_check("fin B", _fin())

## Guardián anti-falso-verde: si un bloque se aborta (SCRIPT ERROR), su `_fin` no corre.
func _fin() -> bool:
	print("  [GUARDIAN] bloque %s completado" % _bloque)
	return true

func _summary() -> void:
	print("=== Resumen M106-env: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M106-ENV FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M106-ENV OK — todos los checks pasaron")
		quit(0)
