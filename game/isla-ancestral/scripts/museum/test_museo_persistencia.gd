# M37: persistencia del museo — K.167 (escritura atomica del bloque) + K.170
# (compatibilidad con el autosave general). DeepSeek-V4.1-Flash, 2026-10-09.
#
# K.167 se satisface por REUSO del writer atomico de M59 (SaveWriter.write_atomic:
# .tmp -> rename a .save, con verificacion interna del .tmp antes del rename); no
# se reinventa. El bloque del museo es UNA seccion ("collections") del payload, asi
# que se persiste como bloque unico: piezas + recompensas viajan juntas o no viajan.
# K.170: el autosave general (SaveManager.request_save) recolecta la seccion via el
# proveedor ISaveProvider registrado por CollectionRegistry, asi que el bloque del
# museo se guarda y se restaura en el ciclo de autosave sin codigo extra.
#
# Guardian de 3 capas: contador + piso CHECKS_MINIMOS (MEDIDO) + marcadores por
# bloque; _summary() diferido sobrevive a un SCRIPT ERROR que aborte _run().
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/museum/test_museo_persistencia.gd
extends SceneTree

const MODULO := "M37-Persistencia"
const CHECKS_MINIMOS := 35   # MEDIDO en verde (35 checks reales); nunca estimado
const FRAMES_MAX := 600
const SLOT: int = 3          # dentro de SLOT_COUNT=3; se limpia antes y despues

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _resumido := false
var _frames := 0
var _fallo_emitido := false

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _process(_delta: float) -> bool:
	_frames += 1
	if not _resumido and _frames > FRAMES_MAX:
		print("!! WATCHDOG: _run() no termino en %d frames (posible SCRIPT ERROR que aborto la funcion)" % FRAMES_MAX)
		_summary()
	return false

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _summary() -> void:
	if _resumido:
		return
	_resumido = true
	for n in BLOQUES:
		if not _vistos.has(n):
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
			_fallos += 1
	if _checks < CHECKS_MINIMOS:
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
		_fallos += 1
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)

# ── utilidades de disco (slot aislado) ──────────────────────────────────

func _p(nombre: String) -> String:
	return "user://saves/" + nombre

func _limpia() -> void:
	for f in ["slot_%d.save" % SLOT, "slot_%d.tmp" % SLOT,
			"slot_%d_r1.bak" % SLOT, "slot_%d_r2.bak" % SLOT]:
		var p := _p(f)
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)
	# el .tmp puede ser un DIRECTORIO (lo usa el bloque C para forzar el fallo)
	var tmp_abs := ProjectSettings.globalize_path(_p("slot_%d.tmp" % SLOT))
	if DirAccess.dir_exists_absolute(tmp_abs):
		DirAccess.remove_absolute(tmp_abs)

func _doc_de_slot() -> Dictionary:
	return SaveWriter.parse_document(FileAccess.get_file_as_string(SaveWriter.path_for(SLOT)))

func _payload_de_slot() -> Dictionary:
	var doc := _doc_de_slot()
	return doc.get("payload", {}) if bool(doc.get("ok", false)) else {}

func _collections_de_slot() -> Dictionary:
	var col: Variant = _payload_de_slot().get("collections", {})
	return col if typeof(col) == TYPE_DICTIONARY else {}

## Siembra un .save directo (sin pasar por el manager) con el bloque del museo dado.
func _siembra(reg) -> bool:
	var p: Dictionary = SaveSchema.default_payload("perfil_m37")
	p["collections"] = reg.get_save_data()
	return SaveWriter.write_atomic(SLOT, p)

# ── bloques ─────────────────────────────────────────────────────────────

## K.167: el camino REAL (request_save) escribe el bloque del museo por el writer
## atomico de M59. Tras el guardado no queda .tmp y el bloque se restaura al cargar.
func _bA_camino_real(reg, sm) -> void:
	reg.restore_save_data({})
	reg.register_item("flora", "baya_roja")
	_limpia()
	sm.current_slot = SLOT
	sm.request_save(SLOT, "test_m37_k167")
	_check(SaveWriter.save_exists(SLOT), "A: request_save deja slot_%d.save" % SLOT)
	_check(not FileAccess.file_exists(_p("slot_%d.tmp" % SLOT)),
		"A: el rename atomico no deja .tmp huerfano")
	_check(not FileAccess.file_exists(_p("slot_%d_r1.bak" % SLOT)),
		"A: sin save previo no hay .bak")
	_check(sm.load_slot(SLOT) == SaveLoader.LoadResult.OK, "A: load_slot() == OK")
	_check(reg.is_registered("flora", "baya_roja"),
		"A: el bloque del museo se restauro por el camino real")
	_fin("A")

