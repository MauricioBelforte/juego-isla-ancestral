# Modelo: DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
# Plataforma: OpenCode
# Fecha: 2026-10-16
#
# M112 — L75: Integración Agricultura (M33) → Inventario (M14):
# sembrar consume 1 semilla del Inventario; cosechar entrega los items con
# delta real medido en Inventario; caso borde inventario lleno ->
# crop_harvest_blocked + tile conservado (regla cozy), resuelto con
# AutoloadOverrides (L152) en vez del replace_by manual del dev test.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/integration/test_farming_inventory.gd
#
# Guardia anti-falso-verde: _fin() por bloque + CHECKS_MINIMOS medido +
# _summary() en call_deferred SEPARADO + watchdog (patrón test_crafting_inventory.gd).

extends SceneTree

const TIMEOUT_SEG := 90.0
const CHECKS_MINIMOS := 20
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E"]

const AutoloadOverridesScript = preload("res://tests/helpers/autoload_overrides.gd")

var _farm: Node
var _inv: Node

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0

## Posiciones propias del test (lejos de las del lote M33: 310/312/314/316/318/320).
const _POS_B := Vector3i(330, 12, 330)
const _POS_E := Vector3i(336, 12, 336)


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== M33+M14 Agricultura<->Inventario (headless) ===")
	_farm = root.get_node_or_null("Farm")
	_inv = root.get_node_or_null("Inventario")
	_check("autoload Farm presente", _farm != null)
	_check("autoload Inventario presente", _inv != null)
	if _farm == null or _inv == null:
		return
	_bloque_A()
	_bloque_B()
	_bloque_C()
	_bloque_D()
	_bloque_E()


func _on_watchdog() -> void:
	_abortado = true
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("todos los bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen M33+M14: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK - todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO - %d checks fallaron" % _fallos)
		quit(1)


## Semilla que consume plant() para un cultivo (misma regla que FarmService).
func _semilla_de(def: CropDefinition) -> String:
	return str(def.yield_seed_id) if def.yield_seed_id != &"" else str(def.crop_id)


## Llevar un tomate (verano) a LISTA regando día a día (determinista, sin calendario).
func _cultivar_tomate(pos: Vector3i) -> CropTile:
	var def: CropDefinition = _farm.obtener_def(&"tomate")
	if def == null:
		return null
	_inv.agregar_items({_semilla_de(def): 2})
	if not _farm.till_tile(pos):
		return null
	if not _farm.plant(def, pos):
		return null
	var tile: CropTile = _farm.get_tile(pos)
	var d: int = 0
	while tile != null and not tile.is_ready() and d < 12:
		_farm.water(pos)
		tile.apply_daily_tick(1, false)  # verano
		d += 1
	return tile


func _bloque_A() -> void:
	_ini("A. definiciones de cultivo cargadas (Balance -> Farm)")
	_check("definiciones_count > 0", _farm.definiciones_count() > 0,
		"n=%d" % _farm.definiciones_count())
	var def: CropDefinition = _farm.obtener_def(&"tomate")
	_check("obtener_def(tomate) presente", def != null)
	if def:
		_check("tomate: yield_item_id no vacio", str(def.yield_item_id) != "")
		_check("tomate: grow_days > 0", int(def.grow_days) > 0, "grow_days=%d" % def.grow_days)
	_fin("A. definiciones de cultivo cargadas (Balance -> Farm)")


func _bloque_B() -> void:
	_ini("B. sembrar consume 1 semilla del Inventario (M14)")
	var def: CropDefinition = _farm.obtener_def(&"tomate")
	if def == null:
		_check("def de tomate presente", false)
		_fin("B. sembrar consume 1 semilla del Inventario (M14)")
		return
	var semilla: String = _semilla_de(def)
	var n0: int = _inv.count_item(semilla)
	_inv.agregar_items({semilla: 5})
	var n1: int = _inv.count_item(semilla)
	_check("semillas agregadas al Inventario (+5)", n1 == n0 + 5, "n0=%d n1=%d" % [n0, n1])
	_check("till_tile exitoso", _farm.till_tile(_POS_B))
	_check("plant exitoso con semilla disponible", _farm.plant(def, _POS_B))
	var tile: CropTile = _farm.get_tile(_POS_B)
	_check("tile creado en SEMILLA", tile != null and tile.stage == CropTile.GrowthStage.SEMILLA)
	_check("plant consumio exactamente 1 semilla", _inv.count_item(semilla) == n1 - 1,
		"n=%d esperado=%d" % [_inv.count_item(semilla), n1 - 1])
	_check("segundo plant en la misma posicion falla", not _farm.plant(def, _POS_B))
	_fin("B. sembrar consume 1 semilla del Inventario (M14)")


