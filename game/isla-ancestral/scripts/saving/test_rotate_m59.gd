# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-02
#
# M59 iter. 2: el CAMINO REAL de guardado (SaveManager.request_save) y la
# rotacion de backups.
#
# REGRESION DEL BUG CRITICO: rotate() corria DESPUES de write_atomic(), que
# renombra .tmp -> .save REEMPLAZANDO el save anterior; luego rotate() movia
# ESE save recien escrito a slot_N_r1.bak. Resultado medido: el slot quedaba
# SIN .save (solo .bak) y load_slot() devolvia NOT_FOUND -> el juego no podia
# cargar NINGUN save escrito por el camino normal (auto-save, timer, UI).
# Las suites previas no lo veian porque llamaban a write_atomic() DIRECTO,
# nunca a request_save().
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_rotate_m59.gd
#
# Guardia anti-falso-verde de 3 capas (misma doctrina que test_slots_m59.gd):
#   1) _fin(clave) cierra cada bloque: un bloque que no cierra NO corrio.
#   2) CHECKS_MINIMOS: piso MEDIDO EN VERDE (no estimado, no copiado).
#   3) _summary() en call_deferred separado: sobrevive a un SCRIPT ERROR que
#      aborte _run() y decide el exit code (sin el, un abort daria 0 fallos).
#
# No usa class_name: evita depender del cache de clases globales en headless.

extends SceneTree

## Piso de checks. MEDIDO en la primera corrida VERDE (43) y fijado aqui.
const CHECKS_MINIMOS: int = 43

## Slot de trabajo (dentro de SLOT_COUNT=3). Se limpia antes y despues.
const SLOT: int = 2

## Dia distintivo sembrado a mano para distinguir "save anterior" de "save nuevo".
const DIA_SEMBRADO: int = 77
const DIA_INTERRUMPIDO: int = 33

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}      # clave -> descripcion

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

# ── utilidades de reporte ────────────────────────────────────────────────

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _abrir(clave: String, desc: String) -> void:
	_abiertos[clave] = desc
	print("-- bloque %s: %s" % [clave, desc])

func _fin(clave: String) -> void:
	_abiertos.erase(clave)
	_cerrados.append(clave)
	print("-- fin bloque %s" % clave)

# ── utilidades de disco (slot aislado) ───────────────────────────────────

func _rutas() -> Array:
	return ["slot_%d.save" % SLOT, "slot_%d.tmp" % SLOT,
		"slot_%d_r1.bak" % SLOT, "slot_%d_r2.bak" % SLOT]

func _limpia() -> void:
	for f: String in _rutas():
		var p := "user://saves/" + f
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

func _existe(archivo: String) -> bool:
	return FileAccess.file_exists("user://saves/" + archivo)

## Dia del payload de un archivo del slot, o -1 si no se puede leer.
func _dia_de(archivo: String) -> int:
	var p := "user://saves/" + archivo
	if not FileAccess.file_exists(p):
		return -1
	var doc: Dictionary = SaveWriter.parse_document(FileAccess.get_file_as_string(p))
	if not bool(doc.get("ok", false)):
		return -1
	var payload: Dictionary = doc.get("payload", {})
	return int(payload.get("time", {}).get("day", -1))

## Siembra un .save directo (sin pasar por el manager) con un dia conocido.
func _siembra(dia: int, version: int = SaveSchema.SCHEMA_VERSION) -> bool:
	var p: Dictionary = SaveSchema.default_payload("perfil_rot")
	p["schema_version"] = version
	p["time"]["day"] = dia
	return SaveWriter.write_atomic(SLOT, p)

# ── bloques ──────────────────────────────────────────────────────────────

## REGRESION: request_save() (el camino de produccion) debe dejar un .save
## cargable. Con el bug, el slot quedaba solo con .bak.
func _b1_camino_real(sm) -> void:
	_abrir("1", "request_save() deja un .save cargable (regresion: rotacion invertida)")
	_limpia()
	sm.request_save(SLOT, "test_rotate_b1")
	_ok(SaveWriter.save_exists(SLOT),
		"tras request_save() existe slot_%d.save (con el bug solo habia .bak)" % SLOT)
	_ok(not _existe("slot_%d.tmp" % SLOT), "no queda .tmp huerfano tras el guardado")
	# En el primer guardado no habia save previo -> no debe haber backup.
	_ok(not _existe("slot_%d_r1.bak" % SLOT),
		"sin save previo, la rotacion no crea .bak (rotate() es no-op)")
	_ok(sm.load_slot(SLOT) == SaveLoader.LoadResult.OK,
		"load_slot() devuelve OK sobre el save recien escrito por request_save()")
	_fin("1")

