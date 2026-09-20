# Modelo: glm-5.3-flash (iter. 2) · DeepSeek-V4.1-Flash (iter. 3, Log 1094)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-03 · 2026-09-19
#
# M62: Test GlobalPool (auditoría de señales al devolver, fallback honesto
# queue_free, drenar_familia, estados activo/estacionado).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/rendimiento/memoria/test_pool_iter2.gd
#
# ── ENDURECIDO EN Log 1094 (DeepSeek-V4.1-Flash) ───────────────────────────
# La suite PASABA, pero tenía dos agujeros que la hacían incapaz de fallar:
#   · `_check(a.is_processing() == true or true, …)` → el `or true` la vuelve
#     infalsificable.
#   · `_check(conns_antes >= 0, …)` → `.size()` nunca es negativo: tautología.
#   · No contaba checks ni tenía piso, así que un `SCRIPT ERROR` que abortara
#     una función daría "0 fallo(s)" igual (falso verde por omisión).
#   · `receptor.free()` liberaba un nodo que seguía DENTRO del pool.
# Ahora las aserciones pueden fallar de verdad, hay guardián de 3 capas, y el
# nodo devuelto lo libera el pool (no el test).

extends SceneTree

const MODULO := "M62-pool-iter2"
const BLOQUES: Array[String] = ["A", "B", "C", "D"]
## Piso MEDIDO en verde, NO copiado. Valor = salida real de la corrida
##   godot --headless --path game/isla-ancestral --script res://scripts/rendimiento/memoria/test_pool_iter2.gd
## el 2026-09-19 (Log 1094): "=== Resumen M62-pool-iter2: 25 checks, 0 fallos ===".
const CHECKS_MINIMOS := 25

const _SC_POOL := preload("res://scripts/rendimiento/memoria/global_pool.gd")

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	print("=== [M62] Test GlobalPool iter. 2 (endurecido, Log 1094) ===")
	var pool = _SC_POOL.new()
	_check("GlobalPool instancia", pool != null)
	if pool == null:
		_fin("A")
		_fin("B")
		_fin("C")
		_fin("D")
		return
	_bloque_a_api_unica(pool)
	_bloque_b_auditoria_senales(pool)
	_bloque_c_fallback_honesto(pool)
	_bloque_d_drenar(pool)

## ── A. API única: obtener / devolver / precalentar / límite / tamaño ──────
func _bloque_a_api_unica(pool: RefCounted) -> void:
	print("--- A. GlobalPool: API única ---")
	pool.set_limite("test_api", 3)
	_check("límite configurable", int(pool.limite("test_api")) == 3,
		"limite=%d" % int(pool.limite("test_api")))
	var creados: int = pool.precalentar("test_api", 2, func():
		var n := Node.new()
		n.name = "precalentado"
		return n)
	_check("precalentar devuelve cuántos creó (2)", creados == 2, "creados=%d" % creados)
	_check("tamaño del pool = 2", int(pool.tamanio("test_api")) == 2,
		"n=%d" % int(pool.tamanio("test_api")))
	var a: Node = pool.obtener("test_api")
	_check("obtener devuelve nodo", a != null)
	# Al salir del pool queda ACTIVO: `obtener()` hace set_process(true).
	_check("obtener activa el nodo", a != null and a.is_processing(),
		"processing=%s" % ("n/a" if a == null else str(a.is_processing())))
	_check("el pool bajó a 1", int(pool.tamanio("test_api")) == 1,
		"n=%d" % int(pool.tamanio("test_api")))
	_check("devolver() acepta el nodo", pool.devolver("test_api", a))
	_check("devolver re-estaciona (vuelve a 2)", int(pool.tamanio("test_api")) == 2,
		"n=%d" % int(pool.tamanio("test_api")))
	_check("devolver detiene el process", not a.is_processing())
	_check("el ítem estacionado cumple el contrato de limpieza", pool.esta_limpio(a))
	_check("familia inexistente -> tamaño 0", int(pool.tamanio("inexistente")) == 0,
		"n=%d" % int(pool.tamanio("inexistente")))
	_fin("A")

## ── B. Auditoría de señales: desconexión ENTRANTE al estacionar ───────────
func _bloque_b_auditoria_senales(pool: RefCounted) -> void:
	print("--- B. Auditoría de señales al devolver ---")
	var emisor := Node.new()
	var receptor := Node.new()
	root.add_child(emisor)
	root.add_child(receptor)
	emisor.add_user_signal("ping")
	# Conexión ENTRANTE al receptor: señal de otro nodo -> método del receptor.
	emisor.connect("ping", Callable(receptor, "queue_free").bind())
	_check("el receptor tiene 1 conexión entrante antes",
		receptor.get_incoming_connections().size() == 1,
		"conns=%d" % receptor.get_incoming_connections().size())
	_check("el emisor no tiene conexiones entrantes",
		emisor.get_incoming_connections().size() == 0,
		"conns=%d" % emisor.get_incoming_connections().size())
	var ok: bool = pool.devolver("test_senales", receptor)
	_check("devolver con señales devuelve true", ok)
	var conns: int = receptor.get_incoming_connections().size()
	_check("la auditoría desconectó las entrantes del receptor", conns == 0,
		"conns=%d" % conns)
	# El receptor NO se libera aquí: es del pool. Lo libera `drenar_familia`.
	emisor.queue_free()
	_fin("B")

## ── C. Fallback honesto: pool lleno -> queue_free, sin crecer sin tope ────
func _bloque_c_fallback_honesto(pool: RefCounted) -> void:
	print("--- C. Fallback honesto (pool lleno) ---")
	pool.set_limite("test_lleno", 1)
	var n1 := Node.new()
	var n2 := Node.new()
	root.add_child(n1)
	root.add_child(n2)
	_check("el primer devolver entra al pool", pool.devolver("test_lleno", n1))
	_check("el segundo devolver es rechazado", not pool.devolver("test_lleno", n2))
	_check("el pool NO crece más allá del límite", int(pool.tamanio("test_lleno")) == 1,
		"n=%d" % int(pool.tamanio("test_lleno")))
	_check("el rechazado quedó encolado para liberar", n2.is_queued_for_deletion(),
		"queued=%s" % str(n2.is_queued_for_deletion()))
	_fin("C")

## ── D. drenar_familia / liberar_todo liberan de verdad ───────────────────
func _bloque_d_drenar(pool: RefCounted) -> void:
	print("--- D. drenar_familia y liberar_todo ---")
	pool.precalentar("drenar_a", 2, func(): return Node.new())
	pool.precalentar("drenar_b", 3, func(): return Node.new())
	var liberados: int = pool.drenar_familia("drenar_a")
	_check("drenar_familia libera 2", liberados == 2, "liberados=%d" % liberados)
	_check("la familia drenada queda vacía", int(pool.tamanio("drenar_a")) == 0,
		"n=%d" % int(pool.tamanio("drenar_a")))
	_check("la otra familia queda intacta", int(pool.tamanio("drenar_b")) == 3,
		"n=%d" % int(pool.tamanio("drenar_b")))
	var total: int = pool.liberar_todo()
	_check("liberar_todo libera el resto (>=3)", total >= 3, "total=%d" % total)
	_check("todas las familias quedan vacías", int(pool.tamanio("drenar_b")) == 0,
		"n=%d" % int(pool.tamanio("drenar_b")))
	_fin("D")

## ── Utilidades ────────────────────────────────────────────────────────────
func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## Capa 3: corre SIEMPRE, aunque `_run()` haya abortado por un SCRIPT ERROR.
func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecutó (posible SCRIPT ERROR que abortó la función)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (mínimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
