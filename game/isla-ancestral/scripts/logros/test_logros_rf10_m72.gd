extends SceneTree
## M72 t6 agnes-3-flash — RF10 (is_unlocked, get_definicion, get_todos, get_estado).
## Pattern correcto (igual que RF2/RF13/RF6): usar el autoload "Achievements" (ya cargado via _ready).
##
## ENDURECIDO 2026-10-26 (residuo M72, DeepSeek-V4.1-Flash): `_test_get_definicion`
## pedia `get_definicion("primer_sello")`, un id que NO existe (el real es
## `logro_primer_sello`). `get_definicion()` devuelve `{}` para id desconocido
## (NUNCA null), asi que `d.id` lanzaba SCRIPT ERROR, la funcion abortaba y sus
## 2 checks no corrian: la suite publicaba "OK=23 FALLOS=0" + EXIT 0.
## Ademas se agregan las 3 capas (piso de checks + `_fin(bloque)` + `_summary()`
## diferido aparte) y se corrige el contrato documentado: id inexistente -> `{}`.
## Ejecutar: godot --headless --path game/isla-ancestral -s res://scripts/logros/test_logros_rf10_m72.gd

const CHECKS_MINIMOS := 27
const BLOQUES := ["is_unlocked", "definicion", "todos", "estado"]

var _ok := 0
var _ko := 0
var _checks := 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_reportar")

func _run() -> void:
	print("[M72-RF10] Inicializando...")
	var root := _root()
	var ach := root.get_node_or_null("Achievements")
	_verificar(ach != null, "Achievements autoload presente (M72)")
	if ach == null:
		return
	_test_is_unlocked(ach)
	_test_get_definicion(ach)
	_test_get_todos(ach)
	_test_get_estado(ach)

func _root() -> Node:
	return root

func _test_is_unlocked(ach) -> void:
	var all = ach.get_todos()
	var ceros := 0
	for l in all:
		if not ach.is_unlocked(l.id):
			ceros += 1
	_verificar(ceros == all.size(), "is_unlocked: %d/%d logros no-desbloqueados al iniciar" % [ceros, all.size()])
	_vistos["is_unlocked"] = true

func _test_get_definicion(ach) -> void:
	# El id real del catálogo es `logro_primer_sello` (el viejo `primer_sello`
	# no existe: get_definicion devolvia {} y `d.id` abortaba la funcion).
	var d = ach.get_definicion("logro_primer_sello")
	_verificar(not d.is_empty(), "get_definicion: existe logro_primer_sello (dict no vacio)")
	_verificar(String(d.get("id", "")) == "logro_primer_sello", "get_definicion: id correcto (%s)" % str(d.get("id", "")))
	# Contrato REAL medido: id inexistente -> Dictionary VACIO (no null).
	var no = ach.get_definicion("no_existe_xyz")
	_verificar(no is Dictionary and (no as Dictionary).is_empty(), "get_definicion: id inexistente -> dict vacio (contrato)")
	_vistos["definicion"] = true

func _test_get_todos(ach) -> void:
	var todos = ach.get_todos()
	_verificar(todos.size() >= 10, "get_todos: >= 10 logros (got %d)" % todos.size())
	var i := 1
	while i < todos.size():
		_verificar(todos[i - 1].orden <= todos[i].orden, "get_todos: ordenado por orden (par %d)" % i)
		i += 1
	_vistos["todos"] = true

func _test_get_estado(ach) -> void:
	var st = ach.get_estado("logro_primer_sello")
	_verificar(st is Dictionary, "get_estado: devuelve Dictionary")
	_verificar(st.has("desbloqueado"), "get_estado: incluye 'desbloqueado'")
	_verificar(st.get("desbloqueado") == false, "get_estado: logro_primer_sello no desbloqueado al iniciar")
	_verificar(String(st.get("id", "")) == "logro_primer_sello", "get_estado: id correcto (%s)" % str(st.get("id", "")))
	_vistos["estado"] = true

func _verificar(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		_ok += 1
		print("  [OK] " + msg)
	else:
		_ko += 1
		push_warning("  [FALLO] " + msg)

func _reportar() -> void:
	var faltan: Array = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltan.append(b)
	if not faltan.is_empty():
		_ko += 1
		print("[FAIL] bloques que NO se ejecutaron (posible SCRIPT ERROR): %s" % str(faltan))
	if _checks < CHECKS_MINIMOS:
		_ko += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("[M72-RF10] OK=%d FALLOS=%d (checks=%d)" % [_ok, _ko, _checks])
	if _ko > 0:
		print("[M72-RF10] HAY FALLOS")
		quit(1)
	else:
		print("[M72-RF10] TODO OK")
		quit(0)
