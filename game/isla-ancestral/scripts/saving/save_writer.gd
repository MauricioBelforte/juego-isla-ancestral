class_name SaveWriter
extends RefCounted

## Módulo 59: Guardado — Escritura atómica con checksum
##
## Regla dura del módulo: NUNCA escribir sobre el save actual.
## Se escribe a slot_N.tmp → se verifica que el .tmp no quedó vacío → se
## renombra a slot_N.save (rename atómico del SO). Ante cualquier fallo el
## save anterior queda intacto.
##
## Formato del archivo (DETERMINISTA para el checksum):
##   línea 1: checksum SHA-256 hex del payload_str
##   línea 2+: payload JSON (la cadena EXACTA tal como se serializó)
## El checksum se calcula sobre el payload_str literal, así que re-serializar
## no introduce indeterminismo (cualquier byte alterado se detecta).

## Prefijo de archivos temporales
const TMP_SUFFIX: String = ".tmp"

## Sufijo del archivo final
const SAVE_SUFFIX: String = ".save"

## Calcula el SHA-256 en hexa de una cadena usando HashingContext.
static func sha256_hex_str(s: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(s.to_utf8_buffer())
	var digest := ctx.finish()
	var hex := ""
	for b in digest:
		hex += "%02x" % b
	return hex

## Devuelve el payload serializado a JSON (string canónico del momento).
static func serialize_payload(payload: Dictionary) -> String:
	return JSON.stringify(payload)

## Construye el contenido completo del archivo: checksum\npayload
static func build_file_content(payload_str: String) -> String:
	var checksum := sha256_hex_str(payload_str)
	return checksum + "\n" + payload_str

## Verifica y parsea el contenido de un archivo de save.
## Devuelve { ok: bool, reason: String, checksum: String, payload_str: String, payload: Variant }
static func parse_document(content: String) -> Dictionary:
	if content.is_empty():
		return {"ok": false, "reason": "contenido vacío", "checksum": "", "payload_str": "", "payload": null}
	var newline := content.find("\n")
	if newline <= 0:
		return {"ok": false, "reason": "formato inválido", "checksum": "", "payload_str": "", "payload": null}
	var checksum := content.substr(0, newline)
	var payload_str := content.substr(newline + 1)
	if sha256_hex_str(payload_str) != checksum:
		return {"ok": false, "reason": "checksum no coincide", "checksum": checksum, "payload_str": payload_str, "payload": null}
	var payload: Variant = JSON.parse_string(payload_str)
	if typeof(payload) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "payload no es JSON objeto", "checksum": checksum, "payload_str": payload_str, "payload": null}
	return {"ok": true, "reason": "", "checksum": checksum, "payload_str": payload_str, "payload": payload}

## Escribe un payload de forma atómica en el slot dado.
## Devuelve true si se escribió correctamente, false ante cualquier fallo.
static func write_atomic(slot: int, payload: Dictionary) -> bool:
	var dir := DirAccess.open(SaveSchema.SAVE_DIR)
	if dir == null:
		dir = DirAccess.open("user://")
		if dir == null or dir.make_dir_recursive(SaveSchema.SAVE_DIR) != OK:
			printerr("[SAVE] No se pudo crear el directorio de saves")
			return false

	var content := build_file_content(serialize_payload(payload))
	var tmp_path := "%s/slot_%d%s" % [SaveSchema.SAVE_DIR, slot, TMP_SUFFIX]
	var final_path := "%s/slot_%d%s" % [SaveSchema.SAVE_DIR, slot, SAVE_SUFFIX]

	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		printerr("[SAVE] No se pudo abrir %s" % tmp_path)
		return false
	# store_string devuelve bool desde Godot 4.4+ (skill save-load, notas 4.4→4.7):
	# nunca asumir éxito de escritura.
	var write_ok: bool = file.store_string(content)
	file.close()
	if not write_ok:
		printerr("[SAVE] Fallo de escritura en %s (disco lleno o permisos)" % tmp_path)
		return false

	# Verificar que el .tmp no quedó vacío ni corrompido antes del rename
	var written := FileAccess.get_file_as_string(tmp_path)
	if parse_document(written).get("ok", false) == false:
		printerr("[SAVE] .tmp no superó verificación interna")
		return false

	# Rename atómico: reemplaza slot_N.save si existe, crea si no
	var err := DirAccess.rename_absolute(tmp_path, final_path)
	if err != OK:
		printerr("[SAVE] Falló el rename atómico (err=%d)" % err)
		return false

	return true

## Limpia un .tmp huérfano de un slot (tras arranque o fallo anterior).
static func cleanup_orphan_tmp(slot: int) -> void:
	var tmp_path := "%s/slot_%d%s" % [SaveSchema.SAVE_DIR, slot, TMP_SUFFIX]
	if FileAccess.file_exists(tmp_path):
		DirAccess.remove_absolute(tmp_path)

## Devuelve true si existe un save en el slot.
static func save_exists(slot: int) -> bool:
	return FileAccess.file_exists("%s/slot_%d%s" % [SaveSchema.SAVE_DIR, slot, SAVE_SUFFIX])

## Ruta del archivo final de un slot.
static func path_for(slot: int) -> String:
	return "%s/slot_%d%s" % [SaveSchema.SAVE_DIR, slot, SAVE_SUFFIX]
