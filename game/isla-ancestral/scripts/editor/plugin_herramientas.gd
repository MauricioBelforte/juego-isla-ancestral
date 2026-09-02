# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M109: Plugin de Herramientas Internas — registra el dock del editor con el
# catálogo de editores (RF1). En esta iteración: Editor de Recetas operativo;
# los demás editores se suman siguiendo el patrón EditorBase (registro único).

@tool
extends EditorPlugin

const RECIPE_TOOL = preload("res://scripts/editor/tools/recipe_tool.gd")

var _dock: PanelContainer

func _enter_tree() -> void:
	_dock = RECIPE_TOOL.new()
	_dock.name = "HerramientasInternas"
	add_control_to_dock(DOCK_SLOT_BOTTOM_LEFT, _dock)
	print("[M109] Plugin de herramientas internas activado (Editor de Recetas)")

func _exit_tree() -> void:
	if _dock:
		remove_control_from_docks(_dock)
		_dock.free()
