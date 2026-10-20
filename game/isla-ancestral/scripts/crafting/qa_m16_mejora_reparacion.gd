# -*- coding: utf-8 -*-
# QA M16 RF-MR (N.1, items 44 de la cola): mejorar/reparar herramientas — G-5.3-Flash-Agente
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M16-MR] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M16-MR] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var svc = load("res://scripts/crafting/crafting_service.gd").new()
	svc.registra_en_save = false
	root.add_child(svc)
	await process_frame

	var inv = root.get_node_or_null("Inventario")
	_check(inv != null and svc._mejora_cfg.size() > 0, "inventario + schema MR3 cargados", "deps ausentes")

	var item_id := "hacha_cobre"
	var mejidas := [0]
	var reparadas := [0]
	svc.herramienta_mejorada.connect(func(_i, _n): mejidas[0] += 1)
	svc.herramienta_reparada.connect(func(_i, _d): reparadas[0] += 1)

	# (a) Sin materiales: motivo 'materiales_insuficientes' y SIN consumo ni señal.
	inv.remover_items({"madera_robusta": inv.count_item("madera_robusta", true)})
	var antes_m: int = inv.count_item("madera_robusta", true)
	var r_sin: Dictionary = svc.mejorar_herramienta(item_id)
	_check(r_sin.get("ok") == false and r_sin.get("motivo") == "materiales_insuficientes", "sin materiales: motivo correcto",
		"motivo: %s" % str(r_sin))
	_check(inv.count_item("madera_robusta", true) == antes_m and mejidas[0] == 0,
		"sin materiales: no consume ni emite", "consumió con fallo")

	# (b) Mejorar 1 nivel OK: dict completo, señal, materiales descontados.
	var coste: Dictionary = svc._mejora_cfg["tipos"]["hacha"]["coste_nivel"][0]
	var mats_antes: Dictionary = {}
	for it in coste:
		inv.agregar_items({String(it): int(coste[it]) + 3})
		mats_antes[String(it)] = inv.count_item(String(it), true)
	var r_ok: Dictionary = svc.mejorar_herramienta(item_id)
	_check(r_ok.get("ok") == true and r_ok.get("nivel_anterior") == 0 and r_ok.get("nivel_nuevo") == 1,
		"mejora 0->1 con retorno honesto", "retorno: %s" % str(r_ok))
	var desconto := true
	for it in coste:
		if inv.count_item(String(it), true) != int(mats_antes[String(it)]) - int(coste[it]):
			desconto = false
	_check(desconto, "materiales descontados exactos (RF-MR5)", "descuento parcial")
	_check(mejidas[0] == 1, "señal herramienta_mejorada emitida 1 vez", "señales: %d" % mejidas[0])

	# (c) Reparar: consume coste_reparacion y emite durabilidad objetivo (=máx nivel 1).
	var r_rep: Dictionary = svc.reparar_herramienta(item_id)
	_check(r_rep.get("ok") == true and reparadas[0] == 1, "reparar OK con señal", "reparación: %s" % str(r_rep))
	_check(int(r_rep.get("_durabilidad", -1)) == svc.durabilidad_maxima("hacha", 1),
		"durabilidad objetivo = máximo del nivel actual", "d: %s" % str(r_rep))

	# (d) Balance MR4: curvas coherentes con el schema.
	_check(svc.durabilidad_maxima("hacha", 3) == 100 + 50 * 3, "durabilidad_maxima curva nivel 3 (250)", "curva: %d" % svc.durabilidad_maxima("hacha", 3))
	_check(absf(svc.efectividad("hacha", 2) - 1.30) < 0.001, "efectividad nivel 2 = 1.30", "e: %s" % str(svc.efectividad("hacha", 2)))

	# (e) Techo: emparchar nivel al máximo -> siguiente mejora da 'nivel_maximo'.
	svc._niveles_mejora[item_id] = 3
	var r_techo: Dictionary = svc.mejorar_herramienta(item_id)
	_check(r_techo.get("ok") == false and r_techo.get("motivo") == "nivel_maximo", "techo: motivo nivel_maximo", "techo: %s" % str(r_techo))
	svc._niveles_mejora[item_id] = 1

	# (f) No-herramienta: motivo no_es_herramienta (MR10 parcial service-side).
	var r_no: Dictionary = svc.mejorar_herramienta("piedra_caliza")
	_check(r_no.get("ok") == false and r_no.get("motivo") == "no_es_herramienta", "item no-herramienta rechazado", "motivo: %s" % str(r_no))

	# (g) RF-MR7 persistencia ADITIVA: save contiene niveles; save viejo no rompe.
	var data: Dictionary = svc.get_save_data()
	_check((data.get("niveles_mejora", {}) as Dictionary).get(item_id, 0) == 1, "save contiene nivel_mejora", "save sin nivel")
	svc.restore_save_data({})
	_check(svc._niveles_mejora.is_empty(), "restore de save viejo (sin campo) no rompe", "rompió con save viejo")
	svc.restore_save_data(data)
	_check(int(svc._niveles_mejora.get(item_id, 0)) == 1, "restore recupera nivel", "no restauró")

	svc.queue_free()
	print("[QA-M16-MR] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
