# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-11-01 (creacion) - 2026-11-02 (base comun)
# M110-UI: Panel Mundo — widgets REALES del 03-Diseno (seccion D).
# Antes de esta tanda el "panel" era un RichTextLabel con el texto
# "Panel: Mundo" (debug_menu_ui.gd:_on_tab_changed): 0 widgets.
#
# Cada widget cablea a una funcion PUBLICA del backend (debug_menu.gd):
#   Label hora        -> hora_actual()
#   OptionButton est. -> set_season(int)
#   OptionButton clim -> set_weather(int)
#   LineEdit seed     -> seed_generacion() (lectura)
#   Button Aplicar    -> aplicar_seed(int)          [NUEVO en el backend]
#   SpinBox chunk X/Z -> regenerar_chunk(cx, cz)
#
# Fail-closed: sin backend los widgets se construyen igual (se pueden medir),
# pero las acciones devuelven ok=false y NO inventan estado.
#
# 2026-11-02: hereda de `PanelBaseM110` (`scripts/debug/panel_base.gd`). Lo que
# se fue a la base: `_menu`, `_ultimo`, `_ready()`, `_llamar()`,
# `_inyectar_menu()`, `ultimo_resultado()`. Lo propio sigue aqui: los 8 widgets,
# los catalogos de estacion/clima y el cableado a las funciones del backend.
extends "res://scripts/debug/panel_base.gd"

const PANEL_ID := "mundo"
## set_weather() clampea a 0..10 (debug_menu.gd:976). El enum Clima de
## weather_service.gd tiene 9 miembros: 0..8. Se piden 9 y el 9/10 solo
## existen como "solicitud" (el clima real es determinista, M31/M32 deciden).
const CLIMAS_ENUM := 9
const ESTACIONES_FALLBACK := ["Primavera", "Verano", "Otoño", "Invierno"]

var _label_hora: Label = null
var _opt_estacion: OptionButton = null
var _opt_clima: OptionButton = null
var _input_seed: LineEdit = null
var _btn_seed: Button = null
var _spin_cx: SpinBox = null
var _spin_cz: SpinBox = null
var _btn_regen: Button = null
var _nombres_clima: Array[String] = []


func _construir() -> void:
	_label_hora = _crear_label("HoraActual", "Hora: --")

	_opt_estacion = _crear_option("SelectorEstacion", "Solicita estación (M29/M31 deciden)")

	_opt_clima = _crear_option("SelectorClima", "Solicita clima (determinista: M31/M32 deciden)")

	_input_seed = LineEdit.new()
	_input_seed.set_name("InputSeed")
	_input_seed.placeholder_text = "seed (entero)"
	add_child(_input_seed)

	_btn_seed = _crear_boton("BotonAplicarSeed", "Aplicar seed")

	_spin_cx = _crear_spin("ChunkX", -512.0, 512.0)
	_spin_cz = _crear_spin("ChunkZ", -512.0, 512.0)

	_btn_regen = _crear_boton("BotonRegenerar", "Regenerar")


func _poblar() -> void:
	var estaciones: Array[String] = _nombres_estaciones()
	for i in range(estaciones.size()):
		_opt_estacion.add_item(estaciones[i], i)
	_nombres_clima = _nombres_de_clima()
	for i in range(_nombres_clima.size()):
		_opt_clima.add_item(_nombres_clima[i], i)


func _conectar() -> void:
	_opt_estacion.item_selected.connect(_on_estacion_elegida)
	_opt_clima.item_selected.connect(_on_clima_elegido)
	_btn_seed.pressed.connect(_on_aplicar_seed)
	_btn_regen.pressed.connect(_on_regenerar)


