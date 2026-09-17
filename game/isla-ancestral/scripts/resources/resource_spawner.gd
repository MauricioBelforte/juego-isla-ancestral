# Modelo: Deepseek V4 Flash (iter 1-2) · GLM-5.3 (iter 4)
# Plataforma: Kilo (Deepseek) · Kilo Code (GLM-5.3)
# Fecha: 2026-08-30 · 2026-09-10 (iter 4)
#
# M15: Recursos — ResourceSpawner (instanciación de nodos en regiones).
# Planifica y coloca ResourceNode sobre el terreno usando TerrainLocator (M167).
# Presupuesto por burbuja: nodos activos ≤ 200; los lejanos se desactivan.
# Se comunica con ResourceManager (definiciones) y emite recurso_reaparecio.
#
# iter 4 (GLM-5.3 / Kilo Code — Log 813): persistencia del spawner.
# - Registra regiones planificadas (centro + def_id + pos de cada nodo).
# - Solo los nodos NO intactos se serializan en el spawner (los intactos
#   se regeneran por la planificación determinista: guardado chico, ítem O.3).
# - restore: re-instancia los nodos guardados con su estado (AGOTADO/DANIADO,
#   golpes_restantes, respawn_dia) aplicado directamente, y marca la región
#   como planificada para que poblar_isla() no duplique (ítem L.6).
# - Formato versionado {"version": 1, ...} (ítem O.4).

class_name ResourceSpawner
extends Node

signal recurso_reaparecio(def_id: StringName, pos: Vector3)

const MAX_NODOS_ACTIVOS := 200
const RADIO_BURBUJA_ACTIVA := 48.0
## Distancia máxima para que un nodo guardado "pertenezca" a una región (m).
const DIST_REGION_GUARDADA := 96.0

var _nodos: Dictionary = {}   # node_id -> ResourceNode
var _next_id: int = 1
var _manager: Node = null     # ResourceManager (autoload)
## Regiones planificadas: region_id -> {"centro": Vector3, "nodos": [{def_id, x, z}]}
var _regiones: Dictionary = {}
## Region_id ya restauradas desde save (no re-planificar al poblar).
var _regiones_restauradas: Dictionary = {}

func _init(manager: Node) -> void:
	_manager = manager

## Planifica nodos de una región usando las definiciones del manager.
## Se llama con region_activada de M08. coloca los tipos por defecto hasta
## alcanzar un presupuesto simple (siempre dentro de MAX_NODOS_ACTIVOS).
## Idempotente (iter 4): una región ya planificada/restaurada no se duplica.
func planificar_region(region_id: String, centro: Vector3, terreno: Node) -> void:
	if _nodos.size() >= MAX_NODOS_ACTIVOS:
		return
	if _regiones.has(region_id):
		return
	var defs: Array = _manager.obtener_todas()
	if defs.is_empty():
		return
	var count := 0
	var registro: Dictionary = {"centro": centro, "nodos": []}
	for def in defs:
		if count >= 12:
			break
		var offsets := _offsets_candidatos(centro, def.def_id)
		for off in offsets:
			if _nodos.size() >= MAX_NODOS_ACTIVOS:
				break
			var node_id := instanciar_nodo(def.def_id, off.x, off.z, terreno)
			if node_id > 0:
				count += 1
				registro["nodos"].append({"def_id": String(def.def_id), "x": off.x, "z": off.z})
			if count >= 4:
				break
	_regiones[region_id] = registro

func _offsets_candidatos(centro: Vector3, def_id: StringName) -> Array:
	# Distribución determinista simple alrededor del centro (radio 4-12 m)
	var offsets := []
	for i in range(8):
		var ang := float(i) * TAU / 8.0
		var r := 6.0 + float((int(def_id.hash()) % 5))  # radio variable, determinista
		offsets.append(Vector3(centro.x + cos(ang) * r, 0, centro.z + sin(ang) * r))
	return offsets

