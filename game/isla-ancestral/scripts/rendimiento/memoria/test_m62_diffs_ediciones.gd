# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-19
#
# M62: Memoria — Suite "Los diffs y ediciones del jugador (M08) no retienen
# historial infinito en RAM" (pin del ítem L142 del 05-Checklist M62).
# Requerimiento de origen: M08 (08-Mundo-Voxel plan-actual 04-Codigo §2):
# los diffs por chunk son el ESTADO del chunk (tabla isla/chunk/ediciones),
# no un op-log infinito; el camino real de producción es tool_controller.gd
# (try_place/_extraer_voxel -> UNA escritura `do_point` por edición).
#
# Contrato que pina (headless, autoloads REALES MemoryMonitor + StreamManager):
#   A. SONDA + EDICIÓN REAL SOBRE EL PAYLOAD (control positivo anti-vacuo):
#      los VoxelBuffer por chunk aceptan ediciones (escrituras de voxel), el
#      medidor los CUENTA (objetos_vivos) y mueren de forma determinista
#      (WeakRef) al soltar la referencia. La edición se LEE de vuelta: la
#      sonda no es vacua.
#   B. CONTRATO DE FUENTE DEL CAMINO DE PRODUCCIÓN (M08): tool_controller.gd
#      edita con `do_point` (una escritura), NO usa writes de área, y NO
#      contiene NINGUNA estructura de historial por edición (_historial,
#      edit_log, undo/redo, diff_store...). Sin historial en la fuente = el
#      RAM por edición no crece en GDScript; lo editado vive en el payload
#      del chunk (estado), no en una lista que solo crece.
#   C. SIN ACUMULACIÓN: 5 ciclos x 10 chunks editados (payload + ediciones)
#      registrados en la cola de descarga del 62 y drenados: 0 retenidos por
#      ciclo, delta global de objetos_vivos 0. Retener 1 por ciclo daría >= 5.
#   D. VÍA REAL M63 MIXTA: payload editado (RefCounted, cola del 62) +
#      Resource del stream (registrar_chunk -> auto-registro en el 62) en la
#      misma descarga; el libro del 63 se cierra con marcar_envejecidos +
#      liberar_envejecidos. Regresión del ensanche Resource -> RefCounted
#      (T61, Log 2001).
#   E. CONTROL POSITIVO AUTOCONTENIDO + BALANCE GLOBAL: 2 payloads editados
#      retenidos por variables propias DEBEN verse vivos (si el detector
#      dijera 0, todo "0 retenidos" anterior sería falso); al soltarlos, el
#      balance global vuelve a la base de A (sin historial infinito).
#
# Alcance (honesto): VoxelToolBuffer NO es construible desde GDScript en este
# build de voxel-tools (sondas Tanda 65: class_exists=true pero
# can_instantiate=false, new(vb) no bindeado [Parse Error "Too many
# arguments"], ClassDB.instantiate=null), así que la edición se simula como
# escrituras de voxel directas sobre el payload por-chunk — el MISMO estado
# que el chunk guarda. El write real de producción (`do_point`) se pina desde
# fuente en B. El VoxelTerrain real gestiona sus buffers internos en C++ y no
# los expone por chunk en GDScript: esta suite pina el contrato M62 igual que
# L137 (test_m62_voxel_buffers.gd, T61).
#
# Guardián anti-falso-verde de 3 capas:
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_diffs_ediciones.gd

extends SceneTree

const MODULO := "M62 diffs/ediciones del jugador (L142)"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md §17 / evidencia Tanda 65).
const CHECKS_MINIMOS := 24

const TOOL_CONTROLLER := "res://scripts/tools/tool_controller.gd"
const PESO_CHUNK_MB := 1   ## mismo peso que M63 asigna por chunk (chunk_lod0 = 1.0)
const EDICIONES := 8       ## ediciones por payload (burst de jugador)
const CICLOS := 5
const CHUNKS_POR_CICLO := 10

## Patrones de historial que NO deben existir en el camino de edición (B).
const PATRONES_HISTORIAL: Array[String] = [
	"_historial", "historial_ediciones", "edit_log", "log_ediciones",
	"op_log", "undo_stack", "redo_stack", "diff_store",
]

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Diagnóstico del resumen (auditoría sin re-correr).
var _a_edits_ok: int = -1
var _a_medidor: int = -1
var _b_do_point: int = -1
var _b_historial: int = -1
var _c_ciclos: int = -1
var _c_vivos: int = -1
var _d_lib63: int = -1
var _d_vivos: int = -1
var _e_control: int = -1
var _e_global: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Diffs/ediciones del jugador (M08): sin historial infinito en RAM (L142) ===")
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
	_bloque_b()
	_bloque_c(mm)
	_bloque_d(mm, sm)
	_bloque_e(mm)


