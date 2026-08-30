extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para la interfaz ISaveable (M111)
## Verifica que la interfaz define los métodos esperados

func test_get_save_data_default() -> void:
	var saveable = ISaveable.new()
	var data = saveable.get_save_data()
	assert_that(data).is_instance_of(Dictionary)
	assert_that(data.size()).is_equal_to(0)

func test_load_save_data_default() -> void:
	var saveable = ISaveable.new()
	saveable.load_save_data({}, 1)

func test_get_save_id_default() -> void:
	var saveable = ISaveable.new()
	var id = saveable.get_save_id()
	assert_that(id).is_equal_to("")

func test_get_save_version_default() -> void:
	var saveable = ISaveable.new()
	var version = saveable.get_save_version()
	assert_that(version).is_equal_to(1)

func test_has_unsaved_changes_default() -> void:
	var saveable = ISaveable.new()
	var has_changes = saveable.has_unsaved_changes()
	assert_that(has_changes).is_false()

func test_mark_saved_default() -> void:
	var saveable = ISaveable.new()
	saveable.mark_saved()

func test_validate_save_data_default() -> void:
	var saveable = ISaveable.new()
	var valid = saveable.validate_save_data({})
	assert_that(valid).is_true()

func test_inheritance_implements_all_methods() -> void:
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

	var custom = CustomSaveable.new()
	assert_that(custom.get_save_id()).is_equal_to("custom_saveable_001")
	assert_that(custom.get_save_version()).is_equal_to(2)
	assert_that(custom.has_unsaved_changes()).is_false()

	var test_data = {"required_field": "value", "other": 123}
	custom.load_save_data(test_data, 2)
	assert_that(custom.get_save_data()).is_equal_to(test_data)
	assert_that(custom.validate_save_data(test_data)).is_true()
	assert_that(custom.validate_save_data({})).is_false()

func test_saved_signal_exists() -> void:
	var saveable = ISaveable.new()
	assert_that(saveable.has_signal("saved")).is_true()

func test_loaded_signal_exists() -> void:
	var saveable = ISaveable.new()
	assert_that(saveable.has_signal("loaded")).is_true()
