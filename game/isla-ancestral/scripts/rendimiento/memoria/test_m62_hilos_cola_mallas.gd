# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-18
#
# M62: Memoria — Suite "generación de mallas en hilos (M08): resultados por
# cola sin copias extra" (pin L141, ítem de reposición [C]).
# Requerimiento de origen: M08 (08-Mundo-Voxel plan-actual 01-Requerimientos.md
# L32): "Generación/guardado en hilos; nunca bloquear el hilo principal" (RF4
# meshing multihilo, 02-Analisis.md L35: pool de hilos de Voxel Tools).
#
# Contrato que pina (headless, autoloads REALES MemoryMonitor + StreamManager):
#   A. CARGA REAL POR LA COLA CON HILO: encolar() una malla con ruta delega en
#      ResourceLoader.load_threaded_request (hilo del engine, NO el main) y el
#      resultado llega por callback. SIN COPIAS: la instancia entregada es la
#      MISMA del cache del loader (identidad de instance_id + resource_path).
#      El peso de la operación (malla_region = 4.0) se reclama UNA sola vez.
#   B. HANDSHAKE §5.3 EN LA ENTREGA: durante la ventana de entrega el recurso
#      va declarado en el 63 (recursos_en_carga_63 == 1), registrado en el 62
#      (recursos_en_carga >= 1) y el veto de producción _puede_descargar()
#      responde false. Tras la entrega ambos lados quedan en 0 y el aviso al
#      62 quedó contado (avisos_m62).
#   C. ANTI DOBLE CARGA L158: _encolar_precarga() de una ruta YA en vuelo
#      devuelve 0 (no hay segunda operación); una sola ruta en _rutas_en_carga;
#      una sola operación completada medida por señal operacion_completada.
#   D. PESO SIN RE-CLAIM A TRAVÉS DE LA ESPERA: el re-encolado del estado
#      IN_PROGRESS en _process() NO vuelve a sumar peso — el delta de
#      pesos_encolados() se mantiene exactamente 4.0 en cada bombeo (muestras)
#      y el progreso pasa de <1 (pendiente) a 1.0 (drenada).
#   E. CONSERVACIÓN GLOBAL: 5 ciclos cola→entrega→registro M62→descarga→drop
#      liberan limpio (1 MB descargado + 1 drop de cola por ciclo). Invariante
#      de "sin copias extra": JAMÁS dos instancias del fixture vivas a la vez
#      (la recarga tras descarga es limpia: la anterior ya no existe). Control
#      positivo anti-falso-verde: CACHE_MODE_IGNORE fuerza 2 vivas y el
#      detector DEBE verlas. Cola/activos/rutas en 0 y delta objetos <= 0.
#
# Fixture: test_fixture_mesh_malla_region.tres (BoxMesh 1×1×1, recurso
# PERMANENTE de la suite — no se borra; tipo "malla_region" => peso 4.0).
#
# Alcance (honesto): el meshing REAL del terreno voxel corre en C++ (Voxel
# Tools) y su integración de datos vive en M08/M63; esta suite pina el
# contrato del 63 que recibe esos resultados: entrega por hilo del engine sin
# copias, con handshake y peso exacto.
#
# Guardián anti-falso-verde de 3 capas:
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_hilos_cola_mallas.gd

extends SceneTree

const MODULO := "M62 hilos/cola de mallas (L141)"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md §16 / evidencia Tanda 64).
const CHECKS_MINIMOS := 33

const FIXTURE := "res://scripts/rendimiento/memoria/test_fixture_mesh_malla_region.tres"
const PESO_MALLA_MB := 4.0   ## semántica PESOS.malla_region = 4.0
const TIMEOUT_MS := 15000    ## techo del bombeo manual (hilo del engine)
const CICLOS := 5

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Diagnóstico del resumen (auditoría sin re-correr).
var _a_veces: int = -1
var _a_identidad: int = -1
var _b_en_carga: int = -1
var _b_veto: int = -1
var _c_delta_ops: int = -1
var _d_muestras: int = -1
var _e_ciclos: int = -1
var _e_copias: int = -1
var _e_nulas: int = -1
var _e_reusos: int = -1
var _e_recargas: int = -1
var _e_control: int = -1

