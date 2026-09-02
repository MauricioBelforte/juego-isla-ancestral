# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M94: Retención sin FOMO — MotorEventosVariantes
# Motor de variantes para festividades/eventos (M74 extendido, RF4).
# Cada festividad tiene 3+ variantes que rotan en ciclo; las participaciones
# se acumulan como sello de colección (M73). Diseño original (04-Codigo.md §2).

class_name MotorEventosVariantes
extends RefCounted

var _variantes: Dictionary = {}   # festividad_id -> Array[String] de variantes
var _indices: Dictionary = {}     # festividad_id -> int (variante actual)
var _participaciones: Dictionary = {}  # festividad_id -> int

## Registra una festividad con sus variantes. Llamar en init.
func registrar(festividad_id: String, variantes: Array) -> void:
	_variantes[festividad_id] = variantes.duplicate()
	if not _indices.has(festividad_id):
		_indices[festividad_id] = 0

## Siguiente variante en ciclo (rotación). Si no hay más variantes, cicla.
func siguiente_variante(festividad_id: String) -> String:
	var lista: Array = _variantes.get(festividad_id, [])
	if lista.is_empty():
		return ""
	var idx: int = _indices.get(festividad_id, 0)
	var variante: String = lista[idx]
	_indices[festividad_id] = (idx + 1) % lista.size()
	_participaciones[festividad_id] = _participaciones.get(festividad_id, 0) + 1
	return variante

func participaciones(festividad_id: String) -> int:
	return _participaciones.get(festividad_id, 0)

func a_diccionario() -> Dictionary:
	return {
		"variantes": _variantes.duplicate(true),
		"indices": _indices.duplicate(true),
		"participaciones": _participaciones.duplicate(true),
	}

static func desde_diccionario(d: Dictionary) -> MotorEventosVariantes:
	var m := MotorEventosVariantes.new()
	for k in d.get("variantes", {}):
		m._variantes[k] = (d["variantes"][k] as Array).duplicate()
	for k in d.get("indices", {}):
		m._indices[k] = int(d["indices"][k])
	for k in d.get("participaciones", {}):
		m._participaciones[k] = int(d["participaciones"][k])
	return m