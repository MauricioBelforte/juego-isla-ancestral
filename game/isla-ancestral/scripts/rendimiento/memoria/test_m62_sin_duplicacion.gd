# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-18
#
# M62: Memoria — Suite "sin duplicación de meshes entre M63 y el 62" (pin L140).
# Cierra por MEDICIÓN el ítem de reposición del backlog:
#   "Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga) [M]"
# Requerimiento de origen: RF5 (01-Requerimientos.md L54): "LRU + pool de
# meshes: liberar ... sin duplicar con M63".
#
# Contrato que pina (headless, autoloads REALES MemoryMonitor + StreamManager):
#   A. IDENTIDAD Y OFERTA ÚNICA: registrar un chunk mueve UNA referencia (no
#      crea objetos nuevos); re-registrar el mismo chunk_id 30 veces (simulación
#      de re-registro por frame) NO infla la cola del 62 (gate `es_nuevo` de
#      registrar_chunk) ni crea copias.
#   B. REEMPLAZO (swap de recurso bajo el mismo chunk_id): el diccionario del 63
#      mantiene UNA entrada; la oferta vieja del 62 se resuelve al drenar (el
#      recurso viejo muere); el nuevo sigue activo. Ventana transitoria acotada:
#      tras el drenaje NO quedan dos mallas vivas del mismo chunk.
#   C. EL 62 NO LIBERA LO DEL 63: drenar la oferta consume la cola y cuenta MB,
#      pero el recurso SIGUE VIVO mientras M63 lo tenga; muere recién con el
#      drop del dueño (liberar_envejecidos). Sin double-free ni colgado.
#   D. VETO (handshake §5.3): el drenaje con el FILTRO DE PRODUCCIÓN
#      (_puede_descargar, el que pasan _enforcement y cambio de región) no
#      descarga un recurso EN CARGA por el 63 (candidato diferido, cola
#      intacta, 0 MB); al terminar la carga se consume. Hallazgo medido: el
#      drenaje directo SIN filtro no veta — el filtro es opt-in del caller y
#      producción siempre lo pasa (verificado en out/tanda63/suite_run1.log).
#   E. CONSERVACIÓN GLOBAL: 5 ciclos x 8 chunks (doble registro + drenaje +
#      liberación) -> cola 0, activos 0, 0 WeakRefs retenidas, delta de
#      objetos_vivos 0.
#
# Alcance (honesto): el llamador de producción de registrar_chunk (chunks reales
# del mundo voxel) sigue siendo deuda de M08/M63; el VoxelTerrain real gestiona
# su streaming en C++. Esta suite pina el contrato del 62: la oferta viaja como
# referencia (misma instancia), una sola vez por chunk, y el drop lo hace el
# dueño (M63), nunca el 62.
#
# Guardián anti-falso-verde de 3 capas:
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_sin_duplicacion.gd

extends SceneTree

const MODULO := "M62 sin duplicación M63/62"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md §15 / evidencia Tanda 63).
const CHECKS_MINIMOS := 33

const PESO_CHUNK_MB := 1   ## semántica PESOS.chunk_lod0 = 1.0 (oferta de registrar_chunk)
const RE_REGISTROS := 30   ## simula re-registro del mismo chunk por ~30 frames
const CICLOS := 5
const CHUNKS_POR_CICLO := 8

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Diagnóstico del resumen (auditoría sin re-correr).
var _a_cola: int = -1
var _a_vivos: int = -1
var _b_swap: int = -1
var _b_old_vivo: int = -1
var _b_new_vivo: int = -1
var _c_lib: int = -1
var _c_queda_vivo: int = -1
var _d_dif: int = -1
var _d_lib: int = -1
var _e_ciclos: int = -1
var _e_vivos: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga) (L140) ===")
	var mm := _mm()
	if mm == null:
		_check("autoload MemoryMonitor presente", false, "mm=null")
		return
	_check("autoload MemoryMonitor presente", true)
	var sm := _sm()
	_check("autoload StreamManager presente (vía real M63)", sm != null, "sm=null")
	if sm == null:
		return
	_bloque_a(mm, sm)
	_bloque_b(mm, sm)
	_bloque_c(mm, sm)
	_bloque_d(mm, sm)
	_bloque_e(mm, sm)