## Ancla viva de la suite: mantiene el fixture referenciado desde A (análogo
## de producción: el mundo retiene lo que carga). Con refs vivas y sin
## descarga el loader REUTILIZA la MISMA instancia (probes Tanda 64: 8/8);
## tras la descarga completa el engine puede reclamarla y la próxima carga es
## una instancia nueva limpia (recarga, no copia).
var _ancla: Resource = null


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Generación de mallas en hilos (M08): resultados por cola sin copias extra (L141) ===")
	var mm := _mm()
	if mm == null:
		_check("autoload MemoryMonitor presente", false, "mm=null")
		return
	_check("autoload MemoryMonitor presente", true)
	var sm := _sm()
	_check("autoload StreamManager presente (vía real M63)", sm != null, "sm=null")
	if sm == null:
		return
	_check("fixture BoxMesh presente y detectable (ResourceLoader.exists)",
		ResourceLoader.exists(FIXTURE), FIXTURE)
	_bloque_a(mm, sm)
	_bloque_b(mm, sm)
	_bloque_c(mm, sm)
	_bloque_d(mm, sm)
	_bloque_e(mm, sm)


## ── A. Carga real por la cola (hilo del engine) sin copias ──────────────────
func _bloque_a(mm: Node, sm: Node) -> void:
	print("--- A. Carga real por la cola con hilo del engine: MISMA instancia ---")
	var p0: float = float(sm.pesos_encolados())
	_check("la cola arranca drenada y sin rutas en vuelo",
		sm.cola_size() == 0 and sm.rutas_en_carga() == 0,
		"cola=%d rutas=%d" % [sm.cola_size(), sm.rutas_en_carga()])
	var entrega := {"veces": 0, "rec": null}
	var cb := func(rec: Resource = null) -> void:
		entrega["veces"] = int(entrega["veces"]) + 1
		entrega["rec"] = rec
	var ok: bool = sm.encolar("t64_op_a", "malla_region", 2, cb, FIXTURE)
	_check("encolar una malla por la cola real: en vuelo con hilo + peso 4.0 una vez",
		ok and sm.cola_size() == 1
			and (absf(float(sm.pesos_encolados()) - p0 - PESO_MALLA_MB) < 0.001)
			and sm.esta_cargando_ruta(FIXTURE),
		"ok=%s cola=%d dpeso=%.1f en_vuelo=%s" % [str(ok), sm.cola_size(),
			float(sm.pesos_encolados()) - p0, str(sm.esta_cargando_ruta(FIXTURE))])
	var muestras: Array = []
	var pr: Array = _pump(sm, muestras)
	_check("el bombeo drena la cola dentro del timeout (%d iteraciones)" % int(pr[0]),
		bool(pr[1]), "cola_fin=%d" % sm.cola_size())
	_a_veces = int(entrega["veces"])
	var rec_a: Resource = entrega["rec"]
	_check("el callback recibió UNA entrega con una Mesh real",
		_a_veces == 1 and rec_a is Mesh,
		"veces=%d clase=%s" % [_a_veces, str(rec_a.get_class()) if rec_a != null else "null"])
	var cache: Resource = ResourceLoader.load(FIXTURE)
	var id_ent: int = rec_a.get_instance_id() if rec_a != null else -1
	var id_ca: int = cache.get_instance_id() if cache != null else -1
	# OJO: los ObjectID uint64 se leen como int64 (pueden venir negativos);
	# la identidad válida es la IGUALDAD de ids vivos (id 0 = objeto liberado).
	_a_identidad = 1 if (id_ent == id_ca and id_ent != 0) else 0
	var ruta_ok: bool = rec_a != null and rec_a.resource_path == FIXTURE
	_check("SIN COPIAS: el resultado es la MISMA instancia del cache (identidad + ruta)",
		_a_identidad == 1 and ruta_ok,
		"id_entrega=%d id_cache=%d ruta=%s" % [id_ent, id_ca,
			str(rec_a.resource_path) if rec_a != null else "?"])
	# Ancla viva de la suite (verificado con probe del loader en Tanda 64:
	# con refs vivas el loader reutiliza la MISMA instancia en cada recarga;
	# sin refs el cache purga y la recarga crea instancia nueva — normal).
	_ancla = rec_a
	_check("ruta cerrada tras la entrega (anti-doble L158 sin residuo)",
		not sm.esta_cargando_ruta(FIXTURE) and sm.rutas_en_carga() == 0
			and sm.cola_size() == 0,
		"en_vuelo=%s rutas=%d cola=%d" % [str(sm.esta_cargando_ruta(FIXTURE)),
			sm.rutas_en_carga(), sm.cola_size()])
	_check("peso reclamado EXACTAMENTE una vez (delta 4.0) y progreso en 1.0",
		(absf(float(sm.pesos_encolados()) - p0 - PESO_MALLA_MB) < 0.001)
			and (absf(sm.progreso() - 1.0) < 0.001),
		"dpeso=%.1f progreso=%.2f" % [float(sm.pesos_encolados()) - p0, sm.progreso()])
	_fin("A")


