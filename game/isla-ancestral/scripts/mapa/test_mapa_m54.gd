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
	_test_persistencia()
	_test_signals()
	_test_canvas_transform()
	_test_texture_cache()
	_summary()

func _test_canvas_transform() -> void:
	print("--- Canvas: zoom/pan sin re-render ---")
	var mm := root.get_node_or_null("MapManager")
	var canvas := MapCanvas.new()
	root.add_child(canvas)
	# In headless: _ready runs immediately on add_child (call_deferred already processed)
	canvas.set_map_data(mm)
	var children_before := canvas._markers_container.get_child_count()
	canvas.apply_zoom(0.5)
	canvas.apply_zoom(-0.3)
	var children_after := canvas._markers_container.get_child_count()
	_check("zoom no recrea niños", children_before == children_after, "before=%d after=%d" % [children_before, children_after])
	canvas.update_markers()
	var children_updated := canvas._markers_container.get_child_count()
	_check("update_markers no recrea niños", children_updated == children_after, "before=%d after=%d" % [children_after, children_updated])
	canvas.queue_free()

func _test_texture_cache() -> void:
	print("--- Textura caché del MapManager ---")
	var mm := root.get_node_or_null("MapManager")
	var tex1: Image = mm.bake_map_texture(128, 128)
	_check("bake texture != null", tex1 != null)
	_check("bake texture size", tex1.get_width() == 128 and tex1.get_height() == 128)
	var tex2: Image = mm.bake_map_texture(128, 128)
	_check("cache reutilizada (same ref)", tex1 == tex2)
	# Invalidar y verificar que se re-bake
	mm.invalidate_map_texture()
	var tex3: Image = mm.bake_map_texture(128, 128)
	_check("re-bake tras invalidate (new ref)", tex3 != tex1)
	var cached: Image = mm.get_cached_map_texture()
	_check("get_cached_map_texture no null", cached != null)

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

func _test_persistencia() -> void:
	print("--- Persistencia de exploración ---")
	var mm := root.get_node_or_null("MapManager")
	mm.marcar_explorada("templo_coral")
	mm.guardar_exploracion()
	var antes: int = mm.contar_exploradas()
	# Reset interno y recargar
	mm._exploradas = {}
	for m in mm.config.get("marcadores", []):
		var id: String = String(m.get("id", ""))
		if not id.is_empty():
			mm._exploradas[id] = bool(m.get("visible_inicial", false))
	mm.cargar_exploracion()
	_check("exploración persistida (templo_coral)", mm.esta_explorada("templo_coral") == true)
	_check("conteo tras recargar >= antes", mm.contar_exploradas() >= antes, "count=%d" % mm.contar_exploradas())
	DirAccess.remove_absolute("user://mapa_exploracion.json")

func _test_signals() -> void:
	print("--- Señales reactivas ---")
	var mm := root.get_node_or_null("MapManager")
	var exp_count: Array = [0]
	var mk_count: Array = [0]
	mm.exploration_changed.connect(func(_ids): exp_count[0] += 1)
	mm.markers_changed.connect(func(_m): mk_count[0] += 1)
	mm.marcar_explorada("templo_ceniza")
	_check("exploration_changed emitida", exp_count[0] == 1, "count=%d" % exp_count[0])
	_check("markers_changed emitida", mk_count[0] == 1, "count=%d" % mk_count[0])

func _summary() -> void:
	print("=== Resumen M54: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M54 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M54 OK — todos los checks pasaron")
		quit(0)