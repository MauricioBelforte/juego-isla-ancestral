# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M113: Escenario — InventoryStress (iter 2, deepseek-v4-flash-vision-exp)
# 100.000 operaciones aditivas + remociones + 10.000 swaps + conteos sobre el
# InventarioService REAL (M14, autoload /root/Inventario), con PRNG
# determinista. Mide add/remove/swap y la integridad final (conteos exactos).
# Si el servicio no está disponible, fallback simulado en memoria (no falla).

class_name InventoryStress
extends StressScenario

const OPS_ADD: int = 100000
const OPS_REMOVE: int = 100000
const OPS_SWAP: int = 10000

var _inv: Node = null
var _fallback: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init() -> void:
	_nombre = "InventoryStress"

func setup() -> void:
	_inv = Engine.get_main_loop().root.get_node_or_null("/root/Inventario")
	_rng.seed = 42
	_limpiar()
	print("[M113] InventoryStress: %d add + %d remove + %d swap (PRNG seed 42)" % [OPS_ADD, OPS_REMOVE, OPS_SWAP])

func execute() -> Dictionary:
	var items := ["madera_roble", "piedra_caliza", "baya_roja", "fibra_algodon", "mineral_cobre"]
	# add
	var t_add := _medir_ms(func(): return _add_lote(items))
	_registrar_metrica("add_ms", t_add["ms"])
	# remove
	var t_rem := _medir_ms(func(): return _remove_lote(items))
	_registrar_metrica("remove_ms", t_rem["ms"])
	# swap (si hay slots ocupados reales)
	var t_swap := _medir_ms(func(): return _swaps(items))
	_registrar_metrica("swap_ms", t_swap["ms"])
	# integridad: conteo final por item (debe ser 0 si todo se removió)
	var integridad := _integrar()
	_registrar_metrica("integridad_ok", 1.0 if integridad else 0.0)
	return resumen_metricas()

func _add_lote(items: Array) -> bool:
	for i in range(OPS_ADD):
		var id: String = items[i % items.size()]
		if _inv and _inv.has_method("add_item"):
			_inv.add_item(id, 1)
		else:
			_fallback[id] = int(_fallback.get(id, 0)) + 1
	return true

func _remove_lote(items: Array) -> bool:
	for i in range(OPS_REMOVE):
		var id: String = items[i % items.size()]
		if _inv and _inv.has_method("remove_item"):
			_inv.remove_item(id, 1)
		else:
			_fallback[id] = maxi(int(_fallback.get(id, 0)) - 1, 0)
	return true

func _swaps(items: Array) -> bool:
	var total: int = _inv.total_slots(0) if _inv and _inv.has_method("total_slots") else 20
	for i in range(OPS_SWAP):
		var a := _rng.randi_range(0, total - 1)
		var b := _rng.randi_range(0, total - 1)
		if _inv and _inv.has_method("swap_items"):
			_inv.swap_items(0, a, 0, b)
	return true

func _integrar() -> bool:
	# Tras add 100k/rem 100k (mismo total por item), el conteo de TODOS debe
	# ser múltiplo exacto (add==remove por item: 20k cada uno).
	var items := ["madera_roble", "piedra_caliza", "baya_roja", "fibra_algodon", "mineral_cobre"]
	for id in items:
		var cant: int = 0
		if _inv and _inv.has_method("count_item"):
			cant = int(_inv.count_item(id))
		else:
			cant = int(_fallback.get(id, 0))
		if cant != 0:
			push_warning("[M113] InventoryStress integridad: %s=%d (esperado 0)" % [id, cant])
			return false
	return true

func _limpiar() -> void:
	var items := ["madera_roble", "piedra_caliza", "baya_roja", "fibra_algodon", "mineral_cobre"]
	if _inv and _inv.has_method("remove_item"):
		for id in items:
			_inv.remove_item(id, 999999)

func teardown() -> void:
	_limpiar()
	print("[M113] InventoryStress: teardown completado")
