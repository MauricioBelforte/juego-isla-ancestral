# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M16: Test de CraftingService (recetas, conocimiento, fabricación, experimentación).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/crafting/test_crafting.gd

extends SceneTree

var _fallos: int = 0
var _cs: Node = null
var _inv: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_cs = root.get_node_or_null("Crafting")
	_inv = root.get_node_or_null("Inventario")
	_check(_cs != null, "Crafting autoload presente")
	_check(_inv != null, "Inventario autoload presente")
	if _cs == null or _inv == null:
		print("=== TEST M16 CRAFTING: 1 fallo(s) ===")
		quit(1)
		return
	_test_recetas_cargadas()
	_test_conocimiento_inicial()
	_test_fabricar_ok()
	_test_fabricar_sin_materiales()
	_test_fabricar_desconocida()
	_test_experimental()
	_test_coste_ao()
	_test_persistencia()
	print("=== TEST M16 CRAFTING: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_recetas_cargadas() -> void:
	_check(_cs.obtener_receta("rec_pico_cobre") != null, "rec_pico_cobre cargada")
	_check(_cs.obtener_receta("rec_talisman_ancestral") != null, "rec_talisman_ancestral cargada")
	_check(_cs.obtener_receta("no_existe") == null, "receta inexistente = null")
	var mesa: Array = _cs.recetas_por_estacion(CraftingRecipe.Estacion.MESA_TRABAJO)
	_check(mesa.size() >= 3, "mesa_trabajo con 3+ recetas conocidas: %d" % mesa.size())

func _test_conocimiento_inicial() -> void:
	# Las recetas de origen "inicial" se conocen de base
	_check(_cs.es_conocida("rec_pico_cobre"), "rec inicial conocida")
	_check(not _cs.es_conocida("rec_tela_lino"), "rec de compra NO conocida al inicio")
	_check(not _cs.es_conocida("rec_ensalada_bayas"), "rec de experimentación NO conocida")

func _test_fabricar_ok() -> void:
	# Dar materiales para 1 pico de cobre (3 madera + 4 cobre)
	_inv.agregar_items({"madera_roble": 10, "mineral_cobre": 10})
	_check(_cs.puede_craft("rec_pico_cobre"), "puede fabricar pico con materiales")
	var max_n: int = _cs.max_craftable("rec_pico_cobre")
	_check(max_n >= 2, "max_craftable >= 2 (10 madera/3, 10 cobre/4): %d" % max_n)
	var ok: bool = _cs.craft("rec_pico_cobre", 1)
	_check(ok, "craft 1x exitoso")
	_check(_inv.count_item("pico_cobre") == 1, "resultado en inventario")
	_check(_inv.count_item("madera_roble") == 7, "madera consumida (10-3)")
	_check(_inv.count_item("mineral_cobre") == 6, "cobre consumido (10-4)")
	# Crear múltiple (RF8): quedan 7 madera y 6 cobre -> máx 2 más... (7/3=2, 6/4=1) -> 1
	var max2: int = _cs.max_craftable("rec_pico_cobre")
	_check(max2 == 1, "max_craftable recalculado = 1 (6/4): %d" % max2)

func _test_fabricar_sin_materiales() -> void:
	# RF11: sin materiales suficientes NO consume nada
	var antes_madera: int = _inv.count_item("madera_roble")
	var fallo: bool = _cs.craft("rec_talisman_ancestral", 1)
	_check(not fallo, "craft sin fragmento falla")
	_check(_inv.count_item("madera_roble") == antes_madera, "materiales intactos tras fallo (RF11)")

func _test_fabricar_desconocida() -> void:
	# RF4: no se puede fabricar una receta no conocida
	_inv.agregar_items({"fibra_algodon": 10})
	var fallo: bool = _cs.craft("rec_tela_lino", 1)
	_check(not fallo, "craft de receta desconocida falla")
	_check(_inv.count_item("fibra_algodon") == 10, "fibra intacta (no consumida)")

func _test_experimental() -> void:
	# Flujo 2.2: experimentar con la combinación correcta descubre la receta sin consumir
	var antes_bayas: int = _inv.count_item("baya_roja")
	var receta: CraftingRecipe = _cs.experimentar(CraftingRecipe.Estacion.FOGATA, {"baya_roja": 1})
	# La combinación canónica de la ensalada es 3 bayas; con 1 baya no coincide
	_check(receta == null, "combinación incorrecta no descubre")
	_check(_inv.count_item("baya_roja") == antes_bayas, "experimentación no consume (§1.3.2)")
	# Combinación correcta (3 bayas)
	receta = _cs.experimentar(CraftingRecipe.Estacion.FOGATA, {"baya_roja": 3})
	_check(receta != null and receta.id == "rec_ensalada_bayas", "combinación correcta descubre receta")
	_check(_cs.es_conocida("rec_ensalada_bayas"), "receta descubierta conocida")
	_check(_inv.count_item("baya_roja") == antes_bayas, "experimentación exitosa tampoco consume")

func _test_coste_ao() -> void:
	# Ruta M38: receta con coste_ao consume monedas (EconomyManager)
	var eco = root.get_node_or_null("EconomyManager")
	_check(eco != null, "EconomyManager autoload presente")
	if eco == null:
		return
	# Materiales del talismán: 1 fragmento + 5 piedra (coste_ao = 10)
	_inv.agregar_items({"fragmento_ancestral": 1, "piedra_caliza": 10})
	# RF4: el talismán es de experimentación — descubrirlo primero (sin consumo)
	var descubierta: CraftingRecipe = _cs.experimentar(CraftingRecipe.Estacion.MESA_TRABAJO,
		{"fragmento_ancestral": 1, "piedra_caliza": 5})
	_check(descubierta != null and descubierta.id == "rec_talisman_ancestral", "talismán descubierto por experimentación")
	var saldo_antes: int = int(eco.saldo)
	var ok: bool = _cs.craft("rec_talisman_ancestral", 1)
	_check(ok, "craft talismán con AO exitoso")
	_check(int(eco.saldo) == saldo_antes - 10, "AO consumido (saldo %d -> %d)" % [saldo_antes, int(eco.saldo)])
	_check(_inv.count_item("talisman_ancestral") == 1, "talismán en inventario")
	_check(_inv.count_item("fragmento_ancestral") == 0, "fragmento consumido")
	_check(_inv.count_item("piedra_caliza") == 5, "piedra consumida (10-5)")

func _test_persistencia() -> void:
	var data: Dictionary = _cs.get_save_data()
	_check(data.has("recetas_conocidas"), "save data tiene recetas_conocidas")
	_check("rec_ensalada_bayas" in data.get("recetas_conocidas", []), "descubierta persiste en save")
	# Restaurar en una instancia nueva (simular carga)
	_cs._conocidas.clear()
	_cs.restore_save_data(data)
	_check(_cs.es_conocida("rec_ensalada_bayas"), "restore recupera conocimiento")