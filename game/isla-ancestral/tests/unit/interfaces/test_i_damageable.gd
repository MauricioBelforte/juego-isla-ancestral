extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para la interfaz IDamageable (M111)
## Verifica que la interfaz define los métodos esperados

func test_take_damage_default() -> void:
	var damageable = IDamageable.new()
	var result = damageable.take_damage(10.0)
	assert_that(result).is_equal_to(0.0)

func test_get_health_default() -> void:
	var damageable = IDamageable.new()
	var health = damageable.get_health()
	assert_that(health).is_equal_to(0.0)

func test_get_max_health_default() -> void:
	var damageable = IDamageable.new()
	var max_health = damageable.get_max_health()
	assert_that(max_health).is_equal_to(100.0)

func test_is_alive_default() -> void:
	var damageable = IDamageable.new()
	var alive = damageable.is_alive()
	assert_that(alive).is_false()

func test_heal_default() -> void:
	var damageable = IDamageable.new()
	var healed = damageable.heal(10.0)
	assert_that(healed).is_equal_to(0.0)

func test_set_health_default() -> void:
	var damageable = IDamageable.new()
	damageable.set_health(50.0)

func test_inheritance_implements_all_methods() -> void:
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

	var custom = CustomDamageable.new()
	assert_that(custom.get_health()).is_equal_to(100.0)
	assert_that(custom.get_max_health()).is_equal_to(100.0)
	assert_that(custom.is_alive()).is_true()

	var damage = custom.take_damage(30.0)
	assert_that(damage).is_equal_to(30.0)
	assert_that(custom.get_health()).is_equal_to(70.0)

	var healed = custom.heal(20.0)
	assert_that(healed).is_equal_to(20.0)
	assert_that(custom.get_health()).is_equal_to(90.0)

	custom.set_health(0.0)
	assert_that(custom.is_alive()).is_false()

func test_health_changed_signal_exists() -> void:
	var damageable = IDamageable.new()
	assert_that(damageable.has_signal("health_changed")).is_true()

func test_died_signal_exists() -> void:
	var damageable = IDamageable.new()
	assert_that(damageable.has_signal("died")).is_true()
