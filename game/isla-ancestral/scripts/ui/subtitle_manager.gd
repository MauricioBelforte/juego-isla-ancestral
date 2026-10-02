# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-02
#
# M91 · Subtítulos — SubtitleManager (autoload "SubtitleManager")
# Implementa el diseño 03-Diseno §6 con correcciones sobre el esqueleto original:
#  - Ruta real scripts/ui/ (el diseño decía res://ui/subtitles/, inexistente).
#  - Config propia persistida en M60 sección "subtitles" (el diseño refería a un
#    AudioSettings inexistente; el autoload real de audio es AudioConfig).
#  - El RichTextLabel se monta POR CÓDIGO en _ready(): el proyecto no usa
#    .tscn para capas UI (§9.47, patrón de credits_layer).
#  - Sin class_name: es autoload (pitfall §9.17/§9.41, igual que AudioConfig).
#  - show_subtitle() es "re-entrante": la generación actual invalida al timer
#    anterior, así un segundo subtítulo no se oculta con el reloj del primero
#    (race condition presente en el esqueleto original).
# Sin bucles por frame: todo es por señal o por timer diferido.
extends Node

## Sección de M60 (DataStore) donde se persiste la config de subtítulos
const SECCION_CONFIG := "subtitles"

## Límites del diseño (ítems "tamaño slider 0.5x a 2x" y "opacidad 0.2 a 1.0")
const TAMANO_MIN := 0.5
const TAMANO_MAX := 2.0
const OPACIDAD_MIN := 0.2
const OPACIDAD_MAX := 1.0
const TAMANO_BASE := 16.0

## Config por defecto
const HABILITADOS_DEFECTO := true
const TAMANO_DEFECTO := 1.0
const OPACIDAD_DEFECTO := 0.9
const FONDO_DEFECTO := true
const COLOR_FONDO_DEFECTO := Color(0.0, 0.0, 0.0, 0.6)
const COLOR_TEXTO_DEFECTO := Color(1.0, 1.0, 1.0, 1.0)

signal subtitulo_mostrado(texto: String, duracion: float)
signal subtitulo_oculto()
signal config_subtitulos_cambiada()
## Emite cuando el usuario alterna el toggle (lo consume la UI de M53)
signal habilitados_cambiado(habilitados: bool)

## estado
var habilitados: bool = HABILITADOS_DEFECTO
var tamano: float = TAMANO_DEFECTO
var opacidad: float = OPACIDAD_DEFECTO
var fondo_visible: bool = FONDO_DEFECTO
var color_fondo: Color = COLOR_FONDO_DEFECTO
var color_texto: Color = COLOR_TEXTO_DEFECTO

## UI montada en runtime
var _capa: CanvasLayer
var _panel: PanelContainer
var _label: RichTextLabel

## Generación del subtítulo activo (ver _mostrar_interno)
var _generacion: int = 0
## Estado del subtítulo actual (para tests y para ocultar a mitad de pantalla)
var _texto_actual: String = ""
## Último tamaño de fuente realmente aplicado (TAMANO_BASE * tamano).
## Expuesto para tests: distingue el override del default del tema (que es 16).
var _font_size_aplicada: int = TAMANO_BASE


func _ready() -> void:
	_crear_ui()
	_cargar_config()
	_aplicar_apariencia()


## §6: monta CanvasLayer + PanelContainer (fondo opcional) + RichTextLabel.
## Sin .tscn — todo por código (§9.47).
func _crear_ui() -> void:
	_capa = CanvasLayer.new()
	_capa.name = "SubtitulosCapa"
	_capa.layer = 90
	add_child(_capa)

	_panel = PanelContainer.new()
	_panel.name = "SubtituloFondo"
	_capa.add_child(_panel)
	# Anclaje: centrado, pegado al borde inferior (abre-ajusta con la ventana)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = -420.0
	_panel.offset_right = 420.0
	_panel.offset_top = -150.0
	_panel.offset_bottom = -40.0
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN

	_label = RichTextLabel.new()
	_label.name = "SubtitleLabel"
	_label.bbcode_enabled = false
	_label.fit_content = true
	_label.scroll_active = false
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel.add_child(_label)

	_panel.visible = false
	_label.visible = false


