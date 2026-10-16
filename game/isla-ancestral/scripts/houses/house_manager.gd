# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18: HouseManager — autoload central para gestión de casas del jugador.
# Registra parcelas, gestiona etapas de mejora y almacenamiento.
extends Node

signal casa_creada(id: String)
signal etapa_cambiada(casa_id: String, etapa: int)

const MAX_ETAPAS := 5
const ETAPAS := {
	1: "choza",
	2: "ampliacion",
	3: "cocina",
	4: "taller",
	5: "sotano_atico",
}

const MIN_DISTANCIA_CASAS := 20.0

var _casas: Dictionary = {}  # id -> {pos: Vector3, etapa: int, interior: String}
var _parcela_del_jugador: String = ""
var _debug_menu: Node = null

func _ready() -> void:
	var reg = get_node_or_null("/root/ServiceRegistry")
	if reg != null and reg.has_method("register"):
		reg.register("house_manager", self)

## Registra una nueva casa. Devuelve el ID asignado.
func registrar_casa(pos: Vector3, id: String = "") -> String:
	if id.is_empty():
		id = "casa_%d" % (Time.get_ticks_msec() % 100000)
	_casas[id] = {
		"pos": pos,
		"etapa": 1,
		"interior": "",
		"muebles": [],
	}
	casa_creada.emit(id)
	return id

## Devuelve la casa del jugador (primer registrada o por ID).
## Instrumenta M153/M104 `volver_a_casa` cuando se resuelve la parcela.
func obtener_casa_jugador() -> Dictionary:
	if _parcela_del_jugador != "" and _casas.has(_parcela_del_jugador):
		return _casas[_parcela_del_jugador]
	if _casas.size() > 0:
		_parcela_del_jugador = _casas.keys()[0]
		var casa: Dictionary = _casas[_parcela_del_jugador]
		# M153 ítem 33 (telemetría M104). Silencioso si no hay AnalyticsDirector.
		var tm := load("res://scripts/analytics/telemetria_m104.gd")
		if tm != null and tm.has_method("volver_a_casa"):
			tm.volver_a_casa(_parcela_del_jugador, casa.get("pos", Vector3.ZERO))
		return casa
	return {}

## Devuelve todas las casas registradas.
func obtener_casas() -> Array:
	return _casas.values()

## Avanza la etapa de una casa. Devuelve true si avanzó.
func avanzar_etapa(casa_id: String) -> bool:
	if not _casas.has(casa_id):
		return false
	var casa: Dictionary = _casas[casa_id]
	if int(casa.get("etapa", 1)) >= MAX_ETAPAS:
		return false
	casa["etapa"] = int(casa["etapa"]) + 1
	_casas[casa_id] = casa
	etapa_cambiada.emit(casa_id, int(casa["etapa"]))
	return true

## Devuelve la etapa actual de una casa.
func obtener_etapa(casa_id: String) -> int:
	if _casas.has(casa_id):
		return int(_casas[casa_id].get("etapa", 1))
	return 0

## Devuelve si hay una casa en las coordenadas dadas.
func hay_casa_en(pos: Vector3, radio: float = 2.0) -> bool:
	for id in _casas:
		var c: Dictionary = _casas[id]
		var cpos: Vector3 = c.get("pos", Vector3.ZERO)
		if cpos.distance_to(pos) < radio:
			return true
	return false

## Agrega un mueble a una casa.
func agregar_mueble(casa_id: String, mueble_id: String) -> bool:
	if not _casas.has(casa_id):
		return false
	var lista: Array = _casas[casa_id].get("muebles", [])
	lista.append(mueble_id)
	_casas[casa_id]["muebles"] = lista
	return true

## Devuelve los muebles de una casa.
func obtener_muebles(casa_id: String) -> Array:
	if _casas.has(casa_id):
		return _casas[casa_id].get("muebles", [])
	return []

## Tabla de costes por etapa (M14). Materiales: [id, cantidad].
const COSTES_ETAPA := {
	1: [[{"id": "wood", "cant": 10}, {"id": "grass", "cant": 5}]],
	2: [[{"id": "wood", "cant": 20}, {"id": "stone", "cant": 10}]],
	3: [[{"id": "wood", "cant": 30}, {"id": "stone", "cant": 15}, {"id": "copper_ore", "cant": 5}]],
	4: [[{"id": "wood", "cant": 40}, {"id": "stone", "cant": 20}, {"id": "iron_ore", "cant": 10}]],
	5: [[{"id": "wood", "cant": 50}, {"id": "stone", "cant": 25}, {"id": "crystal", "cant": 5}]],
}

var _vecinos: Dictionary = {}  # casa_id -> vecino_id

