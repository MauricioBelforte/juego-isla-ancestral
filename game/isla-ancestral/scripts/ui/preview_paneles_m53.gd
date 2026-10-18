# preview_paneles_m53.gd — script de PRUEBA visual (scripts-prueba, M53 D102b)
# Monta el UIRoot REAL (como main_island.gd L61-66) y abre PauseLayer vía
# UIManager para capturar el aspecto actual de los paneles (theme cozy D102).
# Uso: godot --path . res://tests/preview_paneles_m53.tscn  (o MCP run_project scene=...)
# Se borra al cerrar el frente del rediseño visual.
extends Node

func _ready() -> void:
	var ui_root_script := load("res://scripts/ui/ui_root.gd")
	if ui_root_script == null:
		push_error("[PREVIEW] no se pudo cargar ui_root.gd")
		return
	var ui_root: Node = ui_root_script.new()
	ui_root.name = "UIRoot"
	add_child(ui_root)

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout

	var um := get_node_or_null("/root/UIManager")
	if um == null:
		push_error("[PREVIEW] UIManager autoload ausente")
		return
	var pausa: Node = null
	for capa in um._stack:
		if capa != null and capa.name == "PauseLayer":
			pausa = capa
			break
	if pausa == null:
		push_error("[PREVIEW] PauseLayer no registrada (stack vacío o distinto)")
		return
	pausa.open()
	print("[PREVIEW] PauseLayer abierta para captura visual (tema cozy actual)")
