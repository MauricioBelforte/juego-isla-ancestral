# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M15: Recursos — ResourceManager (autoload "ResourceManager")
# Catalogo data-driven de definiciones de recursos (RF1-RF2).
# Orquesta recoleccion, drops y persistencia. Se comunica por senales con
# M14 (Inventario), M13 (senal golpe_aplicado — pendiente) y M29 (respawn).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

signal drop_recogido(item_id: String, cantidad: int)
signal recurso_agotado(def_id: StringName, pos: Vector3)
signal recoleccion_evento(def_id: StringName, cantidad_total: int, herramienta_id: StringName)

const SECCION_SAVE := "resource_manager"

var _definiciones: Dictionary = {}   # def_id -> ResourceDefinition
var _rng: RandomNumberGenerator
var spawner: ResourceSpawner = null

func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = hash(Time.get_ticks_usec())
	_cargar_definiciones_base()
	_registrar_proveedor_guardado()
	spawner = ResourceSpawner.new(self)
	add_child(spawner)

## ── API pública para spawner ─────────────────────────────

func definir_region(region_id: String, centro: Vector3) -> void:
	if spawner != null:
		spawner.planificar_region(region_id, centro, self)

## Pobla la isla inicial con recursos alrededor de un centro (spawn).
## Se llama desde la escena principal al arrancar (deferred para TerrainLocator listo).
func poblar_isla(centro: Vector3) -> void:
	if spawner != null:
		spawner.planificar_region("isla_raiz", centro, self)

## ── Catalogo data-driven ─────────────────────────────────

func _cargar_definiciones_base() -> void:
	_agregar_def(_madera_roble())
	_agregar_def(_piedra_caliza())
	_agregar_def(_fibra_algodon())
	_agregar_def(_baya_roja())
	_agregar_def(_mineral_cobre())
	_agregar_def(_fragmento_ancestral())

func _agregar_def(def: ResourceDefinition) -> void:
	_definiciones[def.def_id] = def

func obtener_def(def_id: StringName) -> ResourceDefinition:
	return _definiciones.get(def_id, null)

func obtener_todas() -> Array[ResourceDefinition]:
	# Fix (glm-5.3-flash/Cline 2026-09-02): .values() devuelve Array sin tipar y
	# el runtime falla con "Trying to return an array of type Array where
	# expected return type is Array[ResourceDefinition]". Se tipa explícito.
	var res: Array[ResourceDefinition] = []
	for d in _definiciones.values():
		res.append(d)
	return res

func cantidad_de(def_id: StringName) -> int:
	# Consulta para M16 (crafting): cantidad disponible en inventario
	if not _definiciones.has(def_id):
		return 0
	var inv = get_node_or_null("/root/Inventario")
	if inv == null or not inv.has_method("agregar_items"):
		return 0
	# El inventario no tiene metodo "cantidad_de" directo; placeholder
	return 0

## ── Definiciones por defecto (RF1: 6 tipos) ─────────────

func _madera_roble() -> ResourceDefinition:
	var d := ResourceDefinition.new()
	d.def_id = &"madera_roble"
	d.display_name = "Madera de Roble"
	d.categoria = ResourceDefinition.Categoria.MADERA
	d.herramienta_requerida = &"hacha"
	d.golpes_requeridos = 3
	d.temporada_respawn = &"primavera"
	d.valor_venta = 5
	d.drops = [_de("madera_roble", 1, 3, 1.0)]
	return d

func _piedra_caliza() -> ResourceDefinition:
	var d := ResourceDefinition.new()
	d.def_id = &"piedra_caliza"
	d.display_name = "Piedra Caliza"
	d.categoria = ResourceDefinition.Categoria.PIEDRA
	d.herramienta_requerida = &"pico"
	d.golpes_requeridos = 2
	d.temporada_respawn = &"todas"
	d.valor_venta = 3
	d.drops = [_de("piedra_caliza", 1, 2, 1.0)]
	return d

func _fibra_algodon() -> ResourceDefinition:
	var d := ResourceDefinition.new()
	d.def_id = &"fibra_algodon"
	d.display_name = "Fibra de Algodon"
	d.categoria = ResourceDefinition.Categoria.FIBRA
	d.herramienta_requerida = &""
	d.golpes_requeridos = 1
	d.temporada_respawn = &"verano"
	d.valor_venta = 2
	d.drops = [_de("fibra_algodon", 2, 4, 1.0)]
	return d