## ── B. Handshake §5.3 durante la entrega por cola ────────────────────────────
func _bloque_b(mm: Node, sm: Node) -> void:
	print("--- B. Handshake durante la entrega (declarado en 63, registrado en 62, vetado) ---")
	var avisos0: int = int(sm.avisos_m62())
	var ent := {"rec": null, "en_carga_mm": -1, "en_carga_63": -1, "veto": false}
	var cb := func(rec: Resource = null) -> void:
		ent["rec"] = rec
		ent["en_carga_mm"] = int(mm.recursos_en_carga())
		ent["en_carga_63"] = int(sm.recursos_en_carga_63())
		ent["veto"] = ((not bool(mm._puede_descargar(rec))) if rec != null else false)
	sm.encolar("t64_op_b", "malla_region", 2, cb, FIXTURE)
	var muestras: Array = []
	_pump(sm, muestras)
	_b_en_carga = int(ent["en_carga_63"])
	_b_veto = 1 if bool(ent["veto"]) else 0
	_check("durante la ventana de entrega el recurso va declarado (63) y registrado (62)",
		int(ent["en_carga_63"]) == 1 and int(ent["en_carga_mm"]) >= 1,
		"63=%d mm=%d" % [int(ent["en_carga_63"]), int(ent["en_carga_mm"])])
	_check("en la ventana el veto de producción está ACTIVO (_puede_descargar = false)",
		bool(ent["veto"]), "veto=%s" % str(ent["veto"]))
	_check("tras la entrega el handshake quedó CERRADO en ambos lados",
		sm.recursos_en_carga_63() == 0 and int(mm.recursos_en_carga()) == 0,
		"63=%d mm=%d" % [sm.recursos_en_carga_63(), int(mm.recursos_en_carga())])
	var rec_b: Resource = ent["rec"]
	_check("la segunda entrega es la MISMA instancia del ancla (sin copia entre cargas)",
		rec_b != null and rec_b == _ancla,
		"id=%d id_ancla=%d" % [rec_b.get_instance_id() if rec_b != null else -1,
			_ancla.get_instance_id() if _ancla != null else -1])
	_check("el aviso al 62 quedó contado (avisos_m62 incrementó)",
		sm.avisos_m62() > avisos0,
		"avisos=%d (antes %d)" % [sm.avisos_m62(), avisos0])
	_fin("B")


