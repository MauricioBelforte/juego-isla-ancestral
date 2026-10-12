# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-12
#
# M121: Soporte Post-Lanzamiento — TicketManager
# Servicio de tickets de soporte: alta, cambio de estado, consulta y
# agrupacion. Diseno de referencia: 04-Codigo.md sec.6.
#
# Divergencia declarada con el diseno: en vez de autoload propio se implementa
# como RefCounted instanciado por SupportManager (no tocar project.godot).
# Estados y prioridades se validan contra las constantes del modulo.

class_name TicketManager
extends RefCounted

const ESTADOS := ["abierto", "en_triage", "en_progreso", "resuelto", "cerrado"]
const PRIORIDADES := ["critica", "alta", "media", "baja"]

signal ticket_created(ticket_id: String)
signal ticket_resolved(ticket_id: String)

var tickets: Dictionary = {}
var _contador: int = 0

func generate_ticket_id() -> String:
	_contador += 1
	return "T%06d" % _contador

func create_ticket(categoria: String, prioridad: String, descripcion: String, user_info: Dictionary = {}) -> String:
	var ticket_id := generate_ticket_id()
	tickets[ticket_id] = {
		"ticket_id": ticket_id,
		"categoria": categoria,
		"prioridad": prioridad if PRIORIDADES.has(prioridad) else "media",
		"descripcion": descripcion,
		"user_info": user_info.duplicate(true),
		"estado": "abierto",
		"historial": [{"estado": "abierto", "ts": Time.get_unix_time_from_system()}],
	}
	ticket_created.emit(ticket_id)
	return ticket_id

func update_ticket_status(ticket_id: String, estado: String) -> bool:
	if not tickets.has(ticket_id):
		return false
	if not ESTADOS.has(estado):
		return false
	var t: Dictionary = tickets[ticket_id]
	t["estado"] = estado
	var hist: Array = t.get("historial", [])
	hist.append({"estado": estado, "ts": Time.get_unix_time_from_system()})
	t["historial"] = hist
	if estado == "resuelto":
		ticket_resolved.emit(ticket_id)
	return true

func resolve_ticket(ticket_id: String) -> bool:
	return update_ticket_status(ticket_id, "resuelto")

func get_ticket(ticket_id: String) -> Dictionary:
	if tickets.has(ticket_id):
		var t: Dictionary = tickets[ticket_id]
		return t.duplicate(true)
	return {}

func total() -> int:
	return tickets.size()

func por_estado(estado: String) -> Array:
	var out: Array = []
	for id in tickets:
		var t: Dictionary = tickets[id]
		if String(t.get("estado", "")) == estado:
			out.append(id)
	return out

func por_prioridad(prioridad: String) -> Array:
	var out: Array = []
	for id in tickets:
		var t: Dictionary = tickets[id]
		if String(t.get("prioridad", "")) == prioridad:
			out.append(id)
	return out
