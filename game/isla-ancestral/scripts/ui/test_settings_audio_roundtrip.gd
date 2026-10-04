# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-04
#
# M53: Test headless del round-trip UI de audio (SettingsAudioLayer <-> AudioConfig).
# Encargo canal 10 (Opción A): un test que FALLE de verdad si se rompe la
# integración entre la sección Audio de Ajustes y el dominio de audio de M91.
#
# Verifica:
#  - sliders -> set_volumen_porcentaje -> config["audio"] (DataStore/M60) y get_save_data
#  - señal inversa volumen_cambiado -> widget (sin bucle: set_value_no_signal)
#  - debounce §21.4: value_changed NO escribe config hasta commit
#  - mutes y opciones (compresion/rango_dinamico/dispositivo_salida) round-trip
#  - camino de fallo: aplicar_opcion inválida -> false + label de feedback visible
#  - i18n de la sección (claves SETTINGS.* recién agregadas a es.po)
#  - heal de des-registro (Esc/close_top) al reabrir
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_settings_audio_roundtrip.gd

extends SceneTree

## Piso de checks medido en verde (patrón M105)
const CHECKS_MINIMOS: int = 50

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var ac := root.get_node_or_null("AudioConfig")
	var ds := root.get_node_or_null("DataStore")
	var ui := root.get_node_or_null("UIManager")
	var loc := root.get_node_or_null("Localization")
	_check(ac != null, "AudioConfig autoload presente")
	_check(ds != null, "DataStore autoload presente")
	_check(ui != null, "UIManager autoload presente")
	if ac == null or ds == null or ui == null:
		_resumen()
		return
	if loc != null and loc.has_method("set_locale"):
		loc.set_locale("es")  # i18n determinista para los checks de texto

	# ── Snapshot del estado real (se restaura al final) ──────────────
	var buses: Array[String] = ["Master", "Music", "SFX"]
	var vol0 := {}
	var mute0 := {}
	for b in buses:
		vol0[b] = ac.get_volumen_porcentaje(b)
		mute0[b] = ac.esta_muteado(b)
	var op0 := {
		"rango_dinamico": String(ac.get_opcion("rango_dinamico", DynamicRangeManager.actual())),
		"compresion": bool(ac.get_opcion("compresion", CompressionManager.activa())),
		"dispositivo_salida": String(ac.get_opcion("dispositivo_salida", OutputDeviceManager.actual())),
	}

	# ── Montar la capa ────────────────────────────────────────────────
	var base_stack: int = ui.stack_size()
	var script := load("res://scripts/ui/layers/settings_audio_layer.gd")
	_check(script != null, "settings_audio_layer.gd carga")
	if script == null or not script.can_instantiate():
		# Sin can_instantiate(): un parse error haría colgar el proceso
		# (load devuelve el GDScript roto y .new() revienta sin llegar a quit())
		_check(script != null and script.can_instantiate(), "settings_audio_layer.gd compila sin errores de parseo")
		_resumen()
		return
	var capa = script.new()
	capa.name = "SettingsAudioTest"
	root.add_child(capa)
	_check(capa.layer_type == UILayerType.Type.MODAL_FULL, "layer_type MODAL_FULL")
	_check(not capa.visible, "inicia oculta")
	_check(ui.stack_size() == base_stack + 1, "registrada en la pila al entrar al árbol (%d)" % ui.stack_size())

	capa.open()
	_check(capa.visible, "open() la hace visible")

	# ── i18n (claves nuevas en es.po) ────────────────────────────────
	var titulo := _buscar(capa, "TituloAudio")
	_check(titulo != null and titulo.text == "Audio",
		"título i18n resuelve 'Audio' (obtuvo: %s)" % str(titulo.text) if titulo else "sin TituloAudio")
	var btn_v := _buscar(capa, "BtnVolver")
	_check(btn_v != null and btn_v.text == "Volver",
		"Volver i18n (obtuvo: %s)" % str(btn_v.text) if btn_v else "sin BtnVolver")

	# ── Slider Master: widget -> AudioConfig -> config["audio"] ──────
	var sl = _buscar(capa, "Slider_Master")
	_check(sl != null, "Slider_Master existe")
	var pct = _buscar(capa, "Pct_Master")
	_check(pct != null, "Pct_Master existe")
	# Estado conocido y distinto del objetivo (el slider ya está sincronizado
	# vía señal inversa al abrir)
	ac.set_volumen_porcentaje("Master", 80.0)
	_check(absf(float(sl.value) - 80.0) < 0.01, "reverse: slider toma 80 por ciento externo (obtuvo %s)" % str(sl.value))
	sl.value = 63.0  # en el árbol => value_changed síncrono (medido en 4.7)
	_check(pct.text == "63%", "etiqueta porcentual del slider se actualiza (obtuvo: %s)" % pct.text)
	_check(bool(capa._sucios["Master"]), "drag marca commit pendiente")
	var cfg_prev: Dictionary = ds.cargar_config()
	_check(absf(float(cfg_prev.get("audio", {}).get("Master", -1.0)) - 0.63) > 0.001,
		"debounce: NO escribe config antes del commit (Master sigue en %s)" % str(cfg_prev.get("audio", {}).get("Master")))
	_check(capa.commit_volumen("Master"), "commit_volumen(Master) devuelve true")
	_check(absf(ac.get_volumen_porcentaje("Master") - 63.0) < 0.01, "AudioConfig Master == 63%")
	var cfg: Dictionary = ds.cargar_config()
	_check(absf(float(cfg.get("audio", {}).get("Master", -1.0)) - 0.63) < 0.005,
		"config[\"audio\"].Master == 0.63 (obtuvo: %s)" % str(cfg.get("audio", {}).get("Master")))
	_check(absf(float(ac.get_save_data().get("volumenes", {}).get("Master", -1.0)) - 0.63) < 0.005,
		"get_save_data volumenes Master == 0.63")

	# ── Señal inversa: cambio externo -> widget (sin bucle) ──────────
	ac.set_volumen_porcentaje("Music", 41.0)
	var sl_m = _buscar(capa, "Slider_Music")
	var pct_m = _buscar(capa, "Pct_Music")
	_check(absf(float(sl_m.value) - 41.0) < 0.01, "reverse: slider Music sigue cambio externo")
	_check(pct_m.text == "41%", "reverse: etiqueta Music correcta (obtuvo: %s)" % pct_m.text)

	# ── Camino drag_ended: commit inmediato sin esperar timer ────────
	sl_m.value = 50.0
	capa._on_drag_ended(true, "Music")
	_check(absf(ac.get_volumen_porcentaje("Music") - 50.0) < 0.01, "drag_ended fuerza commit de Music (50%)")
	var cfg2: Dictionary = ds.cargar_config()
	_check(absf(float(cfg2.get("audio", {}).get("Music", -1.0)) - 0.50) < 0.005,
		"config[\"audio\"].Music == 0.50 tras drag_ended")

	# ── Mute round-trip ──────────────────────────────────────────────
	var mute = _buscar(capa, "Mute_SFX")
	_check(mute != null, "Mute_SFX existe")
	mute.button_pressed = true  # toggled -> set_mute
	_check(ac.esta_muteado("SFX") == true, "mute SFX aplicado vía widget")
	var cfg3: Dictionary = ds.cargar_config()
	_check(bool(cfg3.get("audio", {}).get("mutes", {}).get("SFX", false)) == true,
		"config[\"audio\"].mutes.SFX == true (BUG-092)")
	ac.set_mute("SFX", false)
	_check(mute.button_pressed == false, "reverse: widget mute revierte con mute_cambiado")

	# ── Opción compresion (bool) round-trip ──────────────────────────
	var chk_c = _buscar(capa, "Chk_Compresion")
	_check(chk_c != null, "Chk_Compresion existe")
	var comp_antes := CompressionManager.activa()
	chk_c.button_pressed = not comp_antes  # toggled -> aplicar_opcion
	_check(bool(ac.get_opcion("compresion", false)) == (not comp_antes),
		"set_opcion compresion round-trip")
	_check(CompressionManager.activa() == (not comp_antes), "compresión aplicada al motor")
	var cfg4: Dictionary = ds.cargar_config()
	_check(bool(cfg4.get("audio", {}).get("opciones", {}).get("compresion", false)) == (not comp_antes),
		"config[\"audio\"].opciones.compresion persistida")

	# ── Opción rango_dinamico (preset) round-trip ────────────────────
	var opt_r = _buscar(capa, "Opt_Rango")
	_check(opt_r != null and opt_r.item_count >= 3, "Opt_Rango con 3 presets")
	opt_r.select(0)               # select() no emite item_selected
	opt_r.item_selected.emit(0)   # simula la elección del usuario
	_check(String(ac.get_opcion("rango_dinamico", "")) == "quiet", "rango_dinamico == quiet")
	_check(DynamicRangeManager.actual() == "quiet", "preset quiet aplicado al bus Master")
	ac.set_opcion("rango_dinamico", "medio")
	_check(int(opt_r.selected) == 1, "reverse: dropdown rango == medio (selected=%d)" % int(opt_r.selected))

	# ── Camino de fallo: set_opcion inválida -> false + feedback ─────
	var ok_falso: bool = capa.aplicar_opcion("dispositivo_salida", "no_existe")
	_check(ok_falso == false, "aplicar_opcion inválida devuelve false")
	var lbl_f = _buscar(capa, "LblFallo")
	_check(lbl_f != null and lbl_f.visible, "label de feedback de fallo visible")
	_check(lbl_f != null and String(lbl_f.text) != "" and not String(lbl_f.text).begins_with("SETTINGS."),
		"feedback con texto traducido (obtuvo: %s)" % str(lbl_f.text) if lbl_f else "sin LblFallo")
	_check(String(ac.get_opcion("dispositivo_salida", "x")) != "no_existe", "opción inválida NO persistida")
	# Éxito real: devuelve true, oculta el feedback y revierte el widget
	_check(capa.aplicar_opcion("compresion", comp_antes) == true, "aplicar_opcion válida devuelve true")
	_check(lbl_f != null and not lbl_f.visible, "feedback oculto tras éxito")
	_check(chk_c.button_pressed == comp_antes, "widget compresion revierte con opcion_cambiada")

	# ── Opción dispositivo_salida (si el entorno expone dispositivos) ─
	var devs := OutputDeviceManager.dispositivos()
	if devs.size() > 0:
		var opt_d = _buscar(capa, "Opt_Dispositivo")
		_check(opt_d != null and opt_d.item_count == devs.size(), "Opt_Dispositivo poblado (%d)" % devs.size())
		opt_d.select(0)
		opt_d.item_selected.emit(0)
		_check(String(ac.get_opcion("dispositivo_salida", "")) == String(devs[0]),
			"dispositivo_salida round-trip == %s" % String(devs[0]))
	else:
		_check(true, "headless sin dispositivos de salida: round-trip de dispositivo omitido")

	# ── Cierre, reapertura y heal de des-registro (Esc / close_top) ──
	capa.close()
	_check(not capa.visible, "close() oculta la capa")
	_check(ui.stack_size() == base_stack + 1, "sigue registrada tras close()")
	ui.pop_layer(capa)  # simula Esc (close_top): des-registra
	_check(ui.stack_size() == base_stack, "pop_layer des-registra (simula Esc)")
	capa.open()
	_check(ui.stack_size() == base_stack + 1, "on_layer_opened RE-REGISTRA tras Esc (heal)")
	_check(capa.visible, "reabre correctamente tras el heal")

	# ── Restaurar el snapshot (no dejar el config del entorno sucio) ─
	for b in buses:
		ac.set_volumen_porcentaje(b, float(vol0[b]))
		ac.set_mute(b, bool(mute0[b]))
	if op0["rango_dinamico"] in DynamicRangeManager.RANGOS:
		ac.set_opcion("rango_dinamico", op0["rango_dinamico"])
	# (si el original era "custom" no hay API para restaurarlo: se documenta)
	ac.set_opcion("compresion", op0["compresion"])
	if op0["dispositivo_salida"] in OutputDeviceManager.dispositivos():
		ac.set_opcion("dispositivo_salida", op0["dispositivo_salida"])

	capa.free()  # inmediato: exit_tree des-registra
	_check(ui.stack_size() == base_stack, "free des-registra la capa")

	_resumen()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _buscar(node: Node, nombre: String) -> Node:
	if node.name == nombre:
		return node
	for child in node.get_children():
		if child.name == nombre:
			return child
		var r := _buscar(child, nombre)
		if r:
			return r
	return null

func _resumen() -> void:
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: piso de checks no alcanzado (%d < %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M53 SETTINGS AUDIO: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
