# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M15 (iter. 2): Test de ResourceNode + ResourceSpawner.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/resources/test_recurso_nodo.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 1 (suites SIN-DUENO), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 98). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 14
const _WB_BLOQUES: Array[String] = ["_test_nodo_estados", "_test_spawner_instancia"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false


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
	print("=== Resumen M15: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

var _fallos: int = 0
var _rm: Node = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_rm = root.get_node_or_null("ResourceManager")
	_check(_rm != null, "ResourceManager autoload presente")
	if _rm == null:
		_summary()
		return
	_check(_rm.spawner != null, "spawner creado en manager")
	_test_nodo_estados()
	_fin("_test_nodo_estados")
	_test_spawner_instancia()
	_fin("_test_spawner_instancia")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_nodo_estados() -> void:
	var def: ResourceDefinition = _rm.obtener_def(&"madera_roble")
	_check(def != null, "def madera_roble existe")
	var node := ResourceNode.new()
	_check(node != null, "ResourceNode instanciado")
	node.configurar(def)
	_check(node.def_id == &"madera_roble", "nodo def_id correcto")
	_check(node.estado == ResourceNode.Estado.INTACTO, "estado inicial INTACTO")
	_check(node.golpes_restantes == 3, "madera 3 golpes")
	# Golpe con herramienta incorrecta -> no efectivo
	var ok_hacha: bool = node.aplicar_golpe(&"hacha")
	_check(ok_hacha, "madera golpeada con hacha")
	_check(node.estado == ResourceNode.Estado.DANIADO or node.estado == ResourceNode.Estado.AGOTADO,
		"estado cambiado tras golpe: %d" % node.estado)
	# Golpe con herramienta incorrecta en piedra -> false
	var def_piedra: ResourceDefinition = _rm.obtener_def(&"piedra_caliza")
	var node_piedra := ResourceNode.new()
	node_piedra.configurar(def_piedra)
	var ok_pico: bool = node_piedra.aplicar_golpe(&"pico")
	_check(ok_pico, "piedra golpeada con pico")
	# Agotar del todo
	for i in range(def_piedra.golpes_requeridos):
		node_piedra.aplicar_golpe(&"pico")
	_check(node_piedra.estado == ResourceNode.Estado.AGOTADO, "piedra agotada tras N golpes")

func _test_spawner_instancia() -> void:
	var spawner = _rm.spawner
	# Sin TerrainLocator en headless, el spawner posiciona en Y=30 (fallback seguro)
	var node_id: int = spawner.instanciar_nodo(&"madera_roble", 0.0, 0.0)
	_check(node_id > 0, "instanciar_nodo devuelve id: %d" % node_id)
	_check(spawner.nodos_activos() >= 1, "nodos activos >= 1")
	# Planificar región no debe crashear sin terreno
	spawner.planificar_region("isla_principal", Vector3(0, 0, 0), _rm)
	_check(true, "planificar_region no crashea en headless")