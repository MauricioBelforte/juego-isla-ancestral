# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-02
#
# M131: CreditsLayer — pantalla de créditos (MODAL_FULL).
# UI construida en runtime (patrón de scripts/ui/layers/: sin .tscn, §9.47).
# Consume el autoload credits_manager (catálogo data-driven data/legal/creditos.json).
#
# Cubre la Sección D del 05-Checklist (10/10) + C38 (contador de tiempo):
#   D1 RichTextLabel con desplazamiento suave      D6 conmutación de idioma en caliente
#   D2 botón detener/continuar animación           D7 copyright con año auto-dinámico
#   D3 tamaño de texto S/M/L                       D8 diseño cozy (ThemeUx)
#   D4 modo alto contraste opcional                D9 tiempo máximo 5 minutos
#   D5 velocidad Normal/Lenta/Rápida               D10 navegación por teclado
#
# Se abre con open() (NO push_layer): las capas montadas por UIRoot ya están
# registradas y push_layer es no-op para ellas (ui_manager.gd L457-459).

class_name CreditsLayer
extends UILayer

## Duración máxima de visualización (D9 / J103)
const MAX_SEGUNDOS := 300.0
## Tamaños de texto: S / M / L (D3)
const TAMANOS: Array[int] = [12, 16, 20]
const NOM_TAMANOS: Array[String] = ["S", "M", "L"]
## Desplazamiento en px/s: Normal / Lenta / Rápida (D5)
const VELOCIDADES: Array[float] = [42.0, 16.0, 95.0]
const NOM_VELOCIDADES: Array[String] = ["Normal", "Lenta", "Rápida"]
## Velocidad del salto suave entre secciones (C37 transición suave)
const VELOC_SALTO := 1100.0

var _manager: Node = null
var _bg: ColorRect
var _rich: RichTextLabel
var _btn_anim: Button
var _btn_tam: Button
var _btn_vel: Button
var _btn_contraste: Button
var _btn_idioma: Button
var _btn_cerrar: Button
var _lbl_copy: Label
var _lbl_reloj: Label
var _lbl_seccion: Label
var _lbl_farewell: Label
var _buttons: Array[Button] = []

var _animando: bool = true
var _fin_alcanzado: bool = false
var _reloj: float = 0.0
var _tamanio_idx: int = 1
var _velocidad_idx: int = 0
var _contraste: bool = false
var _seccion_actual: int = 0
var _lineas_seccion: Array[int] = []
var _offs_seccion: Array[float] = []
var _offs_listos: bool = false
var _scroll_objetivo: float = -1.0
var _foco_previo: Control = null


func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_FULL
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_manager = get_node_or_null("/root/credits_manager")
	_crear_ui()
	_reconstruir_texto()
	_aplicar_estilo()
	_actualizar_etiquetas()
	visible = false


