# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-18
#
# M62: Memoria — Suite de contratación "texturas de región se liberan al salir".
# Cierra por MEDICIÓN el ítem L100 de 62-Memoria plan-actual/05-Checklist:
#   "Texturas de región se liberan al salir de la misma (con M63 y M09) [M]"
#
# Qué mide (headless, con los autoloads REALES StreamManager + MemoryMonitor):
#   A. Región EN USO: las texturas encoladas vía el contrato real M63→M62
#      (registrar_chunk) quedan VETADAS (avisar_cambio_region no libera nada en
#      carga) y dentro del radio no se envejecen.
#   B. SALIR de la región: el LRU de M63 libera (2 frames de envejecido) y M62
#      fuerza el drenaje en el cambio de región -> NINGUNA textura sobrevive
#      (prueba con WeakRef).
#   C. Atlas de región (lado M09): la evicción LRU (evictar_atlas) elige las
#      entradas de la región vieja, con log y señal recurso_descargado.
#
# Alcance (honesto): mide el CONTRATO extremo a extremo del mecanismo con los
# dos managers reales; NO cubre al llamador de gameplay (M09/M27 avisando la
# salida de región) — ese cableado pertenece a esos módulos (ver auditoría de
# cableado en 62-Memoria plan-actual/05-Checklist, 2026-10-17). Prelación
# empírica: sonda out/tanda59/probe1.log — semántica de `unreference()` sin
# `reference()` previo (stream_manager.gd L350) verificada SEGURA tanto
# reteniendo como soltando la referencia antes de liberar.
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_texturas_region.gd

extends SceneTree

const MODULO := "M62 texturas region"
const BLOQUES: Array[String] = ["A", "B", "C"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md / evidencia T59).
const CHECKS_MINIMOS := 33

const N_TEXTURAS := 3
const DIST_REGION := 60.0
const R_MAX_DENTRO := 100.0
const R_MAX_FUERA := 10.0

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Referencias del test (se sueltan en el bloque B para la prueba WeakRef).
var _texs: Array[Texture2D] = []
var _debiles: Array[WeakRef] = []

# Deltas base capturados en el bloque A.
var _chunks_base: int = -1
var _descargas_base: int = -1
var _forz_base: int = -1
var _cambios_base: int = -1

# Diagnóstico (se imprime en el resumen, para auditar sin re-correr).
var _obj_base: int = -1
var _obj_fin: int = -1
var _vivos_fin: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Texturas de región se liberan al salir (L100) ===")
	var sm := _sm()
	var mm := _mm()
	if sm == null or mm == null:
		_check("autoloads StreamManager + MemoryMonitor presentes", false,
			"sm=%s mm=%s" % [sm, mm])
		return
	_check("autoloads StreamManager + MemoryMonitor presentes", true)
	_bloque_a()
	_bloque_b()
	_bloque_c()