## ── A. Identidad y oferta única: el registro NO clona la mesh ────────────────
func _bloque_a(mm: Node, sm: Node) -> void:
	print("--- A. Identidad y oferta única (re-registro por frame no duplica) ---")
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_a_cola = mm.unload.candidatos_count()
	_check("la cola de descarga arranca drenada",
		_a_cola == 0, "n=%d" % _a_cola)
	var rec: Resource = Resource.new()
	var deb: Array[WeakRef] = []
	deb.append(weakref(rec))
	var vivos_local: int = mm.objetos_vivos()
	sm.registrar_chunk("t63_a/c0", 95.0, rec)
	_check("registrar 1 chunk = 1 activo en el 63 y 1 oferta en el 62",
		sm.chunks_activos() == 1 and mm.unload.candidatos_count() == 1,
		"activos=%d cola=%d" % [sm.chunks_activos(), mm.unload.candidatos_count()])
	_check("el registro NO creó objetos nuevos (la oferta es la MISMA instancia)",
		mm.objetos_vivos() == vivos_local,
		"vivos=%d esperado=%d" % [mm.objetos_vivos(), vivos_local])
	for _i in RE_REGISTROS:
		sm.registrar_chunk("t63_a/c0", 95.0, rec)
	_check("re-registrar el mismo chunk %d veces NO infla la cola del 62" % RE_REGISTROS,
		mm.unload.candidatos_count() == 1, "n=%d" % mm.unload.candidatos_count())
	_check("re-registrar el mismo chunk %d veces sigue con 1 activo" % RE_REGISTROS,
		sm.chunks_activos() == 1, "activos=%d" % sm.chunks_activos())
	_check("%d re-registros sin copias nuevas de la mesh (mismos vivos)" % RE_REGISTROS,
		mm.objetos_vivos() == vivos_local,
		"vivos=%d esperado=%d" % [mm.objetos_vivos(), vivos_local])
	# Limpieza de A: drenar la oferta y liberar por el dueño (63).
	rec = null
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	sm.marcar_envejecidos(0.0)
	sm.marcar_envejecidos(0.0)
	sm.liberar_envejecidos()
	_a_vivos = _vivos(deb)
	deb.clear()
	_check("A limpia su estado: cola 0, activos 0, mesh liberada",
		mm.unload.candidatos_count() == 0 and sm.chunks_activos() == 0 and _a_vivos == 0,
		"cola=%d activos=%d vivos=%d" % [
			mm.unload.candidatos_count(), sm.chunks_activos(), _a_vivos])
	_fin("A")


## ── B. Reemplazo bajo el mismo chunk_id: sin dos mallas vivas al drenar ──────
func _bloque_b(mm: Node, sm: Node) -> void:
	print("--- B. Reemplazo (swap) de recurso bajo el mismo chunk_id ---")
	var base: int = mm.objetos_vivos()
	var viejo: Resource = Resource.new()
	var w_viejo: WeakRef = weakref(viejo)
	sm.registrar_chunk("t63_b/c0", 90.0, viejo)
	viejo = null
	var nuevo: Resource = Resource.new()
	var w_nuevo: WeakRef = weakref(nuevo)
	sm.registrar_chunk("t63_b/c0", 80.0, nuevo)
	_b_swap = sm.chunks_activos()
	_check("el swap mantiene UNA entrada activa para el chunk_id",
		_b_swap == 1, "activos=%d" % _b_swap)
	_check("el swap deja 1 oferta (la vieja; el nuevo no se re-ofrece)",
		mm.unload.candidatos_count() == 1, "cola=%d" % mm.unload.candidatos_count())
	_b_old_vivo = 1 if w_viejo.get_ref() != null else 0
	_b_new_vivo = 1 if w_nuevo.get_ref() != null else 0
	_check("ventana transitoria: viejo (en cola) y nuevo (activo) conviven 2/2",
		_b_old_vivo == 1 and _b_new_vivo == 1,
		"viejo=%d nuevo=%d" % [_b_old_vivo, _b_new_vivo])
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_b_old_vivo = 1 if w_viejo.get_ref() != null else 0
	_check("tras el drenaje el recurso VIEJO muere (la oferta era su último ref)",
		_b_old_vivo == 0, "viejo=%d" % _b_old_vivo)
	_b_new_vivo = 1 if w_nuevo.get_ref() != null else 0
	_check("el recurso NUEVO sigue vivo y activo (sin duplicación residual)",
		_b_new_vivo == 1 and sm.chunks_activos() == 1,
		"nuevo=%d activos=%d" % [_b_new_vivo, sm.chunks_activos()])
	_check("solo UNA malla del chunk queda viva tras drenar (cola 0, nuevo activo)",
		mm.unload.candidatos_count() == 0 and _b_new_vivo + _b_old_vivo == 1,
		"cola=%d viejo=%d nuevo=%d" % [
			mm.unload.candidatos_count(), _b_old_vivo, _b_new_vivo])
	nuevo = null
	sm.marcar_envejecidos(0.0)
	sm.marcar_envejecidos(0.0)
	var lib: int = sm.liberar_envejecidos()
	var muerto_b: bool = w_nuevo.get_ref() == null
	_b_new_vivo = 1 if w_nuevo.get_ref() != null else 0
	w_viejo = null
	w_nuevo = null
	var fin: int = mm.objetos_vivos()
	_check("liberar el nuevo cierra el ciclo (1 liberado, base restaurada)",
		lib == 1 and muerto_b and fin <= base,
		"lib=%d muerto=%s fin=%d base=%d" % [lib, str(muerto_b), fin, base])
	_fin("B")


