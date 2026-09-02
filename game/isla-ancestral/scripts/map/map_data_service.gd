# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M54: MapDataService — datos del mapa (POIs + niebla de guerra RF5 + pines RF6).
# Independiente de la UI (iter 2 con M53/M57). Persistencia con DataStore (M59)
# cuando exista el manager; por ahora estado en memoria + señales.

extends Node

signal pines_modificados(pines: int)
signal exploracion_modificada

const RUTA_MAP_DATA := "res://data/map/map_data.json"

var _config: Dictionary = {}
var _pois: Array = []
var _pines: Array = []
var _visitados: Dictionary = {}   # "region" -> true/false
var _celdas_vistas: Dictionary = {}

func _ready() -> void:
	_cargar()

func _cargar() -> void:
	if not FileAccess.file_exists(RUTA_MAP_DATA):
		push_warning("[M54] map_data.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_MAP_DATA))
	if typeof(parsed) == TYPE_DICTIONARY:
		_config = parsed
		_pois = parsed.get("pois", [])
	print("[M54] MapDataService listo (%d POIs, %d islas)" % [_pois.size(), _config.get("islas", {}).size()])

## ── POIs (RF3) ─────────────────────────────────────
func pois() -> Array:
	return _pois

func pois_por_categoria(categoria: String) -> Array:
	var out := []
	for p in _pois:
		if String(p.get("categoria", "")) == categoria:
			out.append(p)
	return out

## ── Niebla de guerra (RF5) ─────────────────────────
func marcar_region_visitada(region: String) -> void:
	_visitados[region] = true
	exploracion_modificada.emit()

func region_visitada(region: String) -> bool:
	return _visitados.get(region, false)

func marcar_celda_vista(celda: String) -> void:
	if not _celdas_vistas.has(celda):
		_celdas_vistas[celda] = true
		exploracion_modificada.emit()

func celda_vista(celda: String) -> bool:
	return _celdas_vistas.get(celda, false)

func porcentaje_explorado(total_celdas: int) -> float:
	if total_celdas <= 0:
		return 0.0
	return float(_celdas_vistas.size()) / float(total_celdas)

## ── Pines del jugador (RF6) ────────────────────────
func add_pin(x: float, z: float, nota: String = "") -> void:
	_pines.append({"x": x, "z": z, "nota": nota})
	pines_modificados.emit(_pines.size())

func remove_pin(indice: int) -> void:
	if indice >= 0 and indice < _pines.size():
		_pines.remove_at(indice)
		pines_modificados.emit(_pines.size())

func pines() -> Array:
	return _pines

## ── Asistencia de coordenadas (isla RIZ 256) ───────
func dentro_de_isla(x: float, z: float) -> bool:
	var islas: Dictionary = _config.get("islas", {})
	var riz: Dictionary = islas.get("RIZ", {})
	var centro: Array = riz.get("centro", [128, 128])
	var radio: float = float(riz.get("radio", 256))
	var dx := x - float(centro[0])
	var dz := z - float(centro[1])
	return sqrt(dx * dx + dz * dz) <= radio
