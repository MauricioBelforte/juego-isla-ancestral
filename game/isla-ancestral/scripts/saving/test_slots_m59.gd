# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-02
#
# M59 iter. 1: metadatos por slot (D) y carga de version futura (V).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_slots_m59.gd
#
# Guardia anti-falso-verde de 3 capas (misma doctrina que M62):
#   1) _fin(clave) cierra cada bloque: un bloque que no cierra NO corrio.
#   2) CHECKS_MINIMOS: piso MEDIDO EN VERDE (no estimado, no copiado).
#   3) _summary() en call_deferred separado: sobrevive a un SCRIPT ERROR que
#      aborte _run() (que dejaria las aserciones sin ejecutar) y decide el
#      exit code. Sin esto, un abort daria "0 fallos" FALSO.
#
# No usa class_name: evita depender del cache de clases globales en headless.

extends SceneTree

## Piso de checks. MEDIDO en la primera corrida VERDE (22) y fijado aqui.
## Si el conteo baja de 22, un bloque dejo de ejercitarse (regresion o suite
## recortada) y la suite falla aunque no haya un [FALLO] explicito.
const CHECKS_MINIMOS: int = 22

## Slot real usado por la suite (dentro de SLOT_COUNT=3 para poder usar load_slot)
const SLOT_PRUEBA: int = 3

## Slot fuera de rango: write_atomic acepta cualquier int y load_slot no lo usa.
const SLOT_FANTASMA: int = 99

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}      # clave -> descripcion (clave = id del bloque)
var _slot_previo: Dictionary = {}

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

# ── preservacion del slot real (no pisar saves de otras suites) ───────────

func _backup_slot() -> void:
	var path: String = SaveWriter.path_for(SLOT_PRUEBA)
	if FileAccess.file_exists(path):
		_slot_previo = {"existia": true, "contenido": FileAccess.get_file_as_string(path)}
	else:
		_slot_previo = {"existia": false, "contenido": ""}

func _restore_slot() -> void:
	# Desactivar el guardado de cierre: el manager escribe si current_slot >= 1.
	var sm = root.get_node_or_null("/root/SaveManager")
	if sm != null:
		sm.current_slot = -1
	var path: String = SaveWriter.path_for(SLOT_PRUEBA)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if bool(_slot_previo.get("existia", false)):
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f != null:
			f.store_string(String(_slot_previo.get("contenido", "")))
			f.close()
	SaveWriter.cleanup_orphan_tmp(SLOT_PRUEBA)
	SaveWriter.cleanup_orphan_tmp(SLOT_FANTASMA)
	var ghost: String = SaveWriter.path_for(SLOT_FANTASMA)
	if FileAccess.file_exists(ghost):
		DirAccess.remove_absolute(ghost)

# ── bloques ──────────────────────────────────────────────────────────────

## D: "Mostrar metadatos por slot (hora, dia, progreso)".
## El bug corregido: slot_metadata() hacia JSON.parse_string() del ARCHIVO
## COMPLETO, cuya primera linea es el checksum hex -> siempre devolvia {}.
func _b1_metadatos(sm) -> void:
	_abrir("1", "slot_metadata devuelve dia/version/last_saved")
	var p: Dictionary = SaveSchema.default_payload("perfil_test")
	p["time"]["day"] = 42
	p["meta"]["last_saved"] = "2026-10-02 20:00"
	_ok(SaveWriter.write_atomic(SLOT_PRUEBA, p), "write_atomic escribe el slot de prueba")
	var meta: Dictionary = sm.slot_metadata(SLOT_PRUEBA)
	_ok(not meta.is_empty(),
		"slot_metadata NO vacio (regresion: parseaba checksum+payload entero como JSON)")
	if not meta.is_empty():
		_ok(int(meta.get("day", -1)) == 42, "day == 42 (dio %s)" % str(meta.get("day")))
		_ok(int(meta.get("version", -1)) == SaveSchema.SCHEMA_VERSION,
			"version == %d (dio %s)" % [SaveSchema.SCHEMA_VERSION, str(meta.get("version"))])
		_ok(String(meta.get("last_saved", "")) == "2026-10-02 20:00",
			"last_saved correcto (dio '%s')" % String(meta.get("last_saved", "")))
	_fin("1")