## ── API pública (ítems 233/234) ────────────────────────

## Muestra un subtítulo durante `duracion` segundos.
## Re-entrante: cancela (lógicamente) el reloj de cualquier subtítulo anterior.
func show_subtitle(texto: String, duracion: float) -> void:
	if not habilitados:
		return
	if texto.is_empty():
		hide_subtitle()
		return
	_generacion += 1
	_texto_actual = texto
	_label.text = texto
	_panel.visible = true
	_label.visible = true
	_label.modulate.a = opacidad
	subtitulo_mostrado.emit(texto, duracion)
	if duracion <= 0.0:
		# sin duración: queda hasta hide_subtitle() (útil para diálogos)
		return
	var mi_generacion := _generacion
	await get_tree().create_timer(duracion).timeout
	# Si en el medio entró otro subtítulo, este reloj quedó obsoleto.
	if mi_generacion == _generacion:
		hide_subtitle()


## Oculta el subtítulo actual inmediatamente (ítem 234).
func hide_subtitle() -> void:
	_generacion += 1
	_texto_actual = ""
	if _label == null:
		return
	_label.visible = false
	_panel.visible = false
	subtitulo_oculto.emit()


## true si hay un subtítulo en pantalla ahora mismo
func hay_subtitulo_visible() -> bool:
	return _label != null and _label.visible


## Texto del subtítulo en pantalla ("" si no hay)
func texto_actual() -> String:
	return _texto_actual


## Último tamaño de fuente aplicado (16 * tamano) — expuesto para tests:
## distingue el override real del default del tema, que también es 16.
func get_font_size_aplicada() -> int:
	return _font_size_aplicada


## Última opacidad realmente aplicada al label
func get_opacity_aplicada() -> float:
	if _label == null:
		return 0.0
	return _label.modulate.a


## ── Config (ítems 98-101: toggle, tamaño, opacidad, fondo) ──

func set_habilitados(v: bool) -> void:
	habilitados = v
	if not v:
		hide_subtitle()
	habilitados_cambiado.emit(v)
	config_subtitulos_cambiada.emit()
	_guardar_config()


func get_habilitados() -> bool:
	return habilitados


## Slider 0.5x a 2x (ítem 99). Clamado a los límites del diseño.
func set_subtitle_size(v: float) -> void:
	tamano = clampf(v, TAMANO_MIN, TAMANO_MAX)
	_aplicar_apariencia()
	config_subtitulos_cambiada.emit()
	_guardar_config()


func get_subtitle_size() -> float:
	return tamano


## Slider 0.2 a 1.0 (ítem 100). Clamado a los límites del diseño.
func set_subtitle_opacity(v: float) -> void:
	opacidad = clampf(v, OPACIDAD_MIN, OPACIDAD_MAX)
	_aplicar_apariencia()
	config_subtitulos_cambiada.emit()
	_guardar_config()


func get_subtitle_opacity() -> float:
	return opacidad


## Fondo toggle + color (ítem 101)
func set_background_visible(v: bool) -> void:
	fondo_visible = v
	_aplicar_apariencia()
	config_subtitulos_cambiada.emit()
	_guardar_config()


func get_background_visible() -> bool:
	return fondo_visible


## true si el panel de fondo está realmente en pantalla (depende de que
## haya subtítulo Y de que el toggle de fondo esté encendido)
func fondo_realmente_visible() -> bool:
	return _panel != null and _panel.visible


func set_background_color(c: Color) -> void:
	color_fondo = c
	_aplicar_apariencia()
	config_subtitulos_cambiada.emit()
	_guardar_config()


func get_background_color() -> Color:
	return color_fondo


func set_text_color(c: Color) -> void:
	color_texto = c
	_aplicar_apariencia()
	config_subtitulos_cambiada.emit()
	_guardar_config()


func get_text_color() -> Color:
	return color_texto


## Restaura los defaults del diseño (útil para tests y para "Restaurar")
func restaurar_defaults() -> void:
	habilitados = HABILITADOS_DEFECTO
	tamano = TAMANO_DEFECTO
	opacidad = OPACIDAD_DEFECTO
	fondo_visible = FONDO_DEFECTO
	color_fondo = COLOR_FONDO_DEFECTO
	color_texto = COLOR_TEXTO_DEFECTO
	_aplicar_apariencia()
	config_subtitulos_cambiada.emit()
	_guardar_config()


