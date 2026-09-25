# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M106: Seguridad — SecurityTamperProtection (helper reutilizable, V0 + headless).
# Implementa el servicio "TamperProtection" del diseño (03-Diseno.md §6), que quedó `[ ]`:
#   calculate_checksum            -> calcular_checksum
#   calculate_hmac                -> calcular_hmac
#   validate_savegame             -> validar_savegame
#   validate_savegame_signature   -> validar_savegame_firma
#   secret_key (miembro)          -> el secreto se PASA por parámetro (testeable y sin estado global)
# Lógica pura (RefCounted, sin class_name → preload). No toca el autoload.
#
# HMAC-SHA256 implementado a mano (ipad/opad + HashingContext) porque Godot 4.7 no lo trae.
# Verificado contra `hmac` de Python: hmac_sha256("key","msg") =
#   2d93cbc1be167bcb1637a4a23cbff01a7878f0c50ee833954ea5221bb1b8c628
# y con clave >64 B (rama de hasheo de la clave): cdce77410699bccbddbd9cf9c27d5ced18a5efcc02a4c74c1191b8c043e55f09
#
# ⚠️ Nota de alcance: el diseño declara que el checksum "SHA-256" reemplaza al CRC32 débil del
# autoload. Este helper NO cambia `SecurityManager.validar_save` (autoload en uso); queda como
# alternativa recomendada para M60/M77.

extends RefCounted

const _BLOQUE: int = 64


## Checksum SHA-256 (hex) del texto.
func calcular_checksum(datos: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	_actualizar(ctx, datos.to_utf8_buffer())
	var digest: PackedByteArray = ctx.finish()
	return digest.hex_encode()


## `HashingContext.update()` con un buffer vacío imprime un ERROR del motor
## (`Condition "len == 0" is true`, core/crypto/hashing_context.cpp:54). Hashear el vacío es
## legítimo (sha256("") = e3b0c442…), así que se omite la llamada cuando no hay bytes.
func _actualizar(ctx: HashingContext, bytes: PackedByteArray) -> void:
	if bytes.size() > 0:
		ctx.update(bytes)


## HMAC-SHA256 (hex) de `datos` con `secreto` (RFC 2104).
func calcular_hmac(datos: String, secreto: String) -> String:
	var clave: PackedByteArray = secreto.to_utf8_buffer()
	if clave.size() > _BLOQUE:
		var ch := HashingContext.new()
		ch.start(HashingContext.HASH_SHA256)
		ch.update(clave)
		clave = ch.finish()
	while clave.size() < _BLOQUE:
		clave.append(0)
	var ipad := PackedByteArray()
	var opad := PackedByteArray()
	for i in _BLOQUE:
		ipad.append(clave[i] ^ 0x36)
		opad.append(clave[i] ^ 0x5C)
	var ci := HashingContext.new()
	ci.start(HashingContext.HASH_SHA256)
	ci.update(ipad)
	_actualizar(ci, datos.to_utf8_buffer())
	var interno: PackedByteArray = ci.finish()
	var co := HashingContext.new()
	co.start(HashingContext.HASH_SHA256)
	co.update(opad)
	co.update(interno)
	var salida: PackedByteArray = co.finish()
	return salida.hex_encode()


## Valida un savegame contra su checksum SHA-256 (JSON canónico del diccionario).
func validar_savegame(savegame: Dictionary, checksum: String) -> bool:
	return calcular_checksum(_canonico(savegame)) == checksum


## Valida un savegame contra su firma HMAC-SHA256.
func validar_savegame_firma(savegame: Dictionary, firma: String, secreto: String) -> bool:
	return calcular_hmac(_canonico(savegame), secreto) == firma


## Serialización canónica: claves ordenadas, para que el mismo diccionario dé siempre el mismo hash
## (JSON.stringify de un Dictionary en Godot 4 conserva el orden de inserción, no el alfabético).
func _canonico(d: Dictionary) -> String:
	var claves: Array = d.keys()
	claves.sort()
	var partes := PackedStringArray()
	for k in claves:
		partes.append("%s=%s" % [str(k), JSON.stringify(d[k])])
	return "{" + ",".join(partes) + "}"
