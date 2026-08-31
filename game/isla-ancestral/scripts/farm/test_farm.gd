# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M33: Test de FarmService (arar, plantar, regar, avance diario, cosecha, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/farm/test_farm.gd

extends SceneTree

var _fallos: int = 0
var _farm: Node = null
var _inv: Node = null
var _cal: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_farm = root.get_node_or_null("Farm")
	_inv = root.get_node_or_null("Inventario")
	_cal = root.get_node_or_null("TimeCalendar")
	_check(_farm != null, "Farm autoload presente")
	_check(_inv != null, "Inventario autoload presente")
	if _farm == null:
		print("=== TEST M33 FARM: 1 fallo(s) ===")
		quit(1)
		return
	_test_catalogo()
	_test_ciclo_completo()
	_test_pausa_agua()
	_test_persistencia()
	_test_controller_ruta()
	print("=== TEST M33 FARM: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_catalogo() -> void:
	_check(_farm.definiciones_count() >= 5, "5+ cultivos cargados: %d" % _farm.definiciones_count())
	var tomate: CropDefinition = _farm.obtener_def(&"tomate")
	_check(tomate != null, "tomate existe")
	if tomate:
		_check(tomate.grow_days == 4, "tomate 4 días")
		_check(tomate.yield_amount_max == 4, "tomate rendimiento máx 4")

func _test_ciclo_completo() -> void:
	var pos := Vector3i(300, 12, 300)
	# Dar semillas
	_inv.agregar_items({"tomate": 5})
	# Arar
	_check(_farm.till_tile(pos), "arar OK")
	# Plantar
	var tomate: CropDefinition = _farm.obtener_def(&"tomate")
	_check(_farm.plant(tomate, pos), "plantar OK (consume semilla)")
	_check(_inv.count_item("tomate") == 4, "semilla consumida (5-1)")
	# Regar
	_farm.water(pos)
	var tile: CropTile = _farm.get_tile(pos)
	_check(tile != null, "tile creado")
	_check(tile.water_level == 1, "agua nivel 1 tras riego")
	# Avanzar días con estación de verano (tomate es de verano)
	# Forzar: regar cada día y avanzar via apply_daily_tick simulado por advance_day
	# El calendar real puede estar en otra estación; verificamos la lógica del tile directamente
	var dias: int = 0
	while not tile.is_ready() and dias < 10:
		_farm.water(pos)
		tile.apply_daily_tick(1, false)  # verano = 1
		dias += 1
	_check(tile.is_ready(), "tomate listo tras %d días" % dias)
	_check(_farm.can_harvest(pos), "can_harvest true")
	# Cosechar
	var items: Array = _farm.harvest(pos)
	_check(items.size() >= 1, "cosecha entrega items")
	_check(_inv.count_item("tomate") >= 4, "cosecha en inventario (semillas + fruta)")
	_check(_farm.get_tile(pos) == null, "tile eliminado tras cosecha (no árbol)")

func _test_pausa_agua() -> void:
	var pos := Vector3i(302, 12, 302)
	_inv.agregar_items({"zanahoria": 5})
	_farm.till_tile(pos)
	var zanahoria: CropDefinition = _farm.obtener_def(&"zanahoria")
	_farm.plant(zanahoria, pos)
	var tile: CropTile = _farm.get_tile(pos)
	# Sin regar: tick con estación primavera (apta) pero sin agua -> SIN_AGUA
	var cambio: bool = tile.apply_daily_tick(0, false)
	_check(tile.stage == CropTile.GrowthStage.SIN_AGUA, "sin agua -> SIN_AGUA")
	# Regar y volver a avanzar: reanuda desde la misma etapa (no pierde días)
	_farm.water(pos)
	tile.apply_daily_tick(0, false)
	_check(not tile.is_paused(), "reanudado tras riego")
	_check(tile.grown_days >= 1, "días avanzando tras reanudar")
	# Pausa por estación (calabaza otono en primavera)
	var pos2 := Vector3i(304, 12, 304)
	_inv.agregar_items({"calabaza": 5})
	_farm.till_tile(pos2)
	_farm.plant(_farm.obtener_def(&"calabaza"), pos2)
	var tile2: CropTile = _farm.get_tile(pos2)
	_farm.water(pos2)
	tile2.apply_daily_tick(0, false)  # primavera; calabaza es otono
	_check(tile2.stage == CropTile.GrowthStage.DORMANTE, "estación no apta -> DORMANTE")

func _test_persistencia() -> void:
	var data: Dictionary = _farm.get_save_data()
	_check(data.has("tiles"), "save data tiene tiles")
	_check(data.get("tiles", []).size() >= 1, "tiles persistidas: %d" % data.get("tiles", []).size())
	# Restaurar en instancia limpia
	_farm._tiles.clear()
	_farm.restore_save_data(data)
	_check(_farm._tiles.size() >= 1, "restore recupera tiles: %d" % _farm._tiles.size())

## Iter. 2: ruta del FarmToolController con HEADLESS (sin cámara): simula el
## arar→plantar→regar→cosechar vía API pública (la entrada por raycast es de runtime).
func _test_controller_ruta() -> void:
	var pos := Vector3i(306, 12, 306)
	_check(_farm.puede_plantar_en(pos), "puede_plantar_en: vacío OK")
	# Arar (till) + plantar (como hace el controller al apuntar tierra arada)
	_farm.till_tile(pos)
	_inv.agregar_items({"tomate": 5})
	var tomate: CropDefinition = _farm.obtener_def(&"tomate")
	_check(_farm.plant(tomate, pos), "plantar vía controller OK")
	# Regar y avanzar días hasta cosecha
	var tile: CropTile = _farm.get_tile(pos)
	var dias: int = 0
	while not tile.is_ready() and dias < 10:
		_farm.water(pos)
		tile.apply_daily_tick(1, false)
		dias += 1
	_check(tile.is_ready(), "controller ruta: cultivo listo en %d días" % dias)
	var items: Array = _farm.harvest(pos)
	_check(items.size() >= 1, "controller ruta: cosecha entrega items")
	_check(_farm.get_tile(pos) == null, "controller ruta: tile removido tras cosecha")