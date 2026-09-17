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
const RUTA_CONSUMIDORES := "res://data/lore/consumidores.json"

## Tipos que actúan como "pista" hacia otro sistema (RF3).
const TIPOS_PISTA: Array[int] = [
	PiezaDeLore.Tipo.MURAL,
	PiezaDeLore.Tipo.ESTATUA,
	PiezaDeLore.Tipo.MAPA,
	PiezaDeLore.Tipo.CANCION,
]

var _piezas: Dictionary = {}   # id -> PiezaDeLore
var _por_isla: Dictionary = {} # isla -> Array[PiezaDeLore]
var _por_tipo: Dictionary = {} # tipo(int) -> Array[PiezaDeLore]
var _consumidores: Dictionary = {} # consumidor_id -> {tipo, modulo}
var _ids_duplicados: Array = []    # ids repetidos detectados al CARGAR
var _entradas_sin_id: int = 0      # entradas descartadas por id vacío
var _cargado: bool = false

## Carga el catálogo y el registro de consumidores desde JSON. Idempotente.
## Fallback limpio si falta alguno (no aborta; el LoreGate reporta).
##
## ⚠️ Los IDs duplicados se detectan AQUÍ y se acumulan en _ids_duplicados:
## como _piezas es un Dictionary por id, el duplicado se colapsaría antes de
## que el auditor pudiera verlo (el chequeo del auditor sería código muerto).
func cargar() -> void:
	if _cargado:
		return
	cargar_consumidores()
	if not FileAccess.file_exists(RUTA_CATALOGO):
		push_warning("[M148] Catálogo no encontrado: %s" % RUTA_CATALOGO)
		return
	if not cargar_desde_texto(FileAccess.get_file_as_string(RUTA_CATALOGO)):
		return
	_cargado = true
	print("[M148] LoreCatalogo: %d piezas cargadas (%d islas)" % [_piezas.size(), _por_isla.size()])

## Carga el catálogo desde un texto JSON. Reinicia el estado previo.
## Devuelve true si el documento era válido. Útil para tests/fixtures sin
## tocar el sistema de archivos (y para el LoreGate con catálogos alternos).
func cargar_desde_texto(texto: String) -> bool:
	_reset()
	var parsed: Variant = JSON.parse_string(texto)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("piezas"):
		push_warning("[M148] Catálogo inválido (sin clave 'piezas')")
		return false
	var lista: Array = parsed["piezas"]
	for entrada in lista:
		if typeof(entrada) != TYPE_DICTIONARY:
			continue
		var pieza := _desde_dict(entrada)
		if pieza.id.is_empty():
			_entradas_sin_id += 1
			continue
		if _piezas.has(pieza.id):
			_ids_duplicados.append(pieza.id)
		_piezas[pieza.id] = pieza
		if not _por_isla.has(pieza.isla):
			_por_isla[pieza.isla] = []
		(_por_isla[pieza.isla] as Array).append(pieza)
		if not _por_tipo.has(pieza.tipo):
			_por_tipo[pieza.tipo] = []
		(_por_tipo[pieza.tipo] as Array).append(pieza)
	return true

func _reset() -> void:
	_piezas.clear()
	_por_isla.clear()
	_por_tipo.clear()
	_ids_duplicados.clear()
	_entradas_sin_id = 0

## IDs repetidos detectados al cargar (orden de aparición).
func ids_duplicados() -> Array:
	return _ids_duplicados.duplicate()

## Entradas descartadas por no tener id.
func entradas_sin_id() -> int:
	return _entradas_sin_id

## Carga el registro de consumidores válidos (grafo de pistas, RF3).
func cargar_consumidores() -> void:
	if not FileAccess.file_exists(RUTA_CONSUMIDORES):
		push_warning("[M148] Registro de consumidores no encontrado: %s" % RUTA_CONSUMIDORES)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CONSUMIDORES))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("consumidores"):
		push_warning("[M148] Registro de consumidores inválido")
		return
	for c in parsed["consumidores"]:
		if typeof(c) != TYPE_DICTIONARY:
			continue
		var cid := str(c.get("id", ""))
		if cid.is_empty():
			continue
		_consumidores[cid] = {"tipo": str(c.get("tipo", "")), "modulo": str(c.get("modulo", ""))}

## ¿Existe el consumidor en el registro? (grafo de pistas, RF3)
func consumidor_valido(consumidor_id: String) -> bool:
	if consumidor_id.is_empty():
		return false
	return _consumidores.has(consumidor_id)

## Todos los ids de consumidor registrados (orden estable).
func ids_consumidores() -> Array:
	var out: Array = _consumidores.keys()
	out.sort()
	return out

## ¿La pieza es de tipo pista? (MURAL/ESTATUA/MAPA/CANCION)
static func es_tipo_pista(tipo: int) -> bool:
	return tipo in TIPOS_PISTA

## Pistas válidas: la pieza es tipo pista Y su consumidor_id existe en el
## registro (grafo de pistas real, RF3). Antes solo comprobaba "no vacío".
func es_pista_valida(consumidor_id: String) -> bool:
	return consumidor_valido(consumidor_id)

## Todas las piezas cuyo tipo es pista (para auditoría del grafo).
func pistas() -> Array:
	var out: Array = []
	for tipo in TIPOS_PISTA:
		out.append_array(por_tipo(tipo))
	return out

func _desde_dict(d: Dictionary) -> PiezaDeLore:
	var p := PiezaDeLore.new()
	p.id = str(d.get("id", ""))
	p.canon_ref = str(d.get("canon_ref", ""))
	p.tipo = int(d.get("tipo", 0))
	p.isla = str(d.get("isla", "raiz"))
	p.titulo = str(d.get("titulo", ""))
	p.texto = str(d.get("texto", ""))
	p.consumidor_id = str(d.get("consumidor_id", ""))
	p.temporada = str(d.get("temporada", ""))
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

## Todos los ids del catálogo (orden estable). NO es "estado de exploración":
## el estado real de exploración lo lleva LoreSaveProvider (persistencia).
func todos_los_ids() -> Array:
	var out: Array = _piezas.keys()
	out.sort()
	return out

## Alias legado (nombre confuso: devolvía TODOS los ids, no los explorados).
## Se conserva para no romper llamadas existentes; usar todos_los_ids().
func a_estado_exploracion() -> Array:
	return todos_los_ids()

static func desde_estado_exploracion(ids: Array) -> Dictionary:
	var out: Dictionary = {}
	for i in ids:
		out[str(i)] = true
	return out