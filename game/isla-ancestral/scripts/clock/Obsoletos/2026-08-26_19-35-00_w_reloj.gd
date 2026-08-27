# Modelo: ox-alpha (GLM)
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M30.2: Widget de Reloj (HUD) — Control puro, consumidor de RelojHud + GameTime.
# Diseño según DOCUMENTACION/30 plan-actual 03-Diseno.md §2:
#  - Posición: superior derecha del HUD
#  - Hora "HH:MM" grande (formato de RelojHud, default 24h)
#  - Fecha "Lunes, 12 de Primavera, Año 1"
#  - Chip de estación con color suave de la paleta COLOR_ESTACION
#  - Tick por señales (hora_cambio/dia_cambio/estacion_cambio), NUNCA polling
# Fallback: si no hay GameTime (preview standalone / test), muestra valores mock
# marcados con "~" para no confundir con datos reales.
extends PanelContainer

const RelojHudScript := preload("res://scripts/clock/reloj_hud.gd")

var _reloj: Node = null            # instancia o autoload RelojHud
var _game_time: Node = null        # autoload GameTime (si existe)
var _lbl_hora: Label = null
var _lbl_fecha: Label = null
var _chip_estacion: PanelContainer = null
var _lbl_estacion: Label = null

func _ready() -> void:
	_reloj = get_node_or_null("/root/RelojHud")
	if _reloj == null:
		_reloj = RelojHudScript.new()  # fallback para preview standalone
	_game_time = get_node_or_null("/root/GameTime")
	_construir_ui()
	_refrescar()
	# Suscripción por señales (design doc §2: tick sin polling)
	if _game_time != null:
		_game_time.hora_cambio.connect(_on_hora_cambio)
		_game_time.dia_cambio.connect(_on_dia_cambio)
		_game_time.estacion_cambio.connect(_on_estacion_cambio)

func _exit_tree() -> void:
	if _game_time != null:
		if _game_time.hora_cambio.is_connected(_on_hora_cambio):
			_game_time.hora_cambio.disconnect(_on_hora_cambio)
		if _game_time.dia_cambio.is_connected(_on_dia_cambio):
			_game_time.dia_cambio.disconnect(_on_dia_cambio)
		if _game_time.estacion_cambio.is_connected(_on_estacion_cambio):
			_game_time.estacion_cambio.disconnect(_on_estacion_cambio)

## ── Construcción de UI ────────────────────────────────────────────────────────
func _construir_ui() -> void:
	custom_minimum_size = Vector2(230, 0)
	# El HUD nunca debe bloquear input del juego
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Anclado arriba-derecha del contenedor padre
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	offset_left = -260.0
	offset_top = 16.0
	offset_right = -16.0
	grow_horizontal = Control.GROW_DIRECTION_BEGIN

	# Fondo semitransparente oscuro, esquinas redondeadas (estilo cozy)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.12, 0.78)
	style.set_corner_radius_all(14)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 12
	add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)

	_lbl_hora = Label.new()
	_lbl_hora.name = "Hora"
	_lbl_hora.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_hora.add_theme_font_size_override("font_size", 34)
	_lbl_hora.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88))
	vbox.add_child(_lbl_hora)

	_lbl_fecha = Label.new()
	_lbl_fecha.name = "Fecha"
	_lbl_fecha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_fecha.add_theme_font_size_override("font_size", 14)
	_lbl_fecha.add_theme_color_override("font_color", Color(0.85, 0.83, 0.76))
	vbox.add_child(_lbl_fecha)

	# Chip de estación: mini panel coloreado + nombre
	_chip_estacion = PanelContainer.new()
	var chip_style := StyleBoxFlat.new()
	chip_style.bg_color = Color(0.40, 0.85, 0.40, 0.35)
	chip_style.set_corner_radius_all(9)
	chip_style.content_margin_left = 10
	chip_style.content_margin_right = 10
	chip_style.content_margin_top = 3
	chip_style.content_margin_bottom = 3
	_chip_estacion.add_theme_stylebox_override("panel", chip_style)

	var chip_center := CenterContainer.new()
	_lbl_estacion = Label.new()
	_lbl_estacion.add_theme_font_size_override("font_size", 13)
	_lbl_estacion.add_theme_color_override("font_color", Color(0.95, 0.97, 0.92))
	chip_center.add_child(_lbl_estacion)
	_chip_estacion.add_child(chip_center)

	var fila_chip := HBoxContainer.new()
	fila_chip.alignment = BoxContainer.ALIGNMENT_CENTER
	fila_chip.add_child(_chip_estacion)
	vbox.add_child(fila_chip)

## ── Refresco ────────────────────────────────────────────────────────────────
func _refrescar() -> void:
	# Hora: usa el formato configurado del RelojHud
	_lbl_hora.text = _hora_visual()
	_lbl_fecha.text = _fecha_visual()
	var est := _estacion_actual()
	var color: Color = RelojHudScript.get_color_estacion_estatico(est)
	_lbl_estacion.text = _estacion_nombre(est)
	var chip_style: StyleBoxFlat = _chip_estacion.get_theme_stylebox("panel")
	chip_style.bg_color = Color(color.r, color.g, color.b, 0.32)

## Si hay GameTime real muestra la hora viva; si no, un mock visible.
func _hora_visual() -> String:
	if _game_time != null:
		return "%02d:%02d" % [_game_time.get_hora(), _game_time.get_minuto()]
	return "~09:15"

func _fecha_visual() -> String:
	if _game_time != null and _reloj.has_method("get_fecha_str"):
		var s: String = _reloj.get_fecha_str()
		if s != "":
			return s
	return "~Lunes, 12 de Primavera, Año 1"

func _estacion_actual() -> int:
	if _game_time != null:
		return clampi(int(_game_time.get_estacion()), 0, 3)
	return 0

func _estacion_nombre(est: int) -> String:
	var NOMBRES := ["Primavera", "Verano", "Otoño", "Invierno"]
	return NOMBRES[clampi(est, 0, 3)]

## ── Handlers de señales GameTime (M29) ───────────────────────────────────────
func _on_hora_cambio(_h: int) -> void:
	_refrescar()

func _on_dia_cambio(_info: Dictionary) -> void:
	_refrescar()

func _on_estacion_cambio(_e: int) -> void:
	_refrescar()