## Verifica que la parcela esté despejada (sin casas a menos de 20m y sobre tierra).
func parcela_despejada(pos: Vector3) -> bool:
	if hay_casa_en(pos, MIN_DISTANCIA_CASAS):
		return false
	var tl = get_node_or_null("/root/TerrainLocator")
	if tl != null and tl.has_method("get_height"):
		var h := int(tl.get_height(int(pos.x), int(pos.z)))
		if h <= 0:
			return false
	return true

## Cobra materiales del inventario para avanzar de etapa.
func cobrar_etapa(casa_id: String) -> Dictionary:
	if not _casas.has(casa_id):
		return {"ok": false, "razon": "casa inexistente"}
	var etapa_actual: int = int(_casas[casa_id].get("etapa", 1))
	if etapa_actual >= MAX_ETAPAS:
		return {"ok": false, "razon": "ya en etapa max"}
	var costes: Array = COSTES_ETAPA.get(etapa_actual, [])
	var inv = get_node_or_null("/root/Inventario")
	if inv == null:
		return {"ok": false, "razon": "InventarioService no disponible"}
	# Verificar fondos (transaccional: no descontar nada si falla)
	for grupo in costes:
		for req in grupo:
			var id_item: String = str(req.get("id", ""))
			var cant: int = int(req.get("cant", 0))
			if inv.has_method("count_item"):
				if int(inv.count_item(id_item)) < cant:
					return {"ok": false, "razon": "falta %s x%d" % [id_item, cant]}
	# Descontar
	for grupo in costes:
		for req in grupo:
			inv.remove_item(str(req.get("id", "")), int(req.get("cant", 0)))
	avanzar_etapa(casa_id)
	return {"ok": true, "nueva_etapa": int(_casas[casa_id].get("etapa", 1))}

## Asigna un vecino (M19) a una casa. 1 vecino por casa.
func asignar_vecino(casa_id: String, vecino_id: String) -> bool:
	if not _casas.has(casa_id):
		return false
	if _vecinos.has(casa_id):
		return false
	_vecinos[casa_id] = vecino_id
	return true

## Devuelve el vecino asignado a una casa.
func obtener_vecino(casa_id: String) -> String:
	return _vecinos.get(casa_id, "")

## Cantidad de vecinos asignados.
func cantidad_vecinos() -> int:
	return _vecinos.size()

## Slots de muebles por etapa.
const SLOTS_POR_ETAPA := {1: 2, 2: 4, 3: 6, 4: 8, 5: 12}

## Coloca un mueble en una casa. Verifica capacidad y superficie/pared.
func colocar_mueble(casa_id: String, mueble: Variant) -> Dictionary:
	if not _casas.has(casa_id):
		return {"ok": false, "razon": "casa inexistente"}
	var etapa: int = int(_casas[casa_id].get("etapa", 1))
	var slots: int = int(SLOTS_POR_ETAPA.get(etapa, 2))
	var muebles_actuales: Array = _casas[casa_id].get("muebles", [])
	if muebles_actuales.size() >= slots:
		return {"ok": false, "razon": "capacidad llena (%d/%d)" % [muebles_actuales.size(), slots]}
	if mueble == null:
		return {"ok": false, "razon": "mueble nulo"}
	var requiere_superficie: bool = bool(mueble.get("requiere_superficie", true))
	var requiere_pared: bool = bool(mueble.get("requiere_pared", false))
	if requiere_pared and requiere_superficie:
		return {"ok": false, "razon": "no puede requerir ambos superficie y pared"}
	var id_mueble: String = str(mueble.get("id", ""))
	if id_mueble.is_empty():
		return {"ok": false, "razon": "mueble sin id"}
	muebles_actuales.append(id_mueble)
	_casas[casa_id]["muebles"] = muebles_actuales
	return {"ok": true, "mueble": id_mueble, "slots_usados": muebles_actuales.size(), "slots_max": slots}

## Devuelve la posición de la puerta de una casa (para interacción M19/M21).
func obtener_pos_puerta(casa_id: String) -> Vector3:
	if not _casas.has(casa_id):
		return Vector3.ZERO
	var c: Dictionary = _casas[casa_id]
	var pos: Vector3 = c.get("pos", Vector3.ZERO)
	return pos + Vector3(0, 0, 3.0)  # puerta al frente (norte)

## Verifica si un vecino puede entrar a la casa (no en obra, tiene puerta accesible).
func vecino_puede_entrar(casa_id: String, vecino_id: String) -> bool:
	if not _casas.has(casa_id):
		return false
	var etapa: int = int(_casas[casa_id].get("etapa", 1))
	if etapa < 1:
		return false  # en obra
	if obtener_vecino(casa_id) != vecino_id:
		return false  # no es su casa
	return true

## Registra entrada/salida de un vecino (señal para M19/M21).
signal vecino_entro(casa_id: String, vecino_id: String)
signal vecino_salio(casa_id: String, vecino_id: String)

