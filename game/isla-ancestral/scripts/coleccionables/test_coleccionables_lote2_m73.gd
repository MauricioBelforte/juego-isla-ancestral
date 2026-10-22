extends SceneTree
## M73 lote2 agnes-3-flash — colecciones nuevas "peces" (M34 pesca) + "plantas" (M33 agricultura).
## Verifica que el catalog las expone + registrar_por_fuente("pesca"/"cosecha") resuelve.
## Ejecutar: godot --headless --path game/isla-ancestral -s res://scripts/coleccionables/test_coleccionables_lote2_m73.gd

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
	# 7 categorias (5 + peces + plantas)
	_verificar(_mgr.total_count(&"peces") == 5, "catalog: 5 peces (got %d)" % _mgr.total_count(&"peces"))
	_verificar(_mgr.total_count(&"plantas") == 5, "catalog: 5 plantas (got %d)" % _mgr.total_count(&"plantas"))
	# registrar_por_fuente resuelve al mapeo (antes no habia items peces/plantas)
	_verificar(_mgr.registrar_por_fuente(&"pesca", &"001") == true, "registrar_por_fuente(pesca,001) -> peces_001")
	_verificar(_mgr.es_collected(&"peces_001"), "peces_001 collected")
	_verificar(_mgr.registrar_por_fuente(&"pesca", &"001") == false, "peces_001 idempotente")
	_verificar(_mgr.registrar_por_fuente(&"cosecha", &"003") == true, "registrar_por_fuente(cosecha,003) -> plantas_003")
	_verificar(_mgr.es_collected(&"plantas_003"), "plantas_003 collected")
	_reportar()

func _verificar(cond: bool, msg: String) -> void:
	if cond:
		_ok += 1
		print("  [OK] " + msg)
	else:
		_ko += 1
		push_warning("  [FALLO] " + msg)

func _reportar() -> void:
	print("[M73-LOTE2] OK=%d FALLOS=%d" % [_ok, _ko])
	if _ko > 0:
		print("[M73-LOTE2] HAY FALLOS")
		quit(1)
	else:
		print("[M73-LOTE2] TODO OK")
		quit(0)
