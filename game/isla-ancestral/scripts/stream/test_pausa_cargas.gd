# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-03
#
# M63: Test iter. 2 — pausa/reanudación de cargas (RF Pausa).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/stream/test_pausa_cargas.gd

extends SceneTree

var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var sm := root.get_node_or_null("StreamManager")
	_check(sm != null, "StreamManager autoload presente")
	if sm == null:
		print("=== TEST M63 PAUSA: 1 fallo(s) ===")
		quit(1)
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
	# REANUDAR: la cola se procesa normalmente
	sm.reanudar_cargas()
	_check(not bool(sm.cargas_pausadas()), "cargas_pausadas=false tras reanudar")
	for i in range(30):
		sm._process(0.016)
	_check(int(sm.cola_size()) == 0, "cola vacía tras reanudar y procesar: %d" % int(sm.cola_size()))
	_check(absf(float(sm.progreso()) - 1.0) < 0.001, "progreso 100%% tras vaciar")
	# Idempotencia
	sm.pausar_cargas()
	sm.pausar_cargas()
	sm.reanudar_cargas()
	sm.reanudar_cargas()
	_check(not bool(sm.cargas_pausadas()), "pausa/reanudar idempotentes")
	print("=== TEST M63 PAUSA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
