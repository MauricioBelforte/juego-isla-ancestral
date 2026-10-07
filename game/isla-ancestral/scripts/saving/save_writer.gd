class_name SaveWriter
extends RefCounted

## Módulo 59: Guardado — Escritura atómica con checksum
##
## Regla dura del módulo: NUNCA escribir sobre el save actual.
## Se escribe a slot_N.tmp → se verifica que el .tmp no quedó vacío → se
## renombra a slot_N.save (rename atómico del SO). Ante cualquier fallo el
## save anterior queda intacto.
##
## Formato del archivo (DETERMINISTA para el token de integridad):
##   línea 1: token de integridad del payload_str
##   línea 2+: payload JSON (la cadena EXACTA tal como se serializó)
## El token se calcula sobre el payload_str literal, así que re-serializar
## no introduce indeterminismo (cualquier byte alterado se detecta).
##
## BUG-115 (fix real): el token es un HMAC-SHA256 con clave por instalación
## (`hmac256:<hex>`). Antes era un SHA-256 del payload EN CLARO sin secreto, así
## que cualquiera podía editar el save y recalcular el checksum. El formato es
## RETROCOMPATIBLE: un token SIN prefijo se interpreta como el SHA-256 legado y
## se sigue aceptando (los saves previos al fix siguen cargando). La clave vive
## en `user://saves/clave_integridad.key`; si se pierde, sólo dejan de verificar
## los saves HMAC (los legados no dependen de la clave).

## Prefijo de archivos temporales
const TMP_SUFFIX: String = ".tmp"

## Sufijo del archivo final
const SAVE_SUFFIX: String = ".save"

## Cap de tamano (bytes) para leer un documento de save a memoria (BUG-109).
## Un save real ronda los pocos KB (~4.6 KB medidos); 2 MB da ~450x de margen sin
## permitir que un archivo fabricado agote la memoria al leerse entero. El cap se
## aplica ANTES de leer, así que no depende del token de integridad (que sólo se
## verifica después de tener el contenido en memoria).
const MAX_DOCUMENT_BYTES: int = 2 * 1024 * 1024

## Prefijo del token de integridad HMAC-SHA256 (BUG-115). Un token SIN este
## prefijo es un SHA-256 legado (formato previo al fix) y se acepta igual.
const CHECKSUM_PREFIX: String = "hmac256:"

## Longitud (bytes) de la clave HMAC por instalación.
const KEY_LEN: int = 32

## Ruta de la clave HMAC por instalación (hex de KEY_LEN bytes). Vive en la raíz
## de `user://`, FUERA de SAVE_DIR: las suites de prueba y `_delete_save_dir()`
## borran el contenido de `user://saves`, y la clave debe sobrevivir a eso (si no,
## los saves escritos antes del borrado quedarían sin poder verificarse).
const KEY_PATH: String = "user://clave_integridad.key"

## Caché de la clave en memoria (evita releer el archivo en cada escritura).
static var _clave_cache: PackedByteArray = PackedByteArray()

