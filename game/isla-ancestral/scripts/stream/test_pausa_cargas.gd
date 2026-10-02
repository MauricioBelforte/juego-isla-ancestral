# Modelo: glm-5.3-flash (iter. 2) · DeepSeek-V4.1-Flash (iter. 5)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-03 · 2026-10-02
#
# M63: Test iter. 2 — pausa/reanudación de cargas (RF Pausa).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/stream/test_pausa_cargas.gd
#
# iter. 5 (Log 1192): se le añade guardian de 3 capas (bloque `_fin()`, piso
# CHECKS_MINIMOS MEDIDO y `_summary()` en su propio call_deferred). Antes
# imprimia "0 fallo(s)" sin contador: un aborto por SCRIPT ERROR daba verde.

extends SceneTree

## Piso MEDIDO en verde (Log 1192), NO copiado.
const CHECKS_MINIMOS := 9
const BLOQUES: Array[String] = ["autoload", "pausa", "reanudar", "idempotencia"]

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
	# Encolar 5 operaciones dummy con callables válidos
	for i in range(5):
		var op_id := "op_pausa_%d" % i
		sm.encolar(op_id, "chunk_lod0", i, func(): pass)
	_check(int(sm.cola_size()) == 5, "5 operaciones encoladas: %d" % int(sm.cola_size()))
	# PAUSAR: _process no debe consumir la cola
	sm.pausar_cargas()
	_check(bool(sm.cargas_pausadas()), "cargas_pausadas=true tras pausar")
	for i in range(30):
		sm._process(0.016)
	_check(int(sm.cola_size()) == 5, "cola INTACTA tras 30 frames pausados: %d" % int(sm.cola_size()))
	# Progreso congelado en piso 2%
	var p_pausado: float = float(sm.progreso())
	_check(absf(p_pausado - 0.02) < 0.001, "progreso congelado en piso (2%%): %.3f" % p_pausado)
	_fin("pausa")
	# REANUDAR: la cola se procesa normalmente
	sm.reanudar_cargas()
	_check(not bool(sm.cargas_pausadas()), "cargas_pausadas=false tras reanudar")
	for i in range(30):
		sm._process(0.016)
	_check(int(sm.cola_size()) == 0, "cola vacía tras reanudar y procesar: %d" % int(sm.cola_size()))
	_check(absf(float(sm.progreso()) - 1.0) < 0.001, "progreso 100%% tras vaciar")
	_fin("reanudar")
	# Idempotencia
	sm.pausar_cargas()
	sm.pausar_cargas()
	sm.reanudar_cargas()
	sm.reanudar_cargas()
	_check(not bool(sm.cargas_pausadas()), "pausa/reanudar idempotentes")
	_fin("idempotencia")


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
	print("=== TEST M63 PAUSA: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
