# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M38: Economía — PriceManager
# Precios vigentes por ítem con reglas cozy:
#  - Base desde ItemData (M159: precio_compra / precio_venta)
#  - Venta NUNCA supera el 50-60% de la compra (anti-arbitraje §4.2)
#  - Límite diario de ventas por ítem (anti-grind); excedido → precio al 50%
#  - Ventana de oferta 3 días: ajuste entre -10% y 0% (§2.4)
#  - Descuento por amistad M20 (placeholder: sin M20, descuento 0)
# Los enteros mandan en el precio final (Optimización §7).

class_name PriceManager
extends RefCounted

## Tope de venta como fracción de la compra (regla §8: 50-60%)
const TOPE_VENTA_SOBRE_COMPRA: float = 0.6

## Precio rebajado cuando se supera el límite diario (§2.2)
const FACTOR_EXCEDIDO_DIARIO: float = 0.5

## Ventana de oferta (días laborables) y ajuste máximo por saturación
const VENTANA_OFERTA_DIAS: int = 3
const AJUSTE_OFERTA_MAX: float = 0.10   # -10% .. 0%

## Descuentos por amistad M20 (niveles 2/3/4) — activo cuando M20 exista
const DESCUENTO_AMISTAD := {2: 0.05, 3: 0.10, 4: 0.15}

## Límites diarios de venta por banda (tabla §8): común/comida=3, procesado/fino=2, raro=1
const LIMITE_VENTA_DEFAULT: int = 3

## Límite diario por banda de rareza (tabla §8 actualizada a 4 bandas del catálogo M38).
## Conserva el espíritu cozy (nunca 0) y desincentiva el grind sin castigar el progreso.
const LIMITE_VENTA_POR_BANDA := {
	"comun": 3,
	"poco_comun": 3,
	"raro": 2,
	"epico": 1,
}

var _db = null  # ItemDatabase (Node) — se resuelve lazy para evitar orden de autoloads
var _catalog = null  # EconomyPriceCatalog (Resource) — cache lazy del catálogo econ_prices.tres
var _ventas_hoy: Dictionary = {}          # item_id -> cantidad vendida hoy
var _ventas_ventana: Array[Dictionary] = []  # {item_id, cantidad, dia}
var _dia_actual: int = 0

func _db_get():
	if _db == null:
		_db = Engine.get_main_loop().root.get_node_or_null("/root/ItemDatabase")
	return _db

## Cache del catálogo central de precios (econ_prices.tres). Puede no existir en
## builds parciales; entonces devuelve null y se cae al comportamiento default.
func _catalog_get():
	if _catalog == null:
		var cls: Script = load("res://scripts/economia/economy_price_catalog.gd")
		if cls != null and cls.can_instantiate():
			_catalog = cls.get_catalog()
	return _catalog

## ── Consultas de precio ──────────────────────────────────

func precio_compra_vigente(item_id: String, npc_id: String = "") -> int:
	var base := _precio_base_compra(item_id)
	if base <= 0:
		return 0
	var desc := _descuento_amistad(npc_id)
	var final := int(round(float(base) * (1.0 - desc)))
	return maxi(1, final)

func precio_venta_vigente(item_id: String) -> int:
	var compra := _precio_base_compra(item_id)
	if compra <= 0:
		return 0
	var base := int(round(float(compra) * TOPE_VENTA_SOBRE_COMPRA))
	base = _ajuste_por_oferta(item_id, base)
	return maxi(1, base)

## Límite diario de ventas del ítem (anti-grind).
## Resuelve la banda de rareza: primero del catálogo central (PriceDefinition.rareza),
## luego del ItemData (enum Rareza del ítem), y por defecto LIMITE_VENTA_DEFAULT.
func limite_ventas_dia(item_id: String) -> int:
	var banda := _banda_de(item_id)
	return int(LIMITE_VENTA_POR_BANDA.get(banda, LIMITE_VENTA_DEFAULT))

## Resuelve la banda de rareza de un ítem como string ("comun", "poco_comun", "raro", "epico").
func _banda_de(item_id: String) -> String:
	if item_id.is_empty():
		return ""
	# 1) Override explícito del catálogo central (econ_prices.tres).
	var cat = _catalog_get()
	if cat != null and cat.has_method("get_price_def"):
		var def = cat.get_price_def(item_id)
		if def != null and not str(def.rareza).is_empty():
			return _normalizar_banda(str(def.rareza))
	# 2) Rareza del ítem en ItemData (M159).
	var db = _db_get()
	if db != null and db.has_method("get_item"):
		var item = db.get_item(item_id)
		if item != null:
			return _banda_por_enum(int(item.rareza))
	return ""

