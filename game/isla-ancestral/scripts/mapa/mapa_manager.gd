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
var _cached_texture: Image = null  # Textura cacheada del mapa (sin segundo bake)
var _texture_dirty: bool = true    # Invalidado en exploration_changed
var _fast_travel_provider: Callable = Callable()  # Provider M69 (cancelar/estado)

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
		invalidate_map_texture()
		emit_signal("exploration_changed", _exploradas.keys())
		emit_signal("markers_changed", marcadores_por_isla("raiz"))
		print("[M54] Marcador explorado: %s" % marcador_id)

## Agrega un pin del jugador con tipo (T-0xx pines) y persiste.
func agregar_pin(x: int, y: int, z: int, nota: String = "", tipo: String = "general") -> bool:
	if _pines.size() >= MAX_PINES:
		return false
	var fecha: String = str(int(Time.get_unix_time_from_system()))
	_pines.append({"x": x, "y": y, "z": z, "nota": nota, "tipo": tipo, "fecha": fecha})
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
		var loaded: Array = parsed["pines"]
		for i in range(loaded.size()):
			var p: Dictionary = loaded[i]
			var x: int = int(p.get("x", 0))
			var z: int = int(p.get("z", 0))
			# Validación: fuera de rango se marca no disponible, no se borra
			if x < -10000 or x > 10000 or z < -10000 or z > 10000:
				p["disponible"] = false
				print("[M54] Pin %d fuera de rango (%d,%d) — marcado no disponible" % [i, x, z])
			_pines.append(p)

## ── Textura caché (bake una vez, invalida en exploration_changed) ──

func bake_map_texture(width: int = 256, height: int = 256) -> Image:
	if _cached_texture != null and not _texture_dirty:
		return _cached_texture
	var img := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.15, 0.25, 0.35, 1.0))  # fondo mar
	# Intentar usar TerrainLocator para texture basada en elevación real
	var locator: Node = get_node_or_null("/root/TerrainLocator")
	var has_terrain: bool = locator != null and locator.has_method("get_height")
	if has_terrain:
		var world_size: float = 6200.0  # radio isla * 2
		for y in height:
			for x in width:
				var wx: int = int(float(x) / width * world_size)
				var wz: int = int(float(y) / height * world_size)
				var h: int = locator.get_height(wx, wz)
				# Mapear altura a color: bajo=agua/arena, medio=verde, alto=pardo
				var t: float = clampf(float(h) / 15.0, 0.0, 1.0)
				var col: Color
				if t < 0.15:
					col = Color(0.2, 0.45, 0.7)  # agua
				elif t < 0.3:
					col = Color(0.85, 0.78, 0.5)  # arena
				elif t < 0.7:
					col = Color(0.3, 0.65, 0.25)  # verde
				else:
					col = Color(0.55, 0.45, 0.3)  # pardo/montaña
				img.set_pixel(x, y, col)
	else:
		# Fallback: islas como blobs (sin VoxelTerrain, p.ej. headless)
		var islas: Array = config.get("islas", [])
		var positions: Array = [Vector2(0.25, 0.25), Vector2(0.75, 0.25), Vector2(0.25, 0.75), Vector2(0.75, 0.75)]
		for i in range(mini(islas.size(), 4)):
			var island_id: String = String(islas[i])
			var center: Vector2 = (positions[i] as Vector2) * Vector2(width, height)
			var radius := 40.0
			var color: Color = Color.from_hsv(float(i) * 0.25, 0.3, 0.5, 1.0)
			var explored: bool = _regiones_exploradas.get(island_id, true)
			if not explored:
				color = Color(0.1, 0.1, 0.12, 1.0)
			for y in range(int(center.y) - int(radius), int(center.y) + int(radius)):
				for x in range(int(center.x) - int(radius), int(center.x) + int(radius)):
					if x < 0 or x >= width or y < 0 or y >= height:
						continue
					if (x - center.x) * (x - center.x) + (y - center.y) * (y - center.y) < radius * radius:
						img.set_pixel(x, y, color)
	_cached_texture = img
	_texture_dirty = false
	return img

func invalidate_map_texture() -> void:
	_texture_dirty = true

func get_cached_map_texture() -> Image:
	if _cached_texture == null:
		bake_map_texture()
	return _cached_texture

func cancelar_viaje() -> bool:
	if _fast_travel_provider.is_valid():
		var result: Variant = _fast_travel_provider.call()
		if result != null and result is Dictionary:
			return bool(result.get("cancelled", false))
	return false

## Devuelve el estado del viaje en curso (si el provider lo expone).
func estado_viaje() -> Dictionary:
	if _fast_travel_provider.is_valid():
		var result: Variant = _fast_travel_provider.call("get_state")
		if result is Dictionary:
			return result
	return {"en_curso": false}

## M69 delega su viaje rápido al MapManager vía Callable (desacople §3).
func register_fast_travel_provider(callable: Callable) -> void:
	_fast_travel_provider = callable