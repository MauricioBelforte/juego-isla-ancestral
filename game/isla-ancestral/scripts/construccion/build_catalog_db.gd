# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 2 — BuildCatalogDB: el catalogo data-driven (RF12).
#
# Carga TODAS las recetas `.tres` de `res://data/construccion/piezas/` (recursivo,
# una subcarpeta por familia opcional) y las indexa por id y por familia.
# NUCLEO PURO: no referencia nodos ni VoxelTools -> testeable en headless.
#
# Decision de diseno: el catalogo NO conoce el mundo ni el inventario. Es un
# registro. La validacion vive en `ConstruccionValidator`; el filtrado por modo
# (construccion/decoracion) es una vista (`por_modo`), no una copia.

class_name BuildCatalogDB
extends RefCounted

## Las 12 familias del bloque J del plan (RF12). El orden es el del HUD.
const FAMILIAS: Array[StringName] = [
	&"pared", &"piso", &"techo", &"puerta", &"ventana", &"escalera",
	&"puente", &"camino", &"cerca", &"iluminacion", &"mueble", &"decoracion",
]

## id -> PlacementRule (orden de insercion preservado en `_orden`).
var _por_id: Dictionary = {}
var _orden: Array[StringName] = []

## ── Carga ───────────────────────────────────────────────────────────────

## Carga recursivamente los `.tres` de `dir` que sean `PlacementRule`.
## Devuelve cuantos se registraron. Tolerante: los archivos que no son
## PlacementRule o que fallan se omiten (se cuentan en `omitidos`).
func cargar(dir: String) -> int:
	var antes: int = _por_id.size()
	_cargar_rec(dir)
	return _por_id.size() - antes

func _cargar_rec(dir: String) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	d.list_dir_begin()
	var nombre := d.get_next()
	while nombre != "":
		if nombre.begins_with("."):
			nombre = d.get_next()
			continue
		var ruta: String = dir.path_join(nombre)
		if d.current_is_dir():
			_cargar_rec(ruta)
		elif nombre.ends_with(".tres"):
			var res: Resource = ResourceLoader.load(ruta)
			if res is PlacementRule:
				registrar(res as PlacementRule)
		nombre = d.get_next()
	d.list_dir_end()

## ── Registro ────────────────────────────────────────────────────────────

## Registra (o reemplaza) una receta. Devuelve false si es invalida.
func registrar(r: PlacementRule) -> bool:
	if r == null or not r.es_valida():
		return false
	if not _por_id.has(r.id):
		_orden.append(r.id)
	_por_id[r.id] = r
	return true

## Registra varias. Devuelve cuantas se aceptaron.
func registrar_lista(lista: Array) -> int:
	var n: int = 0
	for r in lista:
		if registrar(r):
			n += 1
	return n

## Elimina una receta del catalogo. true si existia.
func quitar(id: StringName) -> bool:
	if not _por_id.has(id):
		return false
	_por_id.erase(id)
	_orden.erase(id)
	return true

func limpiar() -> void:
	_por_id.clear()
	_orden.clear()

## ── Consultas ───────────────────────────────────────────────────────────

func receta(id: StringName) -> PlacementRule:
	return _por_id.get(id, null) as PlacementRule

func tiene(id: StringName) -> bool:
	return _por_id.has(id)

func cantidad() -> int:
	return _por_id.size()

## Ids en orden de registro.
func ids() -> Array[StringName]:
	return _orden.duplicate()

## Familias PRESENTES en el catalogo, en el orden canonico de `FAMILIAS`.
func familias_presentes() -> Array[StringName]:
	var out: Array[StringName] = []
	for f in FAMILIAS:
		for id in _orden:
			var r: PlacementRule = _por_id[id]
			if r.familia == f:
				out.append(f)
				break
	return out

## Recetas de una familia, en orden de registro.
func por_familia(fam: StringName) -> Array[PlacementRule]:
	var out: Array[PlacementRule] = []
	for id in _orden:
		var r: PlacementRule = _por_id[id]
		if r.familia == fam:
			out.append(r)
	return out

## Filtra por modo: `es_mueble == false` -> construccion; `true` -> decoracion.
func por_modo(es_mueble: bool) -> Array[PlacementRule]:
	var out: Array[PlacementRule] = []
	for id in _orden:
		var r: PlacementRule = _por_id[id]
		if r.es_mueble == es_mueble:
			out.append(r)
	return out

## Conteo por familia (solo las presentes).
func conteo_por_familia() -> Dictionary:
	var out: Dictionary = {}
	for f in FAMILIAS:
		var n: int = 0
		for id in _orden:
			if (_por_id[id] as PlacementRule).familia == f:
				n += 1
		if n > 0:
			out[f] = n
	return out

## ── Diagnostico ─────────────────────────────────────────────────────────

## Audita el catalogo. Devuelve {ok, problemas: Array[String], n, familias}.
## NO lanza: reporta. `ok` es false si hay algo que arreglar.
func validar() -> Dictionary:
	var problemas: Array[String] = []
	for id in _orden:
		var r: PlacementRule = _por_id[id]
		if r.id != id:
			problemas.append("%s: id desalineado con la clave (%s)" % [String(id), String(r.id)])
		if r.nombre.strip_edges() == "":
			problemas.append("%s: sin nombre" % String(id))
		if r.tamano.x < 1 or r.tamano.y < 1:
			problemas.append("%s: tamano invalido %s" % [String(id), str(r.tamano)])
		if not es_familia(r.familia):
			problemas.append("%s: familia desconocida '%s'" % [String(id), String(r.familia)])
		if r.soportes_minimos < 0:
			problemas.append("%s: soportes_minimos negativo" % String(id))
		if r.sobre_agua and not r.superficie_ok.has(&"agua"):
			problemas.append("%s: sobre_agua=true pero 'agua' no esta en superficie_ok" % String(id))
		if r.devolucion < 0.0 or r.devolucion > 1.0:
			problemas.append("%s: devolucion fuera de [0,1]" % String(id))
		for k in r.costo.keys():
			if int(r.costo[k]) <= 0:
				problemas.append("%s: costo '%s' <= 0" % [String(id), String(k)])
	return {
		"ok": problemas.is_empty(),
		"problemas": problemas,
		"n": _por_id.size(),
		"familias": familias_presentes(),
	}

## true si `fam` es una de las 12 familias canonicas.
static func es_familia(fam: StringName) -> bool:
	return FAMILIAS.has(fam)

## Las 12 familias con conteo (0 para las ausentes). Para el HUD.
func mapa_de_familias() -> Dictionary:
	var out: Dictionary = {}
	for f in FAMILIAS:
		out[f] = por_familia(f).size()
	return out
