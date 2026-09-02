# Modelo: ox-alpha (GLM) · iter. 2: glm-5.3
# Plataforma: Cline
# Fecha: 2026-08-26 · iter. 2: 2026-08-31
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
# Iter. 2 (glm-5.3/Cline):
#  - D70: desplegable al pasar el cursor — tooltip contextual vía TooltipService
#    (M53), detectado por rect del cursor (NO captura el mouse: D78 se mantiene).
#  - F100/F107: config data-driven data/ui/w_reloj.tres con fallback a defaults.
#  - F101: formato 12h/24h real desde el config (RelojHud.formatear_hora puro).
extends PanelContainer

const RelojHudScript := preload("res://scripts/clock/reloj_hud.gd")
const RUTA_CONFIG := "res://data/ui/w_reloj.tres"

## Preview/demo: simula el cursor dentro del widget (D70) sin mouse real.
@export var demo_cursor_dentro: bool = false
## Config inyectable para tests/preview: si es WRelojConfig al entrar al árbol,
## reemplaza al recurso en disco (los tests no tocan data/).
var config_inyectada = null
## Ruta del recurso de config (replicable en tests para probar el fallback F107).
var ruta_config: String = RUTA_CONFIG

var _config: WRelojConfig = null   # data/ui/w_reloj.tres (F100) · defaults (F107)
var _reloj: Node = null            # instancia o autoload RelojHud
var _game_time: Node = null        # autoload GameTime (si existe)
var _tooltip_svc: CanvasLayer = null  # autoload TooltipService (M53)
var _hover_activo: bool = false    # D70: cursor dentro del rect del reloj
var _lbl_hora: Label = null
var _lbl_fecha: Label = null
var _fila_chip: HBoxContainer = null
var _chip_estacion: PanelContainer = null
var _lbl_estacion: Label = null

func _ready() -> void:
	_config = _cargar_config()  # F100: data-driven · F107: fallback a defaults
	_reloj = get_node_or_null("/root/RelojHud")
	if _reloj == null:
		_reloj = RelojHudScript.new()  # fallback para preview standalone
	_game_time = get_node_or_null("/root/GameTime")
	_tooltip_svc = get_node_or_null("/root/TooltipService")
	_construir_ui()
	_refrescar()
	set_process(true)  # D70: detección de hover por rect del cursor
	# Suscripción por señales (design doc §2: tick sin polling)
	if _game_time != null:
		_game_time.minuto_cambio.connect(_on_minuto_cambio)
		_game_time.hora_cambio.connect(_on_hora_cambio)
		_game_time.dia_cambio.connect(_on_dia_cambio)
		_game_time.estacion_cambio.connect(_on_estacion_cambio)

func _exit_tree() -> void:
	# D70: nunca dejar un tooltip huérfano al salir del árbol.
	if _hover_activo and _tooltip_svc != null and _tooltip_svc.has_method("hide_tooltip"):
		_tooltip_svc.hide_tooltip()
		_hover_activo = false
	if _game_time != null:
		if _game_time.minuto_cambio.is_connected(_on_minuto_cambio):
			_game_time.minuto_cambio.disconnect(_on_minuto_cambio)
		if _game_time.hora_cambio.is_connected(_on_hora_cambio):
			_game_time.hora_cambio.disconnect(_on_hora_cambio)
		if _game_time.dia_cambio.is_connected(_on_dia_cambio):
			_game_time.dia_cambio.disconnect(_on_dia_cambio)
		if _game_time.estacion_cambio.is_connected(_on_estacion_cambio):
			_game_time.estacion_cambio.disconnect(_on_estacion_cambio)

