# M69 — FastTravelEffect: transición visual del viaje rápido (sección J del 05 real).
# J.2 desvanecimiento curva cozy · J.4 flash sutil al aparecer · J.5 indicador de carga 0.5-1.5s
# J.6 sin huecos negros · J.8 HUD visible · J.9 sin parpadeos por baja luz.
# Capa: CanvasLayer layer=-1 — cubre el mundo 3D y queda DEBAJO del HUD ($UI, canvas base,
# main_island.gd L48) y de UIRoot (CanvasLayer 100): el HUD se ve durante toda la transición.
# No usa UILayer: la transición NO pausa el mundo NI compite por foco (no entra en la pila M53).
# G-5.3-Flash-Agente / Kilo Code — 2026-10-19
extends CanvasLayer

## Velo pleno sostenido alcanzado (el caller teletransporta al jugador aquí).
signal cubierto
## Fade-in + carga mínima completados (transición terminada).
signal terminada

## Noche cozy (pleno) — SIN negro puro (J.6: nunca un hueco negro duro).
const COLOR_VELO := Color(ThemeUx.COLOR_PRESSED, 1.0)
## Dorado ThemeUx (COLOR_HIGHLIGHT_GOLD) para el flash de llegada.
const COLOR_FLASH := Color(ThemeUx.COLOR_HIGHLIGHT_GOLD, 1.0)
## m69_spec §F: bruma 0.5s de salida + fade 0.3s de entrada.
const DUR_FADE_OUT := 0.5
const DUR_FADE_IN := 0.3
const DUR_FLASH := 0.15
## J.5: el indicador de carga vive entre 0.5s (mínimo) y 1.5s (techo).
const CARGA_MIN := 0.5
const CARGA_MAX := 1.5
## Alpha máximo del flash de llegada (sutil, no strobe — J.9).
const FLASH_ALPHA_MAX := 0.22

var _velo: ColorRect
var _flash: ColorRect
var _bruma: CPUParticles2D
var _caja: VBoxContainer
var _lbl_destino: Label
var _barra: ProgressBar
var _tween: Tween
## Fase actual: "" | "saliendo" | "cubierto" | "llegando".
var _fase: String = ""
var _carga_seg := 1.0
var _tiempo_carga := 0.0
var _escala := 1.0
## finalizar_transicion() llegó antes de la cobertura → se ejecuta al cubrir.
var _pendiente_final := false


func _ready() -> void:
	layer = -1
	visible = false
	var ts := get_node_or_null("/root/ThemeService")
	if ts != null and ts.has_method("get_ui_scale"):
		_escala = clampf(float(ts.get_ui_scale()), 0.8, 1.5)
	_armar_ui()


func _armar_ui() -> void:
	_velo = ColorRect.new()
	_velo.color = COLOR_VELO
	_velo.color.a = 0.0
	_velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_velo)

	_flash = ColorRect.new()
	_flash.color = COLOR_FLASH
	_flash.color.a = 0.0
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_flash)

	_bruma = _armar_bruma()
	add_child(_bruma)

	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	_caja = VBoxContainer.new()
	_caja.add_theme_constant_override("separation", 10)
	centro.add_child(_caja)

	_lbl_destino = Label.new()
	_lbl_destino.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_destino.add_theme_font_size_override("font_size", int(ThemeUx.FONT_SIZE_H2 * _escala))
	_lbl_destino.add_theme_color_override("font_color", ThemeUx.COLOR_TEXT_DARK)
	_caja.add_child(_lbl_destino)

	_barra = ProgressBar.new()
	_barra.min_value = 0.0
	_barra.max_value = 1.0
	_barra.show_percentage = false
	_barra.custom_minimum_size = Vector2(280, 14)
	_barra.value = 0.0
	_caja.add_child(_barra)


func _process(delta: float) -> void:
	if _fase == "cubierto":
		_tiempo_carga += delta
		if _barra != null:
			_barra.value = clampf(_tiempo_carga / _carga_seg, 0.0, 1.0)


## J.3: bruma de partículas suaves, coherente con la familia tonal del
## módulo (nube nocturna lenta, sin destellos). Dominio real de partículas:
## M52 (los ítems del plan nombran M41 = música, índice equivocado).
func _armar_bruma() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = 24
	p.lifetime = 3.0
	p.emitting = false
	p.texture = _textura_bruma()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(1400.0, 120.0)
	p.position = Vector2(960.0, 180.0)
	p.direction = Vector2(1.0, 0.2)
	p.spread = 12.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 14.0
	p.initial_velocity_max = 34.0
	p.scale_amount_min = 2.5
	p.scale_amount_max = 6.0
	p.color = Color(0.85, 0.88, 0.95, 0.10)
	return p


