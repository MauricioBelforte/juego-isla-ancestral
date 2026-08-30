extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para la interfaz IInteractable (M111)
## Verifica que la interfaz define los métodos esperados

func test_interact_default() -> void:
	var interactable = IInteractable.new()
	var result = interactable.interact(null)
	assert_that(result).is_false()

func test_get_interaction_prompt_default() -> void:
	var interactable = IInteractable.new()
	var prompt = interactable.get_interaction_prompt(null)
	assert_that(prompt).is_equal_to("")

func test_is_interactable_default() -> void:
	var interactable = IInteractable.new()
	var result = interactable.is_interactable(null)
	assert_that(result).is_true()

func test_get_interaction_priority_default() -> void:
	var interactable = IInteractable.new()
	var priority = interactable.get_interaction_priority()
	assert_that(priority).is_equal_to(0)

func test_get_interaction_range_default() -> void:
	var interactable = IInteractable.new()
	var interaction_range = interactable.get_interaction_range()
	assert_that(interaction_range).is_equal_to(2.0)

func test_inheritance_implements_all_methods() -> void:
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

	var custom = CustomInteractable.new()
	assert_that(custom.interact(null)).is_true()
	assert_that(custom.get_interaction_prompt(null)).is_equal_to("Custom Prompt")
	assert_that(custom.is_interactable(null)).is_false()
	assert_that(custom.get_interaction_priority()).is_equal_to(10)
	assert_that(custom.get_interaction_range()).is_equal_to(5.0)
