# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M33: FarmService (autoload "Farm") — orquestación agrícola.
# Según 03-Diseno §2.4: till/plant/water/apply_rain/can_harvest/harvest/
# get_tile/get_growth_hint/advance_day/reserve_plot/get_active_farm_stats.
# Reglas: progreso nunca se pierde (pausa, no muerte), avance por día M29,
# consumo/entrega via Inventario M14, catálogo desde M93 farming.json.
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).

extends Node

signal crop_planted(crop_id: StringName, voxel_pos: Vector3i)
signal crop_stage_changed(voxel_pos: Vector3i, stage: int)
signal crop_ready(voxel_pos: Vector3i)
signal crop_harvested(voxel_pos: Vector3i, items: Array)
signal crop_harvest_blocked(voxel_pos: Vector3i, items: Array)  # inventario lleno (K)
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
var _ultimo_dia_avanzado: int = -1  # idempotencia del tick diario (K)
var _terrain_test: Node = null      # inyección solo para tests headless

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
## si el VoxelTerrain está disponible, exige bloque natural (GRASS=2/DIRT=1)
## y escribe TIERRA_ARADA (M08, id 31) en el voxel; en headless (sin terrain)
## se registra en _arados sin validación de bloque (modo lógico).
func till_tile(voxel_pos: Vector3i) -> bool:
	if _tiles.has(voxel_pos) or _arados.has(voxel_pos):
		return false  # ya arada/con cultivo
	if not _bloque_es_terreno_natural(voxel_pos):
		return false
	_arados[voxel_pos] = true
	_escribir_bloque(voxel_pos, BlockType.TIERRA_ARADA)  # M08: TIERRA -> TIERRA_ARADA
	tile_tilled.emit(voxel_pos)
	return true

## Verifica que el voxel sea terreno natural usando el VoxelTerrain real (si existe).
## Sin terrain disponible (headless/tests) devuelve true (validación de unidad).
func _bloque_es_terreno_natural(voxel_pos: Vector3i) -> bool:
	var bloque: int = _leer_bloque(voxel_pos)
	if bloque < 0:
		return true
	return bloque == 1 or bloque == 2  # DIRT / GRASS

## Terreno activo (M08). Lookup canónico — mismo criterio que TerrainLocator
## (M167) y tool_controller (M13): VoxelTerrain hijo de la escena actual, con
## fallback de árbol completo. Corrige la ruta vieja "IslaRaiz/VoxelTerrain"
## que no existía en main_island.tscn (VoxelTerrain cuelga de la raíz).
## Retorna Node (no VoxelTerrain) para permitir inyección de un terrain fake
## en tests headless (los call sites usan duck typing: has_method/get_voxel_tool).
func _buscar_terreno() -> Node:
	if _terrain_test != null and is_instance_valid(_terrain_test):
		return _terrain_test
	var tree := get_tree()
	if tree == null:
		return null
	var raiz = tree.current_scene
	if raiz != null:
		for child in raiz.get_children():
			if child is VoxelTerrain:
				return child
	return _buscar_terreno_recursivo(tree.root)

func _buscar_terreno_recursivo(nodo: Node) -> VoxelTerrain:
	if nodo is VoxelTerrain:
		return nodo as VoxelTerrain
	for child in nodo.get_children():
		var r = _buscar_terreno_recursivo(child)
		if r != null:
			return r
	return null

## Lee el bloque del mundo voxel en una posición (-1 si no hay terrain).
func _leer_bloque(voxel_pos: Vector3i) -> int:
	var terrain = _buscar_terreno()
	if terrain == null or not terrain.has_method("get_voxel_tool"):
		return -1
	var vt = terrain.get_voxel_tool()
	if vt == null:
		return -1
	vt.channel = VoxelBuffer.CHANNEL_TYPE  # get_voxel_tool retorna instancia nueva
	return int(vt.get_voxel(voxel_pos)) & 0xFF

## Escribe un bloque en el mundo voxel (M08). No-op si no hay terrain
## (headless/tests sin mundo). set_voxel dispara el re-mesh del chunk (dif de
## chunk automático de Voxel Tools — checklist I3).
func _escribir_bloque(voxel_pos: Vector3i, block_id: int) -> void:
	var terrain = _buscar_terreno()
	if terrain == null or not terrain.has_method("get_voxel_tool"):
		return
	var vt = terrain.get_voxel_tool()
	if vt == null:
		return
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	vt.set_voxel(voxel_pos, block_id)