## ── Construcción de UI ────────────────────────────────────────────────────────
func _construir_ui() -> void:
	# El HUD nunca debe bloquear input del juego
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Anclado arriba-derecha del contenedor padre.
	# FIX (2026-08-26 v2): la manipulación manual de offsets (offset_left/top/right)
	# con set_anchors_preset producía un rect degenerado (altura -16 px) y, con
	# escalado DPI 125 %, recorte del panel. La API canónica es
	# set_anchors_and_offsets_preset con PRESET_MODE_MINSIZE + margen: posiciona
	# por tamaño mínimo y sigue el borde derecho en cualquier resize/escala.
	custom_minimum_size = Vector2(_config.ancho_min, 0)
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, _config.margen_borde)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	grow_vertical = Control.GROW_DIRECTION_END

	# Fondo semitransparente oscuro, esquinas redondeadas (estilo cozy)
	var style := StyleBoxFlat.new()
	style.bg_color = _config.color_fondo
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
	_fila_chip = fila_chip
	fila_chip.visible = _config.mostrar_chip_estacion

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
## F101: el formato 12h/24h viene del config (lo escribirá Ajustes M46).
func _hora_visual() -> String:
	if _game_time != null:
		var fmt: int = RelojHudScript.FormatoHora.HORAS_12 if _config.usar_formato_12h \
			else RelojHudScript.FormatoHora.HORAS_24
		return RelojHudScript.formatear_hora(_game_time.get_hora(), _game_time.get_minuto(), fmt)
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
	# M30 iter. 3 (glm-5.3-flash): nombres localizables por clave (M87) —
	# CLOCK.ESTACIONES.0..3 en los .po; fallback al hardcode del núcleo si
	# Localization no está disponible (headless).
	var loc := get_node_or_null("/root/Localization")
	if loc != null and loc.has_method("tr_key"):
		var traducido := String(loc.tr_key("clock", "estaciones", str(clampi(est, 0, 3))))
		if traducido != "" and not traducido.begins_with("CLOCK."):
			return traducido
	var NOMBRES := ["Primavera", "Verano", "Otoño", "Invierno"]
	return NOMBRES[clampi(est, 0, 3)]

## ── Handlers de señales GameTime (M29) ───────────────────────────────────────
func _on_minuto_cambio(_m: int) -> void:
	_refrescar()

func _on_hora_cambio(_h: int) -> void:
	_refrescar()

func _on_dia_cambio(_info: Dictionary) -> void:
	_refrescar()

func _on_estacion_cambio(_e: int) -> void:
	_refrescar()

## ── Config (F100/F107) ───────────────────────────────────────────────────────
## Carga data/ui/w_reloj.tres (WRelojConfig); si falta o está corrupto cae a
## defaults (F107). config_inyectada permite a tests/preview instanciar con una
## config propia sin tocar el recurso en disco.
func _cargar_config() -> WRelojConfig:
	if config_inyectada is WRelojConfig:
		return config_inyectada
	var cfg: WRelojConfig = load(ruta_config) as WRelojConfig
	if cfg == null:
		push_warning("M30: config '%s' ausente o corrupta; usando defaults (F107)." % ruta_config)
		cfg = WRelojConfig.new()
	return cfg

## ── Hover/desplegable D70 — tooltip contextual vía TooltipService (M53) ───────
## El panel NO captura el mouse (D78: MOUSE_FILTER_IGNORE se mantiene, el HUD
## nunca bloquea clicks del juego): el hover se detecta comparando el rect global
## del widget con la posición del cursor en cada frame (1 has_point, despreciable).
## El desplegable muestra el "detalle": fecha, sesión del día, estación y
## próximos eventos (todo desde GameTime M29 — nunca desde el reloj del SO).
func _process(_delta: float) -> void:
	var pos := get_global_mouse_position()
	if demo_cursor_dentro:
		pos = get_global_rect().get_center()
	_actualizar_hover(pos)

## Testeable: recibe la posición del cursor y decide mostrar/ocultar el tooltip.
func _actualizar_hover(pos_cursor: Vector2) -> void:
	if _tooltip_svc == null or not is_inside_tree():
		return
	var dentro: bool = is_visible_in_tree() and get_global_rect().has_point(pos_cursor)
	if dentro and not _hover_activo:
		_hover_activo = true
		if _tooltip_svc.has_method("show_tooltip"):
			_tooltip_svc.show_tooltip(_texto_tooltip(), self)
	elif not dentro and _hover_activo:
		_hover_activo = false
		if _tooltip_svc.has_method("hide_tooltip"):
			_tooltip_svc.hide_tooltip()

## Contenido del desplegable: formato M88 de TooltipService ("Título|Cuerpo").
## Título localizable cuando existan claves M57; por ahora texto directo.
func _texto_tooltip() -> String:
	var cuerpo := _fecha_visual()
	if _game_time != null:
		var sesion: int = RelojHudScript.get_sesion_dia_estatico(_game_time.get_hora())
		var nombre_sesion := ["Mañana", "Día", "Tarde", "Noche"]
		cuerpo += "\nSesión: %s" % nombre_sesion[sesion]
		cuerpo += "\nEstación: %s" % _estacion_nombre(_estacion_actual())
		var proximos: Array = _game_time.proximos_eventos(2)
		if not proximos.is_empty():
			var dias: Array = []
			for ev in proximos:
				dias.append("día %d" % int(ev.get("dia", 0)))
			cuerpo += "\nPróximos eventos: %s" % ", ".join(PackedStringArray(dias))
	else:
		cuerpo += "\n(Sin GameTime: modo preview)"
	return "Fecha y hora|%s" % cuerpo
