# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M57: Interfaz de Control — ControlInput (autoload "ControlInput")
# Capa unica de acciones (RF2): todo gameplay lee acciones por nombre.
# Envuelve el InputMap de Godot 4 (M04) y agrega:
#   - Deteccion de dispositivo activo (RF7) con señal dispositivo_cambiado
#   - Remapeo en caliente con deteccion de conflictos (RF3, RF5)
#   - Ajustes: sensibilidad, inversion, dead zones, vibracion (RF4)
#   - Persistencia atómica JSON en user://settings/controls.cfg (RF8)
# ⚠️ Sin class_name: es autoload (pitfall documentado en 07-GUIA-GODOT §9.17/§9.41).

extends Node

signal dispositivo_cambiado(modo: String)

const RUTA_CONFIG := "user://settings/controls.cfg"
const RUTA_TMP := "user://settings/controls.tmp"
const RUTA_BACKUP := "user://settings/controls.cfg.bak"

const MODO_TECLADO := "teclado"
const MODO_RATON := "raton"
const MODO_XBOX := "xbox"
const MODO_PLAYSTATION := "playstation"
const MODO_GENERICO := "generico"

## Acciones de gameplay que este modulo reconoce (RF5 atajos).
const ACCIONES_CATALOGO := [
	"mover_norte", "mover_sur", "mover_este", "mover_oeste",
	"interactuar", "inventario", "pausa", "colocar",
	"favorito", "hotbar_1", "hotbar_2", "hotbar_3", "hotbar_4",
	"hotbar_5", "hotbar_6", "hotbar_7", "hotbar_8", "hotbar_9",
]

## Dead zones por defecto (seccion 6 del diseno).
const DEADZONE_PALANCA_IZQ := 0.15
const DEADZONE_PALANCA_DER := 0.20
const DEADZONE_GATILLO := 0.10

var _modo_activo: String = MODO_TECLADO
var _ultimo_pad_id: int = -1
var _pad_nombre: String = ""

## Ajustes (RF4) con defaults.
var sensibilidad_x: float = 1.0
var sensibilidad_y: float = 1.0
var invertir_x: bool = false
var invertir_y: bool = false
var deadzone_palanca_izq: float = DEADZONE_PALANCA_IZQ
var deadzone_palanca_der: float = DEADZONE_PALANCA_DER
var deadzone_gatillo: float = DEADZONE_GATILLO
var vibracion_on: bool = true
var vibracion_intensidad: float = 0.6  # 0..1
var vibracion_duracion: float = 0.25   # seg

func _ready() -> void:
	_cargar_config()

## ── Acciones (RF2) ───────────────────────────────────────

## Consulta si una accion esta presionada (sin escanear scancodes en gameplay).
func accion_presionada(accion: String) -> bool:
	return Input.is_action_pressed(accion)

func accion_justa(accion: String) -> bool:
	return Input.is_action_just_pressed(accion)

## Eje normalizado de una accion (palancas) con dead zone aplicada.
func eje(accion: String) -> float:
	var valor := Input.get_action_strength(accion)
	var dead := deadzone_palanca_izq
	return _aplicar_deadzone(valor, dead)

## Vector de movimiento 2D combinando las 4 acciones direccionales.
func vector_movimiento() -> Vector2:
	var v := Input.get_vector("mover_este", "mover_oeste", "mover_sur", "mover_norte")
	return _aplicar_deadzone_vector(v)

## Ejes de camara con sensibilidad e inversion aplicadas (RF4).
func ejes_camara(delta: Vector2) -> Vector2:
	var out := delta
	out.x *= sensibilidad_x
	out.y *= sensibilidad_y
	if invertir_x:
		out.x = -out.x
	if invertir_y:
		out.y = -out.y
	return out

func _aplicar_deadzone(v: float, dead: float) -> float:
	if absf(v) < dead:
		return 0.0
	return v

func _aplicar_deadzone_vector(v: Vector2) -> Vector2:
	if v.length() < deadzone_palanca_izq:
		return Vector2.ZERO
	return v

## ── Deteccion de dispositivo (RF7) ───────────────────────

func dispositivo_activo() -> String:
	return _modo_activo

func _unhandled_input(event: InputEvent) -> void:
	var nuevo_modo: String = _modo_activo
	if event is InputEventKey:
		nuevo_modo = MODO_TECLADO
	elif event is InputEventMouseButton or event is InputEventMouseMotion:
		nuevo_modo = MODO_RATON
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var pad_id := event.device
		if pad_id != _ultimo_pad_id:
			_ultimo_pad_id = pad_id
			_pad_nombre = Input.get_joy_name(pad_id).to_lower()
		nuevo_modo = _detectar_pad(_pad_nombre)
	if nuevo_modo != _modo_activo:
		_modo_activo = nuevo_modo
		dispositivo_cambiado.emit(_modo_activo)

