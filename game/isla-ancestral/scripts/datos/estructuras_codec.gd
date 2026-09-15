# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M60 iter. 3 — RF3: serialización de construcciones y casas (M17/M18).
#
# Codec PURO de la sección "buildings" del save. Forma canónica (coincide con
# SaveSchema.default_payload):
#
#   "buildings": { "structures": [ { id, tipo, pos, rot_y, planta, variante } ] }
#
# Responsabilidad de M60: QUÉ se guarda y CÓMO se codifica. El ESTADO vivo lo
# aporta M17/M18 a través de BuildingsSaveProvider (duck-typing) — este codec
# no conoce nodos, escenas ni el sistema de construcción.
#
# Reglas duras que respeta:
#  - coordenadas int32 con signo (mundo voxel 1 m, puede extenderse a negativos)
#  - orden determinista por id → checksum estable (RN9)
#  - nunca devuelve referencias a la entrada (sin aliasing)
#  - tolerante: entradas inválidas se descartan, jamás lanza excepción

class_name EstructurasCodec
extends RefCounted

## Nombre de la sección en el payload del save (SaveSchema).
const SECCION: String = "buildings"

## Tope defensivo: un save con más estructuras que esto se considera corrupto
## (save completo < 1 MB por slot, RN2).
const MAX_ESTRUCTURAS: int = 20000

## Claves exactas de una estructura normalizada, en orden.
const CLAVES: Array[String] = ["id", "tipo", "pos", "rot_y", "planta", "variante"]

## Normaliza una lista cruda de estructuras a la forma canónica del save.
## Devuelve un Array NUEVO y ordenado (determinismo del checksum).
static func normalizar(estructuras: Variant) -> Array:
	var out: Array = []
	if typeof(estructuras) != TYPE_ARRAY:
		return out
	for e in (estructuras as Array):
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = e
		var id: String = String(d.get("id", "")).strip_edges()
		if id == "":
			continue
		out.append({
			"id": id,
			"tipo": String(d.get("tipo", "")),
			"pos": pos_a_int32(d.get("pos", null)),
			"rot_y": rot_normalizada(d.get("rot_y", 0)),
			"planta": maxi(0, int(d.get("planta", 0))),
			"variante": String(d.get("variante", "")),
		})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a["id"]) < String(b["id"]))
	if out.size() > MAX_ESTRUCTURAS:
		out.resize(MAX_ESTRUCTURAS)
	return out

## Convierte una posición a [x, y, z] de enteros int32.
## Acepta Vector3i, Vector3 (redondeado) o Array de 3. Si no se puede → [0,0,0].
static func pos_a_int32(v: Variant) -> Array:
	match typeof(v):
		TYPE_VECTOR3I:
			return [v.x, v.y, v.z]
		TYPE_VECTOR3:
			return [roundi(v.x), roundi(v.y), roundi(v.z)]
		TYPE_ARRAY:
			var a: Array = v
			if a.size() >= 3:
				return [int(a[0]), int(a[1]), int(a[2])]
	return [0, 0, 0]

## Normaliza una rotación a un múltiplo de 90 en [0, 270] (RF4 de M17: pasos
## de 90° por eje Y). Acepta grados negativos o > 360.
static func rot_normalizada(v: Variant) -> int:
	var g: int = int(v) % 360
	if g < 0:
		g += 360
	var paso: int = int(round(float(g) / 90.0)) % 4
	return paso * 90

## Valida una lista YA normalizada. Devuelve Array[String] (vacía = OK).
static func validar(estructuras: Array) -> Array[String]:
	var errores: Array[String] = []
	if estructuras.size() > MAX_ESTRUCTURAS:
		errores.append("demasiadas estructuras: %d (máx %d)" % [estructuras.size(), MAX_ESTRUCTURAS])
	var vistos: Dictionary = {}
	for e in estructuras:
		if typeof(e) != TYPE_DICTIONARY:
			errores.append("estructura no es Dictionary")
			continue
		var d: Dictionary = e
		var id: String = String(d.get("id", ""))
		if id == "":
			errores.append("estructura sin id")
		elif vistos.has(id):
			errores.append("id duplicado: %s" % id)
		else:
			vistos[id] = true
		var pos: Variant = d.get("pos", null)
		if typeof(pos) != TYPE_ARRAY or (pos as Array).size() != 3:
			errores.append("pos inválida en %s" % id)
		else:
			for c in (pos as Array):
				if typeof(c) != TYPE_INT:
					errores.append("pos no entera en %s" % id)
					break
		if int(d.get("planta", 0)) < 0:
			errores.append("planta negativa en %s" % id)
	return errores

## Empaqueta una lista cruda en la sección completa del save.
static func a_seccion(estructuras: Variant) -> Dictionary:
	return {"structures": normalizar(estructuras)}

## Desempaqueta la sección del save a una lista normalizada (tolerante:
## sección ausente, mal tipada o con entradas basura → lista vacía/filtrada).
static func desde_seccion(seccion: Variant) -> Array:
	if typeof(seccion) != TYPE_DICTIONARY:
		return []
	return normalizar((seccion as Dictionary).get("structures", []))

## Cantidad de estructuras de una lista cruda (para logs/diagnóstico).
static func contar(estructuras: Variant) -> int:
	if typeof(estructuras) != TYPE_ARRAY:
		return 0
	return (estructuras as Array).size()

## Huella compacta de la lista normalizada: permite detectar cambios sin
## comparar los diccionarios completos (usada por el provider para logs).
static func huella(estructuras: Variant) -> String:
	var normal := normalizar(estructuras)
	return "%d:%s" % [normal.size(), Validador.crc32_hex(Serializer.a_json_canonico({"s": normal}))]
