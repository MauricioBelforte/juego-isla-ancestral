# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-18
#
# M62: Memoria — Suite de colliders estáticos de chunks (pin del ítem L139).
# Cierra por MEDICIÓN el ítem de reposición del backlog:
#   "Colliders estáticos de chunks descargados se liberan junto con la mesh [M]"
#
# Qué mide (headless, autoloads REALES MemoryMonitor + StreamManager):
#   A. Sonda del medidor (control positivo anti-vacuo): los colliders REALES de
#      un chunk voxel (ConcavePolygonShape3D de Mesh.create_trimesh_shape(),
#      payload medido en out/tanda62/probe1.log) viven y mueren de forma
#      determinista (WeakRef) y objetos_vivos() los CUENTA.
#   B. Par {mesh + collider} por chunk: 12 pares encolados por
#      registrar_candidato_descarga (el ensanche T61 los acepta: Resource viaja
#      como RefCounted) se liberan al drenar: 0/24 sobrevivientes (WeakRef).
#   C. Sin acumulación: 5 ciclos x 10 pares drenados; 0 retenidos y delta de
#      objetos_vivos == 0.
#   D. "Junto con la mesh" (evento de descarga único): el mesh del chunk viaja
#      por la vía real M63 (registrar_chunk + liberar_envejecidos) y su collider
#      por la cola directa; tras el MISMO evento ambos mueren (0/2). Además, la
#      forma NODO del collider estático (StaticBody3D + CollisionShape3D) no
#      deja huérfanos al liberar el cuerpo.
#
# Alcance (honesto): el cableado de producción es deuda de M08: quien creará el
# collider por chunk (create_trimesh_shape + StaticBody3D) y lo registrará vía
# registrar_candidato_descarga() es el futuro ChunkMemory de M08 (04-Codigo
# §M08). El VoxelTerrain real gestiona sus colliders internos en C++ y no los
# expone por chunk en GDScript. Esta suite pina el contrato del 62: "si el
# collider del chunk está registrado como candidato, la descarga lo libera
# junto con la mesh, sin residuo".
#
# Guardián anti-falso-verde de 3 capas:
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_colliders_chunk.gd

extends SceneTree

const MODULO := "M62 colliders chunk"
const BLOQUES: Array[String] = ["A", "B", "C", "D"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md §14 / evidencia Tanda 62).
const CHECKS_MINIMOS := 21

const PESO_MALLA_MB := 4     ## semántica PESOS.malla_region = 4.0
const PESO_COLLIDER_MB := 1  ## semántica PESOS.chunk_lod0 = 1.0
const PARES_DESCARGA := 12
const CICLOS := 5
const PARES_POR_CICLO := 10

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
var _orph_d: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Colliders estáticos de chunks: liberación junto con la mesh (L139) ===")
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


## ── A. Sonda del medidor: el collider real cuenta y muere ────────────────────
func _bloque_a(mm: Node) -> void:
	print("--- A. Sonda del medidor (control positivo anti-vacuo) ---")
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la cola de descarga arranca drenada",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	var base: int = mm.objetos_vivos()
	var lote: Array[ConcavePolygonShape3D] = []
	var deb: Array[WeakRef] = []
	for _i in 8:
		var forma: ConcavePolygonShape3D = BoxMesh.new().create_trimesh_shape()
		lote.append(forma)
		deb.append(weakref(forma))
	var f0: ConcavePolygonShape3D = lote[0]
	_check("las formas son ConcavePolygonShape3D reales (trimesh con caras)",
		f0.get_class() == "ConcavePolygonShape3D" and f0.get_faces().size() >= 36,
		"clase=%s caras=%d" % [f0.get_class(), f0.get_faces().size()])
	f0 = null
	_check("el medidor las VE: 8 vivas y objetos_vivos >= base+8",
		_vivos(deb) == 8 and mm.objetos_vivos() >= base + 8,
		"vivos=%d objetos=%d base=%d" % [_vivos(deb), mm.objetos_vivos(), base])
	lote.clear()
	_check("soltar las referencias las libera de forma determinista (0/8)",
		_vivos(deb) == 0, "vivos=%d" % _vivos(deb))
	deb.clear()
	_check("objetos_vivos vuelve a la base (sin residuo)",
		mm.objetos_vivos() <= base, "fin=%d base=%d" % [mm.objetos_vivos(), base])
	_fin("A")