## ── Internos ────────────────────────────────────────────

func _aplicar_apariencia() -> void:
	if _label == null:
		return
	_font_size_aplicada = int(round(TAMANO_BASE * tamano))
	_label.add_theme_font_size_override("font_size", _font_size_aplicada)
	_label.add_theme_color_override("default_color", color_texto)
	_label.modulate.a = opacidad
	_panel.visible = _label.visible and fondo_visible
	if _panel.visible:
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = color_fondo
		estilo.set_corner_radius_all(6)
		estilo.set_content_margin_all(10.0)
		_panel.add_theme_stylebox_override("panel", estilo)


## ── Persistencia (M60 sección "subtitles") ─────────────
# Las claves son ASCII a propósito: el borrador de diseño usaba
# "subtítulo_size"/"subtítulo_opacity" con tilde, y las claves con tildes
# generan mojibake cuando un agente escribe en cp1252 (§28). Misma intención.

func _cargar_config() -> void:
	var ds := get_node_or_null("/root/DataStore")
	if ds == null or not ds.has_method("cargar_config"):
		return
	var config: Dictionary = ds.cargar_config()
	var s: Dictionary = config.get(SECCION_CONFIG, {})
	if s.has("enabled"):
		habilitados = bool(s["enabled"])
	if s.has("size"):
		tamano = clampf(float(s["size"]), TAMANO_MIN, TAMANO_MAX)
	if s.has("opacity"):
		opacidad = clampf(float(s["opacity"]), OPACIDAD_MIN, OPACIDAD_MAX)
	if s.has("background"):
		fondo_visible = bool(s["background"])
	if s.has("color"):
		color_fondo = _color_desde_dic(s["color"], COLOR_FONDO_DEFECTO)
	if s.has("text_color"):
		color_texto = _color_desde_dic(s["text_color"], COLOR_TEXTO_DEFECTO)


func _guardar_config() -> void:
	var ds := get_node_or_null("/root/DataStore")
	if ds == null or not ds.has_method("guardar_config"):
		return
	var config: Dictionary = ds.cargar_config()
	config[SECCION_CONFIG] = get_save_data()
	ds.guardar_config(config)


## Formato del ítem "Incluir subtítulo_color como objeto {r, g, b, a}"
func get_save_data() -> Dictionary:
	return {
		"enabled": habilitados,
		"size": tamano,
		"opacity": opacidad,
		"background": fondo_visible,
		"color": _color_a_dic(color_fondo),
		"text_color": _color_a_dic(color_texto),
	}


func restore_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	habilitados = bool(data.get("enabled", HABILITADOS_DEFECTO))
	tamano = clampf(float(data.get("size", TAMANO_DEFECTO)), TAMANO_MIN, TAMANO_MAX)
	opacidad = clampf(float(data.get("opacity", OPACIDAD_DEFECTO)), OPACIDAD_MIN, OPACIDAD_MAX)
	fondo_visible = bool(data.get("background", FONDO_DEFECTO))
	color_fondo = _color_desde_dic(data.get("color", {}), COLOR_FONDO_DEFECTO)
	color_texto = _color_desde_dic(data.get("text_color", {}), COLOR_TEXTO_DEFECTO)
	_aplicar_apariencia()
	config_subtitulos_cambiada.emit()


## Interfaz de proveedor de guardado (misma que AudioConfig)
func get_section_name() -> String:
	return SECCION_CONFIG


static func _color_a_dic(c: Color) -> Dictionary:
	return {"r": c.r, "g": c.g, "b": c.b, "a": c.a}


static func _color_desde_dic(d: Variant, por_defecto: Color) -> Color:
	if not (d is Dictionary):
		return por_defecto
	var m: Dictionary = d
	if not m.has("r") or not m.has("g") or not m.has("b"):
		return por_defecto
	return Color(
		clampf(float(m["r"]), 0.0, 1.0),
		clampf(float(m["g"]), 0.0, 1.0),
		clampf(float(m["b"]), 0.0, 1.0),
		clampf(float(m.get("a", por_defecto.a)), 0.0, 1.0)
	)
