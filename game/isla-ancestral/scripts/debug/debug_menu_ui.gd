# Modelo: agnes-3-flash (original) / DeepSeek-V4.1-Flash (fix 2026-11-01 y 2026-11-02)
# Plataforma: Kilo Code / WorkBuddy AI
# Fecha: 2026-10-09 (creacion) - 2026-11-02 (placeholder, overlay FPS, aviso dev)
# M110-UI slice 3: DebugMenuUI — controlador de la escena debug_menu.tscn.
# Consume el backend debug_menu.gd sin modificarlo.
#
# CORRECCIONES 2026-11-01 (medidas, no supuestas):
#  1. TabBar con 0 pestañas. `_configurar_tabs()` hacia
#     `_tab_bar.tooltip_text = " | ".join(tabs)` con `tabs` = Array de
#     DICTIONARIES del config. Medido: el join produce
#     `{ "id": "jugador", "nombre": "Jugador" } | { ... }` y `tab_count == 0`
#     (TabBar nace con 0 y solo crece con `add_tab()`), asi que el menu
#     mostraba una barra VACIA. Ahora se usa `add_tab(nombre)`.
#  2. Handlers de señal con el tipo equivocado. Las señales del backend son
#     `estacion_solicitada(estacion: int)` y `clima_solicitado(tipo_clima: int)`
#     (debug_menu.gd:46/49) y los handlers declaraban `String`. Medido:
#     `ERROR: Cannot convert argument 1 from int to String` y el handler NUNCA
#     corria (la consola no registraba la solicitud). Ahora reciben int.
#  3. Los "paneles" eran un RichTextLabel con el texto "Panel: Mundo". Ahora
#     las pestañas `mundo` y `entidades` montan los paneles REALES
#     (`panels/panel_mundo.gd`, `panels/panel_entidades.gd`).
#
# AMPLIACION 2026-11-02 (checklist §M L243, §O L263 y defecto de la consola):
#  4. La consola se usaba como CARTEL de las pestañas sin panel propio:
#     `_on_tab_changed` hacia `_console.set_text("Panel: Jugador ...")`, y eso
#     PISABA las lineas reales del log (el siguiente `_refrescar_vista()` las
#     recuperaba, pero el cartel se volvia a imponer en cada cambio de pestaña).
#     Ahora hay un `Label` placeholder aparte y la consola solo se muestra en la
#     pestaña `sistema`, con su contenido real.
#  5. FPS overlay cada 0.5 s (§O L263): `Label` + `Timer` que lee
#     `Engine.get_frames_per_second()` y se muestra solo si el toggle `fps` del
#     backend esta activo (`toggle_activo("fps")`).
#  6. Aviso "SOLO PARA DESARROLLO" (§M L243) en la barra de titulo.
extends CanvasLayer
class_name DebugMenuUI

const PANEL_MUNDO := preload("res://scripts/debug/panels/panel_mundo.gd")
const PANEL_ENTIDADES := preload("res://scripts/debug/panels/panel_entidades.gd")
const PESTANAS_DEFECTO := ["Jugador", "Mundo", "Entidades", "Visualización", "Sistema"]
## Pestaña que monta la consola real (§G "Panel Sistema").
const PESTANA_CONSOLA := "sistema"
## §O L263: el overlay de FPS se refresca cada 0.5 s.
const FPS_INTERVALO := 0.5
const TEXTO_AVISO_DEV := "SOLO PARA DESARROLLO — no distribuir"
## §N L139: el backend YA tiene `save_config()`/`reset_config()` desde la tanda
## del 2026-10-27, pero ningun widget los llamaba: el estado solo se guardaba al
## cerrar el arbol. Este boton es la via manual y ademas hace medible el item.
const TEXTO_GUARDAR_CONFIG := "Guardar Configuración"
const TEXTO_RESET_CONFIG := "Restablecer"

