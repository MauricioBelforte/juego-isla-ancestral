extends CanvasLayer
## M53 HUD — ActionPromptOverlay: overlay de prompts de acción dinámicos.

var _prompts: Array[String] = []

func set_prompts(prompts: Array[String]) -> void:
	_prompts = prompts
	_actualizar()

func add_prompt(text: String) -> void:
	_prompts.append(text)
	_actualizar()

func clear_prompts() -> void:
	_prompts = []
	_actualizar()

func _actualizar() -> void:
	var labels := get_children()
	for l in labels:
		l.queue_free()
	for i in _prompts.size():
		var lbl := Label.new()
		lbl.text = _prompts[i]
		lbl.position = Vector2(10, 10 + i * 24)
		add_child(lbl)
