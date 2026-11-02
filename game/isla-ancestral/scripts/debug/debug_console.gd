# Modelo: agnes-3-flash (original) / DeepSeek-V4.1-Flash (2026-11-02)
# Plataforma: Kilo Code / WorkBuddy AI
# Fecha: 2026-10-09 (creacion) - 2026-11-02 (filtros §G/§H + linea viva)
# M110-UI slice 2: Consola visual del Debug Menu.
# Consume la API del backend debug_menu.gd (console_get_lines, registrar_evento, etc.).
# No reimplementa logica de comandos; solo UI.
#
# AMPLIACION 2026-11-02 (medida, no supuesta): checklist §G L132-L135 y §H L147-L149.
#  1. Barra de filtros REAL: OptionButton de nivel, OptionButton de categoria,
#     LineEdit de busqueda y CheckBox de auto-scroll. Antes no existia ninguno
#     de los 4 widgets (los 7 items estaban en `[ ]`).
#  2. El guard `has_signal("console_line_added")` era CODIGO MUERTO: esa senal
#     no existe en debug_menu.gd (grep = 0). Medido: la consola solo mostraba el
#     snapshot de `console_get_lines()` al arrancar y NUNCA recibia lineas vivas.
#     Ahora se suscribe a `GameLogger.line_emitted` (la misma senal que usa el
#     backend en debug_menu.gd:1323) y guarda nivel/categoria de cada linea.
#  3. El estado de los filtros se empuja al backend con `set_filtros_consola()`
#     para que §N ("Guardar filtros de consola", ya en `[x]`) persista lo que el
#     usuario elige en la UI: antes la UI nunca escribia esa preferencia.
#  4. `set_text()` se conserva por compatibilidad, pero debug_menu_ui.gd dejo de
#     usarlo para rotular pestañas: pisaba las lineas reales del log.
extends Control
class_name DebugConsole

const CONSOLA_MAX_LINEAS := 100
const CONSOLA_DEFAULT := 50

## Nombres de nivel/categoria del logger. La FUENTE es
## `scripts/logging/logger.gd:36` (Level) y `:39` (Category); el indice 0 de
## cada lista es el comodin "todos". La suite cruza estas listas contra
## `get_script_constant_map()` del logger para que un cambio ahi la ponga roja.
const NIVELES := ["Todos", "Debug", "Info", "Warning", "Error", "Critical"]
const CATEGORIAS := ["Todas", "Boot", "System", "Gameplay", "World", "Networking", "Analytics", "Crash"]
const TODOS := -1

var _rich_label: RichTextLabel = null
var _input_line: LineEdit = null
var _barra: HBoxContainer = null
var _opt_nivel: OptionButton = null
var _opt_categoria: OptionButton = null
var _txt_busqueda: LineEdit = null
var _chk_autoscroll: CheckBox = null
var _debug_menu: Node = null
var _logger: Node = null
## Entradas con metadato: {"nivel": int, "categoria": int, "linea": String}.
## nivel/categoria = TODOS (-1) significa "sin metadato" (lineas locales).
var _entradas: Array[Dictionary] = []
var _motivo: String = ""
var _filtros_aplicados := 0


func _ready() -> void:
	if _debug_menu == null:
		_debug_menu = get_node_or_null("/root/DebugMenu")
	if _logger == null:
		_logger = get_node_or_null("/root/GameLogger")
	# Construir UI programatica (headless-compatible)
	_rich_label = RichTextLabel.new()
	_rich_label.set_name("Consola")
	_rich_label.bbcode_enabled = true
	_rich_label.scroll_following = true
	_rich_label.custom_minimum_size = Vector2(400, 200)
	add_child(_rich_label)

	_construir_filtros()

	_input_line = LineEdit.new()
	_input_line.set_name("Entrada")
	_input_line.placeholder_text = "Escribir comando debug..."
	_input_line.custom_minimum_size = Vector2(400, 30)
	add_child(_input_line)
	_input_line.text_submitted.connect(_on_comando_sumbitido)

	# Snapshot inicial del backend (lineas sin metadato: nivel/categoria TODOS).
	if _debug_menu != null and _debug_menu.has_method("console_get_lines"):
		var existentes: Variant = _debug_menu.call("console_get_lines")
		if existentes is Array:
			for linea in (existentes as Array):
				_entradas.append({"nivel": TODOS, "categoria": TODOS, "linea": str(linea)})
			_recortar()

	# Lineas VIVAS: la senal que el backend realmente usa.
	if _logger != null and _logger.has_signal("line_emitted"):
		_logger.connect("line_emitted", _on_logger_line)
		_motivo = ""
	else:
		_motivo = "GameLogger no disponible: la consola no recibe lineas vivas"

	_restaurar_filtros()
	_refrescar_vista()