## Bordes: sin save y con save invalido (no debe crashear ni inventar datos).
func _b2_bordes(sm) -> void:
	_abrir("2", "slot_metadata: slot inexistente y save corrupto")
	var ghost: String = SaveWriter.path_for(SLOT_FANTASMA)
	if FileAccess.file_exists(ghost):
		DirAccess.remove_absolute(ghost)
	_ok(sm.slot_metadata(SLOT_FANTASMA).is_empty(), "slot inexistente -> {}")

	# 2a) archivo que no es un save (sin cabecera de checksum)
	var f := FileAccess.open(ghost, FileAccess.WRITE)
	_ok(f != null, "se pudo crear el archivo corrupto de prueba")
	if f != null:
		f.store_string("esto no es un save valido\n{\"x\": 1}")
		f.close()
	_ok(sm.slot_metadata(SLOT_FANTASMA).is_empty(), "save ilegible -> {} sin crash")

	# 2b) cabecera de checksum VALIDA en forma pero que NO coincide
	var f2 := FileAccess.open(ghost, FileAccess.WRITE)
	if f2 != null:
		var falso := "0".repeat(64)
		f2.store_string(falso + "\n" + SaveWriter.serialize_payload(SaveSchema.default_payload("x")))
		f2.close()
	_ok(sm.slot_metadata(SLOT_FANTASMA).is_empty(), "checksum que no coincide -> {} (no acepta basura)")
	DirAccess.remove_absolute(ghost)
	_fin("2")

## V: "Cargar con version futura (aviso claro)".
func _b3_version_futura(sm) -> void:
	_abrir("3", "version futura: detectada, avisada y sin degradar")
	var futura: int = SaveSchema.SCHEMA_VERSION + 1
	var p: Dictionary = SaveSchema.default_payload("perfil_test")
	p["schema_version"] = futura
	p["time"]["day"] = 7
	_ok(SaveWriter.write_atomic(SLOT_PRUEBA, p), "se escribio un save de version futura (v%d)" % futura)

	var meta: Dictionary = sm.slot_metadata(SLOT_PRUEBA)
	_ok(int(meta.get("version", -1)) == futura,
		"slot_metadata reporta la version futura v%d sin degradarla (dio %s)" % [futura, str(meta.get("version"))])

	var slot_antes: int = sm.current_slot
	var codigos: Array = []
	var cb := func(slot: int, code: int) -> void:
		if slot == SLOT_PRUEBA:
			codigos.append(code)
	sm.slot_loaded.connect(cb)
	var code: int = sm.load_slot(SLOT_PRUEBA)
	sm.slot_loaded.disconnect(cb)
	_ok(code == SaveLoader.LoadResult.FUTURE_VERSION,
		"load_slot devuelve FUTURE_VERSION (dio %d)" % code)
	_ok(codigos.has(SaveLoader.LoadResult.FUTURE_VERSION),
		"la senal slot_loaded lleva FUTURE_VERSION a la UI (M53)")
	_ok(sm.current_slot == slot_antes,
		"current_slot NO cambia al rechazar la version futura (dio %d, esperaba %d)" % [sm.current_slot, slot_antes])
	_fin("3")

## El rechazo no debe MODIFICAR el archivo (regla: nunca degradar un save).
func _b4_no_degrada(sm) -> void:
	_abrir("4", "el save de version futura sigue intacto en disco")
	var content: String = FileAccess.get_file_as_string(SaveWriter.path_for(SLOT_PRUEBA))
	var parsed: Dictionary = SaveWriter.parse_document(content)
	_ok(bool(parsed.get("ok", false)), "el archivo sigue siendo un documento valido (checksum OK)")
	var payload: Dictionary = parsed.get("payload", {})
	_ok(int(payload.get("schema_version", 0)) == SaveSchema.SCHEMA_VERSION + 1,
		"schema_version en disco sigue siendo la futura (dio %s)" % str(payload.get("schema_version")))
	var time_dict: Dictionary = payload.get("time", {})
	_ok(int(time_dict.get("day", -1)) == 7, "el contenido no se toco (day == 7)")
	_fin("4")

## Regresion: el camino feliz sigue funcionando tras el cambio.
func _b5_roundtrip(sm) -> void:
	_abrir("5", "regresion: un save v1 normal hace round-trip OK")
	var p: Dictionary = SaveSchema.default_payload("perfil_test")
	p["time"]["day"] = 11
	_ok(SaveWriter.write_atomic(SLOT_PRUEBA, p), "write_atomic del save v1")
	var code: int = sm.load_slot(SLOT_PRUEBA)
	_ok(code == SaveLoader.LoadResult.OK, "load_slot devuelve OK (dio %d)" % code)
	_ok(sm.current_slot == SLOT_PRUEBA, "current_slot queda en el slot cargado (dio %d)" % sm.current_slot)
	var meta: Dictionary = sm.slot_metadata(SLOT_PRUEBA)
	_ok(int(meta.get("day", -1)) == 11, "metadatos coherentes tras cargar (day == 11)")
	_fin("5")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	var sm = root.get_node_or_null("/root/SaveManager")
	_ok(sm != null, "SaveManager autoload presente")
	if sm == null:
		return
	_backup_slot()
	_b1_metadatos(sm)
	_b2_bordes(sm)
	_b3_version_futura(sm)
	_b4_no_degrada(sm)
	_b5_roundtrip(sm)
	_restore_slot()

## Corre en un call_deferred separado: si _run() aborta por un error de
## runtime, este resumen igual se ejecuta y delata los bloques sin cerrar.
func _summary() -> void:
	print("=== RESUMEN M59 SLOTS: %d checks, %d fallos, %d bloques cerrados ===" % [
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
