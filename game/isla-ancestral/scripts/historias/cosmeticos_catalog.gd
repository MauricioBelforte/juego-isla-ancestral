# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-10-26
#
# M23: Historias Secundarias - CosmeticosCatalog (RefCounted).
#
# POR QUE EXISTE (iter. 24, Log 2202): las 81 cadenas declaran
# `recompensa.cosmetico` con un NOMBRE VISIBLE ("farol de atardecer"), y hasta
# esta iteracion ese valor era data muerta:
#   - 0 de esos 75 nombres aparecia en cualquier otro archivo del repo
#     (medido: grep sobre data/ y scripts/ -> solo secundarias.json y
#     cadenas_ejemplo.json);
#   - no existia NINGUN catalogo de cosmeticos en data/;
#   - el puente solo emitia `quest_updated(id, "cosmetico", 1)`, que no lleva
#     el cosmetico y ADEMAS no tiene ningun listener (medido: 1 sola
#     ocurrencia de `quest_updated` en scripts/, la del emisor).
# Resultado: completar una cadena no desbloqueaba nada identificable.
#
# Este catalogo le da IDENTIDAD a cada cosmetico declarado (id estable
# `cosm-<slug>`, tipo, solo_visual) y `validar()` cruza el catalogo contra las
# declaraciones para que la data muerta no pueda volver.
#
# Regla de diseno (03-Diseno L62): cosmetico = SOLO VISUAL, nunca stats.
# Sin class_name: se preloadea (GUIA-GODOT/09-godot4-migracion.md §9.17).

extends RefCounted

const RUTA_CATALOGO: String = "res://data/historias/cosmeticos.json"
const PREFIJO_ID: String = "cosm-"
const TIPOS: Array[String] = ["disfraz", "sombrero", "paleta", "casa"]
const MINIMO_ENTRADAS: int = 10

## id -> {id, nombre, tipo, solo_visual, afecta_stats, origen[]}
var _por_id: Dictionary = {}
## nombre -> id (para resolver la declaracion de la cadena)
var _por_nombre: Dictionary = {}
## Errores estructurales detectados al cargar (no de contenido de las cadenas)
var _errores: Array[String] = []


## Carga el catalogo. Devuelve cuantas entradas quedaron utiles (0 = fallo).
func cargar() -> int:
	_por_id.clear()
	_por_nombre.clear()
	_errores.clear()
	if not FileAccess.file_exists(RUTA_CATALOGO):
		_errores.append("catalogo ausente: %s" % RUTA_CATALOGO)
		return 0
	var crudo := FileAccess.get_file_as_string(RUTA_CATALOGO)
	if crudo.is_empty():
		_errores.append("catalogo vacio: %s" % RUTA_CATALOGO)
		return 0
	var parsed: Variant = JSON.parse_string(crudo)
	if typeof(parsed) != TYPE_DICTIONARY:
		_errores.append("catalogo no es un objeto JSON")
		return 0
	var raiz: Dictionary = parsed as Dictionary
	var lista: Variant = raiz.get("cosmeticos", [])
	if typeof(lista) != TYPE_ARRAY:
		_errores.append("'cosmeticos' no es un array")
		return 0
	for entrada in (lista as Array):
		if typeof(entrada) != TYPE_DICTIONARY:
			_errores.append("entrada no es objeto: %s" % str(entrada))
			continue
		var d: Dictionary = entrada as Dictionary
		var cid := String(d.get("id", ""))
		var nombre := String(d.get("nombre", ""))
		var tipo := String(d.get("tipo", ""))
		var origen: Array[String] = _strings(d.get("origen", []))
		if cid.is_empty() or nombre.is_empty():
			_errores.append("entrada sin id o nombre: %s" % str(d))
			continue
		if _por_id.has(cid):
			_errores.append("id duplicado en catalogo: %s" % cid)
			continue
		if _por_nombre.has(nombre):
			_errores.append("nombre duplicado en catalogo: %s" % nombre)
			continue
		_por_id[cid] = {
			"id": cid,
			"nombre": nombre,
			"tipo": tipo,
			"solo_visual": bool(d.get("solo_visual", false)),
			"afecta_stats": bool(d.get("afecta_stats", true)),
			"origen": origen,
		}
		_por_nombre[nombre] = cid
	return _por_id.size()