## ── A. Región en uso: encoladas + vetadas + sin envejecer ────────────────
func _bloque_a() -> void:
	print("--- A. Región en uso: encoladas + vetadas + sin envejecer ---")
	var sm := _sm()
	var mm := _mm()
	# Drenaje inicial: el arranque del juego puede haber dejado candidatos.
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la cola de descarga de M62 arranca drenada",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_obj_base = mm.objetos_vivos()
	_chunks_base = sm.chunks_activos()
	_descargas_base = sm.descargas_total()
	_forz_base = mm.liberaciones_forzadas()
	_cambios_base = mm.cambios_region()

	# 3 texturas de "región A" encoladas vía el contrato real M63 -> M62.
	for i in N_TEXTURAS:
		var img := Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.2, 0.5, 0.3, 1.0))
		var tex := ImageTexture.create_from_image(img)
		_texs.append(tex)
		_debiles.append(weakref(tex))
		sm.registrar_chunk("t59_regA/atlas_%d" % i, DIST_REGION, tex)
	_check("las %d texturas de región se encolaron en M62 (registrar_chunk)"
		% N_TEXTURAS, mm.unload.candidatos_count() == N_TEXTURAS,
		"n=%d" % mm.unload.candidatos_count())
	_check("los %d chunks quedan activos en el LRU de M63" % N_TEXTURAS,
		sm.chunks_activos() == _chunks_base + N_TEXTURAS,
		"%d -> %d" % [_chunks_base, sm.chunks_activos()])

	# La región se está usando: M63 declara cada textura en carga.
	for i in N_TEXTURAS:
		sm.avisar_carga_iniciada(_texs[i])
	_check("M62 ve las %d en carga" % N_TEXTURAS,
		mm.recursos_en_carga() == N_TEXTURAS, "n=%d" % mm.recursos_en_carga())
	_check("M63 ve las %d en carga" % N_TEXTURAS,
		sm.recursos_en_carga_63() == N_TEXTURAS, "n=%d" % sm.recursos_en_carga_63())

	# Cambio de región EN USO: el monitor NO puede liberar lo que está en carga.
	var forzo: bool = mm.avisar_cambio_region("t59_regA")
	_check("en uso, el cambio de región NO fuerza liberación", forzo == false)
	_check("el cambio de región quedó contado",
		mm.cambios_region() == _cambios_base + 1,
		"%d -> %d" % [_cambios_base, mm.cambios_region()])
	_check("la región actual quedó registrada", mm.region_actual() == "t59_regA",
		"region=%s" % mm.region_actual())
	_check("los %d candidatos quedaron VETADOS por estar en carga" % N_TEXTURAS,
		mm.descartes_por_carga() == N_TEXTURAS,
		"d=%d" % mm.descartes_por_carga())
	_check("no hubo liberación forzada", mm.liberaciones_forzadas() == _forz_base,
		"f=%d base=%d" % [mm.liberaciones_forzadas(), _forz_base])
	_check("los %d candidatos SIGUEN en cola (nada se liberó en uso)" % N_TEXTURAS,
		mm.unload.candidatos_count() == N_TEXTURAS,
		"n=%d" % mm.unload.candidatos_count())

	# Dentro de la región (radio 100 m) las texturas a 60 m no se envejecen.
	sm.marcar_envejecidos(R_MAX_DENTRO)
	sm.marcar_envejecidos(R_MAX_DENTRO)
	_check("dentro de la región el LRU no libera nada",
		sm.liberar_envejecidos() == 0)
	_check("los chunks siguen activos", sm.chunks_activos() == _chunks_base + N_TEXTURAS,
		"n=%d" % sm.chunks_activos())
	_check("ni la cola de M62 cambió sola", mm.unload.candidatos_count() == N_TEXTURAS,
		"n=%d" % mm.unload.candidatos_count())
	_fin("A")


