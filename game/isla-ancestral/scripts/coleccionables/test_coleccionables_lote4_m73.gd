extends SceneTree
## M73 lote4 agnes-3-flash — 6 colecciones: ropa, simbolos, mensajes, secretos, muebles, objetos_historia.
## Ejecutar: godot --headless --path game/isla-ancestral -s res://scripts/coleccionables/test_coleccionables_lote4_m73.gd

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
	_verificar(_mgr.total_count(&"ropa") == 4, "ropa: 4 items")
	_verificar(_mgr.total_count(&"simbolos") == 4, "simbolos: 4 items")
	_verificar(_mgr.total_count(&"mensajes") == 4, "mensajes: 4 items")
	_verificar(_mgr.total_count(&"secretos") == 4, "secretos: 4 items")
	_verificar(_mgr.total_count(&"muebles") == 4, "muebles: 4 items")
	_verificar(_mgr.total_count(&"objetos_historia") == 4, "objetos_historia: 4 items")
	_verificar(_mgr.registrar_por_fuente(&"vestuario", &"001") == true, "vestuario -> ropa_001")
	_verificar(_mgr.registrar_por_fuente(&"simbolo", &"004") == true, "simbolo -> simbolos_004")
	_verificar(_mgr.registrar_por_fuente(&"mensaje", &"002") == true, "mensaje -> mensajes_002")
	_verificar(_mgr.registrar_por_fuente(&"secreto", &"003") == true, "secreto -> secretos_003")
	_verificar(_mgr.registrar_por_fuente(&"mueble", &"003") == true, "mueble -> muebles_003")
	_verificar(_mgr.registrar_por_fuente(&"mision", &"004") == true, "mision -> objetos_historia_004")
	_verificar(_mgr.registrar_por_fuente(&"vestuario", &"001") == false, "ropa_001 idempotente")
	_verificar(_mgr.total_count(&"minerales") == 5 and _mgr.total_count(&"ropa") == 4 and _mgr.total_count(&"objetos_historia") == 4,
		"catalog: 19 categorias coexisten")
	_reportar()

func _verificar(cond: bool, msg: String) -> void:
	if cond:
		_ok += 1
		print("  [OK] " + msg)
	else:
		_ko += 1
		push_warning("  [FALLO] " + msg)

func _reportar() -> void:
	print("[M73-LOTE4] OK=%d FALLOS=%d" % [_ok, _ko])
	if _ko > 0:
		print("[M73-LOTE4] HAY FALLOS")
		quit(1)
	else:
		print("[M73-LOTE4] TODO OK")
		quit(0)
