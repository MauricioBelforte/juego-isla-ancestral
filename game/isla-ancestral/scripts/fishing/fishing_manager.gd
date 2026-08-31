# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M34: FishingManager (autoload "Fishing") — orquestador de pesca.
# §2.1: registro de spots, resolución de especie (tablas + PRNG ponderado M29
# con cebo y pity), sesiones, colección/persistencia M59.
# Datos desde data/balance/fishing.json (M93: peces con temporada/hora/clima/
# probabilidad/pity). Reglas anti-frustración §6 verificables en test.
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

signal picada_iniciada(sesion)
signal captura_exitosa(pez, tamano: float)
signal captura_fallida(motivo: String)
signal sesion_terminada(sesion)

const RUTA_FISHING := "res://data/balance/fishing.json"
const FRANJAS := {"ALBA": 0, "DIA": 1, "ATARDECER": 2, "NOCHE": 3, "PROFUNDA": 4}

var _spots: Array = []
var _peces: Array = []           # Array[FishDefinition]
var _sesion: Node = null
var _prng: RandomNumberGenerator
var _coleccion: Dictionary = {}  # pez_id -> {capturado, veces, mejor_tamano}
var _pity_contadores: Dictionary = {}  # pez_id -> capturas sin éxito
var _capturas_totales: int = 0

func _ready() -> void:
	_prng = RandomNumberGenerator.new()
	_prng.seed = hash(Time.get_ticks_usec())
	_cargar_peces()

## ── Datos (M93) ──────────────────────────────────────────

func _cargar_peces() -> void:
	var f := FileAccess.open(RUTA_FISHING, FileAccess.READ)
	if f == null:
		push_warning("[M34] No se pudo abrir fishing.json")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return
	for datos in parsed.get("peces", []):
		var pez := FishDefinition.new()
		pez.id = str(datos.get("id", ""))
		pez.nombre_es = str(datos.get("nombre_i18n", pez.id))
		pez.peso_rareza = float(datos.get("probabilidad", 0.1))
		pez.tamano_min = float(datos.get("peso_kg", [0.3, 1.0])[0])
		pez.tamano_max = float(datos.get("peso_kg", [0.3, 1.0])[1]) if (datos.get("peso_kg", []) as Array).size() > 1 else 1.0
		pez.valor_venta = int(datos.get("precio_venta", 0))
		pez.pity = int(datos.get("pity", 0) if datos.get("pity", 0) != null else 0)
		var horas: Array = datos.get("horas", [])
		if horas.size() >= 2:
			pez.franjas = [_franja_de_hora(int(horas[0]))]
		var clima: Array = datos.get("clima", [])
		for c in clima:
			pez.climas.append(_clima_numero(String(c)))
		var temporada: Array = datos.get("temporadas", [])
		for t in temporada:
			pez.estaciones.append(_estacion_numero(String(t)))
		_peces.append(pez)

func _franja_de_hora(hora: int) -> int:
	if hora >= 21 or hora < 5:
		return FRANJAS["NOCHE"]
	if hora >= 17:
		return FRANJAS["ATARDECER"]
	if hora >= 7:
		return FRANJAS["DIA"]
	return FRANJAS["ALBA"]

func _estacion_numero(nombre: String) -> int:
	match nombre.to_lower():
		"primavera": return 0
		"verano": return 1
		"otono", "otoño": return 2
		"invierno": return 3
	return -1

func _clima_numero(nombre: String) -> int:
	match nombre.to_lower():
		"lluvia": return 1
		"tormenta": return 2
		"nieve": return 3
	return 0  # despejado

## ── Spots ────────────────────────────────────────────────

func registrar_spot(spot) -> void:
	if spot not in _spots:
		_spots.append(spot)

func desregistrar_spot(spot) -> void:
	_spots.erase(spot)
	if _sesion and _sesion.spot == spot:
		_sesion.cancelar("spot_descargado")

func spot_apunta_desde(_origen: Vector3, _direccion: Vector3, _rango: float):
	# Con M51 no integrado: devuelve el primer spot válido registrado
	for s in _spots:
		if s.es_agua_pescable():
			return s
	return null

## ── Sesiones ─────────────────────────────────────────────

func iniciar_sesion(spot, cana: FishingRod, cebo: CeboDefinition = null):
	if _sesion != null:
		_sesion.queue_free()
	var ses := FishingSession.new()
	ses.name = "FishingSession"
	ses.cana = cana
	ses.cebo = cebo
	add_child(ses)
	_sesion = ses
	ses.lanzar(_prng)
	ses.estado_cambiado.connect(_on_estado_sesion.bind(ses, spot))
	picada_iniciada.emit(ses)
	return ses

