# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-04
#
# M53 — SettingsAudioLayer: sección Audio del menú Ajustes (frente Opción A,
# encargo canal 10; wire-up del dominio de audio de M91 / BUG-092).
#
# Construye en código (patrón de pause_layer) la PRIMERA UI de audio del juego:
#   - 3 sliders Maestro/Música/Efectos (0-100%) -> AudioConfig.set_volumen_porcentaje
#   - 3 mutes por bus -> AudioConfig.set_mute
#   - Opciones rango_dinamico/compresion/dispositivo_salida -> AudioConfig.set_opcion
#     con feedback visual cuando la API devuelve false (label de fallo + revert
#     del widget al estado real)
#   - Botón Volver -> close() (capa autogestionada, patrón créditos/inventario)
#
# Persistencia: set_volumen()/set_opcion() guardan config.cfg (M60) en CADA
# llamada; un drag de slider emite value_changed a ~60 Hz, así que el commit se
# DEBOUNCEA (0.25 s) y se fuerza en drag_ended/close (§21.4: sin I/O por frame).
#
# Señales inversas (AudioConfig -> widgets): set_value SÍ emite value_changed
# cuando el control está en el árbol (medido en Godot 4.7 headless) y
# volumen_cambiado se emite SIEMPRE -> sin set_value_no_signal /
# set_pressed_no_signal habría bucle infinito.
#
# Abrir: open() (patrón sancionado ui_manager.gd L457-459; push_layer es no-op
# para capas ya registradas). on_layer_opened re-registra la capa por si un Esc
# (close_top) la des-registró antes.
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_settings_audio_roundtrip.gd

class_name SettingsAudioLayer
extends UILayer

## Buses expuestos en la sección (subconjunto relevante; AudioConfig valida)
const BUSES_SECCION: Array[String] = ["Master", "Music", "SFX"]

## Debounce de persistencia durante drag/teclado (segundos, §21.4)
const DEBOUNCE_COMMIT: float = 0.25

## etiqueta i18n por preset de DynamicRangeManager (orden = RANGOS)
const CLAVES_RANGO := {
	"quiet": "SETTINGS.RANGO_QUIET",
	"medio": "SETTINGS.RANGO_MEDIO",
	"dinamico": "SETTINGS.RANGO_DINAMICO_PRESET",
}

var _ac: Node = null
var _conectado: bool = false

var _sliders: Dictionary = {}   # bus -> HSlider
var _pcts: Dictionary = {}      # bus -> Label "%"
var _mutes: Dictionary = {}     # bus -> CheckButton
var _opt_rango: OptionButton = null
var _chk_compresion: CheckButton = null
var _opt_dispositivo: OptionButton = null
var _lbl_fallo: Label = null
var _timer_commit: Timer = null
var _sucios: Dictionary = {}    # bus -> bool (volumen pendiente de commit)
var _primer_control: Control = null


func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_FULL
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_ac = get_node_or_null("/root/AudioConfig")
	_crear_ui()
	visible = false


func _crear_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.name = "FondoDim"
	add_child(dim)
	dim.move_to_front()

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.92, 0.86, 0.98)
	sb.border_color = Color(0.72, 0.55, 0.30)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.custom_minimum_size = Vector2(460, 0)
	panel.add_child(vbox)

	var title := Label.new()
	title.name = "TituloAudio"
	title.text = _t("SETTINGS.AUDIO_TITULO")
	title.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H1)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	_crear_fila_volumen(vbox, "Master", "SETTINGS.MAESTRO")
	_crear_fila_volumen(vbox, "Music", "SETTINGS.MUSICA")
	_crear_fila_volumen(vbox, "SFX", "SETTINGS.EFECTOS")

	vbox.add_child(HSeparator.new())

	var hdr_op := Label.new()
	hdr_op.name = "HdrOpciones"
	hdr_op.text = _t("SETTINGS.OPCIONES")
	hdr_op.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	vbox.add_child(hdr_op)

	_crear_fila_rango(vbox)
	_crear_fila_compresion(vbox)
	_crear_fila_dispositivo(vbox)

	_lbl_fallo = Label.new()
	_lbl_fallo.name = "LblFallo"
	_lbl_fallo.text = ""
	_lbl_fallo.visible = false
	_lbl_fallo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_fallo.add_theme_color_override("font_color", Color(0.75, 0.15, 0.1))
	_lbl_fallo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_lbl_fallo)

	var btn_volver := Button.new()
	btn_volver.name = "BtnVolver"
	btn_volver.text = _t("SETTINGS.VOLVER")
	btn_volver.pressed.connect(_on_volver)
	vbox.add_child(btn_volver)
	if _primer_control == null:
		_primer_control = _sliders.get("Master", btn_volver)

	# Debounce de persistencia (una sola vez, child de la capa)
	_timer_commit = Timer.new()
	_timer_commit.name = "TimerCommit"
	_timer_commit.wait_time = DEBOUNCE_COMMIT
	_timer_commit.one_shot = true
	_timer_commit.timeout.connect(commit_pendiente)
	add_child(_timer_commit)

	# Estado inicial desde AudioConfig (se re-sincroniza en on_layer_opened)
	_sincronizar_todo()


