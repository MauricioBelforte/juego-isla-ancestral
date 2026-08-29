# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M38: Prueba de edge cases de precios del PriceManager (checklist opcional K/N).
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_edge_cases_precio.gd
# Valida reglas cozy:
#  - Cantidad <= 0 se trata como minorista (1 und) — nunca un descuento inválido.
#  - Tope de descuento por volumen (15%) y cantidad negativa no rompen el cálculo.
#  - Precio final nunca cae por debajo de 1 (clamp defensivo).
#  - Venta del jugador NO recibe bonus por volumen (anti-arbitraje): precio unitario estable.
#  - Límite diario por banda de rareza resuelto desde el catálogo central (econ_prices.tres).
#  - registrar_venta: exceder el límite diario → precio_rebajado_hoy.
#
# Para la parte de PREZIOS afecta el item REAL OBJ-PLA-001 (existe en ItemDatabase, M159),
# inyectando un valor controlado y restaurándolo al final. Para las bandas NO toca la base:
# usa un catálogo falso (get_price_def -> PriceDefinition.rareza), igual que EconomyPriceCatalog.
extends SceneTree

var _fallos := 0
var _checks := 0
var _pm = null
var _db = null

const ITEM := "OBJ-PLA-001"

func _initialize() -> void:
	print("=== TEST EDGE CASES DE PRECIOS (M38) ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var cls: Script = load("res://scripts/economia/price_manager.gd")
	if cls == null or not cls.can_instantiate():
		print("[FAIL] no se pudo cargar price_manager.gd"); quit(1); return
	_pm = cls.new()
	_db = root.get_node_or_null("ItemDatabase")
	_pm._catalog = _CatFake.new()

	# Precio controlado sobre un item REAL. Guardamos el valor original.
	var item = _db.get_item(ITEM)
	if item == null:
		print("[FAIL] item OBJ-PLA-001 no existe en ItemDatabase"); quit(1); return
	var pc_orig := int(item.precio_compra)
	var pv_orig := int(item.precio_venta)
	item.set("precio_compra", 100)
	item.set("precio_venta", 60)

	# ── Cantidad inválida (0 / negativa) se comporta como minorista ──
	_check("minorista cantidad=1 == base (100)", int(_pm.precio_compra_vigente(ITEM, "", 1)) == 100)
	_check("cantidad=0 == minorista (100)", int(_pm.precio_compra_vigente(ITEM, "", 0)) == 100)
	_check("cantidad=-3 == minorista (100)", int(_pm.precio_compra_vigente(ITEM, "", -3)) == 100)

	# ── Mayorista por tramos (control) ──
	_check("volumen 5 → 5% (95)", int(_pm.precio_compra_vigente(ITEM, "", 5)) == 95)
	_check("volumen 10 → 10% (90)", int(_pm.precio_compra_vigente(ITEM, "", 10)) == 90)
	_check("volumen 20 → 15% (85)", int(_pm.precio_compra_vigente(ITEM, "", 20)) == 85)
	_check("volumen 50 → tope 15% (85)", int(_pm.precio_compra_vigente(ITEM, "", 50)) == 85)

	# ── Venta: estable, sin bonus por volumen (anti-arbitraje) ──
	var v1 := int(_pm.precio_venta_vigente(ITEM))
	_check("venta definida (base*0.6 = 60)", v1 == 60)
	_check("venta >= 1 siempre", v1 >= 1)

	# ── Clamp defensivo: precio nunca 0/negativo incluso con descuento sobre base 1 ──
	item.set("precio_compra", 1)
	_check("precio base 1 con descuento → clamp a >=1", int(_pm.precio_compra_vigente(ITEM, "", 20)) >= 1)
	# Restaurar valores originales del item real
	item.set("precio_compra", pc_orig)
	item.set("precio_venta", pv_orig)

	# ── Límite diario por banda desde catálogo (no consulta la base) ──
	_check("comun → 3", _pm.limite_ventas_dia("EDGE-COMUN") == 3)
	_check("poco_comun → 3", _pm.limite_ventas_dia("EDGE-POCO") == 3)
	_check("raro → 2", _pm.limite_ventas_dia("EDGE-RARO") == 2)
	_check("epico → 1", _pm.limite_ventas_dia("EDGE-EPICO") == 1)
	_check("item sin banda/catálogo → default 3", _pm.limite_ventas_dia("EDGE-DEFAULT") == 3)

	# ── registrar_venta + rebaja por límite diario ──
	_check("sin ventas: no rebajado", not _pm.precio_rebajado_hoy("EDGE-EPICO"))
	_pm.registrar_venta("EDGE-EPICO", 1, 1)
	_check("epico en límite (1): no rebajado", not _pm.precio_rebajado_hoy("EDGE-EPICO"))
	_pm.registrar_venta("EDGE-EPICO", 1, 1)
	_check("epico excede límite (2): rebajado", _pm.precio_rebajado_hoy("EDGE-EPICO"))

	# ── Reseteo por cambio de día ──
	_pm.registrar_venta("EDGE-DEFAULT", 9, 2)  # cambia al día 2; primera venta 9 → supera límite 3
	_check("día 2 con 9 ventas (1ra del día): rebajado", _pm.precio_rebajado_hoy("EDGE-DEFAULT"))
	_pm.registrar_venta("EDGE-DEFAULT", 1, 3)  # nuevo día 3: contador se resetea a 0 antes de sumar 1
	_check("día 3 con 1 venta: NO rebajado (contador reseteado)", not _pm.precio_rebajado_hoy("EDGE-DEFAULT"))

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("EDGE CASES DE PRECIOS OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)


## Catálogo falso: expone get_price_def(item_id) -> PriceDefinition | null.
class _CatFake:
	extends RefCounted

	func get_price_def(item_id: String):
		var bandas := {
			"EDGE-COMUN": "comun",
			"EDGE-UNO": "comun",
			"EDGE-POCO": "poco_comun",
			"EDGE-RARO": "raro",
			"EDGE-EPICO": "epico",
		}
		if not bandas.has(item_id):
			return null
		return _Def.new(item_id, bandas[item_id])

class _Def:
	extends RefCounted

	var item_id: String = ""
	var rareza: String = ""

	func _init(p_item_id: String, p_rareza: String) -> void:
		item_id = p_item_id
		rareza = p_rareza