func _crear_ui() -> void:
	_bg = ColorRect.new()
	_bg.color = ThemeUx.COLOR_BG_ARENA
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg.name = "Fondo"
	add_child(_bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	# ── Cabecera: título + copyright (D7) ────────────────────
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	vbox.add_child(header)

	var titulo := Label.new()
	titulo.name = "Titulo"
	titulo.text = _tl("SETTINGS.CREDITOS", "Créditos")
	titulo.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H1)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titulo)

	_lbl_copy = Label.new()
	_lbl_copy.name = "Copyright"
	_lbl_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_copy.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lbl_copy.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	_lbl_copy.add_theme_color_override("font_color", ThemeUx.COLOR_ACCENT_OCRE)
	header.add_child(_lbl_copy)

	vbox.add_child(HSeparator.new())

	# ── Bloque de texto (D1) ─────────────────────────────────
	_rich = RichTextLabel.new()
	_rich.name = "CreditosTexto"
	_rich.bbcode_enabled = true
	_rich.scroll_active = true
	_rich.fit_content = false
	_rich.autowrap_mode = TextServer.AUTOWRAP_OFF
	_rich.focus_mode = Control.FOCUS_NONE
	_rich.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rich.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rich.selection_enabled = false
	vbox.add_child(_rich)

	vbox.add_child(HSeparator.new())

	# ── Controles (D2..D6, D10) ──────────────────────────────
	var controles := HBoxContainer.new()
	controles.name = "Controles"
	controles.add_theme_constant_override("separation", 8)
	vbox.add_child(controles)

	_btn_anim = _agregar_boton(controles, "", _alternar_anim)
	_btn_tam = _agregar_boton(controles, "", _ciclar_tamanio)
	_btn_vel = _agregar_boton(controles, "", _ciclar_velocidad)
	_btn_contraste = _agregar_boton(controles, "", _alternar_contraste)
	_btn_idioma = _agregar_boton(controles, "", _alternar_idioma)
	_btn_cerrar = _agregar_boton(controles, _tl("SETTINGS.CERRAR", "Cerrar"), cerrar)

	# ── Barra de estado: contador (C38), sección, despedida ──
	var estado := HBoxContainer.new()
	estado.name = "Estado"
	estado.add_theme_constant_override("separation", 16)
	vbox.add_child(estado)

	_lbl_reloj = Label.new()
	_lbl_reloj.name = "Contador"
	_lbl_reloj.text = "00:00"
	_lbl_reloj.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	_lbl_reloj.tooltip_text = "Tiempo de visualización"
	estado.add_child(_lbl_reloj)

	_lbl_seccion = Label.new()
	_lbl_seccion.name = "SeccionActual"
	_lbl_seccion.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	_lbl_seccion.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	estado.add_child(_lbl_seccion)

	_lbl_farewell = Label.new()
	_lbl_farewell.name = "Despedida"
	_lbl_farewell.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_farewell.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H3)
	_lbl_farewell.add_theme_color_override("font_color", ThemeUx.COLOR_ACCENT_OCRE)
	_lbl_farewell.visible = false
	estado.add_child(_lbl_farewell)


# ── Acciones de los controles ───────────────────────────────

func _alternar_anim() -> void:
	if _fin_alcanzado:
		return
	_animando = not _animando
	_scroll_objetivo = -1.0
	_actualizar_etiquetas()


func _ciclar_tamanio() -> void:
	_tamanio_idx = (_tamanio_idx + 1) % TAMANOS.size()
	_aplicar_tamanio()
	_actualizar_etiquetas()


func _ciclar_velocidad() -> void:
	_velocidad_idx = (_velocidad_idx + 1) % VELOCIDADES.size()
	_actualizar_etiquetas()


func _alternar_contraste() -> void:
	_contraste = not _contraste
	_aplicar_estilo()
	_actualizar_etiquetas()


func _alternar_idioma() -> void:
	if _manager == null:
		return
	var actual := String(_manager.obtener_idioma())
	var nuevo := "en" if actual == "es" else "es"
	if _manager.has_method("cambiar_idioma"):
		_manager.cambiar_idioma(nuevo)
	_reconstruir_texto()
	_actualizar_etiquetas()


func cerrar() -> void:
	var ui = _get_ui_manager()
	if ui and ui.has_method("close_top"):
		# cierra el tope sólo si el tope somos nosotros
		if ui.has_method("top") and ui.top() == self:
			ui.close_top()
			return
	close()


# ── Contenido ───────────────────────────────────────────────

func _reconstruir_texto() -> void:
	_offs_listos = false
	_offs_seccion.clear()
	_lineas_seccion.clear()
	if _manager == null:
		if _rich:
			_rich.text = "[center](catálogo de créditos no disponible)[/center]"
		return
	var out := ""
	var n: int = int(_manager.cantidad_secciones())
	for i in n:
		_lineas_seccion.append(out.count("\n"))
		var sec: Dictionary = _manager.obtener_seccion(i)
		var titulo: String = String(sec.get("titulo", ""))
		out += "[center][b][color=#8A6A2F]%s[/color][/b][/center]\n" % _escapar(titulo)
		for entrada in sec.get("entradas", []):
			out += "[center]%s[/center]\n" % _escapar(String(entrada))
		out += "\n"
	if _manager.has_method("obtener_farewell"):
		out += "[center][i]%s[/i][/center]\n" % _escapar(String(_manager.obtener_farewell()))
	_rich.text = out


