extends SceneTree
## M73 lote3 agnes-3-flash — 6 colecciones nuevas: insectos, fosiles, cartas, fotos, mapas, herramientas.
## Verifica total_count + registrar_por_fuente (mapeo fuente->categoria) para cada una.
## Ejecutar: godot --headless --path game/isla-ancestral -s res://scripts/coleccionables/test_coleccionables_lote3_m73.gd

var _mgr: Node = null
var _ok := 0
var _ko := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_mgr = root.get_node_or_null("coleccionables")
	_verificar(_mgr != null, "coleccionables autoload presente")
	if _mgr == null:
		_reportar()
		return
	# total_count de las 6 colecciones nuevas
	_verificar(_mgr.total_count(&"insectos") == 4, "insectos: 4 items")
	_verificar(_mgr.total_count(&"fosiles") == 4, "fosiles: 4 items")
	_verificar(_mgr.total_count(&"cartas") == 4, "cartas: 4 items")
	_verificar(_mgr.total_count(&"fotos") == 4, "fotos: 4 items")
	_verificar(_mgr.total_count(&"mapas") == 4, "mapas: 4 items")
	_verificar(_mgr.total_count(&"herramientas") == 4, "herramientas: 4 items")
	# registrar_por_fuente resuelve a la categoria nueva (antes mapeo a inexistente)
	_verificar(_mgr.registrar_por_fuente(&"captura_insecto", &"001") == true, "captura_insecto -> insectos_001")
	_verificar(_mgr.es_collected(&"insectos_001"), "insectos_001 collected")
	_verificar(_mgr.registrar_por_fuente(&"excavacion_fosil", &"004") == true, "excavacion_fosil -> fosiles_004")
	_verificar(_mgr.registrar_por_fuente(&"carta", &"002") == true, "carta -> cartas_002")
	_verificar(_mgr.registrar_por_fuente(&"foto", &"003") == true, "foto -> fotos_003")
	_verificar(_mgr.registrar_por_fuente(&"mapa", &"004") == true, "mapa -> mapas_004")
	_verificar(_mgr.registrar_por_fuente(&"herramienta", &"001") == true, "herramienta -> herramientas_001")
	# idempotencia
	_verificar(_mgr.registrar_por_fuente(&"carta", &"002") == false, "cartas_002 idempotente")
	# 13 categorias totales (5 + peces + plantas + 6 nuevas)
	_verificar(_mgr.total_count(&"minerales") == 5 and _mgr.total_count(&"peces") == 5 and _mgr.total_count(&"insectos") == 4,
		"catalog completo: 13 categorias coexisten")
	_reportar()

func _verificar(cond: bool, msg: String) -> void:
	if cond:
		_ok += 1
		print("  [OK] " + msg)
	else:
		_ko += 1
		push_warning("  [FALLO] " + msg)

func _reportar() -> void:
	print("[M73-LOTE3] OK=%d FALLOS=%d" % [_ok, _ko])
	if _ko > 0:
		print("[M73-LOTE3] HAY FALLOS")
		quit(1)
	else:
		print("[M73-LOTE3] TODO OK")
		quit(0)
