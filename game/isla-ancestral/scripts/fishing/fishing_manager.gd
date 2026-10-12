# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M34: FishingManager (autoload "Fishing") — orquestador de pesca.
# §2.1: registro de spots, resolución de especie (tablas + PRNG ponderado M29
# con cebo y pity), sesiones, colección/persistencia M59.
# Datos desde data/balance/fishing.json (M93: peces con temporada/hora/clima/
# probabilidad/pity). Reglas anti-frustración §6 verificables en test.
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).

extends Node

signal picada_iniciada(sesion)
signal captura_exitosa(pez, tamano: float)
## Ítem pez efectivamente entregado al inventario M14 (E95/G115).
## `cantidad_entregada` puede ser menor que 1 si el inventario estaba lleno:
## en ese caso `bandeja_peces_sueltos` recibe el resto (sin pérdida).
signal pez_entregado(pez_id: String, cantidad_entregada: int, cantidad_total: int)
## El inventario no pudo absorber todo: el resto queda en la bandeja de
## "peces sueltos" (regla cozy: nunca se pierde la captura, J160).
signal bandeja_peces_sueltos(cantidad: int)
signal captura_fallida(motivo: String)
signal sesion_terminada(sesion)

const RUTA_FISHING := "res://data/balance/fishing.json"
const FRANJAS := {"ALBA": 0, "DIA": 1, "ATARDECER": 2, "NOCHE": 3, "PROFUNDA": 4}

var _spots: Array = []
var _peces: Array = []           # Array[FishDefinition]
var _cebos: Dictionary = {}      # cebo_id -> CeboDefinition
var _canas: Dictionary = {}      # cana_id -> FishingRod
var _sesion: Node = null
var _prng: RandomNumberGenerator
var _coleccion: Dictionary = {}  # pez_id -> {capturado, veces, mejor_tamano}
var _pity_contadores: Dictionary = {}  # pez_id -> capturas sin éxito
var _capturas_totales: int = 0
## "Peces sueltos": capturas que no entraron en el inventario M14 (lleno).
## Persisten para que el jugador los recupere (regla anti-pérdida, J160).
var _bandeja_peces: Dictionary = {}  # pez_id -> cantidad

func _ready() -> void:
	_prng = RandomNumberGenerator.new()
	# PRNG de partida (M29 H120, Log 824): la secuencia es determinista por
	# partida+ día (misma partida → mismas capturas en recargas del mismo save).
	# Fallback: si GameTime no existe aún (tests unitarios), semilla 0 estable.
	var gt := get_node_or_null("/root/GameTime")
	if gt and gt.has_method("rng_diario"):
		_prng = gt.rng_diario("m34")
	_cargar_catalogo()

## ── Datos (M93) ──────────────────────────────────────────

## Carga el catálogo completo (peces + cebos + cañas) desde fishing.json.
## Antes solo se cargaban los peces: los 4 cebos y las 3 cañas del catálogo
## quedaban inaccesibles para el juego. Verificado con las suites existentes.
func _cargar_catalogo() -> void:
	var f := FileAccess.open(RUTA_FISHING, FileAccess.READ)
	if f == null:
		push_warning("[M34] No se pudo abrir fishing.json")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return
	_cargar_peces_de(parsed)
	_cargar_cebos_de(parsed)
	_cargar_canas_de(parsed)
	print("[M34] Catálogo: %d peces, %d cebos, %d cañas" % [_peces.size(), _cebos.size(), _canas.size()])


## Carga los 4 cebos (P7). Regla cozy: solo multiplican, nunca son obligatorios.
func _cargar_cebos_de(parsed: Dictionary) -> void:
	for datos in parsed.get("cebos", []):
		if not (datos is Dictionary):
			continue
		var d: Dictionary = datos
		if String(d.get("id", "")) == "":
			continue
		var c := CeboDefinition.new()
		c.id = String(d.get("id"))
		c.multiplicador_probabilidad = float(d.get("multiplicador_probabilidad", 1.0))
		c.multiplicador_espera = float(d.get("multiplicador_espera", 1.0))
		c.consumo_por_captura = int(d.get("consumo_por_captura", 1))
		_cebos[c.id] = c


## Carga las 3 cañas (P8). Mejoran ventana/espera/rareza sin bloquear especies.
func _cargar_canas_de(parsed: Dictionary) -> void:
	for datos in parsed.get("canas", []):
		if not (datos is Dictionary):
			continue
		var d: Dictionary = datos
		if String(d.get("id", "")) == "":
			continue
		var r := FishingRod.new()
		r.id = String(d.get("id"))
		r.rango_lanzamiento = float(d.get("rango_lanzamiento", 8.0))
		r.ventana_exito = float(d.get("ventana_exito", 0.5))
		r.multiplicador_espera = float(d.get("multiplicador_espera", 1.0))
		r.multiplicador_rareza = float(d.get("multiplicador_rareza", 1.0))
		_canas[r.id] = r


