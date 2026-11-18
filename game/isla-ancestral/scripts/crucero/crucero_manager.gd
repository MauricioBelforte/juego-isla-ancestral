extends Node

_func _GL():
	var gl = get_node_or_null("/root/GameLogger")
	if gl != null:
		return gl
	return _FallbackLog.new()

class _FallbackLog:
	func debug(msg, cat="", ctx={}): pass
	func info(msg, cat="", ctx={}): pass
	func warning(msg, cat="", ctx={}): pass
	func error(msg, cat="", ctx={}): pass
	func critical(msg, cat="", ctx={}): pass
## CruceroManager — Módulo 169 (Crucero Real).
##
## El crucero es el VIAJE ENTRE ISLAS + una aventura a bordo. NO reimplementa transporte:
## las rutas, los horarios, la temporada y el cobro del pasaje son de M68 (TransportManager).
## Este manager solo agrega: presencia del buque, estado del viaje, cubierta actual y camarote.
##
## Arquitectura:
##   CruceroManager (este autoload)
##     ├── TransportManager (M68)  → rutas / buy_ticket / temporada
##     ├── EventManager     (M74)  → minijuegos a bordo
##     ├── CargasManager    (M63)  → streaming de cubiertas
##     ├── GameState        (M59)  → persistencia
##     └── GameLogger              → logging

signal embarque(cubierta: int)
signal desembarco(destino: String)
signal zarpe(origen: String, destino: String)
signal llegada(puerto: String)
signal cambio_cubierta(cubierta: int)
signal pasaje_comprado(clase: String, precio: int)

enum Estado { ATRACADO, ABORDO, NAVEGANDO, EMERGENCIA }

const PREFIJO_LOG := "[CRU]"
const RUTA_PASAJES := "res://data/crucero/pasajes.json"
const RUTA_CAMAROTES := "res://data/crucero/camarotes.json"
const CUBIERTA_MIN := 1
const CUBIERTA_MAX := 4

## Estado del viaje.
var estado: Estado = Estado.ATRACADO
## Cubierta en la que está el jugador (1..4).
var cubierta_actual: int = 1
## Id del camarote asignado ("" si no hay).
var camarote_asignado: StringName = &""
## Pasaje en curso.
var pasaje_actual: PasajeCrucero = null
## Ruta de M68 asociada al crucero ("" = la que corresponda).
var route_id: StringName = &""

var _clases: Dictionary = {}      ## id -> Dictionary (pasajes.json)
var _camarotes: Dictionary = {}   ## id -> Dictionary (camarotes.json)


func _ready() -> void:
	_cargar_catalogos()


func _cargar_catalogos() -> void:
	_clases = _leer_json(RUTA_PASAJES, "clases")
	_camarotes = _leer_json(RUTA_CAMAROTES, "camarotes")
	_GL().info("%s catalogos cargados: %d clases, %d camarotes" % [PREFIJO_LOG, _clases.size(), _camarotes.size()], _GL().Category.GAMEPLAY)


func _leer_json(ruta: String, clave: String) -> Dictionary:
	var out := {}
	if not FileAccess.file_exists(ruta):
		_GL().error("%s no existe %s" % [PREFIJO_LOG, ruta], _GL().Category.SYSTEM)
		return out
	var txt := FileAccess.get_file_as_string(ruta)
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		_GL().error("%s JSON invalido en %s" % [PREFIJO_LOG, ruta], _GL().Category.SYSTEM)
		return out
	var lista: Variant = (parsed as Dictionary).get(clave, [])
	if typeof(lista) != TYPE_ARRAY:
		return out
	for item: Variant in (lista as Array):
		if typeof(item) == TYPE_DICTIONARY:
			var d: Dictionary = item
			out[d.get("id", &"")] = d
	return out

# ------------------------------------------------------------------ consultas

func clases_disponibles() -> Array:
	return _clases.keys()

func camarotes_disponibles() -> Array:
	return _camarotes.keys()

func info_clase(clase: StringName) -> Dictionary:
	return _clases.get(clase, {})

func info_camarote(id: StringName) -> Dictionary:
	return _camarotes.get(id, {})

func precio_de(clase: StringName) -> int:
	return int(info_clase(clase).get("precio", 0))

func puede_embarcar() -> bool:
	if estado != Estado.ATRACADO and estado != Estado.ABORDO:
		return false
	return pasaje_actual != null and not pasaje_actual.esta_vacio()

# ------------------------------------------------------------------ ciclo

## Compra el pasaje y reserva el camarote.
## El COBRO lo hace M68 (TransportManager.buy_ticket): no se cobra dos veces.
func vender_pasaje(clase: StringName, route_id_: StringName, origen: StringName, destino: StringName) -> Dictionary:
	if not _clases.has(clase):
		return {"ok": false, "motivo": "clase_desconocida"}
	if not TransportManager.tiene_red():
		return {"ok": false, "motivo": "sin_red"}

	var resultado: Dictionary = TransportManager.buy_ticket(route_id_, origen)
	if not bool(resultado.get("ok", false)):
		return resultado

	var cam := _siguiente_camarote(clase)
	var p := PasajeCrucero.new()
	p.route_id = route_id_
	p.stop_id_origen = origen
	p.stop_id_destino = destino
	p.clase = clase
	p.camarote = cam
	p.precio = int(resultado.get("precio", precio_de(clase)))
	p.cubierta = 2 if cam != &"suite_duo" else 3
	p.fecha_compra = TimeCalendar.fecha_actual() if TimeCalendar.has_method("fecha_actual") else {}
	pasaje_actual = p
	camarote_asignado = cam
	estado = Estado.ABORDO
	pasaje_comprado.emit(String(clase), p.precio)
	_GL().info("%s pasaje vendido: %s -> %s (%s)" % [PREFIJO_LOG, origen, destino, clase], _GL().Category.GAMEPLAY)
	return {"ok": true, "motivo": "", "precio": p.precio, "camarote": cam}

