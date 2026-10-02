# Modelo: glm-5.3-flash (iter. 4) · DeepSeek-V4.1-Flash (iter. 5)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-06 · 2026-10-02
#
# M63 P1: Test de pantalla de carga (mostrar/ocultar/progreso real).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/stream/test_pantalla_carga.gd
#
# iter. 5 (Log 1192): se le añade guardian de 3 capas (bloque `_fin()`, piso
# CHECKS_MINIMOS MEDIDO y `_summary()` en su propio call_deferred).

extends SceneTree

## Piso MEDIDO en verde (Log 1192), NO copiado.
const CHECKS_MINIMOS := 7
const BLOQUES: Array[String] = ["autoload", "mostrar", "progreso", "ocultar"]

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var pc := root.get_node_or_null("PantallaCarga")
	_check(pc != null, "PantallaCarga autoload presente")
	_fin("autoload")
	if pc == null:
		return
	# Inicialmente oculta
	_check(not pc.visible, "pantalla inicia oculta")
	# Mostrar
	pc.mostrar()
	_check(pc.visible, "pantalla visible tras mostrar()")
	_fin("mostrar")
	# Simular progreso del StreamManager
	var sm := root.get_node_or_null("StreamManager")
	_check(sm != null, "StreamManager presente")
	if sm != null:
		sm.encolar("test_carga_1", "chunk_lod0", 1, func(): pass)
		sm.encolar("test_carga_2", "textura_atlas", 1, func(): pass)
		sm.encolar("test_carga_3", "banco_audio", 1, func(): pass)
		# Procesar la cola
		for i in range(50):
			sm._process(0.016)
		# Verificar que la barra creció
		var barra: ColorRect = pc.get_node_or_null("Barra")
		_check(barra != null, "barra existe")
		if barra != null:
			_check(barra.size.x > 0, "barra con ancho > 0: %.1f" % barra.size.x)
	_fin("progreso")
	# Ocultar
	pc.ocultar()
	_check(not pc.visible, "pantalla oculta tras ocultar()")
	_fin("ocultar")

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
	print("=== TEST M63 P1: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
