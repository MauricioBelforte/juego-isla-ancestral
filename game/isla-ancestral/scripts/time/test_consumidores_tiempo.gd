# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# QA de integración: consumidores conectados al GameTime (M29).
# Valida: dia_absoluto monótono, restock/hora automática de tiendas (M39),
# sync de límites diarios de amistad (M20), ventana de oferta (M38) y
# descuento por amistad en precios.
extends SceneTree

var fallos := 0
var ok := 0

func _init() -> void:
	call_deferred("_correr")

func _check(nombre: String, cond: bool) -> void:
	if cond:
		ok += 1
		print("[OK] ", nombre)
	else:
		fallos += 1
		printerr("[FAIL] ", nombre)

func _correr() -> void:
	var gt = root.get_node_or_null("/root/GameTime")
	_check("GameTime presente", gt != null)
	if gt == null:
		_fin()
		return

	# 1) Día absoluto inicial (año 1, mes 1, día 1 → 1)
	var d0 := int(gt.dia_absoluto())
	_check("dia_absoluto inicial == 1", d0 == 1)

	# 2) Cruzar la medianoche vía avanzar_hasta dispara dia_cambio una vez
	var cont := {"hora": 0, "dia": 0}
	gt.hora_cambio.connect(func(_h): cont["hora"] += 1)
	gt.dia_cambio.connect(func(_i): cont["dia"] += 1)
	gt.avanzar_hasta(7, 0)   # 8:00 → medianoche → 7:00 del día siguiente
	_check("avanzar_hasta cruza horas (ticks > 0)", cont["hora"] > 0)
	_check("dia_cambio emitido exactamente 1 vez", cont["dia"] == 1)
	_check("dia_absoluto monótono tras medianoche == 2", int(gt.dia_absoluto()) == d0 + 1)

	# 3) ShopManager resincronizado automáticamente con GameTime (M39↔M29)
	var sm = root.get_node_or_null("/root/ShopManager")
	_check("ShopManager presente", sm != null)
	if sm != null:
		_check("ShopManager.dia_laborable == GameTime.semana_dia",
			sm._dia_laborable_actual == gt.get_semana_dia())
		_check("ShopManager.hora == GameTime.hora", sm._hora_actual == gt.get_hora())

	# 4) Friendship sincronizado con el día absoluto (M20↔M29)
	var fs = root.get_node_or_null("/root/Friendship")
	_check("Friendship presente", fs != null)
	if fs != null:
		fs.registrar_vecino("t_npc")
		_check("Friendship.dia == dia_absoluto", fs._dia == int(gt.dia_absoluto()))

	# 5) Ventana de oferta: registrar ventas queda visible en ventas_hoy (M38)
	var eco = root.get_node_or_null("/root/EconomyManager")
	_check("EconomyManager presente", eco != null)
	if eco != null and eco.precios != null:
		eco.registrar_venta_para_mercado("obj_prueba_x", 5, int(gt.dia_absoluto()))
		_check("ventas_hoy registra la venta registrada",
			int(eco.precios.ventas_hoy("obj_prueba_x")) == 5)

	# 6) Descuento por amistad activo con nivel >= 2 (M20→M38)
	if fs != null and eco != null:
		var item_id := ""
		for cand in ["OBJ-PLA-001", "obj_pla_001", "com_manzana"]:
			if eco.precio_compra_vigente(cand) > 0:
				item_id = cand
				break
		if item_id != "":
			var v = fs._vecinos["t_npc"]
			v.aplicar_puntos(9999, fs.RECOMPENSAS_NIVEL)
			var nivel := int(fs.get_nivel("t_npc"))
			_check("nivel de amistad forzado >= 2", nivel >= 2)
			var sin_desc := int(eco.precio_compra_vigente(item_id))
			var con_desc := int(eco.precio_compra_vigente(item_id, "t_npc"))
			_check("descuento amistad aplica (precio con npc < base)", con_desc < sin_desc)
		else:
			print("[SKIP] descuento amistad: ningún ítem candidato con precio_compra > 0")

	_fin()

func _fin() -> void:
	print("---CONSUMIDORES-TIEMPO---")
	print("%d checks, %d fallos" % [ok + fallos, fallos])
	print("RESULTADO: %s" % ("OK" if fallos == 0 else "FALLOS"))
	quit(1 if fallos > 0 else 0)