## ── Barra de filtros (§G L132-L135 / §H L147-L149) ─────────────────────────
func _construir_filtros() -> void:
	_barra = HBoxContainer.new()
	_barra.set_name("Filtros")
	_barra.add_theme_constant_override("separation", 6)
	add_child(_barra)

	_opt_nivel = OptionButton.new()
	_opt_nivel.set_name("FiltroNivel")
	for n in NIVELES:
		_opt_nivel.add_item(String(n))
	_opt_nivel.select(0)
	_opt_nivel.tooltip_text = "Filtrar por nivel de log"
	_barra.add_child(_opt_nivel)
	_opt_nivel.item_selected.connect(_on_nivel_cambiado)

	_opt_categoria = OptionButton.new()
	_opt_categoria.set_name("FiltroCategoria")
	for c in CATEGORIAS:
		_opt_categoria.add_item(String(c))
	_opt_categoria.select(0)
	_opt_categoria.tooltip_text = "Filtrar por categoria de log"
	_barra.add_child(_opt_categoria)
	_opt_categoria.item_selected.connect(_on_categoria_cambiada)

	_txt_busqueda = LineEdit.new()
	_txt_busqueda.set_name("FiltroBusqueda")
	_txt_busqueda.placeholder_text = "Buscar texto..."
	_txt_busqueda.custom_minimum_size = Vector2(180, 0)
	_txt_busqueda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_barra.add_child(_txt_busqueda)
	_txt_busqueda.text_changed.connect(_on_busqueda_cambiada)

	_chk_autoscroll = CheckBox.new()
	_chk_autoscroll.set_name("FiltroAutoScroll")
	_chk_autoscroll.text = "Auto-scroll"
	_chk_autoscroll.button_pressed = true
	_barra.add_child(_chk_autoscroll)
	_chk_autoscroll.toggled.connect(_on_autoscroll_cambiado)


func _on_nivel_cambiado(_indice: int) -> void:
	_al_cambiar_filtros()


func _on_categoria_cambiada(_indice: int) -> void:
	_al_cambiar_filtros()


func _on_busqueda_cambiada(_texto: String) -> void:
	_al_cambiar_filtros()


func _on_autoscroll_cambiado(_activo: bool) -> void:
	_al_cambiar_filtros()


func _al_cambiar_filtros() -> void:
	_sincronizar_backend()
	_refrescar_vista()


## ── Estado de filtros ──────────────────────────────────────────────────────
## Indice de OptionButton -> valor del backend (-1 = todos).
func nivel_filtro() -> int:
	if _opt_nivel == null:
		return TODOS
	return _opt_nivel.selected - 1


func categoria_filtro() -> int:
	if _opt_categoria == null:
		return TODOS
	return _opt_categoria.selected - 1


func busqueda_filtro() -> String:
	if _txt_busqueda == null:
		return ""
	return _txt_busqueda.text.strip_edges()


func autoscroll_activo() -> bool:
	if _chk_autoscroll == null:
		return true
	return _chk_autoscroll.button_pressed


## Estado completo de los filtros de la UI (para tests y persistencia).
func filtros_ui() -> Dictionary:
	return {
		"nivel": nivel_filtro(),
		"categoria": categoria_filtro(),
		"busqueda": busqueda_filtro(),
		"autoscroll": autoscroll_activo(),
	}


## Aplica filtros por programa (tests y restauracion desde el backend).
func aplicar_filtros(nivel: int, categoria: int, busqueda: String, autoscroll: bool) -> void:
	if _opt_nivel != null:
		_opt_nivel.select(clampi(nivel + 1, 0, NIVELES.size() - 1))
	if _opt_categoria != null:
		_opt_categoria.select(clampi(categoria + 1, 0, CATEGORIAS.size() - 1))
	if _txt_busqueda != null:
		_txt_busqueda.text = busqueda
	if _chk_autoscroll != null:
		_chk_autoscroll.button_pressed = autoscroll
	_al_cambiar_filtros()


## Empuja el estado al backend para que §N lo persista. Si no hay backend, no
## es un fallo: los filtros siguen funcionando en memoria.
func _sincronizar_backend() -> void:
	if _debug_menu == null or not _debug_menu.has_method("set_filtros_consola"):
		return
	_debug_menu.call("set_filtros_consola", filtros_ui())


func _restaurar_filtros() -> void:
	if _debug_menu == null or not _debug_menu.has_method("filtros_consola"):
		return
	var guardados: Variant = _debug_menu.call("filtros_consola")
	if not (guardados is Dictionary):
		return
	var d: Dictionary = guardados
	aplicar_filtros(
		int(d.get("nivel", TODOS)),
		int(d.get("categoria", TODOS)),
		String(d.get("busqueda", "")),
		bool(d.get("autoscroll", true))
	)