func _siguiente_camarote(clase: StringName) -> StringName:
	match clase:
		"primera":
			return &"suite"
		"segunda":
			return &"exterior"
		_:
			return &"interno"

## El jugador cruza el Area3D de embarque.
func embarcar() -> bool:
	if not puede_embarcar():
		_GL().warning("%s embarque rechazado (estado=%s)" % [PREFIJO_LOG, str(estado)], _GL().Category.GAMEPLAY)
		return false
	cubierta_actual = int(pasaje_actual.cubierta)
	estado = Estado.ABORDO
	embarque.emit(cubierta_actual)
	_GL().info("%s embarque en cubierta %d" % [PREFIJO_LOG, cubierta_actual], _GL().Category.GAMEPLAY)
	return true

## M68 avisa que la ruta arrancó.
func _on_viaje_iniciado(route_id_: StringName, _coste: int) -> void:
	if pasaje_actual == null:
		return
	route_id = route_id_
	estado = Estado.NAVEGANDO
	zarpe.emit(String(pasaje_actual.stop_id_origen), String(pasaje_actual.stop_id_destino))
	_GL().info("%s zarpe %s -> %s" % [PREFIJO_LOG, pasaje_actual.stop_id_origen, pasaje_actual.stop_id_destino], _GL().Category.GAMEPLAY)

## M68 avisa que llegamos.
func _on_viaje_llegado(_route_id: StringName, stop_id: StringName) -> void:
	if pasaje_actual == null:
		return
	estado = Estado.ATRACADO
	llegada.emit(String(stop_id))
	_GL().info("%s llegada a %s" % [PREFIJO_LOG, stop_id], _GL().Category.GAMEPLAY)

## Cambio de cubierta (escalera o ascensor).
func cambiar_cubierta(destino: int) -> bool:
	if destino < CUBIERTA_MIN or destino > CUBIERTA_MAX:
		push_warning("%s cubierta invalida: %d" % [PREFIJO_LOG, destino])
		return false
	cubierta_actual = destino
	cambio_cubierta.emit(destino)
	return true

## Desembarco: libera el camarote pero conserva el pasaje hasta el próximo viaje.
func desembarcar(destino: String) -> void:
	if pasaje_actual == null:
		return
	var previo: StringName = pasaje_actual.camarote
	pasaje_actual = null
	camarote_asignado = &""
	estado = Estado.ATRACADO
	desembarco.emit(destino)
	_GL().info("%s desembarco en %s (camarote %s liberado)" % [PREFIJO_LOG, destino, previo], _GL().Category.GAMEPLAY)

## Modo emergencia (tormenta / falla): el viaje se interrumpe.
func declarar_emergencia(motivo: String) -> void:
	if estado != Estado.NAVEGANDO:
		return
	estado = Estado.EMERGENCIA
	_GL().warning("%s EMERGENCIA: %s" % [PREFIJO_LOG, motivo], _GL().Category.GAMEPLAY)

# ------------------------------------------------------------------ persistencia

func a_dict() -> Dictionary:
	return {
		"estado": int(estado),
		"cubierta_actual": cubierta_actual,
		"camarote_asignado": String(camarote_asignado),
		"route_id": String(route_id),
		"pasaje": _pasaje_a_dict(),
	}

func _pasaje_a_dict() -> Dictionary:
	if pasaje_actual == null:
		return {}
	return {
		"route_id": String(pasaje_actual.route_id),
		"origen": String(pasaje_actual.stop_id_origen),
		"destino": String(pasaje_actual.stop_id_destino),
		"clase": String(pasaje_actual.clase),
		"camarote": String(pasaje_actual.camarote),
		"precio": pasaje_actual.precio,
		"cubierta": pasaje_actual.cubierta,
	}

func cargar_desde(datos: Dictionary) -> void:
	estado = int(datos.get("estado", Estado.ATRACADO)) % 4
	cubierta_actual = clampi(int(datos.get("cubierta_actual", 1)), CUBIERTA_MIN, CUBIERTA_MAX)
	camarote_asignado = StringName(datos.get("camarote_asignado", &""))
	route_id = StringName(datos.get("route_id", &""))
	var pj: Variant = datos.get("pasaje", {})
	if typeof(pj) == TYPE_DICTIONARY and not (pj as Dictionary).is_empty():
		var d: Dictionary = pj
		var p := PasajeCrucero.new()
		p.route_id = StringName(d.get("route_id", &""))
		p.stop_id_origen = StringName(d.get("origen", &""))
		p.stop_id_destino = StringName(d.get("destino", &""))
		p.clase = StringName(d.get("clase", &""))
		p.camarote = StringName(d.get("camarote", &""))
		p.precio = int(d.get("precio", 0))
		p.cubierta = int(d.get("cubierta", 2))
		p.embarcado = true
		pasaje_actual = p
		_GL().info("%s estado cargado: cubierta %d, clase %s" % [PREFIJO_LOG, cubierta_actual, p.clase], _GL().Category.GAMEPLAY)

## Conecta las señales de M68. Llamar desde el autoload de arranque.
func conectar_transporte() -> void:
	if not TransportManager.viaje_iniciado.is_connected(_on_viaje_iniciado):
		TransportManager.viaje_iniciado.connect(_on_viaje_iniciado)
	if not TransportManager.viaje_llegado.is_connected(_on_viaje_llegado):
		TransportManager.viaje_llegado.connect(_on_viaje_llegado)