## Nombres de estacion del nucleo (M29). Si el autoload no esta, el catalogo
## literal del propio game_clock.gd:26 (4 estaciones, indices 0..3).
func _nombres_estaciones() -> Array[String]:
	var out: Array[String] = []
	var reloj := get_node_or_null("/root/GameClock")
	if reloj == null:
		reloj = get_node_or_null("/root/GameTime")
	if reloj != null and "NOMBRES_ESTACIONES" in reloj:
		var v: Variant = reloj.get("NOMBRES_ESTACIONES")
		if v is Array:
			for x in (v as Array):
				out.append(String(x))
	if out.is_empty():
		for n in ESTACIONES_FALLBACK:
			out.append(String(n))
	return out


## Nombres de clima (M31). `get_nombre_clima(i)` devuelve "" fuera de rango:
## se corta en el primer vacio para no inventar opciones.
func _nombres_de_clima() -> Array[String]:
	var out: Array[String] = []
	var clima := get_node_or_null("/root/Weather")
	if clima == null or not clima.has_method("get_nombre_clima"):
		return out
	for i in range(CLIMAS_ENUM):
		var n: String = String(clima.call("get_nombre_clima", i))
		if n.is_empty():
			break
		out.append(n)
	return out


## Sincroniza la VISTA con el estado real del backend. Nunca al reves: el
## widget no es fuente de verdad de la hora ni del clima.
func _actualizar() -> void:
	if _menu == null:
		_label_hora.text = "Hora: n/d (DebugMenu no disponible)"
		return
	var hora: int = -1
	if _menu.has_method("hora_actual"):
		var h: Variant = _menu.call("hora_actual")
		if typeof(h) == TYPE_INT:
			hora = int(h)
	if hora < 0:
		_label_hora.text = "Hora: n/d (M29 no disponible)"
	else:
		_label_hora.text = "Hora: %02d:00" % hora
	# Seed actual: -1 es el centinela de "sin generador" (ENTORNO_NO_DISPONIBLE).
	if _menu.has_method("seed_generacion"):
		var s: Variant = _menu.call("seed_generacion")
		if typeof(s) == TYPE_INT and int(s) >= 0:
			_input_seed.text = str(int(s))
		else:
			_input_seed.text = ""


func _on_estacion_elegida(idx: int) -> void:
	_ultimo = _llamar("set_season", [idx])


func _on_clima_elegido(idx: int) -> void:
	_ultimo = _llamar("set_weather", [idx])


func _on_aplicar_seed() -> void:
	var txt: String = _input_seed.text.strip_edges()
	if not txt.is_valid_int():
		_ultimo = {"ok": false, "resultado": "seed invalida: '%s'" % txt}
		return
	_ultimo = _llamar("aplicar_seed", [int(txt)])
	refrescar()


func _on_regenerar() -> void:
	var cx: int = int(_spin_cx.value)
	var cz: int = int(_spin_cz.value)
	_ultimo = _llamar("regenerar_chunk", [cx, cz])


# ── Getters para la suite (evitan depender de rutas de nodo) ────────────────

func obtener_label_hora() -> Label:
	return _label_hora

func obtener_selector_estacion() -> OptionButton:
	return _opt_estacion

func obtener_selector_clima() -> OptionButton:
	return _opt_clima

func obtener_input_seed() -> LineEdit:
	return _input_seed

func obtener_boton_seed() -> Button:
	return _btn_seed

func obtener_spin_cx() -> SpinBox:
	return _spin_cx

func obtener_spin_cz() -> SpinBox:
	return _spin_cz

func obtener_boton_regenerar() -> Button:
	return _btn_regen

func nombres_clima() -> Array[String]:
	return _nombres_clima.duplicate()

## Conteo de widgets exigidos por la seccion D del 03-Diseno.
func widgets_presentes() -> Dictionary:
	return {
		"label_hora": _label_hora != null,
		"dropdown_estacion": _opt_estacion != null,
		"dropdown_clima": _opt_clima != null,
		"input_seed": _input_seed != null,
		"boton_aplicar_seed": _btn_seed != null,
		"input_chunk_x": _spin_cx != null,
		"input_chunk_z": _spin_cz != null,
		"boton_regenerar": _btn_regen != null,
	}
