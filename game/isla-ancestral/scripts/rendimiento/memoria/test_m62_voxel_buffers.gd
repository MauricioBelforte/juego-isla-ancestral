# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-19
#
# M62: Memoria — Suite de buffers de VoxelTools por chunk (pin del ítem L137).
# Cierra por MEDICIÓN el ítem de reposición del backlog:
#   "Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación) [C]"
#
# Qué mide (headless, autoloads REALES MemoryMonitor + StreamManager):
#   A. Sonda del medidor (control positivo anti-vacuo): los buffers REALES de
#      voxel-tools (VoxelBuffer 64^3) viven y mueren de forma determinista
#      (WeakRef) y objetos_vivos() los CUENTA; sin esta sonda, cualquier
#      "0 retenidos" de los bloques siguientes sería vacuo.
#   B. Descarga por candidato (L137): 12 buffers registrados por la API que el
#      diseño asigna a M08 (registrar_candidato_descarga, 04-Codigo §M08) se
#      liberan al drenar la cola: 0 sobrevivientes (WeakRef) y objetos_vivos
#      sin crecer.
#   C. Sin acumulación: 5 ciclos x 10 buffers registrados y drenados; el delta
#      de objetos_vivos por ciclo y global es 0 (retener 1 objeto por ciclo
#      daría delta >= 5).
#   D. Mezcla con la vía real M63: el mismo drenaje consume la mezcla
#      (Resource vía StreamManager.registrar_chunk + VoxelBuffer directo).
#      Es la regresión del ensanche Resource -> RefCounted (T61, Log 2001).
#
# Alcance (honesto): el cableado de producción es deuda de M08: quien creará
# los VoxelBuffer por chunk y los registrará vía registrar_candidato_descarga()
# es el futuro ChunkMemory de M08 (04-Codigo §M08). El VoxelTerrain real
# gestiona sus buffers internos en C++ y no los expone por chunk en GDScript.
# Esta suite pina el contrato: "si el buffer está registrado como candidato,
# la descarga lo libera, sin acumulación".
#
# Guardián anti-falso-verde de 3 capas:
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_voxel_buffers.gd

extends SceneTree

const MODULO := "M62 voxel buffers"
const BLOQUES: Array[String] = ["A", "B", "C", "D"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md §13 / evidencia Tanda 61).
const CHECKS_MINIMOS := 19

const PESO_CHUNK_MB := 1  ## mismo peso que M63 asigna por chunk (PESOS.chunk_lod0 = 1.0)
const BUFFERS_DESCARGA := 12
const CICLOS := 5
const BUFFERS_POR_CICLO := 10

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Diagnóstico del resumen (auditoría sin re-correr).
var _cola_b: int = -1
var _lib_b: int = -1
var _vivos_b: int = -1
var _vivos_c: int = -1
var _ciclos_ok: int = -1
var _cola_d: int = -1
var _lib_d: int = -1
var _libsm_d: int = -1
var _vivos_d: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Buffers de VoxelTools por chunk: liberación al descargar (L137) ===")
	var mm := _mm()
	if mm == null:
		_check("autoload MemoryMonitor presente", false, "mm=null")
		return
	_check("autoload MemoryMonitor presente", true)
	var sm := _sm()
	_check("autoload StreamManager presente (vía real M63)", sm != null, "sm=null")
	if sm == null:
		return
	_bloque_a(mm)
	_bloque_b(mm)
	_bloque_c(mm)
	_bloque_d(mm, sm)


## ── A. Sonda del medidor: el VoxelBuffer real cuenta y muere ─────────────────
func _bloque_a(mm: Node) -> void:
	print("--- A. Sonda del medidor (control positivo anti-vacuo) ---")
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la cola de descarga arranca drenada",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	var base: int = mm.objetos_vivos()
	var lote: Array[VoxelBuffer] = []
	var deb: Array[WeakRef] = []
	for _i in 8:
		var b := _vb()
		lote.append(b)
		deb.append(weakref(b))
	var b0: VoxelBuffer = lote[0]
	_check("los buffers son VoxelBuffer reales (64^3, canal TYPE escrito)",
		b0.get_size() == Vector3i(64, 64, 64)
			and b0.get_voxel(3, 4, 5, VoxelBuffer.CHANNEL_TYPE) == 7,
		"size=%s" % str(b0.get_size()))
	b0 = null
	_check("el medidor los VE: 8 vivos y objetos_vivos >= base+8",
		_vivos(deb) == 8 and mm.objetos_vivos() >= base + 8,
		"vivos=%d objetos=%d base=%d" % [_vivos(deb), mm.objetos_vivos(), base])
	lote.clear()
	_check("soltar las referencias los libera de forma determinista (0/8)",
		_vivos(deb) == 0, "vivos=%d" % _vivos(deb))
	deb.clear()
	_check("objetos_vivos vuelve a la base (sin residuo)",
		mm.objetos_vivos() <= base, "fin=%d base=%d" % [mm.objetos_vivos(), base])
	_fin("A")


