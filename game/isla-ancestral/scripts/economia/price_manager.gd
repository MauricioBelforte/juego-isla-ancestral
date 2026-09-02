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

## ── Señales (contrato §5: UI mercado, feedback) ──
signal tabla_precios_actualizada(tabla: Dictionary)
signal precio_rebajado(item_id: String, antes: int, despues: int)

## Bonos/penalizaciones estacionales (RF9, diseño §2.4, tope ±10%)
const TEMPORADA_BONUS_COMPRA: float = 0.05      # +5% en temporada del ítem
const TEMPORADA_PENALIZACION: float = 0.10      # -10% fuera de temporada

## Tope de venta como fracción de la compra (regla §8: 50-60%)
const TOPE_VENTA_SOBRE_COMPRA: float = 0.6

## Precio rebajado cuando se supera el límite diario (§2.2)
const FACTOR_EXCEDIDO_DIARIO: float = 0.5

## Ventana de oferta (días laborables) y ajuste máximo por saturación
const VENTANA_OFERTA_DIAS: int = 3
const AJUSTE_OFERTA_MAX: float = 0.10   # -10% .. 0%

## Descuentos por amistad M20 (niveles 2/3/4) — activo cuando M20 exista
const DESCUENTO_AMISTAD := {2: 0.05, 3: 0.10, 4: 0.15}

## ── Precio minorista/mayorista por volumen (M38) ──────────
## La compra en bulto baja el precio unitario (mayorista) respecto al minorista.
## Regla cozy: tope TOTAL 20% (amistad + volumen) y NUNCA bonificar la venta del
## jugador en volumen (anti-grind), el precio de venta por unidad es estable.
const _VOLUMEN_TRAMOS := [
	{"min": 1, "desc": 0.00},
	{"min": 5, "desc": 0.05},
	{"min": 10, "desc": 0.10},
	{"min": 20, "desc": 0.15},
]
const DESCUENTO_VOLUMEN_MAX: float = 0.15
const DESCUENTO_TOTAL_MAX: float = 0.20  # amistad + volumen nunca superan 20%

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

## Estado de mercado (RF9 estación, RF14 ferias) — duck-typed, no acopla módulos vecinos
var _estacion_forzado: String = ""          # override de estación (test/control externo)
var _multiplicador_feria_compra: float = 1.0
var _multiplicador_feria_venta: float = 1.0
var _feria_activa: bool = false

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

## Precio de venta al jugador en la tienda (lo que paga). `cantidad` aplica el
## descuento mayorista por volumen (M38). Devuelve precio UNITARIO (ShopManager
## multiplica por cantidad), ya clampeado a >= 1.
func precio_compra_vigente(item_id: String, npc_id: String = "", cantidad: int = 1) -> int:
	var base := _precio_base_compra(item_id)
	if base <= 0:
		return 0
	var mercado := _ajuste_estacional(item_id, base)
	mercado = int(round(float(mercado) * _multiplicador_feria_compra))
	var desc_amistad := _descuento_amistad(npc_id)
	var desc_volumen := _descuento_volumen(cantidad)
	var desc_total := minf(desc_amistad + desc_volumen, DESCUENTO_TOTAL_MAX)
	var final := int(round(float(mercado) * (1.0 - desc_total)))
	return maxi(1, final)

func precio_venta_vigente(item_id: String) -> int:
	var compra := _precio_base_compra(item_id)
	if compra <= 0:
		return 0
	var base := int(round(float(compra) * TOPE_VENTA_SOBRE_COMPRA))
	base = _ajuste_estacional(item_id, base)
	base = int(round(float(base) * _multiplicador_feria_venta))
	base = _ajuste_por_oferta(item_id, base)
	var final := maxi(1, base)
	# RF11 (anti-grind): la venta NUNCA supera la compra vigente (reventa no rentable).
	var tope := precio_compra_vigente(item_id)
	if final > tope:
		final = tope
	return final

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

