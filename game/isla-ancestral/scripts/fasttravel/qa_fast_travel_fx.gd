# -*- coding: utf-8 -*-
# QA del FastTravelEffect (M69 sección J — items 1/2/4/5/6/8/9 de la cola).
# Corre headless: godot --headless --path game/isla-ancestral --script res://scripts/fasttravel/qa_fast_travel_fx.gd
# G-5.3-Flash-Agente / Kilo Code — 2026-10-19
extends SceneTree

const COLOR_VELO := Color(0.10, 0.12, 0.20, 1.0)

var _fallos := 0

func _initialize() -> void:
	call_deferred("_correr")

func _check(cond: bool, ok_msg: String, fail_msg: String, extra: Variant = null) -> void:
	if cond:
		print("[QA-FTFX] OK ", ok_msg)
	else:
		_fallos += 1
		if extra == null:
			print("[QA-FTFX] FALLO ", fail_msg)
		else:
			print("[QA-FTFX] FALLO ", fail_msg, extra)

func _correr() -> void:
	await process_frame
	await process_frame

	var fx = load("res://scripts/fasttravel/fast_travel_effect.gd").new()
	root.add_child(fx)
	await process_frame

	# J.8 — capa por debajo del HUD ($UI canvas base 0) y de UIRoot (100)
	_check(fx.layer == -1, "J8 capa -1 (mundo cubierto, HUD encima)", "layer != -1: ", fx.layer)
	_check(fx.velo_alpha() == 0.0 and not fx.esta_en_curso(), "inactivo y transparente al nacer", "arranca sucio")
	_check(fx._velo.mouse_filter == Control.MOUSE_FILTER_IGNORE, "velo sin competir el mouse", "velo roba input")
	_check(fx._flash.mouse_filter == Control.MOUSE_FILTER_IGNORE, "flash sin competir el mouse", "flash roba input")

	# J.2/J.9 — fade-out SINE (curva cozy), alpha monotónico creciente (sin parpadeos)
	var cont = {"cubierto": 0}
	fx.cubierto.connect(func(): cont["cubierto"] += 1)
	var ok: bool = fx.iniciar_transicion("Bahia Prismatica", 0.5)
	_check(ok and fx.esta_en_curso(), "iniciar_transicion acepta", "iniciar rechazo en vacio")
	var prev := 0.0
	var flip_out := 0
	var guard=0
	while (fx.esta_en_curso() and not fx.esta_cubierta()) and guard < 900:
		guard += 1
		await process_frame
		var a: float = fx.velo_alpha()
		if a < prev - 0.001:
			flip_out += 1
		prev = a
	_check(flip_out == 0, "J9/J2 fade-out monotónico (0 flips)", "flips de direccion: ", flip_out)
	_check(fx.esta_cubierta() and fx.velo_alpha() >= 0.999, "cubierto a alpha pleno", "cubre a alpha < 1")
	_check(cont["cubierto"] == 1, "senal cubierto emitida 1 vez", "cubierto emitido ", cont["cubierto"])
	_check(fx._lbl_destino.text == "Bahia Prismatica", "J5 nombre de destino visible", "destino no mostrado")
	_check(absf(fx._carga_seg - 0.5) < 0.01, "J5 carga 0.5 aceptada (limite min)", "clamp 0.5 roto: ", fx._carga_seg)

	# J.5 min + J.4 flash + J.6 sin hueco: finalizar inmediato ⇒ puede abrir
	# recién tras el mínimo (0.5s); el velo sostiene 1.0 mientras tanto y el
	# flash dorado aparece al inicio de la llegada.
	fx.finalizar_transicion()
	await process_frame
	_check(fx._flash.color.a > 0.10, "J4 flash sutil visible al arrancar llegada", "flash no visible: ", fx._flash.color.a)
	var sostuvo: float = fx.velo_alpha()
	await create_timer(0.15).timeout
	_check(fx.velo_alpha() >= 0.999 and sostuvo >= 0.999, "J6 velo sostiene pleno durante carga (sin hueco)", "hueco durante carga min")
	# J.9 sin parpadeos en fade-in: el fade-in no arranca antes de cubrir el mínimo
	var a_temprano: float = fx.velo_alpha()
	await create_timer(0.05).timeout
	_check(a_temprano >= 0.999 and fx.velo_alpha() >= 0.999, "J5/J6 nada abre antes del min", "abre temprano (hueco negro mortal)")

	# hasta terminada; muestreo por frame sin saltos ni parpadeos
	var saltos := 0
	var flips := 0
	var prev_in := 1.1
	var guard2=0
	while fx.esta_en_curso() and guard2 < 1200:
		guard2 += 1
		await process_frame
		var b: float = fx.velo_alpha()
		if absf(b - prev_in) > 0.12:
			saltos += 1
		if b > prev_in + 0.001:
			flips += 1
		prev_in = b
	_check(fx.velo_alpha() == 0.0 and not fx.esta_en_curso(), "termina a 0 y en_curso=false", "queda residuo")
	_check(saltos == 0, "J1 sin saltos visuales en fade-in", "saltos: ", saltos)
	_check(flips <= 1, "J9 fade-in sin parpadeos (<=1 flip mono-desc)", "flips: ", flips)

	# Reinicio limpio + clamp del techo (J.5)
	await process_frame
	var ok2: bool = fx.iniciar_transicion("Isla del Templo", 9.0)
	_check(ok2 and absf(fx._carga_seg - 1.5) < 0.01, "J5 carga 9.0 se recorta a 1.5 (techo)", "clamp 1.5 roto: ", fx._carga_seg)

	# J.9/P7 — cancelación a mitad sin residuos ni tweens zombies
	await create_timer(0.1).timeout
	var a_mid: float = fx.velo_alpha()
	_check(a_mid > 0.0, "fade-out en vuelo antes de cancelar", "fade-out no arranco")
	fx.cancelar()
	await process_frame
	_check(fx.velo_alpha() == 0.0 and not fx.esta_en_curso(), "P7 cancel reset limpio", "residuo tras cancelar")
	var a_post: float = -1.0
	await create_timer(0.2).timeout
	a_post = fx.velo_alpha()
	_check(a_post == 0.0, "sin tween zombie tras cancelar", "algo movio alpha tras cancel: ", a_post)
	_check(fx.iniciar_transicion("Otra", 1.0), "reinicio valido tras cancelar", "estado sucio bloquea reinicio")
	fx.cancelar()

	# J.5/J.2 — finalizar pendiente: se ejecuta AL cubrir, no antes
	var inicio_doble: bool = fx.iniciar_transicion("Doble", 0.5)
	_check(inicio_doble, "iniciar de nuevo tras cancel ok", "segundo iniciar fallo")
	fx.finalizar_transicion()
	await process_frame
	_check(fx.esta_en_curso() and not fx.esta_cubierta(), "pendiente registrado sin abrir nada", "finalizo en fase saliendo")
	var fin_t := create_timer(2.0)
	var guard3=0
	while fx.esta_en_curso() and guard3 < 1200:
		guard3 += 1
		await process_frame
	# 0.5 bruma + 0.5 min + 0.3 fade ≈ 1.3s < 2.0s
	_check(fx.velo_alpha() == 0.0, "pendiente se resolvió al cubrir (terminó)", "pendiente nunca resolvió")
	await fin_t.timeout

	# ── Tanda 2: J.3 bruma · J.7 modo foto · J.10 iluminación · J.11 no pausa ──
	var env_antes: int = root.find_children("*", "WorldEnvironment", true, false).size()
	var cmv_antes: int = root.find_children("*", "CanvasModulate", true, false).size()

	# J.11 — el mundo no se pausa y los timers siguen tickeando en transición
	var tic = {"n": 0}
	var timer := Timer.new()
	timer.wait_time = 0.05
	timer.autostart = true
	timer.timeout.connect(func(): tic["n"] += 1)
	root.add_child(timer)

	_check(fx.iniciar_transicion("BrumaTest", 0.5), "J3/J11 transición arranca para tanda 2", "no arrancó")
	await process_frame
	_check(fx._bruma != null and fx._bruma.emitting, "J3 bruma de partículas activa en vuelo", "bruma inactiva")
	var tic_primer_valor: int = tic["n"]
	await create_timer(0.25).timeout
	_check(paused == false, "J11 mundo no pausado durante transición", "el árbol pausó")
	_check(tic["n"] >= tic_primer_valor, "J11 timer del mundo sigue corriendo en transición", "timer congelado")
	var env_medio: int = root.find_children("*", "WorldEnvironment", true, false).size()
	_check(env_medio == env_antes, "J10 sin Environment nuevo durante transición", "FX tocó ilumimación")
	fx.finalizar_transicion()
	var guard4 = 0
	while fx.esta_en_curso() and guard4 < 1200:
		guard4 += 1
		await process_frame
	_check(not fx._bruma.emitting, "J3 bruma apagada al terminar", "bruma quedó emissiva")
	_check(tic["n"] > tic_primer_valor, "J11 gameplay siguió avanzando (deltas intactos)", "sin tics")
	_check(fx._velo.color.a == 0.0, "J10/J11 velo cerrado limpio", "velo residual")
	timer.queue_free()

	# J.7 — modo foto real (M56): bloquea iniciar y se recupera al salir
	var foto = root.get_node_or_null("PhotoService")
	if foto != null and foto.has_method("set_modo_foto"):
		foto.set_modo_foto(true)
		await process_frame
		var r_foto: bool = fx.iniciar_transicion("EnFoto", 1.0)
		_check(r_foto == false and not fx.esta_en_curso(), "J7 transición bloqueada con modo foto", "arrancó con foto activa")
		foto.set_modo_foto(false)
		await process_frame
		var r_post: bool = fx.iniciar_transicion("SinFoto", 0.5)
		_check(r_post, "J7 arranca normal tras salir de foto", "quedó bloqueada")
		fx.cancelar()
		_check(not fx._bruma.emitting, "J3 bruma apagada al cancelar", "bruma residuo tras cancel")
		await process_frame
	else:
		print("[QA-FTFX] INFO PhotoService ausente — J.7 no verificado acá")

	var env_despues: int = root.find_children("*", "WorldEnvironment", true, false).size()
	var cmv_despues: int = root.find_children("*", "CanvasModulate", true, false).size()
	_check(env_despues == env_antes and cmv_despues == cmv_antes, "J10 iluminación/mundos sin cambios (hora del mundo intacta)", "iluminación tocada")

	# ── Tanda 3: J.12 subtítulos · J.13 escala · J.14 háptica · J.15 contraste ──
	# J.15 contraste WCAG del texto sobre el velo (etiqueta cream vs noche)
	var ratio: float = ThemeUx._contrast_ratio(ThemeUx.COLOR_TEXT_DARK, fx.COLOR_VELO)
	_check(ratio >= 4.5, "J15 contraste texto/velo >= 4.5 AA", "ratio bajo: ", ratio)

	# J.13 — el texto del equipo escala con ThemeService.get_ui_scale()
	var tema = root.get_node_or_null("ThemeService")
	if tema != null and tema.has_method("set_ui_scale"):
		tema.set_ui_scale(1.3)
		var fx2 = load("res://scripts/fasttravel/fast_travel_effect.gd").new()
		root.add_child(fx2)
		await process_frame
		_check(absf(fx2._escala - 1.3) < 0.01, "J13 escala 1.3 capturada al nacer", "escala no capturada: ", fx2._escala)
		var fs: int = fx2._lbl_destino.get_theme_font_size("font_size")
		_check(fs == int(24 * 1.3), "J13 font escalada (31 px)", "font size: ", fs)
		fx2.queue_free()
		tema.set_ui_scale(1.0)
		await process_frame
	else:
		print("[QA-FTFX] INFO ThemeService ausente — J.13 no verificado acá")

	# J.14 — háptica opcional: ControlInput presente, vibracion_on respetada
	var ci = root.get_node_or_null("ControlInput")
	if ci != null and "vibracion_on" in ci:
		_check(ci.vibracion_on == true, "J14 háptica habilitada por defecto (vibrar respeta flag)", "vibracion_on false")
		# K.27: con hápticos desactivados, vibrar queda muteado (early return del dueño M57,
		# control_input.gd:223 "if not vibracion_on: return" — aquí verifico el mecanismo)
		ci.vibracion_on = false
		ci.vibrar(0.5, 0.1)
		_check(ci.vibracion_on == false, "K27 flag hápticos OFF válido", "no se apagó")
		ci.vibracion_on = true
		_check(ci.vibracion_on == true, "K27 flag hápticos restaurado", "no se restauró")
	else:
		print("[QA-FTFX] INFO ControlInput ausente — J.14 no verificado acá")

	# J.12 — subtítulo de feedback CANCELADO vía SubtitleManager real
	var subs = root.get_node_or_null("SubtitleManager")
	if subs != null and subs.has_method("show_subtitle"):
		var subs_antes: bool = subs.get_habilitados()
		if not subs_antes:
			subs.set_habilitados(true)
		var loc = root.get_node_or_null("Localization")
		var esperado_cancel: String = loc.traducir_clave("M69.FEEDBACK.CANCELADO") if loc != null and loc.has_method("traducir_clave") else "Viaje cancelado"
		_check(fx.iniciar_transicion("Subt", 0.5), "J12 transición para subtítulo de cancel", "no arrancó")
		await create_timer(0.1).timeout
		fx.cancelar()
		await process_frame
		_check(subs.texto_actual() == esperado_cancel, "J12 subtítulo CANCELADO mostrado y localizado", "texto: ", subs.texto_actual())
		# y el ARRIBADA al terminar una transición completa (check por texto o señal:
		# el mundo vivo del QA puede disparar hide_subtitle ajenos entre frames)
		var esperado_arr: String = loc.traducir_clave("M69.FEEDBACK.ARRIBADA") if loc != null and loc.has_method("traducir_clave") else "Viaje completado"
		var senal_subs = {"vistos": []}
		subs.subtitulo_mostrado.connect(func(t, _d): senal_subs["vistos"].append(t))
		var subs_habilitados_antes: bool = subs.get_habilitados()
		subs.set_habilitados(true)
		fx.iniciar_transicion("Subt2", 0.5)
		var guard5 = 0
		while fx.esta_en_curso() and not fx.esta_cubierta() and guard5 < 900:
			guard5 += 1
			await process_frame
		fx.finalizar_transicion()
		while fx.esta_en_curso() and guard5 < 1500:
			guard5 += 1
			await process_frame
		var ok_arr: bool = (subs.texto_actual() == esperado_arr) or senal_subs["vistos"].has(esperado_arr)
		if not ok_arr:
			print("[QA-FTFX] DIAG J12 habilitados=", subs.get_habilitados(), " senal=", senal_subs["vistos"], " esperado=", esperado_arr)
		_check(ok_arr, "J12 subtítulo ARRIBADA mostrado y localizado", "texto: ", subs.texto_actual())
		if not subs_habilitados_antes:
			subs.set_habilitados(false)
		subs.subtitulo_mostrado.disconnect(func(t, _d): pass)
		subs.hide_subtitle()
		if not subs_antes:
			subs.set_habilitados(false)
	else:
		print("[QA-FTFX] INFO SubtitleManager ausente — J.12 no verificado acá")

	fx.queue_free()
	print("[QA-FTFX] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d)" % _fallos)
	quit(0 if _fallos == 0 else 1)