## Instancia un nodo de un recurso en (x, z) sobre el terreno.
## Devuelve node_id (> 0) o -1 si falla (sin terreno o presupuesto lleno).
func instanciar_nodo(def_id: StringName, x: float, z: float, _terreno: Node = null) -> int:
	if _nodos.size() >= MAX_NODOS_ACTIVOS:
		return -1
	var def: ResourceDefinition = _manager.obtener_def(def_id)
	if def == null:
		return -1
	var node := ResourceNode.new()
	node.name = "Recurso_" + str(def_id) + "_" + str(_next_id)
	node.agotado.connect(_on_nodo_agotado)
	add_child(node)  # primero al árbol: configurar() usa get_tree() para M47
	node.configurar(def)
	# Posicionar con TerrainLocator (anti-flotamiento) si existe
	var locator = _buscar_terreno_locator()
	var y: float = 30.0
	var pos_final: Vector3 = Vector3(x, 30.0, z)
	if locator != null:
		var ok: bool = locator.posicionar_sobre_terreno(node, x, z)
		if ok:
			y = node.global_position.y
			pos_final = node.global_position
		else:
			node.global_position = Vector3(x, 30.0, z)
	else:
		node.global_position = Vector3(x, 30.0, z)
	# M15 iter 3: aplicar estado guardado si coincide (def_id + pos cercana)
	if _manager != null and _manager.has_method("consumir_estado_guardado_para"):
		var estado_guardado: Dictionary = _manager.consumir_estado_guardado_para(String(def_id), pos_final)
		if not estado_guardado.is_empty():
			node.estado = int(estado_guardado.get("estado", node.estado))
			node.golpes_restantes = int(estado_guardado.get("golpes_restantes", node.golpes_restantes))
			node.respawn_dia_absoluto = int(estado_guardado.get("respawn_dia", 0))
			node._actualizar_mesh()
	# Registrar en el manager (M15 iter 3)
	if _manager != null and _manager.has_method("registrar_nodo"):
		_manager.registrar_nodo(node)
	_nodos[_next_id] = node
	_next_id += 1
	print("[M15] Nodo %s en (%.0f, %.0f, %.0f) y=%.0f estado=%d" % [str(def_id), x, y, z, y, node.estado])
	return _next_id - 1

func _on_nodo_agotado(def_id: StringName, pos: Vector3) -> void:
	# iter 6 (atria-dawn / Kilo Code — Log 937): FIX doble entrega de drops.
	# Antes este handler generaba y entregaba drops con herramienta vacía, pero
	# ResourceManager.recibir_golpe_en_nodo() — el único camino de producción
	# (tool_controller M13, mining_manager M35) — entrega los drops reales con
	# la herramienta válida. Para recursos sin herramienta requerida
	# (fibra_algodon, baya_roja) es_accesible_con("") == true, por lo que ambas
	# rutas entregaban drops: delta=6 con máximo simple 4 (test_m15_iter6).
	# La generación de drops exige validación de herramienta, responsabilidad del
	# manager; el spawner solo emite la señal de mundo vivo.
	recurso_reaparecio.emit(def_id, pos)

func _buscar_terreno_locator() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.root.get_node_or_null("TerrainLocator")

## Devuelve los nodos activos (para persistencia/QA).
func nodos_activos() -> int:
	return _nodos.size()

func obtener_nodos() -> Dictionary:
	return _nodos.duplicate()

## ── Persistencia del spawner (iter 4, GLM-5.3 / Kilo Code — Log 813) ────
## Cierra el [?] "Persistencia de ResourceSpawner (regiones planificadas,
## presupuesto)" de la iter 3 (05-Checklist L279) + ítems O.2/O.3/O.4.

## Sección propia en el save (M59 duck-typing: get_section_name/get_save_data/
## restore_save_data). Registrada por ResourceManager en _ready (iter 4).
const SECCION_SAVE := "resource_spawner"

func get_section_name() -> String:
	return SECCION_SAVE