func _detectar_pad(nombre_lower: String) -> String:
	if nombre_lower.contains("xbox") or nombre_lower.contains("xinput"):
		return MODO_XBOX
	if nombre_lower.contains("playstation") or nombre_lower.contains("dualshock") or nombre_lower.contains("dual sense"):
		return MODO_PLAYSTATION
	if nombre_lower.contains("nintendo") or nombre_lower.contains("switch") or nombre_lower.contains("steam deck"):
		return MODO_GENERICO
	return MODO_GENERICO

## Nombre legible del boton actual para una accion (para prompts UI).
func etiqueta_accion(accion: String) -> String:
	if _modo_activo == MODO_TECLADO:
		return _etiqueta_teclado(accion)
	if _modo_activo == MODO_RATON:
		return _etiqueta_raton(accion)
	return _etiqueta_mando(accion)

func _etiqueta_teclado(accion: String) -> String:
	var eventos: Array = InputMap.action_get_events(accion)
	for ev in eventos:
		if ev is InputEventKey:
			return OS.get_keycode_string(ev.physical_keycode)
	return "?"

func _etiqueta_raton(accion: String) -> String:
	var eventos: Array = InputMap.action_get_events(accion)
	for ev in eventos:
		if ev is InputEventMouseButton:
			return "Mouse" + str(ev.button_index)
	return "?"

func _etiqueta_mando(accion: String) -> String:
	var eventos: Array = InputMap.action_get_events(accion)
	for ev in eventos:
		if ev is InputEventJoypadButton:
			return "Btn" + str(ev.button_index)
		if ev is InputEventJoypadMotion:
			return "Eje" + str(ev.axis)
	return "?"

## ── Remapeo (RF3) ────────────────────────────────────────

## Remapea una accion a un evento. Devuelve false si hay conflicto.
func remapear(accion: String, evento: InputEvent) -> bool:
	if hay_conflicto(accion, evento):
		return false
	InputMap.action_erase_event(accion, evento)
	InputMap.action_add_event(accion, evento)
	_guardar_config()
	return true

## True si el evento ya esta asignado a otra accion distinta.
func hay_conflicto(accion: String, evento: InputEvent) -> bool:
	for otra in ACCIONES_CATALOGO:
		if otra == accion:
			continue
		for ev in InputMap.action_get_events(otra):
			if _eventos_equivalentes(ev, evento):
				return true
	return false

func _eventos_equivalentes(a: InputEvent, b: InputEvent) -> bool:
	if a is InputEventKey and b is InputEventKey:
		return a.physical_keycode != 0 and a.physical_keycode == b.physical_keycode
	if a is InputEventJoypadButton and b is InputEventJoypadButton:
		return a.button_index == b.button_index
	if a is InputEventMouseButton and b is InputEventMouseButton:
		return a.button_index == b.button_index
	if a is InputEventJoypadMotion and b is InputEventJoypadMotion:
		return a.axis == b.axis
	return false

## Restaura los defaults de todas las acciones (borra remapeos de usuario).
func restaurar_defaults() -> void:
	for accion in ACCIONES_CATALOGO:
		_restaurar_accion(accion)
	sensibilidad_x = 1.0
	sensibilidad_y = 1.0
	invertir_x = false
	invertir_y = false
	deadzone_palanca_izq = DEADZONE_PALANCA_IZQ
	deadzone_palanca_der = DEADZONE_PALANCA_DER
	deadzone_gatillo = DEADZONE_GATILLO
	vibracion_on = true
	vibracion_intensidad = 0.6
	vibracion_duracion = 0.25
	_guardar_config()

func _restaurar_accion(accion: String) -> void:
	# Borra todos los eventos; los defaults reales vuelven al recargar la escena
	# porque estan en project.godot [input]. Aqui solo limpiamos remapeos.
	var eventos := InputMap.action_get_events(accion).duplicate()
	for ev in eventos:
		InputMap.action_erase_event(accion, ev)

## ── Vibracion (RF4) ──────────────────────────────────────

func vibrar(intensidad: float = 0.5, duracion: float = 0.25) -> void:
	if not vibracion_on:
		return
	if Input.get_connected_joypads().is_empty():
		return
	var amp := clampf(intensidad * vibracion_intensidad, 0.0, 1.0)
	for pad in Input.get_connected_joypads():
		Input.start_joy_vibration(pad, amp, amp, duracion)

## ── Persistencia atómica (RF8) ───────────────────────────