## ── Filtrado y render ──────────────────────────────────────────────────────
## Una entrada pasa si coincide en nivel, categoria y texto buscado.
## Una entrada SIN metadato (nivel/categoria TODOS) solo pasa cuando el filtro
## correspondiente esta en "todos": no se le inventa un nivel.
func _pasa(entrada: Dictionary) -> bool:
	var nivel := nivel_filtro()
	if nivel != TODOS and int(entrada.get("nivel", TODOS)) != nivel:
		return false
	var categoria := categoria_filtro()
	if categoria != TODOS and int(entrada.get("categoria", TODOS)) != categoria:
		return false
	var q := busqueda_filtro().to_lower()
	if q != "" and String(entrada.get("linea", "")).to_lower().find(q) < 0:
		return false
	return true


func _refrescar_vista() -> void:
	if _rich_label == null:
		return
	var html := ""
	for e in _entradas:
		if _pasa(e):
			html += String(e.get("linea", "")) + "\n"
	_rich_label.text = html
	_rich_label.scroll_following = autoscroll_activo()
	_filtros_aplicados += 1


func _recortar() -> void:
	while _entradas.size() > CONSOLA_MAX_LINEAS:
		_entradas.pop_front()


## ── Entrada de lineas ──────────────────────────────────────────────────────
## Handler de `GameLogger.line_emitted(level: int, category: int, line: String)`.
## Los tipos tienen que coincidir EXACTAMENTE: con un `String` en el primer
## argumento Godot imprime "Cannot convert argument 1 from int to String" y el
## handler nunca corre (defecto medido en debug_menu_ui.gd el 2026-11-01).
func _on_logger_line(level: int, category: int, linea: String) -> void:
	_agregar_entrada(linea, level, category)


func _agregar_entrada(texto: String, nivel: int, categoria: int) -> void:
	_entradas.append({"nivel": nivel, "categoria": categoria, "linea": texto})
	_recortar()
	_refrescar_vista()


func _agregar_linea(texto: String) -> void:
	_agregar_entrada(texto, TODOS, TODOS)


func _on_comando_sumbitido(texto: String) -> void:
	if texto.strip_edges().is_empty():
		return
	_input_line.text = ""
	# Ejecutar via el backend
	if _debug_menu != null and _debug_menu.has_method("ejecutar_comando"):
		var resultado: Variant = _debug_menu.call("ejecutar_comando", texto)
		if resultado is Dictionary:
			var r: Dictionary = resultado
			var msg := "-> " + str(r.get("comando", texto))
			if bool(r.get("ok", false)):
				_agregar_linea("[color=green]" + msg + " [ok][/color]")
			else:
				_agregar_linea("[color=red]" + msg + " [error: " + str(r.get("error", "")) + "][/color]")
		else:
			_agregar_linea("-> " + texto)
	else:
		_agregar_linea("[color=yellow]Debug Menu no disponible (headless o release)[/color]")


## ── API publica / ganchos de test ──────────────────────────────────────────
## Devuelve TODAS las lineas (contrato previo intacto).
func obtener_lineas() -> Array[String]:
	var salida: Array[String] = []
	for e in _entradas:
		salida.append(String(e.get("linea", "")))
	return salida


## Devuelve solo las lineas que pasan los filtros vigentes.
func lineas_visibles() -> Array[String]:
	var salida: Array[String] = []
	for e in _entradas:
		if _pasa(e):
			salida.append(String(e.get("linea", "")))
	return salida


## Texto que ve el usuario en el RichTextLabel (para tests de render real).
func texto_renderizado() -> String:
	if _rich_label == null:
		return ""
	return _rich_label.text


## Que widgets de filtro existen realmente (para tests).
func widgets_filtros() -> Dictionary:
	return {
		"nivel": _opt_nivel != null,
		"categoria": _opt_categoria != null,
		"busqueda": _txt_busqueda != null,
		"autoscroll": _chk_autoscroll != null,
	}


## Motivo por el que no hay lineas vivas ("" = si las hay).
func motivo_sin_vivas() -> String:
	return _motivo


## True si la consola esta suscrita a GameLogger.
func conectado_al_logger() -> bool:
	return _logger != null and _logger.has_signal("line_emitted") and _logger.is_connected("line_emitted", _on_logger_line)


## Limpia la consola.
func limpiar() -> void:
	_entradas.clear()
	_refrescar_vista()


## Tamano del historial.
func tamano() -> int:
	return _entradas.size()


## Devuelve si el debug menu backend esta conectado.
func backend_conectado() -> bool:
	return _debug_menu != null


## Agrega una linea publica (para el UI, no requiere backend).
func agregar_linea_publica(texto: String) -> void:
	_agregar_linea(texto)


## Setea el texto directamente (para el UI, cambia la vista completa).
## Se conserva por compatibilidad; el UI ya no lo usa para rotular pestañas.
func set_text(html: String) -> void:
	if _rich_label != null:
		_rich_label.text = html


## Inyeccion de dependencias para tests (antes de entrar al arbol).
func _inyectar_backend(nodo: Node) -> void:
	_debug_menu = nodo


func _inyectar_logger(nodo: Node) -> void:
	_logger = nodo