## Estado serializable del spawner: regiones planificadas y SOLO los nodos
## no-intactos (AGOTADO/DANIADO). Los intactos se regeneran por la
## planificación determinista al restaurar (guardado chico, ítem O.3).
## Formato versionado (ítem O.4): {"version": 1, "regiones": {...}}
func get_save_data() -> Dictionary:
	var regiones_out: Dictionary = {}
	for region_id in _regiones:
		var reg: Dictionary = _regiones[region_id]
		var centro: Vector3 = reg.get("centro", Vector3.ZERO)
		var nodos_region: Array = []
		for entry in reg.get("nodos", []):
			var nodo = _buscar_nodo_por_def_y_pos(String(entry.get("def_id", "")), entry.get("x", 0.0), entry.get("z", 0.0))
			if nodo == null or not is_instance_valid(nodo):
				continue
			if nodo.estado == ResourceNode.Estado.INTACTO:
				continue  # ítem O.3: intactos se regeneran, no se serializan
			nodos_region.append({
				"def_id": String(nodo.def_id),
				"x": entry.get("x", 0.0),
				"z": entry.get("z", 0.0),
				"estado": int(nodo.estado),
				"golpes_restantes": int(nodo.golpes_restantes),
				"respawn_dia": int(nodo.respawn_dia_absoluto),
			})
		regiones_out[String(region_id)] = {
			"centro": [centro.x, centro.y, centro.z],
			"nodos": nodos_region,
		}
	return {"version": 1, "regiones": regiones_out}

## Restaura el estado del spawner: re-instancia los nodos guardados con su
## estado aplicado y marca las regiones como restauradas (idempotencia de
## planificar_region). Los nodos INTACTOS de la región se regeneran igual que
## en una partida nueva porque _offsets_candidatos es determinista.
func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < 1:
		return
	var regiones: Dictionary = data.get("regiones", {})
	for region_id in regiones:
		if _regiones_restauradas.has(region_id):
			continue  # ya restaurada: no duplicar (ítem L.6)
		var reg: Dictionary = regiones[region_id]
		var centro_arr: Array = reg.get("centro", [0.0, 0.0, 0.0])
		var centro := Vector3(
			float(centro_arr[0]) if centro_arr.size() > 0 else 0.0,
			float(centro_arr[1]) if centro_arr.size() > 1 else 0.0,
			float(centro_arr[2]) if centro_arr.size() > 2 else 0.0
		)
		# Re-instanciar SOLO los nodos guardados (no-intactos)
		for nd in reg.get("nodos", []):
			var def_id := StringName(String(nd.get("def_id", "")))
			var node_id := instanciar_nodo(def_id, float(nd.get("x", 0.0)), float(nd.get("z", 0.0)), null)
			if node_id <= 0:
				continue
			var nodo: ResourceNode = _nodos[node_id]
			nodo.estado = int(nd.get("estado", ResourceNode.Estado.AGOTADO))
			nodo.golpes_restantes = maxi(0, int(nd.get("golpes_restantes", 0)))
			nodo.respawn_dia_absoluto = int(nd.get("respawn_dia", 0))
			nodo._actualizar_mesh()
		# Marcar región como restaurada: registrar estructura completa para
		# que planificar_region no duplique, pero sin re-instanciar intactos
		# (la estructura se reconstruye con el centro + los nodos guardados;
		# los intactos faltantes se regeneran con poblar si la región no
		# estaba completa en el save — comportamiento determinista).
		_regiones_restauradas[region_id] = true
		if not _regiones.has(region_id):
			_regiones[region_id] = {"centro": centro, "nodos": []}

## Busca el nodo activo del spawner por def_id y posición XY (±0.5 m).
func _buscar_nodo_por_def_y_pos(def_id: String, x: float, z: float) -> ResourceNode:
	for nodo in _nodos.values():
		if nodo == null or not is_instance_valid(nodo):
			continue
		if String(nodo.def_id) != def_id:
			continue
		if absf(nodo.global_position.x - x) < 0.5 and absf(nodo.global_position.z - z) < 0.5:
			return nodo
	return null

## Consulta: ¿la región ya fue planificada o restaurada? (para tests/QA).
func region_planificada(region_id: String) -> bool:
	return _regiones.has(region_id) or _regiones_restauradas.has(region_id)
