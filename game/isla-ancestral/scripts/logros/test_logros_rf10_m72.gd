extends SceneTree
## M72 t6 agnes-3-flash — RF10 (is_unlocked, get_definicion, get_todos, get_estado).
## Pattern correcto (igual que RF2/RF13/RF6): usar el autoload "Achievements" (ya cargado via _ready).
## Ejecutar: godot --headless -s res://scripts/logros/test_logros_rf10_m72.gd

var _ok := 0
var _ko := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("[M72-RF10] Inicializando...")
	var root := _root()
	var ach := root.get_node_or_null("Achievements")
	_verificar(ach != null, "Achievements autoload presente (M72)")
	if ach == null:
		_reportar()
		return
	_test_is_unlocked(ach)
	_test_get_definicion(ach)
	_test_get_todos(ach)
	_test_get_estado(ach)
	_reportar()

func _root() -> Node:
	return root

func _test_is_unlocked(ach) -> void:
	var all = ach.get_todos()
	var ceros := 0
	for l in all:
		if not ach.is_unlocked(l.id):
			ceros += 1
	_verificar(ceros == all.size(), "is_unlocked: %d/%d logros no-desbloqueados al iniciar" % [ceros, all.size()])

func _test_get_definicion(ach) -> void:
	var d = ach.get_definicion("primer_sello")
	_verificar(d != null and d.id == "primer_sello", "get_definicion: existe primer_sello con id correcto")
	var no = ach.get_definicion("no_existe_xyz")
	_verificar(no == null, "get_definicion: id inexistente -> null")

func _test_get_todos(ach) -> void:
	var todos = ach.get_todos()
	_verificar(todos.size() >= 10, "get_todos: >= 10 logros (got %d)" % todos.size())
	var i := 1
	while i < todos.size():
		_verificar(todos[i - 1].orden <= todos[i].orden, "get_todos: ordenado por orden (par %d)" % i)
		i += 1

func _test_get_estado(ach) -> void:
	var st = ach.get_estado("primer_sello")
	_verificar(st is Dictionary, "get_estado: devuelve Dictionary")
	_verificar(st.has("desbloqueado"), "get_estado: incluye 'desbloqueado'")
	_verificar(st.get("desbloqueado") == false, "get_estado: primer_sello no desbloqueado al iniciar")

func _verificar(cond: bool, msg: String) -> void:
	if cond:
		_ok += 1
		print("  [OK] " + msg)
	else:
		_ko += 1
		push_warning("  [FALLO] " + msg)

func _reportar() -> void:
	print("[M72-RF10] OK=%d FALLOS=%d" % [_ok, _ko])
	if _ko > 0:
		print("[M72-RF10] HAY FALLOS")
		quit(1)
	else:
		print("[M72-RF10] TODO OK")
		quit(0)
