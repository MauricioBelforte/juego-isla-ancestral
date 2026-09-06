# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M63: Test iter. 3 — RF2 cargas asíncronas con load_threaded_request real.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/stream/test_rf2_threaded.gd

extends SceneTree

var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var sm := root.get_node_or_null("StreamManager")
	_check(sm != null, "StreamManager autoload presente")
	if sm == null:
		print("=== TEST M63 RF2: 1 fallo(s) ===")
		quit(1)
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
	# Fallback: encolar con ruta INEXISTENTE → cae a callable sin thread
	var caido: Array = [0]
	sm.encolar("test_rf2_2", "textura_atlas", 1, func(): caido[0] += 1, "res://no_existe_recurso.xyz")
	for i in range(30):
		sm._process(0.016)
	_check(int(caido[0]) >= 1, "ruta inexistente cae a callable (fallback honesto)")
	# Operaciones SIN ruta siguen siendo callables diferidos (compatibilidad)
	var sin_ruta: Array = [0]
	sm.encolar("test_rf2_3", "chunk_lod0", 1, func(): sin_ruta[0] += 1)
	for i in range(30):
		sm._process(0.016)
	_check(int(sin_ruta[0]) == 1, "sin ruta = callable diferido (compatibilidad)")
	print("=== TEST M63 RF2: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
