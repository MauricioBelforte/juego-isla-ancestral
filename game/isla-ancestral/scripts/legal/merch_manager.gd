# Modelo: agnes-3.0-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-05
#
# M129: Merchandising — MerchManager (capa de servicio / autoload).
# Carga el catalog data-driven (data/legal/merchandising.json), expone consultas
# y delega la validacion en MerchValidator. Cierra la brecha de Hy3: la capa de
# servicio estaba ausente (solo existia el JSON + validator + test).
#
# Registro en ServiceRegistry como "merch" (idempotente: no rompe si el registro
# aun no esta disponible). No acopla gameplay: es una fachada de datos/legal.

extends Node

const RUTA_DATA := "res://data/legal/merchandising.json"

var _productos: Dictionary = {}       # id -> producto
var _ordenes: Array = []              # preservado el orden del JSON
var _politicas: Dictionary = {}
var _datos: Dictionary = {}
var _error_carga: String = ""

func _ready() -> void:
	cargar()
	_registrar_servicio()

## Carga el catalog. Publico para permitir init manual en tests headless (-s),
## donde los autoloads no se instancian.
func cargar() -> void:
	if not FileAccess.file_exists(RUTA_DATA):
		_error_carga = "archivo inexistente: %s" % RUTA_DATA
		push_warning("[M129] MerchManager: %s" % _error_carga)
		return
	var txt := FileAccess.get_file_as_string(RUTA_DATA)
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		_error_carga = "JSON invalido en %s" % RUTA_DATA
		push_warning("[M129] MerchManager: %s" % _error_carga)
		return
	_datos = parsed as Dictionary
	_politicas = _datos.get("politicas", {}) as Dictionary
	_productos.clear()
	_ordenes.clear()
	for p in _datos.get("productos", []):
		var prod: Dictionary = p as Dictionary
		if prod.is_empty():
			continue
		var id := String(prod.get("id", ""))
		if id.is_empty():
			continue
		_productos[id] = prod
		_ordenes.append(id)

## Todos los productos (Dictionary id->producto).
func get_productos() -> Dictionary:
	return _productos

## El producto con el id dado, o {} si no existe.
func get_product(id: String) -> Dictionary:
	return _productos.get(id, {}) as Dictionary

## Lista de ids en orden de carga.
func get_product_ids() -> Array:
	return _ordenes.duplicate()

## Rango de margen [min,max] del producto (o [] si no especificado).
func get_margen(id: String) -> Array:
	var p: Dictionary = _productos.get(id, {}) as Dictionary
	if p.has("margen"):
		return p["margen"]
	if p.has("margen_estimado"):
		var m: float = float(p["margen_estimado"])
		return [m, m]
	return []

## Precio [min,max] en USD (o []).
func get_precio_usd(id: String) -> Array:
	var p: Dictionary = _productos.get(id, {}) as Dictionary
	return p.get("precio_usd", [])

## Polítícas del módulo.
func get_politicas() -> Dictionary:
	return _politicas

## Valida el catalog cargado. Devuelve Array[String] de errores (vacío = OK).
func validar() -> Array:
	return MerchValidator.validar(_datos)

## True si la carga fue exitosa.
func esta_cargado() -> bool:
	return _error_carga.is_empty() and not _datos.is_empty()

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		push_warning("[M129] ServiceRegistry no disponible; MerchManager no registrado")
		return
	sr.register("merch", self)
	print("[M129] MerchManager listo (%d productos) + registrado como 'merch'" % _productos.size())