## Mapea el enum ItemData.Rareza (0..3) a la banda string del catálogo.
func _banda_por_enum(r: int) -> String:
	match r:
		3: return "epico"
		2: return "raro"
		1: return "poco_comun"
		_: return "comun"

## Normaliza variantes de escritura del catálogo hacia la clave canónica.
func _normalizar_banda(b: String) -> String:
	var v := b.to_lower().strip_edges()
	match v:
		"epico", "legendario", "legendary", "epic": return "epico"
		"raro", "rare": return "raro"
		"poco_comun", "poco común", "uncommon", "poco comun": return "poco_comun"
		_: return "comun"

## Cantidad vendida hoy de un ítem.
func ventas_hoy(item_id: String) -> int:
	return int(_ventas_hoy.get(item_id, 0))

## Registra una venta (la invoca EconomyManager tras depositar).
func registrar_venta(item_id: String, cantidad: int, dia: int) -> void:
	if dia != _dia_actual:
		_dia_actual = dia
		_ventas_hoy.clear()
	_ventas_hoy[item_id] = ventas_hoy(item_id) + cantidad
	_ventas_ventana.append({"item_id": item_id, "cantidad": cantidad, "dia": dia})
	_podar_ventana(dia)

## ¿Precio rebajado por haber superado el límite diario?
func precio_rebajado_hoy(item_id: String) -> bool:
	return ventas_hoy(item_id) > limite_ventas_dia(item_id)

## Serializa estado (§6)
func serializar() -> Dictionary:
	return {
		"ventas_hoy": _ventas_hoy.duplicate(),
		"ventana": _ventas_ventana.duplicate(true),
		"dia": _dia_actual,
	}

func deserializar(d: Dictionary) -> void:
	_ventas_hoy.clear()
	var vh: Dictionary = d.get("ventas_hoy", {})
	for k in vh:
		_ventas_hoy[str(k)] = int(vh[k])
	_ventas_ventana.clear()
	for e in d.get("ventana", []):
		_ventas_ventana.append({"item_id": str(e.get("item_id", "")), "cantidad": int(e.get("cantidad", 0)), "dia": int(e.get("dia", 0))})
	_dia_actual = int(d.get("dia", 0))

# ── Internos ──────────────────────────────────────────────

func _precio_base_compra(item_id: String) -> int:
	var db = _db_get()
	if db == null:
		return 0
	var item = db.get_item(item_id)
	if item == null:
		return 0
	return maxi(0, int(item.precio_compra))

## Ajuste por ventana de oferta: ventas recientes bajan el precio hasta -10%
func _ajuste_por_oferta(item_id: String, base: int) -> int:
	var vendidas := 0
	for e in _ventas_ventana:
		if str(e["item_id"]) == item_id:
			vendidas += int(e["cantidad"])
	var factor := 1.0 - minf(AJUSTE_OFERTA_MAX, float(vendidas) * 0.02)
	var ajustado := int(round(float(base) * factor))
	return clampi(ajustado, maxi(1, int(round(float(base) * (1.0 - AJUSTE_OFERTA_MAX)))), base)

## Descuento por amistad (M20): consulta niveles del autoload Friendship.
## Sin npc_id, sin M20 o nivel < 2 → sin descuento (comportamiento previo).
func _descuento_amistad(npc_id: String) -> float:
	if npc_id.is_empty():
		return 0.0
	var fs = Engine.get_main_loop().root.get_node_or_null("/root/Friendship")
	if fs == null or not fs.has_method("get_nivel"):
		return 0.0
	var nivel := int(fs.get_nivel(npc_id))
	var mejor := 0.0
	for umbral in DESCUENTO_AMISTAD:
		if nivel >= int(umbral):
			mejor = maxf(mejor, float(DESCUENTO_AMISTAD[umbral]))
	return mejor

func _podar_ventana(dia: int) -> void:
	while _ventas_ventana.size() > 0 and (dia - int(_ventas_ventana[0]["dia"])) > VENTANA_OFERTA_DIAS:
		_ventas_ventana.pop_front()
