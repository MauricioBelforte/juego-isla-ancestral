# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M33: FarmService (autoload "Farm") — orquestación agrícola.
# Según 03-Diseno §2.4: till/plant/water/apply_rain/can_harvest/harvest/
# get_tile/get_growth_hint/advance_day/reserve_plot/get_active_farm_stats.
# Reglas: progreso nunca se pierde (pausa, no muerte), avance por día M29,
# consumo/entrega via Inventario M14, catálogo desde M93 farming.json.
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

signal crop_planted(crop_id: StringName, voxel_pos: Vector3i)
signal crop_stage_changed(voxel_pos: Vector3i, stage: int)
signal crop_ready(voxel_pos: Vector3i)
signal crop_harvested(voxel_pos: Vector3i, items: Array)
signal tile_tilled(voxel_pos: Vector3i)
signal tile_watered(voxel_pos: Vector3i, water_level: int)
signal day_advanced(day_index: int)

const MAX_TILES_ACTIVOS := 400  # presupuesto M61

var _tiles: Dictionary = {}       # Vector3i -> CropTile
var _visuales: Dictionary = {}    # Vector3i -> CropTileVisual
var _definiciones: Dictionary = {}  # crop_id -> CropDefinition
var _parcelas: Dictionary = {}    # owner_id -> Array[Rect3i] (reserva simple M17)
var _arados: Dictionary = {}      # Vector3i -> true (tierra arada registrada en el servicio)
var _store := FarmStateStore.new()

func _ready() -> void:
	_cargar_definiciones()
	_registrar_proveedor_guardado()
	_suscribir_tiempo()
	_suscribir_clima()

## ── Clima (M32, glm-5.3-flash 2026-08-31) ────────────────

## Puente M32→M33: cuando el clima del día es de precipitación, la lluvia
## riega los cultivos expuestos (checklist G: "lluvia rellena cultivos
## expuestos sin techo"). Consumidores escuchan señales (03-Diseno M32 §6),
## nunca consultan internals del WeatherService.
##  - LLUVIA/TORMENTA/TROPICAL → apply_rain() al cambiar el clima del día.
##  - Regla cozy G: la lluvia no excede el máximo de agua (ver _on_clima_cambio).
##  - "Expuesto sin techo": hook _tile_expuesto() — mientras no exista techo
##    (M17/M18), todo tile está expuesto; el hook centraliza el chequeo.
func _suscribir_clima() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null or not bus.weather.has_signal("clima_cambio"):
		push_warning("[M33] EventBus.weather no disponible; riego por lluvia desactivado")
		return
	bus.weather.clima_cambio.connect(_on_clima_cambio)

func _on_clima_cambio(clima: int) -> void:
	# 2=LLUVIA, 3=TORMENTA, 7=TROPICAL (WeatherService.Clima)
	if clima == 2 or clima == 3 or clima == 7:
		apply_rain()

## Un tile está "expuesto a la lluvia" si no tiene techo encima.
## Hook único: M17/M18 (construcción/casas) marcarán cobertura aquí.
func _tile_expuesto(_voxel_pos: Vector3i) -> bool:
	return true

## ── Catálogo (M93 farming.json) ──────────────────────────

func _cargar_definiciones() -> void:
	var bal = get_node_or_null("/root/Balance")
	if bal == null or not bal.has_method("get_farming"):
		push_warning("[M33] BalanceService no disponible; sin cultivos")
		return
	var cultivos: Dictionary = bal.get_farming().get("cultivos", {})
	for crop_id in cultivos:
		var d: Dictionary = cultivos[crop_id]
		var def := CropDefinition.new()
		def.crop_id = StringName(String(crop_id))
		def.display_name = String(crop_id).capitalize()
		def.description = "Cultivo de temporada: " + str(d.get("temporada", "todas"))
		def.grow_days = int(d.get("crecimiento_dias", 4))
		def.yield_amount_min = int(d.get("rendimiento_min", 1))
		def.yield_amount_max = int(d.get("rendimiento_max", 3))
		def.seasons = [_estacion_numero(String(d.get("temporada", "todas")))]
		def.yield_item_id = def.crop_id
		def.yield_seed_id = def.crop_id
		def.yield_seed_amount = 1
		_definiciones[def.crop_id] = def

