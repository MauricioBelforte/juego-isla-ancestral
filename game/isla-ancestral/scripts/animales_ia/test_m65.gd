# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M65: Test del modulo Animales-IA.
# Cubre: registro de individuos (via M36 fauna_behavior._ready), presupuesto
# maximo, tick de movimiento (avanzar hacia destino, velocidad, distancia),
# senal solicitar_movimiento de M36 conectada a M65, persistencia de
# presupuesto M59, anti-stuck (abortar si no llega tras 30m).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/animales_ia/test_m65.gd

extends SceneTree

const BehaviorRef = preload("res://scripts/fauna/fauna_behavior.gd")
const SpeciesRef = preload("res://scripts/fauna/fauna_species.gd")

var _fallos: int = 0
var _mgr: Node = null
var _fauna_mgr: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_mgr = root.get_node_or_null("animal_ai")
	_fauna_mgr = root.get_node_or_null("fauna")
	_check(_mgr != null, "animal_ai autoload presente (M65)")
	_check(_fauna_mgr != null, "fauna autoload presente (M36)")
	if _mgr == null:
		print("=== TEST M65 ANIMALES-IA: %d fallo(s) ===" % _fallos)
		quit(1 if _fallos > 0 else 0)
		return
	_test_presupuesto_inicial()
	_test_registro_via_fauna_behavior()
	_test_presupuesto_max()
	_test_tick_movimiento_simple()
	_test_tick_anti_stuck()
	_test_tick_llegada_destino()
	_test_senal_solicitar_movimiento()
	_test_persistencia_presupuesto()
	_test_desregistro()
	print("=== TEST M65 ANIMALES-IA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

## ── Helpers ────────────────────────────────────────────────

func _crear_animal(id_str: String, pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.set_script(load("res://scripts/fauna/fauna_behavior.gd"))
	n.name = id_str
	n.instancia_id = id_str
	# Asignar especie conejo (pradera)
	n.especie = _fauna_mgr.obtener_especie(&"conejo_pradera")
	root.add_child(n)
	n.global_position = pos
	return n

func _limpiar_animales() -> void:
	# Borrar todos los Node3D del root que tengan script fauna_behavior
	for child in root.get_children():
		if child is Node3D and child.get_script() != null:
			var path = child.get_script().resource_path
			if path.ends_with("/fauna/fauna_behavior.gd"):
				child.queue_free()
	# Reset interno del manager
	_mgr._individuos.clear()
	_mgr._presupuesto_actual = 0

## ── Tests ────────────────────────────────────────────────────

func _test_presupuesto_inicial() -> void:
	_check(_mgr.presupuesto_max() == 40, "presupuesto max inicial = 40 (got %d)" % _mgr.presupuesto_max())
	_check(_mgr.presupuesto_actual() == 0, "presupuesto actual = 0 (got %d)" % _mgr.presupuesto_actual())
	_mgr.set_presupuesto_max(20)
	_check(_mgr.presupuesto_max() == 20, "set_presupuesto_max(20) aplica")
	_mgr.set_presupuesto_max(40)  # reset

func _test_registro_via_fauna_behavior() -> void:
	_limpiar_animales()
	var conejo = _crear_animal("conejo_001", Vector3(0, 0, 0))
	_check(_mgr.presupuesto_actual() == 1, "presupuesto tras 1 registro = 1 (got %d)" % _mgr.presupuesto_actual())
	_check(_mgr._individuos.has("conejo_001"), "conejo_001 en _individuos")
	# Re-registrar mismo: no duplica
	_mgr.registrar(conejo)
	_check(_mgr.presupuesto_actual() == 1, "re-registro no duplica: 1")
	conejo.queue_free()

func _test_presupuesto_max() -> void:
	_limpiar_animales()
	_mgr.set_presupuesto_max(3)
	for i in range(5):
		var a = _crear_animal("animal_%d" % i, Vector3(i, 0, 0))
	_check(_mgr.presupuesto_actual() <= 3, "presupuesto no excede 3 (got %d)" % _mgr.presupuesto_actual())
	# Limpiar los 3 que se aceptaron + resetear
	_limpiar_animales()
	_mgr.set_presupuesto_max(40)

func _test_tick_movimiento_simple() -> void:
	_limpiar_animales()
	var conejo = _crear_animal("conejo_tick", Vector3.ZERO)
	# Forzar solicitud de movimiento (la senal se conecta sola al registrar)
	conejo.solicitar_movimiento.emit(Vector3(10, 0, 0), 2.0)
	# Procesar 1 segundo a 2.0 m/s -> debe estar en x=2
	_mgr.tick(1.0)
	var pos: Vector3 = conejo.global_position
	_check(absf(pos.x - 2.0) < 0.01, "tras tick(1.0) a v=2.0: x=2.0 (got %.3f)" % pos.x)
	conejo.queue_free()

func _test_tick_anti_stuck() -> void:
	_limpiar_animales()
	var conejo = _crear_animal("conejo_stuck", Vector3.ZERO)
	# Destino lejano, velocidad baja: tras varios ticks sin llegar, debe abortar
	conejo.solicitar_movimiento.emit(Vector3(1000, 0, 0), 0.1)
	# Tick 5s con v=0.1 -> distancia acumulada = 0.5m, NO deberia abortar
	for i in range(5):
		_mgr.tick(1.0)
	# distancia_acumulada = 0.5 (no llega), pero < 30m, sigue en movimiento
	_check(_mgr._individuos["conejo_stuck"].en_movimiento, "tras 5s con v=0.1, sigue en movimiento")
	# Forzar manualmente distancia_acumulada = 35 para simular loop largo
	_mgr._individuos["conejo_stuck"].distancia_acumulada = 35.0
	_mgr.tick(0.1)
	_check(not _mgr._individuos["conejo_stuck"].en_movimiento, "anti-stuck: tras 35m acumulados, aborta")
	conejo.queue_free()

func _test_tick_llegada_destino() -> void:
	_limpiar_animales()
	var conejo = _crear_animal("conejo_llega", Vector3.ZERO)
	# Destino a 0.5m de la posicion inicial
	conejo.solicitar_movimiento.emit(Vector3(0.5, 0, 0), 1.0)
	_mgr.tick(1.0)  # velocidad 1.0, step = 1.0 > 0.5, llega
	var pos: Vector3 = conejo.global_position
	_check(pos.x >= 0.4 and pos.x <= 0.6, "llego al destino: x=%.3f (esperado 0.5)" % pos.x)
	_check(not _mgr._individuos["conejo_llega"].en_movimiento, "en_movimiento=false al llegar")
	conejo.queue_free()

func _test_senal_solicitar_movimiento() -> void:
	_limpiar_animales()
	var conejo = _crear_animal("conejo_senal", Vector3(0, 0, 0))
	# Emitir la senal manualmente (asi testeamos la conexion)
	conejo.solicitar_movimiento.emit(Vector3(5, 0, 0), 3.0)
	# Verificar que M65 recibio la senal
	_check(_mgr._individuos["conejo_senal"].destino == Vector3(5, 0, 0), "destino actualizado por senal")
	_check(_mgr._individuos["conejo_senal"].velocidad == 3.0, "velocidad actualizada por senal")
	_check(_mgr._individuos["conejo_senal"].en_movimiento, "en_movimiento=true tras senal")
	conejo.queue_free()

func _test_persistencia_presupuesto() -> void:
	_mgr.set_presupuesto_max(15)
	var data: Dictionary = _mgr.get_save_data()
	_check(int(data.get("version", 0)) >= 1, "version >= 1")
	_check(int(data.get("presupuesto_max", 0)) == 15, "presupuesto_max=15 en save data")
	_mgr.set_presupuesto_max(40)
	_mgr.restore_save_data(data)
	_check(_mgr.presupuesto_max() == 15, "restore aplica presupuesto_max=15")
	_mgr.restore_save_data({"version": 0, "presupuesto_max": 100})
	_check(_mgr.presupuesto_max() == 15, "version 0 ignorada (sigue en 15)")
	_mgr.set_presupuesto_max(40)

func _test_desregistro() -> void:
	_limpiar_animales()
	var conejo = _crear_animal("conejo_des", Vector3(0, 0, 0))
	_check(_mgr.presupuesto_actual() == 1, "1 registrado")
	conejo.queue_free()
	# Forzar un tick para que el _exit_tree se ejecute
	await process_frame
	_mgr.tick(0.016)
	_check(_mgr.presupuesto_actual() == 0, "tras _exit_tree: presupuesto_actual=0 (got %d)" % _mgr.presupuesto_actual())
	_check(not _mgr._individuos.has("conejo_des"), "conejo_des removido de _individuos")