var _debug_menu: Node = null
var _tab_bar: TabBar = null
var _content: Control = null
var _title: Label = null
var _close_btn: Button = null
var _console: Control = null
var _panel_mundo: VBoxContainer = null
var _panel_entidades: VBoxContainer = null
var _placeholder: Label = null
var _fps_overlay: Label = null
var _fps_timer: Timer = null
var _aviso_dev: Label = null
var _barra_config: HBoxContainer = null
var _btn_guardar_config: Button = null
var _btn_reset_config: Button = null
var _visible := false
var _ids_pestanas: Array[String] = []


func _ready() -> void:
	if _debug_menu == null:
		_debug_menu = get_node_or_null("/root/DebugMenu")
	_tab_bar = $RootPanel/TabBar
	_content = $RootPanel/ContentPanel
	_title = $RootPanel/TitleBar/TitleLabel
	_close_btn = $RootPanel/TitleBar/CloseButton
	if _close_btn != null:
		_close_btn.pressed.connect(_on_close)

	_construir_aviso_dev()
	_construir_overlay_fps()
	_construir_barra_config()

	# Cartel de las pestañas que no tienen panel propio. NO es la consola.
	_placeholder = Label.new()
	_placeholder.set_name("Placeholder")
	_placeholder.visible = false
	_placeholder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(_placeholder)

	# Consola (pestaña "Sistema")
	_console = (load("res://scripts/debug/debug_console.gd") as Script).new()
	_console.set_name("Consola")
	_content.add_child(_console)

	# Paneles reales del 03-Diseno (secciones D y E)
	_panel_mundo = PANEL_MUNDO.new()
	_panel_mundo.name = "PanelMundo"
	_content.add_child(_panel_mundo)
	_panel_entidades = PANEL_ENTIDADES.new()
	_panel_entidades.name = "PanelEntidades"
	_content.add_child(_panel_entidades)

	# Conectar señales del backend
	if _debug_menu != null:
		if _debug_menu.has_signal("estacion_solicitada"):
			_debug_menu.connect("estacion_solicitada", _on_estacion_solicitada)
		if _debug_menu.has_signal("clima_solicitado"):
			_debug_menu.connect("clima_solicitado", _on_clima_solicitado)
		if _debug_menu.has_method("esta_visible"):
			_visible = bool(_debug_menu.call("esta_visible"))

	_configurar_tabs()
	_on_tab_changed(_tab_bar.current_tab if _tab_bar.tab_count > 0 else 0)


## §M L243: advertencia visible de build de desarrollo.
func _construir_aviso_dev() -> void:
	_aviso_dev = Label.new()
	_aviso_dev.set_name("AvisoDesarrollo")
	_aviso_dev.text = TEXTO_AVISO_DEV
	_aviso_dev.modulate = Color(1.0, 0.85, 0.2)
	_aviso_dev.tooltip_text = "Build de desarrollo (OS.is_debug_build() = %s)" % str(OS.is_debug_build())
	var barra: Node = $RootPanel/TitleBar
	if barra != null:
		barra.add_child(_aviso_dev)
	else:
		add_child(_aviso_dev)


## §O L263: overlay de FPS refrescado cada 0.5 s.
func _construir_overlay_fps() -> void:
	_fps_overlay = Label.new()
	_fps_overlay.set_name("FpsOverlay")
	_fps_overlay.visible = false
	_fps_overlay.text = "FPS: --"
	_fps_overlay.position = Vector2(16, 8)
	_fps_overlay.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	$RootPanel.add_child(_fps_overlay)

	_fps_timer = Timer.new()
	_fps_timer.set_name("TimerFps")
	_fps_timer.wait_time = FPS_INTERVALO
	_fps_timer.autostart = true
	_fps_timer.one_shot = false
	add_child(_fps_timer)
	_fps_timer.timeout.connect(_actualizar_fps)
	_actualizar_fps()


