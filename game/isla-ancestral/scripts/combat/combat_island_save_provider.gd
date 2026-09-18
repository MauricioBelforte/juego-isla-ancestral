# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1): CombatIslandSaveProvider — puente de persistencia M59
# para CombatIslandSystem (zonas desbloqueadas, derrotas, recompensas).
# Patron separado AGENTS.md §15 (mismo que ToolsSaveProvider de M13).
class_name CombatIslandSaveProvider
extends RefCounted

const SECCION_SAVE := "isla_combate_m164"

var sistema_ref = null

func _init(p_ref = null) -> void:
	sistema_ref = p_ref

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	if sistema_ref == null:
		return {}
	return sistema_ref.get_save_data()

func restore_save_data(data: Dictionary) -> void:
	if sistema_ref == null:
		return
	sistema_ref.restore_save_data(data)