## K.167: "bloque unico" — piezas y recompensas viven en la MISMA seccion
## ("collections") del payload, asi que se escriben juntas o no se escriben.
func _bB_bloque_unico(reg, sm) -> void:
	reg.restore_save_data({})
	reg.register_item("fosiles", "fragmento_ancestral")   # completa la exposicion
	reg.otorgar_recompensa("fosiles")
	_limpia()
	sm.current_slot = SLOT
	sm.request_save(SLOT, "test_m37_unico")
	var col := _collections_de_slot()
	_check(not col.is_empty(), "B: la seccion 'collections' esta presente en el archivo")
	_check(col.has("version") and col.has("piezas") and col.has("recompensas"),
		"B: version + piezas + recompensas en UNA sola seccion (bloque unico)")
	_check(typeof(col.get("piezas")) == TYPE_DICTIONARY and typeof(col.get("recompensas")) == TYPE_ARRAY,
		"B: piezas es objeto y recompensas es array (tipos del contrato)")
	# El bloque serializado lleva la pieza Y la recompensa juntas.
	var piezas: Dictionary = col.get("piezas", {})
	_check(piezas.has("fosiles") and "fragmento_ancestral" in piezas["fosiles"],
		"B: la pieza donada viaja en el bloque")
	_check("fosiles" in (col.get("recompensas", []) as Array),
		"B: la recompensa reclamada viaja en el MISMO bloque")
	_fin("B")

## K.167: un fallo de escritura NO deja un bloque parcial. Se fuerza el fallo con
## un DIRECTORIO en el path del .tmp (FileAccess.open(WRITE) devuelve null -> el
## writer aborta ANTES del rename). El bloque anterior queda intacto y recuperable.
func _bC_fallo_sin_parcial(reg, sm) -> void:
	reg.restore_save_data({})
	reg.register_item("flora", "baya_roja")
	_limpia()
	_check(_siembra(reg), "C: se sembro un .save con el bloque A (flora/baya_roja)")
	# Forzar el fallo: el .tmp es un directorio -> FileAccess.open(WRITE) == null.
	var tmp_abs := ProjectSettings.globalize_path(_p("slot_%d.tmp" % SLOT))
	DirAccess.make_dir_recursive_absolute(tmp_abs)
	_check(DirAccess.dir_exists_absolute(tmp_abs), "C: .tmp convertido en directorio (fallo inyectado)")
	_fallo_emitido = false
	var cb := func(_s: int, _r: String) -> void: _fallo_emitido = true
	sm.save_failed.connect(cb)
	sm.request_save(SLOT, "test_m37_fallo")
	sm.save_failed.disconnect(cb)
	_check(_fallo_emitido, "C: request_save reporto save_failed (no un exito silencioso)")
	_check(not SaveWriter.save_exists(SLOT),
		"C: el fallo ocurre ANTES del rename -> no hay .save parcial")
	var code: int = sm.load_slot(SLOT)
	_check(code == SaveLoader.LoadResult.RECOVERED,
		"C: el bloque ANTERIOR se recupera del .bak (dio %d)" % code)
	_check(reg.is_registered("flora", "baya_roja"),
		"C: el bloque anterior sobrevivio COMPLETO (sin estado parcial)")
	DirAccess.remove_absolute(tmp_abs)   # limpieza del directorio inyectado
	_fin("C")

## K.167: corte entre la rotacion y la escritura (manager rota a .bak y muere
## antes de escribir). El bloque anterior sigue siendo el UNICO estado en disco.
func _bD_corte_tras_rotacion(reg, sm) -> void:
	reg.restore_save_data({})
	reg.register_item("peces", "trucha_cascada")
	_limpia()
	_check(_siembra(reg), "D: se sembro un .save con el bloque A (peces/trucha_cascada)")
	SaveBackup.rotate(SLOT)   # simula el corte entre rotate() y write_atomic()
	_check(not SaveWriter.save_exists(SLOT), "D: el slot quedo SIN .save (estado del corte)")
	_check(FileAccess.file_exists(_p("slot_%d_r1.bak" % SLOT)), "D: el bloque vive en el .bak")
	var code: int = sm.load_slot(SLOT)
	_check(code == SaveLoader.LoadResult.RECOVERED,
		"D: load_slot() RECUPERA el bloque anterior (dio %d)" % code)
	_check(reg.is_registered("peces", "trucha_cascada"),
		"D: el bloque recuperado conserva la pieza exacta (sin parcial)")
	_fin("D")