## ── C. El 62 no libera lo del 63: drain cuenta, el dueño hace el drop ────────
func _bloque_c(mm: Node, sm: Node) -> void:
	print("--- C. Drenaje del 62 NO libera: el drop es del dueño (M63) ---")
	var base: int = mm.objetos_vivos()
	var rec: Resource = Resource.new()
	var w_rec: WeakRef = weakref(rec)
	sm.registrar_chunk("t63_c/c0", 85.0, rec)
	rec = null
	_check("oferta registrada (1 candidato)",
		mm.unload.candidatos_count() == 1, "cola=%d" % mm.unload.candidatos_count())
	_c_lib = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("el drenaje cuenta los MB de la oferta y vacía la cola",
		_c_lib == PESO_CHUNK_MB and mm.unload.candidatos_count() == 0,
		"lib=%d cola=%d" % [_c_lib, mm.unload.candidatos_count()])
	_c_queda_vivo = 1 if w_rec.get_ref() != null else 0
	_check("tras drenar, el recurso SIGUE VIVO (el 62 no es dueño del drop)",
		_c_queda_vivo == 1, "vivo=%d" % _c_queda_vivo)
	_check("el 63 mantiene su entrada activa (nada quedó colgado)",
		sm.chunks_activos() == 1, "activos=%d" % sm.chunks_activos())
	sm.marcar_envejecidos(0.0)
	sm.marcar_envejecidos(0.0)
	var lib: int = sm.liberar_envejecidos()
	var muerto: bool = w_rec.get_ref() == null
	_check("el dueño (63) hace el drop: 1 liberado y la mesh muere recién ahí",
		lib == 1 and muerto, "lib=%d muerto=%s" % [lib, str(muerto)])
	w_rec = null
	var fin: int = mm.objetos_vivos()
	_check("el ciclo completo vuelve a la base (sin residuo)",
		fin <= base and sm.chunks_activos() == 0,
		"fin=%d base=%d activos=%d" % [fin, base, sm.chunks_activos()])
	_fin("C")


## ── D. Veto del handshake: en carga no se descarga ───────────────────────────
func _bloque_d(mm: Node, sm: Node) -> void:
	print("--- D. Veto (handshake §5.3): recurso en carga por el 63 no se descarga ---")
	var base: int = mm.objetos_vivos()
	var rec: Resource = Resource.new()
	var w_rec: WeakRef = weakref(rec)
	sm.avisar_carga_iniciada(rec)
	_check("la carga queda declarada en ambos lados (63 y 62)",
		sm.recursos_en_carga_63() == 1 and mm.recursos_en_carga() == 1,
		"sm=%d mm=%d" % [sm.recursos_en_carga_63(), mm.recursos_en_carga()])
	sm.registrar_chunk("t63_d/c0", 70.0, rec)
	rec = null
	_check("oferta registrada durante la carga (1 candidato)",
		mm.unload.candidatos_count() == 1, "cola=%d" % mm.unload.candidatos_count())
	_d_lib = mm.unload.ejecutar_descarga(1 << 30, 1 << 20, mm._puede_descargar)
	_d_dif = mm.unload.diferidos_ultimo_lote()
	_check("el drenaje del 62 (con el filtro de producción) VETA el recurso en carga: 0 MB, diferido 1, cola intacta",
		_d_lib == 0 and _d_dif == 1 and mm.unload.candidatos_count() == 1
			and w_rec.get_ref() != null,
		"lib=%d dif=%d cola=%d vivo=%s" % [
			_d_lib, _d_dif, mm.unload.candidatos_count(),
			str(w_rec.get_ref() != null)])
	sm.avisar_carga_terminada(rec_vivo(w_rec))
	_check("al terminar la carga el registro del 62 queda limpio",
		mm.recursos_en_carga() == 0 and sm.recursos_en_carga_63() == 0,
		"mm=%d sm=%d" % [mm.recursos_en_carga(), sm.recursos_en_carga_63()])
	_d_lib = mm.unload.ejecutar_descarga(1 << 30, 1 << 20, mm._puede_descargar)
	_check("con la carga terminada, el drenaje consume la oferta (filtro sin vetos)",
		_d_lib == PESO_CHUNK_MB and mm.unload.candidatos_count() == 0,
		"lib=%d cola=%d" % [_d_lib, mm.unload.candidatos_count()])
	sm.marcar_envejecidos(0.0)
	sm.marcar_envejecidos(0.0)
	var lib: int = sm.liberar_envejecidos()
	var muerto_d: bool = w_rec.get_ref() == null
	w_rec = null
	var fin: int = mm.objetos_vivos()
	_check("cierre limpio (1 liberado, mesh muerta, base restaurada)",
		lib == 1 and muerto_d and fin <= base,
		"lib=%d muerto=%s fin=%d base=%d" % [lib, str(muerto_d), fin, base])
	_fin("D")


