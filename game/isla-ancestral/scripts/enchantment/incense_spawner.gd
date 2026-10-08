# M163 - Sistema de Encantamientos (iter. 2, seccion C: Incienso)
# IncenseSpawner — Node3D que genera los puntos de incienso en la montaña de
# la Isla Raiz (C6/C7), los renueva cada 3 dias de juego via GameTime (C8) y
# garantiza un punto raro en cada cambio de estación (C3/C12, M29).
#
# Reglas de oro aplicadas (M167/P-39):
#  - NUNCA se hardcodea el radio ni el centro de la isla: el centro de la
#    montaña sale de MundoRaiz.CENTRO (misma formula que _crear_shaman) y las
#    alturas SIEMPRE de TerrainLocator.get_height().
#  - Coordenada local de la montaña (no es centro/radio de isla): misma
#    referencia que el campamento del chaman (240/260 respecto al centro).
extends Node3D
class_name IncenseSpawner

## Puntos iniciales generados (normales).
const CANT_PUNTOS: int = 6
## Dispersion local alrededor del campamento de montaña (metros).
## Distinto al radio de la isla: es la zona de recoleccion del chaman.
const RADIO_DISTRIB: float = 40.0
## Semillas fijas -> spawneo determinista entre sesiones.
const SEMILLA_PUNTOS: int = 163
const SEMILLA_RARO: int = 164

## Centro de la montaña. Vector2.ZERO => se resuelve en _ready desde MundoRaiz.
## Inyectable antes de add_child() para tests.
var centro_montana: Vector2 = Vector2.ZERO

var _rng := RandomNumberGenerator.new()
var _puntos: Array = []
var _creados: int = 0
var _fallas_altura: int = 0
## Locator inyectable (tests). Solo se resuelve de /root si sigue en null.
var _locator = null

## BUG-119 (fix defensivo autorizado, msg 57): en arranque diferido
## (bootstrap.change_scene_to_file) el spawner nace ANTES de que
## TerrainLocator resuelva el VoxelTerrain -> get_height devuelve -1 y el
## spawn sincronico queda en 0 puntos. Se reintenta (patron M50:
## vegetation_spawner espera a que el locator tenga terreno) hasta el
## timeout, sin tocar el flujo del terreno ni el comportamiento cuando el
## locator ya responde al primer intento (tests/arranque normal intactos).
const TIMEOUT_REINTENTOS_MS: int = 8000
var _t_inicio_reintentos: int = -1
var _reintentando: bool = false

func _ready() -> void:
	set_process(false)  # solo procesa mientras reintenta el spawn inicial
	_rng.seed = SEMILLA_PUNTOS
	if centro_montana == Vector2.ZERO:
		centro_montana = _centro_de_mundo()
	if _locator == null:
		_locator = get_node_or_null("/root/TerrainLocator")
	_spawneear(CANT_PUNTOS, false)
	if _puntos.is_empty():
		_t_inicio_reintentos = Time.get_ticks_msec()
		_reintentando = true
		set_process(true)
	var gt := _game_time()
	if gt != null:
		if not gt.dia_cambio.is_connected(_on_dia_cambio):
			gt.dia_cambio.connect(_on_dia_cambio)
		if not gt.estacion_cambio.is_connected(_on_estacion_cambio):
			gt.estacion_cambio.connect(_on_estacion_cambio)

## Reintento del spawn inicial (BUG-119): 1 intento por frame (patron M50,
## vegetation_spawner) - NO usar call_deferred recursivo: en Godot 4 puede
## re-procesarse en el mismo flush del MessageQueue y la recursion infinita
## revienta el proceso con SIGSEGV (medido). Solo se llama _spawneear cuando
## el locator ya responde en el centro de la montaña, para no acumular
## warnings por frame. Si se agota el timeout se conserva el estado honesto
## de 0 puntos (el warning del intento sincronico inicial ya quedo impreso).
func _process(_delta: float) -> void:
	if not _reintentando:
		return
	if not is_inside_tree():
		_reintentando = false
		set_process(false)
		return
	if Time.get_ticks_msec() - _t_inicio_reintentos > TIMEOUT_REINTENTOS_MS:
		_reintentando = false
		set_process(false)
		push_warning("[M163] IncenseSpawner: spawn inicial agotado tras %d ms sin respuesta del terreno"
				% TIMEOUT_REINTENTOS_MS)
		return
	if _locator == null:
		_locator = get_node_or_null("/root/TerrainLocator")
	if _locator != null and _altura(centro_montana.x, centro_montana.y) >= 0:
		_reintentando = false
		set_process(false)
		_spawneear(CANT_PUNTOS, false)

