# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-06
#
# Cola M59 / BUG-109: cap de tamano antes de leer un save entero a memoria.
#
# Antes, los 3 puntos de lectura (save_loader.load, save_manager.slot_metadata,
# save_backup.read_latest_backup) hacian FileAccess.get_file_as_string(path) sin
# comprobar existencia ni tamano: un save fabricado de GBs (el checksum no es
# anti-trampas, ver BUG-115) se cargaba entero -> OOM.
#
# Fix: SaveWriter.read_document(path) verifica existencia y tamano (cap
# MAX_DOCUMENT_BYTES) antes de leer. Esta sonda afirma:
#   - un documento valido chico se lee y parsea;
#   - un documento de EXACTAMENTE el cap SI se lee (el limite es `>`);
#   - un documento de cap+1 NO se lee (devuelve "") y por tanto no parsea.
#
# RED por inyeccion: si se desactiva el cap en read_document, los checks de
# cap+1 fallan (el archivo grande SI se leeria).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_save_size_cap.gd

extends SceneTree

## Piso MEDIDO en verde (7 checks).
const CHECKS_MINIMOS := 6

const DIR_SAVES := "user://saves"
const P_SMALL := "user://saves/_probe_cap_small.save"
const P_AT := "user://saves/_probe_cap_at.save"
const P_OVER := "user://saves/_probe_cap_over.save"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not DirAccess.dir_exists_absolute(DIR_SAVES):
		DirAccess.make_dir_recursive_absolute(DIR_SAVES)
	_limpiar()

	var cap: int = SaveWriter.MAX_DOCUMENT_BYTES
	_check(cap > 0, "MAX_DOCUMENT_BYTES definido (> 0) = %d" % cap)

	# 1) Control: un documento valido chico se lee entero y parsea.
	var payload := {"schema_version": 1, "probe": "ok"}
	var doc := SaveWriter.build_file_content(SaveWriter.serialize_payload(payload))
	_escribir(P_SMALL, doc)
	var leido := SaveWriter.read_document(P_SMALL)
	_check(leido == doc, "documento chico se lee entero")
	_check(SaveWriter.parse_document(leido).get("ok", false), "documento chico parsea OK")

	# 2) Borde: un documento de EXACTAMENTE el cap SI se lee (limite es `>`).
	_escribir(P_AT, _doc_de_bytes(cap))
	var at := SaveWriter.read_document(P_AT)
	_check(at.length() == cap, "documento de exactamente cap (%d bytes) SI se lee" % cap)

	# 3) Guardia: un documento de cap+1 NO se lee (devuelve "") -> no parsea.
	_escribir(P_OVER, _doc_de_bytes(cap + 1))
	var over := SaveWriter.read_document(P_OVER)
	_check(over == "", "documento de cap+1 (%d bytes) NO se lee" % (cap + 1))
	_check(not SaveWriter.parse_document(over).get("ok", false),
		"documento over-cap no parsea como valido (no se materializa)")

	# 4) Ruta inexistente -> "".
	_check(SaveWriter.read_document("user://saves/_no_existe.save") == "",
		"ruta inexistente devuelve ''")

	_limpiar()
	_resumen()

## Construye un documento de save VALIDO de exactamente `bytes` bytes.
## El total es checksum(64) + "\n"(1) + payload; el payload JSON crece 1:1 con el
## relleno, asi que se calcula el relleno a partir del documento con relleno vacio.
func _doc_de_bytes(bytes: int) -> String:
	var base := SaveWriter.build_file_content(SaveWriter.serialize_payload({"schema_version": 1, "filler": ""}))
	var extra := bytes - base.length()
	if extra < 0:
		return base
	return SaveWriter.build_file_content(SaveWriter.serialize_payload({"schema_version": 1, "filler": "a".repeat(extra)}))

func _escribir(path: String, content: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(content)
		f.close()

func _limpiar() -> void:
	for p in [P_SMALL, P_AT, P_OVER]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _resumen() -> void:
	print("=== TEST SAVE-SIZE-CAP: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("TEST SAVE-SIZE-CAP FALLIDO - solo %d checks (piso %d): un bloque aborto en silencio" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	quit(1 if _fallos > 0 else 0)