func _on_estado_sesion(nuevo: int, ses, _spot) -> void:
	if nuevo == FishingSession.Estado.CAPTURA:
		var pez = resolver_especie(_spot, ses.cebo)
		var tamano := _prng.randf_range(pez.tamano_min, pez.tamano_max) if pez else 0.5
		registrar_captura(pez, tamano)
		captura_exitosa.emit(pez, tamano)
		_consumir_cebo(ses)
		_terminar()
	elif nuevo == FishingSession.Estado.ESCAPE:
		# §6.3: huida sin pérdidas — el cebo NO se consume
		captura_fallida.emit("el_pez_se_fue")
		_pity_incrementar()
		_terminar()

func _terminar() -> void:
	if _sesion:
		sesion_terminada.emit(_sesion)
		_sesion.queue_free()
		_sesion = null

func _consumir_cebo(ses) -> void:
	if ses.cebo == null:
		return
	var inv = get_node_or_null("/root/Inventario")
	if inv and inv.has_method("remover_items"):
		inv.remover_items({str(ses.cebo.id): ses.cebo.consumo_por_captura})

## ── Resolución de especie (flujo 4) ──────────────────────

## Filtra por estación M29 + franja M31 + clima M32; elige por PRNG ponderado
## con bono de cebo y pity (§flujo 4 + §6.5: el cebo solo multiplica).
func resolver_especie(_spot, cebo: CeboDefinition = null) -> FishDefinition:
	var cal = get_node_or_null("/root/TimeCalendar")
	var estacion: int = int(cal.get_estacion()) if cal else 0
	var hora: int = cal.get_hora() if cal else 12
	var franja_actual: int = _franja_de_hora(hora)
	var candidatas: Array = []
	for pez in _peces:
		if pez.estaciones.size() > 0 and not pez.estaciones.has(estacion):
			continue
		if pez.franjas.size() > 0 and not pez.franjas.has(franja_actual):
			continue
		candidatas.append(pez)
	if candidatas.is_empty():
		candidatas = _peces  # fallback: nunca pescar "nada" (cozy)
	# Peso: base x bono cebo x pity
	var pesos: Array = []
	for pez in candidatas:
		var peso: float = pez.peso_rareza
		if cebo and pez.cebos_preferidos.has(cebo.id):
			peso *= cebo.multiplicador_probabilidad
		if pez.pity > 0:
			var sin_exito: int = int(_pity_contadores.get(pez.id, 0))
			if sin_exito >= pez.pity:
				peso *= 10.0  # pity garantiza en el roll ponderado
		pesos.append(peso)
	# PRNG ponderado
	var total: float = 0.0
	for p in pesos:
		total += float(p)
	var roll := _prng.randf_range(0.0, total)
	var acumulado: float = 0.0
	for i in candidatas.size():
		acumulado += float(pesos[i])
		if roll <= acumulado:
			# Consumir pity si fue el elegido con pity activo
			var elegido: FishDefinition = candidatas[i]
			if elegido.pity > 0:
				_pity_contadores[elegido.id] = 0
			return elegido
	return candidatas[0] if candidatas.size() > 0 else null

func _pity_incrementar() -> void:
	for pez in _peces:
		if pez.pity > 0:
			_pity_contadores[pez.id] = int(_pity_contadores.get(pez.id, 0)) + 1

## ── Colección (M37) ──────────────────────────────────────

func registrar_captura(pez, tamano: float) -> void:
	if pez == null:
		return
	_capturas_totales += 1
	var entry: Dictionary = _coleccion.get(pez.id, {"capturado": false, "veces": 0, "mejor": 0.0})
	entry["capturado"] = true
	entry["veces"] = int(entry["veces"]) + 1
	entry["mejor"] = maxf(float(entry["mejor"]), tamano)
	_coleccion[pez.id] = entry

func entrega_museo(_pez) -> bool:
	# M37 no implementado: placeholder honesto
	return false

func get_collection_data() -> Dictionary:
	return _coleccion.duplicate(true)

## ── Persistencia (M59) ───────────────────────────────────

func get_section_name() -> String:
	return "fishing"

func get_save_data() -> Dictionary:
	return {"coleccion": _coleccion.duplicate(true), "pity": _pity_contadores.duplicate(),
		"capturas_totales": _capturas_totales}

func restore_save_data(data: Dictionary) -> void:
	_coleccion = data.get("coleccion", {}).duplicate(true)
	_pity_contadores = data.get("pity", {}).duplicate(true)
	_capturas_totales = int(data.get("capturas_totales", 0))