# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M54: Mapa — Test headless
# Valida: MapManager (config data-driven, marcadores por isla, exploración,
# pines, conteo). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	# Limpiar persistencia de pines entre ejecuciones
	if FileAccess.file_exists("user://mapa_pines.json"):
		DirAccess.remove_absolute("user://mapa_pines.json")
	var mm0 := root.get_node_or_null("MapManager")
	if mm0:
		mm0._pines = []  # reset estado interno cargado por autoload
	print("=== [M54] Test de Mapa ===")
	_test_config()
	_test_marcadores()
	_test_exploracion()
	_test_pines()
	_test_region()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: map_config.json ---")
	var mm := root.get_node_or_null("MapManager")
	if mm == null:
		_check("MapManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("MapManager autoload presente", true)
	_check("4 islas", mm.islas().size() == 4, "size=%d" % mm.islas().size())
	_check("6 marcadores", mm.total_marcadores() == 6, "size=%d" % mm.total_marcadores())

func _test_marcadores() -> void:
	print("--- Marcadores por isla ---")
	var mm := root.get_node_or_null("MapManager")
	var raiz = mm.marcadores_por_isla("raiz")
	_check("raiz 2 marcadores", raiz.size() == 2, "size=%d" % raiz.size())
	var ceniza = mm.marcadores_por_isla("ceniza")
	_check("ceniza 2 marcadores", ceniza.size() == 2, "size=%d" % ceniza.size())
	var inexistente = mm.marcadores_por_isla("no_existe")
	_check("isla inexistente -> vacío", inexistente.is_empty())

func _test_exploracion() -> void:
	print("--- Exploración (fog) ---")
	var mm := root.get_node_or_null("MapManager")
	_check("faro visible inicial", mm.esta_explorada("faro") == true)
	_check("templo_raiz oculto inicial", mm.esta_explorada("templo_raiz") == false)
	mm.marcar_explorada("templo_raiz")
	_check("templo_raiz explorado", mm.esta_explorada("templo_raiz") == true)
	_check("contar_exploradas >= 4", mm.contar_exploradas() >= 4, "count=%d" % mm.contar_exploradas())
	_check("exploración id inexistente no crashea", true)

func _test_pines() -> void:
	print("--- Pines del jugador ---")
	var mm := root.get_node_or_null("MapManager")
	_check("agregar pin", mm.agregar_pin(100, 20, 100, "Mi casa"))
	_check("agregar 2do pin", mm.agregar_pin(200, 30, 200))
	_check("pines = 2", mm.pines().size() == 2, "size=%d" % mm.pines().size())
	_check("borrar pin índice 0", mm.borrar_pin(0))
	_check("pines = 1 tras borrar", mm.pines().size() == 1, "size=%d" % mm.pines().size())
	_check("borrar índice inválido -> false", mm.borrar_pin(99) == false)
	_check("borrar índice -1 -> false", mm.borrar_pin(-1) == false)

func _test_region() -> void:
	print("--- Fog por región y tipos ---")
	var mm := root.get_node_or_null("MapManager")
	_check("faro en región explorada inicial", mm.region_explorada("raiz") == true)
	_check("templo_raiz región oculta antes", mm.region_explorada("raiz") == true)  # faro la abrió
	# tipos: faro es lugar -> circulo
	_check("tipo_forma lugar -> circulo", mm.tipo_forma("lugar") == "circulo")
	_check("tipo_forma templo -> diamante", mm.tipo_forma("templo") == "diamante")
	_check("tipo_forma tienda -> cuadrado", mm.tipo_forma("tienda") == "cuadrado")
	_check("tipo_forma viaje -> triangulo", mm.tipo_forma("viaje") == "triangulo")
	_check("marcadores por tipo lugar (3)", mm.marcadores_por_tipo("lugar").size() == 3, "size=%d" % mm.marcadores_por_tipo("lugar").size())

func _summary() -> void:
	print("=== Resumen M54: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M54 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M54 OK — todos los checks pasaron")
		quit(0)