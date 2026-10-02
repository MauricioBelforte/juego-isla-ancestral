# Modelo: deepseek-v4-flash (iter. 1) · DeepSeek-V4.1-Flash (iter. 5, reescrito)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-01 · 2026-10-02
#
# M63: Cargas y Streaming — suite canónica.
# Cubre lo que NINGUNA otra suite del módulo cubre:
#   A. ProgressCalculator (pesos por tipo, peso total, progreso).
#   B. StreamManager: API de cola (PESOS, tipo desconocido, orden por prioridad,
#      pesos_encolados).
#   C. Señales del manager (operacion_completada, chunk_listo, banco_listo,
#      shader_listo, progreso_cambiado) — no cubiertas en test_stream.gd.
#   D. Progreso real (piso 2%, tope 98% mientras hay cola, 100% al vaciar).
#
# ⚠️ HISTORIA (Log 1192): esta suite estaba MUERTA dando verde. Apuntaba a una
# API que nunca existió en el manager entregado (`sm.weights`,
# `sm.cargadas_size()`, `sm.obtener_cache()`, `sm.presupuesto_chunks`,
# `sm.cola_vacia`, `encolar(tipo, ruta)` de 2 args, `precalentar_mundo(Array)`).
# Cada llamada lanzaba un SCRIPT ERROR que abortaba la función, el resumen
# imprimía "8 checks, 0 fallos" y salía con código 0. El sello §21.8 del módulo
# (Log 895) se apoyó en ese "0 fallos". Reescrita contra la API REAL con
# guardián de 3 capas (bloque `_fin()`, piso CHECKS_MINIMOS MEDIDO, `_summary()`
# en su propio call_deferred).
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/stream/test_stream_m63.gd

extends SceneTree

## Piso MEDIDO en verde (29 checks, Log 1192), NO copiado.
const CHECKS_MINIMOS := 29
const BLOQUES: Array[String] = ["A", "B", "C", "D"]

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M63] Test de Cargas y Streaming (suite canonica) ===")
	_bloque_a_progress_calculator()
	var sm := root.get_node_or_null("StreamManager")
	if sm == null:
		_check("StreamManager autoload presente", false)
		return
	_check("StreamManager autoload presente", true)
	_bloque_b_cola(sm)
	_bloque_c_senales(sm)
	_bloque_d_progreso(sm)


## ── A. ProgressCalculator (class_name, métodos estáticos) ─────────────────
func _bloque_a_progress_calculator() -> void:
	print("--- A. ProgressCalculator: pesos y progreso ---")
	_check("peso escena = 10", ProgressCalculator.peso_de_tipo("escena") == 10)
	_check("peso chunk = 2", ProgressCalculator.peso_de_tipo("chunk") == 2)
	_check("peso región = 5", ProgressCalculator.peso_de_tipo("region") == 5)
	_check("peso desconocido = 1", ProgressCalculator.peso_de_tipo("xyz") == 1)
	_check("peso data-driven (weights json)",
		ProgressCalculator.peso_de_tipo("escena", {"escena": 25}) == 25)
	var ops := [{"peso": 10}, {"peso": 5}, {"peso": 5}]
	_check("peso total de cola = 20", ProgressCalculator.calcular_peso_total(ops) == 20)
	_check("progreso 0.5", ProgressCalculator.progreso(10, 20) == 0.5)
	_check("progreso 1.0 con total 0 (vacío = completo)",
		ProgressCalculator.progreso(0, 0) == 1.0)
	_fin("A")