## K.170: el autosave general guarda y restaura el bloque del museo. Se prueban
## los dos disparadores reales: el motivo "auto_dia" (request_save) y el EventBus
## (calendar.day_started -> _on_auto_save_dia).
func _bE_autosave(reg, sm, bus) -> void:
	reg.restore_save_data({})
	reg.register_item("flora", "baya_roja")
	reg.register_item("fauna", "gaviota_playera")
	_limpia()
	sm.current_slot = SLOT
	sm.request_save(SLOT, "auto_dia")
	_check(SaveWriter.save_exists(SLOT), "E: autosave (auto_dia) escribio el slot")
	var col := _collections_de_slot()
	var piezas: Dictionary = col.get("piezas", {})
	_check(piezas.has("flora") and piezas.has("fauna"),
		"E: el bloque del museo viaja en el autosave (flora + fauna)")
	# Round-trip: reset + cargar restaura el estado.
	reg.restore_save_data({})
	_check(sm.load_slot(SLOT) == SaveLoader.LoadResult.OK, "E: el autosave se recarga OK")
	_check(reg.is_registered("flora", "baya_roja") and reg.is_registered("fauna", "gaviota_playera"),
		"E: el bloque del museo se restauro desde el autosave")
	# Segundo disparador: el EventBus (B1) -> _on_auto_save_dia.
	reg.restore_save_data({})
	reg.register_item("flora", "fibra_algodon")
	_limpia()
	sm.current_slot = SLOT
	bus.calendar.day_started.emit(5, "Primavera")
	_check(SaveWriter.save_exists(SLOT), "E: day_started por EventBus disparo el autosave")
	var col2 := _collections_de_slot()
	var piezas2: Dictionary = col2.get("piezas", {})
	_check(piezas2.has("flora") and "fibra_algodon" in piezas2["flora"],
		"E: el bloque nuevo se escribio en el autosave disparado por el bus")
	_fin("E")

## K.170 (control): con el museo VACIO el autosave sigue escribiendo un bloque
## valido (version + piezas/recompensas vacias) y no rompe la carga.
func _bF_autosave_vacio(reg, sm) -> void:
	reg.restore_save_data({})
	_limpia()
	sm.current_slot = SLOT
	sm.request_save(SLOT, "auto_timer")
	_check(SaveWriter.save_exists(SLOT), "F: el autosave escribe aunque el museo este vacio")
	var col := _collections_de_slot()
	_check(typeof(col) == TYPE_DICTIONARY and col.has("version"),
		"F: el bloque vacio conserva la version")
	_check((col.get("piezas", {}) as Dictionary).is_empty() and (col.get("recompensas", []) as Array).is_empty(),
		"F: el bloque vacio tiene piezas/recompensas vacias")
	_check(sm.load_slot(SLOT) == SaveLoader.LoadResult.OK, "F: el save del museo vacio carga OK")
	_check(is_equal_approx(reg.get_total_progress(), 0.0), "F: el museo vacio queda en 0%")
	_fin("F")

# ── orquestacion ────────────────────────────────────────────────────────

func _run() -> void:
	var reg = root.get_node_or_null("CollectionRegistry")
	var sm = root.get_node_or_null("SaveManager")
	var bus = root.get_node_or_null("EventBus")
	_check(reg != null, "autoload CollectionRegistry presente")
	_check(sm != null, "autoload SaveManager presente")
	_check(bus != null, "autoload EventBus presente")
	if reg == null or sm == null or bus == null:
		return
	_bA_camino_real(reg, sm)
	_bB_bloque_unico(reg, sm)
	_bC_fallo_sin_parcial(reg, sm)
	_bD_corte_tras_rotacion(reg, sm)
	_bE_autosave(reg, sm, bus)
	_bF_autosave_vacio(reg, sm)
	_limpia()
	reg.restore_save_data({})
	sm.current_slot = -1
