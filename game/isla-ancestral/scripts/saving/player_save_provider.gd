# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M59: Guardado — PlayerSaveProvider (sección "player" del schema).
# Guarda/restaura la posición del jugador (I4: posición, zona, spawn).
# Búsqueda perezosa del nodo "Player" en la escena actual; sin-op grácil
# cuando no existe (tests headless sin mundo, menú, etc.).
# Campos según SaveSchema.default_payload: name/position/spawn_position/zone.
class_name PlayerSaveProvider
extends RefCounted


func get_section_name() -> String:
	return "player"


func _buscar_jugador() -> Node3D:
	var arbol := Engine.get_main_loop() as SceneTree
	if arbol == null:
		return null
	# Búsqueda desde root: Bootstrap carga la escena manualmente y
	# current_scene puede no estar asignado en modo headless/--script.
	return arbol.root.find_child("Player", true, false) as Node3D


func get_save_data() -> Dictionary:
	var jugador := _buscar_jugador()
	if jugador == null:
		return {}
	var pos := jugador.global_position
	return {
		"name": "",
		"position": [pos.x, pos.y, pos.z],
		"spawn_position": [pos.x, pos.y, pos.z],
		"zone": "",
	}


func restore_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	var jugador := _buscar_jugador()
	if jugador == null:
		return
	var pos: Array = data.get("position", [])
	if pos.size() == 3:
		jugador.global_position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))