func _crear_fila_volumen(vbox: VBoxContainer, bus: String, clave_etiqueta: String) -> void:
	var fila := HBoxContainer.new()
	fila.name = "Fila_" + bus

	var lbl := Label.new()
	lbl.text = _t(clave_etiqueta)
	lbl.custom_minimum_size = Vector2(120, 0)
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(lbl)

	var sl := HSlider.new()
	sl.name = "Slider_" + bus
	sl.min_value = 0.0
	sl.max_value = 100.0
	sl.step = 1.0
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# Valor ANTES de conectar: el estado inicial no debe marcar commit
	sl.value = _ac.get_volumen_porcentaje(bus) if _ac else 100.0
	sl.value_changed.connect(_on_slider_volumen.bind(bus))
	sl.drag_ended.connect(_on_drag_ended.bind(bus))
	fila.add_child(sl)

	var pct := Label.new()
	pct.name = "Pct_" + bus
	pct.custom_minimum_size = Vector2(50, 0)
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pct.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pct.text = _fmt_pct(float(sl.value))
	fila.add_child(pct)

	var mute := CheckButton.new()
	mute.name = "Mute_" + bus
	mute.text = _t("SETTINGS.SILENCIAR")
	mute.button_pressed = _ac.esta_muteado(bus) if _ac else false
	mute.toggled.connect(_on_mute_toggled.bind(bus))
	fila.add_child(mute)

	vbox.add_child(fila)
	_sliders[bus] = sl
	_pcts[bus] = pct
	_mutes[bus] = mute
	_sucios[bus] = false
	if _primer_control == null:
		_primer_control = sl


func _crear_fila_rango(vbox: VBoxContainer) -> void:
	var fila := HBoxContainer.new()
	fila.name = "Fila_Rango"
	var lbl := Label.new()
	lbl.text = _t("SETTINGS.RANGO_DINAMICO")
	lbl.custom_minimum_size = Vector2(120, 0)
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(lbl)

	var opt := OptionButton.new()
	opt.name = "Opt_Rango"
	opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for r in DynamicRangeManager.RANGOS:
		opt.add_item(_t(CLAVES_RANGO.get(String(r), "SETTINGS.RANGO_DINAMICO_PRESET")))
	opt.item_selected.connect(_on_rango_sel)
	fila.add_child(opt)
	vbox.add_child(fila)
	_opt_rango = opt


func _crear_fila_compresion(vbox: VBoxContainer) -> void:
	var fila := HBoxContainer.new()
	fila.name = "Fila_Compresion"
	var lbl := Label.new()
	lbl.text = _t("SETTINGS.COMPRESION")
	lbl.custom_minimum_size = Vector2(120, 0)
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(lbl)

	var chk := CheckButton.new()
	chk.name = "Chk_Compresion"
	chk.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chk.toggled.connect(_on_compresion_toggled)
	fila.add_child(chk)
	vbox.add_child(fila)
	_chk_compresion = chk


