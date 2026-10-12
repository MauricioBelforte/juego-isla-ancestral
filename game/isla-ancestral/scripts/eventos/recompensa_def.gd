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

## Deriva el sobrante de una entrega al buzón de M74 (RF6.9).
## Devuelve true si el sobrante quedó en el buzón (la entrega se considera
## completa: el jugador lo recibirá al reclamar), false si no hay buzón.
func _al_buzon(event_manager, contexto: Dictionary, cantidad_pendiente: int) -> bool:
	if cantidad_pendiente <= 0:
		return true
	if event_manager == null or not event_manager.has_method("buzon"):
		return false
	var buzon = event_manager.buzon()
	if buzon == null:
		return false
	var sobrante := to_dict()
	sobrante["cantidad"] = int(cantidad_pendiente)
	var dia: int = int((contexto.get("dia_absoluto", 0)))
	buzon.agregar(StringName(str(contexto.get("evento_id", ""))), sobrante, dia)
	return true


## Entregar la recompensa. Retorna true si se entregó exitosamente.
## El EventManager se encarga de llamar a los módulos correctos.
##
## APIs REALES (verificadas contra los modulos destino, 2026-10-11):
##   M14 Inventario      -> add_item(id, cantidad) o agregar_items(Dictionary)
##   M38 EconomyManager  -> depositar_monedas(total)
## Las firmas anteriores (`agregar(id, cantidad)`, `suministrar_moneda`) NO
## existian en los modulos reales: la entrega fallaba en silencio y el
## anti-duplicado nunca marcaba la recompensa. Se prueba por duck-typing con
## varias firmas candidatas para no romper si M14/M38 renombran metodos.
func entregar(event_manager, contexto: Dictionary = {}) -> bool:
	match tipo:
		TipoRecompensa.OBJETO:
			if id_item == &"":
				return false
			var inv = event_manager.get_node_or_null("/root/Inventario")
			if inv == null:
				return false
			var restante: int = -1
			if inv.has_method("add_item"):
				# M14 devuelve `restante`: lo que NO entró (0 = entró todo).
				restante = int(inv.add_item(String(id_item), int(cantidad)))
			elif inv.has_method("agregar_items"):
				if bool(inv.agregar_items({String(id_item): int(cantidad)})):
					return true
				restante = int(cantidad)
			if restante == null or int(restante) <= 0:
				return true
			# Inventario lleno: el resto va al buzón (RF6.9). Si no hay buzón
			# disponible, la entrega es parcial y se reporta como fallo.
			return _al_buzon(event_manager, contexto, int(restante))
		TipoRecompensa.MONEDA, TipoRecompensa.FERIA:
			if moneda == &"":
				return false
			var eco = event_manager.get_node_or_null("/root/EconomyManager")
			if eco == null:
				return false
			if eco.has_method("depositar_monedas"):
				eco.depositar_monedas(int(cantidad))
				return true
			if eco.has_method("suministrar_moneda"):
				eco.suministrar_moneda(String(moneda), int(cantidad))
				return true
			return false
		TipoRecompensa.AMISTAD:
			# M20 no expone un metodo publico de "sumar puntos": aplica puntos
			# desde sus propios flujos (charlar, regalos, cumpleanos). Se deja
			# el gancho por duck-typing para cuando M20 lo exponga.
			if id_npc == &"" or bonus_amistad <= 0:
				return false
			var fs = event_manager.get_node_or_null("/root/Friendship")
			if fs != null and fs.has_method("modificar"):
				fs.modificar(String(id_npc), int(bonus_amistad))
				return true
			if fs != null and fs.has_method("sumar_puntos"):
				fs.sumar_puntos(String(id_npc), int(bonus_amistad))
				return true
			push_warning("[M74] recompensa AMISTAD sin destino: M20 no expone sumar_puntos/modificar")
			return false
		TipoRecompensa.PROGRESO:
			if progreso_id == &"":
				return false
			# M71 ProgressionManager: sin metodo publico para sumar progreso de
			# evento. Se deja el gancho; hasta entonces NO se marca entregada.
			var prog = event_manager.get_node_or_null("/root/ProgressionManager")
			if prog != null and prog.has_method("registrar_progreso_evento"):
				prog.registrar_progreso_evento(String(progreso_id), int(cantidad))
				return true
			push_warning("[M74] recompensa PROGRESO sin destino: M71 sin registrar_progreso_evento")
			return false
		TipoRecompensa.COLECCION:
			if clave_recuerdo == &"":
				return false
			var museo = event_manager.get_node_or_null("/root/Museo")
			if museo != null and museo.has_method("registrar_recuerdo"):
				museo.registrar_recuerdo({"clave": String(clave_recuerdo), "evento_id": str(contexto.get("evento_id", ""))})
				return true
			push_warning("[M74] recompensa COLECCION sin destino: no existe /root/Museo")
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
