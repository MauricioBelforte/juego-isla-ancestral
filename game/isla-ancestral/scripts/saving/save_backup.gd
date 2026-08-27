class_name SaveBackup
extends RefCounted

## Módulo 59: Guardado — Rotación local de backups
##
## Al guardar, el save anterior se rota a slot_N.bak (conservando hasta
## MAX_ROTATIONS rotaciones). Los backups manuales se guardan con fecha.
## El backup 3-2-1 externo es responsabilidad de M107; aquí solo la
## rotación local inmediata para recuperación rápida.

## Máximo de rotaciones locales que se conservan por slot
const MAX_ROTATIONS: int = 2

const BAK_SUFFIX: String = ".bak"

## Rota el save actual de un slot hacia slot_N.bak (conservando historial).
static func rotate(slot: int) -> void:
	if not SaveWriter.save_exists(slot):
		return
	var final_path := SaveWriter.path_for(slot)

	# Desplazar backups existentes hacia atrás (el más antiguo se descarta)
	for i in range(MAX_ROTATIONS - 1, 0, -1):
		var older := _bak_path(slot, i)
		var newer := _bak_path(slot, i + 1)
		if FileAccess.file_exists(older):
			var _e := DirAccess.rename_absolute(older, newer)

	# El save actual pasa a ser la rotación 1
	DirAccess.rename_absolute(final_path, _bak_path(slot, 1))

## Crea un backup manual fechado del save actual.
## Devuelve la ruta del backup creado, o "" si falló.
static func backup_manual(slot: int) -> String:
	if not SaveWriter.save_exists(slot):
		return ""
	var final_path := SaveWriter.path_for(slot)
	var stamp := Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var dest := "%s/slot_%d_manual_%s%s" % [SaveSchema.SAVE_DIR, slot, stamp, BAK_SUFFIX]
	var err := DirAccess.copy_absolute(final_path, dest)
	if err != OK:
		printerr("[SAVE] Falló backup manual (err=%d)" % err)
		return ""
	return dest

## Devuelve la ruta de la rotación más reciente (1) de un slot.
static func latest_backup(slot: int) -> String:
	return _bak_path(slot, 1)

## Indica si existe algún backup de un slot.
static func has_any_backup(slot: int) -> bool:
	for i in range(1, MAX_ROTATIONS + 1):
		if FileAccess.file_exists(_bak_path(slot, i)):
			return true
	return false

## Devuelve el contenido leído (String) del backup más reciente, o "" si no hay.
static func read_latest_backup(slot: int) -> String:
	var path := latest_backup(slot)
	if path.is_empty() or not FileAccess.file_exists(path):
		return ""
	return FileAccess.get_file_as_string(path)

static func _bak_path(slot: int, rotation: int) -> String:
	return "%s/slot_%d_r%d%s" % [SaveSchema.SAVE_DIR, slot, rotation, BAK_SUFFIX]
