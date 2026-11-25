extends Node

var _gl: Node = null

## Mapea el nombre de categoria (String) al enum Category de GameLogger (int).
const _CAT := {"BOOT": 0, "SYSTEM": 1, "GAMEPLAY": 2, "WORLD": 3, "NETWORKING": 4, "ANALYTICS": 5, "CRASH": 6}

func _cat(cat: String) -> int:
	return int(_CAT.get(cat, 1))

func _log_debug(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.debug(msg, _cat(cat), ctx)

func _log_info(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.info(msg, _cat(cat), ctx)

func _log_warning(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.warning(msg, _cat(cat), ctx)

func _log_error(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.error(msg, _cat(cat), ctx)

func _log_critical(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.critical(msg, _cat(cat), ctx)

## CruceroEventos — Módulo 169: actividades a bordo.
##
## Engancha las 5 actividades del crucero con M74 (EventManager). NO reimplementa el
## sistema de eventos: usa `puede_participar` / `iniciar_participacion` / `finalizar_evento`.
##
## Responsabilidades propias:
##   - límite diario por actividad (para que no se farmee)
##   - bloqueo por clima severo (M32) en las actividades de exterior
##   - enrutar el premio a M38 (monedas)
##
## Uso:
##   CruceroEventos.puede_jugar("crucero_casino_cartas")  -> Dictionary
##   CruceroEventos.finalizar("crucero_casino_cartas", {"exito": true, "premio": 40})

signal actividad_disponible(id: StringName)
signal actividad_jugada(id: StringName, exito: bool, premio: int)

const RUTA_JUEGOS := "res://data/crucero/juegos_a_bordo.json"
const PREFIJO_LOG := "[CRU-EVT]"

## Actividades ya jugadas hoy: id -> veces.
var _jugadas_hoy: Dictionary = {}
## Día del último conteo (para resetear al cambiar de día).
var _dia_control: int = -1


func _ready() -> void:
	_gl = get_node_or_null("/root/GameLogger")
	_cargar_catalogo()


func _cargar_catalogo() -> void:
	if not FileAccess.file_exists(RUTA_JUEGOS):
		_log_error("%s no existe %s" % [PREFIJO_LOG, RUTA_JUEGOS], "SYSTEM")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_JUEGOS))
	if typeof(parsed) != TYPE_DICTIONARY:
		_log_error("%s JSON invalido en %s" % [PREFIJO_LOG, RUTA_JUEGOS], "SYSTEM")
		return
	var lista: Variant = (parsed as Dictionary).get("actividades", [])
	_actividades.clear()
	for item: Variant in (lista as Array):
		if typeof(item) == TYPE_DICTIONARY:
			var d: Dictionary = item
			_actividades[String(d.get("id", &""))] = d
	_log_info("%s %d actividades cargadas" % [PREFIJO_LOG, _actividades.size()], "GAMEPLAY")


var _actividades: Dictionary = {}


func actividades() -> Array:
	return _actividades.keys()


func info_actividad(id: StringName) -> Dictionary:
	return _actividades.get(id, {})


func _chequear_dia() -> void:
	# M169/CI: ver la nota de crucero_manager.vender_pasaje() — el autoload se
	# resuelve por nodo para que `--check-only --script` (gate de CI) compile.
	var t := get_node_or_null("/root/TimeCalendar")
	var dia := 0
	if t != null and t.has_method("dia_trascurrido"):
		dia = int(t.dia_trascurrido())
	if dia != _dia_control:
		_dia_control = dia
		_jugadas_hoy.clear()


func veces_jugadas(id: StringName) -> int:
	return int(_jugadas_hoy.get(id, 0))


## ¿Se puede jugar esta actividad ahora?
func puede_jugar(id: StringName) -> Dictionary:
	_chequear_dia()
	var info: Dictionary = info_actividad(id)
	if info.is_empty():
		return {"ok": false, "motivo": "actividad_desconocida"}

	var limite := int(info.get("limite_diario", 1))
	if veces_jugadas(id) >= limite:
		return {"ok": false, "motivo": "limite_diario"}

	var clima := _clima_actual()
	var bloqueantes: Variant = _catalogo_bloqueantes()
	if clima in (bloqueantes as Array):
		return {"ok": false, "motivo": "clima_severo"}

	return {"ok": true, "motivo": "", "premio_max": int(info.get("premio_max", 0))}


var _bloqueantes: Array = []

func _catalogo_bloqueantes() -> Array:
	if _bloqueantes.is_empty():
		# [3, 7] son los climas adversos de M68 (CLIMAS_ADVERSOS)
		_bloqueantes = [3, 7]
	return _bloqueantes


func _clima_actual() -> int:
	var tp = get_node_or_null("/root/TransportManager")
	if tp != null and tp.has_method("forzar_contexto"):
		var ctx: Dictionary = tp.contexto_de_viaje()
		return int(ctx.get("clima", 0))
	return 0


## Cierra la actividad: suma el conteo diario y avisa a M74.
func finalizar(id: StringName, resultado: Dictionary) -> void:
	_chequear_dia()
	var exito := bool(resultado.get("exito", false))
	var premio := int(resultado.get("premio", 0))
	var tope := int(info_actividad(id).get("premio_max", 0))
	if premio > tope:
		premio = tope

	_jugadas_hoy[id] = veces_jugadas(id) + 1
	actividad_jugada.emit(id, exito, premio)

	# M74 (EventManager) esta registrado como autoload `eventos` en project.godot.
	# `finalizar_evento` hace no-op si el id no esta en su catalogo (los minijuegos
	# del crucero no son festivales), por eso la conexion es segura.
	var em = get_node_or_null("/root/eventos")
	if em == null:
		em = get_node_or_null("/root/EventManager")
	if em != null and em.has_method("finalizar_evento"):
		em.finalizar_evento(id, {"exito": exito, "premio": premio})

	_log_info("%s %s -> exito=%s premio=%d" % [PREFIJO_LOG, id, str(exito), premio], "GAMEPLAY")