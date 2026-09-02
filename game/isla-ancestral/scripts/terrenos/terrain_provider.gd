# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M156: Terrenos — TerrainProvider (autoload "TerrainProvider")
# Data-driven (§1.3 adaptado a JSON del proyecto): carga los 7 terrenos de
# data/terrenos/terrenos.json. Los consumidores (M11, M155, M53) consultan
# por id. Terreno desconocido → modificador 1.0 (§10.2 edge case).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

const RUTA_CATALOGO: String = "res://data/terrenos/terrenos.json"

## id -> {nombre, modificador, debug_color}
var _terrenos: Dictionary = {}


func _ready() -> void:
	_cargar_terrenos()
	_registrar_servicio()


func _cargar_terrenos() -> void:
	_terrenos.clear()
	var texto := FileAccess.get_file_as_string(RUTA_CATALOGO)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M156] terrenos.json inválido; sin terrenos")
		return
	for t in parseado.get("terrenos", []):
		var id := int(t.get("id", -1))
		if id < 0:
			continue
		_terrenos[id] = {
			"nombre": String(t.get("nombre", "")),
			"modificador": float(t.get("modificador", 1.0)),
			"debug_color": String(t.get("debug_color", "")),
		}
	print("[M156] Terrenos cargados: %d" % _terrenos.size())


func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr != null and sr.has_method("registrar"):
		sr.registrar("terrenos", self)


## ── API pública (§1.3) ──────────────────────────────────

func get_terrain_data(terrain_id: int) -> Dictionary:
	return _terrenos.get(terrain_id, {})


func get_speed_modifier(terrain_id: int) -> float:
	var t: Dictionary = _terrenos.get(terrain_id, {})
	return float(t.get("modificador", 1.0))  # §10.2: desconocido → 1.0


func get_terrain_name(terrain_id: int) -> String:
	var t: Dictionary = _terrenos.get(terrain_id, {})
	return String(t.get("nombre", ""))


func get_visual_config(terrain_id: int) -> Dictionary:
	# V2: las escenas visuales llegan con M45/M52 — la estructura ya existe
	return {}


func get_audio_config(terrain_id: int) -> Dictionary:
	return {}


func terrenos_count() -> int:
	return _terrenos.size()