func _bloque_C() -> void:
	_ini("C. crecimiento determinista dia a dia (sin calendario)")
	var tile: CropTile = _farm.get_tile(_POS_B)
	_check("tile de B presente", tile != null)
	if tile == null:
		_fin("C. crecimiento determinista dia a dia (sin calendario)")
		return
	var d: int = 0
	while not tile.is_ready() and d < 12:
		_farm.water(_POS_B)
		tile.apply_daily_tick(1, false)  # verano
		d += 1
	_check("tomate llega a LISTA regando (verano)", tile.is_ready(), "dias=%d" % d)
	_check("grown_days avanzo", tile.grown_days > 0, "grown_days=%d" % tile.grown_days)
	_check("can_harvest true en LISTA", _farm.can_harvest(_POS_B))
	_fin("C. crecimiento determinista dia a dia (sin calendario)")


func _bloque_D() -> void:
	_ini("D. cosechar entrega items al Inventario (delta real)")
	var tile: CropTile = _farm.get_tile(_POS_B)
	_check("tile LISTA presente", tile != null and tile.is_ready())
	if tile == null:
		_fin("D. cosechar entrega items al Inventario (delta real)")
		return
	# Preview determinista (calcular_rendimiento no usa RNG oculto) para saber
	# los ids que van a entrar y medir el delta real contra el Inventario.
	var preview: Array = tile.calcular_rendimiento()
	var antes: Dictionary = {}
	for e in preview:
		antes[str(e["item_id"])] = _inv.count_item(str(e["item_id"]))
	var items: Array = _farm.harvest(_POS_B)
	_check("harvest devuelve items", not items.is_empty())
	# Mismo colapso por id que hace FarmService.harvest antes de agregar_items.
	var esperado: Dictionary = {}
	for e in items:
		esperado[str(e["item_id"])] = int(e["cantidad"])
	var entregado_ok: bool = not esperado.is_empty()
	for id in esperado:
		var delta: int = _inv.count_item(id) - int(antes.get(id, 0))
		if delta != int(esperado[id]):
			entregado_ok = false
			print("    delta %s: %d (esperado %d)" % [id, delta, esperado[id]])
	_check("cada item cosechado entro al Inventario con su cantidad", entregado_ok, str(esperado))
	_check("tile eliminado tras cosechar", _farm.get_tile(_POS_B) == null)
	_check("can_harvest false tras cosechar", not _farm.can_harvest(_POS_B))
	_check("segunda cosecha devuelve []", _farm.harvest(_POS_B).is_empty())
	_fin("D. cosechar entrega items al Inventario (delta real)")


func _bloque_E() -> void:
	_ini("E. inventario lleno: crop_harvest_blocked + tile conservado (L152)")
	var tile: CropTile = _cultivar_tomate(_POS_E)
	_check("tomate LISTA para el test de inventario lleno", tile != null and tile.is_ready())
	if tile == null or not tile.is_ready():
		_fin("E. inventario lleno: crop_harvest_blocked + tile conservado (L152)")
		return
	# Señal con flag por Array mutable (lambda GDScript captura por valor).
	var flag := [false]
	var cb: Callable = func(_p, _its): flag[0] = true
	_farm.crop_harvest_blocked.connect(cb)
	# L152: sustituir /root/Inventario por un stub que rechaza todo.
	var stub := InventarioStub.new()
	var overrides = AutoloadOverridesScript.new(self)
	_check("swap de autoload instalado (L152)", overrides.swap("Inventario", stub))
	_check("ruta /root/Inventario resuelve al stub (nombre preservado)",
		root.get_node_or_null("Inventario") == stub)
	var items: Array = _farm.harvest(_POS_E)
	_check("cosecha con inventario lleno emite crop_harvest_blocked", flag[0])
	_check("tile NO se pierde con inventario lleno (regla cozy)", _farm.get_tile(_POS_E) != null)
	_check("harvest devuelve los items aunque no quepan", not items.is_empty())
	# Restaurar y comprobar que el autoload real vuelve a funcionar.
	_check("restaurar Inventario (L152)", overrides.restaurar("Inventario"))
	_check("swaps activos = 0 tras restaurar", overrides.swaps_activos() == 0)
	_check("/root/Inventario es el autoload real de nuevo", root.get_node_or_null("Inventario") == _inv)
	stub.free()
	_farm.crop_harvest_blocked.disconnect(cb)
	var items2: Array = _farm.harvest(_POS_E)
	_check("tras restaurar, la cosecha real se completa", not items2.is_empty()
		and _farm.get_tile(_POS_E) == null)
	_fin("E. inventario lleno: crop_harvest_blocked + tile conservado (L152)")


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
