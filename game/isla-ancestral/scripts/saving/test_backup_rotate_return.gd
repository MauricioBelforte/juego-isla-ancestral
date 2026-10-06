# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-06
#
# Cola M59 / BUG-112: rotate() debe reportar los fallos de rename.
#
# Antes, `rotate()` descartaba el retorno de DirAccess.rename_absolute
# (`var _e := ...`) y devolvia void: un fallo (disco lleno, permisos, archivo
# bloqueado) dejaba la rotacion parcial EN SILENCIO y rompia la premisa "siempre
# hay un backup valido".
#
# Fix: rotate() devuelve bool (true = rotacion OK o nada que rotar; false = algun
# rename fallo) y loguea cada fallo.
#
# RED por inyeccion: si rotate() vuelve a devolver siempre true, el caso C falla.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_backup_rotate_return.gd

extends SceneTree

## Piso MEDIDO en verde (5 checks).
const CHECKS_MINIMOS := 4

## Slot de prueba aislado.
const SLOT := 98

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_recursive_absolute("user://saves")
	_limpiar()

	# A) Sin save que rotar -> true (nada que hacer, no es un fallo).
	_check(SaveBackup.rotate(SLOT) == true, "sin save -> rotate() true")

	# B) Con save y sin bloqueos -> true y crea r1.bak.
	_escribir(_save_path(), _doc("B"))
	_check(SaveBackup.rotate(SLOT) == true, "con save -> rotate() true")
	_check(FileAccess.file_exists(_bak_path(1)), "rotate() crea la rotacion r1")

	# C) Destino bloqueado (r1.bak es un directorio NO vacio) -> rename falla -> false.
	_limpiar()
	_escribir(_save_path(), _doc("C"))
	_mkdir_no_vacio(_bak_path(1))
	_check(SaveBackup.rotate(SLOT) == false, "rename bloqueado -> rotate() false (BUG-112)")

	_limpiar()
	_resumen()

func _doc(marca: String) -> String:
	var p: Dictionary = SaveSchema.default_payload("slot_%d" % SLOT)
	p["meta"]["last_saved"] = marca
	return SaveWriter.build_file_content(SaveWriter.serialize_payload(p))

func _save_path() -> String:
	return "user://saves/slot_%d.save" % SLOT

func _bak_path(rot: int) -> String:
	return "user://saves/slot_%d_r%d.bak" % [SLOT, rot]

func _escribir(path: String, content: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(content)
		f.close()

func _mkdir_no_vacio(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path)
	var f := FileAccess.open(path + "/x.txt", FileAccess.WRITE)
	if f != null:
		f.store_string("x")
		f.close()

func _limpiar() -> void:
	for p in [_save_path(), _bak_path(1), _bak_path(2)]:
		if DirAccess.dir_exists_absolute(p):
			var d := DirAccess.open(p)
			if d != null:
				d.list_dir_begin()
				var n := d.get_next()
				while n != "":
					d.remove(n)
					n = d.get_next()
				d.list_dir_end()
			DirAccess.remove_absolute(p)
		elif FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _resumen() -> void:
	print("=== TEST BACKUP-ROTATE-RETURN: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("TEST BACKUP-ROTATE-RETURN FALLIDO - solo %d checks (piso %d): un bloque aborto en silencio" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	quit(1 if _fallos > 0 else 0)
