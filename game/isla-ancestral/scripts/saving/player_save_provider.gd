# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M59: Guardado — PlayerSaveProvider (sección "player" del schema).
# Guarda/restaura la posición del jugador (I4: posición, zona, spawn).
# Búsqueda perezosa del nodo "Player" en la escena actual; sin-op grácil
# cuando no existe (tests headless sin mundo, menú, etc.).
# Campos según SaveSchema.default_payload: name/position/spawn_position/zone.
#
# M59 iter. 2/3 (DeepSeek-V4.1-Flash, 2026-10-02): contrato COMPLETO y honesto.
# Medido con un nodo Player inyectado (Log 1202): antes se GUARDABA
# `spawn_position` pero `restore_save_data()` solo restauraba `position`, y
# `spawn_position` era siempre una copia de la posición actual. Ahora:
#  - `spawn_position` y `zone` se leen/restauran SOLO si el nodo las expone
#    (duck-typing). El Player actual no las tiene -> se documenta que
#    `spawn_position` es un punto de reanudación, no un spawn real.
#  - NUNCA se asigna `name`: en un Node, `name` es Node.name y asignarlo
#    RENOMBRARÍA el nodo, rompiendo el `find_child("Player")` del próximo guardado.
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


## true si el nodo expone la propiedad (duck-typing). El Player actual NO tiene
## spawn_position/zone; solo se guardan/restauran si existen, para no inventar
## contrato ni escribir propiedades inexistentes.
func _tiene(nodo: Node3D, prop: String) -> bool:
	return prop in nodo


func get_save_data() -> Dictionary:
	var jugador := _buscar_jugador()
	if jugador == null:
		return {}
	var pos := jugador.global_position
	# spawn_position: si el nodo lo expone se usa; si no, se guarda la posición
	# actual como punto de reanudación (el schema exige la clave presente).
	var spawn := pos
	if _tiene(jugador, "spawn_position"):
		var v: Variant = jugador.get("spawn_position")
		if v is Vector3:
			spawn = v
	var zona := ""
	if _tiene(jugador, "zone"):
		zona = String(jugador.get("zone"))
	return {
		"name": "",
		"position": [pos.x, pos.y, pos.z],
		"spawn_position": [spawn.x, spawn.y, spawn.z],
		"zone": zona,
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
	# spawn_position / zone: solo si el nodo las expone (duck-typing).
	if _tiene(jugador, "spawn_position"):
		var sp: Array = data.get("spawn_position", [])
		if sp.size() == 3:
			jugador.set("spawn_position", Vector3(float(sp[0]), float(sp[1]), float(sp[2])))
	if _tiene(jugador, "zone"):
		jugador.set("zone", String(data.get("zone", "")))
	# NO se toca "name" (ver cabecera): renombraría el nodo.
