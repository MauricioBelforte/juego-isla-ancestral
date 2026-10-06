# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-06
#
# Cola M59 / BUG-113: el guardado de cierre debe rotar y respetar `_writing`.
#
# Antes, `_notification(NOTIFICATION_WM_CLOSE_REQUEST)` escribia DIRECTO con
# write_atomic: sin rotar el save anterior (cierre sin backup) y sin respetar
# `_writing` (riesgo de intercalar una escritura si M61 la vuelve asincrona).
#
# Fix: el cierre replica el camino normal de forma SINCRONA: rota primero, luego
# escribe, y si `_writing` ya esta activo NO intercala (omite el guardado).
#
# Usa el slot 3 (valido) con backup/restore completo de sus archivos.
# RED: con el handler original (escritura directa sin rotar ni mirar _writing),
# los checks de rotacion y del guard _writing fallan.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_close_save.gd

extends SceneTree

## Piso MEDIDO en verde (6 checks).
const CHECKS_MINIMOS := 6

const SLOT := 3

var _fallos: int = 0
var _checks: int = 0
var _prev: Dictionary = {}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var sm = root.get_node_or_null("SaveManager")
	_check(sm != null, "SaveManager autoload presente")
	if sm == null:
		_resumen()
		return
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_recursive_absolute("user://saves")
	_backup()

	# --- Caso normal: el cierre debe ROTAR y ESCRIBIR ---
	_limpiar_slot()
	var marker := _doc("MARKER")
	_escribir(_save_path(), marker)
	sm.current_slot = SLOT
	sm.set_save_blocked(false)
	sm._writing = false
	sm._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)

	_check(FileAccess.file_exists(_bak_path(1)), "el cierre ROTA el save anterior a r1.bak (BUG-113)")
	if FileAccess.file_exists(_bak_path(1)):
		_check(FileAccess.get_file_as_string(_bak_path(1)) == marker,
			"r1.bak contiene el save anterior intacto")
	var after := FileAccess.get_file_as_string(_save_path())
	_check(after != "" and SaveWriter.parse_document(after).get("ok", false),
		"el cierre escribe un save nuevo y valido")

	# --- Guard `_writing`: si ya hay una escritura en curso, NO intercalar ---
	_limpiar_slot()
	var marker2 := _doc("MARKER2")
	_escribir(_save_path(), marker2)
	sm.current_slot = SLOT
	sm._writing = true
	sm._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	_check(FileAccess.get_file_as_string(_save_path()) == marker2,
		"con _writing=true el cierre NO reescribe el save (respeta la escritura en curso)")
	_check(not FileAccess.file_exists(_bak_path(1)),
		"con _writing=true el cierre NO rota (no intercala)")

	# limpieza
	sm._writing = false
	sm.current_slot = -1
	_restore()
	_resumen()

func _doc(marca: String) -> String:
	var p: Dictionary = SaveSchema.default_payload("slot_%d" % SLOT)
	p["meta"]["last_saved"] = marca
	return SaveWriter.build_file_content(SaveWriter.serialize_payload(p))

func _save_path() -> String:
	return "user://saves/slot_%d.save" % SLOT

func _bak_path(rot: int) -> String:
	return "user://saves/slot_%d_r%d.bak" % [SLOT, rot]

func _paths() -> Array:
	return [_save_path(), _bak_path(1), _bak_path(2)]

func _escribir(path: String, content: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(content)
		f.close()

func _limpiar_slot() -> void:
	for p in _paths():
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

func _backup() -> void:
	_prev.clear()
	for p in _paths():
		_prev[p] = FileAccess.get_file_as_string(p) if FileAccess.file_exists(p) else null

func _restore() -> void:
	for p in _paths():
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)
		var c = _prev.get(p, null)
		if c != null:
			_escribir(p, String(c))

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _resumen() -> void:
	print("=== TEST CLOSE-SAVE: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("TEST CLOSE-SAVE FALLIDO - solo %d checks (piso %d): un bloque aborto en silencio" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	quit(1 if _fallos > 0 else 0)