## La rotacion debe preservar el save ANTERIOR en .bak, no el recien escrito.
## Si rotate() corriera despues de write_atomic(), el .bak tendria el save NUEVO.
func _b2_rotacion_preserva_anterior(sm) -> void:
	_abrir("2", "la rotacion preserva el save ANTERIOR en .bak")
	_limpia()
	_ok(_siembra(DIA_SEMBRADO), "se sembro un save con day=%d" % DIA_SEMBRADO)
	sm.request_save(SLOT, "test_rotate_b2")
	_ok(SaveWriter.save_exists(SLOT), "sigue habiendo slot_%d.save" % SLOT)
	_ok(_existe("slot_%d_r1.bak" % SLOT), "el save previo se roto a slot_%d_r1.bak" % SLOT)
	_ok(_dia_de("slot_%d_r1.bak" % SLOT) == DIA_SEMBRADO,
		"el .bak conserva el save ANTERIOR (day=%d, dio %d)" % [
			DIA_SEMBRADO, _dia_de("slot_%d_r1.bak" % SLOT)])
	_ok(_dia_de("slot_%d.save" % SLOT) != DIA_SEMBRADO,
		"el .save es el save NUEVO, no el sembrado (dio day=%d)" % _dia_de("slot_%d.save" % SLOT))
	_ok(sm.load_slot(SLOT) == SaveLoader.LoadResult.OK, "el save nuevo carga OK")
	_fin("2")

## Guardado interrumpido: el manager rota a .bak y muere antes de escribir el
## nuevo. Queda .bak sin .save. Antes -> NOT_FOUND (progreso inalcanzable);
## ahora -> RECOVERED desde el backup.
func _b3_interrumpido(sm) -> void:
	_abrir("3", "guardado interrumpido: sin .save pero con .bak -> RECOVERED")
	_limpia()
	_ok(_siembra(DIA_INTERRUMPIDO), "se sembro un save con day=%d" % DIA_INTERRUMPIDO)
	SaveBackup.rotate(SLOT)   # simula el corte entre la rotacion y la escritura
	_ok(not SaveWriter.save_exists(SLOT), "el slot quedo SIN .save (estado del corte)")
	_ok(_existe("slot_%d_r1.bak" % SLOT), "el save vive en .bak")
	var code: int = sm.load_slot(SLOT)
	_ok(code == SaveLoader.LoadResult.RECOVERED,
		"load_slot() RECUPERA el backup en vez de NOT_FOUND (dio %d)" % code)
	var payload: Dictionary = sm.loader.load(SLOT).get("payload", {})
	_ok(int(payload.get("time", {}).get("day", -1)) == DIA_INTERRUMPIDO,
		"el payload recuperado conserva day=%d (dio %s)" % [
			DIA_INTERRUMPIDO, str(payload.get("time", {}).get("day", "N/A"))])
	_fin("3")

## Un backup de version FUTURA no debe cargarse como RECOVERED: eso degradaria
## un save mas nuevo (regla dura "nunca degradar un save").
func _b4_backup_futuro(sm) -> void:
	_abrir("4", "backup de version FUTURA no se carga (no degradar)")
	_limpia()
	var futura: int = SaveSchema.SCHEMA_VERSION + 1
	_ok(_siembra(88, futura), "se sembro un save v%d (futura)" % futura)
	SaveBackup.rotate(SLOT)   # el save futuro queda como backup, sin .save
	var code: int = sm.load_slot(SLOT)
	_ok(code == SaveLoader.LoadResult.FUTURE_VERSION,
		"load_slot() devuelve FUTURE_VERSION, no RECOVERED (dio %d)" % code)
	var doc: Dictionary = SaveWriter.parse_document(
		FileAccess.get_file_as_string("user://saves/slot_%d_r1.bak" % SLOT))
	_ok(int(doc.get("payload", {}).get("schema_version", 0)) == futura,
		"el backup futuro sigue intacto en disco (no se degrada)")
	_fin("4")

## Control negativo: sin save y sin backup -> NOT_FOUND (el bloque 3 no debe
## dispararse cuando no hay nada que recuperar).
func _b5_control_vacio(sm) -> void:
	_abrir("5", "control: slot vacio sin backup -> NOT_FOUND")
	_limpia()
	var code: int = sm.load_slot(SLOT)
	_ok(code == SaveLoader.LoadResult.NOT_FOUND,
		"sin .save y sin .bak -> NOT_FOUND (dio %d)" % code)
	_fin("5")

