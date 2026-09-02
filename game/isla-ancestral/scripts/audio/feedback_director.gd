# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M44: ASMR y Feedback — FeedbackDirector (autoload)
# Aplica recetas de capas por acción con precedencia contextual
# (interior/clima/hora), blacklist anti-agresión (True Peak / buzz) y
# sincronía keyframes (M34). Diseño original (04-Codigo.md §1.1).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_RECETAS := "res://data/audio/feedback_recetas.json"
const RUTA_BLACKLIST := "res://data/audio/feedback_blacklist.json"

signal feedback_aplicado(accion: String, capas: Array)

var recetas: Dictionary = {}
var blacklist: Dictionary = {}
var _contexto: Dictionary = {}   # {"interior": bool, "clima": int, "hora": int}

func _ready() -> void:
	_cargar_recetas()
	_cargar_blacklist()
	_registrar_servicio()
	print("[M44] FeedbackDirector listo (%d recetas)" % recetas.size())

func _cargar_recetas() -> void:
	if not FileAccess.file_exists(RUTA_RECETAS):
		push_warning("[M44] feedback_recetas.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_RECETAS))
	if typeof(parsed) == TYPE_DICTIONARY:
		recetas = parsed

func _cargar_blacklist() -> void:
	if not FileAccess.file_exists(RUTA_BLACKLIST):
		push_warning("[M44] feedback_blacklist.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_BLACKLIST))
	if typeof(parsed) == TYPE_DICTIONARY:
		blacklist = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("feedback"):
		sr.register("feedback", self)

## Aplica la receta de la acción (con precedencia contextual).
## Devuelve Array de capas activas (vacío si la acción está en blacklist o no existe).
func sensacion(accion: String) -> Array:
	# Blacklist anti-agresión: acción prohibida -> silencio
	if _en_blacklist(accion):
		return []
	if not recetas.has(accion):
		return []
	var entrada: Dictionary = recetas[accion]
	var capas: Array = entrada.get("capas", []).duplicate()
	# Precedencia contextual: interior agrega capa de reverb
	if _contexto.get("interior", false):
		var interior_capa: String = entrada.get("interior_capa", "")
		if interior_capa != "":
			capas.append(interior_capa)
	emit_signal("feedback_aplicado", accion, capas)
	return capas

func _en_blacklist(accion: String) -> bool:
	return blacklist.get("prohibidas", []).has(accion)

func set_contexto(tipo: String, valor: Variant) -> void:
	_contexto[tipo] = valor

func key_sync(_accion: String, _keyframe: int) -> void:
	# Sincronía keyframes (M34): stub — se conecta cuando M34 emita
	pass

func pausar() -> void:
	pass

func reanudar() -> void:
	pass