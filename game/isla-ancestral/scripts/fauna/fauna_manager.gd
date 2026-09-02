# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M36: Fauna - FaunaManager (autoload "fauna").
# Orquesta el catalogo + registry + spawner basico. Iter 1 provee el API
# publica principal; el spawner real (con burbuja de 72m + filtros M09/M29/M31)
# se delega a iter 2 cuando M09 (biomas) este implementado.
# Reutiliza:
#   - FaunaCatalog (RefCounted) - inyectable
#   - FaunaRegistry (autoload) - por referencia global
#   - TimeCalendar (autoload M29) - por duck-typing
# No acopla con M65 (Animales-IA) ni M09 (Biomas): usa stubs tolerantes.

extends Node

const CatalogRef = preload("res://scripts/fauna/fauna_catalog.gd")

var catalog = null
var _rng: RandomNumberGenerator = null

## Spawner basico: para tests. Iter 2: M36-Spawner (con filtros M09/M29/M31/M32).
var _individuos: Array = []  # Array de FaunaBehavior (Node3D)

func _ready() -> void:
	catalog = CatalogRef.new()
	catalog.cargar()
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	print("[M36] FaunaManager ready: %d especies en catalogo" % catalog.cantidad())
	# M65: tick del manager de animal_ai cada frame
	set_process(true)

## ── API publica ─────────────────────────────────────────────

## Devuelve la cantidad total de especies en el catalogo.
func cantidad_especies() -> int:
	return catalog.cantidad() if catalog != null else 0

## Devuelve una especie por id (o null).
func obtener_especie(id: StringName):
	return catalog.obtener(id) if catalog != null else null

## Devuelve la lista de especies candidatas para una hora+bioma dados.
## RF B/C: filtrado por ventana horaria y bioma.
func candidatas_para(hora: int, bioma: StringName) -> Array:
	if catalog == null:
		return []
	return catalog.candidatas_para(hora, bioma)

## RF C: muestreo ponderado por rareza. Devuelve una especie aleatoria
## del set de candidatas para hora+bioma. Null si no hay candidatas.
func especie_aleatoria_para(hora: int, bioma: StringName):
	if catalog == null:
		return null
	var candidatas: Array = catalog.candidatas_para(hora, bioma)
	if candidatas.is_empty():
		return null
	# Calcular pesos
	var pesos: Array = []
	for c in candidatas:
		pesos.append(catalog.peso_por_rareza(c.rareza))
	# Muestreo ponderado simple (busqueda lineal)
	var total: float = 0.0
	for p in pesos:
		total += p
	if total <= 0.0:
		return candidatas[0]
	var r: float = _rng.randf() * total
	var acc: float = 0.0
	for i in range(candidatas.size()):
		acc += pesos[i]
		if r <= acc:
			return candidatas[i]
	return candidatas[candidatas.size() - 1]

## RF C: porcentaje de descubrimientos del diario (proxy: M37 Museos).
func porcentaje_descubierto() -> float:
	var registry := _get_registry()
	if registry == null:
		return 0.0
	return registry.porcentaje_descubierto(catalog.cantidad() if catalog != null else 0)

## Registra un avistamiento directamente en el registry (util para tests).
func registrar_avistamiento_test(especie_id: StringName, contexto: Dictionary) -> void:
	var registry := _get_registry()
	if registry != null:
		registry.registrar_avistamiento(especie_id, contexto)

## Estado del diario de fauna (proxy para M37).
func total_avistamientos(especie_id: StringName) -> int:
	var registry := _get_registry()
	if registry == null:
		return 0
	return registry.total_avistamientos(especie_id)

## ── Dedupe de candidatos (util para M36-Spawner iter 2) ─────

## Dada una lista de candidatas + rng, devuelve 1..N individuos segun
## gregaria. No instancia nodos (eso lo hace M65 Animales-IA en iter 2).
func candidatos_de_especie(sp, cantidad: int = 1) -> Array:
	if sp == null or cantidad <= 0:
		return []
	if sp.gregaria:
		var n: int = _rng.randi_range(sp.cantidad_manada_min, sp.cantidad_manada_max)
		cantidad = min(cantidad, n)
	var out: Array = []
	for i in range(cantidad):
		out.append({"especie": sp, "instancia_id": "fauna_%d_%d_%d" % [Time.get_ticks_msec(), _rng.randi(), i]})
	return out

## ── Persistencia M59 (proxy) ────────────────────────────────

## Indica al registro que persista ahora (util para eventos como guardado manual).
func persistir() -> void:
	var registry := _get_registry()
	if registry != null and registry.has_method("guardar_local"):
		registry.guardar_local()

## ── Tick: procesar M65 (animal_ai) cada frame ─────────────

func _process(_delta: float) -> void:
	var ai := _get_animal_ai()
	if ai != null and ai.has_method("tick"):
		ai.tick(_delta)

## ── Internos ────────────────────────────────────────────────

func _get_registry() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("fauna_registry")

func _get_animal_ai() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("animal_ai")