func _crear_fila_dispositivo(vbox: VBoxContainer) -> void:
	var fila := HBoxContainer.new()
	fila.name = "Fila_Dispositivo"
	var lbl := Label.new()
	lbl.text = _t("SETTINGS.DISPOSITIVO_SALIDA")
	lbl.custom_minimum_size = Vector2(120, 0)
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(lbl)

	var opt := OptionButton.new()
	opt.name = "Opt_Dispositivo"
	opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for d in OutputDeviceManager.dispositivos():
		opt.add_item(String(d))
	opt.item_selected.connect(_on_dispositivo_sel)
	fila.add_child(opt)
	vbox.add_child(fila)
	_opt_dispositivo = opt


## ── Handlers: widgets -> AudioConfig (forward) ────────────

func _on_slider_volumen(value: float, bus: String) -> void:
	if not _pcts.has(bus):
		return
	_pcts[bus].text = _fmt_pct(value)
	_sucios[bus] = true
	if _timer_commit:
		_timer_commit.start()


func _on_drag_ended(_cambiado: bool, _bus: String) -> void:
	# Suelte del grabber: commit inmediato del valor final (y de cualquier otro
	# bus pendiente). Sin debounce: una sola escritura por gesto.
	if _timer_commit:
		_timer_commit.stop()
	commit_pendiente()


func _on_mute_toggled(pressed: bool, bus: String) -> void:
	if _ac:
		_ac.set_mute(bus, pressed)


func _on_rango_sel(idx: int) -> void:
	var rangos := DynamicRangeManager.RANGOS
	if idx < 0 or idx >= rangos.size():
		return
	aplicar_opcion("rango_dinamico", String(rangos[idx]))


func _on_compresion_toggled(pressed: bool) -> void:
	aplicar_opcion("compresion", pressed)


func _on_dispositivo_sel(idx: int) -> void:
	var devs := OutputDeviceManager.dispositivos()
	if idx < 0 or idx >= devs.size():
		return
	aplicar_opcion("dispositivo_salida", String(devs[idx]))


## Aplica una opción vía AudioConfig con feedback si devuelve false.
## PÚBLICA: es el punto de test del camino de fallo.
func aplicar_opcion(clave: String, valor: Variant) -> bool:
	if _ac == null:
		return false
	var ok: bool = _ac.set_opcion(clave, valor)
	if ok:
		_ocultar_fallo()
	else:
		_mostrar_fallo()
		_sincronizar_opciones()
	return ok


## Aplica en AudioConfig los volúmenes marcados como pendientes.
## PÚBLICA: la llaman drag_ended, el timer, close() y el test headless.
func commit_pendiente() -> bool:
	var todo_ok := true
	for bus in _sucios.keys():
		if bool(_sucios[bus]):
			if not commit_volumen(bus):
				todo_ok = false
	return todo_ok


## Commitea un bus concreto (no-op si no estaba pendiente).
func commit_volumen(bus: String) -> bool:
	if _ac == null or not _sliders.has(bus):
		return false
	if not bool(_sucios.get(bus, false)):
		return true
	var ok: bool = _ac.set_volumen_porcentaje(bus, float(_sliders[bus].value))
	if ok:
		_sucios[bus] = false
		_ocultar_fallo()
	else:
		_mostrar_fallo()
		_sincronizar_volumen(bus)
	return ok


func _on_volver() -> void:
	commit_pendiente()
	close()


## ── Handlers: AudioConfig -> widgets (reverse, sin bucle) ─

func _on_ac_volumen(bus: String, vol: float) -> void:
	if not _sliders.has(bus):
		return
	# set_value SÍ emite con el control en el árbol -> sin sufijo no_signal
	# cerraríamos el bucle volumen_cambiado -> slider -> set_volumen -> señal...
	_sliders[bus].set_value_no_signal(clampf(vol, 0.0, 1.0) * 100.0)
	_pcts[bus].text = _fmt_pct(clampf(vol, 0.0, 1.0) * 100.0)
	# El valor ya está persistido por quien lo cambió (incluido nuestro commit)
	_sucios[bus] = false


func _on_ac_mute(bus: String, mute: bool) -> void:
	if _mutes.has(bus):
		_mutes[bus].set_pressed_no_signal(mute)


