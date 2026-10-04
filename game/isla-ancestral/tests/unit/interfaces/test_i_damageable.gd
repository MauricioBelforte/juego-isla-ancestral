# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M111: Unit tests IDamageable (interfaz)
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
#   godot --headless --path game/isla-ancestral --script res://tests/unit/interfaces/test_i_damageable.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 16
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']


## Unit tests para la interfaz IDamageable (M111)
## Verifica que la interfaz define los métodos esperados

# Fix BUG-051 (atria-dawn, 2026-09-18): GDScript no permite declarar clases
# dentro de funciones; la clase CustomDamageable estaba dentro de
# test_inheritance_implements_all_methods y era un parse error (el script
# nunca compilo). Movida a ambito de archivo.
class CustomDamageable extends IDamageable:
	var _health: float = 100.0
	var _max_health: float = 100.0

	func take_damage(amount: float, damage_type: StringName = &"", source: Node = null) -> float:
		_health = max(0.0, _health - amount)
		return amount

	func get_health() -> float:
		return _health

	func get_max_health() -> float:
		return _max_health

	func is_alive() -> bool:
		return _health > 0.0

	func heal(amount: float) -> float:
		var old_health = _health
		_health = min(_max_health, _health + amount)
		return _health - old_health

	func set_health(value: float) -> void:
		_health = clamp(value, 0.0, _max_health)


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
	_ini("A. test_take_damage_default")
	var damageable = IDamageable.new()
	var result = damageable.take_damage(10.0)
	_check("result .is_equal_to(0.0)", (result) == (0.0))

	_fin("A. test_take_damage_default")


func _bloque_B() -> void:
	_ini("B. test_get_health_default")
	var damageable = IDamageable.new()
	var health = damageable.get_health()
	_check("health .is_equal_to(0.0)", (health) == (0.0))

	_fin("B. test_get_health_default")


func _bloque_C() -> void:
	_ini("C. test_get_max_health_default")
	var damageable = IDamageable.new()
	var max_health = damageable.get_max_health()
	_check("max_health .is_equal_to(100.0)", (max_health) == (100.0))

	_fin("C. test_get_max_health_default")


func _bloque_D() -> void:
	_ini("D. test_is_alive_default")
	var damageable = IDamageable.new()
	var alive = damageable.is_alive()
	_check("alive .is_false()", (alive) == false)

	_fin("D. test_is_alive_default")


func _bloque_E() -> void:
	_ini("E. test_heal_default")
	var damageable = IDamageable.new()
	var healed = damageable.heal(10.0)
	_check("healed .is_equal_to(0.0)", (healed) == (0.0))

	_fin("E. test_heal_default")


func _bloque_F() -> void:
	_ini("F. test_set_health_default")
	var damageable = IDamageable.new()
	damageable.set_health(50.0)

	_fin("F. test_set_health_default")


func _bloque_G() -> void:
	_ini("G. test_inheritance_implements_all_methods")
	var custom = CustomDamageable.new()
	_check("custom.get_health() .is_equal_to(100.0)", (custom.get_health()) == (100.0))
	_check("custom.get_max_health() .is_equal_to(100.0)", (custom.get_max_health()) == (100.0))
	_check("custom.is_alive() .is_true()", (custom.is_alive()) == true)

	var damage = custom.take_damage(30.0)
	_check("damage .is_equal_to(30.0)", (damage) == (30.0))
	_check("custom.get_health() .is_equal_to(70.0)", (custom.get_health()) == (70.0))

	var healed = custom.heal(20.0)
	_check("healed .is_equal_to(20.0)", (healed) == (20.0))
	_check("custom.get_health() .is_equal_to(90.0)", (custom.get_health()) == (90.0))

	custom.set_health(0.0)
	_check("custom.is_alive() .is_false()", (custom.is_alive()) == false)

	_fin("G. test_inheritance_implements_all_methods")


func _bloque_H() -> void:
	_ini("H. test_health_changed_signal_exists")
	var damageable = IDamageable.new()
	_check("damageable.has_signal(\"health_changed\") .is_true()", (damageable.has_signal("health_changed")) == true)

	_fin("H. test_health_changed_signal_exists")


func _bloque_I() -> void:
	_ini("I. test_died_signal_exists")
	var damageable = IDamageable.new()
	_check("damageable.has_signal(\"died\") .is_true()", (damageable.has_signal("died")) == true)

	_fin("I. test_died_signal_exists")