## Lee un documento verificando existencia y tamano ANTES de cargarlo entero a
## memoria. Devuelve "" si no existe, no se puede abrir o excede el cap (BUG-109).
static func read_document(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var size := f.get_length()
	f.close()
	if size > MAX_DOCUMENT_BYTES:
		push_error("[SAVE] Documento %s excede el cap (%d > %d bytes); no se lee (BUG-109)" % [path, size, MAX_DOCUMENT_BYTES])
		return ""
	return FileAccess.get_file_as_string(path)

## Calcula el SHA-256 en hexa de una cadena usando HashingContext.
##
## LEGADO (BUG-115): formato previo al fix, sin secreto. Se conserva SOLO para
## poder VERIFICAR saves escritos antes del fix (retrocompatibilidad). NO se usa
## para escribir: `build_file_content()` emite HMAC-SHA256.
static func sha256_hex_str(s: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(s.to_utf8_buffer())
	var digest := ctx.finish()
	var hex := ""
	for b in digest:
		hex += "%02x" % b
	return hex

## Carga (o genera una vez) la clave HMAC por instalación.
##
## BUG-115: la clave vive en `user://saves/clave_integridad.key` como hex de
## KEY_LEN bytes aleatorios de Crypto. Si el archivo falta se genera; si está
## corrupto se regenera (con aviso: los saves HMAC previos dejan de verificar,
## no hay forma de recuperarlos sin la clave). Ante fallo de escritura se
## devuelve una clave efímera de sesión (coherente mientras dure el proceso).
static func _cargar_o_generar_clave() -> PackedByteArray:
	if _clave_cache.size() == KEY_LEN:
		return _clave_cache
	if FileAccess.file_exists(KEY_PATH):
		var hex := FileAccess.get_file_as_string(KEY_PATH).strip_edges()
		if hex.length() == KEY_LEN * 2 and hex.is_valid_hex_number(false):
			_clave_cache = hex.hex_decode()
			return _clave_cache
		push_error("[SAVE] Clave de integridad corrupta en %s; se regenera (BUG-115)" % KEY_PATH)
	var clave: PackedByteArray = Crypto.new().generate_random_bytes(KEY_LEN)
	var f := FileAccess.open(KEY_PATH, FileAccess.WRITE)
	if f == null:
		push_error("[SAVE] No se pudo persistir la clave de integridad; se usa una efímera (BUG-115)")
		_clave_cache = clave
		return clave
	f.store_string(clave.hex_encode())
	f.close()
	_clave_cache = clave
	return clave

## Comparación en tiempo (razonablemente) constante de dos cadenas.
static func _igualdad_constante(a: String, b: String) -> bool:
	if a.length() != b.length():
		return false
	var diff := 0
	for i in a.length():
		diff |= a.unicode_at(i) ^ b.unicode_at(i)
	return diff == 0

## Firma un payload con HMAC-SHA256 y la clave por instalación (BUG-115).
## Devuelve `hmac256:<hex>`, o "" si HMACContext no pudo iniciarse (el llamador
## debe tratar "" como fallo; `build_file_content` produciría un documento que
## `parse_document` rechaza, así que `write_atomic` no llega a renombrar).
static func firmar_payload(payload_str: String) -> String:
	var clave := _cargar_o_generar_clave()
	var ctx := HMACContext.new()
	if ctx.start(HashingContext.HASH_SHA256, clave) != OK:
		push_error("[SAVE] HMACContext.start falló; no se puede firmar (BUG-115)")
		return ""
	ctx.update(payload_str.to_utf8_buffer())
	return CHECKSUM_PREFIX + ctx.finish().hex_encode()

## Verifica el token de integridad de un payload. Acepta el HMAC nuevo
## (`hmac256:<hex>`) y el SHA-256 legado (64 hex sin prefijo) — BUG-115.
static func verificar_checksum(payload_str: String, checksum: String) -> bool:
	if checksum.begins_with(CHECKSUM_PREFIX):
		var esperado := firmar_payload(payload_str)
		return esperado != "" and _igualdad_constante(esperado, checksum)
	return _igualdad_constante(sha256_hex_str(payload_str), checksum)

## Devuelve el payload serializado a JSON (string canónico del momento).
static func serialize_payload(payload: Dictionary) -> String:
	return JSON.stringify(payload)

## Construye el contenido completo del archivo: token\npayload
## El token es el HMAC-SHA256 (BUG-115), retrocompatible en lectura.
static func build_file_content(payload_str: String) -> String:
	return firmar_payload(payload_str) + "\n" + payload_str

## Verifica y parsea el contenido de un archivo de save.
## Devuelve { ok: bool, reason: String, checksum: String, payload_str: String,
##           payload: Variant, legacy: bool }
##
## `legacy == true` significa que el token era un SHA-256 en claro (save previo
## al fix BUG-115). Se acepta por RETROCOMPATIBILIDAD — regla dura del proyecto
## "nunca degradar/inutilizar un save". LIMITACIÓN CONOCIDA Y DELIBERADA: como el
## token legado se sigue aceptando, un atacante con acceso al sistema de archivos
## puede reemplazar la línea 1 por `sha256(payload)` y el documento verifica. Es
## decir: el HMAC NO convierte el save en a prueba de manipulación local — la
## clave vive en `user://` junto a los saves y es legible. Lo que sí aporta el
## fix es (a) detectar corrupción/tampering no reproducido por el algoritmo
## público en los saves NUEVOS y (b) exponer el caso legado vía este flag.
static func parse_document(content: String) -> Dictionary:
	if content.is_empty():
		return {"ok": false, "reason": "contenido vacío", "checksum": "", "payload_str": "", "payload": null, "legacy": false}
	var newline := content.find("\n")
	if newline <= 0:
		return {"ok": false, "reason": "formato inválido", "checksum": "", "payload_str": "", "payload": null, "legacy": false}
	var checksum := content.substr(0, newline)
	var payload_str := content.substr(newline + 1)
	if not verificar_checksum(payload_str, checksum):
		return {"ok": false, "reason": "checksum no coincide", "checksum": checksum, "payload_str": payload_str, "payload": null, "legacy": false}
	var payload: Variant = JSON.parse_string(payload_str)
	if typeof(payload) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "payload no es JSON objeto", "checksum": checksum, "payload_str": payload_str, "payload": null, "legacy": false}
	return {"ok": true, "reason": "", "checksum": checksum, "payload_str": payload_str, "payload": payload, "legacy": not checksum.begins_with(CHECKSUM_PREFIX)}

## Escribe un payload de forma atómica en el slot dado.
## Devuelve true si se escribió correctamente, false ante cualquier fallo.
static func write_atomic(slot: int, payload: Dictionary) -> bool:
	# BUG-114: defensa en profundidad. Los llamadores ya validan el rango, pero
	# una llamada directa con un slot fuera de rango (p.ej. 99) no debe crear
	# `slot_99.save` fuera del contrato de SLOT_COUNT slots.
	if not SaveSchema.slot_valido(slot):
		push_error("[SAVE] write_atomic: slot fuera de rango (%d; válido 1..%d)" % [slot, SaveSchema.SLOT_COUNT])
		return false
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
	# BUG-114: no operar sobre slots fuera de rango (defensa en profundidad).
	if not SaveSchema.slot_valido(slot):
		return
	var tmp_path := "%s/slot_%d%s" % [SaveSchema.SAVE_DIR, slot, TMP_SUFFIX]
	if FileAccess.file_exists(tmp_path):
		DirAccess.remove_absolute(tmp_path)

## Devuelve true si existe un save en el slot.
static func save_exists(slot: int) -> bool:
	return FileAccess.file_exists("%s/slot_%d%s" % [SaveSchema.SAVE_DIR, slot, SAVE_SUFFIX])

## Ruta del archivo final de un slot.
static func path_for(slot: int) -> String:
	return "%s/slot_%d%s" % [SaveSchema.SAVE_DIR, slot, SAVE_SUFFIX]