func registrar_entrada_vecino(casa_id: String, vecino_id: String) -> bool:
	if not vecino_puede_entrar(casa_id, vecino_id):
		return false
	vecino_entro.emit(casa_id, vecino_id)
	return true

func registrar_salida_vecino(casa_id: String, vecino_id: String) -> bool:
	if not _vecinos.has(casa_id) or _vecinos[casa_id] != vecino_id:
		return false
	vecino_salio.emit(casa_id, vecino_id)
	return true

## Verifica si una casa está en una ubicación conocida de M160 (WorldLocations).
func casa_en_ubicacion_conocida(casa_id: String) -> bool:
	if not _casas.has(casa_id):
		return false
	var pos: Vector3 = _casas[casa_id].get("pos", Vector3.ZERO)
	var wl = get_node_or_null("/root/WorldLocations")
	if wl == null or not wl.has_method("buscar_cerca"):
		return true  # sin M160 → no bloquear
	return wl.buscar_cerca(Vector2(pos.x, pos.z), 100.0)

## Devuelve el vecino actual de una casa (string, "" si no hay).
## (ya existe como obtener_vecino, este es alias para legibilidad)

## Habitaciones por etapa (SLOTS_POR_ETAPA = capacidad de muebles).
## Nombre de la habitación base desbloqueada en cada etapa.
const HABITACIONES_POR_ETAPA := {
	1: ["living"],
	2: ["living", "dormitorio"],
	3: ["living", "dormitorio", "cocina"],
	4: ["living", "dormitorio", "cocina", "taller"],
	5: ["living", "dormitorio", "cocina", "taller", "sotano"],
}

## Devuelve las habitaciones disponibles en una casa según su etapa.
func obtener_habitaciones(casa_id: String) -> Array:
	if not _casas.has(casa_id):
		return []
	var etapa: int = int(_casas[casa_id].get("etapa", 1))
	return HABITACIONES_POR_ETAPA.get(etapa, [])

## Verifica si una habitación específica está desbloqueada en la casa.
func habitacion_desbloqueada(casa_id: String, nombre: String) -> bool:
	return obtener_habitaciones(casa_id).has(nombre)

## ── M29: Integración con tiempo/estaciones ──

## Devuelve el nombre de la estación actual (usa GameTime/M29 si existe).
func obtener_estacion_actual() -> String:
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("obtener_estacion"):
		return String(gt.obtener_estacion())
	return "primavera"

## Verifica si una etapa de construcción es válida en la estación actual.
## (Ej: construcción pesada no en invierno — diseño propio)
func etapa_viable_en_estacion(etapa: int) -> bool:
	var estacion := obtener_estacion_actual()
	# Etapa 5 (sótano/ático) no se construye en invierno
	if etapa >= 5 and estacion == "invierno":
		return false
	return true

## Cantidad de casas registradas.
func cantidad_casas() -> int:
	return _casas.size()

## Limpia todo (para tests).
func limpiar() -> void:
	_casas.clear()
	_parcela_del_jugador = ""

## Devuelve datos para guardado (M60, contrato BuildingsSaveProvider).
func obtener_estructuras() -> Array:
	var lista: Array = []
	for id in _casas:
		var c: Dictionary = _casas[id]
		var pos: Vector3 = c.get("pos", Vector3.ZERO)
		lista.append({
			"id": id,
			"tipo": "casa",
			"pos": [int(pos.x), int(pos.y), int(pos.z)],
			"rot_y": 0.0,
			"planta": int(c.get("etapa", 1)),
			"variante": "",
		})
	return lista

## Restaura estructuras desde el save (M60, contrato BuildingsSaveProvider).
func restaurar_estructuras(lista: Array) -> void:
	_casas.clear()
	_vecinos.clear()
	for e in lista:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var id: String = String(e.get("id", ""))
		if id.is_empty():
			continue
		var pos_arr: Array = e.get("pos", [0, 0, 0])
		var pos := Vector3(float(pos_arr[0]), float(pos_arr[1]), float(pos_arr[2]))
		_casas[id] = {
			"pos": pos,
			"etapa": int(e.get("planta", 1)),
			"interior": "",
			"muebles": [],
		}
		if _casas.size() == 1:
			_parcela_del_jugador = id

## Devuelve datos para guardado (M60).
func obtener_datos_guardado() -> Dictionary:
	var data := {"casas": {}, "parcela_jugador": _parcela_del_jugador}
	for id in _casas:
		data["casas"][id] = _casas[id].duplicate(true)
	return data

## Restaura desde guardado.
func restaurar_desde_guardado(data: Dictionary) -> void:
	_casas = data.get("casas", {})
	_parcela_del_jugador = String(data.get("parcela_jugador", ""))
