# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M148: Lore Ambiental — LoreCatalogo
# Catálogo central de piezas de lore (RF1/RF9/RF10): carga data-driven desde
# JSON, índice por isla/tipo, lookup por id, validación de pistas.
# Diseño original (04-Codigo.md §1.1, LoreCatalogo.cs).

class_name LoreCatalogo
extends RefCounted

const RUTA_CATALOGO := "res://data/lore/lore.json"

var _piezas: Dictionary = {}   # id -> PiezaDeLore
var _por_isla: Dictionary = {} # isla -> Array[PiezaDeLore]
var _por_tipo: Dictionary = {} # tipo(int) -> Array[PiezaDeLore]
var _cargado: bool = false

## Carga el catálogo desde JSON. Idempotente. Fallback limpio si falta.
func cargar() -> void:
	if _cargado:
		return
	if not FileAccess.file_exists(RUTA_CATALOGO):
		push_warning("[M148] Catálogo no encontrado: %s" % RUTA_CATALOGO)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATALOGO))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("piezas"):
		push_warning("[M148] Catálogo inválido (sin clave 'piezas')")
		return
	var lista: Array = parsed["piezas"]
	for entrada in lista:
		if typeof(entrada) != TYPE_DICTIONARY:
			continue
		var pieza := _desde_dict(entrada)
		if pieza.id.is_empty():
			continue
		_piezas[pieza.id] = pieza
		if not _por_isla.has(pieza.isla):
			_por_isla[pieza.isla] = []
		(_por_isla[pieza.isla] as Array).append(pieza)
		if not _por_tipo.has(pieza.tipo):
			_por_tipo[pieza.tipo] = []
		(_por_tipo[pieza.tipo] as Array).append(pieza)
	_cargado = true
	print("[M148] LoreCatalogo: %d piezas cargadas (%d islas)" % [_piezas.size(), _por_isla.size()])

func _desde_dict(d: Dictionary) -> PiezaDeLore:
	var p := PiezaDeLore.new()
	p.id = String(d.get("id", ""))
	p.canon_ref = String(d.get("canon_ref", ""))
	p.tipo = int(d.get("tipo", 0))
	p.isla = String(d.get("isla", "raiz"))
	p.titulo = String(d.get("titulo", ""))
	p.texto = String(d.get("texto", ""))
	p.consumidor_id = String(d.get("consumidor_id", ""))
	p.temporada = String(d.get("temporada", ""))
	return p

## Lookup por id. null si no existe.
func obtener_pieza(id: String) -> PiezaDeLore:
	return _piezas.get(id, null)

## Piezas de una isla (RF9: ≥ 12 por isla).
func por_isla(isla: String) -> Array:
	return _por_isla.get(isla, []).duplicate()

## Piezas de un tipo.
func por_tipo(tipo: int) -> Array:
	return _por_tipo.get(tipo, []).duplicate()

func cantidad_total() -> int:
	return _piezas.size()

## Pistas válidas: piezas tipo pista (MURAL/ESTATUA/MAPA/CANCION) cuyo
## consumidor_id NO esté vacío (grafo de pistas, RF3).
func es_pista_valida(consumidor_id: String) -> bool:
	return not consumidor_id.is_empty()

func a_estado_exploracion() -> Array:
	return _piezas.keys()

static func desde_estado_exploracion(ids: Array) -> Dictionary:
	var out: Dictionary = {}
	for i in ids:
		out[String(i)] = true
	return out