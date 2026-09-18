# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1): GemSaveProvider — puente de persistencia M59 para
# GemCurrency (AGENTS.md §15: flujo separado, no refactoriza sistemas
# existentes; el provider expone accessors duck-typed como M13).
class_name GemSaveProvider
extends RefCounted

const SECCION_SAVE := "gemas_m164"

## Referencia al GemCurrency (autoload). Duck-typed para evitar
## dependencia de compilacion con combat_island_system.gd.
var gemas_ref = null

func _init(p_ref = null) -> void:
	gemas_ref = p_ref

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	if gemas_ref == null:
		return {}
	return gemas_ref.get_save_data()

func restore_save_data(data: Dictionary) -> void:
	if gemas_ref == null:
		return
	gemas_ref.restore_save_data(data)
