# Modelo: glm-5.3-flash (iter. 3) · DeepSeek-V4.1-Flash (iter. 5)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-04 · 2026-10-02
#
# M63: Test iter. 3 — RF2 cargas asíncronas con load_threaded_request real.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/stream/test_rf2_threaded.gd
#
# iter. 5 (Log 1192): se le añade guardian de 3 capas (bloque `_fin()`, piso
# CHECKS_MINIMOS MEDIDO y `_summary()` en su propio call_deferred).

extends SceneTree

## Piso MEDIDO en verde (Log 1192), NO copiado.
const CHECKS_MINIMOS := 7
const BLOQUES: Array[String] = ["autoload", "threaded", "fallback", "sin_ruta"]

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	var sm := root.get_node_or_null("StreamManager")
	_check(sm != null, "StreamManager autoload presente")
	_fin("autoload")
	if sm == null:
		return
	# Encolar una carga threaded de un recurso REAL (balloance/fishing.json es
	# un JSON, no Resource; usar un .json conocido como FileAccess, no load).
	# En Godot load() solo carga Resources (.tres/.png/.wav/etc.) — usar un
	# recurso existente del proyecto para el test.
	var ruta := "res://scripts/herramientas158/tool_tier_system.gd"
	if not ResourceLoader.exists(ruta):
		ruta = "res://scripts/stream/stream_manager.gd"
	_check(ResourceLoader.exists(ruta), "recurso de prueba existe: %s" % ruta)
	# Encolar con threaded: el callable recibe el Resource cargado
	var resultado: Array = [null]
	sm.encolar("test_rf2_1", "textura_atlas", 1, func(rec): resultado[0] = rec, ruta)
	_check(int(sm.cola_size()) == 1, "1 operación encolada con ruta threaded")
	# Procesar: si el thread no está listo, re-encola; al estarlo, ejecuta callback
	for i in range(100):
		sm._process(0.016)
		if resultado[0] != null:
			break
	_check(resultado[0] != null, "threaded callback recibió el Resource")
	var rec: Resource = resultado[0]
	_check(rec is Script or rec is Resource, "recurso cargado es Resource/Script")
	_fin("threaded")
	# Fallback: encolar con ruta INEXISTENTE → cae a callable sin thread
	var caido: Array = [0]
	sm.encolar("test_rf2_2", "textura_atlas", 1, func(): caido[0] += 1, "res://no_existe_recurso.xyz")
	for i in range(30):
		sm._process(0.016)
	_check(int(caido[0]) >= 1, "ruta inexistente cae a callable (fallback honesto)")
	_fin("fallback")
	# Operaciones SIN ruta siguen siendo callables diferidos (compatibilidad)
	var sin_ruta: Array = [0]
	sm.encolar("test_rf2_3", "chunk_lod0", 1, func(): sin_ruta[0] += 1)
	for i in range(30):
		sm._process(0.016)
	_check(int(sin_ruta[0]) == 1, "sin ruta = callable diferido (compatibilidad)")
	_fin("sin_ruta")


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


## Capa 3: corre SIEMPRE, aunque `_run()` haya abortado por un SCRIPT ERROR.
func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("FALLO: el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: solo %d checks ejecutados (minimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M63 RF2: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