func _guardar_config() -> void:
	var dir := "user://settings"
	DirAccess.make_dir_recursive_absolute(dir)
	var data := _serializar()
	var tmp := FileAccess.open(RUTA_TMP, FileAccess.WRITE)
	if tmp == null:
		push_warning("[M57] No se pudo abrir tmp config")
		return
	tmp.store_string(JSON.stringify(data, "\t"))
	tmp.close()
	# Backup del archivo previo si existe
	if FileAccess.file_exists(RUTA_CONFIG):
		DirAccess.rename_absolute(RUTA_CONFIG, RUTA_BACKUP)
	# Rename atomico
	var err := DirAccess.rename_absolute(RUTA_TMP, RUTA_CONFIG)
	if err != OK:
		push_warning("[M57] No se pudo renombrar config")

func _cargar_config() -> void:
	if not FileAccess.file_exists(RUTA_CONFIG):
		return
	var f := FileAccess.open(RUTA_CONFIG, FileAccess.READ)
	if f == null:
		push_warning("[M57] No se pudo leer config; usando defaults")
		return
	var texto := f.get_as_text()
	var parsed = JSON.parse_string(texto)
	if not (parsed is Dictionary):
		push_warning("[M57] Config JSON invalida; usando defaults")
		return
	_aplicar_serializado(parsed)

func _serializar() -> Dictionary:
	var bindings := {}
	for accion in ACCIONES_CATALOGO:
		var eventos: Array = InputMap.action_get_events(accion)
		if eventos.is_empty():
			continue
		var lista := []
		for ev in eventos:
			lista.append(_evento_a_dict(ev))
		bindings[accion] = lista
	return {
		"version": 1,
		"bindings": bindings,
		"ajustes": {
			"sensibilidad_x": sensibilidad_x,
			"sensibilidad_y": sensibilidad_y,
			"invertir_x": invertir_x,
			"invertir_y": invertir_y,
			"deadzone_palanca_izq": deadzone_palanca_izq,
			"deadzone_palanca_der": deadzone_palanca_der,
			"deadzone_gatillo": deadzone_gatillo,
			"vibracion_on": vibracion_on,
			"vibracion_intensidad": vibracion_intensidad,
			"vibracion_duracion": vibracion_duracion,
		},
	}

func _aplicar_serializado(data: Dictionary) -> void:
	if data.has("bindings") and data["bindings"] is Dictionary:
		for accion in data["bindings"]:
			if not InputMap.has_action(accion):
				continue
			for ev_dict in data["bindings"][accion]:
				var ev := _dict_a_evento(ev_dict)
				if ev != null:
					InputMap.action_add_event(accion, ev)
	if data.has("ajustes") and data["ajustes"] is Dictionary:
		var a: Dictionary = data["ajustes"]
		sensibilidad_x = float(a.get("sensibilidad_x", 1.0))
		sensibilidad_y = float(a.get("sensibilidad_y", 1.0))
		invertir_x = bool(a.get("invertir_x", false))
		invertir_y = bool(a.get("invertir_y", false))
		deadzone_palanca_izq = float(a.get("deadzone_palanca_izq", DEADZONE_PALANCA_IZQ))
		deadzone_palanca_der = float(a.get("deadzone_palanca_der", DEADZONE_PALANCA_DER))
		deadzone_gatillo = float(a.get("deadzone_gatillo", DEADZONE_GATILLO))
		vibracion_on = bool(a.get("vibracion_on", true))
		vibracion_intensidad = float(a.get("vibracion_intensidad", 0.6))
		vibracion_duracion = float(a.get("vibracion_duracion", 0.25))

func _evento_a_dict(ev: InputEvent) -> Dictionary:
	if ev is InputEventKey:
		return {"tipo": "tecla", "keycode": ev.physical_keycode}
	if ev is InputEventJoypadButton:
		return {"tipo": "boton", "index": ev.button_index}
	if ev is InputEventMouseButton:
		return {"tipo": "raton", "index": ev.button_index}
	if ev is InputEventJoypadMotion:
		return {"tipo": "eje", "index": ev.axis}
	return {}

func _dict_a_evento(d: Dictionary) -> InputEvent:
	match str(d.get("tipo", "")):
		"tecla":
			var k := InputEventKey.new()
			k.physical_keycode = int(d.get("keycode", 0))
			return k
		"boton":
			var b := InputEventJoypadButton.new()
			b.button_index = int(d.get("index", 0)) as JoyButton
			return b
		"raton":
			var m := InputEventMouseButton.new()
			m.button_index = int(d.get("index", 0)) as MouseButton
			return m
		"eje":
			var j := InputEventJoypadMotion.new()
			j.axis = int(d.get("index", 0)) as JoyAxis
			return j
	return null
