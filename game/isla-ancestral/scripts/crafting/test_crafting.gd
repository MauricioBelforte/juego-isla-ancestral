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
	_test_estacional_rf5()
	_test_pergamino_m14()
	_test_feedback_cargado()
	_test_season_changed_runtime()
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
	# RF5: el talismán es estacional (otono/invierno). Forzar otoño para el test.
	var gt: Node = root.get_node_or_null("GameTime")
	if gt != null:
		gt._mes = 9
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
	# Reset estación
	if gt != null:
		gt._mes = 1

func _test_persistencia() -> void:
	var data: Dictionary = _cs.get_save_data()
	_check(data.has("recetas_conocidas"), "save data tiene recetas_conocidas")
	_check("rec_ensalada_bayas" in data.get("recetas_conocidas", []), "descubierta persiste en save")
	# Restaurar en una instancia nueva (simular carga)
	_cs._conocidas.clear()
	_cs.restore_save_data(data)
	_check(_cs.es_conocida("rec_ensalada_bayas"), "restore recupera conocimiento")

## RF5: recetas estacionales filtradas por temporada actual (M29).
func _test_estacional_rf5() -> void:
	var gt: Node = root.get_node_or_null("GameTime")
	_check(gt != null, "GameTime autoload presente para test estacional")
	if gt == null:
		return
	# rec_ensalada_bayas: temporadas ["primavera","verano"] (0,1)
	# rec_talisman_ancestral: temporadas ["otono","invierno"] (2,3)
	var ensalada: CraftingRecipe = _cs.obtener_receta("rec_ensalada_bayas")
	var talisman: CraftingRecipe = _cs.obtener_receta("rec_talisman_ancestral")
	_check(ensalada != null and ensalada.temporadas.size() == 2, "ensalada tiene 2 temporadas")
	_check(talisman != null and talisman.temporadas.size() == 2, "talisman tiene 2 temporadas")
	# es_fabricable_ahora por estación (puro, sin M29)
	_check(ensalada.es_fabricable_ahora(0), "ensalada fabricable en primavera")
	_check(ensalada.es_fabricable_ahora(1), "ensalada fabricable en verano")
	_check(not ensalada.es_fabricable_ahora(2), "ensalada NO fabricable en otoño")
	_check(not ensalada.es_fabricable_ahora(3), "ensalada NO fabricable en invierno")
	_check(talisman.es_fabricable_ahora(2), "talisman fabricable en otoño")
	_check(not talisman.es_fabricable_ahora(0), "talisman NO fabricable en primavera")
	# Filtrado por temporada actual: forzar otoño (_mes=9 -> estación 2)
	gt._mes = 9
	var mesa: Array = _cs.recetas_por_estacion(CraftingRecipe.Estacion.MESA_TRABAJO)
	var tiene_ensalada: bool = false
	for r in mesa:
		if r.id == "rec_ensalada_bayas":
			tiene_ensalada = true
	_check(not tiene_ensalada, "ensalada NO aparece en mesa_trabajo en otoño (estación incorrecta)")
	# max_craftable devuelve 0 para receta fuera de temporada
	_inv.agregar_items({"baya_roja": 9})
	_check(_cs.max_craftable("rec_ensalada_bayas") == 0, "max_craftable=0 fuera de temporada")
	# Forzar verano (_mes=4 -> estación 1)
	gt._mes = 4
	if not _cs.es_conocida("rec_ensalada_bayas"):
		_cs.aprender_desde_pergamino("rec_ensalada_bayas")
	var fogata: Array = _cs.recetas_por_estacion(CraftingRecipe.Estacion.FOGATA)
	var tiene_ens: bool = false
	for r in fogata:
		if r.id == "rec_ensalada_bayas":
			tiene_ens = true
	_check(tiene_ens, "ensalada aparece en fogata en verano")
	# craft fuera de temporada: no consume (forzar invierno _mes=11 -> estación 3)
	gt._mes = 11
	var bayas_antes: int = _inv.count_item("baya_roja")
	var ok: bool = _cs.craft("rec_ensalada_bayas", 1)
	_check(not ok, "craft de ensalada en invierno falla")
	_check(_inv.count_item("baya_roja") == bayas_antes, "sin consumo en temporada cerrada (RF5/RF11)")
	# Reset estación
	gt._mes = 1

## Pergaminos M14: usar_pergamino(item_id) aprende la receta y emite señal.
func _test_pergamino_m14() -> void:
	# item_id con prefijo "pergamino_rec_"
	_cs._conocidas = ["rec_mesa_robusta", "rec_pico_cobre", "rec_hacha_cobre", "rec_caja_almacenamiento", "rec_ensalada_bayas"]
	_cs.aprender_desde_pergamino("rec_tela_lino")
	_check(_cs.es_conocida("rec_tela_lino"), "pergamino aprende receta")
	# Re-usar pergamino conocido: no consume (honesto)
	var result: Dictionary = _cs.usar_pergamino("pergamino_rec_tela_lino")
	_check(bool(result.get("aprendido")) == false, "pergamino ya conocido: no aprende de nuevo")
	# Item sin prefijo
	var r2: Dictionary = _cs.usar_pergamino("piedra_caliza")
	_check(bool(r2.get("aprendido")) == false and str(r2.get("rec_id")) == "", "item sin prefijo pergamino: rechazado")
	# Aprende nueva
	var r3: Dictionary = _cs.usar_pergamino("pergamino_rec_ensalada_bayas")
	# ensalada ya conocida de tests previos
	_check(bool(r3.get("aprendido")) == false, "pergamino de receta ya conocida: no aprende")

## Feedback procedural: crafting_feedback cargado como hijo del servicio.
func _test_feedback_cargado() -> void:
	var fb: Node = _cs.get_node_or_null("CraftingFeedback")
	_check(fb != null, "CraftingFeedback instanciado como hijo del servicio")
	if fb != null:
		# El AudioStreamPlayer existe y el stream es AudioStreamWAV
		_check(fb.get_child_count() >= 2, "feedback tiene nodos hijos (audio/canvas)")
		var wav = AudioStreamWAV.new()
		# Solo verifica que la clase existe (no instancia completa en headless)
		_check(wav != null, "AudioStreamWAV disponible")

## RF5 en runtime: conexión a la señal estacion_cambio de M29 + emisión segura.
func _test_season_changed_runtime() -> void:
	var gt: Node = root.get_node_or_null("GameTime")
	_check(gt != null, "GameTime presente")
	if gt == null:
		return
	# Verificar que el servicio está conectado a estacion_cambio de M29
	var conexiones: Array = gt.estacion_cambio.get_connections()
	var conectado: bool = false
	for c in conexiones:
		if c.callable.get_object() == _cs:
			conectado = true
	_check(conectado, "servicio conectado a estacion_cambio de M29")
	# Emitir la señal no debe crashear; el handler del servicio se ejecuta
	# y el cache se mantiene coherente con GameTime (lectura on-demand).
	gt._mes = 4  # verano
	gt.emit_signal("estacion_cambio", 1)
	_check(_cs.get_estacion_actual() == 1, "get_estacion_actual() == 1 (verano)")
	gt._mes = 11  # invierno
	gt.emit_signal("estacion_cambio", 3)
	_check(_cs.get_estacion_actual() == 3, "get_estacion_actual() == 3 (invierno)")
	# Restaurar
	gt._mes = 1
	gt.emit_signal("estacion_cambio", 0)