## §N L139: barra de configuracion con guardado/restablecido MANUALES.
## El backend ya sabia persistir (save_config/reset_config, tanda 2026-10-27),
## pero solo lo hacia en `_notification(EXIT_TREE)`: desde la UI no habia forma
## de pedirlo, asi que el item no era ejercitable. Los dos botones son
## fail-closed: sin backend o sin el metodo no hacen nada (no fingen guardar).
func _construir_barra_config() -> void:
	_barra_config = HBoxContainer.new()
	_barra_config.set_name("BarraConfig")

	_btn_guardar_config = Button.new()
	_btn_guardar_config.set_name("BotonGuardarConfig")
	_btn_guardar_config.text = TEXTO_GUARDAR_CONFIG
	_btn_guardar_config.tooltip_text = "Escribe el estado del menu en user://debug_menu_estado.json"
	_btn_guardar_config.pressed.connect(_on_guardar_config)
	_barra_config.add_child(_btn_guardar_config)

	_btn_reset_config = Button.new()
	_btn_reset_config.set_name("BotonResetConfig")
	_btn_reset_config.text = TEXTO_RESET_CONFIG
	_btn_reset_config.tooltip_text = "Borra el estado guardado y vuelve a los valores por defecto"
	_btn_reset_config.pressed.connect(_on_reset_config)
	_barra_config.add_child(_btn_reset_config)

	$RootPanel.add_child(_barra_config)


## Guardado manual. Devuelve true solo si el backend realmente lo ejecuto.
func _on_guardar_config() -> void:
	if _debug_menu == null or not _debug_menu.has_method("save_config"):
		return
	_debug_menu.call("save_config")
	_avisar_consola("Configuración guardada")


## Restablecido manual (borra `user://debug_menu_estado.json`).
func _on_reset_config() -> void:
	if _debug_menu == null or not _debug_menu.has_method("reset_config"):
		return
	_debug_menu.call("reset_config")
	_avisar_consola("Configuración restablecida")


## Escribe en la consola si existe (en `_ready()` puede llamarse antes de que
## la consola este montada: el guardia es obligatorio, no defensivo).
func _avisar_consola(texto: String) -> void:
	if _console != null and _console.has_method("agregar_linea_publica"):
		_console.call("agregar_linea_publica", texto)


## Se muestra solo si el toggle `fps` del backend esta activo.
func fps_habilitado() -> bool:
	if _debug_menu == null or not _debug_menu.has_method("toggle_activo"):
		return false
	return bool(_debug_menu.call("toggle_activo", "fps"))


## Un tick del overlay. Publico para que la suite lo ejercite sin esperar 0.5 s.
func _actualizar_fps() -> void:
	if _fps_overlay == null:
		return
	var activo := fps_habilitado()
	_fps_overlay.visible = activo
	if activo:
		_fps_overlay.text = "FPS: %d" % Engine.get_frames_per_second()


## Pestañas REALES en la TabBar, con los nombres del config.
func _configurar_tabs() -> void:
	var datos := _leer_pestanas()
	_ids_pestanas = datos[0]
	var nombres: Array[String] = datos[1]
	for n in nombres:
		_tab_bar.add_tab(n)
	if _tab_bar.tab_count > 0:
		_tab_bar.current_tab = 0
		_tab_bar.tab_changed.connect(_on_tab_changed)


## Devuelve [ids, nombres] del config. Si el config falta o esta roto, usa el
## catalogo literal (5 pestañas) para que la barra nunca quede vacia.
func _leer_pestanas() -> Array:
	var ids: Array[String] = []
	var nombres: Array[String] = []
	var config_path := "res://data/debug/debug_menu_config.json"
	if FileAccess.file_exists(config_path):
		var txt := FileAccess.get_file_as_string(config_path)
		var json: Variant = JSON.parse_string(txt)
		if json is Dictionary and (json as Dictionary).has("pestanas"):
			var pest: Variant = (json as Dictionary)["pestanas"]
			if pest is Array:
				for p in (pest as Array):
					if p is Dictionary:
						var nombre := String((p as Dictionary).get("nombre", ""))
						if nombre.is_empty():
							continue
						nombres.append(nombre)
						ids.append(String((p as Dictionary).get("id", "")))
	if nombres.is_empty():
		for n in PESTANAS_DEFECTO:
			nombres.append(String(n))
			ids.append(String(n).to_lower())
	return [ids, nombres]