## ── C. Anti doble carga L158: la misma ruta no entra dos veces ───────────────
func _bloque_c(mm: Node, sm: Node) -> void:
	print("--- C. Anti doble carga L158 (la misma ruta no se encola dos veces) ---")
	var completadas := [0]
	var fy := func(_op_id: String, _tipo: String) -> void:
		completadas[0] = int(completadas[0]) + 1
	var con: int = sm.operacion_completada.connect(fy)
	_check("instrumentación conectada (señal operacion_completada)", con == OK, "err=%d" % con)
	var c0: int = int(completadas[0])
	var e1: int = sm._encolar_precarga(FIXTURE, "malla_region", 3)
	_check("_encolar_precarga encola la primera vez (1) y abre la ruta",
		e1 == 1 and sm.esta_cargando_ruta(FIXTURE) and sm.cola_size() == 1,
		"e1=%d en_vuelo=%s cola=%d" % [e1, str(sm.esta_cargando_ruta(FIXTURE)), sm.cola_size()])
	var e2: int = sm._encolar_precarga(FIXTURE, "malla_region", 3)
	_check("la segunda llamada INMEDIATA es rechazada (0) — no hay segunda operación",
		e2 == 0 and sm.cola_size() == 1,
		"e2=%d cola=%d" % [e2, sm.cola_size()])
	_check("una sola ruta en vuelo (sin segunda carga de la misma malla)",
		sm.rutas_en_carga() == 1,
		"rutas=%d" % sm.rutas_en_carga())
	var muestras: Array = []
	var pr: Array = _pump(sm, muestras)
	_check("el bombeo drena y cierra la ruta",
		bool(pr[1]) and not sm.esta_cargando_ruta(FIXTURE) and sm.rutas_en_carga() == 0,
		"cola=%d en_vuelo=%s" % [sm.cola_size(), str(sm.esta_cargando_ruta(FIXTURE))])
	_c_delta_ops = int(completadas[0]) - c0
	_check("operacion_completada delta == 1 (una única operación completada)",
		_c_delta_ops == 1, "delta=%d" % _c_delta_ops)
	_fin("C")


## ── D. Peso exacto a través de la espera (re-encolado sin re-claim) ──────────
func _bloque_d(mm: Node, sm: Node) -> void:
	print("--- D. Peso exacto durante la espera (IN_PROGRESS re-encola sin re-claim) ---")
	var p0: float = float(sm.pesos_encolados())
	sm.encolar("t64_op_d", "malla_region", 2, Callable(), FIXTURE)
	_check("encolada: cola 1 y delta de peso exactamente 4.0 (reclamado una vez)",
		sm.cola_size() == 1
			and (absf(float(sm.pesos_encolados()) - p0 - PESO_MALLA_MB) < 0.001),
		"cola=%d dpeso=%.2f" % [sm.cola_size(), float(sm.pesos_encolados()) - p0])
	_check("con la operación pendiente el progreso NO llegó a 1.0",
		sm.progreso() < 1.0 - 0.000001,
		"progreso=%.3f" % sm.progreso())
	var muestras: Array = []
	var pr: Array = _pump(sm, muestras)
	var max_dev: float = 0.0
	for m in muestras:
		max_dev = maxf(max_dev, absf(float(m) - p0 - PESO_MALLA_MB))
	_d_muestras = muestras.size()
	_check("cada bombeo conserva el delta de peso en 4.0 (ningún re-claim)",
		muestras.size() >= 1 and max_dev < 0.001,
		"n=%d max_desvio=%.3f" % [muestras.size(), max_dev])
	_check("tras drenar: cola 0, delta peso sigue 4.0 y progreso 1.0",
		bool(pr[1])
			and (absf(float(sm.pesos_encolados()) - p0 - PESO_MALLA_MB) < 0.001)
			and (absf(sm.progreso() - 1.0) < 0.001),
		"cola=%d dpeso=%.2f prog=%.3f" % [sm.cola_size(),
			float(sm.pesos_encolados()) - p0, sm.progreso()])
	_check("la ruta quedó cerrada (sin residuo del anti-doble)",
		not sm.esta_cargando_ruta(FIXTURE) and sm.rutas_en_carga() == 0,
		"en_vuelo=%s rutas=%d" % [str(sm.esta_cargando_ruta(FIXTURE)), sm.rutas_en_carga()])
	_fin("D")


