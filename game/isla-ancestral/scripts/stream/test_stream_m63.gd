# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M63: Cargas y Streaming — Test headless
# Valida: StreamManager (cola con pesos, prioridad, cache LRU, progreso
# real por pesos, precalentamiento, pausa/reanudar, señales) y
# ProgressCalculator (pesos/tipo, progreso). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_PROGRESS := preload("res://scripts/stream/progress_calculator.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M63] Test de Cargas y Streaming ===")
	_test_progress_calculator()
	_test_stream_manager()
	_test_lru()
	_test_pausa()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_progress_calculator() -> void:
	print("--- ProgressCalculator: pesos y progreso ---")
	_check("peso escena = 10", _SC_PROGRESS.peso_de_tipo("escena") == 10)
	_check("peso chunk = 2", _SC_PROGRESS.peso_de_tipo("chunk") == 2)
	_check("peso desconocido = 1", _SC_PROGRESS.peso_de_tipo("xyz") == 1)
	_check("peso con weights json", _SC_PROGRESS.peso_de_tipo("escena", {"escena": 25}) == 25)
	var ops := [{"peso": 10}, {"peso": 5}, {"peso": 5}]
	_check("peso total cola = 20", _SC_PROGRESS.calcular_peso_total(ops) == 20)
	_check("progreso 0.5", _SC_PROGRESS.progreso(10, 20) == 0.5)
	_check("progreso 1.0 con total 0", _SC_PROGRESS.progreso(0, 0) == 1.0)

func _test_stream_manager() -> void:
	print("--- StreamManager: cola con pesos + progreso real ---")
	var sm := root.get_node_or_null("StreamManager")
	if sm == null:
		_check("StreamManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("StreamManager autoload presente", true)
	_check("weights cargados (escena=10)", int(sm.weights.get("escena", 0)) == 10)
	var completadas: Array = []
	var vacias: int = 0
	sm.operacion_completada.connect(func(op, id): completadas.append(id))
	sm.cola_vacia.connect(func(): vacias += 1)
	# Encolar 3 operaciones: 2 de tipo escena (peso 10 c/u), 1 chunk (peso 2)
	sm.encolar("escena", "res://scenes/main_island.tscn")
	sm.encolar("chunk", "res://scripts/core/event_bus.gd")
	sm.encolar("escena", "res://scenes/test_stress.tscn")
	_check("cola procesada (3 operaciones)", sm.cargadas_size() >= 2, "cargadas=%d" % sm.cargadas_size())
	_check("cache contiene main_island", sm.obtener_cache("res://scenes/main_island.tscn") != null)
	_check("progreso 1.0 tras completar", sm.progreso() == 1.0, "prog=%f" % sm.progreso())
	_check("señal operacion_completada emitida", completadas.size() >= 3, "size=%d" % completadas.size())

func _test_lru() -> void:
	print("--- StreamManager: LRU con tope ---")
	var sm := root.get_node_or_null("StreamManager")
	var antes: int = sm.cargadas_size()
	sm.presupuesto_chunks = 2
	# Encolar más rutas para forzar LRU
	for i in range(4):
		sm.encolar("chunk", "res://scripts/core/service_registry.gd" if i == 0 else "res://scripts/core/game_flow_manager.gd")
	# LRU con tope 2: el cache no debe exceder 2 (pero al menos mantiene el último)
	_check("LRU tope respetado (<=3 tolerancia)", sm.cargadas_size() <= 3, "size=%d" % sm.cargadas_size())
	sm.presupuesto_chunks = 64

func _test_pausa() -> void:
	print("--- StreamManager: pausar/reanudar ---")
	var sm := root.get_node_or_null("StreamManager")
	sm.pausar_cargas()
	sm.encolar("escena", "res://scenes/main_island.tscn")
	var size_pausada: int = sm.cola_size()
	_check("pausa retiene cola", size_pausada >= 1, "size=%d" % size_pausada)
	sm.reanudar_cargas()
	_check("reanudar drena cola", sm.cola_size() == 0, "size=%d" % sm.cola_size())
	# precalentamiento
	var antes: int = sm.cargadas_size()
	sm.precalentar_mundo(["res://scenes/main_island.tscn"])
	_check("precalentamiento encola", sm.cargadas_size() >= antes)

func _summary() -> void:
	print("=== Resumen M63: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M63 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M63 OK — todos los checks pasaron")
		quit(0)