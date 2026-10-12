# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M121: Soporte Post-Lanzamiento — SupportManager (autoload)
# FAQ data-driven, categorías de tickets, canales de soporte, política de
# respuesta. Adaptación Godot 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_FAQ := "res://data/support/faq.json"

# --- Servicios M121 (D2) -----------------------------------------------------
# Los 4 servicios del diseno (04-Codigo.md sec.5-8) se instancian de forma
# perezosa y viven como hijos logicos de este autoload. NO se registran como
# autoloads propios para no editar project.godot (archivo compartido por varios
# agentes: trampa AM del skill). Se preloadean por RUTA (no por class_name)
# para no depender de la cache global de clases (trampa 123).
const _SC_FAQ := preload("res://scripts/support/faq_manager.gd")
const _SC_TICKET := preload("res://scripts/support/ticket_manager.gd")
const _SC_HOTFIX := preload("res://scripts/support/hotfix_manager.gd")
const _SC_PATCH := preload("res://scripts/support/patch_manager.gd")

signal ticket_created(ticket_id: String)
signal ticket_resolved(ticket_id: String)

var support_email: String = "support@islaancestral.com"
var support_discord_channel: String = "#soporte"
var support_steam_url: String = "https://steamcommunity.com/app/APPID/discussions/"

var config: Dictionary = {}

var _faq: Variant = null
var _tickets: Variant = null
var _hotfixes: Variant = null
var _parches: Variant = null

func _ready() -> void:
	_cargar_faq()
	_registrar_servicio()
	print("[M121] SupportManager listo (%d FAQ, %d canales)" % [config.get("faq", []).size(), config.get("canales", []).size()])

func _cargar_faq() -> void:
	if not FileAccess.file_exists(RUTA_FAQ):
		push_warning("[M121] faq.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_FAQ))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("support"):
		sr.register("support", self)

func faq_por_categoria(categoria: String) -> Array:
	var resultado: Array = []
	for item in config.get("faq", []):
		if String(item.get("categoria", "")) == categoria:
			resultado.append(item)
	return resultado

func buscar_faq(termino: String) -> Array:
	var resultado: Array = []
	for item in config.get("faq", []):
		var texto := "%s %s %s" % [item.get("pregunta", ""), item.get("respuesta", ""), item.get("id", "")]
		if texto.to_lower().contains(termino.to_lower()):
			resultado.append(item)
	return resultado

func canales() -> Array:
	return config.get("canales", []).duplicate()

func categorias() -> Array:
	return config.get("categorias", []).duplicate()

func politica_respuesta() -> Dictionary:
	return config.get("politica_respuesta", {}).duplicate(true)

# --- Accessors a los 4 servicios (M121 D2) -----------------------------------
# Devuelven Variant (no el tipo concreto) para evitar el warning
# unsafe_method_access al llamar metodos del servicio sobre una base tipada.

func faq_manager() -> Variant:
	if _faq == null:
		_faq = _SC_FAQ.new()
	return _faq

func ticket_manager() -> Variant:
	if _tickets == null:
		_tickets = _SC_TICKET.new()
	return _tickets

func hotfix_manager() -> Variant:
	if _hotfixes == null:
		_hotfixes = _SC_HOTFIX.new()
	return _hotfixes

func patch_manager() -> Variant:
	if _parches == null:
		_parches = _SC_PATCH.new()
	return _parches

# --- API de tickets de SupportManager (delega en TicketManager) --------------

func create_ticket(categoria: String, prioridad: String, descripcion: String, user_info: Dictionary = {}) -> String:
	var tm: Variant = ticket_manager()
	var tid: String = str(tm.create_ticket(categoria, prioridad, descripcion, user_info))
	ticket_created.emit(tid)
	return tid

func generate_ticket_id() -> String:
	var tm: Variant = ticket_manager()
	return str(tm.generate_ticket_id())

func resolve_ticket(ticket_id: String) -> bool:
	var tm: Variant = ticket_manager()
	var ok: bool = bool(tm.resolve_ticket(ticket_id))
	if ok:
		ticket_resolved.emit(ticket_id)
	return ok

# --- Configuracion de canales (M121 D2) --------------------------------------
# Devuelven la configuracion declarativa; el alta real del servicio externo
# (email/Discord) es una tarea manual de operaciones, no de codigo.

func setup_email_autoresponder() -> Dictionary:
	return {"email": support_email, "auto_respuesta": true, "sla_horas": int(politica_respuesta().get("primer_contacto_horas", 24))}

func setup_discord_channels() -> Array:
	return ["#soporte", "#faq", "#anuncios"]