func _estacion_numero(nombre: String) -> int:
	match nombre.to_lower():
		"primavera": return 0
		"verano": return 1
		"otono", "otoño": return 2
		"invierno": return 3
	return -1  # todas: cualquier estación pasa el check por lista vacía... ver can_advance

## Definición por id (para tests y persistencia).
func obtener_def(crop_id: StringName) -> CropDefinition:
	return _definiciones.get(crop_id, null)

func definiciones_count() -> int:
	return _definiciones.size()

## ── Tiempo (M29) ─────────────────────────────────────────

func _suscribir_tiempo() -> void:
	var cal = get_node_or_null("/root/TimeCalendar")
	if cal and cal.has_signal("day_advanced"):
		cal.day_advanced.connect(_on_dia_avanzado)
	elif cal and cal.has_signal("day_changed"):
		cal.day_changed.connect(_on_dia_avanzado)

func _on_dia_avanzado(_info) -> void:
	advance_day()

## ── API pública ──────────────────────────────────────────

## Arar un bloque de tierra (pala M13). Validación voxel defensiva:
## si el VoxelTerrain está disponible, exige bloque natural (GRASS=2/DIRT=1);
## en headless (sin terrain) se registra en _arados sin validación de bloque.
## La conversión VISUAL a TIERRA_ARADA (voxel de M08) queda para cuando M08
## agregue el bloque arado (iter. 3+ — no se tocan módulos de otros agentes).
func till_tile(voxel_pos: Vector3i) -> bool:
	if _tiles.has(voxel_pos) or _arados.has(voxel_pos):
		return false  # ya arada/con cultivo
	if not _bloque_es_terreno_natural(voxel_pos):
		return false
	_arados[voxel_pos] = true
	tile_tilled.emit(voxel_pos)
	return true

## Verifica que el voxel sea terreno natural usando el VoxelTerrain real (si existe).
## Sin terrain disponible (headless/tests) devuelve true (validación de unidad).
func _bloque_es_terreno_natural(voxel_pos: Vector3i) -> bool:
	var terrain = _buscar_terreno()
	if terrain == null or not terrain.has_method("get_voxel_tool"):
		return true
	var vt = terrain.get_voxel_tool()
	if vt == null:
		return true
	var bloque: int = int(vt.get_voxel(voxel_pos)) & 0xFF
	return bloque == 1 or bloque == 2  # DIRT / GRASS

func _buscar_terreno():
	var tree := get_tree()
	if tree == null:
		return null
	return tree.root.get_node_or_null("IslaRaiz/VoxelTerrain") if tree.root.get_node_or_null("IslaRaiz") else null

## Plantar una semilla (consume 1 del inventario M14). Requiere tierra arada.
func plant(crop: CropDefinition, voxel_pos: Vector3i) -> bool:
	if crop == null or _tiles.has(voxel_pos):
		return false
	if not _arados.has(voxel_pos):
		return false  # §flujo 1: primero arar, luego plantar
	if _tiles.size() >= MAX_TILES_ACTIVOS:
		return false
	var inv = get_node_or_null("/root/Inventario")
	if inv == null:
		return false
	# Consume la semilla (mismo id del cultivo por defecto)
	var semilla := str(crop.yield_seed_id) if crop.yield_seed_id != &"" else str(crop.crop_id)
	if not inv.remover_items({semilla: 1}):
		return false
	var cal = get_node_or_null("/root/TimeCalendar")
	var tile := CropTile.new()
	tile.voxel_pos = voxel_pos
	tile.crop_def = crop
	tile.stage = CropTile.GrowthStage.SEMILLA
	tile.planted_at_day = int(cal.get_dia_absoluto()) if cal else 0
	_tiles[voxel_pos] = tile
	_crear_visual(tile)
	crop_planted.emit(crop.crop_id, voxel_pos)
	crop_stage_changed.emit(voxel_pos, tile.stage)
	return true

