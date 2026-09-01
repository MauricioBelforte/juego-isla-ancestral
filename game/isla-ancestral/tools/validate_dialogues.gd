extends MainLoop
## Valida todos los grafos de dialogo en data/dialogues/.
## Ejecutar: godot --headless -s tools/validate_dialogues.gd

const DIALOGUE_DIR := "res://data/dialogues/"
const OUTPUT_PATH := "res://tools/validation_result.txt"

var _step := 0


func _init() -> void:
	pass


func _iteration(_delta: float) -> bool:
	_step += 1
	if _step == 1:
		_run_validation()
		return true
	return false


func _run_validation() -> void:
	var output := "=== Validador de Grafos de Dialogo ===\n"
	var dir := DirAccess.open(DIALOGUE_DIR)
	if dir == null:
		output += "ERROR: No se pudo abrir " + DIALOGUE_DIR + "\n"
		_write_output(output)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	var total := 0
	var errors := 0

	while file_name != "":
		if file_name.ends_with(".json"):
			total += 1
			var result := _validate_file(DIALOGUE_DIR + file_name)
			if result.size() > 0:
				errors += 1
				for err in result:
					output += "  [ERROR] " + file_name + ": " + err + "\n"
			else:
				output += "  [OK] " + file_name + "\n"
		file_name = dir.get_next()

	dir.list_dir_end()
	output += "\n=== Resultado: " + str(total) + " archivos, " + str(errors) + " con errores ===\n"
	_write_output(output)


func _write_output(text: String) -> void:
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(text)
		file.close()


func _validate_file(path: String) -> Array:
	var errors := []
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("No se pudo abrir el archivo")
		return errors

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		errors.append("JSON invalido: " + json.get_error_message())
		return errors

	var data := json.data
	if not data is Dictionary:
		errors.append("Root no es un Dictionary")
		return errors

	if not data.has("id"):
		errors.append("Falta campo 'id'")
	if not data.has("start"):
		errors.append("Falta campo 'start'")
	if not data.has("nodes"):
		errors.append("Falta campo 'nodes'")
		return errors

	var nodes: Dictionary = data["nodes"]
	if nodes.is_empty():
		errors.append("No hay nodos definidos")
		return errors

	if data.has("start") and not nodes.has(data["start"]):
		errors.append("start '" + str(data["start"]) + "' no existe en nodes")

	var visited := {}
	for node_id in nodes:
		var node: Dictionary = nodes[node_id]
		var node_errors := _validate_node(node_id, node, nodes, visited)
		errors.append_array(node_errors)

	for node_id in nodes:
		if node_id == data.get("start", ""):
			continue
		if not visited.has(node_id):
			errors.append("Nodo huerfano: '" + node_id + "' no es alcanzable desde start")

	return errors


func _validate_node(node_id: String, node: Dictionary, all_nodes: Dictionary, visited: Dictionary) -> Array:
	var errors := []

	if not node.has("tipo"):
		errors.append("Nodo '" + node_id + "': falta 'tipo'")
		return errors

	var tipo: int = node["tipo"]

	if not node.has("speaker_key"):
		errors.append("Nodo '" + node_id + "': falta 'speaker_key'")

	if tipo == 0:
		if not node.has("text_key"):
			errors.append("Nodo '" + node_id + "': speech sin 'text_key'")
		if node.has("next_id"):
			var next: String = node["next_id"]
			visited[next] = true
			if not all_nodes.has(next):
				errors.append("Nodo '" + node_id + "': next_id '" + next + "' no existe")

	elif tipo == 1:
		if not node.has("options"):
			errors.append("Nodo '" + node_id + "': choice sin 'options'")
		else:
			var options: Array = node["options"]
			if options.is_empty():
				errors.append("Nodo '" + node_id + "': choice con options vacio")
			for i in options.size():
				var opt: Dictionary = options[i]
				if not opt.has("next_id"):
					errors.append("Nodo '" + node_id + "': option[" + str(i) + "] sin 'next_id'")
				else:
					var next: String = opt["next_id"]
					visited[next] = true
					if not all_nodes.has(next):
						errors.append("Nodo '" + node_id + "': option[" + str(i) + "] next_id '" + next + "' no existe")

	elif tipo == 3:
		pass

	else:
		errors.append("Nodo '" + node_id + "': tipo desconocido " + str(tipo))

	return errors