func _baya_roja() -> ResourceDefinition:
	var d := ResourceDefinition.new()
	d.def_id = &"baya_roja"
	d.display_name = "Baya Roja"
	d.categoria = ResourceDefinition.Categoria.COMIDA
	d.herramienta_requerida = &""
	d.golpes_requeridos = 1
	d.temporada_respawn = &"otono"
	d.valor_venta = 1
	d.drops = [_de("baya_roja", 1, 3, 0.8)]
	return d

func _mineral_cobre() -> ResourceDefinition:
	var d := ResourceDefinition.new()
	d.def_id = &"mineral_cobre"
	d.display_name = "Mineral de Cobre"
	d.categoria = ResourceDefinition.Categoria.MINERAL
	d.rareza = 1
	d.herramienta_requerida = &"pico"
	d.golpes_requeridos = 4
	d.temporada_respawn = &"todas"
	d.valor_venta = 10
	d.drops = [_de("mineral_cobre", 1, 2, 1.0)]
	return d

func _fragmento_ancestral() -> ResourceDefinition:
	var d := ResourceDefinition.new()
	d.def_id = &"fragmento_ancestral"
	d.display_name = "Fragmento Ancestral"
	d.categoria = ResourceDefinition.Categoria.RARO
	d.rareza = 3
	d.herramienta_requerida = &"pico"
	d.golpes_requeridos = 6
	d.temporada_respawn = &"primavera"
	d.evento_respawn = &"festival_cosecha"
	d.region = &"templo"
	d.valor_venta = 50
	d.drops = [_de("fragmento_ancestral", 1, 1, 0.3)]
	return d

func _de(item: String, cant_min: int, cant_max: int, prob: float) -> ResourceDropEntry:
	var e := ResourceDropEntry.new()
	e.item_id = item
	e.cantidad_min = cant_min
	e.cantidad_max = cant_max
	e.probabilidad = prob
	return e

## ── Generacion de drops (RF5) ────────────────────────────

## Genera los drops de un recurso segun su definicion y herramienta usada.
## Devuelve Dict {item_id: cantidad} para enviar a Inventario.agregar_items().
## Si la herramienta no es valida (RF4), devuelve {} (sin drops).
func generar_drops(def_id: StringName, herramienta_id: StringName, mejorada: bool) -> Dictionary:
	var def := obtener_def(def_id)
	if def == null:
		return {}
	if not def.es_accesible_con(herramienta_id, true):
		return {}
	var resultado: Dictionary = {}
	var entradas := def.drops_para_herramienta(mejorada)
	for entrada in entradas:
		if _rng.randf() <= entrada.probabilidad:
			var cant := entrada.cantidad(_rng)
			resultado[entrada.item_id] = resultado.get(entrada.item_id, 0) + cant
	if resultado.is_empty():
		# Garantia anti-frustracion: si probabilidad fallo, dar al menos 1
		resultado[def_id] = 1
	return resultado

## Envia los drops al Inventario (M14) y emite senales.
func entregar_drops(drops: Dictionary, def_id: StringName, herramienta_id: StringName, _mejorada: bool) -> bool:
	var inv = get_node_or_null("/root/Inventario")
	if inv == null or not inv.has_method("agregar_items"):
		return false
	var ok: bool = inv.agregar_items(drops)
	if ok:
		for item_id in drops:
			drop_recogido.emit(String(item_id), int(drops[item_id]))
		var total: int = 0
		for c in drops.values():
			total += int(c)
		recoleccion_evento.emit(def_id, total, herramienta_id)
	return ok

## ── Persistencia (M59) ───────────────────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)
	if _gt_dia_cambio_conectado == false:
		var gt = get_node_or_null("/root/GameTime")
		if gt != null and gt.has_signal("dia_cambio"):
			gt.dia_cambio.connect(_on_dia_cambio_m29)
			_gt_dia_cambio_conectado = true

var _gt_dia_cambio_conectado: bool = false

