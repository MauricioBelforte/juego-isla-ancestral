# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M60 iter. 3 — RF3: serialización de construcciones y casas (M17/M18).
#
# Codec PURO de la sección "buildings" del save. Forma canónica (coincide con
# SaveSchema.default_payload):
#
#   "buildings": { "structures": [ { id, tipo, pos, rot_y, planta, variante,
#                                     fase?, mejora?, muebles?, cofre?, puertas? } ] }
#
# Los campos opcionales son ADITIVOS: un save viejo (sin ellos) se carga igual
# y un save nuevo conserva el estado de M18 (muebles, cofres, puertas) y de la
# obra (fase/mejora) sin romper la forma base.
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
#  - migración implícita: ausencia de campos opcionales = defaults de M17/M18

class_name EstructurasCodec
extends RefCounted

## Nombre de la sección en el payload del save (SaveSchema).
const SECCION: String = "buildings"

## Tope defensivo: un save con más estructuras que esto se considera corrupto
## (save completo < 1 MB por slot, RN2).
const MAX_ESTRUCTURAS: int = 20000

## Claves exactas de la forma base, en orden.
const CLAVES: Array[String] = ["id", "tipo", "pos", "rot_y", "planta", "variante"]

## Claves opcionales aditivas (M18/M17). Solo se incluyen si tienen estado real.
const CLAVES_OPCIONALES: Array[String] = ["fase", "mejora", "muebles", "cofre", "puertas"]

## Topes defensivos por estructura (save completo < 1 MB por slot, RN2).
const MAX_MUEBLES: int = 512
const MAX_SLOTS_COFRE: int = 64
const MAX_PUERTAS: int = 64
const MAX_CANTIDAD: int = 999999

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
		var canon: Dictionary = {
			"id": id,
			"tipo": String(d.get("tipo", "")),
			"pos": pos_a_int32(d.get("pos", null)),
			"rot_y": rot_normalizada(d.get("rot_y", 0)),
			"planta": maxi(0, int(d.get("planta", 0))),
			"variante": String(d.get("variante", "")),
		}
		_aplicar_opcionales(canon, d)
		out.append(canon)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a["id"]) < String(b["id"]))
	if out.size() > MAX_ESTRUCTURAS:
		out.resize(MAX_ESTRUCTURAS)
	return out

## Copia los campos opcionales presentes en `d` a `canon`, ya saneados.
## Un campo ausente o inválido NO se agrega (compatibilidad con saves viejos).
static func _aplicar_opcionales(canon: Dictionary, d: Dictionary) -> void:
	if d.has("fase"):
		canon["fase"] = clampi(int(d.get("fase", 0)), 0, MAX_CANTIDAD)
	if d.has("mejora"):
		canon["mejora"] = clampi(int(d.get("mejora", 0)), 0, MAX_CANTIDAD)
	elif d.has("mejoras"):
		canon["mejora"] = clampi(int(d.get("mejoras", 0)), 0, MAX_CANTIDAD)
	if d.has("muebles"):
		var muebles := normalizar_muebles(d.get("muebles"))
		if not muebles.is_empty():
			canon["muebles"] = muebles
	if d.has("cofre"):
		var cofre := normalizar_cofre(d.get("cofre"))
		if not cofre.is_empty():
			canon["cofre"] = cofre
	if d.has("puertas"):
		var puertas := normalizar_puertas(d.get("puertas"))
		if not puertas.is_empty():
			canon["puertas"] = puertas

## Muebles de M18: [{ celda:[x,y,z], mueble:String, rotacion:0..3 }].
## Acepta `pos` como alias de `celda` y grados como alias de pasos.
static func normalizar_muebles(v: Variant) -> Array:
	var out: Array = []
	if typeof(v) != TYPE_ARRAY:
		return out
	for raw in (v as Array):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = raw
		var celda := celda_a_int32(d.get("celda", d.get("pos", null)))
		if celda.is_empty():
			continue
		var mueble: String = String(d.get("mueble", d.get("id", ""))).strip_edges()
		if mueble == "":
			continue
		out.append({
			"celda": celda,
			"mueble": mueble,
			"rotacion": _rot_pasos(d.get("rotacion", d.get("rot_y", 0))),
		})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ca: Array = a["celda"]
		var cb: Array = b["celda"]
		for i in 3:
			if int(ca[i]) != int(cb[i]):
				return int(ca[i]) < int(cb[i])
		return String(a["mueble"]) < String(b["mueble"]))
	if out.size() > MAX_MUEBLES:
		out.resize(MAX_MUEBLES)
	return out

## Contenido de cofre de M18: { contenido:[{item_id:String, cantidad:int>0}] }.
## Acepta también un Array directo o la clave `slots`; suma duplicados por item.
static func normalizar_cofre(v: Variant) -> Dictionary:
	var crudo: Variant = v
	if typeof(v) == TYPE_DICTIONARY:
		var d: Dictionary = v
		crudo = d.get("contenido", d.get("slots", []))
	if typeof(crudo) != TYPE_ARRAY:
		return {}
	var acumulado: Dictionary = {}
	for raw in (crudo as Array):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var slot: Dictionary = raw
		var item_id: String = String(slot.get("item_id", slot.get("item", ""))).strip_edges()
		var cantidad: int = int(slot.get("cantidad", 0))
		if item_id == "" or cantidad <= 0:
			continue
		acumulado[item_id] = mini(MAX_CANTIDAD, int(acumulado.get(item_id, 0)) + cantidad)
	if acumulado.is_empty():
		return {}
	var items: Array = acumulado.keys()
	items.sort()
	var contenido: Array = []
	for item_id in items:
		contenido.append({"item_id": String(item_id), "cantidad": int(acumulado[item_id])})
	if contenido.size() > MAX_SLOTS_COFRE:
		contenido.resize(MAX_SLOTS_COFRE)
	return {"contenido": contenido}

