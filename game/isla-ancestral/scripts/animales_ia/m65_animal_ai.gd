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
# Pitfalls respetados (GUIA-GODOT/INDICE.md):
#   - Sin class_name (autoload, seccion 9.17)
#   - snake_case en senales
#   - Duck-typing en M36 (fauna) y M29 (TimeCalendar)
#   - Tolerante a fallos: si M36 no esta, no rompe el arranque

extends Node

const BehaviorRef = preload("res://scripts/fauna/fauna_behavior.gd")
## P-38 (Log 1154, agnes-3-flash): revivir PackLogic/SchoolLogic (BUG-080) —
## las logicas de manada/banco vuelven a tener consumidor en produccion.
const PackLogicRef = preload("res://scripts/animales_ia/pack_logic.gd")
const SchoolLogicRef = preload("res://scripts/animales_ia/school_logic.gd")
const SpeciesRef = preload("res://scripts/fauna/fauna_species.gd")

## Mapa: instancia_id -> Dictionary con {nodo, velocidad_actual, destino, tick_acumulado}
var _individuos: Dictionary = {}

## P-38: grupos por especie (gregaria). TERRESTRE -> manada (PackLogic);
## ACUATICA/AEREA/ANFIBIA -> banco (SchoolLogic). Clave: id de especie.
var _packs: Dictionary = {}
var _schools: Dictionary = {}
## P-38: datos de especie para la decision de huida ({radio, vel_huida})
var _especie_datos: Dictionary = {}

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
	# P-38 (Log 1154): si la especie es gregaria, se integra al grupo
	# (manada/banco) — PackLogic/SchoolLogic dejan de estar huérfanas.
	_grupo_agregar(nodo, instancia_id)

## Desregistra un individuo (llamado por M36._exit_tree).
func desregistrar(nodo) -> void:
	if nodo == null:
		return
	var instancia_id: String = String(nodo.instancia_id)
	if _individuos.has(instancia_id):
		_individuos.erase(instancia_id)
		_presupuesto_actual = maxi(0, _presupuesto_actual - 1)
	# P-38 (Log 1154): salir del grupo (manada/banco)
	_grupo_remover(nodo, instancia_id)

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
	# P-38 (Log 1154): comportamiento grupal — manada/banco. La cohesión y la
	# migración emiten `solicitar_movimiento` (ya conectado en registrar()); la
	# huida coordinada sobreescribe el destino de TODO el grupo.
	_grupos_tick(dt, _pos_jugador_actual())

## QA (P-38, Log 1154): tamano del grupo (manada o banco) de una especie.
## Devuelve 0 si la especie no tiene grupo activo.
func grupo_tamanio(especie_id: String) -> int:
	if _packs.has(especie_id):
		return int(_packs[especie_id].tamanio())
	if _schools.has(especie_id):
		return int(_schools[especie_id].tamanio())
	return 0

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

## ── P-38 (Log 1154, agnes-3-flash): grupos manada/banco (PackLogic/SchoolLogic) ──
## Resuelve BUG-080: la logica de manada/banco vuelve a tener consumidor en
## produccion. Regla de clasificacion (datos del catalogo M36):
##   - gregaria + TERRESTRE  -> manada (PackLogic: lider rotativo, cohesion, huida)
##   - gregaria + ACUATICA/AEREA/ANFIBIA -> banco (SchoolLogic: cohesion/
##     alineacion/separacion + migracion coordinada)
## Ambas logics emiten `solicitar_movimiento` (ya conectada en registrar()); la
## huida coordinada sobreescribe el destino de TODO el grupo del mismo tipo.

func _grupo_agregar(nodo, instancia_id: String) -> void:
	var especie = nodo.get("especie")
	if especie == null:
		return
	var especie_id := str(especie.id)
	var gregaria: bool = bool(especie.gregaria)
	if not gregaria:
		return
	var clase: int = int(especie.clase)
	_especie_datos[especie_id] = {
		"radio": float(especie.radio_alarma),
		"vel_huida": float(especie.velocidad_huida),
	}
	if clase == SpeciesRef.Clase.TERRESTRE:
		if not _packs.has(especie_id):
			_packs[especie_id] = PackLogicRef.new()
			print("[M65] Manada (PackLogic) creada para %s" % especie_id)
		_packs[especie_id].agregar(nodo, instancia_id)
	else:
		if not _schools.has(especie_id):
			_schools[especie_id] = SchoolLogicRef.new()
			print("[M65] Banco (SchoolLogic) creado para %s" % especie_id)
		_schools[especie_id].agregar(nodo, instancia_id)

func _grupo_remover(nodo, instancia_id: String) -> void:
	if nodo == null:
		return
	var especie = nodo.get("especie")
	if especie == null:
		return
	var especie_id := str(especie.id)
	var clase: int = int(especie.clase)
	if clase == SpeciesRef.Clase.TERRESTRE and _packs.has(especie_id):
		_packs[especie_id].remover(instancia_id)
	elif _schools.has(especie_id):
		_schools[especie_id].remover(instancia_id)