func cantidad() -> int:
	return _por_id.size()


func obtener(cosmetico_id: String) -> Dictionary:
	if _por_id.has(cosmetico_id):
		return (_por_id[cosmetico_id] as Dictionary).duplicate(true)
	return {}


## Resuelve el NOMBRE visible declarado por una cadena al id del catalogo.
## Devuelve "" si el nombre no esta catalogado (data muerta).
func id_de_nombre(nombre: String) -> String:
	return String(_por_nombre.get(nombre.strip_edges(), ""))


func por_nombre(nombre: String) -> Dictionary:
	return obtener(id_de_nombre(nombre))


func todos() -> Array[Dictionary]:
	var salida: Array[Dictionary] = []
	for cid in _por_id:
		salida.append((_por_id[cid] as Dictionary).duplicate(true))
	return salida


func ids() -> Array[String]:
	var salida: Array[String] = []
	for cid in _por_id:
		salida.append(String(cid))
	salida.sort()
	return salida


func errores_de_carga() -> Array[String]:
	return _errores.duplicate()


## Nombres declarados por las cadenas que NO estan en el catalogo.
func faltantes(nombres_declarados: Array) -> Array[String]:
	var salida: Array[String] = []
	for n in nombres_declarados:
		var nombre := String(n).strip_edges()
		if nombre.is_empty():
			continue
		if not _por_nombre.has(nombre):
			salida.append(nombre)
	return salida


## Entradas del catalogo que ninguna cadena declara (catalogo huerfano).
func huerfanos(nombres_declarados: Array) -> Array[String]:
	var declarados := {}
	for n in nombres_declarados:
		declarados[String(n).strip_edges()] = true
	var salida: Array[String] = []
	for nombre in _por_nombre:
		if not declarados.has(String(nombre)):
			salida.append(String(nombre))
	salida.sort()
	return salida


## Valida el catalogo contra si mismo. Devuelve la lista de errores (vacia = OK).
func validar() -> Array[String]:
	var errores: Array[String] = []
	errores.append_array(_errores)
	if _por_id.size() < MINIMO_ENTRADAS:
		errores.append("catalogo con %d entradas (minimo %d)" % [_por_id.size(), MINIMO_ENTRADAS])
	var conteo := {}
	for cid in _por_id:
		var c: Dictionary = _por_id[cid]
		var nombre := String(c.get("nombre", ""))
		var tipo := String(c.get("tipo", ""))
		if not String(cid).begins_with(PREFIJO_ID):
			errores.append("%s: id sin prefijo '%s'" % [String(cid), PREFIJO_ID])
		if not (tipo in TIPOS):
			errores.append("%s: tipo desconocido '%s'" % [String(cid), tipo])
		else:
			conteo[tipo] = int(conteo.get(tipo, 0)) + 1
		# Regla dura del diseno: cosmetico nunca da stats (03-Diseno L62).
		if not bool(c.get("solo_visual", false)):
			errores.append("%s: solo_visual debe ser true" % String(cid))
		if bool(c.get("afecta_stats", true)):
			errores.append("%s: afecta_stats debe ser false" % String(cid))
		var origen: Array = c.get("origen", [])
		if origen.is_empty():
			errores.append("%s: sin cadena de origen" % String(cid))
		if nombre.length() < 3:
			errores.append("%s: nombre demasiado corto" % String(cid))
	for tipo in TIPOS:
		if int(conteo.get(tipo, 0)) == 0:
			errores.append("tipo sin ninguna entrada: %s" % tipo)
	return errores


## Conteo por tipo, para reportes (p. ej. "disfraz 10 / sombrero 2 / ...").
func conteo_por_tipo() -> Dictionary:
	var conteo := {}
	for tipo in TIPOS:
		conteo[tipo] = 0
	for cid in _por_id:
		var tipo := String((_por_id[cid] as Dictionary).get("tipo", ""))
		if conteo.has(tipo):
			conteo[tipo] = int(conteo[tipo]) + 1
	return conteo


func _strings(valor: Variant) -> Array[String]:
	var salida: Array[String] = []
	if typeof(valor) != TYPE_ARRAY:
		return salida
	for x in (valor as Array):
		salida.append(String(x))
	return salida