## ── E. Conservación global: 5 ciclos cola→entrega→registro→drop ──────────────
func _bloque_e(mm: Node, sm: Node) -> void:
	print("--- E. Conservación global: %d ciclos cola→entrega→registro M62→drop ---" % CICLOS)
	# Ciclo de calentamiento: llena el cache del loader (no cuenta).
	var warm := {"rec": null}
	var cbw := func(rec: Resource = null) -> void:
		warm["rec"] = rec
	sm.encolar("t64_e_warm", "malla_region", 2, cbw, FIXTURE)
	var mw: Array = []
	_pump(sm, mw)
	# Antes de cualquier descarga (E es el único bloque que descarga) el loader
	# con cache viva reutiliza la MISMA instancia del ancla (probes Tanda 64).
	_check("con el ancla viva el loader reutiliza la MISMA instancia (sin recarga aún)",
		warm["rec"] != null and warm["rec"] == _ancla,
		"warm=%s" % ("viva" if warm["rec"] != null else "null"))
	var base: int = int(mm.objetos_vivos())
	var d0: int = int(sm.descargas_total())
	# Invariante de "sin copias extra": JAMÁS dos instancias del fixture vivas
	# a la vez. Con la descarga completa activa el engine puede reclamar la
	# instancia descargada (probes: el refcount decae y la próxima carga trae
	# una instancia NUEVA) — eso es RECARGA limpia, no copia: la copia sería
	# que la nueva llegue mientras la anterior SIGUE viva.
	var prev: Resource = null
	var hubo_prev: bool = false
	var copias: int = 0
	var nulas: int = 0
	var reusos: int = 0
	var recargas: int = 0
	var ciclos_ok: int = 0
	for i in range(CICLOS):
		var ent := {"rec": null}
		var cb := func(rec: Resource = null) -> void:
			ent["rec"] = rec
		sm.encolar("t64_e_%d" % i, "malla_region", 2, cb, FIXTURE)
		var ms: Array = []
		_pump(sm, ms)
		var r: Resource = ent["rec"]
		var entrego: bool = r != null
		if not entrego:
			nulas += 1
		else:
			if hubo_prev:
				if r == prev:
					reusos += 1  # misma instancia viva: reuso del cache
				elif is_instance_valid(prev):
					copias += 1  # la nueva llegó con la anterior VIVA: copia real
				else:
					recargas += 1  # la anterior ya no existe: recarga limpia
			prev = r
			hubo_prev = true
		sm.registrar_chunk("t64_e/c%d" % i, 60.0, r)
		var lib: int = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
		r = null
		sm.marcar_envejecidos(0.0)
		sm.marcar_envejecidos(0.0)
		var libsm: int = sm.liberar_envejecidos()
		var cola: int = mm.unload.candidatos_count()
		if entrego and lib == 1 and libsm == 1 and cola == 0 and sm.chunks_activos() == 0:
			ciclos_ok += 1
		print("  ciclo %d: entrego=%s lib=%d libsm=%d cola=%d" % [i, str(entrego), lib, libsm, cola])
	_e_ciclos = ciclos_ok
	_e_copias = copias
	_e_nulas = nulas
	_e_reusos = reusos
	_e_recargas = recargas
	var act: int = sm.chunks_activos()
	var cola_fin: int = mm.unload.candidatos_count()
	var fin: int = int(mm.objetos_vivos())
	_check("los %d ciclos entregaron, descargaron (1 MB) y liberaron (1) limpio" % CICLOS,
		ciclos_ok == CICLOS, "ciclos_ok=%d" % ciclos_ok)
	_check("sin copias: %d entregas vivas, 0 nulas, 0 duplicados y todas clasificadas" % CICLOS,
		nulas == 0 and copias == 0 and reusos + recargas + nulas == CICLOS - 1,
		"nulas=%d copias=%d reusos=%d recargas=%d" % [nulas, copias, reusos, recargas])
	_check("cola 62 final 0 y 0 chunks activos",
		cola_fin == 0 and act == 0, "cola=%d activos=%d" % [cola_fin, act])
	_check("delta global de objetos_vivos <= 0 (fin <= base) y sin rutas en vuelo",
		fin <= base and sm.rutas_en_carga() == 0,
		"fin=%d base=%d rutas=%d" % [fin, base, sm.rutas_en_carga()])
	_check("las descargas del 63 quedaron contadas (+%d)" % CICLOS,
		int(sm.descargas_total()) - d0 == CICLOS,
		"delta=%d" % (int(sm.descargas_total()) - d0))
	# Control POSITIVO del detector de copias (anti-falso-verde, capa semántica):
	# dos cargas CACHE_MODE_IGNORE devuelven DOS instancias frescas distintas,
	# ambas retenidas por estas variables => 2 vivas simultáneas garantizadas.
	# El detector (desigualdad + is_instance_valid) DEBE verlas; si no, el
	# detector estaría ciego. Autocontenido a propósito (no depende de `prev`,
	# al que el engine puede reclamar entre ciclos).
	var dup1: Resource = ResourceLoader.load(FIXTURE, "", ResourceLoader.CACHE_MODE_IGNORE)
	var dup2: Resource = ResourceLoader.load(FIXTURE, "", ResourceLoader.CACHE_MODE_IGNORE)
	var control: int = 0
	if dup1 != null and dup2 != null and dup1 != dup2 \
			and is_instance_valid(dup1) and is_instance_valid(dup2):
		control = 1
	_e_control = control
	_check("control positivo: el detector SÍ ve una copia forzada (2 CACHE_MODE_IGNORE = 2 vivas)",
		control == 1, "control=%d dup1=%d dup2=%d" % [control,
			dup1.get_instance_id() if dup1 != null else 0,
			dup2.get_instance_id() if dup2 != null else 0])
	_fin("E")