## Metadatos sobre el camino REAL (no sobre un payload sembrado a mano).
## El proveedor de tiempo (M29) emite "dia"; el schema declara "day". collect()
## reemplaza la seccion entera, asi que leer solo "day" daba SIEMPRE 0.
func _b6_metadatos_reales(sm) -> void:
	_abrir("6", "slot_metadata sobre request_save: dia del proveedor + last_saved")
	_limpia()
	sm.request_save(SLOT, "test_rotate_b6")
	var meta: Dictionary = sm.slot_metadata(SLOT)
	_ok(not meta.is_empty(), "slot_metadata no vacio tras request_save()")
	_ok(String(meta.get("last_saved", "")).length() >= 10,
		"last_saved sellado por el manager (dio '%s')" % String(meta.get("last_saved", "")))
	var doc: Dictionary = SaveWriter.parse_document(
		FileAccess.get_file_as_string(SaveWriter.path_for(SLOT)))
	var time_dict: Dictionary = doc.get("payload", {}).get("time", {})
	# Tolerante a la reconciliacion futura del dialecto: acepta "dia" o "day".
	var dia_real: int = int(time_dict.get("dia", time_dict.get("day", -1)))
	_ok(int(meta.get("day", -2)) == dia_real,
		"day de slot_metadata == el dia del proveedor (%d, dio %d; con el bug de dialecto daba 0)" % [
			dia_real, int(meta.get("day", -2))])
	_fin("6")

## Apagado durante la ESCRITURA (antes del rename): queda un .tmp huerfano a
## medio escribir y el .save ANTERIOR intacto -> la carga debe seguir OK y el
## .tmp debe poder limpiarse al arrancar (_process_init_cleanup).
func _b7_tmp_huerfano(sm) -> void:
	_abrir("7", "kill durante la escritura: .tmp huerfano no rompe la carga")
	_limpia()
	_ok(_siembra(44), "se sembro un save valido (day=44)")
	var f := FileAccess.open("user://saves/slot_%d.tmp" % SLOT, FileAccess.WRITE)
	_ok(f != null, "se creo un .tmp huerfano (corte antes del rename)")
	if f != null:
		f.store_string("basura a medio escribir")
		f.close()
	_ok(_existe("slot_%d.tmp" % SLOT), "el .tmp huerfano existe en disco")
	_ok(sm.load_slot(SLOT) == SaveLoader.LoadResult.OK,
		"el .save ANTERIOR sigue cargando OK pese al .tmp huerfano")
	SaveWriter.cleanup_orphan_tmp(SLOT)   # == _process_init_cleanup() al arrancar
	_ok(not _existe("slot_%d.tmp" % SLOT), "cleanup_orphan_tmp() borra el .tmp al arrancar")
	_fin("7")

## Item H: "Manejar campos nuevos (defaults) y faltantes (sin crash)".
## Un save al que le falta una seccion debe CARGAR completandose con los defaults
## del schema (antes: validate() -> "Falta sección: X" -> CORRUPTED).
func _b8_completar_defaults(sm) -> void:
	_abrir("8", "item H: save con secciones faltantes carga completando defaults")
	_limpia()
	var p: Dictionary = SaveSchema.default_payload("perfil_rot")
	p["time"]["day"] = 55
	p.erase("photos")
	p.erase("collections")
	_ok(SaveWriter.write_atomic(SLOT, p), "se escribio un save SIN photos/collections")
	# Control: validate() SIN completar SI detecta la falta (el fix no es cosmetico).
	var errores: Array[String] = SaveSchema.validate(p)
	_ok(not errores.is_empty(),
		"control: validate() reporta la seccion faltante sin completar (dio %d errores)" % errores.size())
	var code: int = sm.load_slot(SLOT)
	_ok(code == SaveLoader.LoadResult.OK,
		"load_slot() completa con defaults y carga OK (dio %d)" % code)
	var cargado: Dictionary = sm.loader.load(SLOT).get("payload", {})
	_ok(cargado.has("photos") and cargado.has("collections"),
		"el payload cargado recupero las secciones faltantes")
	var photos: Dictionary = cargado.get("photos", {})
	var ids: Variant = photos.get("ids", null)
	_ok(ids is Array and (ids as Array).is_empty(), "photos.ids quedo con el default []")
	_ok(int(cargado.get("time", {}).get("day", -1)) == 55,
		"el dato REAL (day=55) no se sobrescribio (dio %s)" % str(cargado.get("time", {}).get("day")))
	_fin("8")

## Nodo con spawn_position/zone via script creado en runtime (para probar el
## duck-typing del proveedor sin depender de un script ajeno).
func _nodo_con_props() -> Node3D:
	var scr := GDScript.new()
	scr.source_code = "extends Node3D\nvar spawn_position: Vector3 = Vector3.ZERO\nvar zone: String = \"\"\n"
	if scr.reload() != OK:
		return null
	var n := Node3D.new()
	n.set_script(scr)
	return n

