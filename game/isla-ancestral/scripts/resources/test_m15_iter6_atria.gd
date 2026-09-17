# Modelo: atria-dawn
# Plataforma: Kilo Code
# Fecha: 2026-09-16
#
# M15 iter 6: test de regression de economia (anti doble-entrega de drops) +
# stub cantidad_de. Ejecutar:
# Godot --headless --path game/isla-ancestral --script res://scripts/resources/test_m15_iter6_atria.gd
#
# Descubrimiento iter 6 (atria-dawn, log 937): el spawner conecta node.agotado
# -> _on_nodo_agotado que genera y entrega drops con herramienta vacia, MIENTRAS
# ResourceManager.recibir_golpe_en_nodo entrega los drops reales. Para recursos
# sin herramienta requerida (fibra_algodon, baya_roja) es_accesible_con("") == true
# => doble entrega. Los tests previos usaban `count >= 1` (sin cota superior) y
# por eso nunca lo detectaron.

extends SceneTree

var _fallos: int = 0
var _rm: Node = null
var _inv: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_rm = root.get_node_or_null("ResourceManager")
	_inv = root.get_node_or_null("Inventario")
	_check(_rm != null, "ResourceManager autoload presente")
	_check(_inv != null, "Inventario autoload presente")
	if _rm == null or _inv == null:
		print("=== TEST M15 ITER6: 1 fallo(s) ===")
		quit(1)
		return
	_test_doble_entrega_recurso_sin_herramienta()
	_test_doble_entrega_recurso_con_herramienta()
	_test_cantidad_de_refleja_inventario()
	print("=== TEST M15 ITER6: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Crea un nodo via el spawner (camino real de produccion: conecta agotado ->
## _on_nodo_agotado del spawner, lo registra en el manager, etc.).
func _crear_nodo_via_spawner(def_id: StringName, x: float, z: float) -> ResourceNode:
	var spawner = _rm.get("spawner")
	if spawner == null or not spawner.has_method("instanciar_nodo"):
		return null
	var node_id: int = spawner.instanciar_nodo(def_id, x, z, null)
	if node_id <= 0:
		return null
	var nodos: Dictionary = spawner.obtener_nodos()
	return nodos.get(node_id, null)

func _liberar(nodo: ResourceNode) -> void:
	if nodo == null:
		return
	_rm.desregistrar_nodo(nodo)
	if is_instance_valid(nodo):
		nodo.queue_free()

## Recurso sin herramienta (fibra_algodon): drop unico esperado 2..4 items.
## Si el spawner duplica la entrega, el delta seria 4..8.
func _test_doble_entrega_recurso_sin_herramienta() -> void:
	var antes: int = _inv.count_item("fibra_algodon")
	var nodo: ResourceNode = _crear_nodo_via_spawner(&"fibra_algodon", 150.0, 150.0)
	if nodo == null:
		_check(false, "nodo fibra_algodon creado via spawner")
		return
	_check(nodo.def_id == &"fibra_algodon", "nodo fibra creado con def correcto")
	var ok: bool = _rm.recibir_golpe_en_nodo(nodo, &"")
	_check(ok, "golpe a fibra con herramienta vacia (sin requisito) aceptado")
	_check(nodo.estado == ResourceNode.Estado.AGOTADO, "fibra AGOTADO en 1 golpe")
	var despues: int = _inv.count_item("fibra_algodon")
	var delta: int = despues - antes
	_check(delta >= 2, "fibra entrega al menos el minimo de drops (delta=%d)" % delta)
	_check(delta <= 4, "fibra SIN doble entrega de drops (delta=%d, maximo simple 4)" % delta)
	_liberar(nodo)

## Recurso con herramienta (madera_roble, requiere hacha): drop unico 1..3.
## Si el spawner duplicara, delta 2..6 (aqui el bug es inofensivo porque
## es_accesible_con("") es false, pero se verifica la cota de todos modos).
func _test_doble_entrega_recurso_con_herramienta() -> void:
	var antes: int = _inv.count_item("madera_roble")
	var nodo: ResourceNode = _crear_nodo_via_spawner(&"madera_roble", 160.0, 160.0)
	if nodo == null:
		_check(false, "nodo madera_roble creado via spawner")
		return
	_check(not _rm.recibir_golpe_en_nodo(nodo, &"pico"), "madera rechaza pico")
	var def: ResourceDefinition = _rm.obtener_def(&"madera_roble")
	for i in range(def.golpes_requeridos):
		_rm.recibir_golpe_en_nodo(nodo, &"hacha")
	_check(nodo.estado == ResourceNode.Estado.AGOTADO, "madera AGOTADO tras 3 golpes con hacha")
	var despues: int = _inv.count_item("madera_roble")
	var delta: int = despues - antes
	_check(delta >= 1, "madera entrega al menos 1 drop (delta=%d)" % delta)
	_check(delta <= 3, "madera sin duplicacion de drops (delta=%d, maximo simple 3)" % delta)
	_liberar(nodo)

## cantidad_de() debe reflejar el inventario real (M14). Stub detectado iter 6:
## devolvia 0 fijo con el comentario falso "el inventario no tiene cantidad_de".
## Inventario si lo tiene: count_item().
func _test_cantidad_de_refleja_inventario() -> void:
	var nodo: ResourceNode = _crear_nodo_via_spawner(&"baya_roja", 170.0, 170.0)
	if nodo == null:
		_check(false, "nodo baya_roja creado via spawner")
		return
	var antes_inv: int = _inv.count_item("baya_roja")
	var antes_cantidad_de: int = _rm.cantidad_de(&"baya_roja")
	_check(antes_cantidad_de == antes_inv, "cantidad_de coincide con count_item ANTES (inv=%d cantidad_de=%d)" % [antes_inv, antes_cantidad_de])
	_rm.recibir_golpe_en_nodo(nodo, &"")
	var despues_inv: int = _inv.count_item("baya_roja")
	var despues_cantidad_de: int = _rm.cantidad_de(&"baya_roja")
	_check(despues_cantidad_de == despues_inv, "cantidad_de coincide con count_item DESPUES (inv=%d cantidad_de=%d)" % [despues_inv, despues_cantidad_de])
	_check(despues_cantidad_de > antes_cantidad_de, "cantidad_de refleja la recoleccion (antes=%d despues=%d)" % [antes_cantidad_de, despues_cantidad_de])
	_liberar(nodo)
