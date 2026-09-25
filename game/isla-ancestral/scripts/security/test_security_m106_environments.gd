# Modelo: kimi-k3 (Moonshot AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-20
#
# M106 T-008: Test headless del resolver de entornos dev/staging/prod (RF4).
# Lógica pura + headless-safe. Guardián anti-falso-verde: cada bloque marca `_fin()`;
# fallos reales → exit 1.

extends SceneTree

const _ENV := preload("res://scripts/security/security_environment_resolver.gd")

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M106] Test resolver de entornos ===")
	_bloque = "A"
	_test_entornos_definidos()
	_bloque = "B"
	_test_seleccion_entorno()
	_bloque = "C"
	_test_valores_por_entorno()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── A. los 3 entornos están definidos ───────────────────
func _test_entornos_definidos() -> void:
	print("--- A. entornos definidos (dev/staging/prod) ---")
	var r = _ENV.new("dev")
	var disponibles: Array = r.entornos_disponibles()
	_check("dev definido", disponibles.has("dev"))
	_check("staging definido", disponibles.has("staging"))
	_check("prod definido", disponibles.has("prod"))
	_check("3 entornos", disponibles.size() == 3, "n=%d" % disponibles.size())
	_check("fin A", _fin())

## ── B. selección del entorno activo ─────────────────────
func _test_seleccion_entorno() -> void:
	print("--- B. selección del entorno activo ---")
	_check("forzado dev", _ENV.new("dev").entorno() == "dev")
	_check("forzado staging", _ENV.new("staging").entorno() == "staging")
	_check("forzado prod", _ENV.new("prod").entorno() == "prod")
	_check("case-insensitive (PROD)", _ENV.new("PROD").entorno() == "prod")
	_check("entorno inválido -> dev", _ENV.new("inexistente").entorno() == "dev")
	_check("es_dev()", _ENV.new("dev").es_dev() == true)
	_check("es_prod() en prod", _ENV.new("prod").es_prod() == true)
	_check("es_prod() en dev es false", _ENV.new("dev").es_prod() == false)
	_check("fin B", _fin())

## ── C. valores por entorno (separación real) ─────────────
func _test_valores_por_entorno() -> void:
	print("--- C. valores por entorno (separación) ---")
	var dev = _ENV.new("dev")
	var prod = _ENV.new("prod")
	# dev: localhost, telemetría OFF, log DEBUG
	_check("dev api localhost", str(dev.valor("api_base_url", "")).contains("localhost"))
	_check("dev telemetria OFF", dev.valor("telemetria", true) == false)
	_check("dev log DEBUG", str(dev.valor("log_level", "")) == "DEBUG")
	# prod: API real, telemetría ON, log WARNING
	_check("prod api NO localhost", not str(prod.valor("api_base_url", "")).contains("localhost"))
	_check("prod telemetria ON", prod.valor("telemetria", false) == true)
	_check("prod log WARNING", str(prod.valor("log_level", "")) == "WARNING")
	# separación de base de datos
	_check("dev base_datos != prod", str(dev.valor("base_datos", "")) != str(prod.valor("base_datos", "")))
	# clave inexistente -> default
	_check("clave inexistente -> default", dev.valor("no_existe", "fallback") == "fallback")
	# config_entorno devuelve copia (no alias)
	var cfg: Dictionary = dev.config_entorno()
	cfg["__test__"] = 1
	_check("config_entorno es copia", not dev.config_entorno().has("__test__"))
	_check("fin C", _fin())

## Guardián anti-falso-verde: si un bloque se aborta (SCRIPT ERROR), su `_fin` no corre.
func _fin() -> bool:
	print("  [GUARDIAN] bloque %s completado" % _bloque)
	return true

func _summary() -> void:
	print("=== Resumen M106-env: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M106-ENVIRONMENTS FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M106-ENVIRONMENTS OK — todos los checks pasaron")
		quit(0)
