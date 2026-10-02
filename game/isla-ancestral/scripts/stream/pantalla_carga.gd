# Modelo: glm-5.3-flash (iter. 4) · DeepSeek-V4.1-Flash (iter. 6)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-06 · 2026-10-02
#
# M63 P1: Pantalla de carga con barra de progreso real (StreamManager).
# - CanvasLayer con barra ColorRect (progreso del StreamManager)
# - Se muestra/oculta con señal carga_iniciada/carga_completada (M40)
# - Usada por SceneManager/Bootstrap
# iter. 6 (Log 1193, DeepSeek-V4.1-Flash) — diseño §6 (L98/L99):
#  - CONSEJOS de mundo rotando: `tips.txt` + semilla de partida (M29) via
#    `ConsejosCarga` (logica pura). Sin `tips.txt` la pantalla funciona igual.
#  - FUNDIDO (fade) hacia la escena al terminar via `FundidoCarga` (maquina de
#    estados pura): `fundir()` baja la opacidad y `ocultar()` al completar.
# ⚠️ Sin class_name: autoload (07-GUIA §9.17).

extends CanvasLayer

signal pantalla_oculta

var _barra: ColorRect = null
var _fondo: ColorRect = null
var _texto: Label = null
var _consejos: Label = null
var _stream: Node = null

## iter. 6: estado de los consejos rotando (§6 L98).
var _tips: PackedStringArray = PackedStringArray()
var _semilla: int = 0
var _tick: int = 0
var _t_rotacion: float = 0.0
## iter. 6: fundido hacia la escena (§6 L99).
var _fundido := FundidoCarga.new()


func _ready() -> void:
	layer = 100  # por encima de todo
	_construir_ui()
	_conectar_stream()
	_tips = ConsejosCarga.cargar()
	_semilla = _leer_semilla()
	_actualizar_consejo()
	ocultar()


func _construir_ui() -> void:
	_fondo = ColorRect.new()
	_fondo.name = "Fondo"
	_fondo.color = Color(0.12, 0.08, 0.06)  # marrón oscuro cozy
	_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fondo)

	_barra = ColorRect.new()
	_barra.name = "Barra"
	_barra.color = Color(0.85, 0.65, 0.35)  # ámbar cálido
	_barra.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_barra.position = Vector2(210, 380)
	_barra.size = Vector2(500, 16)
	add_child(_barra)

	_texto = Label.new()
	_texto.name = "Texto"
	_texto.text = "Cargando..."
	_texto.add_theme_font_size_override("font_size", 18)
	_texto.add_theme_color_override("font_color", Color(0.95, 0.90, 0.80))
	_texto.position = Vector2(210, 350)
	add_child(_texto)

	# iter. 6 (L98): consejo de mundo rotando, bajo la barra.
	_consejos = Label.new()
	_consejos.name = "Consejos"
	_consejos.text = ""
	_consejos.add_theme_font_size_override("font_size", 14)
	_consejos.add_theme_color_override("font_color", Color(0.80, 0.74, 0.62))
	_consejos.position = Vector2(210, 420)
	add_child(_consejos)


func _conectar_stream() -> void:
	_stream = get_node_or_null("/root/StreamManager")
	if _stream == null:
		return
	if _stream.has_signal("progreso_cambiado"):
		_stream.progreso_cambiado.connect(_on_progreso)
	if _stream.has_signal("operacion_completada"):
		_stream.operacion_completada.connect(_on_op_completada)


func _on_progreso(p: float) -> void:
	if not visible:
		return
	_barra.size.x = 500.0 * clampf(p, 0.0, 1.0)


func _on_op_completada(_op_id: String, _tipo: String) -> void:
	if _stream != null and _stream.has_method("progreso"):
		var p: float = float(_stream.progreso())
		_barra.size.x = 500.0 * clampf(p, 0.0, 1.0)
		_texto.text = "Cargando... %d%%" % int(p * 100)


## Muestra la pantalla de carga (llamado por SceneManager/Bootstrap).
## Reinicia el fundido: la pantalla aparece opaca.
func mostrar() -> void:
	visible = true
	_fundido = FundidoCarga.new()
	_aplicar_alpha(1.0)
	set_process(true)


## Oculta la pantalla (llamado cuando la carga llega al 100%).
func ocultar() -> void:
	visible = false
	set_process(false)
	pantalla_oculta.emit()


## ── iter. 6 (L99): fundido hacia la escena ──────────────

## Inicia el fundido de salida; al completarse, `_process` llama a `ocultar()`.
func fundir(duracion: float = FundidoCarga.DURACION_DEFAULT) -> void:
	_fundido.iniciar(duracion)
	_aplicar_alpha(_fundido.alpha())
	if _fundido.terminado():
		ocultar()
	else:
		set_process(true)


func fundiendo() -> bool:
	return _fundido.estado() == FundidoCarga.Estado.FUNDIENDO


func alpha_actual() -> float:
	return _fundido.alpha()


func _aplicar_alpha(a: float) -> void:
	for n in [_fondo, _barra, _texto, _consejos]:
		if n != null:
			n.modulate.a = a


## ── iter. 6 (L98): consejos de mundo rotando ────────────

## Fija la semilla de partida (M29) y reinicia la rotacion de consejos.
func configurar_seed(semilla: int) -> void:
	_semilla = int(semilla)
	_tick = 0
	_t_rotacion = 0.0
	_actualizar_consejo()


func consejo_actual() -> String:
	return _consejos.text if _consejos != null else ""


func _actualizar_consejo() -> void:
	if _consejos == null:
		return
	_consejos.text = ConsejosCarga.consejo(_tips, _semilla, _tick)


## Semilla de partida de M29 (autoload GameTime); 0 si no esta disponible.
func _leer_semilla() -> int:
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("get_semilla_partida"):
		return int(gt.get_semilla_partida())
	return 0


## ── Proceso (rotacion de consejos + fundido) ────────────

func _process(delta: float) -> void:
	# §6 L98: la rotacion avanza solo con la pantalla visible (set_process).
	if not _tips.is_empty():
		_t_rotacion += delta
		while _t_rotacion >= ConsejosCarga.INTERVALO_ROTACION:
			_t_rotacion -= ConsejosCarga.INTERVALO_ROTACION
			_tick += 1
			_actualizar_consejo()
	# §6 L99: fundido de salida; al completar, ocultar.
	if _fundido.estado() == FundidoCarga.Estado.FUNDIENDO:
		_fundido.avanzar(delta)
		_aplicar_alpha(_fundido.alpha())
		if _fundido.terminado():
			ocultar()
