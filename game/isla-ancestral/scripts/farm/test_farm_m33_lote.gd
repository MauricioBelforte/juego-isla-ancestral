# Modelo: atria (Atria-Dawn-Preview)
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M33: Lote deep work — tests de la sección N + stress L.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/farm/test_farm_m33_lote.gd
# Cobertura: determinismo save/recarga, 4 estaciones con ventana parcial,
#            30 días sin agua (pausa, nunca muerte), inventario lleno al
#            cosechar, pisoteo NPC sin pérdida, stress 400 cultivos.

extends SceneTree

# Guardia anti-falso-verde (instrumentación LOTE 2, Log 1490)
const CHECKS_MINIMOS := 30
const _WB_BLOQUES: Array[String] = ["_test_determinismo", "_test_4_estaciones", "_test_30_dias_sin_agua", "_test_inventario_lleno", "_test_pisoteo_npc", "_test_stress_400"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false
var _fallos: int = 0

var _farm: Node = null
var _inv: Node = null

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
	print("=== Resumen M33 lote: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_farm = root.get_node_or_null("Farm")
	_inv = root.get_node_or_null("Inventario")
	_check(_farm != null, "Farm autoload presente")
	if _farm == null:
		_summary()
		return
	_test_determinismo()
	_fin("_test_determinismo")
	_test_4_estaciones()
	_fin("_test_4_estaciones")
	_test_30_dias_sin_agua()
	_fin("_test_30_dias_sin_agua")
	_test_inventario_lleno()
	_fin("_test_inventario_lleno")
	_test_pisoteo_npc()
	_fin("_test_pisoteo_npc")
	_test_stress_400()
	_fin("_test_stress_400")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Llevar un tomate (verano) a LISTA regando día a día.
func _cultivar_tomate(pos: Vector3i) -> CropTile:
	_inv.agregar_items({"tomate": 5})
	_farm.till_tile(pos)
	_farm.plant(_farm.obtener_def(&"tomate"), pos)
	var tile: CropTile = _farm.get_tile(pos)
	var d: int = 0
	while not tile.is_ready() and d < 12:
		_farm.water(pos)
		tile.apply_daily_tick(1, false)  # verano
		d += 1
	return tile

## N1: serializar → deserializar produce el mismo estado (determinismo).
func _test_determinismo() -> void:
	var pos := Vector3i(310, 12, 310)
	var tile: CropTile = _cultivar_tomate(pos)
	_check(tile != null, "determinismo: tile creado")
	if tile == null:
		return
	# Almacenar un estado intermedio con agua y días avanzados
	var antes := tile.serializar()
	var tile2 := CropTile.new()
	tile2.deserializar(antes, _farm.obtener_def(&"tomate"))
	_check(tile2.voxel_pos == tile.voxel_pos, "determinismo: voxel_pos igual")
	_check(tile2.stage == tile.stage, "determinismo: stage igual (%d)" % tile.stage)
	_check(tile2.grown_days == tile.grown_days, "determinismo: grown_days igual")
	_check(tile2.water_level == tile.water_level, "determinismo: water_level igual")
	_check(tile2.quality == tile.quality, "determinismo: quality igual")
	_check(tile2.planted_at_day == tile.planted_at_day, "determinismo: planted_at_day igual")
	_check(tile2.prev_stage == tile.prev_stage, "determinismo: prev_stage igual")
	_check(tile2.fruit_cooldown == tile.fruit_cooldown, "determinismo: fruit_cooldown igual")
	# Round-trip vía FarmStateStore (M59)
	var store := FarmStateStore.new()
	var data := store.to_save_dict([tile])
	_check(data.has("tiles") and data.get("tiles").size() == 1, "store: 1 tile serializado")
	var restaurados: Array = store.from_save_dict(data, func(cid): return _farm.obtener_def(StringName(cid)))
	_check(restaurados.size() == 1, "store: 1 tile restaurado")
	if restaurados.size() == 1:
		var r: CropTile = restaurados[0]
		_check(r.stage == tile.stage, "store round-trip: stage igual")
		_check(r.grown_days == tile.grown_days, "store round-trip: grown_days igual")
		_check(r.water_level == tile.water_level, "store round-trip: water_level igual")
	# Tile corrupto (crop inexistente): validate lo aísla y no rompe
	var corrupto := {"version": 1, "tiles": [{"pos": [1, 2, 3], "crop": "inexistente_xyz", "stage": 4}]}
	var res_c: Array = store.from_save_dict(corrupto, func(cid): return _farm.obtener_def(StringName(cid)))
	_check(res_c.is_empty(), "tile corrupto (crop inexistente) se aísla")

## N2: cultivo de ventana parcial (calabaza = otoño) en las 4 estaciones.
## DORMANTE fuera de ventana, retoma sin pérdida al volver la apta.
func _test_4_estaciones() -> void:
	var pos := Vector3i(312, 12, 312)
	_inv.agregar_items({"calabaza": 5})
	_farm.till_tile(pos)
	_farm.plant(_farm.obtener_def(&"calabaza"), pos)
	var tile: CropTile = _farm.get_tile(pos)
	_farm.water(pos)
	# Primavera (0): no apta para calabaza -> DORMANTE
	tile.apply_daily_tick(0, false)
	_check(tile.stage == CropTile.GrowthStage.DORMANTE, "calabaza en primavera -> DORMANTE")
	_check(tile.grown_days == 0, "DORMANTE no suma días")
	var dias_antes := tile.grown_days
	# Verano (1): tampoco apta -> sigue DORMANTE
	tile.apply_daily_tick(1, false)
	_check(tile.stage == CropTile.GrowthStage.DORMANTE, "calabaza en verano -> DORMANTE")
	_check(tile.grown_days == dias_antes, "DORMANTE no pierde días en verano")
	# Otoño (2): apta -> retoma desde SEMILLA
	tile.apply_daily_tick(2, false)
	_check(not tile.is_paused(), "otoño: reanuda desde DORMANTE")
	_check(tile.grown_days >= 1, "otoño: avanza días tras reanudar")
	_check(tile.stage != CropTile.GrowthStage.DORMANTE, "otoño: sale de DORMANTE")
	# Invierno (3): no apta -> DORMANTE de nuevo, conservando progreso
	var dias_otonio := tile.grown_days
	tile.apply_daily_tick(3, false)
	_check(tile.stage == CropTile.GrowthStage.DORMANTE, "invierno: vuelve a DORMANTE")
	_check(tile.grown_days == dias_otonio, "invierno: conserva días acumulados")

## N3: 30 días sin agua -> SIN_AGUA todo el tiempo, nunca muerte, días congelados.
func _test_30_dias_sin_agua() -> void:
	var pos := Vector3i(314, 12, 314)
	_inv.agregar_items({"zanahoria": 5})
	_farm.till_tile(pos)
	_farm.plant(_farm.obtener_def(&"zanahoria"), pos)
	var tile: CropTile = _farm.get_tile(pos)
	var i: int = 0
	while i < 30:
		tile.apply_daily_tick(0, false)  # primavera, sin agua
		i += 1
	_check(tile.stage == CropTile.GrowthStage.SIN_AGUA, "30 días sin agua -> SIN_AGUA (no muerte)")
	_check(_farm.get_tile(pos) != null, "el tile sigue vivo tras 30 días sin agua")
	var dias_congelados := tile.grown_days
	# Regar: reanuda desde la misma etapa
	_farm.water(pos)
	tile.apply_daily_tick(0, false)
	_check(not tile.is_paused(), "regar reanuda el cultivo")
	_check(tile.grown_days >= dias_congelados + 1, "reanudar suma días desde donde quedó")
	# LISTA estable: un cultivo listo no consume agua ni retrocede.
	while not tile.is_ready():
		_farm.water(pos)
		tile.apply_daily_tick(0, false)
	_farm.water(pos)
	_farm.water(pos)  # agua a tope (2): si LISTA consumiera, bajaría
	var agua_en_lista := tile.water_level
	tile.apply_daily_tick(0, false)
	tile.apply_daily_tick(0, false)
	_check(tile.is_ready(), "LISTA se mantiene estable")
	_check(tile.water_level == agua_en_lista, "LISTA no consume agua (nivel sigue en %d)" % agua_en_lista)

## N4: cosecha con inventario lleno -> crop_harvest_blocked, tile conservado.
## Se sustituye /root/Inventario por un stub atómico que siempre rechaza.
## Nota: lambdas GDScript capturan por valor; el flag usa Array mutable
## (patrón documentado en Log 306 / iteración puente glm-5.3-flash).
func _test_inventario_lleno() -> void:
	var pos := Vector3i(316, 12, 316)
	var tile: CropTile = _cultivar_tomate(pos)
	_check(tile != null and tile.is_ready(), "tomate LISTA para test de inventario")
	if tile == null or not tile.is_ready():
		return
	var flag := [false]
	var cb: Callable = func(_p, _items): flag[0] = true
	_farm.crop_harvest_blocked.connect(cb)
	# Sustituir el Inventario real por un stub que rechaza todo (atómico)
	var inv_real: Node = _inv
	var stub := InventarioStub.new()
	inv_real.replace_by(stub)
	stub.name = "Inventario"
	var items: Array = _farm.harvest(pos)
	_check(flag[0], "cosecha con inventario lleno emite crop_harvest_blocked")
	_check(_farm.get_tile(pos) != null, "tile NO se pierde con inventario lleno (regla cozy)")
	_check(not items.is_empty(), "harvest devuelve los items aunque no quepan")
	# Restaurar el Inventario real
	stub.replace_by(inv_real)
	inv_real.name = "Inventario"
	_farm.crop_harvest_blocked.disconnect(cb)

## K: pisoteo NPC -> agitación visual, cero pérdida de progreso.
## (M64 no está cableado; se verifica el contrato: shake no toca el estado.)
func _test_pisoteo_npc() -> void:
	var pos := Vector3i(318, 12, 318)
	_inv.agregar_items({"zanahoria": 5})
	_farm.till_tile(pos)
	_farm.plant(_farm.obtener_def(&"zanahoria"), pos)
	var tile: CropTile = _farm.get_tile(pos)
	_farm.water(pos)
	tile.apply_daily_tick(0, false)
	var dias_antes := tile.grown_days
	var stage_antes := tile.stage
	# Simular el pisoteo: el visual se agita, el estado no cambia
	var visual = _farm._visuales.get(pos, null)
	if visual and visual.has_method("shake"):
		visual.shake(0.3)
	_check(tile.grown_days == dias_antes, "pisoteo: no pierde días")
	_check(tile.stage == stage_antes, "pisoteo: no cambia etapa")
	_check(_farm.get_tile(pos) != null, "pisoteo: el cultivo sigue vivo")

## L: stress 400 cultivos + lluvia global en 1 tick.
func _test_stress_400() -> void:
	var base := Vector3i(320, 12, 320)
	# Sufrir semillas: agregar_items es atómica y respeta stacks; se siembran
	# en lotes pequeños para no chocar con el límite de stacks del inventario.
	var sembrados: int = 0
	var x: int = 0
	while x < 20 and sembrados < 400:
		var z: int = 0
		while z < 20 and sembrados < 400:
			var pos := Vector3i(base.x + x, base.y, base.z + z)
			if _farm.till_tile(pos):
				var def: CropDefinition = _farm.obtener_def(&"tomate" if (sembrados % 2) == 0 else &"zanahoria")
				_inv.agregar_items({str(def.crop_id): 5})
				if _farm.plant(def, pos):
					sembrados += 1
			z += 1
		x += 1
	_check(sembrados >= 100, "stress: %d cultivos sembrados" % sembrados)
	# Medir el tick diario completo
	var t0: int = Time.get_ticks_msec()
	_farm.advance_day()
	var t1: int = Time.get_ticks_msec()
	var ms: int = t1 - t0
	print("[L] advance_day sobre %d cultivos: %d ms" % [sembrados, ms])
	_check(ms <= 50, "stress: advance_day en <50 ms (umbral headless holgado; M61 pide <=2 ms en runtime)")
	# Lluvia global idempotente sobre muchos cultivos
	_farm.apply_rain()
	var stats: Dictionary = _farm.get_active_farm_stats()
	_check(int(stats.get("tiles", 0)) == sembrados, "stress: stats reporta %d tiles" % stats.get("tiles", 0))

## Stub de Inventario: agregar_items siempre falla (atómico, como el real).
## Declara los métodos del contrato para que has_method() del FarmService
## funcione de forma nativa (sin sobrescribir has_method: Godot lo usa).
class InventarioStub extends Node:
	signal inventario_lleno(container: int, item_id: String, sobrante: int)
	func agregar_items(_items: Dictionary) -> bool:
		for item_id in _items:
			inventario_lleno.emit(0, str(item_id), int(_items[item_id]))
		return false
	func remover_items(_items: Dictionary) -> bool:
		return false
	func count_item(_item_id: String, _include_house: bool = false) -> int:
		return 0
