# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — Serializer
# Codifica/decodifica save (JSON) y mundo voxel (binario IAVX1).
# D1 del módulo: partida en JSON (estabilidad entre versiones); voxel en binario.

class_name Serializer
extends RefCounted

## Magic del archivo binario de mundo voxel (RF4, sección 5.3 de 03-Diseno)
const MAGIC_VOXEL: String = "IAVX1"

## Serializa a JSON pretty (2 espacios), UTF-8 sin BOM. No incluye checksum.
static func a_json(datos: Dictionary) -> String:
	return JSON.stringify(datos, "  ")

## JSON.parse con chequeo de error; devuelve {} si falla (SN: jamás excepción).
static func desde_json(texto: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(texto)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("[M60] JSON inválido o no objeto")
		return {}
	return parsed

## JSON compacto canónico (claves ordenadas recursivamente) para checksum estable.
## §9.11 de la guía 07: el checksum se calcula sobre la cadena EXACTA guardada,
## pero para contratos e ids estables necesitamos una forma canónica del dict.
static func a_json_canonico(datos: Dictionary) -> String:
	return JSON.stringify(_ordenar_claves(datos))

## Ordena las claves de un Dictionary en forma recursiva (Arrays se mantienen).
static func _ordenar_claves(valor: Variant) -> Variant:
	match typeof(valor):
		TYPE_DICTIONARY:
			var sorted: Dictionary = {}
			var claves: Array = valor.keys()
			claves.sort()
			for k in claves:
				sorted[k] = _ordenar_claves(valor[k])
			return sorted
		TYPE_ARRAY:
			var arr: Array = []
			for item in valor:
				arr.append(_ordenar_claves(item))
			return arr
		_:
			return valor

## Normaliza floats del save a 4 decimales para checksum estable.
static func normalizar_float(valor: float) -> float:
	return snappedf(valor, 0.0001)

## Serializa un Vector3i a [x, y, z] (array de 3 ints) para JSON.
static func vector3i_a_array(v: Vector3i) -> Array:
	return [v.x, v.y, v.z]

## Convierte el payload del save a un Dictionary plano serializable:
##   - Vector2/3 -> Array
##   - Vector3i -> Array
##   - Color -> Array
##   - floats normalizados a 4 decimales (RN9 determinismo)
static func a_plano(datos: Dictionary) -> Dictionary:
	return _a_plano_rec(datos)

static func _a_plano_rec(valor: Variant) -> Variant:
	match typeof(valor):
		TYPE_VECTOR2:
			return [snappedf(valor.x, 0.0001), snappedf(valor.y, 0.0001)]
		TYPE_VECTOR3:
			return [snappedf(valor.x, 0.0001), snappedf(valor.y, 0.0001), snappedf(valor.z, 0.0001)]
		TYPE_VECTOR2I:
			return [valor.x, valor.y]
		TYPE_VECTOR3I:
			return [valor.x, valor.y, valor.z]
		TYPE_COLOR:
			return [snappedf(valor.r, 0.0001), snappedf(valor.g, 0.0001), snappedf(valor.b, 0.0001), snappedf(valor.a, 0.0001)]
		TYPE_FLOAT:
			return snappedf(valor, 0.0001)
		TYPE_DICTIONARY:
			var d: Dictionary = {}
			for k in valor:
				d[k] = _a_plano_rec(valor[k])
			return d
		TYPE_ARRAY:
			var a: Array = []
			for item in valor:
				a.append(_a_plano_rec(item))
			return a
		_:
			return valor

## ── Voxel: formato IAVX1 ─────────────────────────────────

## Codifica chunk edits a binario: magic + count + por chunk
## [coord Vector3i(int32 x3) + num_voxeles(int32) + bytes(int32 x num_voxeles)]
## Cada vóxel editado se guarda como 4 int32: [x, y, z, tipo] (RF4, RN6 lengths).
static func a_binario_voxel(chunks: Array) -> PackedByteArray:
	var out := PackedByteArray()
	out.append_array(MAGIC_VOXEL.to_ascii_buffer())
	var count := chunks.size()
	# reserve: magic(5) + count(4) + 12 bytes por voxel editado (aprox)
	out.resize(out.size() + 4)
	out.encode_s32(5, count)
	var offset := 9
	for chunk in chunks:
		var coord: Vector3i = chunk.get("coord", Vector3i.ZERO)
		var voxeles: PackedInt32Array = chunk.get("voxeles", PackedInt32Array())
		# coord int32 x3
		out.resize(offset + 4)
		out.encode_s32(offset, coord.x)
		offset += 4
		out.resize(offset + 4)
		out.encode_s32(offset, coord.y)
		offset += 4
		out.resize(offset + 4)
		out.encode_s32(offset, coord.z)
		offset += 4
		# num_voxeles
		out.resize(offset + 4)
		out.encode_s32(offset, voxeles.size())
		offset += 4
		# bytes de vóxeles (cada voxel = 4 int32)
		var bytes_needed := voxeles.size() * 4
		var prev_size := out.size()
		out.resize(prev_size + bytes_needed)
		for i in range(voxeles.size()):
			out.encode_s32(offset + i * 4, voxeles[i])
		offset += bytes_needed
	return out

## Detecta magic "IAVX1"; si no coincide devuelve {} (corrupto/futuro).
## Devuelve { chunks: Array, count: int } o {} si el magic falla.
static func desde_binario_voxel(data: PackedByteArray) -> Dictionary:
	if data.size() < 9:
		return {}
	if data.slice(0, 5).get_string_from_ascii() != MAGIC_VOXEL:
		return {}
	var count := data.decode_s32(5)
	if count < 0 or count > 4096:
		return {}
	# Ojo: 9 bytes por chunk es inválido; validamos el tamaño global
	if data.size() < 9 + count * 9:
		return {}
	var chunks: Array = []
	var offset := 9
	for i in range(count):
		if offset + 12 > data.size():
			break
		var cx := data.decode_s32(offset)
		var cy := data.decode_s32(offset + 4)
		var cz := data.decode_s32(offset + 8)
		offset += 12
		if offset + 4 > data.size():
			break
		var num := data.decode_s32(offset)
		offset += 4
		if num < 0 or num > 100000:
			num = 0
		var voxeles := PackedInt32Array()
		for j in range(num):
			if offset + 4 > data.size():
				break
			voxeles.append(data.decode_s32(offset))
			offset += 4
		chunks.append({
			"coord": Vector3i(cx, cy, cz),
			"voxeles": voxeles,
		})
	return {"chunks": chunks, "count": chunks.size()}