## ── B. Salir de la región: liberación real + WeakRef ─────────────────────
func _bloque_b() -> void:
	print("--- B. Salir de la región: el LRU libera + M62 drena + WeakRef ---")
	var sm := _sm()
	var mm := _mm()
	# Salida real: el jugador se aleja -> 2 frames de envejecido -> LRU libera.
	sm.marcar_envejecidos(R_MAX_FUERA)
	sm.marcar_envejecidos(R_MAX_FUERA)
	var liberados: int = sm.liberar_envejecidos()
	_check("al salir, el LRU de M63 libera las %d texturas" % N_TEXTURAS,
		liberados == N_TEXTURAS, "liberados=%d" % liberados)
	_check("chunks_activos volvió a la base", sm.chunks_activos() == _chunks_base,
		"%d vs base %d" % [sm.chunks_activos(), _chunks_base])
	_check("el LRU contó las %d descargas" % N_TEXTURAS,
		sm.descargas_total() == _descargas_base + N_TEXTURAS,
		"%d -> %d" % [_descargas_base, sm.descargas_total()])
	_check("M62 ya no ve recursos en carga (avisar_carga_terminada)",
		mm.recursos_en_carga() == 0, "n=%d" % mm.recursos_en_carga())
	_check("M63 ya no ve recursos en carga",
		sm.recursos_en_carga_63() == 0, "n=%d" % sm.recursos_en_carga_63())

	# El cambio de región ahora drena la cola de M62 (ya sin veto).
	var forzo: bool = mm.avisar_cambio_region("t59_regB")
	_check("el cambio de región ahora SÍ fuerza la liberación", forzo == true)
	_check("la liberación forzada quedó contada",
		mm.liberaciones_forzadas() == _forz_base + 1,
		"f=%d base=%d" % [mm.liberaciones_forzadas(), _forz_base])
	_check("la cola de M62 quedó VACÍA (texturas descargadas)",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_check("cambios de región contados (2)",
		mm.cambios_region() == _cambios_base + 2,
		"%d -> %d" % [_cambios_base, mm.cambios_region()])

	# Prueba fuerte del ítem L100: ninguna textura de la región vieja sobrevive.
	_texs.clear()
	var vivos: int = _contar_vivos(_debiles)
	_debiles.clear()
	_vivos_fin = vivos
	_check("NINGUNA de las %d texturas de región sobrevive al salir (WeakRef) (L100)"
		% N_TEXTURAS, vivos == 0, "vivas=%d" % vivos)
	_obj_fin = mm.objetos_vivos()
	_check("objetos_vivos() no creció con el ciclo completo (fin <= base)",
		_obj_fin <= _obj_base,
		"base=%d fin=%d delta=%d" % [_obj_base, _obj_fin, _obj_fin - _obj_base])
	_fin("B")


## ── C. Atlas de región (lado M09): LRU + señal + log ─────────────────────
func _bloque_c() -> void:
	print("--- C. Atlas de región (lado M09): evicción LRU + señal + log ---")
	var mm := _mm()
	var emisiones: Array = []
	mm.recurso_descargado.connect(func(sistema: String, mb: int) -> void:
		emisiones.append([sistema, mb]))
	var entradas: Array = [
		{"nombre": "t59_regA/color.png", "mb": 40, "ultimo_uso": 1},
		{"nombre": "t59_regA/normal.png", "mb": 35, "ultimo_uso": 2},
		{"nombre": "t59_regB/color.png", "mb": 40, "ultimo_uso": 9},
	]
	var ev: Array = mm.evictar_atlas(entradas, 75, 99)
	var mb_ev := 0
	var solo_regA := true
	for e in ev:
		mb_ev += int((e as Dictionary).get("mb", 0))
		if not String((e as Dictionary).get("nombre", "")).begins_with("t59_regA"):
			solo_regA = false
	_check("evictar_atlas evicta las 2 entradas de la región vieja (75 MB)",
		ev.size() == 2 and mb_ev == 75, "n=%d mb=%d" % [ev.size(), mb_ev])
	_check("solo evicta entradas de la región A (deja intacta la B)", solo_regA)
	var ev2: Array = mm.evictar_atlas(entradas, 40, 99)
	_check("con hasta_mb=40 evicta solo 1 (la más antigua)", ev2.size() == 1,
		"n=%d" % ev2.size())
	var ev3: Array = mm.evictar_atlas(entradas, 1000, 1)
	_check("max_entradas=1 manda sobre hasta_mb grande", ev3.size() == 1,
		"n=%d" % ev3.size())
	var ev4: Array = mm.evictar_atlas(entradas, 0, 99)
	_check("hasta_mb=0 es no-op (nada evictado)", ev4.is_empty(),
		"n=%d" % ev4.size())
	_check("la señal recurso_descargado se emitió por cada evicción útil (3)",
		emisiones.size() == 3, "n=%d" % emisiones.size())
	var tipos_ok := true
	var mbs: Array = []
	for em in emisiones:
		if String(em[0]) != "atlas":
			tipos_ok = false
		mbs.append(int(em[1]))
	_check("las emisiones son tipo 'atlas' y con los MB correctos (75, 40, 40)",
		tipos_ok and mbs == [75, 40, 40], "tipos_ok=%s mbs=%s" % [tipos_ok, mbs])
	_fin("C")


## ── Utilidades ───────────────────────────────────────────────────────────

func _sm() -> Node:
	return root.get_node_or_null("StreamManager")


func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


## Cuántos de los WeakRef siguen vivos (=> el objeto fue RETENIDO por alguien).
func _contar_vivos(debiles: Array) -> int:
	var vivos := 0
	for w in debiles:
		if (w as WeakRef).get_ref() != null:
			vivos += 1
	return vivos


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
	print("-- texturas de región que sobrevivieron: %d" % _vivos_fin)
	print("-- objetos_vivos: base=%d fin=%d (delta=%d)" % [_obj_base, _obj_fin, _obj_fin - _obj_base])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
