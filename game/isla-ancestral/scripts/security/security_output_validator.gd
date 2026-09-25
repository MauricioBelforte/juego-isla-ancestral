# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M106: Seguridad — SecurityOutputValidator (helper reutilizable, V0 + headless).
# Implementa el servicio "OutputValidator" del diseño (03-Diseno.md §5), que quedó `[ ]`:
#   validate_checksum  -> validar_checksum
#   calculate_sha256   -> calcular_sha256
#   validate_signature -> validar_firma
#   validate_json      -> validar_json  (esquema simple clave->tipo, como el diseño)
# Lógica pura (RefCounted, sin class_name → se carga vía preload, §9.52). No toca el autoload.
#
# SHA-256 con `HashingContext` del motor (sin dependencias externas). Verificado contra el
# vector estándar: sha256("abc") = ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
#
# ⚠️ Alcance honesto: `validar_firma` compara DIGESTS (SHA-256), no verifica firmas
# asimétricas (RSA/Ed25519). La verificación con clave pública real es de M77 (online).
# Devuelve false si no coincide (fail-closed), nunca true "por defecto".

extends RefCounted


## SHA-256 en hex minúsculas del texto UTF-8.
func calcular_sha256(datos: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(datos.to_utf8_buffer())
	var digest: PackedByteArray = ctx.finish()
	return digest.hex_encode()


## ¿El checksum declarado coincide con el SHA-256 del texto? (comparación en tiempo constante).
func validar_checksum(datos: String, checksum_esperado: String) -> bool:
	return _igualdad_constante(calcular_sha256(datos), checksum_esperado)


## Valida un JSON contra un esquema simple `clave -> TYPE_*` (mismo contrato que el diseño §5).
## Devuelve false si falta una clave o su tipo no coincide.
func validar_json(json: Dictionary, esquema: Dictionary) -> bool:
	for clave in esquema.keys():
		if not json.has(clave):
			return false
		var esperado: int = int(esquema[clave])
		if typeof(json[clave]) != esperado:
			return false
	return true


## Valida una firma declarada comparándola con el SHA-256 del texto (digest, no asimétrica).
## Ver la nota de alcance del encabezado.
func validar_firma(datos: String, firma: String, _clave_publica: String = "") -> bool:
	return _igualdad_constante(calcular_sha256(datos), firma)


## Comparación en tiempo constante: no corta en el primer byte distinto.
func _igualdad_constante(a: String, b: String) -> bool:
	if a.length() != b.length():
		return false
	var dif: int = 0
	for i in a.length():
		dif |= a.unicode_at(i) ^ b.unicode_at(i)
	return dif == 0