## Contrato COMPLETO del PlayerSaveProvider (iter. 3). Antes se guardaba
## `spawn_position` pero nunca se restauraba.
func _b9_player_provider() -> void:
	_abrir("9", "PlayerSaveProvider: contrato completo con nodo inyectado")
	var prov = PlayerSaveProvider.new()
	_ok(prov.get_save_data().is_empty(), "sin nodo Player -> {} (no inventa datos)")

	var p := Node3D.new()
	p.name = "Player"
	root.add_child(p)
	p.global_position = Vector3(4.0, 0.0, 4.0)
	var d: Dictionary = prov.get_save_data()
	_ok(d.size() == 4, "con Player devuelve las 4 claves del schema (dio %d)" % d.size())
	_ok(d.get("spawn_position") == d.get("position"),
		"sin propiedad spawn_position en el nodo, se usa la posicion actual (documentado)")
	p.global_position = Vector3.ZERO
	prov.restore_save_data({"name": "X", "position": [10.0, 5.0, -3.0],
		"spawn_position": [1.0, 2.0, 3.0], "zone": "playa"})
	_ok(p.global_position == Vector3(10.0, 5.0, -3.0),
		"restaura position (dio %s)" % str(p.global_position))
	_ok(p.name == "Player",
		"NO renombra el nodo al restaurar 'name' (sigue '%s')" % p.name)
	root.remove_child(p)
	p.free()

	var q := _nodo_con_props()
	if q == null:
		_ok(false, "no se pudo crear el nodo con spawn_position/zone (script runtime)")
		_fin("9")
		return
	q.name = "Player"
	root.add_child(q)
	q.global_position = Vector3(7.0, 0.0, 7.0)
	q.set("spawn_position", Vector3(9.0, 9.0, 9.0))
	q.set("zone", "cueva")
	var d2: Dictionary = prov.get_save_data()
	_ok(d2.get("spawn_position") == [9.0, 9.0, 9.0],
		"lee spawn_position del nodo si existe (dio %s)" % str(d2.get("spawn_position")))
	_ok(String(d2.get("zone")) == "cueva",
		"lee zone del nodo si existe (dio '%s')" % String(d2.get("zone")))
	prov.restore_save_data({"position": [1.0, 1.0, 1.0],
		"spawn_position": [2.0, 3.0, 4.0], "zone": "playa"})
	_ok(q.get("spawn_position") == Vector3(2.0, 3.0, 4.0),
		"RESTAURA spawn_position si el nodo la expone (dio %s)" % str(q.get("spawn_position")))
	_ok(String(q.get("zone")) == "playa",
		"RESTAURA zone si el nodo la expone (dio '%s')" % String(q.get("zone")))
	root.remove_child(q)
	q.free()
	_fin("9")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	var sm = root.get_node_or_null("/root/SaveManager")
	_ok(sm != null, "SaveManager autoload presente")
	if sm == null:
		return
	_b1_camino_real(sm)
	_b2_rotacion_preserva_anterior(sm)
	_b3_interrumpido(sm)
	_b4_backup_futuro(sm)
	_b5_control_vacio(sm)
	_b6_metadatos_reales(sm)
	_b7_tmp_huerfano(sm)
	_b8_completar_defaults(sm)
	_b9_player_provider()
	_limpia()
	sm.current_slot = -1

## Corre en un call_deferred separado: si _run() aborta por un error de
## runtime, este resumen igual se ejecuta y delata los bloques sin cerrar.
func _summary() -> void:
	print("=== RESUMEN M59 ROTACION: %d checks, %d fallos, %d bloques cerrados ===" % [
		_checks, _fallos, _cerrados.size()])
	var abortado := false
	if not _abiertos.is_empty():
		abortado = true
		print("  BLOQUES QUE NO CERRARON (abortados por un error de runtime):")
		for clave in _abiertos.keys():
			print("    - [%s] %s" % [clave, _abiertos[clave]])
	if _checks < CHECKS_MINIMOS:
		abortado = true
		print("  PISO NO CUMPLIDO: %d checks < CHECKS_MINIMOS=%d (suite muerta o recortada)" % [
			_checks, CHECKS_MINIMOS])
	if abortado:
		print("RESULTADO: FALLO (suite incompleta)")
		quit(1)
		return
	if _fallos > 0:
		print("RESULTADO: FALLO (%d)" % _fallos)
		quit(1)
	else:
		print("RESULTADO: OK")
		quit(0)
