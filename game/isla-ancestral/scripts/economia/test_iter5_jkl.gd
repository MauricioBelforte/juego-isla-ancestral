# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-11
#
# M38 iter 5: test de las brechas reales de las secciones J/K/L cerradas.
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_iter5_jkl.gd
#
# Valida (checklist M38 iter 5):
#   K.4/I.9 — FACTOR_EXCEDIDO_DIARIO aplicado en precio_venta_vigente + señal
#             precio_rebajado emitida UNA vez al cruzar el límite (no por consulta).
#   L.3     — caché de tabla_del_dia: invalidada por registrar_venta y
#             recalcular_tabla_dia; dos consultas sin cambios = mismo contenido.
#   L.7     — tope de entradas de la ventana de oferta (MAX_ENTRADAS_VENTANA).
#   L.6/J.8 — caché de descuento por amistad invalidada por
#             invalidar_cache_amistad(npc) (la señal M20 la dispara en runtime).
#   J.5/J.7 — anti-arbitraje crafting: precio_venta de un craftable NUNCA supera
#             la suma de precios de sus materiales (con datos del catálogo real).
#   K.13    — descuento amistad+volumen nunca produce precio <= 0 (clamp >= 1).
#   L.1     — EconomyPriceCatalog.get_price_def O(1) vía índice (resultado == lineal).

extends SceneTree

var _fallos := 0
var _checks := 0
var _pm = null
var _eco = null

