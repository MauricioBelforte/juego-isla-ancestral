# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M33: Test del puente M32→M33 (lluvia del clima riega cultivos expuestos).
# Complementa test_farm.gd (núcleo Deepseek) — no lo reemplaza.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/farm/test_farm_clima.gd

extends SceneTree

var _fallos: int = 0
var _farm: Node = null
var _bus: Node = null
var _inv: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_farm = root.get_node_or_null("Farm")
	_bus = root.get_node_or_null("EventBus")
	_inv = root.get_node_or_null("Inventario")
	_check(_farm != null, "Farm autoload presente")
	_check(_bus != null and _bus.weather != null, "EventBus.weather presente")
	if _farm == null or _bus == null or _inv == null:
		print("=== TEST M33 CLIMA: 1+ fallo(s) ===")
		quit(1)
		return
	_test_riego_por_lluvia()
	_test_sin_exceso()
	_test_climas_secos_no_riegan()
	print("=== TEST M33 CLIMA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _plantar_en(pos: Vector3i) -> void:
	_inv.agregar_items({"tomate": 1})
	_check(_farm.till_tile(pos), "arar %s" % pos)
	var tomate: CropDefinition = _farm.obtener_def(&"tomate")
	_check(_farm.plant(tomate, pos), "plantar %s" % pos)

func _test_riego_por_lluvia() -> void:
	var pos := Vector3i(340, 14, 340)
	_plantar_en(pos)
	var tile = _farm.get_tile(pos)
	_check(tile != null and tile.water_level == 0, "cultivo recién plantado sin agua")
	# Lluvia (clima 2) vía EventBus: el puente dispara apply_rain
	_bus.weather.clima_cambio.emit(2)
	tile = _farm.get_tile(pos)
	_check(tile.water_level == 2, "lluvia riega a máximo (0→2)")
	_check(_farm.can_harvest(pos) == false, "regado ≠ listo")

func _test_sin_exceso() -> void:
	# G: lluvia sobre cultivo ya regado no excede el máximo
	var pos := Vector3i(341, 14, 341)
	_plantar_en(pos)
	_farm.water(pos)
	_farm.water(pos)  # regar() suma 1 por llamada (máx 2)
	var tile = _farm.get_tile(pos)
	_check(tile.water_level == 2, "regado manual a 2")
	# Las lambdas capturan por valor: usar contenedor mutable para contar
	var eventos: Array = [0]
	var cb := func(_p: Vector3i, _w: int) -> void:
		eventos[0] += 1
	_farm.tile_watered.connect(cb)
	_bus.weather.clima_cambio.emit(2)
	_check(eventos[0] == 0, "sin señal redundante con cultivo ya a máximo")
	_farm.tile_watered.disconnect(cb)

func _test_climas_secos_no_riegan() -> void:
	var pos := Vector3i(342, 14, 342)
	_plantar_en(pos)
	var tile = _farm.get_tile(pos)
	tile.water_level = 0
	# SOLEADO (0), NUBLADO (1), NIEBLA (4), NIEVE (5), VIENTO (6): sin riego
	for clima in [0, 1, 4, 5, 6]:
		_bus.weather.clima_cambio.emit(clima)
		tile = _farm.get_tile(pos)
		_check(tile.water_level == 0, "clima seco %d no riega" % clima)
	# TORMENTA (3) y TROPICAL (7) sí riegan
	_bus.weather.clima_cambio.emit(3)
	tile = _farm.get_tile(pos)
	_check(tile.water_level == 2, "tormenta riega")
	tile.water_level = 0
	_bus.weather.clima_cambio.emit(7)
	tile = _farm.get_tile(pos)
	_check(tile.water_level == 2, "tropical riega")
