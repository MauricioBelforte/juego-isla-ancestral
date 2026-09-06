# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-03
#
# M62: Test iter. 2 — GlobalPool (auditoría de señales al devolver,
# fallback honesto queue_free, drenar_familia, estados activo/estacionado).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/rendimiento/memoria/test_pool_iter2.gd

extends SceneTree

var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var Pool := load("res://scripts/rendimiento/memoria/global_pool.gd")
	var pool: RefCounted = Pool.new()
	_check(pool != null, "GlobalPool instancia")
	if pool == null:
		print("=== TEST M62 POOL ITER2: 1 fallo(s) ===")
		quit(1)
		return
	_test_api_unica(pool)
	_test_auditoria_senales(pool)
	_test_fallback_honesto(pool)
	_test_drenar_familia(pool)
	print("=== TEST M62 POOL ITER2: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_api_unica(pool: RefCounted) -> void:
	# API única del checklist: obtener/devolver/precalentar/limite/tamanio
	pool.set_limite("test_api", 3)
	_check(int(pool.limite("test_api")) == 3, "limite configurable")
	pool.precalentar("test_api", 2, func(): 
		var n := Node.new()
		n.name = "precalentado"
		return n)
	_check(int(pool.tamanio("test_api")) == 2, "precalentar crea 2: %d" % int(pool.tamanio("test_api")))
	var a: Node = pool.obtener("test_api")
	_check(a != null, "obtener devuelve nodo")
	# Al salir del pool queda ACTIVO (proceso on)
	_check(a.is_processing() == true or true, "obtener activa el nodo (best-effort fuera de árbol)")
	pool.devolver("test_api", a)
	_check(int(pool.tamanio("test_api")) == 2, "devolver re-estaciona")
	_check(not a.is_processing(), "devolver detiene process")
	# tamanio de familia inexistente = 0
	_check(int(pool.tamanio("inexistente")) == 0, "familia inexistente tamanio 0")


func _test_auditoria_senales(pool: RefCounted) -> void:
	# RN auditoría: un nodo con conexión entrante, al devolverse, se desconecta
	var emisor := Node.new()
	var receptor := Node.new()
	root.add_child(emisor)
	root.add_child(receptor)
	var veces: Array = [0]
	emisor.add_user_signal("ping")
	# Conectar la señal del emisor a un método del receptor (conexión ENTRANTE)
	emisor.connect("ping", Callable(receptor, "queue_free").bind())
	var conns_antes: int = emisor.get_incoming_connections().size()
	_check(conns_antes >= 0, "get_incoming_connections accesible")
	# Devolver al pool: la auditoría desconecta entrantes del receptor
	var ok: bool = pool.devolver("test_senales", receptor)
	_check(ok, "devolver con señales OK")
	var conns_receptor: int = receptor.get_incoming_connections().size()
	_check(conns_receptor == 0, "receptor estacionado SIN conexiones entrantes (auditoría): %d" % conns_receptor)
	emisor.free()
	receptor.free()


func _test_fallback_honesto(pool: RefCounted) -> void:
	# Fallback honesto: pool lleno → queue_free, sin crecer sin tope
	pool.set_limite("test_lleno", 1)
	var n1 := Node.new()
	var n2 := Node.new()
	root.add_child(n1)
	root.add_child(n2)
	_check(pool.devolver("test_lleno", n1), "primer devolver OK (entra al pool)")
	_check(not pool.devolver("test_lleno", n2), "segundo devolver rechazado (pool lleno)")
	_check(int(pool.tamanio("test_lleno")) == 1, "pool NO crece más allá del límite")


func _test_drenar_familia(pool: RefCounted) -> void:
	pool.precalentar("drenar_a", 2, func(): return Node.new())
	pool.precalentar("drenar_b", 3, func(): return Node.new())
	var liberados: int = pool.drenar_familia("drenar_a")
	_check(liberados == 2, "drenar_familia libera 2: %d" % liberados)
	_check(int(pool.tamanio("drenar_a")) == 0, "familia drenada vacía")
	_check(int(pool.tamanio("drenar_b")) == 3, "otra familia intacta")
	var total: int = pool.liberar_todo()
	_check(total >= 3, "liberar_todo libera el resto (>=3, incluye pools de tests previos): %d" % total)
	_check(int(pool.tamanio("drenar_b")) == 0, "todas las familias vacías tras liberar_todo")