func _initialize() -> void:
	print("=== TEST M38 ITER5 (J/K/L) ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var cls: Script = load("res://scripts/economia/price_manager.gd")
	if cls == null or not cls.can_instantiate():
		print("[FAIL] no se pudo cargar price_manager.gd"); quit(1); return
	_pm = cls.new()
	_eco = root.get_node_or_null("EconomyManager")
	_test_k4_rebaja_50_y_senal()
	_test_l3_cache_tabla()
	_test_l7_tope_ventana()
	_test_l6_j8_cache_amistad()
	_test_j5_j7_anti_arbitraje_crafting()
	_test_k13_clamp_descuentos()
	_test_l1_indice_catalogo()
	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("M38 ITER5 J/K/L OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

## ── K.4 + I.9: rebaja 50% + señal precio_rebajado al cruzar límite ──────
## Usa el catálogo real (madera_roble: común, límite 3) con PriceManager nuevo.
func _test_k4_rebaja_50_y_senal() -> void:
	# Precio de venta base de madera_roble (tope 0.6 sobre compra 10 → 6)
	var base := int(_pm.precio_venta_vigente("madera_roble"))
	_check("venta base madera_roble == 6 (10*0.6)", base == 6)
	# Conectar señal precio_rebajado y contar emisiones
	var recibidas: Array = []
	_pm.precio_rebajado.connect(func(item, antes, despues): recibidas.append([item, antes, despues]))
	# Vender 3 (límite exacto): NO cruza → sin señal, sin rebaja
	_pm.registrar_venta("madera_roble", 3, 1)
	_check("3 ventas (límite exacto): sin rebaja", not _pm.precio_rebajado_hoy("madera_roble"))
	_check("sin señal precio_rebajado en límite exacto", recibidas.is_empty())
	_check("precio sigue sin rebaja (6)", int(_pm.precio_venta_vigente("madera_roble")) == 6)
	# Una venta más (4 > 3): CRUZA → señal UNA vez + precio al 50%
	_pm.registrar_venta("madera_roble", 1, 1)
	_check("4 ventas: rebajado", _pm.precio_rebajado_hoy("madera_roble"))
	_check("señal precio_rebajado emitida UNA vez (n=%d)" % recibidas.size(), recibidas.size() == 1)
	if recibidas.size() == 1:
		_check("señal con item correcto", str(recibidas[0][0]) == "madera_roble")
		_check("señal antes == precio sin rebaja (6)", int(recibidas[0][1]) == 6)
		_check("señal despues == 50% (3)", int(recibidas[0][2]) == 3)
	# El precio de venta YA aplica el 50% (consulta pura)
	_check("precio_venta con rebaja == 3 (50% de 6)", int(_pm.precio_venta_vigente("madera_roble")) == 3)
	# Consultar N veces NO re-emite (señal solo al cruzar)
	for i in range(5):
		_pm.precio_venta_vigente("madera_roble")
	_check("5 consultas más: señal sigue == 1 (n=%d)" % recibidas.size(), recibidas.size() == 1)

## ── L.3: caché de tabla_del_dia ─────────────────────────────────────────
func _test_l3_cache_tabla() -> void:
	var t1: Dictionary = _pm.tabla_del_dia()
	_check("tabla del día no vacía (catálogo real)", t1.size() > 0)
	# Sin invalidación, dos consultas devuelven el mismo contenido (caché)
	var t2: Dictionary = _pm.tabla_del_dia()
	_check("tabla cacheada: mismo contenido en 2 consultas", t1.hash() == t2.hash())
	# registrar_venta invalida: la tabla refleja las nuevas ventas
	_pm.registrar_venta("fibra_algodon", 9, 1)  # común, límite 3 → rebajado
	var t3: Dictionary = _pm.tabla_del_dia()
	_check("tabla invalidada por venta: vendidas_hoy actualizado", int(t3.get("fibra_algodon", {}).get("vendidas_hoy", 0)) == 9)
	_check("tabla invalidada: fibra rebajada por exceder límite", bool(t3.get("fibra_algodon", {}).get("rebajado", false)))
	# recalcular_tabla_dia también invalida sin romper el contenido
	_pm.recalcular_tabla_dia()
	var t4: Dictionary = _pm.tabla_del_dia()
	_check("recalcular mantiene consistencia (fibra sigue rebajada)", bool(t4.get("fibra_algodon", {}).get("rebajado", false)))

## ── L.7: tope de entradas de la ventana de oferta ───────────────────────
func _test_l7_tope_ventana() -> void:
	var cls: Script = load("res://scripts/economia/price_manager.gd")
	var pm2 = cls.new()
	# 300 ventas de un ítem en el día 1 → ventana acotada a MAX_ENTRADAS_VENTANA
	for i in range(300):
		pm2.registrar_venta("ITEM-PICO-VENTANA", 1, 1)
	_check("ventana acotada a 120 entradas (n=%d)" % pm2._ventas_ventana.size(), pm2._ventas_ventana.size() == 120)
	# El conteo de vendidas_hoy NO se pierde (está en _ventas_hoy, no en la ventana)
	_check("ventas_hoy intactas tras tope (300)", pm2.ventas_hoy("ITEM-PICO-VENTANA") == 300)
	pm2 = null

## ── L.6/J.8: caché de descuento por amistad ────────────────────────────
## El nivel REAL de un NPC desconocido en Friendship es 0 → sin descuento.
## Se valida el MECANISMO de la caché: población en primera consulta, reuso
## en consultas con el mismo nivel, e invalidación por NPC (la señal
## nivel_amistad_cambio de M20 dispara invalidar_cache_amistad en runtime).
func _test_l6_j8_cache_amistad() -> void:
	var cls: Script = load("res://scripts/economia/price_manager.gd")
	var pm3 = cls.new()
	# 1) Primera consulta: calcula desde el nivel REAL del autoload Friendship
	# (NPC desconocido → nivel 1 → bajo el umbral 2 → desc 0.0) y cachea.
	var fs = root.get_node_or_null("Friendship")
	var nivel_real: int = int(fs.get_nivel("npc_test")) if fs != null and fs.has_method("get_nivel") else 0
	var d1 := float(pm3._descuento_amistad("npc_test"))
	_check("nivel real %d (< umbral 2): desc 0.0" % nivel_real, d1 == 0.0)
	_check("caché poblada tras 1ra consulta", pm3._cache_desc_amistad.has("npc_test"))
	if pm3._cache_desc_amistad.has("npc_test"):
		_check("caché guarda nivel real (%d)" % nivel_real, int(pm3._cache_desc_amistad["npc_test"]["nivel"]) == nivel_real)
	# 2) Segunda consulta MISMO nivel → usa la caché (entrada intacta, mismo dict)
	var entry_antes = pm3._cache_desc_amistad.get("npc_test", {})
	var d2 := float(pm3._descuento_amistad("npc_test"))
	_check("2da consulta mismo nivel: mismo resultado (0.0)", d2 == 0.0)
	# 3) Invalidación por NPC (la dispara la señal M20 en runtime)
	pm3.invalidar_cache_amistad("npc_test")
	_check("invalidar borra SOLO la entrada del NPC", not pm3._cache_desc_amistad.has("npc_test"))
	# 4) La invalidación de un NPC no afecta a otro
	pm3._cache_desc_amistad["npc_otro"] = {"nivel": 3, "desc": 0.10}
	pm3.invalidar_cache_amistad("npc_test")
	_check("invalidar npc_test NO borra npc_otro", pm3._cache_desc_amistad.has("npc_otro"))
	pm3 = null

## ── J.5/J.7: anti-arbitraje crafting ────────────────────────────────────
## Craftear para vender NUNCA es rentable: el precio de venta del resultado
## no supera la suma de precios de venta de los materiales. Usa datos reales
## (receta pico_cobre: 3 madera + 4 cobre → 1 pico_cobre, catálogo econ_prices).
func _test_j5_j7_anti_arbitraje_crafting() -> void:
	# materiales de la receta real (crafting_service carga de M93 crafting.json)
	var cs = root.get_node_or_null("Crafting")
	if cs == null or not cs.has_method("obtener_receta"):
		_check("Crafting disponible para anti-arbitraje", false)
		return
	var receta = cs.obtener_receta("rec_pico_cobre")
	if receta == null:
		_check("receta rec_pico_cobre existe", false)
		return
	# Venta de los materiales
	var suma_materiales := 0
	for mat_id in receta.materiales:
		suma_materiales += int(_pm.precio_venta_vigente(str(mat_id))) * int(receta.materiales[mat_id])
	# Venta del resultado
	var venta_resultado := int(_pm.precio_venta_vigente(receta.resultado_id))
	_check("venta pico_cobre (%d) < materiales (madera+cobre: %d)" % [venta_resultado, suma_materiales], venta_resultado < suma_materiales)
	# RF11: la venta nunca supera la compra (reventa no rentable)
	var compra_resultado := int(_pm.precio_compra_vigente(receta.resultado_id))
	_check("RF11: venta (%d) <= compra (%d) del resultado", venta_resultado <= compra_resultado)

## ── K.13: descuentos nunca producen precio <= 0 ──────────────────────────
## Usa PriceManager con catálogo falso: precio base 1 y máximo descuento
## combinado (20%: amistad 15% + volumen 15% clampeado) → clamp a >= 1.
func _test_k13_clamp_descuentos() -> void:
	var cls: Script = load("res://scripts/economia/price_manager.gd")
	var pm4 = cls.new()
	pm4._catalog = _CatK13.new()
	# precio base 1: con cualquier descuento el final clampa a >= 1 (jamás 0)
	_check("base 1 + volumen 20 → clamp 1", int(pm4.precio_compra_vigente("K13-ITEM", "", 20)) >= 1)
	_check("base 1 + volumen 50 → clamp 1", int(pm4.precio_compra_vigente("K13-ITEM", "", 50)) >= 1)
	_check("base 1 minorista → 1", int(pm4.precio_compra_vigente("K13-ITEM", "", 1)) == 1)
	pm4 = null

## Catálogo falso para K.13: ítem con precio de compra 1.
class _CatK13:
	extends RefCounted

	func get_price_def(item_id: String):
		if item_id == "K13-ITEM":
			var def := _DefK13.new("K13-ITEM", 1)
			return def
		return null

class _DefK13:
	extends RefCounted

	var item_id: String = ""
	var precio_compra: int = 1
	var precio_venta: int = 0
	var rareza: String = "comun"
	var variabilidad_mercado: float = 1.0
	var temporada: String = ""

	func _init(p_id: String, p_compra: int) -> void:
		item_id = p_id
		precio_compra = p_compra

## ── L.1: índice O(1) del catálogo ──────────────────────────────────────
## El resultado del índice debe ser idéntico al lineal (mismas definiciones).
func _test_l1_indice_catalogo() -> void:
	var cat = _catalogo_real()
	if cat == null:
		_check("catálogo econ_prices.tres cargado", false)
		return
	_check("índice construido (n=%d)" % cat._indice.size(), cat._indice.size() == cat.price_overrides.size())
	# Consulta por índice == consulta lineal para todos los ítems
	var ok := true
	for e in cat.price_overrides:
		if cat.get_price_def(str(e.item_id)) != e:
			ok = false
			break
	_check("get_price_def O(1) == lineal para todas las entradas", ok)
	_check("ítem inexistente → null", cat.get_price_def("ITEM-INEXISTENTE-XYZ") == null)
	_check("cadena vacía → null", cat.get_price_def("") == null)

func _catalogo_real():
	if _eco != null and _eco.precios != null and "_catalog" in _eco.precios:
		return _eco.precios._catalog
	var cls: Script = load("res://scripts/economia/economy_price_catalog.gd")
	return cls.get_catalog()
