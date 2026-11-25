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
	_gl = get_node_or_null("/root/GameLogger")
	_cargar_catalogos()


func _cargar_catalogos() -> void:
	_clases = _leer_json(RUTA_PASAJES, "clases")
	_camarotes = _leer_json(RUTA_CAMAROTES, "camarotes")
	_log_info("%s catalogos cargados: %d clases, %d camarotes" % [PREFIJO_LOG, _clases.size(), _camarotes.size()], "GAMEPLAY")


func _leer_json(ruta: String, clave: String) -> Dictionary:
	var out := {}
	if not FileAccess.file_exists(ruta):
		_log_error("%s no existe %s" % [PREFIJO_LOG, ruta], "SYSTEM")
		return out
	var txt := FileAccess.get_file_as_string(ruta)
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		_log_error("%s JSON invalido en %s" % [PREFIJO_LOG, ruta], "SYSTEM")
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
	# M169/CI (2026-11-25, Deepseek V4.1 Flash-DeepAI): el autoload se resuelve
	# por NODO, no por identificador global. `godot --check-only --script` compila
	# los .gd sin registrar los autoloads como singletons, asi que un
	# `TransportManager.metodo()` literal aborta con "Identifier not found"
	# (patron BUG-128 / T-108 de GUIA-GODOT/06). Con get_node_or_null la misma
	# referencia funciona igual en runtime y el gate compila.
	var tm = get_node_or_null("/root/TransportManager")
	if tm == null or not tm.tiene_red():
		return {"ok": false, "motivo": "sin_red"}

	var resultado: Dictionary = tm.buy_ticket(route_id_, origen)
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
	var tc = get_node_or_null("/root/TimeCalendar")
	p.fecha_compra = tc.fecha_actual() if tc != null and tc.has_method("fecha_actual") else {}
	pasaje_actual = p
	camarote_asignado = cam
	estado = Estado.ABORDO
	pasaje_comprado.emit(String(clase), p.precio)
	_log_info("%s pasaje vendido: %s -> %s (%s)" % [PREFIJO_LOG, origen, destino, clase], "GAMEPLAY")
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
		_log_warning("%s embarque rechazado (estado=%s)" % [PREFIJO_LOG, str(estado)], "GAMEPLAY")
		return false
	cubierta_actual = int(pasaje_actual.cubierta)
	estado = Estado.ABORDO
	embarque.emit(cubierta_actual)
	_log_info("%s embarque en cubierta %d" % [PREFIJO_LOG, cubierta_actual], "GAMEPLAY")
	return true

## M68 avisa que la ruta arrancó.
func _on_viaje_iniciado(route_id_: StringName, _coste: int) -> void:
	if pasaje_actual == null:
		return
	route_id = route_id_
	estado = Estado.NAVEGANDO
	zarpe.emit(String(pasaje_actual.stop_id_origen), String(pasaje_actual.stop_id_destino))
	_log_info("%s zarpe %s -> %s" % [PREFIJO_LOG, pasaje_actual.stop_id_origen, pasaje_actual.stop_id_destino], "GAMEPLAY")

## M68 avisa que llegamos.
func _on_viaje_llegado(_route_id: StringName, stop_id: StringName) -> void:
	if pasaje_actual == null:
		return
	estado = Estado.ATRACADO
	llegada.emit(String(stop_id))
	_log_info("%s llegada a %s" % [PREFIJO_LOG, stop_id], "GAMEPLAY")

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
	_log_info("%s desembarco en %s (camarote %s liberado)" % [PREFIJO_LOG, destino, previo], "GAMEPLAY")

## Modo emergencia (tormenta / falla): el viaje se interrumpe.
func declarar_emergencia(motivo: String) -> void:
	if estado != Estado.NAVEGANDO:
		return
	estado = Estado.EMERGENCIA
	_log_warning("%s EMERGENCIA: %s" % [PREFIJO_LOG, motivo], "GAMEPLAY")


# ------------------------------------------------------------------ streaming (K-03)
## Nunca debe haber dos cubiertas cargadas a la vez: al entrar a una se
## descarga la anterior. M63 (CargasManager) es el dueño del streaming; este
## manager solo orquesta y deja registro para el test.

var _cubierta_cargada: Node = null


func descargar_cubierta() -> void:
	if _cubierta_cargada != null and is_instance_valid(_cubierta_cargada):
		_cubierta_cargada.queue_free()
	_cubierta_cargada = null


## Carga la cubierta `destino` (1..4) y descarga la anterior.
func cargar_cubierta(destino: int) -> bool:
	if destino < CUBIERTA_MIN or destino > CUBIERTA_MAX:
		push_warning("%s cubierta invalida: %d" % [PREFIJO_LOG, destino])
		return false
	descargar_cubierta()
	var ruta := "res://scenes/crucero/interior_cubierta_%d.tscn" % destino
	var cargas := get_node_or_null("/root/CargasManager")
	if cargas != null and cargas.has_method("cargar_sector"):
		await cargas.cargar_sector(ruta)
		cubierta_actual = destino
		cambio_cubierta.emit(destino)
		_log_info("%s cubierta %d cargada (la anterior fue descargada)" % [PREFIJO_LOG, destino], "GAMEPLAY")
		return true
	_log_warning("%s CargasManager no disponible; no se cargo la cubierta %d" % [PREFIJO_LOG, destino], "GAMEPLAY")
	return false


## Conecta la senal `puerta_cruzada` de una cubierta cargada (CruceroInterior) para
## que el ciclo de puertas (4 -> 1) cierre: puerta -> cambiar_cubierta + cargar la
## siguiente. Sella la integracion CruceroManager <-> CruceroInterior.
func conectar_interior(n: Node) -> void:
	if n == null or not n.has_signal("puerta_cruzada"):
		return
	if not n.puerta_cruzada.is_connected(_on_puerta_cruzada):
		n.puerta_cruzada.connect(_on_puerta_cruzada)


func _on_puerta_cruzada(destino: int) -> void:
	cambiar_cubierta(destino)
	cargar_cubierta(destino)


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
		_log_info("%s estado cargado: cubierta %d, clase %s" % [PREFIJO_LOG, cubierta_actual, p.clase], "GAMEPLAY")

## Conecta las señales de M68. Llamar desde el autoload de arranque.
func conectar_transporte() -> void:
	var tm = get_node_or_null("/root/TransportManager")
	if tm == null:
		_log_info("%s TransportManager ausente; senales de viaje no conectadas" % PREFIJO_LOG, "GAMEPLAY")
		return
	if not tm.viaje_iniciado.is_connected(_on_viaje_iniciado):
		tm.viaje_iniciado.connect(_on_viaje_iniciado)
	if not tm.viaje_llegado.is_connected(_on_viaje_llegado):
		tm.viaje_llegado.connect(_on_viaje_llegado)