## ── RF10: Tabla de precios del día (dato puro para la UI, M53/M55) ──
## Devuelve { item_id: {compra, venta, limite, vendidas_hoy, rebajado} }.
## `item_ids` vacío → enumera candidatos del catálogo central (overrides) + ítems
## con ventas registradas. Solo incluye ítems con precio base > 0.
## Sin bucles por frame: se consulta bajo demanda (apertura de tienda/diario).
func tabla_del_dia(item_ids: Array = []) -> Dictionary:
	var candidatos: Array[String] = []
	for id in item_ids:
		var s := str(id)
		if not s.is_empty() and not candidatos.has(s):
			candidatos.append(s)
	if candidatos.is_empty():
		# Enumeración fallback: overrides del catálogo + ítems con actividad.
		var cat = _catalog_get()
		if cat != null and "price_overrides" in cat:
			for e in cat.price_overrides:
				var s2 := str(e.item_id)
				if not candidatos.has(s2):
					candidatos.append(s2)
		for id in _ventas_hoy:
			var s3 := str(id)
			if not candidatos.has(s3):
				candidatos.append(s3)
		for e in _ventas_ventana:
			var s4 := str(e["item_id"])
			if not candidatos.has(s4):
				candidatos.append(s4)
		candidatos.sort()  # orden estable para la UI (determinismo de datos)

	var tabla: Dictionary = {}
	for id in candidatos:
		var compra := precio_compra_vigente(id, "", 1)
		if compra <= 0:
			continue  # ítem sin precio definido: fuera de la tabla del día
		tabla[id] = {
			"compra": compra,
			"venta": precio_venta_vigente(id),
			"limite": limite_ventas_dia(id),
			"vendidas_hoy": ventas_hoy(id),
			"rebajado": precio_rebajado_hoy(id),
		}
	return tabla

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

# ── Mercado: estación (RF9) y ferias (RF14) ──

## Fuerza la estación activa (override para test o control externo). Vacío → lee del calendario.
func forzar_estacion(nombre: String) -> void:
	_estacion_forzado = "" if nombre == null else str(nombre)

## Ajuste estacional (RF9, diseño §2.4): +5% en temporada del ítem, -10% fuera. Sin temporada → sin cambio.
func _ajuste_estacional(item_id: String, base: int) -> int:
	var temporada_item := _temporada_item(item_id)
	if temporada_item.is_empty():
		return base
	var actual := _nombre_estacion_actual()
	if actual.is_empty():
		return base
	if temporada_item == actual:
		return int(round(float(base) * (1.0 + TEMPORADA_BONUS_COMPRA)))
	return int(round(float(base) * (1.0 - TEMPORADA_PENALIZACION)))

## Resuelve la temporada del ítem desde el catálogo central (PriceDefinition.temporada_bonus).
func _temporada_item(item_id: String) -> String:
	var cat = _catalog_get()
	if cat != null and cat.has_method("get_price_def"):
		var def = cat.get_price_def(item_id)
		if def != null:
			var tb = def.get("temporada_bonus")
			if tb != null:
				return str(tb)
	return ""

## Nombre de la estación actual (intenta autoload /root/TimeCalendar o ServiceRegistry).
func _nombre_estacion_actual() -> String:
	if not _estacion_forzado.is_empty():
		return _estacion_forzado
	var tc = _resolver_calendario()
	if tc != null and tc.has_method("get_estacion") and tc.has_method("get_nombre_estacion"):
		return str(tc.get_nombre_estacion(int(tc.get_estacion())))
	return ""

func _resolver_calendario():
	var root = Engine.get_main_loop().root
	var tc = root.get_node_or_null("/root/TimeCalendar")
	if tc != null:
		return tc
	var sr = root.get_node_or_null("/root/ServiceRegistry")
	if sr != null and sr.has_method("get_service"):
		return sr.get_service("time_calendar")
	return null

