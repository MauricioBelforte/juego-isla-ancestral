# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M156: Terrenos — TerrainProvider (autoload "TerrainProvider")
# Data-driven (§1.3 adaptado a JSON del proyecto): carga los 7 terrenos de
# data/terrenos/terrenos.json. Los consumidores (M11, M155, M53) consultan
# por id. Terreno desconocido → modificador 1.0 (§10.2 edge case).
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).
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
			# M156 iter. 5 (lote I, 2026-10-13): config visual data-driven (§5.1/§5.2).
			# Claves opcionales: terreno sin "huella"/"particulas" →
			# get_visual_config() = {}.
			"huella": t.get("huella", {}),
			"particulas": t.get("particulas", {}),
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


## M156 iter. 5 (lote I, 2026-10-13, atria-dawn): config visual data-driven.
## Devuelve {"huella_distancia", "huella_tamano", "huella_alpha", "color",
## "particulas_frecuencia", "particulas_intensidad"}.
## Terreno desconocido → diccionario vacio (el consumidor no dibuja).
func get_visual_config(terrain_id: int) -> Dictionary:
	var t: Dictionary = _terrenos.get(terrain_id, {})
	var h: Dictionary = t.get("huella", {})
	if h.is_empty():
		return {}
	var color := _parsear_color(String(t.get("debug_color", "1,1,1")))
	var p: Dictionary = t.get("particulas", {})
	return {
		"huella_distancia": float(h.get("distancia", 0.7)),
		"huella_tamano": float(h.get("tamano", 0.5)),
		"huella_alpha": float(h.get("alpha", 0.4)),
		"color": color,
		"particulas_frecuencia": float(p.get("frecuencia", 1.0)),
		"particulas_intensidad": int(p.get("intensidad", 2)),
	}


## "r,g,b" (0-1) -> Color. Cadena invalida → Color.WHITE.
func _parsear_color(texto: String) -> Color:
	var partes := texto.split(",")
	if partes.size() < 3:
		return Color.WHITE
	var r := float(partes[0])
	var g := float(partes[1])
	var b := float(partes[2])
	return Color(clampf(r, 0.0, 1.0), clampf(g, 0.0, 1.0), clampf(b, 0.0, 1.0))


func get_audio_config(terrain_id: int) -> Dictionary:
	return {}


func terrenos_count() -> int:
	return _terrenos.size()
