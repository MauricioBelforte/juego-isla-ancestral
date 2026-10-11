# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-09
#
# M64 / BUG-129 (causa raíz) — medición de huérfanos del boot.
#
# Hipótesis verificada en disco: npc_agent.gd instancia 8 estados con .new() y
# state_machine.register_state() los guarda en _states SIN add_child → los 56
# Nodes (7 NPCs × 8 estados) nunca entran al árbol → GdUnit los cuenta como
# huérfanos al cerrar (BUG-129).
#
# Este harness corre SOLO con el binario (igual que test_m56):
#   Godot --headless --path game/isla-ancestral --script scripts/ia_npc/test_bug129_estados_orphan.gd
#
# Mide los huérfanos del boot DESPUÉS de varios frames (cuando VillagerManager
# pobló y NPCManager registró agentes) y clasifica por familia:
#   - estados ia_npc/states/*.gd  → el leak de M64 (objeto del fix)
#   - MeshInstance3D / Node3D     → mallas GLB de villagers (M19, fuera de alcance)
#   - resto
# Exit code: 0 si states_orphans == 0 (criterio de cierre M64), 1 si quedan.
extends SceneTree

const FRAMES_ESPERA: int = 40


func _initialize() -> void:
	# Dejar que Bootstrap cargue main_island y la población asiente.
	for i in FRAMES_ESPERA:
		await process_frame
	await create_timer(1.0).timeout

	var root_node: Node = root
	var ids: Array = root_node.get_orphan_node_ids()
	var states_orphans: int = 0
	var mesh_orphans: int = 0
	var node3d_orphans: int = 0
	var otros: int = 0
	var ejemplos_states: Array[String] = []

	for id in ids:
		var n := instance_from_id(id) as Node
		if n == null or n.is_queued_for_deletion():
			continue
		var scr := n.get_script() as Script
		var path := ""
		if scr != null:
			path = scr.resource_path
		if path.contains("ia_npc/states/"):
			states_orphans += 1
			if ejemplos_states.size() < 3:
				ejemplos_states.append("%s (%s)" % [n.name, path.get_file()])
		elif n is MeshInstance3D:
			mesh_orphans += 1
		elif n is Node3D:
			node3d_orphans += 1
		else:
			otros += 1

	print("[BUG129-MEDICION] total_strays=%d states=%d mesh=%d node3d=%d otros=%d" % [
		ids.size(), states_orphans, mesh_orphans, node3d_orphans, otros,
	])
	if not ejemplos_states.is_empty():
		print("[BUG129-MEDICION] ejemplos_states: %s" % str(ejemplos_states))
	print("[BUG129-MEDICION] npc_manager_agents=%d" % _contar_agentes())

	if states_orphans == 0:
		print("[BUG129-MEDICION] RESULTADO: states orphans = 0 (criterio M64 cumplido)")
		quit(0)
	else:
		print("[BUG129-MEDICION] RESULTADO: quedan %d states orphans (leak activo)" % states_orphans)
		quit(1)


func _contar_agentes() -> int:
	var nm := root.get_node_or_null("NPCManager")
	if nm != null and nm.has_method("get_agent_count"):
		return nm.get_agent_count()
	return -1