func _escapar(texto: String) -> String:
	return texto.replace("[", "[lb]")


# ── Estilo (D4 alto contraste, D8 cozy) ─────────────────────

func _aplicar_estilo() -> void:
	if _rich == null:
		return
	var fondo: Color
	if _contraste:
		fondo = Color(0.0, 0.0, 0.0)
	else:
		fondo = ThemeUx.COLOR_BG_ARENA
	_bg.color = fondo
	# El color de texto lo decide credits_manager (RF7 / M58)
	var texto := ThemeUx.COLOR_TEXT_DARK
	if _manager and _manager.has_method("color_contraste_accesible"):
		texto = _manager.color_contraste_accesible(fondo)
	_rich.add_theme_color_override("default_color", texto)
	_rich.add_theme_color_override("bold_color", ThemeUx.COLOR_ACCENT_OCRE if not _contraste else Color(1.0, 0.85, 0.4))
	_rich.add_theme_color_override("italics_color", texto)
	_aplicar_tamanio()


func _aplicar_tamanio() -> void:
	if _rich == null:
		return
	# S(12) / M(16) / L(20) — el M(16) coincide con tamano_fuente_base(1.0)
	var px: int = TAMANOS[_tamanio_idx]
	_rich.add_theme_font_size_override("normal_font_size", px)
	_rich.add_theme_font_size_override("bold_font_size", px)
	_rich.add_theme_font_size_override("italics_font_size", px)


# ── Etiquetas dinámicas ─────────────────────────────────────

func _actualizar_etiquetas() -> void:
	if _lbl_copy and _manager:
		_lbl_copy.text = String(_manager.obtener_copyright())
	if _btn_anim:
		_btn_anim.text = _tl("SETTINGS.PAUSA", "Pausar") if _animando else _tl("SETTINGS.CONTINUAR", "Continuar")
		_btn_anim.tooltip_text = "Detener o reanudar el desplazamiento automático"
	if _btn_tam:
		_btn_tam.text = "Tamaño: %s" % NOM_TAMANOS[_tamanio_idx]
		_btn_tam.tooltip_text = "Tamaño de letra (S / M / L)"
	if _btn_vel:
		_btn_vel.text = "Velocidad: %s" % NOM_VELOCIDADES[_velocidad_idx]
		_btn_vel.tooltip_text = "Velocidad del desplazamiento"
	if _btn_contraste:
		_btn_contraste.text = "Contraste: %s" % ("Alto" if _contraste else "Normal")
		_btn_contraste.tooltip_text = "Modo de alto contraste"
	if _btn_idioma:
		var idio := "es"
		if _manager:
			idio = String(_manager.obtener_idioma())
		_btn_idioma.text = "Idioma: %s" % idio.to_upper()
		_btn_idioma.tooltip_text = "Cambiar idioma de los créditos"
	if _btn_cerrar:
		_btn_cerrar.tooltip_text = "Cerrar créditos (ESC)"
	_actualizar_lbl_seccion()


func _actualizar_lbl_seccion() -> void:
	if _lbl_seccion == null:
		return
	var txt := ""
	if _manager and _seccion_actual < _lineas_seccion.size() and _seccion_actual < int(_manager.cantidad_secciones()):
		txt = String(_manager.obtener_seccion(_seccion_actual).get("titulo", ""))
	_lbl_seccion.text = txt


# ── Proceso: desplazamiento + contador + tiempo máximo ──────

func _process(delta: float) -> void:
	if not visible:
		return
	if _reloj < MAX_SEGUNDOS:
		_reloj += delta
		if _lbl_reloj:
			_lbl_reloj.text = "%02d:%02d" % [int(_reloj) / 60, int(_reloj) % 60]
		if _reloj >= MAX_SEGUNDOS:
			_fin()
	if _rich == null:
		return
	var bar: VScrollBar = _rich.get_v_scroll_bar()
	if bar == null:
		return
	_cachear_offsets()
	var tope := maxf(0.0, bar.max_value - bar.page)
	if _scroll_objetivo >= 0.0:
		var d := _scroll_objetivo - bar.value
		if absf(d) < 1.0:
			bar.value = _scroll_objetivo
			_scroll_objetivo = -1.0
		else:
			bar.value = bar.value + signf(d) * minf(absf(d), VELOC_SALTO * delta)
	elif _animando and not _fin_alcanzado and tope > 0.0:
		bar.value = minf(bar.value + VELOCIDADES[_velocidad_idx] * delta, tope)
		if bar.value >= tope - 0.5:
			_fin()
	_sincronizar_seccion()