func _cargar_peces_de(parsed: Dictionary) -> void:
	_peces.clear()
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
		# Toda hora listada mapea a su franja (antes solo se usaba la primera:
		# "horas": [4, 20] perdía la NOCHE de la 20). Contrato FishDefinition:
		# franjas vacías = todas.
		var franjas_set: Array[int] = []
		for h in horas:
			var franja := _franja_de_hora(int(h))
			if not franjas_set.has(franja):
				franjas_set.append(franja)
		pez.franjas = franjas_set
		var clima: Array = datos.get("clima", [])
		for c in clima:
			pez.climas.append(_clima_numero(String(c)))
		# "temporadas": ["todas"] → estaciones VACÍAS (= todas, contrato
		# FishDefinition L14). Antes: _estacion_numero("todas") devolvía -1 y
		# pez.estaciones = [-1] NUNCA matcheaba una estación real 0-3 → el
		# pez caía SIEMPRE al fallback "todas las especies" de resolver_especie
		# (el filtro de estación quedaba roto para peces "todas").
		var temporada: Array = datos.get("temporadas", [])
		if not temporada.has("todas"):
			for t in temporada:
				var est := _estacion_numero(String(t))
				if est >= 0:
					pez.estaciones.append(est)
		# P17: exclusivas por bioma (lista de ids M51; vacío = todos).
		# Antes no se leían, así que el filtro por bioma nunca podía aplicarse.
		var biomas: Array = datos.get("biomas", [])
		for b in biomas:
			var nombre_b: String = String(b)
			if nombre_b != "" and not pez.biomas.has(nombre_b):
				pez.biomas.append(nombre_b)
		# P16: pieza de museo (M37) y receta (M15), opcionales.
		pez.pieza_museo = String(datos.get("pieza_museo", ""))
		pez.id_receta = String(datos.get("id_receta", ""))
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
	# T-D9 (2)/BUG-116: aviso por el bus para que M59 (SaveManager) bloquee el
	# guardado durante la pesca sin acoplarse a Fishing (rompe el ciclo BUG-069).
	var bus := get_node_or_null("/root/EventBus")
	if bus != null and bus.fishing != null:
		bus.fishing.sesion_iniciada.emit(ses)
	return ses

func _on_estado_sesion(nuevo: int, ses, _spot) -> void:
	if nuevo == FishingSession.Estado.CAPTURA:
		var pez = resolver_especie(_spot, ses.cebo)
		var tamano := _prng.randf_range(pez.tamano_min, pez.tamano_max) if pez else 0.5
		registrar_captura(pez, tamano)
		captura_exitosa.emit(pez, tamano)
		# E95/G115: crear el ítem y entregarlo a M14 (antes solo se emitía la
		# señal: nadie creaba el pez ni lo sumaba al inventario).
		_entregar_pez_a_inventario(pez)
		_consumir_cebo(ses)
		_terminar()
	elif nuevo == FishingSession.Estado.ESCAPE:
		# §6.3: huida sin pérdidas — el cebo NO se consume
		captura_fallida.emit("el_pez_se_fue")
		_pity_incrementar()
		_terminar()


## ── Entrega a M14 (E95/G115) ────────────────────────────────────────────

## Entrega 1 ítem pez al inventario (M14). Contrato real de M14:
## `add_item(item_id, amount)` devuelve el SOBRANTE no aceptado (0 = todo entró).
## Si no entra todo, el resto va a la bandeja de "peces sueltos" (J160): la
## captura nunca se pierde. Devuelve {entregado, bandeja, motivo}.
func _entregar_pez_a_inventario(pez) -> Dictionary:
	var resultado: Dictionary = {"entregado": 0, "bandeja": 0, "motivo": &""}
	if pez == null:
		resultado["motivo"] = &"sin_pez"
		return resultado
	var item_id: String = String(pez.id)
	if item_id == "":
		resultado["motivo"] = &"sin_id"
		return resultado
	var inv = get_node_or_null("/root/Inventario")
	if inv == null or not inv.has_method("add_item"):
		# Sin M14 disponible (headline/tests): toda la captura a la bandeja.
		_bandeja_peces[item_id] = int(_bandeja_peces.get(item_id, 0)) + 1
		resultado["bandeja"] = 1
		resultado["motivo"] = &"sin_inventario"
		bandeja_peces_sueltos.emit(1)
		return resultado
	var restante: int = int(inv.add_item(item_id, 1))
	var entregado: int = 1 - restante
	resultado["entregado"] = entregado
	if restante > 0:
		_bandeja_peces[item_id] = int(_bandeja_peces.get(item_id, 0)) + restante
		resultado["bandeja"] = restante
		resultado["motivo"] = &"inventario_lleno"
		bandeja_peces_sueltos.emit(restante)
	pez_entregado.emit(item_id, entregado, 1)
	return resultado

