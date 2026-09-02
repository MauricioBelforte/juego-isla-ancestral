extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para M156 - Terrenos y Movimiento

func test_terrain_modifiers_calculate_effective_speed() -> void:
	var speed := TerrainModifiers.calculate_effective_speed(5.0, 0.8, 0.2)
	assert_that(speed).is_equal_to(4.2)

func test_terrain_modifiers_clamp_negative() -> void:
	var speed := TerrainModifiers.calculate_effective_speed(1.0, 0.1, -2.0)
	assert_that(speed).is_greater_than(0.0)

func test_terrain_data_provider_speed_modifier_ceped() -> void:
	var provider := TerrainDataProvider.new()
	provider._ready()
	assert_that(provider.get_speed_modifier(0)).is_equal_to(1.0)

func test_terrain_data_provider_speed_modifier_barro() -> void:
	var provider := TerrainDataProvider.new()
	provider._ready()
	assert_that(provider.get_speed_modifier(1)).is_equal_to(0.6)

func test_terrain_data_provider_fallback_terreno_inexistente() -> void:
	var provider := TerrainDataProvider.new()
	provider._ready()
	assert_that(provider.get_speed_modifier(999)).is_equal_to(1.0)
