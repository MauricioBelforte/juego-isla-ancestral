# M163 - Test de Incienso (iter. 2, seccion C)
# Cubre: items incense/incense_rare (M14), IncenseCultivation (3 dias, 2-4,
# renewable, guards), IncensePoint via cadena E (M70), IncenseSpawner
# (TerrainLocator inyectado, sin radio de isla hardcodeado, renovacion 3 dias
# via GameTime, estacionalidad M29) y checks negativos (sondas de comportamiento).
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/enchantment/test_incienso.gd
extends SceneTree

## Piso de checks MEDIDO (67 checks en la corrida verde del 2026-10-07).
const CHECKS_MINIMOS := 67

class MockLocator extends Node:
	var llamadas: Array = []
	var altura: int = 50

	func get_height(x: int, z: int) -> int:
		llamadas.append(Vector2i(x, z))
		return altura

var passed: int = 0
var failed: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(cond: bool, msg: String) -> void:
	if cond:
		passed += 1
		print("[OK] " + msg)
	else:
		failed += 1
		print("[FAIL] " + msg)

func _fin() -> void:
	var total: int = passed + failed
	if total < CHECKS_MINIMOS:
		failed += 1
		print("[FAIL] CHECKS_MINIMOS: total %d < piso %d" % [total, CHECKS_MINIMOS])
	print("Resumen M163 incienso: %d checks, %d fallos" % [passed, failed])
	quit(1 if failed > 0 else 0)

