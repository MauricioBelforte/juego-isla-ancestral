# T-053-068: LoadingLayer — pantalla de carga con progreso real (M63)
# Muestra una pantalla de carga cozy con barra de progreso y consejos.
# Consume StreamManager (M63) de forma defensiva.

class_name LoadingLayer
extends UILayer

signal carga_completada

var _progress_bar: ProgressBar
var _status_label: Label
var _tip_label: Label
var _progress: float = 0.0
var _target_progress: float = 0.0

## ── Consejos cozy ──────────────────────────────────────
const TIPS := [
	"Recuerda regar tus plantas cada día...",
	"Los vecinos aprecian los regalos...",
	"Explora las ruinas antiguas con cuidado...",
	"El comercio justo es la clave...",
	"Las estaciones cambian la vida de la isla...",
	" fotografía puede capturar momentos únicos...",
	"El diario registra tus descubrimientos...",
	"Respeta la naturaleza de la isla...",
]

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_FULL
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	# Suavizar el progreso hacia el objetivo
	if _progress < _target_progress:
		_progress = move_toward(_progress, _target_progress, delta * 0.5)
		_actualizar_barra()
	elif _progress >= 1.0 and _target_progress >= 1.0:
		# Carga completada
		carga_completada.emit()


## ── API pública ─────────────────────────────────────────

## Muestra la pantalla de carga
func mostrar_carga(titulo: String = "") -> void:
	_progress = 0.0
	_target_progress = 0.0
	_actualizar_barra()
	_mostrar_tip_aleatorio()
	visible = true
	if _status_label:
		_status_label.text = titulo if titulo != "" else _t("LOADING.CARGANDO")


## Actualiza el progreso de carga (0.0 a 1.0)
func set_progreso(valor: float) -> void:
	_target_progress = clampf(valor, 0.0, 1.0)


## Oculta la pantalla de carga
func ocultar_carga() -> void:
	visible = false
	_progress = 0.0
	_target_progress = 0.0


## ── Métodos privados ────────────────────────────────────

func _crear_ui() -> void:
	# Fondo completo
	var bg := ColorRect.new()
	bg.color = Color(0.90, 0.84, 0.74)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.name = "Fondo"
	add_child(bg)
	bg.move_to_front()

	# Contenido centrado
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	vbox.custom_minimum_size = Vector2(400, 0)
	center.add_child(vbox)

	# Título
	var title := Label.new()
	title.name = "Title"
	title.text = _t("LOADING.TITULO")
	title.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H1)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Barra de progreso
	_progress_bar = ProgressBar.new()
	_progress_bar.custom_minimum_size = Vector2(0, 24)
	_progress_bar.max_value = 1.0
	_progress_bar.value = 0.0
	_progress_bar.show_percentage = false
	vbox.add_child(_progress_bar)

	# Estado
	_status_label = Label.new()
	_status_label.name = "StatusLabel"
	_status_label.text = _t("LOADING.CARGANDO")
	_status_label.add_theme_font_size_override("font_size", 14)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_status_label)

	# Consejo
	_tip_label = Label.new()
	_tip_label.name = "TipLabel"
	_tip_label.text = ""
	_tip_label.add_theme_font_size_override("font_size", 12)
	_tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_tip_label)


func _actualizar_barra() -> void:
	if _progress_bar:
		_progress_bar.value = _progress
	if _status_label:
		var percent := int(_progress * 100)
		_status_label.text = _t("LOADING.CARGANDO") + " %d%%" % percent


func _mostrar_tip_aleatorio() -> void:
	if _tip_label and TIPS.size() > 0:
		var idx := randi() % TIPS.size()
		_tip_label.text = _t("LOADING.TIP") + " " + TIPS[idx]


func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave


## ── UILayer virtual ──────────────────────────────────────

func on_layer_opened() -> void:
	_progress = 0.0
	_target_progress = 0.0
	_actualizar_barra()
	_mostrar_tip_aleatorio()


func on_layer_closed() -> void:
	visible = false


func focus_first() -> Control:
	return null  # Loading no tiene foco interactivo