## Inyección de terrain para tests headless (duck-typed: solo necesita
## get_voxel_tool()). Pasar null para volver al lookup real.
func set_terrain_para_tests(t: Node) -> void:
	_terrain_test = t

## Variante visual del suelo arado (checklist G "suelo húmedo" + I2): húmeda
## si el cultivo tiene agua, seca si no. Regla legible y determinista (sin RNG).
## Solo escribe si el voxel difiere (evita re-mesh innecesario — presupuesto M61).
func _actualizar_voxel_suelo(tile: CropTile) -> void:
	var block_id: int = BlockType.TIERRA_ARADA_HUMEDA if tile.water_level >= 1 else BlockType.TIERRA_ARADA
	if _leer_bloque(tile.voxel_pos) != block_id:
		_escribir_bloque(tile.voxel_pos, block_id)

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
	_actualizar_voxel_suelo(tile)  # M08: tierra arada seca -> húmeda
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
				_actualizar_voxel_suelo(tile)  # M08: lluvia -> variante húmeda

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
		# agregar_items es atómica: si no cabe todo, revierte y devuelve false.
		# El cultivo NO se pierde (regla cozy M152): el tile se conserva en
		# LISTA y se emite crop_harvest_blocked con el sobrante para que la UI
		# avise al jugador (checklist K "inventario lleno").
		if not inv.agregar_items(dict_items):
			crop_harvest_blocked.emit(voxel_pos, items)
			return items
	crop_harvested.emit(voxel_pos, items)
	_visual_fx(voxel_pos, "harvest")
	if tile.crop_def != null and tile.crop_def.is_tree:
		# Perenne: vuelve a MADURA con cooldown frutal
		tile.stage = CropTile.GrowthStage.MADURA
		tile.fruit_cooldown = 2
		tile.grown_days = int(tile.crop_def.grow_days) - 1
		_actualizar_visual(tile)
	else:
		# El bloque TIERRA_ARADA se conserva (checklist I5): la tierra queda
		# arada y reutilizable; solo se va el cultivo (y el agua con él).
		_tiles.erase(voxel_pos)
		_eliminar_visual(voxel_pos)
		_escribir_bloque(voxel_pos, BlockType.TIERRA_ARADA)
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
## Idempotente (K): si el día absoluto ya fue procesado (guardado a mitad del
## avance + recarga), no se reaplica el tick — jamás doble avance de cultivos.
func advance_day() -> void:
	var cal = get_node_or_null("/root/TimeCalendar")
	if cal and cal.has_method("get_dia_absoluto"):
		var dia: int = int(cal.get_dia_absoluto())
		if dia == _ultimo_dia_avanzado:
			day_advanced.emit(dia)
			return
		_ultimo_dia_avanzado = dia
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
		_actualizar_voxel_suelo(tile)  # M08: al secarse (water 0) vuelve a la variante seca
	day_advanced.emit(int(cal.get_dia_absoluto()) if cal else 0)

## Parcelas (M17, reserva simple)
func reserve_plot(owner_id: int, center: Vector3i, radius: int) -> bool:
	if _parcelas.has(center):
		return false
	_parcelas[center] = {"owner": owner_id, "radius": radius}
	return true

## Fertilizante (M13/M15, bono benigno): marca el cultivo como fertilizado.
## Efecto legible (03-Diseno A7): acelera el crecimiento (días dobles) y
## mejora la calidad del rendimiento. Sin penalización por mal uso (RF11).
func fertilize(voxel_pos: Vector3i) -> bool:
	var tile: CropTile = _tiles.get(voxel_pos, null)
	if tile == null or tile.fertilized:
		return false
	tile.fertilized = true
	_actualizar_visual(tile)
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
	data["ultimo_dia"] = _ultimo_dia_avanzado  # idempotencia (K) persistente
	return data

func restore_save_data(data: Dictionary) -> void:
	_arados.clear()
	for a in data.get("arados", []):
		_arados[Vector3i(int(a[0]), int(a[1]), int(a[2]))] = true
	# Recuperar el último día procesado: si el guardado cayó a mitad de un
	# advance_day y el calendario sigue en el mismo día, no se reaplica el tick.
	_ultimo_dia_avanzado = int(data.get("ultimo_dia", -1))
	var tiles = _store.from_save_dict(data, func(crop_id): return _definiciones.get(StringName(crop_id), null))
	_tiles.clear()
	for tile in tiles:
		_tiles[tile.voxel_pos] = tile
		_crear_visual(tile)