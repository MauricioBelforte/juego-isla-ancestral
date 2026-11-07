# Modelo: DeepSeek V4.1 Flash
# Plataforma: OpenCode
# Fecha: 2026-11-06
#
# M129: Merchandising — MerchManager (capa de servicio / autoload).
# Carga el catalog data-driven (data/legal/merchandising.json), expone consultas
# y delega la validacion en MerchValidator. Cierra la brecha de Hy3: la capa de
# servicio estaba ausente (solo existia el JSON + validator + test).
#
# Registro en ServiceRegistry como "merch" (idempotente: no rompe si el registro
# aun no esta disponible). No acopla gameplay: es una fachada de datos/legal.
#
# v3 (DS-OC, 2026-11-06) — item L101 del checklist: control de stock y
# numeracion de TIRADAS LIMITADAS fisicas (artbook de pasta dura, vinilo,
# figuras de resina). Modelo de estado por SKU:
#   unidades   = tiraje total (inmutable, del JSON)
#   vendidas   = unidades confirmadas (asignan numero correlativo 1..N)
#   reservadas = unidades apartadas (preventa) que aun no asignan numero
#   numeros    = correlativos ya asignados (unico por SKU, sin huecos)
# Persistencia por el contrato de guardado de M59 (SaveManager provider).

extends Node

const RUTA_DATA := "res://data/legal/merchandising.json"
const SECCION_GUARDADO := "merch"

var _productos: Dictionary = {}       # id -> producto
var _ordenes: Array = []              # preservado el orden del JSON
var _politicas: Dictionary = {}
var _datos: Dictionary = {}
var _error_carga: String = ""
var _tiradas: Dictionary = {}         # sku -> estado de la tirada limitada
var _orden_tiradas: Array = []        # skus en orden del JSON

func _ready() -> void:
	cargar()
	_registrar_servicio()
	_registrar_proveedor_guardado()

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
	_cargar_tiradas()

func _cargar_tiradas() -> void:
	_tiradas.clear()
	_orden_tiradas.clear()
	for t in _datos.get("tiradas_limitadas", []):
		var tirada: Dictionary = t as Dictionary
		if tirada.is_empty():
			continue
		var sku := String(tirada.get("sku", ""))
		if sku.is_empty():
			continue
		_tiradas[sku] = {
			"sku": sku,
			"producto_id": String(tirada.get("producto_id", "")),
			"unidades": int(tirada.get("unidades", 0)),
			"descripcion": String(tirada.get("descripcion", "")),
			"vendidas": 0,
			"reservadas": 0,
			"numeros": [],
		}
		_orden_tiradas.append(sku)

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

# ── Tiradas limitadas (stock + numeracion) ──────────────────────────────

## Todas las tiradas (Dictionary sku->estado).
func get_tiradas() -> Dictionary:
	return _tiradas

## Estado de una tirada, o {} si el SKU no es limitado.
func get_tirada(sku: String) -> Dictionary:
	return _tiradas.get(sku, {}) as Dictionary

## Skus de tiradas limitadas en orden de carga.
func get_tirada_ids() -> Array:
	return _orden_tiradas.duplicate()

## True si el SKU pertenece a una tirada limitada.
func es_tirada_limitada(sku: String) -> bool:
	return _tiradas.has(sku)

## Tiraje total del SKU (0 si no es limitado).
func unidades_totales(sku: String) -> int:
	if not _tiradas.has(sku):
		return 0
	return int(_tiradas[sku]["unidades"])

## Unidades ya vendidas (numeros asignados).
func unidades_vendidas(sku: String) -> int:
	if not _tiradas.has(sku):
		return 0
	return int(_tiradas[sku]["vendidas"])

## Unidades reservadas (preventa) que aun no asignan numero.
func unidades_reservadas(sku: String) -> int:
	if not _tiradas.has(sku):
		return 0
	return int(_tiradas[sku]["reservadas"])

## Unidades disponibles = total - vendidas - reservadas.
## Devuelve -1 si el SKU no es una tirada limitada (stock no aplica).
func unidades_disponibles(sku: String) -> int:
	if not _tiradas.has(sku):
		return -1
	var t: Dictionary = _tiradas[sku]
	return int(t["unidades"]) - int(t["vendidas"]) - int(t["reservadas"])

## Correlativos ya asignados al SKU (copia).
func get_numeros_asignados(sku: String) -> Array:
	if not _tiradas.has(sku):
		return []
	return (_tiradas[sku]["numeros"] as Array).duplicate()

## Aparta unidades para preventa. No asigna numero todavia.
## Devuelve {ok, motivo, disponibles}.
func reservar_unidades(sku: String, cantidad: int = 1) -> Dictionary:
	if not _tiradas.has(sku):
		return {"ok": false, "motivo": "sku_no_limitado", "disponibles": -1}
	var disp := unidades_disponibles(sku)
	if cantidad <= 0:
		return {"ok": false, "motivo": "cantidad_invalida", "disponibles": disp}
	if cantidad > disp:
		return {"ok": false, "motivo": "stock_insuficiente", "disponibles": disp}
	_tiradas[sku]["reservadas"] = int(_tiradas[sku]["reservadas"]) + cantidad
	return {"ok": true, "motivo": "", "disponibles": unidades_disponibles(sku)}