## ── E. Conservación global: 5 ciclos x 8 chunks ──────────────────────────────
func _bloque_e(mm: Node, sm: Node) -> void:
	print("--- E. Conservación global: %d ciclos x %d chunks ---" % [CICLOS, CHUNKS_POR_CICLO])
	var base: int = mm.objetos_vivos()
	_e_ciclos = 0
	_e_vivos = 0
	for ciclo in CICLOS:
		var deb: Array[WeakRef] = []
		var mallas: Array[Mesh] = []
		for j in CHUNKS_POR_CICLO:
			var malla := BoxMesh.new()
			mallas.append(malla)
			deb.append(weakref(malla))
			var cid := "t63_e/c%d/f%d" % [ciclo, j]
			sm.registrar_chunk(cid, 50.0 + float(j), malla)
			sm.registrar_chunk(cid, 50.0 + float(j), malla)
			sm.registrar_chunk(cid, 50.0 + float(j), malla)
		mallas.clear()
		var lib: int = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
		sm.marcar_envejecidos(0.0)
		sm.marcar_envejecidos(0.0)
		var libsm: int = sm.liberar_envejecidos()
		var vivos: int = _vivos(deb)
		_e_vivos += vivos
		deb.clear()
		var cola: int = mm.unload.candidatos_count()
		var fin: int = mm.objetos_vivos()
		if (lib == CHUNKS_POR_CICLO * PESO_CHUNK_MB and libsm == CHUNKS_POR_CICLO
				and vivos == 0 and cola == 0 and fin <= base):
			_e_ciclos += 1
		print("  ciclo %d: lib=%d libsm=%d vivos=%d cola=%d objetos_fin=%d" % [
			ciclo, lib, libsm, vivos, cola, fin])
	_check("los %d ciclos drenaron y liberaron limpio (doble/triple registro incluido)" % CICLOS,
		_e_ciclos == CICLOS, "ciclos_ok=%d" % _e_ciclos)
	_check("%d WeakRefs acumuladas: 0 retenidas (sin duplicación residual)" % (CICLOS * CHUNKS_POR_CICLO),
		_e_vivos == 0, "vivos=%d" % _e_vivos)
	_check("cola final 0 y 0 chunks activos",
		mm.unload.candidatos_count() == 0 and sm.chunks_activos() == 0,
		"cola=%d activos=%d" % [mm.unload.candidatos_count(), sm.chunks_activos()])
	_check("delta global de objetos_vivos == 0 (fin <= base)",
		mm.objetos_vivos() <= base, "fin=%d base=%d" % [mm.objetos_vivos(), base])
	_check("las descargas del 63 quedaron contadas (%d >= %d)" % [
			sm.descargas_total(), CICLOS * CHUNKS_POR_CICLO],
		sm.descargas_total() >= CICLOS * CHUNKS_POR_CICLO,
		"total=%d" % sm.descargas_total())
	_fin("E")


## ── Utilidades ───────────────────────────────────────────────────────────────

func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


func _sm() -> Node:
	return root.get_node_or_null("StreamManager")


## El recurso de un WeakRef vivo (o null). Centraliza el null-check tipado.
func rec_vivo(w: WeakRef) -> Resource:
	return w.get_ref() as Resource


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
	print("-- A: cola=%d vivos_fin=%d" % [_a_cola, _a_vivos])
	print("-- B: swap=%d old_vivo=%d new_vivo=%d" % [_b_swap, _b_old_vivo, _b_new_vivo])
	print("-- C: lib=%d queda_vivo=%d" % [_c_lib, _c_queda_vivo])
	print("-- D: dif=%d lib=%d" % [_d_dif, _d_lib])
	print("-- E: ciclos_ok=%d/%d vivos_acum=%d" % [_e_ciclos, CICLOS, _e_vivos])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
