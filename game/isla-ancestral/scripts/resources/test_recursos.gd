# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M15: Test de ResourceManager (catalogo, drops, definiciones).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/resources/test_recursos.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 1 (suites SIN-DUENO), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 98). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 23
const _WB_BLOQUES: Array[String] = ["_test_catalogo", "_test_drops", "_test_definiciones"]
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
	_test_catalogo()
	_fin("_test_catalogo")
	_test_drops()
	_fin("_test_drops")
	_test_definiciones()
	_fin("_test_definiciones")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_catalogo() -> void:
	var todas: Array = _rm.obtener_todas()
	_check(todas.size() >= 6, "6 tipos de recurso cargados: %d" % todas.size())
	# Verificar cada tipo
	_check(_rm.obtener_def(&"madera_roble") != null, "madera_roble existe")
	_check(_rm.obtener_def(&"piedra_caliza") != null, "piedra_caliza existe")
	_check(_rm.obtener_def(&"fibra_algodon") != null, "fibra_algodon existe")
	_check(_rm.obtener_def(&"baya_roja") != null, "baya_roja existe")
	_check(_rm.obtener_def(&"mineral_cobre") != null, "mineral_cobre existe")
	_check(_rm.obtener_def(&"fragmento_ancestral") != null, "fragmento_ancestral existe")
	# Def inexistente
	_check(_rm.obtener_def(&"no_existe") == null, "def inexistente = null")
	# Propiedades de una definicion
	var madera = _rm.obtener_def(&"madera_roble")
	_check(madera.categoria == ResourceDefinition.Categoria.MADERA, "madera categoria MADERA")
	_check(madera.herramienta_requerida == &"hacha", "madera requiere hacha")
	_check(madera.golpes_requeridos == 3, "madera 3 golpes")
	_check(madera.drops.size() == 1, "madera 1 drop entry")

func _test_drops() -> void:
	# Generar drops con herramienta correcta
	var drops: Dictionary = _rm.generar_drops(&"madera_roble", &"hacha", false)
	_check(drops is Dictionary, "generar_drops devuelve dict")
	_check(drops.size() >= 1, "al menos 1 item generado")
	_check(drops.has("madera_roble"), "contiene madera_roble")
	# Generar drops de fragmento (raro, probabilidad 30%)
	var raro: Dictionary = _rm.generar_drops(&"fragmento_ancestral", &"pico", false)
	_check(raro.size() >= 1, "fragmento genera al menos 1 (garantia anti-frustracion)")
	# Drops con herramienta mejorada
	var def2: ResourceDefinition = _rm.obtener_def(&"madera_roble")
	_check(def2.drops_para_herramienta(false).size() == 1, "drops sin mejora")

func _test_definiciones() -> void:
	var def: ResourceDefinition = _rm.obtener_def(&"piedra_caliza")
	_check(def.es_accesible_con(&"pico", false), "piedra accesible con pico")
	_check(not def.es_accesible_con(&"hacha", false), "piedra NO accesible con hacha")
	var fibra: ResourceDefinition = _rm.obtener_def(&"fibra_algodon")
	_check(fibra.herramienta_requerida == &"", "fibra no requiere herramienta")
	# Drops de un recurso
	var drops: Dictionary = _rm.generar_drops(&"piedra_caliza", &"pico", false)
	_check(drops.get("piedra_caliza", 0) >= 1, "piedra genera 1-2")
	# RNG consistente
	var r1: Dictionary = _rm.generar_drops(&"baya_roja", &"", false)
	_check(r1.size() >= 1, "baya genera al menos 1")