## Textura radial procedural (no requiere asset).
func _textura_bruma() -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1.0, 1.0, 1.0, 0.0))
	g.set_color(1, Color(1.0, 1.0, 1.0, 1.0))
	g.add_point(0.55, Color(1.0, 1.0, 1.0, 0.8))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 128
	t.height = 128
	return t


## ── API pública ──────────────────────────────────────────────────────────

## Arranca la transición: bruma de salida con curva cozy + indicador de carga.
## `carga` es el tiempo del indicador, se recorta al rango [0.5, 1.5] (J.5).
func iniciar_transicion(destino: String = "", carga: float = 1.0) -> bool:
	if _fase != "":
		return false
	# J.7 modo foto (M56): con la foto activa no se arranca la transición
	# (la foto necesita vista limpia; el velo taparía la captura).
	var ps := get_node_or_null("/root/PhotoService")
	if ps != null and ps.has_method("modo_foto") and bool(ps.modo_foto()):
		return false
	_fase = "saliendo"
	_pendiente_final = false
	_carga_seg = clampf(carga, CARGA_MIN, CARGA_MAX)
	_tiempo_carga = 0.0
	_lbl_destino.text = destino
	_barra.value = 0.0
	_caja.visible = true
	_flash.color.a = 0.0
	_bruma.emitting = true
	visible = true
	_tween = create_tween()
	_tween.tween_property(_velo, "color:a", 1.0, DUR_FADE_OUT).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(_al_cubrir)
	return true


## Velo pleno sostenido: la cobertura NUNCA se abre sola (J.6) — el caller
## teletransporta al jugador y llama finalizar_transicion().
func esta_cubierta() -> bool:
	return _fase == "cubierto"


func esta_en_curso() -> bool:
	return _fase != ""


func velo_alpha() -> float:
	return _velo.color.a if _velo != null else 0.0


func carga_display() -> float:
	return _barra.value if _barra != null else 0.0


## Punto de llegada: flash sutil dorado + fade-in con curva cozy.
## Si se llama antes de cubrir, queda pendiente y arranca al cubrir.
func finalizar_transicion() -> void:
	if _fase == "":
		return
	if _fase != "cubierto":
		_pendiente_final = true
		return
	_arrancar_llegada()


## Cancelación a mitad (P7 de la spec §F, versión Effect): reset limpio
## instantáneo — sin tweens zombies, sin flashes residuales.
func cancelar() -> void:
	var habia := _fase != "" or visible
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
	_velo.color.a = 0.0
	_flash.color.a = 0.0
	_bruma.emitting = false
	_fase = ""
	_pendiente_final = false
	visible = false
	# J.12: subtítulo de feedback de la acción cancelada (solo si había algo en vuelo).
	if habia:
		_subtitular("M69.FEEDBACK.CANCELADO")


## J.12: subtítulo de feedback vía SubtitleManager (duck typing).
func _subtitular(clave: String) -> void:
	var subs := get_node_or_null("/root/SubtitleManager")
	if subs == null or not subs.has_method("show_subtitle"):
		return
	subs.show_subtitle(_texto_local(clave), 2.0)


## Localización con fallback a la clave (mismo patrón que pause_layer._t_local).
func _texto_local(clave: String) -> String:
	var loc := get_node_or_null("/root/Localization")
	if loc != null and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave


## J.14: confirmación háptica (opcional: respeta vibracion_on de M57/M68).
func _haptico() -> void:
	var ci := get_node_or_null("/root/ControlInput")
	if ci != null and ci.has_method("vibrar"):
		ci.vibrar(0.35, 0.20)


## ── Fases internas ───────────────────────────────────────────────────────

func _al_cubrir() -> void:
	_fase = "cubierto"
	_tiempo_carga = 0.0
	cubierto.emit()
	if _pendiente_final:
		_pendiente_final = false
		_arrancar_llegada()


func _arrancar_llegada() -> void:
	_fase = "llegando"
	# J.5: esperar el resto del mínimo de carga antes de abrir el velo.
	var espera: float = maxf(0.0, _carga_seg - _tiempo_carga)
	_tween = create_tween()
	# J.9: un solo pico luminoso suave y decaimiento — nada de parpadeos.
	_flash.color.a = FLASH_ALPHA_MAX
	_tween.tween_property(_flash, "color:a", 0.0, DUR_FLASH).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if espera > 0.0:
		_tween.tween_interval(espera)
	_tween.tween_property(_velo, "color:a", 0.0, DUR_FADE_IN).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(_al_terminar)


func _al_terminar() -> void:
	_fase = ""
	_velo.color.a = 0.0
	_flash.color.a = 0.0
	_bruma.emitting = false
	_caja.visible = false
	visible = false
	terminada.emit()
	# J.12 subtítulo de llegada + J.14 confirmación háptica opcional.
	_subtitular("M69.FEEDBACK.ARRIBADA")
	_haptico()