## ── A. Sonda + edición real sobre el payload (control anti-vacuo) ────────────
func _bloque_a(mm: Node) -> void:
	print("--- A. Sonda del medidor + edición real sobre el payload ---")
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la cola de descarga arranca drenada",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	var base: int = mm.objetos_vivos()
	var lote: Array[VoxelBuffer] = []
	var deb: Array[WeakRef] = []
	for _i in 3:
		var vb := _vb_editado()
		lote.append(vb)
		deb.append(weakref(vb))
	var b0: VoxelBuffer = lote[0]
	_a_edits_ok = 0
	if b0.get_voxel(EDICIONES - 1, EDICIONES - 1, EDICIONES - 1, VoxelBuffer.CHANNEL_TYPE) == _valor_edicion(EDICIONES - 1):
		_a_edits_ok += 1
	if b0.get_voxel(0, 0, 0, VoxelBuffer.CHANNEL_TYPE) == _valor_edicion(0):
		_a_edits_ok += 1
	_check("las %d ediciones del payload se leen de vuelta (sonda no vacua)" % EDICIONES,
		_a_edits_ok == 2, "edits_ok=%d" % _a_edits_ok)
	b0 = null
	_a_medidor = _vivos(deb)
	_check("el medidor los VE: 3 payloads editados vivos y objetos_vivos >= base+3",
		_a_medidor == 3 and mm.objetos_vivos() >= base + 3,
		"vivos=%d objetos=%d base=%d" % [_a_medidor, mm.objetos_vivos(), base])
	lote.clear()
	_check("soltar las referencias los libera de forma determinista (0/3)",
		_vivos(deb) == 0, "vivos=%d" % _vivos(deb))
	deb.clear()
	_check("objetos_vivos vuelve a la base (sin residuo)",
		mm.objetos_vivos() <= base, "fin=%d base=%d" % [mm.objetos_vivos(), base])
	_fin("A")


## ── B. Contrato de fuente: el camino de edición no guarda historial ─────────
func _bloque_b() -> void:
	print("--- B. Contrato de fuente (tool_controller.gd) ---")
	var f := FileAccess.open(TOOL_CONTROLLER, FileAccess.READ)
	_check("tool_controller.gd existe y es legible (%s)" % TOOL_CONTROLLER,
		f != null, "FileAccess=null")
	if f == null:
		_fin("B")
		return
	var src := f.get_as_text()
	_check("la fuente tiene contenido (>1000 chars)", src.length() > 1000, "n=%d" % src.length())
	_b_do_point = src.count("do_point(")
	_check("edita con do_point (una escritura por acción): >=2 usos",
		_b_do_point >= 2, "do_point=%d" % _b_do_point)
	_check("sin writes de área (do_sphere/do_box): cada voxel es una escritura",
		src.count("do_sphere(") == 0 and src.count("do_box(") == 0,
		"sphere=%d box=%d" % [src.count("do_sphere("), src.count("do_box(")])
	var bajas := src.to_lower()
	_b_historial = 0
	var encontrados: Array[String] = []
	for patron in PATRONES_HISTORIAL:
		if bajas.find(patron) != -1:
			_b_historial += 1
			encontrados.append(patron)
	_check("SIN estructuras de historial por edición (%d patrones)" % PATRONES_HISTORIAL.size(),
		_b_historial == 0, "encontrados=%s" % str(encontrados))
	_fin("B")


## ── C. Sin acumulación: 5 ciclos x 10 chunks editados ────────────────────────
func _bloque_c(mm: Node) -> void:
	print("--- C. Sin acumulación: %d ciclos x %d chunks editados ---" % [CICLOS, CHUNKS_POR_CICLO])
	var base: int = mm.objetos_vivos()
	_c_ciclos = 0
	_c_vivos = 0
	for ciclo in CICLOS:
		var deb: Array[WeakRef] = []
		var vb: VoxelBuffer = null
		for _i in CHUNKS_POR_CICLO:
			vb = _vb_editado()
			deb.append(weakref(vb))
			mm.registrar_candidato_descarga(vb, PESO_CHUNK_MB, 60.0 + float(ciclo))
		vb = null
		var lib: int = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
		var vivos: int = _vivos(deb)
		_c_vivos += vivos
		deb.clear()
		var fin: int = mm.objetos_vivos()
		var cola: int = mm.unload.candidatos_count()
		if lib == CHUNKS_POR_CICLO and vivos == 0 and cola == 0 and fin <= base:
			_c_ciclos += 1
		print("  ciclo %d: lib=%d vivos=%d cola=%d objetos_fin=%d" % [ciclo, lib, vivos, cola, fin])
	_check("los %d ciclos drenaron limpio (%d por ciclo, 0 retenidos)" % [CICLOS, CHUNKS_POR_CICLO],
		_c_ciclos == CICLOS, "ciclos_ok=%d" % _c_ciclos)
	_check("%d WeakRefs acumuladas: 0 retenidas (sin acumulación)" % (CICLOS * CHUNKS_POR_CICLO),
		_c_vivos == 0, "vivos=%d" % _c_vivos)
	_check("delta global de objetos_vivos == 0 (fin <= base)",
		mm.objetos_vivos() <= base, "fin=%d base=%d" % [mm.objetos_vivos(), base])
	_fin("C")