func _on_ac_opcion(clave: String, valor: Variant) -> void:
	match clave:
		"rango_dinamico":
			if _opt_rango:
				var idx := DynamicRangeManager.RANGOS.find(String(valor))
				if idx >= 0:
					_opt_rango.select(idx)  # select() no emite item_selected
		"compresion":
			if _chk_compresion:
				_chk_compresion.set_pressed_no_signal(bool(valor))
		"dispositivo_salida":
			if _opt_dispositivo:
				var di := OutputDeviceManager.dispositivos().find(String(valor))
				if di >= 0:
					_opt_dispositivo.select(di)


## ── Sincronización (estado real -> widgets) ───────────────

func _sincronizar_todo() -> void:
	if _ac == null:
		return
	for bus in BUSES_SECCION:
		_sincronizar_volumen(bus)
		if _mutes.has(bus):
			_mutes[bus].set_pressed_no_signal(_ac.esta_muteado(bus))
	_sincronizar_opciones()


func _sincronizar_volumen(bus: String) -> void:
	if _ac == null or not _sliders.has(bus):
		return
	var pct: float = float(_ac.get_volumen_porcentaje(bus))
	_sliders[bus].set_value_no_signal(pct)
	_pcts[bus].text = _fmt_pct(pct)
	_sucios[bus] = false


func _sincronizar_opciones() -> void:
	if _ac == null:
		return
	if _opt_rango:
		var rango := String(_ac.get_opcion("rango_dinamico", DynamicRangeManager.actual()))
		var idx := DynamicRangeManager.RANGOS.find(rango)
		if idx >= 0:
			_opt_rango.select(idx)
	if _chk_compresion:
		var comp := bool(_ac.get_opcion("compresion", CompressionManager.activa()))
		_chk_compresion.set_pressed_no_signal(comp)
	if _opt_dispositivo:
		var devs := OutputDeviceManager.dispositivos()
		var disp := String(_ac.get_opcion("dispositivo_salida", OutputDeviceManager.actual()))
		var di := devs.find(disp)
		if di >= 0:
			_opt_dispositivo.select(di)


func _mostrar_fallo() -> void:
	if _lbl_fallo:
		_lbl_fallo.text = _t("SETTINGS.AUDIO_FALLA")
		_lbl_fallo.visible = true


func _ocultar_fallo() -> void:
	if _lbl_fallo:
		_lbl_fallo.visible = false


## ── UILayer virtual ───────────────────────────────────────

func on_layer_opened() -> void:
	# Re-registrar por si un Esc (close_top) des-registró la capa:
	# register_layer es idempotente (no-op si ya está en la pila).
	var um := _get_ui_manager()
	if um and um.has_method("register_layer"):
		um.register_layer(self)
	_conectar_audio()
	_sincronizar_todo()


func on_layer_closed() -> void:
	commit_pendiente()
	if _timer_commit:
		_timer_commit.stop()
	_desconectar_audio()
	visible = false


func focus_first() -> Control:
	return _primer_control


func _conectar_audio() -> void:
	if _ac == null or _conectado:
		return
	_ac.volumen_cambiado.connect(_on_ac_volumen)
	_ac.mute_cambiado.connect(_on_ac_mute)
	_ac.opcion_cambiada.connect(_on_ac_opcion)
	_conectado = true


func _desconectar_audio() -> void:
	if _ac == null or not _conectado:
		return
	if _ac.volumen_cambiado.is_connected(_on_ac_volumen):
		_ac.volumen_cambiado.disconnect(_on_ac_volumen)
	if _ac.mute_cambiado.is_connected(_on_ac_mute):
		_ac.mute_cambiado.disconnect(_on_ac_mute)
	if _ac.opcion_cambiada.is_connected(_on_ac_opcion):
		_ac.opcion_cambiada.disconnect(_on_ac_opcion)
	_conectado = false


## ── Utilidades ────────────────────────────────────────────

static func _fmt_pct(v: float) -> String:
	return "%d%%" % roundi(clampf(v, 0.0, 100.0))


func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave
