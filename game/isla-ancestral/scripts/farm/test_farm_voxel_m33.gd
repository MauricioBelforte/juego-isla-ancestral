# Modelo: atria (Atria-Dawn-Preview)
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M33+M08: Tests de integración voxel — bloque TIERRA_ARADA (31) + variante
# húmeda TIERRA_ARADA_HUMEDA (32).
# Cobertura: arar escribe el voxel, regar/lluvia dejan la variante húmeda, al
# secarse vuelve a la seca, cosechar conserva la tierra arada, un cambio de
# voxel externo (nieve M32) no borra el estado, y sin terrain (headless puro)
# el servicio sigue funcionando en modo lógico.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/farm/test_farm_voxel_m33.gd

extends SceneTree

# Guardia anti-falso-verde (instrumentación LOTE 2, Log 1490)
const CHECKS_MINIMOS := 20
const _WB_BLOQUES: Array[String] = ["_test_arar_escribe_voxel", "_test_variante_humeda_y_seca", "_test_lluvia_humeda", "_test_cosecha_conserva_arada", "_test_nieve_no_borra_estado", "_test_sin_terrain_headless"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false
var _fallos: int = 0

var _farm: Node = null
var _inv: Node = null

## VoxelTool fake (duck-typed): registra los voxels escritos.
class FakeVT extends RefCounted:
	var channel: int = 0
	var _voxels: Dictionary = {}
	func set_voxel(pos: Vector3i, value: int) -> void:
		_voxels[pos] = value
	func get_voxel(pos: Vector3i) -> int:
		return int(_voxels.get(pos, 1))  # DIRT por defecto (validación de till)

## Terrain fake (duck-typed): FarmService lo resuelve vía set_terrain_para_tests.
class FakeTerrain extends Node:
	var _vt: FakeVT = null
	func _init() -> void:
		_vt = FakeVT.new()
	func get_voxel_tool() -> FakeVT:
		return _vt

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true

func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M33+M08 voxel: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_farm = root.get_node_or_null("Farm")
	_inv = root.get_node_or_null("Inventario")
	_check(_farm != null, "Farm autoload presente")
	_check(_inv != null, "Inventario autoload presente")
	if _farm == null:
		_summary()
		return
	_test_arar_escribe_voxel()
	_fin("_test_arar_escribe_voxel")
	_test_variante_humeda_y_seca()
	_fin("_test_variante_humeda_y_seca")
	_test_lluvia_humeda()
	_fin("_test_lluvia_humeda")
	_test_cosecha_conserva_arada()
	_fin("_test_cosecha_conserva_arada")
	_test_nieve_no_borra_estado()
	_fin("_test_nieve_no_borra_estado")
	_test_sin_terrain_headless()
	_fin("_test_sin_terrain_headless")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## V1: arar escribe el bloque TIERRA_ARADA (31) en el voxel (checklist I1 + I3).
func _test_arar_escribe_voxel() -> void:
	var t := FakeTerrain.new()
	_farm.set_terrain_para_tests(t)
	var pos := Vector3i(400, 8, 400)
	_check(_farm.till_tile(pos), "arar OK con terrain inyectado")
	_check(int(t.get_voxel_tool().get_voxel(pos)) == BlockType.TIERRA_ARADA, "arar escribe TIERRA_ARADA (31) en el voxel")
	_check(_farm.puede_plantar_en(pos), "la tierra arada permite plantar")
	_farm.set_terrain_para_tests(null)

## V2: regar deja la variante húmeda (32); al consumirse el agua (advance_day)
## el suelo vuelve a la variante seca (31). Zanahoria = primavera (estación
## inicial del TimeCalendar), aguaNeed 1.
func _test_variante_humeda_y_seca() -> void:
	var t := FakeTerrain.new()
	_farm.set_terrain_para_tests(t)
	var pos := Vector3i(402, 8, 402)
	_farm.till_tile(pos)
	_check(int(t.get_voxel_tool().get_voxel(pos)) == BlockType.TIERRA_ARADA, "recien arada: variante seca (31)")
	_inv.agregar_items({"zanahoria": 5})
	_check(_farm.plant(_farm.obtener_def(&"zanahoria"), pos), "plantar zanahoria")
	var tile: CropTile = _farm.get_tile(pos)
	_check(tile != null, "tile creado")
	_farm.water(pos)
	_check(int(t.get_voxel_tool().get_voxel(pos)) == BlockType.TIERRA_ARADA_HUMEDA, "regar -> variante humeda (32)")
	_farm.advance_day()  # consume 1 de agua (TimeCalendar inicia en primavera=0, apta)
	_check(tile.water_level == 0, "advance_day consume el agua del cultivo")
	_check(int(t.get_voxel_tool().get_voxel(pos)) == BlockType.TIERRA_ARADA, "al secarse vuelve a la variante seca (31)")
	_farm.set_terrain_para_tests(null)

## V3: la lluvia (apply_rain, puente M32) también deja la variante húmeda.
func _test_lluvia_humeda() -> void:
	var t := FakeTerrain.new()
	_farm.set_terrain_para_tests(t)
	var pos := Vector3i(403, 8, 403)
	_farm.till_tile(pos)
	_inv.agregar_items({"zanahoria": 5})
	_check(_farm.plant(_farm.obtener_def(&"zanahoria"), pos), "plantar zanahoria (lluvia)")
	_farm.apply_rain()  # riega todos los cultivos expuestos (sin techo aún)
	_check(int(t.get_voxel_tool().get_voxel(pos)) == BlockType.TIERRA_ARADA_HUMEDA, "apply_rain -> variante humeda (32)")
	_farm.set_terrain_para_tests(null)

## V4: cosechar conserva la tierra arada — el bloque NO vuelve a DIRT (checklist I5).
func _test_cosecha_conserva_arada() -> void:
	var t := FakeTerrain.new()
	_farm.set_terrain_para_tests(t)
	var pos := Vector3i(404, 8, 404)
	_farm.till_tile(pos)
	_inv.agregar_items({"zanahoria": 5})
	_farm.plant(_farm.obtener_def(&"zanahoria"), pos)
	var tile: CropTile = _farm.get_tile(pos)
	var d: int = 0
	while not tile.is_ready() and d < 10:
		_farm.water(pos)
		tile.apply_daily_tick(0, false)  # primavera, sin lluvia
		d += 1
	_check(tile.is_ready(), "zanahoria llego a LISTA")
	var items: Array = _farm.harvest(pos)
	_check(not items.is_empty(), "harvest entrega items")
	_check(_farm.get_tile(pos) == null, "harvest elimina el tile (no es arbol)")
	_check(int(t.get_voxel_tool().get_voxel(pos)) == BlockType.TIERRA_ARADA, "cosecha: el bloque sigue TIERRA_ARADA (no DIRT)")
	_check(_farm.puede_plantar_en(pos), "la tierra sigue arada y reutilizable")
	_farm.set_terrain_para_tests(null)

## V5: un cambio de voxel externo (nieve M32 u otro módulo escribiendo encima)
## no borra el estado agrícola: el estado vive en el servicio, no en el voxel
## (checklist I6).
func _test_nieve_no_borra_estado() -> void:
	var t := FakeTerrain.new()
	_farm.set_terrain_para_tests(t)
	var pos := Vector3i(405, 8, 405)
	_farm.till_tile(pos)
	_inv.agregar_items({"zanahoria": 5})
	_check(_farm.plant(_farm.obtener_def(&"zanahoria"), pos), "plantar zanahoria (nieve)")
	# Simular nieve u otro módulo escribiendo el voxel por encima
	t.get_voxel_tool().set_voxel(pos, BlockType.SNOW)
	_check(_farm.get_tile(pos) != null, "el tile sobrevive a un voxel externo (estado en el servicio)")
	_check(_farm.puede_plantar_en(pos) == false, "sigue habiendo un cultivo (no se puede replantar)")
	_check(not _farm.get_growth_hint(pos).is_empty(), "get_growth_hint sigue funcionando")
	_check(_farm.can_harvest(pos) == false, "no cosechable todavia (no llego a LISTA)")
	_farm.set_terrain_para_tests(null)

## V6: sin terrain (headless puro, sin escena cargada) el servicio funciona en
## modo lógico: arar/plantar sin tocar el mundo voxel.
func _test_sin_terrain_headless() -> void:
	_farm.set_terrain_para_tests(null)  # sin inyección: el lookup real no halla VoxelTerrain
	var pos := Vector3i(406, 8, 406)
	_check(_farm.till_tile(pos), "arar OK sin terrain (modo lógico)")
	_check(_farm.puede_plantar_en(pos), "puede_plantar_en sin terrain")
	_inv.agregar_items({"zanahoria": 5})
	_check(_farm.plant(_farm.obtener_def(&"zanahoria"), pos), "plantar OK sin terrain")
	_check(_farm.get_tile(pos) != null, "tile creado sin terrain")
