# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M14: Inventario — InventorySlot
# item_id + cantidad + flags + instancia (para herramientas M13 con durabilidad).
# Skill godot-inventory-system: cantidades int, nunca mutar blueprints compartidos.

class_name InventorySlot
extends RefCounted

var item_id: String = ""          # vacio = slot libre
var cantidad: int = 0
var favorito: bool = false        # fijo ante sort; nunca sobrescrito por auto-apilado
var bloqueado: bool = false       # candado (tooltip explica desbloqueo)
## Datos de instancia para items NO apilables con estado propio
## (ej: ToolData.serializar() de una herramienta con durabilidad actual)
var instancia: Dictionary = {}

func esta_libre() -> bool:
	return item_id == "" or cantidad <= 0

func puede_apilar(cantidad_extra: int, stack_max: int) -> bool:
	return item_id != "" and (cantidad + cantidad_extra) <= stack_max

func ocupar(p_id: String, p_cantidad: int, p_instancia: Dictionary = {}) -> void:
	item_id = p_id
	cantidad = p_cantidad
	instancia = p_instancia.duplicate(true)

func vaciar() -> void:
	item_id = ""
	cantidad = 0
	instancia = {}

func serializar() -> Dictionary:
	if esta_libre():
		return {}
	var d := {"id": item_id, "n": cantidad}
	if favorito:
		d["fav"] = true
	if bloqueado:
		d["lock"] = true
	if not instancia.is_empty():
		d["inst"] = instancia.duplicate(true)
	return d

static func deserializar(d: Dictionary) -> InventorySlot:
	var s := InventorySlot.new()
	s.item_id = str(d.get("id", ""))
	s.cantidad = int(d.get("n", 0))
	s.favorito = bool(d.get("fav", false))
	s.bloqueado = bool(d.get("lock", false))
	var inst: Variant = d.get("inst", {})
	if typeof(inst) == TYPE_DICTIONARY:
		s.instancia = inst.duplicate(true)
	return s
