# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-16
#
# M106: Seguridad — Test de SecurityInputValidator (métodos "InputValidator" del diseño).
# Lógica pura + headless-safe. Guardián anti-falso-verde: cada bloque marca `_fin()`;
# fallos reales → exit 1.

extends SceneTree

const _V := preload("res://scripts/security/security_input_validator.gd")

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M106] Test SecurityInputValidator ===")
	_bloque = "A"
	_test_sanitize()
	_bloque = "B"
	_test_validar_primitivas()
	_bloque = "C"
	_test_email_enum()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── A. sanitizar ────────────────────────────────────────
func _test_sanitize() -> void:
	print("--- A. sanitizar ---")
	var v = _V.new()
	_check("control chars eliminados", v.sanitizar("hola\u0001\u0002mundo") == "holamundo")
	_check("tab/nl/r conservados", v.sanitizar("a\tb\nc") == "a\tb\nc")
	_check("truncado a max_len", v.sanitizar("abcdef", 3) == "abc")
	_check("string vacio -> vacio", v.sanitizar("") == "")
	_check("fin A", _fin())

## ── B. validar string/int/float ─────────────────────────
func _test_validar_primitivas() -> void:
	print("--- B. validar string/int/float ---")
	var v = _V.new()
	_check("validar_string ok", v.validar_string("hola", 1, 10))
	_check("validar_string vacio (min 1) NO", not v.validar_string("", 1, 10))
	_check("validar_string corto (< min) NO", not v.validar_string("a", 5, 10))
	# int
	_check("validar_int 42 en [1,100]", v.validar_int(42, 1, 100))
	_check("validar_int float entero 42.0", v.validar_int(42.0, 1, 100))
	_check("validar_int float fraccion NO", not v.validar_int(42.5, 1, 100))
	_check("validar_int string '42'", v.validar_int("42", 1, 100))
	_check("validar_int fuera rango NO", not v.validar_int(101, 1, 100))
	_check("validar_int string no num NO", not v.validar_int("abc", 1, 100))
	# float
	_check("validar_float 0.5 en [0,1]", v.validar_float(0.5, 0.0, 1.0))
	_check("validar_float 1.5 fuera [0,1] NO", not v.validar_float(1.5, 0.0, 1.0))
	_check("validar_float string '0.9'", v.validar_float("0.9", 0.0, 1.0))
	_check("fin B", _fin())

## ── C. email + enumeracion ──────────────────────────────
func _test_email_enum() -> void:
	print("--- C. email + enumeracion ---")
	var v = _V.new()
	_check("email valido", v.validar_email("a@b.co"))
	_check("email valido (mayus)", v.validar_email("A@B.CO"))
	_check("email invalido (sin @)", not v.validar_email("hola.com"))
	_check("email invalido (vacio)", not v.validar_email(""))
	_check("enumeracion contiene", v.validar_enumeracion("media", ["baja", "media", "alta"]))
	_check("enumeracion no contiene", not v.validar_enumeracion("ultra", ["baja", "media", "alta"]))
	_check("fin C", _fin())

## Guardián anti-falso-verde: si un bloque se aborta (SCRIPT ERROR), su `_fin` no corre.
func _fin() -> bool:
	print("  [GUARDIAN] bloque %s completado" % _bloque)
	return true

func _summary() -> void:
	print("=== Resumen M106-input: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M106-INPUT FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M106-INPUT OK — todos los checks pasaron")
		quit(0)
