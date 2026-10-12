# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
# Endurecido: DeepSeek-V4.1-Flash / WorkBuddy (2026-10-12)
#
# M01: Fundamentos del Proyecto — Test headless
# Valida: FundamentalsValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.
#
# Guardas anti-falso-verde (skill isla-ancestral-ciclo-modulo, trampas 11/61/63/122):
#   Capa 1 — BLOQUES + _fin(): nombra el bloque que no cerro (aborto silencioso).
#   Capa 2 — CHECKS_MINIMOS: piso MEDIDO en verde (no estimado).
#   Capa 3 — _summary() en call_deferred APARTE de _run(): si _run() aborta por
#            un SCRIPT ERROR, la cola diferida sigue y el resumen CORRE igual.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/proyecto/fundamentals_validator.gd")
const RUTA_DATA := "res://data/proyecto/fundamentos.json"

# Capa 2: piso de checks medido en la corrida verde (8).
const CHECKS_MINIMOS := 8
# Capa 1: bloques esperados.
const BLOQUES := ["datos", "validator", "errores"]

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _run() -> void:
	print("=== [M01] Test de Fundamentos del Proyecto ===")
	_test_data()
	_test_validator()
	_test_validator_errores()
	# NO llama a _summary() ni a quit(): lo hace el diferido registrado en _init,
	# que corre aunque esta funcion aborte por un SCRIPT ERROR (trampa 61).

func _cargar() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATA))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _test_data() -> void:
	print("--- Datos: fundamentos.json ---")
	var data: Dictionary = _cargar()
	_check("fundamentos.json cargado", not data.is_empty())
	var lista: Array = data.get("fundamentos", [])
	_check("4 fundamentos", lista.size() == 4, "size=%d" % lista.size())
	_fin("datos")

func _test_validator() -> void:
	print("--- FundamentalsValidator: data real ---")
	var data: Dictionary = _cargar()
	var errores: Array = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))
	_fin("validator")

func _test_validator_errores() -> void:
	print("--- FundamentalsValidator: errores detectados ---")
	var malo: Dictionary = {
		"fundamentos": [
			{"id": "", "titulo": "", "detalle": ""}
		],
		"politicas": {}
	}
	var errores: Array = _SC_VALIDATOR.validar(malo)
	_check("sin id detectado", str(errores).contains("sin id"))
	_check("sin título detectado", str(errores).contains("sin título"))
	_check("sin detalle detectado", str(errores).contains("sin detalle"))
	_check("sin políticas detectado", str(errores).contains("políticas"))
	_fin("errores")

func _summary() -> void:
	# Capa 1: bloques que no cerraron.
	for b in BLOQUES:
		if not _vistos.has(b):
			_fallos += 1
			print("[FAIL] el bloque '%s' NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)" % b)
	# Capa 3: piso de checks.
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d): corrida INCOMPLETA" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M01: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M01 FALLIDO - salida con codigo 1")
		quit(1)
	else:
		print("TEST M01 OK - todos los checks pasaron")
		quit(0)