func _on_dia_cambio_m29(_info: Dictionary) -> void:
	_evaluar_respawn_global()

## RF respawn (M15 iter 3): evalúa todos los nodos activos y los que cumplan
## el ciclo de respawn vuelven a INTACTO.
func _evaluar_respawn_global() -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt == null:
		return
	var dia_actual: int = int(gt.dia_absoluto()) if gt.has_method("dia_absoluto") else 0
	var estacion: int = int(gt.get_estacion()) if gt.has_method("get_estacion") else 0
	for nodo in _nodos_activos:
		if nodo == null or not is_instance_valid(nodo):
			continue
		nodo.evaluar_respawn(dia_actual, estacion)

## API pública para golpe sobre un nodo (M13 / interacción futura).
## Centraliza la validación de herramienta y dispara drops + respawn.
func recibir_golpe_en_nodo(nodo: ResourceNode, herramienta_id: StringName) -> bool:
	if nodo == null or not is_instance_valid(nodo):
		return false
	var def := obtener_def(nodo.def_id)
	if def == null:
		return false
	if not def.es_accesible_con(herramienta_id, true):
		return false
	var antes_estado: int = nodo.estado
	if not nodo.aplicar_golpe(herramienta_id):
		return false
	if antes_estado != ResourceNode.Estado.AGOTADO and nodo.estado == ResourceNode.Estado.AGOTADO:
		# Programar respawn
		var gt = get_node_or_null("/root/GameTime")
		if gt != null and gt.has_method("dia_absoluto"):
			nodo.programar_respawn(int(gt.dia_absoluto()) + maxi(1, def.dias_para_respawn))
		var drops: Dictionary = generar_drops(nodo.def_id, herramienta_id, false)
		entregar_drops(drops, nodo.def_id, herramienta_id, false)
		recurso_agotado.emit(nodo.def_id, nodo.global_position)
		if nodo.esta_listo_para_respawn():
			_evaluar_respawn_global()
	return true

var _nodos_activos: Array = []

## Registra un nodo en el manager (lo llama ResourceSpawner al instanciar).
func registrar_nodo(nodo: ResourceNode) -> void:
	if nodo != null and nodo not in _nodos_activos:
		_nodos_activos.append(nodo)

## Desregistra un nodo (al respawnear se reemplaza; al cerrar escena).
func desregistrar_nodo(nodo: ResourceNode) -> void:
	_nodos_activos.erase(nodo)

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	# M15 iter 3: persistencia real — estado de cada nodo activo
	var nodos_data: Array = []
	for nodo in _nodos_activos:
		if nodo == null or not is_instance_valid(nodo):
			continue
		nodos_data.append({
			"def_id": String(nodo.def_id),
			"pos": [nodo.global_position.x, nodo.global_position.y, nodo.global_position.z],
			"estado": nodo.estado,
			"golpes_restantes": nodo.golpes_restantes,
			"respawn_dia": nodo.respawn_dia_absoluto,
		})
	return {"version": 2, "nodos": nodos_data}

func restore_save_data(data: Dictionary) -> void:
	# La restauración completa (re-instanciar nodos en sus posiciones) ocurre
	# tras el spawn inicial. Aquí marcamos los flags para que el spawner
	# aplique el estado guardado cuando cree los nodos.
	if int(data.get("version", 0)) < 2:
		return
	_estado_guardado_pendiente = data.get("nodos", [])

var _estado_guardado_pendiente: Array = []

## Consumido por ResourceSpawner al planificar: aplica el estado guardado
## a los nodos recién creados. Devuelve un dict def_id+pos -> estado.
func consumir_estado_guardado_para(def_id: String, pos: Vector3) -> Dictionary:
	if _estado_guardado_pendiente.is_empty():
		return {}
	for i in range(_estado_guardado_pendiente.size() - 1, -1, -1):
		var nd: Dictionary = _estado_guardado_pendiente[i]
		if String(nd.get("def_id", "")) != def_id:
			continue
		var p: Array = nd.get("pos", [])
		if p.size() != 3:
			continue
		var d: float = Vector3(p[0], p[1], p[2]).distance_to(pos)
		if d < 0.5:
			_estado_guardado_pendiente.remove_at(i)
			return nd
	return {}