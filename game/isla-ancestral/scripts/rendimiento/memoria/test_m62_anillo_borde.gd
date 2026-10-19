# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-19
#
# M62: Memoria — Suite "Al mover el anillo (M12/M63) se descargan los chunks
# del borde antes de cargar nuevos" (pin del ítem L143 del 05-Checklist M62).
# Requerimiento de origen: el anillo de carga es M12 (zoom/posición de cámara)
# -> M63 aplica §4: los chunks fuera de rango se marcan envejecidos
# (distancia > r_max + 1.0, gracia de 2 frames) y `liberar_envejecidos` los
# suelta (más lejanos primero, silencioso). La invariante del ítem es de ORDEN:
# al mover el anillo, el borde se DESCARGA antes de cargar los nuevos.
#
# Contrato que pina (headless, autoloads REALES MemoryMonitor + StreamManager):
#   A. EL ANILLO MARCA SU BORDE (§4): con r_max dado, el borde (> r_max+1) se
#      libera EXACTAMENTE tras 2 marcas; una sola marca NO libera (gracia);
#      la frontera es ESTRICTA (r_max+1.0 exacto queda; r_max+1.5 sale); el
#      interior no se toca; liberar es idempotente; descargas_total +borde.
#   B. INVARIANTE DEL ÍTEM (borde antes que nuevos): anillo A (5 interior +
#      4 borde) -> el 62 drena su cola -> se mueve el anillo (r 100->60) ->
#      el borde (4) se descarga (0/4 vivos, libro del 63 cerrado); RECIÉN
#      ENTONCES entran los chunks nuevos (4). Sin convivencia borde-viejo +
#      anillo-nuevo; el interior (5) sobrevive al movimiento.
#   C. CONTROL ANTI-FALSO-VERDE: gracia (1 marca = 0 liberados); frontera
#      estricta (61.0 == r_max+1 queda, 61.5 sale); el chunk que sale del
#      anillo y VUELVE no se descarga (el contador se resetea, §4).
#   D. VÍA REAL 63->62 CON RECURSO: el chunk de borde con Resource llega como
#      candidato al 62; el 62 decide y drena; al mover el anillo el 63 cierra
#      su libro (1) y el payload muere (0/1 vivos). Estado final limpio.
#   E. CICLO COMPLETO: 2 movimientos consecutivos (r200 -> r100); cada
#      movimiento descarga SU borde (2 y 2, incluido el chunk recién cargado
#      que quedó fuera) y deja 3 activos = 3 vivos; balance <= base+3
#      (sin acumulación entre movimientos).
#
# Alcance (honesto): el CALLER de producción del movimiento del anillo
# (M12 zoom -> M63 aplicar r_max) todavía no está cableado en el repo; esta
# suite pina el contrato del mecanismo de descarga del borde del 62/63 y la
# secuencia canónica que lo cumple (marcar x2 -> liberar -> recién registrar
# nuevos), igual que L137/139/140/141/142 con sus dueños. El cableado M12/M63
# sigue siendo deuda de esos módulos.
#
# Guardián anti-falso-verde de 3 capas:
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_anillo_borde.gd

extends SceneTree

const MODULO := "M62 anillo/borde al mover (L143)"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md / evidencia Tanda 66).
const CHECKS_MINIMOS := 24

const PESO_CHUNK_MB := 1   ## chunk_lod0 = 1.0 (M63 §4)
const R_MAX_A := 100.0
const R_MAX_B := 60.0

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Diagnóstico del resumen (auditoría sin re-correr).
var _a_lib: int = -1
var _a_interior: int = -1
var _b_lib: int = -1
var _b_vivos: int = -1
var _c_gracia: int = -1
var _c_frontera: int = -1
var _d_lib: int = -1
var _d_vivos: int = -1
var _e_lib1: int = -1
var _e_lib2: int = -1
var _e_final: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Anillo/borde: al mover el anillo se descarga el borde antes de cargar nuevos (L143) ===")
	var mm := _mm()
	if mm == null:
		_check("autoload MemoryMonitor presente", false, "mm=null")
		return
	_check("autoload MemoryMonitor presente", true)
	var sm := _sm()
	_check("autoload StreamManager presente (vía real M63)", sm != null, "sm=null")
	if sm == null:
		return
	_bloque_a(sm)
	_bloque_b(mm, sm)
	_bloque_c(sm)
	_bloque_d(mm, sm)
	_bloque_e(mm, sm)


