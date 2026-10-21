extends SceneTree
## M72 t6 agnes-3-flash — RF10 (is_unlocked, get_definicion, get_todos, get_estado).
## Pattern correcto: extends SceneTree + call_deferred (igual que test_logros_depende_de / rf13 / rf6).
## Ejecutar: godot --headless -s res://scripts/logros/test_logros_rf10_m72.gd

const CATALOG := "res://data/logros/logros.json"
var _ok := 0
var _ko := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("[M72-RF10] Inicializando...")
	var path := ProjectSettings.globalize_path(CATALOG)
	var service = load("res://scripts/logros/achievement_service.gd").new()
	service.inicializar_catalogo(path)
	_test_is_unlocked(service)
	_test_get_definicion(service)
	_test_get_todos(service)
	_test_get_estado(service)
	_reportar()

func _test_is_unlocked(s) -> void:
	var all = s.get_todos()
	var ceros := 0
	for l in all:
		if not s.is_unlocked(l.id):
			ceros += 1
	_verificar(ceros == all.size(), "is_unlocked: %d/%d logros no-desbloqueados al iniciar" % [ceros, all.size()])

func _test_get_definicion(s) -> void:
	var d = s.get_definicion("primer_sello")
	_verificar(d != null and d.id == "primer_sello", "get_definicion: existe primer_sello con id correcto")
	var no = s.get_definicion("no_existe_xyz")
	_verificar(no == null, "get_definicion: id inexistente -> null")

func _test_get_todos(s) -> void:
	var todos = s.get_todos()
	_verificar(todos.size() >= 10, "get_todos: >= 10 logros (got %d)" % todos.size())
	var i := 1
	while i < todos.size():
		_verificar(todos[i - 1].orden <= todos[i].orden, "get_todos: ordenado por orden (par %d)" % i)
		i += 1

func _test_get_estado(s) -> void:
	var st = s.get_estado("primer_sello")
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
