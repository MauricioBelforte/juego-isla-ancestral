# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M54: Mapa — MapManager (autoload)
# Datos de mapa data-driven (map_config.json): marcadores por isla,
# exploración (fog de guerra por región), pines del jugador con persistencia,
# tipos de marcador con diferenciación (daltonismo M58).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_CONFIG := "res://data/mapa/map_config.json"
const RUTA_PINES := "user://mapa_pines.json"
const MAX_PINES := 50

signal exploration_changed(region_ids: Array)
signal markers_changed(markers: Array)
signal pines_changed(pines: Array)

var config: Dictionary = {}
var _exploradas: Dictionary = {}   # marcador_id -> bool
var _regiones_exploradas: Dictionary = {}  # region_id -> bool (fog por región)
var _pines: Array = []             # [{x, y, z, nota, tipo}]

func _ready() -> void:
	_cargar_config()
	_inicializar_exploracion()
	_cargar_pines()
	_registrar_servicio()
	print("[M54] MapManager listo (%d marcadores, %d pines)" % [config.get("marcadores", []).size(), _pines.size()])

func _cargar_config() -> void:
	if not FileAccess.file_exists(RUTA_CONFIG):
		push_warning("[M54] map_config.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CONFIG))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _inicializar_exploracion() -> void:
	for m in config.get("marcadores", []):
		var id: String = String(m.get("id", ""))
		if not id.is_empty():
			_exploradas[id] = bool(m.get("visible_inicial", false))
			# Cada marcador define su región (si no, la isla completa)
			var region: String = String(m.get("region", String(m.get("isla", "raiz"))))
			if not _regiones_exploradas.has(region):
				_regiones_exploradas[region] = bool(m.get("visible_inicial", false))

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("mapa"):
		sr.register("mapa", self)

func islas() -> Array:
	return config.get("islas", []).duplicate()

func marcadores_por_isla(isla: String) -> Array:
	var resultado: Array = []
	for m in config.get("marcadores", []):
		if String(m.get("isla", "")) == isla:
			resultado.append(m)
	return resultado

func marcadores_por_tipo(tipo: String) -> Array:
	var resultado: Array = []
	for m in config.get("marcadores", []):
		if String(m.get("tipo", "")) == tipo:
			resultado.append(m)
	return resultado

## Tipos de marcador con forma/color (diferenciación daltonismo M58, T-021).
func tipo_forma(tipo: String) -> String:
	match tipo:
		"lugar": return "circulo"
		"templo": return "diamante"
		"tienda": return "cuadrado"
		"viaje": return "triangulo"
		_:
			return "circulo"

func esta_explorada(marcador_id: String) -> bool:
	return _exploradas.get(marcador_id, false)

func region_explorada(region_id: String) -> bool:
	return _regiones_exploradas.get(region_id, false)

func marcar_explorada(marcador_id: String) -> void:
	if _exploradas.has(marcador_id) and not _exploradas[marcador_id]:
		_exploradas[marcador_id] = true
		# Al explorar un marcador, su región queda explorada (fog por región)
		for m in config.get("marcadores", []):
			if String(m.get("id", "")) == marcador_id:
				var region: String = String(m.get("region", String(m.get("isla", "raiz"))))
				_regiones_exploradas[region] = true
				break
		emit_signal("exploration_changed", _exploradas.keys())
		emit_signal("markers_changed", marcadores_por_isla("raiz"))
		print("[M54] Marcador explorado: %s" % marcador_id)

## Agrega un pin del jugador con tipo (T-0xx pines) y persiste.
func agregar_pin(x: int, y: int, z: int, nota: String = "", tipo: String = "general") -> bool:
	if _pines.size() >= MAX_PINES:
		return false
	_pines.append({"x": x, "y": y, "z": z, "nota": nota, "tipo": tipo})
	_guardar_pines()
	emit_signal("pines_changed", _pines.duplicate(true))
	return true

func borrar_pin(indice: int) -> bool:
	if indice < 0 or indice >= _pines.size():
		return false
	_pines.remove_at(indice)
	_guardar_pines()
	emit_signal("pines_changed", _pines.duplicate(true))
	return true

func pines() -> Array:
	return _pines.duplicate(true)

func contar_exploradas() -> int:
	var count := 0
	for id in _exploradas:
		if _exploradas[id]:
			count += 1
	return count

func total_marcadores() -> int:
	return config.get("marcadores", []).size()

func total_regiones() -> int:
	return _regiones_exploradas.size()

func contar_regiones_exploradas() -> int:
	var count := 0
	for id in _regiones_exploradas:
		if _regiones_exploradas[id]:
			count += 1
	return count


## Persistencia de exploración (compatible M59/JSON).
func guardar_exploracion() -> void:
	var f := FileAccess.open("user://mapa_exploracion.json", FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"exploradas": _exploradas, "regiones": _regiones_exploradas}, "  "))
	f.close()

func cargar_exploracion() -> void:
	if not FileAccess.file_exists("user://mapa_exploracion.json"):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("user://mapa_exploracion.json"))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	if parsed.has("exploradas"):
		for id in parsed["exploradas"]:
			if _exploradas.has(id):
				_exploradas[id] = bool(parsed["exploradas"][id])
	if parsed.has("regiones"):
		for id in parsed["regiones"]:
			if _regiones_exploradas.has(id):
				_regiones_exploradas[id] = bool(parsed["regiones"][id])

## Persistencia de pines (M59-compatible, data-driven).
func _guardar_pines() -> void:
	var f := FileAccess.open(RUTA_PINES, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"pines": _pines}, "  "))
	f.close()

func _cargar_pines() -> void:
	if not FileAccess.file_exists(RUTA_PINES):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_PINES))
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("pines"):
		_pines = parsed["pines"]