## Regar (regadera M13). Sube agua hasta 2, reanuda SIN_AGUA.
func water(voxel_pos: Vector3i) -> void:
	var tile: CropTile = _tiles.get(voxel_pos, null)
	if tile == null:
		return
	tile.regar()
	tile_watered.emit(voxel_pos, tile.water_level)
	_actualizar_visual(tile)
	_visual_fx(voxel_pos, "water")

## Lluvia (M32): rellena agua de todos los cultivos expuestos.
## Regla cozy (checklist G): nunca excede el máximo (agua máx 2), no toca
## cultivos listos (ya no consumen agua) y no emite señal redundante si el
## nivel ya está al máximo (idempotente por tile).
func apply_rain() -> void:
	for voxel_pos in _tiles:
		var tile: CropTile = _tiles[voxel_pos]
		if tile != null and not tile.is_ready() and _tile_expuesto(voxel_pos):
			var nuevo := mini(tile.water_level + 2, 2)
			if nuevo != tile.water_level:
				tile.water_level = nuevo
				tile_watered.emit(voxel_pos, tile.water_level)

func can_harvest(voxel_pos: Vector3i) -> bool:
	var tile: CropTile = _tiles.get(voxel_pos, null)
	return tile != null and tile.is_ready()

## ¿Se puede plantar en esta posición (tierra arada sin cultivo)?
func puede_plantar_en(voxel_pos: Vector3i) -> bool:
	return _arados.has(voxel_pos) and not _tiles.has(voxel_pos)

## Persistencia también de la tierra arada (M59).
func _arados_serializar() -> Array:
	var out: Array = []
	for p in _arados:
		out.append([p.x, p.y, p.z])
	return out

## Cosecha: entrega ítems a M14; árboles quedan en cooldown, resto se elimina.
func harvest(voxel_pos: Vector3i) -> Array:
	var tile: CropTile = _tiles.get(voxel_pos, null)
	if tile == null or not tile.is_ready():
		return []
	var items: Array = tile.calcular_rendimiento()
	var inv = get_node_or_null("/root/Inventario")
	if inv and inv.has_method("agregar_items"):
		var dict_items: Dictionary = {}
		for e in items:
			dict_items[str(e["item_id"])] = int(e["cantidad"])
		inv.agregar_items(dict_items)
	crop_harvested.emit(voxel_pos, items)
	_visual_fx(voxel_pos, "harvest")
	if tile.crop_def != null and tile.crop_def.is_tree:
		# Perenne: vuelve a MADURA con cooldown frutal
		tile.stage = CropTile.GrowthStage.MADURA
		tile.fruit_cooldown = 2
		tile.grown_days = int(tile.crop_def.grow_days) - 1
		_actualizar_visual(tile)
	else:
		_tiles.erase(voxel_pos)
		_eliminar_visual(voxel_pos)
	return items

func get_tile(voxel_pos: Vector3i) -> CropTile:
	return _tiles.get(voxel_pos, null)

## Tooltip amigable (M53).
func get_growth_hint(voxel_pos: Vector3i) -> String:
	var tile: CropTile = _tiles.get(voxel_pos, null)
	if tile == null or tile.crop_def == null:
		return ""
	match tile.stage:
		CropTile.GrowthStage.LISTA:
			return "¡Listo para cosechar!"
		CropTile.GrowthStage.DORMANTE:
			return "Descansa. Volverá en su estación."
		CropTile.GrowthStage.SIN_AGUA:
			return "Necesita agua."
		CropTile.GrowthStage.SEMILLA:
			return "Recién plantado. Riégalo."
	var dias_faltan: int = maxi(0, tile.crop_def.grow_days - tile.grown_days)
	return "Creciendo... %d día(s) restantes (riego diario)." % dias_faltan