## ── Handlers de tiempo (C8/C12) ─────────────────────────────

## Renuevan todos los puntos agotados con 3+ dias (C8).
func _on_dia_cambio(_info: Dictionary) -> void:
	var dia := _dia_actual()
	for p in _puntos:
		p.renovar(dia)

## Al cambiar de estación (M29): renuevan agotados + aparece un punto raro
## si no hay ninguno activo (C3/C12).
func _on_estacion_cambio(_est: int) -> void:
	var dia := _dia_actual()
	for p in _puntos:
		p.renovar(dia)
	if not _hay_raro_activo():
		_rng.seed = SEMILLA_RARO
		_spawneear(1, true)

# ── Spawneo ───────────────────────────────────────────────────

func _spawneear(cant: int, raro: bool) -> void:
	var script = load("res://scripts/enchantment/incense_point.gd")
	if script == null:
		push_warning("[M163] IncensePoint script no encontrado")
		return
	var creados := 0
	var intentos := 0
	while creados < cant and intentos < cant * 4:
		intentos += 1
		var ang := _rng.randf_range(0.0, TAU)
		var dist := sqrt(_rng.randf_range(0.0, 1.0)) * RADIO_DISTRIB
		var x: float = centro_montana.x + cos(ang) * dist
		var z: float = centro_montana.y + sin(ang) * dist
		var h := _altura(x, z)
		if h < 0:
			_fallas_altura += 1
			continue
		var p = script.new()
		p.name = ("InciensoRaro" if raro else "Incienso") + str(_creados)
		p.raro = raro
		add_child(p)
		p.global_position = Vector3(x, float(h) + 1.0, z)
		_puntos.append(p)
		_creados += 1
		creados += 1
	if creados == 0:
		push_warning("[M163] IncenseSpawner: 0 puntos creados (%d fallas de altura en centro %s)"
				% [_fallas_altura, str(centro_montana)])
	else:
		print("[M163] IncenseSpawner: %d puntos en montaña (%d fallas de altura, centro %s)"
				% [_puntos.size(), _fallas_altura, str(centro_montana)])

## Altura del terreno via TerrainLocator. Devuelve -1 si no hay locator o la
## geometria voxel no responde (nunca se inventa altura ni se hardcodea nada).
func _altura(x: float, z: float) -> int:
	if _locator != null and _locator.has_method("get_height"):
		return int(_locator.get_height(int(round(x)), int(round(z))))
	return -1

func _hay_raro_activo() -> bool:
	for p in _puntos:
		if p.raro and p.estado == 0:
			return true
	return false

# ── Helpers publicos (tests / integracion) ────────────────────

func puntos() -> Array:
	return _puntos

func puntos_raros() -> Array:
	var out: Array = []
	for p in _puntos:
		if p.raro:
			out.append(p)
	return out

func fallas_altura() -> int:
	return _fallas_altura

func _centro_de_mundo() -> Vector2:
	# Misma formula que _crear_shaman() en main_island.gd: campamento de la
	# montaña, derivado de MundoRaiz.CENTRO (sin radio de isla propio).
	var m = get_node_or_null("/root/MundoRaiz")
	if m != null:
		return Vector2(m.CENTRO.x - 240.0, m.CENTRO.y - 260.0)
	return Vector2(320.0, 300.0)

func _game_time() -> Node:
	var ml = Engine.get_main_loop()
	if ml == null:
		return null
	return ml.root.get_node_or_null("GameTime")

func _dia_actual() -> int:
	var gt = _game_time()
	if gt != null and gt.has_method("dia_absoluto"):
		return int(gt.dia_absoluto())
	return 0
