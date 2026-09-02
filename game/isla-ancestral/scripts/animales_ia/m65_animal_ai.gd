# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M65: Animales-IA - M65AnimalAI (autoload "animal_ai").
# Manager que conecta con M36 (Fauna) y mueve los nodos de animales.
# Reutiliza M36 (fauna) y TimeCalendar (M29) via duck-typing.
# Iter 1 NO reutiliza NPCAgent (M64) directamente porque tiene errores
# pre-existentes en state_machine.gd. La capa M65 es independiente.
#
# RF M65: ejecutar el movimiento real de los animales (deambular, huir,
# alimentarse, descanso) consumiendo la senal `solicitar_movimiento(destino, velocidad)`
# que M36 emite por cada individuo.
#
# Pitfalls respetados (07-GUIA-GODOT):
#   - Sin class_name (autoload, seccion 9.17)
#   - snake_case en senales
#   - Duck-typing en M36 (fauna) y M29 (TimeCalendar)
#   - Tolerante a fallos: si M36 no esta, no rompe el arranque

extends Node

const BehaviorRef = preload("res://scripts/fauna/fauna_behavior.gd")

## Mapa: instancia_id -> Dictionary con {nodo, velocidad_actual, destino, tick_acumulado}
var _individuos: Dictionary = {}

## Presupuesto global de animales (M61: tope de simulacion)
var _presupuesto_max: int = 40
var _presupuesto_actual: int = 0

## Velocidad por defecto si la especie no la define
const VELOCIDAD_POR_DEFECTO: float = 2.0

func _ready() -> void:
	# Conectar a fauna_registry.solicitar_avistamiento (delegada de M36 behavior)
	var registry := _get_fauna_registry()
	if registry != null:
		# M36 ya emite la senal; nosotros no necesitamos reemitirla
		pass
	# Tambien conectar a cualquier fauna_behavior que aparezca (M36 los crea)
	# (no hay API global; se hace via registrar() cuando M36 instancie)

## ── API publica ─────────────────────────────────────────────

## Registra un individuo animal para que reciba movimiento.
## Llamado por M36 cuando crea un fauna_behavior.
func registrar(nodo) -> void:
	if nodo == null or not is_instance_valid(nodo):
		return
	if not (nodo is BehaviorRef):
		return
	var instancia_id: String = String(nodo.instancia_id)
	if instancia_id == "":
		instancia_id = "ai_%d" % Time.get_ticks_msec()
		nodo.instancia_id = instancia_id
	if _individuos.has(instancia_id):
		return
	if _presupuesto_actual >= _presupuesto_max:
		push_warning("[M65] presupuesto maximo alcanzado (%d). Ignorando %s" % [_presupuesto_max, instancia_id])
		return
	_individuos[instancia_id] = {
		"nodo": nodo,
		"destino": Vector3.ZERO,
		"velocidad": VELOCIDAD_POR_DEFECTO,
		"tick_acumulado": 0.0,
		"en_movimiento": false,
		"distancia_acumulada": 0.0,
	}
	_presupuesto_actual += 1
	# Conectar a la senal de movimiento que M36 emite
	if not nodo.solicitar_movimiento.is_connected(_on_solicitar_movimiento):
		nodo.solicitar_movimiento.connect(_on_solicitar_movimiento.bind(instancia_id))

## Desregistra un individuo (llamado por M36._exit_tree).
func desregistrar(nodo) -> void:
	if nodo == null:
		return
	var instancia_id: String = String(nodo.instancia_id)
	if _individuos.has(instancia_id):
		_individuos.erase(instancia_id)
		_presupuesto_actual = maxi(0, _presupuesto_actual - 1)

## Tick del manager. Procesa el movimiento de todos los individuos.
## dt: delta en segundos. Llamar desde el SceneTree principal una vez por frame.
func tick(dt: float) -> void:
	for id in _individuos.keys():
		var data: Dictionary = _individuos[id]
		if not is_instance_valid(data.nodo):
			_individuos.erase(id)
			_presupuesto_actual = maxi(0, _presupuesto_actual - 1)
			continue
		_procesar_individuo(id, data, dt)

## ── RF M65: presupuesto ────────────────────────────────────

func presupuesto_max() -> int:
	return _presupuesto_max

func presupuesto_actual() -> int:
	return _presupuesto_actual

func set_presupuesto_max(n: int) -> void:
	_presupuesto_max = maxi(0, n)

## ── Internos ────────────────────────────────────────────────

func _procesar_individuo(id: String, data: Dictionary, dt: float) -> void:
	var nodo = data.nodo
	if not data.en_movimiento:
		return
	# Mover al destino
	var pos_actual: Vector3 = nodo.global_position
	var destino: Vector3 = data.destino
	var dir: Vector3 = destino - pos_actual
	dir.y = 0
	var dist: float = dir.length()
	if dist < 0.1:
		# Llegamos
		data.en_movimiento = false
		data.distancia_acumulada = 0.0
		return
	dir = dir.normalized()
	var vel: float = data.velocidad
	var step: float = minf(vel * dt, dist)
	# En M65: actualizar posicion (en produccion usaria NavigationServer3D)
	var nueva_pos: Vector3 = pos_actual + dir * step
	nodo.global_position = nueva_pos
	data.distancia_acumulada += step
	# Si llegamos al destino: marcar como inactivo
	if dist - step < 0.05:
		data.en_movimiento = false
		data.distancia_acumulada = 0.0
		return
	# Si el animal acumulo demasiada distancia sin llegar, abortar (anti-stuck)
	if data.distancia_acumulada > 30.0 and dist > 0.5:
		data.en_movimiento = false
		data.distancia_acumulada = 0.0

## Callback de la senal `solicitar_movimiento(destino, velocidad)` que M36 emite.
func _on_solicitar_movimiento(destino: Vector3, velocidad: float, instancia_id: String) -> void:
	if not _individuos.has(instancia_id):
		return
	var data: Dictionary = _individuos[instancia_id]
	data.destino = destino
	data.velocidad = velocidad
	data.en_movimiento = true
	data.distancia_acumulada = 0.0

## ── Persistencia M59 (no requerida para M65; placeholder) ─

func get_section_name() -> String:
	return "m65_animal_ai"

func get_save_data() -> Dictionary:
	return {"version": 1, "presupuesto_max": _presupuesto_max}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < 1:
		return
	_presupuesto_max = int(data.get("presupuesto_max", 40))

## ── Helpers ────────────────────────────────────────────────

func _get_fauna_registry() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("fauna_registry")