## Texto del cartel de cada pestaña sin panel propio (dato de UI, no del log).
func _descripcion_pestana(id: String) -> String:
	match id:
		"jugador":
			return "Panel: Jugador\nTeletransporte, inventario, progreso"
		"visualizacion":
			return "Panel: Visualización\nColliders, FPS, chunks, nav, hitbox, IA"
		_:
			return "Panel: %s" % id


func _on_tab_changed(tab: int) -> void:
	var id: String = ""
	if tab >= 0 and tab < _ids_pestanas.size():
		id = _ids_pestanas[tab]
	_mostrar_panel(id)
	# El cartel va al PLACEHOLDER. Antes se escribia en la consola y pisaba las
	# lineas reales del log en cada cambio de pestaña.
	if _placeholder != null:
		var tiene_panel := (id == "mundo" or id == "entidades" or id == PESTANA_CONSOLA)
		_placeholder.visible = not tiene_panel
		if not tiene_panel:
			_placeholder.text = _descripcion_pestana(id)


## Un solo punto que decide qué se ve: el panel de la pestaña activa, la
## consola en "Sistema", o el cartel.
func _mostrar_panel(id: String) -> void:
	if _panel_mundo != null:
		_panel_mundo.visible = (id == "mundo")
	if _panel_entidades != null:
		_panel_entidades.visible = (id == "entidades")
	if _console != null:
		_console.visible = (id == PESTANA_CONSOLA)


func _on_close() -> void:
	if _debug_menu != null and _debug_menu.has_method("alternar"):
		_debug_menu.call("alternar")


func _on_estacion_solicitada(estacion: int) -> void:
	# La señal del backend es int (debug_menu.gd:46). Declararla String hacia
	# que Godot no pudiera convertir el argumento y el handler no corriera.
	if _console != null:
		_console.call("agregar_linea_publica", "Estación solicitada: %d" % estacion)


func _on_clima_solicitado(clima: int) -> void:
	if _console != null:
		_console.call("agregar_linea_publica", "Clima solicitado: %d" % clima)


## Devuelve si el UI está visible (para tests).
func esta_visible_ui() -> bool:
	return visible and _visible

## Devuelve el TabBar (para tests).
func obtener_tab_bar() -> TabBar:
	return _tab_bar

## Devuelve el ContentPanel (para tests).
func obtener_contenido() -> Control:
	return _content

## Devuelve la consola (para tests).
func obtener_consola() -> Control:
	return _console

## Devuelve el panel Mundo (para tests).
func obtener_panel_mundo() -> VBoxContainer:
	return _panel_mundo

## Devuelve el panel Entidades (para tests).
func obtener_panel_entidades() -> VBoxContainer:
	return _panel_entidades

## Devuelve el cartel de pestañas sin panel (para tests).
func obtener_placeholder() -> Label:
	return _placeholder

## Devuelve el overlay de FPS (para tests).
func obtener_overlay_fps() -> Label:
	return _fps_overlay

## Devuelve el aviso de desarrollo (para tests).
func obtener_aviso_dev() -> Label:
	return _aviso_dev

## Devuelve la barra de configuracion (para tests).
func obtener_barra_config() -> HBoxContainer:
	return _barra_config

## Devuelve el boton "Guardar Configuración" (para tests).
func obtener_boton_guardar_config() -> Button:
	return _btn_guardar_config

## Devuelve el boton "Restablecer" (para tests).
func obtener_boton_reset_config() -> Button:
	return _btn_reset_config

## Ids de las pestañas en el orden de la TabBar (para tests).
func ids_pestanas() -> Array[String]:
	return _ids_pestanas.duplicate()

## Devuelve si el backend está conectado.
func backend_conectado() -> bool:
	return _debug_menu != null

## Inyeccion del backend para tests (antes de entrar al arbol).
func _inyectar_menu(nodo: Node) -> void:
	_debug_menu = nodo
