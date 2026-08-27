# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Checkpoint Manager
# 3 slots por bioma (rotativo) + 1 slot global de emergencia.
# Escritura atómica reusando el patrón establecido en M59 (SaveWriter).

## Checkpoints rotativos: 3 por bioma + 1 emergencia global. Escritura atómica.
class_name CheckpointManager
extends Node

## Slots por bioma (rotativo)
const SLOTS_POR_BIOMA: int = 3

## Slot global de emergencia
const SLOT_GLOBAL: int = -1

## Bioma actual
var bioma_actual: String = "aurora"

## Índice rotativo del último checkpoint por bioma
var _next_slot: Dictionary = {}

## Slot del último checkpoint global
var _last_global: int = 0

## Ruta base de checkpoints (subdirectorio de user://)
const CHECKPOINT_DIR: String = "user://checkpoints/"

func _ready() -> void:
	_ensure_dir()

## Crea el directorio de checkpoints si no existe.
func _ensure_dir() -> void:
	if not DirAccess.dir_exists_absolute(CHECKPOINT_DIR):
		var err := DirAccess.make_dir_absolute(CHECKPOINT_DIR)
		if err != OK:
			push_warning("[M66] No se pudo crear %s (err=%d)" % [CHECKPOINT_DIR, err])

## Escucha eventos de checkpoint del SoftlockGuard.
func registrar_checkpoint(bioma: String, evento: String, payload: Dictionary) -> bool:
	if bioma == "__global__":
		return _escribir_checkpoint_atomico("global_%d" % _last_global, payload)

	# Slot rotativo por bioma
	if not _next_slot.has(bioma):
		_next_slot[bioma] = 0
	var slot := int(_next_slot[bioma])
	var ok := _escribir_checkpoint_atomico("%s_%d" % [bioma, slot], payload)
	if ok:
		_next_slot[bioma] = (slot + 1) % SLOTS_POR_BIOMA
		if bioma == "__global__":
			_last_global += 1
	return ok

## Escribe un checkpoint con el patrón atómico tmp+rename+.bak (reutiliza SaveWriter).
func _escribir_checkpoint_atomico(filename_base: String, payload: Dictionary) -> bool:
	var final_path := "%s%s.save" % [CHECKPOINT_DIR, filename_base]
	var tmp_path := "%s.tmp" % final_path
	var bak_path := "%s.bak" % final_path

	# Serializar + checksum (reutiliza SaveWriter)
	var content := SaveWriter.build_file_content(SaveWriter.serialize_payload(payload))
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		return false
	var ok := file.store_string(content)
	file.close()
	if not ok:
		return false

	# Verificar .tmp antes del rename
	var written := FileAccess.get_file_as_string(tmp_path)
	if not SaveWriter.parse_document(written).get("ok", false):
		DirAccess.remove_absolute(tmp_path)
		return false

	# Backup del anterior (.bak) antes del rename
	if FileAccess.file_exists(final_path):
		if FileAccess.file_exists(bak_path):
			DirAccess.remove_absolute(bak_path)
		DirAccess.rename_absolute(final_path, bak_path)

	# Rename atómico
	var err := DirAccess.rename_absolute(tmp_path, final_path)
	return err == OK

## Lee el checkpoint más reciente de un bioma (para recovery).
func leer_checkpoint(bioma: String) -> Dictionary:
	if not DirAccess.dir_exists_absolute(CHECKPOINT_DIR):
		return {}

	if bioma == "__global__":
		var best := ""
		var best_slot := -1
		var dir := DirAccess.open(CHECKPOINT_DIR)
		if dir:
			dir.list_dir_begin()
			var name := dir.get_next()
			while name != "":
				if name.begins_with("global_") and name.ends_with(".save"):
					var slot_num := name.trim_suffix(".save").trim_prefix("global_").to_int()
					if slot_num > best_slot:
						best_slot = slot_num
						best = name
				name = dir.get_next()
			dir.list_dir_end()
		if best != "":
			var content := FileAccess.get_file_as_string("%s%s" % [CHECKPOINT_DIR, best])
			return SaveWriter.parse_document(content).get("payload", {})
		return {}

	# Último slot rotativo escrito
	var slot := int((_next_slot.get(bioma, 0) as int) - 1 + SLOTS_POR_BIOMA) % SLOTS_POR_BIOMA
	var path := "%s%s_%d.save" % [CHECKPOINT_DIR, bioma, slot]
	if FileAccess.file_exists(path):
		var content := FileAccess.get_file_as_string(path)
		return SaveWriter.parse_document(content).get("payload", {})
	# Fallback: buscar el más reciente existente
	var dir := DirAccess.open(CHECKPOINT_DIR)
	if dir:
		dir.list_dir_begin()
		var best_name := ""
		var best_mtime := 0
		var name := dir.get_next()
		while name != "":
			if name.begins_with("%s_" % bioma) and name.ends_with(".save"):
				var mtime := FileAccess.get_modified_time("%s%s" % [CHECKPOINT_DIR, name])
				if mtime > best_mtime:
					best_mtime = mtime
					best_name = name
			name = dir.get_next()
		dir.list_dir_end()
		if best_name != "":
			var content := FileAccess.get_file_as_string("%s%s" % [CHECKPOINT_DIR, best_name])
			return SaveWriter.parse_document(content).get("payload", {})
	return {}