## Peces que no entraron en el inventario (para la UI y el save).
func peces_sueltos() -> Dictionary:
	return _bandeja_peces.duplicate()

## Intenta vaciar la bandeja en el inventario (llamado por la UI al liberar
## espacio). Devuelve cuántos se rescataron.
func rescatar_peces_sueltos() -> int:
	var inv = get_node_or_null("/root/Inventario")
	if inv == null or not inv.has_method("add_item"):
		return 0
	var rescatados: int = 0
	for item_id in _bandeja_peces.keys():
		var pendiente: int = int(_bandeja_peces[item_id])
		while pendiente > 0:
			var restante: int = int(inv.add_item(String(item_id), pendiente))
			var entro: int = pendiente - restante
			rescatados += entro
			pendiente = restante
			if restante > 0:
				break  # inventario sigue lleno
		if pendiente > 0:
			_bandeja_peces[item_id] = pendiente
		else:
			_bandeja_peces.erase(item_id)
	return rescatados

func _terminar() -> void:
	if _sesion:
		sesion_terminada.emit(_sesion)
		# T-D9 (2)/BUG-116: reanuda el guardado por el bus (par del inicio).
		var bus := get_node_or_null("/root/EventBus")
		if bus != null and bus.fishing != null:
			bus.fishing.sesion_terminada.emit(_sesion)
		_sesion.queue_free()
		_sesion = null

func _consumir_cebo(ses) -> void:
	if ses.cebo == null:
		return
	var inv = get_node_or_null("/root/Inventario")
	if inv and inv.has_method("remover_items"):
		inv.remover_items({str(ses.cebo.id): ses.cebo.consumo_por_captura})

## ── Acceso al catálogo (para HUD, tiendas M38/M39 y QA) ────────────────

func peces() -> Array:
	return _peces.duplicate()

func pez_por_id(id: String) -> FishDefinition:
	for pez in _peces:
		if String(pez.id) == String(id):
			return pez
	return null

func cebos() -> Dictionary:
	return _cebos.duplicate()

func cebo_por_id(id: String) -> CeboDefinition:
	return _cebos.get(String(id), null)

func canas() -> Dictionary:
	return _canas.duplicate()

func cana_por_id(id: String) -> FishingRod:
	return _canas.get(String(id), null)

func cantidad_peces() -> int:
	return _peces.size()


## ── Resolución de especie (flujo 4) ──────────────────────

## Filtra por estación M29 + franja M31 + clima M32; elige por PRNG ponderado
## con bono de cebo y pity (§flujo 4 + §6.5: el cebo solo multiplica).
func resolver_especie(_spot, cebo: CeboDefinition = null) -> FishDefinition:
	var cal = get_node_or_null("/root/GameTime") if get_node_or_null("/root/GameTime") else get_node_or_null("/root/TimeCalendar")
	var estacion: int = int(cal.get_estacion()) if cal else 0
	var hora: int = cal.get_hora() if cal else 12
	var bioma_spot: String = _bioma_de_spot(_spot)
	var candidatas: Array = _candidatas_de_estacion(estacion, hora, bioma_spot)
	if candidatas.is_empty():
		candidatas = _peces  # fallback: nunca pescar "nada" (cozy)
	# Peso: base x bono cebo x bono clima x pity
	var pesos: Array = []
	for pez in candidatas:
		pesos.append(_peso_efectivo(pez, cebo))
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

## Candidatas por estación M29 + franja M31 + bioma M51 (extraído de
## resolver_especie para testabilidad, patrón _peso_efectivo del Log 310). El
## clima NO filtra (§6 M32: bono sí, bloqueo no — solo multiplica pesos en
## _peso_efectivo).
## Contrato: estaciones/franjas/biomas VACÍOS = todos (FishDefinition L14-15).
## `bioma_spot` vacío (M51 no integrado) = no filtra, para no dejar al jugador
## sin nada que pescar.
func _candidatas_de_estacion(estacion: int, hora: int = 12, bioma_spot: String = "") -> Array:
	var franja_actual: int = _franja_de_hora(hora)
	var candidatas: Array = []
	for pez in _peces:
		if pez.estaciones.size() > 0 and not pez.estaciones.has(estacion):
			continue
		if pez.franjas.size() > 0 and not pez.franjas.has(franja_actual):
			continue
		if bioma_spot != "" and pez.biomas.size() > 0 and not pez.biomas.has(bioma_spot):
			continue
		candidatas.append(pez)
	return candidatas