## ── A. El anillo marca su borde (§4: r_max+1 estricto, gracia 2 frames) ──────
func _bloque_a(sm: Node) -> void:
	print("--- A. El anillo marca su borde (§4) ---")
	var ids_int: Array[String] = ["t66_a/i10", "t66_a/i40", "t66_a/i90", "t66_a/i101"]
	var d_int: Array[float] = [10.0, 40.0, 90.0, 101.0]   ## 101.0 == r_max+1.0 exacto
	var ids_bor: Array[String] = ["t66_a/b101", "t66_a/b150", "t66_a/b300"]
	var d_bor: Array[float] = [101.5, 150.0, 300.0]
	for i in ids_int.size():
		sm.registrar_chunk(ids_int[i], d_int[i])
	for i in ids_bor.size():
		sm.registrar_chunk(ids_bor[i], d_bor[i])
	_check("anillo armado: 7 chunks activos (4 interior + 3 borde)",
		sm.chunks_activos() == 7, "activos=%d" % sm.chunks_activos())
	var d0: int = sm.descargas_total()
	sm.marcar_envejecidos(R_MAX_A)
	var lib1: int = sm.liberar_envejecidos()
	_check("una sola marca NO libera (gracia de 2 frames, §4)",
		lib1 == 0 and sm.chunks_activos() == 7, "lib=%d activos=%d" % [lib1, sm.chunks_activos()])
	sm.marcar_envejecidos(R_MAX_A)
	_a_lib = sm.liberar_envejecidos()
	_check("dos marcas liberan EXACTAMENTE el borde (3)",
		_a_lib == 3, "lib=%d" % _a_lib)
	_a_interior = sm.chunks_activos()
	var int_ok := true
	for cid in ids_int:
		if not sm.chunk_activo(cid):
			int_ok = false
	var bor_ok := true
	for cid in ids_bor:
		if sm.chunk_activo(cid):
			bor_ok = false
	_check("frontera estricta: el interior sobrevive (4: 10/40/90/101.0) y el borde se fue",
		_a_interior == 4 and int_ok and bor_ok, "activos=%d" % _a_interior)
	var lib2: int = sm.liberar_envejecidos()
	_check("liberar de nuevo es idempotente (0)",
		lib2 == 0, "lib2=%d" % lib2)
	_check("descargas_total subió exactamente el borde (3)",
		sm.descargas_total() - d0 == 3, "delta=%d" % (sm.descargas_total() - d0))
	# Limpieza del bloque (sin check): vaciar el libro del 63.
	sm.marcar_envejecidos(-1.0)
	sm.marcar_envejecidos(-1.0)
	sm.liberar_envejecidos()
	_fin("A")


## ── B. Invariante del ítem: borde descargado ANTES de cargar los nuevos ──────
func _bloque_b(mm: Node, sm: Node) -> void:
	print("--- B. Borde descargado ANTES de cargar nuevos ---")
	var base: int = mm.objetos_vivos()
	var ids_int: Array[String] = ["t66_b/i20", "t66_b/i30", "t66_b/i40", "t66_b/i50", "t66_b/i60"]
	var d_int: Array[float] = [20.0, 30.0, 40.0, 50.0, 60.0]         ## quedan dentro de r60
	var ids_bor: Array[String] = ["t66_b/b120", "t66_b/b180", "t66_b/b240", "t66_b/b300"]
	var ids_new: Array[String] = ["t66_b/n10", "t66_b/n26", "t66_b/n42", "t66_b/n58"]
	var deb_int: Array[WeakRef] = []
	var deb_bor: Array[WeakRef] = []
	var deb_new: Array[WeakRef] = []
	var rec: Resource = null
	for i in ids_int.size():
		rec = Resource.new()
		deb_int.append(weakref(rec))
		sm.registrar_chunk(ids_int[i], d_int[i], rec)
	rec = null
	for i in ids_bor.size():
		rec = Resource.new()
		deb_bor.append(weakref(rec))
		sm.registrar_chunk(ids_bor[i], 120.0 + float(i) * 60.0, rec)
	rec = null
	_check("anillo A: 9 chunks activos (5 interior + 4 borde) y el 62 recibió 9 candidatos",
		sm.chunks_activos() == 9 and mm.unload.candidatos_count() == 9,
		"activos=%d cola=%d" % [sm.chunks_activos(), mm.unload.candidatos_count()])
	var lib62: int = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("el 62 decide y drena su cola (9) antes del movimiento",
		lib62 == 9 and mm.unload.candidatos_count() == 0,
		"lib62=%d cola=%d" % [lib62, mm.unload.candidatos_count()])
	# Mover el anillo: r 100 -> 60. Borde real = > 61.0 (120..300).
	sm.marcar_envejecidos(R_MAX_B)
	sm.marcar_envejecidos(R_MAX_B)
	_b_lib = sm.liberar_envejecidos()
	_check("al mover el anillo se descarga EXACTAMENTE su borde (4)",
		_b_lib == 4, "libb=%d" % _b_lib)
	var vivos_bor: int = _vivos(deb_bor)
	var vivos_int: int = _vivos(deb_int)
	_b_vivos = vivos_bor
	_check("el borde se descargó ANTES de cargar: 0/4 vivos del borde y 5/5 del interior",
		vivos_bor == 0 and vivos_int == 5, "borde=%d interior=%d" % [vivos_bor, vivos_int])
	for i in ids_new.size():
		rec = Resource.new()
		deb_new.append(weakref(rec))
		sm.registrar_chunk(ids_new[i], 10.0 + float(i) * 16.0, rec)
	rec = null
	var borde_activo := false
	for cid in ids_bor:
		if sm.chunk_activo(cid):
			borde_activo = true
	var vivos_new: int = _vivos(deb_new)
	_check("recién entonces cargan los nuevos: activos = 5 interior + 4 nuevos",
		sm.chunks_activos() == 9 and not borde_activo and vivos_new == 4,
		"activos=%d borde_activo=%s nuevos=%d" % [sm.chunks_activos(), str(borde_activo), vivos_new])
	# Los WeakRef wrappers cuentan en objetos_vivos: soltarlos antes del balance.
	deb_int.clear()
	deb_bor.clear()
	deb_new.clear()
	_check("sin convivencia borde-viejo + anillo-nuevo: 0 vivos del borde y total <= base+9",
		vivos_bor == 0 and mm.objetos_vivos() <= base + 9,
		"vivos_bor=%d fin=%d base=%d" % [vivos_bor, mm.objetos_vivos(), base])
	# Limpieza del bloque (sin check).
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	sm.marcar_envejecidos(-1.0)
	sm.marcar_envejecidos(-1.0)
	sm.liberar_envejecidos()
	_fin("B")


