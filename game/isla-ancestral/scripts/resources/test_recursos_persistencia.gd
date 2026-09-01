extends SceneTree

## M15 iter 3: test de persistencia, respawn y helper de golpe.
## Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/resources/test_recursos_persistencia.gd

var _fallos: int = 0
var _rm: Node = null
var _inv: Node = null
var _gt: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_rm = root.get_node_or_null("ResourceManager")
	_inv = root.get_node_or_null("Inventario")
	_gt = root.get_node_or_null("GameTime")
	_check(_rm != null, "ResourceManager autoload presente")
	_check(_inv != null, "Inventario autoload presente")
	_check(_gt != null, "GameTime autoload presente")
	if _rm == null:
		print("=== TEST M15 ITER3: 1 fallo(s) ===")
		quit(1)
		return
	_test_persistencia_round_trip()
	_test_respawn_con_dia_y_estacion()
	_test_helper_golpe_y_drops()
	_test_registro_y_lista_nodos()
	print("=== TEST M15 ITER3: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Crea y registra un ResourceNode anclado al root (necesario para global_position
## en headless: global_position en nodos sueltos falla con ERR_COND).
func _crear_nodo_registrado(def_id_str: String, pos: Vector3) -> ResourceNode:
	var def: ResourceDefinition = _rm.obtener_def(StringName(def_id_str))
	var nodo := ResourceNode.new()
	nodo.configurar(def)
	root.add_child(nodo)
	nodo.global_position = pos
	_rm.registrar_nodo(nodo)
	return nodo

func _liberar(nodo: ResourceNode) -> void:
	if nodo == null:
		return
	_rm.desregistrar_nodo(nodo)
	if is_instance_valid(nodo):
		nodo.queue_free()

func _test_persistencia_round_trip() -> void:
	var nodo := _crear_nodo_registrado("madera_roble", Vector3(100, 10, 100))
	nodo.estado = ResourceNode.Estado.DANIADO
	nodo.golpes_restantes = 1
	nodo.respawn_dia_absoluto = 42
	# Re-registrar para capturar el estado actualizado
	_rm.desregistrar_nodo(nodo)
	_rm.registrar_nodo(nodo)
	var save: Dictionary = _rm.get_save_data()
	_check(int(save.get("version", 0)) == 2, "save version=2")
	_check(save.get("nodos", []).size() >= 1, "save tiene >=1 nodo")
	_rm.restore_save_data(save)
	var estado: Dictionary = _rm.consumir_estado_guardado_para("madera_roble", Vector3(100, 10, 100))
	_check(int(estado.get("estado", -1)) == ResourceNode.Estado.DANIADO, "estado DANIADO restaurado")
	_check(int(estado.get("golpes_restantes", -1)) == 1, "golpes_restantes=1 restaurado")
	_check(int(estado.get("respawn_dia", -1)) == 42, "respawn_dia=42 restaurado")
	# Consumir de nuevo -> vacío
	var estado2: Dictionary = _rm.consumir_estado_guardado_para("madera_roble", Vector3(100, 10, 100))
	_check(estado2.is_empty(), "estado consumido una sola vez")
	_liberar(nodo)

func _test_respawn_con_dia_y_estacion() -> void:
	# piedra (temporada_respawn="todas" -> respawn_estacion=-1)
	var def_p: ResourceDefinition = _rm.obtener_def(&"piedra_caliza")
	var nodo := ResourceNode.new()
	nodo.configurar(def_p)
	root.add_child(nodo)
	nodo.estado = ResourceNode.Estado.AGOTADO
	nodo.respawn_dia_absoluto = 5
	# Día antes
	var res: bool = nodo.evaluar_respawn(4, 0)
	_check(not res, "no respawnea antes del dia programado")
	_check(nodo.estado == ResourceNode.Estado.AGOTADO, "sigue AGOTADO")
	# Día exacto
	res = nodo.evaluar_respawn(5, 2)
	_check(res, "respawnea en dia exacto (todas las estaciones)")
	_check(nodo.estado == ResourceNode.Estado.INTACTO, "vuelve a INTACTO")
	_check(nodo.respawn_dia_absoluto == 0, "respawn_dia_absoluto reseteado")
	# fibra (respawn_estacion=1 verano)
	var def_f: ResourceDefinition = _rm.obtener_def(&"fibra_algodon")
	var nodo_f := ResourceNode.new()
	nodo_f.configurar(def_f)
	root.add_child(nodo_f)
	nodo_f.estado = ResourceNode.Estado.AGOTADO
	nodo_f.respawn_dia_absoluto = 10
	res = nodo_f.evaluar_respawn(10, 0)
	_check(not res, "fibra no respawnea fuera de verano")
	res = nodo_f.evaluar_respawn(10, 1)
	_check(res and nodo_f.estado == ResourceNode.Estado.INTACTO, "fibra respawnea en verano")
	nodo.queue_free()
	nodo_f.queue_free()

func _test_helper_golpe_y_drops() -> void:
	var nodo := _crear_nodo_registrado("piedra_caliza", Vector3(200, 10, 200))
	var def: ResourceDefinition = _rm.obtener_def(&"piedra_caliza")
	# Herramienta incorrecta
	var ok: bool = _rm.recibir_golpe_en_nodo(nodo, &"hacha")
	_check(not ok, "golpe con hacha en piedra falla")
	# Herramienta correcta: agotar
	for i in range(def.golpes_requeridos):
		_rm.recibir_golpe_en_nodo(nodo, &"pico")
	_check(nodo.estado == ResourceNode.Estado.AGOTADO, "nodo AGOTADO tras helper")
	_check(nodo.respawn_dia_absoluto > 0, "respawn programado")
	_check(_inv.count_item("piedra_caliza") >= 1, "drops entregados a inventario (M14)")
	# Nodo inválido
	_check(not _rm.recibir_golpe_en_nodo(null, &"pico"), "golpe a nodo null falla")
	_liberar(nodo)

func _test_registro_y_lista_nodos() -> void:
	var n1 := _crear_nodo_registrado("baya_roja", Vector3(50, 0, 50))
	var n2 := _crear_nodo_registrado("mineral_cobre", Vector3(60, 0, 60))
	var save: Dictionary = _rm.get_save_data()
	_check(save.get("nodos", []).size() >= 2, "save incluye los 2 nodos registrados")
	var size_antes: int = save.get("nodos", []).size()
	_rm.desregistrar_nodo(n1)
	var save2: Dictionary = _rm.get_save_data()
	_check(save2.get("nodos", []).size() == size_antes - 1, "desregistrar reduce la lista en 1")
	_liberar(n2)