## ── D. Vía real M63 mixta: payload editado (62) + Resource del stream ────────
func _bloque_d(mm: Node, sm: Node) -> void:
	print("--- D. Vía real M63 mixta (registrar_chunk + envejecidos) ---")
	var base: int = mm.objetos_vivos()
	var deb: Array[WeakRef] = []
	var payload := _vb_editado()
	deb.append(weakref(payload))
	mm.registrar_candidato_descarga(payload, PESO_CHUNK_MB, 80.0)
	payload = null
	var rec: Resource = Resource.new()
	deb.append(weakref(rec))
	sm.registrar_chunk("t65_regD/c0", 120.0, rec)
	rec = null
	_check("cola mixta: payload editado (62) + chunk del 63 = 2 (%d activo en el 63)" % sm.chunks_activos(),
		mm.unload.candidatos_count() == 2 and sm.chunks_activos() == 1,
		"cola=%d activos=%d" % [mm.unload.candidatos_count(), sm.chunks_activos()])
	var lib: int = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la descarga drena ambos (2 MB) y deja la cola vacía",
		lib == 2 and mm.unload.candidatos_count() == 0,
		"lib=%d cola=%d" % [lib, mm.unload.candidatos_count()])
	sm.marcar_envejecidos(0.0)
	sm.marcar_envejecidos(0.0)
	_d_lib63 = sm.liberar_envejecidos()
	_check("el chunk del 63 se libera con liberar_envejecidos (1)",
		_d_lib63 == 1, "libsm=%d" % _d_lib63)
	_d_vivos = _vivos(deb)
	_check("ambos liberados (0/2 vivos) — el ensanche Resource->RefCounted no rompió la vía",
		_d_vivos == 0, "vivos=%d" % _d_vivos)
	deb.clear()
	_check("chunks_activos vuelve a 0 y objetos_vivos no creció",
		sm.chunks_activos() == 0 and mm.objetos_vivos() <= base,
		"activos=%d fin=%d base=%d" % [sm.chunks_activos(), mm.objetos_vivos(), base])
	_fin("D")


## ── E. Control positivo autocontenido + balance global ───────────────────────
func _bloque_e(mm: Node) -> void:
	print("--- E. Control positivo autocontenido + balance global ---")
	var base: int = mm.objetos_vivos()
	var c1 := _vb_editado()
	var c2 := _vb_editado()
	var deb: Array[WeakRef] = []
	deb.append(weakref(c1))
	deb.append(weakref(c2))
	_e_control = _vivos(deb)
	_check("control: 2 payloads editados RETENIDOS por vars propias -> el detector DEBE ver 2",
		_e_control == 2, "control=%d" % _e_control)
	_check("control: objetos_vivos >= base+2 (el medidor tampoco es ciego)",
		mm.objetos_vivos() >= base + 2, "objetos=%d base=%d" % [mm.objetos_vivos(), base])
	c1 = null
	c2 = null
	_check("control: al soltarlas quedan 0 (liberación real, no fantasma)",
		_vivos(deb) == 0, "vivos=%d" % _vivos(deb))
	deb.clear()
	_e_global = mm.objetos_vivos()
	_check("balance global final <= base del bloque (sin historial infinito)",
		_e_global <= base, "global=%d base=%d" % [_e_global, base])
	_fin("E")


## ── Utilidades ───────────────────────────────────────────────────────────────

func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


func _sm() -> Node:
	return root.get_node_or_null("StreamManager")


## Valor de la k-ésima edición simulada (determinista, != aire).
func _valor_edicion(k: int) -> int:
	return 1 + (k % 5)


## Payload por-chunk con el burst de ediciones del jugador aplicado.
func _vb_editado() -> VoxelBuffer:
	var vb := VoxelBuffer.new()
	vb.create(64, 64, 64)
	for k in EDICIONES:
		vb.set_voxel(_valor_edicion(k), k, k, k, VoxelBuffer.CHANNEL_TYPE)
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
	print("-- A: edits_ok=%d medidor=%d" % [_a_edits_ok, _a_medidor])
	print("-- B: do_point=%d historial=%d" % [_b_do_point, _b_historial])
	print("-- C: ciclos_ok=%d/%d vivos_acum=%d" % [_c_ciclos, CICLOS, _c_vivos])
	print("-- D: libsm=%d vivos=%d" % [_d_lib63, _d_vivos])
	print("-- E: control=%d global=%d" % [_e_control, _e_global])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