## ── B. API de la cola ────────────────────────────────────────────────────
func _bloque_b_cola(sm: Node) -> void:
	print("--- B. StreamManager: cola con pesos + orden por prioridad ---")
	_check("PESOS.chunk_lod0 = 1 (§2)", float(sm.PESOS.get("chunk_lod0", 0)) == 1.0)
	_check("PESOS.shader = 5 (§2)", float(sm.PESOS.get("shader", 0)) == 5.0)
	# Los 7 pesos de §2, medidos de una sola vez (evidencia de la sección C).
	var esperados := {
		"chunk_lod0": 1.0, "chunk_lod1": 3.0, "banco_audio": 3.0,
		"textura_atlas": 2.0, "shader": 5.0, "npc_instancia": 1.0, "malla_region": 4.0,
	}
	var pesos_ok := true
	var pesos_mal := ""
	for k in esperados:
		if not is_equal_approx(float(sm.PESOS.get(k, -1.0)), float(esperados[k])):
			pesos_ok = false
			pesos_mal += "%s=%s " % [k, str(sm.PESOS.get(k, "ausente"))]
	_check("los 7 pesos de §2 coinciden", pesos_ok, pesos_mal)
	_check("PESOS tiene exactamente 7 tipos", sm.PESOS.size() == 7, "n=%d" % sm.PESOS.size())
	# Tipo desconocido: encolar() debe RECHAZAR (devuelve false), no romper.
	_check("tipo desconocido -> encolar() = false",
		sm.encolar("op_malo", "tipo_inexistente", 1, func(): pass) == false)
	_check("el rechazo NO ensució la cola", sm.cola_size() == 0,
		"cola=%d" % sm.cola_size())
	# Encolar 3 con prioridades desordenadas: el orden debe ser por prioridad.
	var p0: float = float(sm.pesos_encolados())
	sm.encolar("op_a", "chunk_lod0", 2, func(): pass)   # peso 1
	sm.encolar("op_b", "shader", 1, func(): pass)       # peso 5
	sm.encolar("op_c", "banco_audio", 3, func(): pass)  # peso 3
	_check("3 operaciones encoladas", sm.cola_size() == 3, "cola=%d" % sm.cola_size())
	_check("orden por prioridad (op_b primero)",
		String(sm._cola[0].get("op_id", "")) == "op_b",
		"primero=%s" % String(sm._cola[0].get("op_id", "")))
	_check("pesos_encolados() sumó 1+5+3 = 9",
		is_equal_approx(float(sm.pesos_encolados()) - p0, 9.0),
		"delta=%.1f" % (float(sm.pesos_encolados()) - p0))
	_fin("B")


## ── C. Señales del manager ───────────────────────────────────────────────
func _bloque_c_senales(sm: Node) -> void:
	print("--- C. Señales: operacion_completada + chunk/banco/shader_listo ---")
	var completadas: Array = []
	var chunks: Array = []
	var bancos: Array = []
	var shaders: Array = []
	var progresos: Array = []
	sm.operacion_completada.connect(func(op_id, _tipo): completadas.append(op_id))
	sm.chunk_listo.connect(func(cid): chunks.append(cid))
	sm.banco_listo.connect(func(bid): bancos.append(bid))
	sm.shader_listo.connect(func(sid): shaders.append(sid))
	sm.progreso_cambiado.connect(func(p): progresos.append(p))
	# Procesar hasta vaciar (los 3 ops de B: chunk_lod0, shader, banco_audio).
	for i in range(30):
		sm._process(0.016)
		if sm.cola_size() == 0:
			break
	_check("cola vaciada por _process", sm.cola_size() == 0, "cola=%d" % sm.cola_size())
	_check("operacion_completada emitió las 3", completadas.size() == 3,
		"n=%d" % completadas.size())
	_check("chunk_listo emitió op_a (chunk_lod0)", chunks.has("op_a"), "%s" % [chunks])
	_check("shader_listo emitió op_b (shader)", shaders.has("op_b"), "%s" % [shaders])
	_check("banco_listo emitió op_c (banco_audio)", bancos.has("op_c"), "%s" % [bancos])
	_check("progreso_cambiado se emitió al menos una vez", progresos.size() >= 1,
		"n=%d" % progresos.size())
	_fin("C")


## ── D. Progreso real (piso/tope/cierre §2) ───────────────────────────────
func _bloque_d_progreso(sm: Node) -> void:
	print("--- D. Progreso: piso 2%, tope 98%, 100% al vaciar ---")
	_check("100% con la cola vacía", absf(float(sm.progreso()) - 1.0) < 0.001,
		"p=%.3f" % float(sm.progreso()))
	# Encolar trabajo pendiente: el progreso NO debe saltar a 1.0.
	sm.encolar("op_x1", "chunk_lod1", 1, func(): pass)
	var p: float = float(sm.progreso())
	_check("piso 2% respetado con cola pendiente", p >= 0.02 - 0.0001, "p=%.3f" % p)
	_check("tope 98% respetado con cola pendiente", p <= 0.98 + 0.0001, "p=%.3f" % p)
	for i in range(20):
		sm._process(0.016)
	_check("cola vacía tras procesar", sm.cola_size() == 0, "cola=%d" % sm.cola_size())
	_check("100% tras vaciar", absf(float(sm.progreso()) - 1.0) < 0.001,
		"p=%.3f" % float(sm.progreso()))
	_fin("D")


## ── Utilidades ───────────────────────────────────────────────────────────

func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


## Capa 3: corre SIEMPRE, aunque `_run()` haya abortado por un SCRIPT ERROR.
func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecutó (posible SCRIPT ERROR que abortó la función)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (mínimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M63 (canónica): %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M63 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M63 OK — los %d checks pasaron" % _checks)
		quit(0)