## Puertas/ventanas de M18: [{ celda:[x,y,z], abierta:bool }].
## Deduplica por celda (última entrada gana) y ordena por celda.
static func normalizar_puertas(v: Variant) -> Array:
	if typeof(v) != TYPE_ARRAY:
		return []
	var por_celda: Dictionary = {}
	for raw in (v as Array):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = raw
		var celda := celda_a_int32(d.get("celda", d.get("pos", null)))
		if celda.is_empty():
			continue
		por_celda[_clave_celda(celda)] = {
			"celda": celda,
			"abierta": bool(d.get("abierta", false)),
		}
	var claves: Array = por_celda.keys()
	claves.sort()
	var out: Array = []
	for k in claves:
		out.append(por_celda[k])
	if out.size() > MAX_PUERTAS:
		out.resize(MAX_PUERTAS)
	return out

## Convierte una celda a [x,y,z] int32. A diferencia de `pos_a_int32`, devuelve
## [] si el valor no es una celda válida (para no inventar un [0,0,0] falso).
static func celda_a_int32(v: Variant) -> Array:
	match typeof(v):
		TYPE_VECTOR3I:
			return [v.x, v.y, v.z]
		TYPE_VECTOR3:
			return [roundi(v.x), roundi(v.y), roundi(v.z)]
		TYPE_ARRAY:
			var a: Array = v
			if a.size() < 3:
				return []
			var out: Array = []
			for i in 3:
				var c: Variant = a[i]
				if typeof(c) != TYPE_INT and typeof(c) != TYPE_FLOAT:
					return []
				out.append(int(c))
			return out
	return []

static func _clave_celda(celda: Array) -> String:
	return "%d:%d:%d" % [int(celda[0]), int(celda[1]), int(celda[2])]

## Rotación de mueble en pasos de 90° [0..3]. Acepta pasos (0-3) o grados.
static func _rot_pasos(v: Variant) -> int:
	var r: int = int(v)
	if absi(r) > 3 and posmod(r, 90) == 0:
		return posmod(int(round(float(r) / 90.0)), 4)
	return posmod(r, 4)

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
		_validar_opcionales(d, id, errores)
	return errores

## Valida los campos opcionales ADITIVOS de una estructura ya normalizada.
static func _validar_opcionales(d: Dictionary, id: String, errores: Array[String]) -> void:
	for clave in ["fase", "mejora"]:
		if not d.has(clave):
			continue
		var v: Variant = d[clave]
		if typeof(v) != TYPE_INT or int(v) < 0:
			errores.append("%s inválida en %s" % [clave, id])
	if d.has("muebles"):
		var muebles: Variant = d["muebles"]
		if typeof(muebles) != TYPE_ARRAY:
			errores.append("muebles no es Array en %s" % id)
		else:
			if (muebles as Array).size() > MAX_MUEBLES:
				errores.append("demasiados muebles en %s" % id)
			for raw in (muebles as Array):
				if typeof(raw) != TYPE_DICTIONARY:
					errores.append("mueble no es Dictionary en %s" % id)
					continue
				var m: Dictionary = raw
				if not _celda_es_int32(m.get("celda", null)):
					errores.append("celda de mueble inválida en %s" % id)
				if String(m.get("mueble", "")).strip_edges() == "":
					errores.append("mueble sin id en %s" % id)
				if typeof(m.get("rotacion", null)) != TYPE_INT \
						or int(m.get("rotacion", -1)) < 0 or int(m.get("rotacion", -1)) > 3:
					errores.append("rotación de mueble inválida en %s" % id)
	if d.has("cofre"):
		var cofre: Variant = d["cofre"]
		if typeof(cofre) != TYPE_DICTIONARY:
			errores.append("cofre no es Dictionary en %s" % id)
		else:
			var contenido: Variant = (cofre as Dictionary).get("contenido", null)
			if typeof(contenido) != TYPE_ARRAY:
				errores.append("cofre.contenido no es Array en %s" % id)
			else:
				if (contenido as Array).size() > MAX_SLOTS_COFRE:
					errores.append("demasiados slots de cofre en %s" % id)
				for raw in (contenido as Array):
					if typeof(raw) != TYPE_DICTIONARY:
						errores.append("slot de cofre no es Dictionary en %s" % id)
						continue
					var slot: Dictionary = raw
					if String(slot.get("item_id", "")).strip_edges() == "":
						errores.append("slot de cofre sin item_id en %s" % id)
					if typeof(slot.get("cantidad", null)) != TYPE_INT \
							or int(slot.get("cantidad", 0)) <= 0:
						errores.append("cantidad de cofre inválida en %s" % id)
	if d.has("puertas"):
		var puertas: Variant = d["puertas"]
		if typeof(puertas) != TYPE_ARRAY:
			errores.append("puertas no es Array en %s" % id)
		else:
			if (puertas as Array).size() > MAX_PUERTAS:
				errores.append("demasiadas puertas en %s" % id)
			for raw in (puertas as Array):
				if typeof(raw) != TYPE_DICTIONARY:
					errores.append("puerta no es Dictionary en %s" % id)
					continue
				var p: Dictionary = raw
				if not _celda_es_int32(p.get("celda", null)):
					errores.append("celda de puerta inválida en %s" % id)
				if typeof(p.get("abierta", null)) != TYPE_BOOL:
					errores.append("abierta no es bool en %s" % id)

static func _celda_es_int32(v: Variant) -> bool:
	if typeof(v) != TYPE_ARRAY or (v as Array).size() != 3:
		return false
	for c in (v as Array):
		if typeof(c) != TYPE_INT:
			return false
	return true

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
