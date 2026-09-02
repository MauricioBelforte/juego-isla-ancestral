# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — WriterAtomico
# Escritura segura (D4/RN3): backup .bak -> .tmp -> rename -> restauración.
# El formato de archivo es DETERMINISTA para el checksum (lección §9.11 de la
# guía 07): línea 1 = checksum CRC32 hex, líneas siguientes = payload_str EXACTO.
# El hash se calcula sobre la cadena literal guardada; jamás sobre un dict
# re-serializado.

class_name WriterAtomico
extends RefCounted

const TMP_SUFFIX: String = ".tmp"
const BAK_SUFFIX: String = ".bak"

## Escribe `contenido` de forma atómica en `ruta`:
##   1) backup del archivo actual -> ruta.bak (si existía)
##   2) escribir ruta.tmp
##   3) verificar checksum del .tmp antes del rename (contenido = checksum\npayload)
##   4) rename_absolute ruta.tmp -> ruta
##   5) si el rename falla, restaurar el .bak
## Devuelve Error (OK si tuvo éxito). El save anterior NUNCA queda corrupto.
static func escribir_atomicamente(ruta: String, contenido: String) -> Error:
	var ruta_tmp := ruta + TMP_SUFFIX
	var ruta_bak := ruta + BAK_SUFFIX

	# 1) Backup del archivo actual (RN3: el .bak sobrevive a cambios de versión)
	if FileAccess.file_exists(ruta):
		if FileAccess.file_exists(ruta_bak):
			DirAccess.remove_absolute(ruta_bak)
		var err_copy := DirAccess.copy_absolute(ruta, ruta_bak)
		if err_copy != OK:
			push_warning("[M60] No se pudo crear backup %s (err=%d)" % [ruta_bak, err_copy])

	# 2) Escribir .tmp
	var file := FileAccess.open(ruta_tmp, FileAccess.WRITE)
	if file == null:
		push_error("[M60] No se pudo abrir %s" % ruta_tmp)
		return FileAccess.get_open_error()
	var write_ok: bool = file.store_string(contenido)
	file.close()
	if not write_ok:
		push_error("[M60] Fallo de escritura en %s (disco lleno/permisos)" % ruta_tmp)
		DirAccess.remove_absolute(ruta_tmp)
		return ERR_FILE_CANT_WRITE

	# 3) Verificar que el .tmp supera el check de checksum antes del rename
	if not _verificar_documento(FileAccess.get_file_as_string(ruta_tmp)):
		push_error("[M60] .tmp no superó verificación interna (corrupto antes de rename)")
		DirAccess.remove_absolute(ruta_tmp)
		return ERR_FILE_CORRUPT

	# 4) Rename atómico
	var err_rename := DirAccess.rename_absolute(ruta_tmp, ruta)
	if err_rename != OK:
		push_error("[M60] Falló rename atómico (err=%d); restaurando .bak" % err_rename)
		if FileAccess.file_exists(ruta_bak) and FileAccess.file_exists(ruta):
			var err_restore := DirAccess.copy_absolute(ruta_bak, ruta)
			if err_restore != OK:
				push_error("[M60] No se pudo restaurar .bak tras fallo de rename")
		return err_rename

	return OK

## Restaura el .bak sobre el archivo principal (recuperación manual, M107).
## Devuelve Error.
static func restaurar_backup(ruta: String) -> Error:
	var ruta_bak := ruta + BAK_SUFFIX
	if not FileAccess.file_exists(ruta_bak):
		return ERR_FILE_NOT_FOUND
	var err := DirAccess.copy_absolute(ruta_bak, ruta)
	if err == OK:
		print("[M60] Backup restaurado: %s" % ruta)
	return err

## Construye el contenido del archivo: checksum\npayload_str (patrón §9.11).
static func construir_con_checksum(payload_str: String) -> String:
	return Validador.crc32_hex(payload_str) + "\n" + payload_str

## Parsea y verifica un documento checksum\npayload.
## Devuelve { ok, reason, checksum, payload_str, payload }
static func parsear_documento(contenido: String) -> Dictionary:
	if contenido.is_empty():
		return {"ok": false, "reason": "contenido vacío", "checksum": "", "payload_str": "", "payload": null}
	var newline := contenido.find("\n")
	if newline <= 0:
		return {"ok": false, "reason": "formato inválido", "checksum": "", "payload_str": "", "payload": null}
	var checksum := contenido.substr(0, newline)
	var payload_str := contenido.substr(newline + 1)
	if Validador.crc32_hex(payload_str) != checksum:
		return {"ok": false, "reason": "checksum no coincide", "checksum": checksum, "payload_str": payload_str, "payload": null}
	var payload: Variant = JSON.parse_string(payload_str)
	if typeof(payload) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "payload no es objeto JSON", "checksum": checksum, "payload_str": payload_str, "payload": null}
	return {"ok": true, "reason": "", "checksum": checksum, "payload_str": payload_str, "payload": payload}

static func _verificar_documento(contenido: String) -> bool:
	return parsear_documento(contenido).get("ok", false) == true

## ── Variante "cruda": para archivos que NO son JSON (ej: ConfigFile .cfg) ──

## Construye el contenido con checksum sobre texto crudo (no JSON).
static func construir_con_checksum_crudo(texto: String) -> String:
	return Validador.crc32_hex(texto) + "\n" + texto

## Verifica checksum de un documento crudo; devuelve el texto tras el checksum.
## No exige que el payload sea JSON (usado por GestorConfig).
static func parsear_documento_crudo(contenido: String) -> Dictionary:
	if contenido.is_empty():
		return {"ok": false, "reason": "contenido vacío", "checksum": "", "payload_str": ""}
	var newline := contenido.find("\n")
	if newline <= 0:
		return {"ok": false, "reason": "formato inválido", "checksum": "", "payload_str": ""}
	var checksum := contenido.substr(0, newline)
	var payload_str := contenido.substr(newline + 1)
	if Validador.crc32_hex(payload_str) != checksum:
		return {"ok": false, "reason": "checksum no coincide", "checksum": checksum, "payload_str": ""}
	return {"ok": true, "reason": "", "checksum": checksum, "payload_str": payload_str}

## Escribe con checksum sobre texto crudo (verificación solo de checksum).
static func escribir_atomicamente_crudo(ruta: String, texto: String) -> Error:
	var ruta_tmp := ruta + TMP_SUFFIX
	var ruta_bak := ruta + BAK_SUFFIX
	if FileAccess.file_exists(ruta):
		if FileAccess.file_exists(ruta_bak):
			DirAccess.remove_absolute(ruta_bak)
		DirAccess.copy_absolute(ruta, ruta_bak)
	var contenido := construir_con_checksum_crudo(texto)
	var file := FileAccess.open(ruta_tmp, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var write_ok: bool = file.store_string(contenido)
	file.close()
	if not write_ok:
		DirAccess.remove_absolute(ruta_tmp)
		return ERR_FILE_CANT_WRITE
	if not parsear_documento_crudo(FileAccess.get_file_as_string(ruta_tmp)).get("ok", false):
		DirAccess.remove_absolute(ruta_tmp)
		return ERR_FILE_CORRUPT
	var err_rename := DirAccess.rename_absolute(ruta_tmp, ruta)
	if err_rename != OK:
		if FileAccess.file_exists(ruta_bak) and FileAccess.file_exists(ruta):
			DirAccess.copy_absolute(ruta_bak, ruta)
		return err_rename
	return OK