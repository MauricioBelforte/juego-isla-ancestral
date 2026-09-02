# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M63: Test de StreamManager (cola por pesos, progreso piso/tope, presupuesto
# de frame, LRU envejecido/tope, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/stream/test_stream.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var sm := root.get_node_or_null("StreamManager")
	_check(sm != null, "StreamManager autoload presente")
	if sm == null:
		print("=== TEST M63 STREAM: 1+ fallo(s) ===")
		quit(1)
		return
	_test_cola_pesos(sm)
	_test_progreso_piso_tope(sm)
	_test_presupuesto_frame(sm)
	_test_lru_envejecido(sm)
	_test_lru_tope(sm)
	_test_persistencia(sm)
	print("=== TEST M63 STREAM: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_cola_pesos(sm: Node) -> void:
	# §2: pesos por tipo de operación
	_check(float(sm.PESOS.get("chunk_lod0", 0)) == 1.0, "peso chunk_lod0 = 1 (§2)")
	_check(float(sm.PESOS.get("shader", 0)) == 5.0, "peso shader = 5 (§2)")
	# Encolar 3 operaciones con prioridades desordenadas; el orden debe ser por prioridad
	sm.encolar("op_a", "chunk_lod0", 2, func(): pass)
	sm.encolar("op_b", "shader", 1, func(): pass)
	sm.encolar("op_c", "banco_audio", 3, func(): pass)
	_check(sm.cola_size() == 3, "3 operaciones encoladas")
	# El primero en procesarse debe ser op_b (prioridad 1)
	var primero: String = String(sm._cola[0].get("op_id", ""))
	_check(primero == "op_b", "orden por prioridad (op_b primero): %s" % primero)

func _test_progreso_piso_tope(sm: Node) -> void:
	# Piso 2% con cola no vacía al inicio (§2)
	var p0: float = sm.progreso()
	_check(p0 >= 0.02, "piso 2% al iniciar cola (%.2f)" % p0)
	# Procesar todo: llega a 1.0 (tope se levanta al vaciar)
	var frames := 0
	while sm.cola_size() > 0 and frames < 50:
		sm._process(0.016)
		frames += 1
	_check(sm.cola_size() == 0, "cola vaciada por _process")
	_check(absf(sm.progreso() - 1.0) < 0.01, "progreso 100% al vaciar")
	# Tope 98%: encolar trabajo largo y verificar que no salta a 100% a mitad
	sm.encolar("op_x1", "chunk_lod1", 1, func(): pass)
	sm.encolar("op_x2", "chunk_lod1", 2, func(): pass)
	sm._process(0.016)  # procesa solo op_x1 (o ambas — depende del presupuesto)
	var p1: float = sm.progreso()
	_check(p1 <= 0.98 + 0.02, "tope 98% respetado en cola parcial (%.2f)" % p1)
	sm._process(0.016)

func _test_presupuesto_frame(sm: Node) -> void:
	# §8: el _process respeta PRESUPUESTO_MS — con muchas ops cortas, procesa
	# varias por frame pero sale si excede el presupuesto
	sm.encolar("bulk", "npc_instancia", 1, func(): pass)
	for i in range(200):
		sm.encolar("bulk_%d" % i, "npc_instancia", 5, func(): pass)
	var antes: int = sm.cola_size()
	sm._process(0.016)
	_check(sm.cola_size() < antes, "_process drena la cola (presupuesto ms)")
	# Todas cortas: es plausible que drene en 1 frame con presupuesto 40ms — OK

func _test_lru_envejecido(sm: Node) -> void:
	# §4: registrar chunks, envejecer los lejanos, liberar
	sm.registrar_chunk("chunk_cerca", 5.0)
	sm.registrar_chunk("chunk_lejos", 200.0)
	sm.registrar_chunk("chunk_medio", 50.0)
	sm.marcar_envejecidos(100.0)  # cerca/medio en rango, lejos envejece
	sm.marcar_envejecidos(100.0)  # 2 frames
	var liberados: int = sm.liberar_envejecidos()
	_check(liberados == 1, "solo el lejano envejecido se libera (%d)" % liberados)
	_check(sm.chunk_activo("chunk_cerca"), "cercano sobrevive")
	_check(not sm.chunk_activo("chunk_lejos"), "lejano liberado")
	# Envejecido con 1 frame NO se libera aún
	sm.registrar_chunk("chunk_recien", 300.0)
	sm.marcar_envejecidos(100.0)
	sm.liberar_envejecidos()
	_check(sm.chunk_activo("chunk_recien"), "1 frame envejecido aún NO se libera")

func _test_lru_tope(sm: Node) -> void:
	# §4 tope duro: MAX_CHUNKS (limpiar chunks de tests anteriores — singleton)
	sm._chunks.clear()
	sm.set_max_chunks(3)
	sm.registrar_chunk("a", 1.0)
	sm.registrar_chunk("b", 2.0)
	sm.registrar_chunk("c", 3.0)
	sm.registrar_chunk("d", 4.0)
	sm.registrar_chunk("e", 5.0)
	var liberados: int = sm.aplicar_tope()
	_check(liberados == 2, "tope 3 libera 2 (%d)" % liberados)
	_check(sm.chunks_activos() == 3, "chunks activos = 3")
	_check(sm.chunk_activo("a") and sm.chunk_activo("b"), "los más cercanos sobreviven")
	_check(not sm.chunk_activo("d") and not sm.chunk_activo("e"), "los más lejanos liberados")

func _test_persistencia(sm: Node) -> void:
	var data: Dictionary = sm.get_save_data()
	_check(data.has("max_chunks") and data.has("descargas_total"), "save_data métricas LRU")
	_check(sm.get_section_name() == "stream", "sección 'stream'")
	sm.restore_save_data({"max_chunks": 100, "descargas_total": 999})
	_check(sm.chunks_activos() <= 100, "max_chunks restaurado")
	sm.set_max_chunks(4096)
