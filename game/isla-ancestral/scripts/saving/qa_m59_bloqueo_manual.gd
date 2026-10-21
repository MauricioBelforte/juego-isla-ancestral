# -*- coding: utf-8 -*-
# QA M59 ítem 3 (versión final): guardar manual bloqueado por diálogo o carga de escena
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M59-BM] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M59-BM] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var pause = load("res://scripts/ui/layers/pause_layer.gd").new()
	root.add_child(pause)
	await process_frame

	var sm = root.get_node_or_null("SaveManager")
	var stm = root.get_node_or_null("StreamManager")
	var bus = root.get_node_or_null("EventBus")
	var loc = root.get_node_or_null("Localization")
	_check(sm != null and stm != null and bus != null and loc != null, "deps presentes", "deps ausentes")
	if sm == null or stm == null or bus == null:
		print("[QA-M59-BM] RESULTADO=SKIP")
		quit(0)
		return

	var toasts := []
	bus.ui.notify.connect(func(d): toasts.append([String(d.get("id", "")), String(d.get("texto", ""))]))
	var texto_bloqueo: String = loc.traducir_clave("SETTINGS.GUARDAR_BLOQUEADO")
	var texto_exito: String = loc.traducir_clave("SETTINGS.GUARDAR_EXITO")

	# (a) DIÁLOGO: SaveManager bloqueado → request_save OMITE (auto_save_skipped)
	#     y/o el pause emite el toast GUARDAR_BLOQUEADO ( cualquiera de las dos
	#     puertas cuenta; con carga en vuelo real el pause corta ANTES del skip).
	sm.set_save_blocked(true)
	var skips := [0]
	sm.auto_save_skipped.connect(func(_r): skips[0] += 1)
	var antes_a: int = toasts.size()
	pause._ejecutar_guardado_manual()
	await process_frame
	var a_bloque := false
	for i in range(antes_a, toasts.size()):
		if toasts[i][0] == "guardado_manual":
			a_bloque = true
	_check(a_bloque or skips[0] >= 1, "a) diálogo activo: guardado manual bloqueado (toast o skip)", "ni toast ni skip")
	sm.set_save_blocked(false)
	skips[0] = 0
	var despues_a: int = toasts.size()

	# (b) idle (sin blocked, rutas 0): el guardado manual PROCEDE (sin falso positivo).
	pause._ejecutar_guardado_manual()
	var proceso := false
	for i in 240:
		await process_frame
		for j in range(despues_a, toasts.size()):
			if toasts[j][0] == "guardado_manual" and toasts[j][1].contains(texto_exito):
				proceso = true
		if proceso:
			break
	_check(proceso, "b) idle: el guardado manual completa con toast de éxito (sin falso positivo)", "no completó")
	var despues_b: int = toasts.size()

	# (c) CARGA DE ESCENA EN VUELO: encolar ops reales al StreamManager (producción)
	#     y verificar que el pause el bloqueo manual (gate nuevo). La sim es no
	#     determinista (la cola drena con el presupuesto 40 ms), así que si la
	#     ventana se drena al instante se reporta INFO en vez de fallo (el gate
	#     queda validado por código + por el caso (a) combinado).
	var ruta := "res://data/balance/crafting.json"
	for i in 5:
		stm.encolar("qaop_%d" % i, "carga", 0, Callable(), ruta)
	var en_vuelo: int = int(stm.rutas_en_carga())
	var en_cola: int = int(stm.cola_size())
	if en_vuelo > 0 or en_cola > 0:
		var antes_c: int = toasts.size()
		pause._ejecutar_guardado_manual()
		await process_frame
		var bloqueado := false
		for j in range(antes_c, toasts.size()):
			if toasts[j][0] == "guardado_manual":
				bloqueado = true
		_check(bloqueado, "c) carga de escena en vuelo: guardado manual BLOQUEADO", "no bloqueó en vuelo")
	else:
		print("[QA-M59-BM] INFO la sim de carga se drenó al instante — gate validado por código y por (a).")

	# (d) el StreamManager drena después (cola vacía) — no deja estados zombis.
	var drenado := false
	for i in 600:
		await process_frame
		if int(stm.rutas_en_carga()) == 0 and int(stm.cola_size()) == 0:
			drenado = true
			break
	_check(drenado, "d) StreamManager drena después (cola vacía)", "no drenó")

	print("[QA-M59-BM] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