## ── Utilidades ───────────────────────────────────────────────────────────────

func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


func _sm() -> Node:
	return root.get_node_or_null("StreamManager")


## Bombea la cola real del 63 (`_process`) hasta drenar o agotar el timeout.
## `muestras` registra `pesos_encolados()` tras cada bombeo (detección de
## re-claim por re-encolado IN_PROGRESS). Devuelve [iteraciones, drenó].
func _pump(sm: Node, muestras: Array) -> Array:
	var inicio := Time.get_ticks_msec()
	var it := 0
	while sm.cola_size() > 0 and Time.get_ticks_msec() - inicio < TIMEOUT_MS:
		sm._process(0.0)
		muestras.append(sm.pesos_encolados())
		it += 1
		OS.delay_msec(1)
	return [it, sm.cola_size() == 0]


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALL] %s %s" % [nombre, detalle])


## Capa 3: corre SIEMPRE, aunque `_run()` haya abortado por un SCRIPT ERROR.
func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FALL] el bloque %s NO se ejecutó (posible SCRIPT ERROR que abortó la función)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FALL] solo %d checks ejecutados (mínimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("-- A: veces=%d identidad=%d" % [_a_veces, _a_identidad])
	print("-- B: en_carga_63=%d veto=%d" % [_b_en_carga, _b_veto])
	print("-- C: delta_ops=%d" % _c_delta_ops)
	print("-- D: muestras_pump=%d" % _d_muestras)
	print("-- E: ciclos_ok=%d/%d copias=%d nulas=%d reusos=%d recargas=%d control=%d" % [
		_e_ciclos, CICLOS, _e_copias, _e_nulas, _e_reusos, _e_recargas, _e_control])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
