# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — Validador
# Integridad con CRC32 + contrato de campos por versión (RF8).
# Junto al writer, sigue la lección §9.11 de la guía 07: el checksum se
# calcula sobre la cadena EXACTA que se guarda (payload_str), no sobre un
# dict re-serializado (round-trip no es determinista).

class_name Validador
extends RefCounted

## Tabla CRC-32 (polinomio 0xEDB88320, reflejado) precomputada.
static var _tabla: Array = []
static var _tabla_ready: bool = false

static func _crc_table() -> Array:
	if _tabla_ready:
		return _tabla
	_tabla = []
	for i in range(256):
		var crc: int = i
		for _j in range(8):
			if crc & 1:
				crc = (crc >> 1) ^ 0xEDB88320
			else:
				crc = crc >> 1
		_tabla.append(crc)
	_tabla_ready = true
	return _tabla

## CRC32 en formato estándar (IEEE, reflejado) sobre bytes UTF-8.
## Devuelve un int sin signo en rango [0, 2^32). Godot 4 int64 lo sostiene.
static func crc32_hex(payload_str: String) -> String:
	var bytes := payload_str.to_utf8_buffer()
	var table := _crc_table()
	var crc: int = 0xFFFFFFFF
	for b in bytes:
		var byte: int = b
		var idx := (crc ^ byte) & 0xFF
		crc = (crc >> 8) ^ table[idx]
	crc = crc ^ 0xFFFFFFFF
	if crc < 0:
		crc = crc & 0xFFFFFFFF
	return "%08x" % crc

## CRC32 sobre el JSON canónico del dict (sin campo checksum): útil para
## comparar versiones PURAS (datos construidos, no parseados) o fingerprints.
## Para el archivo se usa el patrón cadena-exacta (ver WriterAtomico).
static func calcular_crc32(datos: Dictionary) -> int:
	var limpio := datos.duplicate(true)
	limpio.erase("checksum")
	var canon := Serializer.a_json_canonico(limpio)
	var bytes := canon.to_utf8_buffer()
	var table := _crc_table()
	var crc: int = 0xFFFFFFFF
	for b in bytes:
		var idx := (crc ^ int(b)) & 0xFF
		crc = (crc >> 8) ^ table[idx]
	crc = crc ^ 0xFFFFFFFF
	if crc < 0:
		crc = crc & 0xFFFFFFFF
	return crc

## Verifica integridad: true si el checksum guardado coincide con el calculado
## sobre el payload SIN el campo checksum (que se excluye del cálculo).
static func verificar_integridad(datos: Dictionary, checksum_guardado: int) -> bool:
	var calculado := calcular_crc32(datos)
	return calculado == checksum_guardado

## Contrato de la versión 1 (esquema v1): valida campos obligatorios y tipos.
## Devuelve Array[String] de errores (vacía = OK); nunca lanza excepción.
static func validar_contrato(datos: Dictionary, version: int) -> Array[String]:
	var errores: Array[String] = []
	var esquema := _esquema_para(version)
	if esquema.is_empty():
		errores.append("No existe esquema para versión %d" % version)
		return errores

	# 1) version
	if not datos.has("version"):
		errores.append("Falta campo obligatorio: version")
	else:
		var v: Variant = datos["version"]
		# Godot 4.7: JSON.parse_string puede devolver FLOAT para enteros.
		# Normalizamos a int para que el contrato sea robusto ante el parser.
		if typeof(v) == TYPE_INT:
			pass
		elif typeof(v) == TYPE_FLOAT:
			var vf: float = v
			# aceptar solo valores enteros exactos (1.0 -> 1; 1.5 no es version válida)
			if float(int(vf)) != vf:
				errores.append("version no es entero (%s)" % str(vf))
			else:
				datos["version"] = int(vf)
		else:
			errores.append("version no es int")

	# NOTA: el checksum NO se valida como campo interno del dict: se guarda como
	# primera línea del archivo (patrón cadena-exacta §9.11, ver WriterAtomico).

	# 2) bloques de sistema exigidos por esquema
	var bloques: Array = esquema.get("bloques", [])
	for bloque in bloques:
		var nombre: String = bloque
		if not datos.has(nombre):
			errores.append("Falta bloque: %s" % nombre)
		elif typeof(datos[nombre]) != TYPE_DICTIONARY:
			errores.append("Bloque %s no es Dictionary" % nombre)

	# 3) tipos internos del bloque "jugador" (RF3)
	var jugador: Variant = datos.get("jugador", null)
	if typeof(jugador) == TYPE_DICTIONARY:
		if jugador.has("pos") and typeof(jugador["pos"]) != TYPE_ARRAY:
			errores.append("jugador.pos no es Array")

	# 4) tipos internos del bloque "inventario" (RF3)
	var inventario: Variant = datos.get("inventario", null)
	if typeof(inventario) == TYPE_DICTIONARY:
		if inventario.has("slots") and typeof(inventario["slots"]) != TYPE_ARRAY:
			errores.append("inventario.slots no es Array")

	# 5) meta
	var meta: Variant = datos.get("meta", null)
	if typeof(meta) != TYPE_DICTIONARY:
		errores.append("meta no es Dictionary")

	return errores

static func _esquema_para(version: int) -> Dictionary:
	# Esquema v1: bloques de sistema mínimos exigidos (RF3).
	if version == 1:
		return {
			"version": 1,
			"bloques": ["jugador", "inventario", "tiempo", "mundo_voxel", "meta"],
		}
	return {}