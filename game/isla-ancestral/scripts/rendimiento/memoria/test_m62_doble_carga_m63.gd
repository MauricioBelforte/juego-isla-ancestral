# Modelo: DeepSeek-V4.1-Flash
# Plataforma: OpenCode
# Fecha: 2026-10-20
#
# M62: Memoria - suite de la frontera ResourceCache + cola M63.
# Cierra por MEDICION el item L163:
#   "Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueno)".
#
# Contrato que pina (headless, autoloads REALES StreamManager + MemoryMonitor):
#   A. La cola arranca drenada (precondicion).
#   B. La primera carga threaded abre UNA ruta en vuelo y UNA operacion.
#   C. La segunda llamada a `encolar()` con la MISMA ruta es RECHAZADA:
#      no hay segunda operacion, no hay segunda ruta y `_encolar_precarga()`
#      tampoco la duplica.
#   D. Al completarse hay UN solo callback, la ruta se cierra y el ResourceLoader
#      entrega la MISMA instancia (cache de Godot); el detector de duplicados
#      de LeakGuard ve 0 duplicados, con control positivo CACHE_MODE_IGNORE.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_doble_carga_m63.gd

extends SceneTree

const FIXTURE := "res://scripts/rendimiento/memoria/test_fixture_mesh_malla_region.tres"
const BLOQUES: Array[String] = ["A", "B", "C", "D"]
const CHECKS_MINIMOS := 18

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _cola_base: int = -1
var _entregado: Array = [null]
var _completadas: Array[String] = []


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Frontera ResourceCache + cola M63 (L163) ===")
	var sm := _sm()
	var mm := _mm()
	_check("StreamManager autoload presente", sm != null)
	_check("MemoryMonitor autoload presente", mm != null)
	if sm == null or mm == null:
		return
	var fy := func(op_id: String, _tipo: String) -> void:
		_completadas.append(op_id)
	sm.operacion_completada.connect(fy)
	_bloque_a(sm)
	_bloque_b(sm)
	_bloque_c(sm)
	_bloque_d(sm, mm)
	sm.operacion_completada.disconnect(fy)


func _bloque_a(sm: Node) -> void:
	print("--- A. Precondicion: cola y rutas drenadas ---")
	sm.reanudar_cargas()
	for _i in 180:
		sm._process(0.016)
		if sm.cola_size() == 0 and sm.rutas_en_carga() == 0:
			break
	_check("cola 0 y rutas_en_carga 0 antes de la prueba",
		sm.cola_size() == 0 and sm.rutas_en_carga() == 0,
		"cola=%d rutas=%d" % [sm.cola_size(), sm.rutas_en_carga()])
	_fin("A")


func _bloque_b(sm: Node) -> void:
	print("--- B. Primera carga threaded: una sola ruta y una sola operacion ---")
	sm.pausar_cargas()
	_cola_base = sm.cola_size()
	var cb := func(rec: Resource) -> void:
		_entregado[0] = rec
	var ok: bool = sm.encolar("doble_1", "malla_region", 3, cb, FIXTURE)
	_check("la primera carga se acepta", ok, "ok=%s" % str(ok))
	_check("la ruta queda EN VUELO", sm.esta_cargando_ruta(FIXTURE),
		"en_vuelo=%s" % str(sm.esta_cargando_ruta(FIXTURE)))
	_check("la cola crece exactamente 1", sm.cola_size() == _cola_base + 1,
		"cola=%d base=%d" % [sm.cola_size(), _cola_base])
	_check("hay UNA sola ruta en vuelo", sm.rutas_en_carga() == 1,
		"rutas=%d" % sm.rutas_en_carga())
	_fin("B")


func _bloque_c(sm: Node) -> void:
	print("--- C. Segunda llamada con la MISMA ruta: rechazo sin doble carga ---")
	var ok2: bool = sm.encolar("doble_2", "malla_region", 3,
		func(_rec: Resource) -> void: pass, FIXTURE)
	_check("la segunda carga de la misma ruta es RECHAZADA", ok2 == false,
		"ok2=%s" % str(ok2))
	_check("la cola NO crece con la segunda llamada", sm.cola_size() == _cola_base + 1,
		"cola=%d base=%d" % [sm.cola_size(), _cola_base])
	_check("sigue habiendo UNA sola ruta en vuelo", sm.rutas_en_carga() == 1,
		"rutas=%d" % sm.rutas_en_carga())
	var pre: int = sm._encolar_precarga(FIXTURE, "malla_region", 3)
	_check("_encolar_precarga tambien rechaza la ruta en vuelo", pre == 0,
		"pre=%d" % pre)
	_check("la cola sigue en base+1 tras la precarga", sm.cola_size() == _cola_base + 1,
		"cola=%d base=%d" % [sm.cola_size(), _cola_base])
	_fin("C")


func _bloque_d(sm: Node, mm: Node) -> void:
	print("--- D. Entrega unica, cache de Godot y detector de duplicados ---")
	sm.reanudar_cargas()
	for _i in 180:
		sm._process(0.016)
		if _entregado[0] != null and not sm.esta_cargando_ruta(FIXTURE):
			break
	_check("el callback recibio el Resource", _entregado[0] is Resource,
		"tipo=%s" % str(typeof(_entregado[0])))
	_check("se completo UNA sola operacion (doble_1; doble_2 no existe)",
		_completadas.count("doble_1") == 1 and _completadas.count("doble_2") == 0,
		"completadas=%s" % str(_completadas))
	_check("la ruta quedo cerrada (sin residuo del anti-doble)",
		not sm.esta_cargando_ruta(FIXTURE) and sm.rutas_en_carga() == 0,
		"en_vuelo=%s rutas=%d" % [str(sm.esta_cargando_ruta(FIXTURE)), sm.rutas_en_carga()])
	_check("la cola vuelve a la base", sm.cola_size() == _cola_base,
		"cola=%d base=%d" % [sm.cola_size(), _cola_base])
	_check("M62 no retiene la carga al terminar", mm.recursos_en_carga() == 0,
		"mm=%d" % mm.recursos_en_carga())
	var rec: Resource = _entregado[0] as Resource
	var rec_cache: Resource = ResourceLoader.load(FIXTURE)
	_check("ResourceLoader entrega la MISMA instancia (cache)",
		rec != null and rec_cache != null
			and rec.get_instance_id() == rec_cache.get_instance_id(),
		"rec=%d cache=%d" % [
			rec.get_instance_id() if rec != null else -1,
			rec_cache.get_instance_id() if rec_cache != null else -1])
	var dups: Array = LeakGuard.recursos_duplicados([rec, rec_cache])
	_check("LeakGuard no ve duplicados de la misma instancia", dups.is_empty(),
		str(dups))
	var copia: Resource = ResourceLoader.load(FIXTURE, "", ResourceLoader.CACHE_MODE_IGNORE)
	var dups2: Array = LeakGuard.recursos_duplicados([rec, copia])
	_check("control positivo: CACHE_MODE_IGNORE SI es detectado",
		dups2.size() == 1, str(dups2))
	copia = null
	_fin("D")


func _sm() -> Node:
	return root.get_node_or_null("StreamManager")


func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALL] %s %s" % [nombre, detalle])


func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FALL] el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FALL] solo %d checks ejecutados (minimo: %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M62 doble carga: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M62 doble carga FALLIDO - salida con codigo 1")
		quit(1)
	else:
		print("TEST M62 doble carga OK - los %d checks pasaron" % _checks)
		quit(0)