## Avance diario (M29): estación -> apply_daily_tick por tile.
func advance_day() -> void:
	var cal = get_node_or_null("/root/TimeCalendar")
	var season: int = int(cal.get_estacion()) if cal else 0
	for voxel_pos in _tiles:
		var tile: CropTile = _tiles[voxel_pos]
		if tile == null:
			continue
		var cambio: bool = tile.apply_daily_tick(season, false)
		if tile.is_ready() and cambio:
			crop_ready.emit(voxel_pos)
		if cambio:
			crop_stage_changed.emit(voxel_pos, tile.stage)
		_actualizar_visual(tile)
	day_advanced.emit(int(cal.get_dia_absoluto()) if cal else 0)

## Parcelas (M17, reserva simple)
func reserve_plot(owner_id: int, center: Vector3i, radius: int) -> bool:
	if _parcelas.has(center):
		return false
	_parcelas[center] = {"owner": owner_id, "radius": radius}
	return true

## Estadísticas para analytics M104 / profiler M61.
func get_active_farm_stats() -> Dictionary:
	var listos := 0
	var pausados := 0
	for voxel_pos in _tiles:
		var tile: CropTile = _tiles[voxel_pos]
		if tile and tile.is_ready():
			listos += 1
		elif tile and tile.is_paused():
			pausados += 1
	return {"tiles": _tiles.size(), "listos": listos, "pausados": pausados}

## ── Visuales ─────────────────────────────────────────────

func _crear_visual(tile: CropTile) -> void:
	var vis_script := load("res://scripts/farm/crop_tile_visual.gd")
	if vis_script == null:
		return
	var visual = vis_script.new()
	visual.name = "Crop_" + str(tile.voxel_pos.x) + "_" + str(tile.voxel_pos.z)
	add_child(visual)
	# Posición sobre el terreno (M167) — fallback y=voxel+1
	visual.position = Vector3(tile.voxel_pos) + Vector3(0.5, 1.1, 0.5)
	var locator = get_node_or_null("/root/TerrainLocator")
	if locator and locator.has_method("posicionar_sobre_terreno"):
		locator.posicionar_sobre_terreno(visual, tile.voxel_pos.x + 0.5, tile.voxel_pos.z + 0.5)
	_visuales[tile.voxel_pos] = visual
	visual.refresh(tile)

func _actualizar_visual(tile: CropTile) -> void:
	var visual = _visuales.get(tile.voxel_pos, null)
	if visual:
		visual.refresh(tile)

func _visual_fx(voxel_pos: Vector3i, tipo: String) -> void:
	var visual = _visuales.get(voxel_pos, null)
	if visual == null:
		return
	if tipo == "water" and visual.has_method("play_water_fx"):
		visual.play_water_fx()
	elif tipo == "harvest" and visual.has_method("play_harvest_fx"):
		visual.play_harvest_fx()

func _eliminar_visual(voxel_pos: Vector3i) -> void:
	var visual = _visuales.get(voxel_pos, null)
	if visual:
		visual.queue_free()
		_visuales.erase(voxel_pos)

## ── Persistencia (M59) ───────────────────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

func get_section_name() -> String:
	return "farm"

func get_save_data() -> Dictionary:
	var data := _store.to_save_dict(_tiles.values())
	data["arados"] = _arados_serializar()
	return data

func restore_save_data(data: Dictionary) -> void:
	_arados.clear()
	for a in data.get("arados", []):
		_arados[Vector3i(int(a[0]), int(a[1]), int(a[2]))] = true
	var tiles = _store.from_save_dict(data, func(crop_id): return _definiciones.get(StringName(crop_id), null))
	_tiles.clear()
	for tile in tiles:
		_tiles[tile.voxel_pos] = tile
		_crear_visual(tile)