## ── B. Par {mesh + collider} por chunk: 12 pares drenados ────────────────────
func _bloque_b(mm: Node) -> void:
	print("--- B. Par {mesh + collider} por chunk (registrar_candidato_descarga) ---")
	var base: int = mm.objetos_vivos()
	var deb: Array[WeakRef] = []
	var mallas: Array[Mesh] = []
	var formas: Array[ConcavePolygonShape3D] = []
	for i in PARES_DESCARGA:
		var malla := BoxMesh.new()
		var forma: ConcavePolygonShape3D = malla.create_trimesh_shape()
		mallas.append(malla)
		formas.append(forma)
		deb.append(weakref(malla))
		deb.append(weakref(forma))
		mm.registrar_candidato_descarga(malla, PESO_MALLA_MB, 100.0 - float(i))
		mm.registrar_candidato_descarga(forma, PESO_COLLIDER_MB, 100.0 - float(i))
	mallas.clear()
	formas.clear()
	_cola_b = mm.unload.candidatos_count()
	_check("los %d pares quedaron encolados como candidatos (2 por chunk)" % PARES_DESCARGA,
		_cola_b == PARES_DESCARGA * 2, "cola=%d" % _cola_b)
	_lib_b = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la descarga drena los %d pares (%d MB: %d por malla + %d por collider)" % [
			PARES_DESCARGA, PARES_DESCARGA * (PESO_MALLA_MB + PESO_COLLIDER_MB),
			PESO_MALLA_MB, PESO_COLLIDER_MB],
		_lib_b == PARES_DESCARGA * (PESO_MALLA_MB + PESO_COLLIDER_MB), "lib=%d" % _lib_b)
	_check("cola vacía tras la descarga",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_vivos_b = _vivos(deb)
	_check("NINGUNO de los %d sobrevive a la descarga (WeakRef de malla y collider)" % (PARES_DESCARGA * 2),
		_vivos_b == 0, "vivos=%d" % _vivos_b)
	deb.clear()
	_check("objetos_vivos no creció con el ciclo completo (fin <= base)",
		mm.objetos_vivos() <= base, "fin=%d base=%d" % [mm.objetos_vivos(), base])
	_fin("B")


## ── C. Sin acumulación: 5 ciclos x 10 pares ──────────────────────────────────
func _bloque_c(mm: Node) -> void:
	print("--- C. Sin acumulación: %d ciclos x %d pares ---" % [CICLOS, PARES_POR_CICLO])
	var base: int = mm.objetos_vivos()
	_ciclos_ok = 0
	_vivos_c = 0
	for ciclo in CICLOS:
		var deb: Array[WeakRef] = []
		var mallas: Array[Mesh] = []
		var formas: Array[ConcavePolygonShape3D] = []
		for _i in PARES_POR_CICLO:
			var malla := BoxMesh.new()
			var forma: ConcavePolygonShape3D = malla.create_trimesh_shape()
			mallas.append(malla)
			formas.append(forma)
			deb.append(weakref(malla))
			deb.append(weakref(forma))
			mm.registrar_candidato_descarga(malla, PESO_MALLA_MB, 60.0 + float(ciclo))
			mm.registrar_candidato_descarga(forma, PESO_COLLIDER_MB, 60.0 + float(ciclo))
		mallas.clear()
		formas.clear()
		var lib: int = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
		var vivos: int = _vivos(deb)
		_vivos_c += vivos
		deb.clear()
		var fin: int = mm.objetos_vivos()
		var cola: int = mm.unload.candidatos_count()
		if lib == PARES_POR_CICLO * (PESO_MALLA_MB + PESO_COLLIDER_MB) and vivos == 0 and cola == 0 and fin <= base:
			_ciclos_ok += 1
		print("  ciclo %d: lib=%d vivos=%d cola=%d objetos_fin=%d" % [ciclo, lib, vivos, cola, fin])
	_check("los %d ciclos drenaron limpio (%d pares por ciclo, 0 retenidos)" % [CICLOS, PARES_POR_CICLO],
		_ciclos_ok == CICLOS, "ciclos_ok=%d" % _ciclos_ok)
	_check("%d WeakRefs acumuladas: 0 retenidas (sin acumulación)" % (CICLOS * PARES_POR_CICLO * 2),
		_vivos_c == 0, "vivos=%d" % _vivos_c)
	_check("delta global de objetos_vivos == 0 (fin <= base)",
		mm.objetos_vivos() <= base, "fin=%d base=%d" % [mm.objetos_vivos(), base])
	_fin("C")


## ── D. "Junto con la mesh": evento único + forma NODO del collider ───────────
func _bloque_d(mm: Node, sm: Node) -> void:
	print("--- D. Evento de descarga único (mesh vía M63 + collider directo) ---")
	var rec: Resource = Resource.new()
	var deb: Array[WeakRef] = []
	deb.append(weakref(rec))
	sm.registrar_chunk("t62_regD/c0", 120.0, rec)
	var forma: ConcavePolygonShape3D = BoxMesh.new().create_trimesh_shape()
	deb.append(weakref(forma))
	mm.registrar_candidato_descarga(forma, PESO_COLLIDER_MB, 80.0)
	forma = null
	_cola_d = mm.unload.candidatos_count()
	_check("cola mixta: mesh del 63 + collider directo = 2",
		_cola_d == 2, "n=%d" % _cola_d)
	_lib_d = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("el drenaje consume ambos y deja la cola vacía",
		_lib_d == PESO_COLLIDER_MB + 1 and mm.unload.candidatos_count() == 0,
		"lib=%d cola=%d" % [_lib_d, mm.unload.candidatos_count()])
	rec = null
	sm.marcar_envejecidos(0.0)
	sm.marcar_envejecidos(0.0)
	_libsm_d = sm.liberar_envejecidos()
	_check("el mesh del 63 se libera con liberar_envejecidos (1)",
		_libsm_d == 1, "libsm=%d" % _libsm_d)
	_vivos_d = _vivos(deb)
	_check("mesh y collider mueren en el MISMO evento de descarga (0/2 vivos)",
		_vivos_d == 0, "vivos=%d" % _vivos_d)
	deb.clear()
	# Forma NODO del collider estático (el uso clásico: cuerpo + shape por chunk).
	var base_orph: int = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	var cuerpo := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = BoxMesh.new().create_trimesh_shape()
	cuerpo.add_child(cs)
	var con_orph: int = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	_check("el collider NODO (StaticBody3D + CollisionShape3D) se cuenta como huérfano (2 nodos)",
		con_orph >= base_orph + 2, "base=%d con=%d" % [base_orph, con_orph])
	cuerpo.free()
	cs = null
	cuerpo = null
	_orph_d = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	_check("liberar el cuerpo libera el collider sin huérfanos (vuelve a la base)",
		_orph_d <= base_orph, "base=%d fin=%d" % [base_orph, _orph_d])
	_fin("D")


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
	print("-- B: cola=%d drenados=%d vivos=%d" % [_cola_b, _lib_b, _vivos_b])
	print("-- C: ciclos_ok=%d/%d vivos_acum=%d" % [_ciclos_ok, CICLOS, _vivos_c])
	print("-- D: cola=%d drenados=%d libsm=%d vivos=%d orph_fin=%d" % [_cola_d, _lib_d, _libsm_d, _vivos_d, _orph_d])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
