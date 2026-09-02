extends SceneTree

## Test headless M38 (iter. 2): RF10 tabla del día + RF15 historial de transacciones
## + persistencia del historial (RF13 parcial).
## Uso: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_tabla_dia_transacciones.gd

var _fallos := 0
var _checks := 0
var _db = null

func _initialize() -> void:
	print("=== TEST TABLA DEL DIA + TRANSACCIONES (M38 iter. 2) ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var eco = root.get_node_or_null("EconomyManager")
	_db = root.get_node_or_null("ItemDatabase")
	_check("autoloads presentes (eco, db)", eco != null and _db != null)
	if eco == null or _db == null:
		print("FALTAN AUTOLOADS NECESARIOS")
		quit(1)
		return

	# Ítem de prueba: "madera_roble" tiene override en econ_prices.tres (compra=10).
	# Precio de venta esperado = tope 60% de la compra = 6 (sin oferta).

	# ── RF10: tabla del día con ids explícitos ──
	var ids: Array = ["madera_roble", "INEXISTENTE-XYZ"]
	var tabla: Dictionary = eco.tabla_del_dia(ids)
	_check("tabla excluye ítem sin precio definido", not tabla.has("INEXISTENTE-XYZ"))
	_check("tabla incluye ítem con precio", tabla.has("madera_roble"))
	if tabla.has("madera_roble"):
		var f: Dictionary = tabla["madera_roble"]
		_check("compra == 10 (override del catálogo)", int(f["compra"]) == 10)
		_check("venta == 6 (tope 60% sin oferta)", int(f["venta"]) == 6)
		_check("limite por banda definido (>0)", int(f["limite"]) > 0)
		_check("vendidas_hoy == 0 al inicio", int(f["vendidas_hoy"]) == 0)
		_check("rebajado == false al inicio", bool(f["rebajado"]) == false)

	# Determinismo: dos llamadas consecutivas devuelven datos idénticos.
	var tabla2: Dictionary = eco.tabla_del_dia(ids)
	_check("tabla determinista (2 llamadas iguales)", tabla2.has("madera_roble") and int(tabla2["madera_roble"]["venta"]) == int(tabla["madera_roble"]["venta"]))

	# ── Ajuste por oferta: registrar 1 venta → venta baja hasta -10%, con piso ──
	eco.registrar_venta_para_mercado("madera_roble", 1, 1)
	var f2: Dictionary = eco.tabla_del_dia(ids)["madera_roble"]
	_check("venta con oferta <= 6 y >= 5 (piso -10%)", int(f2["venta"]) <= 6 and int(f2["venta"]) >= 5)

	# ── Precio rebajado por superar límite diario ──
	var limite: int = int(f2["limite"])
	eco.precios._ventas_hoy["madera_roble"] = limite + 1  # forzar excedente
	eco.precios._dia_actual = 1
	var f3: Dictionary = eco.tabla_del_dia(ids)["madera_roble"]
	_check("rebajado == true al superar limite", bool(f3["rebajado"]) == true)

	# ── RF15: historial de transacciones ──
	eco._historial.clear()
	var recibidas: Array = []
	eco.transaccion_registrada.connect(func(tx): recibidas.append(tx))
	_check("deposito 50 OK", eco.depositar_monedas(50))
	_check("retiro 30 OK", eco.retirar_monedas(30))
	_check("retiro imposible (999999) falla", not eco.retirar_monedas(999999))
	_check("deposito negativo falla", not eco.depositar_monedas(-1))
	var hist: Array = eco.obtener_historial()
	_check("historial registra SOLO transacciones exitosas (2)", hist.size() == 2)
	_check("señal emite lo mismo que se guarda", recibidas.size() == 2)
	if hist.size() == 2:
		_check("tx0 = deposito", str(hist[0]["tipo"]) == "deposito")
		_check("tx1 = retiro", str(hist[1]["tipo"]) == "retiro")
		_check("tx con campo dia (M29) y ts", hist[0].has("dia") and hist[0].has("ts"))
	# obtener_historial devuelve copia, no referencia.
	var copia: Array = eco.obtener_historial(1)
	_check("obtener_historial(1) devuelve la última", copia.size() == 1)
	eco.obtener_historial()[0]["tipo"] = "MANIPULADO"
	_check("historial devuelto es copia (sin manipulación)", str(eco.obtener_historial()[0]["tipo"]) != "MANIPULADO")

	# ── Anillo: cap en HISTORIAL_MAX ──
	eco._historial.clear()
	for i in range(eco.HISTORIAL_MAX + 30):
		eco.depositar_monedas(1)
	_check("anillo acotado a HISTORIAL_MAX", eco.obtener_historial().size() == eco.HISTORIAL_MAX)

	# ── RF13 parcial: persistencia del historial ──
	var datos: Dictionary = eco.get_save_data()
	_check("get_save_data incluye historial", datos.has("historial") and typeof(datos["historial"]) == TYPE_ARRAY)
	_check("get_save_data incluye saldo y precios", datos.has("saldo") and datos.has("precios"))
	eco.restore_save_data(datos)
	var hist2: Array = eco.obtener_historial()
	_check("historial restaurado exacto", hist2.size() == datos["historial"].size())
	if hist2.size() > 0:
		_check("entrada restaurada íntegra", str(hist2[hist2.size() - 1]["tipo"]) == "deposito" and int(hist2[hist2.size() - 1]["monto"]) == 1)
	# Restauración defensiva: historial corrupto no rompe.
	eco.restore_save_data({"saldo": 77, "historial": ["basura", {"tipo": "retiro", "monto": 5}]})
	_check("restore defensivo descarta no-diccionarios", eco.obtener_historial().size() == 1)
	_check("restore aplica saldo", int(eco.saldo) == 77)

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS")
		quit(1)
	else:
		print("TABLA DEL DIA + TRANSACCIONES OK")
		quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