func _grupos_tick(delta: float, pos_jugador: Vector3) -> void:
	for especie_id in _packs.keys():
		var pack = _packs[especie_id]
		pack.tick(delta, pos_jugador)
		_huir_coordinado_pack(especie_id, pack, pos_jugador)
		if pack.tamanio() == 0:
			_packs.erase(especie_id)
	for especie_id in _schools.keys():
		var school = _schools[especie_id]
		school.tick(delta, pos_jugador)
		# SchoolLogic no tiene limpieza por nodo: si no queda individuo vivo de la
		# especie, se descarta el grupo completo (se re-crea en el proximo registrar)
		if not _tiene_individuo_vivo(especie_id):
			_schools.erase(especie_id)
			continue
		_huir_coordinado_school(especie_id, school, pos_jugador)

func _tiene_individuo_vivo(especie_id: String) -> bool:
	for id in _individuos.keys():
		var d: Dictionary = _individuos[id]
		var nodo = d.nodo
		if nodo == null or not is_instance_valid(nodo):
			continue
		var esp = nodo.get("especie")
		if esp != null and str(esp.id) == especie_id:
			return true
	return false

## Devuelve [id del miembro mas cerca del jugador, su distancia] para la especie.
func _dist_al_jugador(especie_id: String, pos_jugador: Vector3) -> Array:
	var id_cerca := ""
	var dist_cerca := INF
	for id in _individuos.keys():
		var d: Dictionary = _individuos[id]
		var nodo = d.nodo
		if nodo == null or not is_instance_valid(nodo):
			continue
		var esp = nodo.get("especie")
		if esp == null or str(esp.id) != especie_id:
			continue
		var dist: float = nodo.global_position.distance_to(pos_jugador)
		if dist < dist_cerca:
			dist_cerca = dist
			id_cerca = str(id)
	return [id_cerca, dist_cerca]

func _huir_coordinado_pack(especie_id: String, pack, pos_jugador: Vector3) -> void:
	if pos_jugador == Vector3.ZERO:
		return
	var datos: Dictionary = _especie_datos.get(especie_id, {})
	var radio: float = float(datos.get("radio", 4.0))
	var vel_huida: float = float(datos.get("vel_huida", 3.0))
	var cerca := _dist_al_jugador(especie_id, pos_jugador)
	var id_cerca: String = str(cerca[0])
	var dist_cerca: float = float(cerca[1])
	# La decision es de PackLogic (public API): el lider huye si esta dentro del
	# radio; los seguidores si el lider esta marcado huyendo.
	if id_cerca == "" or not pack.debe_huir_coordinado(id_cerca, dist_cerca, radio):
		return
	var destino: Vector3 = pack.destino_huida_coordinada(pos_jugador)
	for id in _individuos.keys():
		var d: Dictionary = _individuos[id]
		var nodo = d.nodo
		if nodo == null or not is_instance_valid(nodo):
			continue
		var esp = nodo.get("especie")
		if esp == null or str(esp.id) != especie_id:
			continue
		d.destino = destino
		d.velocidad = vel_huida
		d.en_movimiento = true
		d.distancia_acumulada = 0.0
	pack.marcar_huyendo(id_cerca, true)
	print("[M65] Huida coordinada de manada %s (dist %.1fm < radio %.0fm)" % [especie_id, dist_cerca, radio])

func _huir_coordinado_school(especie_id: String, school, pos_jugador: Vector3) -> void:
	if pos_jugador == Vector3.ZERO:
		return
	var datos: Dictionary = _especie_datos.get(especie_id, {})
	var radio: float = float(datos.get("radio", 4.0))
	var vel_huida: float = float(datos.get("vel_huida", 3.0))
	var cerca := _dist_al_jugador(especie_id, pos_jugador)
	var dist_cerca: float = float(cerca[1])
	if str(cerca[0]) == "" or not school.debe_huir_banco(dist_cerca, radio):
		return
	var destino: Vector3 = school.destino_huida_banco(pos_jugador)
	for id in _individuos.keys():
		var d: Dictionary = _individuos[id]
		var nodo = d.nodo
		if nodo == null or not is_instance_valid(nodo):
			continue
		var esp = nodo.get("especie")
		if esp == null or str(esp.id) != especie_id:
			continue
		d.destino = destino
		d.velocidad = vel_huida
		d.en_movimiento = true
		d.distancia_acumulada = 0.0
	print("[M65] Huida de banco %s (dist %.1fm < radio %.0fm)" % [especie_id, dist_cerca, radio])

## Duck-typing del jugador: mismo patron que M36 (primer nodo del grupo "player").
func _pos_jugador_actual() -> Vector3:
	var ml := Engine.get_main_loop()
	if ml is SceneTree:
		for n in (ml as SceneTree).get_nodes_in_group("player"):
			if n.has_method("get_global_position"):
				return n.get_global_position()
	return Vector3.ZERO

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
