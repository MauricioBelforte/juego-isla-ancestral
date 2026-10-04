# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M111: Unit tests ISaveable (interfaz)
#
# CONVERTIDO de gdUnit4 a headless (BUG-093, sub-frente) por convertir.py.
# Motivo: la suite gdUnit4 PARSEABA pero MORIA en runtime (metodos
# inexistentes: is_equal_to/is_greater_than/is_instance_of/has_not_contains/
# has_any_item -> 0 apariciones en addons/gdUnit4/). Ademas las suites gdUnit4
# NO se ejecutan en el CI del proyecto (solo `--script`, estandar 12.1).
#
# Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS
# MEDIDO + _summary() en call_deferred SEPARADO + watchdog.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/unit/interfaces/test_i_saveable.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 15
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']


## Unit tests para la interfaz ISaveable (M111)
## Verifica que la interfaz define los métodos esperados

# Fix BUG-051 (atria-dawn, 2026-09-18): GDScript no permite declarar clases
# dentro de funciones; CustomSaveable estaba dentro de
# test_inheritance_implements_all_methods y era un parse error.
class CustomSaveable extends ISaveable:
	var _data: Dictionary = {}
	var _dirty: bool = false
	var _save_id: String = "custom_saveable_001"
	var _version: int = 2

	func get_save_data() -> Dictionary:
		return _data.duplicate(true)

	func load_save_data(data: Dictionary, version: int = 1) -> void:
		_data = data.duplicate(true)
		_dirty = false

	func get_save_id() -> String:
		return _save_id

	func get_save_version() -> int:
		return _version

	func has_unsaved_changes() -> bool:
		return _dirty

	func mark_saved() -> void:
		_dirty = false

	func validate_save_data(data: Dictionary) -> bool:
		return data.has("required_field")


var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== M111 (headless) ===")
	_bloque_A()
	_bloque_B()
	_bloque_C()
	_bloque_D()
	_bloque_E()
	_bloque_F()
	_bloque_G()
	_bloque_H()
	_bloque_I()
	_bloque_J()


func _on_watchdog() -> void:
	_abortado = true
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("todos los bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen M111: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


func _bloque_A() -> void:
	_ini("A. test_get_save_data_default")
	var saveable = ISaveable.new()
	var data = saveable.get_save_data()
	_check("data .is_instance_of(Dictionary)", (data) is Dictionary)
	_check("data.size() .is_equal_to(0)", (data.size()) == (0))

	_fin("A. test_get_save_data_default")


func _bloque_B() -> void:
	_ini("B. test_load_save_data_default")
	var saveable = ISaveable.new()
	saveable.load_save_data({}, 1)

	_fin("B. test_load_save_data_default")


func _bloque_C() -> void:
	_ini("C. test_get_save_id_default")
	var saveable = ISaveable.new()
	var id = saveable.get_save_id()
	_check("id .is_equal_to(\"\")", (id) == (""))

	_fin("C. test_get_save_id_default")


func _bloque_D() -> void:
	_ini("D. test_get_save_version_default")
	var saveable = ISaveable.new()
	var version = saveable.get_save_version()
	_check("version .is_equal_to(1)", (version) == (1))

	_fin("D. test_get_save_version_default")


func _bloque_E() -> void:
	_ini("E. test_has_unsaved_changes_default")
	var saveable = ISaveable.new()
	var has_changes = saveable.has_unsaved_changes()
	_check("has_changes .is_false()", (has_changes) == false)

	_fin("E. test_has_unsaved_changes_default")


func _bloque_F() -> void:
	_ini("F. test_mark_saved_default")
	var saveable = ISaveable.new()
	saveable.mark_saved()

	_fin("F. test_mark_saved_default")


func _bloque_G() -> void:
	_ini("G. test_validate_save_data_default")
	var saveable = ISaveable.new()
	var valid = saveable.validate_save_data({})
	_check("valid .is_true()", (valid) == true)

	_fin("G. test_validate_save_data_default")


func _bloque_H() -> void:
	_ini("H. test_inheritance_implements_all_methods")
	var custom = CustomSaveable.new()
	_check("custom.get_save_id() .is_equal_to(\"custom_saveable_001\")", (custom.get_save_id()) == ("custom_saveable_001"))
	_check("custom.get_save_version() .is_equal_to(2)", (custom.get_save_version()) == (2))
	_check("custom.has_unsaved_changes() .is_false()", (custom.has_unsaved_changes()) == false)

	var test_data = {"required_field": "value", "other": 123}
	custom.load_save_data(test_data, 2)
	_check("custom.get_save_data() .is_equal_to(test_data)", (custom.get_save_data()) == (test_data))
	_check("custom.validate_save_data(test_data) .is_true()", (custom.validate_save_data(test_data)) == true)
	_check("custom.validate_save_data({}) .is_false()", (custom.validate_save_data({})) == false)

	_fin("H. test_inheritance_implements_all_methods")


func _bloque_I() -> void:
	_ini("I. test_saved_signal_exists")
	var saveable = ISaveable.new()
	_check("saveable.has_signal(\"saved\") .is_true()", (saveable.has_signal("saved")) == true)

	_fin("I. test_saved_signal_exists")


func _bloque_J() -> void:
	_ini("J. test_loaded_signal_exists")
	var saveable = ISaveable.new()
	_check("saveable.has_signal(\"loaded\") .is_true()", (saveable.has_signal("loaded")) == true)

	_fin("J. test_loaded_signal_exists")