## ── B. Descarga por candidato: los 12 buffers del chunk mueren ──────────────
func _bloque_b(mm: Node) -> void:
	print("--- B. Descarga por candidato (registrar_candidato_descarga) ---")
	var base: int = mm.objetos_vivos()
	var deb: Array[WeakRef] = []
	var vb: VoxelBuffer = null
	for i in BUFFERS_DESCARGA:
		vb = _vb()
		deb.append(weakref(vb))
		mm.registrar_candidato_descarga(vb, PESO_CHUNK_MB, 100.0 - float(i))
	vb = null
	_cola_b = mm.unload.candidatos_count()
	_check("los %d buffers quedaron encolados como candidatos (L137)" % BUFFERS_DESCARGA,
		_cola_b == BUFFERS_DESCARGA, "cola=%d" % _cola_b)
	_lib_b = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la descarga drena los %d (peso %d MB c/u)" % [BUFFERS_DESCARGA, PESO_CHUNK_MB],
		_lib_b == BUFFERS_DESCARGA, "lib=%d" % _lib_b)
	_check("cola vacía tras la descarga",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_vivos_b = _vivos(deb)
	_check("NINGUNO de los %d sobrevive a la descarga (WeakRef)" % BUFFERS_DESCARGA,
		_vivos_b == 0, "vivos=%d" % _vivos_b)
	deb.clear()
	_check("objetos_vivos no creció con el ciclo completo (fin <= base)",
		mm.objetos_vivos() <= base, "fin=%d base=%d" % [mm.objetos_vivos(), base])
	_fin("B")


## ── C. Sin acumulación: 5 ciclos x 10 buffers ────────────────────────────────
func _bloque_c(mm: Node) -> void:
	print("--- C. Sin acumulación: %d ciclos x %d buffers ---" % [CICLOS, BUFFERS_POR_CICLO])
	var base: int = mm.objetos_vivos()
	_ciclos_ok = 0
	_vivos_c = 0
	for ciclo in CICLOS:
		var deb: Array[WeakRef] = []
		var vb: VoxelBuffer = null
		for _i in BUFFERS_POR_CICLO:
			vb = _vb()
			deb.append(weakref(vb))
			mm.registrar_candidato_descarga(vb, PESO_CHUNK_MB, 60.0 + float(ciclo))
		vb = null
		var lib: int = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
		var vivos: int = _vivos(deb)
		_vivos_c += vivos
		deb.clear()
		var fin: int = mm.objetos_vivos()
		var cola: int = mm.unload.candidatos_count()
		if lib == BUFFERS_POR_CICLO and vivos == 0 and cola == 0 and fin <= base:
			_ciclos_ok += 1
		print("  ciclo %d: lib=%d vivos=%d cola=%d objetos_fin=%d" % [ciclo, lib, vivos, cola, fin])
	_check("los %d ciclos drenaron limpio (%d por ciclo, 0 retenidos)" % [CICLOS, BUFFERS_POR_CICLO],
		_ciclos_ok == CICLOS, "ciclos_ok=%d" % _ciclos_ok)
	_check("%d WeakRefs acumuladas: 0 retenidas (sin acumulación)" % (CICLOS * BUFFERS_POR_CICLO),
		_vivos_c == 0, "vivos=%d" % _vivos_c)
	_check("delta global de objetos_vivos == 0 (fin <= base)",
		mm.objetos_vivos() <= base, "fin=%d base=%d" % [mm.objetos_vivos(), base])
	_fin("C")


## ── D. Mezcla con la vía real M63 (regresión del ensanche T61) ──────────────
func _bloque_d(mm: Node, sm: Node) -> void:
	print("--- D. Mezcla M63 (Resource) + VoxelBuffer en la misma cola ---")
	var rec: Resource = Resource.new()
	var deb: Array[WeakRef] = []
	deb.append(weakref(rec))
	sm.registrar_chunk("t61_regD/c0", 120.0, rec)
	var vb: VoxelBuffer = _vb()
	deb.append(weakref(vb))
	mm.registrar_candidato_descarga(vb, PESO_CHUNK_MB, 80.0)
	vb = null
	_cola_d = mm.unload.candidatos_count()
	_check("cola mixta: Resource del 63 + VoxelBuffer directo = 2",
		_cola_d == 2, "n=%d" % _cola_d)
	_lib_d = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("el drenaje consume ambos (2 MB) y deja la cola vacía",
		_lib_d == 2 and mm.unload.candidatos_count() == 0,
		"lib=%d cola=%d" % [_lib_d, mm.unload.candidatos_count()])
	rec = null
	sm.marcar_envejecidos(0.0)
	sm.marcar_envejecidos(0.0)
	_libsm_d = sm.liberar_envejecidos()
	_check("el chunk del 63 se libera con liberar_envejecidos (1)",
		_libsm_d == 1, "libsm=%d" % _libsm_d)
	_vivos_d = _vivos(deb)
	_check("ambos objetos liberados (0/2 vivos) — el ensanche no rompió la vía Resource",
		_vivos_d == 0, "vivos=%d" % _vivos_d)
	deb.clear()
	_fin("D")


## ── Utilidades ───────────────────────────────────────────────────────────────

func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


func _sm() -> Node:
	return root.get_node_or_null("StreamManager")


## Buffer de voxel REAL (el tipo de voxel-tools que M08 usará por chunk).
func _vb() -> VoxelBuffer:
	var vb := VoxelBuffer.new()
	vb.create(64, 64, 64)
	vb.set_voxel(7, 3, 4, 5, VoxelBuffer.CHANNEL_TYPE)
	return vb


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
	print("-- B: cola=%d drenados=%d vivos=%d" % [_cola_b, _lib_b, _vivos_b])
	print("-- C: ciclos_ok=%d/%d vivos_acum=%d" % [_ciclos_ok, CICLOS, _vivos_c])
	print("-- D: cola=%d drenados=%d libsm=%d vivos=%d" % [_cola_d, _lib_d, _libsm_d, _vivos_d])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
