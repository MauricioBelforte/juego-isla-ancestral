# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M21: WorldStateService — capa unica de acceso al estado del mundo para
# condiciones/efectos de dialogo (RF5, seccion 3/6 de 03-Diseno.md).
# NO duplica estado: DELEGA en los autoloads existentes (TimeCalendar M29,
# GameTime M30, Friendship M20, EventBus M07) y guarda SOLO banderas propias
# del sistema de dialogo (flag_*) como proveedor de guardado M59.
# ⚠️ Sin class_name: es autoload (pitfall documentado en 07-GUIA-GODOT §9.17/§9.41).

extends Node

## Claves de condicion soportadas (prefijo → fuente):
##   hora:int, minuto:int, dia:int, mes:int, anio:int, estacion:int (0-3),
##   es_de_dia:bool, es_noche:bool, dia_absoluto:int        → TimeCalendar (M29)
##   amistad_<npc_id>:int                                    → Friendship.get_nivel (M20)
##   clima:String                                             → M32 (placeholder, "" si no existe)
##   flag_<clave>:Variant                                     → banderas propias persistibles (M59)

const SECCION_SAVE := "world_state_dialogos"

var _banderas: Dictionary = {}

func _ready() -> void:
	_registrar_proveedor_guardado()

## ── API publica ──────────────────────────────────────────

## Resuelve una clave de condicion. Devuelve `default` si no existe.
func get_value(clave: String, default: Variant = null) -> Variant:
	if clave.begins_with("flag_"):
		return _banderas.get(clave, default)
	var tc := get_node_or_null("/root/TimeCalendar")
	if tc == null:
		return default
	match clave:
		"hora":
			return tc.get_hora()
		"minuto":
			return tc.get_minuto()
		"dia":
			return tc.get_fecha().get("dia", 1)
		"mes":
			return tc.get_fecha().get("mes", 1)
		"anio":
			return tc.get_fecha().get("anio", 1)
		"estacion":
			return tc.get_estacion()
		"es_de_dia":
			return tc.es_de_dia()
		"es_noche":
			return tc.es_noche()
		"dia_absoluto":
			return tc.get_dia_absoluto()
		"clima":
			return _get_clima()
	if clave.begins_with("amistad_"):
		return _get_amistad(clave.trim_prefix("amistad_"), default)
	return default

## Snapshot de varias claves en una sola consulta.
func get_snapshot(claves: Array) -> Dictionary:
	var snap := {}
	for clave in claves:
		snap[str(clave)] = get_value(str(clave))
	return snap

## ── Banderas propias (persistibles via M59) ─────────────

func set_flag(clave: String, valor: Variant) -> void:
	if not clave.begins_with("flag_"):
		clave = "flag_" + clave
	_banderas[clave] = valor

func get_flag(clave: String, default: Variant = null) -> Variant:
	if not clave.begins_with("flag_"):
		clave = "flag_" + clave
	return _banderas.get(clave, default)

func has_flag(clave: String) -> bool:
	if not clave.begins_with("flag_"):
		clave = "flag_" + clave
	return _banderas.has(clave)

## ── Internos ─────────────────────────────────────────────

func _get_amistad(npc_id: String, default: Variant) -> Variant:
	var fs := get_node_or_null("/root/Friendship")
	if fs == null or not fs.has_method("get_nivel"):
		return default
	return int(fs.get_nivel(npc_id))

## M32 (Clima): delega en WeatherService autoload (núcleo determinista, glm-5.3-flash).
func _get_clima() -> String:
	var w := get_node_or_null("/root/Weather")
	if w == null or not w.has_method("get_nombre_clima"):
		return ""
	return str(w.get_nombre_clima())

## ── Persistencia (ISaveProvider M59) ─────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	return {"banderas": _banderas.duplicate(true)}

func restore_save_data(data: Dictionary) -> void:
	_banderas.clear()
	var bd: Dictionary = data.get("banderas", {})
	for clave in bd:
		_banderas[str(clave)] = bd[clave]