func _cachear_offsets() -> void:
	if _offs_listos or _lineas_seccion.is_empty():
		return
	if _rich.get_line_count() <= 0:
		return
	_offs_seccion.clear()
	for l in _lineas_seccion:
		_offs_seccion.append(float(_rich.get_line_offset(l)))
	_offs_listos = true


func _sincronizar_seccion() -> void:
	if _offs_seccion.is_empty() or _lbl_seccion == null:
		return
	var y := 0.0
	var bar: VScrollBar = _rich.get_v_scroll_bar()
	if bar:
		y = bar.value
	var idx := 0
	for i in _offs_seccion.size():
		if _offs_seccion[i] <= y + 12.0:
			idx = i
	if idx != _seccion_actual:
		_seccion_actual = idx
		_actualizar_lbl_seccion()
		if _manager and _manager.has_method("ir_a_seccion"):
			_manager.ir_a_seccion(idx)


func _fin() -> void:
	if _fin_alcanzado:
		return
	_fin_alcanzado = true
	_animando = false
	_scroll_objetivo = -1.0
	if _manager and _manager.has_method("obtener_farewell") and _lbl_farewell:
		_lbl_farewell.text = String(_manager.obtener_farewell())
		_lbl_farewell.visible = true
	_actualizar_etiquetas()


# ── Navegación por teclado (D10) ────────────────────────────

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		var k: int = event.keycode
		if k == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			close()
		elif k == KEY_PAGEUP:
			get_viewport().set_input_as_handled()
			_saltar_seccion(-1)
		elif k == KEY_PAGEDOWN:
			get_viewport().set_input_as_handled()
			_saltar_seccion(1)


func _saltar_seccion(dir: int) -> void:
	var n := _lineas_seccion.size()
	if n == 0:
		return
	_seccion_actual = clampi(_seccion_actual + dir, 0, n - 1)
	if _manager and _manager.has_method("ir_a_seccion"):
		_manager.ir_a_seccion(_seccion_actual)
	_actualizar_lbl_seccion()
	if _offs_listos and _seccion_actual < _offs_seccion.size():
		_scroll_objetivo = _offs_seccion[_seccion_actual]
	elif _seccion_actual < _lineas_seccion.size():
		_scroll_objetivo = float(_rich.get_line_offset(_lineas_seccion[_seccion_actual]))


# ── UILayer virtual ─────────────────────────────────────────

func on_layer_opened() -> void:
	var vp := get_viewport()
	if vp:
		_foco_previo = vp.gui_get_focus_owner()
	_reloj = 0.0
	_fin_alcanzado = false
	_animando = true
	_scroll_objetivo = -1.0
	_seccion_actual = 0
	_reconstruir_texto()
	_aplicar_estilo()
	_actualizar_etiquetas()
	if _lbl_farewell:
		_lbl_farewell.visible = false
	if _lbl_reloj:
		_lbl_reloj.text = "00:00"
	if _rich:
		var bar: VScrollBar = _rich.get_v_scroll_bar()
		if bar:
			bar.value = 0.0
	if _btn_cerrar:
		_btn_cerrar.grab_focus()


func on_layer_closed() -> void:
	_animando = false
	_scroll_objetivo = -1.0
	var f := _foco_previo
	_foco_previo = null
	visible = false
	if f and is_instance_valid(f) and f is Control and f.is_inside_tree():
		f.grab_focus()


func focus_first() -> Control:
	if _buttons.size() > 0:
		return _buttons[0]
	return null


# ── Helpers ─────────────────────────────────────────────────

func _agregar_boton(parent: Container, texto: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = texto
	btn.pressed.connect(cb)
	parent.add_child(btn)
	_buttons.append(btn)
	return btn


func _tl(clave: String, defecto: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return defecto