## ── C. Gracia + frontera estricta + reset del que vuelve (anti-falso-verde) ──
func _bloque_c(sm: Node) -> void:
	print("--- C. Gracia, frontera estricta y reset al volver ---")
	sm.registrar_chunk("t66_c/exacto", 61.0)   ## == r_max + 1.0 exacto
	sm.registrar_chunk("t66_c/borde", 61.5)
	sm.registrar_chunk("t66_c/reset", 50.0)
	sm.marcar_envejecidos(R_MAX_B)
	_c_gracia = sm.liberar_envejecidos()
	_check("una sola marca NO libera nada (gracia de 2 frames, §4)",
		_c_gracia == 0 and sm.chunks_activos() == 3, "lib=%d activos=%d" % [_c_gracia, sm.chunks_activos()])
	sm.marcar_envejecidos(R_MAX_B)
	_c_frontera = sm.liberar_envejecidos()
	_check("frontera estricta: 61.0 (== r_max+1) queda; 61.5 sale (1)",
		_c_frontera == 1 and sm.chunk_activo("t66_c/exacto") and not sm.chunk_activo("t66_c/borde"),
		"lib=%d" % _c_frontera)
	# El que sale del anillo y VUELVE: marca fuera (r30) x2 y vuelve (r60) x2.
	sm.marcar_envejecidos(30.0)
	sm.marcar_envejecidos(30.0)
	sm.marcar_envejecidos(R_MAX_B)
	sm.marcar_envejecidos(R_MAX_B)
	var lib_reset: int = sm.liberar_envejecidos()
	_check("el chunk que vuelve al anillo NO se descarga (contador reset §4)",
		lib_reset == 0 and sm.chunk_activo("t66_c/reset"),
		"lib=%d activo=%s" % [lib_reset, str(sm.chunk_activo("t66_c/reset"))])
	# Limpieza del bloque (sin check).
	sm.marcar_envejecidos(-1.0)
	sm.marcar_envejecidos(-1.0)
	sm.liberar_envejecidos()
	_fin("C")


