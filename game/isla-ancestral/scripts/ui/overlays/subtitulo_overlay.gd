# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-20
#
# M53 D.7/J.6 (iter. agnes, Log 1118) — Overlay de subtítulos de diálogo
# controlado por M58 (RF8: subtítulos activado/tamaño/fondo).
#
# El M58 lo gobierna (AccesibilityManager autoload, scripts/accesibilidad/):
#   - get_subtitulos() -> {"activado": bool, "tamano": "pequeno|mediano|grande", "fondo": bool}
#   - señal subtitulos_changed(activado, tamano, fondo)
# Si M58 no está montado, usa los defaults de RF8 (on/mediano/fondo), que es
# la configuración por defecto del perfil "default" de M58.
#
# Límite honesto (J.6): M58 RF8 no expisa "opacidad" → el fondo usa 0.45
# fijo; si M58 agrega el campo, se conecta aquí (ver 05-Checklist M53 §QA).

class_name SubtituloOverlay
extends Control

## Mapeo tamaño M58 -> px (decisión visual registrada en Log 1118:
## se alinean a la jerarquía ThemeUx: SMALL=12 / BODY=16 / H3=20).
const TAMAÑOS_PX := {"pequeno": 14, "mediano": 18, "grande": 24}
const FONDO_COLOR := Color(0.08, 0.06, 0.05, 0.45)
const DEFAULT_RF8 := {"activado": true, "tamano": "mediano", "fondo": true}

var _panel: PanelContainer
var _label: Label
var _fondo_visible: bool = true

func _ready() -> void:
	_crear_ui()
	_aplicar_estado(_leer_m58())
	_conectar_m58()
	visible = false

func _crear_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_panel = PanelContainer.new()
	_panel.name = "SubtituloPanel"
	_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_panel.position = Vector2(-160, -64)
	_panel.size = Vector2(320, 44)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# El overlay es decorativo: el diálogo se lee en su panel, no aquí.
	_panel.z_index = 2
	add_child(_panel)

	var sb := StyleBoxFlat.new()
	sb.bg_color = FONDO_COLOR
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(6)
	_panel.add_theme_stylebox_override("panel", sb)

	_label = Label.new()
	_label.name = "SubtituloTexto"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", TAMAÑOS_PX["mediano"])
	_panel.add_child(_label)

## ── API pública ──────────────────────────────────────────

## Muestra el texto completo del nodo actual del diálogo (independiente del
## typing effect: el subtítulo es la accesibilidad del texto, no el decorado).
func mostrar(texto: String) -> void:
	if not bool(_leer_m58().get("activado", true)):
		visible = false
		return
	_label.text = texto
	visible = true

## Oculta el subtítulo (diálogo terminado o M58 lo desactiva).
func ocultar() -> void:
	_label.text = ""
	visible = false

## ── Estado M58 (RF8) ─────────────────────────────────────

func _leer_m58() -> Dictionary:
	var acc := _m58()
	if acc != null and acc.has_method("get_subtitulos"):
		return acc.get_subtitulos()
	return DEFAULT_RF8

func _m58() -> Node:
	return get_node_or_null("/root/AccesibilityManager")

func _conectar_m58() -> void:
	var acc := _m58()
	if acc != null and acc.has_signal("subtitulos_changed"):
		if not acc.subtitulos_changed.is_connected(_on_subtitulos_changed):
			acc.subtitulos_changed.connect(_on_subtitulos_changed)

func _on_subtitulos_changed(activado: bool, tamano: String, fondo: bool) -> void:
	_aplicar_estado({"activado": activado, "tamano": tamano, "fondo": fondo})

func _aplicar_estado(cfg: Dictionary) -> void:
	var activado: bool = bool(cfg.get("activado", true))
	var tamano: String = String(cfg.get("tamano", "mediano"))
	var fondo: bool = bool(cfg.get("fondo", true))
	_label.add_theme_font_size_override("font_size",
		int(TAMAÑOS_PX.get(tamano, TAMAÑOS_PX["mediano"])))
	var sb: StyleBoxFlat = _panel.get_theme_stylebox("panel")
	if sb != null:
		sb.bg_color.a = FONDO_COLOR.a if fondo else 0.0
	_fondo_visible = fondo
	if not activado and visible:
		ocultar()
