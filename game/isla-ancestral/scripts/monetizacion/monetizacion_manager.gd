# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M95: MonetizaciónManager (autoload) — núcleo V0 data-driven.
# - RF: 3 ediciones (Standard/Deluxe/Coleccionista) con precios data-driven
# - RF: DLC expansión + cosmético (sin fragmentar historia — M152)
# - RF: 0 pay-to-win y 0 loot boxes (M94/M152 verificación)
# - RF: impuestos/reembolsos por plataforma (M96)
# - Persistencia: compras del jugador en user:// (M57/M59 pattern)
# Ejecutar test: Godot --headless --path game/isla-ancestral --script res://scripts/monetizacion/test_monetizacion.gd

extends Node

signal compra_realizada(edicion: String, precio: float)
signal dlc_descargado(dlc_id: String)
signal p2w_detectado(detalle: String)

const RUTA_DATOS := "res://data/monetizacion/monetizacion.json"
const RUTA_COMPRAS := "user://monetizacion_compras.json"

## Catálogo de ediciones y DLC (data-driven)
var _catalogo: Dictionary = {}
## Compras del jugador (edicion/dlc -> true)
var _compras: Dictionary = {}

func _ready() -> void:
	_cargar_catalogo()
	_cargar_compras()
	print("[M95] MonetizacionManager listo (%d ediciones, %d DLC)" % [
		(_catalogo.get("ediciones", {}) as Dictionary).size(),
		(_catalogo.get("dlc", {}) as Dictionary).size()])


func _cargar_catalogo() -> void:
	if not FileAccess.file_exists(RUTA_DATOS):
		push_warning("[M95] monetizacion.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATOS))
	if typeof(parsed) == TYPE_DICTIONARY:
		_catalogo = parsed


func _cargar_compras() -> void:
	if not FileAccess.file_exists(RUTA_COMPRAS):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_COMPRAS))
	if typeof(parsed) == TYPE_DICTIONARY:
		_compras = parsed


func _guardar_compras() -> void:
	var f := FileAccess.open(RUTA_COMPRAS, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_compras, "\t"))


## Verifica si una edición/DLC ya fue comprado.
func esta_comprado(id: String) -> bool:
	return _compras.has(id)


## Compra una edición (premium). Retorna {ok, precio} o {ok: false, motivo}.
func comprar_edicion(edicion_id: String) -> Dictionary:
	var ediciones: Dictionary = _catalogo.get("ediciones", {})
	if not ediciones.has(edicion_id):
		return {"ok": false, "motivo": "edición inexistente"}
	if esta_comprado(edicion_id):
		return {"ok": false, "motivo": "ya comprado"}
	var precio: float = float(ediciones[edicion_id].get("precio", 0))
	_compras[edicion_id] = {"tipo": "edicion", "precio": precio}
	guardar_compras()
	compra_realizada.emit(edicion_id, precio)
	print("[M95] Edición comprada: %s ($%.2f)" % [edicion_id, precio])
	return {"ok": true, "precio": precio}


## Compra un DLC (expansión o cosmético).
func comprar_dlc(dlc_id: String) -> Dictionary:
	var dlcs: Dictionary = _catalogo.get("dlc", {})
	if not dlcs.has(dlc_id):
		return {"ok": false, "motivo": "DLC inexistente"}
	if esta_comprado(dlc_id):
		return {"ok": false, "motivo": "ya comprado"}
	var precio: float = float(dlcs[dlc_id].get("precio", 0))
	_compras[dlc_id] = {"tipo": "dlc", "precio": precio}
	guardar_compras()
	compra_realizada.emit(dlc_id, precio)
	print("[M95] DLC comprado: %s ($%.2f)" % [dlc_id, precio])
	return {"ok": true, "precio": precio}


## Verificación M94/M152: detecta si algún item del catálogo es P2W
## (da ventaja gameplay no cosmética). Retorna lista de offenders.
func auditar_p2w() -> Array[String]:
	var offenders: Array[String] = []
	var todas := {}
	for cat in ["ediciones", "dlc"]:
		for id in _catalogo.get(cat, {}):
			var item: Dictionary = _catalogo[cat][id]
			if item.get("p2w", false):
				offenders.append(String(id))
				p2w_detectado.emit(String(id))
	if offenders.size() > 0:
		push_error("[M95] P2W detectado: %s" % str(offenders))
	return offenders


## Calcula impuesto por plataforma (M96: Steam 30%, EGS 12%, etc.)
func calcular_impuesto(precio: float, plataforma: String) -> float:
	var impuestos: Dictionary = _catalogo.get("impuestos", {})
	var pct: float = float(impuestos.get(plataforma, 0.30))  # default Steam 30%
	return precio * pct


## Catálogo de ediciones (para UI M53)
func get_ediciones() -> Dictionary:
	return _catalogo.get("ediciones", {})


## Catálogo de DLC (para UI M53)
func get_dlc() -> Dictionary:
	return _catalogo.get("dlc", {})


## Persistencia de compras (M57/M59 pattern)
func guardar_compras() -> void:
	var f := FileAccess.open(RUTA_COMPRAS, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_compras, "\t"))


func get_compras() -> Dictionary:
	return _compras.duplicate()
