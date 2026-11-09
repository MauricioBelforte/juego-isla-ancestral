# Modelo: DeepSeek-V4.1-Flash (OpenCode)
# Plataforma: OpenCode
# Fecha: 2026-11-08
#
# Critical de la evaluación Nemotron (Crouton Alpha / Glyph Cluster) — M52:
#   "VfxDirector sin `_process`/`_exit_tree`; conexión a `evento_generico`,
#    una señal inexistente → el director queda MUDO."
#
# Esta suite prueba la corrección de punta a punta contra el EventBus REAL:
#   A. los 13 buses namespaced del catálogo conectan y NINGUNO falta;
#   B. el director corre `_process` (ciclo de vida de emisores);
#   C. un evento real dispara el VFX correcto y EN LA POSICIÓN del evento;
#   D. un bus sin VFX no dispara nada;
#   E. `_exit_tree()` libera el pool (sin nodos huérfanos).
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/integration/test_vfx_director_vida_m52.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
const CHECKS_MINIMOS := 16

const DIRECTOR := preload("res://scripts/particles/vfx_director.gd")

var _checks: int = 0
var _fallos: int = 0
var _bloque: String = "(inicio)"
var _detalles: Array[String] = []
var _d = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== VfxDirector: bus real + ciclo de vida (critico M52) ===")
	var bus := root.get_node_or_null("EventBus")
	_check("A0 /root/EventBus existe", bus != null)
	if bus == null:
		_summary()
		return
	_check("A1 el EventBus NO tiene la señal plana evento_generico (causa raiz)",
		not bus.has_signal("evento_generico"))

	_d = DIRECTOR.new()
	root.add_child(_d)
	await process_frame

	_bloque = "A. registro y conexion"
	_check("A2 30 eventos unicos del catalogo", _d.eventos_registrados() == 30,
		str(_d.eventos_registrados()))
	_check("A3 13 buses conectados al EventBus real", _d.buses_conectados() == 13,
		str(_d.buses_conectados()))
	_check("A4 ningun bus del catalogo falta", (_d.buses_faltantes() as Array).is_empty(),
		str(_d.buses_faltantes()))

	_bloque = "B. ciclo de vida"
	_check("B1 el director procesa cada frame (_process)", _d.is_processing() == true)

	_bloque = "C. evento real dispara VFX en su posicion"
	var d0: int = _d.disparos()
	bus.world.block_removed.emit(Vector3i(4, 5, 6), 3)
	_check("C1 world.block_removed dispara un VFX", _d.disparos() == d0 + 1,
		"%d -> %d" % [d0, _d.disparos()])
	_check("C2 el VFX es el del catalogo (bloque_roto)", _d.ultimo_disparo() == "bloque_roto",
		_d.ultimo_disparo())
	_check("C3 la posicion sale del Vector3i del evento",
		_d.ultima_posicion() == Vector3(4, 5, 6), str(_d.ultima_posicion()))

	var d1: int = _d.disparos()
	bus.world.block_placed.emit(Vector3i(1, 2, 3), 7)
	_check("C4 world.block_placed dispara bloque_colocado",
		_d.disparos() == d1 + 1 and _d.ultimo_disparo() == "bloque_colocado",
		_d.ultimo_disparo())
	_check("C5 posicion del segundo evento", _d.ultima_posicion() == Vector3(1, 2, 3),
		str(_d.ultima_posicion()))

	_bloque = "D. bus sin VFX"
	var d2: int = _d.disparos()
	bus.quest.quest_started.emit("mision_sin_vfx")
	_check("D1 quest_started no tiene VFX y no dispara", _d.disparos() == d2,
		"%d -> %d" % [d2, _d.disparos()])

	_bloque = "E. teardown"
	var nodos_antes: int = _d.get_pool().nodos().size()
	_d._exit_tree()
	_check("E1 _exit_tree() vacia el pool", _d.get_pool().nodos().is_empty(),
		"antes=%d" % nodos_antes)
	_d._exit_tree()
	_check("E2 _exit_tree() es idempotente", _d.get_pool().nodos().is_empty())

	_bloque = "F. dispatch directo sigue vivo (compatibilidad)"
	_check("F1 disparo directo por nombre de evento", _d.disparar("bloque_roto", Vector3.ZERO) == true)
	_check("F2 evento inexistente devuelve false", _d.disparar("no_existe_vfx", Vector3.ZERO) == false)
	_summary()


func _on_watchdog() -> void:
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if ok:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _summary() -> void:
	print("=== Resumen VfxDirector vida M52: %d checks, %d fallos (minimo %d) ===" % [
		_checks, _fallos, CHECKS_MINIMOS])
	if _fallos > 0:
		print("FALLOS:")
		for d in _detalles:
			print("  - " + d)
	if _checks < CHECKS_MINIMOS:
		print("INVALIDO: %d checks, minimo %d" % [_checks, CHECKS_MINIMOS])
		quit(2)
		return
	if _fallos > 0:
		print("TEST VfxDirector vida FALLIDO")
		quit(1)
		return
	print("TEST VfxDirector vida OK — el director responde a eventos reales y limpia su pool")
	quit(0)