## Libera una reserva (cancelacion de preventa).
## Devuelve {ok, motivo, disponibles}.
func liberar_reserva(sku: String, cantidad: int = 1) -> Dictionary:
	if not _tiradas.has(sku):
		return {"ok": false, "motivo": "sku_no_limitado", "disponibles": -1}
	var reservadas := unidades_reservadas(sku)
	if cantidad <= 0:
		return {"ok": false, "motivo": "cantidad_invalida", "disponibles": unidades_disponibles(sku)}
	if cantidad > reservadas:
		return {"ok": false, "motivo": "reserva_insuficiente", "disponibles": unidades_disponibles(sku)}
	_tiradas[sku]["reservadas"] = reservadas - cantidad
	return {"ok": true, "motivo": "", "disponibles": unidades_disponibles(sku)}

## Confirma una venta: consume primero las reservas y luego stock libre, y
## asigna correlativos 1..N (unicos, sin huecos). Devuelve {ok, motivo,
## numeros, disponibles}.
func confirmar_venta(sku: String, cantidad: int = 1) -> Dictionary:
	if not _tiradas.has(sku):
		return {"ok": false, "motivo": "sku_no_limitado", "numeros": [], "disponibles": -1}
	var t: Dictionary = _tiradas[sku]
	var total := int(t["unidades"])
	var vendidas := int(t["vendidas"])
	if cantidad <= 0:
		return {"ok": false, "motivo": "cantidad_invalida", "numeros": [], "disponibles": unidades_disponibles(sku)}
	if vendidas + cantidad > total:
		return {"ok": false, "motivo": "stock_insuficiente", "numeros": [], "disponibles": unidades_disponibles(sku)}
	# Consumir reservas primero; el resto sale del stock libre.
	var de_reserva: int = min(cantidad, int(t["reservadas"]))
	t["reservadas"] = int(t["reservadas"]) - de_reserva
	var nuevos: Array = []
	for i in range(cantidad):
		nuevos.append(vendidas + i + 1)
	t["vendidas"] = vendidas + cantidad
	var acumulados: Array = t["numeros"] as Array
	acumulados.append_array(nuevos)
	t["numeros"] = acumulados
	return {"ok": true, "motivo": "", "numeros": nuevos, "disponibles": unidades_disponibles(sku)}

## Reinicia el estado dinamico de todas las tiradas (solo tests / nueva partida).
func reiniciar_tiradas() -> void:
	for sku in _orden_tiradas:
		_tiradas[sku]["vendidas"] = 0
		_tiradas[sku]["reservadas"] = 0
		_tiradas[sku]["numeros"] = []

# ── Persistencia (M59: SaveManager provider) ────────────────────────────

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		push_warning("[M129] ServiceRegistry no disponible; MerchManager no registrado")
		return
	sr.register("merch", self)
	print("[M129] MerchManager listo (%d productos, %d tiradas limitadas) + registrado como 'merch'"
		% [_productos.size(), _orden_tiradas.size()])

func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

func get_section_name() -> String:
	return SECCION_GUARDADO

func get_save_data() -> Dictionary:
	var estado: Dictionary = {}
	for sku in _orden_tiradas:
		var t: Dictionary = _tiradas[sku]
		estado[sku] = {
			"vendidas": int(t["vendidas"]),
			"reservadas": int(t["reservadas"]),
			"numeros": (t["numeros"] as Array).duplicate(),
		}
	return {"version": 1, "tiradas": estado}

func restore_save_data(data: Dictionary) -> void:
	var estado: Dictionary = data.get("tiradas", {}) as Dictionary
	for sku in _orden_tiradas:
		if not estado.has(sku):
			continue
		var e: Dictionary = estado[sku] as Dictionary
		var total := unidades_totales(sku)
		var vendidas: int = clampi(int(e.get("vendidas", 0)), 0, total)
		var reservadas: int = clampi(int(e.get("reservadas", 0)), 0, total - vendidas)
		var numeros: Array = []
		for n in e.get("numeros", []):
			var v := int(n)
			if v >= 1 and v <= total:
				numeros.append(v)
		# Si el save viene inconsistente (numeros != vendidas o duplicados),
		# se reconstruye 1..vendidas: los correlativos no pueden tener huecos.
		if numeros.size() != vendidas or _hay_duplicados(numeros):
			numeros = []
			for i in range(vendidas):
				numeros.append(i + 1)
		_tiradas[sku]["vendidas"] = vendidas
		_tiradas[sku]["reservadas"] = reservadas
		_tiradas[sku]["numeros"] = numeros

func _hay_duplicados(arr: Array) -> bool:
	var vistos: Dictionary = {}
	for n in arr:
		if vistos.has(n):
			return true
		vistos[n] = true
	return false