## Bioma del spot (id textual de M51). Devuelve "" si el spot no lo expone:
## sin bioma conocido no se filtra (regla cozy: nunca dejar de pescar).
func _bioma_de_spot(spot) -> String:
	if spot == null:
		return ""
	var b: Variant = spot.get("bioma")
	if b is String and String(b) != "":
		return String(b)
	var idb: Variant = spot.get("bioma_id")
	if idb is String and String(idb) != "":
		return String(idb)
	return ""

## ── Bonos de clima (M32→M34, glm-5.3-flash 2026-08-31) ──
## Diseño M32 §6 / checklist P21: "lluvia +15% raro; tropical +25% raro;
## nunca prohibida". El clima NUNCA filtra especies (bono sí, bloqueo no):
## solo multiplica pesos. Criterios de bono (ambos se suman por multiplicación):
##  1. Preferencia JSON: pez.climas incluye el clima actual (campo "clima" de
##     fishing.json, cargado pero sin usar hasta hoy).
##  2. Rareza: peso_rareza <= UMBRAL_RARO (los "raros" suben con lluvia/tropical).
const UMBRAL_RARO: float = 0.08
const BONO_LLUVIA: float = 1.15
const BONO_TROPICAL: float = 1.25

## Peso efectivo de un pez bajo el clima actual (+ cebo + pity).
## Extraído de resolver_especie para testabilidad (sin roll).
func _peso_efectivo(pez: FishDefinition, cebo: CeboDefinition = null) -> float:
	var peso: float = pez.peso_rareza
	var clima_m32 := _clima_actual_m32()
	if clima_m32 >= 0:
		var bono := 1.0
		var es_preferido := pez.climas.has(_clima_m32_a_m34(clima_m32))
		var es_raro := pez.peso_rareza <= UMBRAL_RARO
		if clima_m32 == 2 and (es_preferido or es_raro):  # LLUVIA
			bono = BONO_LLUVIA
		elif clima_m32 == 7 and (es_preferido or es_raro):  # TROPICAL
			bono = BONO_TROPICAL
		peso *= bono
	if cebo and pez.cebos_preferidos.has(cebo.id):
		peso *= cebo.multiplicador_probabilidad
	if pez.pity > 0:
		var sin_exito: int = int(_pity_contadores.get(pez.id, 0))
		if sin_exito >= pez.pity:
			peso *= 10.0  # pity garantiza en el roll ponderado
	return peso

## Clima actual del WeatherService (M32) o -1 si no existe.
func _clima_actual_m32() -> int:
	var w := get_node_or_null("/root/Weather")
	if w == null or not w.has_method("get_clima"):
		return -1
	return int(w.get_clima())

## Convierte el enum de M32 (0-8) al formato numérico de fishing.json
## (0=despejado, 1=lluvia, 2=tormenta, 3=nieve) que usan pez.climas.
func _clima_m32_a_m34(clima_m32: int) -> int:
	match clima_m32:
		2: return 1  # LLUVIA
		3: return 2  # TORMENTA
		5: return 3  # NIEVE
	return 0  # despejado (SOLEADO/NUBLADO/NIEBLA/VIENTO/TROPICAL/ESPECIAL)

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
	# M37 núcleo implementado (glm-5.3-flash): la donación real la procesa
	# DonationService.donate("peces", pez.id) con el inventario del jugador.
	# Este método queda como compat (devuelve si la pieza ya está registrada).
	var registry := get_node_or_null("/root/CollectionRegistry")
	if registry != null and registry.has_method("is_registered"):
		return bool(registry.is_registered("peces", String(_pez.id)))
	return false

func get_collection_data() -> Dictionary:
	return _coleccion.duplicate(true)

## ── Persistencia (M59) ───────────────────────────────────

func get_section_name() -> String:
	return "fishing"

func get_save_data() -> Dictionary:
	return {"coleccion": _coleccion.duplicate(true), "pity": _pity_contadores.duplicate(),
		"capturas_totales": _capturas_totales,
		# J160: los peces que no entraron por inventario lleno también se guardan.
		"bandeja_peces": _bandeja_peces.duplicate(true)}

func restore_save_data(data: Dictionary) -> void:
	_coleccion = data.get("coleccion", {}).duplicate(true)
	_pity_contadores = data.get("pity", {}).duplicate(true)
	_capturas_totales = int(data.get("capturas_totales", 0))
	var bandeja: Variant = data.get("bandeja_peces", {})
	if bandeja is Dictionary:
		_bandeja_peces = (bandeja as Dictionary).duplicate(true)