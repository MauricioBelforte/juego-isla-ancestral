# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — GestorSlot
# Slots de guardado: rutas estandarizadas, listado rápido (meta.json),
# borrado seguro. Compatible con M59: save manager delega aquí las rutas.
# Rutas (RN5 relativas a user://):
#   user://saves/slot_N/save.json       <- partida (JSON con checksum)
#   user://saves/slot_N/mundo_voxel.bin <- mundo voxel edits (binario IAVX1)
#   user://saves/slot_N/meta.json       <- meta ligera para el menú
#   user://saves/slot_N/save.json.bak   <- backup de WriterAtomico

class_name GestorSlot
extends RefCounted

const RAIZ_SAVES: String = "user://saves"
const ARCHIVO_SAVE: String = "save.json"
const ARCHIVO_VOXEL: String = "mundo_voxel.bin"
const ARCHIVO_META: String = "meta.json"
const SLOT_COUNT: int = 3

## Directorio del slot (user://saves/slot_N).
static func dir_slot(slot: int) -> String:
	return "%s/slot_%d" % [RAIZ_SAVES, slot]

## Rutas del slot: save.json, mundo_voxel.bin, meta.json, bak.
static func rutas_slot(slot: int) -> Dictionary:
	var dir := dir_slot(slot)
	return {
		"dir": dir,
		"save": "%s/%s" % [dir, ARCHIVO_SAVE],
		"voxel": "%s/%s" % [dir, ARCHIVO_VOXEL],
		"meta": "%s/%s" % [dir, ARCHIVO_META],
		"bak": "%s/%s.bak" % [dir, ARCHIVO_SAVE],
	}

## Crea el directorio del slot si no existe. Devuelve Error.
static func asegurar_directorio(slot: int) -> Error:
	var dir := dir_slot(slot)
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir)):
		return OK
	var err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	if err != OK and DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir)):
		return OK
	if err != OK:
		# intentar por open
		var d := DirAccess.open(RAIZ_SAVES)
		if d == null:
			d = DirAccess.open("user://")
			if d and d.make_dir_recursive("saves") != OK:
				return ERR_CANT_CREATE
		return OK
	return err

## true si el slot tiene save.json válido.
static func existe_slot(slot: int) -> bool:
	var r := rutas_slot(slot)
	return FileAccess.file_exists(r["save"])

## Borra el slot completo (confirmación del llamador). Devuelve bool.
static func borrar_slot(slot: int) -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		return false
	var r := rutas_slot(slot)
	var ok := true
	for clave in ["save", "voxel", "meta", "bak"]:
		var path: String = r[clave]
		if FileAccess.file_exists(path):
			if DirAccess.remove_absolute(path) != OK:
				ok = false
	var dir := dir_slot(slot)
	# intentar quitar directorio si quedó vacío
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir)):
		DirAccess.remove_absolute(dir)
	return ok

## Lista slots existentes leyendo SOLO meta.json (rápido, sin deserializar).
## Devuelve Array de Dictionary con {slot, nombre, fecha, segundos, version}.
static func listar_slots() -> Array:
	var lista: Array = []
	for i in range(1, SLOT_COUNT + 1):
		var meta := leer_meta(i)
		if meta.is_empty():
			continue
		lista.append({"slot": i, "meta": meta})
	return lista

## Lee meta.json del slot (Dictionary) o {} si no existe.
static func leer_meta(slot: int) -> Dictionary:
	var r := rutas_slot(slot)
	if not FileAccess.file_exists(r["meta"]):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(r["meta"]))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

## Escribe meta.json del slot (pequeño, para el menú de guardado).
static func escribir_meta(slot: int, meta: Dictionary) -> Error:
	var err := asegurar_directorio(slot)
	if err != OK:
		return err
	var r := rutas_slot(slot)
	var f := FileAccess.open(r["meta"], FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	var write_ok: bool = f.store_string(JSON.stringify(meta, "  "))
	f.close()
	if not write_ok:
		return ERR_FILE_CANT_WRITE
	return OK

## Meta por defecto para un slot nuevo.
static func meta_default(slot: int, nombre: String = "Aurora Año 1") -> Dictionary:
	return {
		"slot": slot,
		"nombre": nombre,
		"fecha_iso": Time.get_datetime_string_from_system(true),
		"segundos_jugados": 0.0,
		"version": 1,
		"checksum": "",
	}