## Aplica precios especiales de feria (RF14) leídos de EventDefinition.flags.
func aplicar_precios_feria(multiplicador_compra: float, multiplicador_venta: float) -> void:
	_multiplicador_feria_compra = clampf(float(multiplicador_compra), 0.1, 5.0)
	_multiplicador_feria_venta = clampf(float(multiplicador_venta), 0.1, 5.0)
	_feria_activa = true
	_emitir_tabla()

func limpiar_precios_feria() -> void:
	_multiplicador_feria_compra = 1.0
	_multiplicador_feria_venta = 1.0
	_feria_activa = false
	_emitir_tabla()

func esta_feria_activa() -> bool:
	return _feria_activa

## Recálculo diario (RF9): refresca estación y avisa a la UI. Llamado al amanecer (M31) o manualmente.
func recalcular_tabla_dia() -> void:
	_emitir_tabla()

func _emitir_tabla() -> void:
	tabla_precios_actualizada.emit(tabla_del_dia())

## Vincula EventManager (M73) para ferias (duck-typing; no acopla si no existe).
func vincular_eventos() -> void:
	var em = _resolver_event_manager()
	if em == null:
		return
	if em.has_signal("evento_iniciado") and not em.is_connected("evento_iniciado", Callable(self, "_on_evento_iniciado")):
		em.connect("evento_iniciado", Callable(self, "_on_evento_iniciado"))
	if em.has_signal("evento_terminado") and not em.is_connected("evento_terminado", Callable(self, "_on_evento_terminado")):
		em.connect("evento_terminado", Callable(self, "_on_evento_terminado"))

func _on_evento_iniciado(evento_id) -> void:
	var ev = _evento_def(evento_id)
	if ev == null:
		return
	var flags = ev.get("flags")
	if typeof(flags) != TYPE_DICTIONARY:
		return
	var mc = float(flags.get("precio_compra", 1.0))
	var mv = float(flags.get("precio_venta", 1.0))
	if mc != 1.0 or mv != 1.0:
		aplicar_precios_feria(mc, mv)

func _on_evento_terminado(evento_id) -> void:
	limpiar_precios_feria()

func _resolver_event_manager():
	var root = Engine.get_main_loop().root
	var em = root.get_node_or_null("/root/EventManager")
	if em != null:
		return em
	var sr = root.get_node_or_null("/root/ServiceRegistry")
	if sr != null and sr.has_method("get_service"):
		return sr.get_service("event_manager")
	return null

func _evento_def(evento_id):
	var em = _resolver_event_manager()
	if em == null or not em.has_method("get_evento_by_id"):
		return null
	return em.get_evento_by_id(str(evento_id))

# ── Internos ──────────────────────────────────────────────

func _precio_base_compra(item_id: String) -> int:
	# 1) Override del catálogo central (econ_prices.tres) — flujo documentado en
	#    economy_price_catalog.gd §1: overrides PRIMERO, luego ItemData (M159).
	#    (Fix M39: se usaba solo para rareza; el precio siempre caía a 0 sin M159.)
	var cat = _catalog_get()
	if cat != null and cat.has_method("get_price_def"):
		var def = cat.get_price_def(item_id)
		if def != null and int(def.precio_compra) > 0:
			return maxi(0, int(def.precio_compra))
	# 2) ItemData base (M159) cuando exista
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

## Descuento minorista/mayorista por volumen: mayor cantidad → mayor descuento
## por unidad (tramos 1/5/10/20). Nunca negativo; `cantidad <= 0` se trata como 1.
func _descuento_volumen(cantidad: int) -> float:
	var c := maxi(cantidad, 1)
	var mejor := 0.0
	for tramo in _VOLUMEN_TRAMOS:
		if c >= int(tramo["min"]):
			mejor = maxf(mejor, float(tramo["desc"]))
	return mejor

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