## ── D. Vía real 63->62 con recurso: el 62 drena, luego el 63 cierra ──────────
func _bloque_d(mm: Node, sm: Node) -> void:
	print("--- D. Vía real 63->62 con recurso ---")
	var base: int = mm.objetos_vivos()
	var deb: Array[WeakRef] = []
	var rec: Resource = Resource.new()
	deb.append(weakref(rec))
	sm.registrar_chunk("t66_d/b120", 120.0, rec)
	rec = null
	_check("chunk de borde con recurso: activo en el 63 (1) y candidato en el 62 (1)",
		sm.chunks_activos() == 1 and mm.unload.candidatos_count() == 1,
		"activos=%d cola=%d" % [sm.chunks_activos(), mm.unload.candidatos_count()])
	var lib62: int = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("el 62 drena su decisión antes del movimiento (1)",
		lib62 == 1 and mm.unload.candidatos_count() == 0,
		"lib62=%d cola=%d" % [lib62, mm.unload.candidatos_count()])
	sm.marcar_envejecidos(R_MAX_B)
	sm.marcar_envejecidos(R_MAX_B)
	_d_lib = sm.liberar_envejecidos()
	_d_vivos = _vivos(deb)
	_check("al mover el anillo el 63 cierra su libro y el payload muere (1 liberado, 0/1 vivos)",
		_d_lib == 1 and _d_vivos == 0, "lib=%d vivos=%d" % [_d_lib, _d_vivos])
	deb.clear()
	_check("estado final: sin chunks activos y balance <= base",
		sm.chunks_activos() == 0 and mm.objetos_vivos() <= base,
		"activos=%d fin=%d base=%d" % [sm.chunks_activos(), mm.objetos_vivos(), base])
	_fin("D")


## ── E. Ciclo completo: 2 movimientos consecutivos del anillo ────────────────
func _bloque_e(mm: Node, sm: Node) -> void:
	print("--- E. Ciclo completo: 2 movimientos consecutivos ---")
	var base: int = mm.objetos_vivos()
	var ids: Array[String] = ["t66_e/c50", "t66_e/c90", "t66_e/c120", "t66_e/c220", "t66_e/c250"]
	var dist: Array[float] = [50.0, 90.0, 120.0, 220.0, 250.0]
	var deb: Array[WeakRef] = []
	var rec: Resource = null
	for i in ids.size():
		rec = Resource.new()
		deb.append(weakref(rec))
		sm.registrar_chunk(ids[i], dist[i], rec)
	rec = null
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	# Movimiento 1: el anillo pasa a r200 -> borde > 201: c220 y c250.
	sm.marcar_envejecidos(200.0)
	sm.marcar_envejecidos(200.0)
	_e_lib1 = sm.liberar_envejecidos()
	rec = Resource.new()
	deb.append(weakref(rec))
	sm.registrar_chunk("t66_e/n150", 150.0, rec)
	rec = null
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("movimiento 1 (r200): descarga su borde (2) y el nuevo n150 entra al anillo",
		_e_lib1 == 2 and sm.chunk_activo("t66_e/n150"), "lib1=%d" % _e_lib1)
	# Movimiento 2: el anillo pasa a r100 -> borde > 101: c120 y n150.
	sm.marcar_envejecidos(100.0)
	sm.marcar_envejecidos(100.0)
	_e_lib2 = sm.liberar_envejecidos()
	rec = Resource.new()
	deb.append(weakref(rec))
	sm.registrar_chunk("t66_e/n95", 95.0, rec)
	rec = null
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("movimiento 2 (r100): descarga su borde (2: c120 + n150) y entra n95",
		_e_lib2 == 2 and sm.chunk_activo("t66_e/n95") and not sm.chunk_activo("t66_e/n150"),
		"lib2=%d" % _e_lib2)
	_e_final = _vivos(deb)
	deb.clear()
	_check("tras 2 movimientos: 3 activos = 3 vivos (c50, c90, n95) y balance <= base+3",
		sm.chunks_activos() == 3 and _e_final == 3 and mm.objetos_vivos() <= base + 3,
		"activos=%d vivos=%d fin=%d" % [sm.chunks_activos(), _e_final, mm.objetos_vivos()])
	# Limpieza del bloque (sin check).
	sm.marcar_envejecidos(-1.0)
	sm.marcar_envejecidos(-1.0)
	sm.liberar_envejecidos()
	_fin("E")


## ── Utilidades ───────────────────────────────────────────────────────────────

func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


func _sm() -> Node:
	return root.get_node_or_null("StreamManager")


## Cuántos de los WeakRef siguen vivos (=> el objeto fue RETENIDO por alguien).
func _vivos(deb: Array[WeakRef]) -> int:
	var n := 0
	for w in deb:
		if (w as WeakRef).get_ref() != null:
			n += 1
	return n


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
	print("-- A: lib=%d interior=%d" % [_a_lib, _a_interior])
	print("-- B: lib=%d vivos_borde=%d" % [_b_lib, _b_vivos])
	print("-- C: gracia=%d frontera=%d" % [_c_gracia, _c_frontera])
	print("-- D: lib=%d vivos=%d" % [_d_lib, _d_vivos])
	print("-- E: lib1=%d lib2=%d final=%d" % [_e_lib1, _e_lib2, _e_final])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