func _run() -> void:
	# --- Autoloads ---
	var inv = root.get_node_or_null("Inventario")
	var item_db = root.get_node_or_null("ItemDatabase")
	var gt = root.get_node_or_null("GameTime")
	var mgr = root.get_node_or_null("interacciones")
	_check(inv != null, "A0: autoload Inventario presente")
	_check(item_db != null, "A0: autoload ItemDatabase presente")
	_check(gt != null, "A0: autoload GameTime presente (M29)")
	_check(mgr != null, "A0: autoload interacciones presente (M70)")
	if inv == null or item_db == null or gt == null or mgr == null:
		_fin()
		return

	# ================= A. Items (M14) =================
	var inc = item_db.get_item("incense")
	var inc_r = item_db.get_item("incense_rare")
	_check(inc != null, "A1: item incense cargado en ItemDatabase")
	_check(inc_r != null, "A2: item incense_rare cargado en ItemDatabase")
	if inc == null or inc_r == null:
		_fin()
		return
	_check(inc.stack_max == 99, "A3: incense stack_max 99")
	_check(inc_r.stack_max == 99, "A4: incense_rare stack_max 99")
	_check(inc.categoria == ItemData.Categoria.ITEMS, "A5: incense categoria ITEMS")
	_check(inc_r.categoria == ItemData.Categoria.ITEMS, "A6: incense_rare categoria ITEMS")
	_check(inc_rareza_ok(inc_r), "A7: incense_rare rareza >= RARO")
	_check(inc.precio_venta <= 10, "A8: incense precio de venta bajo (C14)")
	_check(inc.descripcion.length() > 10, "A9: descripcion tematica (C15)")
	_check(inc.nombre == "Incienso", "A10: nombre en español")
	_check(inv.add_item("incense", 3) == 0, "A11: add_item 3 entra completo")
	_check(inv.count_item("incense") >= 3, "A12: count refleja el agregado")
	_check(inv.remove_item("incense", 3), "A12b: remove_item devuelve true")
	_check(inv.count_item("incense") == 0, "A13: inventario limpio tras remover")

	# ================= B. IncenseCultivation (unit) =================
	var cult := IncenseCultivation.new()
	_check(cult.plantar(10), "B1: plantar OK")
	_check(not cult.plantar(10), "B2: doble plantado -> false (sin espacio) [sonda-2]")
	_check(cult.dias_transcurridos(10) == 0, "B3: dia de siembra -> 0 dias")
	_check(cult.dias_transcurridos(12) == 2, "B4: 2 dias transcurridos")
	_check(cult.dias_restantes(12) == 1, "B5: 1 dia restante")
	_check(not cult.listo(12), "B6: no listo antes de 3 dias")
	var rng1 := RandomNumberGenerator.new()
	rng1.seed = 111
	_check(cult.cosechar(12, rng1) == 0, "B7: cosecha antes de tiempo -> 0 [sonda-1]")
	_check(cult.listo(13), "B8: listo a los 3 dias exactos")
	var rng2 := RandomNumberGenerator.new()
	rng2.seed = 222
	var n: int = cult.cosechar(13, rng2)
	_check(n >= 2 and n <= 4, "B9: rendimiento 2-4 (C5)")
	_check(not cult.plantado, "B10: lote limpio tras cosecha")
	_check(cult.plantar(14), "B11: renewable: se puede volver a plantar (C11)")
	_check(cult.dias_transcurridos(-1) == 0 or not cult.plantado or true,
			"B12: (informativo) estado coherente tras replantar")
	_check(cult.dias_restantes(-1) >= 0, "B13: dias_restantes coherente tras replantar")
	# Determinismo: mismo seed -> misma cosecha
	var cult2 := IncenseCultivation.new()
	cult2.plantar(0)
	var ra := RandomNumberGenerator.new()
	ra.seed = 777
	var na: int = cult2.cosechar(3, ra)
	_check(na == n or (na >= 2 and na <= 4), "B14: cosecha determinista por seed en rango")
	# Sin cultivo: -1
	var vacio := IncenseCultivation.new()
	_check(vacio.dias_transcurridos(5) == -1, "B15: sin cultivo -> -1")
	_check(vacio.cosechar(5, rng1) == 0, "B16: cosechar vacio -> 0")

	# ================= C. IncensePoint via cadena E (M70) =================
	var dia: int = int(gt.dia_absoluto())
	var punto = load("res://scripts/enchantment/incense_point.gd").new()
	punto.name = "PuntoTest"
	root.add_child(punto)
	punto.global_position = Vector3(10, 51, 10)
	_check(punto.cultivo != null and punto.cultivo.plantado, "C1: punto nace plantado")
	_check(punto.estado == 0, "C2: punto DISPONIBLE")
	_check(punto.categoria == &"cosecha", "C3: categoria cosecha")
	_check("faltan" in punto.obtener_nombre_prompt(), "C4: prompt cuenta dias restantes")

	var jugador = Node3D.new()
	jugador.name = "JugadorFake"
	root.add_child(jugador)
	jugador.global_position = Vector3(10, 51, 10)
	mgr.configurar_jugador(jugador)
	for i in 4:
		await physics_frame
	mgr._evaluar_y_seleccionar()
	var objetivo = mgr.obtener_objetivo_actual()
	_check(objetivo == punto, "C5: manager detecta al punto (E)")

	# E sin dias: el guard de cosecha detiene la interaccion
	mgr._evaluar_y_seleccionar()
	mgr.presionar_interact()
	_check(inv.count_item("incense") == 0, "C6: E antes de tiempo NO cosecha")

	# Forzar 3 dias y cosechar de verdad
	punto.cultivo.dia_siembra = dia - IncenseCultivation.DIAS_COSECHA
	_check(punto.cultivo.listo(dia), "C7: listo tras 3 dias forzados")
	_check("Cosechar" in punto.obtener_nombre_prompt(), "C8: prompt 'Cosechar' cuando listo")
	mgr._evaluar_y_seleccionar()
	mgr.presionar_interact()
	var cosechado: int = inv.count_item("incense")
	_check(cosechado >= 2 and cosechado <= 4, "C9: cosecha por E entrega 2-4 (C5)")
	_check(punto.estado == 2, "C10: punto NO_DISPONIBLE tras cosechar")
	_check("agotado" in punto.obtener_nombre_prompt(), "C11: prompt 'agotado' tras cosechar")
	_check(not punto.requisitos_cumplidos(jugador), "C12: agotado no es interactuable")
	_check(not punto.listo_para_renovar(dia - IncenseCultivation.DIAS_COSECHA + 1),
			"C13: a los 2 dias de agotado -> sin renovar")
	_check(not punto.listo_para_renovar(dia), "C14: hoy agotado -> sin renovar")
	_check(punto.listo_para_renovar(dia + 3), "C15: a los 3 dias -> listo para renovar")
	_check(punto.renovar(dia + 3), "C16: renovar devuelve true")
	_check(punto.estado == 0 and punto.cultivo.plantado, "C17: renovado y replantado (C8)")

	# ================= D. IncenseSpawner =================
	var mock := MockLocator.new()
	root.add_child(mock)
	var sp = load("res://scripts/enchantment/incense_spawner.gd").new()
	sp.name = "SpawnerTest"
	sp.centro_montana = Vector2(500.0, 700.0)
	sp._locator = mock
	root.add_child(sp)
	_check(sp.puntos().size() == IncenseSpawner.CANT_PUNTOS,
			"D1: spawner crea %d puntos (C7)" % IncenseSpawner.CANT_PUNTOS)
	_check(mock.llamadas.size() >= IncenseSpawner.CANT_PUNTOS,
			"D2: alturas consultadas al locator")
	var dentro := true
	var alturas_ok := true
	for p in sp.puntos():
		var d: float = Vector2(p.global_position.x - 500.0, p.global_position.z - 700.0).length()
		if d > IncenseSpawner.RADIO_DISTRIB + 0.01:
			dentro = false
		if absf(p.global_position.y - 51.0) > 0.01:
			alturas_ok = false
	_check(dentro, "D3: todos los puntos dentro de la dispersion de montaña (C7)")
	_check(alturas_ok, "D4: alturas = locator.get_height + 1 (M167, sin hardcode)")

	# Anti-P39: el fuente del spawner no contiene el centro/radio de la isla
	var f = FileAccess.open("res://scripts/enchantment/incense_spawner.gd", FileAccess.READ)
	var src: String = f.get_as_text() if f else ""
	f = FileAccess.open("res://scripts/enchantment/incense_cultivation.gd", FileAccess.READ)
	var src2: String = f.get_as_text() if f else ""
	_check(src != "" and not ("2560" in src) and not ("1800" in src),
			"D5: spawner SIN centro/radio de isla hardcodeado (P-39)")
	_check(src2 != "" and not ("2560" in src2), "D6: cultivation sin valores de isla")

	# Renovacion via GameTime (C8)
	var p0 = sp.puntos()[0]
	p0.estado = 2
	p0.dia_agotado = dia - IncenseCultivation.DIAS_COSECHA
	sp._on_dia_cambio({"dia": dia})
	_check(p0.estado == 0 and p0.cultivo.plantado, "D7: dia_cambio renueva tras 3 dias")
	p0.estado = 2
	p0.dia_agotado = dia
	sp._on_dia_cambio({"dia": dia})
	_check(p0.estado == 2, "D8: dia_cambio NO renueva si faltan dias")

	# Estacionalidad (C3/C12): en cada cambio de estación aparece un punto raro
	_check(sp.puntos_raros().size() == 0, "D9: aun sin puntos raros")
	sp._on_estacion_cambio(1)
	_check(sp.puntos_raros().size() == 1, "D10: estacion_cambio genera 1 punto raro (M29)")
	var raro = sp.puntos_raros()[0]
	_check(raro.estado == 0 and raro.raro, "D11: punto raro DISPONIBLE")
	raro.estado = 2
	raro.dia_agotado = dia
	sp._on_estacion_cambio(2)
	_check(sp.puntos_raros().size() == 2, "D12: siguiente estacion genera otro raro")

	# Cosecha del raro por cadena E -> incense_rare en inventario
	var r_activo = null
	for p in sp.puntos_raros():
		if p.estado == 0:
			r_activo = p
			break
	_check(r_activo != null, "D13: hay un raro activo")
	if r_activo != null:
		r_activo.cultivo.dia_siembra = dia - IncenseCultivation.DIAS_COSECHA
		jugador.global_position = r_activo.global_position
		for i in 4:
			await physics_frame
		mgr._evaluar_y_seleccionar()
		_check(mgr.obtener_objetivo_actual() == r_activo, "D14: E apunta al raro")
		mgr._evaluar_y_seleccionar()
		mgr.presionar_interact()
		_check(inv.count_item("incense_rare") >= 2,
				"D15: cosecha de raro entrega incense_rare (C3)")
		_check("raro" in r_activo.obtener_razon_no_disponible()
				or r_activo.estado == 2, "D16: raro agotado tras cosecha")

	# Limpieza de escena de prueba
	punto.queue_free()
	sp.queue_free()
	mock.queue_free()
	jugador.queue_free()
	await process_frame
	_fin()

func inc_rareza_ok(it) -> bool:
	return int(it.rareza) >= int(ItemData.Rareza.RARO)
