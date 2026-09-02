# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M16/M39: Test RF14 — la tienda general vende pergaminos de receta y el
# flujo completo funciona: comprar → inventario → usar_pergamino → receta aprendida.
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/crafting/test_pergaminos_tienda.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var sm := root.get_node_or_null("ShopManager")
	var inv := root.get_node_or_null("Inventario")
	var craft := root.get_node_or_null("Crafting")
	var eco := root.get_node_or_null("EconomyManager")
	_check(sm != null and inv != null and craft != null, "ShopManager + Inventario + Crafting presentes")
	if sm == null or inv == null or craft == null:
		print("=== TEST M16 RF14: 1+ fallo(s) ===")
		quit(1)
		return
	# La tienda general registra el pergamino en su stock
	var shop = sm.obtener_tienda("tienda_general") if sm.has_method("obtener_tienda") else null
	_check(shop != null, "tienda_general registrada")
	if shop != null:
		var tiene_pergamino := false
		var def = shop.definicion
		for entry in def.catalogo_venta:
			var eid: String = str(entry.item_id) if "item_id" in entry else ""
			if eid.contains("pergamino"):
				tiene_pergamino = true
		_check(tiene_pergamino, "tienda_general vende un pergamino (RF14)")
	# Flujo: dar AO → comprar (simulado: agregar item) → usar pergamino
	eco.depositar_monedas(1000)
	inv.agregar_items({"pergamino_rec_tela_lino": 1})
	_check(int(inv.count_item("pergamino_rec_tela_lino")) == 1, "pergamino en inventario")
	_check(not craft.es_conocida("rec_tela_lino"), "rec_tela_lino NO conocida antes")
	var res: Dictionary = craft.usar_pergamino("pergamino_rec_tela_lino")
	_check(bool(res.get("aprendido", false)), "usar_pergamino aprende la receta")
	_check(craft.es_conocida("rec_tela_lino"), "rec_tela_lino conocida después")
	# Contrato del núcleo: usar_pergamino NO descuenta el inventario — eso lo
	# hace M14 al recibir el evento use_item (el pergamino queda hasta que el
	# sistema de uso lo retire).
	_check(int(inv.count_item("pergamino_rec_tela_lino")) == 1,
		"contrato núcleo: usar_pergamino no descuenta (M14 lo hace via use_item)")
	# Idempotencia cozy: un segundo pergamino de receta conocida NO se consume
	inv.agregar_items({"pergamino_rec_tela_lino": 1})
	res = craft.usar_pergamino("pergamino_rec_tela_lino")
	_check(not bool(res.get("aprendido", true)), "re-uso de receta conocida: aprendido=false (honesto)")
	_check(int(inv.count_item("pergamino_rec_tela_lino")) == 2, "pergamino NO consumido si ya conocida")
	# RF17 (iter. 5): flujo vía item_usado de M14 — señal → aprende → consume.
	# Reset del estado de recetas conocidas (el flujo anterior ya la aprendió):
	# el save de M16 usa clave "recetas_conocidas" (ver get_save_data del núcleo).
	if craft.has_method("restore_save_data"):
		craft.restore_save_data({"recetas_conocidas": []})
	inv.agregar_items({"pergamino_rec_tela_lino": 1})
	var antes: int = int(inv.count_item("pergamino_rec_tela_lino"))
	_check(not craft.es_conocida("rec_tela_lino"), "RF17: estado reseteado")
	inv.item_usado.emit("pergamino_rec_tela_lino", "rf17")
	_check(craft.es_conocida("rec_tela_lino"), "RF17: receta conocida via item_usado")
	_check(int(inv.count_item("pergamino_rec_tela_lino")) == antes - 1, "RF17: pergamino consumido via item_usado")
	print("=== TEST M16 RF14: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
