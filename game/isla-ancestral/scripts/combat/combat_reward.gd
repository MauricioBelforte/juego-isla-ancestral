# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1 — parte data-driven): CombatReward — recompensa exclusiva
# de la Isla de Combate. TODAS son cosméticas (F.7: no dan ventajas
# mecanicas). Se persisten en M59 (seccion recompensas_m164).
class_name CombatReward
extends Resource

enum Tipo { SKIN, TITULO, DECORACION, HERRAMIENTA, MONTURA }

@export var id: String = ""
@export var display_name_key: String = ""
@export var tipo: Tipo = Tipo.SKIN
## Condicion de desbloqueo legible (ej: "derrotar_guardian_montana").
@export var unlock_condition: String = ""
## Item M159 que se entrega al inventario (vacío = solo bandera/cosmetico).
@export var item_id: String = ""
## Modulo que aplica el cosmetico (M155 skins, M18 decoraciones, M14 items).
@export var modulo_aplicacion: String = ""

func es_valido() -> bool:
	return id != "" and display_name_key != "" and unlock_condition != "" \
		and tipo >= 0

## Recompensas por defecto del diseno (seccion F del checklist).
## Retorna Array[CombatReward] con las 6 exclusivas (F.1-F.6).
static func recompensas_por_defecto() -> Array[CombatReward]:
	var out: Array[CombatReward] = []
	_out(out, "skin_guerrero_ancestral", "M164.SKIN_GUERRERO", Tipo.SKIN,
		"derrotar_guardian_montana", "", "M155")
	_out(out, "skin_senor_del_templo", "M164.SKIN_TEMPLO", Tipo.SKIN,
		"derrotar_senor_del_templo", "", "M155")
	_out(out, "titulo_cazador_de_cristal", "M164.TITULO_CAZADOR", Tipo.TITULO,
		"derrotar_100_enemigos", "", "M71")
	_out(out, "decoracion_estandarte", "M164.ESTANDARTE", Tipo.DECORACION,
		"completar_isla_100", "", "M18")
	_out(out, "herramienta_filo_ancestral", "M164.FILO_ANCESTRAL", Tipo.HERRAMIENTA,
		"recompensa_jefe", "f" + "ilo_ancestral", "M14")
	_out(out, "montura_corcel_de_batalla", "M164.CORCEL", Tipo.MONTURA,
		"recompensa_jefe_final", "", "M155")
	return out

static func _out(arr: Array[CombatReward], p_id: String, p_key: String,
		p_tipo: Tipo, p_cond: String, p_item: String, p_mod: String) -> void:
	var r := CombatReward.new()
	r.id = p_id
	r.display_name_key = p_key
	r.tipo = p_tipo
	r.unlock_condition = p_cond
	r.item_id = p_item
	r.modulo_aplicacion = p_mod
	arr.append(r)
