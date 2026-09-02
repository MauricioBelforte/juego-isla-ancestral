# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M74: Eventos — Definición de recompensa
#
# Cada recompensa especifica qué entregar y cómo.

extends Resource
class_name RecompensaDef

enum TipoRecompensa { OBJETO, COLECCION, MONEDA, AMISTAD, PROGRESO, FERIA }

@export var tipo: TipoRecompensa = TipoRecompensa.OBJETO
@export var cantidad: int = 1
@export var id_item: StringName = &""       # M14 item ID
@export var id_npc: StringName = &""        # M20 NPC para amistad
@export var moneda: StringName = &""        # M38 moneda de feria
@export var progreso_id: StringName = &""   # M71 progreso ID
@export var clave_recuerdo: StringName = &"" # M37 galería de recuerdos
@export var bonus_amistad: int = 0          # Puntos directos de amistad

## Entregar la recompensa. Retorna true si se entregó exitosamente.
## El EventManager se encarga de llamar a los módulos correctos.
func entregar(event_manager, contexto: Dictionary = {}) -> bool:
	match tipo:
		TipoRecompensa.OBJETO:
			if id_item != &"":
				var inv = event_manager.get_node_or_null("/root/Inventario")
				if inv != null and inv.has_method("agregar"):
					inv.agregar(str(id_item), cantidad)
					return true
			return false
		TipoRecompensa.MONEDA:
			if moneda != &"":
				var eco = event_manager.get_node_or_null("/root/EconomyManager")
				if eco != null and eco.has_method("suministrar_moneda"):
					eco.suministrar_moneda(str(moneda), cantidad)
					return true
			return false
		TipoRecompensa.AMISTAD:
			if id_npc != &"" and bonus_amistad > 0:
				var fs = event_manager.get_node_or_null("/root/Friendship")
				if fs != null and fs.has_method("modificar"):
					fs.modificar(str(id_npc), bonus_amistad)
					return true
			return false
		TipoRecompensa.PROGRESO:
			if progreso_id != &"":
				# M71 ProgressionService — placeholder
				return true
			return false
		TipoRecompensa.FERIA:
			if moneda != &"":
				var eco = event_manager.get_node_or_null("/root/EconomyManager")
				if eco != null and eco.has_method("suministrar_moneda"):
					eco.suministrar_moneda(str(moneda), cantidad)
					return true
			return false
		TipoRecompensa.COLECCION:
			if clave_recuerdo != &"":
				# M37 Museo: registrar recuerdo
				var museo = event_manager.get_node_or_null("/root/Museo")
				if museo != null and museo.has_method("registrar_recuerdo"):
					museo.registrar_recuerdo({"clave": str(clave_recuerdo), "evento_id": contexto.get("evento_id", "")})
					return true
			return false
		_:
			return false
	return false


func to_dict() -> Dictionary:
	return {
		"tipo": tipo,
		"cantidad": cantidad,
		"id_item": str(id_item),
		"id_npc": str(id_npc),
		"moneda": str(moneda),
		"progreso_id": str(progreso_id),
		"clave_recuerdo": str(clave_recuerdo),
		"bonus_amistad": bonus_amistad,
	}


static func from_dict(d: Dictionary) -> RecompensaDef:
	var r := RecompensaDef.new()
	r.tipo = int(d.get("tipo", 0))
	r.cantidad = int(d.get("cantidad", 1))
	r.id_item = d.get("id_item", &"")
	r.id_npc = d.get("id_npc", &"")
	r.moneda = d.get("moneda", &"")
	r.progreso_id = d.get("progreso_id", &"")
	r.clave_recuerdo = d.get("clave_recuerdo", &"")
	r.bonus_amistad = int(d.get("bonus_amistad", 0))
	return r
