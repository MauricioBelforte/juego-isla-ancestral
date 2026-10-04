# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M111: Unit tests IInteractable (interfaz)
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
#   godot --headless --path game/isla-ancestral --script res://tests/unit/interfaces/test_i_interactable.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 11
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F']


## Unit tests para la interfaz IInteractable (M111)
## Verifica que la interfaz define los métodos esperados

# Fix BUG-051 (atria-dawn, 2026-09-18): GDScript no permite declarar clases
# dentro de funciones; CustomInteractable estaba dentro de
# test_inheritance_implements_all_methods y era un parse error.
class CustomInteractable extends IInteractable:
	func interact(interactor: Node) -> bool:
		return true

	func get_interaction_prompt(interactor: Node) -> String:
		return "Custom Prompt"

	func is_interactable(interactor: Node) -> bool:
		return false

	func get_interaction_priority() -> int:
		return 10

	func get_interaction_range() -> float:
		return 5.0


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
	_ini("A. test_interact_default")
	var interactable = IInteractable.new()
	var result = interactable.interact(null)
	_check("result .is_false()", (result) == false)

	_fin("A. test_interact_default")


func _bloque_B() -> void:
	_ini("B. test_get_interaction_prompt_default")
	var interactable = IInteractable.new()
	var prompt = interactable.get_interaction_prompt(null)
	_check("prompt .is_equal_to(\"\")", (prompt) == (""))

	_fin("B. test_get_interaction_prompt_default")


func _bloque_C() -> void:
	_ini("C. test_is_interactable_default")
	var interactable = IInteractable.new()
	var result = interactable.is_interactable(null)
	_check("result .is_true()", (result) == true)

	_fin("C. test_is_interactable_default")


func _bloque_D() -> void:
	_ini("D. test_get_interaction_priority_default")
	var interactable = IInteractable.new()
	var priority = interactable.get_interaction_priority()
	_check("priority .is_equal_to(0)", (priority) == (0))

	_fin("D. test_get_interaction_priority_default")


func _bloque_E() -> void:
	_ini("E. test_get_interaction_range_default")
	var interactable = IInteractable.new()
	var interaction_range = interactable.get_interaction_range()
	_check("interaction_range .is_equal_to(2.0)", (interaction_range) == (2.0))

	_fin("E. test_get_interaction_range_default")


func _bloque_F() -> void:
	_ini("F. test_inheritance_implements_all_methods")
	var custom = CustomInteractable.new()
	_check("custom.interact(null) .is_true()", (custom.interact(null)) == true)
	_check("custom.get_interaction_prompt(null) .is_equal_to(\"Custom Prompt\")", (custom.get_interaction_prompt(null)) == ("Custom Prompt"))
	_check("custom.is_interactable(null) .is_false()", (custom.is_interactable(null)) == false)
	_check("custom.get_interaction_priority() .is_equal_to(10)", (custom.get_interaction_priority()) == (10))
	_check("custom.get_interaction_range() .is_equal_to(5.0)", (custom.get_interaction_range()) == (5.0))

	_fin("F. test_inheritance_implements_all_methods")
