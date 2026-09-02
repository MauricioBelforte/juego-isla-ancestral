extends SceneTree

## Test headless M38 (iter. 2): RF10 tabla del día + RF15 historial de transacciones
## + persistencia del historial (RF13 parcial).
## Uso: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_tabla_dia_transacciones.gd

var _fallos := 0
var _checks := 0

func _initialize() -> void:
	print("=== TEST TABLA DEL DIA + TRANSACCIONES (M38 iter. 2) ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var eco = root.get_node_or_null("EconomyManager")
	var db = root.get_node_or_null("ItemDatabase")
	_check("autoloads presentes (eco, db)", eco != null and db != null)
	if eco == null or db == null:
		print("FALTAN AUTOLOADS NECESARIOS")
		quit(1)
		return

	# Ítem de prueba con precio base conocido (compra 200 → venta tope 120).
	_asegurar_item("OBJ-PLA-001", 200, 100)

	# ── RF10: tabla del día con ids explícitos ──
	var ids: Array = ["OBJ-PLA-001", "INEXISTENTE-XYZ"]
	var tabla: Dictionary = eco.tabla_del_dia(ids)
	_check("tabla excluye ítem sin precio definido", not tabla.has("INEXISTENTE-XYZ"))
	_check("tabla incluye ítem con precio", tabla.has("OBJ-PLA-001"))
	if tabla.has("OBJ-PLA-001"):
		var f: Dictionary = tabla["OBJ-PLA-001"]
		_check("compra == 200 (base minorista)", int(f["compra"]) == 200)
		_check("venta == 120 (tope 60% sin oferta)", int(f["venta"]) == 120)
		_check("limite por banda definido (>0)", int(f["limite"]) > 0)
		_check("vendidas_hoy == 0 al inicio", int(f["vendidas_hoy"]) == 0)
		_check("rebajado == false al inicio", bool(f["rebajado"]) == false)

	# Determinismo: dos llamadas consecutivas devuelven datos idénticos.
	var tabla2: Dictionary = eco.tabla_del_dia(ids)
	_check("tabla determinista (2 llamadas iguales)", tabla2.has("OBJ-PLA-001") and int(tabla2["OBJ-PLA-001"]["venta"]) == int(tabla["OBJ-PLA-001"]["venta"]))

	# ── Ajuste por oferta: registrar 1 venta → venta baja hasta -10%, con piso ──
	eco.registrar_venta_para_mercado("OBJ-PLA-001", 1, 1)
	var f2: Dictionary = eco.tabla_del_dia(ids)["OBJ-PLA-001"]
	_check("venta con oferta <= 120 y >= 108 (piso -10%)", int(f2["venta"]) <= 120 and int(f2["venta"]) >= 108)

	# ── Precio rebajado por superar límite diario ──
	var limite: int = int(f2["limite"])
	eco.precios._ventas_hoy["OBJ-PLA-001"] = limite + 1  # forzar excedente
	eco.precios._dia_actual = 1
	var f3: Dictionary = eco.tabla_del_dia(ids)["OBJ-PLA-001"]
	_check("rebajado == true al superar limite", bool(f3["rebajado"]) == true)

# ---PARTE2---
